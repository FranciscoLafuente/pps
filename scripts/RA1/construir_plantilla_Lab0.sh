#!/usr/bin/env bash
# construir_plantilla.sh - Prepara pps-core a partir de una imagen LIMPIA de
# Ubuntu 26.04 LTS (sin Java, sin Docker, sin herramientas) como plantilla del
# modulo PPS. Es un script SOLO PARA EL PROFESORADO.
# Requisitos: Internet, ejecucion como root (sudo) y un usuario sin privilegios ya creado.
# Uso:  sudo env USUARIO=pps bash construir_plantilla.sh
# Variables opcionales:
#   ESCRITORIO=auto|si|no  (por defecto auto) Si la imagen no trae escritorio grafico,
#                          "si" instala ubuntu-desktop-minimal (varios GB; tarda).
#   IMAGENES="img1 img2"   Imagenes de contenedor que se descargan ahora para poder
#                          usarlas despues en modo laboratorio (sin Internet).
# Es repetible: se puede volver a ejecutar sin romper nada.
# NO PROBADO en una maquina real con Ubuntu 26.04: revisa cada fase al ejecutarla.

set -euo pipefail

USUARIO="${USUARIO:-pps}"
ESCRITORIO="${ESCRITORIO:-auto}"
IMAGENES="${IMAGENES:-}"

if [ "$(id -u)" -ne 0 ]; then
    echo "Ejecuta con sudo." >&2
    exit 2
fi
if ! id "$USUARIO" >/dev/null 2>&1; then
    echo "El usuario $USUARIO no existe. Crealo en la instalacion o con adduser." >&2
    exit 2
fi
if ! grep -q '^VERSION_ID="26.04"' /etc/os-release; then
    echo "Este script esta pensado para Ubuntu 26.04 LTS." >&2
    exit 2
fi
case "$ESCRITORIO" in auto|si|no) ;; *) echo "ESCRITORIO debe ser auto, si o no." >&2; exit 2 ;; esac

# Si se vuelve a ejecutar con el modo laboratorio activo, se levanta la barrera
# de salida solo para esta ejecucion (al final se vuelve a activar).
if systemctl is-active --quiet pps-laboratorio.service 2>/dev/null; then
    systemctl stop pps-laboratorio.service
    echo "Modo laboratorio desactivado temporalmente para poder descargar paquetes."
fi

echo "== 1/7 Nombre de la maquina =="
hostnamectl set-hostname pps-core

echo "== 2/7 Paquetes base, JDK 21 y Python =="
export DEBIAN_FRONTEND=noninteractive
apt-get update
# La imagen es limpia: se instala explicitamente todo lo que el laboratorio necesita.
# openjdk-21-jdk esta en "universe"; el JDK por defecto de 26.04 es el 25 (verificar).
apt-get install -y ca-certificates curl git nftables binutils unzip \
    python3 python3-venv python3-pip openjdk-21-jdk
# Si hay varios JDK, deja el 21 como predeterminado para que java y javac coincidan
JDK21="$(update-alternatives --list java 2>/dev/null | grep 'java-21' | head -n 1 || true)"
if [ -n "$JDK21" ]; then
    update-alternatives --set java "$JDK21"
    update-alternatives --set javac "${JDK21%/java}/javac" 2>/dev/null || true
fi

echo "== 3/7 Docker Engine desde el repositorio oficial (clave propia del repositorio) =="
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
cat > /etc/apt/sources.list.d/docker.sources <<DOCKER_EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
DOCKER_EOF
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker "$USUARIO"

# Comprobacion de Docker mientras aun hay Internet (modo mantenimiento)
docker run --rm hello-world >/dev/null
echo "Docker funciona: hello-world ejecutado correctamente."

for imagen in $IMAGENES; do
    echo "Descargando imagen: $imagen"
    docker pull "$imagen"
done

echo "== 4/7 Escritorio grafico =="
hay_escritorio() {
    dpkg -s gdm3 >/dev/null 2>&1 || dpkg -s ubuntu-desktop-minimal >/dev/null 2>&1 \
        || dpkg -s ubuntu-desktop >/dev/null 2>&1
}
if hay_escritorio; then
    echo "La imagen ya trae escritorio grafico: no se instala nada."
