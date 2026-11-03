"""Pruebas de pytest sobre la CONFIGURACION de seguridad de un contenedor ya creado.

Misma idea que en 1.4: cada prueba dice una cosa que debe ser cierta; si falla, el informe
muestra lo esperado y lo obtenido. Se elige el contenedor con la variable CONTENEDOR.
Uso:   CONTENEDOR=tallerbit-v1 python3 -m pytest -q test_contenedor.py
"""
import os
import subprocess

NOMBRE = os.environ.get("CONTENEDOR", "tallerbit-v2")


def inspeccionar(plantilla):
    """Lee un campo de la configuracion real del contenedor con 'docker inspect'."""
    r = subprocess.run(["docker", "inspect", "-f", plantilla, NOMBRE],
                       capture_output=True, text=True)
    assert r.returncode == 0, "no se pudo inspeccionar el contenedor " + NOMBRE + ": " + r.stderr.strip()
    return r.stdout.strip()


def test_no_se_ejecuta_como_root():
    usuario = inspeccionar("{{.Config.User}}")
    assert usuario not in ("", "0", "root") and not usuario.startswith("0:"), "usuario actual: '" + usuario + "'"


def test_sistema_de_ficheros_de_solo_lectura():
    assert inspeccionar("{{.HostConfig.ReadonlyRootfs}}") == "true"


def test_capacidades_eliminadas():
    assert "ALL" in inspeccionar("{{.HostConfig.CapDrop}}")


def test_sin_nuevos_privilegios():
    assert "no-new-privileges" in inspeccionar("{{.HostConfig.SecurityOpt}}")


def test_sin_red():
    assert inspeccionar("{{.HostConfig.NetworkMode}}") == "none"


def test_limite_de_procesos():
    valor = inspeccionar("{{.HostConfig.PidsLimit}}")
    assert valor.isdigit() and int(valor) > 0, "limite actual: " + valor


def test_limite_de_memoria():
    valor = inspeccionar("{{.HostConfig.Memory}}")
    assert valor.isdigit() and int(valor) > 0, "limite actual: " + valor


def test_no_es_privilegiado():
    assert inspeccionar("{{.HostConfig.Privileged}}") == "false"
