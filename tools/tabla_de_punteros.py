#!/usr/bin/env python3
"""Dice si un hueco es una tabla de punteros, y hasta donde llega.

No basta con que las palabras "parezcan direcciones": en un cartucho de 32 KB
dos bytes cualesquiera caen dentro de 0x4000..0xBFFF una de cada cuatro veces.
Aqui se exigen tres cosas a la vez, y se dice cual falla cuando falla:

  1. todas las palabras leidas caen dentro del cartucho;
  2. NINGUNA apunta dentro de la propia tabla;
  3. la tabla acaba justo donde empieza su destino mas bajo POR DELANTE, o bien
     donde acaba el hueco.

La 3 es la que la cierra. Las entradas que apuntan hacia ATRAS no cuentan para
cerrarla -son saltos a codigo compartido anterior-, igual que en
tools/tablas_despacho.py.

Uso: tabla_de_punteros.py <rom> <org> <ini> <fin> [<ini> <fin> ...]
     tabla_de_punteros.py <rom> <org> --presupuesto   (rangos por la entrada)
"""
import re
import sys


def analiza(rom, org, a, b):
    """(n_entradas, fin, motivo) de la tabla que empieza en a sin pasar de b."""
    fin_rom = org + len(rom)
    n, tope = 0, b
    while True:
        p = a + n * 2
        if p + 1 >= b:
            return n, a + n * 2, "se acaba el hueco"
        w = rom[p - org] | (rom[p + 1 - org] << 8)
        if not (org <= w < fin_rom):
            return n, a + n * 2, "0x%04X no es una direccion del cartucho" % w
        if a <= w < a + n * 2 + 2:
            return n, a + n * 2, "0x%04X apunta dentro de la tabla" % w
        if w > a:
            tope = min(tope, w)
        n += 1
        if a + n * 2 >= tope:
            return n, a + n * 2, "llega a su destino mas bajo, 0x%04X" % tope


def main():
    if len(sys.argv) < 4:
        sys.exit(__doc__)
    rom = open(sys.argv[1], "rb").read()
    org = int(sys.argv[2], 0)
    if sys.argv[3] == "--presupuesto":
        rangos = []
        for ln in sys.stdin:
            m = re.search(r"0x([0-9A-Fa-f]{4})\.\.0x([0-9A-Fa-f]{4})", ln)
            if m:
                rangos.append((int(m.group(1), 16), int(m.group(2), 16) + 1))
    else:
        v = [int(x, 0) for x in sys.argv[3:]]
        rangos = list(zip(v[::2], v[1::2]))

    for a, b in rangos:
        n, fin, motivo = analiza(rom, org, a, b)
        entero = " TABLA ENTERA" if fin == b else ""
        print("0x%04X..0x%04X (%5d B): %3d entradas hasta 0x%04X%s  (%s)"
              % (a, b - 1, b - a, n, fin, entero, motivo))


if __name__ == "__main__":
    main()
