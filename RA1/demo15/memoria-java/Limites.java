/* Limites.java · Java convierte los errores de memoria y de tipo en excepciones controladas.
 * Compilar: javac -d out Limites.java      Ejecutar: java -cp out Limites
 * Version de referencia del modulo: JDK 25 (probado solo con JDK 21 en el entorno de preparacion). */
public class Limites {

    public static void main(String[] args) {
        // 1) Acceso fuera de limites: en C seria comportamiento indefinido; aqui, una excepcion.
        int[] datos = new int[4];                       // indices validos: 0, 1, 2 y 3
        try {
            datos[10] = 99;                              // intento de escribir lejos del array
        } catch (ArrayIndexOutOfBoundsException e) {
            System.out.println("1) Fuera de limites -> " + e.getClass().getSimpleName() + ": " + e.getMessage());
        }

        // 2) Referencia nula: el programa falla de forma limpia, no lee direcciones arbitrarias.
        String texto = null;
        try {
            System.out.println(texto.length());
        } catch (NullPointerException e) {
            System.out.println("2) Referencia nula -> " + e.getClass().getSimpleName());
        }

        // 3) Conversion de tipos incorrecta: el tipo se comprueba en tiempo de ejecucion.
        Object o = "soy una cadena";
        try {
            Integer n = (Integer) o;                     // una cadena no es un entero
            System.out.println(n);
        } catch (ClassCastException e) {
            System.out.println("3) Conversion invalida -> " + e.getClass().getSimpleName());
        }

        // 4) Lo que Java NO evita: el desbordamiento de enteros pasa en silencio.
        int cantidad = Integer.MAX_VALUE;                // 2147483647
        int total = cantidad + 1;                        // no hay excepcion: da la vuelta
        System.out.println("4) Entero desbordado en silencio -> " + total);
        try {
            Math.addExact(cantidad, 1);                  // la version "exacta" si lanza excepcion
        } catch (ArithmeticException e) {
            System.out.println("   Math.addExact lo detecta -> " + e.getClass().getSimpleName() + ": " + e.getMessage());
        }
    }
}
