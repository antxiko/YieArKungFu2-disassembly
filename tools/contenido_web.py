#!/usr/bin/env python3
"""El contenido propio de Yie Ar Kung-Fu II: los hallazgos y los pies de la galeria.

Vive aparte de make_web.py a proposito: asi el generador no lleva dentro ni un
texto del cartucho anterior, que es de donde se copia el andamiaje.

Todo lo que se afirma aqui esta medido sobre el listado o sobre el volcado de
VRAM del emulador, y lleva su direccion al lado.
"""



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
    ("oleada1_1.png",
     "Primera oleada del decorado de los escenarios 1-2: ocho tiras verticales "
     "de paisaje de cuatro casillas, elegidas por los ocho nibbles de 0x5BF0. "
     "Sus casillas son las bandas del propio combate.",
     "First wave of the backdrop of sceneries 1-2: eight vertical slices of "
     "landscape four tiles wide, picked by the eight nibbles at 0x5BF0. Its "
     "tiles are the fight screen's own bands."),
    ("oleada1_2.png", "Segunda oleada, escenarios 1-2.",
     "Second wave, sceneries 1-2."),
    ("oleada1_3.png", "Tercera oleada, escenarios 1-2.",
     "Third wave, sceneries 1-2."),
    ("oleada2_1.png", "Primera oleada, escenarios 3-4.",
     "First wave, sceneries 3-4."),
    ("oleada2_2.png", "Segunda oleada, escenarios 3-4: el paisaje entero en "
     "orden, tiras 0 a 7.", "Second wave, sceneries 3-4: the whole landscape "
     "in order, slices 0 to 7."),
    ("oleada2_3.png", "Tercera oleada, escenarios 3-4.",
     "Third wave, sceneries 3-4."),
    ("oleada3_1.png", "Primera oleada, escenarios 5-6.",
     "First wave, sceneries 5-6."),
    ("oleada3_2.png", "Segunda oleada, escenarios 5-6.",
     "Second wave, sceneries 5-6."),
    ("oleada3_3.png", "Tercera oleada, escenarios 5-6.",
     "Third wave, sceneries 5-6."),
    ("oleada4_1.png", "Primera oleada, escenarios 7-8: el paisaje se corre "
     "ocho columnas a la derecha en cada pantalla.",
     "First wave, sceneries 7-8: the landscape slides eight columns right on "
     "each screen."),
    ("oleada4_2.png", "Segunda oleada, escenarios 7-8.",
     "Second wave, sceneries 7-8."),
    ("oleada4_3.png", "Tercera oleada, escenarios 7-8.",
     "Third wave, sceneries 7-8."),
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

NOMBRE = 'Yie Ar Kung-Fu II'

ANIO = 1985

