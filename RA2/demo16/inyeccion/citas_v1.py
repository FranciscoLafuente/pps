# citas_v1.py - VERSIÓN VULNERABLE (solo para el laboratorio).
# Hallazgo : la búsqueda por matrícula devuelve más filas de las que debe si se manipula el texto.
# Causa raíz: CWE-89 (inyección SQL). OWASP Top 10:2025, A05 Inyección.


def buscar_por_matricula(con, matricula):
    # El texto que llega del usuario se pega dentro de la orden SQL con una f-string.
    # La base de datos no puede distinguir qué parte es la orden y qué parte es el dato.
    consulta = (
        "SELECT id, usuario, matricula, motivo FROM citas "
        f"WHERE matricula = '{matricula}'"
    )
    return con.execute(consulta).fetchall()
