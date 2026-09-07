#!/usr/bin/env python3
"""Dibuja las pantallas de Yie Ar Kung-Fu II ejecutando los pasos del cartucho.

En este repositorio no hay ni una captura de pantalla. Todo lo que se ve sale
de aqui: tools/vram.py monta la VRAM traduciendo a Python las rutinas de carga
y esto pinta lo que esa VRAM dice, con la paleta del TMS9918.

Uso: graficos.py <rom> <org> <carpeta>
"""
import os
import struct
import sys
import zlib

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vram as V                                          # noqa: E402

# Los quince colores del MSX1 mas el transparente, en RGB, tal como los da la
# documentacion del TMS9918 de Texas Instruments.
PALETA = [
    (0, 0, 0), (0, 0, 0), (33, 200, 66), (94, 220, 120),
    (84, 85, 237), (125, 118, 252), (212, 82, 77), (66, 235, 245),
    (252, 85, 84), (255, 121, 120), (212, 193, 84), (230, 206, 128),
    (33, 176, 59), (201, 91, 186), (204, 204, 204), (255, 255, 255),
]

# El color de fondo -el borde, y con el TODO lo que en la tabla de color salga
# transparente- es el nibble bajo del registro 7. La tabla de arranque de
# 0x4963 dice 0xE4, o sea azul oscuro, pero eso solo vale hasta que empieza el
# juego: 0x5208 lo cambia con `ld b,0E0h` en cuanto la escena no es la cero, y
# el propio listado lo dice ahi -"el borde se pone negro"-. El nibble bajo pasa
# a 0, que es NEGRO.
#
# Tomar el 0xE4 de la tabla de arranque era el motivo de que todos los
# escenarios salieran con el fondo azul en vez de negro.
BORDE = PALETA[0xE0 & 0x0F]


