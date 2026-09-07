#!/usr/bin/env python3
"""La VRAM de Yie Ar Kung-Fu II, montada ejecutando en Python los pasos del cartucho.

En este repositorio no hay ni una captura de pantalla. Todo lo que se ve sale
de aqui: cada metodo de esta clase es la traduccion de una rutina del propio
cartucho, con su direccion delante, y lo que se pinta luego es lo que esas
rutinas dejan en los 16 KB de VRAM.

EL REPARTO DE LA VRAM lo fijan los ocho registros de 0x4963 (`02 E2 0E 7F 07
76 03 E4`), que `pon_los_registros_del_vdp` (0x4952) vuelca del 0 al 7:

    R0=02 R1=E2   SCREEN 2, sprites de 16x16
    R2=0E         tabla de NOMBRES en 0x3800
    R3=7F R4=07   COLOR en 0x0000 y PATRONES en 0x2000 -no son direcciones,
                  son base y mascara, y por eso el color cae en 0x0000-
    R5=76         atributos de sprite en 0x3B00
    R6=03         patrones de sprite en 0x1800
    R7=E4         borde azul oscuro

OJO al orden: en este cartucho los bancos van AL REVES de lo habitual -los
patrones en 0x2000 y el color en 0x0000-, asi que un mismo dibujo son dos
guiones con el mismo desplazamiento y 0x2000 de diferencia. Se ve en
`monta_la_pantalla_de_combate`, que carga 0x01F0 y 0x21F0 con la misma forma.

Uso: vram.py <rom>            (imprime lo que monta cada escena)
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import formatos as F                                          # noqa: E402

ORG = 0x4000

COLORES = 0x0000
SPRITES = 0x1800                      # patrones de sprite, por el registro 6
PATRONES = 0x2000
NOMBRES = 0x3800
ATRIBUTOS = 0x3B00                    # la SAT, por el registro 5

# Los ocho escenarios comparten decorado de dos en dos: 0x4FB4 hace `srl a`
# sobre el escenario y guarda el resultado en (0xE2E0), que es lo que indexa
# todas las tablas de bandas y de decorado.
DECORADOS = 4
ESCENARIOS = 8


class Vram:
    """Los 16 KB de VRAM y las rutinas del cartucho que los llenan."""

    def __init__(self, rom, org=ORG):
        self.rom, self.org = rom, org
        self.v = bytearray(0x4000)

    # ------------------------------------------------------------------
    # Leer la ROM
    # ------------------------------------------------------------------
    def b(self, d):
        return self.rom[d - self.org]

    def w(self, d):
        return self.b(d) | (self.b(d + 1) << 8)

    def tabla(self, t, i):
        """L_4830: `add a,a` + `suma_a_a_hl` + leer la palabra. Una entrada."""
        return self.w(t + 2 * i)

    # ------------------------------------------------------------------
    # Los volcados a la VRAM
    # ------------------------------------------------------------------
    def rle(self, p, dest=None):
        """guion_rle (0x48E1) si dest es None, y L_48E7 si el destino ya viene.

        Devuelve los bytes de ROM que ha consumido el guion.
        """
        tramos, n = F.guion_rle(self.rom, p, dest is None, self.org)
        for vram, datos in tramos:
            d = vram if vram is not None else dest
            self.v[d:d + len(datos)] = datos
            dest = d + len(datos)
        return n

    def rle_en_tercios(self, p, dest, veces):
        """L_48AE (dos tercios) y L_48B2 (los tres): el mismo guion, +0x800."""
        for _ in range(veces):
            self.rle(p, dest)
            dest += 0x800

    def literal(self, p, dest=None, c=0xFF):
        """pinta_guion (0x48C6), byte_del_guion (0x48CE) y borra_guion (0x48DD).

        Con dest puesto es L_48C2, que pinta SIN leer la palabra de destino.
        Con c=0 es `borra_guion`: el `and c` de 0x48D6 convierte en cero todo
        lo que se escriba.
        """
        p_ini = p
        if dest is None:
            dest = self.w(p)
            p += 2
        while True:
            x = self.b(p)
            p += 1
            if x == 0xFF:                        # cierra el guion
                return p - p_ini
            if x == 0xFE:                        # abre otro tramo
                dest = self.w(p)
                p += 2
                continue
            self.v[dest] = x & c
            dest += 1

    def rellena(self, dest, n, valor):
        """FILVRM (0x0056): n bytes iguales."""
        self.v[dest:dest + n] = bytes([valor]) * n

    def rellena_los_tres_bancos(self, dest, n, valor):
        """0x489D: lo mismo en los tres tercios, subiendo 0x800 cada vez."""
        for _ in range(3):
            self.rellena(dest, n, valor)
            dest += 0x800

    # ------------------------------------------------------------------
    # Los dos espejos
    # ------------------------------------------------------------------
    @staticmethod
    def vuelve_los_bits(x):
        """vuelve_los_bits (0x4934): los ocho bits al reves."""
        return int("{:08b}".format(x)[::-1], 2)

    def copia_dando_la_vuelta(self, orig, dest, n):
        """copia_dando_la_vuelta (0x5A80), el espejo del decorado.

        No se refleja la pantalla: se reflejan los PATRONES, y la mitad derecha
        del decorado son los mismos dibujos con los bits al reves. Por eso el
        color se escribe DOS veces y el patron una sola.
        """
        for i in range(n):
            self.v[dest + i] = self.vuelve_los_bits(self.v[orig + i])

    def espeja_sprites(self, orig, dest, cuantos):
        """espeja_sprites (0x490C): un patron de sprite reflejado es su gemelo.

        Un patron de 16x16 son 32 bytes: los 16 primeros la columna izquierda y
        los 16 ultimos la derecha. Reflejar es cambiarlas de sitio Y darle la
        vuelta a los bits, y eso es lo que hace el doble bucle de 0x4919: DE
        entra apuntando al destino MAS 0x10, escribe la primera mitad ahi,
        retrocede 0x20 (`sub 020h`) y escribe la segunda en el destino.
        """
        for _ in range(cuantos):
            for i in range(0x10):
                self.v[dest + 0x10 + i] = self.vuelve_los_bits(self.v[orig + i])
            for i in range(0x10):
                self.v[dest + i] = self.vuelve_los_bits(self.v[orig + 0x10 + i])
            orig += 0x20
            dest += 0x20

    # ------------------------------------------------------------------
    # Las figuras de casillas
    # ------------------------------------------------------------------
    def figura(self, p, fila, col):
        """pinta_figura_sin_sprites (0x675D) + pon_la_figura_en_la_pantalla.

        Descomprime la figura con el lector que REPITE el byte (0x67F5, no el
        que escribe ceros) y la sube a la tabla de nombres fila a fila,
        recortando lo que se salga por los lados: el `add a,c` de 0x670C
        cuando la columna es negativa y el `sub 020h` de 0x671C cuando se pasa
        de la 32.

        LA FILA VA UNA MENOS DE LO QUE DICE. El bucle de 0x66FD baja 32
        casillas `fila - 1` veces (el `dec a` de 0x66FB), asi que una figura
        pedida en la fila 4 empieza en la 3. La fila 0 es la excepcion: el
        `jr z` de 0x66F9 se salta el bucle entero y tambien aterriza en la 0.
        """
        fila = max(fila - 1, 0)
        alto, ancho, casillas, _ = F.figura(self.rom, p, self.org)
        for f in range(alto):
            tira = casillas[f * ancho:(f + 1) * ancho]
            c0, tira = col, tira
            if col < 0:
                if ancho + col <= 0:
                    return alto, ancho
                tira, c0 = tira[-(ancho + col):], 0
            elif col + ancho > 32:
                if col >= 32:
                    return alto, ancho
                tira = tira[:32 - col]
            d = NOMBRES + (fila + f) * 32 + c0
            self.v[d:d + len(tira)] = tira
        return alto, ancho

    # ------------------------------------------------------------------
    # LAS ESCENAS
    # ------------------------------------------------------------------
    def arranca_la_pantalla(self):
        """arranca_la_pantalla (0x493F): los 16 KB a cero antes de nada."""
        self.v = bytearray(0x4000)
        return self

    def limpia_la_pantalla(self):
        """limpia_la_pantalla (0x485C): aparca los sprites y borra los nombres."""
        self.v[ATRIBUTOS] = 0xD0                 # L_46BF: 0xD0 en la y del primero
        self.rellena(NOMBRES, 0x300, 0x00)
        return self

    def monta_la_fuente(self):
        """monta_la_fuente (0x4A8D): la fuente de la casa, en los tres tercios.

        Primero `limpia_la_fuente` (0x4AA4) pone a cero los 0x80 primeros bytes
        de patrones y da a las dieciseis primeras casillas un color distinto a
        cada una -de ahi el `inc a` de 0x4AC0-, y luego sube los patrones de
        0x4AC5 a 0x2080 y les pone color 0xF0.
        """
        self.rellena_los_tres_bancos(PATRONES, 0x80, 0x00)
        color = 0
        for i in range(0x10):                    # una casilla, un color
            self.rellena_los_tres_bancos(COLORES + i * 8, 8, color)
            color += 1
        self.rle_en_tercios(0x4AC5, PATRONES + 0x80, 3)
        self.rellena_los_tres_bancos(COLORES + 0x80, 0x160, 0xF0)
        return self

    def monta_el_cartel(self):
        """monta_el_cartel (0x4C0C): el cartel que baja en la presentacion.

        Sus patrones van a 0x2200 en los TRES tercios y su color es plano
        (0xF0, 0xD8 bytes desde 0x0200, tambien en los tres). Importa aunque la
        presentacion se acabe: nadie los borra, y siguen ahi bajo el titulo y
        bajo el combate.
        """
        self.rle_en_tercios(0x4C52, PATRONES + 0x200, 3)
        self.rellena_los_tres_bancos(COLORES + 0x200, 0xD8, 0xF0)
        return self

    def monta_el_titulo(self):
        """monta_el_titulo (0x4CE9): borde negro, pantalla limpia y logotipo.

        El logotipo son tres piezas: los patrones de 0x4D43 en 0x2400 -y
        L_48AE los repite en 0x2C00, o sea en los dos primeros tercios-, su
        color plano de 0x4F4E en 0x0400 y 0x0C00, y la figura de 7x18 de
        0x4F5F, que la coloca 0x4D10 en la fila 7, columna 4.

        OJO: esto NO borra la VRAM. `limpia_la_pantalla` solo vacia la tabla de
        NOMBRES; los patrones y el color que dejo la presentacion siguen ahi.
        """
        self.limpia_la_pantalla()
        self.monta_la_fuente()
        self.rle_en_tercios(0x4D43, PATRONES + 0x400, 2)
        self.rle_en_tercios(0x4F4E, COLORES + 0x400, 2)
        return self

    def pantalla_del_titulo(self, cursor=True, dos_jugadores=False):
        """L_4D06 (0x4D06) y L_4D1F: el titulo entero, con su cursor.

        Tras el logotipo van los dos rotulos de 0x4A3A -"PLAY SELECT" y las dos
        opciones- y, cada cuadro de la escena 1, el cursor: el mismo guion de
        0x4A6C pintado en 0x3A4A o en 0x3A8A segun (0xE047), y BORRADO en la
        otra (el `ld c,000h` de 0x4D3B, que hace que el `and c` de 0x48D6
        escriba ceros). El bit 3 de la espera lo hace parpadear.
        """
        self.monta_el_titulo()
        # `ld bc,00704h` + `ld (0e170h),bc` deja C en (0xE170) y B en
        # (0xE171): fila 4 y columna 7, no al reves.
        self.figura(0x4F5F, 4, 7)
        n = self.literal(0x4A3A)                 # los dos rotulos de debajo
        self.literal(0x4A3A + n)
        elegido, otro = 0x3A4A, 0x3A8A
        if dos_jugadores:
            elegido, otro = otro, elegido
        self.literal(0x4A6C, elegido, c=0xFF if cursor else 0x00)
        self.literal(0x4A6C, otro, c=0x00)       # el que no toca, borrado
        return self

    # ------------------------------------------------------------------
    def sprites_del_jugador(self):
        """L_5ABA (0x5ABA): los dieciseis guiones de sprite y su espejo.

        Las dos tablas van en paralelo: 0x5B02 los guiones y 0x5B22 los
        destinos, de 0x1A00 a 0x1EE0. Y al final, `espeja_sprites` refleja 48
        patrones de 0x1A00 sobre 0x1900: el muneco mirando al otro lado no se
        dibuja dos veces, se calcula.
        """
        for i in range(16):
            self.rle(self.tabla(0x5B02, i), self.tabla(0x5B22, i))
        self.espeja_sprites(0x1A00, 0x1900, 0x30)
        return self

    def decorado_de_fondo(self, escenario=None):
        """L_5AE1 (0xA7D1, el guion suelto) o L_5AE6 (uno de los ocho del pozo).

        Los dos acaban en `guion_rle`, o sea con el destino metido dentro del
        propio guion.
        """
        if escenario is None:
            self.rle(0xA7D1)
        else:
            self.rle(self.tabla(0x5AF2, escenario))
        return self

    def monta_la_pantalla_de_combate(self, escenario):
        """monta_la_pantalla_de_combate (0x597F) + espeja_el_decorado (0x5A4D).

        Primero lo que no cambia -el marco de 0x943B/0x93E4/0x94B0/0x9464 y los
        iconos de 0x51F2 y 0x51CC- y luego las tres bandas y el suelo, cada una
        con su pareja de tablas: patrones a un sitio y color a DOS, porque el
        espejo no toca colores. Las tres distancias cuadran con las tres
        copias: 0x0560-0x0260 = 0x300, y las otras dos 0x3C0.
        """
        self.rle(0x943B, COLORES + 0x1F0)        # el marco, color
        self.rle(0x943B, COLORES + 0x4F0)        # y otra vez medio tercio abajo
        self.rle(0x93E4, PATRONES + 0x1F0)       # el marco, patron
        self.rle(0x94B0, COLORES + 0x480)        # el segundo trozo del marco
        self.rle(0x9464, PATRONES + 0x480)
        self.rle(0x51F2, COLORES + 0x1400)       # los iconos, dos veces en color
        self.rle(0x51F2, COLORES + 0x17C0)
        self.rle(0x51CC, PATRONES + 0x1400)      # y una en patron

        decorado = escenario >> 1                # el `srl a` de 0x4FB4
        self.rle(self.tabla(0x5957, decorado), COLORES + 0x260)   # banda alta
        self.rle(self.tabla(0x5957, decorado), COLORES + 0x560)
        self.rle(self.tabla(0x594F, decorado), PATRONES + 0x260)
        self.rle(self.tabla(0x5967, decorado), COLORES + 0x880)   # banda media
        self.rle(self.tabla(0x5967, decorado), COLORES + 0xC40)
        self.rle(self.tabla(0x595F, decorado), PATRONES + 0x880)
        self.rle(self.tabla(0x5977, decorado), COLORES + 0x13C0)  # banda baja
        self.rle(self.tabla(0x5977, decorado), COLORES + 0x1780)
        self.rle(self.tabla(0x596F, decorado), PATRONES + 0x13C0)

        self.rle(0xB898, COLORES + 0x1080)       # el suelo de serie
        self.rle(0xB898, COLORES + 0x1440)
        self.rle(0xB819, PATRONES + 0x1080)
        self.espeja_el_decorado(escenario)
        return self

    def espeja_el_decorado(self, escenario=None, dos_jugadores=False):
        """espeja_el_decorado (0x5A4D): los tres tramos de patrones reflejados.

        Y una cola que se salta con dos jugadores: en el escenario 3 -y solo en
        ese, por el `cp 003h` de 0x5A7A- hay ademas marcador de fase.
        """
        self.copia_dando_la_vuelta(0x2200, 0x2500, 0x300)
        self.copia_dando_la_vuelta(0x2880, 0x2C40, 0x3C0)
        self.copia_dando_la_vuelta(0x3080, 0x3440, 0x3C0)
        if not dos_jugadores and escenario == 3:
            self.marcador_de_fase()
        return self

    def marcador_de_fase(self, largo=True):
        """L_7C76 (0x7C76) y su hermano corto L_7C7E: el rotulo de la fase.

        Cinco casillas -0x28 BYTES, no 0x28 patrones- que van al color por
        duplicado (0x12D8 y 0x1698, la distancia de siempre) y al patron una
        sola vez, porque de la otra mitad se encarga el espejo de 0x7C9B.
        """
        color, patron = (0x7CF1, 0x7CA7) if largo else (0x7D06, 0x7CCD)
        self.rle(color, COLORES + 0x12D8)
        self.rle(color, COLORES + 0x1698)
        self.rle(patron, PATRONES + 0x12D8)
        self.copia_dando_la_vuelta(0x32D8, 0x3698, 0x28)
        return self

    def pon_el_suelo_de_la_ronda(self, escenario):
        """pon_el_suelo_de_la_ronda (0x5A93): cada escenario tiene SU suelo.

        Aqui ya no manda el decorado sino el escenario entero, o sea que dos
        escenarios que comparten bandas no comparten suelo.
        """
        self.rle(self.tabla(0x593F, escenario), COLORES + 0x1080)
        self.rle(self.tabla(0x593F, escenario), COLORES + 0x1440)
        self.rle(self.tabla(0x592F, escenario), PATRONES + 0x1080)
        self.espeja_el_decorado(escenario)       # el `jr L_5A65` de 0x5AB8
        return self

    def fila_del_decorado(self, escenario=0, dos_jugadores=False):
        """L_5B42 (0x5B42): la fila 3, el contador de vidas y los dos nombres."""
        self.rle(0x6006)                         # la fila 3, destino dentro
        if dos_jugadores:                        # L_4838, solo con dos
            self.v[0x384A] = 0x3F
            self.v[0x3855] = 0x3F
        self.literal(0x447B)                     # "LEE YOUNG", el que se maneja
        self.literal(self.tabla(0x4487, escenario), 0x3885)   # y su rival
        return self

    def decorado_de_arriba(self, decorado):
        """L_5B4E (0x5B4E) con el modo 3: el decorado del combate.

        Sube el guion de 0x5FFE a partir de la fila 5, y los decorados 0 y 3
        llevan ademas las dos filas de abajo -que son los mismos 64 bytes de
        0x5F38, indexados igual-.
        """
        self.rle(self.tabla(0x5FFE, decorado), NOMBRES + 0xA0)
        if decorado in (0, 3):
            self.dos_filas_de_abajo(decorado)
        return self

    def dos_filas_de_abajo(self, decorado):
        """L_5BD5 (0x5BD5): los cuatro guiones de 0x5F38, en la fila 21."""
        self.rle(self.tabla(0x5F38, decorado), NOMBRES + 0x2A0)
        return self

    def monta_la_oleada(self, decorado, fase):
        """monta_la_oleada (0x5B70): UNA PANTALLA DE OLEADAS SON CUATRO BYTES.

        La tira de 0x5BE8 que toque trae ocho nibbles, cada nibble elige una
        figura de las treinta de 0x5C64 y las ocho se pintan en fila de cuatro
        en cuatro columnas. Las pares van en el nibble BAJO y las impares en el
        alto, que es lo que dice el `bit 0,b` de 0x5B9F.
        """
        tira = self.tabla(0x5BE8, decorado) + fase * 4
        figuras = self.tabla(0x5C20, decorado)
        fila = 6 if decorado == 2 else 7
        col, p = 0, tira
        for i in range(8):
            x = self.b(p)
            n = (x & 0x0F) if i % 2 == 0 else (x >> 4)
            self.figura(self.tabla(figuras, n), fila, col)
            if i % 2:
                p += 1
            col += 4
        if decorado != 2:                        # la cabecera de la oleada
            self.rellena(NOMBRES + 0xA0, 0x20, self.b(0x5BE4 + decorado))
        self.dos_filas_de_abajo(decorado)
        return self

    def marcador(self, dos_jugadores=False, nivel=1, puntos=(0, 0, 0), vidas=3):
        """L_472F (0x472F): el armazon del marcador y los cuatro numeros.

        Los rotulos salen del guion literal de 0x4A06 -"1UP SCORE", "HI-SCORE",
        "STAGE", "2UP"-, y encima se escriben los digitos en BCD por 0x4785,
        que parte cada byte en dos nibbles y le suma 0x10 para caer en las
        cifras de la fuente.
        """
        self.literal(0x4A06)
        if dos_jugadores:
            self.literal(0x4A34, 0x3816)
            self.rellena(0x3836, 5, 0x00)
        self.bcd(0x381C, [nivel])                # el nivel
        if not dos_jugadores:
            self.bcd(0x383B, [vidas])            # y las vidas
        self.bcd(0x382D, list(puntos))           # los puntos del jugador 1
        return self

    def bcd(self, dest, bytes_bcd):
        """escribe_en_bcd (0x4785): nibble alto y bajo, +0x10 por la fuente.

        El `ld c,0xFF` de 0x4796 es lo que se come los ceros a la izquierda:
        hasta que sale una cifra distinta de cero se escribe la casilla vacia.
        """
        visto = False
        for x in bytes_bcd:
            for n in (x >> 4, x & 0x0F):
                if n or visto:
                    visto = True
                    self.v[dest] = 0x10 + n
                else:
                    self.v[dest] = 0x00
                dest += 1
        if not visto:                            # el ultimo cero si se ve
            self.v[dest - 1] = 0x10
        return self

    # ------------------------------------------------------------------
    # Las escenas enteras, en el orden en que las monta el cartucho
    # ------------------------------------------------------------------
    def monta_la_partida(self, escenario):
        """L_5776 (0x5776): lo que monta la demostracion al empezar.

            prepara_el_marcador             y de paso (0xE2E0) = escenario / 2
            L_5ABA                          los sprites del muneco
            L_5AE1                          el decorado de fondo suelto
            monta_la_pantalla_de_combate    marco, iconos, bandas y espejo
            L_5B42                          la fila 3 y los dos nombres
            L_472F                          y el marcador
        """
        self.sprites_del_jugador()
        self.decorado_de_fondo()
        self.monta_la_pantalla_de_combate(escenario)
        self.fila_del_decorado(escenario)
        self.marcador(nivel=escenario + 1)
        return self

    def empieza_la_ronda(self, escenario):
        """0x50BB: lo que anade el arranque de cada ronda dentro del combate.

        En el modo 3 -el de un jugador contra uno- el suelo lo pone la RONDA
        (0x50C4) y no el montaje de la pantalla, y detras va el decorado de
        arriba de L_5B4E. Con eso la pantalla queda como se ve jugando.
        """
        self.pon_el_suelo_de_la_ronda(escenario)
        self.decorado_de_fondo(escenario)
        self.decorado_de_arriba(escenario >> 1)
        return self

    def pantalla_de_combate(self, escenario):
        """La pantalla de combate entera, encadenada desde el encendido."""
        self.desde_el_encendido()
        self.monta_la_partida(escenario)
        self.empieza_la_ronda(escenario)
        return self

    def pantalla_de_oleadas(self, decorado, fase):
        """Lo mismo, pero fuera del modo 3: el `jr nz` de 0x5B58 se va a las
        oleadas en vez de al decorado del combate."""
        self.desde_el_encendido()
        self.monta_la_partida(decorado * 2)
        # Fuera del modo 3 el `jr nz` de 0x50C2 se salta el suelo de la ronda y
        # el guion del pozo: la pantalla se queda con lo que monto 0x597F.
        self.monta_la_oleada(decorado, fase)
        return self

    def desde_el_encendido(self):
        """El encadenado que hace falta para que la VRAM cuadre con el VDP.

        Y hace falta: el cartucho **solo borra la tabla de nombres** al cambiar
        de escena, nunca los patrones ni el color. Montar una pantalla suelta
        deja cientos de bytes de diferencia contra el emulador que no son un
        error de lectura, sino herencia que falta. Aqui va la cadena entera:

            INIT 0x40B6      arranca_la_pantalla: los 16 KB a cero
            escena 0 sub 2   limpia, la fuente y el cartel de la presentacion
            escena 0 sub 1   0x4114 -> L_4D06, la pantalla del titulo
        """
        self.arranca_la_pantalla()               # INIT 0x40B6
        self.presentacion()
        self.pantalla_del_titulo()               # 0x4114 -> L_4D06
        return self

    def presentacion(self):
        """La escena 0, subescena 2 (0x411B): lo que deja la presentacion.

        Del cartel que baja solo sobrevive lo que no esta en la tabla de
        nombres -sus patrones y su color-, porque el titulo la vuelve a
        limpiar; pero eso basta para que la herencia cuadre.
        """
        self.limpia_la_pantalla()                # 0x4126
        self.monta_la_fuente()                   # 0x4129
        self.monta_el_cartel()                   # 0x412C -> 0x4C0C
        self.rle(0x49F5)                         # los rotulos de 0x4104
        return self


def como_en_la_demostracion(rom, escenario, marcador_corto=True):
    """La cadena EXACTA que reproduce los volcados de tools/omsx_vram.tcl.

    El emulador no arranca una partida por escenario: encadena
    presentacion -> titulo -> demostracion una y otra vez, y el guion de
    volcado le impone a cada vuelta un escenario distinto. Como el cartucho
    solo borra la tabla de nombres, la VRAM de la vuelta N arrastra lo de las
    anteriores, y sin reproducir esa cadena el cotejo no puede dar cero.

    El `marcador_corto` es la unica pieza que no es montaje de pantalla sino
    PARTIDA: en el escenario 3, cuando el enemigo suelta lo suyo, 0x7A36 llama
    a L_7C7E y el rotulo de la fase se cambia por el corto.
    """
    v = Vram(rom)
    v.arranca_la_pantalla()
    for k in range(escenario + 1):
        v.presentacion()
        v.pantalla_del_titulo()
        v.monta_la_partida(k)
        v.empieza_la_ronda(k)
        if marcador_corto and k == 3:
            v.marcador_de_fase(largo=False)
    return v


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    rom = open(sys.argv[1], "rb").read()
    v = Vram(rom).desde_el_encendido()
    print("titulo      : %d casillas de nombre escritas"
          % sum(1 for x in v.v[NOMBRES:NOMBRES + 0x300] if x))
    for e in range(ESCENARIOS):
        v = Vram(rom).pantalla_de_combate(e)
        print("combate %d   : decorado %d, %d casillas"
              % (e, e >> 1, sum(1 for x in v.v[NOMBRES:NOMBRES + 0x300] if x)))
    for d in range(DECORADOS):
        for f in range(3):
            v = Vram(rom).pantalla_de_oleadas(d, f)
            print("oleada %d.%d  : %d casillas"
                  % (d, f, sum(1 for x in v.v[NOMBRES:NOMBRES + 0x300] if x)))


if __name__ == "__main__":
    main()
