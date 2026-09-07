# Empezar

Todo lo de aqui se reproduce. El listado no es un fichero terminado que haya que
creerse: se **genera** desde el cartucho, y al reensamblarlo devuelve el
cartucho byte a byte.

## Lo que hace falta

    python3        3.8 o posterior, sin bibliotecas
    pasmo          para reensamblar
    z80dasm        para desensamblar
    make
    openMSX        solo para las comprobaciones del emulador

## El cartucho no se distribuye

Este repositorio no trae el juego. Hay que poner la ROM en la raiz del proyecto
como `yiear2.rom`, 32.768 bytes exactos, y comprobar que es la misma:

    make comprueba

    bcb41b35ec0dddfd81ee9bd46998c0ea9c9435d6292e973d46c1324cc36e6150  yiear2.rom

## Todo de una vez

    make

Eso encadena cuatro pasos:

| paso | que hace |
|---|---|
| `listado` | traza el flujo desde los puntos de entrada declarados y escribe `src/yiear2.asm` |
| `verify` | lo reensambla con pasmo y compara el sha256 con la ROM |
| `sanity` | las cuatro comprobaciones que un reensamblado no puede hacer |
| `test` | los tests propios del repositorio |

El que decide si el desensamblado es fiable es `verify`:

    == ensamblando src/yiear2.asm (org 0x4000) ==
      ensamblado : 32768 bytes  bcb41b35...
      original   : 32768 bytes  bcb41b35...
    OK: reproducible byte a byte

## Lo que un reensamblado NO puede cazar

Leer datos como codigo da los mismos bytes. Eso lo caza `make sanity`, que son
cuatro comprobaciones distintas:

- **ningun byte declarado como datos puede salir como codigo** —
  `check_trace.py` y `check_datos_como_codigo.py`;
- **ningun punto de entrada puede caer dentro de una zona de datos** —
  `check_entradas.py`, nueve puntos de entrada contra 160 rangos de datos
  declarados;
- **ni un byte del cartucho sin asignar** — `presupuesto.py`, que tiene que
  sumar 32.768.

## Las imagenes

    make imagenes

`tools/graficos.py` y `tools/figuras.py` montan las pantallas ejecutando en
Python los mismos guiones, espejos y lectores de figuras que corre el Z80. En
este repositorio no hay ni una captura de pantalla.

## Y la comprobacion que cierra la duda

    make vram

Arranca el cartucho en openMSX, deja que su propia demostracion se juegue sola,
vuelca los 16 KB de VRAM en nueve instantes y les resta la VRAM que monta
Python. Mirar el dibujo no basta; esto si.

    9 pantallas cotejadas, 0 bytes distintos en las tablas estaticas

## Los demas objetivos

| objetivo | para que |
|---|---|
| `make densidad` | cuanto del listado esta comentado y que rutinas se quedan cortas |
| `make sonda` | en que escena esta el cartucho en cada segundo emulado |
| `make web` | rehace las imagenes y regenera este sitio |
