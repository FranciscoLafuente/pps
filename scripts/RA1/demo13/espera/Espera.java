public class Espera {
    public static void main(String[] args) throws InterruptedException {
        System.out.println("Proceso en marcha, PID " + ProcessHandle.current().pid());
        Thread.sleep(60_000);
    }
}
