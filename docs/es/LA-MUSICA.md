# La música

Todo lo que suena aquí sale de ejecutar el motor de sonido del cartucho (`suena_el_cuadro`, 0xB992, y `pide_pieza`, 0xB8DE, que le reparte las voces; lo llama la interrupción) en un Z80 emulado, cuadro a cuadro y a 60 por segundo, igual que lo llama el juego. Lo que el motor escribe en el PSG pasa a sonido con un AY-3-8910 (`tools/musica.py`). Cada MP3 es la pieza entera hasta donde vuelve a empezar, más 8 segundos de la vuelta apagándose; las que no se repiten acaban donde acaba el motor.

## Cotejado con openMSX

Las escrituras al PSG se han comparado cuadro a cuadro con las de openMSX (C-BIOS MSX1 japonés). En todos los cuadros el PSG queda igual:

- la pieza 0x9F entera, 170 cuadros, dos veces;
- la pieza 0x93, sus primeros 210 cuadros de 513.

El timbre no está cotejado: es el de un AY-3-8910 de manual, no una grabación del emulador. Las sondas están en `tools/omsx_psg.tcl` y `tools/coteja_psg.py`.

## Cómo se pide una pieza

`pide_pieza` recibe el número en A. Los números bajos son efectos y del 0x84 en adelante hay música. Cada voz ocupa dieciséis bytes desde 0xE010 y 0xE040 guarda la copia del mezclador del PSG, que el arranque deja en 0xB8. Las pistas «de la tabla» están en la tabla de pistas pero ninguna rutina las pide con un `ld a`; se omite la 0x94, de varios minutos. En un segundo tramo de la 0x93 el cotejo cuadra 181 cuadros y luego el emulador sigue tocando donde este motor calla: no se ha averiguado por qué, y la pieza publicada puede diferir del juego pasado ese punto.

## Las músicas

**La pieza del 0x41B5** (0x9F)

Lo pide `L_41B5` y `L_422B`; dura 2,8 s.

<audio controls preload="none" src="../audio/musica_9F.mp3?v=321c7c8a"></audio>

**La pieza del 0x41D1** (0x93)

Lo pide `L_41D1`; dura 8,6 s y vuelve a empezar en el segundo 0,0.

<audio controls preload="none" src="../audio/musica_93.mp3?v=fba0a250"></audio>

**La pieza del 0x424D** (0xA2)

Lo pide `L_424D`; dura 2,6 s.

<audio controls preload="none" src="../audio/musica_A2.mp3?v=e4a16457"></audio>

**La pieza del 0x50B9** (0x95)

Lo pide `L_50B9`; dura 41,1 s y vuelve a empezar en el segundo 14,9.

<audio controls preload="none" src="../audio/musica_95.mp3?v=d11af31c"></audio>

**Pista 0x84 de la tabla** (0x84)

Lo pide ninguna llamada directa: está en la tabla de pistas; dura 11,6 s y vuelve a empezar en el segundo 11,2.

<audio controls preload="none" src="../audio/musica_84.mp3?v=4a05a9ec"></audio>

**Pista 0x96 de la tabla** (0x96)

Lo pide ninguna llamada directa: está en la tabla de pistas; dura 24,3 s y vuelve a empezar en el segundo 14,9.

<audio controls preload="none" src="../audio/musica_96.mp3?v=b0aa8de1"></audio>

**Pista 0x9D de la tabla** (0x9D)

Lo pide ninguna llamada directa: está en la tabla de pistas; dura 29,9 s.

<audio controls preload="none" src="../audio/musica_9D.mp3?v=b0c0cc74"></audio>

**Pista 0x9E de la tabla** (0x9E)

Lo pide ninguna llamada directa: está en la tabla de pistas; dura 29,9 s.

<audio controls preload="none" src="../audio/musica_9E.mp3?v=8e1554d5"></audio>

**Pista 0xA0 de la tabla** (0xA0)

Lo pide ninguna llamada directa: está en la tabla de pistas; dura 2,6 s.

<audio controls preload="none" src="../audio/musica_A0.mp3?v=cdfe6351"></audio>

**Pista 0xA1 de la tabla** (0xA1)

Lo pide ninguna llamada directa: está en la tabla de pistas; dura 2,6 s.

<audio controls preload="none" src="../audio/musica_A1.mp3?v=a1da126b"></audio>

**Pista 0xA3 de la tabla** (0xA3)

Lo pide ninguna llamada directa: está en la tabla de pistas; dura 2,6 s.

<audio controls preload="none" src="../audio/musica_A3.mp3?v=ed34a4fc"></audio>

**Pista 0xA4 de la tabla** (0xA4)

Lo pide ninguna llamada directa: está en la tabla de pistas; dura 2,6 s.

<audio controls preload="none" src="../audio/musica_A4.mp3?v=5b894ecb"></audio>
