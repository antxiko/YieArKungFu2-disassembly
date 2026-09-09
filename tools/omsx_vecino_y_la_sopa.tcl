# Sale la sopa MAS VECES con el cartucho hermano puesto?
#
# Se pone el sitio de la ronda encima del jugador SIEMPRE que hay caja de golpe
# -o sea, se le quita al jugador la unica parte dificil-, y se cuenta cuantas
# veces el cartucho suelta el cuenco (0x7409) y cuantas concede la
# invulnerabilidad (0x7462) en el mismo tiempo emulado. La demostracion es una
# partida GRABADA, asi que las dos vueltas son la misma partida.
#
# La unica diferencia entre las dos es (0xE450), que es lo unico que el rastreo
# de ranuras deja escrito.
proc opcion {n d} { global env ; if {[info exists env($n)]} { return $env($n) } ; return $d }
set ::VECINO [expr {[opcion Y2_VECINO 0]}]
set ::SEGS   [expr {[opcion Y2_SEGS 90]}]
set renderer none
set throttle off
file mkdir "work/omsx"
set ::salida [open "work/omsx/vecino-$::VECINO.txt" w]
fconfigure $::salida -translation binary
set ::cuencos 0
set ::invul 0
set ::latas 0
set ::preparas 0

# el cartucho hermano, puesto o no, en el unico sitio que lo mira
debug set_bp 0x74A3 {} {
    debug write memory 0xE450 $::VECINO
    debug write memory 0xE053 3
}
# el sitio de la ronda, siempre encima de la caja del golpe del jugador
debug set_bp 0x7402 {} {
    set by [debug read memory 0xE12C]
    if {$by == 0} return
    debug write memory 0xE300 [expr {($by - 2) & 0xFF}]
    debug write memory 0xE301 [expr {([debug read memory 0xE12D] - 2) & 0xFF}]
}
debug set_bp 0x7409 {} { incr ::cuencos }
debug set_bp 0x7462 {} { incr ::invul }
debug set_bp 0x74D4 {} { incr ::latas }
debug set_bp 0x50A3 {} { incr ::preparas }

proc informe {} {
    puts $::salida [format "vecino=%d  %ds emulados" $::VECINO $::SEGS]
    puts $::salida [format "cuencos soltados (0x7409): %d" $::cuencos]
    puts $::salida [format "invulnerabilidades (0x7462): %d" $::invul]
    puts $::salida [format "latas soltadas (0x74D4): %d" $::latas]
    puts $::salida [format "prepara_la_partida (0x50A3): %d" $::preparas]
    puts $::salida [format "cerrojo de la sopa 0xE261=%d, escena 0xE262=%d" \
        [debug read memory 0xE261] [debug read memory 0xE262]]
    flush $::salida
    close $::salida
    exit
}
after time [expr {double($::SEGS)}] informe
