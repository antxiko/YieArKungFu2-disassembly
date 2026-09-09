#!/usr/bin/env python3
"""Comprobaciones sobre el listado de Yie Ar Kung-Fu II, y sobre lo que afirma.

Ninguna necesita el cartucho. Las que miran bytes los sacan de los `defb` del
propio listado, que es lo mismo que hay en la ROM -eso lo garantiza
`make verify`, que reensambla y compara el sha256-.

Lo que se vigila:

  - que el listado no se degrade sin que nadie se entere: densidad, rutinas sin
    explicar, bloques de datos sin descripcion;
  - que las afirmaciones que se publican SE COMPRUEBEN sobre los bytes. Los
    ocho nombres de rival se decodifican con la fuente del cartucho y tienen que
    decir YEN-PEI, LAN-FANG, PO-CHIN, WEN-HU, WEI-CHIN, MEI-LING, HAN-CHEN y LI
    JEN; los bloques de los ocho rivales tienen que teselar sin hueco ni solape
    con el lector que escribe ceros y no con el otro; las dos parejas del
    rastreo de ranuras tienen que ser las que se publican; y las cifras de la
    portada tienen que ser las de este listado;
  - que no se cuele el nombre de otro juego de la serie, que ya ha pasado.
"""
import os
import re
import sys
import unittest

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASM = os.path.join(RAIZ, "src", "yiear2.asm")
NOTES = os.path.join(RAIZ, "src", "yiear2.notes")
ENTRIES = os.path.join(RAIZ, "src", "yiear2.entries")
DOCS = os.path.join(RAIZ, "docs")
ORG, FIN = 0x4000, 0xC000

sys.path.insert(0, os.path.join(RAIZ, "tools"))

import formatos as F                                          # noqa: E402

# Los demas juegos de la serie. Que el nombre de otro salga en una pagina de
# este es casi siempre un copia y pega: ya paso con cinco ficheros LICENSE, con
# el pie de catorce paginas de otro proyecto y con unos tests que llegaron
# copiados y apuntaban al .asm de otro cartucho.
#
# "Yie Ar Kung-Fu" NO esta en la lista, y no por dejadez: este cartucho es su
# segunda parte y ademas lo BUSCA en la otra ranura, asi que nombrarlo es el
# contenido. Lo vigila su propio test, mas abajo.
OTROS_JUEGOS = (
    "Tennis", "Pitfall", "Temptations", "Stardust", "Ale Hop", "Colt 36",
    "Antarctic", "Athletic Land", "Monkey Academy", "F-1 Spirit", "Pippols",
    "Time Pilot", "Frogger", "Super Cobra", "Billiards", "Mahjong",
    "Hyper Rally", "Nemesis", "Demonia", "Cabbage", "Hole in One",
    "Casio World Open", "3D Golf", "Baseball", "Goonies", "Trailblazer",
    "King's Valley", "Sky Jaguar", "Mopi Ranger", "Descubrimiento",
    "War in Middle Earth", "Ping Pong", "Soccer", "Football", "Road Fighter",
    "Hyper Sports", "Hyper Olympic", "Valley", "Ranger", "Jaguar",
)


def lee(ruta):
    with open(ruta, encoding="utf-8") as f:
        return f.read()


def lineas_del_asm():
    return lee(ASM).splitlines()


def bytes_de_los_defb():
    """Reconstruye los bloques de datos leyendo los `defb` del listado.

    Cada linea de datos acaba en un comentario con su direccion, asi que se
    puede volver a montar el trozo de ROM sin tener el cartucho delante.
    """
    fuera = {}
    for ln in lineas_del_asm():
        m = re.match(r"^\tdef[bw] (.*?)\t*; ?([0-9a-f]{4})", ln)
        if not m:
            continue
        dire = int(m.group(2), 16)
        vals = []
        for tr in m.group(1).split(","):
            tr = tr.strip()
            if not tr:
                continue
            v = int(tr[:-1], 16) if tr.endswith("h") else int(tr, 0)
            if ln.lstrip().startswith("defw"):
                vals += [v & 0xFF, v >> 8]
            else:
                vals.append(v)
        for k, v in enumerate(vals):
            fuera[dire + k] = v
    return fuera


