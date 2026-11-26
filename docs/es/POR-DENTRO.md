# Por dentro

## Empezar

Todo lo de aqui se reproduce. El listado no es un fichero terminado que haya que
creerse: se **genera** desde el cartucho, y al reensamblarlo devuelve el
cartucho byte a byte.

### Lo que hace falta

    python3        3.8 o posterior, sin bibliotecas
    pasmo          para reensamblar
    z80dasm        para desensamblar
    make
    openMSX        solo para las comprobaciones del emulador

### El cartucho no se distribuye

Este repositorio no trae el juego. Hay que poner la ROM en la raiz del proyecto
como `yiear2.rom`, 32.768 bytes exactos, y comprobar que es la misma:

    make comprueba

    bcb41b35ec0dddfd81ee9bd46998c0ea9c9435d6292e973d46c1324cc36e6150  yiear2.rom

### Todo de una vez

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

### Lo que un reensamblado NO puede cazar

Leer datos como codigo da los mismos bytes. Eso lo caza `make sanity`, que son
cuatro comprobaciones distintas:

- **ningun byte declarado como datos puede salir como codigo** —
  `check_trace.py` y `check_datos_como_codigo.py`;
- **ningun punto de entrada puede caer dentro de una zona de datos** —
  `check_entradas.py`, nueve puntos de entrada contra 160 rangos de datos
  declarados;
- **ni un byte del cartucho sin asignar** — `presupuesto.py`, que tiene que
  sumar 32.768.

### Las imagenes

    make imagenes

`tools/graficos.py` y `tools/figuras.py` montan las pantallas ejecutando en
Python los mismos guiones, espejos y lectores de figuras que corre el Z80. En
este repositorio no hay ni una captura de pantalla.

### Y la comprobacion que cierra la duda

    make vram

Arranca el cartucho en openMSX, deja que su propia demostracion se juegue sola,
vuelca los 16 KB de VRAM en nueve instantes y les resta la VRAM que monta
Python. Mirar el dibujo no basta; esto si.

    9 pantallas cotejadas, 0 bytes distintos en las tablas estaticas

### Los demas objetivos

| objetivo | para que |
|---|---|
| `make densidad` | cuanto del listado esta comentado y que rutinas se quedan cortas |
| `make sonda` | en que escena esta el cartucho en cada segundo emulado |
| `make web` | rehace las imagenes y regenera este sitio |

## El cartucho

    fichero    yiear2.rom
    tamano     32.768 bytes
    sha256     bcb41b35ec0dddfd81ee9bd46998c0ea9c9435d6292e973d46c1324cc36e6150
    catalogo   RC-737
    maquina    MSX1

### Donde vive

Un cartucho de 32 KB en las **paginas 1 y 2**, `0x4000..0xBFFF`. Sin paginacion
y sin mapper: los 32 KB estan a la vez y el Z80 los ve todos.

### Las dos cabeceras

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

### La marca oculta

Los ultimos quince bytes, cerrando justo en `0xBFFF`:

    FF 32 00 BA 9B AC 85 B9 A8 80 B9 BA 81 0C 37 AA

Detras estan `RC-737` y el titulo en **katakana escrito del reves**. Es la marca
que **Manuel Pazos** descubrio en los cartuchos de Konami -el numero de catalogo
y el titulo japones metidos en los ultimos bytes de la ROM-, y este la lleva.
`tools/marca_konami.py` la lee y `tools/busca_marca_konami.py` la busca por toda
la imagen.

### Lo que hace INIT, en orden

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

### El VDP

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

### La RAM

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

## El codigo

    13.725 bytes de codigo   41,89 %
    19.043 bytes de datos    58,11 %
         0 sin explicar       0,00 %
     1.027 bloques de codigo medidos, ninguno por debajo del 10 % comentado
       430 de las 1.168 etiquetas llevan nombre; el resto son saltos internos
     7.142 instrucciones, 2.923 comentarios de linea — 40,9 %

