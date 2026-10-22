import java.util.ArrayList;
import java.util.List;

public class Memoria {

    static int profundidad = 0;

    static void recursion() {
        profundidad++;
        recursion();
    }

    public static void main(String[] args) {
        // Tipos primitivos: la variable contiene el valor.
        int a = 5;
        int b = a;
        b = 9;
        System.out.println("a=" + a + " b=" + b);

        // Objetos: la variable contiene una referencia a un objeto del monton.
        int[] x = {1, 2, 3};
        int[] y = x;
        y[0] = 99;
        System.out.println("x[0]=" + x[0] + " (y apunta al mismo objeto)");

        // La pila tiene un tamano limitado.
        try {
            recursion();
        } catch (StackOverflowError error) {
            System.out.println("StackOverflowError tras " + profundidad + " llamadas anidadas");
        }

        // El monton tambien: con -Xmx16m se agota rapido.
        List<byte[]> bloques = new ArrayList<>();
        try {
            while (true) {
                bloques.add(new byte[1_000_000]);
            }
        } catch (OutOfMemoryError error) {
            int n = bloques.size();
            bloques.clear();
            System.out.println("OutOfMemoryError tras reservar " + n + " bloques de 1 MB");
        }
        System.out.println("maxMemory visto por la JVM: " + (Runtime.getRuntime().maxMemory() / (1024 * 1024)) + " MB");
    }
}
