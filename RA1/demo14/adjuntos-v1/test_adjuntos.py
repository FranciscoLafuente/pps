import random

import pytest

from adjuntos import ruta_adjunto


def esta_dentro(base, ruta):
    return ruta.resolve().is_relative_to(base.resolve())


# --- Comportamiento legítimo: debe seguir funcionando tras cualquier corrección.
@pytest.mark.parametrize("nombre", ["factura.pdf", "2026/factura.pdf", "a/b/c.txt"])
def test_nombres_legitimos_se_aceptan(tmp_path, nombre):
    resultado = ruta_adjunto(tmp_path, nombre)
    assert esta_dentro(tmp_path, resultado)
    assert resultado.name == nombre.split("/")[-1]


# --- Comportamiento que NO debe ocurrir (prueba negativa o de abuso).
@pytest.mark.parametrize(
    "nombre",
    ["../secreto.txt", "../../etc/passwd", "/etc/passwd", "a/../../b", "", ".", ".."],
)
def test_nombres_que_escapan_se_rechazan(tmp_path, nombre):
    with pytest.raises(ValueError):
        ruta_adjunto(tmp_path, nombre)


def test_enlace_simbolico_hacia_fuera_se_rechaza(tmp_path):
    base = tmp_path / "adjuntos"
    fuera = tmp_path / "fuera"
    base.mkdir()
    fuera.mkdir()
    (base / "enlace").symlink_to(fuera)
    with pytest.raises(ValueError):
        ruta_adjunto(base, "enlace/dato.txt")


# --- Prueba de propiedad: para cualquier nombre generado, o se rechaza o queda dentro.
def test_propiedad_nunca_se_sale_de_la_base(tmp_path):
    azar = random.Random(2026)  # semilla fija: la prueba es reproducible
    trozos = ["a", "b", "..", ".", "/", "//", "doc.txt"]
    for _ in range(2000):
        nombre = "".join(azar.choice(trozos) for _ in range(azar.randint(1, 6)))
        try:
            resultado = ruta_adjunto(tmp_path, nombre)
        except ValueError:
            continue
        assert esta_dentro(tmp_path, resultado), f"se sale de la base con {nombre!r}"
