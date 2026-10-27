import java.security.SecureRandom;
import java.util.Random;

/**
 * Generador de cupones de descuento (empresa ficticia).
 * Versión 2: usa java.security.SecureRandom.
 */
public class CuponSeguro {

    private static final String ALFABETO = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private static final SecureRandom AZAR = new SecureRandom();

    static String generar(Random azar, int longitud) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < longitud; i++) {
            sb.append(ALFABETO.charAt(azar.nextInt(ALFABETO.length())));
        }
        return sb.toString();
    }

    static String generar(int longitud) {
        return generar(AZAR, longitud);
    }

    public static void main(String[] args) {
        System.out.println(generar(8));
    }
}