DATOS = bytes_de_los_defb()


def trozo(dire, n):
    """n bytes seguidos desde una direccion, sacados de los `defb`."""
    fuera = []
    for k in range(n):
        if dire + k not in DATOS:
            raise AssertionError("0x%04X no esta en los datos del listado"
                                 % (dire + k))
        fuera.append(DATOS[dire + k])
    return fuera


def rom_de_mentira():
    """Un buffer de 32 KB con lo que el listado declara como datos.

    Sirve para pasarle a tools/formatos.py los lectores de verdad sin tener el
    cartucho delante: lo que no es dato queda a cero, y ningun formato de este
    cartucho empieza en zona de codigo.
    """
    b = bytearray(FIN - ORG)
    for d, v in DATOS.items():
        if ORG <= d < FIN:
            b[d - ORG] = v
    return bytes(b)


ROM = rom_de_mentira()


def palabra(d):
    return DATOS[d] | (DATOS[d + 1] << 8)


def texto_con_la_fuente(bs):
    """La fuente del cartucho: 0x00 espacio, 0x10..0x19 cifras, 0x21..0x3A A-Z.

    Se comprueba sola: con este reparto los rotulos salen legibles -SCORE, PLAY
    SELECT, GAME OVER- y con cualquier otro no.
    """
    fuera = ""
    for b in bs:
        if b == 0x00:
            fuera += " "
        elif 0x21 <= b <= 0x3A:
            fuera += chr(ord("A") + b - 0x21)
        elif 0x10 <= b <= 0x19:
            fuera += chr(ord("0") + b - 0x10)
        elif b == 0x20:
            fuera += "-"        # y no un espacio: se ve en YEN-PEI
        else:
            fuera += "."
    return fuera


class TestListado(unittest.TestCase):
    """Que el listado siga siendo el que se publica."""

    def setUp(self):
        self.lineas = lineas_del_asm()

    def test_reproduce_la_rom_en_el_encabezado(self):
        """El listado dice de que cartucho es."""
        cabeza = "\n".join(self.lineas[:30])
        self.assertIn("YIE AR KUNG-FU II", cabeza)
        self.assertIn("RC-737", cabeza)

    def test_todas_las_instrucciones_llevan_su_direccion(self):
        """Sin la direccion al lado, ni densidad.py ni los aplicadores valen."""
        malas = [ln for ln in self.lineas
                 if ln.startswith("\t") and ";" not in ln
                 and not ln.strip().startswith(("org", "end", "include"))]
        self.assertEqual(malas, [], "lineas sin direccion: %s" % malas[:3])

    def test_densidad_por_encima_del_liston(self):
        """El liston de la serie es el 22 %; este listado va por el 40,9 %."""
        n = c = 0
        for ln in self.lineas:
            m = re.match(r"^\t.*;([0-9a-f]{4})(.*)$", ln)
            if not m:
                continue
            n += 1
            if ";" in m.group(2):
                c += 1
        self.assertGreater(n, 7000)
        self.assertGreaterEqual(100.0 * c / n, 38.0,
                                "densidad %.1f %%, por debajo de lo publicado" %
                                (100.0 * c / n))

    def test_ninguna_rutina_por_debajo_del_diez_por_ciento(self):
        """El otro numero del liston, y el que de verdad cuesta."""
        flojas, nombre, n, c = [], "(cabecera)", 0, 0
        for ln in self.lineas:
            m = re.match(r"^([A-Za-z_][A-Za-z_0-9]*):\s*(;.*)?$", ln)
            if m:
                if n >= 6 and c * 100 // n < 10:
                    flojas.append(nombre)
                nombre, n, c = m.group(1), 0, 0
                continue
            m = re.match(r"^\t.*;([0-9a-f]{4})(.*)$", ln)
            if not m:
                continue
            n += 1
            if ";" in m.group(2):
                c += 1
        self.assertEqual(flojas, [], "rutinas flojas: %s" % flojas[:5])

    def test_ninguna_rutina_se_queda_sin_bautizar(self):
        """Lo que lleva nombre son las RUTINAS, y una rutina es lo que se LLAMA.

        Una etiqueta a la que solo se llega con `jr` o `jp` es un salto interno
        y se queda como `L_xxxx`; una que es destino de un `call` es una rutina
        y tiene que tener nombre. Aqui no queda ninguna sin el, y el que las
        busca es tools/sin_bautizar.py.
        """
        llamadas = set()
        for ln in self.lineas:
            m = re.search(r"^\tcall\s+(?:[a-z]+,)?(L_[0-9A-F]{4})\b", ln)
            if m:
                llamadas.add(m.group(1))
        self.assertEqual(sorted(llamadas), [],
                         "rutinas llamadas y sin bautizar: %s"
                         % sorted(llamadas)[:6])

    def test_las_etiquetas_sin_nombre_no_van_a_mas(self):
        """Y las que quedan sin nombre, que no vuelvan a subir.

        738 de 1168 siguen siendo `L_xxxx`, y todas son saltos internos. El
        numero se fija aqui para que solo pueda bajar.
        """
        etiquetas = [ln[:-1] for ln in self.lineas
                     if re.match(r"^[A-Za-z_][A-Za-z_0-9]*:\s*$", ln)]
        sin_nombre = [e for e in etiquetas if re.match(r"^L_[0-9A-F]{4}$", e)]
        self.assertLessEqual(len(sin_nombre), 738,
                             "%d de %d etiquetas sin bautizar: han subido"
                             % (len(sin_nombre), len(etiquetas)))


