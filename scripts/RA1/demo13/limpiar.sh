#!/bin/sh
# Borra los ficheros generados al compilar (class, jar, salidas) y deja solo las fuentes.
cd "$(dirname "$0")" || exit 2
find . -name '*.class' -delete
find . -name '*.jar' -delete
find . -name 'salida.txt' -delete
echo "Limpio."
