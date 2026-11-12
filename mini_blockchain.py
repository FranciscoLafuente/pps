# Mini cadena de bloques para la clase (solo la librería estándar de Python)
# Ejecutar con: python3 mini_blockchain.py
import hashlib, json

def hash_bloque(b):
    texto = json.dumps({k: b[k] for k in ("indice", "transacciones", "hash_anterior")}, sort_keys=True)
    return hashlib.sha256(texto.encode()).hexdigest()

def nuevo_bloque(cadena, transacciones):
    ant = cadena[-1]["hash"] if cadena else "0" * 64
    b = {"indice": len(cadena), "transacciones": transacciones, "hash_anterior": ant}
    b["hash"] = hash_bloque(b)
    cadena.append(b)

def validar(cadena):
    for i, b in enumerate(cadena):
        if b["hash"] != hash_bloque(b):
            return f"BLOQUE {i} MANIPULADO (su hash no coincide con su contenido)"
        if i > 0 and b["hash_anterior"] != cadena[i - 1]["hash"]:
            return f"CADENA ROTA en el bloque {i} (apunta a un hash que ya no existe)"
    return "cadena íntegra"

cadena = []
nuevo_bloque(cadena, ["Ana paga 5 a Luis"])
nuevo_bloque(cadena, ["Luis paga 2 a Marta"])
nuevo_bloque(cadena, ["Marta paga 1 a Ana"])

for b in cadena:
    print(b["indice"], b["hash"][:16], "<-", b["hash_anterior"][:16], b["transacciones"])
print("Validación:", validar(cadena))

print("\nManipulamos el bloque 1: Luis pagó 200 en vez de 2")
cadena[1]["transacciones"] = ["Luis paga 200 a Marta"]
print("Validación:", validar(cadena))

print("\nEl atacante recalcula el hash del bloque 1 para disimular...")
cadena[1]["hash"] = hash_bloque(cadena[1])
print("Validación:", validar(cadena))
print("...pero el bloque 2 sigue apuntando al hash antiguo. Habría que rehacer TODOS los bloques siguientes,")
print("y en una red real, además, convencer a la mayoría de los nodos (ataque del 51 %).")
