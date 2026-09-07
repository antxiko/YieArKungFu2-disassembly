# El juego

![La pantalla del titulo](../imagenes/titulo.png)

*La pantalla del titulo, montada por `0x4CE9` y colocada por `0x4D10`. No es una
captura: esta dibujada desde la ROM, y cotejada contra la VRAM de openMSX a 768
de 768 casillas.*

LEE YOUNG se abre paso por **ocho escenarios**, un rival en cada uno, hasta el
emperador Yie-Gah. Entre combate y combate estan las **pantallas de oleadas**,
donde los enemigos llegan en fila.

## Los ocho rivales

Sus nombres son ocho guiones colgados de la tabla de punteros de `0x4487`,
indexada por el escenario de la ronda; el que se maneja esta en `0x447B`.

| ronda | rival | decorado |
|---|---|---|
| 1 | YEN-PEI | 0 |
| 2 | LAN-FANG | 0 |
| 3 | PO-CHIN | 1 |
| 4 | WEN-HU | 1 |
| 5 | WEI-CHIN | 2 |
| 6 | MEI-LING | 2 |
| 7 | HAN-CHEN | 3 |
| 8 | LI-JEN | 3 |

Los ocho escenarios comparten **cuatro decorados**, de dos en dos: `0x4FB4` hace
un `srl a` sobre el escenario y guarda el resultado en `(0xE2E0)`, que es lo que
indexa todas las tablas de bandas y de decorado. El **suelo** no sigue esa
regla -lo indexa el escenario entero, en `0x5A93`-, asi que dos rondas que
comparten decorado pisan suelos distintos.

![Escenario 1](../imagenes/escenario1.png)

*Ronda 1, contra YEN-PEI.*

![Escenario 7](../imagenes/escenario7.png)

*Ronda 7, contra HAN-CHEN: el nocturno.*

## Los rivales son casillas, no sprites

El muneco que se maneja esta hecho de sprites. El rival no: va escrito
directamente en la **tabla de nombres**, con `pinta_la_figura` (`0x66D8`)
descomprimiendo una figura en `0xE480` y subiendola fila a fila, recortando lo
que se salga por los lados.

Cada rival tiene un bloque de **22 punteros** en `0x6922`, indexado por
escenario. Once son dibujos y once remisiones de dos bytes: el **fotograma impar
es el par mirando al otro lado**, y el mismo bit que sigue el puntero
(`bit 0,a` de `0x677C`) niega la x en `0x686A`.

![YEN-PEI](../imagenes/rival1.png)

*Las once figuras de YEN-PEI, cada una con su alto, su ancho y sus casillas
comprimidas.*

![LI-JEN](../imagenes/rival8.png)

*LI-JEN, el emperador Yie-Gah.*

## LEE YOUNG

![Las diez poses](../imagenes/poses.png)

*Las diez poses, cada una montada con sus trios `[y][x][patron]` y los guiones
que suben sus patrones.*

Un fotograma son cuatro cajas de golpe mas hasta ocho trios, colgados de
los veinte punteros de `0x6C83`. Mirando a un lado, los ocho sprites usan los
**patrones 0 a 7**, que `0x6BE6` acaba de subir a `0x1800` siguiendo los guiones
del propio fotograma; mirando al otro, los trios traen numeros de patron que
caen en el banco **espejado** que dejo `espeja_sprites` (`0x490C`). Un dibujo,
dos direcciones.

## Las pantallas de oleadas

Una pantalla de oleadas son **cuatro bytes**. La tira de `0x5BE8` que le toca al
decorado trae ocho nibbles; cada uno elige una figura de las treinta de
`0x5C64`, y las ocho se pintan en fila de cuatro en cuatro columnas. Las pares
salen del nibble bajo y las impares del alto. Todo eso lo comprueban los tests:
las cuatro tiras son de doce bytes, ningun nibble pide una figura que su tabla
no tenga, y las treinta figuras encajan una detras de otra hasta `0x5F38`.

Aqui **no hay ningun dibujo de una**, y es a proposito: montadas sobre la VRAM
del combate, esas figuras piden casillas que ahi son la fuente, y salen letras.
De donde salen sus patrones no se sabe: esta en
[Preguntas abiertas](PREGUNTAS-ABIERTAS.html).

## El marcador y la barra de energia

La fila 3 es un guion entero (`0x6006`) con la barra de `KO` en medio, y debajo
los dos nombres. Las cifras se escriben en BCD por `0x4785`, que parte cada byte
en dos nibbles y le suma `0x10` para caer en los digitos de la fuente; el
`ld c,0xFF` de `0x4796` es lo que se come los ceros a la izquierda.

`0x572A` no es el rotulo de la pausa: dice **PERFECT 5000**, y solo se pinta
cuando la fase acaba con la barra llena -`0x5328` la compara contra `0x24`-.

## Dos jugadores

Con dos jugadores, el segundo mando **lleva al rival**. Los cinco bits de
`(0xE052)` entran directos en la tabla de 32 de `0x7DA2`, exactamente igual que
los del jugador en `0x6990`. Con un jugador se los inventa `0x7E7E`.

## El truco de las vidas

`0x43B8` guarda las **diez primeras pulsaciones** desde el encendido y las
compara contra `0x43ED`:

    01 04 04 02 02 02 08 08 08 08

Con el reparto de bits del PSG eso es **arriba una vez, izquierda dos, abajo
tres y derecha cuatro**. Si cuadra, `(0xE055)` pasa de 3 vidas a `0x95`.

## Y la demostracion es una partida grabada

Cuando nadie toca nada, el cartucho se juega solo. No hay inteligencia: son 33
pulsaciones grabadas en `0x57E4`, que acaban en el `0xFF` que busca `0x57DA`,
con sus duraciones en la tira de `0x5806`. Por eso dos encendidos dan la misma
demostracion, y por eso las imagenes de este sitio se pueden cotejar contra el
emulador.