class TestBloquesDeDatos(unittest.TestCase):
    """Cada bloque de datos tiene que decir QUE es, no solo donde empieza."""

    def test_todos_los_bloques_llevan_nombre_y_explicacion(self):
        cortos = []
        for ln in lee(NOTES).splitlines():
            m = re.match(r"^D (0x[0-9a-f]{4}) (0x[0-9a-f]{4}) (\S+)\s+(.*)$",
                         ln)
            if not m:
                continue
            if len(m.group(4).strip()) < 20:
                cortos.append((m.group(1), m.group(3)))
        self.assertEqual(cortos, [],
                         "bloques con explicacion de menos de veinte letras: %s"
                         % cortos[:5])

    def test_ningun_bloque_se_llama_por_su_direccion(self):
        """Un nombre como tabla_de_0x5c20 es un bloque sin identificar.

        Nombrar una direccion de RAM (0xE0xx) es otra cosa y vale: dice
        QUE variable indexa el bloque, que es justo lo que se quiere.
        """
        malos = [ln.split()[3] for ln in lee(NOTES).splitlines()
                 if ln.startswith("D 0x")
                 and re.search(r"0x[4-9ab][0-9a-f]{3}", ln.split()[3])]
        self.assertEqual(malos, [],
                         "bloques bautizados por su direccion: %s" % malos[:5])

    def test_las_entradas_estan_justificadas(self):
        """Cada punto de entrada declarado a mano lleva su por que."""
        sin_razon = []
        for ln in lee(ENTRIES).splitlines():
            ln = ln.strip()
            if not ln or ln.startswith("#"):
                continue
            if ";" not in ln and "#" not in ln:
                sin_razon.append(ln)
        self.assertEqual(sin_razon, [],
                         "entradas sin justificar: %s" % sin_razon[:5])


class TestLasDosCabeceras(unittest.TestCase):
    """Las dos cabeceras, leidas de los bytes."""

    def test_la_cabecera_del_cartucho(self):
        self.assertEqual(trozo(0x4000, 2), [0x41, 0x42])      # "AB"
        self.assertEqual(palabra(0x4002), 0x4070)             # INIT
        self.assertEqual(trozo(0x4004, 12), [0] * 12)

    def test_la_cabecera_del_game_master(self):
        """"AB" 07 37: el 0x07 de los RC-7xx y el 0x37 de RC-737."""
        self.assertEqual(trozo(0x4010, 4), [0x41, 0x42, 0x07, 0x37])

    def test_las_variables_que_el_game_master_puede_tocar(self):
        self.assertEqual([palabra(0x4014 + 2 * i) for i in range(7)],
                         [0x6400, 0xE000, 0xE002, 0xE055, 0xE066, 0xE048,
                          0xE04E])

    def test_la_marca_oculta_cierra_en_el_ultimo_byte(self):
        """RC-737 en los ultimos bytes, la marca que descubrio Manuel Pazos."""
        cola = trozo(0xBFF0, 16)
        self.assertEqual(cola[-2:], [0x37, 0xAA])
        self.assertEqual(max(DATOS), 0xBFFF)


