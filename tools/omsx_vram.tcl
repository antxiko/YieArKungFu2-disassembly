# Vuelca la VRAM de Yie Ar Kung-Fu II en los instantes que importan.
#
# No hace falta jugar. El cartucho encadena solo presentacion -> titulo ->
# DEMOSTRACION, y la demostracion es una partida GRABADA (la tira de mandos de
# 0x57E4, que acaba en 0xFF), asi que dos arranques dan lo mismo. Los instantes
# salen de tools/omsx_sonda.tcl: la escena 1 -el titulo- vive entre t=12 y t=16
# y la 2 -el combate- entre t=17 y t=40, y luego se repite.
#
# LOS OCHO ESCENARIOS EN UNA SOLA PARTIDA. La demostracion siempre pelea en el
# primero, asi que para ver los otros siete se aprovecha que 0x5776 deja la
# ronda a cero y escribe el escenario en (0xE2C0) tres instrucciones antes de
# montar la pantalla: un punto de interrupcion en 0x5784 -ya escrito el 0- pone
# ahi el que toque, y el cartucho monta ESE decorado, ESE suelo y ESE rival con
# su propio codigo. No se falsea nada: se cambia un byte de partida, como
# haria un jugador llegando a esa ronda.
#
# De cada instante salen dos ficheros: vram_NN.bin con los 16 KB tal cual e
# info_NN.txt con el estado del juego, para poder decir CONTRA QUE se compara.
#
# Trampas de Tcl ya pagadas en esta serie y respetadas aqui: nada de corchetes
# dentro de un `format`, el binario con -translation binary, y `debug
# read_block` en vez de `debug save_to_file`, que no existe.

set renderer none
set throttle off

set carpeta "work/omsx"
set esc 0

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
    close $f
}

# El titulo: escena 1, que la sonda situa entre t=12 y t=16.
after time 14 {vuelca "titulo"}

# Y cada demostracion, con su escenario impuesto. El volcado va seis segundos
# despues de montarse la pantalla: ya esta todo subido y la partida grabada
# lleva un rato corriendo.
debug set_bp 0x5784 {} {
    global esc
    if {$esc < 8} {
        debug write memory 0xE2C0 $esc
        after time 6 "vuelca escenario$esc"
        incr esc
    } else {
        after time 1 exit
    }
}
