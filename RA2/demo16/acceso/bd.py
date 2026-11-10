# bd.py - Base de datos de pruebas en memoria para la aplicación ficticia "Citas Tallerbit".
# No hay datos reales: nombres, matrículas y motivos son inventados.
import sqlite3


def crear_bd():
    """Crea una base SQLite en memoria con tres citas de tres clientes distintos."""
    con = sqlite3.connect(":memory:")
    con.execute(
        "CREATE TABLE citas (id INTEGER PRIMARY KEY, usuario TEXT, matricula TEXT, motivo TEXT)"
    )
    # Los "?" son parámetros: sqlite3 los rellena sin mezclar los datos con la orden SQL.
    con.executemany(
        "INSERT INTO citas (usuario, matricula, motivo) VALUES (?, ?, ?)",
        [
            ("marta", "1234ABC", "Cambio de aceite"),
            ("luis", "5678DEF", "Revision de frenos"),
            ("irene", "9012GHI", "Diagnosis electronica"),
        ],
    )
    return con