class TestElRastreoDeRanuras(unittest.TestCase):
    """Las dos parejas contra las que compara el rastreo de 0xBF6C."""

    def test_las_dos_parejas_son_las_publicadas(self):
        self.assertEqual(trozo(0xBFD9, 4), [0x5A, 0x47, 0x23, 0x70])

    def test_son_dos_y_no_tres(self):
        """Detras de la segunda pareja ya no hay una tercera: la lista cierra.

        Lo dice el propio bucle, que compara exactamente dos, y aqui se
        comprueba que los dos bytes siguientes no son otra pareja escondida.
        """
        self.assertNotEqual(trozo(0xBFDD, 2), [0x5A, 0x47])


class TestLosRivales(unittest.TestCase):
    """Los ocho nombres, decodificados de los bytes con la fuente del cartucho.

    No se comprueba que el texto del listado diga YEN-PEI: se leen los guiones
    y se mira lo que dicen.
    """

    NOMBRES = ["YEN-PEI", "LAN-FANG", "PO-CHIN", "WEN-HU", "WEI-CHIN",
               "MEI-LING", "HAN-CHEN", "LI-JEN"]

    def guion(self, d):
        fuera = []
        while DATOS[d] != 0xFF:
            fuera.append(DATOS[d])
            d += 1
        return texto_con_la_fuente(fuera).strip()

    def test_el_que_se_maneja_es_lee_young(self):
        """El guion de 0x447B lleva su destino de VRAM delante (0x3892)."""
        self.assertEqual(palabra(0x447B), 0x3892)
        self.assertEqual(self.guion(0x447D), "LEE YOUNG")

    def test_los_ocho_nombres(self):
        for i, esperado in enumerate(self.NOMBRES):
            self.assertEqual(self.guion(palabra(0x4487 + 2 * i)), esperado)

    def test_la_tabla_cierra_donde_empieza_su_primera_entrada(self):
        """Ocho punteros, y el mas bajo es justo el byte siguiente a la tabla."""
        entradas = [palabra(0x4487 + 2 * i) for i in range(8)]
        self.assertEqual(min(entradas), 0x4497)
        self.assertEqual(len(set(entradas)), 8)


class TestLosBloquesDeLosRivales(unittest.TestCase):
    """Los ocho bloques de 0x6922, leidos con el lector que escribe CEROS.

    Esta es la prueba de que 0x67A7 y 0x67F5 no son intercambiables: con el
    lector bueno los tramos teselan sin un hueco ni un solape, y con el otro no.
    """

    def bloques(self):
        return [palabra(0x6922 + 2 * e) for e in range(8)]

    def entradas(self, b):
        return [palabra(b + 2 * i) for i in range(22)]

    def test_son_ocho_bloques_de_veintidos_punteros(self):
        for b in self.bloques():
            self.assertEqual(min(self.entradas(b)), b + 44,
                             "el bloque 0x%04X no cierra a 44 bytes" % b)

    def test_los_ciento_sesenta_y_ocho_tramos_teselan(self):
        malos = []
        for e, b in enumerate(self.bloques()):
            ent = self.entradas(b)
            for i, p in enumerate(ent):
                n, _, _, _ = F.entrada_del_enemigo(ROM, p, impar=(i % 2 == 1))
                siguientes = [x for x in ent if x > p]
                if not siguientes:
                    continue
                if p + n != min(siguientes):
                    malos.append((e, i, hex(p), hex(p + n),
                                  hex(min(siguientes))))
        self.assertEqual(malos, [], "tramos que no teselan: %s" % malos[:4])

    def test_las_entradas_impares_son_remisiones_de_dos_bytes(self):
        """Y apuntan al segundo byte de otra entrada, no a un dibujo."""
        for b in self.bloques():
            ent = self.entradas(b)
            for i in range(1, 22, 2):
                destino = palabra(ent[i] + 1)
                self.assertIn(destino - 1, ent,
                              "la remision de 0x%04X no apunta a una entrada"
                              % ent[i])


