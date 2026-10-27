#!/usr/bin/env bash
# Borra los ficheros generados al probar en estas carpetas.
cd "$(dirname "$0")" || exit 1
find . -name '__pycache__' -type d -prune -exec rm -rf {} + 2>/dev/null
find . -name '.pytest_cache' -type d -prune -exec rm -rf {} + 2>/dev/null
rm -rf pedido-v1/out pedido-v2/out pedido-v1/resultado.txt pedido-v2/resultado.txt
echo "Limpio."