### Todo cuelga de la interrupcion

INIT acaba en un `jr $` en `0x40C1`. De ahi en adelante no pasa nada en el flujo
principal: `0x409B` ha escrito un `jp cada_cuadro` en el gancho de `0xFD9A`, y
`cada_cuadro` (`0x402E`) es el juego entero.

Lee el estado del VDP para limpiar la peticion de interrupcion, hace un cuadro
de sonido y se protege con `(0xE005)` para que un cuadro que tarde de mas no se
reentre. Luego lee los mandos y llama a `haz_el_cuadro`.

### Una escena, una subescena y un solo salto indirecto

`haz_el_cuadro` (`0x40CB`) cuenta el cuadro y reparte por `(0xE000)`, la escena,
con la tabla de ocho entradas de `0x40E9`. Dentro de cada escena se repite el
truco con `(0xE001)`, la subescena, y siempre por la misma rutina:

    reparte_por_tabla:
        pop hl        ; la tabla ES la direccion de retorno
        add a,a
        ...
        jp (hl)

`reparte_por_tabla` (`0x4066`) saca su propia direccion de retorno para
encontrar la tabla, y por eso en el listado cada tabla de reparto esta
**inmediatamente detras del `call`**. Y ese `jp (hl)` de `0x406F` es el **unico
salto indirecto del cartucho**: todo lo demas se decide estaticamente.

Hay una vuelta de tuerca mas. Antes de repartir, `0x40D4` **empuja un remate**
-`0x47AF` si el bit 6 de `(0xE002)` esta puesto y `0x4358` si no-, de modo que
la escena vuelve por ahi sin saberlo. La escena 3 es la excepcion: el `cp 003h`
de `0x40E1` se salta el empujon.

### Las ocho escenas

| `(0xE000)` | en | que es |
|---|---|---|
| 0 | `0x40F9` | la presentacion, con el cartel bajando |
| 1 | `0x4131` | el titulo y el PLAY SELECT |
| 2 | `0x413E` | el juego, y la demostracion |
| 3 | `0x416B` | la espera antes de jugar |
| 4 | `0x41C5` | el arranque de una ronda |
| 5 | `0x4240` | entre rondas |
| 6 | `0x425E` | los finales |
| 7 | `0x433A` | el game over |

### Los cuatro formatos de datos

Aqui no hay nada guardado en plano. Todo es un guion, y los cuatro lectores
estan traducidos en `tools/formatos.py`:

**Guion literal** — `guion_literal` (`0x48C8`). Una palabra de destino de VRAM y
detras las casillas, una a una; `0xFE` cierra el tramo y abre otro con su
destino, `0xFF` cierra el guion. La misma rutina tambien **borra**: el `and c`
de `0x48D6` con `C = 0` convierte en ceros todo lo que se escriba, y eso es
`borra_guion`.

**Guion RLE** — `guion_rle` (`0x48E1`). `0x01..0x7F` repite N veces el byte que
sigue, `0x81..0xFF` copia los N bytes que siguen, `0x80` cierra el tramo y abre
otro con otro destino, `0x00` cierra el guion. `vuelca_el_guion_con_destino_en_hl` es lo mismo con el
destino ya en HL.

Cuidado con el `0x80`. Leerlo como "no hace nada" da un guion que tambien parece
encajar -`0x49F5` salia de 53 bytes y llegaba limpiamente a `0x4A2A`,
saltandose de paso el guion de `0x4A06` que hay en medio- y ademas escupia texto
legible. Lo que lo delata es que la cadena entera de guiones consecutivos solo
cierra sin huecos ni solapes con la lectura buena.

**Figura** — hay dos, y no son la misma. Las dos leen alto y ancho delante y las
dos tratan `0xF0..0xFF` como una secuencia ascendente, pero la orden
`0xE0..0xEF` cambia **de las dos maneras a la vez**: `0x67F5` repite el byte que
viene detras y ocupa dos, y `0x67A7` escribe **ceros** y ocupa uno. El primero
dibuja las figuras de las oleadas y el segundo las de los rivales.

