#!/usr/bin/env bash
# contenedor_v2.sh · Mismo contenedor ENDURECIDO. Cada opcion lleva su motivo.
set -u
NOMBRE=tallerbit-v2
docker rm -f "$NOMBRE" >/dev/null 2>&1
#  --user 10001:10001            : proceso sin privilegios (no es root, ni siquiera dentro)
#  --read-only                   : sistema de ficheros raiz de solo lectura
#  --tmpfs /tmp                  : unico sitio escribible, en memoria y temporal
#  --cap-drop ALL                : se quitan todas las capacidades de Linux (no se necesita ninguna)
#  --security-opt no-new-privileges : el proceso no puede ganar privilegios (por ejemplo con binarios setuid)
#  --network none                : sin red (si la aplicacion la necesita, se abre solo lo imprescindible)
#  --pids-limit 64 --memory 128m : tope de procesos y de memoria, contra bombas y fugas
docker run -d --name "$NOMBRE" \
  --user 10001:10001 --read-only --tmpfs /tmp \
  --cap-drop ALL --security-opt no-new-privileges \
  --network none --pids-limit 64 --memory 128m \
  alpine:3.20 sleep 600 >/dev/null
echo "== Que puede hacer el proceso dentro de v2 =="
docker exec "$NOMBRE" sh -c 'echo "usuario:           $(id -un 2>/dev/null || id -u)";
  touch /prueba 2>/dev/null && echo "escribir en /:     PERMITIDO" || echo "escribir en /:     DENEGADO";
  touch /tmp/prueba && echo "escribir en /tmp:  permitido (tmpfs temporal)";
  echo "capacidades:       $(grep CapEff /proc/self/status)";
  echo "interfaces de red: $(ls /sys/class/net | tr "\n" " ")"'
echo
"$(dirname "$0")/verificar_contenedor.sh" "$NOMBRE"
[ "${CONSERVAR:-0}" = 1 ] || docker rm -f "$NOMBRE" >/dev/null   # con CONSERVAR=1 el contenedor se deja para las pruebas de pytest
