"""calculadora.py · VERSION CORREGIDA (v2): se analiza el texto y solo se calculan operaciones permitidas.

Idea: no ejecutar el texto, sino convertirlo en un arbol (ast.parse) y recorrerlo nosotros,
aceptando unicamente numeros, + - * / %, el signo y los parentesis. Todo lo demas se rechaza.
"""
import ast
import operator

# Lista BLANCA de operaciones permitidas (lo que no esta aqui, no se calcula).
_BINARIAS = {
    ast.Add: operator.add,
    ast.Sub: operator.sub,
    ast.Mult: operator.mul,
    ast.Div: operator.truediv,
    ast.Mod: operator.mod,
}
_UNARIAS = {ast.USub: operator.neg, ast.UAdd: operator.pos}
LONGITUD_MAXIMA = 200               # evita expresiones gigantes (consumo de memoria y de CPU)


def evaluar(expresion):
    """Evalua una expresion aritmetica sencilla. Lanza ValueError si no es valida o no esta permitida."""
    if not isinstance(expresion, str) or not expresion.strip():
        raise ValueError("expresion vacia")
    if len(expresion) > LONGITUD_MAXIMA:
        raise ValueError("expresion demasiado larga")
    try:
        arbol = ast.parse(expresion.strip(), mode="eval")      # solo analiza, NO ejecuta nada
        return _calcular(arbol.body)
    except ZeroDivisionError as error:
        raise ValueError("division por cero") from error
    except (SyntaxError, RecursionError) as error:
        raise ValueError("expresion mal formada") from error


def _calcular(nodo):
    """Recorre el arbol y calcula solo los nodos permitidos."""
    # type(...) in (int, float) deja fuera a bool (True/False) y a cadenas, listas, etc.
    if isinstance(nodo, ast.Constant) and type(nodo.value) in (int, float):
        return nodo.value
    if isinstance(nodo, ast.BinOp) and type(nodo.op) in _BINARIAS:
        return _BINARIAS[type(nodo.op)](_calcular(nodo.left), _calcular(nodo.right))
    if isinstance(nodo, ast.UnaryOp) and type(nodo.op) in _UNARIAS:
        return _UNARIAS[type(nodo.op)](_calcular(nodo.operand))
    # Llamadas, atributos, nombres, listas, potencias... todo lo demas es un error.
    raise ValueError("elemento no permitido: " + type(nodo).__name__)
