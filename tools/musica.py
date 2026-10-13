#!/usr/bin/env python3
"""La musica del cartucho, ejecutando su motor de sonido (ver motor_musica.py).

Pide el sonido con `pide_pieza` (0xB8DE, A = numero; `pide_pieza_si_la_escena_
lo_permite`, 0xB8D3, mira antes la escena) y corre `suena_el_cuadro` (0xB992),
que la interrupcion llama cada cuadro. Tres voces de 16 bytes desde 0xE010; la
copia del registro 7 del PSG, en 0xE040. El cartucho es de 32 KB, sin mapper.
Uso:  musica.py registros 0x9F [cuadros] | mp3 0x9F f.mp3 | todas docs/audio
      musica.py barrido 0x80 0xFF | emu
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import motor_musica  # noqa: E402
from motor_musica import P  # noqa: E402

TABLA = "ninguna llamada directa: está en la tabla de pistas"

PIEZAS = [
    P(0x9F, "La pieza del 0x41B5", "The tune at 0x41B5",
      "`L_41B5` y `L_422B`"),
    P(0x93, "La pieza del 0x41D1", "The tune at 0x41D1", "`L_41D1`"),
    P(0xA2, "La pieza del 0x424D", "The tune at 0x424D", "`L_424D`"),
    P(0x95, "La pieza del 0x50B9", "The tune at 0x50B9", "`L_50B9`"),
] + [P(n, "Pista 0x%02X de la tabla" % n, "Table track 0x%02X" % n, TABLA)
     for n in (0x84, 0x96, 0x9D, 0x9E, 0xA0, 0xA1, 0xA3, 0xA4)]

PAGINA = motor_musica.pagina_basica(
    "`suena_el_cuadro`, 0xB992, y `pide_pieza`, 0xB8DE, que le reparte las "
    "voces; lo llama la interrupción",
    "`suena_el_cuadro`, 0xB992, and `pide_pieza`, 0xB8DE, which hands it the "
    "voices; the interrupt calls it",
    "C-BIOS MSX1 japonés",
    [("la pieza 0x9F entera, 170 cuadros, dos veces",
      "tune 0x9F, whole, 170 frames, twice"),
     ("la pieza 0x93, sus primeros 298 cuadros de 513, y en trozos de 181, "
      "126, 155 cuadros y otros, según cuándo la pisa otra petición",
      "tune 0x93, its first 298 frames of 513, and in stretches of 181, "
      "126, 155 frames and others, depending on when another request "
      "cuts in")],
    [("Cómo se pide una pieza",
      "`pide_pieza` recibe el número en A. Los números bajos son efectos y "
      "del 0x84 en adelante hay música. Cada voz ocupa dieciséis bytes desde "
      "0xE010 y 0xE040 guarda la copia del mezclador del PSG, que el "
      "arranque deja en 0xB8. Las pistas «de la tabla» están en la tabla de "
      "pistas pero ninguna rutina las pide con un `ld a`; se omite la 0x94, "
      "de varios minutos. El juego pide piezas por dos entradas: `pide_pieza` "
      "y `pide_pieza_si_la_escena_lo_permite`, que salta a la misma "
      "rutina; con las dos vigiladas, y con la RAM del sonido tal como "
      "estaba al pedir cada pieza, todos los trozos cuadran con openMSX.",
      "How a piece is asked for",
      "`pide_pieza` takes the number in A. Low numbers are effects and from "
      "0x84 up there is music. Each voice takes sixteen bytes from 0xE010 "
      "and 0xE040 holds the copy of the PSG mixer, which start-up leaves at "
      "0xB8. The tracks marked «in the table» are in the track table but no "
      "routine asks for them with an `ld a`; 0x94, several minutes long, is "
      "left out. The game asks for pieces through two entries: `pide_pieza` "
      "and `pide_pieza_si_la_escena_lo_permite`, which jumps into the same "
      "routine; with both watched, and with the sound RAM as it was when "
      "each piece was asked for, every stretch agrees with openMSX.")])

CFG = dict(rom="yiear2.rom", org=0x4000, frame=0xB992, pide=0xB8DE,
           ram=(0xE010, 0xE041), ram0=[(0xE040, 0xB8)],
           excluye=[0xE019, 0xE029, 0xE039], hz=60, psg0={7: 0xB8},
           piezas=PIEZAS, pagina=PAGINA,
           cotejado=[(0x9F, 170, None), (0x93, 513, 1)])

if __name__ == "__main__":
    sys.exit(motor_musica.main(CFG, sys.argv[1:]))
