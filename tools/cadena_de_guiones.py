#!/usr/bin/env python3
"""Prueba si un hueco es una cadena de guiones, y solo lo dice si CIERRA.

La prueba no es que el primer guion se lea sin reventar -eso pasa casi siempre-
sino que la cadena entera cubra el hueco EXACTAMENTE: ni un byte de sobra ni de
menos. Un formato mal leido se pasa de largo o se queda corto, y con esta
condicion no cuela.

Se prueban los tres formatos de tools/formatos.py -RLE con la direccion de VRAM
delante, RLE con el destino en HL, y literal- y se dice cual cierra. Si cierra
mas de uno, se dicen todos: entonces el encaje no decide y hay que mirar quien
lo llama.

Uso: cadena_de_guiones.py <rom> <ini> <fin> [<ini> <fin> ...]
     cadena_de_guiones.py <rom> --presupuesto     (rangos por la entrada)
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from formatos import guion_literal, guion_rle, texto              # noqa: E402

ORG = 0x4000


def cadena(rom, a, b, modo):
    """[(ini, fin, tramos)] si la cadena cierra justo en b; None si no."""
    p, out = a, []
    while p < b:
        try:
            if modo == "lit":
                t, n = guion_literal(rom, p)
            else:
                t, n = guion_rle(rom, p, modo == "rle")
        except IndexError:
            return None
        if n <= 0 or p + n > b:
            return None
        out.append((p, p + n, t))
        p += n
    return out if p == b else None


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    rom = open(sys.argv[1], "rb").read()
    if sys.argv[2] == "--presupuesto":
        rangos = []
        for ln in sys.stdin:
            m = re.search(r"0x([0-9A-Fa-f]{4})\.\.0x([0-9A-Fa-f]{4})", ln)
            if m:
                rangos.append((int(m.group(1), 16), int(m.group(2), 16) + 1))
    else:
        v = [int(x, 0) for x in sys.argv[2:]]
        rangos = list(zip(v[::2], v[1::2]))

    for a, b in rangos:
        cierran = [(m, cadena(rom, a, b, m)) for m in ("rle", "rleh", "lit")]
        cierran = [(m, c) for m, c in cierran if c]
        if not cierran:
            continue
        for m, c in cierran:
            print("0x%04X..0x%04X (%5d B)  CIERRA como %-4s con %d guiones"
                  % (a, b - 1, b - a, m, len(c)))
            for ini, fin, t in c:
                et = " / ".join(texto(d).strip() for _, d in t if d)[:52]
                print("      0x%04X..0x%04X %4d B  %s"
                      % (ini, fin, fin - ini, ("|%s|" % et) if et.strip() else ""))


if __name__ == "__main__":
    main()
