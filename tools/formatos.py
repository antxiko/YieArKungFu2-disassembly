#!/usr/bin/env python3
"""Los formatos de datos de Yie Ar Kung-Fu II, sacados del codigo que los lee.

Ninguno esta supuesto: cada uno es la traduccion a Python de una rutina del
cartucho, y la prueba de que estan bien es que las longitudes ENCAJAN -el
guion acaba justo donde empieza el siguiente-.

  guion_literal(rom, p)   traduce 0x48C8:
        word   direccion de VRAM
        bytes  se escriben seguidos
        0xFE   cierra el tramo y abre otro, con otra direccion delante
        0xFF   cierra el guion

  guion_rle(rom, p, con_dir)   traduce 0x48E1 (con_dir=True) y 0x48E7 (False,
                               porque entonces el destino lo pone quien llama):
        word        direccion de VRAM, solo si con_dir
        0x01..0x7F  repite N veces el byte que sigue
        0x81..0xFF  copia los N = orden & 0x7F bytes que siguen
        0x80        cierra el tramo y VUELVE A 0x48E1, o sea abre otro tramo
                    con otra direccion de VRAM delante
        0x00        cierra el guion

CUIDADO con el 0x80. Leerlo como "no hace nada" da un guion que tambien parece
encajar -0x49F5 salia de 53 bytes y llegaba limpiamente a 0x4A2A, saltandose de
paso el guion de 0x4A06 que hay en medio-, y ademas escupia texto legible. Lo
que lo delata es que la cadena entera de guiones consecutivos solo cierra sin
huecos ni solapes con la lectura buena: 0x49F5 son 17 bytes y acaban en 0x4A06.

  figura(rom, p)          traduce 0x67F5  (0xE0..0xEF repite un byte)
  figura_a_ceros(rom, p)  traduce 0x67A7  (0xE0..0xEF escribe ceros)

Los dos lectores de figuras son PARECIDOS Y DISTINTOS, y el cartucho usa los
dos. Ver la explicacion en figura_a_ceros.

Uso: formatos.py <rom> rle  <dir> [<dir> ...]      (destino en el guion)
     formatos.py <rom> rleh <dir> [<dir> ...]      (destino en HL, 0x48E7)
     formatos.py <rom> lit  <dir> [<dir> ...]
"""
import sys

ORG = 0x4000


def guion_rle(rom, p, con_dir=True, org=ORG):
    """([(direccion de VRAM o None, bytes)], bytes de ROM que ocupa)."""
    ini, tramos, vram = p, [], None
    if con_dir:
        vram = rom[p - org] | (rom[p + 1 - org] << 8)
        p += 2
    out = bytearray()
    while True:
        orden = rom[p - org]
        p += 1
        if orden == 0x00:                        # cierra el guion
            tramos.append((vram, bytes(out)))
            return tramos, p - ini
        if orden == 0x80:                        # cierra el tramo y abre otro
            tramos.append((vram, bytes(out)))
            out = bytearray()
            vram = rom[p - org] | (rom[p + 1 - org] << 8)
            p += 2
            continue
        n = orden & 0x7F
        if n == orden:                           # bit 7 a cero: repetir
            out.extend([rom[p - org]] * n)
            p += 1
        else:                                    # bit 7 puesto: literal
            out.extend(rom[p - org:p - org + n])
            p += n


def guion_literal(rom, p, org=ORG):
    """([(direccion de VRAM, bytes)], bytes de ROM que ocupa)."""
    ini, tramos = p, []
    while True:
        vram = rom[p - org] | (rom[p + 1 - org] << 8)
        p += 2
        datos = bytearray()
        while True:
            b = rom[p - org]
            p += 1
            if b in (0xFE, 0xFF):
                tramos.append((vram, bytes(datos)))
                break
            datos.append(b)
        if b == 0xFF:
            return tramos, p - ini


def figura(rom, p, org=ORG):
    """Traduce 0x67F5: una figura de casillas, con su alto y su ancho delante.

    Los dos primeros bytes son alto y ancho, y el total de casillas que hay que
    producir es alto*ancho -eso lo calcula el propio cartucho con un `add a,c`
    repetido-. Luego, ordenes de uno o dos bytes:

        0xF0..0xFF   los N = orden & 0x0F siguientes son una SECUENCIA: se
                     escribe el byte que viene detras y se va SUMANDO UNO
        0xE0..0xEF   repite N = orden & 0x0F veces el byte que viene detras
        0x00..0xDF   una casilla, tal cual

    Devuelve (alto, ancho, casillas, bytes de ROM que ocupa). La prueba de que
    esta bien leido es doble: salen exactamente alto*ancho casillas Y la figura
    acaba justo donde empieza la siguiente de su tabla.
    """
    ini = p
    alto, ancho = rom[p - org], rom[p + 1 - org]
    p += 2
    quedan = alto * ancho
    out = bytearray()
    while quedan > 0:
        o = rom[p - org]
        p += 1
        if o >= 0xF0:                       # secuencia ascendente
            n = o & 0x0F
            v = rom[p - org]
            p += 1
            for _ in range(n):
                if quedan == 0:
                    break
                out.append(v & 0xFF)
                v += 1
                quedan -= 1
        elif o >= 0xE0:                     # repetir el mismo
            n = o & 0x0F
            v = rom[p - org]
            p += 1
            for _ in range(n):
                if quedan == 0:
                    break
                out.append(v)
                quedan -= 1
        else:                               # una casilla suelta
            out.append(o)
            quedan -= 1
    return alto, ancho, bytes(out), p - ini



