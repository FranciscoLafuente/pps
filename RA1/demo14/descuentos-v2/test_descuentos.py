import pytest

from descuentos import porcentaje_descuento


# Una prueba por partición de equivalencia: un valor representativo de cada tramo.
@pytest.mark.parametrize("unidades, esperado", [(5, 0), (25, 5), (75, 10), (500, 15)])
def test_valor_representativo_de_cada_tramo(unidades, esperado):
    assert porcentaje_descuento(unidades) == esperado


# Análisis de valores límite: justo en el borde de cada tramo y justo al lado.
@pytest.mark.parametrize(
    "unidades, esperado",
    [(1, 0), (9, 0), (10, 5), (49, 5), (50, 10), (99, 10), (100, 15)],
)
def test_valores_limite(unidades, esperado):
    assert porcentaje_descuento(unidades) == esperado


@pytest.mark.parametrize("unidades", [0, -1, -1000])
def test_unidades_no_validas_se_rechazan(unidades):
    with pytest.raises(ValueError):
        porcentaje_descuento(unidades)


@pytest.mark.parametrize("unidades", [2.5, "10", None])
def test_tipo_no_valido_se_rechaza(unidades):
    with pytest.raises(TypeError):
        porcentaje_descuento(unidades)
