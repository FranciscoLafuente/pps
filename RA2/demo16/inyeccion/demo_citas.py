# demo_citas.py - Muestra la diferencia entre v1 y v2 con tres entradas.
# Uso: python demo_citas.py
import citas_v1
import citas_v2
from bd import crear_bd

ENTRADAS = ["1234ABC", "O'Brien", "x' OR '1'='1"]

for nombre, modulo in (("v1 (vulnerable)", citas_v1), ("v2 (corregida)", citas_v2)):
    print(f"--- {nombre} ---")
    for entrada in ENTRADAS:
        con = crear_bd()
        try:
            filas = modulo.buscar_por_matricula(con, entrada)
            print(f"  entrada {entrada!r:18} -> {len(filas)} fila(s)")
        except Exception as error:
            print(f"  entrada {entrada!r:18} -> ERROR {type(error).__name__}")
