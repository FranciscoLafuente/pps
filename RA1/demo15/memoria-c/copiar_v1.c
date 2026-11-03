/* copiar_v1.c · VERSION VULNERABLE (solo para el laboratorio)
 * Defecto: strcpy copia sin mirar el tamano del destino (CWE-120 / CWE-787, a verificar). */
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
    char nombre[8];                    /* reserva 8 bytes: 7 caracteres + el terminador '\0' */
    if (argc < 2) {                    /* sin argumento no hay nada que copiar */
        fprintf(stderr, "uso: %s NOMBRE\n", argv[0]);
        return 2;
    }
    strcpy(nombre, argv[1]);           /* copia TODO lo que reciba, aunque no quepa en 8 bytes */
    printf("Hola, %s\n", nombre);
    return 0;
}
