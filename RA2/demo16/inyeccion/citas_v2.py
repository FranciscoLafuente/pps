# citas_v2.py - VERSIÓN CORREGIDA.
# Corrección: consulta parametrizada. La orden SQL y el dato viajan por separado.


def buscar_por_matricula(con, matricula):
    # El "?" marca dónde irá el dato. sqlite3 lo trata siempre como un valor, nunca como SQL.
    consulta = (
        "SELECT id, usuario, matricula, motivo FROM citas WHERE matricula = ?"
    )
    return con.execute(consulta, (matricula,)).fetchall()
