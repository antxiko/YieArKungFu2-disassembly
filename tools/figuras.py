#!/usr/bin/env python3
"""Monta las figuras de Yie Ar Kung-Fu II: las poses de LEE YOUNG y los ocho rivales.

Ninguna es un volcado crudo de patrones. Un volcado crudo de los 64 patrones de
sprite no dice nada -se ve en `graficos.py --hoja`-, porque el muneco NO es un
sprite: son DOCE, y lo que cambia por pose es donde va cada uno y que dibujo
tiene dentro.

EL MUNECO (0x6B79, `monta_al_jugador`). Su fotograma sale de los veinte
punteros de 0x6C83: diez dibujos en las entradas pares y diez REMISIONES de dos
bytes en las impares, que apuntan al dibujo de delante. Un dibujo es

    4 cajas     0x80 = no hay y ocupa 1 byte; si no [y][x][alto][ancho], y la
                CUARTA solo [y][x] (el `cp 1` de 0x6879 sale antes). NO son
                sprites: van a 0xE120 y las lee se_tocan (0x654F)
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
    4 cajas     igual que las del muneco
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


def lee_las_cuatro_cajas(rom, p, org=ORG):
    """monta_las_cajas_con_a (0x684A): cuatro, y la cuarta de solo [y][x].

    Son las CAJAS DE GOLPE del fotograma, no sprites: acaban en 0xE120 y las
    lee se_tocan (0x654F). Aqui se leen solo para saber cuanto ocupan y poder
    seguir hasta el byte de la paleta.
    """
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
    cajas, p = lee_las_cuatro_cajas(rom, p, org)
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
    return cajas, list(tira), trios, guiones


def dibuja_al_jugador(rom, i, fondo=None):
    """La pose i, montada como la monta el cartucho y pintada tal cual.

    Se parte de la VRAM de una partida de verdad -los patrones espejados ya
    subidos- y encima se sueltan los guiones del fotograma, que es exactamente
    lo que hace 0x6BE6 antes de que el VDP lo pinte.
    """
    if fondo is None:
        fondo = G.BORDE                          # el color de fondo del juego
    v = V.como_en_la_demostracion(rom, 0)
    cajas, tira, trios, guiones = fotograma_del_jugador(rom, i)
    for g in guiones:                            # sube_los_patrones_del_fotograma
        v.rle(g)

    # Los ocho de los trios llevan los patrones de 0x6C7B, en orden, y los
    # colores de la tira; los cuatro de cabecera traen los suyos dentro.
    puestos = [(y, x, rom[PATRONES_BASE + k - ORG], tira[k])
               for k, (y, x, _) in enumerate(trios[:8])]
    # Y NADA MAS. Las cuatro entradas de cabecera NO son sprites: son las
    # CAJAS DE GOLPE del fotograma. Se ve en donde acaban:
    # `monta_las_cajas_del_jugador` (0x6BFD) las escribe en 0xE120, y la
    # tabla de atributos de sprite en RAM es 0xE080..0xE0FF -los 0x80 bytes que
    # 0x500F aparca con 0xE0 en la y-, asi que 0xE120 cae FUERA. Quien la lee
    # es el codigo de choques: 0x5578 la nombra "la caja del jugador", y 0x541D
    # y 0x5526 hacen lo mismo con la del enemigo.
    #
    # Pintarlas como sprites era lo que sacaba manchones verdes sobre el muneco
    # -sus dos ultimos bytes son alto y ancho, no patron y color, y un 0x0C
    # leido como color da verde oscuro- y lo que descolocaba el pelo.

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
        _, q = lee_las_cuatro_cajas(rom, p + 2, org)
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
        px = [[G.BORDE] * (ancho * 8) for _ in range(alto * 8)]
        for f in range(alto):
            for c in range(ancho):
                t = casillas[f * ancho + c]
                for y, fila in enumerate(G.casilla(v, t, 2, G.BORDE)):
                    px[f * 8 + y][c * 8:c * 8 + 8] = fila
        dibujos.append(px)
    if not dibujos:
        return [[(0, 0, 0)]]
    # Todas al mismo tamano, apoyadas en el suelo, para que G.rejilla las
    # reparta en varias filas. En una sola tira las once figuras daban una
    # lamina de 1489 px de ancho, y en la pagina cada luchador quedaba
    # diminuto.
    alto = max(len(d) for d in dibujos)
    ancho = max(len(d[0]) for d in dibujos)
    igual = []
    for d in dibujos:
        q = [[G.BORDE] * ancho for _ in range(alto)]
        for y, fila in enumerate(d):
            q[alto - len(d) + y][:len(fila)] = fila
        igual.append(q)
    return G.rejilla(igual, 4, sep=sep, fondo=G.BORDE)


def main():
    rom = open(sys.argv[1], "rb").read()
    carpeta = sys.argv[2] if len(sys.argv) > 2 else "work/gfx"
    os.makedirs(carpeta, exist_ok=True)
    poses = [dibuja_al_jugador(rom, i) for i in range(10)]
    alto = max(len(p) for p in poses)
    ancho = max(len(p[0]) for p in poses)
    igual = []
    for p in poses:                              # todas al mismo tamano
        q = [[G.BORDE] * ancho for _ in range(alto)]
        for y, fila in enumerate(p):
            q[alto - len(p) + y][:len(fila)] = fila
        igual.append(q)
    G.png(os.path.join(carpeta, "poses.png"),
          G.rejilla(igual, 5, sep=2, fondo=G.BORDE), escala=3)
    for e in range(V.ESCENARIOS):
        G.png(os.path.join(carpeta, "rival%d.png" % (e + 1)),
              dibuja_a_un_rival(rom, e), escala=3)
    print("  poses.png (las diez del muneco) y ocho rival*.png")


if __name__ == "__main__":
    main()
