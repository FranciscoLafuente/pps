/**
 * Cálculo del importe de un pedido en céntimos (tienda ficticia de Tallerbit).
 * Versión 1.
 */
public class Pedido {

    static int totalCentimos(int unidades, int precioCentimos) {
        return unidades * precioCentimos;
    }

    public static void main(String[] args) {
        System.out.println("3 x 1000       = " + totalCentimos(3, 1_000));
        System.out.println("3000000 x 1000 = " + totalCentimos(3_000_000, 1_000));
    }
}
