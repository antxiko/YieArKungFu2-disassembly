#!/usr/bin/env python3
"""Compara la VRAM que monta tools/vram.py con la del emulador, byte a byte.

Mirar el dibujo no basta. Las imagenes de este repositorio se montan ejecutando
en Python los pasos del cartucho, y la unica forma de saber si los formatos
estan bien leidos es coger la VRAM que el VDP tiene DE VERDAD -volcada con
tools/omsx_vram.tcl mientras la demostracion se juega sola- y restarle la de
Python.

La geometria de este cartucho va al reves de lo normal, y por eso las tablas no
estan donde uno espera (lo dicen los ocho bytes de 0x4963):

    color      0x0000..0x17FF   tres bancos de 0x800
    spr patr   0x1800..0x1FFF   los 64 patrones de sprite
    patrones   0x2000..0x37FF   tres bancos de 0x800
    nombres    0x3800..0x3AFF   que casilla va en cada sitio

Las tres primeras son ESTATICAS: se montan al entrar en la pantalla y no se
tocan hasta que cambia, asi que tienen que salir a CERO. Con dos excepciones
que no son error sino juego, y que por eso se cuentan aparte:

  * los ocho primeros patrones de sprite (0x1800..0x18FF), que son la POSE del
    muneco: `sube_los_patrones_del_fotograma` (0x6BE6) los rehace cada vez que
    cambia de fotograma, siguiendo hasta quince guiones colgados del propio
    fotograma;
  * la tabla de nombres, donde el juego repinta cada cuadro al enemigo, el
    marcador y los rotulos.

Y una trampa que costo la mitad del trabajo: el cartucho **no borra los
patrones ni el color al cambiar de escena**, solo la tabla de nombres. Montar
una pantalla suelta deja cientos de bytes de diferencia que no son un error de
lectura sino herencia que falta, asi que aqui se encadena todo desde el
encendido con vram.como_en_la_demostracion().

Uso: coteja_vram.py <rom> <org> <carpeta de volcados>
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vram as V                                            # noqa: E402

# Lo que tiene que salir a cero, y lo que no.
ESTATICAS = (
    ("color", 0x0000, 0x1800),
    ("spr patr 8-63", 0x1900, 0x0700),
    ("patrones", 0x2000, 0x1800),
)
DINAMICAS = (
    ("la pose del muneco", 0x1800, 0x0100),
    ("los nombres", 0x3800, 0x0300),
)


def lee_info(ruta):
    d = {}
    if not os.path.exists(ruta):
        return d
    for linea in open(ruta, encoding="utf-8"):
        k, _, v = linea.strip().partition(" ")
        d[k] = v
    return d


def distintos(nuestra, suya, ini, n):
    return sum(1 for i in range(n) if nuestra[ini + i] != suya[ini + i])


def cotejo(nuestra, suya, tablas):
    return [(nombre, distintos(nuestra, suya, ini, n), n)
            for nombre, ini, n in tablas]


def main(argv):
    if len(argv) < 4:
        return print(__doc__) or 2
    rom = open(argv[1], "rb").read()
    carpeta = argv[3]

    # El cursor del titulo PARPADEA con el bit 3 de la espera (0x4D22), asi
    # que del volcado puede salir encendido o apagado; se prueban los dos y se
    # dice cual cuadra, que es una medida mas y no una excusa.
    casos = [("titulo", "el titulo",
              V.Vram(rom).arranca_la_pantalla().presentacion()
              .pantalla_del_titulo(cursor=True))]
    casos += [("escenario%d" % e, "el escenario %d" % (e + 1),
               V.como_en_la_demostracion(rom, e)) for e in range(V.ESCENARIOS)]

    total, hechos = 0, 0
    print("%-16s %s" % ("pantalla", "bytes distintos en lo ESTATICO"))
    print("=" * 78)
    for fichero, nombre, nuestra in casos:
        ruta = os.path.join(carpeta, "vram_%s.bin" % fichero)
        if not os.path.exists(ruta):
            print("  %-16s (no hay volcado)" % nombre)
            continue
        suya = open(ruta, "rb").read()
        info = lee_info(os.path.join(carpeta, "info_%s.txt" % fichero))
        if fichero == "titulo":
            otra = (V.Vram(rom).arranca_la_pantalla().presentacion()
                    .pantalla_del_titulo(cursor=False))
            if (distintos(otra.v, suya, 0x3800, 0x300)
                    < distintos(nuestra.v, suya, 0x3800, 0x300)):
                nuestra = otra
        res = cotejo(nuestra.v, suya, ESTATICAS)
        din = cotejo(nuestra.v, suya, DINAMICAS)
        total += sum(d for _, d, _ in res)
        hechos += 1
        print("  %-16s %s" % (nombre, "  ".join(
            "%s %d/%d" % (n, d, t) for n, d, t in res)))
        print("  %-16s (dinamico, no cuenta: %s)" % ("", "  ".join(
            "%s %d/%d" % (n, d, t) for n, d, t in din)))
        print("  %-16s (escena %s.%s, escenario %s, decorado %s, t=%s)"
              % ("", info.get("escena"), info.get("subescena"),
                 info.get("escenario"), info.get("decorado"),
                 info.get("tiempo", "?")[:5]))
    print("-" * 78)
    print("  %d pantallas cotejadas, %d bytes distintos en las tablas"
          " estaticas" % (hechos, total))
    return 0 if total == 0 and hechos else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
