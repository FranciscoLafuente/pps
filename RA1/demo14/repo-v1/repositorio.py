"""Acceso a datos de la tienda ficticia Tallerbit. Versión 1 (con fallo)."""
import sqlite3


def crear_bd():
    conexion = sqlite3.connect(":memory:")
    conexion.execute("CREATE TABLE usuarios (id INTEGER PRIMARY KEY, nombre TEXT, rol TEXT)")
    conexion.executemany(
        "INSERT INTO usuarios (nombre, rol) VALUES (?, ?)",
        [("ana", "admin"), ("luis", "lector"), ("marta", "lector")],
    )
    return conexion


def buscar_por_nombre(conexion, nombre):
    consulta = f"SELECT id, nombre, rol FROM usuarios WHERE nombre = '{nombre}'"
    return conexion.execute(consulta).fetchall()
