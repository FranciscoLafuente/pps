# test_fichas.py - Prueba de regresión del control de acceso por registro (CWE-639).
# Uso: VERSION=v1 python -m pytest -q    (debe fallar)
#      VERSION=v2 python -m pytest -q    (debe pasar)
import importlib
import os

from bd import crear_bd

fichas = importlib.import_module(f"fichas_{os.environ.get('VERSION', 'v2')}")


def test_el_propietario_ve_su_cita():
    con = crear_bd()
    cita = fichas.obtener_cita(con, "marta", 1)  # la cita 1 es de marta
    assert cita is not None
    assert cita[1] == "marta"


def test_otro_usuario_no_ve_la_cita_ajena():
    con = crear_bd()
    assert fichas.obtener_cita(con, "luis", 1) is None  # luis pide la cita de marta


def test_cita_inexistente_da_el_mismo_resultado():
    con = crear_bd()
    assert fichas.obtener_cita(con, "marta", 999) is None
