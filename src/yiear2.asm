; ==========================================================================
; YIE AR KUNG-FU II: THE EMPEROR YIE-GAH - Konami - MSX1 - cartucho RC-737 de 32 KB en las paginas 1 y 2
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x04000


; ----------------------------------------------------------------------
; Etiquetas que no caen en ninguna posicion emitida del listado
; (destinos fuera del binario o dentro de una instruccion).
; ----------------------------------------------------------------------
L_70F9:	equ 0x070f9

; ----------------------------------------------------------------------
; DATOS cabecera_del_cartucho: "AB" y la direccion de INIT (0x4070);
;   STATEMENT, DEVICE y TEXT a cero, y los seis bytes reservados tambien
;   0x4000..0x4010  (16 bytes)
DATA_cabecera_del_cartucho:
	defw 04241h,04070h,00000h,00000h,00000h,00000h,00000h,00000h	; 4000

; ----------------------------------------------------------------------
; DATOS cabecera_del_game_master: "AB" 07 37: el 0x07 de los RC-7xx y el 0x37
;   de RC-737
;   0x4010..0x4014  (4 bytes)
DATA_cabecera_del_game_master:
	defb 041h,042h,007h,037h	; 4010

; ----------------------------------------------------------------------
; DATOS punteros_del_game_master: las variables que el Game Master toca:
;   0x6400, 0xE000, 0xE002, 0xE055, 0xE066, 0xE048 y 0xE04E; el reparto de
;   este espacio cambia de un cartucho a otro
;   0x4014..0x4025  (17 bytes)
DATA_punteros_del_game_master:
	defw 06400h,0e000h,0e002h,0e055h,0e066h,0e048h,0e04eh,00000h	; 4014
	defb 004h	; 4024

; ======================================================================
; CODIGO 0x4025..0x40e9  (196 bytes)
; ======================================================================


prepara_el_titulo:
	ld hl,0c9e1h		;4025
	ld (0410dh),hl		;4028
	jp monta_el_cartel		;402b
cada_cuadro:		; El gancho de H.KEYI: el juego ENTERO cuelga de aqui
	call 0013eh		;402e   ; BIOS RDVDP - Reads VDP status register | Leer el estado del VDP: eso limpia la peticion de interrupcion
	di			;4031
	call suena_el_cuadro		;4032   ; Un cuadro de sonido
	ld hl,0e005h		;4035
	bit 0,(hl)		;4038   ; Ya se esta dentro?
	jr nz,L_4049		;403a
	inc (hl)			;403c   ; Marcar que se entra
	ei			;403d
	call lee_los_mandos		;403e   ; Leer los mandos
	call haz_el_cuadro		;4041   ; Y hacer el cuadro
	ld a,000h		;4044
	ld (0e005h),a		;4046
L_4049:
	call 0013eh		;4049   ; BIOS RDVDP - Reads VDP status register
	or a			;404c
	di			;404d
	call m,suena_el_cuadro		;404e
	ei			;4051
	ret			;4052
pon_registro_del_vdp:
	ld hl,00000h		;4053
	ld (04119h),hl		;4056
	jp 00047h		;4059   ; BIOS WRTVDP - Writes data in the VDP-register
suma_a_a_hl:		; HL += A, con el acarreo al alto
	add a,l			;405c
	ld l,a			;405d
	ret nc			;405e
	inc h			;405f
	ret			;4060
suma_a_a_de:		; DE += A, igual
	add a,e			;4061
	ld e,a			;4062
	ret nc			;4063
	inc d			;4064
	ret			;4065
reparte_por_tabla:		; El `pop hl` recoge la tabla: es la direccion de retorno
	pop hl			;4066
reparte_por_tabla_en_hl:		; Con la tabla ya en HL, sin sacarla de la pila
	add a,a			;4067   ; Dos bytes por entrada
	call suma_a_a_hl		;4068   ; Avanzar hasta la que toca
	ld e,(hl)			;406b   ; Leerla
	inc hl			;406c
	ld d,(hl)			;406d
	ex de,hl			;406e
	jp (hl)			;406f   ; Y saltar ahi: el unico salto indirecto del cartucho
INIT:		; Lo que ejecuta la BIOS al encontrar la "AB" de 0x4000
	di			;4070   ; Nada de interrupciones mientras se monta
	im 1		;4071
	call 00138h		;4073   ; BIOS RSLREG - Reads the primary slot register | En que ranura primaria esta este cartucho
	rrca			;4076   ; El dato de la pagina 1 esta en los bits 2 y 3
	rrca			;4077
	and 003h		;4078
	ld c,a			;407a
	ld b,000h		;407b
	ld hl,0fcc1h		;407d   ; La tabla de subranuras de la BIOS
	add hl,bc			;4080
	or (hl)			;4081   ; Juntar ranura y subranura
	ld c,a			;4082
	inc hl			;4083
	inc hl			;4084
	inc hl			;4085
	inc hl			;4086
	ld a,(hl)			;4087   ; Cuatro entradas mas alla, la de la pagina 2
	and 00ch		;4088
	or c			;408a
	ld (0e451h),a		;408b   ; Guardada: hara falta para volver aqui desde otra ranura
	ld h,080h		;408e   ; H = 0x80: la pagina 2
	call 00024h		;4090   ; BIOS ENASLT - Switches to specified slot and page definitively | Conmutar la pagina 2 a esta misma ranura
	call prepara_y_vuelve_a_mi_ranura		;4093   ; Buscar el Yie Ar Kung-Fu I en las otras
	ld a,0c3h		;4096   ; Un `jp` en el gancho de interrupcion...
	ld (0fd9ah),a		;4098
	ld hl,cada_cuadro		;409b   ; ...hacia el bucle de cuadro: de aqui cuelga el juego entero
	ld (0fd9bh),hl		;409e
	ld sp,0e400h		;40a1   ; La pila, en lo alto de la RAM del juego
	ld hl,0e000h		;40a4   ; Y toda la RAM de 0xE000 a cero
	ld de,0e001h		;40a7
	ld bc,003ffh		;40aa
	ld (hl),000h		;40ad
	ldir		;40af
	ld a,001h		;40b1   ; Marca de "arrancando"
	ld (0e005h),a		;40b3
	call arranca_la_pantalla		;40b6   ; Encender la pantalla
	xor a			;40b9
	ld (0e005h),a		;40ba
	call 0013eh		;40bd   ; BIOS RDVDP - Reads VDP status register | Leer el registro de estado para no perder la primera interrupcion
	ei			;40c0
el_bucle_vacio:		; INIT acaba aqui: a partir de este `jr $` todo pasa en la interrupcion
	jr el_bucle_vacio		;40c1
suena_con_pantalla_apagada:
	ld hl,04964h		;40c3   ; El registro de la pantalla
	res 6,(hl)		;40c6   ; Apagarla y pedir la pieza igual
	jp pide_pieza		;40c8
haz_el_cuadro:		; Cuenta el cuadro y reparte la escena que toque
	ld hl,0e003h		;40cb   ; El contador de cuadros
	inc (hl)			;40ce
	ld a,(0e002h)		;40cf   ; El bit 6 de la marca de escena...
	and 040h		;40d2
	ld hl,047afh		;40d4   ; ...elige el remate que no hace nada
	jr nz,L_40DC		;40d7
	ld hl,04358h		;40d9   ; ...o el que lee los mandos
L_40DC:
	ld bc,(0e000h)		;40dc   ; La escena y la subescena
	ld a,c			;40e0
	cp 003h		;40e1   ; En la escena 3 no se remata
	jr z,L_40E6		;40e3
	push hl			;40e5   ; El remate se EMPUJA: la escena volvera por ahi
L_40E6:
	call reparte_por_tabla		;40e6   ; Y a la escena que toque

; ----------------------------------------------------------------------
; DATOS tabla_de_escenas: 8 entradas; reparte segun (0xE000) el arranque, el
;   titulo, el juego y el remate
;   0x40e9..0x40f9  (16 bytes)
DATA_tabla_de_escenas:
	defw 040f9h,04131h,0413eh,0416bh,041c5h,04240h,0425eh,0433ah	; 40e9

; ======================================================================
; CODIGO 0x40f9..0x43ed  (756 bytes)
; ======================================================================


escena_presentacion:
	djnz L_410D		;40f9   ; B es la subescena
	ld a,(0e003h)		;40fb   ; Un cuadro de cada dos
	rra			;40fe
	ret nc			;40ff
	call baja_un_paso		;4100   ; Bajar el rotulo un paso
	ret nz			;4103
	ld de,049f5h		;4104   ; Cuando llega, pintar los rotulos
	call guion_rle		;4107
	xor a			;410a
	jr L_4163		;410b
L_410D:
	djnz L_411B		;410d
	ld hl,0e004h		;410f   ; La espera de la presentacion
	dec (hl)			;4112
	ret nz			;4113
	call monta_la_pantalla_del_titulo		;4114   ; Montar la pantalla del titulo
	xor a			;4117
	jp L_41FB		;4118
L_411B:
	ld a,025h		;411b   ; Callar la musica
	call pide_pieza		;411d
	call borra_lo_apuntado_del_truco		;4120
	call pon_los_registros_del_vdp		;4123   ; Los registros del VDP
	call limpia_la_pantalla		;4126   ; Limpiar la pantalla...
	call monta_la_fuente		;4129   ; ...y subir la fuente
	call arranca_la_presentacion		;412c   ; Y arrancar la presentacion
	jr L_4166		;412f
L_4131:
	call apunta_la_pulsacion_del_truco		;4131   ; Ir apuntando el codigo secreto
	ld hl,0e004h		;4134   ; La espera
	dec (hl)			;4137
	jp nz,L_4D1F		;4138   ; Todavia no: seguir animando
	jp escena_siguiente		;413b   ; Se acabo: a la escena siguiente
L_413E:
	djnz L_4157		;413e
	call lee_la_orden_grabada_de_la_demostracion		;4140   ; Preparar la partida
	call haz_un_cuadro_de_combate		;4143
	ld a,(0e059h)		;4146   ; Hay demostracion en marcha?
	or a			;4149
	ret nz			;414a
L_414B:
	xor a			;414b
L_414C:
	ld (0e000h),a		;414c   ; Escena 0: vuelta a la presentacion
	ld a,020h		;414f   ; Con veinte y pico cuadros de espera
	ld (0e004h),a		;4151
	jp subescena_cero		;4154
L_4157:
	call barre_la_pantalla_desde_la_fila_2		;4157   ; Mirar si hay que empezar
	ret p			;415a   ; Todavia no
	call borra_lo_apuntado_del_truco		;415b
	call monta_la_partida_de_la_demostracion		;415e   ; Montar la pantalla de la partida
	ld a,020h		;4161
L_4163:
	ld (0e004h),a		;4163   ; Dejar la espera que traiga A
L_4166:
	ld hl,0e001h		;4166   ; Y pasar a la subescena siguiente
	inc (hl)			;4169
	ret			;416a
L_416B:
	djnz L_418F		;416b
	ld hl,0e004h		;416d   ; La espera del "PLAY SELECT"
	dec (hl)			;4170
	jr nz,L_417A		;4171
	ld a,020h		;4173   ; Se agoto: otros 0x20 cuadros y a la subescena siguiente
	ld (0e004h),a		;4175
	jr L_4166		;4178
L_417A:
	ld a,(0e002h)		;417a   ; Uno o dos jugadores?
	bit 5,a		;417d
	ld de,04a57h		;417f   ; El rotulo de uno...
	jr z,L_4187		;4182
	ld de,04a61h		;4184   ; ...o el de dos
L_4187:
	bit 2,(hl)		;4187   ; El bit 2 de la espera lo hace parpadear
	jp z,pinta_guion		;4189   ; Pintarlo...
	jp borra_guion		;418c   ; ...o borrarlo
L_418F:
	djnz L_41A7		;418f
	call barre_la_pantalla_desde_la_fila_2		;4191   ; Ha pulsado?
	ret p			;4194   ; Todavia no
	call partida_nueva		;4195   ; Preparar la partida
	call sube_los_sprites_del_muneco		;4198   ; Y subir los sprites del muneco
	ld a,(0e002h)		;419b   ; Con dos jugadores...
	bit 5,a		;419e
	jr z,L_4166		;41a0
	call monta_la_pantalla_de_dos_jugadores		;41a2   ; ...hay que montar ademas la pantalla de presentacion
	jr L_4166		;41a5
L_41A7:
	djnz L_41B5		;41a7
	call toca_demostracion		;41a9   ; Mirar si toca demostracion
	ret z			;41ac   ; No toca
	call pon_la_tira_de_escenarios		;41ad
	call sube_los_sprites_del_muneco		;41b0
	jr escena_siguiente		;41b3
L_41B5:
	ld a,(0e002h)		;41b5   ; Con un jugador...
	bit 5,a		;41b8
	jr nz,L_41C1		;41ba
	ld a,09fh		;41bc   ; ...suena la musica del titulo
	call pide_pieza_si_la_escena_lo_permite		;41be
L_41C1:
	ld a,030h		;41c1   ; Y 0x30 cuadros de espera
	jr L_4163		;41c3
L_41C5:
	djnz L_4207		;41c5
	ld a,(0e012h)		;41c7   ; Esperar a que la musica acabe
	and a			;41ca
	ret nz			;41cb
	ld a,020h		;41cc   ; 0x20 cuadros
	ld (0e004h),a		;41ce
L_41D1:
	call barre_la_pantalla_desde_la_fila_2		;41d1   ; Esperar a que suelte el boton
	jp p,L_41D1		;41d4
	call prepara_el_marcador		;41d7   ; Montar el marcador
	call sube_el_guion_de_sprite_suelto		;41da   ; Y los sprites
	call monta_la_pantalla_de_combate		;41dd   ; La pantalla de combate entera
	call pinta_la_fila_3_y_los_dos_nombres		;41e0   ; Y la fila del decorado
	ld a,001h		;41e3   ; Los dos jugadores, vivos
	ld (0e059h),a		;41e5
	ld (0e069h),a		;41e8
	ld a,(0e107h)		;41eb   ; Segun por que ronda vaya...
	and 003h		;41ee
	cp 003h		;41f0   ; ...suena una musica u otra
	jr z,escena_siguiente		;41f2
	ld a,093h		;41f4
	call pide_pieza_si_la_escena_lo_permite		;41f6
escena_siguiente:		; Deja 0x20 cuadros de espera, sube (0xE000) y pone la subescena a cero
	ld a,020h		;41f9   ; 0x20 cuadros de espera
L_41FB:
	ld (0e004h),a		;41fb
	ld hl,0e000h		;41fe   ; Una escena mas
	inc (hl)			;4201
subescena_cero:
	xor a			;4202   ; Y la subescena, a cero
pon_subescena:
	ld (0e001h),a		;4203
	ret			;4206
L_4207:
	call barre_la_pantalla_desde_la_fila_2		;4207   ; Esperar al boton
	ret p			;420a
	ld hl,0e055h		;420b   ; Las vidas del jugador 1...
	ld a,(hl)			;420e
	sub 001h		;420f   ; ...una menos, en BCD
	daa			;4211
	ld (hl),a			;4212
	ld hl,0e065h		;4213   ; Y las del 2, igual
	ld a,(hl)			;4216
	sub 001h		;4217
	daa			;4219
	ld (hl),a			;421a
	call pinta_el_marcador		;421b   ; Repintar el marcador
	ld de,04a32h		;421e   ; El rotulo de dos jugadores...
	ld a,(0e002h)		;4221
	bit 5,a		;4224
	jr nz,L_422B		;4226   ; ...o el de uno
	ld de,04a2ah		;4228
L_422B:
	call pinta_guion		;422b
	inc l			;422e
	call escribe_el_nivel_donde_diga_hl		;422f   ; Poner el numero de vidas
	ld a,(0e012h)		;4232   ; Si no suena nada...
	and a			;4235
	jr nz,L_423D		;4236
	ld a,09fh		;4238   ; ...arrancar la musica
	call pide_pieza_si_la_escena_lo_permite		;423a
L_423D:
	jp L_4166		;423d
L_4240:
	call el_combate		;4240   ; Repartir por la subescena
	ld hl,0e059h		;4243   ; Los dos jugadores siguen vivos?
	ld a,(0e069h)		;4246
	and (hl)			;4249
	ret nz			;424a   ; Si: seguir jugando
	jr escena_siguiente		;424b
L_424D:
	ld a,(0e058h)		;424d   ; Le queda alguna vida a alguien?
	ld hl,0e068h		;4250
	or (hl)			;4253
	call z,baja_el_nivel_en_bcd		;4254   ; A nadie: fin de la partida
	ld a,0a2h		;4257   ; La musica de "se acabo"
	call pide_pieza_si_la_escena_lo_permite		;4259
	jr escena_siguiente		;425c
L_425E:
	djnz L_4281		;425e
	ld de,04a7ch		;4260   ; El rotulo del final de ronda
	call pinta_guion		;4263
	ld hl,0e055h		;4266   ; Comparar las vidas de los dos...
	ld a,(0e065h)		;4269
	cp (hl)			;426c
	jr c,L_4277		;426d
	ld hl,038f0h		;426f   ; ...y marcar en pantalla al que va ganando
	ld a,012h		;4272
	call 0004dh		;4274   ; BIOS WRTVRM - Writes data in VRAM
L_4277:
	ld a,011h		;4277   ; La musica de ronda superada
	call pide_pieza_si_la_escena_lo_permite		;4279
	ld a,060h		;427c   ; 0x60 cuadros para leerlo
	jp L_4163		;427e
L_4281:
	djnz L_428A		;4281
	ld hl,0e004h		;4283   ; La espera
	dec (hl)			;4286
	ret nz			;4287
	jr L_424D		;4288   ; Se acabo el descanso
L_428A:
	djnz L_4297		;428a
	call haz_un_cuadro_del_final		;428c   ; Animar el paso de ronda
	ld a,(0e17ah)		;428f   ; Ha terminado?
	and a			;4292
	ret z			;4293
	jp L_4335		;4294
L_4297:
	ld a,(0e002h)		;4297   ; Con dos jugadores...
	bit 5,a		;429a
	jr z,L_42C0		;429c
	ld a,(0e059h)		;429e   ; ...mirar cual sigue vivo
	and a			;42a1
	ld hl,0e055h		;42a2   ; Las vidas de uno...
	ld de,0e065h		;42a5   ; ...y las del otro
	jr z,L_42AB		;42a8
	ex de,hl			;42aa   ; Cambiarlos si le toca al segundo
L_42AB:
	ld a,(hl)			;42ab   ; Las vidas del que acaba de perder
	cp 002h		;42ac   ; Le queda mas de una?
	jr c,L_42BC		;42ae
	ex de,hl			;42b0   ; Si: le toca al otro
	ld a,(hl)			;42b1
	add a,001h		;42b2   ; Y a este se le suma una vida, en BCD
	daa			;42b4
	ld (hl),a			;42b5
	call sube_el_nivel_en_bcd		;42b6   ; Subir el marcador
	jp L_4335		;42b9
L_42BC:
	dec (hl)			;42bc   ; Una vida menos y a seguir
	jp L_4166		;42bd
L_42C0:
	ld a,(0e059h)		;42c0   ; Con un jugador: sigue vivo?
	and a			;42c3
	jr nz,L_42DC		;42c4
	ld a,(0e055h)		;42c6   ; Le quedan vidas?
	and a			;42c9
	jr z,L_424D		;42ca   ; No: se acabo
	ld hl,0e061h		;42cc   ; La tanda de la coreografia...
	ld a,(hl)			;42cf
	sub 002h		;42d0   ; ...baja dos, sin pasarse de cero
	jr nc,L_42D5		;42d2
	xor a			;42d4
L_42D5:
	ld (hl),a			;42d5
	call da_una_vida_al_jugador_2		;42d6   ; Y una vida mas
	jp L_4335		;42d9
L_42DC:
	call sube_el_nivel_y_da_una_vida_al_1		;42dc   ; Subir el marcador del que gano
	call da_una_vida_al_jugador_2		;42df   ; Y la vida
	xor a			;42e2   ; Empezar de cero la tanda...
	ld (0e060h),a		;42e3
	ld (0e061h),a		;42e6   ; ...y el paso
	ld a,(0e066h)		;42e9   ; Si la ronda ha vuelto a cero...
	and a			;42ec
	jr nz,L_4335		;42ed
	ld a,003h		;42ef   ; ...toca la subescena 3
	jp pon_subescena		;42f1
sube_el_nivel_y_da_una_vida_al_1:
	call sube_el_nivel_la_ronda_y_la_vuelta		;42f4   ; Subir el marcador del jugador 1
	ld de,0e055h		;42f7
	jr suma_una_vida_en_bcd		;42fa
da_una_vida_al_jugador_2:
	ld de,0e065h		;42fc   ; El del jugador 2
suma_una_vida_en_bcd:
	ld a,(de)			;42ff
	add a,001h		;4300   ; Una VIDA mas, en BCD: 0xE055 y 0xE065 son los contadores de REST, medido metiendoles un valor y mirando que casilla lo pinta
	daa			;4302
	ld (de),a			;4303
	ret			;4304
sube_el_nivel_la_ronda_y_la_vuelta:
	call sube_el_nivel_en_bcd		;4305   ; Subir el nivel
	ret z			;4308   ; No habia que subirlo
	ld hl,0e066h		;4309   ; La ronda...
	ld de,0e06ah		;430c   ; ...y la vuelta
	inc (hl)			;430f
	ld a,(hl)			;4310
	cp 008h		;4311   ; A las ocho rondas...
	ret c			;4313
	xor a			;4314   ; ...vuelta a la primera...
	ld (hl),a			;4315
	ex de,hl			;4316
	ld a,(hl)			;4317
	inc a			;4318   ; ...y una vuelta mas, hasta un maximo de dos
	cp 003h		;4319
	jr c,L_431F		;431b
	ld a,002h		;431d
L_431F:
	ld (hl),a			;431f
	ret			;4320
sube_el_nivel_en_bcd:
	ld hl,0e053h		;4321   ; El nivel, en BCD
	ld a,(hl)			;4324
	add a,001h		;4325
	daa			;4327
	ld (hl),a			;4328
	or 001h		;4329   ; Devolver "no cero"
	ret			;432b
baja_el_nivel_en_bcd:
	ld hl,0e053h		;432c   ; El nivel, uno menos
	ld a,(hl)			;432f
	sub 001h		;4330
	daa			;4332
	ld (hl),a			;4333
	ret			;4334
L_4335:
	ld a,004h		;4335   ; Subescena 4
	jp L_414C		;4337
L_433A:
	djnz L_434B		;433a
	ld a,(0e012h)		;433c   ; Esperar a que calle la musica
	or a			;433f
	ret nz			;4340
	ld hl,0e002h		;4341   ; La marca de escena...
	ld a,(hl)			;4344
	and 0bfh		;4345   ; ...pierde el bit 6: vuelve a leerse el mando
	ld (hl),a			;4347
	jp L_414B		;4348
L_434B:
	call barre_la_pantalla_desde_la_fila_2		;434b   ; Esperar al boton
	ret p			;434e
	ld de,04a6fh		;434f   ; El rotulo de "continuar"
	call pinta_guion		;4352
	jp L_4163		;4355
L_4358:
	ld a,(0e410h)		;4358   ; Con el truco puesto no se lee el mando
	ld de,0e047h		;435b
	ld hl,0e000h		;435e
	and a			;4361
	jr nz,L_4386		;4362
	call lee_mando_y_teclado		;4364   ; El mando y el teclado
	ld d,a			;4367
	call lee_las_filas_7_y_8_del_teclado		;4368   ; Y el segundo mando
	or d			;436b
	ld hl,0e046h		;436c   ; Quedarse solo con lo que se acaba de pulsar
	call guarda_lo_pulsado_y_lo_recien_pulsado		;436f
	or a			;4372
	and 033h		;4373   ; Solo interesan el disparo y algunas teclas
	ret z			;4375
	ld hl,0e004h		;4376   ; Reiniciar la espera
	ld (hl),000h		;4379
	ld l,(hl)			;437b
	ld de,0e047h		;437c
	ld b,(hl)			;437f   ; Que subescena hay?
	djnz L_439B		;4380
	and 030h		;4382   ; Se pulso disparo?
	jr z,L_43A5		;4384
L_4386:
	ld a,(de)			;4386   ; Uno o dos jugadores?
	or a			;4387
	ld a,041h		;4388   ; 0x41: un jugador
	jr z,L_438E		;438a
	ld a,060h		;438c   ; 0x60: dos jugadores
L_438E:
	ld (0e002h),a		;438e   ; La marca de escena
	ld (hl),003h		;4391   ; Subescena 3
	inc hl			;4393
	ld c,000h		;4394
	ld (hl),c			;4396
	dec c			;4397
	jp L_4D29		;4398   ; Y a montar la eleccion
L_439B:
	ld (hl),001h		;439b   ; Subescena 1
	ld a,025h		;439d   ; Callar la musica
	call pide_pieza		;439f
	jp monta_la_pantalla_del_titulo		;43a2   ; Y montar el titulo
L_43A5:
	ld a,(de)			;43a5   ; Cambiar de uno a dos jugadores
	xor 001h		;43a6
	ld (de),a			;43a8
	ret			;43a9
borra_lo_apuntado_del_truco:
	ld hl,0e410h		;43aa   ; Los 0x20 bytes del truco...
	ld de,0e411h		;43ad
	ld bc,00020h		;43b0
	ld (hl),000h		;43b3   ; ...todos a cero
	ldir		;43b5
	ret			;43b7
apunta_la_pulsacion_del_truco:
	ld hl,0e411h		;43b8   ; Cuantas pulsaciones lleva apuntadas
	ld a,(hl)			;43bb
	cp 00ah		;43bc   ; Ya son diez: no se apunta mas
	ret nc			;43be
	ld a,(0e051h)		;43bf   ; La ultima pulsacion
	and 01fh		;43c2   ; Sin pulsar nada no cuenta
	ret z			;43c4
	push af			;43c5
	ld de,0e412h		;43c6   ; La lista de las diez
	ld a,(hl)			;43c9
	call suma_a_a_de		;43ca
	pop af			;43cd
	ld (de),a			;43ce   ; Apuntada
	inc (hl)			;43cf   ; Una mas
	ld a,(hl)			;43d0
	cp 00ah		;43d1   ; Todavia no son diez
	ret nz			;43d3
	ld de,0e412h		;43d4   ; Con diez, comparar contra la secuencia buena
	ld hl,043edh		;43d7
	ld b,00ah		;43da
L_43DC:
	ld a,(de)			;43dc   ; Byte a byte
	cp (hl)			;43dd
	ret nz			;43de   ; A la primera que falle, nada
	inc de			;43df
	inc hl			;43e0
	djnz L_43DC		;43e1
	ld a,001h		;43e3   ; Las diez cuadran: truco puesto
	ld (0e410h),a		;43e5
	xor a			;43e8
	ld (0e047h),a		;43e9   ; Y a un jugador
	ret			;43ec

; ----------------------------------------------------------------------
; DATOS la_secuencia_del_truco: las diez pulsaciones: 01 04 04 02 02 02 08 08
;   08 08
;   0x43ed..0x43f7  (10 bytes)
DATA_la_secuencia_del_truco:
	defb 001h,004h,004h,002h,002h,002h,008h,008h,008h,008h	; 43ed  ..........

; ======================================================================
; CODIGO 0x43f7..0x447b  (132 bytes)
; ======================================================================


toca_demostracion:
	ld a,(0e002h)		;43f7   ; Con dos jugadores no hay demostracion
	bit 5,a		;43fa
	jr nz,L_4401		;43fc
	or 001h		;43fe   ; Devolver "no"
	ret			;4400
L_4401:
	ld ix,0e2c0h		;4401   ; La tira de escenarios por ronda
	ld de,0e051h		;4405   ; Lo que se acaba de pulsar
	ld hl,0e06eh		;4408   ; La opcion en la que esta el cursor
	call mueve_el_cursor_del_menu		;440b   ; Mover el cursor
	call pinta_el_cursor_del_menu		;440e   ; Y repintarlo
	ld a,(0e06fh)		;4411   ; Se ha elegido algo?
	and a			;4414
	ret			;4415
mueve_el_cursor_del_menu:
	ld a,(de)			;4416   ; El mando...
	ld b,a			;4417
	ld a,(0e008h)		;4418   ; ...y el teclado
	or b			;441b
	push af			;441c
	bit 0,a		;441d   ; Arriba?
	jr z,L_4429		;441f
	ld a,(hl)			;4421   ; Una opcion menos...
	sub 001h		;4422
	jr nc,L_4428		;4424
	ld a,002h		;4426   ; ...y de la primera se pasa a la ultima
L_4428:
	ld (hl),a			;4428
L_4429:
	pop af			;4429
	push af			;442a
	bit 1,a		;442b   ; Abajo?
	jr z,L_4437		;442d
	ld a,(hl)			;442f
	inc a			;4430   ; Una opcion mas...
	cp 003h		;4431   ; ...y de la ultima a la primera
	jr c,L_4436		;4433
	xor a			;4435
L_4436:
	ld (hl),a			;4436
L_4437:
	pop af			;4437
	bit 4,a		;4438   ; Disparo?
	ret z			;443a
	ld b,(hl)			;443b   ; La opcion elegida...
	ld (ix+000h),b		;443c   ; ...se guarda como escenario de la primera ronda
	inc hl			;443f
	ld a,001h		;4440   ; Y marca de "elegido"
	ld (hl),a			;4442
	dec hl			;4443
	ret			;4444
pinta_el_cursor_del_menu:
	ld c,(hl)			;4445   ; En que opcion esta el cursor
	ld b,003h		;4446   ; Las tres opciones
	ld hl,038c5h		;4448   ; Donde va la primera
L_444B:
	ld a,c			;444b   ; Es esta la del cursor?
	and a			;444c
	ld a,043h		;444d   ; Si: la casilla del cursor
	jr z,L_4452		;444f
	xor a			;4451   ; No: casilla vacia
L_4452:
	call 0004dh		;4452   ; BIOS WRTVRM - Writes data in VRAM
	ld a,020h		;4455   ; Bajar una fila
	call suma_a_a_hl		;4457
	dec c			;445a
	djnz L_444B		;445b
	ret			;445d
L_445E:
	ld de,0447bh		;445e   ; "LEE YOUNG", el que se maneja
	call pinta_guion		;4461
	ld hl,0e2c0h		;4464   ; La tira de escenarios
	ld de,04487h		;4467   ; Y la tabla de nombres de rival
	ld a,(0e066h)		;446a   ; La ronda...
	call suma_a_a_hl		;446d   ; ...dice que escenario toca
	ex de,hl			;4470
	ld a,(de)			;4471   ; Y el escenario, que rival
	call lee_la_entrada_de_la_tabla		;4472
	ld hl,03885h		;4475   ; Su nombre va en la VRAM 0x3885
	jp L_48C2		;4478   ; Se pinta sin palabra de destino delante

; ----------------------------------------------------------------------
; DATOS rotulo_de_lee_young: un guion literal: "LEE YOUNG" en la VRAM 0x3892,
;   el nombre del que se maneja; 1 guion(es), medidos con tools/formatos.py
;   0x447b..0x4487  (12 bytes)
DATA_rotulo_de_lee_young:
	defb 092h,038h,02ch,025h,025h,000h,039h,02fh,035h,02eh,027h,0ffh	; 447b  .8,%%.9/5.'.

; ----------------------------------------------------------------------
; DATOS tabla_de_los_rivales: ocho punteros; cierra en 0x4497, su primera
;   entrada. 0x4467 la indexa con el escenario de la ronda
;   0x4487..0x4497  (16 bytes)
DATA_tabla_de_los_rivales:
	defw 04497h,0449fh,044a8h,044b0h,044b7h,044c0h,044c9h,044d2h	; 4487

; ----------------------------------------------------------------------
; DATOS nombres_de_los_rivales: los ocho, cada uno cerrado con 0xFF y sin
;   direccion delante: YEN PEI, LAN FANG, PO CHIN, WEN HU, WEI CHIN, MEI LING,
;   HAN CHEN y LI JEN. Las ocho longitudes suman 66 y acaban al byte en 0x44D9
;   0x4497..0x44d9  (66 bytes)
DATA_nombres_de_los_rivales:
	defb 039h,025h,02eh,020h,030h,025h,029h,0ffh	; 4497  9%. 0%).
	defb 02ch,021h,02eh,020h,026h,021h,02eh,027h,0ffh	; 449f  ,!. &!.'.
	defb 030h,02fh,020h,023h,028h,029h,02eh,0ffh	; 44a8  0/ #()..
	defb 037h,025h,02eh,020h,028h,035h,0ffh	; 44b0
	defb 037h,025h,029h,020h,023h,028h,029h,02eh,0ffh	; 44b7  7%) #()..
	defb 02dh,025h,029h,020h,02ch,029h,02eh,027h,0ffh	; 44c0  -%) ,).'.
	defb 028h,021h,02eh,020h,023h,028h,025h,02eh,0ffh	; 44c9  (!. #(%..
	defb 02ch,029h,020h,02ah,025h,02eh,0ffh	; 44d2

; ======================================================================
; CODIGO 0x44d9..0x454a  (113 bytes)
; ======================================================================


pon_la_tira_de_escenarios:
	xor a			;44d9   ; Escenario 0 para empezar
	ld (0e2e0h),a		;44da
	ld a,(0e002h)		;44dd   ; Con dos jugadores no se toca la tira
	bit 5,a		;44e0
	ret nz			;44e2
	xor a			;44e3
	ld hl,0e2c0h		;44e4   ; Los diez escenarios...
	ld b,00ah		;44e7
L_44E9:
	ld (hl),a			;44e9   ; ...en orden, del 0 al 9
	inc hl			;44ea
	inc a			;44eb
	djnz L_44E9		;44ec
	ret			;44ee
monta_la_pantalla_de_dos_jugadores:
	ld de,0454ah		;44ef   ; Los patrones de la presentacion
	ld hl,02200h		;44f2   ; A 0x2200, y L_48AE repite en 0x2A00
	call vuelca_el_guion_en_dos_tercios		;44f5
	ld de,045c9h		;44f8   ; Los colores
	push de			;44fb
	ld hl,00200h		;44fc
	call vuelca_el_guion_en_dos_tercios		;44ff
	pop de			;4502
	push de			;4503   ; Y otras dos veces mas a mano...
	ld hl,00500h		;4504
	call vuelca_el_guion_con_destino_en_hl		;4507
	pop de			;450a
	ld hl,00dc0h		;450b   ; ...en 0x0500 y 0x0DC0, que es donde caera el espejo
	call vuelca_el_guion_con_destino_en_hl		;450e
	call espeja_el_decorado		;4511   ; Espejar los patrones
	ld de,045d2h		;4514   ; El decorado de la presentacion
	call guion_rle		;4517
	ld de,04632h		;451a   ; Su rotulo
	call pinta_guion		;451d
	ld bc,0070ch		;4520   ; En la fila 12, columna 7: el `ld (nn),bc` deja C -la fila- en 0xE170 y B -la columna- en 0xE171
	ld (0e170h),bc		;4523
	ld de,04654h		;4527   ; Y la figura de 4x4
	call pinta_figura_sin_sprites		;452a
	ld bc,0ba57h		;452d   ; La posicion del muneco
	ld (0e112h),bc		;4530
	ld a,001h		;4534
	ld (0e114h),a		;4536   ; Mirando a la derecha
	ld (0e118h),a		;4539
	call monta_al_jugador		;453c   ; Montarlo
	ld a,0e0h		;453f
	ld (0e080h),a		;4541
	call sube_los_cuatro_primeros_sprites		;4544
	jp sube_los_demas_sprites		;4547

; ----------------------------------------------------------------------
; DATOS patrones_de_la_presentacion: un guion RLE de 152 bytes de VRAM que
;   0x44EF suelta en 0x2200, y L_48AE repite en 0x2A00; 1 guion(es), medidos
;   con tools/formatos.py
;   0x454a..0x45c9  (127 bytes)
DATA_patrones_de_la_presentacion:
	defb 003h,000h,082h,007h,00fh,003h,00ch,003h,000h,002h,0ffh,003h,000h,008h,00ch,08ah,008h,00ch,07eh,07fh,07fh,07eh,00ch,008h,00fh,007h,006h,000h,002h,0ffh,006h,000h,090h,01fh,03fh,07fh,077h,07ah,07fh,077h,038h,080h,0c0h,0e0h,060h,0e0h,0e0h,060h,0c0h,009h,000h,083h,003h,007h,007h,004h,00fh,003h,0ffh,08dh,0fch,0f9h,0b9h,07fh,01fh,0f8h,0feh,0feh,01fh,0cfh,0ceh,0cdh,01dh,004h,000h,002h,0b8h,08fh,0f8h,0f0h,00fh,007h,003h,000h,001h,007h,00fh,00fh,06eh,0eeh,0efh,01eh,0feh,003h,0ffh,085h,07dh,07ch,0fch,078h,07fh,003h,0ffh,081h,0e0h,003h,000h,084h,080h,0e0h,0f0h,0f0h,004h,01fh,089h,00fh,006h,00fh,03fh,0ffh,0f0h,0c0h,0c0h,080h,003h,000h,000h	; 454a  ..................~..~............?.wz.w8...`..`........................................n.......}|.x..................?........

; ----------------------------------------------------------------------
; DATOS colores_de_la_presentacion: el mismo tamano en 9 bytes; va a 0x0200 y
;   0x0A00 por L_48AE, y ademas a 0x0500 y a 0x0DC0 a mano, que es lo que pide
;   el espejo de 0x5A4D
;   0x45c9..0x45d2  (9 bytes)
DATA_colores_de_la_presentacion:
	defb 018h,0a0h,008h,0f0h,010h,0a0h,068h,080h,000h	; 45c9  ......h..

; ----------------------------------------------------------------------
; DATOS guion_del_marcador_grande: un solo guion RLE, 161 casillas; lo pinta
;   0x4514 con el destino ya en HL; 1 guion(es), medidos con tools/formatos.py
;   0x45d2..0x4632  (96 bytes)
DATA_guion_del_marcador_grande:
	defb 089h,038h,082h,012h,030h,00ah,000h,082h,011h,030h,00dh,000h,081h,040h,009h,041h,084h,0a0h,000h,000h,040h,009h,041h,081h,0a0h,008h,000h,098h,042h,000h,039h,025h,02eh,020h,030h,025h,029h,000h,0a2h,036h,033h,042h,02ch,025h,025h,020h,039h,010h,035h,02eh,027h,0a2h,008h,000h,08eh,042h,000h,02ch,021h,02eh,020h,026h,021h,02eh,027h,0a2h,000h,000h,044h,009h,045h,081h,0a4h,008h,000h,08bh,042h,000h,030h,02fh,020h,023h,028h,029h,02eh,000h,0bah,015h,000h,081h,044h,009h,045h,081h,0bch,000h	; 45d2  .8..0....0...@.A....@.A.....B.9%. 0%)..63B,%% 9.5.'....B.,!. &!.'...D.E.....B.0/ #()......D.E...

; ----------------------------------------------------------------------
; DATOS rotulo_de_la_presentacion: un guion literal de dos tramos de 14
;   casillas, en 0x3A29 y 0x3A69; lo pinta 0x451A; 1 guion(es), medidos con
;   tools/formatos.py
;   0x4632..0x4654  (34 bytes)
DATA_rotulo_de_la_presentacion:
	defb 029h,03ah,033h,025h,02ch,025h,023h,034h,000h,012h,030h,02ch,021h,039h,025h,032h,0feh,069h,03ah,030h,035h,033h,028h,000h,033h,030h,021h,023h,025h,000h,02bh,025h,039h,0ffh	; 4632  ):3%,%#4..0,!9%2.i:053(.30!#%.+%9.

; ----------------------------------------------------------------------
; DATOS figura_de_la_presentacion: una figura de 4x4 que 0x4527 pinta en
;   (0xE170) = 0x070C; 1 figura(s), medida con tools/formatos.py
;   0x4654..0x465b  (7 bytes)
DATA_figura_de_la_presentacion:
	defb 004h,004h,000h,0fdh,046h,0cah,0c9h	; 4654

; ======================================================================
; CODIGO 0x465b..0x4695  (58 bytes)
; ======================================================================


partida_nueva:		; Pone a cero 0x335 bytes de variables desde 0xE04B
	ld hl,0e04bh		;465b   ; Desde 0xE04B...
	ld bc,00335h		;465e   ; ...0x335 bytes...
	ld d,h			;4661
	ld e,l			;4662
	inc e			;4663
	ld (hl),000h		;4664   ; ...a cero
	ldir		;4666
	ld hl,04695h		;4668   ; Los valores de partida...
	ld de,0e055h		;466b   ; ...a 0xE055
	ld bc,00004h		;466e
	ldir		;4671
	ld a,001h		;4673
	ld (0e053h),a		;4675
	ld a,(0e410h)		;4678
	and a			;467b
	jr z,L_4683		;467c
	ld a,095h		;467e
	ld (0e055h),a		;4680
L_4683:
	ld a,(0e002h)		;4683   ; La marca de escena
	and 020h		;4686   ; Con un jugador no hay nada que copiar
	ret z			;4688
	ld hl,0e055h		;4689   ; Los dieciseis bytes del jugador 1...
	ld de,0e065h		;468c   ; ...al jugador 2
	ld bc,00010h		;468f
	ldir		;4692
	ret			;4694

; ----------------------------------------------------------------------
; DATOS los_valores_de_partida: cuatro bytes que 0x4668 copia a 0xE055: las
;   tres vidas, y detras 0x00, 0x02 y 0x01
;   0x4695..0x4699  (4 bytes)
DATA_los_valores_de_partida:
	defb 003h,000h,002h,001h	; 4695

; ======================================================================
; CODIGO 0x4699..0x485a  (449 bytes)
; ======================================================================


barre_la_pantalla_desde_la_fila_2:
	ld c,040h		;4699   ; Desde la columna 0x40...
	ld b,016h		;469b   ; ...y 22 filas
	jr cortina		;469d
barre_la_pantalla_desde_la_fila_5:
	ld c,0a0h		;469f   ; Desde 0xA0 y 18 filas
	ld b,012h		;46a1
	jr cortina		;46a3
barre_la_pantalla_entera:
	ld c,000h		;46a5   ; Desde 0 y las 24
	ld b,018h		;46a7
cortina:		; Barre la pantalla fila a fila y aparca los sprites en 0x3B00
	ld hl,0e004h		;46a9   ; La cuenta de la cortina
	dec (hl)			;46ac
	ret m			;46ad   ; Ya llego al final
	ld a,(hl)			;46ae
	ld h,038h		;46af
	xor 01fh		;46b1   ; Al reves: la cortina sube
	add a,c			;46b3   ; Sumado el desplazamiento de la banda
	ld l,a			;46b4
	xor a			;46b5
	ld de,00020h		;46b6   ; Bajar una fila son 32 casillas
L_46B9:
	call 0004dh		;46b9   ; BIOS WRTVRM - Writes data in VRAM | Casilla vacia
	add hl,de			;46bc
	djnz L_46B9		;46bd
aparca_los_sprites:
	ld hl,03b00h		;46bf   ; El primer atributo de sprite...
	ld a,0d0h		;46c2   ; ...con 0xD0 en la y aparca todos los demas
	call 0004dh		;46c4   ; BIOS WRTVRM - Writes data in VRAM
	xor a			;46c7
	ret			;46c8
suma_puntos_en_bcd:
	ld e,000h		;46c9   ; DE = lo que se suma
	ld hl,0e04eh		;46cb   ; Los puntos del jugador que juega
	ld c,000h		;46ce
	ld a,(0e002h)		;46d0   ; De quien son los puntos?
	add a,a			;46d3
	ret p			;46d4
	ld a,(hl)			;46d5   ; Las unidades y decenas, en BCD
	add a,e			;46d6
	daa			;46d7
	ld (hl),a			;46d8
	inc l			;46d9
	ld a,(hl)			;46da   ; Las centenas, con el acarreo
	adc a,d			;46db
	daa			;46dc
	ld (hl),a			;46dd
	inc hl			;46de
	ld a,(hl)			;46df   ; Y los millares
	adc a,c			;46e0
	daa			;46e1
	ld (hl),a			;46e2
	jr nc,L_46F2		;46e3   ; Se paso de 999999?
	ld bc,09999h		;46e5   ; Entonces se clava en 999999
	ld (0e048h),bc		;46e8
	ld (0e049h),bc		;46ec
	jr pinta_los_puntos		;46f0
L_46F2:
	ex de,hl			;46f2
	ld hl,0e057h		;46f3   ; El proximo premio
	cp (hl)			;46f6   ; Todavia no llega
	jr c,L_4714		;46f7
	ld a,(hl)			;46f9
	add a,005h		;46fa   ; Subir el liston cinco mil...
	daa			;46fc
	jr nc,L_4701		;46fd
	ld a,0ffh		;46ff   ; ...hasta que no cabe mas
L_4701:
	ld (hl),a			;4701
	push de			;4702
	ld hl,0e055h		;4703   ; Una vida de regalo
	ld a,(hl)			;4706
	add a,001h		;4707
	daa			;4709
	ld (hl),a			;470a
	ld a,010h		;470b   ; Y la musica del premio
	call pide_pieza_si_la_escena_lo_permite		;470d
	call pinta_las_vidas		;4710   ; Repintar las vidas
	pop de			;4713
L_4714:
	ld b,003h		;4714   ; Comparar tres bytes
	ld hl,0e04ah		;4716   ; La mejor marca
	ex de,hl			;4719
	ld c,l			;471a
L_471B:
	ld a,(de)			;471b   ; Byte a byte, del mas alto al mas bajo
	sub (hl)			;471c
	jr c,L_4725		;471d   ; Si es menor, no hay marca nueva
	jr nz,pinta_los_puntos		;471f   ; Si es mayor, ya esta
	dec l			;4721
	dec e			;4722
	djnz L_471B		;4723
L_4725:
	ld l,c			;4725
	ld bc,00003h		;4726   ; Marca nueva: copiar los tres bytes
	ld e,04ah		;4729
	lddr		;472b
	jr pinta_los_puntos		;472d
pinta_el_marcador:
	ld de,04a06h		;472f   ; El armazon del marcador
	call pinta_guion		;4732
	ld a,(0e002h)		;4735   ; Con dos jugadores...
	bit 5,a		;4738
	jr z,L_474E		;473a
	ld hl,03816h		;473c   ; ...ademas el rotulo del segundo
	ld de,04a34h		;473f
	call byte_del_guion		;4742
	ld hl,03836h		;4745   ; Y limpiar cinco casillas
	ld c,005h		;4748
	xor a			;474a
	call rellena_c_bytes_con_filvrm		;474b
L_474E:
	call pinta_el_nivel		;474e   ; Pintar el nivel
	ld a,(0e002h)		;4751   ; Con un jugador...
	bit 5,a		;4754
	jr nz,pinta_los_puntos		;4756
	call pinta_las_vidas		;4758   ; ...pintar tambien las vidas
pinta_los_puntos:		; Los cuatro marcadores, cada uno con su direccion de VRAM
	ld de,0e04ah		;475b   ; Los puntos del jugador 1...
	ld hl,0382dh		;475e   ; ...en la VRAM 0x382D
	call escribe_tres_bytes_de_bcd		;4761
	ld hl,03823h		;4764   ; Los del 2, en 0x3823
	ld de,0e050h		;4767
escribe_tres_bytes_de_bcd:
	ld b,003h		;476a   ; Tres bytes de BCD
	jr L_4780		;476c
pinta_el_nivel:
	ld hl,0381ch		;476e   ; El nivel va en 0x381C
escribe_el_nivel_donde_diga_hl:
	ld de,0e053h		;4771   ; Un solo byte
	ld b,001h		;4774
	jr L_4780		;4776
pinta_las_vidas:
	ld hl,0383bh		;4778   ; Las vidas, en 0x383B
	ld de,0e055h		;477b
	ld b,001h		;477e
L_4780:
	call abre_para_escribir		;4780   ; Preparar el puerto de la VDP
	ld c,000h		;4783   ; C = 0: de momento se comen los ceros
escribe_en_bcd:		; Nibble alto y bajo por separado, +0x10 para caer en los digitos de la fuente; el `ld c,0xFF` come los ceros a la izquierda
	ld a,(de)			;4785   ; El byte de BCD
	rra			;4786   ; El nibble alto...
	rra			;4787
	rra			;4788
	rra			;4789
	and 00fh		;478a
	jr z,L_4790		;478c   ; ...si no es cero, ya no se come ninguno mas
	ld c,0ffh		;478e
L_4790:
	dec b			;4790   ; El ultimo digito se pinta siempre
	jr nz,L_4795		;4791
	ld c,0ffh		;4793
L_4795:
	inc b			;4795
	add a,010h		;4796   ; Los digitos empiezan en la casilla 0x10
	and c			;4798   ; Con C = 0 sale una casilla vacia
	exx			;4799
	out (c),a		;479a   ; Directo al puerto de datos
	exx			;479c
	ld a,(de)			;479d   ; Y ahora el nibble bajo
	and 00fh		;479e
	jr z,L_47A4		;47a0
	ld c,0ffh		;47a2
L_47A4:
	add a,010h		;47a4
	and c			;47a6
	exx			;47a7
	out (c),a		;47a8
	exx			;47aa
	dec de			;47ab   ; Los bytes van del mas alto al mas bajo
	djnz escribe_en_bcd		;47ac
	ret			;47ae
L_47AF:
	ret			;47af
L_47B0:
	ld c,(hl)			;47b0   ; Un byte de aqui...
	ld a,(de)			;47b1
	ld (hl),a			;47b2   ; ...por otro de alli
	ld a,c			;47b3
	ld (de),a			;47b4
	inc hl			;47b5
	inc de			;47b6
	djnz L_47B0		;47b7
	ret			;47b9
copia_los_atributos_del_muneco:
	ld a,(0e107h)		;47ba   ; Que modo de juego es
	and 003h		;47bd
	dec a			;47bf
	ret z			;47c0
	ld hl,0e1e0h		;47c1   ; Copiar el atributo del muneco
	ld de,0e080h		;47c4
	ld bc,00010h		;47c7
	ldir		;47ca
	ld hl,0e1e4h		;47cc   ; Y los tres que le siguen
	ld de,0e084h		;47cf
	call copia_el_sprite_si_no_esta_aparcado		;47d2
	ld hl,0e1e8h		;47d5
	ld de,0e088h		;47d8
	call copia_el_sprite_si_no_esta_aparcado		;47db
	ld hl,0e1ech		;47de
	ld de,0e08ch		;47e1
copia_el_sprite_si_no_esta_aparcado:
	ld a,(hl)			;47e4   ; Este sprite esta aparcado?
	cp 0e0h		;47e5
	ret z			;47e7
	ld a,(0e1e0h)		;47e8   ; La y del muneco...
	sub (hl)			;47eb   ; ...menos la de este
	jr nc,L_47F0		;47ec
	neg		;47ee
L_47F0:
	cp 010h		;47f0   ; A mas de 16 no se solapan
	ret nc			;47f2
	ld a,(0e003h)		;47f3   ; Un cuadro si y otro no...
	rra			;47f6
	ld a,0e0h		;47f7   ; ...se aparca, para que parpadee
	jr c,L_47FD		;47f9
	ld (de),a			;47fb
	ret			;47fc
L_47FD:
	ld (0e080h),a		;47fd
	ret			;4800
sube_los_cuatro_primeros_sprites:
	call aparca_los_sprites_si_el_jugador_no_esta		;4801
	ld hl,03b00h		;4804
	ld de,0e080h		;4807
	ld c,010h		;480a
	jr L_4819		;480c
sube_los_demas_sprites:
	call aparca_los_sprites_si_el_jugador_no_esta		;480e
	ld hl,03b10h		;4811
	ld de,0e090h		;4814
	ld c,070h		;4817
L_4819:
	jp vuelca_c_bytes_con_ldirvm		;4819
aparca_los_sprites_si_el_jugador_no_esta:
	ld a,(0e10bh)		;481c   ; El jugador esta a lo suyo?
	cp 002h		;481f
	ret c			;4821
	ld hl,0e080h		;4822   ; Los 0x1C atributos...
	ld de,0e081h		;4825
	ld (hl),0e0h		;4828   ; ...con 0xE0 en la y: aparcados
	ld bc,0001bh		;482a
	ldir		;482d
	ret			;482f
lee_la_entrada_de_la_tabla:
	add a,a			;4830   ; Dos bytes por entrada
	call suma_a_a_hl		;4831   ; Avanzar hasta la que toca
	ld e,(hl)			;4834   ; Y devolverla en DE
	inc hl			;4835
	ld d,(hl)			;4836
	ret			;4837
pinta_los_contadores_de_vidas:
	ld a,(0e002h)		;4838   ; La marca de escena
	bit 5,a		;483b   ; Con un jugador no hay segundo contador
	ret z			;483d
	ld hl,03855h		;483e   ; El contador del jugador 2...
	ld de,0e065h		;4841   ; ...con sus vidas
	call pinta_un_contador_de_vidas		;4844
	ld hl,0384ah		;4847   ; Y el del 1
	ld de,0e055h		;484a
pinta_un_contador_de_vidas:
	ld a,(de)			;484d   ; Las vidas
	ld de,0485ah		;484e   ; Las dos casillas
	dec a			;4851   ; Le queda mas de una?
	dec a			;4852
	jr nz,L_4856		;4853
	inc de			;4855   ; Si: la otra casilla
L_4856:
	ld a,(de)			;4856   ; La que salga
	jp 0004dh		;4857   ; BIOS WRTVRM - Writes data in VRAM | Y a la VRAM

; ----------------------------------------------------------------------
; DATOS casillas_del_contador_de_vidas: dos: 0x3F si (0xE055) no ha llegado a
;   dos y 0x3E si si; 0x484E elige una y la escribe con WRTVRM
;   0x485a..0x485c  (2 bytes)
DATA_casillas_del_contador_de_vidas:
	defb 03fh,03eh	; 485a

; ======================================================================
; CODIGO 0x485c..0x4963  (263 bytes)
; ======================================================================


limpia_la_pantalla:
	call aparca_los_sprites		;485c
	ld hl,03800h		;485f
	ld bc,00300h		;4862
	xor a			;4865
	jp 00056h		;4866   ; BIOS FILVRM - Fills VRAM with value
abre_para_escribir:
	ex af,af'			;4869
	call 00053h		;486a   ; BIOS SETWRT - Enables VDP to write
	exx			;486d
	ld a,(00007h)		;486e
	ld c,a			;4871
	exx			;4872
	ex af,af'			;4873
	ret			;4874
L_4875:
	call 00050h		;4875   ; BIOS SETRD - Enables VDP to read
	exx			;4878
	ld a,(00006h)		;4879
	ld c,a			;487c
	exx			;487d
	ret			;487e
vuelca_c_bytes_con_ldirvm:
	ld b,000h		;487f
vuelca_con_ldirvm:
	ex de,hl			;4881
	jp 0005ch		;4882   ; BIOS LDIRVM - Block transfers to VRAM from memory
rellena_c_bytes_con_filvrm:
	ld b,000h		;4885
	jp 00056h		;4887   ; BIOS FILVRM - Fills VRAM with value
L_488A:
	exx			;488a
	ld b,003h		;488b
L_488D:
	exx			;488d   ; Guardar la cuenta
	push bc			;488e
	push de			;488f
	call vuelca_con_ldirvm		;4890   ; Volcar
	ld de,00800h		;4893   ; Y subir un tercio
	add hl,de			;4896
	pop de			;4897
	pop bc			;4898
	exx			;4899
	djnz L_488D		;489a   ; Los tres
	ret			;489c
rellena_los_tres_bancos:
	ld d,003h		;489d
L_489F:
	push bc			;489f
	push de			;48a0
	call 00056h		;48a1   ; BIOS FILVRM - Fills VRAM with value
	ld de,00800h		;48a4
	add hl,de			;48a7
	pop de			;48a8
	pop bc			;48a9
	dec d			;48aa
	jr nz,L_489F		;48ab
	ret			;48ad
vuelca_el_guion_en_dos_tercios:
	ld b,002h		;48ae   ; Dos veces: los dos primeros tercios
	jr L_48B4		;48b0
vuelca_el_guion_en_los_tres_tercios:
	ld b,003h		;48b2   ; Tres veces: la pantalla entera
L_48B4:
	push bc			;48b4
	push de			;48b5
	call vuelca_el_guion_con_destino_en_hl		;48b6   ; Volcar el guion
	ld de,00800h		;48b9   ; Y subir un tercio en la VRAM
	add hl,de			;48bc
	pop de			;48bd
	pop bc			;48be
	djnz L_48B4		;48bf
	ret			;48c1
L_48C2:
	ld c,0ffh		;48c2   ; Sin borrar, y SIN leer la palabra de destino
	jr byte_del_guion		;48c4
pinta_guion:
	ld c,0ffh		;48c6   ; C = 0xFF: pintar de verdad
guion_literal:
	ex de,hl			;48c8
	ld e,(hl)			;48c9   ; La palabra de delante es el destino en la VRAM
	inc hl			;48ca
	ld d,(hl)			;48cb
	ex de,hl			;48cc
	inc de			;48cd   ; Y detras van las casillas
byte_del_guion:
	ld a,(de)			;48ce   ; Una casilla
	inc de			;48cf
	ld b,a			;48d0
	inc b			;48d1   ; 0xFF cierra el guion
	ret z			;48d2
	inc b			;48d3
	jr z,guion_literal		;48d4   ; 0xFE abre otro tramo, con su destino delante
	and c			;48d6   ; Con C = 0 sale un cero: eso es borrar
	call 0004dh		;48d7   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;48da
	jr byte_del_guion		;48db
borra_guion:
	ld c,000h		;48dd   ; C = 0: todo lo que se escriba sale vacio
	jr guion_literal		;48df
guion_rle:
	ex de,hl			;48e1
	ld e,(hl)			;48e2   ; El destino, metido en el propio guion
	inc hl			;48e3
	ld d,(hl)			;48e4
	ex de,hl			;48e5
	inc de			;48e6
vuelca_el_guion_con_destino_en_hl:
	call abre_para_escribir		;48e7   ; Aqui el destino ya viene en HL
orden_del_rle:
	ld a,(de)			;48ea   ; Una orden
	and a			;48eb
	ret z			;48ec   ; 0x00 cierra el guion
	inc de			;48ed
	ld b,a			;48ee
	and 07fh		;48ef   ; Quitarle el bit alto...
	cp b			;48f1   ; ...y si no cambia, es una repeticion
	jr z,repite_un_byte		;48f2
	and a			;48f4
	jr z,guion_rle		;48f5   ; El 0x80 pelado abre otro tramo, con otro destino
	ld b,a			;48f7   ; Si no, son B bytes seguidos
L_48F8:
	ld a,(de)			;48f8   ; Uno a uno...
	inc de			;48f9
	exx			;48fa
	out (c),a		;48fb   ; ...directos al puerto de datos
	exx			;48fd
	djnz L_48F8		;48fe
	jr orden_del_rle		;4900
repite_un_byte:
	ld a,(de)			;4902   ; El byte que se repite
	inc de			;4903
L_4904:
	exx			;4904
	out (c),a		;4905   ; B veces al puerto
	exx			;4907
	djnz L_4904		;4908
	jr orden_del_rle		;490a
espeja_sprites:
	call espeja_un_sprite		;490c   ; Espejar un sprite
	ld a,020h		;490f   ; Y saltar al siguiente, 32 bytes mas alla
	call suma_a_a_de		;4911
	dec c			;4914   ; Hasta agotar C
	jr nz,espeja_sprites		;4915
	ret			;4917
espeja_un_sprite:
	push de			;4918
L_4919:
	ld b,010h		;4919   ; Media pareja: 16 filas
L_491B:
	call 0004ah		;491b   ; BIOS RDVRM - Reads the content of VRAM | Leer la fila de la izquierda
	call vuelve_los_bits		;491e   ; Darle la vuelta a los ocho bits
	ex de,hl			;4921
	call 0004dh		;4922   ; BIOS WRTVRM - Writes data in VRAM | Y escribirla a la derecha
	ex de,hl			;4925
	inc e			;4926
	inc hl			;4927
	djnz L_491B		;4928
	ld a,e			;492a   ; Volver 32 bytes atras
	sub 020h		;492b
	ld e,a			;492d
	bit 4,e		;492e   ; Si no se ha cruzado el limite, la otra mitad
	jr z,L_4919		;4930
	pop de			;4932
	ret			;4933
vuelve_los_bits:
	push bc			;4934
	ld c,a			;4935   ; El byte a dar la vuelta
	ld b,008h		;4936   ; Ocho bits
L_4938:
	rr c		;4938   ; Sale por abajo...
	rla			;493a   ; ...y entra por arriba
	djnz L_4938		;493b
	pop bc			;493d
	ret			;493e
arranca_la_pantalla:
	ld a,0b8h		;493f   ; El mezclador del PSG
	call escribe_el_mezclador		;4941
	ld a,025h		;4944   ; Un pitido
	call suena_con_pantalla_apagada		;4946
	xor a			;4949   ; Y toda la VRAM...
	ld h,a			;494a
	ld l,a			;494b
	ld bc,04000h		;494c   ; ...los 16 KB...
	call 00056h		;494f   ; BIOS FILVRM - Fills VRAM with value | ...a cero
pon_los_registros_del_vdp:
	ld hl,04963h		;4952   ; La tabla de ocho registros
	ld d,008h		;4955   ; Del 0 al 7
	ld c,000h		;4957
L_4959:
	ld b,(hl)			;4959   ; El valor
	call 00047h		;495a   ; BIOS WRTVDP - Writes data in the VDP-register | Al registro C
	inc hl			;495d
	inc c			;495e
	dec d			;495f
	jr nz,L_4959		;4960
	ret			;4962

; ----------------------------------------------------------------------
; DATOS registros_del_vdp: los ocho bytes de los registros 0 a 7, en orden
;   0x4963..0x496b  (8 bytes)
DATA_registros_del_vdp:
	defb 002h,0e2h,00eh,07fh,007h,076h,003h,0e4h	; 4963  .....v..

; ======================================================================
; CODIGO 0x496b..0x49f5  (138 bytes)
; ======================================================================


pon_el_color_del_borde:
	ld c,007h		;496b   ; El registro 7, el del borde
	jp pon_registro_del_vdp		;496d
lee_los_mandos:
	call lee_el_mando_y_las_teclas_del_2		;4970   ; Leer el teclado
	call lee_mando_y_teclado		;4973   ; El mando y las teclas
	ld d,a			;4976
	call lee_las_filas_7_y_8_del_teclado		;4977   ; El segundo mando
	or d			;497a
mete_estos_mandos:
	ld hl,0e009h		;497b   ; Donde se guarda lo pulsado
guarda_lo_pulsado_y_lo_recien_pulsado:
	ld c,(hl)			;497e   ; Lo que habia
	ld (hl),a			;497f   ; Guardar lo de ahora
	xor c			;4980   ; Lo que ha cambiado...
	and (hl)			;4981   ; ...y ademas esta pulsado: eso es "recien pulsado"
	dec hl			;4982
	ld (hl),a			;4983   ; Un byte antes queda lo recien pulsado
	ret			;4984
lee_mando_y_teclado:
	ld e,08fh		;4985   ; E = 0x8F: el mando 1
lee_un_mando_del_psg:
	ld a,00fh		;4987   ; El registro 15 del PSG...
	call 00093h		;4989   ; BIOS WRTPSG - Writes data to PSG-register | ...elige que mando se lee
	ld a,00eh		;498c   ; Y el 14 trae el estado
	di			;498e
	call 00096h		;498f   ; BIOS RDPSG - Reads value from PSG-register
	ei			;4992
	cpl			;4993   ; Los bits vienen al reves
	and 03fh		;4994
	ret			;4996
lee_las_filas_7_y_8_del_teclado:
	ld a,007h		;4997   ; La fila 7 del teclado
	call 00141h		;4999   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix
	cpl			;499c   ; Los bits vienen al reves
	rrca			;499d
	and 020h		;499e   ; Quedarse con el que interesa
	ld e,a			;49a0
	ld a,008h		;49a1   ; Y ahora la fila 8
	call 00141h		;49a3   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix
	cpl			;49a6
	rrca			;49a7
	rrca			;49a8
	ld b,a			;49a9
	and 004h		;49aa
	or e			;49ac
	ld c,a			;49ad
	ld a,b			;49ae
	rrca			;49af
	rrca			;49b0
	ld b,a			;49b1
	and 018h		;49b2
	or c			;49b4
	ld c,a			;49b5
	ld a,b			;49b6
	rrca			;49b7
	and 003h		;49b8
	or c			;49ba
	ret			;49bb
lee_el_mando_y_las_teclas_del_2:
	ld e,0cfh		;49bc   ; E = 0xCF: el mando 2
	call lee_un_mando_del_psg		;49be   ; Leerlo
	ld d,a			;49c1
	call lee_las_teclas_del_segundo_jugador		;49c2   ; Y las teclas del segundo
	or d			;49c5
	ld hl,0e052h		;49c6   ; Todo junto en (0xE052)
	jr guarda_lo_pulsado_y_lo_recien_pulsado		;49c9
lee_las_teclas_del_segundo_jugador:
	ld a,006h		;49cb   ; La fila 6
	call 00141h		;49cd   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix
	ld b,a			;49d0
	ld a,003h		;49d1
	call 00141h		;49d3   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix
	ld l,a			;49d6
	rra			;49d7
	rra			;49d8
	push af			;49d9
	push hl			;49da
	rra			;49db
	rra			;49dc
	rl b		;49dd
	ld a,005h		;49df
	call 00141h		;49e1   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix
	rra			;49e4
	rl b		;49e5
	pop hl			;49e7
	ld a,l			;49e8
	rra			;49e9
	rl b		;49ea
	pop af			;49ec
	rra			;49ed
	rl b		;49ee
	ld a,b			;49f0
	cpl			;49f1
	and 01fh		;49f2
	ret			;49f4

; ----------------------------------------------------------------------
; DATOS marco_y_rotulo_software: guion RLE de dos tramos: doce casillas 0x5A
;   de marco en 0x394A y "SOFTWARE" en 0x396C
;   0x49f5..0x4a06  (17 bytes)
DATA_marco_y_rotulo_software:
	defb 04ah,039h,00ch,05ah,080h,06ch,039h,088h,033h,02fh,026h,034h,037h,021h,032h,025h,000h	; 49f5  J9.Z.l9.3/&47!2%.

; ----------------------------------------------------------------------
; DATOS rotulos_del_marcador: cuatro tramos: "HI SCORE", "REST", "STAGE" y
;   "SCORE"
;   0x4a06..0x4a2a  (36 bytes)
DATA_rotulos_del_marcador:
	defb 00ch,038h,028h,029h,020h,033h,023h,02fh,032h,025h,0feh,036h,038h,032h,025h,033h,034h,020h,0feh,016h,038h,033h,034h,021h,027h,025h,020h,0feh,004h,038h,033h,023h,02fh,032h,025h,0ffh	; 4a06  .8() 3#/2%.682%34 ..834!'% ..83#/2%.

; ----------------------------------------------------------------------
; DATOS rotulo_stage: la palabra STAGE en 0x38EC, fila 7
;   0x4a2a..0x4a32  (8 bytes)
DATA_rotulo_stage:
	defb 0ech,038h,033h,034h,021h,027h,025h,0ffh	; 4a2a  .834!'%.

; ----------------------------------------------------------------------
; DATOS rotulo_round: ROUND en la misma casilla que STAGE: el mismo sitio,
;   otra palabra
;   0x4a32..0x4a3a  (8 bytes)
DATA_rotulo_round:
	defb 0ech,038h,032h,02fh,035h,02eh,024h,0ffh	; 4a32  .82/5.$.

; ----------------------------------------------------------------------
; DATOS rotulos_del_titulo: "(c)KONAMI 1985", "PLAY SELECT" y "1PLAYER"; el
;   ano del cartucho lo dice el propio rotulo
;   0x4a3a..0x4a61  (39 bytes)
DATA_rotulos_del_titulo:
	defb 08ah,039h,01ah,02bh,02fh,02eh,021h,02dh,029h,000h,011h,019h,018h,015h,0feh,0ebh,039h,030h,02ch,021h,039h,000h,033h,025h,02ch,025h,023h,034h,0feh,04dh,03ah,011h,030h,02ch,021h,039h,025h,032h,0ffh	; 4a3a  .9.+/.!-).......90,!9.3%,%#4.M:.0,!9%2.

; ----------------------------------------------------------------------
; DATOS rotulo_dos_jugadores: "2PLAYERS", debajo del anterior
;   0x4a61..0x4a6c  (11 bytes)
DATA_rotulo_dos_jugadores:
	defb 08dh,03ah,012h,030h,02ch,021h,039h,025h,032h,033h,0ffh	; 4a61  .:.0,!9%23.

; ----------------------------------------------------------------------
; DATOS guion_vacio: tres bytes: una direccion de VRAM y el 0xFF; no escribe
;   nada
;   0x4a6c..0x4a6f  (3 bytes)
DATA_guion_vacio:
	defb 01bh,01ch,0ffh	; 4a6c

; ----------------------------------------------------------------------
; DATOS rotulo_game_over: "GAME  OVER", con los dos espacios
;   0x4a6f..0x4a7c  (13 bytes)
DATA_rotulo_game_over:
	defb 0ebh,038h,027h,021h,02dh,025h,000h,000h,02fh,036h,025h,032h,0ffh	; 4a6f  .8'!-%../6%2.

; ----------------------------------------------------------------------
; DATOS rotulo_gana_el_jugador: "PLAYER 1  WIN!"; el 1 se sobrescribe con el
;   numero del que gana
;   0x4a7c..0x4a8d  (17 bytes)
DATA_rotulo_gana_el_jugador:
	defb 0e9h,038h,030h,02ch,021h,039h,025h,032h,000h,011h,000h,000h,037h,029h,02eh,03bh,0ffh	; 4a7c  .80,!9%2....7).;.

; ======================================================================
; CODIGO 0x4a8d..0x4ac5  (56 bytes)
; ======================================================================


monta_la_fuente:
	call limpia_la_fuente		;4a8d   ; Limpiar la fuente
	ld de,04ac5h		;4a90   ; Los patrones de la fuente...
	ld hl,02080h		;4a93   ; ...a 0x2080, y L_48B2 los repite en los tres tercios
	call vuelca_el_guion_en_los_tres_tercios		;4a96
	ld a,0f0h		;4a99   ; Color 0xF0
	ld hl,00080h		;4a9b   ; Desde 0x0080...
	ld bc,00160h		;4a9e   ; ...0x160 bytes
	jp rellena_los_tres_bancos		;4aa1
limpia_la_fuente:
	ld hl,02000h		;4aa4   ; El primer patron
	ld bc,00080h		;4aa7   ; 0x80 bytes
	xor a			;4aaa
	call rellena_los_tres_bancos		;4aab   ; A cero
	ld hl,00000h		;4aae   ; La casilla 0
	ld de,00008h		;4ab1   ; Ocho bytes por casilla
	ld b,010h		;4ab4   ; Dieciseis casillas
L_4AB6:
	push bc			;4ab6
	ld bc,00008h		;4ab7   ; Ocho bytes
	push hl			;4aba
	call rellena_los_tres_bancos		;4abb   ; Cada una de un color
	pop hl			;4abe
	add hl,de			;4abf   ; La casilla siguiente
	inc a			;4ac0   ; Y el color siguiente
	pop bc			;4ac1
	djnz L_4AB6		;4ac2
	ret			;4ac4

; ----------------------------------------------------------------------
; DATOS patrones_de_la_fuente: un guion RLE de 313 B que `monta_la_fuente`
;   (0x4A90) vuelca en 0x2080, o sea en la tabla de PATRONES: en este cartucho
;   los bancos van al reves; 1 guion(es), medidos con tools/formatos.py
;   0x4ac5..0x4bfe  (313 bytes)
DATA_patrones_de_la_fuente:
	defb 08ah,01ch,022h,063h,063h,063h,022h,01ch,000h,018h,038h,004h,018h,0c2h,07eh,000h,03eh,063h,003h,00eh,03ch,070h,07fh,000h,03eh,063h,003h,00eh,003h,063h,03eh,000h,00eh,01eh,036h,066h,066h,07fh,006h,000h,07fh,060h,07eh,063h,003h,063h,03eh,000h,03eh,063h,060h,07eh,063h,063h,03eh,000h,07fh,063h,006h,00ch,018h,018h,018h,000h,03eh,063h,063h,03eh,063h,063h,03eh,000h,03eh,063h,063h,03fh,003h,063h,03eh,000h,08bh,03ch,042h,099h,0a1h,0a1h,099h,042h,03ch,000h,00fh,01fh,004h,0ffh,089h,00fh,000h,000h,0feh,0e0h,0e0h,0c0h,0c0h,080h,018h,000h,003h,000h,001h,07eh,004h,000h,0c1h,01ch,036h,063h,063h,07fh,063h,063h,000h,07eh,063h,063h,07eh,063h,063h,07eh,000h,03eh,063h,060h,060h,060h,063h,03eh,000h,07ch,066h,063h,063h,063h,066h,07ch,000h,07fh,060h,060h,07eh,060h,060h,07fh,000h,07fh,060h,060h,07eh,060h,060h,060h,000h,03eh,063h,060h,067h,063h,063h,03fh,000h,063h,063h,063h,07fh,063h,063h,063h,000h,03ch,005h,018h,083h,03ch,000h,01fh,004h,006h,08bh,066h,03ch,000h,063h,066h,06ch,078h,07ch,06eh,067h,000h,006h,060h,093h,07fh,000h,063h,077h,07fh,07fh,06bh,063h,063h,000h,063h,073h,07bh,07fh,06fh,067h,063h,000h,03eh,005h,063h,0a3h,03eh,000h,07eh,063h,063h,063h,07eh,060h,060h,000h,03eh,063h,063h,063h,06fh,066h,03dh,000h,07eh,063h,063h,062h,07ch,066h,063h,000h,03eh,063h,060h,03eh,003h,063h,03eh,000h,07eh,006h,018h,001h,000h,006h,063h,082h,03eh,000h,004h,063h,0a4h,036h,01ch,008h,000h,063h,063h,06bh,06bh,07fh,077h,022h,000h,063h,076h,03ch,01ch,01eh,037h,063h,000h,066h,066h,07eh,03ch,018h,018h,018h,000h,07fh,007h,00eh,01ch,038h,070h,07fh,000h,005h,018h,083h,000h,018h,000h,000h	; 4ac5  .."ccc"...8...~.>c..<p..>c...c>...6ff....`~c.c>.>c`~cc>..c......>cc>cc>.>cc?.c>..<B....B<....................~....6cc.cc.~cc~cc~.>c```c>.|fcccf|..``~``...``~```.>c`gcc?.ccc.ccc.<...<.....f<.cflx|ng..`...cw..kcc.cs{.ogc.>.c.>.~ccc~``.>cccof=.~ccb|fc.>c`>.c>.~.....c.>..c.6...cckk.w".cv<..7c.ff~<........8p.........

; ======================================================================
; CODIGO 0x4bfe..0x4c52  (84 bytes)
; ======================================================================


arranca_la_presentacion:
	ld a,00eh		;4bfe
	ld (0e00ah),a		;4c00
	ld hl,03aaah		;4c03
	ld (0e00eh),hl		;4c06
	jp prepara_el_titulo		;4c09
monta_el_cartel:
	ld de,04c52h		;4c0c   ; Los patrones del cartel...
	ld hl,02200h		;4c0f   ; ...a 0x2200, repetidos en los tres tercios
	call vuelca_el_guion_en_los_tres_tercios		;4c12
	ld hl,00200h		;4c15   ; Y su color, desde 0x0200
	ld bc,000d8h		;4c18
	ld a,0f0h		;4c1b
	jp rellena_los_tres_bancos		;4c1d
baja_un_paso:
	ld hl,(0e00eh)		;4c20   ; Por donde va el rotulo
	ld de,0ffe0h		;4c23   ; Menos 0x20: baja una fila
	add hl,de			;4c26
	ld (0e00eh),hl		;4c27
	ld a,040h		;4c2a   ; La casilla del rotulo
	ld b,003h		;4c2c   ; Tres seguidas
	call escribe_seguidas_subiendo		;4c2e
	ld bc,00b0ch		;4c31   ; Y luego doce
	call escribe_seguidas_subiendo		;4c34
	ld b,c			;4c37
	call escribe_seguidas_subiendo		;4c38
	xor a			;4c3b
	call 00056h		;4c3c   ; BIOS FILVRM - Fills VRAM with value
	ld hl,0e00ah		;4c3f
	dec (hl)			;4c42
	ret			;4c43
escribe_seguidas_subiendo:
	push hl			;4c44
L_4C45:
	call 0004dh		;4c45   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;4c48
	inc a			;4c49
	djnz L_4C45		;4c4a
	pop de			;4c4c
	ld hl,00020h		;4c4d
	add hl,de			;4c50
	ret			;4c51

; ----------------------------------------------------------------------
; DATOS guion_del_cartel: un guion RLE; lo pinta `monta_el_cartel` (0x4C0C); 1
;   guion(es), medidos con tools/formatos.py
;   0x4c52..0x4ce9  (151 bytes)
DATA_guion_del_cartel:
	defb 00fh,000h,001h,001h,006h,000h,082h,0ffh,0feh,008h,00fh,084h,0c3h,0c7h,0cfh,0dfh,003h,0ffh,089h,0feh,0fch,0f8h,0f0h,0e0h,0c0h,080h,007h,007h,005h,000h,083h,003h,0cfh,0dfh,005h,000h,083h,0e1h,0f9h,07dh,005h,000h,083h,0efh,0ffh,0f7h,005h,000h,083h,007h,08fh,09eh,005h,000h,083h,0f0h,0f8h,078h,005h,000h,083h,0f7h,0ffh,0fbh,005h,000h,08bh,08fh,0dfh,0f7h,00ch,01eh,01eh,00ch,000h,01eh,09eh,09eh,008h,00fh,090h,0ffh,0ffh,0dfh,0cfh,0c7h,0c3h,0c1h,0c0h,007h,087h,0c7h,0efh,0ffh,0ffh,0ffh,0fch,004h,0deh,084h,09eh,09fh,00fh,003h,005h,03dh,083h,07dh,0f9h,0e1h,008h,0e3h,090h,0dch,0c0h,0c7h,0deh,0dch,0deh,0cfh,0c3h,03ch,07ch,0fch,03ch,03ch,07ch,0fch,0deh,008h,0f1h,008h,0e3h,008h,0deh,088h,038h,044h,0bah,0aah,0b2h,0aah,044h,038h,003h,000h,001h,0ffh,004h,000h,000h	; 4c52  .......................................}.................x...............................................=.}.............<|.<<|.........8D....D8.......

; ======================================================================
; CODIGO 0x4ce9..0x4d43  (90 bytes)
; ======================================================================


monta_el_titulo:
	ld b,0e0h		;4ce9   ; El borde, negro
	call pon_el_color_del_borde		;4ceb
	call limpia_la_pantalla		;4cee   ; Limpiar la pantalla
	call monta_la_fuente		;4cf1   ; Y subir la fuente
	ld de,04d43h		;4cf4   ; Los patrones del logotipo...
	ld hl,02400h		;4cf7   ; ...a 0x2400, y L_48AE los repite en 0x2C00
	call vuelca_el_guion_en_dos_tercios		;4cfa
	ld de,04f4eh		;4cfd   ; Y su color, a 0x0400 y 0x0C00
	ld hl,00400h		;4d00
	jp vuelca_el_guion_en_dos_tercios		;4d03
monta_la_pantalla_del_titulo:
	call monta_el_titulo		;4d06   ; Montar el titulo
	ld bc,00704h		;4d09   ; Fila 4, columna 7: C va a 0xE170 -la fila- y B a 0xE171 -la columna-, y 0x66FB baja una menos, asi que aterriza en la fila 3
	ld (0e170h),bc		;4d0c
	ld de,04f5fh		;4d10   ; La figura del logotipo
	call pinta_figura_sin_sprites		;4d13
	ld de,04a3ah		;4d16   ; Y los dos rotulos de debajo
	call pinta_guion		;4d19
	jp pinta_guion		;4d1c
L_4D1F:
	ld hl,0e004h		;4d1f
	bit 3,(hl)		;4d22
	ld c,0ffh		;4d24
	jr nz,L_4D29		;4d26
	inc c			;4d28
L_4D29:
	ld hl,03a4ah		;4d29   ; La casilla del cursor de un jugador...
	ld de,03a8ah		;4d2c   ; ...y la de dos
	ld a,(0e047h)		;4d2f   ; Cual esta elegido
	or a			;4d32
	jr z,L_4D36		;4d33
	ex de,hl			;4d35   ; Cambiarlas si toca
L_4D36:
	push de			;4d36
	call pinta_el_cursor_donde_diga_hl		;4d37
	pop hl			;4d3a
	ld c,000h		;4d3b
pinta_el_cursor_donde_diga_hl:
	ld de,04a6ch		;4d3d
	jp byte_del_guion		;4d40

; ----------------------------------------------------------------------
; DATOS patrones_del_logotipo: un guion RLE de 544 bytes de VRAM -68
;   patrones-; 0x4CF4 lo suelta en 0x2400 y L_48AE lo repite en 0x2C00; 1
;   guion(es), medidos con tools/formatos.py
;   0x4d43..0x4f4e  (523 bytes)
DATA_patrones_del_logotipo:
	defb 098h,000h,048h,0c9h,0d8h,071h,033h,066h,0c4h,000h,080h,080h,010h,028h,070h,040h,030h,000h,008h,01ch,034h,024h,0fdh,049h,049h,003h,000h,0a2h,080h,0e1h,081h,003h,002h,000h,049h,0dbh,0b2h,0e6h,0c4h,066h,023h,000h,022h,026h,066h,06eh,0cbh,0dbh,091h,000h,047h,049h,0d8h,097h,0b2h,036h,01ch,000h,000h,080h,019h,026h,004h,000h,091h,01eh,018h,030h,07dh,021h,061h,040h,000h,048h,0c8h,098h,098h,030h,0b0h,0e0h,000h,07fh,005h,036h,0d1h,07fh,000h,000h,0ffh,000h,000h,0beh,0a2h,0aah,000h,000h,0ffh,000h,000h,0fbh,08ah,0aah,0bah,082h,0feh,000h,000h,0ffh,000h,000h,0bah,082h,0feh,000h,000h,0ffh,000h,030h,0bah,082h,0feh,000h,000h,0ffh,000h,0c0h,000h,000h,014h,00eh,00ch,001h,000h,000h,020h,018h,088h,001h,097h,05fh,03fh,03fh,000h,001h,012h,040h,068h,0fch,0fch,0fah,07fh,03fh,0ffh,07fh,03fh,03fh,09fh,01fh,0feh,0fch,0feh,0fch,0f8h,0fch,0fch,0f2h,005h,000h,096h,001h,007h,01fh,00fh,01fh,03eh,07ch,0f8h,0f0h,0e0h,0e0h,08ah,010h,002h,020h,000h,000h,008h,000h,0b0h,050h,000h,003h,00fh,002h,000h,083h,073h,071h,070h,003h,0ffh,002h,0e1h,083h,060h,0b0h,000h,005h,0c0h,002h,000h,002h,007h,0c1h,006h,007h,006h,007h,03ch,078h,0ffh,0ffh,001h,0ffh,001h,0ffh,000h,00fh,08fh,081h,081h,09fh,09fh,09ch,038h,0ffh,0ffh,0c7h,0c7h,0ffh,0ffh,038h,000h,0e0h,0e0h,001h,003h,0f3h,0f7h,077h,000h,03fh,0ffh,0ffh,0ceh,08eh,00eh,01ch,000h,083h,0e1h,0f0h,070h,038h,03bh,03bh,08eh,0c7h,0ffh,09fh,001h,019h,0d9h,0d9h,039h,070h,0fdh,0fch,0c0h,003h,0cch,093h,0feh,0cch,0feh,000h,0fch,0cch,0fch,0cch,0feh,0c0h,0feh,03eh,0c0h,0fch,0feh,0c0h,0ffh,07dh,031h,005h,001h,003h,0e3h,005h,0e0h,003h,0ffh,005h,000h,090h,0e0h,0e1h,0e1h,003h,007h,01fh,00eh,004h,0e1h,0c1h,0c1h,083h,0a3h,03fh,03fh,01fh,003h,0c7h,002h,0c0h,002h,080h,09ch,000h,0c0h,0cfh,0cfh,000h,007h,000h,01fh,01fh,000h,0ffh,0ffh,078h,0ffh,078h,0ffh,0ffh,01ch,0dfh,0c7h,007h,087h,007h,0e7h,0e0h,038h,0ffh,0ffh,004h,039h,0bch,038h,076h,0f6h,0c6h,0c7h,0c3h,0c3h,0c1h,000h,01ch,01ch,038h,078h,0f0h,0e7h,0c3h,003h,03bh,038h,038h,078h,0f1h,0f7h,0e3h,081h,0dfh,0dfh,0c1h,0cfh,0c7h,0e6h,0bfh,01fh,0fch,0fch,0c0h,0c1h,080h,001h,0feh,0fch,0fch,0cch,003h,0ffh,03dh,0f9h,07eh,0f8h,0feh,07fh,080h,0ffh,09ch,0f8h,0ffh,03eh,000h,000h,0f8h,005h,020h,002h,000h,002h,088h,081h,0f8h,003h,088h,002h,000h,0a1h,0f8h,080h,0f0h,080h,080h,0f8h,000h,000h,088h,0d8h,0f8h,0a8h,088h,088h,000h,000h,0f0h,088h,088h,0f0h,080h,080h,000h,000h,0f0h,088h,088h,0f0h,090h,088h,000h,000h,070h,004h,088h,086h,070h,000h,000h,088h,088h,070h,003h,020h,002h,000h,081h,070h,004h,020h,09eh,070h,000h,000h,0f8h,080h,0f0h,083h,080h,0f8h,000h,000h,00fh,010h,010h,093h,011h,00fh,000h,000h,00eh,011h,011h,01fh,011h,011h,000h,000h,011h,011h,01fh,003h,011h,000h	; 4d43  ..H..q3f.....(p@0...4$.II.........I....f#."&fn....GI...6.....&.....0}!a@.H...0.....6.................................0................ ...._??...@h....?..??..................>|....... .....P......sqp.....`.............<x..............8......8.......w.?..........p8;;........9p.................>.....}1........................??....................x.x..........8...9.8v.........8x....;88x........................=.~........>.... ...........................................p...p....p. ...p. .p................................

; ----------------------------------------------------------------------
; DATOS colores_del_logotipo: el mismo tamano de VRAM en 17 bytes, que es lo
;   que se comprime un color plano; 0x4CFD lo suelta en 0x0400 y 0x0C00
;   0x4f4e..0x4f5f  (17 bytes)
DATA_colores_del_logotipo:
	defb 058h,0f0h,01fh,0a0h,081h,080h,007h,0a0h,07fh,080h,07fh,080h,07fh,080h,024h,080h,000h	; 4f4e  X.............$..

; ----------------------------------------------------------------------
; DATOS casillas_del_logotipo: la figura de 7x18 que coloca esos patrones en
;   la pantalla; 0x4D10 la pinta con L_675D en (0xE170) = 0x0704, o sea fila 7
;   y columna 4; 1 figura(s), medida con tools/formatos.py
;   0x4f5f..0x4f99  (58 bytes)
DATA_casillas_del_logotipo:
	defb 007h,012h,0e4h,000h,0fbh,080h,0e4h,000h,090h,0efh,000h,000h,08bh,08ch,091h,092h,08bh,08ch,08bh,08ch,08bh,08ch,08bh,08ch,08bh,08ch,08bh,08ch,08bh,08ch,08dh,08dh,093h,094h,0ech,08dh,08eh,08fh,0f6h,095h,000h,0ffh,09bh,0aah,0abh,0a8h,0feh,0ach,000h,0f3h,0b9h,0b9h,0bch,0bdh,0bch,000h,0f6h,0beh	; 4f5f  ..........................................................

; ======================================================================
; CODIGO 0x4f99..0x5056  (189 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ---------------------------------------------------------------------
; Preparar el marcador antes de una ronda.
; ----------------------------------------------------------------------
prepara_el_marcador:
	ld hl,0e100h		;4f99   ; Los diez bytes del marcador...
	ld de,0e101h		;4f9c
	ld bc,0000ah		;4f9f
	ld (hl),000h		;4fa2   ; ...a cero
	ldir		;4fa4
	ld a,024h		;4fa6   ; La casilla vacia del marcador
	ld hl,0e100h		;4fa8
	ld b,004h		;4fab   ; Las cuatro primeras
L_4FAD:
	ld (hl),a			;4fad
	inc hl			;4fae
	djnz L_4FAD		;4faf
	call el_escenario_de_la_ronda		;4fb1   ; El escenario de esta ronda
	srl a		;4fb4   ; Partido por dos: cada decorado sirve para dos escenarios
	ld (0e2e0h),a		;4fb6   ; Ese es el decorado
	ld a,(0e002h)		;4fb9   ; Con dos jugadores...
	bit 5,a		;4fbc
	jr z,L_4FC5		;4fbe
	ld a,003h		;4fc0   ; ...el modo de juego es el 3
	ld (0e060h),a		;4fc2
L_4FC5:
	jp elige_el_modo_de_juego		;4fc5   ; Y pasarlo a (0xE107)

; ----------------------------------------------------------------------
; ---------------------------------------------------------------------
; Partida nueva: se borra toda la RAM del combate y se colocan los dos
; munecos en su sitio de salida.
; ----------------------------------------------------------------------
prepara_la_partida:
	ld hl,0e10bh		;4fc8   ; De 0xE10B en adelante...
	ld de,0e10ch		;4fcb
	ld bc,00194h		;4fce   ; ...0x194 bytes...
	ld (hl),000h		;4fd1   ; ...a cero
	ldir		;4fd3
	ld bc,0d087h		;4fd5   ; El jugador arranca en 0x87, 0xD0
	ld (0e112h),bc		;4fd8
	ld bc,00411h		;4fdc   ; Y el enemigo en 0x11, 0x04
	ld (0e132h),bc		;4fdf
	ld (0e151h),bc		;4fe3   ; Que es tambien su posicion "vieja"
	ld a,018h		;4fe7   ; 0x18 cuadros de espera
	ld (0e154h),a		;4fe9
	xor a			;4fec
	ld (0e003h),a		;4fed   ; El contador de cuadros, a cero
	inc a			;4ff0
	ld (0e114h),a		;4ff1   ; Los dos mirando al mismo lado...
	ld (0e118h),a		;4ff4   ; ...y los dos en el fotograma 1
	ld (0e138h),a		;4ff7
	ld (0e153h),a		;4ffa
	ld a,(0e06ah)		;4ffd   ; Que vuelta es
	ld hl,05056h		;5000   ; Los ajustes de esa vuelta...
	call lee_la_entrada_de_la_tabla		;5003
	ex de,hl			;5006
	ld de,0e160h		;5007   ; ...los diez bytes van a 0xE160
	ld bc,0000ah		;500a
	ldir		;500d
	ld hl,0e080h		;500f   ; Los 0x80 bytes de atributos de sprite...
	ld a,0e0h		;5012   ; ...con 0xE0 en la y: aparcados
	ld b,080h		;5014
L_5016:
	ld (hl),a			;5016
	inc hl			;5017
	djnz L_5016		;5018
	ld hl,0e1e0h		;501a   ; Y los 16 de la copia de al lado, igual
	ld b,010h		;501d
L_501F:
	ld (hl),a			;501f
	inc hl			;5020
	djnz L_501F		;5021
	ld a,(0e066h)		;5023   ; La ronda
	add a,a			;5026
	ld hl,0507ah		;5027   ; Sus dos bytes...
	ld de,0e300h		;502a   ; ...a 0xE300
	call suma_a_a_hl		;502d
	ld a,(hl)			;5030
	ld (de),a			;5031
	inc hl			;5032
	inc de			;5033
	ld a,(hl)			;5034
	ld (de),a			;5035
	call elige_el_modo_de_juego		;5036   ; Poner el modo de juego
	and 003h		;5039   ; Es el modo 3?
	cp 003h		;503b
	ld a,001h		;503d
	jr nz,L_5044		;503f
	ld (0e187h),a		;5041   ; Entonces hay que marcar esto
L_5044:
	ld (0e159h),a		;5044   ; Y el jugador 1 empieza vivo
	ret			;5047
elige_el_modo_de_juego:
	ld de,0508ah		;5048   ; Los cuatro modos
	ld a,(0e060h)		;504b   ; El que este elegido
	call suma_a_a_de		;504e
	ld a,(de)			;5051
	ld (0e107h),a		;5052   ; Queda en (0xE107)
	ret			;5055

; ----------------------------------------------------------------------
; DATOS tabla_de_los_ajustes: tres punteros; cierra en 0x505C, su entrada mas
;   baja
;   0x5056..0x505c  (6 bytes)
DATA_tabla_de_los_ajustes:
	defw 0505ch,05066h,05070h	; 5056  -> DATA_ajustes_de_la_partida 0x5066 0x5070

; ----------------------------------------------------------------------
; DATOS ajustes_de_la_partida: tres tiras de diez bytes; 0x5000 elige con
;   (0xE06A) y las copia con ldir a 0xE160
;   0x505c..0x507a  (30 bytes)
DATA_ajustes_de_la_partida:
	defb 000h,019h,055h,0b1h,001h,021h,011h,012h,000h,055h	; 505c  ..U..!...U
	defb 0ffh,0eeh,0ffh,0eeh,0ffh,0aah,0afh,000h,055h,0a0h	; 5066  ........U.
	defb 0ffh,0eeh,0ffh,0eeh,0ffh,0aah,0afh,0feh,0efh,0ffh	; 5070  ..........

; ----------------------------------------------------------------------
; DATOS dos_bytes_por_ronda: ocho parejas; 0x5027 entra con 2*(0xE066) y copia
;   la que salga a 0xE300. No son el escenario -eso lo da 0xE2C0-: los valores
;   son 0x7E80, 0x8EE0, 0x68D8, 0x8E03, 0x9E90, 0x6810, 0x6880 y 0x8E80
;   0x507a..0x508a  (16 bytes)
DATA_dos_bytes_por_ronda:
	defb 07eh,080h	; 507a
	defb 08eh,0e0h	; 507c
	defb 068h,0d8h	; 507e
	defb 08eh,003h	; 5080
	defb 09eh,090h	; 5082
	defb 068h,010h	; 5084
	defb 068h,080h	; 5086
	defb 08eh,080h	; 5088

; ----------------------------------------------------------------------
; DATOS cuatro_por_0xe060: 0x5048 los indexa con (0xE060) y deja el que salga
;   en (0xE107)
;   0x508a..0x508e  (4 bytes)
DATA_cuatro_por_0xe060:
	defb 006h,012h,00ah,003h	; 508a

; ======================================================================
; CODIGO 0x508e..0x509d  (15 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ======================================================================
; EL BUCLE DEL COMBATE
; ======================================================================
; Es la escena 5, y va por tres subescenas: montar, pelear y recoger.
; ----------------------------------------------------------------------
el_combate:
	call pinta_la_barra_de_fase		;508e   ; El reloj
	call pinta_el_marcador_de_vidas		;5091   ; Los golpes en marcha
	call pinta_el_indicador_que_parpadea		;5094   ; El indicador
	ld a,(0e104h)		;5097   ; Y repartir por la subescena
	call reparte_por_tabla		;509a

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_509d: 3 entradas, tras el `call reparte_por_tabla`
;   de 0x509A; detras sigue la primera, 0x50A3
;   0x509d..0x50a3  (6 bytes)
DATA_tabla_de_subescenas_509d:
	defw 050a3h,050e1h,050f6h	; 509d  -> L_50A3 L_50E1 L_50F6

; ======================================================================
; CODIGO 0x50a3..0x51a3  (256 bytes)
; ======================================================================


L_50A3:
	call prepara_la_partida		;50a3   ; Poner la RAM del combate a cero
	ld de,0e10ah		;50a6   ; El paso de la coreografia
	ld a,(de)			;50a9
	and a			;50aa   ; Venia a mitad de tira?
	jr z,L_50B9		;50ab
	ld hl,0e061h		;50ad   ; Entonces una tanda mas...
	inc (hl)			;50b0
	ld a,(hl)			;50b1
	cp 008h		;50b2   ; ...sin pasar de la octava
	jr c,L_50B9		;50b4
	ld a,006h		;50b6
	ld (hl),a			;50b8
L_50B9:
	xor a			;50b9   ; Y el paso, a cero
	ld (de),a			;50ba
	ld a,(0e107h)		;50bb   ; El modo de juego
	and 003h		;50be
	cp 003h		;50c0   ; En el modo 3...
	jr nz,L_50D6		;50c2
	call pon_el_suelo_de_la_ronda		;50c4   ; ...el suelo lo pone la ronda
	call sube_el_guion_del_pozo_de_la_ronda		;50c7
	ld a,(0e101h)		;50ca   ; Si ya se ha llegado lejos...
	cp 00dh		;50cd
	jr c,L_50D6		;50cf
	ld a,095h		;50d1   ; ...suena otra musica
	call pide_pieza_si_la_escena_lo_permite		;50d3
L_50D6:
	call monta_el_decorado_o_la_oleada		;50d6   ; Montar el decorado
	call guarda_las_casillas_que_tapa_el_marcador		;50d9   ; Y guardar las casillas que tapa el marcador
L_50DC:
	ld hl,0e104h		;50dc   ; Subescena siguiente
	inc (hl)			;50df
	ret			;50e0
L_50E1:
	call haz_un_cuadro_del_jugador_y_del_enemigo		;50e1   ; Un cuadro de combate
	ld a,(0e187h)		;50e4   ; Se acabo?
	and a			;50e7
	ret nz			;50e8
	ld a,(0e113h)		;50e9   ; Donde esta el enemigo
	cp 025h		;50ec   ; Todavia no ha llegado al borde
	ret nc			;50ee
	ld a,020h		;50ef   ; 0x20 cuadros y a recoger
	ld (0e004h),a		;50f1
	jr L_50DC		;50f4
L_50F6:
	call barre_la_pantalla_desde_la_fila_5		;50f6   ; Bajar la cortina
	ret p			;50f9   ; Todavia no ha acabado
	ld hl,0e060h		;50fa   ; Una fase mas
	inc (hl)			;50fd
	xor a			;50fe   ; Y vuelta a la primera subescena
	ld (0e104h),a		;50ff
	ret			;5102
haz_un_cuadro_del_jugador_y_del_enemigo:
	call pinta_las_barras		;5103   ; Los golpes del jugador
	call mira_si_alguna_barra_llego_a_cero		;5106   ; El reloj
	call anima_el_destello		;5109
	ld a,(0e003h)		;510c   ; Un cuadro si y otro no
	and 001h		;510f
	jr z,L_511E		;5111
	call reparte_la_subescena_del_enemigo		;5113   ; Los cuadros pares: el jugador
	call monta_al_jugador		;5116   ; Montarlo
	call sube_los_demas_sprites		;5119   ; Y subir sus sprites
	jr L_5143		;511c
L_511E:
	ld a,(0e107h)		;511e   ; Los impares: segun el modo...
	and 003h		;5121
	jr z,L_5143		;5123
	call reparte_la_subescena_de_0xe130		;5125   ; ...mover lo que haya
	ld a,(0e107h)		;5128
	and 003h		;512b
	dec a			;512d   ; Modo 1: nada mas
	jr z,L_5143		;512e
	dec a			;5130
	jr nz,L_5138		;5131
	call limpia_la_ultima_banda_y_repasa_las_ranuras		;5133   ; Modo 2: los seis enemigos de golpe
	jr L_5143		;5136
L_5138:
	call mueve_al_enemigo		;5138   ; Y si no, el enemigo del escenario
	call el_escenario_de_la_ronda		;513b   ; En el escenario 0...
	cp 000h		;513e
	call z,pinta_el_agarre_en_la_ultima_fila		;5140   ; ...hay ademas algo que mover
L_5143:
	call haz_lo_que_solo_hay_con_un_jugador		;5143   ; Los proyectiles
	call el_escenario_de_la_ronda		;5146   ; En el escenario 3...
	cp 003h		;5149
	call z,haz_lo_del_escenario_que_toque		;514b   ; ...tambien
	call copia_los_atributos_del_muneco		;514e   ; Aparcar los sprites que se solapen
	call sube_los_cuatro_primeros_sprites		;5151   ; Y subirlo todo a la VRAM
	jp L_5201		;5154
guarda_las_casillas_que_tapa_el_marcador:
	ld bc,00403h		;5157   ; Tres filas de cuatro casillas
	ld (0e460h),bc		;515a
	ld de,0e462h		;515e   ; Donde se guardan
	ld hl,038aeh		;5161   ; Y de donde se leen
	ld b,003h		;5164
L_5166:
	push bc			;5166
	ld b,004h		;5167
L_5169:
	call 0004ah		;5169   ; BIOS RDVRM - Reads the content of VRAM | Leer la casilla...
	ld (de),a			;516c   ; ...y guardarla
	inc hl			;516d
	inc de			;516e
	djnz L_5169		;516f
	ld a,01ch		;5171   ; Saltar al principio de la fila siguiente
	call suma_a_a_hl		;5173
	pop bc			;5176
	djnz L_5166		;5177
	ret			;5179
pinta_la_barra_de_fase:
	ld a,(0e002h)		;517a   ; Con dos jugadores no hay barra
	bit 5,a		;517d
	ret nz			;517f
	ld hl,03af3h		;5180   ; Donde va la barra
	ld c,008h		;5183   ; Ocho casillas
	ld de,051a3h		;5185
	call vuelca_c_bytes_con_ldirvm		;5188
	ld a,(0e003h)		;518b   ; El bit 2 del cuadro...
	bit 2,a		;518e
	ret nz			;5190   ; ...la hace parpadear
	ld hl,03aech		;5191   ; El principio de la barra
	ld a,(0e060h)		;5194   ; La fase por la que va
	ld b,a			;5197
	ld a,007h		;5198   ; Al reves: se llena de derecha a izquierda
	sub b			;519a
	add a,a			;519b   ; Dos casillas por fase
	add a,l			;519c
	ld l,a			;519d
	ld a,082h		;519e   ; La casilla del tope
	jp 0004dh		;51a0   ; BIOS WRTVRM - Writes data in VRAM

; ----------------------------------------------------------------------
; DATOS casillas_de_la_barra: ocho que 0x5185 vuelca en la VRAM 0x3AF3
;   0x51a3..0x51ab  (8 bytes)
DATA_casillas_de_la_barra:
	defb 081h,0f8h,080h,0f8h,080h,0f8h,080h,0f8h	; 51a3  ........

; ======================================================================
; CODIGO 0x51ab..0x51c9  (30 bytes)
; ======================================================================


pinta_el_indicador_que_parpadea:
	ld a,(0e107h)		;51ab   ; Con dos jugadores no hay indicador
	cp 003h		;51ae
	ret z			;51b0
	ld de,0e098h		;51b1   ; El atributo del sprite
	ld hl,051c9h		;51b4   ; Los tres primeros bytes
	ld bc,00003h		;51b7
	ldir		;51ba
	ld a,(0e003h)		;51bc   ; El bit 2 del cuadro elige el color...
	bit 2,a		;51bf
	ld a,00ah		;51c1   ; ...0x0A...
	jr z,L_51C7		;51c3
	ld a,006h		;51c5   ; ...o 0x06: parpadea
L_51C7:
	ld (de),a			;51c7
	ret			;51c8

; ----------------------------------------------------------------------
; DATOS atributo_del_indicador: los tres primeros bytes del atributo de sprite
;   que 0x51B4 copia a 0xE098; el cuarto -el color- lo pone 0x51C7, 0x0A o
;   0x06 segun el bit 2 de (0xE003), o sea parpadea
;   0x51c9..0x51cc  (3 bytes)
DATA_atributo_del_indicador:
	defb 0ach,070h,0d8h	; 51c9

; ----------------------------------------------------------------------
; DATOS guiones_de_los_iconos: dos guiones RLE de 40 casillas cada uno; los
;   pinta 0x59AE/0x59B7 y 0x51B4; 2 guion(es), medidos con tools/formatos.py
;   0x51cc..0x5201  (53 bytes)
DATA_guiones_de_los_iconos:
	defb 006h,000h,0a2h,080h,0ffh,000h,018h,03ch,03ch,03ch,018h,080h,0ffh,000h,018h,03ch,03ch,03ch,018h,001h,0ffh,03ch,042h,07eh,05eh,05eh,07eh,05eh,03ch,00eh,034h,02eh,046h,05ch,030h,020h,010h,000h	; 51cc  .......<<<.....<<<...<B~^^~^<.4.F\0 ..
	defb 008h,0f0h,006h,080h,002h,0f0h,006h,050h,009h,0f0h,081h,0e0h,008h,0a0h,000h	; 51f2  .......P.......

; ======================================================================
; CODIGO 0x5201..0x5212  (17 bytes)
; ======================================================================


L_5201:
	ld bc,(0e10bh)		;5201   ; La escena y la subescena del jugador
	ld a,c			;5205
	push bc			;5206
	and a			;5207   ; Si no es la cero...
	ld b,0e0h		;5208   ; ...el borde se pone negro
	call nz,pon_el_color_del_borde		;520a
	pop bc			;520d
	ld a,c			;520e   ; Y repartir por la subescena
	call reparte_por_tabla		;520f

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_5212: 4 entradas, tras el `call reparte_por_tabla`
;   de 0x520F; detras sigue la primera, 0x521A
;   0x5212..0x521a  (8 bytes)
DATA_tabla_de_subescenas_5212:
	defw 0521ah,05294h,052feh,0535eh	; 5212  -> L_521A encaja_el_golpe L_52FE L_535E

; ======================================================================
; CODIGO 0x521a..0x572a  (1296 bytes)
; ======================================================================


L_521A:
	ld a,(0e100h)		;521a   ; Esta el jugador en pie?
	and a			;521d
	ret z			;521e
	ld a,(0e102h)		;521f   ; Y de una pieza?
	and a			;5222
	ret z			;5223
	ld a,(0e107h)		;5224   ; El modo de juego
	and 003h		;5227
	dec a			;5229
	dec a			;522a
	jp z,L_5465		;522b   ; El modo 2 va por otro lado
	call alcanza_el_enemigo		;522e   ; Leer lo que se pide
	call mira_si_el_enemigo_esta_tocado		;5231   ; Y moverlo
	call el_escenario_de_la_ronda		;5234   ; En que escenario
	cp 003h		;5237   ; El 3 tiene lo suyo
	jp z,L_5588		;5239
	cp 000h		;523c   ; Los escenarios 0, 6 y 7...
	jr z,L_524E		;523e
	cp 006h		;5240
	jr z,L_524E		;5242
	cp 007h		;5244
	jr z,L_524E		;5246
	call mira_el_toque_de_lo_que_vuela		;5248   ; ...no llegan aqui: mirar los choques
	call mueve_las_tres_cosas_que_vuelan		;524b   ; Y el agarre
L_524E:
	ld hl,0e181h		;524e   ; Le queda invulnerabilidad?
	ld a,(hl)			;5251
	and a			;5252
	ret z			;5253   ; No
	call baja_la_invulnerabilidad		;5254   ; Bajarla un punto
	ld a,001h		;5257   ; Y apuntar si sigue
	jr nz,L_525C		;5259
	dec a			;525b
L_525C:
	ld (0e110h),a		;525c
	ret			;525f
mira_la_invulnerabilidad:
	ld hl,0e181h		;5260   ; Otra vez la invulnerabilidad
	ld a,(hl)			;5263
	and a			;5264
	ret z			;5265
baja_la_invulnerabilidad:
	ld a,(0e008h)		;5266   ; Se esta pulsando el disparo?
	and 010h		;5269
	jr z,L_5273		;526b
	dec (hl)			;526d   ; Entonces baja de cuatro en cuatro
	ret z			;526e
	dec (hl)			;526f
	ret z			;5270
	dec (hl)			;5271
	ret z			;5272
L_5273:
	dec (hl)			;5273   ; Si no, de uno en uno
	ret			;5274
L_5275:
	ld hl,0e10bh		;5275   ; Una escena mas del jugador...
	inc (hl)			;5278
	xor a			;5279   ; ...y la subescena a cero
	ld (0e10ch),a		;527a
	ret			;527d
L_527E:
	ld hl,0e10ch		;527e   ; Una subescena mas
	inc (hl)			;5281
	ret			;5282
L_5283:
	xor a			;5283
L_5284:
	ld (0e10bh),a		;5284
	ret			;5287
pon_la_espera:
	ld (0e004h),a		;5288
pon_las_escenas_del_jugador_y_del_enemigo:
	ld a,b			;528b
	ld (0e110h),a		;528c
	ld a,c			;528f
	ld (0e130h),a		;5290
	ret			;5293

; ----------------------------------------------------------------------
; ---------------------------------------------------------------------
; El jugador ha encajado un golpe: se le quita energia y se le pone a
; levantarse. Lo que se quita depende de la ronda y del modo.
; ----------------------------------------------------------------------
encaja_el_golpe:
	call mira_la_invulnerabilidad		;5294   ; Ir gastando la invulnerabilidad
	ld hl,0e004h		;5297   ; La espera
	dec (hl)			;529a
	ret nz			;529b
	ld hl,0e102h		;529c   ; La barra que se toca
	ld a,(0e116h)		;529f   ; Que tipo de golpe fue
	cp 001h		;52a2   ; El del tipo 1 va contra la otra barra
	jr nz,L_52BE		;52a4
	ld a,(0e265h)		;52a6   ; Salvo que ya estuviera tocado
	and a			;52a9
	jr nz,L_52D1		;52aa
	ld hl,0e100h		;52ac   ; La otra barra
	ld b,008h		;52af   ; Ocho de castigo
	ld a,(0e066h)		;52b1   ; Segun la ronda...
	cp 005h		;52b4   ; ...de la quinta en adelante, ocho
	jr nc,L_52C0		;52b6
	ld b,006h		;52b8   ; De la tercera a la cuarta, seis
	cp 003h		;52ba
	jr nc,L_52C0		;52bc
L_52BE:
	ld b,004h		;52be   ; Y antes, cuatro
L_52C0:
	ld a,(0e107h)		;52c0   ; El modo de juego
	and 003h		;52c3
	cp 003h		;52c5   ; Fuera del modo 3...
	jr z,L_52CB		;52c7
	ld b,002h		;52c9   ; ...solo dos
L_52CB:
	ld a,(hl)			;52cb
	sub b			;52cc   ; Restarlo de la barra...
	jr nc,L_52D0		;52cd
	xor a			;52cf   ; ...sin bajar de cero
L_52D0:
	ld (hl),a			;52d0
L_52D1:
	xor a			;52d1
	ld b,a			;52d2
	ld c,a			;52d3
	call pon_las_escenas_del_jugador_y_del_enemigo		;52d4   ; A levantarse
	ld a,001h		;52d7   ; Y los dos contadores de golpe...
	ld (0e117h),a		;52d9
	ld (0e137h),a		;52dc   ; ...a uno
	call devuelve_al_jugador_a_su_sitio		;52df   ; Repintar la barra
	ld a,(0e002h)		;52e2   ; Con un jugador...
	bit 5,a		;52e5
	jr nz,L_52F9		;52e7
	ld a,(0e110h)		;52e9   ; ...y si no queda de pie...
	dec a			;52ec
	jr z,L_5283		;52ed
	ld a,(0e185h)		;52ef   ; ...mirar si hay ordenes pendientes
	ld hl,0e184h		;52f2
	or (hl)			;52f5
	and a			;52f6
	jr nz,L_52FC		;52f7
L_52F9:
	call acerca_al_enemigo_al_jugador		;52f9   ; Pasar el turno
L_52FC:
	jr L_5283		;52fc
L_52FE:
	djnz L_530C		;52fe   ; Reparto por subescena
	ld hl,0e004h		;5300   ; La espera
	dec (hl)			;5303
	ret nz			;5304
	ld a,085h		;5305   ; El fotograma de caer
	ld bc,00302h		;5307   ; Y su duracion
	jr L_5358		;530a
L_530C:
	djnz L_5317		;530c
	ld hl,0e004h		;530e
	dec (hl)			;5311
	ret nz			;5312
	ld a,005h		;5313   ; El fotograma de estar en el suelo
	jr L_5355		;5315
L_5317:
	djnz L_532E		;5317
	ld hl,0e004h		;5319
	dec (hl)			;531c
	ret nz			;531d
	ld a,(0e100h)		;531e   ; La barra esta llena?
	cp 024h		;5321
	ld a,001h		;5323   ; Entonces se levanta entero
	jr z,L_5328		;5325
	xor a			;5327   ; Si no, tocado
L_5328:
	ld (0e10dh),a		;5328   ; Queda apuntado
	jp L_527E		;532b   ; Y a la subescena siguiente
L_532E:
	djnz L_533A		;532e
	call descuenta_la_barra_a_tanteo		;5330   ; Levantarse
	ret nz			;5333   ; Todavia no
	call mira_si_la_fase_fue_perfecta		;5334   ; Ya de pie
	jp L_527E		;5337
L_533A:
	djnz L_5346		;533a
	ld hl,0e004h		;533c   ; La espera
	dec (hl)			;533f
	ret nz			;5340
	xor a			;5341   ; El jugador deja de estar vivo
	ld (0e069h),a		;5342
	ret			;5345
L_5346:
	ld a,05ch		;5346   ; El pitido de levantarse
	call pide_pieza		;5348
	xor a			;534b   ; Ya no hay nadie agarrado
	ld (0e1d7h),a		;534c
	inc a			;534f   ; Y el contador de golpe a uno
	ld (0e117h),a		;5350
	ld a,030h		;5353   ; 0x30 cuadros
L_5355:
	ld bc,00402h		;5355   ; El fotograma y su duracion
L_5358:
	call pon_la_espera		;5358   ; Ponerlos
	jp L_527E		;535b
L_535E:
	djnz L_5371		;535e   ; Reparto
	ld hl,0e004h		;5360   ; La espera
	dec (hl)			;5363
	ret nz			;5364
	ld a,00eh		;5365   ; La musica de caerse
	call pide_pieza_si_la_escena_lo_permite		;5367
	ld a,070h		;536a   ; El fotograma 0x70
	ld bc,00203h		;536c
	jr L_5358		;536f
L_5371:
	djnz L_537F		;5371   ; Reparto por subescena
	ld hl,0e004h		;5373   ; La espera
	dec (hl)			;5376
	ret nz			;5377
	ld a,010h		;5378   ; El fotograma 0x10 y su duracion
	ld bc,00200h		;537a
	jr L_5358		;537d
L_537F:
	djnz L_538B		;537f   ; Reparto
	ld hl,0e004h		;5381
	dec (hl)			;5384
	ret nz			;5385
	xor a			;5386   ; El jugador deja de estar vivo
	ld (0e059h),a		;5387
	ret			;538a
L_538B:
	call apunta_a_las_casillas_guardadas		;538b   ; Aparcar los sprites
	ld a,05ch		;538e   ; El pitido
	call pide_pieza		;5390
	ld a,030h		;5393   ; Y el fotograma 0x30
	ld bc,00500h		;5395
	jr L_5358		;5398

; ----------------------------------------------------------------------
; ---------------------------------------------------------------------
; Mirar si el golpe del ENEMIGO alcanza al jugador, y al reves.
; ----------------------------------------------------------------------
alcanza_el_enemigo:
	ld de,0e157h		;539a   ; La marca de "tocado" del jugador
	ld a,(0e112h)		;539d   ; Donde esta el jugador
	cp 077h		;53a0   ; Muy a la izquierda: no llega
	jr c,L_53F1		;53a2
	cp 086h		;53a4   ; De 0x86 en adelante siempre puede
	jr c,L_53B3		;53a6
	ld a,(0e117h)		;53a8   ; Si no, mirar por que fotograma va
	cp 003h		;53ab
	jr c,L_53F1		;53ad   ; Antes del tercero no hay golpe
	cp 006h		;53af   ; Y del sexto en adelante, tampoco
	jr nc,L_53F1		;53b1
L_53B3:
	ld ix,0e12ch		;53b3   ; La caja del golpe
	ld hl,0e140h		;53b7   ; Y la del jugador
	ld a,002h		;53ba   ; Dos, la altura de la caja
	ld (ix+002h),a		;53bc
	call se_tocan		;53bf   ; Se tocan?
	ld de,0e157h		;53c2
	jr z,L_53F1		;53c5   ; No
	ld a,(de)			;53c7   ; Ya estaba tocado?
	and a			;53c8
	ret nz			;53c9
	inc a			;53ca   ; Marcarlo
	ld (de),a			;53cb
	ld bc,00401h		;53cc   ; El fotograma de encajar y su duracion
	call pon_las_escenas_del_jugador_y_del_enemigo		;53cf
	call da_tres_puntos_de_tanteo		;53d2   ; Restar la energia
	ld a,001h		;53d5
	call elige_la_caja_del_que_toca		;53d7   ; Y sumar el tanteo
	call el_escenario_de_la_ronda		;53da   ; En el escenario 3...
	cp 003h		;53dd
	jr nz,L_53E5		;53df
	xor a			;53e1   ; ...ademas se suelta lo que hubiera agarrado
	ld (0e1c6h),a		;53e2
L_53E5:
	ld a,003h		;53e5   ; Tres cuadros de aturdimiento
	ld (0e159h),a		;53e7
	ld (0e154h),a		;53ea
	ld a,00bh		;53ed   ; El pitido del golpe
	jr L_5454		;53ef
L_53F1:
	xor a			;53f1
	ld (de),a			;53f2   ; No hay toque: limpiar la marca
	ret			;53f3
mira_si_el_enemigo_esta_tocado:
	ld a,(0e29eh)		;53f4   ; Hay algo que lo impida?
	and a			;53f7
	ret nz			;53f8
	ld a,(0e10bh)		;53f9   ; El jugador esta a lo suyo?
	and a			;53fc
	ret nz			;53fd
	ld de,0e158h		;53fe   ; La marca de "tocado" del enemigo
	call el_escenario_de_la_ronda		;5401   ; En el escenario 3...
	cp 003h		;5404
	jr nz,L_540E		;5406
	ld a,(0e1c6h)		;5408   ; ...manda otra cosa
	and a			;540b
	jr nz,L_5419		;540c
L_540E:
	ld a,(0e137h)		;540e   ; Por que fotograma va el golpe
	cp 003h		;5411   ; Antes del tercero no hace dano
	jr c,L_5448		;5413
	cp 007h		;5415   ; Y del septimo en adelante, tampoco
	jr nc,L_5448		;5417
L_5419:
	ld ix,0e14ch		;5419   ; La caja del golpe del jugador
	ld hl,0e120h		;541d   ; Y la del enemigo
	ld a,002h		;5420
	ld (ix+002h),a		;5422   ; Altura dos
	call se_tocan		;5425   ; Se tocan?
	ld b,000h		;5428
L_542A:
	ld de,0e158h		;542a   ; La marca del enemigo
	and a			;542d
	jr z,L_5448		;542e   ; No hay toque
	ld a,(de)			;5430
	and a			;5431   ; Ya estaba tocado?
	ret nz			;5432
	push bc			;5433
	inc a			;5434
	ld (de),a			;5435   ; Marcarlo
L_5436:
	ld bc,00104h		;5436   ; El fotograma de encajar
	call pon_las_escenas_del_jugador_y_del_enemigo		;5439
	pop bc			;543c
	ld a,b			;543d   ; Si viene del camino corto...
	and a			;543e
	jr nz,L_5444		;543f
	call elige_la_caja_del_que_toca		;5441   ; ...sumar el tanteo
L_5444:
	ld a,00ch		;5444   ; El pitido de acertar
	jr L_5454		;5446
L_5448:
	xor a			;5448
	ld (de),a			;5449   ; Sin toque, limpiar la marca
	ret			;544a
L_544B:
	ld b,000h		;544b   ; Sin tanteo
	jr L_5451		;544d
L_544F:
	ld b,001h		;544f   ; Con tanteo
L_5451:
	push bc			;5451
	jr L_5436		;5452
L_5454:
	call pide_pieza		;5454   ; Sonar
L_5457:
	ld a,018h		;5457   ; 0x18 cuadros
	ld (0e004h),a		;5459
	ld a,(0e110h)		;545c   ; Y apuntar de que tipo fue el golpe
	ld (0e116h),a		;545f
	jp L_5275		;5462   ; A la escena siguiente del jugador
L_5465:
	call recorre_las_cinco_ranuras		;5465   ; Mover la tanda entera
	ld b,005h		;5468   ; Las seis ranuras...
	ld iy,0e200h		;546a   ; ...que empiezan en 0xE200
L_546E:
	push bc			;546e
	call monta_la_caja_en_0xe140		;546f
	ld de,0000ch		;5472   ; Cada una son doce bytes
	add iy,de		;5475
	pop bc			;5477
	djnz L_546E		;5478
	ld iy,0e20ch		;547a
monta_la_caja_en_0xe140:
	ld a,(iy+002h)		;547e   ; Por donde va este
	cp 01fh		;5481   ; Ya paso de largo
	ret nc			;5483
	ld a,(iy+000h)		;5484   ; Esta ocupada?
	dec a			;5487
	ret nz			;5488
	ld de,0e140h		;5489   ; Su caja
	ld a,(iy+001h)		;548c   ; La fila...
	add a,a			;548f   ; ...por ocho, que es lo que mide una casilla
	add a,a			;5490
	add a,a			;5491
	sub 004h		;5492
	ld (de),a			;5494
	inc de			;5495
	ld a,(iy+002h)		;5496
	add a,a			;5499
	add a,a			;549a
	add a,a			;549b
	sub 004h		;549c
	ld (de),a			;549e
	inc de			;549f
	ld a,008h		;54a0
	ld (de),a			;54a2
	inc de			;54a3
	ld (de),a			;54a4
	ld ix,0e12ch		;54a5
	ld hl,0e140h		;54a9
	ld a,002h		;54ac
	ld (ix+002h),a		;54ae
	call se_tocan		;54b1
	ret z			;54b4
	ld a,002h		;54b5
	ld (iy+000h),a		;54b7
	ld a,(iy+00ah)		;54ba
	and a			;54bd
	jr z,L_54DE		;54be
	ld hl,0e1a4h		;54c0
	call suma_a_a_hl		;54c3
	inc (hl)			;54c6
	ld a,(hl)			;54c7
	cp 003h		;54c8
	jr nz,L_54DE		;54ca
	ld hl,0e2f0h		;54cc
	inc (hl)			;54cf
	ld a,(hl)			;54d0
	cp 005h		;54d1
	jr c,L_54DE		;54d3
	xor a			;54d5
	ld (hl),a			;54d6
	inc hl			;54d7
	ld a,(hl)			;54d8
	cp 003h		;54d9
	jr nc,L_54DE		;54db
	inc (hl)			;54dd
L_54DE:
	ld a,003h		;54de
	ld (0e117h),a		;54e0
	ld d,001h		;54e3
	jp L_55C4		;54e5
recorre_las_cinco_ranuras:
	ld hl,0e201h		;54e8   ; La primera ranura
	ld iy,0e200h		;54eb   ; Y su cabecera
	ld b,005h		;54ef   ; Cinco de las seis
L_54F1:
	push bc			;54f1
	push hl			;54f2
	call monta_la_caja_en_0xe14c		;54f3
	pop hl			;54f6
	ld de,0000ch		;54f7   ; Doce bytes por ranura
	add hl,de			;54fa
	add iy,de		;54fb
	pop bc			;54fd
	djnz L_54F1		;54fe
monta_la_caja_en_0xe14c:
	ld a,(iy+000h)		;5500   ; Esta ranura vale?
	dec a			;5503
	ret nz			;5504
	ld de,0e14ch		;5505   ; La caja de este
	ld a,(hl)			;5508   ; Su columna...
	add a,a			;5509   ; ...por ocho
	add a,a			;550a
	add a,a			;550b
	ld (de),a			;550c
	inc hl			;550d
	inc de			;550e
	ld a,(hl)			;550f   ; Y su fila
	cp 020h		;5510   ; De la 32 para abajo no hay nada que mirar
	ret nc			;5512
	add a,a			;5513
	add a,a			;5514
	add a,a			;5515
	add a,008h		;5516   ; Media casilla de ajuste
	ld b,a			;5518
	inc hl			;5519
	ld a,(hl)			;551a   ; Por que lado mira
	and a			;551b
	ld a,b			;551c
	jr z,L_5521		;551d
	sub 010h		;551f   ; Al reves, media casilla menos
L_5521:
	ld (de),a			;5521
	ld ix,0e14ch		;5522   ; La caja de este...
	ld hl,0e120h		;5526   ; ...contra la del jugador
	ld a,003h		;5529   ; Altura tres
	call se_tocan		;552b   ; Se tocan?
	push af			;552e
	jr z,L_554A		;552f
	ld a,(iy+009h)		;5531   ; Ya estaba tocado?
	and a			;5534
	jr nz,L_554E		;5535
	inc a			;5537
	ld (iy+009h),a		;5538   ; Marcarlo
	ld (iy+008h),a		;553b
	ld a,003h		;553e   ; Y a la escena 3: cayendose
	ld (iy+000h),a		;5540
	pop af			;5543
	ld b,000h		;5544   ; Sin tanteo
	push bc			;5546
	jp L_5436		;5547   ; Al camino de encajar
L_554A:
	xor a			;554a
	ld (iy+009h),a		;554b   ; No hay toque: limpiar su marca
L_554E:
	xor a			;554e
	ld (0e158h),a		;554f   ; Y la del enemigo
	pop af			;5552
	ret			;5553
mira_el_toque_de_la_coordenada_siguiente:
	push hl			;5554
	inc hl			;5555   ; La coordenada siguiente
	ld c,000h		;5556
	call monta_la_caja_de_altura_dos		;5558   ; Montar la caja
	call se_tocan		;555b   ; Y mirar el toque
	pop hl			;555e
	ret			;555f
monta_la_caja_de_altura_dos:
	ld b,002h		;5560   ; Altura dos
monta_la_caja_en_0xe19d:
	ld ix,0e19dh		;5562   ; Donde se monta la caja
	ld a,(hl)			;5566   ; La columna...
	add a,008h		;5567   ; ...mas media casilla
	ld (ix+000h),a		;5569
	ld a,c			;556c
	and a			;556d
	jr nz,L_5571		;556e
	inc hl			;5570
L_5571:
	inc hl			;5571   ; Y la fila, igual
	ld a,(hl)			;5572
	add a,008h		;5573
	ld (ix+001h),a		;5575
	ld hl,0e120h		;5578   ; Contra la caja del jugador
	ld (ix+002h),b		;557b   ; Y la altura que se pidio
	ret			;557e
mira_si_la_coordenada_esta_a_tiro:
	push hl			;557f
	inc hl			;5580   ; La coordenada
	ld d,(hl)			;5581
	inc hl			;5582
	call mira_si_esta_dentro_de_la_caja_de_once		;5583   ; Mirar si esta a tiro
	pop hl			;5586
	ret			;5587
L_5588:
	ld a,(0e29eh)		;5588   ; Hay algo que lo impida?
	and a			;558b
	ret nz			;558c
	ld a,(0e1b0h)		;558d   ; Ya hay cuatro cosas volando?
	cp 004h		;5590
	ret nc			;5592
	call lanza_lo_que_sale_del_enemigo		;5593   ; Lanzar
	ld hl,0e1b1h		;5596   ; La coordenada del proyectil
	call mira_el_toque_de_la_coordenada_siguiente		;5599   ; Toca al jugador?
	ret z			;559c   ; No
	ld hl,0e1b2h		;559d   ; La caja del proyectil
	ld de,0e14ch		;55a0
	ld a,(hl)			;55a3
	add a,006h		;55a4   ; Seis de ajuste
	ld (de),a			;55a6
	inc hl			;55a7
	inc hl			;55a8
	inc de			;55a9
	ld a,(hl)			;55aa
	add a,006h		;55ab   ; Y la fila igual
	ld (de),a			;55ad
	jp L_544B		;55ae   ; Al camino de encajar, sin tanteo
lanza_lo_que_sale_del_enemigo:
	ld hl,0e1b1h		;55b1
	call mira_si_la_coordenada_esta_a_tiro		;55b4   ; Esta a tiro?
	ret z			;55b7
	ld a,004h		;55b8   ; Cuatro cuadros
	ld (0e1b0h),a		;55ba
	ld a,010h		;55bd   ; Y el sentido en el que sale
	ld (0e1c4h),a		;55bf
	ld d,010h		;55c2
L_55C4:
	call suma_puntos_en_bcd		;55c4   ; Sumar el tanteo
	ld a,00bh		;55c7   ; Y el pitido
	jp pide_pieza		;55c9
mira_el_toque_de_lo_que_vuela:
	ld a,(0e10bh)		;55cc   ; El jugador esta a lo suyo?
	and a			;55cf
	ret nz			;55d0
	call mira_si_toca_algo_de_lo_que_vuela		;55d1   ; Mirar el toque
	ld b,001h		;55d4
	ld c,a			;55d6
	call el_escenario_de_la_ronda		;55d7   ; En el escenario 2...
	cp 002h		;55da
	ld a,c			;55dc
	jp nz,L_542A		;55dd
	and a			;55e0
	ret z			;55e1
	ld a,0b0h		;55e2   ; ...el agarre dura 0xB0 cuadros
	ld (0e181h),a		;55e4
devuelve_al_jugador_a_su_sitio:
	xor a			;55e7   ; El salto, a cero
	ld (0e11ch),a		;55e8
	ld (0e11dh),a		;55eb
	ld a,087h		;55ee   ; Y el jugador vuelve a 0x87
	ld (0e112h),a		;55f0
	jp L_6B6D		;55f3
elige_la_caja_del_que_toca:
	ld hl,0e12ch		;55f6   ; La caja del jugador
	ld b,00fh		;55f9   ; 0x0F de ancho
	and a			;55fb   ; De quien es
	jr nz,L_5603		;55fc
	ld hl,0e14ch		;55fe   ; La del enemigo, 0x0D
	ld b,00dh		;5601
L_5603:
	ld (0e180h),a		;5603   ; De quien fue el tanteo
	ld de,0e1e0h		;5606   ; Los atributos del numerito
	ld a,(hl)			;5609   ; Su columna...
	sub 006h		;560a   ; ...seis a la izquierda
	ld (de),a			;560c
	inc hl			;560d
	inc de			;560e
	ld a,(hl)			;560f   ; Y su fila, igual
	sub 006h		;5610
	ld (de),a			;5612
	inc de			;5613
	ld a,0c4h		;5614
	ld (de),a			;5616
	inc de			;5617
	ld a,b			;5618
	ld (de),a			;5619
	ld a,03ah		;561a
	ld (0e183h),a		;561c
	ret			;561f
da_tres_puntos_de_tanteo:
	ld a,(0e002h)		;5620   ; Con dos jugadores no hay tanteo aqui
	bit 5,a		;5623
	ret nz			;5625
	ld d,003h		;5626   ; Tres puntos
	jp suma_puntos_en_bcd		;5628
mira_si_toca_algo_de_lo_que_vuela:
	ld b,000h		;562b   ; B = 0: todavia no ha tocado nada
	ld c,b			;562d
	ld a,(0e158h)		;562e   ; El enemigo ya esta tocado?
	and a			;5631
	jr nz,L_5689		;5632
	ld hl,0e1e4h		;5634   ; La primera de las tres cosas que vuelan
	ld de,0e1a7h		;5637   ; Su estado
	ld iy,0e1b2h		;563a   ; Y donde se apunta
	call mira_el_toque_de_una_de_las_que_vuelan		;563e
	ld hl,0e1e8h		;5641   ; La segunda
	ld de,0e1a8h		;5644
	ld iy,0e1b5h		;5647
	call mira_el_toque_de_una_de_las_que_vuelan		;564b
	ld hl,0e1ech		;564e   ; Y la tercera
	ld de,0e1a9h		;5651
	ld iy,0e1b8h		;5654
mira_el_toque_de_una_de_las_que_vuelan:
	push bc			;5658
	ld c,001h		;5659   ; Con la coordenada de al lado
	call monta_la_caja_de_altura_dos		;565b   ; Montar la caja
	pop bc			;565e
	ld a,(de)			;565f   ; En que estado esta
	cp 001h		;5660   ; Solo cuentan las que estan sueltas
	jr nz,L_5689		;5662
	push de			;5664
	push bc			;5665
	call se_tocan		;5666   ; Toca al jugador?
	pop bc			;5669
	pop de			;566a
	ld c,a			;566b
	and a			;566c
	jr z,L_5689		;566d   ; No
	ld a,(0e29eh)		;566f   ; Es el momento de agarrar?
	and a			;5672
	jr z,L_567C		;5673
	ld a,002h		;5675   ; Entonces pasa al estado 2: agarrada
	ld (de),a			;5677
	xor a			;5678
	ld c,a			;5679
	jr L_5689		;567a
L_567C:
	ld a,00ch		;567c   ; El pitido
	call pide_pieza		;567e
	ld a,003h		;5681   ; Estado 3, y once cuadros
	ld b,00bh		;5683
L_5685:
	ld (de),a			;5685
	ld (iy+000h),b		;5686
L_5689:
	ld a,c			;5689   ; Juntar lo de esta con lo de las de antes
	or b			;568a
	ld b,a			;568b
	ret			;568c
mueve_las_tres_cosas_que_vuelan:
	ld hl,0e1e4h		;568d   ; La primera
	ld de,0e1a7h		;5690
	ld iy,0e1b2h		;5693
	call mueve_una_de_las_que_vuelan		;5697
	ld hl,0e1e8h		;569a   ; La segunda
	ld de,0e1a8h		;569d
	ld iy,0e1b5h		;56a0
	call mueve_una_de_las_que_vuelan		;56a4
	ld hl,0e1ech		;56a7   ; Y la tercera
	ld de,0e1a9h		;56aa
	ld iy,0e1b8h		;56ad
mueve_una_de_las_que_vuelan:
	ld a,(de)			;56b1   ; Solo las sueltas
	cp 001h		;56b2
	ret nz			;56b4
	push de			;56b5
	call mira_si_llego_a_su_sitio		;56b6   ; Ha llegado a su sitio?
	pop de			;56b9
	and a			;56ba
	ret z			;56bb   ; Todavia no
	ld a,(0e002h)		;56bc   ; Con un jugador...
	bit 5,a		;56bf
	jr nz,L_56CA		;56c1
	push de			;56c3
	ld d,001h		;56c4   ; ...un punto de tanteo
	call suma_puntos_en_bcd		;56c6
	pop de			;56c9
L_56CA:
	ld a,00bh		;56ca   ; El pitido
	call pide_pieza		;56cc
	ld a,006h		;56cf   ; Estado 6, y 0x13 cuadros
	ld b,013h		;56d1
	jr L_5685		;56d3
descuenta_la_barra_a_tanteo:
	ld a,(0e002h)		;56d5   ; Con dos jugadores no hay recuento
	bit 5,a		;56d8
	jr nz,L_56F7		;56da
	ld hl,0e100h		;56dc   ; La barra
	ld a,(0e003h)		;56df   ; Uno de cada cuatro cuadros
	and 006h		;56e2
	ret nz			;56e4
	ld a,(hl)			;56e5   ; Queda algo que descontar?
	and a			;56e6
	jr z,L_56F7		;56e7
	dec (hl)			;56e9   ; Un punto menos de barra...
	ld d,002h		;56ea   ; ...y dos de tanteo
	call suma_puntos_en_bcd		;56ec
	ld a,00fh		;56ef   ; El pitido de la cuenta
	call pide_pieza_si_la_escena_lo_permite		;56f1
	or 001h		;56f4   ; Devolver "todavia queda"
	ret			;56f6
L_56F7:
	and 000h		;56f7   ; Devolver "se acabo"
	ret			;56f9
mira_si_la_fase_fue_perfecta:
	ld a,(0e002h)		;56fa   ; Con dos jugadores no hay perfecto
	bit 5,a		;56fd
	jr nz,L_5724		;56ff
	ld a,(0e10dh)		;5701   ; Se acabo la fase sin un rasguno?
	and a			;5704
	jr z,L_5724		;5705
	ld hl,03880h		;5707   ; Limpiar la fila
	ld c,020h		;570a
	xor a			;570c
	call rellena_c_bytes_con_filvrm		;570d
	ld de,0572ah		;5710   ; Y pintar "PERFECT 5000"
	call pinta_guion		;5713
	ld a,012h		;5716   ; La musica del perfecto
	call pide_pieza_si_la_escena_lo_permite		;5718
	ld d,050h		;571b   ; 0x50 de tanteo, que son los 5000
	call suma_puntos_en_bcd		;571d
	ld a,050h		;5720   ; Y 0x50 cuadros para leerlo
	jr L_5726		;5722
L_5724:
	ld a,010h		;5724   ; Sin perfecto, solo 0x10
L_5726:
	ld (0e004h),a		;5726
	ret			;5729

; ----------------------------------------------------------------------
; DATOS rotulo_del_perfecto: un guion literal que dice "PERFECT 5000" en la
;   VRAM 0x388A; lo pinta 0x5710, y solo cuando (0xE10D) no es cero -que
;   0x5328 pone al acabar la fase con la barra llena, comparandola contra
;   0x24-; 1 guion(es), medidos con tools/formatos.py
;   0x572a..0x5739  (15 bytes)
DATA_rotulo_del_perfecto:
	defb 08ah,038h,030h,025h,032h,026h,025h,023h,034h,000h,015h,010h,010h,010h,0ffh	; 572a  .80%2&%#4......

; ======================================================================
; CODIGO 0x5739..0x57e4  (171 bytes)
; ======================================================================


acerca_al_enemigo_al_jugador:
	call mide_la_distancia		;5739   ; A que distancia esta
	ld a,b			;573c
	cp 004h		;573d   ; De cerca no se acerca mas
	ret nc			;573f
	ld hl,0e156h		;5740   ; La x del jugador
	ld b,(hl)			;5743
	ld de,0e113h		;5744   ; Y la del enemigo
	ld a,(de)			;5747
	cp b			;5748   ; Quien esta a la derecha
	ld b,008h		;5749   ; Ocho de paso
	ld c,0ffh		;574b
	jr nc,L_5757		;574d
	ld a,b			;574f   ; Y si esta al otro lado, al reves
	neg		;5750
	ld b,a			;5752
	ld a,c			;5753
	neg		;5754
	ld c,a			;5756
L_5757:
	ld a,(0e002h)		;5757   ; Con dos jugadores...
	bit 5,a		;575a
	jr z,L_5769		;575c
	ld a,(de)			;575e   ; ...mover tambien al enemigo
	add a,b			;575f
	cp 0ddh		;5760   ; Sin pasar de 0xDD...
	jr nc,L_5769		;5762
	cp 023h		;5764   ; ...ni bajar de 0x23
	jr c,L_5769		;5766
	ld (de),a			;5768
L_5769:
	ld hl,0e133h		;5769   ; La fila del enemigo
	ld a,(hl)			;576c
	add a,c			;576d   ; Mas lo que se pidio
	cp 01ch		;576e   ; Sin pasar de 0x1C...
	ret nc			;5770
	cp 005h		;5771   ; ...ni bajar de 5
	ret c			;5773
	ld (hl),a			;5774
	ret			;5775
monta_la_partida_de_la_demostracion:
	ld hl,00100h		;5776   ; El reloj a 0x0100
	ld (0e00bh),hl		;5779
	ld a,000h		;577c   ; La ronda, a cero
	ld (0e066h),a		;577e
	ld (0e2c0h),a		;5781   ; Y el primer escenario, tambien
	xor a			;5784
	ld (0e06ah),a		;5785   ; La vuelta...
	ld (0e06ch),a		;5788   ; ...y el paso de la demostracion
	ld a,001h		;578b   ; El jugador 1 empieza vivo
	ld (0e059h),a		;578d
	ld hl,0e002h		;5790   ; La marca de escena...
	ld a,(hl)			;5793
	and 0dfh		;5794   ; ...pierde el bit 5 -un jugador- y gana el 0
	or 001h		;5796
	ld (hl),a			;5798
	ld a,003h		;5799   ; Modo 3
	ld (0e060h),a		;579b
	call prepara_el_marcador		;579e   ; Preparar el marcador
	call sube_los_sprites_del_muneco		;57a1   ; Subir los sprites
	call sube_el_guion_de_sprite_suelto		;57a4   ; Montar el decorado
	call monta_la_pantalla_de_combate		;57a7   ; La pantalla de combate
	call pinta_la_fila_3_y_los_dos_nombres		;57aa   ; La fila del decorado
	jp pinta_el_marcador		;57ad   ; Y el marcador
haz_un_cuadro_de_combate:
	call el_combate		;57b0
	ret			;57b3
lee_la_orden_grabada_de_la_demostracion:
	ld a,(0e10bh)		;57b4   ; El jugador esta a lo suyo?
	dec a			;57b7
	ret z			;57b8
	ld hl,0e00ch		;57b9   ; La cuenta de la orden grabada
	dec (hl)			;57bc
	jr nz,L_57D1		;57bd   ; Todavia dura
	push hl			;57bf
	ld de,05806h		;57c0   ; La tira de duraciones
	ld hl,0e06ch		;57c3   ; Por que orden va
	ld a,(hl)			;57c6
	call suma_a_a_de		;57c7
	ld a,(de)			;57ca   ; Su duracion
	inc (hl)			;57cb   ; Una orden mas
	pop hl			;57cc
	ld (hl),a			;57cd   ; Guardada
	dec hl			;57ce
	inc (hl)			;57cf   ; Y una posicion mas en la tira de mandos
	inc hl			;57d0
L_57D1:
	dec hl			;57d1   ; Por que mando va
	ld a,(hl)			;57d2
	ld hl,057e4h		;57d3   ; La tira de mandos grabados
	call suma_a_a_hl		;57d6
	ld a,(hl)			;57d9
	cp 0ffh		;57da   ; El 0xFF cierra la demostracion
	jp nz,mete_estos_mandos		;57dc   ; Si no, meterlo como si se hubiera pulsado
	xor a			;57df
	ld (0e059h),a		;57e0   ; Se acabo: el jugador deja de estar vivo
	ret			;57e3

; ----------------------------------------------------------------------
; DATOS los_mandos_grabados: la partida grabada de la demostracion: 33
;   pulsaciones y el 0xFF que 0x57DA busca para pararla
;   0x57e4..0x5806  (34 bytes)
DATA_los_mandos_grabados:
	defb 000h,004h,000h,001h,008h,000h,004h,011h,000h,010h,005h,006h,008h,000h,011h,008h,004h,000h,004h,000h,001h,000h,001h,000h,001h,000h,011h,00ah,010h,004h,011h,000h,010h,0ffh	; 57e4  ..................................

; ----------------------------------------------------------------------
; DATOS la_otra_tira_de_la_demostracion: otros 32 bytes, los que carga 0x57C0
;   0x5806..0x5826  (32 bytes)
DATA_la_otra_tira_de_la_demostracion:
	defb 040h,008h,03ah,030h,008h,00ah,025h,002h,018h,028h,007h,010h,008h,038h,006h,002h,020h,02dh,020h,040h,020h,040h,020h,040h,00ah,03ah,008h,010h,028h,002h,030h,010h	; 5806  @.:0..%..(...8.. - @ @ @.:..(.0.

; ======================================================================
; CODIGO 0x5826..0x5834  (14 bytes)
; ======================================================================


haz_un_cuadro_del_final:
	call monta_al_jugador		;5826   ; Montar al muneco
	call sube_los_demas_sprites		;5829   ; Y subir sus sprites
	ld bc,(0e178h)		;582c   ; La escena y la subescena del final
	ld a,c			;5830
	call reparte_por_tabla		;5831   ; Repartir

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_5834: 5 entradas, tras el `call reparte_por_tabla`
;   de 0x5831; detras sigue la primera, 0x583E
;   0x5834..0x583e  (10 bytes)
DATA_tabla_de_subescenas_5834:
	defw 0583eh,0586eh,058a0h,058bfh,058d1h	; 5834

; ======================================================================
; CODIGO 0x583e..0x58ef  (177 bytes)
; ======================================================================


L_583E:
	djnz L_585F		;583e
	call barre_la_pantalla_entera		;5840   ; Bajar la cortina
	ret p			;5843   ; Todavia no
	ld bc,0e077h		;5844   ; El muneco, en 0x77
	ld (0e112h),bc		;5847
	xor a			;584b
	ld (0e133h),a		;584c   ; Y el enemigo, en la fila 0
	ld (0e156h),a		;584f
	ld (0e10eh),a		;5852
	call monta_la_fuente		;5855   ; Subir la fuente
	call sube_los_cuatro_primeros_sprites		;5858   ; Y los sprites
	ld a,030h		;585b   ; 0x30 cuadros
	jr L_588E		;585d
L_585F:
	ld a,0c0h		;585f   ; Si no, el muneco a 0xC0
	ld (0e112h),a		;5861
	ld a,020h		;5864
L_5866:
	ld (0e004h),a		;5866   ; La espera que traiga A
L_5869:
	ld hl,0e179h		;5869   ; Y a la subescena siguiente
	inc (hl)			;586c
	ret			;586d
L_586E:
	ld a,(0e003h)		;586e   ; Un cuadro de cada dos
	and 001h		;5871
	ret nz			;5873
	push bc			;5874
	call pinta_o_borra_las_cuatro_casillas		;5875   ; Parpadear las cuatro casillas
	pop bc			;5878
	djnz L_5899		;5879
	ld a,004h		;587b   ; El fotograma 4
	ld (0e11dh),a		;587d
	call arranca_la_orden_pedida		;5880   ; Andar
	ld a,(0e113h)		;5883   ; Donde va el otro
	cp 0a0h		;5886   ; Todavia no ha llegado
	ret nc			;5888
	call pinta_las_cuatro_casillas		;5889   ; Pintar las cuatro casillas fijas
	ld a,040h		;588c   ; 0x40 cuadros
L_588E:
	ld (0e004h),a		;588e   ; La espera
	ld hl,0e178h		;5891   ; Una escena mas...
	inc (hl)			;5894
	xor a			;5895   ; ...y la subescena a cero
	inc hl			;5896
	ld (hl),a			;5897
	ret			;5898
L_5899:
	ld hl,0e004h		;5899
	dec (hl)			;589c   ; La espera
	ret nz			;589d
	jr L_5869		;589e
L_58A0:
	djnz L_58AB		;58a0
	ld hl,0e004h		;58a2
	dec (hl)			;58a5
	ret nz			;58a6
	ld a,080h		;58a7   ; 0x80 cuadros
	jr L_588E		;58a9
L_58AB:
	ld hl,0e004h		;58ab
	dec (hl)			;58ae
	ret nz			;58af
	ld de,058f9h		;58b0   ; Los rotulos del final
	call pinta_guion		;58b3
	ld a,011h		;58b6   ; Y la musica
	call pide_pieza_si_la_escena_lo_permite		;58b8
	ld a,050h		;58bb   ; 0x50 cuadros
	jr L_5866		;58bd
L_58BF:
	ld a,(0e003h)		;58bf
	and 001h		;58c2
	ret nz			;58c4
	call avanza_la_caida_del_jugador		;58c5   ; Animar
	ld hl,0e004h		;58c8
	dec (hl)			;58cb
	ret nz			;58cc
	ld a,040h		;58cd   ; 0x40 cuadros
	jr L_588E		;58cf
L_58D1:
	ld hl,0e004h		;58d1
	dec (hl)			;58d4
	ret nz			;58d5
	ld a,001h		;58d6   ; Y marcar que se acabo
	ld (0e17ah),a		;58d8
	ret			;58db
pinta_o_borra_las_cuatro_casillas:
	ld de,058efh		;58dc   ; Las cuatro casillas
	ld a,(0e003h)		;58df
	bit 2,a		;58e2   ; El bit 2 del cuadro...
	jp nz,borra_guion		;58e4   ; ...las borra...
L_58E7:
	jp pinta_guion		;58e7   ; ...o las pinta: parpadean
pinta_las_cuatro_casillas:
	ld de,058efh		;58ea   ; Aqui siempre se pintan
	jr L_58E7		;58ed

; ----------------------------------------------------------------------
; DATOS guion_de_las_cuatro_casillas: dos tramos de dos casillas en la tabla
;   de nombres, 0x3A2F y 0x3A4F: filas 17 y 18, columnas 15 y 16, o sea un
;   bloque de 2x2 en el centro. 0x58DC lo pinta y lo borra segun el bit 2 de
;   (0xE003), asi que parpadea; 1 guion(es), medidos con tools/formatos.py
;   0x58ef..0x58f9  (10 bytes)
DATA_guion_de_las_cuatro_casillas:
	defb 02fh,03ah,07dh,0f5h,0feh,04fh,03ah,07eh,0f6h,0ffh	; 58ef  /:}..O:~..

; ----------------------------------------------------------------------
; DATOS rotulos_del_final: cuatro tramos que 0x58B0 pinta de una vez, con el
;   alfabeto de la casa (la letra es el ASCII menos 0x20): "CONGRATULATIONS!"
;   en 0x3888, "THANK YOU" en 0x38CB, "FOR" en 0x390E y "YOUR BRAVERY!!" en
;   0x3949; 1 guion(es), medidos con tools/formatos.py
;   0x58f9..0x592f  (54 bytes)
DATA_rotulos_del_final:
	defb 088h,038h,023h,02fh,02eh,027h,032h,021h,034h,035h,02ch,021h,034h,029h,02fh,02eh,033h,03bh,0feh,0cbh,038h,034h,028h,021h,02eh,02bh,000h,039h,02fh,035h,0feh,00eh,039h,026h,02fh,032h,0feh,049h,039h,039h,02fh,035h,032h,000h,022h,032h,021h,036h,025h,032h,039h,03bh,03bh,0ffh	; 58f9  .8#/.'2!45,!4)/.3;..84(!.+.9/5..9&/2.I99/52."2!6%29;;.

; ----------------------------------------------------------------------
; DATOS tabla_de_patrones_del_suelo: ocho punteros; los carga 0x5AAC y van a
;   la VRAM de patrones 0x3080
;   0x592f..0x593f  (16 bytes)
DATA_tabla_de_patrones_del_suelo:
	defw 094c3h,0980fh,09b4dh,09d53h,09f65h,0a1b1h,099d8h,0a3a0h	; 592f

; ----------------------------------------------------------------------
; DATOS tabla_de_colores_del_suelo: ocho punteros, los mismos ocho suelos en
;   color; los carga 0x5A97 y van a 0x1080 y a 0x1440
;   0x593f..0x594f  (16 bytes)
DATA_tabla_de_colores_del_suelo:
	defw 09764h,09957h,09cf2h,09f0ch,0a12ah,0a302h,09b2eh,0a47fh	; 593f

; ----------------------------------------------------------------------
; DATOS tabla_de_patrones_de_la_banda_alta: cuatro punteros; los carga 0x59E0
;   y van a 0x2260
;   0x594f..0x5957  (8 bytes)
DATA_tabla_de_patrones_de_la_banda_alta:
	defw 0a9fbh,0aa6eh,0ab18h,0aad5h	; 594f  -> DATA_guiones_de_las_bandas 0xaa6e 0xab18 0xaad5

; ----------------------------------------------------------------------
; DATOS tabla_de_colores_de_la_banda_alta: cuatro punteros; los carga 0x59CA y
;   van a 0x0260 y a 0x0560
;   0x5957..0x595f  (8 bytes)
DATA_tabla_de_colores_de_la_banda_alta:
	defw 0aa3ch,0aac0h,0ac22h,0ab15h	; 5957

; ----------------------------------------------------------------------
; DATOS tabla_de_patrones_de_la_banda_media: cuatro punteros; los carga 0x5A04
;   y van a 0x2880
;   0x595f..0x5967  (8 bytes)
DATA_tabla_de_patrones_de_la_banda_media:
	defw 0ac57h,0b007h,0b417h,0b23ah	; 595f

; ----------------------------------------------------------------------
; DATOS tabla_de_colores_de_la_banda_media: cuatro punteros; los carga 0x59EE
;   y van a 0x0880 y a 0x0C40
;   0x5967..0x596f  (8 bytes)
DATA_tabla_de_colores_de_la_banda_media:
	defw 0ae87h,0b204h,0b67dh,0b390h	; 5967

; ----------------------------------------------------------------------
; DATOS tabla_de_patrones_de_la_banda_baja: cuatro punteros; los carga 0x5A27
;   y van a 0x33C0
;   0x596f..0x5977  (8 bytes)
DATA_tabla_de_patrones_de_la_banda_baja:
	defw 0b765h,0b798h,0b804h,0b7c1h	; 596f

; ----------------------------------------------------------------------
; DATOS tabla_de_colores_de_la_banda_baja: cuatro punteros; los carga 0x5A12 y
;   van a 0x13C0 y a 0x1780
;   0x5977..0x597f  (8 bytes)
DATA_tabla_de_colores_de_la_banda_baja:
	defw 0b787h,0b7beh,0b816h,0b7f6h	; 5977

; ======================================================================
; CODIGO 0x597f..0x5af2  (371 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ======================================================================
; MONTAR LA PANTALLA DE COMBATE
; ======================================================================
; Primero lo que no cambia -el marco y los iconos-, luego las tres
; bandas y el suelo, que si dependen del escenario. Y al final el
; espejo, que es lo que permite dibujar solo la mitad.
; Los bancos van al reves: los patrones caen en 0x2000 y los colores en
; 0x0000, asi que un mismo dibujo son dos guiones con el mismo offset.
; ======================================================================
; ======================================================================
; ======================================================================
; ======================================================================
; ----------------------------------------------------------------------
monta_la_pantalla_de_combate:
	ld hl,001f0h		;597f   ; Los colores del marco, en el primer tercio
	ld de,0943bh		;5982   ; El mismo guion se usa dos veces: por eso se guarda
	push de			;5985
	call vuelca_el_guion_con_destino_en_hl		;5986   ; Volcar con el destino ya en HL
	ld hl,004f0h		;5989   ; Y otra vez, medio tercio mas abajo
	pop de			;598c
	call vuelca_el_guion_con_destino_en_hl		;598d
	ld hl,021f0h		;5990   ; Ahora los patrones del marco, mismo offset pero banco de 0x2000
	ld de,093e4h		;5993
	call vuelca_el_guion_con_destino_en_hl		;5996
	ld hl,00480h		;5999   ; El segundo trozo del marco: color...
	ld de,094b0h		;599c
	call vuelca_el_guion_con_destino_en_hl		;599f
	ld hl,02480h		;59a2   ; ...y patron
	ld de,09464h		;59a5
	call vuelca_el_guion_con_destino_en_hl		;59a8
	ld hl,01400h		;59ab   ; Los iconos, dos veces en color
	ld de,051f2h		;59ae
	call vuelca_el_guion_con_destino_en_hl		;59b1
	ld hl,017c0h		;59b4
	ld de,051f2h		;59b7
	call vuelca_el_guion_con_destino_en_hl		;59ba
	ld hl,03400h		;59bd   ; Y una en patron
	ld de,051cch		;59c0
	call vuelca_el_guion_con_destino_en_hl		;59c3
	ld a,(0e2e0h)		;59c6   ; El escenario que toca; se usa cinco veces, de ahi el `push`
	push af			;59c9
	ld hl,05957h		;59ca   ; Colores de la banda de arriba
	call lee_la_entrada_de_la_tabla		;59cd
	push de			;59d0
	ld hl,00260h		;59d1   ; Van a 0x0260...
	call vuelca_el_guion_con_destino_en_hl		;59d4
	pop de			;59d7
	ld hl,00560h		;59d8   ; ...y a 0x0560, que es donde caera el espejo
	call vuelca_el_guion_con_destino_en_hl		;59db
	pop af			;59de
	push af			;59df
	ld hl,0594fh		;59e0   ; Patrones de la banda de arriba
	call lee_la_entrada_de_la_tabla		;59e3
	ld hl,02260h		;59e6   ; Solo una vez: al reflejo lo copia 0x5A4D
	call vuelca_el_guion_con_destino_en_hl		;59e9
	pop af			;59ec
	push af			;59ed
	ld hl,05967h		;59ee   ; Colores de la banda del medio
	call lee_la_entrada_de_la_tabla		;59f1
	push de			;59f4
	ld hl,00880h		;59f5   ; 0x0880 y 0x0C40: la misma distancia que la copia, 0x3C0
	call vuelca_el_guion_con_destino_en_hl		;59f8
	pop de			;59fb
	ld hl,00c40h		;59fc
	call vuelca_el_guion_con_destino_en_hl		;59ff
	pop af			;5a02
	push af			;5a03
	ld hl,0595fh		;5a04   ; Patrones de la banda del medio
	call lee_la_entrada_de_la_tabla		;5a07
	ld hl,02880h		;5a0a
	call vuelca_el_guion_con_destino_en_hl		;5a0d
	pop af			;5a10
	push af			;5a11
	ld hl,05977h		;5a12   ; Colores de la banda de abajo
	call lee_la_entrada_de_la_tabla		;5a15
	push de			;5a18
	ld hl,013c0h		;5a19   ; 0x13C0 y 0x1780, otra vez 0x3C0
	call vuelca_el_guion_con_destino_en_hl		;5a1c
	pop de			;5a1f
	ld hl,01780h		;5a20
	call vuelca_el_guion_con_destino_en_hl		;5a23
	pop af			;5a26
	ld hl,0596fh		;5a27   ; Patrones de la banda de abajo
	call lee_la_entrada_de_la_tabla		;5a2a
	ld hl,033c0h		;5a2d
	call vuelca_el_guion_con_destino_en_hl		;5a30
	ld de,0b898h		;5a33   ; El suelo de serie; 0x5A93 lo cambia por el de la ronda
	push de			;5a36
	ld hl,01080h		;5a37   ; Su color, las dos veces
	call vuelca_el_guion_con_destino_en_hl		;5a3a
	pop de			;5a3d
	ld hl,01440h		;5a3e
	call vuelca_el_guion_con_destino_en_hl		;5a41
	ld de,0b819h		;5a44   ; Y su patron, una
	ld hl,03080h		;5a47
	call vuelca_el_guion_con_destino_en_hl		;5a4a

; ----------------------------------------------------------------------
; ---------------------------------------------------------------------
; EL ESPEJO. Tres tramos de la tabla de patrones copiados sobre si
; mismos con los ocho bits del reves. No se refleja la pantalla: se
; reflejan los PATRONES, y la mitad derecha son los mismos dibujos.
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------
; ----------------------------------------------------------------------
espeja_el_decorado:
	ld hl,02200h		;5a4d   ; La banda de arriba: 0x2200 -> 0x2500
	ld de,02500h		;5a50
	ld bc,00300h		;5a53   ; 0x300 bytes, o sea 96 patrones
	call copia_dando_la_vuelta		;5a56
	ld hl,02880h		;5a59   ; La del medio: 0x2880 -> 0x2C40
	ld de,02c40h		;5a5c
	ld bc,003c0h		;5a5f
	call copia_dando_la_vuelta		;5a62
L_5A65:
	ld hl,03080h		;5a65   ; Y el suelo: 0x3080 -> 0x3440
	ld de,03440h		;5a68
	ld bc,003c0h		;5a6b
	call copia_dando_la_vuelta		;5a6e
	ld a,(0e002h)		;5a71   ; Con dos jugadores no hay nada mas que hacer
	bit 5,a		;5a74
	ret nz			;5a76
	call el_escenario_de_la_ronda		;5a77   ; Escenario 3: ademas hay que poner el marcador de fase
	cp 003h		;5a7a
	ret nz			;5a7c
	jp L_7C76		;5a7d
copia_dando_la_vuelta:
	call 0004ah		;5a80   ; BIOS RDVRM - Reads the content of VRAM | Leer el patron de origen
	call vuelve_los_bits		;5a83   ; Darle la vuelta a los ocho bits
	ex de,hl			;5a86
	call 0004dh		;5a87   ; BIOS WRTVRM - Writes data in VRAM | Y escribirlo en el destino
	ex de,hl			;5a8a
	inc hl			;5a8b
	inc de			;5a8c
	dec bc			;5a8d   ; Hasta agotar BC
	ld a,b			;5a8e
	or c			;5a8f
	jr nz,copia_dando_la_vuelta		;5a90
	ret			;5a92
pon_el_suelo_de_la_ronda:
	call el_escenario_de_la_ronda		;5a93   ; A = el escenario de esta ronda
	push af			;5a96
	ld hl,0593fh		;5a97   ; Su suelo en color...
	call lee_la_entrada_de_la_tabla		;5a9a
	push de			;5a9d
	ld hl,01080h		;5a9e   ; ...a 0x1080 y a 0x1440
	call vuelca_el_guion_con_destino_en_hl		;5aa1
	pop de			;5aa4
	ld hl,01440h		;5aa5
	call vuelca_el_guion_con_destino_en_hl		;5aa8
	pop af			;5aab
	ld hl,0592fh		;5aac   ; ...y en patron
	call lee_la_entrada_de_la_tabla		;5aaf
	ld hl,03080h		;5ab2   ; A 0x3080, que 0x5A65 reflejara a 0x3440
	call vuelca_el_guion_con_destino_en_hl		;5ab5
	jr L_5A65		;5ab8   ; Y a reflejar
sube_los_sprites_del_muneco:
	ld b,010h		;5aba   ; Los dieciseis guiones de sprite
L_5ABC:
	push bc			;5abc
	ld hl,05b02h		;5abd   ; La tabla de guiones...
	ld a,b			;5ac0
	dec a			;5ac1   ; ...que va de 0 a 15
	call lee_la_entrada_de_la_tabla		;5ac2
	push de			;5ac5
	ld hl,05b22h		;5ac6   ; Y la de destinos, en paralelo
	ld a,b			;5ac9
	dec a			;5aca
	call lee_la_entrada_de_la_tabla		;5acb
	ex de,hl			;5ace
	pop de			;5acf
	call vuelca_el_guion_con_destino_en_hl		;5ad0   ; Volcar con el destino en HL
	pop bc			;5ad3
	djnz L_5ABC		;5ad4
	ld hl,01a00h		;5ad6   ; Los patrones de 0x1A00...
	ld de,01910h		;5ad9   ; ...se espejan sobre 0x1910
	ld c,030h		;5adc   ; 0x30 sprites
	jp espeja_sprites		;5ade
sube_el_guion_de_sprite_suelto:
	ld de,0a7d1h		;5ae1   ; El guion suelto, el que no pasa por tabla
	jr L_5AEF		;5ae4
sube_el_guion_del_pozo_de_la_ronda:
	call el_escenario_de_la_ronda		;5ae6   ; El escenario de la ronda...
	ld hl,05af2h		;5ae9   ; ...elige uno de los siete del pozo
	call lee_la_entrada_de_la_tabla		;5aec
L_5AEF:
	jp guion_rle		;5aef   ; Se vuelca con el destino metido dentro

; ----------------------------------------------------------------------
; DATOS tabla_de_guiones_del_pozo: ocho punteros a los guiones de 0xA87E en
;   adelante; los carga 0x5AE9
;   0x5af2..0x5b02  (16 bytes)
DATA_tabla_de_guiones_del_pozo:
	defw 0a87eh,0a87eh,0a8dch,0a9bch,0a90eh,0a8bbh,0a93fh,0a983h	; 5af2

; ----------------------------------------------------------------------
; DATOS tabla_de_guiones_de_sprite: dieciseis punteros a los guiones de 0xA490
;   en adelante
;   0x5b02..0x5b22  (32 bytes)
DATA_tabla_de_guiones_de_sprite:
	defw 0a490h,0a4a7h,0a4c1h,0a4d5h,0a522h,0a56bh,0a583h,0a58dh	; 5b02
	defw 0a5d8h,0a5f1h,0a645h,0a6aeh,0a6fch,0a753h,0a762h,0a79ch	; 5b12

; ----------------------------------------------------------------------
; DATOS destinos_de_los_sprites: las dieciseis direcciones de VRAM, de 0x1A00
;   a 0x1EE0, todas dentro de los patrones de sprite (0x1800 por el registro
;   6)
;   0x5b22..0x5b42  (32 bytes)
DATA_destinos_de_los_sprites:
	defw 01a00h,01a20h,01a40h,01a80h,01b00h,01b60h,01b80h,01ba0h	; 5b22
	defw 01c20h,01c40h,01ca0h,01d40h,01de0h,01e60h,01ea0h,01ee0h	; 5b32

; ======================================================================
; CODIGO 0x5b42..0x5be4  (162 bytes)
; ======================================================================


pinta_la_fila_3_y_los_dos_nombres:
	ld de,06006h		;5b42   ; La fila 3 del decorado
	call guion_rle		;5b45
	call pinta_los_contadores_de_vidas		;5b48   ; El contador de vidas
	jp L_445E		;5b4b   ; Y los nombres de los dos que pelean
monta_el_decorado_o_la_oleada:
	ld a,(0e107h)		;5b4e   ; El modo de juego
	and 003h		;5b51
	cp 003h		;5b53
	ld a,(0e2e0h)		;5b55   ; El decorado que toca
	jr nz,monta_la_oleada		;5b58   ; Fuera del modo 3 son las oleadas
	push af			;5b5a
	ld hl,05ffeh		;5b5b   ; El decorado de arriba
	call lee_la_entrada_de_la_tabla		;5b5e
	ld hl,038a0h		;5b61   ; De la fila 5 para abajo
	call vuelca_el_guion_con_destino_en_hl		;5b64
	pop af			;5b67
	and a			;5b68   ; Los decorados 0 y 3...
	jr z,L_5BD5		;5b69
	cp 003h		;5b6b
	jr z,L_5BD5		;5b6d   ; ...llevan ademas las dos filas de abajo
	ret			;5b6f

; ----------------------------------------------------------------------
; ---------------------------------------------------------------------
; UNA PANTALLA DE OLEADAS SON CUATRO BYTES. La tira de 0x5BE8 trae ocho
; nibbles, cada nibble elige una figura de las treinta de 0x5C64, y las
; ocho se pintan en fila de cuatro en cuatro columnas.
; ----------------------------------------------------------------------
monta_la_oleada:
	push af			;5b70
	ld hl,05be8h		;5b71   ; Las cuatro tiras
	call lee_la_entrada_de_la_tabla		;5b74   ; La que toque por decorado
	ld a,(0e060h)		;5b77   ; La fase...
	add a,a			;5b7a   ; ...por cuatro: cada fase son cuatro bytes
	add a,a			;5b7b
	call suma_a_a_de		;5b7c
	pop af			;5b7f
	push af			;5b80
	push de			;5b81
	ld hl,05c20h		;5b82   ; Y la tabla de figuras
	call lee_la_entrada_de_la_tabla		;5b85
	ex de,hl			;5b88
	pop de			;5b89
	pop af			;5b8a
	push af			;5b8b
	cp 002h		;5b8c   ; El decorado 2...
	ld a,007h		;5b8e   ; ...pinta en la fila 6 en vez de la 7
	jr nz,L_5B94		;5b90
	ld a,006h		;5b92
L_5B94:
	ld (0e170h),a		;5b94   ; Ahi va la fila
	ld c,000h		;5b97   ; Empezando por la columna 0
	ld b,008h		;5b99   ; Ocho figuras
L_5B9B:
	push hl			;5b9b
	push bc			;5b9c
	push de			;5b9d
	ld a,(de)			;5b9e   ; El byte de la tira
	bit 0,b		;5b9f   ; Las pares van en el nibble bajo...
	jr nz,L_5BA7		;5ba1
	rra			;5ba3   ; ...y las impares en el alto
	rra			;5ba4
	rra			;5ba5
	rra			;5ba6
L_5BA7:
	and 00fh		;5ba7   ; Ese nibble elige la figura
	call lee_la_entrada_de_la_tabla		;5ba9
	ld a,c			;5bac
	ld (0e171h),a		;5bad   ; La columna
	call pinta_figura_sin_sprites		;5bb0   ; Y a pintarla
	pop de			;5bb3
	pop bc			;5bb4
	bit 0,b		;5bb5   ; Cada dos figuras...
	jr z,L_5BBA		;5bb7
	inc de			;5bb9   ; ...se gasta un byte de la tira
L_5BBA:
	ld a,004h		;5bba   ; Cuatro columnas de separacion
	add a,c			;5bbc
	ld c,a			;5bbd
	pop hl			;5bbe
	djnz L_5B9B		;5bbf
	pop af			;5bc1
	cp 002h		;5bc2   ; En el decorado 2 no hay mas
	jr z,L_5BD5		;5bc4
	ld hl,05be4h		;5bc6   ; Y si no, la cabecera de la oleada
	call suma_a_a_hl		;5bc9
	ld a,(hl)			;5bcc
	ld hl,038a0h		;5bcd
	ld c,020h		;5bd0
	call rellena_c_bytes_con_filvrm		;5bd2
L_5BD5:
	ld hl,05f38h		;5bd5
	ld a,(0e2e0h)		;5bd8
	call lee_la_entrada_de_la_tabla		;5bdb
	ld hl,03aa0h		;5bde
	jp vuelca_el_guion_con_destino_en_hl		;5be1

; ----------------------------------------------------------------------
; DATOS cabecera_de_las_oleadas: cuatro bytes que carga 0x5BC6
;   0x5be4..0x5be8  (4 bytes)
DATA_cabecera_de_las_oleadas:
	defb 009h,006h,000h,04ch	; 5be4

; ----------------------------------------------------------------------
; DATOS tabla_de_las_tiras: cuatro punteros a las tiras de nibbles
;   0x5be8..0x5bf0  (8 bytes)
DATA_tabla_de_las_tiras:
	defw 05bf0h,05bfch,05c14h,05c08h	; 5be8  -> DATA_las_cuatro_tiras 0x5bfc 0x5c14 0x5c08

; ----------------------------------------------------------------------
; DATOS las_cuatro_tiras: doce bytes cada una: tres posiciones de cuatro
;   bytes, y cada byte son dos objetos
;   0x5bf0..0x5c20  (48 bytes)
DATA_las_cuatro_tiras:
	defb 054h,044h,054h,067h,055h,054h,045h,056h,045h,045h,045h,045h	; 5bf0  TDTgUTEVEEEE
	defb 023h,045h,001h,067h,001h,023h,045h,067h,045h,001h,067h,023h	; 5bfc  #E.g.#EgE.g#
	defb 023h,054h,056h,077h,021h,023h,054h,056h,001h,021h,023h,054h	; 5c08  #TVw!#TV.!#T
	defb 001h,023h,001h,023h,034h,050h,012h,033h,045h,001h,023h,045h	; 5c14  .#.#4P.3E.#E

; ----------------------------------------------------------------------
; DATOS tablas_de_figuras: cinco tablas seguidas: una de 4 punteros a las
;   otras y luego las de 8, 8, 8 y 6 figuras; las 34 entradas ocupan justo
;   hasta 0x5C64, donde empieza la primera figura
;   0x5c20..0x5c64  (68 bytes)
DATA_tablas_de_figuras:
	defw 05c28h,05c38h,05c58h,05c48h,05c64h,05c88h,05caeh,05cd4h	; 5c20
	defw 05cf2h,05d12h,05d38h,05d5dh,05d82h,05d8eh,05d9ch,05da8h	; 5c30
	defw 05db9h,05dc7h,05dd6h,05de9h,05df9h,05e1eh,05e3ah,05e53h	; 5c40
	defw 05e74h,05e90h,05each,05ec6h,05edeh,05ef6h,05f07h,05f17h	; 5c50
	defw 05f1dh,05f31h	; 5c60

; ----------------------------------------------------------------------
; DATOS las_treinta_figuras: las figuras que se pintan en las oleadas, en el
;   formato de 0x67F5: alto, ancho y las casillas con dos ordenes de RLE
;   -repetir y SECUENCIA ASCENDENTE-. Las treinta encajan una detras de otra y
;   la ultima acaba justo en 0x5F38, que es la siguiente direccion que el
;   codigo carga (desde 0x5BD5)
;   0x5c64..0x5f38  (724 bytes)
DATA_las_treinta_figuras:
	defb 00ah,004h,0e4h,04ch,0b0h,04fh,050h,051h,000h,010h,011h,018h,022h,023h,023h,022h,023h,028h,029h,028h,02fh,02dh,02fh,02fh,03bh,031h,02fh,031h,0e4h,049h,0e4h,000h,05ah,05ah,05bh,000h	; 5c64  ...L.OPQ...."##"#()(/-//;1/1.I..ZZ[.
	defb 00ah,004h,0e4h,04ch,0b3h,04dh,04dh,053h,017h,016h,015h,016h,023h,010h,022h,000h,029h,022h,029h,028h,030h,031h,02fh,031h,02fh,031h,03dh,005h,0e4h,049h,000h,000h,053h,000h,000h,05ah,05ch,05ah	; 5c88  ...L.MMS....#.".)")(01/1/1=..I..S..Z\Z
	defb 00ah,004h,0e4h,04ch,0b3h,051h,0b1h,04dh,0f4h,017h,000h,022h,024h,024h,022h,029h,022h,02bh,031h,031h,034h,034h,005h,062h,042h,005h,049h,04ah,060h,049h,000h,056h,055h,056h,000h,05bh,05dh,0d3h	; 5cae  ...L.Q.M..."$$")"+1144.bB.IJ`I.VUV.[].
	defb 00ah,004h,0e4h,04ch,0e4h,04dh,0f3h,01fh,092h,000h,025h,026h,09ch,0e4h,02bh,038h,039h,0b0h,035h,043h,0bbh,005h,005h,0e4h,049h,0e5h,000h,05ah,0d2h,0d3h	; 5cd4  ...L.M....%&..+89.5C....I..Z..
	defb 00ah,004h,0e4h,04ch,0e4h,04dh,01bh,08eh,01dh,01eh,089h,000h,089h,000h,0e4h,02bh,0f3h,035h,036h,0e3h,005h,043h,0e4h,049h,000h,000h,0cbh,000h,000h,0d2h,0d4h,0d2h	; 5cf2  ...L.M.........+.56..C.I........
	defb 00ah,004h,0e4h,04ch,051h,0b1h,053h,0b1h,091h,090h,08fh,090h,09ch,000h,09ch,000h,0e4h,02bh,0ach,0afh,0aeh,0afh,0bbh,0bah,005h,005h,061h,0d8h,04ah,049h,0ceh,0cdh,0cch,000h,05bh,0d5h,0d2h,000h	; 5d12  ...LQ.S..........+........a.JI....[...
	defb 00ah,004h,0e4h,04ch,051h,0b1h,04dh,04dh,091h,090h,08dh,090h,089h,023h,022h,023h,029h,022h,028h,022h,0a9h,0a9h,02fh,02fh,0bbh,005h,031h,02fh,0e4h,049h,0cbh,0e3h,000h,0d4h,0d2h,0d3h,000h	; 5d38  ...LQ.MM.....#"#)"("..//..1/.I.......
	defb 00ah,004h,0e4h,04ch,04dh,0b0h,0b3h,04dh,01dh,089h,08eh,08dh,023h,022h,010h,023h,029h,028h,0a1h,023h,02fh,02fh,0a5h,03ah,0a8h,0f4h,046h,049h,051h,052h,0e3h,000h,0c6h,000h,0d2h,0d2h,0d3h	; 5d5d  ...LM..M....#".#)(.#//.:..FIQR.......
	defb 005h,004h,0e8h,006h,05dh,0e6h,006h,088h,061h,05eh,062h,055h	; 5d82  ....]...a^bU
	defb 005h,004h,0e9h,006h,063h,010h,092h,061h,0ceh,055h,000h,062h,0e3h,000h	; 5d8e  ....c..a.U.b..
	defb 003h,004h,0e4h,006h,053h,0aeh,0afh,056h,047h,043h,042h,0bfh	; 5d9c  ....S..VGCB.
	defb 004h,004h,0e3h,006h,0aeh,04eh,0afh,0bbh,052h,042h,047h,017h,033h,000h,000h,055h,000h	; 5da8  .....N..RBG.3..U.
	defb 003h,004h,056h,0bbh,006h,006h,052h,008h,053h,0aeh,097h,0bfh,039h,017h	; 5db9  ..V...R.S...9.
	defb 004h,004h,006h,006h,058h,0e5h,006h,089h,061h,01ah,006h,0bfh,042h,0bfh,060h	; 5dc7  ....X...a...B.`
	defb 005h,004h,006h,006h,058h,0e5h,006h,011h,01ah,061h,012h,0abh,040h,043h,0bbh,000h,055h,000h,000h	; 5dd6  ....X....a..@C..U..
	defb 004h,004h,0e4h,006h,04fh,04eh,056h,0bbh,0b1h,033h,000h,0aah,0bfh,055h,000h,058h	; 5de9  ....ONV..3...U.X
	defb 00ah,004h,0e4h,050h,051h,053h,055h,055h,013h,000h,045h,004h,016h,015h,019h,026h,02eh,02eh,02dh,02eh,091h,023h,017h,000h,033h,015h,015h,023h,0e3h,000h,019h,03dh,03dh,0e4h,000h,03dh,000h	; 5df9  ...PQSUU..E....&..-..#..3..#...==..=.
	defb 00ah,004h,0e4h,050h,0e4h,055h,0e4h,004h,0e4h,027h,046h,029h,029h,02ah,0e4h,000h,017h,0e3h,000h,023h,024h,091h,015h,0e5h,000h,03dh,03eh,000h	; 5e1e  ...P.U...'F))*.....#$....=>.
	defb 00ah,004h,0e4h,050h,0e4h,055h,0e4h,004h,0e4h,027h,000h,047h,0bfh,0a2h,0e9h,000h,091h,017h,016h,0e4h,000h,03dh,03eh,03dh,000h	; 5e3a  ...P.U...'.G.........=>=.
	defb 009h,004h,0e4h,050h,055h,055h,0b3h,0b1h,004h,0bdh,000h,000h,09eh,019h,000h,08fh,0a1h,0a0h,02eh,02dh,0e3h,000h,03dh,000h,016h,016h,08fh,019h,015h,015h,0e4h,000h,03dh	; 5e53  ...PUU.............-..=.........=
	defb 00ah,004h,056h,0b6h,050h,050h,000h,000h,04dh,0e5h,000h,03ah,015h,03ah,019h,02ch,02dh,02ch,02dh,0eah,000h,03eh,03dh,0e4h,000h,03dh,0e3h,000h	; 5e74  ..V.PP..M..:.:.,-,-..>=..=..
	defb 009h,004h,050h,056h,0b6h,050h,051h,000h,000h,04dh,0e4h,000h,03ah,015h,091h,016h,02ch,02bh,02dh,02eh,000h,03dh,0e8h,000h,03dh,0e4h,000h,03dh	; 5e90  ..PV.PQ..M..:...,+-..=..=..=
	defb 009h,004h,0e4h,050h,051h,053h,055h,055h,000h,000h,045h,004h,015h,019h,091h,026h,02eh,02dh,02ch,02eh,0ebh,000h,03dh,03dh,0e3h,000h	; 5eac  ...PQSUU..E....&.-,...==..
	defb 009h,004h,0e4h,050h,0e4h,055h,0e4h,004h,0e4h,027h,0a0h,0e3h,048h,03dh,0e3h,03eh,0e4h,000h,03eh,0e4h,000h,03dh,000h,000h	; 5ec6  ...P.U...'..H=.>..>..=..
	defb 006h,004h,0f3h,064h,064h,064h,06ah,0cah,06bh,064h,065h,0cch,06fh,0d9h,0dah,0dbh,064h,064h,061h,067h,063h,0e3h,064h,060h	; 5ede  ...dddj.kde.o...ddagc.d`
	defb 006h,003h,067h,064h,064h,0f3h,06ch,0e3h,064h,065h,0ddh,0deh,068h,0d9h,061h,0e3h,064h	; 5ef6  ..gdd.l.de..h.a.d
	defb 006h,004h,0e8h,064h,06eh,067h,0cah,064h,064h,0ddh,064h,064h,0deh,062h,0e6h,064h	; 5f07  ...dng.dd.dd.b.d
	defb 006h,003h,0e9h,064h,0e9h,064h	; 5f17
	defb 006h,004h,064h,068h,069h,0c9h,064h,064h,070h,0d0h,064h,064h,071h,0d1h,064h,064h,05fh,0d7h,0e8h,064h	; 5f1d  ..dhi.ddp.ddq.dd_..d
	defb 006h,003h,0c8h,0e8h,064h,0e9h,064h	; 5f31

; ----------------------------------------------------------------------
; DATOS tabla_de_las_dos_filas_de_abajo: cuatro punteros; la tabla cierra
;   justo en 0x5F40, su entrada mas baja
;   0x5f38..0x5f40  (8 bytes)
DATA_tabla_de_las_dos_filas_de_abajo:
	defw 05f40h,05f82h,05ff9h,05fb7h	; 5f38  -> DATA_guiones_de_las_dos_filas_de_abajo 0x5f82 0x5ff9 0x5fb7

; ----------------------------------------------------------------------
; DATOS guiones_de_las_dos_filas_de_abajo: los cuatro, en orden de direccion;
;   los cuatro vuelcan 64 casillas, o sea dos filas enteras; 4 guion(es),
;   medidos con tools/formatos.py
;   0x5f40..0x5ffe  (190 bytes)
DATA_guiones_de_las_dos_filas_de_abajo:
	defb 0c0h,078h,079h,078h,079h,078h,079h,078h,079h,078h,079h,078h,079h,078h,079h,078h,079h,078h,079h,078h,079h,078h,079h,078h,079h,078h,079h,078h,079h,078h,079h,078h,079h,07ah,07bh,07ah,07bh,07ah,07bh,07ah,07bh,07ah,07bh,07ah,07bh,07ah,07bh,07ah,07bh,07ah,07bh,07ah,07bh,07ah,07bh,07ah,07bh,07ah,07bh,07ah,07bh,07ah,07bh,07ah,07bh,000h	; 5f40  .xyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyz{z{z{z{z{z{z{z{z{z{z{z{z{z{z{z{.
	defb 0a6h,006h,078h,079h,078h,078h,07ah,079h,078h,078h,078h,0f1h,006h,078h,006h,078h,079h,0f2h,078h,078h,006h,078h,078h,006h,006h,078h,079h,078h,006h,006h,006h,079h,078h,006h,006h,006h,07ah,07bh,07ch,00ch,006h,088h,07ah,006h,006h,006h,07ah,07bh,07ch,0f2h,006h,006h,000h	; 5f82  ..xyxxzyxxx..x.xy.xx.xx..xyx...yx...z{|...z...z{|....
	defb 0c0h,078h,0f0h,079h,079h,0f0h,078h,0f0h,079h,079h,0f0h,078h,0f0h,079h,079h,0f0h,078h,0f0h,079h,079h,0f0h,078h,0f0h,079h,079h,0f0h,078h,0f0h,079h,079h,0f0h,078h,0f0h,07ah,07bh,07ch,0f4h,0f3h,07ah,07bh,07ch,0f4h,0f3h,07ah,07bh,07ch,0f4h,0f3h,07ah,07bh,07ch,0f4h,0f3h,07ah,07bh,07ch,0f4h,0f3h,07ah,07bh,07ch,0f4h,0f3h,07ah,07bh,000h	; 5fb7  .x.yy.x.yy.x.yy.x.yy.x.yy.x.yy.x.z{|..z{|..z{|..z{|..z{|..z{|..z{.
	defb 020h,078h,020h,079h,000h	; 5ff9

; ----------------------------------------------------------------------
; DATOS tabla_del_decorado_de_arriba: cuatro punteros; cierra en 0x6006... que
;   no es su entrada mas baja sino el guion que carga 0x5B42, pegado delante
;   de las cuatro
;   0x5ffe..0x6006  (8 bytes)
DATA_tabla_del_decorado_de_arriba:
	defw 0601ah,0611ah,06328h,06230h	; 5ffe  -> DATA_guiones_del_decorado_de_arriba 0x611a 0x6328 0x6230

; ----------------------------------------------------------------------
; DATOS guion_de_la_fila_3: una fila entera de 32 casillas en 0x3860; lo
;   suelta 0x5B42 con guion_rle, o sea con el destino metido dentro; 1
;   guion(es), medidos con tools/formatos.py
;   0x6006..0x601a  (20 bytes)
DATA_guion_de_la_fila_3:
	defb 060h,038h,004h,000h,081h,042h,009h,04bh,084h,006h,040h,041h,006h,009h,04bh,081h,0a2h,004h,000h,000h	; 6006  `8...B.K..@A..K.....

; ----------------------------------------------------------------------
; DATOS guiones_del_decorado_de_arriba: los cuatro de 0x5FFE, en orden de
;   direccion; vuelcan 352, 352, 512 y 352 casillas y la cadena acaba al byte
;   en 0x6464; 4 guion(es), medidos con tools/formatos.py
;   0x601a..0x6464  (1098 bytes)
DATA_guiones_del_decorado_de_arriba:
	defb 020h,009h,020h,04ch,08bh,0b0h,04fh,050h,051h,0b3h,04dh,04dh,053h,0b3h,051h,0b1h,009h,04dh,086h,051h,0b1h,053h,0b1h,051h,0b1h,003h,04dh,0aah,0b0h,0b3h,04dh,000h,010h,011h,018h,017h,016h,015h,016h,017h,018h,019h,01ah,01bh,08eh,01dh,01eh,01fh,020h,021h,092h,091h,090h,08fh,090h,091h,090h,08dh,090h,01dh,089h,08eh,08dh,022h,023h,023h,022h,023h,010h,022h,003h,000h,002h,024h,09ch,000h,024h,011h,011h,000h,025h,026h,09ch,09ch,000h,09ch,000h,089h,023h,022h,023h,023h,022h,010h,023h,023h,028h,029h,028h,029h,022h,029h,028h,00fh,02bh,002h,029h,0a1h,022h,028h,022h,029h,028h,029h,023h,02fh,02dh,02fh,02fh,030h,031h,02fh,031h,031h,033h,034h,034h,035h,036h,037h,036h,038h,039h,0b0h,035h,0ach,037h,0aeh,0afh,0a9h,0a9h,004h,02fh,0a2h,0a5h,03ah,03bh,031h,02fh,031h,02fh,031h,03dh,03eh,03fh,040h,041h,042h,043h,005h,044h,045h,045h,0bch,005h,043h,0bbh,0bah,005h,005h,0bbh,005h,031h,02fh,0a8h,046h,047h,048h,00ah,049h,08dh,04ah,04bh,049h,04ch,04dh,04eh,0c6h,0c5h,0c4h,0c1h,04fh,0c3h,0c2h,007h,0c1h,082h,051h,052h,008h,000h,091h,053h,000h,054h,055h,056h,057h,058h,059h,0d1h,0d0h,0cfh,000h,0ceh,0cdh,0cch,000h,0cbh,006h,000h,09ah,050h,05ah,05ah,05bh,05ah,000h,05bh,05ah,05ah,05ch,000h,05bh,05dh,0d3h,05eh,05fh,000h,000h,0d7h,0d6h,0d3h,05bh,0d5h,05bh,0d2h,0d4h,003h,0d2h,084h,000h,0d2h,0d2h,0d3h,000h	; 601a   . L..OPQ.MMS.Q..M.Q.S.Q..M...M................. !............."##"#."...$..$...%&......#"##".##()()")(.+.)."(")()#/-//01/11344567689.5.7...../..:;1/1/1=>?@ABC.DEE..C......1/.FGH.I.JKILMN....O.....QR...S.TUVWXY............PZZ[Z.[ZZ\.[].^_.....[.[..........
	defb 024h,006h,094h,04dh,006h,006h,04eh,0aeh,04fh,050h,04fh,04eh,051h,0b1h,0aeh,04fh,0b1h,051h,008h,0b1h,0aeh,04fh,04eh,009h,006h,08fh,04dh,006h,006h,04eh,050h,051h,052h,008h,008h,053h,008h,008h,052h,008h,054h,003h,008h,08ch,0b2h,0b4h,008h,0b2h,008h,0b1h,0aeh,0b0h,0aeh,006h,006h,0adh,003h,006h,084h,010h,011h,008h,012h,003h,008h,0b3h,014h,015h,014h,008h,017h,014h,018h,019h,091h,090h,08ch,08fh,008h,08ch,08dh,008h,08ch,012h,008h,089h,088h,01ah,092h,089h,01ah,008h,008h,01ch,0bah,01eh,008h,008h,01fh,020h,021h,022h,023h,024h,025h,026h,027h,09dh,09ch,09bh,09ah,099h,098h,097h,008h,08ch,094h,007h,008h,09ah,03fh,000h,029h,029h,008h,03fh,02ah,02bh,02ch,02dh,02eh,02fh,030h,000h,000h,0a8h,0a7h,0a6h,0a5h,0a4h,0a3h,0a2h,0b7h,008h,0a1h,0b7h,005h,008h,08dh,031h,000h,0b2h,033h,034h,035h,033h,038h,037h,038h,039h,03ah,03bh,004h,000h,08bh,0b3h,0b2h,0b1h,0b0h,0afh,0b0h,0abh,0adh,034h,0aah,032h,004h,008h,08ch,03ch,000h,032h,03dh,03eh,03fh,040h,041h,042h,043h,000h,0bdh,006h,000h,08ah,045h,04dh,0bbh,0bah,0b9h,0b8h,0b7h,0b6h,046h,047h,004h,008h,08dh,0bfh,000h,0aah,03dh,048h,03ch,049h,051h,000h,04ch,000h,000h,04ch,004h,000h,081h,0c4h,003h,000h,094h,04dh,051h,0c1h,0b4h,0c0h,0b5h,0b8h,0a9h,008h,008h,031h,000h,000h,032h,049h,049h,051h,000h,0c5h,0c5h,00ch,000h,092h,052h,000h,04dh,0c9h,0c1h,0c1h,0b1h,047h,008h,031h,000h,0c4h,0bdh,058h,055h,056h,0cah,04ch,011h,000h,086h,0c4h,058h,059h,055h,045h,05bh,000h	; 611a  $..M..N.OPONQ..O.Q...ON...M..NPQR..S..R.T.......................................................... !"#$%&'.............?.)).?*+,-./0................1..34538789:;...........4.2...<.2=>?@ABC.....EM......FG......=H<IQ.L..L.......MQ........1..2IIQ......R.M....G.1...XUV.L....XYUE[.
	defb 020h,04ch,085h,001h,04dh,0afh,04fh,0afh,008h,050h,082h,04fh,0afh,004h,050h,084h,04fh,04dh,04dh,0afh,009h,050h,006h,001h,086h,04dh,051h,051h,0b1h,051h,0b1h,003h,001h,002h,051h,082h,0b1h,04dh,004h,001h,002h,051h,082h,053h,054h,005h,055h,016h,001h,086h,012h,001h,001h,015h,010h,043h,004h,004h,002h,015h,084h,017h,012h,018h,011h,006h,001h,091h,016h,001h,001h,08fh,001h,015h,001h,019h,001h,019h,091h,016h,015h,019h,091h,015h,026h,003h,027h,003h,001h,0a2h,017h,01bh,01ch,015h,012h,015h,016h,017h,01dh,08fh,015h,016h,015h,019h,001h,02bh,02ch,02ch,02bh,02dh,02eh,02eh,02dh,02ch,02eh,028h,029h,02ah,001h,001h,09bh,09bh,001h,015h,003h,001h,092h,015h,001h,017h,016h,030h,0a8h,030h,0a8h,030h,0a8h,030h,0a8h,030h,0a8h,030h,091h,023h,017h,006h,001h,083h,031h,032h,034h,003h,031h,096h,034h,031h,032h,035h,036h,037h,038h,039h,0b1h,039h,0b1h,039h,0b1h,039h,0b1h,039h,0b1h,033h,015h,091h,08eh,017h,004h,001h,083h,03ah,03bh,001h,003h,03ah,086h,001h,03ah,03bh,03ah,001h,03ch,003h,001h,088h,03dh,001h,03dh,03eh,03dh,001h,001h,03dh,003h,001h,084h,017h,08eh,012h,091h,006h,001h,082h,040h,041h,005h,001h,081h,03dh,005h,001h,081h,03dh,005h,001h,002h,03dh,003h,001h,084h,017h,091h,016h,012h,005h,001h,081h,042h,017h,001h,083h,017h,001h,017h,050h,001h,050h,001h,000h	; 6230   L..M.O..P.O..P.OMM..P...MQQ.Q....Q..M...Q.ST.U........C............................&.'..................+,,+-..-,.()*.............0.0.0.0.0.0.#....124.1.41256789.9.9.9.9.3.......:;..:..:;:.<...=.=>=..=..........@A...=...=...=..........B......P.P..
	defb 002h,000h,084h,04ch,000h,04ch,000h,007h,04dh,086h,04eh,04fh,050h,051h,052h,053h,007h,04dh,084h,000h,0ach,000h,0ach,003h,000h,087h,054h,04ch,0b4h,04ch,000h,005h,055h,004h,056h,088h,057h,058h,059h,05ah,0bah,05bh,0b8h,05ch,004h,056h,090h,0b5h,005h,000h,0ach,054h,0ach,0b4h,000h,000h,05dh,04ch,0bdh,04ch,000h,005h,063h,003h,000h,08ah,05eh,05fh,005h,060h,061h,0c1h,062h,005h,0bfh,0beh,003h,000h,090h,0c3h,005h,000h,0ach,05dh,0ach,0bdh,000h,000h,010h,05dh,088h,05dh,000h,005h,05eh,003h,000h,08ah,011h,005h,012h,013h,014h,015h,016h,017h,005h,089h,003h,000h,087h,0d6h,005h,000h,0d5h,010h,0d5h,088h,003h,000h,09ch,05dh,000h,05dh,000h,005h,05eh,018h,019h,091h,01ah,01bh,01ch,01dh,01eh,01fh,020h,021h,005h,092h,019h,091h,090h,0d6h,005h,000h,0d5h,000h,0d5h,004h,000h,0fch,05dh,000h,05dh,000h,005h,022h,023h,024h,025h,026h,027h,028h,029h,02ah,02bh,02ch,02dh,005h,09eh,024h,025h,09bh,09ah,005h,000h,0d5h,000h,0d5h,000h,000h,02eh,02eh,05dh,02eh,05dh,02eh,02fh,030h,031h,032h,0aah,026h,033h,034h,035h,036h,037h,038h,039h,005h,09eh,032h,0aah,030h,031h,02fh,02eh,0d5h,02eh,0d5h,02eh,02eh,03ah,03ah,05dh,03ah,03bh,03ch,03dh,03eh,03fh,040h,0b8h,041h,042h,043h,044h,045h,046h,047h,048h,049h,04ah,040h,0b8h,03eh,03fh,03dh,0b4h,0b3h,03ah,0d5h,03ah,03ah,000h,000h,05dh,000h,000h,04bh,04ch,04dh,04eh,040h,0b8h,04fh,050h,051h,052h,053h,054h,055h,056h,057h,0c7h,040h,0b8h,04dh,04eh,04ch,0c3h,000h,000h,0d5h,004h,000h,089h,05dh,000h,03ch,005h,058h,005h,005h,059h,05ah,00ah,005h,090h,059h,05ah,005h,005h,058h,005h,0b4h,000h,0d5h,000h,000h,03ah,03ah,03bh,000h,05bh,016h,05ch,085h,0d3h,000h,0b3h,03ah,03ah,000h	; 6328  ...L.L..M.NOPQRS.M........TL.L..U.V.WXYZ.[.\.V.....T....]L.L..c...^_.`a.b..........].....].]..^..........................].]..^......... !..............].].."#$%&'()*+,-..$%...........].]./012.&3456789..2.01/......::]:;<=>?@.ABCDEFGHIJ@.>?=..:.::..]..KLMN@.OPQRSTUVW.@.MNL.......].<.X..YZ...YZ..X......::;.[.\....::.

; ======================================================================
; CODIGO 0x6464..0x646c  (8 bytes)
; ======================================================================


reparte_la_subescena_del_enemigo:
	ld bc,(0e110h)		;6464   ; La escena y la subescena del enemigo
	ld a,c			;6468
	call reparte_por_tabla		;6469   ; Repartir

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_646c: 6 entradas, tras el `call reparte_por_tabla`
;   de 0x6469; detras sigue la primera, 0x6478
;   0x646c..0x6478  (12 bytes)
DATA_tabla_de_subescenas_646c:
	defw 06478h,06480h,0648eh,0649ch,064bdh,064c4h	; 646c

; ======================================================================
; CODIGO 0x6478..0x64be  (70 bytes)
; ======================================================================


L_6478:
	ld a,(0e181h)		;6478   ; Esta agarrado?
	and a			;647b
	ret nz			;647c
	jp lee_lo_que_pide		;647d   ; No: a lo suyo
L_6480:
	ld hl,0e113h		;6480   ; Su columna
L_6483:
	ld a,(0e003h)		;6483   ; El bit 1 del cuadro...
	bit 1,a		;6486
	jr z,L_648C		;6488
	inc (hl)			;648a   ; ...lo mueve a un lado...
	ret			;648b
L_648C:
	dec (hl)			;648c   ; ...o al otro: tiembla
	ret			;648d
L_648E:
	ld hl,0e003h		;648e   ; El contador de cuadros
	ld a,(hl)			;6491
	bit 3,a		;6492   ; Su bit 3 elige el fotograma
	ld b,010h		;6494
	jr z,$+56		;6496
	ld b,012h		;6498
	jr $+52		;649a
avanza_la_caida_del_jugador:
	ld a,(0e117h)		;649c   ; Hay un golpe en marcha?
	and a			;649f
	jp nz,arranca_la_orden_pedida		;64a0
	ld hl,0e10eh		;64a3   ; Por que paso va la caida
	ld a,(hl)			;64a6
	cp 006h		;64a7   ; Pasado el sexto se acabo
	jp nc,L_69D0		;64a9
	ld de,064beh		;64ac   ; Los seis fotogramas
	ld a,(hl)			;64af
	call suma_a_a_de		;64b0
	ld a,(de)			;64b3   ; El que toque
	ld (0e11dh),a		;64b4
	ld a,009h		;64b7   ; Nueve cuadros
	ld (0e117h),a		;64b9
	inc (hl)			;64bc   ; Y un paso mas
L_64BD:
	ret			;64bd

; ----------------------------------------------------------------------
; DATOS seis_por_0xe10e: 0x64AC los indexa con (0xE10E), que va de 0 a 5, y el
;   que sale acaba en (0xE11D)
;   0x64be..0x64c4  (6 bytes)
DATA_seis_por_0xe10e:
	defb 018h,006h,009h,014h,00ah,005h	; 64be

; ======================================================================
; CODIGO 0x64c4..0x64dd  (25 bytes)
; ======================================================================


L_64C4:
	call aparca_los_dieciseis_sprites_si_no_vuela_nada		;64c4   ; Aparcar los sprites
	ld a,087h		;64c7   ; El muneco vuelve a 0x87
	ld (0e112h),a		;64c9
	ld b,010h		;64cc
L_64CE:
	call elige_el_fotograma_segun_el_lado		;64ce   ; Que fotograma le toca
	ld (0e118h),a		;64d1
	ret			;64d4
reparte_la_subescena_de_0xe130:
	ld bc,(0e130h)		;64d5   ; La escena y la subescena
	ld a,c			;64d9
	call reparte_por_tabla		;64da   ; Repartir

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_64dd: 5 entradas, tras el `call reparte_por_tabla`
;   de 0x64DA; detras sigue la primera, 0x64E7
;   0x64dd..0x64e7  (10 bytes)
DATA_tabla_de_subescenas_64dd:
	defw 064e7h,064f7h,064fdh,06513h,06549h	; 64dd

; ======================================================================
; CODIGO 0x64e7..0x6543  (92 bytes)
; ======================================================================


L_64E7:
	ld a,(0e107h)		;64e7   ; El modo de juego
	and 003h		;64ea
	dec a			;64ec
	dec a			;64ed
	jp z,decide_el_siguiente		;64ee   ; El modo 2: la coreografia
	call mueve_lo_agarrado_o_reparte		;64f1   ; Si no, mover al enemigo
	jp L_7F8B		;64f4
L_64F7:
	ld hl,0e133h		;64f7   ; Su fila
	jp L_6483		;64fa   ; Y hacerla temblar
L_64FD:
	ld a,014h		;64fd   ; El fotograma 0x14
	ld (0e138h),a		;64ff
aparca_los_dieciseis_sprites_si_no_vuela_nada:
	ld a,(0e180h)		;6502   ; Hay algo volando?
	and a			;6505
	ret nz			;6506
	ld a,0e0h		;6507   ; Entonces aparcar los sprites...
	ld hl,0e1e0h		;6509
	ld b,010h		;650c   ; ...los dieciseis
escribe_seguidas:		; B bytes iguales a A, seguidos desde (HL)
	ld (hl),a			;650e   ; Un byte
	inc hl			;650f
	djnz escribe_seguidas		;6510
	ret			;6512
L_6513:
	ld a,(0e137h)		;6513   ; Hay golpe en marcha?
	and a			;6516
	jp nz,L_7D40		;6517   ; Si: seguirlo
	ld hl,0e10fh		;651a   ; Por que paso va
	ld a,(hl)			;651d
	cp 006h		;651e   ; Pasado el sexto...
	jr c,L_652B		;6520
	ld a,(0e11fh)		;6522   ; ...manda el lado
	ld (0e134h),a		;6525
	jp L_7DE2		;6528
L_652B:
	ld de,06543h		;652b   ; Los seis pares
	ld a,(hl)			;652e   ; El que toque
	call suma_a_a_de		;652f
	ld a,(de)			;6532
	and 0f0h		;6533   ; El nibble alto...
	jr z,L_6538		;6535
	inc a			;6537   ; ...mas uno si no es cero
L_6538:
	ld (0e134h),a		;6538   ; Es la orden
	ld a,(de)			;653b   ; Y el nibble bajo...
	and 00fh		;653c
	call arranca_el_golpe_de_siete_cuadros		;653e   ; ...la mueve
	inc (hl)			;6541   ; Un paso mas
	ret			;6542

; ----------------------------------------------------------------------
; DATOS seis_pares_de_nibbles: 0x652B los indexa; del byte que saca, el nibble
;   alto va a (0xE134) y el bajo se usa aparte
;   0x6543..0x6549  (6 bytes)
DATA_seis_pares_de_nibbles:
	defb 014h,005h,013h,004h,015h,003h	; 6543

; ======================================================================
; CODIGO 0x6549..0x6664  (283 bytes)
; ======================================================================


L_6549:
	ld a,001h		;6549   ; Arrancar el golpe
	ld (0e137h),a		;654b
	ret			;654e

; ----------------------------------------------------------------------
; ---------------------------------------------------------------------
; SE TOCAN DOS CAJAS? IX trae la caja que ataca -x, y y su radio- y HL
; la lista de hasta TRES cajas del otro. Cada caja son cuatro bytes:
; alto, algo, ancho y algo. Devuelve cero si no hay toque.
; ----------------------------------------------------------------------
se_tocan:
	ld a,(0e10bh)		;654f   ; Hay algo que lo impida?
	and a			;6552
	jr nz,L_659D		;6553
	ld a,(0e100h)		;6555   ; El jugador esta en pie?
	and a			;6558
	jr z,L_659D		;6559
	ld b,003h		;655b   ; Tres cajas
L_655D:
	push hl			;655d
	push bc			;655e
	ld b,(hl)			;655f   ; El alto de esta
	ld a,(hl)			;6560
	inc hl			;6561
	inc hl			;6562
	and a			;6563   ; Un cero quiere decir "no hay caja"
	jr z,L_6595		;6564
	add a,(hl)			;6566   ; Mas el ancho: el borde derecho
	ld c,a			;6567
	dec hl			;6568
	ld d,(hl)			;6569   ; Y lo mismo por el otro eje
	ld a,(hl)			;656a
	inc hl			;656b
	inc hl			;656c
	add a,(hl)			;656d
	ld e,a			;656e
	ld a,(ix+000h)		;656f   ; La x de la caja que ataca...
	sub (ix+002h)		;6572   ; ...menos su radio
	jr c,L_6595		;6575   ; Se sale por abajo: no toca
	cp c			;6577   ; Y por arriba tampoco
	jr nc,L_6595		;6578
	add a,(ix+002h)		;657a   ; Dos radios: el otro borde
	add a,(ix+002h)		;657d
	cp b			;6580   ; Comparado con el alto
	jr c,L_6595		;6581
	ld a,(ix+001h)		;6583   ; Ahora el otro eje
	sub (ix+002h)		;6586
	cp e			;6589
	jr nc,L_6595		;658a
	add a,(ix+002h)		;658c
	add a,(ix+002h)		;658f
	cp d			;6592
	jr nc,L_65A0		;6593   ; Todo cuadra: hay toque
L_6595:
	pop bc			;6595
	pop hl			;6596
	inc hl			;6597   ; La caja siguiente, cuatro bytes mas alla
	inc hl			;6598
	inc hl			;6599
	inc hl			;659a
	djnz L_655D		;659b
L_659D:
	and 000h		;659d   ; Devolver cero: no hay toque
	ret			;659f
L_65A0:
	pop bc			;65a0
	pop hl			;65a1
L_65A2:
	or 001h		;65a2
	ret			;65a4
mira_si_llego_a_su_sitio:
	ld d,(hl)			;65a5
mira_si_esta_dentro_de_la_caja_de_once:
	inc hl			;65a6   ; La otra coordenada
	ld e,(hl)			;65a7
	ld a,(0e10bh)		;65a8   ; Hay algo que lo impida?
	cp 001h		;65ab
	jr z,L_659D		;65ad
	ld a,d			;65af   ; Dos de margen por arriba...
	add a,002h		;65b0
	ld d,a			;65b2
	add a,00bh		;65b3   ; ...y once de ancho
	ld h,a			;65b5
	ld a,e			;65b6   ; Lo mismo por el otro eje
	add a,002h		;65b7
	ld e,a			;65b9
	add a,00bh		;65ba
	ld l,a			;65bc
	push hl			;65bd
	ld hl,0e12ch		;65be   ; La coordenada del jugador
	ld b,(hl)			;65c1
	inc hl			;65c2
	ld c,(hl)			;65c3
	pop hl			;65c4
	ld a,b			;65c5   ; Vale cero?
	and a			;65c6
	jr z,L_659D		;65c7
	cp d			;65c9   ; Se sale por un lado...
	jr c,L_659D		;65ca
	cp h			;65cc   ; ...o por el otro
	jr nc,L_659D		;65cd
	ld a,c			;65cf   ; Y ahora el otro eje
	cp e			;65d0
	jr c,L_659D		;65d1
	cp l			;65d3
	jr nc,L_659D		;65d4
	jr L_65A2		;65d6   ; Dentro: si toca

; ----------------------------------------------------------------------
; ---------------------------------------------------------------------
; LAS DOS BARRAS DE ENERGIA. Cada una son nueve casillas y cada casilla
; cuatro puntos, de ahi el `sub 4` repetido de 0x661D. Se pintan una
; hacia un lado y la otra hacia el otro, y el bit 0 de B es lo que
; decide cual.
; ----------------------------------------------------------------------
pinta_las_barras:
	ld de,0e101h		;65d8   ; La barra del jugador 1
	ld hl,0e108h		;65db   ; Y su aviso
	call pita_si_queda_poca_barra		;65de   ; Pitar si esta a punto de acabarse
	ld hl,0e100h		;65e1   ; Lo que hay que pintar
	call recorta_la_barra_al_tope		;65e4   ; Ha cambiado?
	jr c,L_65F1		;65e7   ; No: nada que hacer
	ld hl,03872h		;65e9   ; Donde va la barra
	ld b,000h		;65ec   ; B = 0: hacia un lado
	call elige_las_casillas_de_la_barra		;65ee
L_65F1:
	ld de,0e103h		;65f1   ; La del jugador 2
	ld hl,0e109h		;65f4
	ld a,(0e002h)		;65f7   ; Solo si hay dos jugadores
	bit 5,a		;65fa
	jr z,L_6601		;65fc
	call pita_si_queda_poca_barra		;65fe
L_6601:
	ld hl,0e102h		;6601
	call recorta_la_barra_al_tope		;6604
	ret c			;6607
	ld b,001h		;6608   ; B = 1: hacia el otro
	ld hl,0386dh		;660a   ; Y en otra fila
elige_las_casillas_de_la_barra:
	cp 00dh		;660d   ; Menos de 13 puntos...
	ld de,06669h		;660f   ; ...casillas de cifra alta...
	jr nc,L_6617		;6612
	ld de,06664h		;6614   ; ...o de cifra baja
L_6617:
	ld c,000h		;6617   ; C = cuantas casillas llenas
L_6619:
	cp 004h		;6619   ; Cuatro puntos por casilla
	jr c,L_6622		;661b
	sub 004h		;661d   ; Uno menos...
	inc c			;661f   ; ...y una casilla mas
	jr L_6619		;6620
L_6622:
	push af			;6622
	ld a,c			;6623
	and a			;6624   ; Ninguna llena?
	jr z,L_6635		;6625
	push bc			;6627
	bit 0,b		;6628   ; Si la barra va al reves...
	jr z,L_6630		;662a
	ld a,l			;662c   ; ...restar en vez de sumar
	sub c			;662d
	inc a			;662e
	ld l,a			;662f
L_6630:
	ld a,(de)			;6630   ; La casilla de "lleno"
	call rellena_c_bytes_con_filvrm		;6631   ; C veces
	pop bc			;6634
L_6635:
	pop af			;6635
	and a			;6636   ; Lo que sobra
	jr nz,L_663B		;6637
	ld a,004h		;6639   ; Cero cuenta como cuatro
L_663B:
	call suma_a_a_de		;663b   ; Y elige la casilla del resto
	ld a,c			;663e
	cp 009h		;663f   ; Con nueve llenas se acabo
	ret z			;6641
	and a			;6642
	jr z,L_664C		;6643
	inc a			;6645   ; Ajustar la posicion...
	bit 0,b		;6646   ; ...segun el lado
	call z,suma_a_a_hl		;6648
	dec l			;664b
L_664C:
	ld a,(de)			;664c
	bit 0,b		;664d
	jr z,L_6653		;664f
	add a,060h		;6651   ; En el lado de la derecha las casillas van 0x60 mas alla
L_6653:
	jp 0004dh		;6653   ; BIOS WRTVRM - Writes data in VRAM | Escribirla
recorta_la_barra_al_tope:
	ld a,(de)			;6656   ; La barra
	cp 024h		;6657   ; El tope son 0x24 puntos
	jr c,L_665E		;6659
	ld a,024h		;665b
	ld (de),a			;665d
L_665E:
	cp (hl)			;665e   ; Ya esta donde tiene que estar?
	ret c			;665f
	ret z			;6660
	dec a			;6661   ; Si no, acercarla de uno en uno
	ld (de),a			;6662
	ret			;6663

; ----------------------------------------------------------------------
; DATOS casillas_de_una_cifra_baja: cinco; 0x6614 las elige cuando el numero
;   no llega a 13
;   0x6664..0x6669  (5 bytes)
DATA_casillas_de_una_cifra_baja:
	defb 047h,044h,045h,046h,043h	; 6664

; ----------------------------------------------------------------------
; DATOS casillas_de_una_cifra_alta: las otras cinco, desde 0x660F
;   0x6669..0x666e  (5 bytes)
DATA_casillas_de_una_cifra_alta:
	defb 04bh,048h,049h,04ah,043h	; 6669

; ======================================================================
; CODIGO 0x666e..0x6922  (692 bytes)
; ======================================================================


pita_si_queda_poca_barra:
	ld a,(de)			;666e   ; Le queda poca?
	cp 00dh		;666f
	ret nc			;6671   ; Todavia no
	ld a,(hl)			;6672   ; Ya avisado?
	and a			;6673
	ret nz			;6674
	ld a,(0e10bh)		;6675   ; Hay algo que lo impida?
	and a			;6678
	ret nz			;6679
	ld a,097h		;667a   ; Marcar que ya se aviso
	ld (hl),a			;667c
	jp pide_pieza_si_la_escena_lo_permite		;667d   ; Y pitar
mira_si_alguna_barra_llego_a_cero:
	ld a,(0e10bh)		;6680   ; Hay algo que lo impida?
	and a			;6683
	ret nz			;6684
	ld de,0e101h		;6685   ; La barra del jugador 1
	ld b,003h		;6688   ; Su escena de "muerto"
	call tira_al_suelo_si_la_barra_esta_a_cero		;668a
	ld de,0e103h		;668d   ; La del 2
	ld b,002h		;6690
tira_al_suelo_si_la_barra_esta_a_cero:
	ld a,(de)			;6692   ; Le queda algo?
	and a			;6693
	ret nz			;6694   ; Si: sigue vivo
	ld a,b			;6695
	jp L_5284		;6696   ; Y si no, a la escena de caerse
anima_el_destello:
	ld hl,0e183h		;6699   ; La cuenta del destello
	ld a,(hl)			;669c
	and a			;669d   ; No hay
	jr z,L_66A6		;669e
	dec (hl)			;66a0   ; Una menos
	cp 020h		;66a1   ; Por debajo de 0x20 hay que animarlo
	jr c,L_66AC		;66a3
	ret			;66a5
L_66A6:
	ld a,0e0h		;66a6   ; Se acabo: aparcar su sprite
	ld (0e1e0h),a		;66a8
	ret			;66ab
L_66AC:
	ld a,(0e002h)		;66ac   ; Con dos jugadores no
	bit 5,a		;66af
	jr nz,L_66BF		;66b1
	ld a,(0e102h)		;66b3   ; Le queda barra al otro?
	and a			;66b6
	jr z,L_66BF		;66b7
	ld a,(0e180h)		;66b9   ; Y de quien es el tanteo?
	and a			;66bc
	jr nz,L_66C2		;66bd
L_66BF:
	xor a			;66bf   ; Nada que hacer
	ld (hl),a			;66c0
	ret			;66c1
L_66C2:
	ld hl,0e1e0h		;66c2   ; Los atributos del destello
	ld a,(0e155h)		;66c5   ; La columna del jugador...
	sub 010h		;66c8   ; ...dieciseis a la izquierda
	ld (hl),a			;66ca
	inc hl			;66cb
	inc hl			;66cc
	ld a,0cch		;66cd   ; Casilla 0xCC
	ld (hl),a			;66cf
	inc hl			;66d0
	ld a,00fh		;66d1   ; Y color 0x0F
	ld (hl),a			;66d3
	ret			;66d4

; ----------------------------------------------------------------------
; ======================================================================
; PINTAR UNA FIGURA DE CASILLAS
; ======================================================================
; Entra con DE en la figura y la posicion ya puesta en (0xE170) fila y
; (0xE171) columna. La figura se descomprime entera a 0xE480 y de ahi
; se sube a la tabla de nombres fila a fila, recortando lo que se salga
; por los lados.
; (0xE176) dice si esto pinta o BORRA: con 0xFF sube el dibujo con
; LDIRVM, y con 0 rellena de unos con FILVRM.
; ======================================================================
; ======================================================================
; ----------------------------------------------------------------------
borra_la_figura:
	xor a			;66d5   ; A = 0: la marca de borrar
	jr L_66DA		;66d6
pinta_la_figura:
	ld a,0ffh		;66d8   ; A = 0xFF: la de pintar
L_66DA:
	ld (0e176h),a		;66da   ; Queda apuntado para 0x6733
	push ix		;66dd
	call monta_los_cuatro_sprites		;66df   ; Monta los cuatro sprites y deja DE en el alto
	pop ix		;66e2
	ld a,(de)			;66e4   ; B = el alto
	ld b,a			;66e5
	inc de			;66e6
	ld a,(de)			;66e7   ; C = el ancho
	ld c,a			;66e8
	ld (0e172h),bc		;66e9   ; (0xE172) = ancho y (0xE173) = alto, por el orden del `ld (nn),bc`
	inc de			;66ed   ; DE ya apunta a las ordenes de la figura
	call descomprime_la_figura		;66ee   ; Descomprimirla a 0xE480
pon_la_figura_en_la_pantalla:
	ld hl,0e170h		;66f1   ; La fila
	ld a,(hl)			;66f4
	and a			;66f5
	ld hl,03800h		;66f6   ; El principio de la tabla de nombres
	jr z,L_6704		;66f9   ; Fila 0: no hay que bajar nada -y es la excepcion, porque el `dec a` de abajo hace que las demas caigan UNA FILA MAS ARRIBA de la pedida-
	dec a			;66fb
	ld b,a			;66fc
L_66FD:
	ld a,020h		;66fd   ; Bajar una fila son 32 casillas
	call suma_a_a_hl		;66ff
	djnz L_66FD		;6702
L_6704:
	ld a,(0e171h)		;6704   ; Ahora la columna
	ld b,a			;6707
	and a			;6708   ; Si es negativa, la figura asoma por la izquierda
	jp p,L_6718		;6709
	add a,c			;670c   ; Lo que queda dentro es ancho + columna
	ret nc			;670d   ; Si no queda nada, no se pinta
	ret z			;670e
	ld b,a			;670f   ; B = las casillas que se ven
	ld a,c			;6710
	sub b			;6711
	call suma_a_a_de		;6712   ; Saltarse en la figura las que se salen
	ld c,b			;6715   ; C = el ancho recortado
	jr vuelca_una_fila		;6716
L_6718:
	cp 020h		;6718   ; Columna 32 o mas: fuera de la pantalla
	ret nc			;671a
	add a,c			;671b   ; Se sale por la derecha?
	sub 020h		;671c
	jr nc,L_6726		;671e
	ld a,b			;6720   ; No: la fila entera, desplazada
	call suma_a_a_hl		;6721
	jr vuelca_una_fila		;6724
L_6726:
	sub c			;6726   ; Si: solo hasta el borde
	neg		;6727
	ld c,a			;6729
	ld a,b			;672a   ; Y desplazar HL a la columna
	call suma_a_a_hl		;672b
vuelca_una_fila:
	ld (0e174h),de		;672e   ; Guardar por donde va la figura
	push bc			;6732
	ld a,(0e176h)		;6733   ; Pintar o borrar?
	and a			;6736
	jr z,L_673E		;6737
	call vuelca_c_bytes_con_ldirvm		;6739   ; Pintar: subir C casillas con LDIRVM
	jr L_6743		;673c
L_673E:
	ld a,001h		;673e   ; Borrar: rellenar de unos con FILVRM
	call rellena_c_bytes_con_filvrm		;6740
L_6743:
	pop bc			;6743
	ld a,(0e173h)		;6744   ; Una fila menos
	dec a			;6747
	ld (0e173h),a		;6748
	ret z			;674b   ; Cuando se agotan, listo
	ld a,(0e172h)		;674c   ; Avanzar la figura el ancho SIN recortar
	ld de,(0e174h)		;674f
	call suma_a_a_de		;6753
	ld a,020h		;6756   ; Y bajar una fila en la pantalla
	call suma_a_a_hl		;6758
	jr vuelca_una_fila		;675b
pinta_figura_sin_sprites:
	ld a,0ffh		;675d   ; Siempre pinta; esta no borra nunca
	ld (0e176h),a		;675f
	ld a,(de)			;6762   ; B = el alto
	ld b,a			;6763
	inc de			;6764
	ld a,(de)			;6765   ; C = el ancho
	ld c,a			;6766
	ld (0e172h),bc		;6767
	inc de			;676b   ; DE, en las ordenes
	ld hl,0e480h		;676c   ; El descomprimido va a 0xE480
	push bc			;676f
	push hl			;6770
	call cuenta_las_casillas_y_lee_repitiendo		;6771   ; Con el lector que REPITE el byte, no el que pone ceros
	pop de			;6774
	pop bc			;6775
	jp pon_la_figura_en_la_pantalla		;6776   ; Y a pintar por el camino de siempre

; ----------------------------------------------------------------------
; La remision del fotograma impar: si el indice es impar, lo que hay en
; (HL) no es el dibujo sino un puntero al de al lado.
; ----------------------------------------------------------------------
sigue_la_remision:
	ld a,(ix+000h)		;6779   ; El indice del fotograma
	bit 0,a		;677c   ; Par: no hay remision que seguir
	ret z			;677e
	ld e,(hl)			;677f   ; Impar: la palabra es la direccion del dibujo bueno
	inc hl			;6780
	ld d,(hl)			;6781
	ex de,hl			;6782
	ret			;6783
descomprime_la_figura:
	push bc			;6784
	ld hl,0e480h		;6785   ; El buffer de la figura
	call cuenta_las_casillas_y_lee_a_ceros		;6788   ; Descomprimir alto*ancho casillas
	pop bc			;678b
	push bc			;678c
	ld a,(ix+000h)		;678d   ; Otra vez el indice
	bit 0,a		;6790   ; Si es impar hay que darle la vuelta
	ld de,0e480h		;6792
	ld hl,0e500h		;6795
	jr z,L_67A0		;6798
	call espeja_la_figura		;679a   ; Espejarla en 0xE500
	ld de,0e500h		;679d   ; Y pintar la espejada
L_67A0:
	pop bc			;67a0
	ret			;67a1
cuenta_las_casillas_y_lee_a_ceros:
	xor a			;67a2
L_67A3:
	add a,c			;67a3
	djnz L_67A3		;67a4
	ld b,a			;67a6

; ----------------------------------------------------------------------
; ---------------------------------------------------------------------
; EL LECTOR DE FIGURAS DE LOS ENEMIGOS. B trae alto*ancho y el bucle
; corta en cuanto lo agota, aunque sea a media orden. Su hermano de
; y ocupa dos, y aqui escribe CEROS y ocupa uno.
; ----------------------------------------------------------------------
lee_figura_a_ceros:
	ld a,(de)			;67a7   ; La orden
	cp 0f0h		;67a8   ; 0xF0..0xFF: secuencia ascendente
	jr c,L_67BC		;67aa
	and 00fh		;67ac   ; Cuantas
	ld c,a			;67ae
	inc de			;67af
	ld a,(de)			;67b0   ; Y desde que casilla
L_67B1:
	ld (hl),a			;67b1   ; Escribirla
	inc hl			;67b2
	inc a			;67b3   ; La siguiente es una mas
	dec b			;67b4   ; Una casilla menos del total
	ret z			;67b5   ; Se acabo la figura
	dec c			;67b6   ; Y una menos de la orden
	jr nz,L_67B1		;67b7
	inc de			;67b9   ; Saltarse el byte del valor
	jr lee_figura_a_ceros		;67ba
L_67BC:
	cp 0e0h		;67bc   ; 0xE0..0xEF: ceros
	jr c,L_67CE		;67be
	and 00fh		;67c0
	ld c,a			;67c2
L_67C3:
	ld (hl),000h		;67c3   ; Un cero
	inc hl			;67c5
	dec b			;67c6   ; Una casilla menos
	ret z			;67c7   ; Se acabo
	dec c			;67c8   ; Y una menos de la orden
	jr nz,L_67C3		;67c9
	inc de			;67cb   ; Esta orden NO gasta byte de valor
	jr lee_figura_a_ceros		;67cc
L_67CE:
	ld a,(de)			;67ce   ; Y si no, una casilla suelta
	ld (hl),a			;67cf
	inc de			;67d0
	inc hl			;67d1
	djnz lee_figura_a_ceros		;67d2   ; Hasta agotar el total
	ret			;67d4
espeja_la_figura:
	ld a,c			;67d5   ; Al final de la fila
	dec a			;67d6
	call suma_a_a_de		;67d7   ; Retroceder hasta ahi
	push de			;67da
	push bc			;67db
L_67DC:
	ld a,(de)			;67dc   ; La casilla de origen
	cp 010h		;67dd   ; Las casillas por debajo de 0x10 no se espejan
	jr c,L_67E9		;67df
	cp 088h		;67e1   ; Y de 0x88 en adelante...
	jr c,L_67E7		;67e3
	add a,010h		;67e5   ; ...llevan 0x10 mas
L_67E7:
	add a,078h		;67e7   ; El espejo de una casilla esta 0x78 mas alla
L_67E9:
	ld (hl),a			;67e9   ; Escribirla
	inc hl			;67ea
	dec de			;67eb   ; Leyendo del reves
	dec c			;67ec   ; Toda la fila
	jr nz,L_67DC		;67ed
	pop bc			;67ef
	pop de			;67f0
	inc de			;67f1   ; Y a la fila siguiente
	djnz espeja_la_figura		;67f2   ; Todas
	ret			;67f4

; ----------------------------------------------------------------------
; es igual salvo en el 0xE0..0xEF: alli repite el byte de detras
; ----------------------------------------------------------------------
cuenta_las_casillas_y_lee_repitiendo:
	xor a			;67f5
L_67F6:
	add a,c			;67f6
	djnz L_67F6		;67f7
	ld b,a			;67f9
lee_figura_repitiendo:
	ld a,(de)			;67fa   ; La orden
	cp 0f0h		;67fb   ; 0xF0..0xFF: secuencia ascendente
	jr c,L_680F		;67fd
	and 00fh		;67ff   ; Cuantas
	ld c,a			;6801
	inc de			;6802
	ld a,(de)			;6803   ; Y desde que casilla
L_6804:
	ld (hl),a			;6804   ; Escribirla
	inc hl			;6805
	inc a			;6806   ; La siguiente es una mas
	dec b			;6807   ; Una casilla menos del total
	ret z			;6808   ; Se acabo
	dec c			;6809
	jr nz,L_6804		;680a
	inc de			;680c   ; Saltarse el byte del valor
	jr lee_figura_repitiendo		;680d
L_680F:
	cp 0e0h		;680f   ; 0xE0..0xEF: repetir
	jr c,L_6822		;6811
	and 00fh		;6813   ; Cuantas veces
	ld c,a			;6815
	inc de			;6816
	ld a,(de)			;6817   ; Y que byte: AQUI SI hay valor
L_6818:
	ld (hl),a			;6818   ; Escribirlo
	inc hl			;6819
	dec b			;681a   ; Una menos
	ret z			;681b   ; Se acabo
	dec c			;681c
	jr nz,L_6818		;681d
	inc de			;681f   ; Saltarse el valor
	jr lee_figura_repitiendo		;6820
L_6822:
	ld a,(de)			;6822   ; Y si no, una casilla suelta
	ld (hl),a			;6823
	inc de			;6824
	inc hl			;6825
	djnz lee_figura_repitiendo		;6826   ; Hasta agotar el total
	ret			;6828

; ----------------------------------------------------------------------
; ======================================================================
; LOS CUATRO SPRITES DE UN FOTOGRAMA
; ======================================================================
; Delante de cada dibujo van cuatro sprites. Los tres primeros son
; [y][x][patron][color] y el CUARTO solo [y][x]: el `cp 1` de 0x687A
; sale del bucle antes de leerle patron y color. Un 0x80 en el sitio
; del [y] significa "este no se pinta" y ocupa un solo byte.
; Si el fotograma es IMPAR la x se NIEGA: es el mismo dibujo mirando al
; otro lado.
; ----------------------------------------------------------------------
monta_los_cuatro_sprites:
	ld a,(0e176h)		;6829   ; Pintando o borrando?
	and a			;682c
	jr nz,L_683C		;682d
	ld hl,0e190h		;682f   ; Borrando: los atributos de la copia vieja
	ld ix,0e190h		;6832
	ld iy,0e191h		;6836
	jr L_6847		;683a
L_683C:
	ld hl,0e140h		;683c   ; Pintando: los de la nueva
	ld ix,0e155h		;683f
	ld iy,0e141h		;6843
L_6847:
	ld a,(0e138h)		;6847   ; El fotograma manda
monta_los_sprites_con_a:
	ld (0e15eh),a		;684a   ; Queda apuntado: su bit 0 decide el espejo
	ld b,004h		;684d   ; Cuatro sprites, ni uno mas
L_684F:
	push bc			;684f
	ld c,(ix+000h)		;6850   ; C = la x de referencia
	ld b,(ix+001h)		;6853   ; B = la y de referencia
	ld a,(de)			;6856   ; 0x80 en el primer byte...
	cp 080h		;6857
	jr nz,L_6866		;6859   ; ...si no, es un sprite de verdad
	xor a			;685b   ; ...quiere decir sprite vacio: y y x a cero
	ld (hl),a			;685c
	inc hl			;685d
	ld (hl),a			;685e
	inc hl			;685f
	inc hl			;6860   ; Y saltarse su patron y su color
	inc hl			;6861
	inc de			;6862   ; Solo ha gastado UN byte
	pop bc			;6863
	jr L_6886		;6864
L_6866:
	add a,c			;6866   ; La y del sprite, relativa a la del muneco
	ld (hl),a			;6867
	inc hl			;6868
	inc de			;6869
	ld a,(0e15eh)		;686a   ; El fotograma otra vez
	bit 0,a		;686d   ; Impar quiere decir "mirando al otro lado"...
	ld a,(de)			;686f
	jr z,L_6874		;6870
	neg		;6872   ; ...y entonces la x va cambiada de signo
L_6874:
	add a,b			;6874   ; La x, relativa a la del muneco
	ld (hl),a			;6875
	inc hl			;6876
	inc de			;6877
	pop bc			;6878   ; B vuelve a ser la cuenta del bucle
	ld a,b			;6879
	cp 001h		;687a   ; El cuarto sprite no lleva patron ni color
	jr z,corrige_las_x_al_espejar		;687c
	ld a,(de)			;687e   ; El patron
	ld (hl),a			;687f
	inc hl			;6880
	inc de			;6881
	ld a,(de)			;6882   ; Y el color
	ld (hl),a			;6883
	inc hl			;6884
	inc de			;6885
L_6886:
	djnz L_684F		;6886   ; A por el siguiente
corrige_las_x_al_espejar:
	ld a,(0e15eh)		;6888   ; Solo si se ha espejado
	bit 0,a		;688b
	ret z			;688d
	ld b,003h		;688e   ; Los tres sprites de detras del primero
L_6890:
	ld a,(iy+000h)		;6890   ; La x de este...
	sub (iy+002h)		;6893   ; ...menos la de dos mas alla
	ld (iy+000h),a		;6896
	inc iy		;6899   ; Cuatro bytes por atributo
	inc iy		;689b
	inc iy		;689d
	inc iy		;689f
	djnz L_6890		;68a1
	ret			;68a3

; ----------------------------------------------------------------------
; ======================================================================
; MOVER AL ENEMIGO
; ======================================================================
; Primero lo borra donde estaba -con el fotograma y la posicion VIEJOS,
; que guarda en 0xE151 y 0xE153- y luego lo pinta donde toca. Los dos
; dibujos salen del bloque que le corresponda al escenario.
; ----------------------------------------------------------------------
mueve_al_enemigo:
	call el_escenario_de_la_ronda		;68a4   ; El escenario de la ronda
	push af			;68a7
	ld hl,06922h		;68a8   ; Su bloque de fotogramas
	call lee_la_entrada_de_la_tabla		;68ab
	ex de,hl			;68ae
	pop af			;68af
	push hl			;68b0   ; Hara falta otra vez para pintar
	cp 000h		;68b1   ; En el escenario 0 el enemigo es especial
	jr nz,borralo_donde_estaba		;68b3
	ld a,(0e1d7h)		;68b5   ; Si ya esta puesto, no hay nada que hacer
	and a			;68b8
	jr z,L_68BD		;68b9
	pop hl			;68bb
	ret			;68bc
L_68BD:
	ld hl,03a00h		;68bd   ; Si no, limpiar la ultima banda de la pantalla
	ld c,0a0h		;68c0
	xor a			;68c2
	call rellena_c_bytes_con_filvrm		;68c3   ; 0xA0 casillas a cero
	jr ahora_pintalo_donde_toca		;68c6
borralo_donde_estaba:
	ld ix,0e153h		;68c8   ; El fotograma VIEJO
	ld a,(ix+000h)		;68cc
	call lee_la_entrada_de_la_tabla		;68cf   ; Su entrada en el bloque
	ld hl,0e152h		;68d2
	ex de,hl			;68d5
	ld a,(de)			;68d6   ; La columna vieja...
	add a,(hl)			;68d7   ; ...mas el dy de la entrada
	ld (0e171h),a		;68d8
	inc hl			;68db
	call sigue_la_remision		;68dc   ; Si el fotograma era impar, saltar al dibujo bueno
	ld de,0e151h		;68df
	ld a,(de)			;68e2
	add a,(hl)			;68e3   ; Y la fila, igual
	ld (0e170h),a		;68e4
	inc hl			;68e7
	ex de,hl			;68e8
	call borra_la_figura		;68e9   ; A borrarlo
ahora_pintalo_donde_toca:
	ld hl,0e132h		;68ec   ; La posicion nueva pasa a ser la vieja
	ld de,0e151h		;68ef
	ld bc,00002h		;68f2
	ldir		;68f5
	ld a,(0e138h)		;68f7   ; Y el fotograma nuevo, tambien
	ld (0e153h),a		;68fa
	pop hl			;68fd   ; El bloque que se habia guardado
	ld ix,0e138h		;68fe   ; Ahora se indexa por el fotograma NUEVO
	ld a,(ix+000h)		;6902
	call lee_la_entrada_de_la_tabla		;6905
	ld hl,0e133h		;6908
	ex de,hl			;690b
	ld a,(de)			;690c
	add a,(hl)			;690d   ; La columna nueva mas su dy
	ld (0e171h),a		;690e
	inc hl			;6911
	call sigue_la_remision		;6912   ; Otra vez la remision si toca
	ld de,0e132h		;6915
	ld a,(de)			;6918
	add a,(hl)			;6919   ; Y la fila
	ld (0e170h),a		;691a
	inc hl			;691d
	ex de,hl			;691e
	jp pinta_la_figura		;691f

; ----------------------------------------------------------------------
; DATOS tabla_de_los_enemigos: ocho punteros a los ocho bloques de fotogramas;
;   los carga 0x68A8 con el escenario
;   0x6922..0x6932  (16 bytes)
DATA_tabla_de_los_enemigos:
	defw 08142h,0839dh,087c7h,089f3h,08bafh,08dach,0857bh,08f74h	; 6922

; ======================================================================
; CODIGO 0x6932..0x6990  (94 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ======================================================================
; LO QUE PIDE EL JUGADOR
; ======================================================================
; El mando entra por (0xE009) con cinco bits -cuatro direcciones y el
; disparo- y esos cinco bits SON el indice de la tabla de 32 de 0x6990.
; Por eso la tabla es tan grande: no hay que traducir nada.
; ----------------------------------------------------------------------
lee_lo_que_pide:
	ld a,(0e117h)		;6932   ; Hay algo en marcha?
	and a			;6935
	jr nz,arranca_la_orden_pedida		;6936
	call guarda_lo_pulsado_del_cuadro		;6938   ; Apuntar lo que se pide
	ld hl,0e11dh		;693b   ; Lo que se acaba de pedir
	ld a,(hl)			;693e
	and a			;693f   ; Nada
	jr z,arranca_la_orden_pedida		;6940
	cp 002h		;6942   ; Las cuatro direcciones solas...
	jr z,arranca_la_orden_pedida		;6944
	cp 004h		;6946
	jr z,arranca_la_orden_pedida		;6948
	cp 008h		;694a
	jr z,arranca_la_orden_pedida		;694c   ; ...no interrumpen lo que haya
	inc hl			;694e
	xor (hl)			;694f   ; Lo mismo que antes?
	jr nz,arranca_la_orden_pedida		;6950
	ld (0e117h),a		;6952   ; Entonces se para
	ld (0e115h),a		;6955
	ret			;6958
guarda_lo_pulsado_del_cuadro:
	ld hl,0e11dh		;6959   ; Lo que se pedia
	ld a,(hl)			;695c
	inc hl			;695d
	ld (hl),a			;695e   ; Se guarda como "lo de antes"
	ld a,(0e009h)		;695f   ; El mando, con sus cinco bits
	and 01fh		;6962
	dec hl			;6964
	ld (hl),a			;6965   ; Guardado
	and a			;6966   ; Sin pulsar nada...
	jr nz,L_696C		;6967
	inc a			;6969   ; ...un cuadro
	jr L_696E		;696a
L_696C:
	ld a,009h		;696c   ; Pulsando algo, nueve
L_696E:
	ld (0e117h),a		;696e   ; Es lo que dura la orden
	xor a			;6971
	ld (0e11ch),a		;6972   ; Y el paso, a cero
	ret			;6975
arranca_la_orden_pedida:
	xor a			;6976   ; Ya no se pide nada nuevo
	ld (0e115h),a		;6977
	ld a,(0e117h)		;697a
	cp 008h		;697d   ; La orden 8 -el salto- ...
	jr nz,L_6986		;697f
	ld a,009h		;6981   ; ...suena
	call pide_pieza		;6983
L_6986:
	ld a,(0e11dh)		;6986   ; La orden en marcha
	ld hl,0e117h		;6989
	dec (hl)			;698c   ; Un cuadro menos
	call reparte_por_tabla		;698d   ; Y a la orden que sea

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_6990: 32 entradas, tras el `call
;   reparte_por_tabla` de 0x698D; detras sigue la primera, 0x69D0
;   0x6990..0x69d0  (64 bytes)
DATA_tabla_de_subescenas_6990:
	defw 069d0h,069d8h,06a0ch,069d0h,06a47h,06b29h,06b34h,069d0h	; 6990
	defw 06a12h,06b26h,06b31h,069d0h,069d0h,069d0h,069d0h,069d0h	; 69a0
	defw 06b3ch,06a6dh,06a0ch,069d0h,06b1eh,06a6dh,06a0ch,069d0h	; 69b0
	defw 06b1bh,06a6dh,06a0ch,069d0h,069d0h,069d0h,069d0h,069d0h	; 69c0

; ======================================================================
; CODIGO 0x69d0..0x69f1  (33 bytes)
; ======================================================================


L_69D0:
	xor a			;69d0   ; Se acabo el salto...
	ld (0e11ah),a		;69d1
	ld b,a			;69d4   ; ...y el fotograma es el 0
	jp L_6B44		;69d5
L_69D8:
	ld hl,0e11ch		;69d8   ; Por que paso va
	ld a,(hl)			;69db
	cp 002h		;69dc   ; En los dos primeros...
	jr nc,L_69EC		;69de
	ld a,(0e009h)		;69e0   ; ...si ademas se pulsa disparo...
	bit 4,a		;69e3
	jr z,L_69EC		;69e5
	ld a,011h		;69e7   ; ...la orden pasa a ser la 0x11
	ld (0e11dh),a		;69e9
L_69EC:
	ld c,001h		;69ec   ; C = 1: salto en el sitio
	jp L_6A6F		;69ee

; ----------------------------------------------------------------------
; DATOS la_curva_del_salto: veintiseis desplazamientos y el 0xA0 que la
;   cierra; van de 0xFC a 0x04, o sea suben cuatro y bajan cuatro. 0x6AA3
;   entra con (0xE11C)
;   0x69f1..0x6a0c  (27 bytes)
DATA_la_curva_del_salto:
	defb 0fch,0fch,0fch,0fch,0fch,0fch,0fdh,0fdh,0fdh,0fdh,0feh,0feh,0ffh,001h,002h,002h,003h,003h,003h,003h,004h,004h,004h,004h,004h,004h,0a0h	; 69f1  ...........................

; ======================================================================
; CODIGO 0x6a0c..0x6c51  (581 bytes)
; ======================================================================


L_6A0C:
	xor a			;6a0c   ; Fotograma 8, quieto
	ld b,008h		;6a0d
	jp L_6B44		;6a0f
L_6A12:
	xor a			;6a12   ; Deja de mirar a un lado
	ld (0e114h),a		;6a13
	ld (0e117h),a		;6a16
	ld hl,0e113h		;6a19   ; Donde esta
	ld a,(hl)			;6a1c
	cp 0ddh		;6a1d   ; Pegado al borde derecho: no se mueve mas
	jp nc,L_69D0		;6a1f
	push hl			;6a22
	call mide_la_distancia		;6a23   ; A que distancia queda el otro
	pop hl			;6a26
	and a			;6a27
	jr z,L_6A2F		;6a28
	ld a,b			;6a2a   ; Si esta pegado, tampoco
	dec a			;6a2b
	jp z,L_69D0		;6a2c
L_6A2F:
	inc (hl)			;6a2f   ; Dos columnas a la derecha
	inc (hl)			;6a30
	jr L_6A67		;6a31
alterna_las_dos_piernas_al_andar:
	ld hl,0e119h		;6a33   ; El fotograma de andar
	ld a,(0e003h)		;6a36   ; Cada cuatro cuadros...
	and 006h		;6a39
	ld a,(hl)			;6a3b
	jr nz,L_6A45		;6a3c
	and a			;6a3e   ; ...alterna entre el 0 y el 0x0E: las dos piernas
	ld a,00eh		;6a3f
	jr z,L_6A44		;6a41
	xor a			;6a43
L_6A44:
	ld (hl),a			;6a44
L_6A45:
	ld b,a			;6a45
	ret			;6a46
L_6A47:
	xor a			;6a47   ; Nada en marcha
	ld (0e117h),a		;6a48
	inc a			;6a4b
	ld (0e114h),a		;6a4c   ; Mirando al otro lado
	ld hl,0e113h		;6a4f
	ld a,(hl)			;6a52
	cp 023h		;6a53   ; Pegado al borde izquierdo
	jp c,L_69D0		;6a55
	push hl			;6a58
	call mide_la_distancia		;6a59   ; O al otro muneco
	pop hl			;6a5c
	and a			;6a5d
	jr nz,L_6A65		;6a5e
	ld a,b			;6a60
	dec a			;6a61
	jp z,L_69D0		;6a62
L_6A65:
	dec (hl)			;6a65   ; Dos columnas a la izquierda
	dec (hl)			;6a66
L_6A67:
	call alterna_las_dos_piernas_al_andar		;6a67
	jp L_6B47		;6a6a
L_6A6D:
	ld c,000h		;6a6d   ; C = 0: salto con carrera
L_6A6F:
	ld a,(0e009h)		;6a6f   ; El mando
	and 010h		;6a72   ; Se suelta el disparo?
	jr nz,L_6A7C		;6a74
	inc a			;6a76
	ld (0e11bh),a		;6a77   ; Marcar que se solto
	jr L_6A9F		;6a7a
L_6A7C:
	ld hl,0e11ah		;6a7c   ; Ya se esta pegando en el aire?
	ld a,(hl)			;6a7f
	and a			;6a80
	jr nz,L_6A9F		;6a81
	inc hl			;6a83   ; Se ha soltado alguna vez?
	ld a,(hl)			;6a84
	and a			;6a85
	jr z,L_6A9F		;6a86
	ld b,00bh		;6a88   ; Con carrera, a partir del paso 11
	ld a,c			;6a8a
	and a			;6a8b
	jr z,L_6A90		;6a8c
	ld b,003h		;6a8e   ; En el sitio, del 3
L_6A90:
	ld a,(0e11ch)		;6a90
	cp b			;6a93   ; Todavia es pronto
	jr c,L_6A9F		;6a94
	ld a,009h		;6a96   ; Empezar la patada del salto
	dec hl			;6a98
	ld (hl),a			;6a99
	ld a,008h		;6a9a
	call pide_pieza		;6a9c   ; Y sonar
L_6A9F:
	ld hl,0e11ch		;6a9f
	ld a,(hl)			;6aa2   ; Por que paso va el salto
	ld de,069f1h		;6aa3   ; La curva
	call suma_a_a_de		;6aa6
	ld a,(de)			;6aa9
	cp 0a0h		;6aaa   ; El 0xA0 la cierra
	jp nz,L_6AB9		;6aac
	xor a			;6aaf
	ld (0e11ah),a		;6ab0   ; Se acabo el salto
	ld (0e11bh),a		;6ab3
	jp L_69D0		;6ab6
L_6AB9:
	inc (hl)			;6ab9   ; Un paso mas
	ld hl,0e112h		;6aba   ; Y sumar el desplazamiento a la columna
	add a,(hl)			;6abd
	ld (hl),a			;6abe
	ld a,001h		;6abf   ; Un cuadro de la orden
	ld (0e117h),a		;6ac1
	ld a,(0e11ch)		;6ac4   ; Por que paso va
	cp 003h		;6ac7   ; Antes del tercero no se avanza
	jr c,L_6B16		;6ac9
L_6ACB:
	ld de,0e113h		;6acb   ; La columna
	ld hl,0e114h		;6ace   ; Y el lado al que mira
	ld a,(hl)			;6ad1
	and a			;6ad2
	jr z,L_6AEE		;6ad3   ; Mirando a la derecha
	ld b,001h		;6ad5   ; B = 1: se llego al borde
	ld a,c			;6ad7   ; Salto en el sitio: no se mueve
	and a			;6ad8
	jr nz,L_6AE5		;6ad9
	ld a,(de)			;6adb   ; Cuatro columnas a la izquierda
	sub 004h		;6adc
	cp 022h		;6ade   ; Del 0x22 no se pasa
	ld b,000h		;6ae0
	jr c,L_6AEB		;6ae2
	ld (de),a			;6ae4
L_6AE5:
	ld a,005h		;6ae5   ; Fotograma 5
	ld c,00bh		;6ae7   ; Y 0x0B si esta pegando
	jr L_6B02		;6ae9
L_6AEB:
	ld (hl),b			;6aeb   ; Al llegar al borde, dar la vuelta
	jr L_6ACB		;6aec
L_6AEE:
	ld b,000h		;6aee
	ld a,c			;6af0   ; Salto en el sitio
	and a			;6af1
	jr nz,L_6AFE		;6af2
	ld a,(de)			;6af4
	add a,004h		;6af5   ; Cuatro columnas a la derecha
	cp 0e0h		;6af7   ; Sin pasar de 0xE0
	ld b,001h		;6af9
	jr nc,L_6AEB		;6afb
	ld (de),a			;6afd
L_6AFE:
	ld a,004h		;6afe   ; Fotograma 4
	ld c,00ah		;6b00   ; Y 0x0A pegando
L_6B02:
	ld b,a			;6b02
	ld hl,0e11ah		;6b03   ; Esta pegando en el aire?
	ld a,(hl)			;6b06
	cp 002h		;6b07
	jr c,L_6B12		;6b09
	dec (hl)			;6b0b   ; Un cuadro menos
	ld b,c			;6b0c   ; El fotograma de la patada
	ld a,005h		;6b0d   ; Y la orden 5
	ld (0e115h),a		;6b0f
L_6B12:
	ld a,b			;6b12
	jp L_6B75		;6b13   ; Poner el fotograma
L_6B16:
	ld b,004h		;6b16   ; Fotograma 4: cayendo
	jp L_6B47		;6b18
L_6B1B:
	xor a			;6b1b   ; Mirando a la izquierda
	jr L_6B20		;6b1c
L_6B1E:
	ld a,001h		;6b1e   ; Mirando a la derecha
L_6B20:
	ld c,001h		;6b20   ; El golpe 1
	ld b,002h		;6b22   ; Y su fotograma
	jr L_6B54		;6b24
L_6B26:
	xor a			;6b26   ; A la izquierda
	jr L_6B2B		;6b27
L_6B29:
	ld a,001h		;6b29   ; A la derecha
L_6B2B:
	ld c,002h		;6b2b   ; El golpe 2
	ld b,006h		;6b2d
	jr L_6B54		;6b2f
L_6B31:
	xor a			;6b31   ; A la izquierda
	jr L_6B36		;6b32
L_6B34:
	ld a,001h		;6b34   ; A la derecha
L_6B36:
	ld c,003h		;6b36   ; El golpe 3
	ld b,00ch		;6b38
	jr L_6B54		;6b3a
L_6B3C:
	ld a,(0e114h)		;6b3c   ; Hacia donde mira ya
	and a			;6b3f
	jr z,L_6B1B		;6b40
	jr L_6B1E		;6b42
L_6B44:
	ld (0e117h),a		;6b44   ; La orden
L_6B47:
	call elige_el_fotograma_segun_el_lado		;6b47   ; Y el fotograma que le toca
	jr L_6B75		;6b4a
elige_el_fotograma_segun_el_lado:
	ld a,(0e114h)		;6b4c   ; Mirando a un lado o al otro
	and a			;6b4f
	ld a,b			;6b50   ; B es el de base...
	ret z			;6b51
	inc a			;6b52   ; ...y el de al lado es el espejado
	ret			;6b53
L_6B54:
	ld (0e114h),a		;6b54   ; Poner el lado
	ld a,c			;6b57   ; Y el tipo de golpe
	ld (0e115h),a		;6b58
	call elige_el_fotograma_segun_el_lado		;6b5b
	ld b,a			;6b5e
	ld a,(0e117h)		;6b5f
	cp 007h		;6b62
	jr nc,L_6B6D		;6b64
	cp 002h		;6b66
	jr c,L_6B6D		;6b68
	ld a,b			;6b6a
	jr L_6B75		;6b6b
L_6B6D:
	ld a,(0e114h)		;6b6d
	and a			;6b70
	jr z,L_6B75		;6b71
	ld a,001h		;6b73
L_6B75:
	ld (0e118h),a		;6b75
	ret			;6b78

; ----------------------------------------------------------------------
; ======================================================================
; MONTAR AL JUGADOR
; ======================================================================
; El muneco son ocho sprites y se arma entero en RAM, en la copia de
; atributos de 0xE09C; el volcado a la VRAM lo hace otro. El fotograma
; (0xE118) elige la entrada en el bloque de 0x6C83.
; (0xE114) parte la rutina en dos caminos que se parecen mucho: con el
; a cero los trios llevan patron, y con el a uno hay que seguir antes
; una remision y la x sale al reves.
; ----------------------------------------------------------------------
monta_al_jugador:
	ld de,06c7bh		;6b79   ; Los ocho numeros de patron
	ld hl,0e09eh		;6b7c   ; Al tercer byte de cada atributo
	call reparte_de_cuatro_en_cuatro		;6b7f
	ld bc,(0e112h)		;6b82   ; BC = la posicion del muneco
	ld a,(0e118h)		;6b86   ; El fotograma
	ld hl,06c83h		;6b89   ; Su entrada en el bloque
	add a,a			;6b8c   ; Punteros de dos bytes
	call suma_a_a_hl		;6b8d
	ld e,(hl)			;6b90
	inc hl			;6b91
	ld d,(hl)			;6b92
	ex de,hl			;6b93
	ld a,(0e114h)		;6b94   ; Mirando a la derecha o a la izquierda?
	and a			;6b97
	jr z,monta_al_jugador_mirando_al_otro_lado		;6b98
	ld e,(hl)			;6b9a   ; Seguir la remision: aqui la entrada es un puntero
	inc hl			;6b9b
	ld d,(hl)			;6b9c
	ex de,hl			;6b9d
	call monta_los_sprites_del_jugador		;6b9e   ; Los cuatro sprites de delante
	call pon_los_colores_del_fotograma		;6ba1   ; Y el byte de la paleta
	ld de,0e09ch		;6ba4   ; La copia de atributos en RAM
trios_con_patron:
	ld a,(hl)			;6ba7   ; El nibble alto a 8 cierra la lista...
	and 0f0h		;6ba8
	cp 080h		;6baa
	jr z,cierra_la_lista_de_sprites		;6bac
	ld a,(hl)			;6bae   ; La y, relativa a la del muneco
	add a,c			;6baf
	ld (de),a			;6bb0
	inc hl			;6bb1
	inc de			;6bb2
	ld a,010h		;6bb3   ; La x va del reves: 0x10 + x, cambiada de signo
	add a,(hl)			;6bb5
	neg		;6bb6
	add a,b			;6bb8
	ld (de),a			;6bb9   ; Guardada
	inc hl			;6bba
	inc de			;6bbb
	ld a,(hl)			;6bbc   ; Y el patron, que aqui SI viene en el trio
	ld (de),a			;6bbd
	inc de			;6bbe   ; El color se queda como estaba
	inc de			;6bbf
	inc hl			;6bc0
	jr trios_con_patron		;6bc1   ; A por el siguiente
cierra_la_lista_de_sprites:
	ld a,0d0h		;6bc3   ; 0xD0 en la y: el VDP deja de mirar de aqui para abajo
	ld (de),a			;6bc5
	ret			;6bc6
monta_al_jugador_mirando_al_otro_lado:
	call monta_los_sprites_del_jugador		;6bc7   ; Los cuatro sprites
	call pon_los_colores_del_fotograma		;6bca   ; La paleta
	ld de,0e09ch		;6bcd
trios_sin_negar_la_x:
	ld a,(hl)			;6bd0   ; Mismo terminador
	and 0f0h		;6bd1
	cp 080h		;6bd3
	jr z,sube_los_patrones_del_fotograma		;6bd5
	ld a,(hl)			;6bd7   ; La y
	add a,c			;6bd8
	ld (de),a			;6bd9
	inc hl			;6bda
	inc de			;6bdb
	ld a,(hl)			;6bdc   ; Y la x, esta vez tal cual
	add a,b			;6bdd
	ld (de),a			;6bde
	inc hl			;6bdf   ; El patron de este trio se salta
	inc hl			;6be0
	inc de			;6be1
	inc de			;6be2
	inc de			;6be3
	jr trios_sin_negar_la_x		;6be4
sube_los_patrones_del_fotograma:
	ld a,0d0h		;6be6   ; Cerrar la lista de sprites
	ld (de),a			;6be8
	ld a,(hl)			;6be9   ; Y el nibble BAJO del terminador...
	and 00fh		;6bea   ; ...dice cuantos guiones vienen detras
	ret z			;6bec   ; Ninguno: no hay nada que subir
	ld b,a			;6bed
	inc hl			;6bee
sube_un_guion:
	ld e,(hl)			;6bef   ; La direccion del guion
	inc hl			;6bf0
	ld d,(hl)			;6bf1
	inc hl			;6bf2
	push bc			;6bf3
	push hl			;6bf4
	call guion_rle		;6bf5   ; Se vuelca con el destino metido dentro
	pop hl			;6bf8
	pop bc			;6bf9
	djnz sube_un_guion		;6bfa   ; Hasta agotar la cuenta
	ret			;6bfc
monta_los_sprites_del_jugador:
	push bc			;6bfd
	ex de,hl			;6bfe
	ld hl,0e120h		;6bff   ; Los atributos de este muneco
	ld ix,0e112h		;6c02   ; La posicion de referencia
	ld iy,0e121h		;6c06
	ld a,(0e114h)		;6c0a   ; El bit 0 decide el espejo
	call monta_los_sprites_con_a		;6c0d
	ex de,hl			;6c10
	pop bc			;6c11
	ret			;6c12
pon_los_colores_del_fotograma:
	push bc			;6c13
	push hl			;6c14
	ld a,(hl)			;6c15   ; El byte de la paleta, que va delante de los trios
	push af			;6c16
	ld a,(0e10bh)		;6c17   ; Invulnerable?
	cp 002h		;6c1a
	jr nc,L_6C34		;6c1c
	ld a,(0e29eh)		;6c1e   ; Hay algo que haga parpadear al muneco?
	and a			;6c21
	jr nz,L_6C2A		;6c22
	ld a,(0e265h)		;6c24
	and a			;6c27
	jr z,L_6C34		;6c28
L_6C2A:
	ld a,(0e003h)		;6c2a   ; El bit 1 del contador de cuadros...
	bit 1,a		;6c2d
	ld hl,06c66h		;6c2f   ; ...alterna entre los dos juegos de colores: eso es el parpadeo
	jr z,L_6C37		;6c32
L_6C34:
	ld hl,06c51h		;6c34   ; Sin parpadeo, siempre los mismos
L_6C37:
	pop af			;6c37
	call lee_la_entrada_de_la_tabla		;6c38   ; La tira de ocho que toque
	ld hl,0e09fh		;6c3b   ; Al cuarto byte de cada atributo
	call reparte_de_cuatro_en_cuatro		;6c3e
	pop hl			;6c41
	inc hl			;6c42   ; Y dejar HL en el primer trio
	pop bc			;6c43
	ret			;6c44
reparte_de_cuatro_en_cuatro:
	ld b,008h		;6c45   ; Ocho sprites
L_6C47:
	ld a,(de)			;6c47   ; Un byte de la tira...
	ld (hl),a			;6c48   ; ...a este atributo
	inc hl			;6c49   ; Y saltar al mismo campo del siguiente
	inc hl			;6c4a
	inc hl			;6c4b
	inc hl			;6c4c
	inc de			;6c4d
	djnz L_6C47		;6c4e
	ret			;6c50

; ----------------------------------------------------------------------
; DATOS tabla_de_los_colores_a: tres punteros a las tiras de colores de
;   detras; 0x6C34 la elige cuando 0x6C13 no tiene por que parpadear
;   0x6c51..0x6c57  (6 bytes)
DATA_tabla_de_los_colores_a:
	defw 06c5eh,06c57h,06c58h	; 6c51  -> 0x6c5e DATA_colores_a 0x6c58

; ----------------------------------------------------------------------
; DATOS colores_a: tres tiras de ocho colores, SOLAPADAS: empiezan en 0x6C57,
;   0x6C58 y 0x6C5E, y la ultima acaba justo en 0x6C66. Ocho porque L_6C45
;   copia ocho, de cuatro en cuatro, sobre el cuarto byte de los atributos de
;   sprite (0xE09F)
;   0x6c57..0x6c66  (15 bytes)
DATA_colores_a:
	defb 006h,00bh,00bh,004h,004h,004h,004h,006h,00bh,00bh,00bh,004h,004h,004h,004h	; 6c57  ...............

; ----------------------------------------------------------------------
; DATOS tabla_de_los_colores_b: los otros tres; 0x6C2F la elige, y 0x6C2D
;   alterna entre las dos con el bit 1 de (0xE003): eso es el parpadeo
;   0x6c66..0x6c6c  (6 bytes)
DATA_tabla_de_los_colores_b:
	defw 06c73h,06c6ch,06c6dh	; 6c66  -> 0x6c73 DATA_colores_b 0x6c6d

; ----------------------------------------------------------------------
; DATOS colores_b: otras tres tiras de ocho solapadas, en 0x6C6C, 0x6C6D y
;   0x6C73; la ultima acaba en 0x6C7B
;   0x6c6c..0x6c7b  (15 bytes)
DATA_colores_b:
	defb 006h,00bh,00bh,008h,008h,008h,008h,006h,00bh,00bh,00bh,008h,008h,008h,008h	; 6c6c  ...............

; ----------------------------------------------------------------------
; DATOS patrones_del_jugador: los ocho numeros de patron, de 4 en 4 porque los
;   sprites son de 16x16; 0x6B79 los copia sobre el tercer byte de los
;   atributos (0xE09E)
;   0x6c7b..0x6c83  (8 bytes)
DATA_patrones_del_jugador:
	defb 000h,004h,008h,00ch,010h,014h,018h,01ch	; 6c7b  ........

; ----------------------------------------------------------------------
; DATOS fotogramas_del_jugador: veinte punteros -la tabla cierra en 0x6CAB- y
;   los veinte tramos: diez dibujos y diez remisiones de dos bytes al dibujo
;   de delante
;   0x6c83..0x6e1d  (410 bytes)
DATA_fotogramas_del_jugador:
	defb 0abh,06ch,0d7h,06ch,0d9h,06ch,006h,06dh,008h,06dh,02ch,06dh,02eh,06dh,052h,06dh,054h,06dh,078h,06dh,07ah,06dh,09ch,06dh,09eh,06dh,0c3h,06dh,0c5h,06dh,0ebh,06dh,0edh,06dh,003h,06eh,005h,06eh,01bh,06eh	; 6c83  .l.l.l.m.m,m.mRmTmxmzm.m.m.m.m.m.m.n.n.n
	defb 000h,0f8h,017h,00ch,017h,0f6h,009h,018h,080h,080h,000h,0f7h,0f8h,020h,0fbh,0f8h,024h,0f9h,006h,028h,00eh,0ffh,02ch,009h,0f4h,030h,007h,004h,034h,019h,0f6h,038h,017h,004h,03ch,084h,08eh,0a4h,0a5h,0a4h,0bfh,0a4h,0d3h,0a4h	; 6cab  ............. ..$..(..,..0..4..8..<.........
	defb 0abh,06ch	; 6cd7
	defb 000h,001h,019h,00bh,018h,0f8h,008h,00eh,018h,00ch,008h,008h,00dh,018h,001h,0f7h,002h,020h,0fbh,002h,04ch,00bh,014h,050h,009h,0f4h,054h,009h,004h,058h,019h,0f8h,05ch,019h,00bh,060h,084h,08eh,0a4h,069h,0a5h,081h,0a5h,08bh,0a5h	; 6cd9  ................. ..L..P..T..X..\..`...i.....
	defb 0d9h,06ch	; 6d06
	defb 003h,0f6h,015h,012h,080h,080h,080h,000h,0f7h,0f9h,020h,0fbh,0f9h,024h,0f7h,005h,088h,00bh,0f4h,08ch,007h,0f1h,090h,007h,001h,094h,017h,0f9h,098h,083h,08eh,0a4h,0a5h,0a4h,0ach,0a6h	; 6d08  .......... ..$......................
	defb 008h,06dh	; 6d2c
	defb 0fbh,0feh,025h,00ch,080h,080h,001h,01eh,001h,0f2h,000h,020h,0f5h,000h,064h,00ch,005h,050h,002h,000h,068h,002h,010h,06ch,012h,000h,070h,084h,08eh,0a4h,0d6h,0a5h,081h,0a5h,0efh,0a5h	; 6d2e  ..%........ ..d..P..h..l..p.........
	defb 02eh,06dh	; 6d52
	defb 00ch,0f6h,014h,012h,080h,080h,080h,000h,0ffh,0f9h,020h,003h,0f9h,024h,0ffh,005h,088h,013h,0f4h,08ch,00fh,0f1h,090h,00fh,001h,094h,01fh,0f9h,098h,083h,08eh,0a4h,0a5h,0a4h,0ach,0a6h	; 6d54  .......... ..$......................
	defb 054h,06dh	; 6d78
	defb 000h,0f8h,01ah,010h,080h,080h,015h,016h,001h,0f7h,0f9h,020h,0fbh,0f9h,024h,00bh,001h,09ch,007h,0f8h,0a0h,007h,008h,0a4h,017h,0f8h,0a8h,083h,08eh,0a4h,0a5h,0a4h,0fah,0a6h	; 6d7a  ........... ..$...................
	defb 07ah,06dh	; 6d9c
	defb 000h,0feh,020h,00eh,080h,080h,01ah,01eh,001h,0f7h,000h,020h,0fah,000h,064h,00ch,0f9h,074h,007h,0fbh,078h,007h,00bh,07ch,017h,000h,080h,017h,010h,084h,083h,08eh,0a4h,0d6h,0a5h,043h,0a6h	; 6d9e  .. ........ ..d..t..x..|...........C.
	defb 09eh,06dh	; 6dc3
	defb 000h,0f6h,020h,010h,080h,080h,080h,000h,0f7h,0f8h,020h,0fbh,0f8h,024h,0f9h,006h,028h,00eh,0ffh,02ch,009h,0f4h,040h,007h,004h,044h,017h,0f8h,048h,084h,08eh,0a4h,0a5h,0a4h,0bfh,0a4h,020h,0a5h	; 6dc5  .. ....... ..$..(..,..@..D..H....... .
	defb 0c5h,06dh	; 6deb
	defb 080h,080h,080h,080h,002h,01dh,0ech,0ach,01dh,00ch,0b0h,010h,0f1h,0b4h,010h,001h,0b8h,082h,051h,0a7h,060h,0a7h	; 6ded  ..................Q.`.
	defb 0edh,06dh	; 6e03
	defb 080h,080h,080h,080h,002h,01dh,0ech,0ach,01dh,00ch,0b0h,010h,0f1h,0bch,010h,001h,0c0h,082h,051h,0a7h,09ah,0a7h	; 6e05  ..................Q...
	defb 005h,06eh	; 6e1b

; ======================================================================
; CODIGO 0x6e1d..0x6e5f  (66 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ======================================================================
; A QUE DISTANCIA ESTA EL JUGADOR
; ======================================================================
; De aqui sale todo el comportamiento del enemigo. Se resta una x de la
; otra y lo que salga se mete en uno de SIETE tramos; ese numero es el
; indice con el que 0x7FD8 entra en la tabla del escenario.
; Tres de los seis cortes son fijos -0x13, 0x40 y 0x48- y los otros tres
; salen de la tira de 0x6E5F, o sea que cada escenario tiene su alcance.
; ----------------------------------------------------------------------
mide_la_distancia:
	ld a,(0e156h)		;6e1d   ; La x del jugador
	ld hl,0e113h		;6e20   ; Y la del enemigo
	ld c,001h		;6e23   ; C = 1: el jugador queda a la derecha
	cp (hl)			;6e25   ; Quien esta mas a la derecha?
	jr nc,L_6E2E		;6e26
	dec c			;6e28   ; C = 0: queda a la izquierda
	ld b,a			;6e29
	ld a,(hl)			;6e2a
	sub b			;6e2b   ; La distancia, siempre positiva
	jr clasifica_la_distancia		;6e2c
L_6E2E:
	sub (hl)			;6e2e   ; Y por el otro lado igual
clasifica_la_distancia:
	push af			;6e2f
	call el_escenario_de_la_ronda		;6e30   ; El escenario de la ronda
	ld hl,06e5fh		;6e33   ; Su tira de tres cortes
	call lee_la_entrada_de_la_tabla		;6e36
	ex de,hl			;6e39
	pop af			;6e3a
	ld b,000h		;6e3b   ; B = el tramo, de 0 a 6
	cp 013h		;6e3d   ; Pegado: menos de 0x13
	jr c,apunta_el_lado		;6e3f
	inc b			;6e41
	cp (hl)			;6e42   ; Primer corte del escenario
	jr c,apunta_el_lado		;6e43
	inc b			;6e45
	inc hl			;6e46
	cp (hl)			;6e47   ; Segundo corte
	inc hl			;6e48
	jr c,apunta_el_lado		;6e49
	inc b			;6e4b
	cp 040h		;6e4c   ; Corte fijo en 0x40
	jr c,apunta_el_lado		;6e4e
	inc b			;6e50
	cp 048h		;6e51   ; Y en 0x48
	jr c,apunta_el_lado		;6e53
	inc b			;6e55
	cp (hl)			;6e56   ; Tercer corte del escenario
	jr c,apunta_el_lado		;6e57
	inc b			;6e59
apunta_el_lado:
	ld a,c			;6e5a
	ld (0e11fh),a		;6e5b   ; De que lado ha quedado; el TRAMO se lo lleva quien llamo, en B
	ret			;6e5e

; ----------------------------------------------------------------------
; DATOS tabla_del_alcance: ocho punteros, uno por escenario -el sexto repite
;   el cuarto-; los carga 0x6E33
;   0x6e5f..0x6e6f  (16 bytes)
DATA_tabla_del_alcance:
	defw 06e6fh,06e72h,06e75h,06e78h,06e7bh,06e78h,06e7eh,06e81h	; 6e5f

; ----------------------------------------------------------------------
; DATOS tiras_del_alcance: siete tiras de tres bytes, las que apunta la tabla
;   de arriba; 0x6E42 compara contra ellas
;   0x6e6f..0x6e84  (21 bytes)
DATA_tiras_del_alcance:
	defb 01dh,028h,068h	; 6e6f
	defb 01dh,028h,088h	; 6e72
	defb 020h,02ah,088h	; 6e75
	defb 020h,028h,088h	; 6e78
	defb 020h,028h,068h	; 6e7b
	defb 020h,028h,090h	; 6e7e
	defb 020h,02ah,080h	; 6e81

; ======================================================================
; CODIGO 0x6e84..0x6eb2  (46 bytes)
; ======================================================================


L_6E84:
	ld a,(0e135h)		;6e84   ; Cual de los tres golpes
	call lee_la_entrada_de_la_tabla		;6e87   ; Su tira de fotogramas
	ld b,000h		;6e8a
	ld hl,0e137h		;6e8c   ; Por que cuadro va
	dec (hl)			;6e8f   ; Uno menos
	ld a,(hl)			;6e90
	ld hl,06eb2h		;6e91   ; Los tres umbrales
	cp (hl)			;6e94   ; Comparar con el primero
	jr nc,L_6EA2		;6e95
	inc b			;6e97
	inc hl			;6e98
	cp (hl)			;6e99
	jr nc,L_6EA2		;6e9a
	inc b			;6e9c
	inc hl			;6e9d
	cp (hl)			;6e9e
	jr nc,L_6EA2		;6e9f
	inc b			;6ea1
L_6EA2:
	ld a,b			;6ea2   ; El tramo que salio
	call suma_a_a_de		;6ea3
	ld a,(0e134h)		;6ea6   ; De que lado viene
	and a			;6ea9
	ld a,(de)			;6eaa   ; El fotograma de la tira
	jr nz,L_6EAE		;6eab
	inc a			;6ead   ; El del otro lado es el de al lado
L_6EAE:
	ld (0e138h),a		;6eae   ; Ahi va
	ret			;6eb1

; ----------------------------------------------------------------------
; DATOS umbrales_del_golpe: los tres que 0x6E94 compara contra (0xE137) para
;   saber por que fotograma va: 0x0E, 0x07 y 0x01
;   0x6eb2..0x6eb5  (3 bytes)
DATA_umbrales_del_golpe:
	defb 00eh,007h,001h	; 6eb2

; ======================================================================
; CODIGO 0x6eb5..0x6ed0  (27 bytes)
; ======================================================================


L_6EB5:
	ld b,000h		;6eb5
	jr L_6EC4		;6eb7
L_6EB9:
	ld a,(0e003h)		;6eb9   ; El contador de cuadros
	bit 3,a		;6ebc   ; Su bit 3 alterna el fotograma
	ld b,000h		;6ebe
	jr z,L_6EC4		;6ec0
	ld b,002h		;6ec2
L_6EC4:
	ld a,(0e134h)		;6ec4   ; Y el lado suma otro
	and a			;6ec7
	jr nz,L_6ECB		;6ec8
	inc b			;6eca
L_6ECB:
	ld a,b			;6ecb
	ld (0e138h),a		;6ecc   ; Ese es el fotograma del enemigo
	ret			;6ecf

; ----------------------------------------------------------------------
; DATOS tres_variables: 0xE1A7, 0xE1A8 y 0xE1A9; son punteros a RAM, no a ROM,
;   y 0x6EF5 elige con (0xE135)
;   0x6ed0..0x6ed6  (6 bytes)
DATA_tres_variables:
	defw 0e1a7h,0e1a8h,0e1a9h	; 6ed0

; ======================================================================
; CODIGO 0x6ed6..0x6f95  (191 bytes)
; ======================================================================


lanza_algo_si_el_escenario_lo_lleva:
	call el_escenario_de_la_ronda		;6ed6   ; En que escenario
	cp 001h		;6ed9
	jr z,L_6EE8		;6edb
	cp 002h		;6edd
	jr z,L_6EE8		;6edf
	cp 004h		;6ee1
	jr z,L_6EE8		;6ee3
	cp 005h		;6ee5
	ret nz			;6ee7   ; Solo los escenarios 1, 2, 4 y 5 lanzan cosas
L_6EE8:
	ld a,(0e137h)		;6ee8   ; Por que fotograma va el golpe
	cp 006h		;6eeb   ; Solo en el sexto se suelta
	ret nz			;6eed
	ld a,(0e135h)		;6eee   ; Cual de las tres
	cp 003h		;6ef1   ; Ya estan las tres fuera
	ret nc			;6ef3
	ld b,a			;6ef4
	ld hl,06ed0h		;6ef5   ; Su estado
	call lee_la_entrada_de_la_tabla		;6ef8
	ld a,(de)			;6efb   ; Ocupada?
	and a			;6efc
	ret nz			;6efd
	ld a,b			;6efe
	ld hl,0e1a3h		;6eff   ; Apuntar cual sale
	ld (hl),a			;6f02
	ld a,(0e1a3h)		;6f03
	push af			;6f06
	ld hl,06f9bh		;6f07   ; Su sitio
	call lee_la_entrada_de_la_tabla		;6f0a
	ex de,hl			;6f0d
	pop af			;6f0e
	ld de,06fa1h		;6f0f   ; Y su casilla
	call suma_a_a_de		;6f12
	ld a,(de)			;6f15
	ld (hl),a			;6f16
	push hl			;6f17
	ld a,(0e1a3h)		;6f18
	ld hl,0e1a4h		;6f1b
	ld de,0e1a7h		;6f1e
	and a			;6f21
	jr z,L_6F2B		;6f22
	inc hl			;6f24
	inc de			;6f25
	dec a			;6f26
	jr z,L_6F2B		;6f27
	inc hl			;6f29
	inc de			;6f2a
L_6F2B:
	ld a,(0e134h)		;6f2b
	ld (hl),a			;6f2e   ; El lado al que sale
	ld a,001h		;6f2f
	ld (de),a			;6f31   ; Y estado 1: suelta
	ld a,(0e156h)		;6f32   ; Donde esta el jugador
	ld b,a			;6f35
	ld a,(hl)			;6f36
	and a			;6f37
	ld a,009h		;6f38   ; Nueve columnas a la derecha...
	jr z,L_6F3E		;6f3a
	ld a,0e7h		;6f3c   ; ...o a la izquierda
L_6F3E:
	add a,b			;6f3e
	pop hl			;6f3f
	inc hl			;6f40
	ld (hl),a			;6f41   ; Ahi arranca
	call el_escenario_de_la_ronda		;6f42   ; Segun el escenario...
	cp 005h		;6f45
	jr z,L_6F5D		;6f47
	cp 002h		;6f49
	jr z,L_6F68		;6f4b
	cp 001h		;6f4d
	jr z,L_6F57		;6f4f
	ld a,0f0h		;6f51   ; ...sale a una altura y a una velocidad
	ld b,006h		;6f53
	jr L_6F7B		;6f55
L_6F57:
	ld a,0f0h		;6f57
	ld b,00fh		;6f59
	jr L_6F7B		;6f5b
L_6F5D:
	ld a,046h		;6f5d
	call pide_pieza		;6f5f   ; En el escenario 5, ademas, suena
	ld b,0f4h		;6f62
	ld c,0f0h		;6f64
	jr L_6F71		;6f66
L_6F68:
	ld a,047h		;6f68
	call pide_pieza		;6f6a
	ld b,0f0h		;6f6d
	ld c,0f4h		;6f6f
L_6F71:
	ld a,(0e134h)		;6f71
	and a			;6f74
	ld a,b			;6f75
	jr z,L_6F79		;6f76
	ld a,c			;6f78
L_6F79:
	ld b,00fh		;6f79
L_6F7B:
	inc hl			;6f7b   ; La casilla
	ld (hl),a			;6f7c
	inc hl			;6f7d
	ld (hl),b			;6f7e   ; Y el ancho
	call el_escenario_de_la_ronda		;6f7f
	cp 004h		;6f82
	ret nz			;6f84
	ld a,(0e1a3h)		;6f85
	ld hl,06f95h		;6f88
	call lee_la_entrada_de_la_tabla		;6f8b
	ld a,006h		;6f8e
	ld (de),a			;6f90
	xor a			;6f91
	inc de			;6f92
	ld (de),a			;6f93
	ret			;6f94

; ----------------------------------------------------------------------
; DATOS mas_tres_variables: 0xE1AB, 0xE1AD y 0xE1AF, desde 0x6F88 con (0xE1A3)
;   0x6f95..0x6f9b  (6 bytes)
DATA_mas_tres_variables:
	defw 0e1abh,0e1adh,0e1afh	; 6f95

; ----------------------------------------------------------------------
; DATOS y_otras_tres: 0xE1E4, 0xE1E8 y 0xE1EC, desde 0x6F07
;   0x6f9b..0x6fa1  (6 bytes)
DATA_y_otras_tres:
	defw 0e1e4h,0e1e8h,0e1ech	; 6f9b

; ----------------------------------------------------------------------
; DATOS tres_casillas: 0x7E, 0x8E y 0x9E; 0x6F0F las indexa con el mismo
;   (0xE1A3)
;   0x6fa1..0x6fa4  (3 bytes)
DATA_tres_casillas:
	defb 07eh,08eh,09eh	; 6fa1

; ======================================================================
; CODIGO 0x6fa4..0x70c1  (285 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ======================================================================
; LAS TRES COSAS QUE VUELAN
; ======================================================================
; Cada escenario lanza lo suyo, pero las tres ranuras se mueven con el
; mismo codigo: el estado (0xE1A7..0xE1A9) reparte, y de ahi salen la
; casilla, el color y lo que avanza.
; ----------------------------------------------------------------------
mueve_lo_que_vuela:
	call el_escenario_de_la_ronda		;6fa4   ; En que escenario
	cp 007h		;6fa7
	jp z,L_78EA		;6fa9   ; El 7 tiene lo suyo
	cp 006h		;6fac
	jp z,L_75EB		;6fae   ; Y el 6, tambien
	cp 000h		;6fb1
	ret z			;6fb3   ; Los escenarios 0 y 3 no lanzan nada
	cp 003h		;6fb4
	ret z			;6fb6
	ld hl,0e1e5h		;6fb7   ; La primera de las tres
	ld a,(0e1a4h)		;6fba   ; Su cuenta
	ld de,0e1a7h		;6fbd   ; Su estado
	ld ix,0e1abh		;6fc0   ; Su sitio
	ld iy,0e1b1h		;6fc4   ; Y su coordenada
	call baja_la_espera_de_lo_que_vuela		;6fc8
	ld hl,0e1e9h		;6fcb   ; La segunda
	ld a,(0e1a5h)		;6fce
	ld de,0e1a8h		;6fd1
	ld ix,0e1adh		;6fd4
	ld iy,0e1b4h		;6fd8
	call baja_la_espera_de_lo_que_vuela		;6fdc
	ld hl,0e1edh		;6fdf   ; Y la tercera
	ld a,(0e1a6h)		;6fe2
	ld de,0e1a9h		;6fe5
	ld ix,0e1afh		;6fe8
	ld iy,0e1b7h		;6fec
baja_la_espera_de_lo_que_vuela:
	ld b,a			;6ff0
	ld a,(iy+001h)		;6ff1   ; La espera
	and a			;6ff4
	jr z,L_6FF8		;6ff5   ; Ya esta a cero
	dec a			;6ff7   ; Una menos
L_6FF8:
	ld (iy+001h),a		;6ff8
	ld a,(de)			;6ffb   ; El estado
	and a			;6ffc
	ret z			;6ffd   ; Cero: no hay nada volando
	dec a			;6ffe   ; Estado 1: volando
	jr z,L_7043		;6fff
	dec a			;7001   ; Estado 2: se apaga
	jr z,L_7035		;7002
	dec a			;7004   ; Estado 3
	jr z,L_7015		;7005
	dec a			;7007   ; Estado 4: se apaga tambien
	jr z,L_7035		;7008
	dec a			;700a   ; Estado 5
	jr z,L_701D		;700b
	ld b,008h		;700d   ; Y si no, la casilla 0xD4
	ld c,007h		;700f
	ld a,0d4h		;7011
	jr L_7027		;7013
L_7015:
	ld b,001h		;7015   ; Estado 3: casilla 0xC4 y color 0x0D
	ld c,00dh		;7017
	ld a,0c4h		;7019
	jr L_7027		;701b
L_701D:
	ld b,001h		;701d   ; Estado 5: casilla 0xC8, color 0x0F...
	ld c,00fh		;701f
	ld a,0c8h		;7021
	dec hl			;7023
	ld (hl),06fh		;7024   ; ...y la de al lado a 0x6F
	inc hl			;7026
L_7027:
	inc hl			;7027
	ld (hl),a			;7028   ; Poner la casilla
	inc hl			;7029
	ld a,c			;702a
	ld (hl),a			;702b   ; Y el color
	ld a,(iy+001h)		;702c
	cp b			;702f   ; Todavia no le toca cambiar
	ret nc			;7030
	ex de,hl			;7031
	dec (hl)			;7032   ; Un estado menos
	ex de,hl			;7033
	ret			;7034
L_7035:
	xor a			;7035   ; Apagarlo todo: casilla...
	ld (hl),a			;7036
	ld (de),a			;7037   ; ...estado...
	ld (iy+000h),a		;7038   ; ...sitio y cuenta
	ld (iy+002h),a		;703b
	dec hl			;703e
	ld a,0e0h		;703f   ; Y aparcar su sprite
	ld (hl),a			;7041
	ret			;7042
L_7043:
	call el_escenario_de_la_ronda		;7043   ; En que escenario
	cp 004h		;7046   ; El 4 va por otro lado
	jr z,$+129		;7048
	cp 001h		;704a
	push af			;704c
	call z,sube_o_baja_una_fila		;704d   ; En el 1, ademas, ondea
	pop af			;7050
	cp 005h		;7051   ; El escenario 5 va mas deprisa
	push af			;7053
	ld a,b			;7054   ; Hacia que lado va
	and a			;7055
	ld a,(0e06ah)		;7056   ; Y en que vuelta
	jr nz,L_706D		;7059
	and a			;705b
	jr z,L_705F		;705c   ; A la derecha: cuatro columnas...
	inc (hl)			;705e   ; ...o cinco en la segunda vuelta
L_705F:
	inc (hl)			;705f
	inc (hl)			;7060
	inc (hl)			;7061
	pop af			;7062
	jr nz,L_7067		;7063
	inc (hl)			;7065   ; Y dos mas en el escenario 5
	inc (hl)			;7066
L_7067:
	ld a,(hl)			;7067
	cp 0f8h		;7068   ; Pasado 0xF8 se acabo
	ret c			;706a
	jr L_707D		;706b
L_706D:
	and a			;706d
	jr z,L_7071		;706e
	dec (hl)			;7070   ; A la izquierda, igual pero restando
L_7071:
	dec (hl)			;7071   ; Tres columnas a la izquierda
	dec (hl)			;7072
	dec (hl)			;7073
	pop af			;7074
	jr nz,L_7079		;7075   ; En el escenario 5...
	dec (hl)			;7077   ; ...dos mas
	dec (hl)			;7078
L_7079:
	ld a,(hl)			;7079
	cp 008h		;707a   ; Y por debajo de 8 se acabo
	ret nc			;707c
L_707D:
	jr L_7035		;707d
sube_o_baja_una_fila:
	dec hl			;707f   ; La fila
	ld a,(iy+000h)		;7080   ; Hacia arriba o hacia abajo?
	and a			;7083
	jr nz,L_7089		;7084
	dec (hl)			;7086   ; Una fila arriba...
	jr L_708A		;7087
L_7089:
	inc (hl)			;7089   ; ...o abajo
L_708A:
	inc (iy+002h)		;708a   ; Un paso mas de la onda
	ld a,(iy+002h)		;708d
	cp 010h		;7090   ; A los dieciseis...
	jr c,L_70A0		;7092
	xor a			;7094
	ld (iy+002h),a		;7095   ; ...vuelta a empezar...
	ld a,(iy+000h)		;7098
	xor 001h		;709b   ; ...y cambia el sentido: eso es lo que la hace ondear
	ld (iy+000h),a		;709d
L_70A0:
	inc hl			;70a0
	inc hl			;70a1
	ld a,(0e003h)		;70a2   ; Uno de cada ocho cuadros...
	and 00eh		;70a5
	jr nz,L_70AE		;70a7
	ld b,042h		;70a9   ; ...suena el silbido
	call pide_la_pieza_si_nada_lo_impide		;70ab
L_70AE:
	ld a,(0e003h)		;70ae   ; El contador de cuadros...
	rra			;70b1
	rra			;70b2
	and 003h		;70b3   ; ...da dos bits...
	push de			;70b5
	ld de,070c1h		;70b6   ; ...que eligen la casilla: gira
	call suma_a_a_de		;70b9
	ld a,(de)			;70bc
	pop de			;70bd
	ld (hl),a			;70be
	dec hl			;70bf
	ret			;70c0

; ----------------------------------------------------------------------
; DATOS cuatro_casillas_a: 0x70B6 las indexa con dos bits de una cuenta
;   0x70c1..0x70c5  (4 bytes)
DATA_cuatro_casillas_a:
	defb 0f0h,0f4h,0f8h,0fch	; 70c1

; ----------------------------------------------------------------------
; DATOS cuatro_casillas_b: las mismas cuatro, desde 0x70DE, que ademas pone un
;   6 detras
;   0x70c5..0x70c9  (4 bytes)
DATA_cuatro_casillas_b:
	defb 0f0h,0f4h,0f8h,0fch	; 70c5

; ======================================================================
; CODIGO 0x70c9..0x71ee  (293 bytes)
; ======================================================================


L_70C9:
	inc hl			;70c9   ; La casilla
	ld a,(0e003h)		;70ca
	and 00eh		;70cd
	jr nz,L_70D6		;70cf
	ld b,043h		;70d1   ; Otro silbido
	call pide_la_pieza_si_nada_lo_impide		;70d3
L_70D6:
	ld a,(0e003h)		;70d6
	rra			;70d9
	rra			;70da
	and 003h		;70db
	push de			;70dd
	ld de,070c5h		;70de
	call suma_a_a_de		;70e1
	ld a,(de)			;70e4
	pop de			;70e5
	ld (hl),a			;70e6
	inc hl			;70e7
	ld a,006h		;70e8   ; Color 6
	ld (hl),a			;70ea
	dec hl			;70eb
	dec hl			;70ec
	ld a,(ix+001h)		;70ed   ; La parte de abajo de la velocidad
	sub 020h		;70f0   ; Restarle 0x20: eso es la gravedad
	ld (ix+001h),a		;70f2
	jr nc,$+4		;70f5   ; Si se pasa...
	dec (ix+000h)		;70f7   ; ...se lleva una a la parte de arriba
	ld a,(ix+000h)		;70fa   ; La velocidad entera
	sub 000h		;70fd
	and a			;70ff   ; Sube o baja?
	jp p,L_710F		;7100
	neg		;7103   ; Subiendo: en positivo
	cp 006h		;7105   ; El tope son seis
	jr c,L_710B		;7107
	ld a,006h		;7109
L_710B:
	neg		;710b   ; Y otra vez en negativo
	jr L_7115		;710d
L_710F:
	cp 006h		;710f   ; Bajando: mismo tope
	jr c,L_7115		;7111
	ld a,006h		;7113
L_7115:
	ld (ix+000h),a		;7115   ; Guardar la velocidad recortada
	ld a,b			;7118   ; Hacia que lado va
	and a			;7119
	jr nz,L_7150		;711a
	ld a,(ix+000h)		;711c   ; Sube o baja?
	and a			;711f
	jp p,L_7139		;7120
	ld a,(hl)			;7123   ; La fila
	dec hl			;7124
	cp 0efh		;7125   ; Entre 0xE0 y 0xEF esta tapando algo...
	jr nc,L_7136		;7127
	cp 0e0h		;7129
	jr c,L_7136		;712b
	ld a,(hl)			;712d   ; ...y si lo que hay debajo es 0xC0...
	cp 0c0h		;712e
	jr nz,L_7136		;7130
	ld a,(iy+000h)		;7132   ; ...se devuelve la casilla que se habia guardado
	ld (hl),a			;7135
L_7136:
	inc hl			;7136
	jr L_714A		;7137
L_7139:
	ld a,(hl)			;7139   ; Bajando: de 0xF0 en adelante
	dec hl			;713a
	cp 0f0h		;713b
	jr c,L_7149		;713d
	ld a,(hl)			;713f
	cp 0c0h		;7140   ; Ya esta tapado?
	jr z,L_7149		;7142
	ld (iy+000h),a		;7144   ; Guardar la casilla de debajo...
	ld (hl),0c0h		;7147   ; ...y poner la de tapar
L_7149:
	inc hl			;7149
L_714A:
	ld a,(ix+000h)		;714a   ; Sumar la velocidad a la fila
	add a,(hl)			;714d
	jr L_7183		;714e
L_7150:
	ld a,(ix+000h)		;7150   ; Por el otro lado igual...
	and a			;7153
	jp m,L_716A		;7154
	ld a,(hl)			;7157   ; ...pero mirando el borde de arriba
	dec hl			;7158
	cp 010h		;7159
	jr nc,L_7167		;715b
	ld a,(hl)			;715d
	cp 0c0h		;715e
	jr z,L_7167		;7160
	ld (iy+000h),a		;7162
	ld (hl),0c0h		;7165
L_7167:
	inc hl			;7167
	jr L_717E		;7168
L_716A:
	ld a,(hl)			;716a   ; La fila
	dec hl			;716b
	cp 011h		;716c   ; Entre 0x11 y 0x20 esta tapando algo
	jr c,L_717D		;716e
	cp 020h		;7170
	jr nc,L_717D		;7172
	ld a,(hl)			;7174   ; Lo que hay debajo es la casilla de tapar?
	cp 0c0h		;7175
	jr nz,L_717D		;7177
	ld a,(iy+000h)		;7179   ; Entonces devolver la que se habia guardado
	ld (hl),a			;717c
L_717D:
	inc hl			;717d
L_717E:
	ld c,(ix+000h)		;717e   ; Aqui se resta en vez de sumar
	ld a,(hl)			;7181
	sub c			;7182
L_7183:
	ld (hl),a			;7183   ; La fila nueva
	add a,008h		;7184   ; Ocho de margen
	ld c,a			;7186
	ld a,(0e134h)		;7187   ; De que lado viene
	ld b,00dh		;718a   ; Trece de alcance...
	and a			;718c
	jr z,L_7191		;718d
	ld b,006h		;718f   ; ...o seis
L_7191:
	ld a,(0e156h)		;7191   ; Donde esta el jugador
	sub b			;7194
	cp c			;7195
	ret nc			;7196   ; Se ha pasado
	add a,013h		;7197   ; Y por el otro lado
	cp c			;7199
	ret c			;719a
	ld a,0e0h		;719b   ; Ha llegado: aparcar el sprite...
	dec hl			;719d
	ld (hl),a			;719e
	xor a			;719f   ; ...y apagar el estado
	ld (de),a			;71a0
	ret			;71a1
pide_la_pieza_si_nada_lo_impide:
	ld a,(0e10bh)		;71a2   ; Hay algo que lo impida?
	and a			;71a5
	ret nz			;71a6
	ld a,b			;71a7   ; Y pedir la pieza
	jp pide_pieza		;71a8
suelta_una_de_las_tres_del_escenario_0:
	call el_escenario_de_la_ronda		;71ab   ; En que escenario
	cp 000h		;71ae
	ret nz			;71b0   ; Solo el 0
	ld a,(0e137h)		;71b1   ; Por que fotograma va el golpe
	cp 006h		;71b4
	ret nz			;71b6   ; Solo el sexto
	ld a,(0e135h)		;71b7   ; Cual de las tres
	cp 003h		;71ba
	ret nc			;71bc   ; Ya estan las tres fuera
	ld de,071eeh		;71bd   ; Las tres casillas
	call suma_a_a_de		;71c0
	ld a,(de)			;71c3
	ld (0e1d0h),a		;71c4   ; La que toque
	ld hl,0e1d5h		;71c7   ; Su lado
	ld de,0e1d7h		;71ca   ; Y su estado
	ld a,(0e134h)		;71cd
	ld (hl),a			;71d0   ; El lado del que sale
	ld a,001h		;71d1
	ld (de),a			;71d3   ; Estado 1: suelta
	ld a,(0e133h)		;71d4   ; La fila del enemigo
	ld b,a			;71d7
	ld a,(hl)			;71d8
	and a			;71d9
	ld a,001h		;71da   ; Una mas...
	jr z,L_71E0		;71dc
	ld a,0fdh		;71de   ; ...o tres menos, segun el lado
L_71E0:
	add a,b			;71e0
	ld (0e1d1h),a		;71e1   ; Ahi arranca
	ld a,012h		;71e4   ; 0x12 cuadros
	ld (0e1d6h),a		;71e6
	ld a,045h		;71e9   ; Y el pitido
	jp pide_pieza		;71eb

; ----------------------------------------------------------------------
; DATOS tres_por_0xe135: 0x12, 0x13 y 0x14; 0x71BD las indexa y deja el que
;   salga en (0xE1D0)
;   0x71ee..0x71f1  (3 bytes)
DATA_tres_por_0xe135:
	defb 012h,013h,014h	; 71ee

; ======================================================================
; CODIGO 0x71f1..0x7273  (130 bytes)
; ======================================================================


L_71F1:
	ld hl,0e1d6h		;71f1
	ld a,(hl)			;71f4   ; Le queda tiempo?
	and a			;71f5
	jr nz,L_7204		;71f6
	ld (0e1d7h),a		;71f8   ; Se acabo: apagarlo
	ld (0e1d8h),a		;71fb
	ld a,003h		;71fe
	ld (0e137h),a		;7200
	ret			;7203
L_7204:
	dec a			;7204   ; Un cuadro menos
	ld (hl),a			;7205
	ld a,(0e1d5h)		;7206   ; De que lado viene
	and a			;7209
	ld b,000h		;720a   ; Sin ajuste...
	jr nz,L_7210		;720c
	ld b,002h		;720e   ; ...o dos
L_7210:
	ld a,(hl)			;7210
	cp 008h		;7211   ; Por debajo de 8 se acabo
	jr nc,L_7216		;7213
	inc b			;7215
L_7216:
	cp 007h		;7216   ; El fotograma 7 va aparte
	jr z,L_723D		;7218
	ld hl,0e1d1h		;721a   ; La columna
	ld a,b			;721d
	ld c,a			;721e
	and a			;721f   ; Segun el lado...
	ld a,(hl)			;7220
	jr z,L_7229		;7221
	dec c			;7223   ; ...se ajusta de una manera o de otra
	jr z,L_722D		;7224
	dec c			;7226
	jr z,L_722D		;7227
L_7229:
	sub 001h		;7229
	jr L_722F		;722b
L_722D:
	add a,001h		;722d
L_722F:
	ld (hl),a			;722f
	jr c,L_7236		;7230
	cp 01eh		;7232
	jr nz,L_723D		;7234
L_7236:
	ld hl,0e1d8h		;7236
	ld a,(hl)			;7239
	xor 001h		;723a
	ld (hl),a			;723c
L_723D:
	push bc			;723d   ; La columna...
	ld a,(0e1d1h)		;723e
	add a,a			;7241   ; ...por ocho, que es lo que mide una casilla
	add a,a			;7242
	add a,a			;7243
	ld b,a			;7244
	ld a,(0e1d5h)		;7245   ; De que lado viene
	and a			;7248
	ld a,b			;7249
	jr nz,L_724E		;724a
	add a,00eh		;724c
L_724E:
	ld (0e14dh),a		;724e   ; Ahi va la columna
	ld a,(0e1d8h)		;7251   ; Hay ajuste?
	and a			;7254
	jr nz,L_725D		;7255
	ld a,(0e1d0h)		;7257   ; La fila, por ocho
	add a,a			;725a
	add a,a			;725b
	add a,a			;725c
L_725D:
	ld (0e14ch),a		;725d   ; Ahi va la fila
	ld bc,(0e1d0h)		;7260   ; La posicion entera
	ld (0e170h),bc		;7264
	pop bc			;7268
	ld hl,07273h		;7269   ; La tabla de figuras
	ld a,b			;726c
	call lee_la_entrada_de_la_tabla		;726d   ; La que toque
	jp pinta_figura_sin_sprites		;7270   ; Y a pintarla

; ----------------------------------------------------------------------
; DATOS tabla_de_las_cuatro_figuras: cuatro punteros; cierra en 0x727B
;   0x7273..0x727b  (8 bytes)
DATA_tabla_de_las_cuatro_figuras:
	defw 0727bh,0727fh,07283h,07287h	; 7273  -> DATA_cuatro_figuras 0x727f 0x7283 0x7287

; ----------------------------------------------------------------------
; DATOS cuatro_figuras: las cuatro que apunta, de cuatro bytes cada una;
;   0x7269 elige con B y las pinta con L_675D; 4 figura(s), medidas con
;   tools/formatos.py
;   0x727b..0x728b  (16 bytes)
DATA_cuatro_figuras:
	defb 001h,002h,0cah,0c9h	; 727b
	defb 001h,002h,000h,0cah	; 727f
	defb 001h,002h,051h,052h	; 7283
	defb 001h,002h,052h,000h	; 7287

; ======================================================================
; CODIGO 0x728b..0x72ff  (116 bytes)
; ======================================================================


avanza_el_paso_del_agarre:
	ld a,(0e138h)		;728b   ; El fotograma
	cp 004h		;728e
	ret nc			;7290   ; De 4 en adelante, nada
	ld de,0e1d3h		;7291   ; La espera
	ld hl,0e1d2h		;7294   ; Y el paso
	ld a,(de)			;7297
	and a			;7298   ; Todavia espera
	jr nz,L_72A4		;7299
	inc (hl)			;729b   ; Un paso mas
	ld a,(hl)			;729c
	cp 005h		;729d
	ret nz			;729f
	ld a,001h		;72a0
	ld (de),a			;72a2
	ret			;72a3
L_72A4:
	dec (hl)			;72a4   ; Una menos
	ld a,(hl)			;72a5
	and a			;72a6
	ret nz			;72a7   ; Todavia dura
	ld (de),a			;72a8   ; Se acabo
	ret			;72a9
mueve_el_agarre:
	ld b,000h		;72aa   ; B = 0
	ld hl,0e138h		;72ac   ; El fotograma
	ld a,(hl)			;72af
	and a			;72b0
	jr z,L_72C0		;72b1   ; Los fotogramas 0 y 1 no llevan ajuste
	dec a			;72b3
	jr z,L_72C0		;72b4
	ld a,(hl)			;72b6
	bit 0,a		;72b7   ; Y su bit 0 lo elige
	ld a,001h		;72b9
	jr nz,L_72BF		;72bb
	ld a,0ffh		;72bd
L_72BF:
	ld b,a			;72bf
L_72C0:
	ld a,(0e133h)		;72c0
	add a,b			;72c3
	ld (0e1d4h),a		;72c4
	ret			;72c7
pinta_el_agarre_en_la_ultima_fila:
	call mueve_el_agarre		;72c8   ; Mover el agarre
	ld a,(0e137h)		;72cb   ; Hay golpe en marcha?
	and a			;72ce
	ret nz			;72cf
	ld a,(0e138h)		;72d0   ; El fotograma
	cp 012h		;72d3   ; De 0x12 en adelante, nada
	ret nc			;72d5
	ld hl,03a00h		;72d6   ; Limpiar la ultima fila
	ld c,020h		;72d9
	xor a			;72db
	call rellena_c_bytes_con_filvrm		;72dc
	ld de,0e1d2h		;72df
	ld a,(de)			;72e2
	ld hl,072ffh		;72e3
	call suma_a_a_hl		;72e6
	ld a,(0e1d4h)		;72e9
	add a,(hl)			;72ec
	ld (0e171h),a		;72ed
	ld a,011h		;72f0
	ld (0e170h),a		;72f2
	ld hl,07305h		;72f5
	ld a,(de)			;72f8
	call lee_la_entrada_de_la_tabla		;72f9
	jp pinta_figura_sin_sprites		;72fc

; ----------------------------------------------------------------------
; DATOS ajustes_de_fila: seis: 0xFC, 0xFD, 0xFE y tres ceros; 0x72E3 los
;   indexa con (0xE1D2) y los suma a (0xE1D4)
;   0x72ff..0x7305  (6 bytes)
DATA_ajustes_de_fila:
	defb 0fch,0fdh,0feh,000h,000h,000h	; 72ff

; ----------------------------------------------------------------------
; DATOS tabla_de_las_seis_figuras: seis punteros; cierra en 0x7311
;   0x7305..0x7311  (12 bytes)
DATA_tabla_de_las_seis_figuras:
	defw 07311h,07317h,0731ch,07320h,07324h,07329h	; 7305

; ----------------------------------------------------------------------
; DATOS seis_figuras: las que apunta, y cierran al byte en 0x732F; 6
;   figura(s), medidas con tools/formatos.py
;   0x7311..0x732f  (30 bytes)
DATA_seis_figuras:
	defb 001h,004h,0cah,0c9h,0c9h,0c9h	; 7311
	defb 001h,003h,0cah,0c9h,0c9h	; 7317
	defb 001h,002h,0cah,0c9h	; 731c
	defb 001h,002h,051h,052h	; 7320
	defb 001h,003h,051h,051h,052h	; 7324
	defb 001h,004h,051h,051h,051h,052h	; 7329

; ======================================================================
; CODIGO 0x732f..0x73f1  (194 bytes)
; ======================================================================


haz_lo_que_solo_hay_con_un_jugador:
	ld a,(0e002h)		;732f   ; Con dos jugadores no hay nada de esto
	bit 5,a		;7332
	ret nz			;7334
	ld a,(0e10bh)		;7335   ; El jugador esta a lo suyo?
	cp 002h		;7338
	ret nc			;733a
	call cuenta_el_descanso_entre_asaltos		;733b   ; El descanso entre asaltos
	ld a,(0e107h)		;733e   ; Solo en el modo 3...
	cp 003h		;7341
	ret nz			;7343
	call reparte_la_subescena_del_bicho		;7344   ; ...hay bicho volando...
	call el_extra_del_cartucho_vecino		;7347   ; ...y premio del cartucho hermano
	jp L_752D		;734a   ; Y subir sus atributos
cuenta_el_descanso_entre_asaltos:
	ld hl,0e265h		;734d   ; La cuenta del descanso
	ld a,(hl)			;7350
	and a			;7351   ; No hay descanso
	jr z,L_7375		;7352
	dec (hl)			;7354   ; Una menos
	ret nz			;7355
	ld a,024h		;7356   ; Las dos barras, llenas otra vez
	ld (0e100h),a		;7358
	ld (0e101h),a		;735b
	xor a			;735e   ; Y el aviso, apagado
	ld (0e108h),a		;735f
	ld de,0e266h		;7362   ; De quien era el turno
	ld a,(de)			;7365
	and a			;7366
	jr nz,L_736D		;7367   ; Del jugador
	ld hl,0e2f1h		;7369   ; Del otro: una vida suya menos
	dec (hl)			;736c
L_736D:
	xor a			;736d
	ld (de),a			;736e   ; Limpiar el turno
	ld bc,00000h		;736f   ; Y a la escena 0
	jp pon_las_escenas_del_jugador_y_del_enemigo		;7372
L_7375:
	ld a,(0e100h)		;7375   ; Le queda barra al jugador?
	and a			;7378
	ret z			;7379
	ld a,(0e102h)		;737a   ; Y al otro?
	and a			;737d
	ret z			;737e
	ld a,(0e2f1h)		;737f   ; Le quedan vidas al otro?
	and a			;7382
	ret z			;7383
	ld a,(0e008h)		;7384   ; Se pulso la tecla de rendirse?
	and 020h		;7387
	ret z			;7389
	ld b,000h		;738a   ; B = 0: se rinde el jugador
L_738C:
	ld a,010h		;738c   ; 0x10 cuadros de descanso
	ld (0e265h),a		;738e
	ld a,b			;7391   ; Y de quien fue
	ld (0e266h),a		;7392
	ld bc,00404h		;7395   ; El fotograma de caerse
	call pon_las_escenas_del_jugador_y_del_enemigo		;7398
	ld hl,0e108h		;739b   ; Es la primera vez?
	ld a,(hl)			;739e
	and a			;739f
	jr z,L_73B2		;73a0
	ld a,(0e107h)		;73a2   ; El modo de juego...
	and 003h		;73a5
	cp 003h		;73a7
	ld a,093h		;73a9   ; ...elige la musica de despues
	jr nz,L_73AF		;73ab
	ld a,095h		;73ad
L_73AF:
	ld (0e041h),a		;73af   ; Queda en cola
L_73B2:
	ld a,011h		;73b2   ; Y suena la de ahora
	jp pide_pieza_si_la_escena_lo_permite		;73b4
pinta_el_marcador_de_vidas:
	ld hl,03ae0h		;73b7   ; La fila del marcador de vidas
	ld c,010h		;73ba   ; Dieciseis casillas...
	xor a			;73bc
	call rellena_c_bytes_con_filvrm		;73bd   ; ...a cero
	ld a,(0e2f0h)		;73c0   ; Las vidas del jugador
	and a			;73c3
	jr z,L_73CF		;73c4   ; Ninguna
	ld c,a			;73c6
	ld hl,03ae7h		;73c7   ; Se pintan desde 0x3AE7...
	ld a,084h		;73ca   ; ...con la casilla 0x84
	call rellena_c_bytes_con_filvrm		;73cc
L_73CF:
	ld a,(0e003h)		;73cf   ; El bit 2 del cuadro...
	bit 2,a		;73d2
	ret nz			;73d4   ; ...las hace parpadear
	ld a,(0e2f1h)		;73d5   ; Las del otro
	and a			;73d8
	ret z			;73d9
	ld c,a			;73da
	ld hl,03ae3h		;73db   ; Desde 0x3AE3...
	ld a,083h		;73de   ; ...con la 0x83
	jp rellena_c_bytes_con_filvrm		;73e0
reparte_la_subescena_del_bicho:
	ld a,(0e003h)		;73e3   ; Un cuadro de cada dos
	and 001h		;73e6
	ret nz			;73e8
	ld bc,(0e262h)		;73e9   ; La escena y la subescena del bicho
	ld a,c			;73ed
	call reparte_por_tabla		;73ee   ; Repartir

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_73f1: 6 entradas, tras el `call reparte_por_tabla`
;   de 0x73EE; detras sigue la primera, 0x73FD
;   0x73f1..0x73fd  (12 bytes)
DATA_tabla_de_subescenas_73f1:
	defw 073fdh,07427h,07458h,07483h,0748fh,0749ch	; 73f1

; ======================================================================
; CODIGO 0x73fd..0x74f1  (244 bytes)
; ======================================================================


L_73FD:
	ld a,(0e261h)		;73fd   ; Ya hay uno fuera?
	and a			;7400
	ret nz			;7401
	ld hl,0e300h		;7402   ; Esta el jugador a tiro?
	call mira_si_llego_a_su_sitio		;7405
	ret z			;7408   ; No
	ld de,0e250h		;7409   ; Su atributo
	ld a,028h		;740c   ; Fila 0x28
	ld (de),a			;740e
	ld a,(0e003h)		;740f   ; El contador de cuadros...
	srl a		;7412
	ld c,a			;7414
	srl a		;7415
	add a,c			;7417
	add a,020h		;7418   ; ...por 1,5 y mas 0x20: por ahi sale
	inc de			;741a
	ld (de),a			;741b
	inc de			;741c
	ld a,0dch		;741d   ; Casilla 0xDC
	ld (de),a			;741f
	inc de			;7420
	ld a,00fh		;7421   ; Y color 0x0F
	ld (de),a			;7423
	jp L_746E		;7424
L_7427:
	ld hl,0e250h		;7427   ; Su atributo
	ld de,0e262h		;742a   ; Y su escena
	ld ix,0e260h		;742d
	ld b,062h		;7431   ; 0x62 cuadros de vida
	call mira_si_el_jugador_esta_en_lo_suyo		;7433   ; Sigue valiendo?
	jr z,L_743C		;7436
	ld a,005h		;7438   ; No: a la escena 5
	ld (de),a			;743a
	ret			;743b
L_743C:
	inc (hl)			;743c   ; Un cuadro mas
	ld a,(hl)			;743d
	cp b			;743e   ; Se le acabo?
	ret c			;743f
	ld a,0b0h		;7440   ; Entonces 0xB0 de espera...
	ld (ix+000h),a		;7442
	ex de,hl			;7445
	inc (hl)			;7446   ; ...y a la escena siguiente
	ret			;7447
mira_si_el_jugador_esta_en_lo_suyo:
	ld a,(0e10bh)		;7448   ; En que anda el jugador
	dec a			;744b
	dec a			;744c
	jr z,L_7455		;744d
	dec a			;744f
	jr z,L_7455		;7450
	and 000h		;7452
	ret			;7454
L_7455:
	or 001h		;7455   ; Devolver "vale"
	ret			;7457
L_7458:
	ld hl,0e253h		;7458   ; La coordenada del bicho
	call alterna_el_color_del_premio		;745b   ; Toca al jugador?
	jr z,L_7473		;745e
	ld a,0a8h		;7460   ; 0xA8 cuadros de castigo
	ld (0e29eh),a		;7462
	ld de,0e260h		;7465
	ld hl,0e252h		;7468
	call coge_el_premio		;746b   ; Sonar y apagarlo
L_746E:
	ld hl,0e262h		;746e   ; Una escena mas
	inc (hl)			;7471
	ret			;7472
L_7473:
	call mira_si_el_jugador_esta_en_lo_suyo		;7473   ; Sigue valiendo?
	jr nz,L_747D		;7476
	ld hl,0e260h		;7478   ; La cuenta
	dec (hl)			;747b
	ret nz			;747c
L_747D:
	ld a,005h		;747d   ; Escena 5
L_747F:
	ld (0e262h),a		;747f
	ret			;7482
L_7483:
	ld hl,0e260h		;7483   ; La cuenta
	dec (hl)			;7486
	ret nz			;7487
	ld a,0e0h		;7488
	ld (0e250h),a		;748a
	jr L_746E		;748d
L_748F:
	ld hl,0e29eh		;748f
	dec (hl)			;7492
	ret nz			;7493
	ld a,001h		;7494
	ld (0e261h),a		;7496
L_7499:
	xor a			;7499
	jr L_747F		;749a
L_749C:
	ld a,0e0h		;749c
	ld (0e250h),a		;749e
	jr L_7499		;74a1

; ----------------------------------------------------------------------
; ======================================================================
; EL PREMIO DE TENER EL YIE AR KUNG-FU I EN LA OTRA RANURA
; ======================================================================
; 0xBF6C rastrea las cuatro ranuras al arrancar y compara dos sumas de
; 16 bytes contra las dos parejas de 0xBFD9, que son las de las DOS
; compilaciones del RC-725. Si lo encuentra, deja (0xE450) = 1, y este
; es el UNICO sitio de todo el cartucho que mira esa marca.
; Ademas exige nivel 3 o mas y un solo jugador (eso lo filtra 0x732F).
; ----------------------------------------------------------------------
el_extra_del_cartucho_vecino:		; Lo unico que mira 0xE450; ademas pide ronda >= 3
	ld a,(0e450h)		;74a3   ; La marca del cartucho vecino
	and a			;74a6
	ret z			;74a7   ; Sin el, no hay premio
	ld a,(0e053h)		;74a8   ; El nivel
	cp 003h		;74ab
	ret c			;74ad   ; Antes del tercero, tampoco
	ld a,(0e003h)		;74ae   ; Un cuadro de cada dos
	and 001h		;74b1
	ret nz			;74b3
	ld de,0e254h		;74b4   ; El atributo donde va
	ld a,(0e271h)		;74b7   ; Ya se cogio?
	and a			;74ba
	jr nz,L_74E4		;74bb
	ld a,(0e100h)		;74bd   ; La barra del jugador...
	cp 009h		;74c0   ; ...tiene que estar bajo mininos
	jr nc,L_74E4		;74c2
	ld a,(0e102h)		;74c4   ; Y la otra tambien
	cp 00dh		;74c7
	jr nc,L_74E4		;74c9
	ld a,(0e272h)		;74cb   ; Por que paso va
	dec a			;74ce
	jr z,$+38		;74cf
	dec a			;74d1
	jr z,$+50		;74d2
	ld hl,074f1h		;74d4   ; Los cuatro bytes del atributo
	ld bc,00004h		;74d7
	ldir		;74da   ; Copiados
	call pinta_la_figura_del_premio		;74dc   ; Pintar la figura
	ld hl,0e272h		;74df
	inc (hl)			;74e2   ; Y un paso mas
	ret			;74e3
L_74E4:
	ld a,0e0h		;74e4   ; Aparcar el sprite
	ld (de),a			;74e6
	xor a			;74e7
	ld (0e272h),a		;74e8   ; Y el paso, a cero
	ret			;74eb
apunta_a_las_casillas_guardadas:
	ld de,0e460h		;74ec
	jr $+44		;74ef

; ----------------------------------------------------------------------
; DATOS los_cuatro_del_extra: 38 78 e0 0f; 0x74D4 los copia con ldir y llama a
;   0x7518. Es el premio de haber encontrado el Yie Ar Kung-Fu I en la otra
;   ranura
;   0x74f1..0x74f5  (4 bytes)
DATA_los_cuatro_del_extra:
	defb 038h,078h,0e0h,00fh	; 74f1

; ======================================================================
; CODIGO 0x74f5..0x7525  (48 bytes)
; ======================================================================


L_74F5:
	ld hl,0e254h		;74f5   ; El atributo del premio
	ld de,0e272h		;74f8   ; Y su cuenta
	ld ix,0e273h		;74fb
	ld b,072h		;74ff   ; 0x72 cuadros
	jp L_743C		;7501
L_7504:
	ld hl,0e257h		;7504   ; La coordenada del premio
	call alterna_el_color_del_premio		;7507   ; Lo ha cogido el jugador?
	ret z			;750a
	xor a			;750b
	ld (0e272h),a		;750c   ; El paso, a cero
	inc a			;750f
	ld (0e271h),a		;7510   ; Y marcarlo como cogido
	ld b,001h		;7513
	jp L_738C		;7515
pinta_la_figura_del_premio:
	ld de,07525h		;7518   ; La figura del premio
L_751B:
	ld bc,00e06h		;751b   ; En la fila 6, columna 14
	ld (0e170h),bc		;751e
	jp pinta_figura_sin_sprites		;7522

; ----------------------------------------------------------------------
; DATOS figura_del_extra: la figura de 3x4 que 0x7518 pinta en (0xE170) =
;   0x0E06; 1 figura(s), medida con tools/formatos.py
;   0x7525..0x752d  (8 bytes)
DATA_figura_del_extra:
	defb 003h,004h,001h,0f3h,090h,001h,0f7h,093h	; 7525  ........

; ======================================================================
; CODIGO 0x752d..0x75e3  (182 bytes)
; ======================================================================


L_752D:
	ld hl,0e250h		;752d   ; Los ocho bytes del premio...
	ld de,0e090h		;7530
	ld bc,00008h		;7533   ; ...a los atributos de sprite
	ldir		;7536
	ret			;7538
alterna_el_color_del_premio:
	ld a,(0e003h)		;7539   ; El contador de cuadros
	bit 1,a		;753c   ; Su bit 1 alterna el color...
	ld a,00fh		;753e
	jr z,L_7544		;7540
	ld a,00dh		;7542
L_7544:
	ld (hl),a			;7544   ; ...entre 0x0F y 0x0D: parpadea
	dec hl			;7545
	dec hl			;7546
	dec hl			;7547
	ld a,(0e110h)		;7548   ; El jugador esta a lo suyo?
	and a			;754b
	jr nz,L_7558		;754c
	ld c,001h		;754e   ; Montar su caja
	ld b,003h		;7550
	call monta_la_caja_en_0xe19d		;7552
	jp se_tocan		;7555   ; Y mirar el toque
L_7558:
	and 000h		;7558   ; Sin toque
	ret			;755a
coge_el_premio:
	ld a,011h		;755b   ; El pitido del premio
	call pide_pieza_si_la_escena_lo_permite		;755d
	ld a,020h		;7560   ; El sprite, aparcado
	ld (de),a			;7562
	ld a,0d0h		;7563   ; Y la coordenada fuera
	ld (hl),a			;7565
	inc hl			;7566
	ld a,00fh		;7567
	ld (hl),a			;7569
	ld d,005h		;756a   ; Cinco puntos de tanteo
	jp suma_puntos_en_bcd		;756c
suelta_una_de_las_tres_del_escenario_6:
	call el_escenario_de_la_ronda		;756f   ; En que escenario
	cp 006h		;7572
	ret nz			;7574   ; Solo el 6
	ld a,(0e137h)		;7575   ; Por que fotograma va el golpe
	cp 006h		;7578
	ret nz			;757a   ; Solo el sexto
	ld a,(0e135h)		;757b   ; Cual de las tres
	cp 003h		;757e
	ret nc			;7580   ; Ya estan las tres fuera
	ld hl,0e1c0h		;7581   ; Cual de las dos ranuras toca
	ld a,(hl)			;7584
	and a			;7585   ; Ocupada?
	jr z,L_758E		;7586
	ld de,0e1b0h		;7588   ; Entonces la otra
	xor a			;758b
	jr L_7593		;758c
L_758E:
	ld de,0e1a0h		;758e   ; La primera
	ld a,001h		;7591
L_7593:
	ld (hl),a			;7593   ; Y apuntar cual queda para la vez siguiente
	ld a,(de)			;7594
	and a			;7595   ; Ya estaba fuera?
	ret nz			;7596
	ld a,001h		;7597   ; Estado 1: suelta
	ld (de),a			;7599
	inc de			;759a
	inc de			;759b
	ld a,087h		;759c   ; Fila 0x87
	ld (de),a			;759e
	inc de			;759f
	inc de			;75a0
	ld a,(0e156h)		;75a1   ; Donde esta el jugador
	ld b,a			;75a4
	ld a,(0e134h)		;75a5   ; Por que lado sale
	and a			;75a8
	ld a,010h		;75a9   ; Dieciseis a un lado...
	jr z,L_75B1		;75ab
	neg		;75ad   ; ...o veinticuatro al otro
	sub 008h		;75af
L_75B1:
	add a,b			;75b1   ; Sumado a la columna del jugador
	ld (de),a			;75b2
	inc de			;75b3
	ld a,000h		;75b4   ; Sin desplazamiento
	ld (de),a			;75b6
	ld a,006h		;75b7   ; Casilla 6
	inc de			;75b9
	ld (de),a			;75ba
	ld a,0f0h		;75bb   ; Color 0xF0
	inc de			;75bd
	ld (de),a			;75be
	ld a,007h		;75bf   ; Y ancho 7
	inc de			;75c1
	ld (de),a			;75c2
	ld a,(0e134h)		;75c3   ; El lado
	inc de			;75c6
	ld (de),a			;75c7
	ld hl,075e3h		;75c8   ; Las cuatro velocidades
	ld a,(0e003h)		;75cb   ; El contador de cuadros...
	rra			;75ce
	rra			;75cf
	rra			;75d0
	rra			;75d1
	rra			;75d2
	rra			;75d3
	and 003h		;75d4   ; ...da dos bits...
	add a,a			;75d6   ; ...y cada velocidad son dos bytes
	call suma_a_a_hl		;75d7
	ld a,(hl)			;75da
	inc de			;75db
	inc de			;75dc
	ld (de),a			;75dd   ; La parte de arriba
	inc hl			;75de
	ld a,(hl)			;75df
	inc de			;75e0
	ld (de),a			;75e1   ; Y la de abajo
	ret			;75e2

; ----------------------------------------------------------------------
; DATOS cuatro_palabras: 0x0400, 0x0360, 0x0250 y 0x0080; 0x75C8 las indexa
;   con dos bits de (0xE003)
;   0x75e3..0x75eb  (8 bytes)
DATA_cuatro_palabras:
	defw 00400h,00360h,00250h,00080h	; 75e3

; ======================================================================
; CODIGO 0x75eb..0x77b0  (453 bytes)
; ======================================================================


L_75EB:
	call mira_los_toques_y_repasa_las_dos_ranuras		;75eb   ; Mover lo del escenario 6
	ld ix,0e1a0h		;75ee   ; La primera ranura
	ld hl,0e1abh		;75f2
	ld de,0e1a3h		;75f5
	call reparte_por_el_estado_de_la_ranura		;75f8   ; Moverla
	call sube_los_atributos_de_las_dos_ranuras		;75fb   ; Y subir sus sprites
	ld ix,0e1b0h		;75fe   ; La segunda
	ld hl,0e1bbh		;7602
	ld de,0e1b3h		;7605
	call reparte_por_el_estado_de_la_ranura		;7608
	jp sube_los_atributos_de_las_dos_ranuras		;760b   ; Y sus sprites
reparte_por_el_estado_de_la_ranura:
	ld a,(0e10bh)		;760e   ; El jugador esta a lo suyo?
	cp 002h		;7611
	ret nc			;7613
	ld a,(ix+000h)		;7614   ; En que estado esta
	and a			;7617
	ret z			;7618   ; Apagada
	dec a			;7619   ; Estado 1
	jr z,L_766D		;761a
	dec a			;761c   ; Estado 2
	jp z,L_776B		;761d
	dec a			;7620   ; Estado 3
	jp z,L_776F		;7621
	dec a			;7624   ; Estado 4
	jp z,L_7773		;7625
	dec a			;7628   ; Estado 5
	jp z,L_7663		;7629
	dec a			;762c   ; Estado 6
	jp z,L_7652		;762d
	dec a			;7630   ; Estado 7
	jp z,L_763A		;7631
	ld a,0e0h		;7634   ; Y si no, aparcar el sprite
	dec de			;7636
	ld (de),a			;7637
	jr L_7668		;7638
L_763A:
	ld a,0c8h		;763a   ; Casilla 0xC8...
	ld b,00fh		;763c   ; ...y color 0x0F
	call pon_la_casilla_y_el_color_y_descuenta		;763e
	ret nz			;7641   ; Todavia no ha acabado
	inc (ix+000h)		;7642   ; Un estado mas
	ret			;7645
pon_la_casilla_y_el_color_y_descuenta:
	inc de			;7646
	inc de			;7647
	inc de			;7648
	inc de			;7649
	ld (de),a			;764a   ; La casilla
	ld a,b			;764b
	inc de			;764c
	ld (de),a			;764d   ; Y el color
	inc hl			;764e
	inc hl			;764f
	dec (hl)			;7650   ; Y una cuenta menos
	ret			;7651
L_7652:
	ld a,0d4h		;7652   ; Casilla 0xD4
	ld b,007h		;7654   ; Y color 7
	call pon_la_casilla_y_el_color_y_descuenta		;7656
	ret nz			;7659   ; Todavia no
	ld a,007h		;765a   ; Estado 7
	ld (ix+000h),a		;765c
	ld a,010h		;765f   ; Y 0x10 de cuenta
	ld (hl),a			;7661
	ret			;7662
L_7663:
	ld a,0e0h		;7663   ; Aparcar el sprite
	ld (ix+002h),a		;7665
L_7668:
	xor a			;7668
	ld (ix+000h),a		;7669   ; Y el estado, a cero
	ret			;766c
L_766D:
	ld a,(ix+009h)		;766d   ; Hacia que lado va
	and a			;7670
	jr nz,L_7681		;7671
	ld a,(de)			;7673   ; A la derecha: sumar la parte de abajo...
	add a,(hl)			;7674
	ld (de),a			;7675
	inc hl			;7676
	inc de			;7677
	ld a,(de)			;7678
	adc a,(hl)			;7679   ; ...y la de arriba con el acarreo
	ld (de),a			;767a
	cp 0f0h		;767b   ; Pasado 0xF0 hay que dar la vuelta
	jr nc,L_768D		;767d
	jr L_7695		;767f
L_7681:
	ld a,(de)			;7681   ; A la izquierda: restar
	sub (hl)			;7682
	ld (de),a			;7683
	inc hl			;7684
	inc de			;7685
	ld a,(de)			;7686
	sbc a,(hl)			;7687
	ld (de),a			;7688
	cp 010h		;7689   ; Y por debajo de 0x10, igual
	jr nc,L_7695		;768b
L_768D:
	ld a,(ix+009h)		;768d
	xor 001h		;7690   ; Cambiar de sentido
	ld (ix+009h),a		;7692
L_7695:
	ex de,hl			;7695
	inc hl			;7696   ; La velocidad de caida
	ld a,(hl)			;7697
	sub 060h		;7698   ; Menos 0x60: la gravedad
	ld (hl),a			;769a
	inc hl			;769b
	ld a,(hl)			;769c   ; Con el acarreo a la parte de arriba
	sbc a,000h		;769d
	ld (hl),a			;769f
	ld a,(ix+002h)		;76a0   ; La fila...
	sub (hl)			;76a3   ; ...menos lo que cae
	ld (ix+002h),a		;76a4
	cp 0a0h		;76a7   ; Por encima de 0xA0 sigue en el aire
	ret c			;76a9
	dec hl			;76aa
	dec hl			;76ab
	ld a,(hl)			;76ac   ; Ha tocado suelo: guardar el rebote
	ld (ix+00eh),a		;76ad
	dec hl			;76b0
	dec hl			;76b1
	ld a,002h		;76b2   ; Estado 2
	dec hl			;76b4
	dec hl			;76b5
	ld (hl),a			;76b6
	ld a,010h		;76b7   ; Y 0x10 de cuenta
	inc de			;76b9
	ld (de),a			;76ba
	ld (ix+007h),0f4h		;76bb   ; Casilla 0xF4...
	ld (ix+008h),00fh		;76bf   ; ...y color 0x0F
	xor a			;76c3
	ld (ix+00fh),a		;76c4   ; Sin rebotes todavia
	ld a,044h		;76c7   ; El pitido del golpe contra el suelo
	jp pide_pieza		;76c9
mira_los_toques_y_repasa_las_dos_ranuras:
	call mira_si_el_jugador_rompe_alguna_ranura		;76cc   ; Mirar si le da al enemigo
	call mira_si_las_dos_le_dan_al_enemigo		;76cf   ; Y si le da al jugador
	ld iy,0e1a0h		;76d2   ; La primera ranura
	ld de,0e1a0h		;76d6
	ld hl,0e1a2h		;76d9
	call tumba_al_jugador_si_esta_le_toca		;76dc   ; Mirarla
	ld iy,0e1b0h		;76df   ; Y la segunda
	ld de,0e1b0h		;76e3
	ld hl,0e1b2h		;76e6
tumba_al_jugador_si_esta_le_toca:
	ld a,(de)			;76e9   ; Esta suelta?
	dec a			;76ea
	ret nz			;76eb
	call monta_la_caja_de_dos_y_mira_el_toque		;76ec   ; Toca al jugador?
	ret z			;76ef
	xor a			;76f0   ; Si: limpiar sus cuentas...
	ld (iy+00bh),a		;76f1
	ld (iy+00ch),a		;76f4
	jp devuelve_al_jugador_a_su_sitio		;76f7   ; ...y tumbarlo
monta_la_caja_de_dos_y_mira_el_toque:
	ld c,000h		;76fa   ; Montar la caja...
	call monta_la_caja_de_altura_dos		;76fc   ; ...de dos de alto...
	jp se_tocan		;76ff   ; ...y mirar el toque
mira_si_las_dos_le_dan_al_enemigo:
	ld hl,0e1a2h		;7702   ; La coordenada de la primera
	ld de,0e1a0h		;7705
	call mira_si_lo_lanzado_le_da_al_enemigo		;7708
	ld hl,0e1b2h		;770b   ; Y la de la segunda
	ld de,0e1b0h		;770e
mira_si_lo_lanzado_le_da_al_enemigo:
	ld a,(de)			;7711   ; Esta suelta?
	dec a			;7712
	ret nz			;7713
	push de			;7714
	ld d,(hl)			;7715   ; Su coordenada
	inc hl			;7716
	call mira_si_esta_dentro_de_la_caja_de_once		;7717   ; Le da al enemigo?
	pop de			;771a
	ret z			;771b   ; No
	push de			;771c
	ld d,001h		;771d   ; Un punto de tanteo
	call suma_puntos_en_bcd		;771f
	ld a,00bh		;7722   ; El pitido
	call pide_pieza		;7724
	pop de			;7727
	ld a,006h		;7728   ; Estado 6
	ld (de),a			;772a
	ld a,00dh		;772b   ; Y trece bytes mas alla...
	call suma_a_a_de		;772d
	ld a,005h		;7730   ; ...un 5
	ld (de),a			;7732
	ret			;7733
mira_si_el_jugador_rompe_alguna_ranura:
	ld a,(0e29eh)		;7734   ; Hay algo que lo impida?
	and a			;7737
	ret nz			;7738
	ld iy,0e1a0h		;7739   ; La primera
	ld hl,0e1a2h		;773d
	call mira_si_el_jugador_rompe_esta_ranura		;7740
	ld iy,0e1b0h		;7743   ; Y la segunda
	ld hl,0e1b2h		;7747
mira_si_el_jugador_rompe_esta_ranura:
	ld a,(iy+000h)		;774a   ; En que estado esta
	cp 002h		;774d
	ret c			;774f   ; Antes del 2 no se puede golpear
	cp 005h		;7750
	ret nc			;7752   ; Y del 5 en adelante, tampoco
	ld c,000h		;7753
	ld b,008h		;7755   ; Caja de ocho de alto
	call monta_la_caja_en_0xe19d		;7757
	call se_tocan		;775a   ; Le da el jugador?
	ret z			;775d   ; No
	call manda_al_enemigo_a_la_escena_4		;775e   ; Sumar el tanteo
	ld a,005h		;7761   ; Estado 5: rota
	ld (iy+000h),a		;7763
	ld a,00ch		;7766   ; Y el pitido de romperla
	jp pide_pieza		;7768
L_776B:
	ld b,00fh		;776b   ; Color 0x0F
	jr L_7775		;776d
L_776F:
	ld b,007h		;776f   ; Color 7
	jr L_7775		;7771
L_7773:
	ld b,004h		;7773   ; Color 4
L_7775:
	ld (ix+007h),0f4h		;7775   ; Casilla 0xF4
	ld (ix+008h),b		;7779
	ld a,(ix+00fh)		;777c   ; Por que rebote va
	add a,a			;777f   ; Dos bytes por rebote
	ld hl,077b0h		;7780
	call suma_a_a_hl		;7783
	ld a,(hl)			;7786
	add a,09ah		;7787   ; La fila del rebote, mas 0x9A
	ld (ix+002h),a		;7789
	inc hl			;778c
	ld a,(ix+00eh)		;778d
	add a,(hl)			;7790   ; Y la columna
	ld (ix+004h),a		;7791
	ld a,(ix+00fh)		;7794
	inc a			;7797
	cp 00ah		;7798
	jr c,L_779D		;779a
	xor a			;779c
L_779D:
	ld (ix+00fh),a		;779d   ; Guardar el rebote
	dec (ix+00dh)		;77a0   ; Un cuadro menos
	ld a,(ix+00dh)		;77a3
	ret nz			;77a6   ; Todavia dura
	ld a,005h		;77a7   ; Cinco cuadros
	ld (ix+00dh),a		;77a9
	inc (ix+000h)		;77ac   ; Y un estado mas
	ret			;77af

; ----------------------------------------------------------------------
; DATOS diez_parejas: 0x7780 entra con 2*(ix+15): del primer byte saca (ix+2)
;   sumandole 0x9A, y del segundo (ix+4) sumandole (ix+14)
;   0x77b0..0x77c4  (20 bytes)
DATA_diez_parejas:
	defb 0fch,006h	; 77b0
	defb 0f8h,0f8h	; 77b2
	defb 000h,008h	; 77b4
	defb 0f6h,0fch	; 77b6
	defb 0f8h,00bh	; 77b8
	defb 0fah,0feh	; 77ba
	defb 0fah,002h	; 77bc
	defb 000h,0f4h	; 77be
	defb 0fch,008h	; 77c0
	defb 000h,000h	; 77c2

; ======================================================================
; CODIGO 0x77c4..0x78de  (282 bytes)
; ======================================================================


sube_los_atributos_de_las_dos_ranuras:
	ld de,0e1e4h		;77c4   ; Los atributos que se van a subir
	ld hl,0e1a2h		;77c7   ; La primera ranura
	call monta_el_atributo_de_una_ranura		;77ca
	ld hl,0e1b2h		;77cd   ; Y la segunda
monta_el_atributo_de_una_ranura:
	ld a,(hl)			;77d0   ; La fila
	ld (de),a			;77d1
	inc de			;77d2
	inc hl			;77d3
	inc hl			;77d4
	ld a,(hl)			;77d5   ; La columna
	ld (de),a			;77d6
	inc de			;77d7
	inc hl			;77d8
	inc hl			;77d9
	inc hl			;77da
	ld a,(hl)			;77db   ; La casilla
	ld (de),a			;77dc
	inc de			;77dd
	inc hl			;77de
	ld a,(hl)			;77df   ; Y el color
	ld (de),a			;77e0
	inc de			;77e1
	ret			;77e2
suelta_las_tres_a_la_vez_del_escenario_7:
	call el_escenario_de_la_ronda		;77e3   ; En que escenario
	cp 007h		;77e6
	ret nz			;77e8   ; Solo el 7
	ld a,(0e137h)		;77e9   ; Por que fotograma va el golpe
	cp 006h		;77ec
	ret nz			;77ee   ; Solo el sexto
	ld a,(0e135h)		;77ef   ; Cual de las tres
	cp 003h		;77f2
	ret nc			;77f4   ; Ya estan las tres fuera
	ld a,003h		;77f5   ; Tres a la vez
	ld (0e1d2h),a		;77f7
	ret			;77fa
cuenta_la_espera_entre_una_y_otra:
	ld a,(0e10bh)		;77fb   ; El jugador esta a lo suyo?
	cp 002h		;77fe
	ret nc			;7800
	call el_escenario_de_la_ronda		;7801   ; En que escenario
	cp 007h		;7804
	ret nz			;7806   ; Solo el 7
	ld hl,0e1d3h		;7807   ; La espera entre una y otra
	ld a,(hl)			;780a
	and a			;780b   ; Ya se agoto
	jr z,L_7810		;780c
	dec (hl)			;780e   ; Una menos
	ret			;780f
L_7810:
	ld hl,0e1d2h		;7810   ; Cuantas quedan por soltar
	ld a,(hl)			;7813
	and a			;7814
	ret z			;7815   ; Ninguna
	dec a			;7816
	ld ix,0e1a0h		;7817   ; La primera ranura
	ld de,0e1a0h		;781b
	jr z,L_7833		;781e
	ld ix,0e1b0h		;7820   ; La segunda
	ld de,0e1b0h		;7824
	dec a			;7827
	jr z,L_7833		;7828
	ld ix,0e1c0h		;782a   ; Y la tercera
	ld de,0e1c0h		;782e
	dec a			;7831
	ret nz			;7832
L_7833:
	ld a,(de)			;7833   ; Ocupada?
	and a			;7834
	ret nz			;7835
	ld b,009h		;7836   ; Nueve cuadros de espera
	ld a,(0e102h)		;7838   ; La barra del jugador
	cp 01bh		;783b   ; Cuanto mas llena...
	jr nc,L_7847		;783d
	ld b,006h		;783f   ; ...mas espera: seis...
	cp 012h		;7841
	jr nc,L_7847		;7843
	ld b,003h		;7845   ; ...o tres
L_7847:
	ld a,(0e06ah)		;7847   ; En que vuelta
	and a			;784a
	jr z,L_785A		;784b
	dec a			;784d
	jr z,L_7854		;784e
	ld b,003h		;7850   ; De la tercera en adelante, tres fijos
	jr L_785A		;7852
L_7854:
	ld a,b			;7854
	sub 003h		;7855   ; En la segunda, tres menos
	jr z,L_785A		;7857
	ld b,a			;7859
L_785A:
	ld a,b			;785a
	ld (0e1d3h),a		;785b   ; Ahi queda la espera
	dec (hl)			;785e   ; Una menos por soltar
	ld a,001h		;785f
	ld (de),a			;7861   ; Estado 1: suelta
	ld a,020h		;7862
	inc de			;7864
	inc de			;7865
	ld (de),a			;7866   ; Fila 0x20
	ld a,(0e113h)		;7867   ; La columna del enemigo
	ld b,a			;786a
	ld a,(0e003h)		;786b
	bit 5,a		;786e   ; El bit 5 del cuadro...
	jr nz,L_7881		;7870
	bit 2,a		;7872   ; ...y el 2 deciden si se desplaza
	ld c,020h		;7874   ; 0x20 columnas
	jr z,L_787C		;7876
L_7878:
	ld a,b			;7878
	sub c			;7879
	jr nc,L_7880		;787a
L_787C:
	ld a,b			;787c
	add a,c			;787d
	jr c,L_7878		;787e
L_7880:
	ld b,a			;7880
L_7881:
	ld a,(0e003h)		;7881
	rra			;7884   ; El contador de cuadros...
	rra			;7885
	and 003h		;7886   ; ...da dos bits
	push af			;7888
	add a,a			;7889
	push af			;788a
	ld a,000h		;788b
	inc de			;788d
	inc de			;788e
	inc de			;788f
	ld (de),a			;7890   ; Sin desplazamiento
	inc de			;7891
	ld a,005h		;7892   ; Ancho 5
	ld (de),a			;7894
	inc de			;7895
	pop af			;7896
	ld hl,078deh		;7897   ; Las cuatro parejas
	call suma_a_a_hl		;789a
	ld a,(hl)			;789d
	ld (de),a			;789e   ; La casilla
	inc hl			;789f
	inc de			;78a0
	ld a,(hl)			;78a1   ; Y el color
	ld (de),a			;78a2
	pop af			;78a3
	ld hl,078e6h		;78a4   ; Y las dos de la otra tabla
	call suma_a_a_hl		;78a7
	ld a,(0e003h)		;78aa
	bit 1,a		;78ad   ; El bit 1 del cuadro elige el sentido
	ld a,(hl)			;78af
	ld c,a			;78b0
	jr nz,L_78BD		;78b1
L_78B3:
	ld a,b			;78b3
	sub c			;78b4   ; A la izquierda, si cabe
	jr c,L_78BD		;78b5
	ld b,a			;78b7
	xor a			;78b8   ; Sentido 0 y casilla 0xF4
	ld c,0f4h		;78b9
	jr L_78C6		;78bb
L_78BD:
	ld a,b			;78bd
	add a,c			;78be   ; A la derecha
	jr c,L_78B3		;78bf
	ld b,a			;78c1
	ld a,001h		;78c2   ; Sentido 1 y casilla 0xF0
	ld c,0f0h		;78c4
L_78C6:
	ld (ix+00bh),a		;78c6   ; El sentido
	ld (ix+004h),b		;78c9   ; La columna
	ld (ix+009h),c		;78cc   ; Y la casilla
	ld a,002h		;78cf   ; Dos cosas mas por soltar
	ld (0e1d1h),a		;78d1
	ld b,0eeh		;78d4   ; El borde se pone claro: eso es el fogonazo
	call pon_el_color_del_borde		;78d6
	ld a,04ah		;78d9   ; Y suena
	jp pide_pieza		;78db

; ----------------------------------------------------------------------
; DATOS cuatro_parejas_a: 0x7897 las indexa y copia las dos mitades seguidas
;   0x78de..0x78e6  (8 bytes)
DATA_cuatro_parejas_a:
	defb 000h,005h	; 78de
	defb 000h,001h	; 78e0
	defb 080h,002h	; 78e2
	defb 000h,000h	; 78e4

; ----------------------------------------------------------------------
; DATOS dos_parejas_b: las que carga 0x78A4 justo despues
;   0x78e6..0x78ea  (4 bytes)
DATA_dos_parejas_b:
	defb 070h,020h	; 78e6
	defb 038h,000h	; 78e8

; ======================================================================
; CODIGO 0x78ea..0x7909  (31 bytes)
; ======================================================================


L_78EA:
	ld a,(0e10bh)		;78ea   ; El jugador esta a lo suyo?
	cp 002h		;78ed
	jr nc,L_78FB		;78ef
	ld hl,0e1d1h		;78f1   ; Queda fogonazo?
	ld a,(hl)			;78f4
	and a			;78f5
	jr z,L_78FB		;78f6
	dec (hl)			;78f8   ; Uno menos
	jr L_7900		;78f9
L_78FB:
	ld b,0e0h		;78fb   ; Se acabo: el borde, negro otra vez
	call pon_el_color_del_borde		;78fd
L_7900:
	call sube_los_atributos_de_las_tres_ranuras		;7900   ; Subir los atributos
	ld a,(0e1d0h)		;7903   ; Y repartir por el estado
	call reparte_por_tabla		;7906

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_7909: 2 entradas, tras el `call reparte_por_tabla`
;   de 0x7906; detras sigue la primera, 0x790D
;   0x7909..0x790d  (4 bytes)
DATA_tabla_de_subescenas_7909:
	defw 0790dh,079c8h	; 7909  -> L_790D L_79C8

; ======================================================================
; CODIGO 0x790d..0x7a61  (340 bytes)
; ======================================================================


L_790D:
	call mira_si_alguna_toca_al_jugador		;790d   ; Mirar si le da al jugador
	ld ix,0e1a0h		;7910   ; La primera de las tres
	ld de,0e1a0h		;7914
	ld hl,0e1a5h		;7917
	call hazle_caer_o_apagala		;791a
	ld ix,0e1b0h		;791d   ; La segunda
	ld de,0e1b0h		;7921
	ld hl,0e1b5h		;7924
	call hazle_caer_o_apagala		;7927
	ld ix,0e1c0h		;792a   ; Y la tercera
	ld de,0e1c0h		;792e
	ld hl,0e1c5h		;7931
hazle_caer_o_apagala:
	ld a,(0e10bh)		;7934   ; El jugador esta a lo suyo?
	cp 002h		;7937
	ret nc			;7939
	ld a,(de)			;793a   ; En que estado esta
	and a			;793b
	ret z			;793c   ; Apagada
	dec a			;793d   ; Estado 1: cayendo
	jr z,L_7948		;793e
	xor a			;7940   ; Y si no, apagarla...
	ld (de),a			;7941
	ld a,0e0h		;7942   ; ...y aparcar su sprite
	inc de			;7944
	inc de			;7945
	ld (de),a			;7946
	ret			;7947
L_7948:
	inc de			;7948
	ld a,(de)			;7949   ; La fila, parte de abajo...
	add a,(hl)			;794a
	ld (de),a			;794b
	inc de			;794c
	inc hl			;794d
	ld a,(de)			;794e   ; ...y de arriba, con el acarreo
	adc a,(hl)			;794f
	ld (de),a			;7950
	cp 0a0h		;7951   ; Pasado 0xA0 se acabo
	jr nc,L_7977		;7953
	inc de			;7955
	inc hl			;7956
	ld a,(ix+00bh)		;7957   ; Hacia que lado va
	and a			;795a
	jr nz,L_796B		;795b
	ld a,(de)			;795d   ; A la derecha: sumar la columna
	add a,(hl)			;795e
	ld (de),a			;795f
	inc de			;7960
	inc hl			;7961
	ld a,(de)			;7962
	adc a,(hl)			;7963
	ld (de),a			;7964
	cp 0f0h		;7965   ; Sin pasar de 0xF0
	jr nc,L_7977		;7967
	jr L_797D		;7969
L_796B:
	ld a,(de)			;796b   ; A la izquierda: restar
	sub (hl)			;796c
	ld (de),a			;796d
	inc de			;796e
	inc hl			;796f
	ld a,(de)			;7970
	sbc a,(hl)			;7971
	ld (de),a			;7972
	cp 010h		;7973   ; Sin bajar de 0x10
	jr nc,L_797D		;7975
L_7977:
	ld a,002h		;7977   ; Estado 2: se apaga
	ld (ix+000h),a		;7979
	ret			;797c
L_797D:
	ld a,(0e003h)		;797d   ; El bit 1 del cuadro...
	bit 1,a		;7980
	ld a,00fh		;7982   ; ...alterna el color entre 0x0F...
	jr z,L_7988		;7984
	ld a,006h		;7986   ; ...y 6: destella
L_7988:
	inc hl			;7988
	inc hl			;7989
	ld (hl),a			;798a   ; Ahi va el color
	ret			;798b
mira_si_alguna_toca_al_jugador:
	ld a,(0e29eh)		;798c   ; Hay algo que lo impida?
	and a			;798f
	ret nz			;7990
	ld iy,0e1a0h		;7991   ; La primera
	ld de,0e1a0h		;7995
	ld hl,0e1a2h		;7998
	call enciende_el_rayo_si_esta_toca		;799b
	ld iy,0e1b0h		;799e   ; La segunda
	ld de,0e1b0h		;79a2
	ld hl,0e1b2h		;79a5
	call enciende_el_rayo_si_esta_toca		;79a8
	ld iy,0e1c0h		;79ab   ; Y la tercera
	ld de,0e1c0h		;79af
	ld hl,0e1c2h		;79b2
enciende_el_rayo_si_esta_toca:
	call monta_la_caja_de_dos_y_mira_el_toque		;79b5   ; Toca al jugador?
	ret z			;79b8   ; No
	ld a,001h		;79b9
	ld (0e1d0h),a		;79bb   ; Estado 1 del rayo
	ld a,002h		;79be
	ld (iy+000h),a		;79c0   ; Y esta, apagandose
	ld a,00ch		;79c3   ; El pitido
	jp pide_pieza		;79c5
L_79C8:
	xor a			;79c8   ; Apagar el rayo
	ld (0e1d0h),a		;79c9
manda_al_enemigo_a_la_escena_4:
	ld a,004h		;79cc   ; El enemigo pasa a la escena 4
	ld (0e130h),a		;79ce
	xor a			;79d1
	ld (0e10bh),a		;79d2   ; Y el jugador queda a lo suyo...
	inc a			;79d5
	ld (0e110h),a		;79d6   ; ...con la escena 1
	jp L_5457		;79d9
sube_los_atributos_de_las_tres_ranuras:
	ld hl,0e1a2h		;79dc   ; Los tres atributos...
	ld de,0e1e4h		;79df   ; ...a la copia que se sube
	call monta_el_atributo_de_una_de_las_tres		;79e2
	ld hl,0e1b2h		;79e5
	call monta_el_atributo_de_una_de_las_tres		;79e8
	ld hl,0e1c2h		;79eb
monta_el_atributo_de_una_de_las_tres:
	ld a,(hl)			;79ee   ; La fila
	ld (de),a			;79ef
	inc de			;79f0
	inc hl			;79f1
	inc hl			;79f2
	ld a,(hl)			;79f3   ; La columna
	ld (de),a			;79f4
	inc de			;79f5
	inc hl			;79f6
	inc hl			;79f7
	inc hl			;79f8
	inc hl			;79f9
	inc hl			;79fa
	ld a,(hl)			;79fb   ; La casilla
	ld (de),a			;79fc
	inc de			;79fd
	inc hl			;79fe
	ld a,(hl)			;79ff   ; Y el color
	ld (de),a			;7a00
	inc de			;7a01
	ret			;7a02
suelta_una_de_las_tres_del_escenario_3:
	call el_escenario_de_la_ronda		;7a03   ; En que escenario
	cp 003h		;7a06
	ret nz			;7a08   ; Solo el 3
	ld a,(0e137h)		;7a09   ; Por que fotograma va el golpe
	cp 006h		;7a0c
	ret nz			;7a0e   ; Solo el sexto
	ld a,(0e135h)		;7a0f   ; Cual de las tres
	cp 003h		;7a12
	ret nc			;7a14   ; Ya estan las tres fuera
	ld hl,0e1b0h		;7a15   ; La segunda ranura
	ld a,001h		;7a18
	ld (hl),a			;7a1a   ; Estado 1
	inc hl			;7a1b
	inc hl			;7a1c
	ld a,(0e155h)		;7a1d   ; La fila del enemigo
	ld (hl),a			;7a20
	inc hl			;7a21
	inc hl			;7a22
	ld a,(0e156h)		;7a23   ; Y su columna
	ld (hl),a			;7a26
	ld a,0f0h		;7a27   ; Casilla 0xF0
	ld (0e1b9h),a		;7a29
	ld a,00fh		;7a2c
	ld (0e1bah),a		;7a2e
	ld a,04dh		;7a31
	call pide_pieza		;7a33
	jp L_7C7E		;7a36
haz_lo_del_escenario_que_toque:
	call elige_el_color_que_parpadea		;7a39
	jp L_7C2D		;7a3c
elige_el_color_que_parpadea:
	ld hl,0e003h		;7a3f   ; Casilla 0xF0
	ld a,(hl)			;7a42
	bit 2,a		;7a43
	ld b,00fh		;7a45
	jr z,L_7A4B		;7a47
	ld b,001h		;7a49
L_7A4B:
	ld a,(hl)			;7a4b
	bit 3,a		;7a4c
	ld a,0f0h		;7a4e
	jr z,L_7A54		;7a50
	ld a,0f4h		;7a52
L_7A54:
	ld hl,0e1b9h		;7a54   ; La casilla...
	ld (hl),a			;7a57
	inc hl			;7a58
	ld (hl),b			;7a59   ; ...y el color
	ld hl,0e1b0h		;7a5a   ; El estado
	ld a,(hl)			;7a5d
	call reparte_por_tabla		;7a5e   ; Y a el

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_7a61: 7 entradas, tras el `call reparte_por_tabla`
;   de 0x7A5E; detras sigue la primera, 0x7A6F
;   0x7a61..0x7a6f  (14 bytes)
DATA_tabla_de_subescenas_7a61:
	defw 07a6fh,07a75h,07ac4h,07b68h,07beah,07c01h,07c0ch	; 7a61

; ======================================================================
; CODIGO 0x7a6f..0x7b58  (233 bytes)
; ======================================================================


L_7A6F:
	ld a,0e0h		;7a6f
	ld (0e1b2h),a		;7a71
	ret			;7a74
L_7A75:
	ld hl,0e1b1h		;7a75   ; La columna, parte de abajo
	ld a,(hl)			;7a78
	sub 0a0h		;7a79   ; Menos 0xA0
	ld (hl),a			;7a7b
	inc hl			;7a7c
	ld a,(hl)			;7a7d   ; Y la de arriba, con el acarreo
	sbc a,002h		;7a7e
	ld (hl),a			;7a80
	cp 030h		;7a81   ; Todavia no ha llegado a 0x30
	ret nc			;7a83
	ld hl,0e1b5h		;7a84   ; La velocidad
	xor a			;7a87
	ld (hl),a			;7a88
	inc hl			;7a89
	ld (hl),a			;7a8a
	inc hl			;7a8b
	ld a,000h		;7a8c
	ld (hl),a			;7a8e
	inc hl			;7a8f
	ld a,015h		;7a90   ; 0x15 a lo ancho
	ld (hl),a			;7a92
	inc hl			;7a93
	inc hl			;7a94
	inc hl			;7a95
	xor a			;7a96
	ld (hl),a			;7a97
	inc hl			;7a98
	ld a,040h		;7a99   ; 0x40 de referencia
	ld (0e1c0h),a		;7a9b
	ld b,a			;7a9e
	ld a,(0e1b2h)		;7a9f   ; La columna de ahora...
	sub b			;7aa2   ; ...menos esa referencia
	ld (hl),a			;7aa3
	ld a,(0e1b4h)		;7aa4   ; Y la fila
	inc hl			;7aa7
	ld (hl),a			;7aa8
	ld b,a			;7aa9
	inc hl			;7aaa
	xor a			;7aab
	ld (hl),a			;7aac
	inc hl			;7aad
	ld a,(0e1b4h)		;7aae   ; La misma fila...
	sub b			;7ab1   ; ...menos ella misma: cero
	ld (hl),a			;7ab2
	inc hl			;7ab3
	inc hl			;7ab4
	ld a,007h		;7ab5   ; Siete de ancho...
	ld (hl),a			;7ab7
	inc hl			;7ab8
	ld (hl),a			;7ab9   ; ...y siete de alto
	ld a,020h		;7aba   ; 0x20 de espera
	ld (0e1c5h),a		;7abc
L_7ABF:
	ld hl,0e1b0h		;7abf
	inc (hl)			;7ac2   ; Un estado mas
	ret			;7ac3
L_7AC4:
	call pide_el_zumbido_si_no_suena_ya		;7ac4   ; Mover lo que hay
	ld hl,0e1bdh		;7ac7   ; El desplazamiento
	ld a,(hl)			;7aca
	cp 080h		;7acb   ; Ya esta en 0x80?
	jr z,L_7AD4		;7acd
	inc (hl)			;7acf   ; Subirlo...
	ret c			;7ad0
	dec (hl)			;7ad1   ; ...y si se paso, dos atras
	dec (hl)			;7ad2
	ret			;7ad3
L_7AD4:
	ld hl,0e1c5h		;7ad4   ; La espera
	ld a,(hl)			;7ad7
	and a			;7ad8
	jr z,L_7ADD		;7ad9
	dec (hl)			;7adb   ; Una menos
	ret			;7adc
L_7ADD:
	ld a,(0e1b2h)		;7add   ; La columna
	cp 032h		;7ae0   ; Todavia no ha llegado
	ret nc			;7ae2
	ld a,(0e003h)		;7ae3   ; El contador de cuadros...
	rra			;7ae6
	rra			;7ae7
	push af			;7ae8
	and 003h		;7ae9   ; ...da dos bits para la velocidad...
	ld (0e1c3h),a		;7aeb
	pop af			;7aee
	rra			;7aef   ; ...y otro para el sentido
	rra			;7af0
	and 001h		;7af1
	ld (0e1c4h),a		;7af3
	ld a,032h		;7af6   ; La columna vuelve a 0x32
	ld (0e1b2h),a		;7af8
	ld hl,0e1b5h		;7afb   ; La velocidad
	xor a			;7afe
	ld (hl),a			;7aff
	inc hl			;7b00
	ld a,003h		;7b01   ; Tres
	ld (hl),a			;7b03
	inc hl			;7b04
	ld a,(0e1c3h)		;7b05   ; La velocidad elegida
	add a,a			;7b08
	ld de,07b58h		;7b09   ; Sus dos bytes
	call suma_a_a_de		;7b0c
	ld a,(0e1c4h)		;7b0f   ; Y el sentido...
	and a			;7b12
	ld a,(de)			;7b13
	jr z,L_7B18		;7b14
	neg		;7b16   ; ...la cambia de signo
L_7B18:
	ld (hl),a			;7b18   ; Ahi va
	inc de			;7b19
	inc hl			;7b1a
	ld a,(0e1c4h)		;7b1b   ; Lo mismo con el segundo byte
	and a			;7b1e
	ld a,(de)			;7b1f
	jr z,L_7B24		;7b20
	neg		;7b22
L_7B24:
	ld (hl),a			;7b24
	inc hl			;7b25
	inc hl			;7b26
	inc hl			;7b27
	xor a			;7b28
	ld (hl),a			;7b29
	inc hl			;7b2a
	ld a,(0e1b2h)		;7b2b   ; La columna...
	sub 064h		;7b2e   ; ...menos 0x64
	ld (hl),a			;7b30
	ld a,(0e1b4h)		;7b31   ; Y la fila
	inc hl			;7b34
	ld (hl),a			;7b35
	ld b,a			;7b36
	inc hl			;7b37
	xor a			;7b38
	ld (hl),a			;7b39
	inc hl			;7b3a
	ld a,(0e1b4h)		;7b3b   ; La misma fila menos ella: cero
	sub b			;7b3e
	ld (hl),a			;7b3f
	inc hl			;7b40
	ld a,064h		;7b41   ; 0x64 de referencia
	ld (hl),a			;7b43
	inc hl			;7b44
	ld a,(0e1c3h)		;7b45   ; La velocidad otra vez
	add a,a			;7b48
	ld de,07b60h		;7b49   ; Su tamano
	call suma_a_a_de		;7b4c
	ld a,(de)			;7b4f
	ld (hl),a			;7b50   ; Ancho...
	inc de			;7b51
	inc hl			;7b52
	ld a,(de)			;7b53
	ld (hl),a			;7b54   ; ...y alto
	jp L_7ABF		;7b55

; ----------------------------------------------------------------------
; DATOS cuatro_por_0xe1c3: 0x7B09 entra con 2*(0xE1C3) y NIEGA el valor si
;   (0xE1C4) no es cero
;   0x7b58..0x7b60  (8 bytes)
DATA_cuatro_por_0xe1c3:
	defb 000h,06ah	; 7b58
	defb 000h,040h	; 7b5a
	defb 000h,050h	; 7b5c
	defb 000h,059h	; 7b5e

; ----------------------------------------------------------------------
; DATOS ocho_mas: los que carga 0x7B49
;   0x7b60..0x7b68  (8 bytes)
DATA_ocho_mas:
	defb 001h,005h,004h,007h,005h,005h,002h,008h	; 7b60  ........

; ======================================================================
; CODIGO 0x7b68..0x7ca7  (319 bytes)
; ======================================================================


L_7B68:
	call pide_el_zumbido_si_no_suena_ya		;7b68   ; Mover lo que hay
	ld a,(0e1b2h)		;7b6b   ; La columna
	cp 032h		;7b6e
	ret nc			;7b70   ; Todavia no
	ld a,001h		;7b71
	ld (0e1b0h),a		;7b73   ; Estado 1
	ret			;7b76
pide_el_zumbido_si_no_suena_ya:
	ld a,(0e032h)		;7b77   ; Ya esta sonando?
	and a			;7b7a
	jr nz,L_7B89		;7b7b
	ld a,(0e10bh)		;7b7d   ; El jugador esta a lo suyo?
	cp 002h		;7b80
	jr nc,L_7B89		;7b82
	ld a,041h		;7b84   ; El zumbido
	call pide_pieza		;7b86
L_7B89:
	ld a,(0e1c1h)		;7b89   ; La velocidad angular
	ld b,a			;7b8c
	ld hl,(0e1bbh)		;7b8d   ; La posicion de ahora
	ld de,(0e1b5h)		;7b90   ; Y la velocidad
	call gira_un_paso		;7b94   ; Girarla
	ld (0e1bbh),hl		;7b97   ; Guardar la posicion...
	ld (0e1b5h),de		;7b9a   ; ...y la velocidad
	ld a,(0e1c0h)		;7b9e   ; La referencia...
	add a,h			;7ba1   ; ...sumada a la parte alta
	ld h,a			;7ba2
	ld (0e1b1h),hl		;7ba3
	ld a,(0e1c2h)		;7ba6
	ld b,a			;7ba9
	ld hl,(0e1beh)		;7baa
	ld de,(0e1b7h)		;7bad
	call gira_un_paso		;7bb1
	ld (0e1beh),hl		;7bb4
	ld (0e1b7h),de		;7bb7
	ld a,(0e1bdh)		;7bbb
	add a,h			;7bbe
	ld h,a			;7bbf
	ld (0e1b3h),hl		;7bc0
	ret			;7bc3

; ----------------------------------------------------------------------
; ---------------------------------------------------------------------
; Un giro hecho a base de sumas: HL y DE son las dos componentes y B
; dice cuantos pasos se dan. Cada paso suma a una lo que vale la otra
; partido por 128, que es como se aproxima un seno sin tablas.
; ----------------------------------------------------------------------
gira_un_paso:
	ld a,d			;7bc4   ; La otra componente
	ld c,h			;7bc5   ; Guardar la parte alta
	add a,a			;7bc6   ; Por dos, mirando el signo
	jr nc,L_7BCA		;7bc7
	dec h			;7bc9   ; Negativa: bajar la parte alta
L_7BCA:
	add a,l			;7bca   ; Sumarla a esta componente
	ld l,a			;7bcb
	ld a,000h		;7bcc
	adc a,h			;7bce
	cp 080h		;7bcf   ; Se desbordo?
	jr nz,L_7BD4		;7bd1
	ld a,c			;7bd3   ; Entonces se deja como estaba
L_7BD4:
	ld h,a			;7bd4
	ld c,d			;7bd5
	neg		;7bd6   ; Y ahora la otra, cambiada de signo
	add a,a			;7bd8
	jr nc,L_7BDC		;7bd9
	dec d			;7bdb
L_7BDC:
	add a,e			;7bdc   ; Sumar a la otra componente
	ld e,a			;7bdd
	ld a,000h		;7bde
	adc a,d			;7be0
	cp 080h		;7be1   ; Se desbordo?
	jr nz,L_7BE6		;7be3
	ld a,c			;7be5   ; Se deja como estaba
L_7BE6:
	ld d,a			;7be6
	djnz gira_un_paso		;7be7   ; Tantos pasos como diga B
	ret			;7be9
L_7BEA:
	ld a,0c4h		;7bea   ; Casilla 0xC4
	ld hl,0e1b9h		;7bec
	ld (hl),a			;7bef
	inc hl			;7bf0
	ld a,006h		;7bf1   ; Y color 6
	ld (hl),a			;7bf3
	ld hl,0e1c4h		;7bf4   ; La cuenta
	dec (hl)			;7bf7
	ret nz			;7bf8   ; Todavia dura
	ld a,0f0h		;7bf9   ; Se acabo: casilla 0xF0
	ld (0e1b9h),a		;7bfb
	jp L_7ABF		;7bfe   ; Y un estado mas
L_7C01:
	ld hl,0e1b2h		;7c01   ; La columna
	inc (hl)			;7c04   ; Una mas
	ld a,(hl)			;7c05
	cp 098h		;7c06   ; Hasta 0x98
	ret c			;7c08
	jp L_7ABF		;7c09   ; Ahi se acaba
L_7C0C:
	ld hl,0e1b4h		;7c0c   ; La fila
	ld de,0e156h		;7c0f   ; Donde esta el jugador
	ld a,(de)			;7c12
	sub 008h		;7c13   ; Ocho por arriba...
	ld b,a			;7c15
	ld a,(de)			;7c16
	add a,008h		;7c17   ; ...y ocho por abajo
	ld c,a			;7c19
	ld a,(hl)			;7c1a
	ld d,a			;7c1b
	add a,010h		;7c1c   ; Dieciseis de alto
	cp b			;7c1e
	ret c			;7c1f   ; Se sale por abajo
	ld a,d			;7c20
	cp c			;7c21   ; Y por arriba
	ret nc			;7c22
	xor a			;7c23   ; Le ha dado: apagarlo...
	ld (0e1b0h),a		;7c24
	ld (0e1c6h),a		;7c27   ; ...y soltar lo que llevara agarrado
	jp L_7C76		;7c2a   ; Y a repintar el marcador
L_7C2D:
	ld hl,0e1b2h		;7c2d   ; La coordenada
	ld de,0e1e4h		;7c30   ; Y donde se copia
	ld a,(hl)			;7c33   ; La fila
	ld (de),a			;7c34
	inc de			;7c35
	inc hl			;7c36
	inc hl			;7c37
	ld a,(hl)			;7c38   ; La columna
	ld (de),a			;7c39
	inc de			;7c3a
	ld a,005h		;7c3b
	call suma_a_a_hl		;7c3d   ; Cinco bytes mas alla...
	ld a,(hl)			;7c40   ; ...la casilla
	ld (de),a			;7c41
	inc de			;7c42
	inc hl			;7c43
	ld a,(hl)			;7c44   ; Y el color
	ld (de),a			;7c45
	ret			;7c46
mueve_lo_agarrado_del_escenario_3:
	call el_escenario_de_la_ronda		;7c47   ; En que escenario
	cp 003h		;7c4a
	ret nz			;7c4c   ; Solo el 3
	ld a,(0e1c6h)		;7c4d   ; Hay algo agarrado?
	and a			;7c50
	ret z			;7c51   ; No
	ld a,(0e003h)		;7c52   ; Uno de cada dos cuadros...
	and 002h		;7c55
	jr z,L_7C5B		;7c57
	pop hl			;7c59   ; ...se salta el retorno: eso frena al enemigo
	ret			;7c5a
L_7C5B:
	ld hl,0e134h		;7c5b   ; El lado al que mira
	ld a,(0e156h)		;7c5e   ; La columna del jugador
	ld b,a			;7c61
	ld a,(0e1b4h)		;7c62   ; Y la de lo agarrado
	cp b			;7c65
	ld a,001h		;7c66   ; A la derecha: 1
	jr c,L_7C6B		;7c68
	dec a			;7c6a   ; A la izquierda: 0
L_7C6B:
	ld (hl),a			;7c6b   ; Ahi va el lado
	ld c,a			;7c6c
	ld a,(0e003h)		;7c6d   ; El bit 2 del cuadro decide el fotograma
	bit 2,a		;7c70
	pop hl			;7c72
	jp L_811B		;7c73
L_7C76:
	ld de,07cf1h		;7c76   ; El rotulo de la fase, en color...
	ld hl,07ca7h		;7c79   ; ...y en patrones
	jr L_7C84		;7c7c
L_7C7E:
	ld de,07d06h		;7c7e   ; La version corta: color...
	ld hl,07ccdh		;7c81   ; ...y patrones
L_7C84:
	push hl			;7c84
	push de			;7c85
	ld hl,012d8h		;7c86   ; El color va a 0x12D8...
	call vuelca_el_guion_con_destino_en_hl		;7c89
	pop de			;7c8c
	ld hl,01698h		;7c8d   ; ...y a 0x1698
	call vuelca_el_guion_con_destino_en_hl		;7c90
	pop hl			;7c93
	ex de,hl			;7c94
	ld hl,032d8h		;7c95   ; Y el patron a 0x32D8
	call vuelca_el_guion_con_destino_en_hl		;7c98
	ld hl,032d8h		;7c9b   ; Que se espeja sobre 0x3698
	ld de,03698h		;7c9e
	ld bc,00028h		;7ca1   ; 0x28 patrones
	jp copia_dando_la_vuelta		;7ca4

; ----------------------------------------------------------------------
; DATOS guiones_del_marcador_de_fase: cuatro guiones; 0x7C76, 0x7C79, 0x7C7E y
;   0x7C81 cargan los cuatro; 4 guion(es), medidos con tools/formatos.py
;   0x7ca7..0x7d17  (112 bytes)
DATA_guiones_del_marcador_de_fase:
	defb 005h,000h,08fh,002h,009h,005h,00fh,01fh,00fh,03fh,016h,04eh,0f0h,03fh,01fh,00fh,007h,087h,004h,0ffh,090h,00fh,01fh,00fh,03fh,016h,04eh,0f0h,03fh,0c0h,0e0h,0f0h,0f0h,0f0h,01ch,03eh,080h,000h	; 7ca7  .........?.N.?..........?.N.?......>..
	defb 008h,000h,0a0h,007h,00bh,007h,01eh,00dh,01fh,07fh,0ffh,0e0h,0f0h,0f8h,078h,078h,0ffh,0ffh,0ffh,00fh,017h,00fh,03ch,01ah,032h,003h,007h,0c0h,0e0h,0f0h,0f0h,0f0h,01ch,03eh,080h,000h	; 7ccd  ..............xx......<.2........>..
	defb 00eh,0f0h,082h,0fah,0a0h,005h,009h,003h,0a0h,006h,0f0h,082h,0fah,0a0h,005h,090h,083h,0a0h,0a0h,09ah,000h	; 7cf1  .....................
	defb 008h,000h,005h,090h,003h,0a0h,005h,090h,003h,0a0h,00dh,090h,083h,0a0h,0a0h,09ah,000h	; 7d06  .................

; ======================================================================
; CODIGO 0x7d17..0x7da2  (139 bytes)
; ======================================================================


mueve_lo_agarrado_o_reparte:
	call el_escenario_de_la_ronda		;7d17   ; En que escenario
	cp 000h		;7d1a
	jr nz,L_7D25		;7d1c
	ld a,(0e1d7h)		;7d1e   ; En el 0, si hay algo agarrado...
	and a			;7d21
	jp nz,L_71F1		;7d22   ; ...se mueve eso
L_7D25:
	call suelta_una_de_las_tres_del_escenario_3		;7d25   ; Lo del escenario 3
	call cuenta_la_espera_entre_una_y_otra		;7d28   ; Lo del 7
	call mueve_lo_que_vuela		;7d2b   ; Y lo de los demas
	ld a,(0e137h)		;7d2e   ; Hay golpe en marcha?
	and a			;7d31
	jr z,L_7D46		;7d32
	call lanza_algo_si_el_escenario_lo_lleva		;7d34   ; Si: seguirlo por cada escenario
	call suelta_una_de_las_tres_del_escenario_0		;7d37
	call suelta_las_tres_a_la_vez_del_escenario_7		;7d3a
	call suelta_una_de_las_tres_del_escenario_6		;7d3d
L_7D40:
	ld hl,082d8h		;7d40   ; Y sacar el fotograma de la tabla
	jp L_6E84		;7d43

; ----------------------------------------------------------------------
; ======================================================================
; EL ENEMIGO SE MANEJA COMO EL JUGADOR
; ======================================================================
; Los cinco bits del mando entran directos en una tabla de 32, igual
; que en 0x6990. La diferencia es de donde vienen: con dos jugadores
; los pone el SEGUNDO MANDO en (0xE052), y con uno se los inventa la
; maquina en 0x7E7E.
; ----------------------------------------------------------------------
L_7D46:
	call el_escenario_de_la_ronda		;7d46   ; En que escenario
	cp 000h		;7d49
	call z,avanza_el_paso_del_agarre		;7d4b   ; En el 0 hay ademas que agarrar
	ld a,(0e118h)		;7d4e   ; Por que fotograma va el jugador
	cp 010h		;7d51   ; De 0x10 en adelante no se hace nada
	jp nc,L_7DE2		;7d53
	ld a,(0e002h)		;7d56   ; El modo de juego
	and 003h		;7d59
	dec a			;7d5b
	jp z,lo_maneja_la_maquina		;7d5c   ; Modo 1: lo maneja la maquina
	call mide_la_distancia		;7d5f   ; A que distancia esta
	ld a,b			;7d62
	cp 004h		;7d63   ; De lejos vale cualquier orden
	ld de,0e052h		;7d65   ; El mando del segundo
	jr nc,L_7D80		;7d68
	ld a,(de)			;7d6a   ; De cerca, las ordenes 0x11, 0x12...
	and 01fh		;7d6b
	cp 011h		;7d6d
	jr z,L_7D7D		;7d6f
	cp 012h		;7d71
	jr z,L_7D7D		;7d73
	cp 014h		;7d75   ; ...0x14 y 0x18...
	jr z,L_7D7D		;7d77
	cp 018h		;7d79
	jr nz,L_7D80		;7d7b
L_7D7D:
	ld a,010h		;7d7d   ; ...se cambian por el 0x10 pelado
	ld (de),a			;7d7f
L_7D80:
	ld hl,0e13dh		;7d80   ; Lo que se pedia
	ld a,(hl)			;7d83
	inc hl			;7d84
	ld (hl),a			;7d85   ; Se guarda como "lo de antes"
	dec hl			;7d86
	ld a,(de)			;7d87   ; Y lo de ahora, con sus cinco bits
	and 01fh		;7d88
	ld (hl),a			;7d8a
	and a			;7d8b   ; Nada
	jr z,L_7D9E		;7d8c
	cp 002h		;7d8e   ; Las cuatro direcciones solas...
	jr z,L_7D9E		;7d90
	cp 004h		;7d92
	jr z,L_7D9E		;7d94
	cp 008h		;7d96
	jr z,L_7D9E		;7d98   ; ...no interrumpen lo que haya
	inc hl			;7d9a
	xor (hl)			;7d9b   ; Lo mismo que antes?
	jr z,L_7D9F		;7d9c
L_7D9E:
	ld a,(de)			;7d9e   ; Entonces vale la orden entera
L_7D9F:
	call reparte_por_tabla		;7d9f   ; Y a la que sea

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_7da2: 32 entradas, tras el `call
;   reparte_por_tabla` de 0x7D9F; detras sigue la primera, 0x7DE2
;   0x7da2..0x7de2  (64 bytes)
DATA_tabla_de_subescenas_7da2:
	defw 07de2h,07de2h,07df6h,07de2h,07e2bh,07de7h,07dfdh,07de2h	; 7da2
	defw 07e06h,07debh,07dfah,07de2h,07de2h,07de2h,07de2h,07de2h	; 7db2
	defw 07e54h,07df3h,07e58h,07de2h,07e5fh,07de7h,07dfdh,07de2h	; 7dc2
	defw 07e5ch,07debh,07dfah,07de2h,07de2h,07de2h,07de2h,07de2h	; 7dd2

; ======================================================================
; CODIGO 0x7de2..0x7e90  (174 bytes)
; ======================================================================


L_7DE2:
	ld b,000h		;7de2   ; Fotograma 0: quieto
L_7DE4:
	jp L_6EC4		;7de4
L_7DE7:
	ld a,001h		;7de7   ; Mirando a la derecha
	jr L_7DEC		;7de9
L_7DEB:
	xor a			;7deb   ; Mirando a la izquierda
L_7DEC:
	ld (0e134h),a		;7dec   ; El lado
	ld a,003h		;7def   ; Golpe 3
	jr arranca_el_golpe_de_siete_cuadros		;7df1
L_7DF3:
	xor a			;7df3   ; Golpe 0
	jr arranca_el_golpe_de_siete_cuadros		;7df4
L_7DF6:
	ld b,012h		;7df6   ; Fotograma 0x12
	jr L_7DE4		;7df8
L_7DFA:
	xor a			;7dfa   ; A la izquierda
	jr L_7DFF		;7dfb
L_7DFD:
	ld a,001h		;7dfd   ; A la derecha
L_7DFF:
	ld (0e134h),a		;7dff   ; El lado
	ld a,005h		;7e02   ; Y golpe 5
	jr arranca_el_golpe_de_siete_cuadros		;7e04
L_7E06:
	ld a,(0e003h)		;7e06   ; Uno de cada cuatro cuadros
	and 006h		;7e09
	jr nz,L_7E51		;7e0b
	ld hl,0e133h		;7e0d   ; La fila
	ld a,(hl)			;7e10
	cp 01ch		;7e11   ; De 0x1C no pasa...
	jr c,L_7E1A		;7e13
	ld a,005h		;7e15   ; ...y ahi se queda en 5
	ld (hl),a			;7e17
	jr L_7E28		;7e18
L_7E1A:
	push hl			;7e1a
	call mide_la_distancia		;7e1b   ; A que distancia esta
	pop hl			;7e1e
	and a			;7e1f
	jr nz,L_7E27		;7e20
	ld a,b			;7e22
	dec a			;7e23   ; Pegado: no se acerca mas
	jp z,L_7E28		;7e24
L_7E27:
	inc (hl)			;7e27   ; Una fila mas
L_7E28:
	xor a			;7e28
	jr L_7E4E		;7e29
L_7E2B:
	ld a,(0e003h)		;7e2b   ; Uno de cada cuatro
	and 006h		;7e2e
	jr nz,L_7E51		;7e30
	ld hl,0e133h		;7e32   ; La fila
	ld a,(hl)			;7e35
	cp 005h		;7e36   ; Por debajo de 5...
	jr nc,L_7E3F		;7e38
	ld a,01bh		;7e3a   ; ...da la vuelta a 0x1B
	ld (hl),a			;7e3c
	jr L_7E4C		;7e3d
L_7E3F:
	push hl			;7e3f
	call mide_la_distancia		;7e40   ; A que distancia
	pop hl			;7e43
	and a			;7e44
	jr z,L_7E4B		;7e45
	ld a,b			;7e47
	dec a			;7e48
	jr z,L_7E4C		;7e49
L_7E4B:
	dec (hl)			;7e4b   ; Una fila menos
L_7E4C:
	ld a,001h		;7e4c   ; Y mirando al otro lado
L_7E4E:
	ld (0e134h),a		;7e4e   ; El lado
L_7E51:
	jp L_6EB9		;7e51   ; Poner el fotograma
L_7E54:
	ld a,004h		;7e54   ; Golpe 4
	jr arranca_el_golpe_de_siete_cuadros		;7e56
L_7E58:
	ld a,002h		;7e58   ; Golpe 2
	jr arranca_el_golpe_de_siete_cuadros		;7e5a
L_7E5C:
	xor a			;7e5c   ; A la izquierda
	jr L_7E61		;7e5d
L_7E5F:
	ld a,001h		;7e5f   ; A la derecha
L_7E61:
	ld (0e134h),a		;7e61   ; El lado
	call el_escenario_de_la_ronda		;7e64   ; En que escenario
	cp 001h		;7e67   ; El 1 usa el golpe 2...
	ld a,001h		;7e69
	jr nz,arranca_el_golpe_de_siete_cuadros		;7e6b
	inc a			;7e6d   ; ...y los demas el 1
arranca_el_golpe_de_siete_cuadros:
	call pon_el_tipo_de_golpe		;7e6e   ; Arrancar el golpe
	ld a,007h		;7e71   ; Siete cuadros
	jr L_7E7A		;7e73
pon_el_tipo_de_golpe:
	ld (0e135h),a		;7e75   ; El tipo de golpe
	ld a,010h		;7e78   ; Y dieciseis cuadros
L_7E7A:
	ld (0e137h),a		;7e7a
	ret			;7e7d

; ----------------------------------------------------------------------
; ======================================================================
; CUANDO LO MANEJA LA MAQUINA
; ======================================================================
; Aqui no hay mando: el escenario elige una de las ocho rutinas de
; apuntadas que se van gastando.
; ----------------------------------------------------------------------
lo_maneja_la_maquina:
	call corrige_el_lado_segun_la_fila		;7e7e   ; Corregir la fila si se salio
	call saca_lo_siguiente_de_la_cola_del_lado		;7e81   ; Gastar la cola de un lado
	call saca_lo_siguiente_de_la_otra_cola		;7e84   ; Y la del otro
	call mueve_lo_agarrado_del_escenario_3		;7e87   ; Lo del escenario 3
	call el_escenario_de_la_ronda		;7e8a   ; El escenario de la ronda
	call reparte_por_tabla		;7e8d   ; Y a su rutina

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_7e90: 8 entradas, tras el `call reparte_por_tabla`
;   de 0x7E8D; detras sigue codigo que se alcanza por otra via
;   0x7e90..0x7ea0  (16 bytes)
DATA_tabla_de_subescenas_7e90:
	defw 07fa3h,082fdh,086cbh,088feh,08b32h,08d2bh,084ddh,08ee7h	; 7e90

; ======================================================================
; CODIGO 0x7ea0..0x7fdb  (315 bytes)
; ======================================================================


el_escenario_de_la_ronda:
	push hl			;7ea0   ; La tira de escenarios
	ld hl,0e2c0h		;7ea1
	ld a,(0e066h)		;7ea4   ; Indexada por la ronda
	call suma_a_a_hl		;7ea7
	ld a,(hl)			;7eaa   ; Ese es el escenario
	pop hl			;7eab
	ret			;7eac
saca_dos_bits_del_azar:
	ld b,002h		;7ead   ; Dos veces
L_7EAF:
	push bc			;7eaf
	ld hl,0e169h		;7eb0   ; El ultimo byte del registro
	push hl			;7eb3
	ld a,(hl)			;7eb4
	srl a		;7eb5   ; Sale un bit por arriba...
	dec hl			;7eb7
	ld b,009h		;7eb8
L_7EBA:
	rr (hl)		;7eba   ; ...y va bajando por los diez bytes
	dec hl			;7ebc
	djnz L_7EBA		;7ebd
	pop hl			;7ebf
	rr (hl)		;7ec0   ; ...hasta volver al primero
	pop bc			;7ec2
	djnz L_7EAF		;7ec3
	ld a,(0e160h)		;7ec5   ; Y los dos bits bajos son el resultado
	and 003h		;7ec8
	ret			;7eca
saca_lo_siguiente_de_la_otra_cola:
	ld hl,0e184h		;7ecb   ; La cola de este lado
	ld a,(hl)			;7ece
	and a			;7ecf
	ret z			;7ed0   ; Vacia
	ld a,(0e003h)		;7ed1   ; Uno de cada dos cuadros...
	and 002h		;7ed4
	jr z,L_7EDA		;7ed6
	pop de			;7ed8   ; ...se salta el retorno
	ret			;7ed9
L_7EDA:
	dec (hl)			;7eda   ; Una orden menos
	ld a,001h		;7edb   ; Un cuadro de espera
	ld (0e154h),a		;7edd
	ld (0e159h),a		;7ee0
	ld a,(0e134h)		;7ee3   ; El lado, cambiado
	xor 001h		;7ee6
	ld c,a			;7ee8
	ld a,(0e003h)		;7ee9   ; Y el bit 2 del cuadro elige el fotograma
	bit 2,a		;7eec
	pop hl			;7eee
	jp L_811B		;7eef
corrige_el_lado_segun_la_fila:
	ld hl,0e133h		;7ef2   ; La fila del enemigo
	call el_escenario_de_la_ronda		;7ef5   ; En que escenario
	cp 007h		;7ef8   ; El 7 tiene sus limites
	jr z,L_7F1A		;7efa
	ld a,(0e134h)		;7efc   ; De que lado viene
	ld b,a			;7eff
	ld a,(hl)			;7f00
	cp 003h		;7f01   ; Por encima de la fila 3...
	jr c,L_7F09		;7f03
	dec b			;7f05
	cp 01dh		;7f06   ; ...y por debajo de la 0x1D, no hay que corregir
	ret c			;7f08
L_7F09:
	ld hl,0e185h		;7f09   ; La cola de un lado...
	ld de,0e184h		;7f0c   ; ...y la del otro
	ld a,b			;7f0f
	and a			;7f10   ; Se elige por el lado
	jr z,L_7F14		;7f11
	ex de,hl			;7f13
L_7F14:
	ld a,010h		;7f14   ; 0x10 ordenes en una...
	ld (hl),a			;7f16
	xor a			;7f17   ; ...y ninguna en la otra
	ld (de),a			;7f18
	ret			;7f19
L_7F1A:
	ld a,(hl)			;7f1a   ; La fila
	ld b,a			;7f1b
	cp 002h		;7f1c   ; En la 2...
	jr nz,L_7F22		;7f1e
	ld b,01ch		;7f20   ; ...se pasa a la 0x1C
L_7F22:
	cp 01dh		;7f22   ; Y de la 0x1D...
	jr c,L_7F28		;7f24
	ld b,003h		;7f26   ; ...a la 3: el escenario 7 da la vuelta
L_7F28:
	ld (hl),b			;7f28
	ret			;7f29
saca_lo_siguiente_de_la_cola_del_lado:
	ld hl,0e185h		;7f2a   ; La cola de este lado
	ld a,(hl)			;7f2d
	and a			;7f2e
	jr z,L_7F86		;7f2f   ; Vacia
	call el_escenario_de_la_ronda		;7f31   ; En que escenario
	dec (hl)			;7f34   ; Una menos
	cp 007h		;7f35   ; El 7 va aparte
	jr z,L_7F79		;7f37
	inc (hl)			;7f39   ; Devolverla
	ld a,(0e003h)		;7f3a   ; Uno de cada dos cuadros
	and 002h		;7f3d
	jr z,L_7F43		;7f3f
L_7F41:
	pop hl			;7f41
	ret			;7f42
L_7F43:
	dec (hl)			;7f43   ; Una orden menos
	ld a,001h		;7f44   ; Un cuadro de espera
	ld (0e154h),a		;7f46
	ld (0e159h),a		;7f49
	call mide_la_distancia		;7f4c   ; A que distancia esta
	ld hl,0e15ch		;7f4f
	ld a,b			;7f52   ; Pegado?
	and a			;7f53
	jr nz,L_7F5B		;7f54
	ld a,001h		;7f56   ; Marcarlo
	ld (hl),a			;7f58
	jr L_7F79		;7f59
L_7F5B:
	ld a,(hl)			;7f5b   ; Ya estaba pegado?
	and a			;7f5c
	jr z,L_7F65		;7f5d
	xor a			;7f5f   ; Entonces vaciar la cola
	ld (0e185h),a		;7f60
	jr L_7F41		;7f63
L_7F65:
	call pon_la_subescena		;7f65   ; Poner la subescena
	and a			;7f68
	jr z,L_7F79		;7f69
	call el_escenario_de_la_ronda		;7f6b
	cp 003h		;7f6e
	ld a,003h		;7f70
	jr nz,L_7F76		;7f72
	ld a,005h		;7f74
L_7F76:
	jp L_80BB		;7f76
L_7F79:
	ld a,(0e134h)		;7f79   ; Poner la subescena
	ld c,a			;7f7c
	ld a,(0e003h)		;7f7d
	bit 2,a		;7f80
	pop hl			;7f82
	jp L_811B		;7f83
L_7F86:
	xor a			;7f86
	ld (0e15ch),a		;7f87
	ret			;7f8a
L_7F8B:
	ld hl,0e132h		;7f8b
	ld de,0e155h		;7f8e
	ld b,002h		;7f91
L_7F93:
	ld a,(hl)			;7f93   ; La coordenada...
	add a,a			;7f94
	add a,a			;7f95
	add a,a			;7f96   ; ...por ocho
	ld (de),a			;7f97
	inc hl			;7f98
	inc de			;7f99
	djnz L_7F93		;7f9a   ; Todas
	dec de			;7f9c
	dec de			;7f9d
	ld a,(de)			;7f9e
	sub 009h		;7f9f
	ld (de),a			;7fa1
	ret			;7fa2
L_7FA3:
	ld b,018h		;7fa3
	ld c,003h		;7fa5
L_7FA7:
	push bc			;7fa7   ; Medir la distancia
	call mide_la_distancia		;7fa8
	call copia_el_lado		;7fab   ; Y copiar el lado
	pop bc			;7fae
	ld hl,0e15ah		;7faf   ; La cuenta del agarre
	ld a,(hl)			;7fb2
	and a			;7fb3
	jr z,decide_que_hace_el_enemigo		;7fb4   ; A cero: lo de siempre
	dec (hl)			;7fb6   ; Una menos
	dec a			;7fb7
	ld a,b			;7fb8
	ld (0e154h),a		;7fb9
	jr nz,L_7FC3		;7fbc
	ld b,005h		;7fbe
	jp apunta_la_orden		;7fc0
L_7FC3:
	ld a,c			;7fc3
	jp L_80BB		;7fc4

; ----------------------------------------------------------------------
; ======================================================================
; QUE HACE EL ENEMIGO ESTE CUADRO
; ======================================================================
; Dos niveles: el escenario elige la tabla y la distancia elige la
; entrada. Ninguna de las ocho tablas va detras de un `call 0x4066`,
; asi que hay que declararlas a mano en el .entries.
; ----------------------------------------------------------------------
decide_que_hace_el_enemigo:
	call copia_el_lado		;7fc7   ; Copiar el lado en el que esta el jugador
	call mide_la_distancia		;7fca   ; Medir la distancia; deja el tramo en B
	call el_escenario_de_la_ronda		;7fcd   ; El escenario de la ronda...
	ld hl,07fdbh		;7fd0   ; ...elige una de las ocho tablas
	call lee_la_entrada_de_la_tabla		;7fd3
	ex de,hl			;7fd6
	ld a,b			;7fd7   ; Y el tramo de distancia, la entrada
	jp reparte_por_tabla_en_hl		;7fd8   ; A la reaccion que toque

; ----------------------------------------------------------------------
; DATOS tabla_de_las_reacciones: ocho punteros a las ocho tablas de
;   reacciones; los carga 0x7FD0 con el escenario, y luego 0x7FD8 entra en la
;   que salga con el TRAMO DE DISTANCIA en B, el que acaba de medir 0x6E1D
;   0x7fdb..0x7feb  (16 bytes)
DATA_tabla_de_las_reacciones:
	defw 07febh,08304h,086f6h,08937h,08b39h,08d32h,084e4h,08eeah	; 7fdb

; ----------------------------------------------------------------------
; DATOS reacciones_del_escenario_0: 7 entradas, desde 0x7FDB[0]; detras sigue
;   la primera que no es 0x8000, 0x7FF9
;   0x7feb..0x7ff9  (14 bytes)
DATA_reacciones_del_escenario_0:
	defw 08000h,0803bh,0803bh,08033h,08033h,080eeh,08108h	; 7feb

; ======================================================================
; CODIGO 0x7ff9..0x8041  (72 bytes)
; ======================================================================


copia_el_lado:
	ld a,(0e11fh)		;7ff9   ; El lado que dejo 0x6E5A
	ld (0e134h),a		;7ffc   ; Es lo que mira medio cartucho
	ret			;7fff
empuja_si_esta_al_borde:
	ld a,(0e112h)		;8000   ; La x del enemigo
	cp 07dh		;8003   ; Todavia no ha llegado al borde
	ret c			;8005
	ld b,005h		;8006   ; Al borde: la orden 5
apunta_la_orden:
	ld a,(0e156h)		;8008   ; Por donde anda el jugador
	cp 080h		;800b   ; De la mitad para aca?
	ld a,(0e134h)		;800d   ; El lado
	jr c,L_8014		;8010
	xor 001h		;8012   ; Si esta al otro lado, al reves
L_8014:
	and a			;8014
	ld hl,0e184h		;8015   ; La cola de ordenes de un lado...
	jr nz,L_801E		;8018
	ld hl,0e185h		;801a   ; ...o la del otro
	inc b			;801d
L_801E:
	ld (hl),b			;801e   ; Y ahi se deja la orden
	ret			;801f
pon_la_subescena:
	ld a,(0e115h)		;8020   ; En que va el enemigo
	and a			;8023
	ret z			;8024   ; Quieto: subescena 0
	cp 005h		;8025   ; La 5 se queda como esta
	ret z			;8027
	ld a,(0e117h)		;8028   ; Y si el cuadro va muy avanzado...
	cp 005h		;802b
	ld a,(0e115h)		;802d
	ret nc			;8030   ; ...tambien vale
	xor a			;8031   ; Si no, la 0
	ret			;8032
espera_y_reparte:
	ld a,(0e003h)		;8033   ; Uno de cada 32 cuadros...
	and 03eh		;8036
	jp z,L_810F		;8038   ; ...se salta el reparto
reparte_la_subescena:
	call pon_la_subescena		;803b   ; Que subescena toca
	call reparte_por_tabla		;803e   ; Y a ella; la tabla va justo detras

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_8041: 6 entradas, tras el `call reparte_por_tabla`
;   de 0x803E; detras sigue codigo que se alcanza por otra via
;   0x8041..0x804d  (12 bytes)
DATA_tabla_de_subescenas_8041:
	defw 0805dh,0809dh,080c4h,080deh,0805dh,080d6h	; 8041

; ======================================================================
; CODIGO 0x804d..0x8142  (245 bytes)
; ======================================================================


cuenta_atras:
	ld hl,0e154h		;804d   ; La espera del enemigo
	dec (hl)			;8050   ; Un cuadro menos
	ld a,(hl)			;8051
	and a			;8052
	ret			;8053
dos_bits_del_cuadro:
	ld a,(0e003h)		;8054   ; El contador de cuadros...
	rra			;8057
	rra			;8058
	rra			;8059
	and 003h		;805a   ; ...partido por ocho y quedandose con dos bits
	ret			;805c

; ----------------------------------------------------------------------
; ======================================================================
; LAS REACCIONES DEL ESCENARIO 0
; ======================================================================
; Cada una de las seis entradas de 0x8041 es lo que hace el enemigo a
; una distancia. Lo que casi todas acaban haciendo es apuntar una orden
; en la cola de 0xE184 o arrancar un golpe.
; ----------------------------------------------------------------------
reacciona_de_lejos:
	call cuenta_atras		;805d   ; La espera
	ret nz			;8060   ; Todavia no le toca
	call dos_bits_del_cuadro		;8061   ; Dos bits del contador de cuadros
	jr z,L_8085		;8064   ; A cero: esperar
	dec a			;8066   ; A uno: acercarse
	jr z,L_806E		;8067
	dec a			;8069   ; Y si no, la orden 3
	jr z,L_8081		;806a
	jr L_8081		;806c
L_806E:
	ld a,003h		;806e   ; Tres pasos
L_8070:
	ld b,a			;8070
	ld a,(0e06ah)		;8071   ; En que vuelta
	and a			;8074
	jr z,L_807C		;8075
	inc b			;8077   ; Uno mas por vuelta...
	dec a			;8078
	jr z,L_807C		;8079
	inc b			;807b   ; ...hasta dos mas
L_807C:
	ld a,b			;807c
	ld (0e15ah),a		;807d   ; Ahi va lo que anda
	ret			;8080
L_8081:
	ld a,003h		;8081   ; Orden 3
	jr L_80AB		;8083
L_8085:
	ld a,020h		;8085   ; 0x20 cuadros de espera
L_8087:
	ld (0e154h),a		;8087   ; Ahi va la espera
	ld hl,0e135h		;808a   ; El tipo de golpe
	ld a,(hl)			;808d
	inc a			;808e   ; Uno mas
	cp 003h		;808f   ; Los golpes 0, 1 y 2...
	jr c,L_8097		;8091
	cp 006h		;8093   ; ...y del 3 al 5
	jr c,L_8099		;8095
L_8097:
	ld a,003h		;8097   ; Fuera de rango, se queda en 3
L_8099:
	ld (hl),a			;8099
arranca_el_golpe:
	jp pon_el_tipo_de_golpe		;809a   ; Arrancarlo
L_809D:
	call saca_dos_bits_del_azar		;809d   ; Dos bits del registro
	dec a			;80a0   ; A uno: la orden 6
	jr z,L_80B3		;80a1
	dec a			;80a3   ; A dos: acercarse
	jr z,L_80B7		;80a4
	dec a			;80a6   ; A tres: la orden 4
	jr z,L_80B9		;80a7
L_80A9:
	ld a,006h		;80a9   ; Y si no, la 6
L_80AB:
	ld (0e184h),a		;80ab   ; Ahi queda apuntada
	ret			;80ae
L_80AF:
	ld a,004h		;80af   ; Orden 4
	jr L_80AB		;80b1
L_80B3:
	ld a,006h		;80b3   ; Orden 6
	jr L_80BB		;80b5
L_80B7:
	jr reacciona_de_lejos		;80b7   ; Y a la de lejos
L_80B9:
	ld a,004h		;80b9   ; Orden 4
L_80BB:
	call arranca_el_golpe		;80bb   ; Arrancar el golpe
	ld a,006h		;80be   ; Y ponerlo en el sexto cuadro
	ld (0e137h),a		;80c0
	ret			;80c3
L_80C4:
	call saca_dos_bits_del_azar		;80c4   ; Dos bits del registro
	dec a			;80c7
	jr z,L_80D0		;80c8
	dec a			;80ca
	jr z,L_80D2		;80cb
	dec a			;80cd
	jr z,L_80B3		;80ce
L_80D0:
	jr reacciona_de_lejos		;80d0
L_80D2:
	ld a,005h		;80d2   ; Orden 5
	jr L_80BB		;80d4
L_80D6:
	call saca_dos_bits_del_azar		;80d6   ; Dos bits del registro
	dec a			;80d9
	jr z,L_80EA		;80da
	jr L_8081		;80dc
L_80DE:
	call saca_dos_bits_del_azar		;80de   ; Dos bits del registro
	dec a			;80e1
	jr z,L_80A9		;80e2   ; A uno: la orden 6
	dec a			;80e4
	jr z,L_80B9		;80e5   ; A dos: la 4
	dec a			;80e7
	jr z,L_80D2		;80e8   ; A tres: la 5
L_80EA:
	ld a,003h		;80ea   ; Orden 3
	jr L_80BB		;80ec
L_80EE:
	ld hl,0e159h		;80ee   ; La espera
	dec (hl)			;80f1
	ret nz			;80f2   ; Todavia dura
	ld a,010h		;80f3   ; 0x10 cuadros
	ld (hl),a			;80f5
	ld hl,0e135h		;80f6   ; El tipo de golpe
	ld a,(0e003h)		;80f9   ; Dos bits del contador de cuadros
	rra			;80fc
	and 003h		;80fd
	cp 003h		;80ff   ; El 3 se cambia por el 0
	jr nz,L_8104		;8101
	xor a			;8103
L_8104:
	ld (hl),a			;8104   ; Ahi va
	jp pon_el_tipo_de_golpe		;8105   ; Y a arrancarlo
L_8108:
	ld a,(0e003h)		;8108   ; El contador de cuadros
	bit 6,a		;810b   ; Su bit 6 decide
	jr nz,L_80EE		;810d
L_810F:
	call copia_el_lado		;810f   ; Copiar el lado
	ld hl,0e003h		;8112
	ld a,(hl)			;8115
	and 00eh		;8116   ; Uno de cada ocho cuadros
	ret nz			;8118
	bit 4,(hl)		;8119   ; Y su bit 4 elige el fotograma
L_811B:
	ld b,000h		;811b   ; Fotograma 0...
	jr nz,L_8121		;811d
	ld b,002h		;811f   ; ...o 2
L_8121:
	ld a,(0e134h)		;8121   ; El lado...
	and a			;8124
	ld a,b			;8125
	jr nz,L_8129		;8126
	inc a			;8128   ; ...suma uno
L_8129:
	ld hl,0e133h		;8129   ; La fila
	ld (0e138h),a		;812c   ; Ahi va el fotograma
	bit 0,c		;812f   ; Hacia arriba o hacia abajo?
	jr nz,L_813B		;8131
	ld a,(hl)			;8133
	cp 01dh		;8134   ; Sin pasar de la fila 0x1D...
	jr nc,L_8139		;8136
	inc a			;8138   ; ...una mas
L_8139:
	ld (hl),a			;8139
	ret			;813a
L_813B:
	ld a,(hl)			;813b
	and a			;813c   ; Y por el otro lado, sin bajar de cero
	jr z,L_8140		;813d
	dec a			;813f
L_8140:
	ld (hl),a			;8140
	ret			;8141

; ----------------------------------------------------------------------
; DATOS fotogramas_del_enemigo_0: el enemigo del escenario 0, desde 0x6922[0].
;   Delante, 22 punteros que cierran la tabla justo en 0x816E; detras, 22
;   tramos (11 dibujos y 11 remisiones) que teselan el bloque sin un hueco ni
;   un solape; medidos con formatos.entrada_del_enemigo
;   0x8142..0x82d8  (406 bytes)
DATA_fotogramas_del_enemigo_0:
	defb 06eh,081h,08ch,081h,08fh,081h,0aah,081h,0adh,081h,0ceh,081h,0d1h,081h,0f3h,081h,0f6h,081h,014h,082h,017h,082h,031h,082h,034h,082h,04fh,082h,052h,082h,076h,082h,079h,082h,09dh,082h,0a0h,082h,0bdh,082h,0c0h,082h,0d5h,082h	; 8142  n.....................1.4.O.R.v.y...........
	defb 0fdh,000h,008h,0f9h,018h,00fh,020h,0f2h,008h,01eh,080h,080h,005h,006h,0e3h,051h,052h,0e2h,0f4h,010h,000h,0f6h,014h,000h,0f4h,01ah,0e2h,0f4h,01eh,000h	; 816e  ...... ........QR.............
	defb 0fdh,06fh,081h	; 818c
	defb 0fch,000h,008h,0f1h,020h,00fh,080h,080h,080h,005h,006h,0e3h,051h,052h,0e2h,0f4h,010h,000h,0f6h,014h,000h,0f4h,022h,0e3h,0f3h,026h,000h	; 818f  .... .......QR........"..&.
	defb 0feh,090h,081h	; 81aa
	defb 0feh,000h,008h,000h,018h,00ch,020h,0f2h,008h,01eh,080h,080h,005h,006h,0e3h,051h,052h,0e2h,0f3h,010h,088h,000h,014h,0f4h,029h,08ch,0f4h,02dh,09ah,000h,0f4h,01eh,0e2h	; 81ad  ...... ........QR.......)..-.....
	defb 0fch,0aeh,081h	; 81ce
	defb 0fdh,001h,00ah,0f9h,016h,00fh,020h,0f2h,008h,01eh,080h,00dh,0eah,004h,006h,0cah,0c9h,031h,032h,013h,000h,014h,015h,033h,034h,018h,019h,000h,0f4h,01ah,0e2h,0f4h,01eh,000h	; 81d1  ...... ..........12....34.........
	defb 0fdh,0d2h,081h	; 81f3
	defb 0fdh,002h,014h,0f8h,00ch,010h,020h,0f2h,008h,020h,080h,015h,0eah,003h,006h,0cah,0c9h,031h,032h,013h,000h,014h,015h,033h,034h,018h,019h,000h,0f5h,035h	; 81f6  ...... .. .......12....34....5
	defb 0fdh,0f7h,081h	; 8214
	defb 0fdh,001h,01ah,0f4h,00eh,014h,080h,080h,01dh,0eah,004h,006h,0e3h,03ah,03bh,000h,014h,0f5h,03ch,0cah,0f5h,042h,000h,0f4h,047h,000h	; 8217  .............:;...<..B..G.
	defb 0fdh,018h,082h	; 8231
	defb 0fbh,000h,008h,0f0h,018h,010h,020h,0f8h,008h,00eh,080h,00eh,0deh,005h,006h,0e4h,0f8h,051h,000h,0f5h,059h,000h,0f5h,05eh,0e2h,0f4h,063h	; 8234  ...... ..........Q..Y..^..c
	defb 0ffh,035h,082h	; 824f
	defb 0fah,001h,018h,0f0h,010h,014h,080h,080h,012h,0dah,004h,008h,0e3h,067h,0b2h,0e3h,0f3h,068h,0b7h,0b6h,0b5h,0b4h,08ch,0e2h,0beh,0bdh,0bch,0bbh,0bah,052h,0e3h,0c2h,0c1h,0c0h,0bfh,000h	; 8252  .............g...h...........R......
	defb 0feh,053h,082h	; 8276
	defb 0fbh,000h,008h,0f0h,020h,010h,080h,080h,022h,0deh,005h,007h,0e4h,051h,052h,0e3h,0f3h,010h,088h,0e2h,014h,0f4h,029h,08ch,000h,06bh,0f3h,02eh,09ah,000h,06ch,06dh,01fh,020h,021h,0e2h	; 8279  .... ..."....QR.......)..k....lm. !.
	defb 0feh,07ah,082h	; 829d
	defb 0fdh,002h,014h,0f8h,00ch,010h,020h,0f2h,008h,020h,080h,080h,003h,006h,000h,0cah,031h,032h,013h,000h,014h,015h,033h,034h,018h,019h,000h,0f5h,035h	; 82a0  ...... .. ......12....34....5
	defb 0fdh,0a1h,082h	; 82bd
	defb 0fdh,002h,080h,080h,080h,080h,003h,005h,000h,04bh,000h,0c3h,0e2h,04ch,04dh,0c4h,000h,0f3h,04eh,0c7h,0c6h	; 82c0  .........K...LM...N..
	defb 0feh,0c1h,082h	; 82d5

; ----------------------------------------------------------------------
; DATOS fotogramas_del_golpe: siete punteros -que cierran la tabla en 0x82E6-
;   y siete tiras cortas. 0x6E84 entra con (0xE135) y le suma 0 a 3 segun
;   donde este (0xE137) contra los tres umbrales de 0x6EB2; lo que saca es el
;   fotograma, que deja en (0xE138)
;   0x82d8..0x82fd  (37 bytes)
DATA_fotogramas_del_golpe:
	defb 0e6h,082h,0e9h,082h,0ech,082h,0efh,082h,0f2h,082h,0f5h,082h,0f9h,082h	; 82d8  ..............
	defb 000h,004h,006h	; 82e6
	defb 000h,004h,008h	; 82e9
	defb 000h,004h,00ah	; 82ec
	defb 000h,002h,00ch	; 82ef
	defb 000h,002h,00eh	; 82f2
	defb 000h,002h,010h,000h	; 82f5
	defb 012h,012h,012h,000h	; 82f9

; ======================================================================
; CODIGO 0x82fd..0x8304  (7 bytes)
; ======================================================================


L_82FD:
	ld b,030h		;82fd
	ld c,003h		;82ff
	jp L_7FA7		;8301

; ----------------------------------------------------------------------
; DATOS reacciones_del_escenario_1: 7 entradas, desde 0x7FDB[1]; detras sigue
;   0x8312
;   0x8304..0x8312  (14 bytes)
DATA_reacciones_del_escenario_1:
	defw 08000h,0831ah,0831ah,08312h,08312h,0837dh,08393h	; 8304

; ======================================================================
; CODIGO 0x8312..0x8320  (14 bytes)
; ======================================================================


L_8312:
	ld a,(0e003h)		;8312   ; El contador de cuadros
	and 03eh		;8315   ; Uno de cada 32...
	jp z,L_810F		;8317   ; ...se salta el reparto
L_831A:
	call pon_la_subescena		;831a   ; Poner la subescena
	call reparte_por_tabla		;831d   ; Y a ella; la tabla va detras

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_8320: 6 entradas, tras el `call reparte_por_tabla`
;   de 0x831D; detras sigue la primera, 0x832C
;   0x8320..0x832c  (12 bytes)
DATA_tabla_de_subescenas_8320:
	defw 0832ch,08344h,08355h,08369h,0832ch,08366h	; 8320

; ======================================================================
; CODIGO 0x832c..0x839d  (113 bytes)
; ======================================================================


L_832C:
	call cuenta_atras		;832c   ; La espera
	ret nz			;832f   ; Todavia no
	call dos_bits_del_cuadro		;8330   ; Dos bits del cuadro
	jr z,L_833F		;8333   ; A cero: parar
	dec a			;8335
	jr z,L_833A		;8336   ; A uno: acercarse
	jr L_8366		;8338   ; Y si no, la orden 3
L_833A:
	ld a,004h		;833a   ; Cuatro pasos
	jp L_8070		;833c
L_833F:
	ld a,030h		;833f   ; 0x30 cuadros de espera
	jp L_8087		;8341
L_8344:
	call saca_dos_bits_del_azar		;8344   ; Dos bits del registro
	dec a			;8347   ; A uno: la orden 6
	jr z,L_8363		;8348
	dec a			;834a
	jr z,L_8366		;834b   ; A dos: la 3
	dec a			;834d
	jr z,L_8352		;834e   ; A tres: la 5
	jr L_832C		;8350   ; Y si no, esperar
L_8352:
	jp L_80D2		;8352
L_8355:
	call saca_dos_bits_del_azar		;8355   ; Dos bits del registro
	dec a			;8358
	jr z,L_8361		;8359
	dec a			;835b
	jr z,L_8363		;835c
	dec a			;835e
	jr z,L_8366		;835f
L_8361:
	jr L_832C		;8361   ; Esperar
L_8363:
	jp L_80B3		;8363   ; Orden 6
L_8366:
	jp L_8081		;8366   ; Orden 3
L_8369:
	call saca_dos_bits_del_azar		;8369   ; Dos bits del registro
	dec a			;836c
	jr z,L_8352		;836d   ; A uno: la orden 5
	dec a			;836f
	jr z,L_8377		;8370   ; A dos: la 4
	dec a			;8372
	jr z,L_837A		;8373   ; Y a tres: la 3 con golpe
	jr L_8366		;8375
L_8377:
	jp L_80B9		;8377
L_837A:
	jp L_80EA		;837a
L_837D:
	ld hl,0e159h		;837d   ; La espera
	dec (hl)			;8380
	ret nz			;8381   ; Todavia dura
	ld a,010h		;8382   ; 0x10 cuadros
	ld (hl),a			;8384
	ld hl,0e135h		;8385   ; El tipo de golpe
	ld a,(hl)			;8388
	and a			;8389
	ld a,002h		;838a   ; Alterna entre el 0...
	jr z,L_838F		;838c
	xor a			;838e   ; ...y el 2
L_838F:
	ld (hl),a			;838f   ; Ahi va
	jp pon_el_tipo_de_golpe		;8390   ; Y a arrancarlo
L_8393:
	ld a,(0e003h)		;8393   ; El contador de cuadros
	bit 6,a		;8396   ; Su bit 6 decide
	jr nz,L_837D		;8398
	jp L_810F		;839a   ; Y si no, el camino de siempre

; ----------------------------------------------------------------------
; DATOS fotogramas_del_enemigo_1: el enemigo del escenario 1, desde 0x6922[1].
;   Delante, 22 punteros que cierran la tabla justo en 0x83C9; detras, 20
;   tramos (10 dibujos y 10 remisiones) que teselan el bloque sin un hueco ni
;   un solape; medidos con formatos.entrada_del_enemigo
;   0x839d..0x84dd  (320 bytes)
DATA_fotogramas_del_enemigo_1:
	defb 0c9h,083h,0dah,083h,0ddh,083h,0f1h,083h,0f4h,083h,00ah,084h,00dh,084h,029h,084h,02ch,084h,048h,084h,04bh,084h,063h,084h,066h,084h,083h,084h,086h,084h,0a5h,084h,0a8h,084h,0c7h,084h,04bh,084h,063h,084h,0cah,084h,0dah,084h	; 839d  ..............).,.H.K.c.f...........K.c.....
	defb 0ffh,000h,008h,0fdh,020h,00eh,080h,080h,080h,005h,003h,000h,0f7h,010h,08dh,0f6h,017h	; 83c9  .... ............
	defb 0feh,0cah,083h	; 83da
	defb 0feh,000h,008h,0f5h,020h,00eh,080h,080h,080h,005h,003h,000h,0f7h,010h,08dh,0f3h,017h,01dh,01eh,01ch	; 83dd  .... ...............
	defb 0ffh,0deh,083h	; 83f1
	defb 000h,000h,008h,004h,020h,00eh,080h,080h,080h,005h,003h,000h,0f6h,010h,08eh,08dh,01fh,090h,08fh,020h,093h,092h	; 83f4  .... .............. ..
	defb 0fdh,0f5h,083h	; 840a
	defb 0feh,000h,008h,0fch,020h,00eh,080h,080h,080h,005h,004h,0e2h,010h,011h,021h,022h,013h,014h,023h,024h,016h,025h,000h,0f3h,026h,000h,0f3h,01ah	; 840d  .... .........!"..#$.%..&...
	defb 0feh,00eh,084h	; 8429
	defb 0feh,000h,008h,0fdh,020h,00eh,080h,080h,080h,005h,004h,0e2h,010h,011h,000h,0f3h,012h,029h,02ah,016h,025h,000h,02bh,027h,028h,000h,0f3h,01ah	; 842c  .... ............)*.%.+'(...
	defb 0feh,02dh,084h	; 8448
	defb 0feh,001h,012h,0fdh,016h,00eh,080h,080h,080h,004h,004h,0e2h,010h,011h,000h,0f3h,012h,029h,02ah,016h,025h,000h,0f3h,02bh	; 844b  .................)*.%..+
	defb 0feh,04ch,084h	; 8463
	defb 0fch,000h,008h,0edh,020h,00eh,080h,080h,011h,0e0h,005h,004h,0e2h,010h,011h,021h,022h,013h,014h,023h,024h,016h,025h,000h,0f3h,026h,000h,0f3h,01ah	; 8466  .... ..........!"..#$.%..&...
	defb 000h,067h,084h	; 8483
	defb 0fbh,000h,008h,0edh,020h,00eh,080h,080h,014h,0deh,005h,005h,0e3h,010h,011h,0e2h,0f3h,012h,0f3h,034h,016h,025h,000h,037h,038h,031h,028h,0e2h,032h,033h,01ch	; 8486  .... ..............4.%.781(.23.
	defb 000h,087h,084h	; 84a5
	defb 0fbh,000h,008h,0edh,020h,00eh,080h,080h,023h,0deh,005h,005h,0e3h,010h,011h,0e2h,0f3h,012h,0e2h,015h,016h,025h,000h,0f3h,02fh,028h,02eh,000h,032h,033h,01ch	; 84a8  .... ...#............%../(..23.
	defb 000h,0a9h,084h	; 84c7
	defb 0fdh,002h,080h,080h,080h,080h,003h,005h,0e3h,010h,011h,0e2h,0f3h,012h,0f5h,039h	; 84ca  ...............9
	defb 0feh,0cbh,084h	; 84da

; ======================================================================
; CODIGO 0x84dd..0x84e4  (7 bytes)
; ======================================================================


L_84DD:
	ld b,008h		;84dd   ; Ocho de un lado...
	ld c,003h		;84df   ; ...y tres del otro
	jp L_7FA7		;84e1   ; A la reaccion comun

; ----------------------------------------------------------------------
; DATOS reacciones_del_escenario_6: 7 entradas, desde 0x7FDB[6]; detras sigue
;   0x84F2
;   0x84e4..0x84f2  (14 bytes)
DATA_reacciones_del_escenario_6:
	defw 08000h,084fah,084fah,084f2h,08108h,080eeh,08108h	; 84e4

; ======================================================================
; CODIGO 0x84f2..0x8500  (14 bytes)
; ======================================================================


L_84F2:
	ld a,(0e003h)		;84f2   ; El contador de cuadros
	and 03eh		;84f5
	jp z,L_810F		;84f7   ; Uno de cada 32 se salta el reparto
L_84FA:
	call pon_la_subescena		;84fa   ; Poner la subescena
	call reparte_por_tabla		;84fd   ; Y a ella

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_8500: 6 entradas, tras el `call reparte_por_tabla`
;   de 0x84FD; detras sigue la primera, 0x850C
;   0x8500..0x850c  (12 bytes)
DATA_tabla_de_subescenas_8500:
	defw 0850ch,0853bh,08553h,08570h,0850ch,08562h	; 8500

; ======================================================================
; CODIGO 0x850c..0x857b  (111 bytes)
; ======================================================================


L_850C:
	call cuenta_atras		;850c   ; La espera
	ret nz			;850f   ; Todavia no
	call dos_bits_del_cuadro		;8510   ; Dos bits del cuadro
	jr z,L_8523		;8513   ; A cero: golpear
	dec a			;8515
	jr z,L_851B		;8516   ; A uno: acercarse
	dec a			;8518
	jr z,L_8520		;8519   ; A dos: la orden 4
L_851B:
	ld a,004h		;851b   ; Cuatro pasos
	jp L_8070		;851d
L_8520:
	jp L_80AF		;8520   ; Orden 4
L_8523:
	ld a,020h		;8523   ; 0x20 cuadros de espera
	ld (0e154h),a		;8525
	ld hl,0e135h		;8528   ; El tipo de golpe
	ld a,(hl)			;852b
	inc a			;852c   ; Uno mas
	cp 002h		;852d   ; De 2 a 5
	jr c,L_8535		;852f
	cp 006h		;8531
	jr c,L_8537		;8533
L_8535:
	ld a,002h		;8535   ; Fuera de rango, se queda en 2
L_8537:
	ld (hl),a			;8537   ; Ahi va
	jp pon_el_tipo_de_golpe		;8538   ; Y a arrancarlo
L_853B:
	call saca_dos_bits_del_azar		;853b   ; Dos bits del registro
	dec a			;853e   ; A uno: la orden 5
	jr z,L_854A		;853f
	dec a			;8541
	jr z,L_854D		;8542   ; A dos: la 3 con golpe
	dec a			;8544
	jr z,L_8550		;8545   ; A tres: la 4
L_8547:
	jp L_8081		;8547   ; Y si no, la orden 3
L_854A:
	jp L_80D2		;854a
L_854D:
	jp L_80EA		;854d
L_8550:
	jp L_80B9		;8550
L_8553:
	call saca_dos_bits_del_azar		;8553   ; Dos bits del registro
	dec a			;8556
	jr z,L_8550		;8557
	dec a			;8559
	jr z,L_854A		;855a
	dec a			;855c
	jr z,L_8550		;855d
	jp L_80B3		;855f   ; Y si no, la orden 6
L_8562:
	call saca_dos_bits_del_azar		;8562   ; Dos bits del registro
	dec a			;8565
	jr z,L_854D		;8566
	dec a			;8568
	jr z,L_8547		;8569
	dec a			;856b
	jr z,L_854D		;856c
	jr L_8547		;856e
L_8570:
	call saca_dos_bits_del_azar		;8570   ; Dos bits del registro
	dec a			;8573
	jr z,L_8550		;8574
	dec a			;8576
	jr z,L_854A		;8577
	jr L_854D		;8579

; ----------------------------------------------------------------------
; DATOS fotogramas_del_enemigo_6: el enemigo del escenario 6, desde 0x6922[6].
;   Delante, 22 punteros que cierran la tabla justo en 0x85A7; detras, 18
;   tramos (9 dibujos y 9 remisiones) que teselan el bloque sin un hueco ni un
;   solape; medidos con formatos.entrada_del_enemigo
;   0x857b..0x86cb  (336 bytes)
DATA_fotogramas_del_enemigo_6:
	defb 0a7h,085h,0c1h,085h,0c4h,085h,0ddh,085h,0e0h,085h,0fah,085h,0fdh,085h,01bh,086h,0fdh,085h,01bh,086h,0fdh,085h,01bh,086h,01eh,086h,042h,086h,045h,086h,06ah,086h,06dh,086h,08dh,086h,090h,086h,0afh,086h,0b2h,086h,0c8h,086h	; 857b  ..........................B.E.j.m...........
	defb 0fdh,001h,008h,0f8h,018h,00eh,020h,0f2h,008h,01bh,080h,080h,004h,005h,000h,0f3h,010h,088h,0f5h,013h,000h,0f4h,018h,000h,0f4h,01ch	; 85a7  ...... ...................
	defb 0feh,0a8h,085h	; 85c1
	defb 0fch,001h,008h,0f0h,020h,00eh,080h,080h,080h,004h,005h,000h,0f3h,010h,088h,0f5h,013h,000h,0f4h,018h,000h,020h,021h,006h,022h	; 85c4  .... ................ !."
	defb 0ffh,0c5h,085h	; 85dd
	defb 0ffh,001h,008h,000h,018h,00eh,020h,0fah,008h,01bh,080h,080h,004h,004h,0f3h,010h,088h,08fh,023h,024h,017h,093h,025h,026h,0f5h,01bh	; 85e0  ...... ...........#$..%&..
	defb 0fdh,0e1h,085h	; 85fa
	defb 0fdh,001h,008h,0f8h,018h,00eh,020h,0f2h,008h,01bh,080h,080h,004h,005h,013h,027h,011h,012h,088h,000h,028h,0f3h,015h,000h,03dh,0f3h,019h,000h,0f4h,01ch	; 85fd  ...... ........'....(...=.....
	defb 0feh,0feh,085h	; 861b
	defb 0fbh,001h,008h,0f0h,018h,00eh,020h,0f0h,008h,015h,080h,010h,0dbh,004h,006h,0e2h,0f3h,010h,088h,0f3h,029h,015h,024h,017h,000h,02ch,006h,019h,026h,01bh,000h,02dh,02eh,021h,006h,01fh	; 861e  ...... .............).$..,..&..-.!..
	defb 0ffh,01fh,086h	; 8642
	defb 0fbh,001h,008h,0e8h,018h,00eh,020h,0e8h,008h,016h,080h,014h,0dbh,004h,006h,000h,02fh,011h,012h,088h,000h,0f3h,030h,08dh,08ch,08bh,000h,01ch,033h,091h,090h,0e2h,034h,096h,095h,094h,000h	; 8645  ...... ........./.....0.....3...4....
	defb 0ffh,046h,086h	; 866a
	defb 0fbh,002h,010h,0e8h,010h,00eh,020h,0e2h,008h,022h,080h,01bh,0dbh,003h,006h,000h,02fh,011h,012h,088h,000h,0f3h,030h,035h,08ch,08bh,000h,01ch,033h,099h,036h,037h	; 866d  ...... .."....../.....05....3.67
	defb 0ffh,06eh,086h	; 868d
	defb 0fdh,002h,010h,0f8h,010h,00eh,020h,0f2h,008h,022h,080h,080h,003h,006h,000h,02fh,011h,012h,088h,000h,0f3h,030h,035h,08ch,08bh,000h,01ch,033h,099h,036h,037h	; 8690  ...... .."...../.....05....3.67
	defb 0fdh,091h,086h	; 86af
	defb 0feh,002h,080h,080h,080h,080h,003h,005h,000h,038h,000h,0b0h,0e2h,039h,03ah,0b1h,000h,03bh,03ch,006h,0b4h,0b3h	; 86b2  .........8...9:..;<...
	defb 0fdh,0b3h,086h	; 86c8

; ======================================================================
; CODIGO 0x86cb..0x86f6  (43 bytes)
; ======================================================================


L_86CB:
	call mide_la_distancia		;86cb   ; Medir la distancia
	call copia_el_lado		;86ce   ; Y copiar el lado
	ld a,(0e181h)		;86d1   ; Esta agarrado?
	and a			;86d4
	jp nz,L_87B0		;86d5
	ld hl,0e15ah		;86d8   ; La cuenta del agarre
	ld a,(hl)			;86db
	and a			;86dc
	jp z,decide_que_hace_el_enemigo		;86dd   ; A cero: lo de siempre
	dec (hl)			;86e0   ; Una menos
	dec a			;86e1
	ld a,018h		;86e2   ; 0x18 cuadros de espera
	ld (0e154h),a		;86e4
	jr nz,L_86EE		;86e7
	ld b,005h		;86e9   ; Se acabo: la orden 5
	jp apunta_la_orden		;86eb
L_86EE:
	ld a,(hl)			;86ee   ; La cuenta...
	and 001h		;86ef   ; ...alterna entre 4 y 5
	add a,004h		;86f1
	jp L_80BB		;86f3

; ----------------------------------------------------------------------
; DATOS reacciones_del_escenario_2: 7 entradas, desde 0x7FDB[2]; detras sigue
;   0x8704
;   0x86f6..0x8704  (14 bytes)
DATA_reacciones_del_escenario_2:
	defw 08000h,0870ch,0870ch,08704h,0810fh,087a6h,087a6h	; 86f6

; ======================================================================
; CODIGO 0x8704..0x8712  (14 bytes)
; ======================================================================


L_8704:
	ld a,(0e003h)		;8704   ; El contador de cuadros
	and 03eh		;8707
	jp z,L_810F		;8709   ; Uno de cada 32 se salta el reparto
L_870C:
	call pon_la_subescena		;870c   ; Poner la subescena
	call reparte_por_tabla		;870f   ; Y a ella

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_8712: 6 entradas, tras el `call reparte_por_tabla`
;   de 0x870F; detras sigue la primera, 0x871E
;   0x8712..0x871e  (12 bytes)
DATA_tabla_de_subescenas_8712:
	defw 0871eh,08737h,0874dh,0876ah,0871eh,0875ch	; 8712

; ======================================================================
; CODIGO 0x871e..0x87c7  (169 bytes)
; ======================================================================


L_871E:
	call cuenta_atras		;871e   ; La espera
	ret nz			;8721   ; Todavia no
	call dos_bits_del_cuadro		;8722   ; Dos bits del cuadro
	jr z,L_8732		;8725   ; A cero: golpear
	dec a			;8727
	jr z,L_872F		;8728   ; A uno: la orden 4
	ld a,005h		;872a   ; Y si no, cinco pasos
	jp L_8070		;872c
L_872F:
	jp L_80AF		;872f   ; Orden 4
L_8732:
	ld a,028h		;8732   ; 0x28 cuadros de espera
	jp L_8087		;8734
L_8737:
	call saca_dos_bits_del_azar		;8737   ; Dos bits del registro
	dec a			;873a
	jr z,L_8745		;873b
	dec a			;873d
	jr z,L_8747		;873e
	dec a			;8740
	jr z,L_874A		;8741
	jr L_871E		;8743
L_8745:
	jr L_872F		;8745   ; Orden 4
L_8747:
	jp L_80EA		;8747   ; Orden 3 con golpe
L_874A:
	jp L_80D2		;874a   ; Orden 5
L_874D:
	call saca_dos_bits_del_azar		;874d   ; Dos bits del registro
	dec a			;8750
	jr z,L_8747		;8751
	dec a			;8753
	jr z,L_8759		;8754
	dec a			;8756
	jr z,L_874A		;8757
L_8759:
	jp L_80B3		;8759   ; Orden 6
L_875C:
	call saca_dos_bits_del_azar		;875c   ; Dos bits del registro
	dec a			;875f
	jr z,L_8747		;8760
	dec a			;8762
	jr z,L_8767		;8763
	jr L_8745		;8765
L_8767:
	jp L_8081		;8767   ; Orden 3
L_876A:
	call saca_dos_bits_del_azar		;876a   ; Dos bits del registro
	dec a			;876d
	dec a			;876e
	jr z,L_8745		;876f   ; A dos: la orden 4
	jr L_874A		;8771   ; Y si no, la 5
L_8773:
	ld hl,0e15bh		;8773   ; La cuenta de lo que se lanza
	ld a,(hl)			;8776
	and a			;8777
	jr z,L_8791		;8778   ; A cero: hay que recargar
	dec (hl)			;877a   ; Una menos
	ld b,003h		;877b   ; Las tres ranuras
	ld hl,0e1a7h		;877d   ; La primera
L_8780:
	ld a,(hl)			;8780   ; Ocupada?
	and a			;8781
	jr z,L_8788		;8782
	inc hl			;8784   ; La siguiente
	djnz L_8780		;8785
	ret			;8787   ; Las tres llenas: nada
L_8788:
	ld a,003h		;8788   ; Cual ha quedado libre
	sub b			;878a
	ld (0e135h),a		;878b   ; Esa se lanza
	jp pon_el_tipo_de_golpe		;878e   ; Y arrancar el golpe
L_8791:
	ld hl,0e159h		;8791   ; La espera
	dec (hl)			;8794
	ret nz			;8795   ; Todavia dura
	ld a,00bh		;8796   ; Once cuadros
	ld (hl),a			;8798
	ld a,(0e003h)		;8799   ; El contador de cuadros...
	rra			;879c
	and 003h		;879d   ; ...da dos bits...
	jr nz,L_87A2		;879f
	inc a			;87a1   ; ...y el cero se cambia por uno
L_87A2:
	ld (0e15bh),a		;87a2   ; Esas son las que se lanzan
	ret			;87a5
L_87A6:
	ld a,(0e003h)		;87a6   ; El contador de cuadros
	bit 6,a		;87a9   ; Su bit 6 decide
	jr nz,L_8773		;87ab
	jp L_810F		;87ad   ; Y si no, el camino de siempre
L_87B0:
	call mide_la_distancia		;87b0   ; Medir la distancia
	ld a,b			;87b3
	cp 003h		;87b4   ; De lejos...
	push hl			;87b6
	jp nc,L_7F79		;87b7   ; ...se suelta lo agarrado
	pop hl			;87ba
	ld hl,0e154h		;87bb   ; La espera
	dec (hl)			;87be
	ld a,(hl)			;87bf
	and a			;87c0
	ret nz			;87c1
	ld a,006h		;87c2
	jp L_8087		;87c4

; ----------------------------------------------------------------------
; DATOS fotogramas_del_enemigo_2: el enemigo del escenario 2, desde 0x6922[2].
;   Delante, 22 punteros que cierran la tabla justo en 0x87F3; detras, 18
;   tramos (9 dibujos y 9 remisiones) que teselan el bloque sin un hueco ni un
;   solape; medidos con formatos.entrada_del_enemigo
;   0x87c7..0x88fe  (311 bytes)
DATA_fotogramas_del_enemigo_2:
	defb 0f3h,087h,008h,088h,00bh,088h,021h,088h,024h,088h,040h,088h,043h,088h,059h,088h,043h,088h,059h,088h,05ch,088h,073h,088h,076h,088h,097h,088h,09ah,088h,0bdh,088h,0c0h,088h,0e2h,088h,05ch,088h,073h,088h,0e5h,088h,0fbh,088h	; 87c7  ......!.$.@.C.Y.C.Y.\.s.v...........\.s.....
	defb 0feh,000h,008h,0f8h,018h,010h,020h,0f0h,008h,01fh,080h,080h,005h,004h,0e2h,010h,000h,0fah,011h,0f6h,01ah	; 87f3  ...... ..............
	defb 0feh,0f4h,087h	; 8808
	defb 0fdh,000h,008h,0f0h,020h,010h,080h,080h,080h,005h,004h,0e2h,010h,000h,0f8h,011h,020h,01ah,01ah,0f4h,021h,000h	; 880b  .... ........... ...!.
	defb 0ffh,00ch,088h	; 8821
	defb 0ffh,000h,008h,000h,020h,010h,080h,080h,080h,005h,004h,000h,088h,0e2h,08ch,08bh,08ah,089h,090h,08fh,08eh,08dh,020h,01ah,01ah,0f4h,021h,000h	; 8824  .... ................. ...!.
	defb 0fdh,025h,088h	; 8840
	defb 0ffh,001h,012h,0ffh,016h,00dh,080h,080h,080h,004h,005h,000h,025h,026h,010h,000h,0f4h,027h,000h,0f8h,02bh,0e2h	; 8843  ............%&...'..+.
	defb 0fch,044h,088h	; 8859
	defb 0ffh,002h,018h,0feh,010h,010h,080h,080h,080h,003h,005h,000h,025h,026h,010h,000h,0f4h,027h,000h,037h,038h,0f3h,02dh	; 885c  ............%&...'.78.-
	defb 0fch,05dh,088h	; 8873
	defb 0fbh,000h,008h,0e8h,018h,010h,020h,0e0h,008h,01fh,080h,00ch,0dch,005h,005h,0e3h,010h,000h,0f3h,039h,013h,014h,000h,0f4h,015h,000h,019h,01ah,01ah,01bh,000h,0f4h,01ch	; 8876  ...... ............9.............
	defb 000h,077h,088h	; 8897
	defb 0fbh,000h,008h,0e8h,018h,010h,020h,0e0h,008h,01fh,080h,00eh,0dch,005h,005h,0e3h,010h,000h,03ch,03dh,03bh,03eh,0e2h,03fh,016h,017h,040h,000h,019h,01ah,01ah,041h,000h,0f4h,01ch	; 889a  ...... ...........<=;>.?..@....A...
	defb 000h,09bh,088h	; 88bd
	defb 0fbh,000h,008h,0f2h,020h,010h,020h,0f4h,008h,00ch,080h,025h,0deh,005h,006h,0e4h,010h,0e2h,0f3h,039h,013h,014h,0e2h,042h,0f3h,016h,000h,0f3h,043h,01ah,0f5h,046h,094h,000h	; 88c0  .... . ....%.......9...B....C..F..
	defb 0ffh,0c1h,088h	; 88e2
	defb 0fdh,002h,080h,080h,080h,080h,003h,005h,000h,04dh,000h,0c5h,0e2h,04eh,04fh,0c6h,000h,050h,051h,006h,0c9h,0c8h	; 88e5  .........M...NO..PQ...
	defb 0feh,0e6h,088h	; 88fb

; ======================================================================
; CODIGO 0x88fe..0x8937  (57 bytes)
; ======================================================================


L_88FE:
	call mide_la_distancia		;88fe   ; Medir la distancia
	call copia_el_lado		;8901   ; Y copiar el lado
	ld hl,0e15ah		;8904   ; La cuenta del agarre
	ld a,(hl)			;8907
	and a			;8908
	jr z,L_8921		;8909   ; A cero: lo de siempre
	dec (hl)			;890b   ; Una menos
	dec a			;890c
	ld a,010h		;890d   ; 0x10 cuadros de espera
	ld (0e154h),a		;890f
	jr nz,L_8919		;8912   ; Se acabo: la orden 5
	ld b,005h		;8914
	jp apunta_la_orden		;8916
L_8919:
	ld a,(hl)			;8919   ; La cuenta...
	and 001h		;891a   ; ...alterna entre 4 y 5
	add a,004h		;891c
	jp L_80BB		;891e
L_8921:
	call mide_la_distancia		;8921   ; Medir otra vez
	call copia_el_lado		;8924   ; Y copiar el lado
	ld a,(0e1b0h)		;8927   ; En que estado esta lo que gira
	cp 006h		;892a   ; En el 6...
	jr nz,L_8933		;892c
	ld a,001h		;892e   ; ...se marca que ha agarrado
	ld (0e1c6h),a		;8930
L_8933:
	ld a,b			;8933   ; El tramo de distancia
	call reparte_por_tabla		;8934   ; Y a la reaccion que toque

; ----------------------------------------------------------------------
; DATOS reacciones_del_escenario_3: 7 entradas. Llega por dos caminos: el
;   `call reparte_por_tabla` de 0x8934 y, como las otras siete, 0x7FDB[3];
;   detras sigue la primera, 0x8945
;   0x8937..0x8945  (14 bytes)
DATA_reacciones_del_escenario_3:
	defw 08000h,0894dh,0894dh,08945h,0810fh,089e9h,089e9h	; 8937

; ======================================================================
; CODIGO 0x8945..0x8953  (14 bytes)
; ======================================================================


L_8945:
	ld a,(0e003h)		;8945   ; El contador de cuadros
	and 03eh		;8948
	jp z,L_810F		;894a   ; Uno de cada 32 se salta el reparto
L_894D:
	call pon_la_subescena		;894d   ; Poner la subescena
	call reparte_por_tabla		;8950   ; Y a ella

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_8953: 6 entradas, tras el `call reparte_por_tabla`
;   de 0x8950; detras sigue la primera, 0x895F
;   0x8953..0x895f  (12 bytes)
DATA_tabla_de_subescenas_8953:
	defw 0895fh,0899bh,089b2h,089cbh,0895fh,089c3h	; 8953

; ======================================================================
; CODIGO 0x895f..0x89f3  (148 bytes)
; ======================================================================


L_895F:
	call cuenta_atras		;895f   ; La espera
	ret nz			;8962   ; Todavia no
	call dos_bits_del_cuadro		;8963   ; Dos bits del cuadro
	jr z,L_8973		;8966   ; A cero: golpear
	dec a			;8968
	jr z,L_896E		;8969   ; A uno: acercarse
	dec a			;896b
	jr z,L_8973		;896c   ; Y a dos, golpear tambien
L_896E:
	ld a,004h		;896e   ; Cuatro pasos
	jp L_8070		;8970
L_8973:
	ld a,(0e1b0h)		;8973   ; Hay algo girando?
	and a			;8976
	jr z,L_8998		;8977   ; No: la orden 3
	ld a,020h		;8979   ; 0x20 cuadros de espera
	ld (0e154h),a		;897b
	ld hl,0e135h		;897e   ; El tipo de golpe
	ld a,(hl)			;8981
	inc a			;8982   ; Uno mas
	cp 003h		;8983   ; De 3 a 5
	jr c,L_898B		;8985
	cp 006h		;8987
	jr c,L_8994		;8989
L_898B:
	ld a,(0e1b0h)		;898b   ; Fuera de rango: 3 si hay algo girando...
	and a			;898e
	ld a,003h		;898f
	jr nz,L_8994		;8991
	dec a			;8993   ; ...y 2 si no
L_8994:
	ld (hl),a			;8994   ; Ahi va
	jp pon_el_tipo_de_golpe		;8995   ; Y a arrancarlo
L_8998:
	jp L_8081		;8998   ; Orden 3
L_899B:
	call saca_dos_bits_del_azar		;899b   ; Dos bits del registro
	dec a			;899e
	jr z,L_89A9		;899f
	dec a			;89a1
	jr z,L_89AC		;89a2
	dec a			;89a4
	jr z,L_89AF		;89a5
	jr L_89AF		;89a7
L_89A9:
	jp L_80B9		;89a9   ; Orden 4 con golpe
L_89AC:
	jp L_80D2		;89ac   ; Orden 5
L_89AF:
	jp L_80EA		;89af   ; Orden 3 con golpe
L_89B2:
	call saca_dos_bits_del_azar		;89b2   ; Dos bits del registro
	dec a			;89b5
	jr z,L_89C1		;89b6
	dec a			;89b8
	jr z,L_89BE		;89b9
	dec a			;89bb
	jr z,L_89A9		;89bc
L_89BE:
	jp L_80B3		;89be   ; Orden 6
L_89C1:
	jr L_8998		;89c1   ; Y a la orden 3
L_89C3:
	call saca_dos_bits_del_azar		;89c3   ; Dos bits del registro
	and a			;89c6   ; A cero: la orden 3
	jr z,L_89C1		;89c7
	jr L_89AF		;89c9   ; Y si no, la 3 con golpe
L_89CB:
	call saca_dos_bits_del_azar		;89cb   ; Dos bits del registro
	dec a			;89ce
	jr z,L_89AC		;89cf
	dec a			;89d1
	jr z,L_89AC		;89d2
	jr L_89A9		;89d4   ; Y si no, la orden 4
L_89D6:
	ld a,(0e1b0h)		;89d6   ; Hay algo girando?
	and a			;89d9
	ret nz			;89da   ; Si: nada que hacer
	ld a,(0e003h)		;89db   ; Uno de cada dieciseis cuadros
	and 01eh		;89de
	ret nz			;89e0
	ld a,002h		;89e1   ; El golpe 2
	ld (0e135h),a		;89e3
	jp pon_el_tipo_de_golpe		;89e6   ; Arrancarlo
L_89E9:
	ld a,(0e003h)		;89e9   ; El contador de cuadros
	bit 6,a		;89ec   ; Su bit 6 decide
	jr nz,L_89D6		;89ee
	jp L_810F		;89f0   ; Y si no, el camino de siempre

; ----------------------------------------------------------------------
; DATOS fotogramas_del_enemigo_3: el enemigo del escenario 3, desde 0x6922[3].
;   Delante, 22 punteros que cierran la tabla justo en 0x8A1F; detras, 18
;   tramos (9 dibujos y 9 remisiones) que teselan el bloque sin un hueco ni un
;   solape; medidos con formatos.entrada_del_enemigo
;   0x89f3..0x8b32  (319 bytes)
DATA_fotogramas_del_enemigo_3:
	defb 01fh,08ah,034h,08ah,037h,08ah,050h,08ah,053h,08ah,073h,08ah,076h,08ah,08fh,08ah,076h,08ah,08fh,08ah,076h,08ah,08fh,08ah,092h,08ah,0b5h,08ah,0b8h,08ah,0d7h,08ah,0dah,08ah,0f7h,08ah,0fah,08ah,016h,08bh,019h,08bh,02fh,08bh	; 89f3  ..4.7.P.S.s.v...v...v...................../.
	defb 0feh,000h,008h,0f8h,018h,010h,020h,0f4h,008h,01ch,080h,080h,005h,004h,000h,05bh,0e3h,05ch,05dh,0fdh,010h	; 8a1f  ...... ........[.\]..
	defb 0feh,020h,08ah	; 8a34
	defb 0fdh,000h,008h,0f0h,020h,010h,080h,080h,080h,005h,004h,000h,05bh,0e3h,05ch,05dh,0f5h,010h,01dh,01eh,017h,01fh,000h,0f3h,020h	; 8a37  .... .......[.\]........ 
	defb 0ffh,038h,08ah	; 8a50
	defb 0ffh,000h,008h,000h,018h,010h,020h,00ch,008h,00ch,080h,080h,005h,004h,000h,05bh,0e2h,023h,024h,05dh,010h,025h,0f3h,012h,026h,027h,017h,018h,028h,000h,01bh,01ch	; 8a53  ...... ........[.#$].%..&'..(...
	defb 0fdh,054h,08ah	; 8a73
	defb 0feh,001h,008h,0f8h,020h,010h,080h,080h,080h,004h,004h,043h,05ch,05dh,010h,044h,0f3h,012h,000h,045h,017h,01fh,000h,0f3h,020h	; 8a76  .... ......C\].D...E.... 
	defb 0feh,077h,08ah	; 8a8f
	defb 0fbh,000h,008h,0e8h,018h,010h,020h,0e4h,008h,01ah,080h,00eh,0deh,005h,005h,0e2h,05bh,0e2h,029h,02ah,05eh,05fh,0e3h,0f3h,02bh,000h,02eh,036h,00ah,02fh,000h,019h,01ah,030h,031h	; 8a92  ...... .........[.)*^_..+..6./...01
	defb 000h,093h,08ah	; 8ab5
	defb 0fbh,000h,008h,0e8h,020h,010h,080h,080h,00eh,0dbh,005h,005h,0e2h,05bh,0e2h,032h,000h,05eh,05fh,000h,0f3h,033h,02ch,037h,000h,0f3h,038h,0e3h,03bh,03ch,000h	; 8ab8  .... ........[.2.^_..3,7..8.;<.
	defb 000h,0b9h,08ah	; 8ad7
	defb 0fbh,001h,010h,0f0h,018h,010h,080h,080h,024h,0ddh,004h,006h,0e3h,05bh,0e3h,029h,02ah,05eh,05fh,0e3h,03dh,02bh,02ch,037h,0f3h,03eh,039h,041h,042h	; 8ada  ........$....[.)*^_.=+,7.>9AB
	defb 0ffh,0dbh,08ah	; 8af7
	defb 0fbh,001h,010h,0f0h,018h,010h,080h,080h,080h,004h,006h,0e3h,05bh,0e3h,029h,02ah,05eh,05fh,0e3h,03dh,02bh,02ch,037h,0f3h,03eh,039h,041h,042h	; 8afa  ............[.)*^_.=+,7.>9AB
	defb 0ffh,0fbh,08ah	; 8b16
	defb 0feh,002h,080h,080h,080h,080h,003h,005h,000h,048h,000h,0c0h,0e2h,049h,04ah,0c1h,000h,04bh,04ch,00ah,0c4h,0c3h	; 8b19  .........H...IJ..KL...
	defb 0fdh,01ah,08bh	; 8b2f

; ======================================================================
; CODIGO 0x8b32..0x8b39  (7 bytes)
; ======================================================================


L_8B32:
	ld b,028h		;8b32   ; 0x28 de un lado...
	ld c,004h		;8b34   ; ...y cuatro del otro
	jp L_7FA7		;8b36   ; A la reaccion comun

; ----------------------------------------------------------------------
; DATOS reacciones_del_escenario_4: 7 entradas, desde 0x7FDB[4]; detras sigue
;   0x8B47
;   0x8b39..0x8b47  (14 bytes)
DATA_reacciones_del_escenario_4:
	defw 08000h,08b4fh,08b4fh,08b47h,08b47h,08773h,087a6h	; 8b39

; ======================================================================
; CODIGO 0x8b47..0x8b55  (14 bytes)
; ======================================================================


L_8B47:
	ld a,(0e003h)		;8b47   ; El contador de cuadros
	and 07eh		;8b4a
	jp z,L_810F		;8b4c   ; Uno de cada 64 se salta el reparto
L_8B4F:
	call pon_la_subescena		;8b4f   ; Poner la subescena
	call reparte_por_tabla		;8b52   ; Y a ella

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_8b55: 6 entradas, tras el `call reparte_por_tabla`
;   de 0x8B52; detras sigue la primera, 0x8B61
;   0x8b55..0x8b61  (12 bytes)
DATA_tabla_de_subescenas_8b55:
	defw 08b61h,08b79h,08b8dh,08ba7h,08b61h,08b9fh	; 8b55

; ======================================================================
; CODIGO 0x8b61..0x8baf  (78 bytes)
; ======================================================================


L_8B61:
	call cuenta_atras		;8b61   ; La espera
	ret nz			;8b64   ; Todavia no
	call dos_bits_del_cuadro		;8b65   ; Dos bits del cuadro
	jp z,L_8085		;8b68   ; A cero: golpear
	dec a			;8b6b
	jr z,L_8B76		;8b6c   ; A uno: la orden 4
	dec a			;8b6e
	jr z,L_8B76		;8b6f   ; A dos: la 4 tambien
	ld a,004h		;8b71   ; Y si no, cuatro pasos
	jp L_8070		;8b73
L_8B76:
	jp L_80AF		;8b76   ; Orden 4
L_8B79:
	call saca_dos_bits_del_azar		;8b79   ; Dos bits del registro
	dec a			;8b7c
	jr z,L_8B85		;8b7d
	dec a			;8b7f
	jr z,L_8B87		;8b80
	dec a			;8b82
	jr z,L_8B8A		;8b83
L_8B85:
	jr L_8B76		;8b85   ; Orden 4
L_8B87:
	jp L_80D2		;8b87   ; Orden 5
L_8B8A:
	jp L_80EA		;8b8a   ; Orden 3 con golpe
L_8B8D:
	call saca_dos_bits_del_azar		;8b8d   ; Dos bits del registro
	dec a			;8b90
	jr z,L_8B87		;8b91
	dec a			;8b93
	jr z,L_8B9C		;8b94
	dec a			;8b96
	jr z,L_8B9C		;8b97
	jp L_80B3		;8b99   ; Orden 6
L_8B9C:
	jp L_80B9		;8b9c   ; Orden 4 con golpe
L_8B9F:
	call saca_dos_bits_del_azar		;8b9f   ; Dos bits del registro
	dec a			;8ba2
	jr z,L_8B8A		;8ba3   ; A uno: la orden 3 con golpe
	jr L_8B85		;8ba5   ; Y si no, la 4
L_8BA7:
	call saca_dos_bits_del_azar		;8ba7   ; Dos bits del registro
	and a			;8baa
	jr nz,L_8B9C		;8bab   ; A cero: la orden 4
	jr L_8B85		;8bad   ; Y si no, la 4 con golpe

; ----------------------------------------------------------------------
; DATOS fotogramas_del_enemigo_4: el enemigo del escenario 4, desde 0x6922[4].
;   Delante, 22 punteros que cierran la tabla justo en 0x8BDB; detras, 20
;   tramos (10 dibujos y 10 remisiones) que teselan el bloque sin un hueco ni
;   un solape; medidos con formatos.entrada_del_enemigo
;   0x8baf..0x8d2b  (380 bytes)
DATA_fotogramas_del_enemigo_4:
	defb 0dbh,08bh,0f1h,08bh,0f4h,08bh,00ch,08ch,00fh,08ch,02dh,08ch,030h,08ch,056h,08ch,059h,08ch,07eh,08ch,081h,08ch,09dh,08ch,0a0h,08ch,0c6h,08ch,0c9h,08ch,0ebh,08ch,0eeh,08ch,00fh,08dh,081h,08ch,09dh,08ch,012h,08dh,028h,08dh	; 8baf  ..........-.0.V.Y.~.......................(.
	defb 0feh,000h,008h,0f8h,018h,010h,020h,0f3h,008h,018h,080h,080h,005h,004h,000h,010h,011h,000h,0f8h,012h,0f8h,01ah	; 8bdb  ...... ...............
	defb 0feh,0dch,08bh	; 8bf1
	defb 0fdh,000h,008h,0f0h,020h,010h,080h,080h,080h,005h,004h,000h,010h,011h,000h,0f8h,012h,000h,01bh,01ch,022h,000h,0f3h,023h	; 8bf4  .... ..............."..#
	defb 0ffh,0f5h,08bh	; 8c0c
	defb 0ffh,000h,008h,000h,018h,010h,020h,000h,008h,014h,080h,080h,005h,004h,000h,010h,011h,000h,0f4h,012h,026h,017h,018h,027h,0f4h,01ah,028h,029h,020h,021h	; 8c0f  ...... .............&..'..() !
	defb 0fdh,010h,08ch	; 8c2d
	defb 0fdh,000h,008h,0f8h,018h,010h,020h,0f3h,008h,019h,080h,080h,005h,005h,0e2h,010h,011h,000h,048h,02bh,02ch,014h,015h,000h,02dh,02eh,03dh,019h,000h,01ah,02fh,01ch,01dh,000h,01eh,01fh,030h,031h	; 8c30  ...... ...........H+,...-.=.../.....01
	defb 0feh,031h,08ch	; 8c56
	defb 0fdh,000h,008h,0f8h,018h,010h,020h,0f3h,008h,019h,080h,080h,005h,005h,0e2h,010h,011h,0e2h,049h,04ah,014h,015h,048h,04bh,02eh,03dh,019h,000h,01ah,02fh,01ch,01dh,000h,01eh,01fh,030h,031h	; 8c59  ...... ...........IJ..HK.=.../.....01
	defb 0feh,05ah,08ch	; 8c7e
	defb 0fch,001h,014h,0f8h,00ch,010h,020h,0f0h,008h,018h,080h,080h,004h,006h,0e3h,010h,011h,0e3h,0f4h,012h,0e2h,0f4h,016h,0f3h,04ch,01bh,01ch,04fh	; 8c81  ...... .................L..O
	defb 0feh,082h,08ch	; 8c9d
	defb 0fbh,000h,008h,0e8h,018h,010h,020h,0e3h,008h,019h,080h,00ch,0dch,005h,005h,0e2h,010h,011h,000h,0f3h,02ah,014h,015h,000h,02dh,02eh,03dh,019h,000h,01ah,02fh,01ch,01dh,000h,01eh,01fh,030h,031h	; 8ca0  ...... .............*...-.=.../.....01
	defb 000h,0a1h,08ch	; 8cc6
	defb 0fbh,000h,008h,0e8h,014h,010h,020h,0fch,008h,008h,080h,012h,0deh,005h,006h,0e3h,010h,011h,0e3h,032h,033h,014h,015h,0f4h,034h,00bh,038h,0e2h,0f3h,039h,01dh,0e4h,03ch,096h	; 8cc9  ...... ............23...4.8..9..<.
	defb 0ffh,0cah,08ch	; 8ceb
	defb 0fch,000h,008h,0f0h,020h,010h,080h,080h,022h,0dfh,005h,005h,0e2h,010h,011h,0e2h,032h,033h,014h,015h,000h,03eh,037h,00bh,03fh,0f3h,040h,01ch,0f3h,043h,01eh,01fh,000h	; 8cee  .... ...".......23...>7.?.@..C...
	defb 0ffh,0efh,08ch	; 8d0f
	defb 0fdh,002h,080h,080h,080h,080h,003h,005h,000h,050h,000h,0c8h,0e2h,051h,052h,0c9h,000h,053h,054h,002h,0cch,0cbh	; 8d12  .........P...QR..ST...
	defb 0feh,013h,08dh	; 8d28

; ======================================================================
; CODIGO 0x8d2b..0x8d32  (7 bytes)
; ======================================================================


L_8D2B:
	ld b,028h		;8d2b   ; 0x28 de un lado...
	ld c,004h		;8d2d   ; ...y cuatro del otro
	jp L_7FA7		;8d2f   ; A la reaccion comun

; ----------------------------------------------------------------------
; DATOS reacciones_del_escenario_5: 7 entradas, desde 0x7FDB[5]; detras sigue
;   0x8D40
;   0x8d32..0x8d40  (14 bytes)
DATA_reacciones_del_escenario_5:
	defw 08000h,08d48h,08d48h,08d40h,08d40h,08773h,087a6h	; 8d32

; ======================================================================
; CODIGO 0x8d40..0x8d4e  (14 bytes)
; ======================================================================


L_8D40:
	ld a,(0e003h)		;8d40   ; El contador de cuadros
	and 07eh		;8d43
	jp z,L_810F		;8d45   ; Uno de cada 64 se salta el reparto
L_8D48:
	call pon_la_subescena		;8d48   ; Poner la subescena
	call reparte_por_tabla		;8d4b   ; Y a ella

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_8d4e: 6 entradas, tras el `call reparte_por_tabla`
;   de 0x8D4B; detras sigue la primera, 0x8D5A
;   0x8d4e..0x8d5a  (12 bytes)
DATA_tabla_de_subescenas_8d4e:
	defw 08d5ah,08d71h,08d88h,08da3h,08d5ah,08d95h	; 8d4e

; ======================================================================
; CODIGO 0x8d5a..0x8dac  (82 bytes)
; ======================================================================


L_8D5A:
	call cuenta_atras		;8d5a   ; La espera
	ret nz			;8d5d   ; Todavia no
	call dos_bits_del_cuadro		;8d5e   ; Dos bits del cuadro
	jp z,L_8085		;8d61   ; A cero: golpear
	dec a			;8d64
	jr z,L_8D69		;8d65   ; A uno: acercarse
	jr L_8D6E		;8d67   ; Y si no, la orden 4
L_8D69:
	ld a,004h		;8d69   ; Cuatro pasos
	jp L_8070		;8d6b
L_8D6E:
	jp L_80AF		;8d6e   ; Orden 4
L_8D71:
	call saca_dos_bits_del_azar		;8d71   ; Dos bits del registro
	dec a			;8d74
	jr z,L_8D80		;8d75
	dec a			;8d77
	jr z,L_8D82		;8d78
	dec a			;8d7a
	jr z,L_8D85		;8d7b
L_8D7D:
	jp L_80D2		;8d7d   ; Orden 5
L_8D80:
	jr L_8D6E		;8d80   ; Orden 4
L_8D82:
	jp L_80B9		;8d82   ; Orden 4 con golpe
L_8D85:
	jp L_80EA		;8d85   ; Orden 3 con golpe
L_8D88:
	call saca_dos_bits_del_azar		;8d88   ; Dos bits del registro
	dec a			;8d8b
	dec a			;8d8c
	jr z,L_8D7D		;8d8d   ; A dos: la orden 5
	dec a			;8d8f
	jr z,L_8D82		;8d90   ; A tres: la 4 con golpe
	jp L_80B3		;8d92   ; Y si no, la 6
L_8D95:
	call saca_dos_bits_del_azar		;8d95   ; Dos bits del registro
	dec a			;8d98
	jr z,L_8D82		;8d99
	dec a			;8d9b
	jr z,L_8DA1		;8d9c
	dec a			;8d9e
	jr z,L_8D82		;8d9f
L_8DA1:
	jr L_8D80		;8da1   ; Orden 4
L_8DA3:
	call saca_dos_bits_del_azar		;8da3   ; Dos bits del registro
	dec a			;8da6
	dec a			;8da7
	jr z,L_8D80		;8da8   ; A dos: la orden 4
	jr L_8D82		;8daa   ; Y si no, la 4 con golpe

; ----------------------------------------------------------------------
; DATOS fotogramas_del_enemigo_5: el enemigo del escenario 5, desde 0x6922[5].
;   Delante, 22 punteros que cierran la tabla justo en 0x8DD8; detras, 20
;   tramos (10 dibujos y 10 remisiones) que teselan el bloque sin un hueco ni
;   un solape; medidos con formatos.entrada_del_enemigo
;   0x8dac..0x8ee7  (315 bytes)
DATA_fotogramas_del_enemigo_5:
	defb 0d8h,08dh,0efh,08dh,0f2h,08dh,002h,08eh,005h,08eh,01dh,08eh,020h,08eh,03eh,08eh,041h,08eh,05eh,08eh,061h,08eh,077h,08eh,07ah,08eh,094h,08eh,097h,08eh,0b4h,08eh,0b7h,08eh,0d3h,08eh,061h,08eh,077h,08eh,0d6h,08eh,0e4h,08eh	; 8dac  ............ .>.A.^.a.w.z...........a.w.....
	defb 0feh,001h,008h,0fah,018h,00eh,020h,0f3h,008h,019h,080h,080h,004h,004h,000h,0f3h,010h,000h,0f3h,013h,000h,0f7h,016h	; 8dd8  ...... ................
	defb 0feh,0d9h,08dh	; 8def
	defb 0feh,001h,008h,0f2h,020h,00eh,080h,080h,080h,004h,003h,0f7h,010h,0f4h,01dh,000h	; 8df2  .... ...........
	defb 0ffh,0f3h,08dh	; 8e02
	defb 0ffh,001h,008h,003h,018h,00eh,020h,0fbh,008h,019h,080h,080h,004h,004h,000h,0f3h,010h,000h,021h,014h,015h,000h,0f7h,016h	; 8e05  ...... ...........!.....
	defb 0fdh,006h,08eh	; 8e1d
	defb 0feh,001h,008h,0fah,018h,00eh,020h,0f3h,008h,012h,080h,080h,004h,004h,022h,023h,011h,012h,000h,021h,014h,03eh,000h,016h,01dh,024h,019h,01ah,020h,000h	; 8e20  ...... ......."#...!.>...$.. .
	defb 0feh,021h,08eh	; 8e3e
	defb 0feh,001h,008h,0fah,018h,00eh,020h,0f3h,008h,012h,080h,080h,004h,004h,000h,0f3h,010h,025h,026h,014h,03eh,000h,016h,01dh,024h,019h,01ah,020h,000h	; 8e41  ...... ..........%&.>...$.. .
	defb 0feh,042h,08eh	; 8e5e
	defb 0feh,002h,010h,0fah,018h,00eh,080h,080h,080h,003h,004h,000h,0f3h,010h,025h,026h,014h,03eh,000h,016h,027h,024h	; 8e61  ..............%&.>..'$
	defb 0feh,062h,08eh	; 8e77
	defb 0fch,001h,008h,0eah,018h,00eh,020h,0e3h,008h,019h,080h,00dh,0e2h,004h,004h,028h,029h,011h,012h,000h,02ah,014h,015h,000h,0f7h,016h	; 8e7a  ...... ........()...*.....
	defb 000h,07bh,08eh	; 8e94
	defb 0fbh,001h,008h,0e9h,018h,00dh,020h,0f4h,008h,010h,080h,00eh,0dch,004h,005h,02bh,022h,023h,011h,012h,0f5h,02ch,000h,031h,032h,08eh,0e4h,092h,091h	; 8e97  ...... ........+"#...,.12....
	defb 000h,098h,08eh	; 8eb4
	defb 0fch,001h,008h,0ebh,018h,00dh,020h,0f0h,008h,008h,080h,01eh,0e0h,004h,004h,000h,0f3h,010h,025h,026h,014h,03eh,0f3h,033h,024h,0e2h,020h,000h	; 8eb7  ...... ...........%&.>.3$. .
	defb 000h,0b8h,08eh	; 8ed3
	defb 0fdh,003h,080h,080h,080h,080h,002h,006h,0e3h,036h,037h,000h,0f6h,038h	; 8ed6  .........67..8
	defb 0fdh,0d7h,08eh	; 8ee4

; ======================================================================
; CODIGO 0x8ee7..0x8eea  (3 bytes)
; ======================================================================


L_8EE7:
	jp decide_que_hace_el_enemigo		;8ee7   ; Lo de siempre

; ----------------------------------------------------------------------
; DATOS reacciones_del_escenario_7: 7 entradas, desde 0x7FDB[7]; detras sigue
;   0x8EF8
;   0x8eea..0x8ef8  (14 bytes)
DATA_reacciones_del_escenario_7:
	defw 08000h,08ef8h,08ef8h,08ef8h,08f51h,08f51h,08f6ah	; 8eea

; ======================================================================
; CODIGO 0x8ef8..0x8efe  (6 bytes)
; ======================================================================


L_8EF8:
	call pon_la_subescena		;8ef8   ; Poner la subescena
	call reparte_por_tabla		;8efb   ; Y a ella

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_8efe: 6 entradas, tras el `call reparte_por_tabla`
;   de 0x8EFB; detras sigue la primera, 0x8F0A
;   0x8efe..0x8f0a  (12 bytes)
DATA_tabla_de_subescenas_8efe:
	defw 08f0ah,08f28h,08f31h,08f49h,08f0ah,08f3ah	; 8efe

; ======================================================================
; CODIGO 0x8f0a..0x8f74  (106 bytes)
; ======================================================================


L_8F0A:
	call cuenta_atras		;8f0a   ; La espera
	ret nz			;8f0d   ; Todavia no
	call dos_bits_del_cuadro		;8f0e   ; Dos bits del cuadro
	jr z,L_8F1C		;8f11   ; A cero: golpear
	dec a			;8f13
	jr z,L_8F19		;8f14   ; A uno: la orden 4
	dec a			;8f16
	jr z,L_8F1C		;8f17   ; A dos: golpear tambien
L_8F19:
	jp L_80AF		;8f19   ; Orden 4
L_8F1C:
	ld a,006h		;8f1c   ; Seis cuadros de espera
	ld (0e154h),a		;8f1e
	xor a			;8f21   ; El golpe 0
	ld (0e135h),a		;8f22
	jp pon_el_tipo_de_golpe		;8f25   ; Y a arrancarlo
L_8F28:
	call saca_dos_bits_del_azar		;8f28   ; Dos bits del registro
	and a			;8f2b   ; A cero: esperar
	jr z,L_8F0A		;8f2c
L_8F2E:
	jp L_8081		;8f2e   ; Orden 3
L_8F31:
	call saca_dos_bits_del_azar		;8f31   ; Dos bits del registro
	and a			;8f34
	jr z,L_8F2E		;8f35
	jp L_80B3		;8f37   ; Y si no, la orden 6
L_8F3A:
	call saca_dos_bits_del_azar		;8f3a   ; Dos bits del registro
	dec a			;8f3d
	jr z,L_8F45		;8f3e
	dec a			;8f40
	jr z,L_8F45		;8f41
	jr L_8F2E		;8f43   ; Y si no, la orden 3
L_8F45:
	xor a			;8f45   ; El golpe 0, arrancado
	jp L_80BB		;8f46
L_8F49:
	call saca_dos_bits_del_azar		;8f49   ; Dos bits del registro
	and a			;8f4c
	jr z,L_8F45		;8f4d
	jr L_8F2E		;8f4f   ; Y si no, la orden 3
L_8F51:
	ld hl,0e159h		;8f51   ; La espera
	dec (hl)			;8f54
	ret nz			;8f55   ; Todavia dura
	ld b,008h		;8f56   ; Ocho cuadros
	ld a,(0e102h)		;8f58   ; La barra del jugador...
	cp 012h		;8f5b
	jr nc,L_8F61		;8f5d   ; ...si va baja, solo cuatro
	ld b,004h		;8f5f
L_8F61:
	ld a,b			;8f61
	ld (hl),a			;8f62   ; Ahi va la espera
	xor a			;8f63
	ld (0e135h),a		;8f64   ; El golpe 0
	jp pon_el_tipo_de_golpe		;8f67   ; Y a arrancarlo
L_8F6A:
	ld a,(0e003h)		;8f6a   ; El contador de cuadros
	bit 6,a		;8f6d   ; Su bit 6 decide
	jr nz,L_8F51		;8f6f
	jp L_810F		;8f71   ; Y si no, el camino de siempre

; ----------------------------------------------------------------------
; DATOS fotogramas_del_enemigo_7: el enemigo del escenario 7, desde 0x6922[7].
;   Delante, 22 punteros que cierran la tabla justo en 0x8FA0; detras, 8
;   tramos (4 dibujos y 4 remisiones) que teselan el bloque sin un hueco ni un
;   solape; medidos con formatos.entrada_del_enemigo
;   0x8f74..0x901c  (168 bytes)
DATA_fotogramas_del_enemigo_7:
	defb 0a0h,08fh,0bbh,08fh,0a0h,08fh,0bbh,08fh,0a0h,08fh,0bbh,08fh,0beh,08fh,0dfh,08fh,0beh,08fh,0dfh,08fh,0beh,08fh,0dfh,08fh,0beh,08fh,0dfh,08fh,0beh,08fh,0dfh,08fh,0beh,08fh,0dfh,08fh,0e2h,08fh,0fah,08fh,0fdh,08fh,019h,090h	; 8f74  ............................................
	defb 0ffh,000h,000h,0feh,028h,00ch,080h,080h,080h,005h,004h,0f3h,010h,001h,0f3h,013h,001h,016h,00fh,017h,001h,018h,00fh,019h,001h,0f4h,01ah	; 8fa0  ....(......................
	defb 0fdh,0a1h,08fh	; 8fbb
	defb 0fdh,000h,000h,0f6h,028h,00ch,080h,080h,080h,005h,005h,01eh,01fh,011h,012h,001h,0f3h,020h,015h,001h,023h,024h,00fh,017h,001h,001h,018h,00fh,019h,001h,001h,0f4h,01ah	; 8fbe  ....(............ ..#$...........
	defb 0feh,0bfh,08fh	; 8fdf
	defb 0feh,002h,010h,0fch,018h,010h,080h,080h,080h,003h,005h,001h,0f3h,010h,001h,025h,0f3h,013h,09dh,026h,027h,00fh,017h,09eh	; 8fe2  ...............%...&'...
	defb 0fdh,0e3h,08fh	; 8ffa
	defb 0fdh,002h,080h,080h,080h,080h,003h,007h,001h,001h,028h,001h,0a0h,001h,001h,001h,001h,029h,02ah,0a1h,001h,001h,0f3h,02bh,00fh,0a5h,0a4h,0a3h	; 8ffd  ..........(......)*....+....
	defb 0fch,0feh,08fh	; 9019

; ======================================================================
; CODIGO 0x901c..0x9154  (312 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ======================================================================
; QUIEN SALE Y CUANDO
; ======================================================================
; Baja por las tres tablas encadenadas de 0x9276 -ronda, tanda y paso-
; y saca una pareja: que sale y cuanto hay que esperar. Luego busca
; hueco en las seis ranuras de 0xE200 y lo mete ahi.
; ----------------------------------------------------------------------
decide_el_siguiente:
	ld a,(0e1a0h)		;901c   ; Hay uno a medio salir?
	and a			;901f
	jp nz,mete_al_que_toque		;9020
	ld a,(0e1a1h)		;9023   ; Todavia queda espera?
	and a			;9026
	jp nz,L_9135		;9027
	ld hl,09276h		;902a   ; La tabla de las rondas
	ld a,(0e066h)		;902d   ; La ronda...
	call lee_la_entrada_de_la_tabla		;9030   ; ...da la tanda
	ex de,hl			;9033
	ld a,(0e061h)		;9034   ; Y (0xE061), la tira de parejas
	call lee_la_entrada_de_la_tabla		;9037
	ld hl,0e10ah		;903a   ; El paso dentro de la tira
	ld a,(hl)			;903d
	add a,a			;903e   ; Las parejas ocupan dos bytes
	call suma_a_a_de		;903f
	ld a,(de)			;9042   ; El primer byte: lo que sale
	ld (0e1a3h),a		;9043
	push af			;9046
	push hl			;9047
	push de			;9048
	ld a,(0e06ah)		;9049   ; Cuantos jugadores hay
	and a			;904c
	ld de,00306h		;904d   ; Uno: los cortes son 3 y 6
	jr z,elige_el_ritmo		;9050
	dec a			;9052
	ld de,00105h		;9053   ; Dos: 1 y 5
	jr z,elige_el_ritmo		;9056
	ld de,00104h		;9058   ; Y si no, 1 y 4
elige_el_ritmo:
	ld a,(0e061h)		;905b   ; Por que tanda va la cosa
	cp d			;905e   ; Antes del primer corte: lo suave
	ld b,000h		;905f
	ld c,007h		;9061
	ld h,070h		;9063
	jr c,apunta_el_ritmo		;9065
	cp e			;9067   ; Antes del segundo: lo de en medio
	ld b,004h		;9068
	ld c,005h		;906a
	ld h,080h		;906c
	jr c,apunta_el_ritmo		;906e
	ld b,008h		;9070   ; Y del segundo en adelante, lo bravo
	ld c,004h		;9072
	ld h,0a0h		;9074
apunta_el_ritmo:
	ld a,c			;9076
	ld (0e1a9h),a		;9077   ; Lo que aguanta
	ld a,h			;907a
	ld (0e1aah),a		;907b   ; Y lo que corre
	pop de			;907e
	pop hl			;907f
	inc (hl)			;9080   ; Un paso mas en la tira
	ld a,(hl)			;9081
	cp 008h		;9082   ; A los ocho pasos se agota
	jr c,apunta_la_espera		;9084
	xor a			;9086   ; Vuelta a empezar la tira...
	ld (hl),a			;9087
	ld hl,0e061h		;9088   ; ...y a la tanda siguiente
	inc (hl)			;908b
	ld a,(hl)			;908c
	cp 008h		;908d   ; Pasada la octava tanda...
	jr c,apunta_la_espera		;908f
	ld a,006h		;9091   ; ...se queda en la sexta: la coreografia no acaba nunca
	ld (hl),a			;9093
apunta_la_espera:
	inc de			;9094   ; El segundo byte de la pareja
	ld a,(de)			;9095
	cp 010h		;9096   ; Los valores altos llevan descuento
	jr c,L_909B		;9098
	sub b			;909a   ; ...el del ritmo de esta tanda
L_909B:
	ld (0e1a1h),a		;909b   ; La cuenta atras hasta el siguiente
	pop af			;909e   ; Recuperar lo que sale
	bit 3,a		;909f   ; El bit 3 marca a los que salen de dos en dos
	jr z,L_90B0		;90a1
	ld hl,0e1a7h		;90a3   ; Alternar el lado por el que asoma
	ld a,(hl)			;90a6
	xor 001h		;90a7
	ld (hl),a			;90a9
	inc a			;90aa
	ld b,a			;90ab
	ld a,003h		;90ac   ; Tres cuadros de aviso
	jr apunta_el_aviso		;90ae
L_90B0:
	ld a,001h		;90b0   ; Los normales, uno solo
	ld b,000h		;90b2
apunta_el_aviso:
	ld (0e1a0h),a		;90b4   ; Lo que falta para que aparezca
	ld a,b			;90b7
	ld (0e1a8h),a		;90b8   ; Y por que lado
	and a			;90bb   ; Si no viene por ningun lado, nada mas
	jr z,mete_al_que_toque		;90bc
	ld hl,0e1a4h		;90be
	call suma_a_a_hl		;90c1   ; Poner a cero la espera de ese lado
	xor a			;90c4
	ld (hl),a			;90c5
mete_al_que_toque:
	ld hl,0e1a4h		;90c6
	ld a,(hl)			;90c9   ; Todavia no le toca
	and a			;90ca
	jr nz,L_9134		;90cb
	ld hl,0e1a0h		;90cd
	dec (hl)			;90d0   ; Un cuadro menos de aviso
	ld hl,0e200h		;90d1   ; Las seis ranuras de enemigo
	ld b,006h		;90d4
L_90D6:
	ld a,(hl)			;90d6   ; Esta ocupada?
	and a			;90d7
	jr z,ocupa_la_ranura		;90d8
	ld de,0000ch		;90da   ; Cada ranura son doce bytes
	add hl,de			;90dd
	djnz L_90D6		;90de
	xor a			;90e0   ; No cabe ninguno mas
	ld (0e1a4h),a		;90e1
	jr L_9139		;90e4
ocupa_la_ranura:
	ld a,001h		;90e6   ; Marcarla como usada
	ld (hl),a			;90e8
	ld de,0e1a3h		;90e9
	ld a,(de)			;90ec   ; Lo que sale
	bit 3,a		;90ed   ; El bit 3 otra vez: los de dos en dos...
	ld a,(0e1a9h)		;90ef   ; ...esperan lo que diga el ritmo
	jr nz,L_90F5		;90f2
	xor a			;90f4   ; Los demas no esperan nada
L_90F5:
	ld (0e1a4h),a		;90f5
	ld a,(de)			;90f8   ; El bit 2 dice por que lado entra
	bit 2,a		;90f9
	ld a,0feh		;90fb   ; Por la derecha: 0xFE
	ld b,000h		;90fd
	jr nz,L_9104		;90ff
	ld a,022h		;9101   ; Por la izquierda: 0x22
	inc b			;9103
L_9104:
	inc hl			;9104
	inc hl			;9105
	ld (hl),a			;9106   ; La columna de entrada
	inc hl			;9107
	ld (hl),b			;9108   ; Y el sentido en el que anda
	ld a,(de)			;9109   ; Los dos bits bajos...
	and 003h		;910a
	push af			;910c
	ld de,0926eh		;910d   ; ...eligen el campo 1
	call suma_a_a_de		;9110
	ld a,(de)			;9113
	dec hl			;9114
	dec hl			;9115
	ld (hl),a			;9116
	pop af			;9117
	ld de,09272h		;9118
	call suma_a_a_de		;911b
	ld a,(de)			;911e
	inc hl			;911f
	inc hl			;9120
	inc hl			;9121
	inc hl			;9122
	ld (hl),a			;9123
	xor a			;9124
	inc hl			;9125
	inc hl			;9126
	ld (hl),a			;9127
	inc hl			;9128
	inc hl			;9129
	inc hl			;912a
	ld a,(0e1a8h)		;912b
	ld (hl),a			;912e
	xor a			;912f
	inc hl			;9130
	ld (hl),a			;9131
	jr L_9135		;9132
L_9134:
	dec (hl)			;9134
L_9135:
	ld hl,0e1a1h		;9135
	dec (hl)			;9138
L_9139:
	ld ix,0e200h		;9139
	ld b,005h		;913d

; ----------------------------------------------------------------------
; ---------------------------------------------------------------------
; Mover las seis ranuras de la oleada. Cada una son doce bytes y su
; primer byte es la escena, que reparte por la tabla de 0x9154.
; ----------------------------------------------------------------------
mueve_las_seis_ranuras:
	push bc			;913f
	call reparte_la_escena_de_la_ranura		;9140   ; Mover esta
	ld de,0000ch		;9143   ; Doce bytes por ranura
	add ix,de		;9146
	pop bc			;9148
	djnz mueve_las_seis_ranuras		;9149   ; Las seis
reparte_la_escena_de_la_ranura:
	ld a,(ix+000h)		;914b   ; La escena de esta
	and a			;914e
	ret z			;914f   ; Vacia
	dec a			;9150
	call reparte_por_tabla		;9151   ; Y a la que sea

; ----------------------------------------------------------------------
; DATOS tabla_de_subescenas_9154: 3 entradas, tras el `call reparte_por_tabla`
;   de 0x9151; detras sigue la primera, 0x915A
;   0x9154..0x915a  (6 bytes)
DATA_tabla_de_subescenas_9154:
	defw 0915ah,0917bh,09189h	; 9154  -> L_915A L_917B L_9189

; ======================================================================
; CODIGO 0x915a..0x9206  (172 bytes)
; ======================================================================


L_915A:
	ld a,(0e110h)		;915a
	cp 005h		;915d
	jr nz,L_9166		;915f
	ld a,080h		;9161
	ld (ix+002h),a		;9163
L_9166:
	ld a,(ix+005h)		;9166   ; La subescena
	dec a			;9169
	jp z,borra_el_paso_y_corre_la_columna		;916a   ; A uno: caer
	dec a			;916d
	jp z,L_9212		;916e   ; A dos: andar
	call baja_por_la_curva		;9171   ; Y si no, bajar por la curva
	ret nz			;9174   ; Todavia baja
	ld a,014h		;9175   ; Ya abajo: fotograma 0x14
	ld (ix+001h),a		;9177
	ret			;917a
L_917B:
	ld a,003h		;917b   ; Fotograma 3
	ld (ix+004h),a		;917d
	ld a,004h		;9180   ; Cuatro cuadros
	ld (ix+008h),a		;9182
	inc (ix+000h)		;9185   ; Y una escena mas
	ret			;9188
L_9189:
	dec (ix+008h)		;9189   ; Un cuadro menos
	ld a,(ix+008h)		;918c
	and a			;918f
	ret nz			;9190   ; Todavia dura
	ld a,080h		;9191   ; Se acabo: aparcar el sprite...
	ld (ix+002h),a		;9193
	xor a			;9196
	ld (ix+000h),a		;9197   ; ...y vaciar la ranura
	ret			;919a
corre_la_columna_hacia_su_lado:
	ld a,(ix+003h)		;919b   ; Hacia que lado va
	and a			;919e
	ld a,(0e1aah)		;919f   ; Lo que corre
	ld b,a			;91a2
	ld a,(ix+00bh)		;91a3   ; La parte de abajo de la columna
	jr z,L_91BA		;91a6
	sub b			;91a8   ; A la izquierda: restar...
	ld (ix+00bh),a		;91a9
	jr nc,L_91B1		;91ac
	dec (ix+002h)		;91ae   ; ...con el acarreo a la parte de arriba
L_91B1:
	ld a,(ix+002h)		;91b1   ; La columna entera
	cp 080h		;91b4
	jr nc,L_91CE		;91b6
	jr L_91D5		;91b8
L_91BA:
	add a,b			;91ba
	ld (ix+00bh),a		;91bb
	jr nc,L_91C3		;91be
	inc (ix+002h)		;91c0
L_91C3:
	ld a,(ix+002h)		;91c3
	cp 080h		;91c6
	jr nc,L_91D5		;91c8
	cp 021h		;91ca
	jr c,L_91D5		;91cc
L_91CE:
	xor a			;91ce
	ld (ix+000h),a		;91cf
	and 000h		;91d2
	ret			;91d4
L_91D5:
	or 001h		;91d5
	ret			;91d7
borra_el_paso_y_corre_la_columna:
	xor a			;91d8
	ld (ix+004h),a		;91d9
	jp corre_la_columna_hacia_su_lado		;91dc
baja_por_la_curva:
	call borra_el_paso_y_corre_la_columna		;91df   ; Bajar por la curva
	ld a,(0e003h)		;91e2   ; Uno de cada dos cuadros
	and 002h		;91e5
	ret nz			;91e7
	ld a,(ix+007h)		;91e8   ; Por que paso va
	inc (ix+007h)		;91eb   ; Uno mas
	ld hl,09206h		;91ee   ; La curva
	call suma_a_a_hl		;91f1
	ld a,(hl)			;91f4
	cp 0a0h		;91f5   ; El 0xA0 la cierra
	jr z,L_9201		;91f7
	ld a,(ix+001h)		;91f9   ; Y su valor se suma a la fila
	add a,(hl)			;91fc
	ld (ix+001h),a		;91fd
	ret			;9200
L_9201:
	xor a			;9201
	ld (ix+007h),a		;9202
	ret			;9205

; ----------------------------------------------------------------------
; DATOS la_curva_del_enemigo: la misma idea en once bytes y el 0xA0: 0xFF,
;   0x00 y 0x01. 0x91EE entra con (ix+7), que va incrementando
;   0x9206..0x9212  (12 bytes)
DATA_la_curva_del_enemigo:
	defb 0ffh,0ffh,000h,0ffh,000h,000h,000h,001h,000h,001h,001h,0a0h	; 9206  ............

; ======================================================================
; CODIGO 0x9212..0x926e  (92 bytes)
; ======================================================================


L_9212:
	call corre_la_columna_hacia_su_lado		;9212   ; Andar
	ld a,(0e003h)		;9215   ; Uno de cada dos cuadros
	and 002h		;9218
	ret nz			;921a
	ld a,(ix+004h)		;921b   ; El fotograma
	cp 001h		;921e   ; Alterna entre 1...
	jr nz,L_9225		;9220
	inc a			;9222
	jr L_9227		;9223
L_9225:
	ld a,001h		;9225   ; ...y 2: las dos piernas
L_9227:
	ld (ix+004h),a		;9227
	ret			;922a
limpia_la_ultima_banda_y_repasa_las_ranuras:
	ld hl,03a00h		;922b   ; La ultima banda de la pantalla...
	ld c,0a0h		;922e   ; ...0xA0 casillas...
	xor a			;9230
	call rellena_c_bytes_con_filvrm		;9231   ; ...a cero
	ld hl,0e200h		;9234   ; Las seis ranuras
	ld b,005h		;9237
L_9239:
	push bc			;9239
	push hl			;923a
	call pinta_la_figura_de_la_ranura		;923b   ; Pintar esta
	ld de,0000ch		;923e   ; Doce bytes por ranura
	pop hl			;9241
	add hl,de			;9242
	pop bc			;9243
	djnz L_9239		;9244
pinta_la_figura_de_la_ranura:
	ld a,(hl)			;9246   ; Esta ocupada?
	and a			;9247
	ret z			;9248
	inc hl			;9249
	inc hl			;924a
	inc hl			;924b
	inc hl			;924c
	ld a,(hl)			;924d   ; El fotograma...
	add a,a			;924e   ; ...por dos
	ld b,a			;924f
	dec hl			;9250
	ld a,(hl)			;9251   ; Y el lado suma uno
	and a			;9252
	jr z,L_9256		;9253
	inc b			;9255
L_9256:
	ld a,b			;9256
	push hl			;9257
	ld hl,093a6h		;9258   ; La tabla de figuras
	call lee_la_entrada_de_la_tabla		;925b
	pop hl			;925e
	dec hl			;925f
	dec hl			;9260
	ld c,(hl)			;9261   ; La fila, que es lo que C lleva a 0xE170...
	ld a,(de)			;9262   ; ...mas el ajuste de la figura...
	inc hl			;9263
	add a,(hl)			;9264   ; ...y la columna, que B lleva a 0xE171
	ld b,a			;9265
	ld (0e170h),bc		;9266
	inc de			;926a
	jp pinta_figura_sin_sprites		;926b

; ----------------------------------------------------------------------
; DATOS valores_del_campo_1: cuatro, indexados por los dos bits bajos de
;   (0xE1A3); 0x910D los mete en el campo 1 de la ranura del enemigo
;   0x926e..0x9272  (4 bytes)
DATA_valores_del_campo_1:
	defb 011h,013h,014h,014h	; 926e

; ----------------------------------------------------------------------
; DATOS valores_del_campo_4: los otros cuatro, mismo indice, desde 0x9118
;   0x9272..0x9276  (4 bytes)
DATA_valores_del_campo_4:
	defb 001h,001h,002h,003h	; 9272

; ----------------------------------------------------------------------
; DATOS tabla_de_las_rondas: ocho punteros a las ocho tiras de 0x9286; los
;   carga 0x902A con (0xE066)
;   0x9276..0x9286  (16 bytes)
DATA_tabla_de_las_rondas:
	defw 09286h,09296h,092a6h,092b6h,092c6h,092d6h,092e6h,092f6h	; 9276

; ----------------------------------------------------------------------
; DATOS tiras_de_la_ronda: ocho tiras contiguas de ocho punteros; 0x9037 elige
;   con (0xE061) la tira de parejas que toca
;   0x9286..0x9306  (128 bytes)
DATA_tiras_de_la_ronda:
	defw 09306h,09306h,09306h,09316h,09326h,09346h,09316h,09376h	; 9286
	defw 09316h,09336h,09336h,09346h,09316h,09356h,09366h,09376h	; 9296
	defw 09336h,09366h,09326h,09376h,09346h,09306h,09366h,09376h	; 92a6
	defw 09366h,09336h,09366h,09306h,09386h,09356h,09316h,09356h	; 92b6
	defw 09376h,09366h,09336h,09376h,09366h,09386h,09396h,09386h	; 92c6
	defw 09356h,09376h,09396h,09386h,09316h,09366h,09396h,09346h	; 92d6
	defw 09396h,09386h,09376h,09396h,09356h,09366h,09386h,09396h	; 92e6
	defw 09376h,09396h,09366h,09336h,09396h,09386h,09326h,09386h	; 92f6

; ----------------------------------------------------------------------
; DATOS parejas_de_lo_que_sale: diez tiras de ocho parejas (que sale, cuanto
;   se espera); 0x903F entra con (0xE10A)
;   0x9306..0x93a6  (160 bytes)
DATA_parejas_de_lo_que_sale:
	defb 005h,030h,005h,030h,004h,030h,005h,050h,004h,030h,006h,030h,00ch,030h,005h,090h	; 9306  .0.0.0.P.0.0.0..
	defb 004h,02dh,006h,02dh,005h,02dh,00dh,050h,00eh,02dh,006h,02dh,004h,02dh,004h,090h	; 9316  .-.-.-.P.-.-.-..
	defb 005h,027h,00eh,027h,000h,027h,006h,030h,006h,027h,004h,027h,002h,027h,00dh,090h	; 9326  .'.'.'.0.'.'.'..
	defb 005h,023h,000h,023h,00dh,023h,000h,030h,000h,023h,001h,023h,002h,023h,007h,090h	; 9336  .#.#.#.0.#.#.#..
	defb 006h,020h,004h,020h,00ah,020h,000h,030h,008h,028h,005h,023h,00fh,020h,005h,090h	; 9346  . . . .0.(.#. ..
	defb 004h,00ah,005h,00ah,006h,020h,00fh,048h,002h,010h,001h,00ah,000h,020h,00bh,090h	; 9356  ..... .H..... ..
	defb 004h,010h,001h,010h,004h,010h,002h,030h,001h,010h,004h,010h,002h,010h,004h,090h	; 9366  .......0........
	defb 004h,010h,009h,020h,004h,020h,002h,030h,005h,006h,004h,006h,006h,006h,004h,090h	; 9376  ... . .0........
	defb 005h,038h,00bh,018h,003h,010h,003h,030h,000h,018h,00eh,040h,000h,018h,00dh,090h	; 9386  .8.....0...@....
	defb 007h,010h,003h,030h,002h,00ah,004h,00ah,002h,00ah,004h,010h,004h,018h,007h,090h	; 9396  ...0............

; ----------------------------------------------------------------------
; DATOS tabla_de_figuras_del_enemigo: ocho punteros que 0x9258 carga con
;   2*(campo 4) + (1 si el campo 3 no es cero); la ultima figura sale dos
;   veces
;   0x93a6..0x93b6  (16 bytes)
DATA_tabla_de_figuras_del_enemigo:
	defw 093b6h,093beh,093c7h,093cch,093d3h,093d8h,093dfh,093dfh	; 93a6

; ----------------------------------------------------------------------
; DATOS figuras_del_enemigo: siete figuras de casillas, y cierran al byte en
;   0x93E4. Delante de cada una hay un byte que NO es del formato: 0x9262 lo
;   suma a la fila antes de pintar, o sea es un ajuste con signo (0xFF = una
;   fila arriba, 0xFE = dos); 7 figura(s), medidas con tools/formatos.py
;   0x93b6..0x93e4  (46 bytes)
DATA_figuras_del_enemigo:
	defb 0ffh,002h,003h,010h,011h,000h,0f3h,012h	; 93b6  ........
	defb 0feh,002h,003h,000h,089h,088h,08ch,08bh,08ah	; 93be  .........
	defb 0ffh,002h,002h,0f4h,015h	; 93c7
	defb 0ffh,002h,002h,08eh,08dh,090h,08fh	; 93cc
	defb 0ffh,002h,002h,0f4h,019h	; 93d3
	defb 0ffh,002h,002h,092h,091h,094h,093h	; 93d8
	defb 0ffh,002h,002h,0f4h,01dh	; 93df

; ----------------------------------------------------------------------
; DATOS guiones_del_decorado: cuatro guiones RLE que 0x5982..0x59A5 vuelca en
;   0x21F0, 0x2480, 0x01F0 y 0x0480: patrones y colores del decorado; 4
;   guion(es), medidos con tools/formatos.py
;   0x93e4..0x94c3  (223 bytes)
DATA_guiones_del_decorado:
	defb 082h,03ch,042h,004h,081h,084h,042h,03ch,03ch,07eh,004h,0ffh,08ch,07eh,03ch,000h,067h,06eh,07ch,07ch,06eh,067h,000h,000h,03eh,004h,063h,083h,03eh,000h,001h,005h,003h,083h,001h,000h,0ffh,005h,000h,083h,0ffh,000h,0ffh,005h,0c0h,083h,0ffh,000h,0ffh,005h,0f0h,083h,0ffh,000h,0ffh,005h,0fch,082h,0ffh,000h,007h,0ffh,082h,000h,0ffh,005h,0c0h,083h,0ffh,000h,0ffh,005h,0f0h,083h,0ffh,000h,0ffh,005h,0fch,082h,0ffh,000h,007h,0ffh,081h,000h,000h	; 93e4  .<B...B<<~...~<.gn||ng..>.c.>..........................................................
	defb 008h,0f0h,008h,080h,010h,0f6h,011h,0f0h,005h,060h,003h,0f0h,005h,060h,003h,0f0h,005h,060h,003h,0f0h,005h,060h,003h,0f0h,005h,050h,003h,0f0h,005h,050h,003h,0f0h,005h,050h,003h,0f0h,005h,050h,002h,0f0h,000h	; 943b  .........`...`...`...`...P...P...P...P...
	defb 083h,007h,01fh,03fh,003h,07fh,084h,0ffh,0fch,0f0h,0fch,006h,0ffh,004h,000h,081h,080h,003h,0c0h,090h,0f0h,0e3h,040h,040h,0bch,0fch,0ffh,03fh,0ceh,09ch,000h,000h,0cfh,0cfh,0ffh,0dfh,003h,0c0h,002h,040h,002h,0c0h,003h,000h,084h,001h,007h,01fh,01fh,003h,03fh,097h,01fh,0deh,0efh,0f7h,0fbh,0fch,0ffh,0efh,0ceh,0deh,01dh,0fbh,0f7h,00fh,0ffh,000h,000h,080h,0e0h,0f0h,0f0h,0f8h,0f8h,000h	; 9464  ...?..................@@...?...........@..........?.........................
	defb 007h,060h,081h,06bh,010h,060h,004h,06bh,004h,0b0h,004h,06bh,004h,0b0h,003h,060h,025h,0b0h,000h	; 94b0  .`.k.`.k...k...`%..

; ----------------------------------------------------------------------
; DATOS guiones_de_los_suelos: los dieciseis guiones de las dos tablas de
;   0x592F y 0x593F: ocho suelos, cada uno en patrones y en color. Emparejados
;   como los ordenan las tablas, los dos de cada pareja vuelcan lo mismo -752,
;   368, 528, 489, 552, 376, 368 y 240 bytes-, y eso es lo que los cierra, no
;   que la cadena termine donde termina; 16 guion(es), medidos con
;   tools/formatos.py
;   0x94c3..0xa48e  (4043 bytes)
DATA_guiones_de_los_suelos:
	defb 005h,000h,093h,001h,003h,007h,007h,00fh,017h,01ah,03fh,03ah,017h,00dh,0c0h,0e0h,070h,0f0h,0f8h,0f8h,070h,0e0h,004h,000h,084h,0c0h,0f0h,0fch,0feh,004h,000h,088h,007h,009h,003h,000h,007h,009h,01eh,07fh,003h,0ffh,08bh,07fh,0f8h,0ffh,0fch,0e3h,06fh,06bh,06fh,06bh,07fh,03fh,003h,0ffh,08fh,0f7h,0ffh,0f7h,0f9h,0f7h,0eeh,0ddh,0dfh,0dfh,0efh,0efh,000h,080h,000h,0c0h,004h,0e0h,081h,03eh,003h,000h,095h,001h,003h,007h,007h,06fh,075h,037h,06dh,0efh,0dbh,0bfh,0b7h,0ffh,0f7h,0ffh,0f7h,0ffh,0efh,0ffh,0dfh,0f3h,004h,0fch,083h,0f8h,0c0h,0b0h,005h,00fh,083h,007h,00fh,03fh,007h,07fh,081h,000h,007h,0ffh,08ah,000h,0f8h,0fch,0fch,0feh,0feh,0ffh,0f0h,03fh,03eh,007h,000h,091h,06fh,06dh,02fh,01bh,07fh,0f7h,0dfh,0ffh,0ffh,0f7h,0ffh,0f7h,0ffh,0efh,0bfh,0ffh,0f3h,005h,0fch,002h,0f8h,088h,0ffh,0f7h,06fh,02fh,00fh,00fh,003h,00fh,006h,0ffh,086h,03fh,0cch,0f0h,0e0h,0c0h,0c0h,003h,080h,095h,000h,007h,00bh,01ah,07ah,0fch,0fdh,0fdh,07bh,0f8h,0fch,003h,0ffh,0ffh,0beh,0ffh,07dh,07fh,03fh,0ffh,0feh,004h,0fdh,084h,0e0h,090h,078h,0feh,003h,0ffh,081h,0feh,004h,000h,0c6h,001h,003h,007h,007h,03bh,007h,017h,077h,0efh,0dfh,0bfh,0bfh,0ffh,07dh,0ffh,0fbh,0ffh,0f7h,0ffh,0efh,0ffh,0ffh,0feh,0feh,0fch,0fch,0c8h,0b0h,000h,000h,007h,00fh,01fh,007h,003h,007h,000h,000h,0c0h,0e0h,0f0h,0f0h,0f8h,0f8h,0e8h,0e4h,0f0h,0fch,060h,06dh,06fh,06dh,04fh,08fh,01fh,07fh,0ffh,0f7h,0ffh,0f7h,010h,00fh,01fh,01fh,03fh,03fh,01eh,0feh,037h,0cfh,005h,0ffh,094h,07fh,0ffh,0efh,0ffh,0efh,0ffh,0fbh,0ffh,0ffh,0f3h,0f0h,0efh,0f7h,0f7h,0ffh,0ffh,0fch,0c0h,000h,080h,004h,0c0h,081h,080h,006h,000h,082h,01fh,07fh,003h,000h,085h,010h,030h,030h,070h,0f8h,004h,000h,091h,0c0h,0fch,0f3h,0efh,000h,003h,007h,008h,007h,03fh,0bfh,07fh,001h,0feh,0ffh,001h,0feh,003h,0ffh,090h,0feh,03fh,0dfh,0ffh,03fh,0c1h,0deh,0dfh,000h,000h,080h,080h,0c0h,0c0h,000h,0e0h,008h,000h,0aah,0feh,07eh,07dh,03dh,00dh,0eeh,0ffh,0ddh,0ffh,0ffh,0f8h,0f0h,0e0h,0f8h,0fch,0f8h,0ffh,0ffh,03fh,01fh,00fh,00fh,007h,007h,0dfh,0efh,0efh,0f7h,0fbh,0fch,0fbh,0f7h,0f8h,0f8h,0fch,0f0h,0c0h,000h,0c0h,080h,005h,00eh,003h,00fh,087h,007h,00fh,03fh,0e8h,0e4h,0f0h,0fch,003h,0ffh,08eh,000h,04fh,08fh,01fh,07fh,0ffh,0feh,080h,000h,0cfh,03fh,0feh,0f8h,0e0h,009h,000h,08ah,0fch,03ch,03ch,07eh,07eh,07fh,0bfh,0beh,0dfh,0efh,005h,000h,097h,042h,0bdh,0c3h,000h,000h,03ch,04eh,00eh,01fh,01fh,00fh,0f7h,0f9h,0feh,0ffh,0ffh,07fh,07fh,0bfh,0ffh,0ffh,07eh,081h,004h,0ffh,005h,000h,083h,077h,0ffh,0bbh,003h,000h,085h,002h,03ah,07eh,0fch,070h,004h,000h,084h,00ch,00fh,007h,003h,005h,000h,083h,074h,0fbh,0fdh,005h,000h,093h,001h,007h,0e0h,007h,00fh,01bh,017h,0ffh,07fh,0bfh,07fh,0c0h,0e0h,0f0h,0f0h,0fch,0feh,0ffh,0ffh,006h,000h,002h,080h,088h,0fdh,07dh,07dh,03eh,03eh,01fh,02fh,023h,005h,0ffh,086h,07fh,0bfh,0cfh,01fh,0efh,0f7h,00bh,0ffh,002h,0feh,081h,080h,003h,0c0h,004h,0e0h,098h,020h,030h,010h,018h,00ch,006h,003h,001h,073h,03ch,01fh,00fh,003h,000h,000h,0c0h,0ffh,0ffh,01fh,0e3h,0fch,0ffh,07fh,01fh,004h,0ffh,090h,03fh,0cfh,0f3h,0fch,040h,040h,080h,080h,0c0h,0c0h,0e0h,0e0h,070h,01ch,007h,001h,004h,000h,098h,007h,000h,000h,0e0h,03eh,003h,000h,000h,0ffh,0ffh,01fh,01fh,00fh,0f3h,00ch,000h,070h,0b0h,0b0h,0d0h,0d0h,0e0h,0f0h,0fch,007h,000h,083h,01fh,000h,000h,003h,001h,003h,000h,081h,007h,003h,01fh,002h,00fh,08ah,007h,003h,000h,0deh,0bdh,0fdh,0fbh,0fbh,0f8h,007h,004h,000h,088h,003h,00fh,01fh,02fh,008h,00fh,007h,003h,004h,000h,088h,077h,0f7h,0fbh,0fdh,07eh,03ch,000h,000h,000h	; 94c3  ..........?:....p...p...........................okok.?.....................>.......ou7m........................?...............?>...om/.....................o/.......?............z...{.......}.?.......x............;..w.....}..................................`momO...........??..7.....................................00p.............?...........?..?...............~}=..............?............................?........O........?.......<<~~........B....<N..............~......w......:~.p..........t..............................}}>>./#.................... 0......s<.................?...@@......p..........>...........p......................................../.......w...~<...
	defb 008h,050h,004h,0b0h,004h,0b5h,004h,0b0h,004h,0b5h,008h,050h,008h,0b0h,008h,050h,081h,05bh,007h,050h,081h,05bh,013h,050h,003h,0b0h,027h,050h,002h,0f0h,016h,050h,082h,05fh,0f0h,026h,050h,002h,0f0h,006h,050h,082h,05fh,0f0h,010h,050h,081h,05bh,007h,050h,081h,05bh,02fh,050h,004h,0b0h,084h,0b5h,0b9h,0b8h,0b6h,004h,0b0h,004h,0b5h,004h,05bh,004h,050h,004h,05bh,00ah,050h,002h,0f0h,017h,050h,081h,05fh,004h,050h,004h,0f0h,008h,050h,007h,0f0h,036h,050h,083h,090h,080h,060h,005h,05bh,083h,09bh,08bh,06bh,008h,05bh,008h,050h,003h,05bh,00bh,050h,002h,0f0h,002h,05bh,082h,00bh,05bh,004h,050h,002h,05bh,082h,00bh,05bh,00ch,050h,008h,0f0h,010h,050h,004h,0b0h,014h,050h,006h,090h,082h,080h,060h,005h,090h,002h,080h,081h,060h,008h,0f0h,010h,050h,004h,0b0h,004h,050h,004h,0b0h,07ah,050h,002h,0f0h,008h,050h,008h,0f0h,081h,050h,003h,05fh,014h,050h,008h,0f0h,008h,050h,000h	; 9764  .P.........P...P.[.P.[.P..'P...P._.&P...P._..P.[.P.[/P............[.P.[.P...P._.P...P..6P...`.[...k.[.P.[.P...[..[.P.[..[.P...P...P....`.....`...P...P..zP...P...P._.P...P.
	defb 006h,000h,082h,073h,099h,006h,000h,0ach,080h,0c0h,002h,007h,002h,001h,002h,001h,001h,003h,081h,07eh,0c7h,048h,0b6h,001h,021h,07ch,0c0h,0c0h,080h,0c0h,040h,080h,080h,0c0h,003h,007h,007h,00dh,00eh,00fh,00fh,007h,092h,046h,06dh,0abh,042h,085h,085h,005h,001h,001h,004h,003h,002h,007h,004h,00bh,086h,0ffh,080h,0d3h,093h,000h,040h,004h,060h,082h,0e0h,0f0h,007h,007h,0a3h,00fh,099h,098h,08ch,0cch,0c6h,0ffh,0ffh,07fh,0f0h,0f0h,0f8h,078h,03ch,0fch,0feh,0ffh,006h,006h,002h,002h,001h,001h,000h,001h,099h,098h,08ch,0cch,0c6h,0ffh,0e6h,0cch,000h,002h,004h,006h,083h,007h,002h,000h,004h,001h,002h,003h,081h,00fh,006h,000h,0a4h,003h,03fh,002h,007h,002h,001h,002h,001h,0e0h,0f0h,0c0h,0e0h,01fh,01fh,00fh,00fh,007h,000h,0f0h,0f0h,0f8h,0f8h,0fch,001h,000h,000h,0c0h,0e0h,0e0h,0bch,07eh,0efh,0f7h,078h,001h,001h,004h,003h,002h,007h,08ah,000h,0c5h,012h,054h,097h,0d3h,093h,093h,080h,0c0h,005h,0e0h,081h,0f0h,004h,000h,089h,007h,00fh,001h,000h,003h,007h,007h,00fh,0fch,003h,0ffh,002h,0feh,002h,0fch,002h,003h,002h,007h,093h,000h,0c5h,012h,054h,097h,0d3h,093h,0c8h,080h,0c0h,0e0h,0ech,0eeh,001h,001h,003h,003h,007h,00ch,008h,000h,088h,001h,007h,01fh,07fh,0f8h,003h,01fh,0ffh,003h,080h,092h,0c0h,0bfh,000h,0e3h,0edh,0f2h,0f4h,0f3h,0f9h,0fdh,0bfh,0dfh,05fh,06fh,037h,01bh,00ch,003h,004h,0fch,003h,0ffh,087h,01fh,000h,000h,00ch,007h,003h,001h,006h,000h,08eh,0c0h,078h,07fh,03fh,003h,007h,007h,00dh,00eh,00fh,007h,0ffh,00fh,003h,006h,000h,003h,0ffh,003h,07fh,002h,0bfh,005h,000h,0a3h,003h,00eh,03ch,000h,007h,01fh,07ch,0fbh,0f7h,00eh,01eh,0f8h,0f0h,0f0h,0f4h,0f3h,0f0h,0f8h,003h,08fh,0e0h,0c0h,080h,000h,080h,043h,0f0h,0c0h,0e0h,080h,060h,070h,078h,0feh,0ffh,000h	; 980f  ...s...............~.H..!|....@............Fm.B.................@.`..................x<.....................................?............................~..x..........T....................................T........................................._o7...................x.?.......................<...|..................C....`px...
	defb 007h,060h,081h,067h,008h,060h,003h,0f0h,082h,060h,0f0h,005h,060h,089h,06bh,07bh,0b0h,06bh,06bh,0b0h,060h,060h,0a0h,005h,060h,003h,020h,004h,0f0h,081h,0e0h,004h,02fh,004h,0efh,008h,0d0h,004h,0efh,081h,0e0h,011h,0d0h,002h,0f0h,017h,0d0h,081h,0f0h,006h,0d0h,002h,0fdh,010h,0d0h,00bh,0f0h,087h,060h,0f0h,060h,0f2h,0f2h,0bfh,0bfh,006h,0f0h,005h,0f2h,006h,020h,005h,0f0h,018h,0d0h,008h,0b0h,004h,020h,004h,0f2h,004h,0fdh,011h,0d0h,003h,0fdh,010h,0f0h,003h,0d0h,004h,0fdh,019h,0d0h,010h,0f0h,003h,020h,003h,0f0h,082h,0fdh,0d0h,008h,0f0h,00eh,0d0h,002h,0f0h,006h,0d0h,002h,0fdh,007h,0d2h,081h,0fdh,007h,02fh,081h,020h,003h,0f0h,081h,020h,004h,0f0h,000h	; 9957  .`.g.`...`..`.k{.kk.``..`. ...../.........................`.`......... ....... ................... ..................../. ... ...
	defb 006h,000h,096h,003h,007h,007h,00fh,03fh,00bh,01dh,0dfh,0dfh,0ffh,0e0h,0f0h,0fch,018h,018h,0fbh,0f7h,0f7h,000h,006h,009h,003h,004h,000h,099h,007h,00bh,0ddh,0edh,0edh,0fdh,0fdh,07dh,0ffh,0f7h,0f8h,0fdh,0ddh,0e0h,0fbh,0fbh,0e7h,0cfh,01fh,0fdh,0ddh,03bh,0e7h,0dfh,0e0h,007h,0f0h,085h,03dh,01dh,002h,007h,00fh,003h,01fh,088h,0dbh,0e0h,0fbh,0fbh,0bbh,0c0h,0f7h,0f7h,003h,03fh,08ah,0dfh,0a0h,07fh,0ffh,0ffh,0e0h,0e0h,0c0h,000h,0e0h,003h,0f0h,007h,03fh,091h,07fh,077h,080h,0f7h,0f7h,077h,080h,0f7h,0f7h,0bfh,07fh,0ffh,0ffh,0bfh,07fh,0ffh,0ffh,008h,0f8h,002h,01fh,092h,01dh,00dh,00eh,007h,007h,004h,06ch,083h,0dfh,0beh,031h,08fh,07fh,0ffh,0f0h,0f0h,0e0h,0c0h,003h,080h,0a5h,000h,0ffh,0f7h,0b8h,0ddh,0e5h,0f8h,0feh,0feh,0e7h,0cfh,01fh,0fdh,0f3h,08fh,08fh,0efh,0feh,0feh,0f9h,003h,0b7h,0c0h,0f7h,0f7h,0efh,0efh,0f7h,0f8h,0bfh,07fh,0ffh,0ffh,000h,0c0h,0f0h,0f8h,003h,0ffh,002h,07fh,08ch,03bh,03dh,01dh,00dh,005h,001h,001h,0e7h,07bh,03bh,00bh,003h,003h,001h,084h,000h,0c0h,0f8h,0fdh,003h,0feh,08bh,0ffh,005h,00eh,00eh,0c9h,0f5h,0edh,0edh,0eeh,0ffh,0ffh,003h,07fh,002h,03fh,085h,01fh,00fh,00fh,007h,003h,003h,001h,089h,000h,0ffh,0ffh,0fdh,0fdh,0feh,0ffh,0ffh,0fch,005h,000h,086h,001h,01fh,0ffh,007h,03fh,03fh,003h,01fh,095h,00fh,001h,0ffh,0ffh,0fbh,0fdh,0fdh,0f0h,0efh,0dfh,0ffh,0f7h,0f8h,0ffh,0f9h,03eh,0dfh,0efh,0efh,0f7h,0f7h,005h,0ffh,09dh,067h,05bh,03bh,03bh,0e1h,011h,011h,00ch,0e7h,0cfh,01fh,0bdh,0dbh,007h,0efh,0f7h,0beh,0d1h,0cfh,0d7h,0d7h,0bbh,0fbh,0fch,000h,0c0h,0f0h,0f8h,0f8h,003h,0fch,005h,000h,08bh,0e0h,03ch,01ch,018h,02eh,06eh,077h,0f9h,0feh,0ffh,0ffh,004h,000h,084h,042h,03ch,081h,0ffh,003h,000h,092h,002h,00eh,01eh,03fh,03fh,07fh,0bfh,05fh,067h,0bfh,0cfh,071h,09fh,001h,001h,002h,007h,00fh,003h,01fh,000h	; 99d8  .......?...........................}.............;......=................?..............?..w...w......................l...1....................................................;=......{;..........................?.........................??..................>........g[;;...............................<...nw.......B<........??.._g..q.........
	defb 00bh,060h,002h,0b0h,006h,060h,002h,0b0h,003h,060h,008h,0f0h,030h,060h,003h,06fh,052h,060h,005h,06fh,058h,060h,003h,06fh,059h,060h,002h,06fh,010h,060h,000h	; 9b2e  .`...`...`..0`.oR`.oX`.oY`.o.`.
	defb 002h,000h,09eh,002h,004h,006h,033h,06fh,0c6h,007h,005h,0e7h,0f1h,078h,07fh,07dh,078h,00fh,0dfh,0b7h,02fh,07fh,0ffh,07fh,03fh,0c0h,0e0h,070h,0b0h,078h,0feh,0ffh,0ffh,006h,000h,08ah,080h,0c0h,07dh,03ah,03dh,01fh,007h,007h,00fh,00fh,003h,0c0h,081h,080h,004h,0ffh,08ah,0c3h,0bdh,05ah,07eh,05ah,066h,0bdh,0c3h,0e0h,0e0h,006h,0f0h,08bh,007h,009h,00eh,01fh,03fh,03fh,07fh,07fh,0ffh,0ffh,000h,005h,0ffh,083h,0e0h,0c0h,020h,005h,0f0h,004h,07fh,089h,03fh,01fh,00fh,03fh,0ffh,0fch,0e0h,080h,080h,003h,000h,085h,0feh,000h,07fh,01fh,003h,003h,000h,08bh,0e0h,0f8h,0fch,0feh,0feh,01eh,01eh,038h,007h,001h,006h,005h,00fh,084h,0e0h,0c0h,000h,080h,003h,0c0h,085h,000h,007h,007h,003h,001h,004h,000h,090h,0ffh,0feh,0f9h,0fdh,07eh,03eh,01ch,07ch,0fbh,007h,0feh,0f8h,0f0h,070h,070h,0e0h,006h,000h,082h,01fh,07fh,006h,000h,086h,0e0h,0fch,001h,003h,007h,007h,004h,00fh,085h,0fch,0f3h,0efh,0dfh,0dfh,003h,0bfh,091h,007h,00fh,01bh,017h,01bh,01fh,00fh,077h,0f0h,0f8h,074h,0ach,0feh,0eeh,0eeh,0fch,00fh,003h,007h,003h,003h,081h,001h,003h,0bfh,002h,0dfh,09bh,0e7h,0f9h,0feh,0fch,0feh,0ffh,0ffh,07fh,07fh,01fh,080h,0f8h,000h,038h,0f9h,0f9h,0e3h,0f8h,0e0h,000h,080h,0b8h,0f8h,0f8h,0e0h,000h,000h,006h,001h,002h,000h,002h,0feh,08ah,0fdh,0f3h,0ceh,0ceh,0c6h,0e3h,080h,0fch,0f8h,0e0h,024h,000h,002h,00fh,086h,007h,003h,003h,007h,006h,007h,003h,0bfh,002h,0dfh,083h,067h,0b9h,0feh,003h,000h,085h,01ch,01fh,01fh,003h,001h,004h,000h,08ch,0e0h,0ffh,0fdh,0f8h,00fh,01fh,037h,02fh,07fh,000h,080h,0c0h,004h,000h,084h,003h,03fh,03fh,039h,003h,000h,002h,077h,093h,0b4h,07bh,07fh,0c0h,0e0h,070h,0b0h,078h,0f8h,0fch,0feh,078h,07dh,07ah,03dh,01fh,007h,00fh,00fh,004h,000h,006h,080h,094h,000h,080h,0c0h,0c0h,0e0h,0e0h,07dh,03ah,03dh,01fh,007h,007h,001h,03eh,000h,003h,00fh,01fh,03fh,07fh,006h,0ffh,002h,0dfh,084h,0efh,0f3h,007h,0f8h,006h,0ffh,082h,0e0h,0c0h,006h,000h,088h,001h,000h,003h,007h,00fh,00ch,000h,000h,003h,0ffh,082h,0feh,070h,003h,000h,082h,0f8h,0e0h,006h,000h,085h,01fh,007h,003h,001h,001h,019h,000h,08ah,0fch,03ch,03ch,07eh,0ffh,0ffh,0e1h,0deh,0ffh,0ffh,006h,000h,082h,081h,0c3h,005h,000h,083h,087h,0dfh,07fh,006h,0ffh,082h,07fh,03fh,000h	; 9b4d  ......3o.....x.}x.../...?..p.x........}:=..............Z~Zf...........??.......... .....?..?.......................8.........................~>.|.....pp.................................w..t..............................8..............................$...............g...................7/........??9...w..{...p.x...x}z=...............}:=....>....?..............................p.................<<~.....................?.
	defb 008h,060h,00dh,0b0h,003h,06bh,005h,0b0h,00bh,060h,005h,0b0h,003h,060h,004h,0b6h,032h,060h,002h,0f0h,015h,060h,003h,0f0h,01eh,060h,002h,0f0h,005h,060h,003h,0f0h,020h,060h,008h,0b6h,007h,0b0h,081h,0b6h,010h,060h,007h,0b6h,081h,006h,006h,0b6h,002h,060h,008h,0b0h,003h,060h,005h,0f0h,004h,060h,004h,0f0h,02ch,060h,004h,0f0h,008h,060h,015h,0b0h,003h,0b6h,015h,0b0h,003h,060h,005h,0b0h,013h,060h,005h,0b0h,024h,060h,007h,0f0h,028h,060h,008h,0f0h,010h,060h,008h,0b0h,006h,060h,002h,06bh,000h	; 9cf2  .`...k...`...`..2`...`...`...`.. `.......`.......`...`...`..,`...`.......`...`..$`..(`...`...`.k.
	defb 006h,000h,086h,0c0h,0f0h,000h,003h,007h,01fh,003h,0c0h,081h,01fh,003h,0ffh,085h,07fh,0bfh,0bfh,0deh,0c1h,006h,0ffh,084h,000h,0ffh,0f8h,0fah,003h,0fbh,090h,003h,0efh,0eeh,007h,000h,000h,001h,003h,003h,007h,007h,0dfh,00fh,077h,0f7h,0f7h,003h,0fbh,002h,0ffh,081h,0f8h,005h,0ffh,088h,0c0h,000h,0d0h,0ech,0f6h,0f6h,0fbh,0fbh,004h,007h,08fh,003h,001h,003h,00fh,0f8h,0ffh,0f8h,0e0h,0e0h,0c0h,0e0h,0e0h,000h,007h,001h,005h,000h,089h,003h,0ffh,0ffh,0feh,07ch,038h,07ch,07fh,007h,007h,000h,085h,0dfh,00fh,037h,077h,077h,003h,0fbh,086h,0c0h,000h,0c0h,0e0h,0f0h,0f0h,003h,0f8h,002h,07fh,092h,03fh,00fh,007h,00fh,03fh,000h,0e7h,09fh,0bfh,0bfh,038h,0bch,0bfh,000h,0f0h,0f0h,0e0h,080h,007h,000h,082h,001h,003h,003h,00fh,089h,01fh,00fh,0e0h,0d0h,0e0h,0f8h,01fh,01ch,01bh,003h,01fh,083h,008h,007h,01fh,005h,03fh,002h,01fh,083h,00fh,0efh,0efh,003h,0f7h,083h,07bh,01bh,003h,003h,00eh,082h,01ch,038h,008h,000h,002h,007h,081h,006h,003h,000h,087h,00fh,07fh,0ffh,0ffh,0f9h,030h,00fh,003h,0c0h,08bh,01fh,0afh,0b0h,0cfh,0f7h,0f7h,0fbh,0fbh,0f3h,0c8h,03fh,003h,080h,002h,0c0h,083h,040h,0c0h,0c0h,003h,000h,097h,001h,003h,003h,007h,007h,0c0h,000h,0c0h,0e0h,0f0h,0f0h,0f8h,0f8h,000h,01fh,00fh,007h,001h,000h,000h,001h,000h,0f8h,003h,0fch,083h,038h,07ch,0fch,005h,000h,082h,0f0h,0f8h,003h,03fh,083h,01fh,00fh,003h,003h,000h,081h,0f8h,003h,0ffh,086h,0fch,0f3h,00eh,01eh,020h,01fh,003h,0c0h,088h,01fh,0afh,0b0h,01fh,00fh,077h,0f7h,0f7h,003h,0fbh,081h,000h,007h,080h,084h,00eh,006h,003h,001h,004h,000h,08bh,0f9h,0f7h,06fh,0efh,0dfh,0dfh,05fh,04fh,0ffh,0ceh,0f6h,003h,0fbh,08ch,0fdh,0f9h,01fh,01fh,00fh,007h,001h,000h,000h,001h,0f1h,0f8h,003h,0fch,083h,038h,07ch,0fch,005h,000h,088h,003h,00eh,0deh,000h,000h,003h,00fh,01fh,003h,000h,082h,01fh,07fh,003h,0ffh,08bh,03fh,007h,000h,06eh,0f6h,0fbh,0fdh,0feh,0feh,0e0h,000h,003h,0ffh,085h,0feh,0e1h,0dfh,0ffh,0ffh,005h,000h,098h,0c0h,0f0h,0f8h,080h,080h,0c0h,0d0h,060h,0f0h,0fbh,0f7h,0f7h,07fh,07fh,03fh,01fh,00fh,001h,000h,01fh,00fh,037h,077h,077h,003h,0fbh,084h,0b0h,060h,0e0h,0e0h,003h,0c0h,085h,080h,0ffh,0ffh,03fh,00fh,00ah,000h,08ah,0feh,03eh,03ch,07eh,0ffh,0ffh,0e1h,0deh,0ffh,0ffh,006h,000h,08ah,081h,0c3h,000h,000h,03ch,04eh,00eh,01fh,01fh,00fh,005h,0ffh,002h,07fh,082h,09fh,000h,000h	; 9d53  ............................................w............................................|8|.......7ww..............?...?.....8...............................?.........{......8..............0..............?.....@...............................8|.......?............... .........w..................o..._O.....................8|....................?..n.........................`......?......7ww....`........?.....><~.............<N............
	defb 00ch,0a0h,003h,09ah,03fh,0a0h,002h,0f0h,006h,0a0h,002h,0f0h,00eh,0a0h,002h,0f0h,01eh,0a0h,002h,0f0h,006h,0a0h,002h,0f0h,008h,0a0h,005h,090h,003h,0a0h,003h,0f0h,003h,09fh,081h,0fah,01ah,0a0h,007h,0f0h,008h,090h,00ah,0a0h,003h,09ah,02ah,0a0h,081h,0f0h,006h,0a0h,009h,0f0h,013h,0a0h,003h,09ah,032h,0a0h,081h,0f0h,006h,0a0h,002h,0f0h,008h,0a0h,008h,0f0h,018h,0a0h,008h,0f0h,005h,090h,023h,0a0h,008h,0f0h,010h,0a0h,004h,090h,00ch,0a0h,081h,000h,000h	; 9f0c  ....?.........................................*...........2.................#............
	defb 005h,000h,083h,001h,003h,001h,005h,000h,088h,0c0h,0f4h,0f8h,000h,01ch,006h,007h,00fh,003h,01fh,090h,007h,00fh,007h,01fh,00fh,08fh,0ffh,0ffh,0e0h,0f0h,078h,0b8h,0bch,07eh,0ffh,0ffh,006h,000h,08ah,080h,0c0h,01fh,01fh,00fh,007h,001h,076h,0beh,01eh,005h,0ffh,082h,03fh,0dfh,005h,0ffh,002h,0fbh,002h,0f7h,081h,0c0h,006h,0e0h,081h,0c0h,003h,000h,087h,003h,007h,007h,00fh,00fh,0ffh,07fh,00eh,0ffh,085h,0c0h,080h,0c0h,0e0h,0e0h,003h,0f0h,004h,00fh,094h,007h,003h,007h,01fh,0ffh,0feh,0f8h,0e0h,0c0h,000h,080h,080h,0fdh,003h,01fh,007h,007h,001h,003h,003h,003h,0f0h,089h,0e0h,0c0h,080h,0c0h,0f0h,0c0h,080h,080h,0c0h,004h,0e0h,002h,07fh,08ch,03fh,01fh,027h,078h,079h,0e7h,0feh,081h,0dfh,0efh,0eeh,0f8h,004h,0c0h,081h,080h,005h,000h,002h,01fh,083h,00fh,007h,001h,003h,000h,08bh,0f3h,0fbh,0fdh,0feh,0feh,0efh,0dfh,0ceh,00fh,007h,003h,005h,000h,087h,0ffh,0e0h,0f8h,0fch,01ch,018h,070h,005h,000h,084h,007h,01fh,01fh,01ch,003h,000h,089h,079h,0ffh,0ffh,0feh,07dh,007h,00fh,007h,0dfh,003h,0efh,084h,0f7h,00dh,001h,001h,005h,000h,08ah,0f8h,0f7h,0f7h,0fbh,0fbh,07bh,07ch,03fh,07fh,07fh,006h,0ffh,085h,0fdh,003h,03fh,01fh,007h,003h,000h,088h,0e0h,0c0h,0f0h,0f8h,0f8h,038h,038h,070h,005h,000h,08eh,070h,07ch,01fh,007h,00fh,007h,01fh,00fh,00fh,0ffh,0ffh,01eh,00fh,007h,005h,000h,081h,07eh,003h,0ffh,089h,07fh,01fh,003h,000h,01fh,0e0h,0f0h,0f8h,0feh,007h,0ffh,08eh,0f9h,006h,0c0h,0e0h,0c0h,0e0h,0e0h,0a0h,0a8h,06ch,06fh,043h,01fh,003h,006h,000h,088h,0f0h,0feh,0ffh,07fh,01fh,007h,001h,000h,007h,0ffh,08ch,07fh,03fh,01fh,00fh,007h,003h,000h,001h,001h,0e7h,05fh,0bfh,003h,0ffh,092h,0f9h,007h,01fh,01fh,00fh,007h,001h,000h,001h,007h,0c0h,0e0h,0e0h,0a0h,0a0h,060h,060h,040h,003h,000h,096h,003h,007h,00fh,00fh,01fh,01fh,05fh,0bfh,0bfh,0dfh,0ffh,0ffh,0feh,0f0h,0feh,0ffh,0bfh,0c7h,0fbh,0e7h,00fh,0c0h,006h,080h,084h,000h,01fh,07ch,0f8h,005h,000h,081h,0e0h,01ah,000h,084h,008h,025h,01fh,007h,007h,000h,092h,003h,007h,007h,00fh,007h,01fh,00fh,0efh,0efh,0f7h,00dh,00dh,01dh,07eh,0feh,0ffh,0fch,0f0h,005h,000h,087h,003h,007h,01eh,003h,00fh,03fh,07fh,003h,0ffh,084h,07eh,0ffh,0ffh,0bfh,003h,07fh,084h,0bfh,007h,0c0h,080h,003h,0c0h,083h,0e0h,0f0h,070h,006h,000h,087h,0fch,03ch,03ch,07eh,0ffh,0e1h,0deh,003h,0ffh,006h,000h,082h,081h,0c3h,005h,000h,083h,087h,0dfh,07fh,005h,0ffh,002h,07fh,081h,01fh,000h	; 9f65  ..............................x..~............v.....?.........................................................................?.'xy..........................................p..........y...}...................{|?.......?..........88p...p|...............~........................loC.................?........_...................``@........._....................|.........%..................~............?....~...............p....<<~.......................
	defb 006h,060h,082h,080h,090h,006h,060h,082h,080h,090h,040h,0b0h,008h,020h,002h,0f0h,006h,020h,002h,0f0h,006h,020h,002h,0f0h,00bh,020h,003h,0f0h,006h,020h,002h,0f0h,005h,020h,003h,0f0h,005h,020h,005h,0f0h,00bh,020h,003h,0f0h,006h,020h,002h,0f0h,008h,020h,010h,0b0h,00ch,020h,004h,0f0h,028h,0b0h,002h,0f0h,013h,020h,003h,0f0h,010h,0b0h,008h,0f0h,008h,020h,081h,0b0h,007h,02bh,006h,0b0h,002h,02bh,008h,0b0h,008h,020h,002h,02fh,006h,020h,002h,0f0h,00ch,020h,002h,0f0h,00eh,0b0h,002h,020h,008h,0b0h,010h,020h,002h,02fh,006h,020h,002h,0f0h,007h,020h,007h,0f0h,008h,020h,010h,000h,020h,0b0h,008h,0f0h,010h,020h,002h,0f0h,002h,020h,00ch,0f0h,010h,020h,008h,0b0h,005h,020h,003h,02bh,000h	; a12a  .`....`...@.. ... ... ... ... ... ... ... ... ... ... ..(.... ....... ...+...+... ./. ... ..... ... ./. ... ... .. .... ... ... ... .+.
	defb 08ah,007h,01fh,01fh,005h,005h,00fh,007h,003h,0e0h,0f0h,003h,0f8h,083h,0e6h,0dfh,01fh,004h,000h,085h,010h,060h,0e0h,0e0h,003h,003h,007h,09ch,0cfh,0feh,03ch,000h,0e7h,0f8h,0ffh,0ffh,0f0h,0cfh,03fh,07fh,0c0h,0c0h,0e0h,060h,0e0h,0c0h,080h,0c0h,000h,001h,003h,007h,00fh,01fh,03fh,03ch,004h,0ffh,08ah,0c0h,0e1h,00fh,00fh,0c0h,0c0h,0e0h,0c0h,080h,080h,007h,000h,08eh,001h,007h,01eh,078h,070h,0f0h,0e0h,0c0h,080h,080h,000h,00fh,00fh,003h,006h,000h,087h,080h,0c0h,0e0h,070h,030h,060h,0c0h,004h,0ffh,089h,0c0h,0e1h,01eh,07ch,0c0h,0c0h,0e0h,0c0h,080h,003h,000h,08bh,01ch,00eh,00eh,006h,006h,003h,003h,00eh,078h,070h,070h,003h,030h,083h,060h,0c0h,00fh,003h,007h,081h,003h,003h,000h,085h,00ch,002h,003h,001h,001h,003h,000h,08dh,007h,01fh,01fh,085h,0e5h,0f3h,07ch,03fh,0c0h,0c0h,0e0h,0c0h,080h,009h,000h,08ah,003h,004h,003h,007h,007h,00fh,03fh,0feh,0f0h,000h,004h,0ffh,084h,0e0h,0fbh,03bh,0e6h,004h,000h,091h,03eh,037h,003h,001h,007h,01fh,01fh,005h,005h,0c3h,0fch,0ffh,07fh,01fh,00fh,003h,003h,007h,000h,086h,060h,038h,01ch,00fh,007h,003h,006h,000h,089h,0c0h,0f0h,078h,03eh,01fh,00fh,007h,003h,01fh,003h,03fh,085h,0cfh,0f3h,0fch,0ffh,0f7h,003h,007h,087h,0f0h,0e0h,0c0h,000h,07ch,0f2h,0c0h,005h,000h,082h,003h,001h,006h,000h,003h,0ffh,083h,07fh,01fh,003h,004h,000h,087h,003h,00fh,01fh,03ch,0f0h,000h,01fh,003h,0ffh,081h,080h,003h,000h,002h,0ffh,002h,080h,002h,01fh,082h,03eh,07ch,007h,000h,089h,003h,000h,040h,080h,0e0h,0f0h,0f0h,06eh,01fh,006h,000h,082h,003h,00fh,004h,000h,08fh,003h,01fh,0c0h,0c0h,003h,00fh,01fh,03fh,0bdh,0beh,027h,01eh,0cfh,0f7h,0f9h,003h,080h,08bh,0c0h,0f0h,0cfh,0f7h,0fbh,0fbh,0fdh,0fch,0fch,0f8h,000h,004h,080h,08bh,0c0h,0e0h,0e0h,0c0h,0c0h,0e0h,078h,01ch,002h,080h,0c0h,000h	; a1b1  .....................`........<.......?....`..........?<...................xp...............p0`.......|................xpp.0.`.......................|?..............?........;....>7..................`8.........x>......?.............|.....................<................>|.....@....n................?..'...........................x.....
	defb 003h,080h,005h,0b0h,012h,080h,006h,0b0h,009h,080h,005h,0b0h,005h,080h,005h,0b0h,004h,080h,002h,0b8h,002h,0b0h,005h,080h,003h,0b0h,006h,0f0h,002h,080h,004h,0b0h,002h,0f0h,002h,080h,00bh,0b0h,002h,0f0h,007h,080h,002h,0b8h,002h,0b0h,008h,080h,003h,0b0h,002h,0f0h,003h,080h,003h,0b0h,002h,0f0h,003h,080h,002h,0b0h,006h,080h,008h,0b0h,003h,080h,005h,0b0h,008h,080h,008h,0b0h,002h,080h,006h,0b0h,004h,080h,084h,0b8h,0f0h,080h,080h,008h,0b0h,003h,080h,007h,0b0h,00ch,080h,081h,0f0h,00eh,0b0h,003h,080h,081h,0b0h,008h,080h,003h,0b8h,004h,080h,008h,0b0h,00ch,080h,008h,0b0h,081h,0f0h,003h,080h,008h,0b0h,002h,080h,002h,0b8h,081h,080h,003h,0b0h,018h,080h,006h,0b0h,002h,0fbh,081h,080h,005h,0b0h,002h,08bh,003h,080h,005h,0f8h,005h,080h,003h,08bh,005h,080h,003h,0b0h,081h,080h,005h,0b0h,002h,080h,000h	; a302  ..............................................................................................................................................................
	defb 003h,000h,0afh,001h,007h,00eh,01eh,006h,03eh,07fh,0dfh,077h,077h,0afh,0feh,08eh,000h,000h,080h,0b0h,0b8h,078h,07ch,0f0h,00bh,03dh,07eh,07bh,0fdh,085h,079h,0e4h,004h,020h,000h,001h,082h,086h,0cch,003h,0c8h,03ch,0feh,0feh,07fh,09fh,0e7h,07bh,0deh,0bdh,003h,0fdh,002h,07dh,082h,0fdh,0bbh,003h,0ddh,081h,0feh,003h,0ffh,008h,0fdh,002h,0feh,002h,0fdh,002h,0fbh,002h,0f6h,003h,0fdh,085h,07dh,07ch,078h,07ah,027h,003h,0ffh,08ah,0feh,0f9h,0ffh,0ffh,03fh,0edh,0ddh,03bh,0fbh,0f7h,003h,0ffh,002h,000h,002h,080h,002h,0c0h,08ah,0e0h,0f8h,020h,01ah,005h,00dh,001h,005h,005h,004h,003h,000h,085h,081h,087h,0ceh,0deh,0e6h,008h,004h,092h,0ebh,0edh,0eeh,0f3h,0fch,0f1h,0eeh,0f3h,024h,020h,020h,001h,082h,086h,0cch,003h,004h,006h,003h,002h,085h,003h,001h,001h,0fah,0f9h,003h,0fdh,002h,07dh,086h,0fdh,000h,003h,00fh,01fh,01eh,004h,03eh,002h,02eh,087h,01eh,03eh,03eh,07eh,0feh,0deh,0bdh,003h,0fdh,003h,07dh,08ah,0e0h,03ch,01ch,00ch,01eh,03fh,07fh,07fh,071h,07eh,003h,0bfh,08ah,0cfh,0f0h,07fh,000h,0c3h,03ch,081h,0e7h,0ffh,0ffh,007h,000h,087h,002h,00dh,000h,000h,003h,01fh,07fh,003h,0ffh,088h,07fh,0bfh,05fh,067h,0bfh,04fh,071h,09fh,000h	; a3a0  ........>..ww........x|..=~{..y.. .......<.....{.....}......................}|xz'.......?..;............. ..........................$  ..................}........>....>>~......}..<...?..q~........<..................._g.Oq..
	defb 008h,0f1h,008h,0b1h,011h,0f1h,081h,0b1h,06fh,0f1h,002h,081h,05dh,0f1h,000h	; a47f  ........o...]..

; ----------------------------------------------------------------------
; DATOS guiones_de_los_sprites: los dieciseis guiones RLE del bucle de 0x5ABA.
;   La palabra NO es una cola: va DELANTE de cada guion y es su destino en
;   VRAM, que es lo que lee guion_rle (0x48E1) antes de entrar en 0x48E7. Por
;   eso el bloque empieza dos bytes antes de lo que hace pensar la tabla de
;   0x5B02, que apunta a los datos ya sin cabecera. Los dieciseis destinos
;   embebidos caen entre 0x1800 y 0x1880, todos multiplos de 32: sprites de
;   16x16
;   0xa48e..0xa7d1  (835 bytes)
DATA_guiones_de_los_sprites:
	defb 000h,018h,009h,000h,087h,03fh,0ffh,07fh,0feh,078h,020h,020h,009h,000h,087h,080h,0c0h,060h,020h,020h,000h,000h,000h	; a48e  .....?...x  .....`  ...
	defb 020h,018h,008h,000h,088h,001h,007h,05ah,05ah,03fh,01eh,00dh,007h,007h,000h,089h,080h,0c0h,0c0h,0e0h,0e0h,0c0h,0c0h,080h,000h,000h	; a4a5   ......ZZ?................
	defb 040h,018h,00bh,000h,085h,01ch,072h,0e8h,060h,020h,010h,000h,084h,01ch,0fch,0fch,0e0h,01ch,000h,000h	; a4bf  @.....r.` ..........
	defb 080h,018h,082h,00ch,01eh,005h,03fh,002h,01fh,08dh,00dh,01eh,027h,05bh,0bbh,0bbh,0bdh,007h,00fh,01fh,0efh,0abh,0c4h,003h,0e0h,002h,0fbh,08ch,007h,0f7h,081h,0f7h,0f7h,060h,0f0h,0fch,0fch,0f8h,0f8h,0f0h,004h,000h,085h,080h,000h,0b0h,0dch,0deh,010h,000h,087h,0f8h,07eh,07eh,0feh,0c7h,070h,07ch,019h,000h,083h,0deh,0bfh,07fh,003h,03fh,083h,006h,007h,003h,00fh,000h,081h,080h,007h,000h,000h	; a4d3  ......?.....'[...................`..................~~..p|.......?...........
	defb 080h,018h,082h,00ch,01eh,005h,03fh,002h,01fh,08dh,00dh,01eh,027h,04fh,09fh,09fh,0dfh,007h,00fh,01fh,0efh,0abh,0c4h,003h,0e0h,002h,0fbh,08ch,007h,0f7h,081h,0f7h,0f7h,060h,0f0h,0fch,0fch,0f8h,0f8h,0f0h,004h,000h,085h,080h,000h,0a0h,0d0h,0d0h,012h,000h,087h,0e0h,0feh,07fh,09fh,0feh,070h,078h,007h,000h,089h,00dh,00bh,007h,0ffh,07eh,07ch,078h,0e0h,0f8h,007h,000h,000h	; a520  ......?.....'O...................`......................px.......~|x.....
	defb 020h,018h,008h,000h,086h,001h,007h,05ah,05ah,03fh,01eh,009h,000h,089h,080h,0c0h,0c0h,0e0h,0e0h,0c0h,0c0h,000h,000h,000h	; a569   ......ZZ?..............
	defb 040h,018h,084h,0e0h,0f8h,0f8h,038h,01ch,000h,000h	; a581  @.....8...
	defb 060h,018h,00eh,000h,086h,001h,000h,001h,003h,007h,00fh,004h,00bh,003h,007h,085h,01fh,03ch,0e3h,09fh,00fh,007h,0ffh,08ah,0fch,0fbh,0ffh,0feh,0fdh,0fdh,078h,07eh,07eh,0f0h,005h,0ffh,091h,09fh,000h,080h,000h,080h,060h,070h,0b0h,0b8h,0b8h,007h,01fh,07fh,0ffh,0e7h,0e3h,070h,009h,000h,085h,0f8h,0fch,0f8h,0f0h,0c0h,00bh,000h,081h,03ch,003h,0fch,083h,030h,078h,07eh,019h,000h,000h	; a58b  `................<............x~~.........`p.........p...........<...0x~...
	defb 020h,018h,009h,000h,087h,001h,007h,05ah,05ah,03fh,00eh,001h,007h,000h,089h,006h,08ch,0cch,0c6h,0eeh,0eeh,0c6h,0c0h,080h,000h	; a5d6   ......ZZ?...............
	defb 060h,018h,083h,000h,030h,07eh,003h,0ffh,09dh,0feh,0ffh,0ffh,078h,070h,070h,030h,058h,087h,0afh,018h,01fh,01fh,0e6h,0f9h,0e7h,0dfh,03fh,0bfh,0bfh,07fh,03fh,03fh,03ch,0f8h,0f0h,001h,00fh,03fh,003h,0ffh,002h,0dfh,084h,0ech,0f0h,0e0h,080h,004h,000h,087h,0c7h,0dfh,0dch,0e0h,0f0h,0f0h,0c0h,009h,000h,083h,0dfh,01fh,01fh,004h,03fh,002h,07fh,08dh,018h,01ch,01ch,018h,030h,000h,000h,0e0h,0e0h,0c0h,0c0h,080h,080h,00ah,000h,000h	; a5ef  `...0~......xpp0X.........?...??<....?..........................?.......0...........
	defb 040h,018h,084h,038h,06ch,0f4h,0f0h,01dh,000h,0a8h,007h,01fh,07fh,0ffh,01fh,00fh,00fh,01eh,099h,070h,000h,000h,001h,002h,004h,000h,080h,0f0h,0f9h,0f6h,0fdh,0ffh,0feh,07dh,0fdh,0fdh,0fbh,0f7h,08fh,07fh,03fh,0c0h,0f8h,0f0h,060h,080h,040h,000h,0e0h,0feh,004h,0ffh,002h,0feh,081h,003h,009h,000h,090h,080h,0e0h,0f8h,03ch,0feh,0ffh,0ffh,0fbh,007h,00fh,00fh,01fh,03fh,006h,00fh,00fh,007h,000h,089h,0d8h,0f0h,0f0h,0e0h,0c0h,080h,000h,000h,0c0h,007h,000h,084h,01fh,007h,003h,001h,00ch,000h,085h,0c0h,0bch,03eh,04fh,087h,00bh,000h,000h	; a643  @..8l..............p.............}......?...`.@...............<........?...........................>O....
	defb 040h,018h,00bh,000h,085h,0e0h,0f8h,0ech,00eh,03eh,010h,000h,002h,0e0h,081h,0c0h,01dh,000h,084h,00fh,03fh,07fh,0c7h,003h,083h,0a3h,0c7h,07fh,018h,017h,037h,067h,032h,01ch,000h,000h,080h,0c0h,0e0h,0f1h,0feh,0edh,0c1h,03eh,0ffh,0ffh,09fh,07fh,0ffh,0ffh,080h,03fh,03fh,07fh,0ffh,0ffh,0feh,0b8h,008h,0f0h,07ch,004h,0beh,082h,07ch,0f8h,003h,0f0h,082h,0e0h,080h,00bh,000h,081h,0f7h,01fh,000h,000h	; a6ac  @........>..........?.........7g2..........>.......??.......|...|.............
	defb 040h,018h,084h,01ch,0fch,0fch,0e0h,00ch,000h,083h,070h,07ch,01ch,00eh,000h,084h,040h,0e0h,0f0h,0f8h,003h,0ffh,0a0h,07fh,01fh,06fh,0d0h,0bbh,0bbh,0bch,03fh,01fh,01fh,03fh,076h,060h,081h,081h,08eh,0aeh,0adh,0b5h,070h,0efh,00fh,0fah,0fch,000h,0c0h,0f0h,0f8h,0c0h,000h,060h,0fch,003h,0ffh,084h,03fh,0dfh,03fh,007h,009h,000h,08ch,080h,0e0h,0f8h,0f6h,0ffh,0cfh,0ceh,09ch,03fh,01fh,00fh,003h,00ch,000h,084h,0feh,0fch,0f8h,0e0h,00ch,000h,000h	; a6fa  @.........p|....@........o....?..?v`......p..........`....?.?............?.............
	defb 000h,018h,083h,080h,0d8h,078h,01dh,000h,083h,001h,01bh,01eh,01dh,000h,000h	; a751  .....x.........
	defb 040h,018h,088h,01fh,007h,003h,00fh,00fh,01fh,01ch,01bh,005h,01fh,002h,0efh,08bh,0f3h,080h,080h,000h,0e0h,0c0h,0c0h,040h,080h,0e0h,0f0h,006h,0ffh,002h,007h,088h,003h,01fh,00fh,00fh,008h,007h,01fh,03fh,006h,0ffh,088h,0e0h,080h,000h,0c0h,0c0h,0e0h,0e0h,060h,005h,0e0h,002h,0dch,081h,03ch,000h	; a760  @......................@...............?..........`.....<.
	defb 040h,018h,088h,001h,000h,000h,003h,003h,007h,00ch,00bh,005h,01fh,002h,0efh,08bh,0f3h,0e0h,078h,078h,0e0h,0f8h,0f8h,070h,0a0h,0c0h,0f0h,006h,0ffh,08ah,01eh,078h,078h,01fh,07fh,07fh,038h,017h,00fh,03fh,006h,0ffh,005h,000h,083h,080h,0c0h,040h,005h,0e0h,002h,0dch,081h,03ch,000h	; a79a  @.................xx...p.......xx...8..?.......@.....<.

; ----------------------------------------------------------------------
; DATOS guion_de_sprites_suelto: el unico que 0x5AE1 carga a mano, sin pasar
;   por tabla; 288 bytes de VRAM, o sea nueve sprites
;   0xa7d1..0xa87e  (173 bytes)
DATA_guion_de_sprites_suelto:
	defb 020h,01eh,003h,000h,08ah,004h,016h,00fh,00fh,03fh,00fh,01fh,02fh,00ah,002h,006h,000h,089h,080h,0b0h,0e0h,0c0h,0f8h,0e0h,0e0h,0d0h,080h,004h,000h,081h,091h,005h,0aah,081h,091h,00ah,000h,005h,080h,00ah,000h,087h,0c4h,02ah,02ah,0cah,02ah,02ah,0c4h,009h,000h,081h,040h,005h,0a0h,081h,040h,009h,000h,087h,0e4h,08ah,08ah,0cah,02ah,02ah,0c4h,009h,000h,081h,040h,005h,0a0h,081h,040h,00ch,000h,089h,008h,004h,000h,000h,018h,000h,000h,004h,008h,006h,000h,08bh,080h,088h,010h,000h,000h,00ch,000h,000h,010h,088h,080h,003h,000h,089h,008h,018h,03fh,07fh,0ffh,07fh,03fh,018h,008h,009h,000h,005h,0fch,00ah,000h,09eh,008h,000h,008h,0c4h,068h,030h,01fh,039h,044h,03fh,024h,01fh,00fh,003h,000h,000h,088h,000h,088h,044h,088h,000h,0f0h,0ech,002h,0fch,094h,0f8h,0f0h,0c0h,005h,000h,088h,003h,004h,007h,005h,005h,007h,005h,003h,008h,000h,082h,0c0h,020h,005h,0e0h,081h,0c0h,004h,000h,000h	; a7d1   ........?../..............................**.**....@...@.......**....@...@...............................?...?.............h0.9D?$........D......................... .......

; ----------------------------------------------------------------------
; DATOS guiones_del_pozo_de_sprites: los siete de la tabla de 0x5AF2, estos
;   con la direccion de VRAM metida en el propio guion; los siete van a
;   0x1F80, el final del pozo
;   0xa87e..0xa9fb  (381 bytes)
DATA_guiones_del_pozo_de_sprites:
	defb 080h,01fh,007h,000h,081h,001h,00bh,000h,085h,00ch,01eh,033h,07dh,0ffh,010h,000h,081h,001h,00fh,000h,085h,0ffh,07dh,033h,01eh,00ch,00ah,000h,089h,001h,0ffh,0bfh,0ffh,0bfh,07fh,05fh,035h,00fh,007h,000h,002h,080h,007h,000h,089h,00fh,035h,05fh,07fh,0bfh,0ffh,0bfh,0ffh,001h,00eh,000h,002h,080h,007h,000h,000h	; a87e  ...........3}.........}3..........._5.........5_.............
	defb 080h,01fh,007h,000h,082h,003h,00fh,00ch,000h,086h,018h,010h,0ffh,0feh,010h,018h,00ah,000h,086h,018h,008h,0ffh,07fh,008h,018h,00ch,000h,082h,0c0h,0f0h,007h,000h,000h	; a8bb  .................................
	defb 080h,01fh,082h,000h,003h,003h,000h,082h,01fh,007h,009h,000h,08bh,008h,000h,076h,0ffh,07fh,0feh,0ffh,0ffh,06eh,010h,0c0h,005h,000h,08bh,010h,000h,03eh,0ffh,0feh,07fh,0ffh,0ffh,076h,008h,003h,006h,000h,081h,0c0h,003h,000h,082h,0f8h,0e0h,009h,000h,000h	; a8dc  ...............v.....n.......>.....v..............
	defb 080h,01fh,015h,000h,086h,030h,00ch,007h,00eh,01ch,030h,009h,000h,084h,007h,01fh,078h,0c0h,00dh,000h,083h,0c0h,0f0h,018h,00dh,000h,086h,00ch,030h,0e0h,070h,038h,00ch,01dh,000h,084h,0c0h,078h,01fh,007h,00ch,000h,083h,018h,0f0h,0c0h,005h,000h,000h	; a90e  .....0....0.....x...........0.p8.....x...........
	defb 080h,01fh,0c0h,001h,001h,004h,000h,001h,001h,001h,000h,003h,007h,00fh,00fh,00fh,00fh,007h,003h,010h,020h,008h,0d0h,080h,000h,000h,080h,0c0h,0e0h,0b0h,0d0h,0d0h,0f0h,0a0h,0c0h,000h,01dh,039h,00fh,03fh,0ffh,07dh,0fbh,0f3h,07bh,03dh,07fh,03fh,03dh,01dh,006h,0c0h,0e0h,0cch,0eeh,0ffh,0feh,0ffh,0f7h,0fah,0f8h,0b1h,0c6h,0ffh,0ffh,0ech,060h,000h	; a93f  .................... ................9.?.}..{=.?=.................`.
	defb 080h,01fh,092h,000h,001h,001h,003h,002h,006h,006h,00fh,00fh,001h,001h,001h,003h,002h,006h,004h,080h,080h,005h,000h,084h,0c0h,0c0h,080h,080h,005h,000h,002h,001h,005h,000h,002h,003h,002h,001h,006h,000h,08fh,080h,080h,0c0h,040h,060h,060h,0f0h,0f0h,080h,080h,080h,0c0h,040h,060h,020h,000h	; a983  ............................................@``......@` .
	defb 080h,01fh,08eh,000h,000h,002h,002h,003h,005h,005h,006h,003h,004h,000h,002h,001h,001h,004h,000h,002h,020h,08ah,0e0h,0d0h,0d0h,0b0h,0e0h,090h,000h,020h,0c0h,0c0h,004h,000h,002h,002h,089h,003h,005h,005h,006h,003h,000h,002h,001h,001h,005h,000h,002h,020h,089h,0e0h,0d0h,0d0h,0b0h,0e0h,080h,020h,0c0h,0c0h,003h,000h,000h	; a9bc  .................... ........ ................... ....... .....

; ----------------------------------------------------------------------
; DATOS guiones_de_las_bandas: los veinticuatro guiones de las seis tablas de
;   0x594F a 0x597E: tres bandas x cuatro escenarios x (patrones y color). Las
;   doce parejas vuelcan lo mismo las doce: 112, 128, 304, 88, 672, 672, 712,
;   456, 32, 40, 56 y 16 bytes; 24 guion(es), medidos con tools/formatos.py
;   0xa9fb..0xb819  (3614 bytes)
DATA_guiones_de_las_bandas:
	defb 01ch,0ffh,081h,038h,003h,000h,005h,0ffh,083h,01fh,003h,001h,004h,0ffh,081h,0feh,003h,0fch,00dh,0ffh,093h,0fch,0f8h,0f0h,0feh,0f8h,0f8h,0feh,0feh,0f8h,0f8h,0feh,0feh,0f8h,0f8h,0feh,0feh,0e0h,0e0h,0feh,005h,0ffh,083h,0feh,0fch,0fch,006h,0ffh,082h,0fch,0e0h,003h,0ffh,088h,0feh,0f0h,080h,000h,000h,0ffh,0f8h,0c0h,005h,000h,000h	; a9fb  ...8.............................................................
	defb 002h,090h,081h,080h,003h,090h,088h,080h,090h,090h,080h,090h,080h,080h,090h,00ah,080h,083h,090h,080h,090h,005h,080h,08eh,090h,080h,090h,080h,080h,090h,080h,080h,090h,080h,090h,080h,080h,090h,00ah,080h,086h,090h,080h,090h,080h,080h,090h,032h,080h,000h	; aa3c  ...............................................2..
	defb 009h,0ffh,085h,0feh,0fdh,0f3h,007h,01fh,005h,0ffh,083h,078h,001h,01fh,003h,0ffh,002h,0fch,086h,0f8h,0f0h,0e0h,000h,000h,0ffh,003h,07fh,086h,03fh,07fh,07eh,07eh,0f8h,0e0h,006h,000h,004h,0ffh,087h,0f8h,081h,08fh,01fh,07eh,07eh,03ch,003h,01ch,002h,000h,084h,0ffh,0c7h,0bfh,07fh,00dh,0ffh,081h,0feh,004h,0fah,082h,07ah,072h,00bh,0bbh,083h,09fh,0d7h,0c7h,012h,0cfh,088h,0efh,0e8h,0ceh,0dch,0e0h,0d8h,038h,003h,000h	; aa6e  ...........x................?.~~...........~~<................zr...............8..
	defb 014h,060h,004h,080h,008h,068h,005h,060h,00bh,068h,008h,081h,008h,068h,008h,080h,037h,060h,081h,080h,000h	; aac0  .`...h.`.h...h..7`...
	defb 089h,0ffh,000h,000h,0ffh,000h,000h,0ffh,000h,0ffh,00fh,000h,093h,0ffh,000h,000h,0ffh,000h,0f0h,000h,000h,0ffh,000h,000h,0ffh,000h,0ffh,000h,0ffh,0ffh,000h,003h,00dh,000h,08bh,0ffh,000h,0ffh,0ffh,03fh,00fh,007h,003h,0ffh,000h,0ffh,003h,0f7h,084h,0e3h,0c1h,0ffh,000h,007h,0ffh,002h,000h,085h,0ffh,000h,0ffh,000h,0c0h,000h	; aad5  .......................................?........................
	defb 058h,041h,000h	; ab15
	defb 008h,0fbh,002h,0ffh,006h,000h,002h,0ffh,002h,000h,0a4h,0feh,0f8h,0e0h,000h,0ffh,0e3h,0c1h,08eh,01bh,035h,06eh,0dfh,0ffh,0fch,0f3h,0cfh,01fh,038h,027h,05fh,0ffh,03fh,0cfh,0f3h,0f9h,01dh,0e6h,0f9h,0ffh,0dfh,08fh,077h,0dbh,0adh,076h,0fbh,007h,0ffh,08ch,01fh,001h,000h,003h,00bh,00bh,000h,01bh,01bh,000h,000h,03fh,005h,020h,002h,000h,081h,0ffh,008h,000h,08ah,001h,007h,00ch,01bh,037h,007h,01ch,073h,0cfh,03fh,003h,0ffh,0a2h,0b8h,070h,0e0h,0c0h,080h,081h,003h,002h,0bfh,070h,067h,01fh,02eh,063h,07dh,062h,0fdh,0feh,07fh,07fh,03fh,0bfh,0dfh,05fh,000h,000h,07fh,080h,0e0h,030h,0d8h,0ech,01bh,000h,003h,03bh,090h,000h,03bh,03bh,000h,000h,001h,003h,007h,006h,00dh,00dh,06fh,0dfh,0bfh,07fh,07fh,003h,0ffh,002h,002h,081h,003h,003h,001h,08dh,080h,000h,07eh,07eh,03dh,0b8h,0bbh,09ch,0cfh,033h,05fh,05fh,0dfh,003h,0bfh,082h,07fh,0ffh,008h,020h,006h,07eh,003h,000h,087h,004h,026h,070h,07eh,07eh,000h,000h,003h,070h,003h,078h,002h,000h,088h,006h,000h,022h,042h,070h,07eh,000h,000h,003h,07eh,08ah,07ah,078h,07ch,000h,000h,07ah,07ah,07ch,070h,070h,003h,000h,003h,07eh,082h,070h,040h,003h,000h,002h,00eh,004h,006h,002h,000h,003h,07eh,08bh,070h,000h,00eh,000h,000h,040h,078h,060h,000h,01ch,07eh,003h,000h,08fh,040h,000h,060h,006h,070h,000h,000h,008h,000h,002h,006h,01eh,01eh,000h,000h,006h,056h,002h,000h,003h,056h,085h,000h,056h,056h,000h,000h,000h	; ab18  ....................5n......8'_.?.........w..v...............?. ...........7..s.?....p.......pg..c}b....?.._.....0.....;..;;........o...............~~=....3__....... .~....&p~~...p.x....."Bp~...~.zx|..zz|pp...~.p@.........~.p....@x`..~...@.`.p...........V...V..VV...
	defb 008h,06bh,00ch,0d5h,004h,050h,002h,0d0h,006h,050h,002h,0d0h,005h,040h,083h,050h,0d0h,0d0h,006h,050h,002h,0d0h,006h,050h,002h,0d0h,006h,050h,008h,0f0h,029h,050h,002h,040h,015h,050h,008h,0f0h,018h,050h,081h,040h,006h,050h,081h,040h,010h,050h,060h,0f0h,010h,0b0h,000h	; ac22  .k...P...P...@.P...P...P...P..)P.@.P...P.@.P.@.P`....
	defb 005h,000h,088h,0c0h,087h,03eh,008h,004h,004h,002h,002h,01bh,000h,08dh,07fh,03fh,0bfh,05fh,06fh,02fh,027h,026h,0e0h,0e0h,0c0h,0c0h,080h,003h,000h,002h,007h,088h,013h,01bh,009h,00ch,006h,006h,0f8h,0f8h,003h,0f0h,08fh,070h,060h,020h,01fh,05fh,05fh,02fh,02fh,02eh,02eh,024h,0ffh,0dfh,08fh,02fh,003h,017h,087h,01bh,0ffh,0f8h,0f0h,0c0h,0c0h,080h,00ah,000h,090h,0ffh,0feh,0fch,0f8h,0f8h,070h,070h,020h,0ffh,09fh,00fh,007h,007h,003h,001h,000h,006h,0ffh,082h,0f1h,0e0h,007h,0ffh,081h,0e0h,008h,0ffh,003h,000h,08dh,037h,03ch,008h,09fh,09eh,018h,03ch,00fh,0e0h,071h,0e7h,078h,00fh,003h,004h,002h,006h,003h,002h,08eh,07fh,03fh,019h,092h,044h,060h,020h,020h,01fh,0f8h,0f0h,0c0h,000h,020h,00ah,000h,090h,0cfh,05ch,0a4h,0aeh,079h,0eah,0eeh,0dah,003h,060h,0fch,087h,03ch,0c7h,075h,0eeh,00eh,000h,00ah,0ffh,088h,01fh,0c3h,0cfh,0f8h,0c3h,087h,0ceh,07fh,008h,000h,096h,02ch,08eh,029h,0dbh,08dh,037h,041h,05ah,01ah,0f7h,0dch,099h,0cdh,0feh,039h,099h,0ffh,08bh,0f7h,0e3h,0c0h,080h,00ah,000h,08ch,0cfh,08fh,007h,0fdh,0fbh,0f7h,0efh,0dfh,0e3h,0c3h,0c0h,080h,004h,000h,002h,0ffh,082h,07fh,01eh,004h,000h,083h,0ffh,0fch,0f0h,005h,000h,002h,01fh,082h,00fh,007h,004h,000h,082h,0feh,07ch,006h,000h,098h,080h,001h,0ffh,09bh,0ffh,0f7h,0ffh,0ffh,058h,0e6h,0fch,0a9h,04ch,0fbh,02ch,03fh,0f0h,0e0h,0c1h,01ch,027h,00fh,02fh,05fh,009h,0ffh,08ch,010h,0afh,0dfh,0ffh,080h,0ffh,02fh,0ffh,03fh,087h,0e0h,0f8h,005h,0ffh,08bh,0feh,000h,000h,0fbh,0f7h,004h,0bfh,07fh,0ffh,000h,000h,004h,0ffh,08ch,0fch,0e1h,007h,01fh,0ffh,0f0h,0feh,060h,0f8h,0e0h,0bfh,046h,003h,0dfh,002h,0ffh,081h,0f8h,003h,0ffh,082h,000h,0ffh,003h,0f8h,085h,0f9h,0f0h,0e0h,0c0h,080h,005h,0ffh,003h,000h,098h,053h,09ah,0efh,0feh,0a4h,081h,030h,0fch,054h,0a6h,06ah,01fh,0cfh,0cfh,027h,003h,01fh,0c1h,0f0h,0f8h,08dh,035h,075h,06bh,004h,0ffh,0f8h,07fh,000h,07fh,000h,03fh,0f8h,000h,000h,07fh,000h,07fh,000h,0f8h,0ddh,0d9h,0c7h,0b0h,020h,0b0h,010h,07eh,03ch,0b0h,040h,061h,01eh,07fh,000h,020h,020h,040h,080h,004h,050h,009h,0bah,000h,000h,001h,00ah,014h,080h,020h,080h,000h,007h,03eh,01fh,0feh,000h,0feh,000h,088h,043h,024h,008h,004h,001h,000h,000h,07ch,0d9h,0e6h,0f0h,0f8h,003h,0feh,001h,0a6h,035h,0ffh,07fh,0e0h,00fh,084h,040h,000h,008h,02ch,016h,000h,01ch,004h,00ch,000h,000h,03ah,0cch,0a3h,00ah,0c4h,000h,030h,032h,030h,055h,058h,050h,090h,0a8h,000h,000h,0e0h,09eh,054h,049h,003h,000h,006h,006h,007h,006h,004h,004h,006h,002h,000h,000h,063h,09ch,004h,005h,002h,000h,08eh,0a0h,046h,018h,020h,000h,040h,000h,000h,038h,056h,08ah,057h,003h,006h,004h,000h,085h,008h,000h,0a4h,051h,000h,003h,008h,0ach,000h,01ch,00ch,00ch,068h,058h,048h,02ch,024h,004h,006h,003h,007h,005h,001h,002h,002h,006h,006h,004h,005h,006h,006h,002h,0cfh,003h,005h,004h,0f8h,022h,026h,038h,0b0h,030h,0b0h,030h,0ffh,0f8h,0c1h,0e0h,07fh,0ffh,07fh,0ffh,006h,000h,086h,0f0h,0ffh,0f8h,0f0h,0e0h,0c0h,004h,000h,000h	; ac57  .....>.........?._o/'&.....................p` .__//..$.../..................pp ......................7<....<..q.x.........?..D`  ..... ....\..y....`..<.u.................,.)..7AZ......9..............................................|...........X...L.,?....'./_........./.?...........................`...F........................S.....0.T.j...'......5uk.......?............ ..~<.@a...  @..P........ ...>......C$.....|........5.....@..,.......:.....020UXP......TI............c.......F. .@..8V.W........Q........hXH,$...................."&8.0.0....................
	defb 007h,0b0h,081h,030h,021h,080h,08ah,060h,080h,060h,060h,080h,060h,060h,080h,060h,080h,005h,060h,083h,080h,060h,080h,005h,060h,09dh,080h,060h,080h,060h,060h,080h,060h,060h,080h,060h,080h,060h,060h,080h,060h,060h,080h,060h,080h,060h,060h,080h,060h,060h,080h,060h,080h,060h,060h,00ch,080h,0a7h,060h,080h,060h,060h,080h,060h,060h,080h,060h,080h,060h,060h,080h,060h,060h,080h,060h,080h,060h,060h,080h,060h,060h,080h,060h,080h,060h,060h,080h,060h,06ah,080h,060h,080h,060h,060h,080h,060h,060h,003h,000h,08dh,0b0h,030h,050h,0b0h,03bh,0b0h,0b0h,030h,0b0h,030h,0b0h,030h,030h,005h,060h,005h,090h,081h,0a0h,005h,090h,081h,06ah,00fh,090h,088h,0b0h,020h,0a0h,0cbh,0cbh,0cah,084h,0c4h,003h,0b0h,085h,03bh,030h,030h,02bh,02bh,018h,040h,087h,080h,030h,0c8h,0c0h,0b0h,0c0h,0c8h,009h,0c0h,08fh,0c5h,039h,023h,0a8h,059h,0cah,035h,0a5h,0c5h,050h,05bh,05ch,058h,050h,0c0h,003h,05bh,002h,056h,00ch,0c5h,003h,045h,005h,050h,028h,045h,008h,059h,087h,080h,090h,020h,018h,029h,028h,0a8h,012h,050h,087h,0c5h,058h,058h,050h,0c4h,050h,058h,005h,050h,002h,040h,006h,050h,002h,040h,081h,045h,005h,050h,002h,040h,007h,050h,08ah,0a5h,025h,0a5h,035h,025h,050h,035h,025h,0c0h,050h,008h,054h,081h,059h,00bh,050h,004h,090h,098h,025h,028h,020h,080h,0a2h,080h,080h,020h,0a5h,08ah,028h,050h,020h,0a0h,020h,0a0h,030h,080h,020h,050h,0a8h,028h,035h,0a8h,004h,050h,096h,090h,000h,0e0h,000h,035h,0c5h,055h,055h,090h,000h,0e0h,000h,0c5h,026h,0c6h,056h,069h,060h,06eh,060h,059h,050h,004h,090h,002h,0e0h,083h,060h,090h,060h,00dh,090h,003h,025h,085h,0c5h,090h,000h,0e0h,000h,008h,060h,08dh,0a5h,020h,0a0h,050h,096h,060h,0e0h,060h,0a3h,089h,090h,050h,039h,00bh,0e0h,003h,030h,002h,020h,003h,0c0h,084h,060h,030h,060h,0c0h,004h,060h,003h,020h,082h,0c0h,020h,003h,0c0h,018h,060h,004h,030h,081h,020h,003h,0c0h,008h,080h,008h,0e0h,018h,060h,088h,025h,063h,062h,065h,069h,060h,06eh,060h,003h,053h,085h,052h,090h,000h,0e0h,000h,007h,0a5h,084h,020h,080h,060h,080h,005h,060h,000h	; ae87  ...0!..`.``.``.`..`..`..`..`.``.``.`.``.``.`.``.``.`.``...`.``.``.`.``.``.`.``.``.`.``.`j.`.``.``....0P.;..0.0.00.`.......j.... .........;00++.@..0.........9#.Y.5..P[\XP..[.V...E.P(E.Y... .)(..P..XXP.PX.P.@.P.@.E.P.@.P..%.5%P5%.P.T.Y.P...%( .... ..(P . .0. P.(5..P.....5.UU.....&.Vi`n`YP.....`.`...%.......`.. .P.`.`...P9...0. ...`0`..`. .. ...`.0. .......`.%cbei`n`.S.R....... .`..`.
	defb 093h,0f7h,017h,073h,033h,007h,01bh,01ch,0c0h,0ffh,0fch,0fch,0f8h,0f0h,0e0h,000h,000h,07eh,07eh,03ch,003h,038h,00ah,000h,004h,0ffh,084h,0f8h,081h,08fh,01fh,007h,0ffh,081h,0fch,00dh,0ffh,088h,0e7h,003h,003h,0ffh,0ffh,0e0h,007h,07fh,009h,0ffh,082h,0e0h,000h,003h,0ffh,083h,078h,001h,01fh,00eh,0ffh,082h,0f8h,0c0h,00ah,000h,003h,0c7h,003h,0cfh,002h,0dfh,002h,0ffh,0bbh,0fdh,0e3h,0c1h,081h,001h,000h,0e0h,0e1h,0c3h,0cfh,0dfh,0feh,0d8h,0d0h,0ffh,0ffh,0fch,0bch,09ch,01ah,018h,009h,0c0h,080h,003h,03fh,0ffh,0ffh,0fch,0f1h,003h,001h,060h,087h,037h,0e7h,0dfh,09fh,03fh,07ch,078h,0e0h,0e1h,0e0h,0c1h,083h,0c0h,007h,06fh,0f9h,0d9h,098h,010h,010h,000h,00dh,053h,0f0h,080h,004h,000h,086h,0c0h,0ech,01ah,011h,001h,001h,009h,000h,08bh,00fh,010h,06fh,01fh,07fh,0bfh,0ffh,0ffh,09ch,01ch,03eh,003h,07fh,002h,0ffh,09bh,038h,030h,0c1h,0c3h,083h,097h,016h,035h,0c3h,0c7h,0bfh,07fh,07fh,0fdh,0ffh,0ffh,0f8h,0f0h,0c1h,0c3h,087h,097h,017h,037h,0ffh,0feh,0f8h,003h,0e0h,08bh,0c0h,0c2h,003h,006h,038h,098h,0b0h,0c0h,080h,0c0h,020h,003h,040h,085h,060h,0a0h,000h,000h,0fch,003h,0f8h,002h,0f0h,092h,0e0h,0c0h,0c2h,0c2h,082h,086h,085h,005h,00dh,00bh,0f6h,0f4h,0f5h,0e5h,0e5h,0e3h,083h,007h,006h,0ffh,089h,0c7h,083h,0ffh,0ffh,03fh,04fh,047h,090h,0d0h,009h,0c4h,0a4h,049h,05bh,05bh,05fh,00fh,00bh,02bh,02bh,0f6h,0eeh,0edh,0f1h,0f0h,0f9h,0f8h,0fah,02fh,02fh,067h,077h,063h,063h,02bh,028h,0c2h,0c2h,0c6h,0c3h,0c0h,080h,080h,000h,080h,080h,0c0h,080h,004h,000h,002h,0f0h,002h,0f8h,003h,0fch,082h,0f8h,0cfh,003h,0dfh,081h,0cfh,003h,0efh,006h,006h,08eh,08fh,0c6h,0e7h,0ech,0cch,0d8h,0d8h,0e8h,0f9h,0f9h,01bh,01bh,03bh,039h,003h,03dh,081h,0beh,003h,0f0h,089h,0f4h,0f6h,0fah,0fbh,0fbh,0f7h,033h,019h,018h,004h,000h,084h,0f8h,0fch,0fch,0e0h,00eh,000h,08eh,004h,006h,002h,006h,000h,000h,0a0h,0a0h,0d0h,0f8h,0fch,0feh,0ffh,0ffh,003h,007h,002h,003h,003h,000h,081h,0f9h,003h,0fbh,004h,0ffh,088h,07fh,03fh,0bfh,0beh,03eh,0beh,0beh,00fh,010h,000h,08bh,010h,030h,020h,060h,060h,0f4h,000h,000h,010h,038h,028h,003h,02ch,086h,006h,047h,0d8h,0d8h,0dch,09ch,003h,0bch,081h,07dh,010h,0ffh,087h,0f8h,0fch,0fch,0feh,0feh,07fh,038h,003h,000h,085h,03ch,04eh,0bfh,003h,001h,011h,008h,083h,08eh,09eh,0ceh,003h,0c0h,002h,000h,083h,038h,0f8h,078h,00dh,000h,083h,010h,011h,01ah,005h,000h,086h,041h,049h,053h,002h,002h,003h,00ah,000h,086h,037h,01bh,01bh,00dh,00eh,006h,00ah,003h,003h,0bbh,08ch,09fh,0d7h,0c7h,0cfh,0cfh,0efh,0e8h,0ceh,0dch,0e0h,0d8h,038h,009h,000h,08ah,0ffh,03fh,03fh,01fh,00fh,00eh,000h,000h,0ffh,0feh,004h,0fah,085h,07ah,072h,07eh,07eh,03ch,003h,01ch,002h,000h,082h,0f8h,0e0h,006h,000h,000h	; b007  ...s3............~~<.8................................x...........................................?......`.7...?|x.......o.......S................o.......>.....80.....5...............7..........8..... .@.`..................................?OG.....I[[_..++........//gwcc+(............................................;9.=...........3........................................?..>.......0 ``....8(.,..G.......}.........8...<N..............8.x.........AIS......7.....................8....??..........zr~~<..........
	defb 007h,060h,081h,080h,010h,068h,038h,080h,004h,060h,052h,080h,002h,060h,081h,080h,017h,060h,038h,080h,010h,060h,018h,080h,008h,08bh,030h,080h,008h,060h,010h,080h,082h,08bh,06bh,004h,0fbh,002h,08bh,028h,080h,010h,060h,030h,080h,008h,060h,078h,080h,038h,060h,008h,068h,000h	; b204  .`...h8..`R..`...`8..`....0..`....k....(..`0..`x.8`.h.
	defb 084h,0f7h,0e3h,080h,063h,004h,000h,088h,020h,050h,098h,020h,056h,001h,0beh,0d7h,004h,000h,084h,080h,040h,015h,006h,010h,000h,085h,040h,002h,010h,0a0h,002h,004h,000h,08ah,080h,000h,044h,008h,092h,000h,001h,000h,010h,005h,007h,000h,08bh,001h,003h,007h,00eh,01ch,03ah,020h,004h,000h,000h,092h,00bh,000h,083h,00ch,0adh,014h,005h,000h,085h,0b6h,0eeh,026h,056h,001h,003h,000h,086h,084h,010h,07ch,0eeh,07ch,06ch,02bh,000h,087h,001h,000h,022h,010h,049h,000h,080h,004h,000h,094h,080h,040h,015h,006h,084h,010h,040h,010h,040h,080h,000h,000h,0ffh,07fh,01fh,00fh,007h,007h,003h,003h,009h,0ffh,081h,0f3h,003h,0ffh,088h,0fch,0c0h,000h,0ffh,00eh,0ffh,018h,0c0h,003h,000h,083h,0ffh,0f8h,0c0h,005h,000h,081h,0ffh,007h,000h,083h,0ffh,0abh,040h,005h,000h,08fh,0ffh,0abh,040h,000h,000h,0ffh,000h,000h,0ffh,0ffh,000h,0ffh,000h,001h,000h,009h,0f8h,09eh,05ah,000h,0ffh,029h,003h,00ch,010h,020h,018h,000h,004h,000h,040h,015h,080h,07fh,0e0h,0e0h,040h,000h,080h,012h,030h,0c8h,000h,000h,040h,000h,000h,058h,004h,000h,09bh,040h,000h,008h,000h,000h,0fdh,018h,000h,044h,001h,012h,008h,07fh,000h,000h,004h,010h,004h,001h,07ch,000h,000h,008h,084h,030h,008h,0e0h,004h,000h,084h,021h,08ch,013h,008h,003h,000h,085h,090h,084h,031h,0c8h,010h,006h,000h,081h,07fh,003h,000h,081h,018h,003h,000h,081h,088h,003h,0c0h,083h,000h,008h,0e0h,008h,000h,082h,018h,0c3h,004h,000h,086h,0c3h,000h,018h,081h,000h,01dh,00dh,000h,085h,001h,00fh,006h,001h,0fch,003h,000h,08dh,0f8h,03ch,080h,0f8h,090h,0c8h,060h,0c0h,020h,080h,010h,000h,000h,004h,0ffh,099h,03fh,00fh,007h,003h,000h,000h,040h,000h,000h,058h,000h,000h,0ffh,03fh,01fh,00fh,007h,007h,003h,003h,0ffh,00eh,0ffh,0ffh,007h,003h,000h,082h,03fh,003h,006h,000h,088h,0ffh,00eh,0ffh,018h,0ffh,0e0h,0ffh,00fh,000h	; b23a  ....c... P. V.......@.....@.........D...............: ...............&V......|.|l+....".I......@....@.@.........................................@.....@...............Z..)... ....@.....@...0...@..X...@.......D..........|....0.....!........1..............................................<....`. .......?.....@..X...?..............?.............
	defb 008h,041h,07fh,0a1h,029h,0a1h,002h,041h,08eh,0d1h,041h,041h,0d1h,041h,0d1h,041h,041h,0d1h,041h,041h,0d1h,041h,0d1h,005h,04dh,003h,041h,004h,04dh,005h,041h,081h,0d1h,00fh,041h,081h,04bh,006h,0b1h,088h,041h,04bh,0b1h,011h,011h,041h,011h,011h,010h,041h,084h,091h,011h,0a1h,021h,004h,0a1h,081h,0f1h,006h,0a1h,081h,081h,004h,021h,003h,0a1h,081h,081h,007h,0a1h,082h,081h,0f1h,005h,0a1h,002h,081h,004h,0a1h,004h,081h,003h,0a1h,005h,081h,003h,0a1h,005h,081h,008h,0b1h,081h,041h,007h,0b1h,007h,091h,081h,0f1h,004h,091h,004h,031h,008h,091h,018h,041h,007h,0b1h,081h,04bh,006h,0b1h,002h,0b4h,008h,0b1h,008h,041h,008h,0b1h,008h,040h,002h,04dh,006h,040h,008h,0d0h,004h,04dh,004h,040h,000h	; b390  .A..)..A..AA.A.AA.AA.A..M.A.M.A...A.K...AK...A...A....!.........!............................A.........1...A...K.......A...@.M.@...M.@.
	defb 082h,03bh,000h,003h,03bh,003h,000h,003h,01bh,005h,037h,0a8h,0f8h,0f0h,0e0h,0c0h,080h,001h,001h,002h,007h,01bh,03dh,07ch,0feh,0e0h,08ah,0aah,0f4h,0fbh,0fch,0cch,002h,001h,0bfh,05fh,02fh,0dfh,03fh,0f1h,0ffh,0f0h,0e3h,0cfh,007h,001h,0cch,0deh,0bfh,0bbh,0b7h,031h,004h,0ffh,002h,07fh,082h,03fh,0bfh,005h,000h,083h,030h,0d0h,0e8h,006h,000h,082h,007h,01fh,008h,06fh,002h,0feh,002h,0fch,004h,0f8h,083h,003h,007h,007h,005h,00fh,08bh,056h,05bh,04fh,07eh,07eh,03fh,03fh,01fh,06fh,02fh,06fh,003h,0efh,003h,0dfh,083h,0bfh,0ffh,0bfh,003h,0beh,08ch,0feh,033h,077h,067h,067h,06fh,06fh,0ech,0ebh,0bfh,09fh,0dfh,003h,0cfh,097h,08fh,0efh,000h,018h,00ch,004h,020h,030h,012h,00ah,0d8h,070h,020h,08ch,0ceh,05ch,058h,088h,03fh,06fh,07fh,0dfh,0dfh,003h,0ffh,083h,0fch,0feh,0feh,005h,0ffh,008h,0dfh,008h,0f8h,003h,01eh,0adh,01ch,019h,03bh,033h,037h,03fh,03fh,07fh,0ffh,0feh,0feh,0fch,0fch,0bfh,07eh,079h,047h,00fh,03fh,01fh,00fh,0fch,0dch,0e0h,0f0h,0f9h,0f9h,0fbh,0f3h,0c3h,0c7h,0c7h,0cfh,0cdh,0cbh,096h,08dh,087h,0c7h,0e7h,0c7h,087h,003h,0e3h,0fbh,006h,000h,082h,0ffh,000h,007h,0ffh,099h,000h,008h,0a0h,0d2h,06bh,033h,019h,004h,007h,0c4h,08ch,019h,033h,024h,0a8h,040h,0e0h,07fh,07fh,03fh,01fh,000h,007h,001h,000h,004h,0fch,081h,0feh,003h,0ffh,003h,03fh,002h,01fh,0abh,00fh,007h,000h,0f8h,070h,060h,0dfh,0dfh,0bfh,03fh,03fh,083h,0e0h,07ch,07fh,03fh,01fh,007h,000h,0e7h,087h,00eh,0feh,0fdh,0f3h,0c7h,01fh,01fh,03fh,07fh,0ffh,0fbh,0f3h,0e7h,08fh,0c1h,0e1h,0f1h,0c9h,0c1h,023h,083h,083h,006h,000h,002h,0ffh,007h,0fbh,096h,07eh,000h,000h,001h,001h,003h,003h,007h,007h,040h,008h,000h,010h,030h,038h,038h,010h,0f8h,0e0h,0e0h,0c4h,0c0h,003h,0c8h,083h,01fh,007h,007h,005h,003h,008h,0feh,085h,0dfh,06fh,06fh,06ch,06ch,003h,068h,0b8h,0f0h,0c0h,000h,007h,03fh,07fh,00fh,01fh,000h,000h,03fh,001h,01fh,0ffh,0efh,0dfh,01fh,01bh,03ch,0fch,0ffh,0e0h,0f0h,0feh,0feh,0f9h,0c3h,01fh,0ffh,0ffh,038h,007h,03bh,023h,007h,00fh,0f8h,007h,0ffh,03fh,080h,055h,055h,0aah,001h,0ffh,03fh,0ffh,0fbh,070h,037h,0cfh,03fh,00fh,0ffh,0f9h,003h,0ffh,086h,00fh,0c3h,0e1h,0f0h,0f8h,0fbh,006h,0f6h,089h,076h,00fh,00fh,01fh,01fh,03fh,03fh,07fh,07fh,008h,0e7h,003h,0c0h,002h,0e0h,083h,0f0h,0f8h,0fch,003h,003h,002h,007h,083h,00fh,01fh,03fh,004h,0b4h,002h,0dah,09ch,0edh,0f0h,03bh,03ch,01eh,00fh,003h,07fh,01fh,000h,0e0h,0feh,038h,0feh,0f9h,0e7h,01fh,000h,0ffh,0ffh,0f8h,0f7h,0efh,09fh,0ffh,000h,01fh,03fh,003h,07fh,0a3h,0bfh,0dfh,000h,0ffh,07fh,01fh,0feh,07fh,087h,0f8h,000h,0ffh,0ffh,01fh,03fh,0c7h,0f8h,0ffh,000h,0feh,0fch,0e1h,007h,000h,07fh,08fh,000h,0bch,0dch,0d8h,0b0h,000h,0feh,0f8h,000h,003h,0e7h,087h,066h,000h,081h,0e7h,0ffh,0feh,0feh,003h,0fch,003h,0ffh,002h,07fh,003h,03fh,003h,0ffh,002h,00fh,003h,01fh,083h,000h,01fh,01fh,005h,0ffh,083h,000h,0ffh,0ffh,008h,0fbh,008h,020h,082h,030h,078h,004h,07eh,002h,000h,002h,002h,006h,000h,086h,006h,000h,022h,042h,070h,07eh,003h,000h,089h,040h,000h,060h,006h,070h,000h,000h,00eh,00eh,004h,006h,002h,000h,006h,07eh,002h,000h,003h,07eh,082h,070h,040h,004h,000h,08fh,004h,026h,070h,07eh,07eh,000h,000h,008h,000h,002h,006h,01eh,01eh,000h,000h,003h,07eh,085h,070h,000h,00eh,000h,000h,000h	; b417  .;..;.....7...........=|..........._/.?............1.....?....0........o.............V[O~~??.o/o............3wggoo.............. 0...p ..\X.?o....................;37??.......~yG.?......................................k3......3$.@...?............?.......p`...??..|.?............?...........#.........~........@...088..................ooll.h.....?.....?.......<...........8.;#.....?.UU...?..p7.?...............v....??...................?.......;<........8..............?.................?.......................f.............?................... .0x.~........."Bp~...@.`.p.........~...~.p@....&p~~...........~.p.....
	defb 008h,0f0h,00dh,050h,009h,040h,002h,050h,003h,040h,003h,045h,002h,050h,003h,040h,015h,054h,008h,0b0h,007h,060h,081h,0a0h,010h,050h,008h,040h,010h,050h,018h,054h,002h,0b0h,002h,030h,002h,0b0h,08ah,030h,0c0h,0b0h,0b0h,0c0h,0b0h,0b0h,030h,0c0h,0c0h,005h,0a0h,081h,060h,007h,0a0h,083h,060h,0a0h,0a0h,010h,050h,008h,040h,004h,050h,004h,054h,004h,050h,01ch,054h,008h,060h,008h,050h,083h,0c0h,0b0h,0b0h,004h,0c0h,084h,070h,0b0h,0c0h,0b0h,004h,0c0h,081h,070h,003h,0a0h,005h,060h,008h,050h,008h,040h,003h,054h,005h,040h,020h,054h,008h,040h,007h,06bh,081h,060h,008h,050h,006h,095h,002h,065h,081h,050h,007h,057h,081h,050h,007h,057h,008h,056h,00bh,050h,003h,040h,002h,054h,003h,040h,005h,054h,003h,040h,003h,054h,002h,050h,008h,040h,004h,054h,003h,040h,082h,054h,040h,003h,050h,002h,040h,002h,054h,005h,040h,00bh,054h,010h,050h,008h,05fh,005h,057h,003h,047h,008h,057h,008h,050h,005h,054h,003h,040h,003h,054h,015h,040h,003h,054h,005h,040h,003h,054h,005h,040h,005h,054h,003h,040h,005h,054h,003h,040h,003h,05fh,004h,05ah,086h,050h,056h,050h,056h,046h,046h,003h,050h,082h,056h,050h,006h,056h,006h,050h,002h,040h,003h,055h,003h,050h,002h,040h,008h,06bh,008h,050h,050h,0f0h,000h	; b67d  ...P.@.P.@.E.P.@.T...`...P.@.P.T...0...0......0.....`...`...P.@.P.T.P.T.`.P.......p......p...`.P.@.T.@ T.@.k.`.P...e.P.W.P.W.V.P.@.T.@.T.@.T.P.@.T.@.T@.P.@.T.@.T.P._.W.G.W.P.T.@.T.@.T.@.T.@.T.@.T.@._.Z.PVPVFF.P.VP.V.P.@.U.P.@.k.PP..
	defb 0a0h,0fbh,0fbh,0fbh,000h,0ffh,0ffh,07eh,081h,0ffh,0ffh,0ffh,066h,099h,0bdh,03ch,0bdh,0ffh,0ffh,07eh,081h,0ffh,0ffh,07eh,000h,0a5h,099h,03ch,0bdh,0a5h,099h,03ch,018h,000h	; b765  .......~....f..<...~...~...<...<..
	defb 083h,0f0h,0e0h,0e0h,006h,0f0h,003h,0e0h,007h,0f0h,005h,0e0h,005h,0f0h,003h,0e0h,000h	; b787  .................
	defb 082h,0c1h,0e7h,006h,0ffh,087h,09fh,0ffh,0fbh,0f1h,0e4h,084h,02eh,004h,0ffh,095h,0cfh,0b7h,010h,0ffh,0ffh,0fch,0f1h,0c7h,0d7h,0d7h,0b3h,0b3h,0ffh,07fh,00fh,047h,06bh,081h,0b1h,0a5h,0ffh,000h	; b798  ...............................Gk.....
	defb 028h,060h,000h	; b7be
	defb 004h,0ffh,084h,000h,0ffh,0ffh,0efh,004h,0ffh,081h,000h,003h,0ffh,081h,0feh,003h,0fch,004h,0fdh,0a0h,07fh,03fh,01fh,00fh,007h,003h,001h,000h,000h,080h,0c0h,0e0h,0f0h,0f8h,0fch,0feh,03fh,01fh,00fh,035h,06fh,0ffh,012h,076h,07fh,07fh,03fh,03fh,01fh,01fh,00fh,007h,000h	; b7c1  .....................?..............?..5o..v..??.....
	defb 028h,0e1h,088h,080h,080h,040h,080h,080h,080h,0e8h,0e8h,008h,0e0h,000h	; b7f6  (....@........
	defb 090h,0ffh,000h,0ffh,000h,000h,0ffh,000h,000h,000h,0ffh,000h,000h,000h,0ffh,000h,000h,000h	; b804  ..................
	defb 010h,080h,000h	; b816

; ----------------------------------------------------------------------
; DATOS guiones_del_suelo: dos guiones RLE; 0x5A33 y 0x5A44 los vuelcan en
;   0x1080/0x1440 y 0x3080; 2 guion(es), medidos con tools/formatos.py
;   0xb819..0xb8d3  (186 bytes)
DATA_guiones_del_suelo:
	defb 093h,01fh,03fh,03dh,03fh,03fh,01fh,03fh,079h,0c0h,0f8h,060h,0e0h,060h,058h,0bch,0feh,07eh,039h,007h,003h,01fh,08ch,00fh,000h,0f0h,0c0h,0f8h,0c0h,060h,080h,000h,000h,0e0h,080h,00ah,000h,084h,00fh,01fh,01fh,027h,004h,000h,086h,0e0h,0fch,050h,0f0h,079h,0feh,003h,0ffh,08bh,0f8h,07eh,01fh,0f0h,020h,0d0h,0e8h,0f4h,0f4h,0fah,03dh,004h,000h,084h,0b8h,05fh,02fh,02fh,004h,000h,094h,0f8h,07eh,01fh,0ffh,017h,00bh,004h,00fh,00fh,00ah,03fh,007h,0ffh,0ffh,07fh,09eh,0e4h,0f8h,0f8h,0f0h,003h,000h,085h,001h,011h,008h,000h,030h,003h,000h,08bh,040h,044h,008h,000h,00ch,000h,010h,020h,000h,002h,004h,004h,000h,086h,008h,004h,040h,040h,000h,000h,000h	; b819  ..?=??.?y..`.`X..~9..........`...........'.....P.y.....~.. .....=...._//....~........?................0...@D..... ........@@...
	defb 002h,060h,006h,0b0h,002h,060h,009h,0b0h,005h,060h,002h,0b6h,002h,060h,00ch,0f0h,006h,060h,002h,0b0h,006h,060h,007h,0b0h,08ah,0b6h,060h,060h,0b0h,0b0h,060h,0b0h,0b0h,060h,060h,006h,0f0h,002h,060h,081h,0b0h,006h,060h,084h,0b6h,0b0h,0b0h,060h,004h,0b0h,002h,060h,006h,0b0h,002h,060h,020h,0f0h,000h	; b898  .`...`...`...`...`...`....``..`..``...`...`....`...`...` ..

; ======================================================================
; CODIGO 0xb8d3..0xbb77  (676 bytes)
; ======================================================================


pide_pieza_si_la_escena_lo_permite:
	di			;b8d3   ; Nada de interrupciones tocando la RAM del sonido
	push hl			;b8d4
	ld hl,0e002h		;b8d5   ; La marca de escena
	bit 6,(hl)		;b8d8   ; Con el bit 6 puesto no suena nada
	jr z,L_B948		;b8da
	jr L_B8E0		;b8dc
pide_pieza:
	di			;b8de   ; Aqui se pide siempre, mire quien mire
	push hl			;b8df
L_B8E0:
	push de			;b8e0
	push bc			;b8e1
	push af			;b8e2
L_B8E3:
	ld c,a			;b8e3   ; C = la pieza que se pide
	ld b,002h		;b8e4   ; Dos voces
	ld d,03fh		;b8e6   ; D = 0x3F: la mascara de la pieza
	ld hl,0e012h		;b8e8   ; La voz 0
	and d			;b8eb
	cp 013h		;b8ec   ; Las piezas por debajo de 0x13...
	jr c,L_B8F7		;b8ee
	cp 019h		;b8f0   ; ...y de 0x19 son cortas
	jr c,L_B90D		;b8f2
	inc b			;b8f4   ; Las demas ocupan tres voces
	jr L_B90D		;b8f5
L_B8F7:
	cp 011h		;b8f7   ; La pieza 0x11 es especial
	jr nz,L_B90A		;b8f9
	ld a,(hl)			;b8fb   ; Que suena ahora
	ld e,a			;b8fc
	ld a,(0e041h)		;b8fd   ; Y que sono antes
	or a			;b900
	jr z,L_B90A		;b901
	cp e			;b903   ; Si es la misma, se deja
	jr z,L_B90A		;b904
	ld a,019h		;b906   ; Si no, se cambia por la 0x19
	jr L_B8E3		;b908
L_B90A:
	ld l,032h		;b90a   ; La voz de los efectos
	dec b			;b90c
L_B90D:
	ld a,(hl)			;b90d   ; La pieza que esta sonando
	and d			;b90e
	ld e,a			;b90f
	cp 013h		;b910   ; Es corta?
	jr c,L_B91A		;b912
	ld a,c			;b914   ; Y la que se pide?
	and d			;b915
	cp 013h		;b916
	jr nc,L_B91F		;b918
L_B91A:
	ld a,c			;b91a
	and d			;b91b   ; Solo entra la de numero mas alto
	cp e			;b91c
	jr c,L_B945		;b91d   ; Si no, se descarta
L_B91F:
	add a,a			;b91f   ; Dos bytes por pieza
	ld de,0bbdah		;b920   ; La tabla de piezas
	call suma_a_a_de		;b923
	dec hl			;b926
	dec hl			;b927
arranca_una_voz:
	ld (hl),001h		;b928   ; Marcar la voz como ocupada
	inc hl			;b92a
	ld (hl),001h		;b92b
	inc hl			;b92d
	ld (hl),c			;b92e   ; Que pieza es
	inc hl			;b92f
	ld a,(de)			;b930   ; Y donde empieza su guion
	ld (hl),a			;b931
	inc hl			;b932
	inc de			;b933
	ld a,(de)			;b934
	ld (hl),a			;b935
	ld a,005h		;b936   ; Cinco bytes mas alla...
	call suma_a_a_hl		;b938
	xor a			;b93b
	ld (hl),a			;b93c   ; ...el paso, a cero
	ld a,007h		;b93d   ; Y siete mas, la voz siguiente
	call suma_a_a_hl		;b93f
	inc de			;b942
	djnz arranca_una_voz		;b943   ; Todas las voces de la pieza
L_B945:
	pop af			;b945
	pop bc			;b946
	pop de			;b947
L_B948:
	pop hl			;b948
	ei			;b949   ; Y a dejar sonar
	ret			;b94a
repite_un_trozo:
	inc hl			;b94b   ; El limite del bucle
	ld a,(ix+009h)		;b94c   ; Cuantas vueltas lleva
	inc a			;b94f
	cp (hl)			;b950   ; Ya son las que pedia?
	jr z,L_B966		;b951
	jp m,L_B957		;b953
	dec a			;b956
L_B957:
	ld (ix+009h),a		;b957   ; Una mas
	inc hl			;b95a
	ld a,(hl)			;b95b   ; Y volver al principio del trozo
	ld (ix+003h),a		;b95c
	inc hl			;b95f
	ld a,(hl)			;b960
	ld (ix+004h),a		;b961
	jr L_B96F		;b964
L_B966:
	inc hl			;b966
	inc hl			;b967
	xor a			;b968   ; Se acabo el bucle: la cuenta a cero
	ld (ix+009h),a		;b969
	call avanza_el_guion		;b96c   ; Y seguir con el guion
L_B96F:
	inc (ix+000h)		;b96f   ; Un paso mas
	jr L_B9C2		;b972
mezclador:
	ld a,(0e040h)		;b974   ; El mezclador
	ld e,a			;b977
	ld a,c			;b978   ; Que voz
	cp 001h		;b979
	jr z,L_B97E		;b97b
	dec a			;b97d
L_B97E:
	rlca			;b97e   ; El bit del ruido va tres posiciones mas alla
	rlca			;b97f
	rlca			;b980
	dec d			;b981   ; Encender o apagar?
	jr z,L_B988		;b982
	cpl			;b984   ; Apagar: quitar el bit
	and e			;b985
	jr escribe_el_mezclador		;b986
L_B988:
	or e			;b988   ; Encender: ponerlo
escribe_el_mezclador:
	ld (0e040h),a		;b989   ; Queda apuntado
	ld e,a			;b98c
	ld a,007h		;b98d   ; El registro 7 del PSG
	jp 00093h		;b98f   ; BIOS WRTPSG - Writes data to PSG-register
suena_el_cuadro:
	ld a,(0e040h)		;b992   ; El mezclador de siempre
	call escribe_el_mezclador		;b995
	ld c,001h		;b998   ; Empezando por la voz 1
	ld ix,0e010h		;b99a   ; Y por la primera de las tres
	exx			;b99e
	ld b,003h		;b99f   ; Las tres voces
	ld de,00010h		;b9a1   ; Dieciseis bytes cada una
L_B9A4:
	exx			;b9a4
	ld a,(ix+002h)		;b9a5   ; Esta voz suena?
	or a			;b9a8
	jr nz,L_B9B0		;b9a9
	call apaga_la_voz_y_dejala_libre		;b9ab   ; No: callarla
	jr L_B9B3		;b9ae
L_B9B0:
	call calla_la_voz_si_lo_pide_la_orden		;b9b0   ; Si: un paso de su guion
L_B9B3:
	inc c			;b9b3   ; La voz siguiente
	inc c			;b9b4
	exx			;b9b5
	add ix,de		;b9b6
	djnz L_B9A4		;b9b8
	ret			;b9ba
calla_la_voz_si_lo_pide_la_orden:
	bit 6,a		;b9bb   ; El bit 6 de la orden
	ld d,001h		;b9bd   ; D = 1: apagar
	call z,mezclador		;b9bf   ; Callar la voz
L_B9C2:
	ld a,(ix+002h)		;b9c2   ; Que pieza lleva esta voz
	or a			;b9c5
	jp m,L_BA52		;b9c6   ; El bit 7 marca las piezas largas
	ld (ix+00bh),000h		;b9c9   ; El destello, a cero
	dec (ix+000h)		;b9cd   ; Un cuadro menos de nota
	ret nz			;b9d0   ; Todavia dura
L_B9D1:
	ld l,(ix+003h)		;b9d1   ; Por donde va el guion
	ld h,(ix+004h)		;b9d4
	ld a,(hl)			;b9d7   ; La orden
	cp 0feh		;b9d8   ; 0xFE abre un bucle
	jp z,repite_un_trozo		;b9da
	jr nc,apaga_la_voz_y_dejala_libre		;b9dd   ; Y 0xFF cierra la pieza
	bit 7,(ix+002h)		;b9df   ; Pieza larga?
	jp nz,orden_larga		;b9e3
	and 0f0h		;b9e6   ; El nibble alto a 2...
	cp 020h		;b9e8
	ld a,(hl)			;b9ea
	jr nz,L_B9F4		;b9eb
	and 00fh		;b9ed   ; ...trae la duracion de la nota
	ld (ix+001h),a		;b9ef
	inc hl			;b9f2
L_B9F3:
	ld a,(hl)			;b9f3
L_B9F4:
	and 0f0h		;b9f4   ; A 1...
	cp 010h		;b9f6
	jr nz,L_BA0B		;b9f8
	ld a,(hl)			;b9fa   ; ...trae el ruido
	and 00fh		;b9fb
	add a,a			;b9fd   ; Por dos: el registro 6 del PSG
	ld e,a			;b9fe
	ld a,006h		;b9ff
	call 00093h		;ba01   ; BIOS WRTPSG - Writes data to PSG-register | Escribirlo
	ld d,000h		;ba04   ; Y encender el ruido en el mezclador
	call mezclador		;ba06
	inc hl			;ba09
	ld a,(hl)			;ba0a
L_BA0B:
	or a			;ba0b   ; Un cero es un silencio
	jr nz,toca_la_nota		;ba0c
	ld b,a			;ba0e   ; Sin nota, sin volumen y sin periodo
	ld d,a			;ba0f
	ld e,a			;ba10
	jr L_BA21		;ba11
toca_la_nota:
	and 0f0h		;ba13   ; El nibble alto es el volumen
	ld b,a			;ba15
	xor (hl)			;ba16   ; Y el bajo, la octava
	ld d,a			;ba17
	inc hl			;ba18
	ld e,(hl)			;ba19   ; Detras va la nota
	ld a,(ix+00bh)		;ba1a   ; Hay destello en marcha?
	or a			;ba1d
	jp nz,L_BB68		;ba1e
L_BA21:
	call avanza_el_guion		;ba21   ; Avanzar el guion
L_BA24:
	ex de,hl			;ba24
	call escribe_las_dos_mitades_del_tono		;ba25   ; El periodo de esa nota
	ld a,b			;ba28
	rrca			;ba29   ; El volumen, al nibble bajo
	rrca			;ba2a
	rrca			;ba2b
	rrca			;ba2c
arranca_la_cuenta_de_la_nota:
	ld h,a			;ba2d
	ld a,(ix+00bh)		;ba2e   ; Con destello no se toca la envolvente
	or a			;ba31
	jr nz,escribe_el_volumen		;ba32
	ld e,(ix+001h)		;ba34   ; La duracion de la nota...
	ld (ix+000h),e		;ba37   ; ...arranca la cuenta
	ld a,(ix+00eh)		;ba3a   ; Y el ataque...
	add a,e			;ba3d
	ld (ix+008h),a		;ba3e   ; ...marca cuando empieza a bajar
	jr escribe_el_volumen		;ba41
apaga_la_voz_y_dejala_libre:
	ld d,001h		;ba43   ; D = 1: apagar
	call mezclador		;ba45
	xor a			;ba48   ; La voz queda libre
	ld (ix+002h),a		;ba49
	ld (ix+00bh),a		;ba4c
	ld h,a			;ba4f
	jr escribe_el_volumen		;ba50
L_BA52:
	dec (ix+000h)		;ba52   ; Un cuadro menos
	jp z,L_B9D1		;ba55   ; Se agoto: a por la orden siguiente
	ld a,(ix+00bh)		;ba58   ; Con destello no hay envolvente
	or a			;ba5b
	jp nz,L_BB5A		;ba5c
	dec (ix+008h)		;ba5f   ; Bajar el volumen
	ld a,(ix+008h)		;ba62
	cp (ix+000h)		;ba65   ; Ha llegado al final de la nota?
	jr nz,L_BA73		;ba68
	ld e,a			;ba6a
	ld a,(ix+00fh)		;ba6b   ; El suelo de la envolvente
	cp e			;ba6e   ; Por debajo no se baja
	ld a,e			;ba6f
	jr nc,L_BA76		;ba70
	ret			;ba72
L_BA73:
	dec (ix+008h)		;ba73   ; Si no, bajar dos
L_BA76:
	ld a,(ix+007h)		;ba76   ; El volumen de ahora
	dec a			;ba79
	ret m			;ba7a   ; Ya esta a cero
	ld (ix+007h),a		;ba7b
	ld h,a			;ba7e
escribe_el_volumen:
	ld a,c			;ba7f   ; La voz...
	rrca			;ba80
	add a,088h		;ba81   ; ...da el registro de volumen del PSG
	ld e,h			;ba83
	call 00093h		;ba84   ; BIOS WRTPSG - Writes data to PSG-register | Escribirlo
	ld a,c			;ba87
	cp 005h		;ba88   ; Solo tras la ultima voz
	ret nz			;ba8a
	ld a,(0e041h)		;ba8b   ; Hay una pieza en cola?
	or a			;ba8e
	ret z			;ba8f
	ld b,a			;ba90
	ld a,(ix+002h)		;ba91
	cp 019h		;ba94   ; Si es la 0x19, se deja
	ret z			;ba96
	xor a			;ba97
	ld (0e041h),a		;ba98   ; Sacarla de la cola...
	ld a,b			;ba9b
	jp pide_pieza		;ba9c   ; ...y pedirla
orden_larga:
	ld a,(hl)			;ba9f   ; La orden
	and 0f0h		;baa0
	cp 0d0h		;baa2   ; Nibble alto a 0xD...
	ld a,(hl)			;baa4
	jr nz,L_BAAE		;baa5
	and 00fh		;baa7   ; ...trae el destello
	ld (ix+00ah),a		;baa9
	inc hl			;baac
	ld a,(hl)			;baad
L_BAAE:
	cp 0f0h		;baae   ; Y a 0xF...
	jr c,L_BACA		;bab0
	and 00fh		;bab2   ; ...la envolvente
	ld (ix+006h),a		;bab4
	inc hl			;bab7
	ld a,(hl)			;bab8
	and 0f0h		;bab9
	rrca			;babb
	rrca			;babc
	rrca			;babd
	rrca			;babe
	ld (ix+00eh),a		;babf
	ld a,(hl)			;bac2
	and 00fh		;bac3
	ld (ix+00fh),a		;bac5
	inc hl			;bac8
	ld a,(hl)			;bac9
L_BACA:
	cp 0e0h		;baca   ; 0xE0..0xEF: el destello
	jr c,L_BAE9		;bacc
	and 00fh		;bace   ; Su nibble bajo
	bit 3,a		;bad0   ; El bit 3 lo enciende
	jr z,L_BAE4		;bad2
	bit 0,a		;bad4   ; Y el bit 0...
	jr nz,L_BADD		;bad6
	ld (ix+00bh),a		;bad8   ; ...dice si es de subida...
	jr L_BAE7		;badb
L_BADD:
	xor a			;badd   ; ...o de bajada
	ld (ix+00bh),a		;bade
	inc hl			;bae1
	jr orden_larga		;bae2
L_BAE4:
	ld (ix+005h),a		;bae4
L_BAE7:
	inc hl			;bae7
	ld a,(hl)			;bae8
L_BAE9:
	and 00fh		;bae9
	ld b,a			;baeb
	ld a,(ix+00ah)		;baec
	jr z,L_BAF6		;baef
L_BAF1:
	add a,(ix+00ah)		;baf1
	djnz L_BAF1		;baf4
L_BAF6:
	ld (ix+001h),a		;baf6   ; La duracion de la nota
	ld a,(hl)			;baf9
	call avanza_el_guion		;bafa   ; Avanzar el guion
	and 0f0h		;bafd   ; El nibble alto...
	rrca			;baff   ; ...bajado a las unidades: el volumen
	rrca			;bb00
	rrca			;bb01
	rrca			;bb02
	ld b,a			;bb03
	ld a,(ix+00bh)		;bb04   ; Hay destello en marcha?
	or a			;bb07
	jr z,L_BB25		;bb08
	ld a,(ix+001h)		;bb0a
	ld (ix+000h),a		;bb0d
	ld a,b			;bb10
	add a,a			;bb11
	ld hl,0bb83h		;bb12
	call suma_a_a_hl		;bb15
	ld e,(hl)			;bb18
	ld (ix+00ch),e		;bb19
	inc hl			;bb1c
	ld d,(hl)			;bb1d
	ld (ix+00dh),d		;bb1e
	ex de,hl			;bb21
	jp L_B9F3		;bb22
L_BB25:
	ld a,b			;bb25
	sub 00ch		;bb26
	jr z,L_BB2D		;bb28
	ld a,(ix+006h)		;bb2a
L_BB2D:
	ld (ix+007h),a		;bb2d
	call arranca_la_cuenta_de_la_nota		;bb30
	ld a,b			;bb33
pon_el_periodo:
	ld hl,0bb77h		;bb34   ; La tabla de doce periodos
	call suma_a_a_hl		;bb37   ; La nota que toca
	ld l,(hl)			;bb3a   ; Su periodo
	ld h,000h		;bb3b
	ld a,(ix+005h)		;bb3d   ; La octava
	or a			;bb40
	jr z,escribe_las_dos_mitades_del_tono		;bb41   ; La cero es la de la tabla
	ld b,a			;bb43
L_BB44:
	add hl,hl			;bb44   ; Cada octava mas es doblar el periodo
	djnz L_BB44		;bb45
escribe_las_dos_mitades_del_tono:
	ld a,c			;bb47
	ld e,h			;bb48
	call 00093h		;bb49   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,c			;bb4c
	dec a			;bb4d
	ld e,l			;bb4e
	jp 00093h		;bb4f   ; BIOS WRTPSG - Writes data to PSG-register
avanza_el_guion:
	inc hl			;bb52
	ld (ix+003h),l		;bb53
	ld (ix+004h),h		;bb56
	ret			;bb59
L_BB5A:
	ld l,(ix+00ch)		;bb5a   ; Por donde va el guion del destello
	ld h,(ix+00dh)		;bb5d
	ld a,(hl)			;bb60
	cp 0ffh		;bb61   ; El 0xFF lo cierra
	jr z,L_BB72		;bb63
	jp L_B9F3		;bb65   ; Y si no, seguir
L_BB68:
	inc hl			;bb68   ; Un paso mas
	ld (ix+00ch),l		;bb69
	ld (ix+00dh),h		;bb6c
	jp L_BA24		;bb6f
L_BB72:
	ld h,000h		;bb72
	jp escribe_el_volumen		;bb74

; ----------------------------------------------------------------------
; DATOS periodos_de_las_doce_notas: la octava mas alta; `pon_el_periodo`
;   (0xBB34) indexa por nota y luego duplica el valor una vez por octava con
;   `add hl,hl`
;   0xbb77..0xbb83  (12 bytes)
DATA_periodos_de_las_doce_notas:
	defb 06bh,065h,05fh,05ah,055h,050h,04ch,047h,043h,040h,03ch,039h	; bb77  ke_ZUPLGC@<9

; ----------------------------------------------------------------------
; DATOS tabla_de_envolventes: cuatro punteros, indexados por 0xBB12
;   0xbb83..0xbb8b  (8 bytes)
DATA_tabla_de_envolventes:
	defw 0bb8bh,0bb8fh,0bba8h,0bbbdh	; bb83  -> DATA_las_cuatro_envolventes 0xbb8f 0xbba8 0xbbbd

; ----------------------------------------------------------------------
; DATOS las_cuatro_envolventes: parejas de (volumen y canal, tiempo) cerradas
;   con 0xFF
;   0xbb8b..0xbbdc  (81 bytes)
DATA_las_cuatro_envolventes:
	defb 010h,0d0h,000h,0ffh,0b1h,000h,0a1h,00ah	; bb8b  ........
	defb 091h,015h,081h,020h,081h,02ah,081h,035h	; bb93  ... .*.5
	defb 081h,040h,081h,04ah,081h,055h,081h,060h	; bb9b  .@.J.U.`
	defb 081h,06ah,081h,075h,0ffh,0b1h,095h,0a1h	; bba3  .j.u....
	defb 08ah,091h,080h,081h,075h,081h,06ah,081h	; bbab  ....u.j.
	defb 060h,081h,055h,081h,04ah,081h,040h,081h	; bbb3  `.U.J.@.
	defb 035h,0ffh,0b2h,000h,0a2h,00ah,092h,015h	; bbbb  5.......
	defb 082h,020h,082h,02ah,082h,035h,082h,040h	; bbc3  . .*.5.@
	defb 082h,04ah,082h,055h,082h,060h,082h,06ah	; bbcb  .J.U.`.j
	defb 082h,075h,082h,080h,082h,08ah,082h,095h	; bbd3  .u......
	defb 0ffh	; bbdb

; ----------------------------------------------------------------------
; DATOS tabla_de_piezas: 39 punteros; `arranca_una_voz` entra aqui con el
;   numero de pieza por dos (0xB920)
;   0xbbdc..0xbc2a  (78 bytes)
DATA_tabla_de_piezas:
	defw 0bc2ah,0bc47h,0bc66h,0bc7ch,0bc9eh,0bcadh,0bcb7h,0bcc1h	; bbdc
	defw 0bcd0h,0bce1h,0bcf8h,0bcfdh,0bd02h,0bd1fh,0bd2eh,0bd31h	; bbec
	defw 0bd3fh,0bd60h,0bd6ch,0bd82h,0bdaah,0be1eh,0be93h,0bebah	; bbfc
	defw 0bf6bh,0bf6bh,0bd3fh,0bf6bh,0bf6bh,0beech,0bef6h,0bf09h	; bc0c
	defw 0bf1ch,0bf2fh,0bf43h,0bf58h,0bf6bh,0bf6bh,0bf6bh	; bc1c

; ----------------------------------------------------------------------
; DATOS las_treinta_y_nueve_piezas: la musica y los efectos, uno detras de
;   otro; el ultimo acaba justo en 0xBF6C, donde vuelve a haber codigo
;   0xbc2a..0xbf6c  (834 bytes)
DATA_las_treinta_y_nueve_piezas:
	defb 023h,014h,050h,001h,000h,060h,001h,000h,070h,001h,000h,080h,001h,000h,090h,001h	; bc2a  #.P..`..p.......
	defb 000h,0a0h,001h,000h,0b0h,001h,000h,0c0h,001h,000h,026h,000h,0ffh,018h,080h,000h	; bc3a  ..........&.....
	defb 01ch,0a0h,000h,013h,0e0h,000h,01ah,080h,000h,022h,000h,021h,011h,080h,000h,01ah	; bc4a  .........".!....
	defb 0a0h,000h,013h,0b0h,000h,01ch,090h,000h,017h,080h,000h,0ffh,01fh,091h,070h,018h	; bc5a  ..............p.
	defb 0a1h,045h,010h,0c1h,000h,022h,012h,0b1h,018h,015h,0a1h,030h,01fh,091h,050h,081h	; bc6a  .E...".....0..P.
	defb 080h,0ffh,0d7h,033h,022h,000h,021h,010h,0f2h,055h,01fh,0f3h,055h,01dh,0f4h,055h	; bc7a  ...3".!..U..U..U
	defb 01ah,0d5h,055h,022h,01fh,0b5h,055h,0a5h,055h,095h,055h,021h,0c0h,000h,000h,0feh	; bc8a  ..U"..U.U.U!....
	defb 007h,095h,0bch,0ffh,022h,010h,0e0h,005h,015h,0b0h,005h,019h,0b0h,000h,0feh,007h	; bc9a  ...."...........
	defb 09eh,0bch,0ffh,010h,0b0h,000h,012h,0f0h,000h,010h,0c0h,000h,0ffh,010h,0f0h,005h	; bcaa  ................
	defb 01fh,0f2h,055h,000h,0f2h,005h,0ffh,080h,08ah,0a0h,091h,0c0h,08dh,023h,000h,021h	; bcba  ..U..........#.!
	defb 0e0h,075h,0d0h,077h,0d0h,07ah,0c0h,07fh,0c0h,084h,0b0h,08ch,0b0h,093h,0a0h,09bh	; bcca  .u.w.z..........
	defb 0a0h,0a5h,090h,0b0h,090h,0c0h,0ffh,01fh,0f0h,000h,000h,01ch,0f0h,000h,000h,019h	; bcda  ................
	defb 0f0h,000h,000h,016h,0f0h,000h,013h,0f0h,000h,023h,010h,0f0h,000h,0ffh,0f2h,0e8h	; bcea  .........#......
	defb 0a1h,000h,0ffh,0f3h,030h,0a1h,030h,0ffh,023h,012h,0f0h,021h,000h,0e0h,021h,000h	; bcfa  ....0.0.#..!..!.
	defb 0c0h,021h,000h,0a0h,021h,000h,090h,021h,000h,080h,021h,000h,070h,021h,000h,060h	; bd0a  .!..!..!..!.p!.`
	defb 021h,000h,050h,021h,0ffh,021h,0b0h,050h,022h,000h,021h,0a0h,05dh,02dh,000h,0feh	; bd1a  !.P!.!.P".!.]-..
	defb 008h,01fh,0bdh,0ffh,0a0h,050h,0ffh,024h,091h,01dh,090h,0d5h,090h,0a9h,090h,08eh	; bd2a  .....P.$........
	defb 0feh,002h,031h,0bdh,0ffh,024h,082h,000h,0f1h,000h,0e0h,07fh,000h,0d1h,000h,0c0h	; bd3a  ..1..$..........
	defb 07fh,000h,0b1h,000h,0a0h,07fh,000h,091h,000h,080h,07fh,000h,071h,000h,060h,07fh	; bd4a  ............q.`.
	defb 000h,051h,000h,027h,000h,0ffh,023h,090h,087h,080h,078h,090h,06dh,0feh,003h,060h	; bd5a  .Q.'..#...x.m..`
	defb 0bdh,0ffh,0d8h,0e8h,001h,000h,000h,013h,001h,000h,000h,023h,001h,000h,000h,013h	; bd6a  ...........#....
	defb 001h,031h,031h,031h,0feh,0ffh,06ch,0bdh,0d8h,0fdh,033h,0e3h,021h,000h,021h,0e4h	; bd7a  .111..l...3.!.!.
	defb 070h,080h,090h,0c3h,0e3h,007h,0c9h,0d2h,0fch,033h,0e0h,020h,0c2h,020h,0c2h,0d8h	; bd8a  p........3. . ..
	defb 0fdh,033h,0e3h,021h,0cdh,001h,0c7h,0e4h,091h,0e3h,001h,011h,0feh,0ffh,082h,0bdh	; bd9a  .3.!............
	defb 0e9h,0d7h,0fbh,023h,0e1h,090h,070h,092h,020h,040h,070h,020h,040h,020h,000h,0e2h	; bdaa  ...#..p. @p @ ..
	defb 091h,0e1h,001h,041h,020h,000h,0e2h,091h,0e1h,041h,020h,000h,0e2h,091h,091h,040h	; bdba  ...A ....A ....@
	defb 070h,093h,071h,097h,090h,0e1h,000h,023h,001h,045h,041h,071h,095h,0e0h,001h,0e1h	; bdca  p.q....#.EAq....
	defb 072h,090h,042h,070h,020h,040h,020h,000h,021h,041h,073h,041h,071h,095h,0e0h,001h	; bdda  r.Bp @ .!AsAq...
	defb 022h,040h,002h,020h,020h,000h,0e1h,090h,0e0h,000h,0e1h,071h,040h,070h,097h,0e8h	; bdea  "@.  ......q@p..
	defb 000h,000h,000h,000h,013h,000h,000h,000h,000h,033h,000h,000h,000h,000h,023h,000h	; bdfa  .........3....#.
	defb 000h,000h,000h,033h,0e9h,0fah,022h,0e3h,09fh,0e2h,00fh,0e3h,0bdh,040h,070h,09fh	; be0a  ...3.."......@p.
	defb 0feh,0ffh,0aah,0bdh,0d7h,0fbh,033h,0e1h,040h,020h,042h,0e2h,090h,0b0h,0e1h,020h	; be1a  ......3.@ B.... 
	defb 0e2h,090h,0b0h,090h,070h,041h,001h,0e3h,041h,0e2h,041h,021h,001h,0e3h,001h,0e2h	; be2a  ....pA..A.A!....
	defb 001h,0e3h,091h,071h,0e4h,091h,0e3h,091h,041h,091h,0feh,002h,03eh,0beh,0e4h,071h	; be3a  ...q....A...>..q
	defb 0e3h,071h,021h,071h,0e4h,091h,0e3h,091h,041h,091h,0feh,003h,04eh,0beh,0e4h,071h	; be4a  .q!q....A...N..q
	defb 0e3h,071h,021h,071h,0e4h,091h,0e3h,091h,041h,091h,0e4h,051h,0e3h,051h,001h,051h	; be5a  .q!q....A..Q.Q.Q
	defb 0e4h,071h,0e3h,071h,021h,0e2h,001h,0e4h,091h,0e3h,091h,041h,091h,0feh,002h,071h	; be6a  .q.q!......A...q
	defb 0beh,0fdh,033h,0e4h,091h,090h,090h,0e3h,021h,001h,0e4h,091h,090h,090h,0e3h,041h	; be7a  ..3.....!......A
	defb 021h,0feh,006h,07bh,0beh,0feh,0ffh,01eh,0beh,0e9h,0d3h,0fah,000h,0e0h,090h,0c0h	; be8a  !..{............
	defb 0feh,00ch,093h,0beh,0c0h,0d5h,0f9h,024h,0e2h,0c5h,021h,020h,000h,0feh,018h,0a4h	; be9a  .......$..! ....
	defb 0beh,041h,040h,020h,0feh,007h,0abh,0beh,040h,070h,040h,030h,0feh,0ffh,0a4h,0beh	; beaa  .A@ ....@p@0....
	defb 0d3h,0fah,000h,0e0h,0c1h,0feh,00ch,0bah,0beh,0c0h,0dah,0fch,022h,0e4h,090h,0e3h	; beba  ............"...
	defb 000h,010h,020h,0c1h,000h,0c8h,0feh,003h,0c4h,0beh,0e4h,090h,0e3h,000h,020h,040h	; beca  .. ........... @
	defb 0c1h,020h,0c3h,0d5h,0fbh,037h,0e4h,071h,070h,060h,071h,070h,060h,071h,0feh,0ffh	; beda  . ...7.qp`qp`q..
	defb 0c4h,0beh,021h,013h,0e1h,055h,022h,000h,015h,0e1h,088h,0ffh,0e9h,0d8h,0fbh,033h	; beea  ..!..U"........3
	defb 0e1h,090h,070h,092h,020h,040h,070h,020h,040h,020h,000h,0e2h,094h,0c3h,0ffh,0d8h	; befa  ..p. @p @ ......
	defb 0fbh,033h,0e1h,040h,020h,042h,0e2h,090h,0b0h,0e1h,020h,0e2h,090h,0b0h,090h,070h	; bf0a  .3.@ B.... ....p
	defb 044h,0ffh,0d1h,0fah,033h,0e2h,0c0h,0d8h,090h,070h,092h,020h,040h,070h,020h,040h	; bf1a  D...3....p. @p @
	defb 020h,000h,0e3h,094h,0ffh,0e9h,0d8h,0fbh,033h,0e1h,090h,070h,092h,020h,040h,070h	; bf2a   .......3..p. @p
	defb 0d9h,020h,040h,0dah,020h,000h,0e2h,094h,0ffh,0d8h,0fbh,033h,0e1h,040h,020h,042h	; bf3a  . @. ......3.@ B
	defb 0e2h,090h,0b0h,0e1h,020h,0d9h,0e2h,090h,0b0h,0dah,090h,070h,044h,0ffh,0d8h,0fch	; bf4a  .... ......pD...
	defb 033h,0e4h,091h,0e3h,091h,020h,041h,070h,0d9h,020h,040h,0dah,020h,000h,0e4h,094h	; bf5a  3.... Ap. @. ...
	defb 0ffh,0ffh	; bf6a

; ======================================================================
; CODIGO 0xbf6c..0xbfd9  (109 bytes)
; ======================================================================


prepara_y_vuelve_a_mi_ranura:		; Rastrea las ranuras y deja la pagina 1 como estaba
	call busca_el_yie_ar_kung_fu_i		;bf6c   ; Buscar el cartucho hermano
	ld a,(0e451h)		;bf6f   ; La ranura de este cartucho, guardada por INIT
	ld h,040h		;bf72   ; H = 0x40: la pagina 1
	jp 00024h		;bf74   ; BIOS ENASLT - Switches to specified slot and page definitively | Y volver a dejarla como estaba
busca_el_yie_ar_kung_fu_i:		; Recorre las cuatro ranuras primarias y sus subranuras
	xor a			;bf77   ; De entrada, no esta
	ld (0e450h),a		;bf78
	ld hl,0fcc1h		;bf7b   ; La tabla de subranuras de la BIOS
	ld b,004h		;bf7e   ; Las cuatro ranuras primarias
	ld c,000h		;bf80   ; Empezando por la 0
L_BF82:
	push hl			;bf82
	push bc			;bf83
	ld a,(hl)			;bf84   ; Que hay en esta
	and a			;bf85
	jp m,L_BF8F		;bf86   ; Con el bit 7 puesto hay subranuras
	ld a,c			;bf89   ; Sin subranuras: mirarla y ya
	call mira_esta_ranura		;bf8a
	jr L_BF9F		;bf8d
L_BF8F:
	and 080h		;bf8f   ; Con subranuras: quedarse el bit de expandida
	or c			;bf91
	ld b,004h		;bf92   ; Y mirar las cuatro
L_BF94:
	push bc			;bf94
	push af			;bf95
	call mira_esta_ranura		;bf96
	pop af			;bf99
	add a,004h		;bf9a   ; La subranura siguiente va cuatro mas alla
	pop bc			;bf9c
	djnz L_BF94		;bf9d
L_BF9F:
	pop bc			;bf9f
	inc c			;bfa0   ; La ranura siguiente
	pop hl			;bfa1
	inc hl			;bfa2
	djnz L_BF82		;bfa3
	ret			;bfa5
mira_esta_ranura:		; Conmuta la pagina 1 a esa ranura y le toma las dos sumas
	ld h,040h		;bfa6   ; H = 0x40: la pagina 1
	call 00024h		;bfa8   ; BIOS ENASLT - Switches to specified slot and page definitively | Conmutarla a esa ranura
	ld hl,05300h		;bfab   ; La suma de 16 bytes desde 0x5300...
	call suma_dieciseis_bytes		;bfae
	ld d,a			;bfb1   ; ...en D
	ld hl,06700h		;bfb2   ; Y la de 0x6700...
	call suma_dieciseis_bytes		;bfb5
	ld e,a			;bfb8   ; ...en E
	ld b,002h		;bfb9   ; Las dos compilaciones conocidas
	ld hl,0bfd9h		;bfbb   ; Sus dos parejas de sumas
L_BFBE:
	ld a,(hl)			;bfbe   ; La primera suma de esta pareja
	inc hl			;bfbf
	cp d			;bfc0   ; Cuadra?
	jr nz,L_BFCD		;bfc1
	ld a,(hl)			;bfc3   ; Y la segunda?
	cp e			;bfc4
	jr nz,L_BFCD		;bfc5
	ld a,001h		;bfc7   ; Las dos: esta el cartucho hermano
	ld (0e450h),a		;bfc9
	ret			;bfcc
L_BFCD:
	inc hl			;bfcd   ; La pareja siguiente
	djnz L_BFBE		;bfce
	ret			;bfd0
suma_dieciseis_bytes:		; A = suma de los 16 bytes desde (HL)
	ld b,010h		;bfd1   ; Dieciseis bytes
	xor a			;bfd3   ; Empezando en cero
L_BFD4:
	add a,(hl)			;bfd4   ; Sumar sin acarreo: da igual, solo hace de firma
	inc hl			;bfd5
	djnz L_BFD4		;bfd6
	ret			;bfd8

; ----------------------------------------------------------------------
; DATOS firmas_del_yie_ar_kung_fu_i: dos parejas de sumas: 5A 47 la
;   compilacion facil, 23 70 la dificil
;   0xbfd9..0xbfdd  (4 bytes)
DATA_firmas_del_yie_ar_kung_fu_i:
	defb 05ah,047h	; bfd9
	defb 023h,070h	; bfdb

; ----------------------------------------------------------------------
; DATOS relleno_hasta_la_marca: veinte bytes 0xFF; el ultimo byte util antes
;   de la marca es el 0xBFDC
;   0xbfdd..0xbff1  (20 bytes)
DATA_relleno_hasta_la_marca:
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bfdd  ................
	defb 0ffh,0ffh,0ffh,0ffh	; bfed

; ----------------------------------------------------------------------
; DATOS marca_oculta_de_konami: el titulo en katakana del reves, su longitud
;   (0x0C, doce), el 0x37 de RC-737 y el 0xAA que cierra
;   0xbff1..0xc000  (15 bytes)
DATA_marca_oculta_de_konami:
	defb 032h,000h,0bah,09bh,0ach,085h,0b9h,0a8h,080h,0b9h,0bah,081h,00ch,037h,0aah	; bff1  2............7.
