# Sonda: que escena corre en cada segundo, arrancando el cartucho en frio.
#
# No hace falta jugar: la presentacion, el titulo y la demostracion salen solas
# y son deterministas -la demostracion es una partida GRABADA, la tira de
# mandos de 0x57E4 con su 0xFF al final-, asi que dos arranques dan lo mismo.
# Con esto se eligen los instantes en los que volcar la VRAM sin adivinar.
#
# Las variables que se miran, todas medidas sobre el listado:
#   0xE000 la escena       0xE001 la subescena    0xE002 la marca de escena
#   0xE053 la ronda        0xE060 la fase         0xE107 el modo de juego
#   0xE2E0 el decorado     0xE055 las vidas
#
# Se lanza desde el Makefile. Ojo con las trampas de Tcl ya pagadas: nada de
# corchetes dentro de un `format`, y reprogramar el temporizador LO PRIMERO.

set renderer none
set throttle off

set salida [open "work/omsx/sonda.txt" w]
fconfigure $salida -translation binary
set n 0

proc mira {} {
    global salida n
    incr n
    if {$n < 120} { after time 1 mira }
    set e [debug read memory 0xE000]
    set s [debug read memory 0xE001]
    set ronda [debug read memory 0xE053]
    set fase [debug read memory 0xE060]
    set modo [debug read memory 0xE107]
    set deco [debug read memory 0xE2E0]
    set t [machine_info time]
    puts $salida [format "t=%6.2f escena=%3d sub=%3d ronda=%3d fase=%3d modo=%3d decorado=%3d" \
                  $t $e $s $ronda $fase $modo $deco]
    flush $salida
    if {$n >= 120} { close $salida ; exit }
}

after time 1 mira
