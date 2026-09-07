# El codigo

    13.725 bytes de codigo   41,89 %
    19.043 bytes de datos    58,11 %
         0 sin explicar       0,00 %
     1.027 bloques de codigo medidos, ninguno por debajo del 10 % comentado
       430 de las 1.168 etiquetas llevan nombre; el resto son saltos internos
     7.142 instrucciones, 2.919 comentarios de linea — 40,9 %

## Todo cuelga de la interrupcion

INIT acaba en un `jr $` en `0x40C1`. De ahi en adelante no pasa nada en el flujo
principal: `0x409B` ha escrito un `jp cada_cuadro` en el gancho de `0xFD9A`, y
`cada_cuadro` (`0x402E`) es el juego entero.

Lee el estado del VDP para limpiar la peticion de interrupcion, hace un cuadro
de sonido y se protege con `(0xE005)` para que un cuadro que tarde de mas no se
reentre. Luego lee los mandos y llama a `haz_el_cuadro`.

## Una escena, una subescena y un solo salto indirecto

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

## Las ocho escenas

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

## Los cuatro formatos de datos

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

## Montar una pantalla

`monta_la_pantalla_de_combate` (`0x597F`) es el trozo de codigo mas claro del
cartucho. Primero lo que no cambia -el marco y los iconos- y luego las tres
bandas y el suelo, cada uno con su pareja de tablas entre las seis que van
seguidas de `0x592F` a `0x597E`.

El color sube **dos veces** y el patron **una**, y la razon es el espejo:
`espeja_el_decorado` (`0x5A4D`) copia tres tramos de la tabla de patrones sobre
si mismos pasandolos por `vuelve_los_bits`, y la mitad derecha del decorado son
los mismos dibujos del reves. Las cuentas cuadran: `0x0560-0x0260 = 0x300` y las
otras dos `0x3C0`, que es exactamente la distancia de cada copia.

La tabla de nombres se llena aparte: la fila 3 por `pinta_la_fila_3_y_los_dos_nombres`, de la fila 5 para
abajo por `monta_el_decorado_o_la_oleada`, y las dos filas de abajo solo en los decorados 0 y 3.

## Las figuras en pantalla

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

## El sonido

`suena_el_cuadro` hace un cuadro de musica por interrupcion, y `pide_pieza`
elige la pieza. El mezclador del PSG pasa por `escribe_el_mezclador`, y
`suena_con_pantalla_apagada` (`0x40C3`) apaga el bit 6 de la copia del registro
del VDP que hay en `0x4964` para que suene un pitido con la pantalla apagada.

## Codigo que no llama nadie

Cinco rutinas -`0x47B0`, `0x4875`, `0x488A`, `0x544F` y `0x6EB5`- no las nombra
ni un `call`, ni un `jp`, ni ninguna tabla. Estan declaradas en
`src/yiear2.entries` con su justificacion escrita, para que el trazador las trate
como codigo y no acaben siendo un muro de bytes en mitad del listado.
