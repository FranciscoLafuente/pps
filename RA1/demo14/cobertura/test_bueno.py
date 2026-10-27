import pytest

from clasificar import nivel_riesgo


@pytest.mark.parametrize(
    "impacto, probabilidad, esperado",
    [
        (5, 5, "alto"),    # 25
        (3, 5, "alto"),    # 15: justo en el borde
        (3, 4, "medio"),   # 12: justo debajo del borde de "alto"
        (2, 3, "medio"),   # 6: justo en el borde
        (1, 5, "bajo"),    # 5: justo debajo del borde de "medio"
        (1, 1, "bajo"),    # 1
    ],
)
def test_clasificacion_y_bordes(impacto, probabilidad, esperado):
    assert nivel_riesgo(impacto, probabilidad) == esperado
