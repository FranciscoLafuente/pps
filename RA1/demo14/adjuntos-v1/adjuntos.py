"""Descarga de adjuntos de la tienda ficticia Tallerbit. Versión 1 (con fallo)."""
from pathlib import Path


def ruta_adjunto(base, nombre):
    """Devuelve la ruta del fichero adjunto 'nombre' dentro del directorio 'base'."""
    return Path(base) / nombre
