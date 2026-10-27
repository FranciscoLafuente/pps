#!/usr/bin/env bash
# Ensayo de las demostraciones de 1.4 (pruebas de software). Trabaja en una copia temporal.
# Uso:  bash ensayo.sh        (no hace falta sudo)
# Variables opcionales: PYTEST="/opt/pps/venv/bin/python -m pytest"   JUNIT_JAR=/ruta/al/jar
cd "$(dirname "$0")" || exit 1
ORIGEN="$(pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
cp -r "$ORIGEN"/. "$TMP"/
cd "$TMP" || exit 1
ok=0; mal=0
bien()  { echo "[ OK  ] $1"; ok=$((ok+1)); }
fallo() { echo "[FALLO] $1"; mal=$((mal+1)); }

if [ -z "$PYTEST" ]; then
    if python3 -m pytest --version >/dev/null 2>&1; then PYTEST="python3 -m pytest"
    elif [ -x /opt/pps/venv/bin/python ]; then PYTEST="/opt/pps/venv/bin/python -m pytest"
    fi
fi
if [ -z "$PYTEST" ]; then
    echo "[AVISO] No encuentro pytest. Instalalo con:  pps-modo mantenimiento ; python3 -m venv ~/venv-pruebas ; ~/venv-pruebas/bin/pip install pytest"
    echo "        y vuelve a lanzar:  PYTEST='\$HOME/venv-pruebas/bin/python -m pytest' bash ensayo.sh"
else
    echo "Usando: $($PYTEST --version 2>&1 | head -n1)"
    for par in descuentos adjuntos repo; do
        echo "== $par"
        ( cd "$par-v1" && $PYTEST -q >/dev/null 2>&1 ); r1=$?
        ( cd "$par-v2" && $PYTEST -q >/dev/null 2>&1 ); r2=$?
        [ "$r1" -ne 0 ] && bien "$par-v1: las pruebas FALLAN (debe ser asi: version con fallo)" || fallo "$par-v1: las pruebas pasan y no deberian"
        [ "$r2" -eq 0 ] && bien "$par-v2: las pruebas PASAN (version corregida)" || fallo "$par-v2: las pruebas fallan y no deberian"
    done
    echo "== cobertura (el test flojo y el bueno pasan los dos)"
    ( cd cobertura && $PYTEST -q >/dev/null 2>&1 ) && bien "test_flojo y test_bueno pasan sobre el codigo original" || fallo "cobertura: alguna prueba falla"
    echo "== mutacion manual"
    PYBIN="${PYTEST%% *}"; sal="$( cd cobertura && $PYBIN mutar.py 2>&1 )"
    echo "$sal" | grep -q "test_flojo.py" && echo "$sal" | sed -n '1,12p'
    n_flojo="$(echo "$sal" | grep -A5 'test_flojo' | grep -o 'sobreviven: [0-9]*' | grep -o '[0-9]*$')"
    n_bueno="$(echo "$sal" | grep -A5 'test_bueno' | grep -o 'sobreviven: [0-9]*' | grep -o '[0-9]*$')"
    [ "$n_flojo" = "4" ] && bien "mutacion: el test flojo deja sobrevivir 4 de 4" || fallo "mutacion: test flojo = $n_flojo (esperado 4)"
    [ "$n_bueno" = "0" ] && bien "mutacion: el test bueno detecta los 4 mutantes" || fallo "mutacion: test bueno deja sobrevivir $n_bueno (esperado 0)"
fi

echo "== Java / JUnit"
JAR="${JUNIT_JAR:-}"
[ -z "$JAR" ] && JAR="$(ls /opt/pps/lib/junit-platform-console-standalone*.jar "$ORIGEN"/junit-platform-console-standalone*.jar 2>/dev/null | head -n1)"
if [ -z "$JAR" ] || ! command -v javac >/dev/null; then
    echo "[AVISO] Sin JDK o sin el jar de JUnit (junit-platform-console-standalone). Se omite la parte Java (ver LEEME.txt)."
else
    for v in v1 v2; do
        ( cd "pedido-$v" && mkdir -p out && javac -cp "$JAR" -d out *.java && java -jar "$JAR" execute --class-path out --scan-class-path >resultado.txt 2>&1 ); r=$?
        if [ "$v" = v1 ]; then [ "$r" -ne 0 ] && bien "pedido-v1: JUnit informa fallos (debe ser asi)" || fallo "pedido-v1: JUnit no informa fallos"
        else [ "$r" -eq 0 ] && bien "pedido-v2: JUnit pasa" || fallo "pedido-v2: JUnit falla"; fi
    done
fi
echo; echo "Resultado: $ok correctas, $mal con fallo."
[ "$mal" -eq 0 ]