class TestLasOleadas(unittest.TestCase):
    """Una pantalla de oleadas son cuatro bytes: ocho nibbles y treinta figuras."""

    def test_las_cuatro_tiras_son_de_doce_bytes(self):
        tiras = sorted(palabra(0x5BE8 + 2 * i) for i in range(4))
        self.assertEqual(tiras, [0x5BF0, 0x5BFC, 0x5C08, 0x5C14])
        for a, b in zip(tiras, tiras[1:] + [0x5C20]):
            self.assertEqual(b - a, 12)

    def test_ningun_nibble_se_sale_de_las_figuras_de_su_tabla(self):
        """Cada decorado tiene su tabla, y ningun nibble pide una figura de mas."""
        tablas = sorted(palabra(0x5C20 + 2 * i) for i in range(4))
        limites = dict(zip(tablas, tablas[1:] + [0x5C64]))
        for d in range(4):
            tabla = palabra(0x5C20 + 2 * d)
            cuantas = (limites[tabla] - tabla) // 2
            tira = palabra(0x5BE8 + 2 * d)
            for k in range(12):
                for n in (DATOS[tira + k] & 0x0F, DATOS[tira + k] >> 4):
                    self.assertLess(n, cuantas,
                                    "el decorado %d pide la figura %d y solo "
                                    "tiene %d" % (d, n, cuantas))

    def test_las_treinta_figuras_encajan_con_el_lector_que_REPITE(self):
        """El otro lector, el que escribe ceros, no las cierra igual.

        Las treinta van seguidas y la ultima acaba justo en 0x5F38, que es la
        siguiente direccion que carga el codigo (desde 0x5BD5).
        """
        p, n = 0x5C64, 0
        while p < 0x5F38:
            _, _, _, gasta = F.figura(ROM, p)
            self.assertGreater(gasta, 0)
            p += gasta
            n += 1
        self.assertEqual(p, 0x5F38)
        self.assertEqual(n, 30)


class TestLosFotogramasDelJugador(unittest.TestCase):
    """Veinte punteros: diez dibujos y diez remisiones de dos bytes."""

    def test_la_tabla_cierra_en_su_primera_entrada(self):
        ent = [palabra(0x6C83 + 2 * i) for i in range(20)]
        self.assertEqual(min(ent), 0x6CAB)

    def test_las_impares_remiten_al_dibujo_de_delante(self):
        ent = [palabra(0x6C83 + 2 * i) for i in range(20)]
        for i in range(1, 20, 2):
            self.assertEqual(palabra(ent[i]), ent[i - 1],
                             "la remision %d no apunta al dibujo anterior" % i)

    def test_los_ocho_patrones_del_muneco_van_de_cuatro_en_cuatro(self):
        """Son sprites de 16x16, y por eso el numero de patron sube de 4 en 4."""
        self.assertEqual(trozo(0x6C7B, 8),
                         [0x00, 0x04, 0x08, 0x0C, 0x10, 0x14, 0x18, 0x1C])


class TestLaSopa(unittest.TestCase):
    """El sitio de cada ronda, y los cuatro golpes que pueden alcanzarlo.

    Lo que se publica es que la sopa sale PEGANDO en un sitio distinto por
    ronda. Las dos mitades de esa frase salen de los bytes: la tabla de
    0x507A da el sitio, y la CUARTA caja de cada dibujo -la que 0x7402
    compara con el- solo existe en cuatro de los diez.
    """

    def cuarta_caja(self, i):
        """La cuarta caja del dibujo i, o None si ese fotograma no la lleva."""
        import figuras                                          # noqa: E402
        p = palabra(0x6C83 + 4 * i)
        cajas, _ = figuras.lee_las_cuatro_cajas(ROM, p, ORG)
        if cajas and cajas[-1][2] is None:       # la cuarta no lleva alto ni ancho
            return cajas[-1][0], cajas[-1][1]
        return None

    def test_son_ocho_parejas_una_por_ronda(self):
        self.assertEqual(trozo(0x507A, 16),
                         [0x7E, 0x80, 0x8E, 0xE0, 0x68, 0xD8, 0x8E, 0x03,
                          0x9E, 0x90, 0x68, 0x10, 0x68, 0x80, 0x8E, 0x80])

    def test_solo_cuatro_dibujos_llevan_la_caja_del_golpe(self):
        """Y son los cuatro ataques: sin ella, 0x65C6 tumba la comparacion."""
        con = [i for i in range(10) if self.cuarta_caja(i) is not None]
        self.assertEqual(con, [1, 3, 5, 6])

    def test_los_cuatro_puntos_del_golpe(self):
        self.assertEqual([self.cuarta_caja(i) for i in (1, 3, 5, 6)],
                         [(0x0D, 0x18), (0x01, 0x1E), (0x15, 0x16), (0x1A, 0x1E)])


