# test_permisos.py - Prueba de regresión del fallo seguro (CWE-636).
# Uso: VERSION=v1 python -m pytest -q    (debe fallar)
#      VERSION=v2 python -m pytest -q    (debe pasar)
import importlib
import os

permisos = importlib.import_module(f"permisos_{os.environ.get('VERSION', 'v2')}")


def servicio_con_permisos(usuario):
    return {"marta": ["informes"], "luis": []}[usuario]


def servicio_caido(usuario):
    raise ConnectionError("el servicio de permisos no responde")


def test_usuario_con_permiso_accede():
    assert permisos.puede_ver_informes("marta", servicio_con_permisos) is True


def test_usuario_sin_permiso_no_accede():
    assert permisos.puede_ver_informes("luis", servicio_con_permisos) is False


def test_si_el_servicio_falla_se_deniega():
    assert permisos.puede_ver_informes("luis", servicio_caido) is False
