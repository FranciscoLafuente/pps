#!/usr/bin/env bash
# ensayo.sh - Ensayo automatico de las demostraciones de la videoconferencia de 1.3.
# Compila y ejecuta cada demo en una copia temporal (no ensucia tus carpetas) y
# comprueba que el resultado es el que anuncia la guia docente.
# Uso: ./ensayo.sh            (rapido, unos segundos)
#      ./ensayo.sh --completo (incluye la comparacion Java/Python de la demo opcional)
# No necesita Internet y no se dirige a ningun otro sistema.

AQUI="$(cd "$(dirname "$0")" && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cp -r "$AQUI"/. "$TMP"/
cd "$TMP" || exit 2
export LC_ALL="${LC_ALL:-C.UTF-8}"

ok=0; fallo=0
check() {  # check "descripcion" comando...
    d="$1"; shift
    if "$@" >/dev/null 2>&1; then echo "[ OK  ] $d"; ok=$((ok+1))
    else echo "[FALLO] $d"; fallo=$((fallo+1)); fi
}
sale() {   # sale N comando...  -> el comando debe terminar con el codigo N
    esperado="$1"; shift
    "$@" >/dev/null 2>&1; [ "$?" -eq "$esperado" ]
}
contiene() {  # contiene "texto" comando...
    t="$1"; shift
    "$@" 2>&1 | grep -qF -- "$t"
}

echo "== Herramientas =="
for h in java javac javap jcmd jar strings unzip; do
    check "$h disponible" command -v "$h"
done
javac -version 2>&1 | grep -q '^javac 21' && echo "[ OK  ] javac 21" || echo "[AVISO] javac no es la 21: $(javac -version 2>&1)"

echo "== Demo 1: del .java a la JVM (niv) =="
( cd niv && javac Nivelacion.java && java Nivelacion >salida.txt 2>&1 )
check "Nivelacion.class generado" test -f niv/Nivelacion.class
check "cabecera ca fe ba be + version 65 (JDK 21)" sh -c '[ "$(od -An -tx1 -N8 niv/Nivelacion.class | tr -s " " | sed "s/^ //")" = "ca fe ba be 00 00 00 41" ]'
check "javap -c muestra imul en cuadrado" sh -c 'cd niv && javap -c Nivelacion | grep -q imul'
check "la salida incluye el cuadrado de 7" grep -q "El cuadrado de 7 es 49" niv/salida.txt

echo "== Demo 2: error silencioso y su ciclo (pedido-v1 / pedido-v2) =="
( cd pedido-v1 && javac Pedido.java ProbarPedido.java )
check "v1 desborda: 3000000 x 1000 sale negativo" contiene "= -1294967296" java -cp pedido-v1 Pedido
check "v1: la prueba de regresion falla (codigo 1)" sale 1 java -cp pedido-v1 ProbarPedido
check "v1: cuatro lineas FALLO" sh -c '[ "$(java -cp pedido-v1 ProbarPedido | grep -c ^FALLO)" -eq 4 ]'
( cd pedido-v2 && javac Pedido.java ProbarPedido.java )
check "v2 rechaza 3000000 unidades" contiene "Rechazado: Unidades fuera de rango: 3000000" java -cp pedido-v2 Pedido
check "v2: la prueba de regresion pasa (codigo 0)" sale 0 java -cp pedido-v2 ProbarPedido
check "v2: imprime TODO OK" contiene "TODO OK" java -cp pedido-v2 ProbarPedido

echo "== Demo 3: el secreto en el bytecode (acceso-v1 / acceso-v2) =="
( cd acceso-v1 && javac Acceso.java && jar cf acceso.jar Acceso.class )
check "v1 concede con la clave correcta" contiene "Acceso concedido" java -cp acceso-v1 Acceso LabClave-2026
check "strings encuentra la clave en el .class" sh -c 'strings acceso-v1/Acceso.class | grep -q LabClave'
check "tambien dentro del .jar" sh -c 'unzip -p acceso-v1/acceso.jar Acceso.class | strings | grep -q LabClave'
check "javap -v muestra la constante" sh -c 'javap -v -cp acceso-v1 Acceso | grep -q LabClave'
check "comprobar_secretos.sh da FALLO en v1 (codigo 1)" sale 1 sh acceso-v1/comprobar_secretos.sh LabClave acceso-v1/Acceso.class
( cd acceso-v2 && javac Acceso.java )
check "v2 sin variable de entorno: codigo 2" sh -c 'unset CLAVE_LAB; ! java -cp acceso-v2 Acceso x >/dev/null 2>&1 && java -cp acceso-v2 Acceso x 2>&1 | grep -q "Falta la variable"'
check "v2 concede con CLAVE_LAB correcta" sh -c 'CLAVE_LAB=ejemplo-no-secreto java -cp acceso-v2 Acceso ejemplo-no-secreto | grep -q "Acceso concedido"'
check "v2 deniega con clave incorrecta (codigo 1)" sh -c 'CLAVE_LAB=ejemplo-no-secreto java -cp acceso-v2 Acceso otra >/dev/null; [ $? -eq 1 ]'
check "comprobar_secretos.sh da OK en v2 (codigo 0)" sale 0 sh acceso-v2/comprobar_secretos.sh LabClave acceso-v2/Acceso.class

echo "== Lectura guiada: cupones (cupon) =="
( cd cupon && javac CuponInseguro.java CuponSeguro.java ProbarCupon.java )
check "semilla fija: mismo cupon, prueba falla (codigo 1)" sale 1 java -cp cupon ProbarCupon inseguro
check "SecureRandom: cupones distintos, prueba pasa (codigo 0)" sale 0 java -cp cupon ProbarCupon seguro

echo "== Apoyo: memoria, inventario, proceso en marcha =="
( cd mem && javac Memoria.java ) ; ( cd inv && javac Inventario.java ) ; ( cd espera && javac Espera.java )
check "Memoria: agota la pila y el monton con -Xmx16m" sh -c 'java -Xmx16m -cp mem Memoria | grep -q OutOfMemoryError'
check "Inventario: cuatro hallazgos [RIESGO]" sh -c '[ "$(java -cp inv Inventario | grep -c RIESGO)" -eq 4 ]'
java -cp espera Espera >/dev/null 2>&1 & pid=$!
sleep 1
check "jcmd ve el proceso Espera en marcha" sh -c "jcmd $pid VM.version | grep -q JDK"
kill "$pid" 2>/dev/null; wait "$pid" 2>/dev/null

if [ "$1" = "--completo" ]; then
    echo "== Opcional: JIT (jit) =="
    ( cd jit && javac Caliente.java )
    echo "Java:";   java -cp jit Caliente
    if command -v python3 >/dev/null 2>&1; then echo "Python:"; python3 jit/calien.py; fi
    echo "(Los tiempos dependen de tu maquina; la comparacion es cualitativa.)"
fi

echo
echo "Resultado: $ok correctas, $fallo con fallo."
[ "$fallo" -eq 0 ]