class TestElTrucoDeLasVidas(unittest.TestCase):
    """Las diez pulsaciones que hay que acertar, leidas de los bytes."""

    def test_es_un_uno_dos_tres_cuatro(self):
        pulsaciones = trozo(0x43ED, 10)
        self.assertEqual(pulsaciones,
                         [0x01, 0x04, 0x04, 0x02, 0x02, 0x02,
                          0x08, 0x08, 0x08, 0x08])
        # Y agrupadas: una vez el 0x01, dos el 0x04, tres el 0x02 y cuatro el
        # 0x08, que es lo que se publica como "arriba, izquierda, abajo,
        # derecha".
        veces = [(pulsaciones.count(v), v) for v in (0x01, 0x04, 0x02, 0x08)]
        self.assertEqual(veces, [(1, 0x01), (2, 0x04), (3, 0x02), (4, 0x08)])


class TestLosGuionesDeSprite(unittest.TestCase):
    """Los dieciseis guiones del muneco y sus dieciseis destinos."""

    def test_los_destinos_caen_en_la_tabla_de_patrones_de_sprite(self):
        destinos = [palabra(0x5B22 + 2 * i) for i in range(16)]
        self.assertEqual(destinos, sorted(destinos))
        for d in destinos:
            self.assertGreaterEqual(d, 0x1800)
            self.assertLess(d, 0x2000)

    def test_cada_guion_cabe_en_el_hueco_que_deja_el_siguiente(self):
        """Un guion que se pasara pisaria el destino del siguiente."""
        guiones = [palabra(0x5B02 + 2 * i) for i in range(16)]
        destinos = [palabra(0x5B22 + 2 * i) for i in range(16)]
        for i, (g, d) in enumerate(zip(guiones, destinos)):
            tramos, _ = F.guion_rle(ROM, g, con_dir=False)
            escritos = sum(len(b) for _, b in tramos)
            tope = destinos[i + 1] if i + 1 < len(destinos) else 0x2000
            self.assertLessEqual(d + escritos, tope,
                                 "el guion 0x%04X se pasa de 0x%04X"
                                 % (g, tope))


class TestLasCifrasDeLaPortada(unittest.TestCase):
    """Lo que la portada declara tiene que ser lo que dice el listado."""

    def setUp(self):
        sys.path.insert(0, os.path.join(RAIZ, "tools"))
        import make_web
        self.w = make_web

    def test_la_suma_de_bytes_da_el_cartucho(self):
        self.assertEqual(self.w.CODIGO + self.w.DATOS, 32768)

    def test_las_cifras_de_la_portada_son_las_del_listado(self):
        # La misma cuenta que tools/densidad.py: un bloque es una etiqueta
        # CON instrucciones detras, y las etiquetas seguidas no cuentan dos
        # veces.
        n = c = rutinas = enbloque = 0
        for ln in lineas_del_asm():
            if re.match(r"^[A-Za-z_][A-Za-z_0-9]*:\s*(;.*)?$", ln):
                if enbloque:
                    rutinas += 1
                enbloque = 0
                continue
            m = re.match(r"^\t.*;([0-9a-f]{4})(.*)$", ln)
            if not m:
                continue
            n += 1
            enbloque += 1
            if ";" in m.group(2):
                c += 1
        if enbloque:
            rutinas += 1
        self.assertEqual(self.w.INSTRUCCIONES, n)
        self.assertEqual(self.w.COMENTARIOS, c)
        self.assertEqual(self.w.RUTINAS, rutinas)

    def test_la_densidad_declarada_cuadra_con_las_dos_cuentas(self):
        d = 100.0 * self.w.COMENTARIOS / self.w.INSTRUCCIONES
        self.assertEqual(self.w.DENSIDAD.replace(",", "."), "%.1f" % d)
        self.assertEqual(self.w.DENSIDAD_EN, "%.1f" % d)

    def test_la_ficha_dice_el_sha_de_este_cartucho(self):
        sha = None
        for ln in lee(os.path.join(RAIZ, "Makefile")).splitlines():
            if ln.startswith("SHA"):
                sha = ln.split("=")[1].strip()
        self.assertIsNotNone(sha)
        for idioma in ("es", "en"):
            ficha = " ".join(self.w.TXT[idioma]["ficha"])
            self.assertIn(sha[:8], ficha)
            self.assertIn("RC-737", ficha)


