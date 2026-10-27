/**
 * Comprobación de acceso de una herramienta interna (empresa ficticia).
 * Versión 2: la clave se lee del entorno y no figura en el código.
 */
public class Acceso {

    static boolean concede(String esperada, String intento) {
        return esperada != null && !esperada.isEmpty() && esperada.equals(intento);
    }

    public static void main(String[] args) {
        String esperada = System.getenv("CLAVE_LAB");
        if (esperada == null || esperada.isEmpty()) {
            System.out.println("Falta la variable de entorno CLAVE_LAB");
            System.exit(2);
        }
        if (args.length != 1) {
            System.out.println("Uso: java Acceso <clave>");
            System.exit(2);
        }
        if (concede(esperada, args[0])) {
            System.out.println("Acceso concedido");
        } else {
            System.out.println("Acceso denegado");
            System.exit(1);
        }
    }
}