def figura_a_ceros(rom, p, org=ORG):
    """Traduce 0x67A7, el HERMANO de 0x67F5, que NO es el mismo formato.

    Los dos leen alto y ancho delante y los dos tratan 0xF0..0xFF como una
    secuencia ascendente, pero el 0xE0..0xEF cambia y cambia de las dos
    maneras a la vez:

        0x67F5   `inc de` y repite el byte que viene detras   -> 2 bytes
        0x67A7   escribe N CEROS, sin byte de valor           -> 1 byte

    Confundirlos no da un error a la primera casilla: da una figura que casi
    encaja y que se pasa por dos o tres bytes, que es justo lo que costaba
    cuadrar los ocho bloques del enemigo.

    El otro detalle del original: el bucle corta en cuanto ha puesto sus
    alto*ancho casillas, aunque sea a media orden (los `dec b / ret z` de
    0x67B4 y 0x67C6). Un lector que termine la orden empezada se pasa.
    """
    ini = p
    quedan = rom[p - org] * rom[p + 1 - org]
    p += 2
    out = bytearray()
    if quedan == 0:
        return 0, 0, bytes(out), p - ini
    alto, ancho = rom[ini - org], rom[ini + 1 - org]
    while True:
        o = rom[p - org]
        if o >= 0xF0:                       # secuencia ascendente, 2 bytes
            n = o & 0x0F
            v = rom[p + 1 - org]
            while True:
                out.append(v & 0xFF)
                v += 1
                quedan -= 1
                if quedan == 0:
                    return alto, ancho, bytes(out), p + 2 - ini
                n -= 1
                if n == 0:
                    break
            p += 2
        elif o >= 0xE0:                     # N casillas a cero, 1 byte
            n = o & 0x0F
            while True:
                out.append(0)
                quedan -= 1
                if quedan == 0:
                    return alto, ancho, bytes(out), p + 1 - ini
                n -= 1
                if n == 0:
                    break
            p += 1
        else:                               # una casilla suelta
            out.append(o)
            p += 1
            quedan -= 1
            if quedan == 0:
                return alto, ancho, bytes(out), p - ini


def entrada_del_enemigo(rom, p, impar=False, org=ORG):
    """Una entrada de los ocho bloques de 0x6922, tal y como la leen 0x68C8
    (la cabecera) y 0x6829 (los sprites).

    Con el fotograma PAR:

        [dy][dx]           se suman a (0xE152) y (0xE151)
        cuatro sprites     0x80 = vacio y ocupa 1 byte; si no, [y][x][patron]
                           [color]. El CUARTO es de solo [y][x], porque el
                           `ld a,b / cp 1` de 0x6879 sale del bucle antes de
                           leer patron y color.
        figura             la de 0x67A7, o sea figura_a_ceros

    Con el fotograma IMPAR es una REMISION de tres bytes: [dy][word], y la
    word apunta al SEGUNDO byte -el dx- de otra entrada. Lo decide el bit 0
    del indice, en el `bit 0,a / ret z` de 0x677C.

    Devuelve (bytes que ocupa, numero de sprites, alto, ancho).
    """
    if impar:
        return 3, 0, 0, 0
    q = p + 2
    ns = 0
    for k in range(4):
        if rom[q - org] == 0x80:
            q += 1
        else:
            ns += 1
            q += 2 if k == 3 else 4
    alto, ancho, _, n = figura_a_ceros(rom, q, org)
    return q + n - p, ns, alto, ancho


# La fuente de la casa: 0x00 el espacio, 0x10..0x19 las cifras, 0x21..0x3A las
# letras. Se comprueba sola: con ella los rotulos del cartucho salen legibles
# ("SCORE", "PLAY SELECT", "GAME OVER"), y con cualquier otro reparto no.
def texto(bs):
    s = ""
    for c in bs:
        if c == 0x00:
            s += " "
        elif 0x10 <= c <= 0x19:
            s += chr(ord("0") + c - 0x10)
        elif 0x21 <= c <= 0x3A:
            s += chr(ord("A") + c - 0x21)
        else:
            s += "{%02X}" % c
    return s


def main():
    if len(sys.argv) < 4:
        sys.exit(__doc__)
    rom = open(sys.argv[1], "rb").read()
    modo = sys.argv[2]
    for a in sys.argv[3:]:
        d = int(a, 0)
        if modo in ("rle", "rleh"):
            t, n = guion_rle(rom, d, modo == "rle")
        else:
            t, n = guion_literal(rom, d)
        print("0x%04X  %-4s %4d B de ROM, %d tramo(s), %5d B de VRAM; "
              "acaba en 0x%04X" % (d, modo, n, len(t),
                                   sum(len(b) for _, b in t), d + n))
        for v, b in t:
            print("        VRAM %s x%-4d |%s|"
                  % ("0x%04X" % v if v else " (HL)", len(b), texto(b)))


if __name__ == "__main__":
    main()
