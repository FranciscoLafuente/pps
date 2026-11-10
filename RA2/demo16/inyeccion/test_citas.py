# test_citas.py - Prueba de regresión de la búsqueda por matrícula (CWE-89).
# Uso: VERSION=v1 python -m pytest -q    (debe fallar)
#      VERSION=v2 python -m pytest -q    (debe pasar)
import importlib
import os


from bd import crear_bd

# Elige qué versión de la aplicación se prueba según la variable de entorno VERSION.
citas = importlib.import_module(f"citas_{os.environ.get('VERSION', 'v2')}")


def test_busqueda_legitima_devuelve_una_cita():
    con = crear_bd()
    filas = citas.buscar_por_matricula(con, "1234ABC")
    assert len(filas) == 1
    assert filas[0][1] == "marta"


def test_matricula_inexistente_devuelve_lista_vacia():
    con = crear_bd()
    assert citas.buscar_por_matricula(con, "0000ZZZ") == []


def test_texto_con_comilla_no_rompe_la_consulta():
    # Una comilla simple es un carácter normal en un dato: no debe provocar un error SQL.
    con = crear_bd()
    assert citas.buscar_por_matricula(con, "O'Brien") == []


def test_texto_manipulado_no_amplia_el_resultado():
    # Entrada con forma de condición SQL. Debe tratarse como un dato sin coincidencias.
    con = crear_bd()
    assert citas.buscar_por_matricula(con, "x' OR '1'='1") == []