REPOSITORIO = 'https://github.com/antxiko/YieArKungFu2-disassembly'
CODIGO = 13725
COMENTARIOS = 2923
DATOS = 19043
DENSIDAD = '40,9'
DENSIDAD_EN = '40.9'
ESTILO = '\n:root{--tinta:#cfd0d4;--suave:#83868f;--fondo:#000;--panel:#0c0e13;--linea:#23262e;\n  --rojo:#ff897d;--cyan:#65dbef;--verde:#3eb849;--oro:#ded087}\n@media (prefers-color-scheme:light){:root{--tinta:#191a1e;--suave:#5a5d66;--fondo:#e9e7e1;\n  --panel:#f7f6f2;--linea:#d0cdc5;--rojo:#b23f34;--cyan:#1c6b7c;--verde:#2b7734;--oro:#8a7420}}\n:root[data-theme="dark"]{--tinta:#cfd0d4;--suave:#83868f;--fondo:#000;--panel:#0c0e13;\n  --linea:#23262e;--rojo:#ff897d;--cyan:#65dbef;--verde:#3eb849;--oro:#ded087}\n:root[data-theme="light"]{--tinta:#191a1e;--suave:#5a5d66;--fondo:#e9e7e1;--panel:#f7f6f2;\n  --linea:#d0cdc5;--rojo:#b23f34;--cyan:#1c6b7c;--verde:#2b7734;--oro:#8a7420}\n*{box-sizing:border-box}\nbody{margin:0;background:var(--fondo);color:var(--tinta);padding:0 1.25rem 6rem;\n  font:15px/1.7 ui-monospace,"SF Mono",Menlo,Consolas,monospace}\n.w{max-width:1120px;margin:0 auto}\n.n{max-width:68ch}\nh1,h2,h3,h4{font-weight:400;text-wrap:balance}\na{color:var(--cyan)}\nimg{image-rendering:pixelated;max-width:100%;height:auto;display:block}\nheader.top{display:flex;flex-direction:column;align-items:center;gap:1.5rem;\n  padding:4rem 0 2rem;text-align:center}\nheader.top img{width:min(100%,642px)}\n.claim{max-width:60ch;color:var(--suave);font-size:1.05rem}\n.claim b{color:var(--tinta);font-weight:400}\n.ficha{display:flex;flex-wrap:wrap;justify-content:center;gap:0 1.5rem;width:100%;\n  font-size:12px;letter-spacing:.08em;text-transform:uppercase;color:var(--suave);\n  border-top:1px solid var(--linea);border-bottom:1px solid var(--linea);padding:.85rem 0}\n.ficha b{color:var(--rojo);font-weight:400}\nnav{display:flex;flex-wrap:wrap;gap:1.25rem;justify-content:center;padding:1.25rem 0;\n  font-size:12px;letter-spacing:.08em;text-transform:uppercase}\nnav a{color:var(--suave);text-decoration:none;border-bottom:1px solid transparent}\nnav a:hover,nav a:focus{color:var(--tinta);border-bottom-color:var(--rojo)}\nnav.docs{border-top:1px solid var(--linea);border-bottom:1px solid var(--linea);\n  margin-bottom:1rem}\nsection{margin-top:4.5rem;scroll-margin-top:1rem}\nsection>h2{font-size:1rem;letter-spacing:.1em;text-transform:uppercase;\n  border-left:3px solid var(--rojo);padding-left:.9rem;margin:0 0 1.5rem}\n.cifras{display:grid;gap:1px;background:var(--linea);border:1px solid var(--linea);\n  grid-template-columns:repeat(auto-fit,minmax(160px,1fr))}\n.cifra{background:var(--panel);padding:1.1rem}\n.cifra b{display:block;font-size:1.7rem;color:var(--oro);font-weight:400;\n  font-variant-numeric:tabular-nums;line-height:1.2}\n.cifra span{font-size:11px;letter-spacing:.07em;text-transform:uppercase;color:var(--suave)}\n.hall{border-top:1px solid var(--linea);padding-top:1.75rem;margin-top:2.5rem}\n.hall:first-of-type{border-top:0;padding-top:0;margin-top:0}\n.hall h3{margin:0 0 .75rem;font-size:1.15rem;color:var(--rojo)}\n.hall h4{color:var(--oro);margin:1.5rem 0 .5rem;font-size:.95rem}\n.hall p{margin:0 0 1rem}\npre.asm{background:var(--panel);border-left:2px solid var(--verde);margin:1.25rem 0;\n  padding:1rem 1.1rem;overflow-x:auto;font-size:13px;line-height:1.6;color:var(--tinta)}\n.par{display:grid;gap:1.25rem;grid-template-columns:1fr}\n@media(min-width:820px){.par{grid-template-columns:1fr 1fr}}\n.par figure{margin:0}\ntable{border-collapse:collapse;width:100%;margin:1.25rem 0;font-size:13px;display:block;\n  overflow-x:auto}\nth,td{text-align:left;padding:.5rem .75rem;border-bottom:1px solid var(--linea)}\nth{color:var(--suave);font-weight:400;font-size:11px;letter-spacing:.07em;text-transform:uppercase}\ntd.num{font-variant-numeric:tabular-nums;color:var(--oro)}\n.nivel{margin-top:2rem}\n.nivel h3{margin:0 0 .9rem;font-size:.95rem;letter-spacing:.06em;text-transform:uppercase}\n.nivel em{color:var(--cyan);font-style:normal}\n.sep{color:var(--suave);margin:0 .6rem}\n.rejilla{display:grid;gap:.9rem;grid-template-columns:repeat(auto-fill,minmax(250px,1fr))}\n.rejilla figure{margin:0;background:var(--panel);box-shadow:0 0 0 1px var(--linea)}\n.rejilla figcaption{display:flex;justify-content:space-between;padding:.45rem .65rem;\n  font-size:11px;color:var(--suave);border-top:1px solid var(--linea)}\n.dir{font-variant-numeric:tabular-nums;color:var(--verde)}\nfooter{margin-top:5rem;padding-top:1.5rem;border-top:1px solid var(--linea);\n  color:var(--suave);font-size:12px}\n\n/* Aviso de trabajo en curso: tiene que verse antes que las cifras, porque un\n   100% mal leido hace mas dano que no ponerlo. */\n.aviso{background:#3a2a10;border-left:3px solid var(--oro);margin:1.5rem auto;\n  padding:1rem 1.2rem;max-width:900px;border-radius:4px}\n.aviso p{margin:0;color:var(--tinta);font-size:15px;line-height:1.65}\n.galeria{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));\n  gap:1.5rem;margin:1.5rem 0}\n.galeria figure{margin:0}\n.galeria img{width:100%;height:auto;image-rendering:pixelated;\n  border:1px solid var(--linea);border-radius:3px}\n.galeria figcaption{color:var(--suave);font-size:13px;margin-top:.5rem}\naudio{display:block;width:100%;max-width:640px;margin:.75rem 0 1.5rem}\n'
INSTRUCCIONES = 7142
RUTINAS = 1027

