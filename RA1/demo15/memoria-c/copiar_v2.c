/* copiar_v2.c · VERSION CORREGIDA
 * Correccion: se comprueba la longitud y se rechaza lo que no cabe; snprintf nunca escribe mas de sizeof. */
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
    char nombre[8];                    /* mismo tamano que en v1 */
    if (argc < 2) {
        fprintf(stderr, "uso: %s NOMBRE\n", argv[0]);
        return 2;
    }
    if (strlen(argv[1]) >= sizeof nombre) {          /* no cabe: se rechaza, no se trunca en silencio */
        fprintf(stderr, "error: el nombre es demasiado largo (maximo %zu caracteres)\n", sizeof nombre - 1);
        return 1;
    }
    snprintf(nombre, sizeof nombre, "%s", argv[1]);  /* copia acotada por el tamano real del destino */
    printf("Hola, %s\n", nombre);
    return 0;
}
