#!/usr/bin/env bash
# probar.sh · compila v1 y v2 con AddressSanitizer y las ejecuta con una entrada normal y otra demasiado larga.
# Requiere gcc (paquete build-essential). Entradas inofensivas: solo letras 'A'.
set -u
cd "$(dirname "$0")"                                   # trabajar en la carpeta del script
command -v gcc >/dev/null || { echo "Falta gcc: instala build-essential en modo mantenimiento"; exit 3; }
for v in v1 v2; do
  # -g: informacion de depuracion (numeros de linea en el informe); -fsanitize=address: AddressSanitizer
  gcc -g -O0 -fsanitize=address -fno-omit-frame-pointer "copiar_$v.c" -o "copiar_$v" || exit 1
done
LARGO=$(printf 'A%.0s' $(seq 1 40))                    # 40 letras A: no caben en 8 bytes
echo "== v1 con entrada normal =="; ./copiar_v1 Ana;            echo "(codigo de salida: $?)"
echo "== v2 con entrada normal =="; ./copiar_v2 Ana;            echo "(codigo de salida: $?)"
SAL=$(mktemp)                                          # fichero temporal para guardar el informe completo
echo "== v1 con entrada larga =="; ./copiar_v1 "$LARGO" >"$SAL" 2>&1; CODIGO=$?   # el informe va al fichero
head -8 "$SAL"; echo "(codigo de salida: $CODIGO)"; rm -f "$SAL"                  # solo las primeras lineas
echo "== v2 con entrada larga ==";  ./copiar_v2 "$LARGO";       echo "(codigo de salida: $?)"