EDITOR = 'Konami'

PORTADA = {
    'es': dict(
        titulo='Yie Ar Kung-Fu II - desensamblado comentado',
        claim='<b>El juego busca el Yie Ar Kung-Fu (RC-725) en la segunda ranura.</b> Antes de instalar el gancho de interrupcion rastrea las cuatro ranuras, conmuta la pagina 1 de cada una y le toma dos sumas de 16 bytes; si dan lo que espera, del nivel 3 en adelante aparece un <b>refresco</b> que rellena la barra cuando los dos luchadores estan bajo minimos. Y la <b>sopa</b> que deja invulnerable no sale sola: hay que <b>pegar</b> en un sitio distinto en cada ronda, los ocho de la tabla de <code>0x507A</code>.',
        ficha=['Konami - <b>(c) Konami 1985</b>', 'Cartucho <b>RC-737</b>, 32 KB', 'MSX1 - <b>paginas 1 y 2</b>', 'Volcado <b>bcb41b35...</b>'],
        h_num='El cartucho en cifras',
        cifras=[('100 %', 'del binario explicado'), ('1027', 'bloques de codigo medidos'), ('40,9 %', 'del listado comentado'), ('13.725', 'bytes de codigo'), ('19.043', 'bytes de datos'), ('0', 'bytes sin identificar')],
        pie_leg='Esto es trabajo de documentacion y preservacion: el codigo y los graficos siguen siendo de sus autores y de Konami, y la imagen del cartucho no se distribuye.',
        aviso='<b>Aqui no hay ninguna captura.</b> Todas las imagenes estan <b>dibujadas desde los bytes de la ROM</b>, ejecutando en Python los mismos guiones, espejos y lectores de figuras que corre el Z80, y <b>cotejadas byte a byte contra la VRAM de openMSX</b>: <b>nueve</b> pantallas volcadas del emulador dan <b>cero</b> diferencias en color (6.144 bytes), patrones (6.144) y patrones de sprite (1.792), y la del titulo cuadra ademas <b>768 de 768 casillas</b>. El listado y las cifras se reproducen con <code>make</code>, y el reensamblado devuelve la ROM <b>byte a byte</b>.',
    ),
    'en': dict(
        titulo='Yie Ar Kung-Fu II - a commented disassembly',
        claim='<b>The game checks Yie Ar Kung-Fu (RC-725) in the second slot.</b> Before it even installs the interrupt hook it scans the four slots, switches page 1 of each and takes two 16-byte sums; if they come out right, from level 3 on a <b>drink</b> shows up that refills your bar when both fighters are nearly out. And the <b>soup</b> that makes you invulnerable does not come out on its own: you have to <b>strike</b> at a different spot in every round, the eight in the table at <code>0x507A</code>.',
        ficha=['Konami - <b>(c) Konami 1985</b>', 'An <b>RC-737</b> 32 KB cartridge', 'MSX1 - <b>pages 1 and 2</b>', 'Dump <b>bcb41b35...</b>'],
        h_num='The cartridge in numbers',
        cifras=[('100%', 'of the binary explained'), ('1027', 'code blocks measured'), ('40.9%', 'of the listing commented'), ('13,725', 'bytes of code'), ('19,043', 'bytes of data'), ('0', 'bytes unidentified')],
        pie_leg='This is documentation and preservation work: the code and artwork still belong to their authors and to Konami, and the cartridge image is not distributed.',
        aviso="<b>Not one capture here.</b> Every picture is <b>drawn from the bytes of the ROM</b>, by running in Python the very same scripts, mirrors and figure readers the Z80 runs, and then <b>checked byte for byte against openMSX's VRAM</b>: <b>nine</b> screens dumped from the emulator come out with <b>zero</b> differences in colour (6,144 bytes), patterns (6,144) and sprite patterns (1,792), and the title screen matches <b>768 of 768 tiles</b> as well. The listing and the numbers are reproducible with <code>make</code>, and reassembling gives back the ROM <b>byte for byte</b>.",
    ),
}

# La portada: las cifras y el pie tal como estaban
for _i, _c in {'es': ([('100 %', 'del binario explicado'), ('1027', 'bloques de codigo medidos'), ('40,9 %', 'del listado comentado'), ('13.725', 'bytes de codigo'), ('19.043', 'bytes de datos'), ('0', 'bytes sin identificar')], 'El cartucho en cifras', 'Esto es trabajo de documentacion y preservacion: el codigo y los graficos siguen siendo de sus autores y de Konami, y la imagen del cartucho no se distribuye.'), 'en': ([('100%', 'of the binary explained'), ('1027', 'code blocks measured'), ('40.9%', 'of the listing commented'), ('13,725', 'bytes of code'), ('19,043', 'bytes of data'), ('0', 'bytes unidentified')], 'The cartridge in numbers', 'This is documentation and preservation work: the code and artwork still belong to their authors and to Konami, and the cartridge image is not distributed.')}.items():
    PORTADA[_i]["cifras"] = _c[0]
    PORTADA[_i]["h_num"] = _c[1]
    PORTADA[_i]["pie_leg"] = _c[2]
