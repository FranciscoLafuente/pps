"""Mini prueba de mutación manual (solo didáctica): cambia un operador cada vez en una copia
de clasificar.py y comprueba si las pruebas lo detectan. No sustituye a herramientas como mutmut o PIT."""
import pathlib
import shutil
import subprocess
import sys
import tempfile

AQUI = pathlib.Path(__file__).parent
MUTACIONES = [
    ("puntuacion >= 15", "puntuacion > 15"),
    ("puntuacion >= 6", "puntuacion > 6"),
    ("impacto * probabilidad", "impacto + probabilidad"),
    ('return "alto"', 'return "medio"'),
]


def pasan(carpeta, prueba):
    r = subprocess.run([sys.executable, "-m", "pytest", "-q", prueba], cwd=carpeta,
                       capture_output=True, text=True)
    return r.returncode == 0


def main():
    for prueba in ("test_flojo.py", "test_bueno.py"):
        if not (AQUI / prueba).exists():
            print(f"\n== {prueba} ==\n  (no existe todavía; se omite)")
            continue
        print(f"\n== {prueba} ==")
        vivos = 0
        for original, mutante in MUTACIONES:
            with tempfile.TemporaryDirectory() as tmp:
                for f in ("clasificar.py", prueba):
                    shutil.copy(AQUI / f, tmp)
                ruta = pathlib.Path(tmp) / "clasificar.py"
                texto = ruta.read_text(encoding="utf-8")
                assert original in texto, original
                ruta.write_text(texto.replace(original, mutante, 1), encoding="utf-8")
                sobrevive = pasan(tmp, prueba)
            vivos += sobrevive
            print(f"  {'SOBREVIVE' if sobrevive else 'detectado '}  {original!r} -> {mutante!r}")
        print(f"  mutantes que sobreviven: {vivos} de {len(MUTACIONES)}")


if __name__ == "__main__":
    main()
