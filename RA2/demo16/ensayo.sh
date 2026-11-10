#!/usr/bin/env bash
# Ensayo de las demostraciones de 2.1 (fuentes abiertas y listas de riesgos). Trabaja en una copia temporal.
# Uso:  bash ensayo.sh        (no hace falta sudo ni Internet)
# Variable opcional: PYTEST="/ruta/python -m pytest"
cd "$(dirname "$0")" || exit 1
ORIGEN="$(pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
cp -r "$ORIGEN"/. "$TMP"/
cd "$TMP" || exit 1
ok=0; mal=0
bien()  { echo "[ OK  ] $1"; ok=$((ok+1)); }
fallo() { echo "[FALLO] $1"; mal=$((mal+1)); }

# Busca un Python con pytest: el entorno activo, el del profesor, el del sistema y el del alumnado.
if [ -z "$PYTEST" ]; then
    for candidato in "${VIRTUAL_ENV:+$VIRTUAL_ENV/bin/python}" /opt/pps/venv/bin/python python3 "$HOME/venv-pruebas/bin/python"; do
        [ -n "$candidato" ] || continue
        if "$candidato" -m pytest --version >/dev/null 2>&1; then PYTEST="$candidato -m pytest"; break; fi
    done
fi
if [ -z "$PYTEST" ]; then
    echo "[AVISO] No encuentro pytest. Activa tu entorno virtual (source /opt/pps/venv/bin/activate) y repite."
    exit 1
fi
echo "Usando: $($PYTEST --version 2>&1 | head -n1)"

# Para cada carpeta: la version v1 (vulnerable) debe FALLAR y la v2 (corregida) debe PASAR.
for carpeta in inyeccion acceso excepciones; do
    echo "== $carpeta"
    ( cd "$carpeta" && VERSION=v1 $PYTEST -q >/dev/null 2>&1 ); r1=$?
    ( cd "$carpeta" && VERSION=v2 $PYTEST -q >/dev/null 2>&1 ); r2=$?
    [ "$r1" -ne 0 ] && bien "$carpeta v1 (vulnerable): las pruebas FALLAN (debe ser asi)" || fallo "$carpeta v1 pasa y no deberia"
    [ "$r2" -eq 0 ] && bien "$carpeta v2 (corregida): las pruebas PASAN" || fallo "$carpeta v2 falla y no deberia"
    for v in v1 v2; do printf '   recuento real %s: ' $v; ( cd "$carpeta" && VERSION=$v $PYTEST -q 2>&1 | tail -n1 ); done
done

echo "== demo_citas.py (sin pytest)"
( cd inyeccion && python3 demo_citas.py 2>&1 | grep -q "x' OR '1'='1\"     -> 3 fila(s)" ) && bien "v1: la entrada manipulada devuelve 3 filas" || fallo "v1: salida inesperada"
echo; echo "Resultado: $ok correctas, $mal con fallo."
echo "Recuentos que la guia espera (pytest): inyeccion v1 2 fallos y 2 ok, v2 4 ok; acceso v1 1 fallo y 2 ok, v2 3 ok; excepciones v1 1 fallo y 2 ok, v2 3 ok."
[ "$mal" -eq 0 ]
