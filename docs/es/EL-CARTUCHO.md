# El cartucho

    fichero    yiear2.rom
    tamano     32.768 bytes
    sha256     bcb41b35ec0dddfd81ee9bd46998c0ea9c9435d6292e973d46c1324cc36e6150
    catalogo   RC-737
    maquina    MSX1

## Donde vive

Un cartucho de 32 KB en las **paginas 1 y 2**, `0x4000..0xBFFF`. Sin paginacion
y sin mapper: los 32 KB estan a la vez y el Z80 los ve todos.

## Las dos cabeceras

La primera es la de siempre: en `0x4000` estan la firma `"AB"` y la direccion de
INIT, que aqui es `0x4070`. STATEMENT, DEVICE y TEXT valen cero, y los seis
bytes reservados tambien.

La segunda, en `0x4010`, no es cosa del MSX: es la cabecera del **Konami Game
Master**, el cartucho de trucos de la casa que se pone en la otra ranura. Son
`"AB" 07 37` -el `0x07` de los RC-7xx y el `0x37` de RC-737- y detras van siete
direcciones, las variables que el Game Master puede tocar:

| direccion | que es |
|---|---|
| `0x6400` | la rutina de la que se cuelga |
| `0xE000` | la escena |
| `0xE002` | la marca de escena |
| `0xE055` | las vidas |
| `0xE066` | la ronda |
| `0xE048` | los puntos |
| `0xE04E` | los puntos del jugador que juega |

Este cartucho **no la lee nunca**: `tools/quien_lee.py` da cero referencias a
`0x4010..0x4025`. Esta ahi para que la lea el de al lado.

## La marca oculta

Los ultimos quince bytes, cerrando justo en `0xBFFF`:

    FF 32 00 BA 9B AC 85 B9 A8 80 B9 BA 81 0C 37 AA

Detras estan `RC-737` y el titulo en **katakana escrito del reves**. Es la marca
que **Manuel Pazos** descubrio en los cartuchos de Konami -el numero de catalogo
y el titulo japones metidos en los ultimos bytes de la ROM-, y este la lleva.
`tools/marca_konami.py` la lee y `tools/busca_marca_konami.py` la busca por toda
la imagen.

## Lo que hace INIT, en orden

`0x4070`, y el orden importa:

1. le pregunta a la BIOS en que ranura primaria esta (`RSLREG`), calcula su
   ranura y subranura con `0xFCC1` y guarda el resultado en `(0xE451)`;
2. conmuta la **pagina 2** a esa misma ranura con `ENASLT`, para que respondan
   los 32 KB;
3. llama a `prepara_y_vuelve_a_mi_ranura`, que es el **rastreo de ranuras
   buscando la primera parte, el Yie Ar Kung-Fu (RC-725)**, y pasa antes
   que nada;
4. escribe un `jp cada_cuadro` en el gancho de interrupcion de `0xFD9A`;
5. pone la pila en `0xE400` y borra `0xE000..0xE3FF`;
6. enciende la pantalla, habilita interrupciones y cae en un `jr $`.

De ese `jr $` en adelante no pasa nada en el flujo principal: **el juego entero
cuelga de la interrupcion**.

## El VDP

`pon_los_registros_del_vdp` (`0x4952`) vuelca ocho bytes de `0x4963` en los
registros 0 a 7:

    02 E2 0E 7F 07 76 03 E4

Lo que da, y esta es la parte que sorprende:

| tabla | direccion |
|---|---|
| color | `0x0000..0x17FF` |
| patrones de sprite | `0x1800..0x1FFF` |
| patrones | `0x2000..0x37FF` |
| nombres | `0x3800..0x3AFF` |
| atributos de sprite | `0x3B00` |

**Los bancos van al reves de lo habitual**: los patrones en `0x2000` y el color
en `0x0000`. R3 y R4 no son direcciones sino base y mascara, y leerlos como
direcciones es lo que pone la tabla de color donde estan los patrones. La
consecuencia practica esta por todo el codigo: un mismo dibujo son dos guiones
con el mismo desplazamiento y `0x2000` de diferencia, como en
`monta_la_pantalla_de_combate`, que carga `0x01F0` y `0x21F0` con la misma
forma.

R7 vale `0xE4`: el borde y todo lo transparente salen **color 4**, azul oscuro.
Los sprites son de 16x16 (bit 1 de R1).

## La RAM

Todo lo que usa el juego esta de `0xE000` para arriba:

| tramo | que es |
|---|---|
| `0xE000..0xE00F` | escena, subescena, contador de cuadros, esperas, mandos |
| `0xE04A..0xE066` | puntos, nivel, vidas, ronda |
| `0xE080..0xE0FF` | la copia de la tabla de atributos de sprite |
| `0xE100..0xE1FF` | el muneco, el rival y sus figuras |
| `0xE2C0..0xE2E0` | la tira de escenarios por ronda, y el decorado de ahora |
| `0xE400` | la pila, que crece hacia abajo |
| `0xE450..0xE451` | la marca de la primera parte, y la ranura de este cartucho |

Y `0xE450` y `0xE451` estan **por encima** del bloque que INIT borra
(`0xE000..0xE3FF`), que no es casualidad: el rastreo de ranuras los escribe
antes del borrado.