elif [ "$ESCRITORIO" = "si" ]; then
    apt-get install -y ubuntu-desktop-minimal
    systemctl set-default graphical.target
    echo "Escritorio instalado. Hace falta reiniciar para verlo."
elif [ "$ESCRITORIO" = "no" ]; then
    echo "Sin escritorio por peticion (ESCRITORIO=no)."
else
    echo "AVISO: la imagen no trae escritorio grafico. Las practicas con navegador"
    echo "(por ejemplo Juice Shop) lo necesitan. Reejecuta con ESCRITORIO=si para instalarlo."
fi

echo "== 5/7 Herramientas del modulo =="
install -d /etc/pps

cat > /etc/pps/laboratorio.nft <<'PPS_EOF_NFT'
# /etc/pps/laboratorio.nft - Modo laboratorio de PPS.
# Impide abrir conexiones NUEVAS hacia fuera de esta maquina.
# Es una barrera de conducta, no un aislamiento: quien tiene root puede quitarla.
table inet pps_lab
delete table inet pps_lab

table inet pps_lab {
    chain salida {
        type filter hook output priority -10; policy accept;
        oifname "lo" accept
        # Renovacion de la direccion por DHCP (si no, la maquina perderia la IP)
        udp sport 68 udp dport 67 accept
        # Contenedores que hablan con el anfitrion por sus puentes internos
        oifname "docker0" accept
        oifname "br-*" accept
        ct state new counter drop comment "PPS: sin salida nueva en modo laboratorio"
    }
    chain reenvio {
        type filter hook forward priority -10; policy accept;
        # Trafico entre contenedores (puentes de Docker): permitido
        iifname { "docker0", "br-*" } oifname { "docker0", "br-*" } accept
        # Todo lo que intente salir de los contenedores hacia fuera: bloqueado
        iifname { "docker0", "br-*" } ct state new counter drop comment "PPS: contenedores sin salida"
    }
}
PPS_EOF_NFT
chmod 0644 /etc/pps/laboratorio.nft

cat > /etc/systemd/system/pps-laboratorio.service <<'PPS_EOF_UNIT'
[Unit]
Description=PPS: modo laboratorio (sin conexiones nuevas hacia fuera)
Documentation=file:///etc/pps/laboratorio.nft
Wants=network-pre.target
Before=network-pre.target shutdown.target
Conflicts=shutdown.target
DefaultDependencies=no

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/sbin/nft -f /etc/pps/laboratorio.nft
ExecStop=-/usr/sbin/nft delete table inet pps_lab

[Install]
WantedBy=sysinit.target
PPS_EOF_UNIT
chmod 0644 /etc/systemd/system/pps-laboratorio.service

cat > /etc/systemd/system/pps-identidad.service <<'PPS_EOF_ID'
[Unit]
Description=PPS: generar claves de host SSH si faltan (primer arranque de un clon)
ConditionPathExists=/usr/sbin/sshd
ConditionPathExists=!/etc/ssh/ssh_host_ed25519_key
Before=ssh.service ssh.socket
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/bin/ssh-keygen -A
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
PPS_EOF_ID
chmod 0644 /etc/systemd/system/pps-identidad.service

cat > /usr/local/sbin/pps-modo <<'PPS_EOF_MODO'
#!/usr/bin/env bash
# pps-modo - Alterna entre modo MANTENIMIENTO y modo LABORATORIO en pps-core.
#   mantenimiento : sin restricciones de salida (apt, docker pull, descargas).
#   laboratorio   : no se abren conexiones NUEVAS hacia fuera de esta maquina.
# Uso: sudo pps-modo [estado|mantenimiento|laboratorio]
# Es una barrera de conducta, no un aislamiento: quien tiene root puede quitarla.

UNIDAD="pps-laboratorio.service"
REGLAS="/etc/pps/laboratorio.nft"

