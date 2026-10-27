import pytest

from repositorio import buscar_por_nombre, crear_bd


@pytest.fixture
def bd():
    conexion = crear_bd()
    yield conexion
    conexion.close()


def test_usuario_existente(bd):
    assert buscar_por_nombre(bd, "ana") == [(1, "ana", "admin")]


def test_usuario_inexistente_devuelve_lista_vacia(bd):
    assert buscar_por_nombre(bd, "nadie") == []


def test_nombre_con_comilla_no_rompe_la_consulta(bd):
    # Un apellido legítimo con apóstrofo debe tratarse como un dato, no como sintaxis.
    assert buscar_por_nombre(bd, "o'brien") == []


def test_entrada_con_sintaxis_sql_se_trata_como_dato(bd):
    # Si la consulta mezcla datos y código, esto devolvería todos los usuarios.
    assert buscar_por_nombre(bd, "' OR '1'='1") == []
