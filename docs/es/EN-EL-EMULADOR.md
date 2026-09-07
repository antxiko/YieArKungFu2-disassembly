# En el emulador

Todo lo de aqui esta medido con **openMSX** y una **Philips VG-8020**, que es la
maquina de esta serie.

    openmsx -machine Philips_VG_8020 -cart yiear2.rom

## El cartucho se juega solo

No hace falta jugar para medirlo. Desde el encendido encadena presentacion →
titulo → **demostracion**, y la demostracion es una *partida grabada*: 33
pulsaciones en `0x57E4` con sus duraciones en `0x5806`, que acaban en el `0xFF`
que busca `0x57DA`. Dos encendidos dan exactamente lo mismo, que es lo que hace
comparable todo esto.

`make sonda` apunta en que escena esta en cada segundo emulado:

    t=  5.00 escena=  0 sub=  0     la presentacion
    t= 12.00 escena=  1 sub=  0     el titulo
    t= 17.00 escena=  2 sub=  0     empieza el juego
    t= 22.00 escena=  2 sub=  1     la demostracion, peleando
    t= 41.00 escena=  0 sub=  1     y otra vez desde el principio

## Llegar a los ocho escenarios sin jugar

La demostracion pelea siempre en el primero. `0x5776` deja la ronda a cero y
escribe el escenario en `(0xE2C0)` tres instrucciones antes de montar la
pantalla, asi que un punto de interrupcion en `0x5784` -ya escrito el cero-
puede poner ahi el que se quiera, y el cartucho monta **ese** decorado, **ese**
suelo y **ese** rival con su propio codigo.

No se falsea nada: se cambia un byte del estado de la partida, como lo tendria
un jugador que llegase a esa ronda. Eso es lo que hace `tools/omsx_vram.tcl`, y
asi se comprobaron las ocho pantallas de combate de este sitio.

## La comprobacion que cierra la duda

    make vram

Vuelca los 16 KB de VRAM en nueve instantes, y `tools/coteja_vram.py` les resta
la VRAM que monta `tools/vram.py` en Python:

| pantalla | color | patrones de sprite 8-63 | patrones |
|---|---|---|---|
| el titulo | 0/6144 | 0/1792 | 0/6144 |
| escenarios 1 al 8 | 0/6144 | 0/1792 | 0/6144 |

**Nueve pantallas, cero bytes distintos en todas las tablas estaticas.** La del
titulo cuadra ademas su tabla de nombres, 768 de 768 casillas.

Dos zonas se dejan fuera de esa cuenta a proposito, porque no son estaticas y el
emulador esta en mitad de la partida cuando se vuelca:

- **los patrones de sprite 0 a 7** (`0x1800..0x18FF`), que son la pose viva del
  muneco: `sube_los_patrones_del_fotograma` (`0x6BE6`) los rehace cada vez que
  cambia el fotograma;
- **la tabla de nombres**, donde se repintan cada cuadro el rival, el marcador y
  la barra de energia.

## Lo que mas costo cuadrar

Tres cosas, y ninguna se nota como un dibujo raro:

1. **El cartucho solo borra la tabla de nombres al cambiar de escena.** Ni los
   patrones ni el color. Montar una pantalla desde cero dejaba cientos de bytes
   distintos que no eran una lectura mala sino *herencia que faltaba*; el cotejo
   solo cierra a cero si se rehace la cadena entera desde el encendido.
2. **El escenario 4 lleva marcador de fase y los otros siete no** -el
   `cp 003h` de `0x5A7A`, en la cola misma de `espeja_el_decorado`-.
3. **La pareja fila/columna se guarda al reves de como se lee.**
   `ld bc,00704h` seguido de `ld (0e170h),bc` quiere decir fila 4, columna 7, y
   el bucle de `0x66FD` la pinta una fila mas arriba. Antes de arreglarlo, la
   pantalla del titulo tenia 165 casillas mal; despues, ninguna.

## Ver los extras

**El truco de las vidas.** Desde el encendido, antes de tocar nada: arriba una
vez, izquierda dos, abajo tres y derecha cuatro. `(0xE055)` se pone a `0x95`.

**La primera parte en la otra ranura.** Poner el Yie Ar Kung-Fu (RC-725) en la
segunda ranura, jugar una partida de un jugador y llegar a la ronda 3. Lo que
dibuja entonces `0x74A3` **no** esta grabado aqui: esta en las preguntas
abiertas.

## Para medir cualquier otra cosa

`tools/omsx_sonda.tcl` es el patron a copiar: un temporizador que lee un punado
de bytes de RAM por segundo emulado y los escribe. Los puntos de interrupcion de
ejecucion salen baratos; los de escritura tambien en juego normal, pero su
callback tiene que ser barato.