modo_actual() {
    if systemctl is-active --quiet "$UNIDAD"; then
        echo "LABORATORIO"
    else
        echo "MANTENIMIENTO"
    fi
}

necesita_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Este cambio requiere privilegios: ejecuta  sudo pps-modo $1" >&2
        exit 2
    fi
}

accion="${1:-estado}"
case "$accion" in
    estado)
        echo "Modo actual: $(modo_actual)"
        ;;
    laboratorio)
        necesita_root "$accion"
        [ -r "$REGLAS" ] || { echo "No se encuentra $REGLAS" >&2; exit 1; }
        systemctl enable --now "$UNIDAD" || exit 1
        echo "Modo actual: $(modo_actual)  (se mantiene tras reiniciar)"
        ;;
    mantenimiento)
        necesita_root "$accion"
        systemctl disable --now "$UNIDAD" || exit 1
        echo "Modo actual: $(modo_actual)  (se mantiene tras reiniciar)"
        echo "Recuerda volver a 'laboratorio' antes de usar herramientas dinamicas."
        ;;
    *)
        echo "Uso: sudo pps-modo [estado|mantenimiento|laboratorio]" >&2
        exit 64
        ;;
esac
PPS_EOF_MODO
chmod 0755 /usr/local/sbin/pps-modo

cat > /usr/local/sbin/pps-preparar-plantilla <<'PPS_EOF_PREP'
#!/usr/bin/env bash
# pps-preparar-plantilla - Deja el sistema listo para convertirlo en plantilla.
# Borra la identidad de ESTA maquina (claves de host SSH e identificador de
# maquina), los historiales y la cache de paquetes, y apaga el sistema.
# En el primer arranque posterior, pps-identidad.service y systemd la regeneran.
# Uso: sudo pps-preparar-plantilla
# Pruebas: PPS_RAIZ=/ruta/falsa PPS_SIN_APAGAR=1 pps-preparar-plantilla

RAIZ="${PPS_RAIZ:-}"

if [ -z "$RAIZ" ] && [ "$(id -u)" -ne 0 ]; then
    echo "Ejecuta: sudo pps-preparar-plantilla" >&2
    exit 2
fi

if [ -z "${PPS_CONFIRMADO:-}" ]; then
    echo "Esto borrara la identidad de esta maquina (claves SSH, machine-id)"
    echo "y apagara el sistema. Tu sesion se cerrara."
    printf "Escribe PREPARAR para continuar: "
    read -r respuesta
    [ "$respuesta" = "PREPARAR" ] || { echo "Cancelado."; exit 1; }
fi

echo "1/5 Borrando claves de host SSH..."
rm -f "$RAIZ"/etc/ssh/ssh_host_*

echo "2/5 Vaciando el identificador de maquina..."
: > "$RAIZ/etc/machine-id"
# En Ubuntu, /var/lib/dbus/machine-id debe ser un enlace a /etc/machine-id
if [ -e "$RAIZ/var/lib/dbus/machine-id" ] && [ ! -L "$RAIZ/var/lib/dbus/machine-id" ]; then
    rm -f "$RAIZ/var/lib/dbus/machine-id"
    ln -s /etc/machine-id "$RAIZ/var/lib/dbus/machine-id"
fi

