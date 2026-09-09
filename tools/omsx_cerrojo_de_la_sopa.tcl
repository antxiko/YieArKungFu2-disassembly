# Coger la LATA del cartucho hermano, reabre la sopa?
#
# La sopa se cierra por ronda: al agotarse, 0x7496 deja (0xE261) = 1 y la escena
# 0 deja de preguntar. Si coger la lata volviera a poner ese byte a cero, la
# sopa saldria otra vez, y entonces "con los dos cartuchos sale mas a menudo"
# seria cierto de rebote. Aqui se fuerza la secuencia entera y se mira el byte.
#
#   1. el sitio de la ronda, encima del jugador -> cae el cuenco
#   2. el cuenco, encima del jugador            -> se lo come, (0xE261) acaba a 1
#   3. el cartucho hermano y las dos barras bajas -> cae la lata
#   4. la lata, encima del jugador              -> se la bebe
#   5. y se mira (0xE261) antes y despues
set renderer none
set throttle off
file mkdir "work/omsx"
set ::s [open "work/omsx/cerrojo.txt" w]
fconfigure $::s -translation binary
set ::movido 0
set ::comido 0
set ::bebida 0
set ::antes -1

debug set_bp 0x7402 {} {
    if {$::movido} return
    set by [debug read memory 0xE12C]
    if {$by == 0} return
    debug write memory 0xE300 [expr {($by - 2) & 0xFF}]
    debug write memory 0xE301 [expr {([debug read memory 0xE12D] - 2) & 0xFF}]
    set ::movido 1
}
debug set_bp 0x7458 {} {
    if {$::comido} return
    set ::comido 1
    debug write memory 0xE250 [debug read memory 0xE112]
    debug write memory 0xE251 [debug read memory 0xE113]
}
debug set_bp 0x7462 {} {
    puts $::s [format "t=%7.2f  SOPA COMIDA, 0xE29E<-0xA8   cerrojo 0xE261=%d" \
        [machine_info time] [debug read memory 0xE261]]
    flush $::s
}
debug set_bp 0x7496 {} {
    puts $::s [format "t=%7.2f  se agota: 0x7496 va a cerrar el cerrojo" [machine_info time]]
    flush $::s
}
# el vecino y las barras, para que salga la lata
debug set_bp 0x74A3 {} {
    debug write memory 0xE450 1
    debug write memory 0xE053 3
    if {[debug read memory 0xE261] == 1} {
        debug write memory 0xE100 8
        debug write memory 0xE102 12
    }
}
debug set_bp 0x7504 {} {
    if {$::bebida} return
    set ::bebida 1
    set ::antes [debug read memory 0xE261]
    debug write memory 0xE254 [debug read memory 0xE112]
    debug write memory 0xE255 [debug read memory 0xE113]
    puts $::s [format "t=%7.2f  LATA al jugador, cerrojo ANTES 0xE261=%d" \
        [machine_info time] $::antes]
    flush $::s
}
debug set_bp 0x7510 {} {
    puts $::s [format "t=%7.2f  LATA BEBIDA,  cerrojo 0xE261=%d" \
        [machine_info time] [debug read memory 0xE261]]
    flush $::s
}
set ::n 0
proc mira {} {
    incr ::n
    if {$::n < 70} { after time 1 mira }
    puts $::s [format "t=%6.2f  0xE261=%d 0xE262=%d 0xE29E=%02X barras=(%02X,%02X)" \
        [machine_info time] [debug read memory 0xE261] [debug read memory 0xE262] \
        [debug read memory 0xE29E] [debug read memory 0xE100] [debug read memory 0xE102]]
    flush $::s
    if {$::n >= 70} { close $::s ; exit }
}
after time 1 mira
