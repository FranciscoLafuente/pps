"""Descarga de adjuntos de la tienda ficticia Tallerbit. Versión 2 (corregida)."""
from pathlib import Path


def ruta_adjunto(base, nombre):
    """Devuelve la ruta del adjunto 'nombre', que debe quedar dentro de 'base'.

    Lanza ValueError si el nombre es vacío, contiene un byte nulo o, una vez
    resuelto (incluidos '..' y enlaces simbólicos), apunta fuera de 'base'.
    """
    if not nombre or "\x00" in nombre:
        raise ValueError("nombre de adjunto no válido")
    base_real = Path(base).resolve()
    destino = (base_real / nombre).resolve()
    if destino == base_real or not destino.is_relative_to(base_real):
        raise ValueError("el adjunto queda fuera del directorio permitido")
    return destino
