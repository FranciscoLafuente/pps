#!/usr/bin/env bash
# Demo de firma digital con OpenSSL: hash + clave privada, verificación y manipulación
# Uso: bash demo_firma.sh   (en una carpeta vacía; solo crea archivos de prueba)
set -e
echo "== 1. Clave privada y clave pública (RSA 2048) =="
openssl genrsa -out privada.pem 2048 2>/dev/null
openssl rsa -in privada.pem -pubout -out publica.pem 2>/dev/null
ls -l privada.pem publica.pem

echo; echo "== 2. El documento y su resumen (hash SHA-256) =="
printf 'Contrato de servicios NubeSegura - Ayuntamiento de Valdecastro\nImporte: 41.800 EUR\n' > contrato.txt
sha256sum contrato.txt

echo; echo "== 3. Firmar: se calcula el hash y se cifra con la clave PRIVADA =="
openssl dgst -sha256 -sign privada.pem -out contrato.firma contrato.txt
ls -l contrato.firma

echo; echo "== 4. Verificar con la clave PÚBLICA (documento intacto) =="
openssl dgst -sha256 -verify publica.pem -signature contrato.firma contrato.txt

echo; echo "== 5. Alguien cambia UNA cifra del importe y se vuelve a verificar =="
sed 's/41.800/14.800/' contrato.txt > contrato_manipulado.txt
sha256sum contrato_manipulado.txt
openssl dgst -sha256 -verify publica.pem -signature contrato.firma contrato_manipulado.txt || true

echo; echo "== 6. Lo que NO demuestra la firma por sí sola =="
echo "Sabemos que el documento no cambió y que la firmó quien tiene la clave privada."
echo "Pero ¿de quién es publica.pem? Eso lo resuelve un CERTIFICADO emitido por un prestador."