class TestLaWebEstaCompleta(unittest.TestCase):
    """Las siete paginas por idioma y las imagenes que citan."""

    PAGINAS_EN = ("GETTING-STARTED", "THE-GAME", "THE-CARTRIDGE", "THE-CODE",
                  "FINDINGS", "IN-THE-EMULATOR", "OPEN-QUESTIONS")
    PAGINAS_ES = ("EMPEZAR", "EL-JUEGO", "EL-CARTUCHO", "EL-CODIGO",
                  "HALLAZGOS", "EN-EL-EMULADOR", "PREGUNTAS-ABIERTAS")

    def test_estan_las_siete_paginas_en_los_dos_idiomas(self):
        for p in self.PAGINAS_EN:
            self.assertTrue(os.path.exists(os.path.join(DOCS, p + ".md")), p)
        for p in self.PAGINAS_ES:
            self.assertTrue(
                os.path.exists(os.path.join(DOCS, "es", p + ".md")), p)

    def test_las_imagenes_que_se_citan_existen(self):
        faltan = []
        for base, sub in ((DOCS, ""), (os.path.join(DOCS, "es"), "es")):
            for fn in os.listdir(base):
                if not fn.endswith(".md"):
                    continue
                for src in re.findall(r"!\[[^\]]*\]\(([^)]+)\)",
                                      lee(os.path.join(base, fn))):
                    ruta = os.path.normpath(os.path.join(base, src))
                    if not os.path.exists(ruta):
                        faltan.append(os.path.join(sub, fn) + " -> " + src)
        self.assertEqual(faltan, [], "imagenes que no existen: %s" % faltan[:5])

    def test_las_paginas_en_castellano_suben_un_nivel_para_las_imagenes(self):
        """docs/es/ vive un nivel mas abajo: sus imagenes van con ../"""
        malas = []
        for fn in os.listdir(os.path.join(DOCS, "es")):
            if not fn.endswith(".md"):
                continue
            for src in re.findall(r"!\[[^\]]*\]\(([^)]+)\)",
                                  lee(os.path.join(DOCS, "es", fn))):
                if src.startswith("imagenes/"):
                    malas.append(fn + " -> " + src)
        self.assertEqual(malas, [], "imagenes sin ../: %s" % malas[:5])

    def test_la_galeria_de_la_portada_esta_entera(self):
        import contenido_web
        faltan = [f for f, _, _ in contenido_web.GALERIA
                  if not os.path.exists(os.path.join(DOCS, "imagenes", f))]
        self.assertEqual(faltan, [], "faltan en la galeria: %s" % faltan)

    def test_no_se_publica_ninguna_pantalla_de_oleadas(self):
        """Lo que no se sabe montar no se publica.

        Las figuras de las oleadas piden casillas que en la VRAM del
        combate son la fuente, asi que el dibujo sale con letras dentro.
        Mientras no se sepa de donde salen sus patrones, este test exige
        lo contrario de lo normal: que NO haya oleada*.png publicada.
        """
        sobra = [f for f in os.listdir(os.path.join(DOCS, "imagenes"))
                 if f.startswith("oleada")]
        self.assertEqual(sobra, [],
                         "publicadas sin saber montarlas: %s" % sobra)

    def test_el_rotulo_de_la_cabecera_esta(self):
        """Si no esta, make_web se cae al texto y la portada sale sin logotipo."""
        self.assertTrue(
            os.path.exists(os.path.join(DOCS, "imagenes", "rotulo.png")))


