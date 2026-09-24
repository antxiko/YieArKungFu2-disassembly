# Vuelca la VRAM de las DOCE pantallas de oleadas de Yie Ar Kung-Fu II.
#
# La demostracion no las ensena nunca -pelea siempre en el modo 3-, asi que
# aqui se arranca una partida de verdad: en cuanto 0x4114 monta el titulo se
# pulsa ESPACIO (fila 8, bit 0 del teclado, que es lo que lee
# lee_las_filas_7_y_8_del_teclado) y el cartucho entra en la escena de
# combate con un jugador.
#
# Para llegar a las doce sin jugarlas se hace lo mismo que en omsx_vram.tcl:
# cambiar un byte de partida justo antes de que el cartucho lo lea.
#   - 0x41D7 llama a prepara_el_marcador, que saca el decorado de
#     (0xE2C0 + ronda) partido por dos: ahi se escribe la ronda a 0 y el
#     escenario 2*decorado.
#   - 0x4FC5 es el `jp elige_el_modo_de_juego` que cierra prepara_el_marcador,
#     y el modo sale de (0xE060), la fase: ahi se escribe la fase que toque
#     (0, 1 o 2; la 3 es el combate).
#   - 0x50D9 es la instruccion que sigue a monta_el_decorado_o_la_oleada: la
#     pantalla ya esta montada. Se vuelca medio segundo despues y otra vez
#     cuatro segundos despues, para ver si el paisaje se mueve o no.
#
# Luego `reset` y a la siguiente. De cada volcado salen vram_oleada_D_F_x.bin
# e info_oleada_D_F_x.txt.

set renderer none
set throttle off

set carpeta "work/oleadas"
file mkdir $carpeta

set combos {}
for {set d 0} {$d < 4} {incr d} {
    for {set f 0} {$f < 3} {incr f} {
        lappend combos [list $d $f]
    }
}
set idx 0
set en_partida 0
set volcado 0

proc vuelca {nombre} {
    global carpeta
    set d [debug read_block VRAM 0 16384]
    set f [open [file join $carpeta "vram_$nombre.bin"] w]
    fconfigure $f -translation binary
    puts -nonewline $f $d
    close $f

    set f [open [file join $carpeta "info_$nombre.txt"] w]
    puts $f "tiempo [machine_info time]"
    puts $f "escena [debug read memory 0xE000]"
    puts $f "subescena [debug read memory 0xE001]"
    puts $f "ronda [debug read memory 0xE066]"
    puts $f "escenario [debug read memory 0xE2C0]"
    puts $f "decorado [debug read memory 0xE2E0]"
    puts $f "fase [debug read memory 0xE060]"
    puts $f "modo [debug read memory 0xE107]"
    puts $f "vidas [debug read memory 0xE055]"
    puts $f "r7 [debug read {VDP regs} 7]"
    close $f
}

proc siguiente {} {
    global idx combos en_partida volcado
    incr idx
    if {$idx >= [llength $combos]} {
        after time 0.5 exit
        return
    }
    set en_partida 0
    set volcado 0
    reset
}

# El titulo acaba de montarse: un segundo despues, ESPACIO.
debug set_bp 0x4114 {} {
    global en_partida
    if {!$en_partida} {
        set en_partida 1
        after time 1.0 {keymatrixdown 8 1}
        after time 1.3 {keymatrixup 8 1}
    }
}

# Arranca la partida: ronda 0 y el escenario del decorado que toque.
debug set_bp 0x41D7 {} {
    global en_partida idx combos
    if {$en_partida} {
        set d [lindex [lindex $combos $idx] 0]
        debug write memory 0xE066 0
        debug write memory 0xE2C0 [expr {2 * $d}]
    }
}

# prepara_el_marcador va a elegir el modo: la fase que toque.
debug set_bp 0x4FC5 {} {
    global en_partida idx combos
    if {$en_partida} {
        set f [lindex [lindex $combos $idx] 1]
        debug write memory 0xE060 $f
    }
}

# La pantalla de la oleada ya esta montada.
debug set_bp 0x50D9 {} {
    global en_partida volcado idx combos
    if {$en_partida && !$volcado} {
        set volcado 1
        set d [lindex [lindex $combos $idx] 0]
        set f [lindex [lindex $combos $idx] 1]
        after time 0.5 "vuelca oleada_${d}_${f}_a"
        after time 4.0 "vuelca oleada_${d}_${f}_b; siguiente"
    }
}

# Red de seguridad: si algo no dispara, que no se quede colgado.
after time 600 exit
