public class Nivelacion {

    static int cuadrado(int n) {
        return n * n;
    }

    public static void main(String[] args) {
        String nombre = "Tallerbit";
        int puertos = 3;
        boolean activo = true;

        System.out.println("Servidor de " + nombre + " con " + puertos + " puertos, activo: " + activo);

        for (int i = 1; i <= puertos; i++) {
            if (i % 2 == 0) {
                System.out.println(i + " es par");
            } else {
                System.out.println(i + " es impar");
            }
        }
        System.out.println("El cuadrado de 7 es " + cuadrado(7));
    }
}
