#!/usr/bin/env bash
# Ensayo de las demostraciones de 1.5 (seguridad en lenguajes y sandboxes). Trabaja en una copia temporal.
# Uso:  bash ensayo.sh        (no hace falta sudo; Docker se prueba solo si el servicio esta disponible)
# Variables opcionales: PYTEST="/ruta/python -m pytest"
cd "$(dirname "$0")" || exit 1
ORIGEN="$(pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
cp -r "$ORIGEN"/. "$TMP"/
cd "$TMP" || exit 1
ok=0; mal=0
bien()  { echo "[ OK  ] $1"; ok=$((ok+1)); }
fallo() { echo "[FALLO] $1"; mal=$((mal+1)); }

echo "== A1. C con AddressSanitizer"
if command -v gcc >/dev/null; then
    ( cd memoria-c && gcc -g -O0 -fsanitize=address copiar_v1.c -o copiar_v1 && gcc -g -O0 -fsanitize=address copiar_v2.c -o copiar_v2 ) 2>/dev/null
    LARGO=$(printf 'A%.0s' $(seq 1 40))
    ( cd memoria-c && ./copiar_v1 Ana >/dev/null 2>&1 ) && bien "v1 con entrada normal funciona" || fallo "v1 con entrada normal falla"
    ( cd memoria-c && ./copiar_v1 "$LARGO" 2>&1 | grep -q "AddressSanitizer: stack-buffer-overflow" ) && bien "v1 con entrada larga: AddressSanitizer detecta el desbordamiento" || fallo "v1 con entrada larga: no se detecta el desbordamiento"
    ( cd memoria-c && ./copiar_v2 "$LARGO" >/dev/null 2>&1 ); [ "$?" -eq 1 ] && bien "v2 con entrada larga: la rechaza con codigo 1" || fallo "v2 con entrada larga: comportamiento inesperado"
else
    echo "[AVISO] Sin gcc (instala build-essential en modo mantenimiento). Se omite A1."
fi

echo "== A2. Java: limites y SecurityManager"
if command -v javac >/dev/null; then
    mkdir -p out
    javac -d out memoria-java/Limites.java frontera/Frontera.java 2>&1 | grep -v "Picked up"
    java -cp out Limites 2>&1 | grep -q "ArrayIndexOutOfBoundsException" && bien "Limites: excepcion por acceso fuera de limites" || fallo "Limites: no sale la excepcion esperada"
    java -cp out Limites 2>&1 | grep -q "Entero desbordado en silencio -> -2147483648" && bien "Limites: el desbordamiento de enteros es silencioso" || fallo "Limites: salida de enteros inesperada"
    java -cp out Frontera 2>&1 | grep -q "UnsupportedOperationException" && bien "Frontera: no se puede instalar SecurityManager" || fallo "Frontera: se pudo instalar (revisar la version de Java)"
    java -version 2>&1 | grep -v "Picked up" | head -n1
else
    echo "[AVISO] Sin JDK. Se omite A2."
fi

echo "== B. Python: calculadora (eval)"
if [ -z "$PYTEST" ]; then
    for candidato in "${VIRTUAL_ENV:+$VIRTUAL_ENV/bin/python}" python3 /opt/pps/venv/bin/python "$HOME/venv-pruebas/bin/python"; do
        [ -n "$candidato" ] || continue
        if "$candidato" -m pytest --version >/dev/null 2>&1; then PYTEST="$candidato -m pytest"; break; fi
    done
fi
if [ -z "$PYTEST" ]; then
    echo "[AVISO] No encuentro pytest. Activa tu entorno virtual (source ~/venv-pruebas/bin/activate) y repite."
else
    echo "Usando: $($PYTEST --version 2>&1 | head -n1)"
    ( cd calculadora/v1  && $PYTEST -q >/dev/null 2>&1 ); r1=$?
    ( cd calculadora/v1b && $PYTEST -q >/dev/null 2>&1 ); r1b=$?
    ( cd calculadora/v2  && $PYTEST -q >/dev/null 2>&1 ); r2=$?
    [ "$r1"  -ne 0 ] && bien "v1 (eval): las pruebas FALLAN (debe ser asi)" || fallo "v1 pasa y no deberia"
    [ "$r1b" -ne 0 ] && bien "v1b (builtins vacios): las pruebas siguen FALLANDO (debe ser asi)" || fallo "v1b pasa y no deberia"
    [ "$r2"  -eq 0 ] && bien "v2 (ast): las pruebas PASAN" || fallo "v2 falla y no deberia"
    echo "Recuentos reales (anotalos y comparalos con la guia: v1 6 ok/9 fallos, v1b 11/4, v2 15/0):"
    for v in v1 v1b v2; do printf '  %s: ' $v; ( cd calculadora/$v && $PYTEST -q 2>&1 | tail -n1 ); done
fi

echo "== C. Aislamiento"
bash aislamiento/namespaces.sh >/dev/null 2>&1 && bien "namespaces.sh se ejecuta" || fallo "namespaces.sh falla (revisa espacios de usuario / sudo)"
if docker info >/dev/null 2>&1 && docker image inspect alpine:3.20 >/dev/null 2>&1; then
    bash aislamiento/contenedor_v1.sh >/dev/null 2>&1; [ "$?" -ne 0 ] && bien "contenedor v1: el verificador FALLA (debe ser asi)" || fallo "contenedor v1: el verificador pasa y no deberia"
    bash aislamiento/contenedor_v2.sh >/dev/null 2>&1; [ "$?" -eq 0 ] && bien "contenedor v2: el verificador PASA" || fallo "contenedor v2: el verificador falla"
    if [ -n "$PYTEST" ]; then   # las mismas comprobaciones como pruebas de pytest (CONSERVAR=1 deja el contenedor creado)
        CONSERVAR=1 bash aislamiento/contenedor_v1.sh >/dev/null 2>&1; ( cd aislamiento && CONTENEDOR=tallerbit-v1 $PYTEST -q test_contenedor.py >/dev/null 2>&1 ); r=$?; docker rm -f tallerbit-v1 >/dev/null 2>&1
        [ "$r" -ne 0 ] && bien "pytest sobre contenedor v1: FALLA (debe ser asi)" || fallo "pytest sobre contenedor v1 pasa y no deberia"
        CONSERVAR=1 bash aislamiento/contenedor_v2.sh >/dev/null 2>&1; ( cd aislamiento && CONTENEDOR=tallerbit-v2 $PYTEST -q test_contenedor.py >/dev/null 2>&1 ); r=$?; docker rm -f tallerbit-v2 >/dev/null 2>&1
        [ "$r" -eq 0 ] && bien "pytest sobre contenedor v2: PASA" || fallo "pytest sobre contenedor v2 falla"
    fi
else
    echo "[AVISO] Docker no disponible o sin la imagen alpine:3.20 (docker pull alpine:3.20 en modo mantenimiento). Se omite C2."
fi
echo; echo "Resultado: $ok correctas, $mal con fallo."
[ "$mal" -eq 0 ]
