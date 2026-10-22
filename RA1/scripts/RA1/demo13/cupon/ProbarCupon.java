import java.util.Random;

/** Prueba de regresión: la semilla fija no debe permitir reproducir cupones. */
public class ProbarCupon {

    public static void main(String[] args) {
        String modo = args.length > 0 ? args[0] : "inseguro";
        String a, b;
        if (modo.equals("inseguro")) {
            a = CuponInseguro.generar(new Random(42), 8);
            b = CuponInseguro.generar(new Random(42), 8);
        } else {
            a = CuponSeguro.generar(8);
            b = CuponSeguro.generar(8);
        }
        System.out.println("cupon 1: " + a);
        System.out.println("cupon 2: " + b);
        if (a.equals(b)) {
            System.out.println("FALLO: se obtiene el mismo cupon");
            System.exit(1);
        }
        System.out.println("OK");
    }
}