echo "3/5 Limpiando historiales de la shell..."
for d in "$RAIZ"/root "$RAIZ"/home/*; do
    [ -d "$d" ] && rm -f "$d/.bash_history"
done

echo "4/5 Limpiando la cache de paquetes..."
if [ -z "$RAIZ" ]; then
    apt-get clean
    journalctl --rotate >/dev/null 2>&1
    journalctl --vacuum-time=1s >/dev/null 2>&1
fi

echo "5/5 Listo."
if [ -z "${PPS_SIN_APAGAR:-}" ]; then
    echo "Apagando..."
    systemctl poweroff
fi
PPS_EOF_PREP
chmod 0755 /usr/local/sbin/pps-preparar-plantilla

cat > /usr/local/bin/comprobar_base.sh <<'PPS_EOF_COMP'
#!/usr/bin/env bash
# comprobar_base.sh (v3, Campus VDI con escritorio grafico)
# Verifica el laboratorio base de PPS (maquina pps-core).
# Solo hace lecturas locales: no envia trafico a ninguna otra maquina.
# Uso: comprobar_base.sh
#      MEM_MIN_KB=2800000 comprobar_base.sh   (perfil ajustado de 3 GB)

MEM_MIN_KB="${MEM_MIN_KB:-3670016}"   # 3,5 GB
ok=0
fallo=0

comprobar() {
    descripcion="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        echo "[ OK  ] $descripcion"
        ok=$((ok + 1))
    else
        echo "[FALLO] $descripcion"
        fallo=$((fallo + 1))
    fi
}

memoria_suficiente() {
    # MemTotal esta en kB
    awk -v minimo="$MEM_MIN_KB" '/^MemTotal:/ { exit ($2 >= minimo ? 0 : 1) }' /proc/meminfo
}

# Direccion IPv4 de ambito global que no pertenezca a los puentes de Docker
direcciones_propias() {
    ip -4 -o addr show scope global 2>/dev/null | grep -Ev ' (docker0|br-[0-9a-f]+) '
}

tiene_ip() {
    direcciones_propias | grep -q .
}

jdk_21() {
    javac -version 2>&1 | grep -q '^javac 21'
}

identidad_propia() {
    # El identificador de maquina no esta vacio
    test -s /etc/machine-id
}

echo "== Comprobacion del laboratorio base (pps-core en Campus VDI) =="
comprobar "Sistema operativo Ubuntu 26.04" grep -q '^VERSION_ID="26.04"' /etc/os-release
comprobar "Nombre de la maquina: pps-core" test "$(hostname)" = "pps-core"
comprobar "Memoria total suficiente (minimo $MEM_MIN_KB kB)" memoria_suficiente
comprobar "Direccion IPv4 asignada (fuera de Docker)" tiene_ip
comprobar "Identidad propia: machine-id generado" identidad_propia
comprobar "JDK 21 instalado (javac 21)" jdk_21
comprobar "Utilidad strings disponible" command -v strings
comprobar "Utilidad unzip disponible" command -v unzip
if command -v firefox >/dev/null 2>&1; then
    echo "[ OK  ] Navegador disponible (firefox)"
    ok=$((ok + 1))
else
    echo "[AVISO] Sin navegador firefox: las practicas con interfaz web necesitan uno."
fi
comprobar "Servicio Docker activo" systemctl is-active --quiet docker
comprobar "Docker utilizable sin sudo" docker info
comprobar "Herramienta pps-modo instalada" command -v pps-modo

echo
if command -v ip >/dev/null 2>&1; then
    echo "Direcciones IPv4 de esta maquina:"
    direcciones_propias | awk '{ print "  " $2 "  " $4 }'
fi

echo
if ! command -v systemctl >/dev/null 2>&1; then
    echo "[INFO ] No se puede determinar el modo: falta systemctl."
elif systemctl is-active --quiet pps-laboratorio.service 2>/dev/null; then
    echo "[INFO ] Modo LABORATORIO: no se abren conexiones nuevas hacia fuera."
else
    echo "[INFO ] Modo MANTENIMIENTO: sin restricciones de salida."
    echo "        Antes de usar herramientas dinamicas, ejecuta: sudo pps-modo laboratorio"
fi

echo
echo "Resultado: $ok correctas, $fallo con fallo."
if [ "$fallo" -eq 0 ]; then
    exit 0
fi
exit 1
PPS_EOF_COMP
chmod 0755 /usr/local/bin/comprobar_base.sh

systemctl daemon-reload
systemctl enable pps-identidad.service

echo "== 6/7 Modo laboratorio por defecto =="
systemctl enable --now pps-laboratorio.service

echo "== 7/7 Resumen =="
java -version 2>&1 | head -n 1
javac -version
docker --version
echo
echo "Ahora cierra sesion y vuelve a entrar como $USUARIO (para el grupo docker),"
echo "ejecuta comprobar_base.sh y, si todo esta en orden, sigue la guia para sellar la plantilla."
