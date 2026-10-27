import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import org.junit.jupiter.api.Test;

class PedidoTest {

    @Test
    void pedidoNormal() {
        assertEquals(3_000L, Pedido.totalCentimos(3, 1_000));
    }

    @Test
    void elMaximoPermitidoSeAcepta() {
        assertEquals(10_000_000L, Pedido.totalCentimos(10_000, 1_000));
    }

    @Test
    void rechazaUnidadesExcesivas() {
        assertThrows(IllegalArgumentException.class, () -> Pedido.totalCentimos(3_000_000, 1_000));
    }

    @Test
    void rechazaUnaUnidadPorEncimaDelMaximo() {
        assertThrows(IllegalArgumentException.class, () -> Pedido.totalCentimos(10_001, 1));
    }

    @Test
    void rechazaCeroUnidades() {
        assertThrows(IllegalArgumentException.class, () -> Pedido.totalCentimos(0, 1_000));
    }

    @Test
    void rechazaPrecioNegativo() {
        assertThrows(IllegalArgumentException.class, () -> Pedido.totalCentimos(5, -100));
    }
}
