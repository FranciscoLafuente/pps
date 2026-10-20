/** Prueba de regresión del cálculo de pedidos. */
public class ProbarPedido {

    static int fallos = 0;

    static void comprueba(boolean condicion, String descripcion) {
        if (!condicion) {
            System.out.println("FALLO: " + descripcion);
            fallos++;
        }
    }

    static boolean seRechaza(int unidades, int precio) {
        try {
            Pedido.totalCentimos(unidades, precio);
            return false;
        } catch (IllegalArgumentException esperado) {
            return true;
        }
    }

    public static void main(String[] args) {
        // El uso normal debe seguir funcionando.
        comprueba(Pedido.totalCentimos(3, 1_000) == 3_000L, "el pedido normal debe dar 3000");
        comprueba(Pedido.totalCentimos(10_000, 1_000) == 10_000_000L, "el maximo permitido debe aceptarse");
        // Las entradas fuera de rango deben rechazarse, no producir un importe.
        comprueba(seRechaza(3_000_000, 1_000), "3000000 unidades deben rechazarse");
        comprueba(seRechaza(10_001, 1), "una unidad por encima del maximo debe rechazarse");
        comprueba(seRechaza(0, 1_000), "cero unidades deben rechazarse");
        comprueba(seRechaza(5, -100), "un precio negativo debe rechazarse");

        System.out.println(fallos == 0 ? "TODO OK" : "Resultado: " + fallos + " fallos");
        System.exit(fallos == 0 ? 0 : 1);
    }
}
