#!/usr/bin/env bash
# Ensayo de la demostración de 2.2 (de la matriz de verificación a la prueba). Trabaja en una copia temporal.
# Uso:  bash ensayo.sh        (no hace falta sudo ni Internet)
# Variable opcional: PYTEST="/ruta/python -m pytest"
cd "$(dirname "$0")" || exit 1
ORIGEN="$(pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
cp -r "$ORIGEN"/. "$TMP"/
cd "$TMP/verificacion" || exit 1
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

# La versión 1 debe FALLAR en tres requisitos (1.2.4, 8.2.2 y 16.5.2); la versión 2 debe PASAR.
VERSION=v1 $PYTEST -q >/dev/null 2>&1; r1=$?
VERSION=v2 $PYTEST -q >/dev/null 2>&1; r2=$?
[ "$r1" -ne 0 ] && bien "v1 (vulnerable): hay pruebas que FALLAN (debe ser así)" || fallo "v1 pasa y no debería"
[ "$r2" -eq 0 ] && bien "v2 (corregida): las pruebas PASAN" || fallo "v2 falla y no debería"

# Comprueba que los fallos de v1 son exactamente los de los tres requisitos esperados.
salida_v1="$(VERSION=v1 $PYTEST -v 2>&1)"
for req in 1_2_4_un_texto_con_comilla 1_2_4_un_texto_con_forma 8_2_2_otro_usuario 16_5_2_si_el_servicio_cae; do
    echo "$salida_v1" | grep -E "test_v5_0_0_${req}.*FAILED" >/dev/null \
        && bien "v1 incumple el requisito de test_v5_0_0_${req}…" || fallo "v1 no falla en test_v5_0_0_${req}…"
done
for v in v1 v2; do printf '   recuento real %s: ' $v; VERSION=$v $PYTEST -q 2>&1 | tail -n1; done

echo; echo "Resultado: $ok correctas, $mal con fallo."
echo "Recuento que la guía espera (pytest): v1 = 4 failed, 2 passed, 3 skipped; v2 = 6 passed, 3 skipped."
[ "$mal" -eq 0 ]
