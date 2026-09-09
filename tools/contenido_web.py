#!/usr/bin/env python3
"""El contenido propio de Yie Ar Kung-Fu II: los hallazgos y los pies de la galeria.

Vive aparte de make_web.py a proposito: asi el generador no lleva dentro ni un
texto del cartucho anterior, que es de donde se copia el andamiaje.

Todo lo que se afirma aqui esta medido sobre el listado o sobre el volcado de
VRAM del emulador, y lleva su direccion al lado.
"""

HALLAZGOS = {
    "es": [
        ("La sopa: hay que PEGAR en un sitio distinto en cada ronda",
         "<p><i>Esto lo pregunto <b><a href=\"https://github.com/theNestruo\">theNestruo</a></b> en el <a href=\"https://github.com/antxiko/YieArKungFu2-disassembly/issues/1\">issue #1</a>, y de memoria dijo que hacia falta un movimiento concreto en un punto concreto. Es exactamente lo que resulto ser, hasta en la palabra movimiento. La tabla de <code>0x507A</code> estaba aqui desde el principio con una nota diciendo que no se sabia de que era.</i></p>"
         "<p>El cuenco humeante que deja invulnerable un rato no sale al azar. "
         "Al empezar la ronda, <code>0x5027</code> copia a <code>0xE300</code> "
         "la pareja que le toca de una tabla de <b>ocho</b>, en "
         "<code>0x507A</code>, dos bytes por ronda: <b>fila y columna</b>. En "
         "el listado esa tabla estaba, sin saber de que era.</p>"
         "<p>Despues, un cuadro de cada dos, <code>0x73FD</code> pregunta si "
         "el jugador esta ahi. Pero no mira donde esta el muneco: mira "
         "<code>0xE12C</code>, que es la <b>CUARTA</b> de las cuatro cajas que "
         "monta <code>0x684A</code> -la caja del <b>golpe</b>, la misma que "
         "<code>0x53B3</code> usa para saber si el jugador alcanza al rival-. "
         "Tiene que caer dentro de una ventana de <b>11x11</b> que empieza dos "
         "mas alla de la pareja.</p>"
         "<p>Y esa cuarta caja <b>no existe en todos los fotogramas</b>. De "
         "los diez dibujos de <code>0x6C83</code> solo la llevan el 1, el 3, "
         "el 5 y el 6, que son los <b>cuatro ataques</b>; en los otros seis el "
         "guion trae <code>0x80</code>, <code>0x684A</code> deja la caja a "
         "cero y el <code>and a</code> de <code>0x65C6</code> la tumba. O sea "
         "que no basta con ponerse en el sitio: <b>hay que pegar</b> ahi. Eso "
         "es el movimiento particular en el punto particular.</p>"
         "<p><b>Las ocho parejas</b> (fila, columna): "
         "<code>(0x7E,0x80) (0x8E,0xE0) (0x68,0xD8) (0x8E,0x03) (0x9E,0x90) "
         "(0x68,0x10) (0x68,0x80) (0x8E,0x80)</code>. Solo en la <b>fase 3</b> "
         "de la ronda -<code>0x733E</code> exige <code>(0xE107) = 3</code>- y "
         "con <b>un solo jugador</b> (<code>0x732F</code>).</p>"
         "<p><b>Lo que da:</b> <code>(0xE29E) = 0xA8</code>, que baja de uno "
         "en uno un cuadro de cada dos: <b>seis segundos y medio</b> a 50 Hz. "
         "Mientras no valga cero, el golpe del jugador no cuenta "
         "(<code>0x53F4</code>), el rival no lanza nada "
         "(<code>0x5588</code>), lo que ya volaba se queda agarrado en vez de "
         "tocar (<code>0x566F</code>), no se rompen las ranuras "
         "(<code>0x7734</code>), nada toca al jugador (<code>0x798C</code>) y "
         "el muneco <b>parpadea</b> (<code>0x6C1E</code>). Ademas suma 500 "
         "puntos. Y <b>una sola vez por ronda</b>: al agotarse, "
         "<code>0x7496</code> deja <code>(0xE261) = 1</code> y la escena 0 se "
         "planta.</p>"
         "<p>Comprobado en openMSX: en la demostracion "
         "<code>(0xE300) = (0x7E, 0x80)</code>, la primera pareja de la tabla. "
         "Moviendo el sitio encima del jugador el cuenco cae, y al tocarlo "
         "<code>0xE29E</code> se pone a 0xA8 y baja hasta cero.</p>"),

        ("El juego busca el Yie Ar Kung-Fu (RC-725) en la segunda ranura",
         "<p>Lo primero que hace <code>INIT</code>, antes incluso de instalar "
         "el gancho de interrupcion, es llamar a <code>0xBF6C</code>. Ahi hay "
         "un <b>rastreo de ranuras</b>: recorre las cuatro primarias de "
         "<code>0xFCC1</code>, entra en las subranuras cuando el bit 7 lo "
         "pide, conmuta la <b>pagina 1</b> de cada una con ENASLT y le toma "
         "<b>dos sumas de 16 bytes</b>, una desde <code>0x5300</code> y otra "
         "desde <code>0x6700</code>.</p>"
         "<p>Las compara contra las dos parejas escritas en "
         "<code>0xBFD9</code>: <code>5A 47</code> y <code>23 70</code>. Son "
         "las <b>dos compilaciones del Yie Ar Kung-Fu original</b> (RC-725), "
         "reconocidas por separado. Pasadas esas dos sumas por las demas ROM "
         "de la serie no cuadra ninguna, asi que la identificacion no es una "
         "suposicion.</p>"
         "<p>Si lo encuentra, <code>(0xE450) = 1</code>. El <b>unico</b> sitio "
         "del juego que mira esa marca es <code>0x74A3</code>, y ademas exige "
         "<b>nivel 3 o mas</b> (<code>0xE053</code>), <b>un solo jugador</b> "
         "(bit 5 de <code>0xE002</code>) y la fase 3.</p>"
         "<p><b>Que da, medido.</b> Sale cuando las <b>dos</b> barras estan "
         "bajo minimos -la del jugador por debajo de 9 y la del rival por "
         "debajo de 13, de 0x24 que es el tope-: un cartel de 4x3 casillas "
         "(<code>0x7525</code>, fila 6 columna 14) y un <b>refresco</b> que "
         "baja, el sprite de los cuatro bytes de <code>0x74F1</code>. "
         "Cogerlo salta a <code>0x738C</code> con B = 1, y al agotarse los "
         "0x10 cuadros de descanso <code>0x7356</code> deja la barra <b>del "
         "jugador</b> otra vez a 0x24. La del rival no se toca y nadie pierde "
         "una vida. En openMSX las barras pasan de "
         "<code>(0x08, 0x0C)</code> a <code>(0x24, 0x0C)</code>.</p>"
         "<p>Y <b>no tiene nada que ver con la sopa</b>: son dos piezas "
         "distintas, en dos atributos distintos -<code>0xE250</code> la sopa "
         "y <code>0xE254</code> el refresco-, y la marca del vecino no entra "
         "en el camino de la sopa por ningun sitio.</p>"),

        ("Media pantalla y un espejo",
         "<p><code>0x597F</code> monta la pantalla de combate con "
         "<b>cuarenta guiones</b> apuntados por cuarenta punteros repartidos "
         "en seis tablas contiguas, de <code>0x592F</code> a "
         "<code>0x597E</code>. Pero <b>solo se dibuja la mitad</b>: "
         "<code>0x5A4D</code> copia tres tramos de la tabla de patrones sobre "
         "si mismos pasandolos por <code>vuelve_los_bits</code>, y la mitad "
         "derecha del decorado son los mismos dibujos del reves.</p>"
         "<p>De ahi sale una rareza que se ve leyendo el codigo: <b>el color "
         "se escribe dos veces y el patron una sola</b>. El espejo no toca "
         "colores. Y las cuentas cuadran en las tres bandas: "
         "<code>0x0560-0x0260 = 0x300</code> y las otras dos "
         "<code>0x3C0</code>, que es exactamente el desplazamiento de cada "
         "copia.</p>"),

        ("Una pantalla de oleadas son cuatro bytes",
         "<p>Las pantallas donde llegan enemigos en fila no estan dibujadas. "
         "La tira de <code>0x5BE8</code> que le toca al decorado trae "
         "<b>ocho nibbles</b> en cuatro bytes; cada nibble elige una de las "
         "<b>treinta figuras</b> de <code>0x5C64</code>, y las ocho se pintan "
         "en fila, de cuatro en cuatro columnas. Las pares van en el nibble "
         "bajo y las impares en el alto, que es lo que dice el "
         "<code>bit 0,b</code> de <code>0x5B9F</code>.</p>"),

        ("Dos lectores de figuras que se parecen y no son iguales",
         "<p><code>0x67F5</code> y <code>0x67A7</code> leen el mismo formato "
         "de figura salvo en la orden <code>0xE0..0xEF</code>, y ahi cambian "
         "<b>de las dos maneras a la vez</b>: el primero repite el byte que "
         "viene detras y ocupa dos, y el segundo escribe <b>ceros</b> y ocupa "
         "uno. Confundirlos no revienta el listado: da una figura que casi "
         "encaja y se pasa por dos o tres bytes.</p>"
         "<p>Los dos estan en <code>tools/formatos.py</code>, y lo que lo "
         "prueba es que las <b>treinta figuras de las oleadas encajan solo con "
         "el primero</b> y las de los rivales solo con el segundo.</p>"),

        ("Los ocho rivales, y el fotograma impar que no es un dibujo",
         "<p>Cada escenario tiene su rival, y cuelgan de dos tablas de ocho "
         "que se indexan igual: <code>0x6922</code> los fotogramas y "
         "<code>0x7FDB</code> el comportamiento. Cada bloque son <b>22 "
         "punteros</b> que cierran a 44 bytes, y los <b>168 tramos</b> entre "
         "entradas consecutivas teselan sin un hueco ni un solape.</p>"
         "<p>El fotograma <b>impar es el par mirando al otro lado</b>: el "
         "<code>bit 0,a</code> de <code>0x677C</code> sigue un puntero de dos "
         "bytes en vez de leer el dibujo, y el mismo bit niega la x en "
         "<code>0x686A</code>. Los ocho rivales se llaman YEN-PEI, LAN-FANG, "
         "PO-CHIN, WEN-HU, WEI-CHIN, MEI-LING, HAN-CHEN y LI-JEN "
         "(<code>0x4497</code>); el que se maneja es LEE YOUNG "
         "(<code>0x447B</code>).</p>"),

        ("El truco de las vidas: arriba, izquierda, abajo, derecha",
         "<p><code>0x43B8</code> va guardando las <b>diez primeras "
         "pulsaciones</b> desde el encendido y las compara contra los diez "
         "bytes de <code>0x43ED</code>: <code>01 04 04 02 02 02 08 08 08 "
         "08</code>. Con el reparto de bits del PSG eso es <b>arriba una vez, "
         "izquierda dos, abajo tres y derecha cuatro</b>, un 1-2-3-4. Si "
         "cuadra, <code>(0xE055)</code> pasa de 3 vidas a <b>0x95</b>.</p>"),

        ("El muneco no es un sprite: son doce, y la mitad se calcula",
         "<p>Un fotograma de LEE YOUNG son cuatro sprites de cabecera mas "
         "hasta ocho trios <code>[y][x][patron]</code>, colgados de los veinte "
         "punteros de <code>0x6C83</code> -diez dibujos en las entradas pares "
         "y diez remisiones de dos bytes en las impares-.</p>"
         "<p>Y ahi esta el ahorro: mirando a un lado, los ocho sprites usan "
         "los <b>patrones 0 a 7</b>, que <code>0x6BE6</code> acaba de subir a "
         "<code>0x1800</code> siguiendo los guiones del propio fotograma; "
         "mirando al otro, los trios traen numeros de patron que caen en el "
         "banco <b>espejado</b> que dejo <code>espeja_sprites</code> "
         "(<code>0x490C</code>). Un dibujo, dos direcciones, y solo una mitad "
         "guardada.</p>"),

        ("La marca oculta de Konami, y la segunda cabecera",
         "<p>Los ultimos quince bytes del cartucho, cerrando en "
         "<code>0xBFFF</code>, llevan <code>RC-737</code> y el titulo en "
         "<b>katakana escrito del reves</b>. Es la marca que <b>Manuel "
         "Pazos</b> descubrio en los cartuchos de Konami, y este la lleva.</p>"
         "<p>Y hay una <b>segunda cabecera</b> en <code>0x4010</code>, con su "
         "<code>AB</code> y los bytes <code>07 37</code>: la que lee el Konami "
         "Game Master desde la otra ranura.</p>"),

        ("Codigo que no llama nadie",
         "<p>Cinco rutinas -<code>0x47B0</code>, <code>0x4875</code>, "
         "<code>0x488A</code>, <code>0x544F</code> y <code>0x6EB5</code>- no "
         "las nombra ni un <code>call</code>, ni un <code>jp</code>, ni "
         "ninguna tabla. Estan declaradas como puntos de entrada para que "
         "salgan como codigo y no como datos, y su justificacion esta escrita "
         "en <code>src/yiear2.entries</code>.</p>"),

        ("Una fila menos de la que se pide",
         "<p><code>pon_la_figura_en_la_pantalla</code> (<code>0x66F1</code>) "
         "baja 32 casillas <b><code>fila - 1</code> veces</b>, por el "
         "<code>dec a</code> de <code>0x66FB</code>. Una figura pedida en la "
         "fila 4 empieza en la 3, y la fila 0 es la excepcion porque el "
         "<code>jr z</code> de <code>0x66F9</code> se salta el bucle entero. "
         "Sin eso, el logotipo del titulo sale cuatro filas mas abajo y tres "
         "columnas a la izquierda de donde va.</p>"),
    ],
    "en": [
        ("The soup: you must STRIKE a different spot in every round",
         "<p><i>Asked by <b><a href=\"https://github.com/theNestruo\">theNestruo</a></b> in <a href=\"https://github.com/antxiko/YieArKungFu2-disassembly/issues/1\">issue #1</a>, where he said from memory that it took a particular movement at a particular point. That is exactly what it turned out to be, down to the word movement. The table at <code>0x507A</code> was here all along with a note saying nobody knew what it was for.</i></p>"
         "<p>The steaming bowl that makes you invulnerable for a while does "
         "not come out at random. At the start of a round <code>0x5027</code> "
         "copies into <code>0xE300</code> the pair that belongs to it from a "
         "table of <b>eight</b> at <code>0x507A</code>, two bytes per round: "
         "<b>row and column</b>. That table was already in the listing, with "
         "nobody knowing what it was for.</p>"
         "<p>Then, one frame in two, <code>0x73FD</code> asks whether the "
         "player is there. But it does not look at where the figure is: it "
         "looks at <code>0xE12C</code>, the <b>FOURTH</b> of the four boxes "
         "built by <code>0x684A</code> -the <b>strike</b> box, the very one "
         "<code>0x53B3</code> uses to decide whether the player reaches the "
         "rival-. It has to fall inside an <b>11x11</b> window starting two "
         "beyond that pair.</p>"
         "<p>And that fourth box <b>does not exist in every frame</b>. Of the "
         "ten drawings at <code>0x6C83</code> only 1, 3, 5 and 6 carry it, and "
         "those are the <b>four attacks</b>; in the other six the script has "
         "<code>0x80</code>, <code>0x684A</code> leaves the box at zero and "
         "the <code>and a</code> at <code>0x65C6</code> knocks it out. So "
         "standing on the spot is not enough: <b>you have to strike</b> "
         "there. That is the particular movement at the particular point.</p>"
         "<p><b>The eight pairs</b> (row, column): "
         "<code>(0x7E,0x80) (0x8E,0xE0) (0x68,0xD8) (0x8E,0x03) (0x9E,0x90) "
         "(0x68,0x10) (0x68,0x80) (0x8E,0x80)</code>. Only in <b>phase 3</b> "
         "of the round -<code>0x733E</code> demands <code>(0xE107) = 3</code>- "
         "and with a <b>single player</b> (<code>0x732F</code>).</p>"
         "<p><b>What it gives:</b> <code>(0xE29E) = 0xA8</code>, counting down "
         "by one every other frame: <b>six and a half seconds</b> at 50 Hz. "
         "While it is not zero the player's blow does not count "
         "(<code>0x53F4</code>), the rival throws nothing "
         "(<code>0x5588</code>), whatever was already flying gets caught "
         "instead of hitting (<code>0x566F</code>), the slots cannot be broken "
         "(<code>0x7734</code>), nothing touches the player "
         "(<code>0x798C</code>) and the figure <b>blinks</b> "
         "(<code>0x6C1E</code>). It also adds 500 points. And <b>once per "
         "round only</b>: when it runs out <code>0x7496</code> sets "
         "<code>(0xE261) = 1</code> and scene 0 stops asking.</p>"
         "<p>Checked in openMSX: during the demo "
         "<code>(0xE300) = (0x7E, 0x80)</code>, the first pair of the table. "
         "Moving the spot onto the player makes the bowl drop, and touching it "
         "sets <code>0xE29E</code> to 0xA8, counting down to zero.</p>"),

        ("The game checks Yie Ar Kung-Fu (RC-725) in the second slot",
         "<p>The very first thing <code>INIT</code> does, before it even "
         "installs the interrupt hook, is call <code>0xBF6C</code>. There sits "
         "a <b>slot scan</b>: it walks the four primary slots from "
         "<code>0xFCC1</code>, descends into subslots when bit 7 asks for it, "
         "switches <b>page 1</b> of each with ENASLT and takes <b>two 16-byte "
         "sums</b>, one from <code>0x5300</code> and one from "
         "<code>0x6700</code>.</p>"
         "<p>It compares them against the two pairs written at "
         "<code>0xBFD9</code>: <code>5A 47</code> and <code>23 70</code>. "
         "Those are the <b>two builds of the original Yie Ar Kung-Fu</b> "
         "(RC-725), recognised separately. Running those two sums over the "
         "other ROMs in the series matches none of them, so the "
         "identification is not a guess.</p>"
         "<p>If it finds it, <code>(0xE450) = 1</code>. The <b>only</b> place "
         "in the game that reads that flag is <code>0x74A3</code>, and it also "
         "demands <b>level 3 or later</b> (<code>0xE053</code>), a "
         "<b>single player</b> (bit 5 of <code>0xE002</code>) and phase 3.</p>"
         "<p><b>What it gives, measured.</b> It shows up when <b>both</b> "
         "energy bars are nearly empty -the player's below 9 and the "
         "rival's below 13, out of 0x24 full-: a 4x3 tile sign "
         "(<code>0x7525</code>, row 6 column 14) and a <b>drink</b> that "
         "comes down, the sprite from the four bytes at <code>0x74F1</code>. "
         "Taking it jumps to <code>0x738C</code> with B = 1, and when the "
         "0x10 rest frames run out <code>0x7356</code> puts the "
         "<b>player's</b> bar back to 0x24. The rival's is left alone and "
         "nobody loses a life. In openMSX the bars go from "
         "<code>(0x08, 0x0C)</code> to <code>(0x24, 0x0C)</code>.</p>"
         "<p>And it has <b>nothing to do with the soup</b>: they are two "
         "separate items in two separate attributes -<code>0xE250</code> for "
         "the soup, <code>0xE254</code> for the drink- and the neighbour flag "
         "does not appear anywhere along the soup's path.</p>"),

        ("Half a screen and a mirror",
         "<p><code>0x597F</code> builds the fight screen from <b>forty "
         "scripts</b> pointed at by forty pointers spread over six contiguous "
         "tables, <code>0x592F</code> to <code>0x597E</code>. But <b>only half "
         "of it is drawn</b>: <code>0x5A4D</code> copies three stretches of "
         "the pattern table onto themselves through "
         "<code>vuelve_los_bits</code>, and the right half of the scenery is "
         "the same drawings reversed.</p>"
         "<p>That explains an oddity you can read straight off the code: "
         "<b>colour is written twice and the pattern once</b>. The mirror "
         "never touches colour. And the arithmetic checks out on all three "
         "bands: <code>0x0560-0x0260 = 0x300</code> and the other two "
         "<code>0x3C0</code>, exactly the offset of each copy.</p>"),

        ("A wave screen is four bytes",
         "<p>The screens where enemies arrive in a row are not drawn "
         "anywhere. The strip at <code>0x5BE8</code> for that scenery carries "
         "<b>eight nibbles</b> in four bytes; each nibble picks one of the "
         "<b>thirty figures</b> at <code>0x5C64</code>, and the eight are "
         "painted in a row, four columns apart. Even ones come from the low "
         "nibble and odd ones from the high nibble, which is what the "
         "<code>bit 0,b</code> at <code>0x5B9F</code> says.</p>"),

        ("Two figure readers that look alike and are not",
         "<p><code>0x67F5</code> and <code>0x67A7</code> read the same figure "
         "format except for the <code>0xE0..0xEF</code> order, and there they "
         "differ <b>in both ways at once</b>: the first repeats the byte that "
         "follows and takes two bytes, the second writes <b>zeros</b> and "
         "takes one. Mixing them up does not blow up the listing: it gives a "
         "figure that almost fits and overruns by two or three bytes.</p>"
         "<p>Both live in <code>tools/formatos.py</code>, and what proves it "
         "is that the <b>thirty wave figures only fit the first</b> and the "
         "rivals' only the second.</p>"),

        ("The eight rivals, and the odd frame that is not a drawing",
         "<p>Every scenery has its rival, and they hang off two tables of "
         "eight indexed the same way: <code>0x6922</code> for the frames and "
         "<code>0x7FDB</code> for the behaviour. Each block is <b>22 "
         "pointers</b> closing at 44 bytes, and the <b>168 stretches</b> "
         "between consecutive entries tile with no gap and no overlap.</p>"
         "<p>The <b>odd frame is the even one facing the other way</b>: the "
         "<code>bit 0,a</code> at <code>0x677C</code> follows a two-byte "
         "pointer instead of reading the drawing, and the same bit negates x "
         "at <code>0x686A</code>. The eight rivals are YEN-PEI, LAN-FANG, PO "
         "CHIN, WEN-HU, WEI-CHIN, MEI-LING, HAN-CHEN and LI-JEN "
         "(<code>0x4497</code>); the one you play is LEE YOUNG "
         "(<code>0x447B</code>).</p>"),

        ("The lives trick: up, left, down, right",
         "<p><code>0x43B8</code> keeps the <b>first ten key presses</b> since "
         "power-on and compares them against the ten bytes at "
         "<code>0x43ED</code>: <code>01 04 04 02 02 02 08 08 08 08</code>. "
         "With the PSG bit layout that reads <b>up once, left twice, down "
         "three times and right four</b>, a 1-2-3-4. If it matches, "
         "<code>(0xE055)</code> goes from 3 lives to <b>0x95</b>.</p>"),

        ("The fighter is not one sprite: it is twelve, and half is computed",
         "<p>One LEE YOUNG frame is four header sprites plus up to eight "
         "<code>[y][x][pattern]</code> triples, hanging off the twenty "
         "pointers at <code>0x6C83</code> -ten drawings in the even entries "
         "and ten two-byte redirections in the odd ones-.</p>"
         "<p>And there is the saving: facing one way, the eight sprites use "
         "<b>patterns 0 to 7</b>, which <code>0x6BE6</code> has just uploaded "
         "to <code>0x1800</code> following the frame's own scripts; facing the "
         "other, the triples carry pattern numbers that land in the "
         "<b>mirrored</b> bank left by <code>espeja_sprites</code> "
         "(<code>0x490C</code>). One drawing, two directions, only one half "
         "stored.</p>"),

        ("Konami's hidden mark, and the second header",
         "<p>The last fifteen bytes of the cartridge, closing at "
         "<code>0xBFFF</code>, carry <code>RC-737</code> and the title in "
         "<b>katakana written backwards</b>. It is the mark <b>Manuel "
         "Pazos</b> found in Konami's cartridges, and this one has it.</p>"
         "<p>There is also a <b>second header</b> at <code>0x4010</code>, with "
         "its own <code>AB</code> and the bytes <code>07 37</code>: the one "
         "the Konami Game Master reads from the other slot.</p>"),

        ("Code nobody calls",
         "<p>Five routines -<code>0x47B0</code>, <code>0x4875</code>, "
         "<code>0x488A</code>, <code>0x544F</code> and <code>0x6EB5</code>- "
         "are named by no <code>call</code>, no <code>jp</code> and no table. "
         "They are declared as entry points so they come out as code rather "
         "than data, and the reason for each is written down in "
         "<code>src/yiear2.entries</code>.</p>"),

        ("One row higher than asked for",
         "<p><code>pon_la_figura_en_la_pantalla</code> (<code>0x66F1</code>) "
         "steps down 32 tiles <b><code>row - 1</code> times</b>, because of "
         "the <code>dec a</code> at <code>0x66FB</code>. A figure asked for at "
         "row 4 starts at row 3, and row 0 is the exception because the "
         "<code>jr z</code> at <code>0x66F9</code> skips the loop entirely. "
         "Without that, the title logo lands four rows too low and three "
         "columns too far left.</p>"),
    ],
}


