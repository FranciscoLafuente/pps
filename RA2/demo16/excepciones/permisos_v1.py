# permisos_v1.py - VERSIÓN VULNERABLE (solo para el laboratorio).
# Hallazgo : si el servicio de permisos no responde, se concede el acceso a los informes.
# Causa raíz: CWE-636 (no fallar de forma segura, "fail open").
# OWASP Top 10:2025, A10 Gestión incorrecta de condiciones excepcionales.


def puede_ver_informes(usuario, consultar_permisos):
    try:
        return "informes" in consultar_permisos(usuario)
    except Exception:
        # Ante cualquier fallo se "deja pasar" para que la aplicación siga funcionando.
        return True
