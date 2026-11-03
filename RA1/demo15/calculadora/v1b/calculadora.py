"""calculadora.py · VERSION v1b: el intento de "restringir" eval() quitando las funciones integradas.

Parece una defensa, pero NO es un aislamiento: el codigo sigue ejecutandose dentro del mismo
interprete y se puede llegar a objetos peligrosos recorriendo atributos de objetos que ya existen.
"""


def evaluar(expresion):
    """Evalua con un espacio de nombres vacio e intercepta cualquier error como ValueError."""
    try:
        # {"__builtins__": {}} oculta open, __import__, abs, etc. -> las llamadas directas fallan
        return eval(expresion, {"__builtins__": {}}, {})
    except Exception as error:     # NameError, SyntaxError, ZeroDivisionError...
        raise ValueError("expresion no valida") from error