class TestSinNombresDeOtroJuego(unittest.TestCase):
    """El copia y pega del proyecto anterior deja el nombre del juego anterior."""

    # La UNICA excepcion, y acotada: busca_marca_konami.py lleva en su
    # docstring la tabla de que cartuchos de la serie llevan la marca oculta y
    # cuales no. Eso no es un resto de otro proyecto: es el asunto de la
    # herramienta, y sin esos ejemplos las reglas que aplica no se entienden.
    # La excepcion exige que el fichero hable de la marca, para que no se
    # convierta en un agujero por el que pase cualquier otra cosa.
    EXCEPCION = os.path.join("tools", "busca_marca_konami.py")

    def ficheros(self):
        for base, dirs, fs in os.walk(RAIZ):
            dirs[:] = [d for d in dirs
                       if d not in (".git", "__pycache__", "work",
                                    ".pytest_cache", ".forja")]
            for f in fs:
                if f.endswith((".py", ".md", ".tcl", ".html")) or f == "LICENSE":
                    yield os.path.join(base, f)

    def test_la_excepcion_sigue_siendo_lo_que_dice_ser(self):
        ruta = os.path.join(RAIZ, self.EXCEPCION)
        self.assertTrue(os.path.exists(ruta))
        self.assertIn("marca", lee(ruta).lower())

    def test_ni_los_textos_ni_las_herramientas_nombran_otro_juego(self):
        malos = []
        for ruta in self.ficheros():
            if os.path.abspath(ruta) == os.path.abspath(__file__):
                continue        # este fichero lleva la lista, claro
            if os.path.relpath(ruta, RAIZ) == self.EXCEPCION:
                continue
            texto = lee(ruta)
            for juego in OTROS_JUEGOS:
                if juego in texto:
                    malos.append("%s: %s" % (os.path.relpath(ruta, RAIZ),
                                             juego))
        self.assertEqual(malos, [], "nombran otro juego: %s" % malos[:6])

    def test_las_menciones_al_primero_van_con_su_referencia(self):
        """Nombrar Yie Ar Kung-Fu (el de 1985) vale, porque es el contenido.

        Pero solo si el texto dice de cual habla: en el mismo fichero tiene que
        aparecer su numero de catalogo. Asi la excepcion no se convierte en un
        agujero por el que pase cualquier resto de otro proyecto.
        """
        malos = []
        for ruta in self.ficheros():
            if os.path.abspath(ruta) == os.path.abspath(__file__):
                continue
            texto = lee(ruta)
            sueltas = len(re.findall(r"Yie Ar Kung-Fu(?! ?II)", texto))
            if sueltas and "RC-725" not in texto:
                malos.append(os.path.relpath(ruta, RAIZ))
        self.assertEqual(malos, [],
                         "nombran al primero sin decir cual es: %s" % malos[:5])

    def test_las_herramientas_apuntan_al_fichero_de_este_juego(self):
        malos = []
        for ruta in self.ficheros():
            if not ruta.endswith((".py", ".tcl")):
                continue
            for m in re.finditer(r"src/([a-z0-9_]+)\.(asm|notes|entries)",
                                 lee(ruta)):
                if m.group(1) != "yiear2":
                    malos.append("%s: %s" % (os.path.relpath(ruta, RAIZ),
                                             m.group(0)))
        self.assertEqual(malos, [], "apuntan a otro listado: %s" % malos[:5])

    def test_los_ficheros_que_se_citan_existen(self):
        """Citar un fichero que no esta es mentir sobre el repositorio."""
        faltan = []
        for ruta in self.ficheros():
            if not ruta.endswith(".md"):
                continue
            for m in re.finditer(r"`(tools/[a-z0-9_]+\.(?:py|tcl))`",
                                 lee(ruta)):
                if not os.path.exists(os.path.join(RAIZ, m.group(1))):
                    faltan.append("%s: %s" % (os.path.relpath(ruta, RAIZ),
                                              m.group(1)))
        self.assertEqual(faltan, [], "citan lo que no existe: %s" % faltan[:5])


if __name__ == "__main__":
    unittest.main()
