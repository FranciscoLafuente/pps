"""Clasificación de riesgo por impacto x probabilidad (escala 1-5) de un registro de riesgos ficticio."""


def nivel_riesgo(impacto, probabilidad):
    puntuacion = impacto * probabilidad
    if puntuacion >= 15:
        return "alto"
    if puntuacion >= 6:
        return "medio"
    return "bajo"
