#!/usr/bin/env bash
# contenedor_v1.sh · Contenedor con la configuracion POR DEFECTO (sin endurecer). Solo laboratorio.
# Imagen: alpine:3.20 (hay que descargarla antes, en modo mantenimiento: docker pull alpine:3.20; verificar la etiqueta).
set -u
NOMBRE=tallerbit-v1
docker rm -f "$NOMBRE" >/dev/null 2>&1                       # limpia ejecuciones anteriores
# Sin --user, --read-only, --cap-drop ni limites: el proceso es root dentro del contenedor, con el sistema de ficheros escribible.
docker run -d --name "$NOMBRE" alpine:3.20 sleep 600 >/dev/null
echo "== Que puede hacer el proceso dentro de v1 =="
docker exec "$NOMBRE" sh -c 'echo "usuario:           $(id -un)";
  touch /prueba && echo "escribir en /:     PERMITIDO";
  echo "capacidades:       $(grep CapEff /proc/self/status)";
  echo "interfaces de red: $(ls /sys/class/net | tr "\n" " ")"'
echo
"$(dirname "$0")/verificar_contenedor.sh" "$NOMBRE"; RESULTADO=$?   # guarda el resultado del verificador (0 = cumple, 1 = no cumple)
[ "${CONSERVAR:-0}" = 1 ] || docker rm -f "$NOMBRE" >/dev/null   # con CONSERVAR=1 el contenedor se deja para las pruebas de pytest
exit "$RESULTADO"                                             # el script devuelve el resultado del verificador, no el de docker rm