### Montar una pantalla

`monta_la_pantalla_de_combate` (`0x597F`) es el trozo de codigo mas claro del
cartucho. Primero lo que no cambia -el marco y los iconos- y luego las tres
bandas y el suelo, cada uno con su pareja de tablas entre las seis que van
seguidas de `0x592F` a `0x597E`.

El color sube **dos veces** y el patron **una**, y la razon es el espejo:
`espeja_el_decorado` (`0x5A4D`) copia tres tramos de la tabla de patrones sobre
si mismos pasandolos por `vuelve_los_bits`, asi que cada casilla de las bandas
tiene una gemela del reves. Las cuentas cuadran: `0x0560-0x0260 = 0x300` y las
otras dos `0x3C0`, que es exactamente la distancia de cada copia. La pantalla en
si no es simetrica: los guiones de nombres usan las gemelas solo donde quieren
(ver los [hallazgos](CURIOSIDADES.html)).

La tabla de nombres se llena aparte: la fila 3 por `pinta_la_fila_3_y_los_dos_nombres`, de la fila 5 para
abajo por `monta_el_decorado_o_la_oleada`, y las dos filas de abajo solo en los decorados 0 y 3.

### Las figuras en pantalla

`pinta_la_figura` (`0x66D8`) descomprime una figura en `0xE480` y la sube a la
tabla de nombres fila a fila, recortando lo que se salga por cada lado -el
`add a,c` de `0x670C` cuando la columna es negativa y el `sub 020h` de `0x671C`
cuando se pasa de la 32-.

Dos detalles faciles de leer al reves, y los dos medidos contra el emulador:

- la posicion llega en `(0xE170)` **fila** y `(0xE171)` **columna**, en ese
  orden, porque el `ld (nn),bc` deja C delante;
- el bucle de `0x66FD` baja **`fila - 1`** veces, asi que una figura pedida en
  la fila 4 empieza en la 3. La fila 0 es la excepcion: el `jr z` de `0x66F9`
  se salta el bucle.

### El sonido

`suena_el_cuadro` hace un cuadro de musica por interrupcion, y `pide_pieza`
elige la pieza. El mezclador del PSG pasa por `escribe_el_mezclador`, y
`suena_con_pantalla_apagada` (`0x40C3`) apaga el bit 6 de la copia del registro
del VDP que hay en `0x4964` para que suene un pitido con la pantalla apagada.

### Codigo que no llama nadie

Cinco rutinas -`0x47B0`, `0x4875`, `0x488A`, `0x544F` y `0x6EB5`- no las nombra
ni un `call`, ni un `jp`, ni ninguna tabla. Estan declaradas en
`src/yiear2.entries` con su justificacion escrita, para que el trazador las trate
como codigo y no acaben siendo un muro de bytes en mitad del listado.

## En el emulador

Todo lo de aqui esta medido con **openMSX** y una **Philips VG-8020**, que es la
maquina de esta serie.

    openmsx -machine Philips_VG_8020 -cart yiear2.rom

### El cartucho se juega solo

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

### Llegar a los ocho escenarios sin jugar

La demostracion pelea siempre en el primero. `0x5776` deja la ronda a cero y
escribe el escenario en `(0xE2C0)` tres instrucciones antes de montar la
pantalla, asi que un punto de interrupcion en `0x5784` -ya escrito el cero-
puede poner ahi el que se quiera, y el cartucho monta **ese** decorado, **ese**
suelo y **ese** rival con su propio codigo.

No se falsea nada: se cambia un byte del estado de la partida, como lo tendria
un jugador que llegase a esa ronda. Eso es lo que hace `tools/omsx_vram.tcl`, y
asi se comprobaron las ocho pantallas de combate de este sitio.

### La comprobacion que cierra la duda

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

### Lo que mas costo cuadrar

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

### Ver los extras