# Las imagenes de la galeria: fichero, pie en castellano, pie en ingles.
# Todas las dibuja tools/graficos.py o tools/figuras.py desde la ROM.
GALERIA = [
    ("titulo.png",
     "La pantalla del titulo, montada por 0x4CE9 y colocada por 0x4D10. "
     "Cotejada contra la VRAM de openMSX: <b>768 de 768 casillas iguales</b>.",
     "The title screen, built by 0x4CE9 and placed by 0x4D10. Checked against "
     "openMSX's VRAM: <b>768 of 768 tiles identical</b>."),
    ("poses.png",
     "Las diez poses de LEE YOUNG, cada una montada con sus cuatro sprites de "
     "cabecera, sus trios y los guiones que suben sus patrones.",
     "LEE YOUNG's ten poses, each assembled from its four header sprites, its "
     "triples and the scripts that upload its patterns."),
    ("golpes.png",
     "Las mismas diez poses, con una cruz en la CUARTA caja del guion: el "
     "punto por el que ese golpe toca. Solo la tienen cuatro -los cuatro "
     "ataques-, y es el punto que 0x7402 compara con el sitio de la sopa. La "
     "cruz la ponemos nosotros; el punto sale del guion.",
     "The same ten poses, with a cross on the FOURTH box of the script: the "
     "point where that blow lands. Only four carry it -the four attacks- and "
     "it is the point 0x7402 compares against the soup's spot. The cross is "
     "ours; the point comes from the script."),
    ("piezas.png",
     "Las dos piezas que caen, dibujadas desde la ROM: el <b>cuenco de "
     "sopa</b> (patron 0xDC, el de la invulnerabilidad) y el <b>refresco</b> "
     "(patron 0xE0, el del cartucho hermano). Los sube el guion suelto de "
     "0xA7D1, no los dieciseis del muneco.",
     "The two items that drop, drawn from the ROM: the <b>soup bowl</b> "
     "(pattern 0xDC, the invulnerability one) and the <b>drink</b> (pattern "
     "0xE0, the sibling-cartridge one). They come from the loose script at "
     "0xA7D1, not from the sixteen player ones."),
    ("cartel.png",
     "El cartel del premio del cartucho hermano: la figura de 4x3 casillas de "
     "0x7525, que 0x751B pone en la fila 6, columna 14.",
     "The sign for the sibling-cartridge reward: the 4x3 tile figure at "
     "0x7525, which 0x751B places at row 6, column 14."),
    ("escenario1.png",
     "Escenario 1, contra YEN-PEI. El decorado, el suelo y el rival salen de "
     "tablas distintas indexadas por la ronda.",
     "Scenery 1, against YEN-PEI. Scenery, floor and rival come from different "
     "tables indexed by the round."),
    ("escenario2.png", "Escenario 2, contra LAN-FANG: mismo decorado que el 1, "
     "otro suelo.", "Scenery 2, against LAN-FANG: same backdrop as 1, a "
     "different floor."),
    ("escenario3.png", "Escenario 3, contra PO-CHIN.",
     "Scenery 3, against PO-CHIN."),
    ("escenario4.png",
     "Escenario 4, contra WEN-HU. Es el unico que lleva marcador de fase: el "
     "<code>cp 003h</code> de 0x5A7A.",
     "Scenery 4, against WEN-HU. The only one with a phase marker: the "
     "<code>cp 003h</code> at 0x5A7A."),
    ("escenario5.png", "Escenario 5, contra WEI-CHIN.",
     "Scenery 5, against WEI-CHIN."),
    ("escenario6.png", "Escenario 6, contra MEI-LING.",
     "Scenery 6, against MEI-LING."),
    ("escenario7.png", "Escenario 7, contra HAN-CHEN: el nocturno, con los "
     "faroles.", "Scenery 7, against HAN-CHEN: the night one, with lanterns."),
    ("escenario8.png", "Escenario 8, contra LI-JEN, el emperador Yie-Gah.",
     "Scenery 8, against LI-JEN, the emperor Yie-Gah."),
    ("rival1.png", "YEN-PEI, sus once figuras. Los rivales no son sprites: son "
     "CASILLAS, y cada figura trae su alto, su ancho y sus casillas "
     "comprimidas.",
     "YEN-PEI, all eleven figures. The rivals are not sprites: they are "
     "TILES, and each figure carries its height, width and compressed tiles."),
    ("rival2.png", "LAN-FANG.", "LAN-FANG."),
    ("rival3.png", "PO-CHIN.", "PO-CHIN."),
    ("rival4.png", "WEN-HU.", "WEN-HU."),
    ("rival5.png", "WEI-CHIN.", "WEI-CHIN."),
    ("rival6.png", "MEI-LING.", "MEI-LING."),
    ("rival7.png", "HAN-CHEN.", "HAN-CHEN."),
    ("rival8.png", "LI-JEN, el emperador Yie-Gah.",
     "LI-JEN, the emperor Yie-Gah."),
    ("fuente.png",
     "La fuente de la casa, subida por 0x4A8D a los tres tercios: el espacio "
     "en 0x00, las cifras desde 0x10 y las letras desde 0x21.",
     "The in-house font, uploaded by 0x4A8D to all three thirds: space at "
     "0x00, digits from 0x10 and letters from 0x21."),
    ("casillas.png",
     "Las 256 casillas del primer escenario en sus tres bancos, tal y como "
     "quedan en la VRAM despues del espejo.",
     "The 256 tiles of the first scenery in all three banks, exactly as they "
     "sit in VRAM after the mirror."),
]
