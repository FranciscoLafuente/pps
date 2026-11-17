# test_asvs.py - Verificación ASVS 5.0.0 de "Citas Tallerbit" (extracto de la matriz, niveles L1 y L2).
#
# Cada prueba lleva en su NOMBRE el identificador del requisito:
#     test_v5_0_0_<capítulo>_<sección>_<requisito>_<qué se comprueba>
# Así el informe de pytest se lee como una matriz de verificación: cada línea es un requisito.
#
# Uso (desde la carpeta verificacion):
#     VERSION=v1 python3 -m pytest -v -rs    -> la versión 1 de la aplicación incumple tres requisitos
#     VERSION=v2 python3 -m pytest -v -rs    -> la versión 2 los cumple
import importlib
import os
import sys

import pytest

# La aplicación está en ../app. Se añade a la ruta de búsqueda de Python para poder importarla.
AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(AQUI, "..", "app"))

from bd import crear_bd  # noqa: E402

# La variable de entorno VERSION elige qué versión de la aplicación se verifica.
VERSION = os.environ.get("VERSION", "v2")
citas = importlib.import_module(f"citas_{VERSION}")
fichas = importlib.import_module(f"fichas_{VERSION}")
permisos = importlib.import_module(f"permisos_{VERSION}")


# ---------------------------------------------------------------------------
# v5.0.0-1.2.4 (L1): las consultas a la base de datos usan parámetros.
# Riesgo R2 del registro (A05 · CWE-89).
# ---------------------------------------------------------------------------
def test_v5_0_0_1_2_4_un_texto_con_comilla_es_un_dato():
    con = crear_bd()
    assert citas.buscar_por_matricula(con, "O'Brien") == []


def test_v5_0_0_1_2_4_un_texto_con_forma_de_condicion_es_un_dato():
    con = crear_bd()
    assert citas.buscar_por_matricula(con, "x' OR '1'='1") == []


# ---------------------------------------------------------------------------
# v5.0.0-8.2.2 (L1): el acceso a cada dato está limitado a quien tiene permiso sobre ese dato.
# Riesgo R1 del registro (A01 · CWE-639).
# ---------------------------------------------------------------------------
def test_v5_0_0_8_2_2_el_propietario_ve_su_cita():
    con = crear_bd()
    cita = fichas.obtener_cita(con, "marta", 1)  # la cita 1 es de marta
    assert cita is not None and cita[1] == "marta"


def test_v5_0_0_8_2_2_otro_usuario_no_ve_la_cita_ajena():
    con = crear_bd()
    assert fichas.obtener_cita(con, "luis", 1) is None  # luis pide la cita de marta


# ---------------------------------------------------------------------------
# v5.0.0-16.5.2 (L2): si falla el acceso a un recurso externo, la aplicación sigue funcionando de forma segura.
# Riesgo R7 del registro (A10 · CWE-636).
# ---------------------------------------------------------------------------
def servicio_con_permisos(usuario):
    return {"marta": ["informes"], "luis": []}[usuario]


def servicio_caido(usuario):
    raise ConnectionError("el servicio de permisos no responde")


def test_v5_0_0_16_5_2_con_el_servicio_operativo_se_concede_a_quien_tiene_permiso():
    assert permisos.puede_ver_informes("marta", servicio_con_permisos) is True


def test_v5_0_0_16_5_2_si_el_servicio_cae_se_deniega():
    assert permisos.puede_ver_informes("luis", servicio_caido) is False


# ---------------------------------------------------------------------------
# Requisitos que NO se verifican con una prueba de código: quedan marcados como "saltados"
# y el motivo indica cómo se verifican. Un requisito saltado no es un requisito cumplido.
# ---------------------------------------------------------------------------
@pytest.mark.skip(reason="8.1.1 se verifica leyendo la documentación de autorización")
def test_v5_0_0_8_1_1_existe_documentacion_de_las_reglas_de_acceso():
    pass


@pytest.mark.skip(reason="15.2.1 se verifica con el análisis de dependencias del pipeline (RA5)")
def test_v5_0_0_15_2_1_no_hay_componentes_fuera_de_plazo_de_actualizacion():
    pass


@pytest.mark.skip(reason="13.4.2 se verifica con una comprobación de la configuración desplegada")
def test_v5_0_0_13_4_2_la_depuracion_esta_desactivada_en_produccion():
    pass
