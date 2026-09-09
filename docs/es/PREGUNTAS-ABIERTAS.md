# Preguntas abiertas

El listado esta completo: 32.768 bytes, ninguno sin explicar. Eso no quiere
decir que se sepa todo del cartucho. Lo que no, esta aqui.

~~## ~~Que da de verdad la primera parte~~

**CERRADA** el 2026-09-09, a peticion de theNestruo. Es un **refresco** que
rellena la barra del jugador cuando las dos barras estan bajo minimos, y el
cartel de `0x7525` es su aviso. Medido en openMSX poniendo `(0xE450) = 1`: las
barras pasan de `(0x08, 0x0C)` a `(0x24, 0x0C)`. Esta en los
[hallazgos](HALLAZGOS.html).

## De donde sacan sus casillas las pantallas de oleadas

`monta_la_oleada` (`0x5B70`) esta leida y comprobada: cuatro tiras de doce
bytes, ocho nibbles que eligen una de las treinta figuras de `0x5C64`, y las
ocho pintadas de cuatro en cuatro columnas. Todo eso lo verifican los tests
sobre los bytes.

Lo que **no** sale es dibujar una. Montada encima de la VRAM que deja la
pantalla de combate, esas figuras piden casillas que ahi son la fuente, y el
resultado se lee como `1PLAYER` y `2PLAYERS`. O sea que algo carga patrones
antes de una pantalla de oleadas y no se ha encontrado: no lo hace nada del
arranque de ronda (`0x50BB`), y fuera del modo 3 ese camino se salta ademas el
suelo y el guion del pozo.

Dos intentos y parada. En este sitio no hay ningun dibujo de una pantalla de
oleadas, porque lo que no se entiende no se publica.

## Hay algun otro cartucho de Konami haciendo lo mismo?

El rastreo de `0xBF6C` es un juego buscando a **otro juego**, que no es el
mecanismo del Game Master. La pregunta obvia es si aparece en algun otro RC-7xx.
La pista a seguir es un `call` muy temprano desde INIT que toque `0xFCC1` y
ENASLT.

Todavia sin comprobar en el resto de la serie.

## Que decide cual de las dos compilaciones importa

El rastreo distingue las dos compilaciones del RC-725, `5A 47` la facil y
`23 70` la dificil, y guarda el mismo `1` en `(0xE450)` en los dos casos. O sea
que el cartucho se toma el trabajo de reconocer dos compilaciones por separado y
luego no las distingue. Si eso es un resto, una segunda tabla que nunca se uso,
o algo que se lee en otro sitio, no se sabe.

## Los dos escenarios que no se leen

`0x44E4` llena la tira de `0xE2C0` con diez escenarios, del 0 al 9, pero la
ronda vuelve a empezar a las ocho (`0x4311`). Las entradas 8 y 9 no se leen
nunca. Si es un resto de un juego mas largo o simplemente un numero redondo, no
se sabe.

## Los finales

La escena 6 (`0x425E`) lleva los finales y `0x58F9` sus rotulos, que se leen
como una felicitacion. Aqui no se ha llegado a ellos jugando, asi que como es la
secuencia de principio a fin esta descrito desde el codigo y no de haberlo
visto.
