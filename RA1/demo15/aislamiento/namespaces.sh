#!/usr/bin/env bash
# namespaces.sh · Un "mini sandbox" del sistema operativo SIN imagenes ni Docker: espacios de nombres de Linux.
# Compara lo que ve un proceso normal con lo que ve un proceso aislado en su propia red y su propia lista de procesos.
# No modifica nada del sistema y no genera trafico de red.
set -u

mostrar() {   # muestra lo que ve el proceso que ejecuta esta funcion
  echo "  usuario:            $(id -un) (uid $(id -u))"
  echo "  interfaces de red:  $(awk 'NR>2 {sub(":","",$1); printf "%s ", $1}' /proc/net/dev)"
  echo "  procesos visibles:  $(ls /proc | grep -c '^[0-9][0-9]*$')"
}

echo "== Proceso normal (el entorno de siempre) =="
mostrar

echo
echo "== Proceso aislado: red propia (--net), procesos propios (--pid) y usuario propio (--user) =="
# --user --map-root-user : usuario nuevo sin privilegios reales en el sistema (aparece como root solo DENTRO)
# --net                  : espacio de red nuevo, vacio (solo la interfaz lo)
# --pid --fork --mount-proc : arbol de procesos nuevo; --mount-proc remonta /proc para verlo
# bash -c "$(declare -f mostrar); mostrar" : ejecuta dentro la misma funcion de arriba
if unshare --user --map-root-user --net --pid --fork --mount-proc bash -c "$(declare -f mostrar); mostrar" 2>/dev/null; then
  :
else
  echo "  (el sistema no permite espacios de usuario sin privilegios; se reintenta con sudo)"
  sudo unshare --net --pid --fork --mount-proc bash -c "$(declare -f mostrar); mostrar"
fi

echo
echo "Lectura: el proceso aislado cree que es el unico proceso, no tiene red y 'es root', pero ese root"
echo "no tiene poder fuera de su espacio. Docker, Android y los navegadores usan este tipo de mecanismos."