def png(ruta, px, escala=2):
    """Escribe un PNG sin depender de ninguna biblioteca."""
    alto, ancho = len(px) * escala, len(px[0]) * escala
    crudo = bytearray()
    for f in px:
        fila = bytearray()
        for p in f:
            fila += bytes(p) * escala
        for _ in range(escala):
            crudo += b"\x00" + fila

    def trozo(tipo, datos):
        return (struct.pack(">I", len(datos)) + tipo + datos
                + struct.pack(">I", zlib.crc32(tipo + datos) & 0xFFFFFFFF))

    with open(ruta, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n")
        f.write(trozo(b"IHDR", struct.pack(">IIBBBBB", ancho, alto, 8, 2, 0, 0, 0)))
        f.write(trozo(b"IDAT", zlib.compress(bytes(crudo), 9)))
        f.write(trozo(b"IEND", b""))


def casilla(v, tile, banco, fondo=BORDE):
    """Los 8x8 pixeles de una casilla, con el color que le toca en su banco.

    En este cartucho los patrones estan en 0x2000 y el color en 0x0000, al
    reves de lo habitual; el tercio de pantalla elige el banco en los dos.
    """
    p = V.PATRONES + banco * 0x800 + tile * 8
    c = V.COLORES + banco * 0x800 + tile * 8
    out = []
    for f in range(8):
        forma, col = v[p + f], v[c + f]
        tinta, papel = PALETA[col >> 4], PALETA[col & 0x0F]
        if col >> 4 == 0:
            tinta = fondo
        if col & 0x0F == 0:
            papel = fondo
        out.append([tinta if forma & (0x80 >> b) else papel for b in range(8)])
    return out


def pantalla(v, fondo=BORDE):
    """Las 24x32 casillas de la tabla de nombres, cada tercio con su banco."""
    px = [[fondo] * 256 for _ in range(192)]
    for f in range(24):
        for c in range(32):
            t = v[V.NOMBRES + f * 32 + c]
            for y, fila in enumerate(casilla(v, t, f // 8, fondo)):
                px[f * 8 + y][c * 8:c * 8 + 8] = fila
    return px


def sprite(v, patron, color=0x0F, fondo=(0, 0, 0)):
    """Los 16x16 pixeles de un patron de sprite.

    Un patron de 16x16 son 32 bytes: los 16 primeros la columna IZQUIERDA y los
    16 ultimos la derecha. Es el reparto que da por bueno `espeja_sprites`
    (0x4919), que cambia las dos mitades de sitio para reflejarlo.
    """
    base = V.SPRITES + patron * 32
    px = [[fondo] * 16 for _ in range(16)]
    for y in range(16):
        for mitad in range(2):
            b = v[base + mitad * 16 + y]
            for x in range(8):
                if b & (0x80 >> x):
                    px[y][mitad * 8 + x] = PALETA[color & 0x0F]
    return px


def rejilla(dibujos, ancho, sep=1, fondo=(0x20, 0x20, 0x30)):
    """Pone en rejilla una lista de dibujos del mismo tamano."""
    if not dibujos:
        return [[fondo]]
    h, w = len(dibujos[0]), len(dibujos[0][0])
    filas = (len(dibujos) + ancho - 1) // ancho
    px = [[fondo] * (ancho * (w + sep) + sep)
          for _ in range(filas * (h + sep) + sep)]
    for i, d in enumerate(dibujos):
        f, c = divmod(i, ancho)
        y0, x0 = sep + f * (h + sep), sep + c * (w + sep)
        for y, fila in enumerate(d):
            px[y0 + y][x0:x0 + w] = fila
    return px


# ----------------------------------------------------------------------
# Las pantallas
# ----------------------------------------------------------------------
def pantalla_del_titulo(rom):
    """El logotipo, montado como lo monta 0x4CE9 y colocado por 0x4D10."""
    return pantalla(V.Vram(rom).desde_el_encendido().v)


def pantalla_de_combate(rom, escenario):
    """Uno de los ocho escenarios, con su decorado, su suelo y su rival."""
    return pantalla(V.Vram(rom).pantalla_de_combate(escenario).v)


def pantalla_de_oleadas(rom, decorado, fase):
    """Una de las doce pantallas de oleadas: cuatro decorados por tres fases.

    NO se publica: ver la nota de main(). Las casillas que piden sus figuras
    no son las que hay en la VRAM del combate, y de donde salen no se sabe.
    """
    return pantalla(V.Vram(rom).pantalla_de_oleadas(decorado, fase).v)


def hoja_de_casillas(rom, escenario=0):
    """Las 256 casillas de un escenario, en sus tres bancos."""
    v = V.Vram(rom).pantalla_de_combate(escenario).v
    dibujos = [casilla(v, t, b, (0, 0, 0)) for b in range(3) for t in range(256)]
    return rejilla(dibujos, 32)


def hoja_de_sprites(rom):
    """Los 64 patrones de sprite, tras subirlos y espejarlos.

    Los dieciseis guiones de 0x5B02 llenan de 0x1A00 a 0x2000 -o sea los
    patrones 16 a 63- y `espeja_sprites` los refleja sobre 0x1900, ocho
    patrones mas abajo. Se dibujan los 64 para que se vea el reparto entero.
    """
    v = V.Vram(rom).sprites_del_jugador().v
    return rejilla([sprite(v, p) for p in range(64)], 8, sep=2)


def rotulo(rom, fila=2, filas=9):
    """Solo la banda del logotipo, recortada de la pantalla del titulo.

    No es un dibujo aparte: son las mismas filas de la misma pantalla, la que
    monta 0x4CE9 y coloca 0x4D10. Se recorta para que sirva de cabecera.
    """
    px = pantalla(V.Vram(rom).desde_el_encendido().v)
    return px[fila * 8:(fila + filas) * 8]


def la_fuente(rom):
    """Los patrones de la fuente de la casa, del 0x00 al 0x5F.

    No trae el alfabeto entero: la fuente empieza las cifras en 0x10 y las
    letras en 0x21, que es el reparto que hace legibles los rotulos.
    """
    v = V.Vram(rom).desde_el_encendido().v
    return rejilla([casilla(v, t, 0, (0, 0, 0)) for t in range(0x60)], 16)


def main():
    rom = open(sys.argv[1], "rb").read()
    carpeta = sys.argv[3] if len(sys.argv) > 3 else "work/gfx"
    os.makedirs(carpeta, exist_ok=True)
    r = lambda n: os.path.join(carpeta, n)                     # noqa: E731

    png(r("titulo.png"), pantalla_del_titulo(rom))
    png(r("rotulo.png"), rotulo(rom), escala=3)
    png(r("fuente.png"), la_fuente(rom), escala=3)
    png(r("sprites.png"), hoja_de_sprites(rom), escala=3)
    png(r("casillas.png"), hoja_de_casillas(rom), escala=2)
    for e in range(V.ESCENARIOS):
        png(r("escenario%d.png" % (e + 1)), pantalla_de_combate(rom, e))
    # LAS PANTALLAS DE OLEADAS NO SE DIBUJAN, y no por olvido: montadas
    # sobre la VRAM del combate, sus figuras piden casillas que ahi son la
    # FUENTE, y salen letras. `monta_la_oleada` esta bien traducida -sus
    # tiras, sus nibbles y sus treinta figuras los comprueban los tests-,
    # pero de donde salen los patrones de esas casillas no se sabe. Lo que
    # no se sabe montar se dice, no se maquilla: esta en PREGUNTAS
    # ABIERTAS. Para mirarlas por dentro: pantalla_de_oleadas(rom, d, f).
    print("  titulo, rotulo, fuente, sprites, casillas y 8 escenarios")


if __name__ == "__main__":
    main()
