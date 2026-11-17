# fichas_v1.py - VERSIÓN VULNERABLE (solo para el laboratorio).
# Hallazgo : cualquier usuario autenticado ve la cita de otro cambiando el número de la URL.
# Causa raíz: CWE-639 / CWE-862 (falta de comprobación de autorización por registro).
# OWASP Top 10:2025, A01 Control de acceso defectuoso.


def obtener_cita(con, usuario_actual, cita_id):
    # Se busca solo por identificador. Nadie comprueba si la cita pertenece a usuario_actual.
    return con.execute(
        "SELECT id, usuario, matricula, motivo FROM citas WHERE id = ?", (cita_id,)
    ).fetchone()
