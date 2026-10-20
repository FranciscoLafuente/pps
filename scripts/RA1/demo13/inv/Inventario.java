import java.util.List;
import java.util.Map;

/**
 * Revisión de exposición de un inventario de servidores ficticios.
 * Equivalente en Java del ejercicio de inventario escrito en Python.
 */
public class Inventario {

    record Servidor(String hostname, String ip, String so, boolean firewall, List<Integer> puertos) {}

    static final Map<Integer, String> SERVICIOS_RIESGO = Map.of(
            21, "FTP, transmite credenciales sin cifrar",
            23, "Telnet, transmite todo sin cifrar",
            3306, "MySQL accesible desde la red");

    public static void main(String[] args) {
        List<Servidor> servidores = List.of(
                new Servidor("srv-web-01", "10.0.5.50", "Debian 12", true, List.of(22, 80, 443)),
                new Servidor("srv-db-01", "10.0.5.60", "Debian 12", true, List.of(22, 3306)),
                new Servidor("srv-ftp-01", "10.0.5.70", "Ubuntu 18.04", false, List.of(21, 22)),
                new Servidor("srv-test-01", "10.0.5.80", "Debian 12", false, List.of(22, 8080, 8443)));

        for (Servidor servidor : servidores) {
            if (!servidor.firewall()) {
                System.out.println("[RIESGO] " + servidor.hostname() + " no tiene cortafuegos");
            }
            for (int puerto : servidor.puertos()) {
                if (SERVICIOS_RIESGO.containsKey(puerto)) {
                    System.out.println("[RIESGO] " + servidor.hostname() + " expone el puerto "
                            + puerto + ": " + SERVICIOS_RIESGO.get(puerto));
                }
            }
        }
    }
}
