"""Descuento por volumen de la tienda ficticia Tallerbit. Versión 1 (con fallo)."""


def porcentaje_descuento(unidades):
    """Devuelve el porcentaje de descuento (0, 5, 10 o 15) según las unidades del pedido."""
    if not isinstance(unidades, int):
        raise TypeError("las unidades deben ser un entero")
    if unidades < 1:
        raise ValueError("las unidades deben ser al menos 1")
    if unidades > 100:
        return 15
    if unidades > 50:
        return 10
    if unidades > 10:
        return 5
    return 0