PORTADA['es']['aviso'] = '<b>Aqui no hay ninguna captura.</b> Todas las imagenes estan <b>dibujadas desde los bytes de la ROM</b>, ejecutando en Python los mismos guiones, espejos y lectores de figuras que corre el Z80, y <b>cotejadas byte a byte contra la VRAM de openMSX</b>: <b>nueve</b> pantallas volcadas del emulador dan <b>cero</b> diferencias en color (6.144 bytes), patrones (6.144) y patrones de sprite (1.792), y la del titulo cuadra ademas <b>768 de 768 casillas</b>. El listado y las cifras se reproducen con <code>make</code>, y el reensamblado devuelve la ROM <b>byte a byte</b>.'
PORTADA['en']['aviso'] = "<b>Not one capture here.</b> Every picture is <b>drawn from the bytes of the ROM</b>, by running in Python the very same scripts, mirrors and figure readers the Z80 runs, and then <b>checked byte for byte against openMSX's VRAM</b>: <b>nine</b> screens dumped from the emulator come out with <b>zero</b> differences in colour (6,144 bytes), patterns (6,144) and sprite patterns (1,792), and the title screen matches <b>768 of 768 tiles</b> as well. The listing and the numbers are reproducible with <code>make</code>, and reassembling gives back the ROM <b>byte for byte</b>."

PAGINAS = [
    [('THE-GAME.html', 'EL-JUEGO.html', 'The game', 'El juego',
      'what the game is and how it plays',
      'qu&eacute; es el juego y c&oacute;mo se juega'),
     ('THE-PICTURES.html', 'LAS-IMAGENES.html', 'What the cartridge draws', 'Lo que el cartucho dibuja',
      'every picture drawn from the ROM, with its caption',
      'todas las im&aacute;genes dibujadas desde la ROM, con su pie'),
     ('THE-MUSIC.html', 'LA-MUSICA.html', 'The music', 'La m&#250;sica',
      'the tunes, from its own sound engine',
      'las m&uacute;sicas, de su propio motor de sonido')],
    [('CURIOSITIES.html', 'CURIOSIDADES.html', 'Curiosities', 'Curiosidades',
      'what turned up when taking it apart, and what is still open',
      'lo que apareci&oacute; al desmontarlo y lo que queda abierto')],
    [('UNDER-THE-HOOD.html', 'POR-DENTRO.html', 'Under the hood', 'Por dentro',
      'getting started, the cartridge, the code and the emulator',
      'empezar, el cartucho, el c&oacute;digo y el emulador')],
]

VIEJAS = {
    'FINDINGS.html': 'CURIOSITIES.html',
    'HALLAZGOS.html': 'CURIOSIDADES.html',
    'GETTING-STARTED.html': 'UNDER-THE-HOOD.html',
    'EMPEZAR.html': 'POR-DENTRO.html',
    'IN-THE-EMULATOR.html': 'UNDER-THE-HOOD.html',
    'EN-EL-EMULADOR.html': 'POR-DENTRO.html',
    'OPEN-QUESTIONS.html': 'CURIOSITIES.html',
    'PREGUNTAS-ABIERTAS.html': 'CURIOSIDADES.html',
    'THE-CARTRIDGE.html': 'UNDER-THE-HOOD.html',
    'EL-CARTUCHO.html': 'POR-DENTRO.html',
    'THE-CODE.html': 'UNDER-THE-HOOD.html',
    'EL-CODIGO.html': 'POR-DENTRO.html',
}

LOGOTIPO = 'rotulo.png'

PIE_LEGAL = {'es': '<em>Yie Ar Kung-Fu II: The Emperor Yie-Gah</em> lo publico Konami para MSX en 1985; su numero de catalogo es RC-737 y son 32 KB. Es la segunda parte de <em>Yie Ar Kung-Fu</em> (RC-725, 1985). Todos los derechos sobre el juego siguen siendo de sus titulares. Este trabajo es de preservacion, estudio y documentacion, y la imagen del cartucho no se distribuye.', 'en': '<em>Yie Ar Kung-Fu II: The Emperor Yie-Gah</em> was published by Konami for the MSX in 1985; its catalogue number is RC-737 and it is 32 KB. It is the sequel to <em>Yie Ar Kung-Fu</em> (RC-725, 1985). All rights in the game remain with their holders. This is preservation, study and documentation work, and the cartridge image is not distributed.'}
