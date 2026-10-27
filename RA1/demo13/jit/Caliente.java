public class Caliente {
    static long suma(int n) {
        long total = 0;
        for (int i = 0; i < n; i++) {
            total += i % 7;
        }
        return total;
    }
    public static void main(String[] args) {
        long t0 = System.nanoTime();
        long r = 0;
        for (int k = 0; k < 2000; k++) {
            r += suma(100_000);
        }
        long ms = (System.nanoTime() - t0) / 1_000_000;
        System.out.println("resultado=" + r + " tiempo=" + ms + " ms");
    }
}
