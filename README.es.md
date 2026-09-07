# Yie Ar Kung-Fu II (Konami, MSX1) — desensamblado comentado

*(Also available [in English](README.md).)* ·
**[Leelo en la web](https://antxiko.github.io/YieArKungFu2-disassembly/es/)**

Desensamblado completo y comentado de **Yie Ar Kung-Fu II: The Emperor
Yie-Gah**, de Konami para MSX (RC-737, 32 KB, 1985). Los 32.768 bytes estan
explicados, y el listado reensambla la ROM **byte a byte**.

    explicado          32.768 de 32.768   100 %
    densidad           2.919 de 7.142     40,9 %
    bloques bajo 10 %        0 de 1.027
    tests                   44, en verde
    reensamblado       el mismo sha256 del cartucho

## Que hay aqui

    src/yiear2.asm       el listado comentado, generado
    src/yiear2.notes     los comentarios y los bloques de datos, con su medida
    src/yiear2.entries   los puntos de entrada que no se deducen estaticamente
    tools/               las herramientas: trazado, listado, imagenes, VRAM
    tests/               44 comprobaciones que no necesitan el cartucho
    docs/                la web bilingue

## El cartucho no esta aqui

`yiear2.rom` no se distribuye. Hay que poner el propio en la raiz; son 32.768
bytes exactos y

    sha256  bcb41b35ec0dddfd81ee9bd46998c0ea9c9435d6292e973d46c1324cc36e6150

## Reproducirlo

    make comprueba     # comprueba que tu ROM es la misma
    make               # listado, reensamblado, comprobaciones y tests
    make imagenes      # dibuja las pantallas y las figuras desde la ROM
    make vram          # coteja esas imagenes contra la VRAM de openMSX

## Ni una captura de pantalla

Todas las imagenes de este repositorio estan **dibujadas desde los bytes de la
ROM**, ejecutando en Python los mismos guiones, espejos y lectores de figuras
que corre el Z80. Y estan cotejadas byte a byte contra la VRAM del emulador:
**nueve pantallas, cero diferencias** en color (6.144 bytes), patrones (6.144) y
patrones de sprite (1.792). La del titulo cuadra ademas su tabla de nombres, 768
de 768 casillas.

## Lo que aparecio

- **El cartucho busca a su primera parte en la ranura de al lado.** Antes de
  instalar el gancho de interrupcion rastrea las cuatro ranuras y toma dos
  sumas de 16 bytes, y distingue las dos compilaciones del Yie Ar Kung-Fu
  (RC-725).
- **Media pantalla y un espejo**: el decorado se dibuja solo por la izquierda, y
  la derecha son los mismos patrones con los ocho bits del reves. De ahi que el
  color se escriba dos veces y el patron una.
- **El muneco son doce sprites**, y una de sus dos direcciones se calcula de la
  otra en vez de guardarse.
- **Una pantalla de oleadas son cuatro bytes**: ocho nibbles que eligen ocho de
  treinta figuras.
- **El truco de las vidas**: arriba una, izquierda dos, abajo tres, derecha
  cuatro.
- **La demostracion es una partida grabada**: 33 pulsaciones y sus duraciones.

Todo, con sus medidas, en
[Hallazgos](https://antxiko.github.io/YieArKungFu2-disassembly/es/HALLAZGOS.html),
y lo que *no* se sabe en
[Preguntas abiertas](https://antxiko.github.io/YieArKungFu2-disassembly/es/PREGUNTAS-ABIERTAS.html).

## Licencia y credito

Las herramientas, los comentarios, el analisis y la documentacion son MIT —
ver `LICENSE`. El juego no es nuestro: leer [AVISO-LEGAL.md](AVISO-LEGAL.md).

La marca oculta de Konami la descubrio **Manuel Pazos**.
