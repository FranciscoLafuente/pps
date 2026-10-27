/**
 * Cálculo del importe de un pedido en céntimos (tienda ficticia de Tallerbit).
 * Versión 1 (con fallo): el producto se hace en int y se desborda en silencio.
 */
public class Pedido {

    static int totalCentimos(int unidades, int precioCentimos) {
        return unidades * precioCentimos;
    }
}
