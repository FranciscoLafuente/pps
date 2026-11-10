# fichas_v2.py - VERSIÓN CORREGIDA.
# Corrección: la propiedad del registro forma parte de la consulta (denegar por defecto).


def obtener_cita(con, usuario_actual, cita_id):
    # Solo se devuelve la fila si el identificador Y el propietario coinciden.
    # Si no es suya, el resultado es el mismo que si no existiera (None): la aplicación
    # responderá "no encontrada" y no revela que esa cita existe.
    return con.execute(
        "SELECT id, usuario, matricula, motivo FROM citas WHERE id = ? AND usuario = ?",
        (cita_id, usuario_actual),
    ).fetchone()
