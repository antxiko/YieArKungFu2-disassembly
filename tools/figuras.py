#!/usr/bin/env python3
"""Monta las figuras de Yie Ar Kung-Fu II: las poses de LEE YOUNG y los ocho rivales.

Ninguna es un volcado crudo de patrones. Un volcado crudo de los 64 patrones de
sprite no dice nada -se ve en `graficos.py --hoja`-, porque el muneco NO es un
sprite: son DOCE, y lo que cambia por pose es donde va cada uno y que dibujo
tiene dentro.

EL MUNECO (0x6B79, `monta_al_jugador`). Su fotograma sale de los veinte
punteros de 0x6C83: diez dibujos en las entradas pares y diez REMISIONES de dos
bytes en las impares, que apuntan al dibujo de delante. Un dibujo es

    4 sprites   0x80 = vacio y ocupa 1 byte; si no [y][x][patron][color], y el
                CUARTO solo [y][x] (el `cp 1` de 0x6879 sale antes)
    1 byte      la paleta: indexa 0x6C51, que da una tira de ocho colores
    n trios     [y][x][patron] hasta un byte con el nibble alto a 8
    n guiones   el nibble BAJO de ese terminador dice cuantas palabras siguen,
                y cada una es un guion RLE que sube patrones de sprite

Y ahi esta el truco de las dos direcciones: mirando a un lado los ocho sprites
usan los patrones 0 a 7 -que `sube_los_patrones_del_fotograma` (0x6BE6) acaba
de subir a 0x1800 con esos guiones-, y mirando al otro los trios traen numeros
de patron que caen en el banco ESPEJADO que dejo `espeja_sprites`. Un dibujo,
dos direcciones, y solo una mitad se guarda.

LOS RIVALES (0x68A4, `mueve_al_enemigo`) no son sprites sino CASILLAS. Cada
escenario tiene el suyo -ocho bloques en 0x6922- y cada bloque, 22 entradas:

    [dy][dx]    se suman a la fila y la columna del enemigo
    4 sprites   igual que los del muneco
    figura      alto, ancho y las casillas comprimidas, con el lector que
                escribe CEROS (0x67A7), no con el que repite el byte

Uso: figuras.py <rom> <carpeta>
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import formatos as F                                          # noqa: E402
import graficos as G                                          # noqa: E402
import vram as V                                              # noqa: E402

ORG = 0x4000
FOTOGRAMAS = 0x6C83                   # los veinte punteros del muneco
COLORES_A = 0x6C51                    # la tabla de tiras de color
PATRONES_BASE = 0x6C7B                # 00 04 08 ... 1C: los ocho del muneco
ENEMIGOS = 0x6922                     # los ocho bloques de rival
POR_RIVAL = 22                        # entradas de cada bloque


def lee_los_cuatro_sprites(rom, p, org=ORG):
    """monta_los_sprites_con_a (0x684A): cuatro, y el cuarto sin patron ni color."""
    out = []
    for k in range(4):
        if rom[p - org] == 0x80:                 # sprite vacio, un solo byte
            p += 1
            continue
        y, x = rom[p - org], rom[p + 1 - org]
        if k == 3:                               # el cuarto no lleva mas
            out.append((y, x, None, None))
            p += 2
        else:
            out.append((y, x, rom[p + 2 - org], rom[p + 3 - org]))
            p += 4
    return out, p


def fotograma_del_jugador(rom, i, org=ORG):
    """Uno de los diez dibujos: sus sprites, sus colores y sus guiones."""
    p = rom[FOTOGRAMAS + 4 * i - org] | (rom[FOTOGRAMAS + 4 * i + 1 - org] << 8)
    cuatro, p = lee_los_cuatro_sprites(rom, p, org)
    paleta = rom[p - org]
    p += 1
    t = COLORES_A + 2 * paleta
    tira = rom[(rom[t - org] | (rom[t + 1 - org] << 8)) - org:][:8]
    trios = []
    while True:
        x = rom[p - org]
        if x & 0xF0 == 0x80:                     # el terminador
            cuantos = x & 0x0F
            p += 1
            guiones = [rom[p + 2 * k - org] | (rom[p + 2 * k + 1 - org] << 8)
                       for k in range(cuantos)]
            break
        trios.append((rom[p - org], rom[p + 1 - org], rom[p + 2 - org]))
        p += 3
    return cuatro, list(tira), trios, guiones


def dibuja_al_jugador(rom, i, fondo=(0x20, 0x20, 0x30)):
    """La pose i, montada como la monta el cartucho y pintada tal cual.

    Se parte de la VRAM de una partida de verdad -los patrones espejados ya
    subidos- y encima se sueltan los guiones del fotograma, que es exactamente
    lo que hace 0x6BE6 antes de que el VDP lo pinte.
    """
    v = V.como_en_la_demostracion(rom, 0)
    cuatro, tira, trios, guiones = fotograma_del_jugador(rom, i)
    for g in guiones:                            # sube_los_patrones_del_fotograma
        v.rle(g)

    # Los ocho de los trios llevan los patrones de 0x6C7B, en orden, y los
    # colores de la tira; los cuatro de cabecera traen los suyos dentro.
    puestos = [(y, x, rom[PATRONES_BASE + k - ORG], tira[k])
               for k, (y, x, _) in enumerate(trios[:8])]
    puestos += [(y, x, pat if pat is not None else 0, col if col is not None
                 else tira[0]) for y, x, pat, col in cuatro]

    def con_signo(b):
        return b - 256 if b > 127 else b

    puestos = [(con_signo(y), con_signo(x), pat, col) for y, x, pat, col in puestos]
    y0 = min(y for y, _, _, _ in puestos)
    x0 = min(x for _, x, _, _ in puestos)
    alto = max(y for y, _, _, _ in puestos) - y0 + 16
    ancho = max(x for _, x, _, _ in puestos) - x0 + 16
    px = [[fondo] * ancho for _ in range(alto)]
    for y, x, pat, col in puestos:
        d = G.sprite(v.v, (pat & 0xFC) >> 2, col & 0x0F, fondo)
        for f in range(16):
            for c in range(16):
                if d[f][c] != fondo:
                    px[y - y0 + f][x - x0 + c] = d[f][c]
    return px


def figuras_de_un_rival(rom, escenario, org=ORG):
    """Las entradas del bloque de un rival, ya leidas: (dy, dx, alto, ancho, casillas)."""
    t = ENEMIGOS + 2 * escenario
    bloque = rom[t - org] | (rom[t + 1 - org] << 8)
    out = []
    for i in range(POR_RIVAL):
        e = bloque + 2 * i
        p = rom[e - org] | (rom[e + 1 - org] << 8)
        if i % 2:                                # los impares son remisiones
            continue
        dy, dx = rom[p - org], rom[p + 1 - org]
        _, q = lee_los_cuatro_sprites(rom, p + 2, org)
        alto, ancho, casillas, _ = F.figura_a_ceros(rom, q, org)
        out.append((dy, dx, alto, ancho, casillas))
    return out


def dibuja_a_un_rival(rom, escenario, sep=2):
    """Las once figuras del rival de un escenario, con las casillas de SU pantalla.

    Las casillas se pintan con el banco del tercio en el que de verdad cae el
    enemigo -el de abajo, porque pelea en el suelo-, que es lo que hace que
    salgan con sus colores y no en blanco.
    """
    v = V.como_en_la_demostracion(rom, escenario).v
    dibujos = []
    for dy, dx, alto, ancho, casillas in figuras_de_un_rival(rom, escenario):
        if not alto or not ancho:
            continue
        px = [[(0, 0, 0)] * (ancho * 8) for _ in range(alto * 8)]
        for f in range(alto):
            for c in range(ancho):
                t = casillas[f * ancho + c]
                for y, fila in enumerate(G.casilla(v, t, 2, (0, 0, 0))):
                    px[f * 8 + y][c * 8:c * 8 + 8] = fila
        dibujos.append(px)
    if not dibujos:
        return [[(0, 0, 0)]]
    alto = max(len(d) for d in dibujos)
    ancho = sum(len(d[0]) + sep for d in dibujos) + sep
    out = [[(0x20, 0x20, 0x30)] * ancho for _ in range(alto + 2 * sep)]
    x = sep
    for d in dibujos:
        for y, fila in enumerate(d):
            out[sep + alto - len(d) + y][x:x + len(fila)] = fila
        x += len(d[0]) + sep
    return out


def main():
    rom = open(sys.argv[1], "rb").read()
    carpeta = sys.argv[2] if len(sys.argv) > 2 else "work/gfx"
    os.makedirs(carpeta, exist_ok=True)
    poses = [dibuja_al_jugador(rom, i) for i in range(10)]
    alto = max(len(p) for p in poses)
    ancho = max(len(p[0]) for p in poses)
    igual = []
    for p in poses:                              # todas al mismo tamano
        q = [[(0x20, 0x20, 0x30)] * ancho for _ in range(alto)]
        for y, fila in enumerate(p):
            q[alto - len(p) + y][:len(fila)] = fila
        igual.append(q)
    G.png(os.path.join(carpeta, "poses.png"), G.rejilla(igual, 5, sep=2), escala=3)
    for e in range(V.ESCENARIOS):
        G.png(os.path.join(carpeta, "rival%d.png" % (e + 1)),
              dibuja_a_un_rival(rom, e), escala=3)
    print("  poses.png (las diez del muneco) y ocho rival*.png")


if __name__ == "__main__":
    main()
