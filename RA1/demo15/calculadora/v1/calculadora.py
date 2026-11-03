"""calculadora.py · VERSION VULNERABLE (v1) de la calculadora de presupuestos de Tallerbit.

Defecto: se evalua el texto del usuario con eval(). Si el texto es codigo Python, se ejecuta
(CWE-95 / CWE-94, a verificar en la lista vigente).
"""


def evaluar(expresion):
    """Devuelve el resultado de una expresion aritmetica escrita por el usuario."""
    return eval(expresion)          # eval ejecuta CUALQUIER expresion Python, no solo aritmetica
