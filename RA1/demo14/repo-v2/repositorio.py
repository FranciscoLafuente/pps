"""Acceso a datos de la tienda ficticia Tallerbit. Versión 2 (corregida)."""
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
    consulta = "SELECT id, nombre, rol FROM usuarios WHERE nombre = ?"
    return conexion.execute(consulta, (nombre,)).fetchall()
