# permisos_v2.py - VERSIÓN CORREGIDA.
# Corrección: ante un fallo se deniega (fail closed) y se registra el incidente.
import logging

registro = logging.getLogger("permisos")


def puede_ver_informes(usuario, consultar_permisos):
    try:
        return "informes" in consultar_permisos(usuario)
    except Exception:
        # Se deja constancia (para detectar el fallo) y se deniega por defecto.
        registro.exception("Servicio de permisos no disponible; acceso denegado")
        return False
