#!/usr/bin/env bash
# verificar_contenedor.sh NOMBRE · Comprueba la configuracion de seguridad de un contenedor y devuelve
# codigo 0 si cumple todo y 1 si no. Pensado para ejecutarse tambien en un pipeline (gate de seguridad).
set -u
[ $# -eq 1 ] || { echo "uso: $0 NOMBRE_DEL_CONTENEDOR"; exit 2; }
C=$1
fallos=0
valor() { docker inspect -f "$1" "$C"; }     # lee un campo de la configuracion con una plantilla de docker inspect

comprobar() {   # comprobar "descripcion" "valor_actual" "patron_esperado"
  if [[ "$2" =~ $3 ]]; then printf '  [OK]    %s (%s)\n' "$1" "$2"
  else printf '  [FALLA] %s (actual: %s)\n' "$1" "$2"; fallos=$((fallos+1)); fi
}

echo "== Verificacion de $C =="
comprobar "no se ejecuta como root"           "$(valor '{{.Config.User}}')"             '^[1-9][0-9]*'
comprobar "sistema de ficheros de solo lectura" "$(valor '{{.HostConfig.ReadonlyRootfs}}')" '^true$'
comprobar "capacidades eliminadas (ALL)"       "$(valor '{{.HostConfig.CapDrop}}')"      'ALL'
comprobar "sin nuevos privilegios"             "$(valor '{{.HostConfig.SecurityOpt}}')"  'no-new-privileges'
comprobar "sin red"                            "$(valor '{{.HostConfig.NetworkMode}}')"  '^none$'
comprobar "limite de procesos"                 "$(valor '{{.HostConfig.PidsLimit}}')"    '^[1-9][0-9]*$'
comprobar "limite de memoria (bytes)"          "$(valor '{{.HostConfig.Memory}}')"       '^[1-9][0-9]*$'
comprobar "no es privilegiado"                 "$(valor '{{.HostConfig.Privileged}}')"   '^false$'
echo "Resultado: $fallos comprobaciones fallidas"
[ "$fallos" -eq 0 ]
