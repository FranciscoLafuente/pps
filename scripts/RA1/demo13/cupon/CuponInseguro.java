import java.util.Random;

/**
 * Generador de cupones de descuento (empresa ficticia).
 * Versión 1: usa java.util.Random.
 */
public class CuponInseguro {

    private static final String ALFABETO = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

    static String generar(Random azar, int longitud) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < longitud; i++) {
            sb.append(ALFABETO.charAt(azar.nextInt(ALFABETO.length())));
        }
        return sb.toString();
    }

    static String generar(int longitud) {
        return generar(new Random(), longitud);
    }

    public static void main(String[] args) {
        System.out.println(generar(8));
    }
}
