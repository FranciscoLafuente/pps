/* Frontera.java · ¿Puede un programa Java confinarse a si mismo con el SecurityManager?
 * Compilar: javac -d out Frontera.java     Ejecutar: java -cp out Frontera
 * Resultado esperado en JDK recientes: no. Se comprueba en vivo (verificar tambien en JDK 25). */
public class Frontera {

    @SuppressWarnings("removal")                         // la API esta marcada "para eliminar"
    public static void main(String[] args) {
        System.out.println("Version de Java: " + System.getProperty("java.version"));
        System.out.println("SecurityManager activo al arrancar: " + (System.getSecurityManager() != null));
        try {
            // Intento de instalar un gestor de seguridad propio.
            System.setSecurityManager(new SecurityManager());
            System.out.println("Resultado: se pudo instalar un SecurityManager (JDK antiguo o con --allow).");
        } catch (UnsupportedOperationException e) {
            // JDK recientes: la instalacion esta desactivada por defecto o eliminada.
            System.out.println("Resultado: NO se puede instalar -> " + e.getClass().getSimpleName());
            System.out.println("Mensaje del JDK: " + e.getMessage());
        }
    }
}
