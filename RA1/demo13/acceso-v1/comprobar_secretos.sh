#!/bin/sh
# Falla (codigo 1) si algun .class contiene la cadena que no debe aparecer.
PATRON="${1:-LabClave}"
shift
if strings "$@" | grep -q "$PATRON"; then
    echo "FALLO: el patron '$PATRON' aparece en los artefactos"
    exit 1
fi
echo "OK: el patron '$PATRON' no aparece"
