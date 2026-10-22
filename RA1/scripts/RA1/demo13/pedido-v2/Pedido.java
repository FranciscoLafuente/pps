/**
 * Cálculo del importe de un pedido en céntimos (tienda ficticia de Tallerbit).
 * Versión 2: valida el rango de la entrada y no permite que el cálculo se desborde en silencio.
 */
public class Pedido {

    static final int MAX_UNIDADES = 10_000;

    static long totalCentimos(int unidades, int precioCentimos) {
        if (unidades < 1 || unidades > MAX_UNIDADES) {
            throw new IllegalArgumentException("Unidades fuera de rango: " + unidades);
        }
        if (precioCentimos < 0) {
            throw new IllegalArgumentException("Precio no valido: " + precioCentimos);
        }
        return Math.multiplyExact((long) unidades, (long) precioCentimos);
    }

    public static void main(String[] args) {
        System.out.println("3 x 1000       = " + totalCentimos(3, 1_000));
        try {
            System.out.println("3000000 x 1000 = " + totalCentimos(3_000_000, 1_000));
        } catch (IllegalArgumentException error) {
            System.out.println("Rechazado: " + error.getMessage());
        }
    }
}
