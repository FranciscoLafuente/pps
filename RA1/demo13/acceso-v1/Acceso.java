/**
 * Comprobación de acceso de una herramienta interna (empresa ficticia).
 * Versión 1: la clave está escrita en el código.
 */
public class Acceso {

    private static final String CLAVE = "LabClave-2026";

    static boolean concede(String intento) {
        return CLAVE.equals(intento);
    }

    public static void main(String[] args) {
        if (args.length != 1) {
            System.out.println("Uso: java Acceso <clave>");
            System.exit(2);
        }
        if (concede(args[0])) {
            System.out.println("Acceso concedido");
        } else {
            System.out.println("Acceso denegado");
            System.exit(1);
        }
    }
}
