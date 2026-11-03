"""Pruebas de la calculadora: comportamiento legitimo y expresiones que NO son aritmetica."""
import pytest
from calculadora import evaluar

# --- Lo normal debe seguir funcionando (si no, una funcion que rechace todo "pasaria" las pruebas de abuso)
LEGITIMAS = [("2+3*4", 14), ("(1+2)*3", 9), ("10/4", 2.5), ("-5+2", -3), (" 7 - 2 ", 5), ("7%4", 3)]


@pytest.mark.parametrize("expresion,esperado", LEGITIMAS)
def test_expresiones_legitimas(expresion, esperado):
    assert evaluar(expresion) == esperado


# --- Lo que NO es aritmetica debe rechazarse con ValueError (entradas inofensivas, nada se escribe ni se abre)
NO_ARITMETICAS = [
    "__import__('os').getpid()",                    # llamada a una funcion integrada
    "abs(-3)",                                      # cualquier llamada a funcion
    "().__class__",                                 # acceso a atributos de objetos internos
    "().__class__.__bases__[0].__subclasses__()",   # recorrido de atributos: la via que burla a v1b
    "'a'*3",                                        # no son numeros
    "2**3",                                         # potencia: decision de diseno (9**9**9 bloquearia la CPU)
    "",                                             # vacio
    "1;2",                                          # varias sentencias
]


@pytest.mark.parametrize("expresion", NO_ARITMETICAS)
def test_cwe95_expresiones_no_aritmeticas_se_rechazan(expresion):
    with pytest.raises(ValueError):
        evaluar(expresion)


def test_division_por_cero_es_un_error_controlado():
    with pytest.raises(ValueError):
        evaluar("1/0")
