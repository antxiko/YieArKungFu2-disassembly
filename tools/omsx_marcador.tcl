# Que variable es cada cifra del marcador: 0xE053, 0xE055 y 0xE065.
#
# Los comentarios del listado se contradecian -0xE055 salia como "las vidas" en
# 0x4778 y como "una ronda mas" en 0x42FF-, y la demostracion no lo aclara
# porque corre siempre con todo a cero.
#
# Asi que se les mete un valor distinto a cada una y se mira QUE sale pintado.
# El sitio: un punto de interrupcion en 0x57A1, o sea despues de
# `prepara_el_marcador` -que las tocaria- y antes de L_472F, que es quien las
# pinta. Seis segundos despues se leen las casillas de la VRAM.
#
#     0x381C  STAGE     0x383B  REST
#
# La fuente pone las cifras a partir de 0x10, asi que la casilla 0x10+n es el
# digito n.

set renderer none
set throttle off

proc vuelca {} {
    set f [open "work/omsx/marcador.txt" w]
    puts $f "E053 [debug read memory 0xE053]  E055 [debug read memory 0xE055]  E065 [debug read memory 0xE065]"
    puts $f "STAGE en VRAM: [debug read VRAM 0x381C] [debug read VRAM 0x381D]"
    puts $f "REST  en VRAM: [debug read VRAM 0x383B] [debug read VRAM 0x383C]"
    close $f
    exit
}

# 0x53 y 0x67 en BCD: dos cifras que no se pueden confundir con nada.
debug set_bp 0x57A1 {} {
    debug write memory 0xE053 0x53
    debug write memory 0xE055 0x67
    debug write memory 0xE065 0x89
    after time 6 vuelca
}