**El truco de las vidas.** Desde el encendido, antes de tocar nada: arriba una
vez, izquierda dos, abajo tres y derecha cuatro. `(0xE055)` se pone a `0x95`.

**La primera parte en la otra ranura.** Poner el Yie Ar Kung-Fu (RC-725) en la
segunda ranura, jugar una partida de un jugador y llegar al nivel 3. El extra
sale cuando las dos barras estan bajo minimos. Para verlo sin llegar hasta ahi:
`debug write memory 0xE450 1`, `0xE053 3`, `0xE100 8` y `0xE102 12`.

**La sopa.** Sale en la fase 3, con un jugador, PEGANDO en el sitio de la ronda
-la pareja que `0x5027` deja en `(0xE300)`-. Para verla sin buscar el sitio, un
punto de interrupcion en `0x7402` que escriba en `0xE300` la caja del golpe del
propio jugador, `(0xE12C)` menos dos.

### Para medir cualquier otra cosa

`tools/omsx_sonda.tcl` es el patron a copiar: un temporizador que lee un punado
de bytes de RAM por segundo emulado y los escribe. Los puntos de interrupcion de
ejecucion salen baratos; los de escritura tambien en juego normal, pero su
callback tiene que ser barato.

## Código compartido con otros cartuchos de Konami

Este desensamblado se ha comparado, instrucción por instrucción, con
todos los demás de Konami de la serie. Cuenta un bloque cuando las
mismas instrucciones, al menos seis desde una etiqueta hasta su `ret`
o su salto sin condición, están en los dos cartuchos; las direcciones
no se miran, porque cambian de un cartucho a otro. De los otros 57,
**54** tienen al menos un bloque en común con este; estos son los
que más comparten:

| Cartucho | Bloques | Instrucciones | Por ejemplo (aquí = allí) |
|---|---:|---:|---|
| [Yie Ar Kung-Fu](https://antxiko.github.io/YieArKungFu-disassembly/es/) | 35 | 370 | `lee_las_filas_7_y_8_del_teclado` (0x4997) = `lee_el_teclado` |
| [The Goonies](https://antxiko.github.io/Goonies-disassembly/es/) | 29 | 319 | `guion_rle` (0x48E1) |
| [Knightmare](https://antxiko.github.io/Knightmare-disassembly/es/) | 28 | 261 | `pinta_guion` (0x48C6) = `pinta_texto` |
| [Hyper Sports 3](https://antxiko.github.io/HyperSports3-disassembly/es/) | 25 | 284 | `lee_las_filas_7_y_8_del_teclado` (0x4997) = `teclado_del_jugador_1` |
| [Konami's Ping Pong](https://antxiko.github.io/KonamisPingPong-disassembly/es/) | 25 | 284 | `lee_las_filas_7_y_8_del_teclado` (0x4997) = `lee_teclado_1` |
| [Konami’s Soccer](https://antxiko.github.io/KonamisSoccer-disassembly/es/) | 25 | 276 | `cada_cuadro` (0x402E) = `latido` |
| [Nemesis / Gradius](https://antxiko.github.io/Nemesis-disassembly/es/) | 23 | 228 | `guion_rle` (0x48E1) = `descomprime_con_destino` |
| [Q\*bert](https://antxiko.github.io/Qbert-disassembly/es/) | 22 | 241 | `guion_rle` (0x48E1) |
| [Road Fighter](https://antxiko.github.io/RoadFighter-disassembly/es/) | 21 | 245 | `guion_rle` (0x48E1) = `descomprime_con_destino_dentro` |
| [Nemesis 2](https://antxiko.github.io/Nemesis2-disassembly/es/) | 19 | 199 | `guion_rle` (0x48E1) = `descomprime_otra_direccion` |

La matriz entera, los 58 cartuchos entre sí, está en
[Las rutinas](https://antxiko.github.io/MSX-disassembly-database/es/LAS-RUTINAS.html) de la base de datos de la
serie, con el método y el programa que la mide.
