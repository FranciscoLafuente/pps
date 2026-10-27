"""Descuento por volumen de la tienda ficticia Tallerbit. Versión 2 (corregida)."""


def porcentaje_descuento(unidades):
    """Devuelve el porcentaje de descuento (0, 5, 10 o 15) según las unidades del pedido.

    Tramos: 1-9 unidades 0 %, 10-49 5 %, 50-99 10 %, 100 o más 15 %.
    """
    if not isinstance(unidades, int):
        raise TypeError("las unidades deben ser un entero")
    if unidades < 1:
        raise ValueError("las unidades deben ser al menos 1")
    if unidades >= 100:
        return 15
    if unidades >= 50:
        return 10
    if unidades >= 10:
        return 5
    return 0
