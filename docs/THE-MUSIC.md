# The music

Everything you hear here comes from running the cartridge's own sound engine (`suena_el_cuadro`, 0xB992, and `pide_pieza`, 0xB8DE, which hands it the voices; the interrupt calls it) on an emulated Z80, frame by frame at 60 per second, just as the game calls it. What the engine writes to the PSG is turned into sound with an AY-3-8910 (`tools/musica.py`). Each MP3 is the whole piece up to where it starts again, plus 8 seconds of the repeat fading out; those that do not repeat end where the engine ends.

## Checked against openMSX

The PSG writes have been compared frame by frame with those of openMSX (C-BIOS MSX1 japonés). In every frame the PSG ends up the same:

- tune 0x9F, whole, 170 frames, twice;
- tune 0x93, its first 298 frames of 513, and in stretches of 181, 126, 155 frames and others, depending on when another request cuts in.

The timbre is not checked: it is a textbook AY-3-8910, not a recording of the emulator. The probes are `tools/omsx_psg.tcl` and `tools/coteja_psg.py`.

## How a piece is asked for

`pide_pieza` takes the number in A. Low numbers are effects and from 0x84 up there is music. Each voice takes sixteen bytes from 0xE010 and 0xE040 holds the copy of the PSG mixer, which start-up leaves at 0xB8. The tracks marked «in the table» are in the track table but no routine asks for them with an `ld a`; 0x94, several minutes long, is left out. The game asks for pieces through two entries: `pide_pieza` and `pide_pieza_si_la_escena_lo_permite`, which jumps into the same routine; with both watched, and with the sound RAM as it was when each piece was asked for, every stretch agrees with openMSX.

## The tunes

**The tune at 0x41B5** (0x9F)

Asked for by `L_41B5` y `L_422B`; lasts 2.8 s.

<audio controls preload="none" src="audio/musica_9F.mp3?v=321c7c8a"></audio>

**The tune at 0x41D1** (0x93)

Asked for by `L_41D1`; lasts 8.6 s and starts again at second 0.0.

<audio controls preload="none" src="audio/musica_93.mp3?v=fba0a250"></audio>

**The tune at 0x424D** (0xA2)

Asked for by `L_424D`; lasts 2.6 s.

<audio controls preload="none" src="audio/musica_A2.mp3?v=e4a16457"></audio>

**The tune at 0x50B9** (0x95)

Asked for by `L_50B9`; lasts 41.1 s and starts again at second 14.9.

<audio controls preload="none" src="audio/musica_95.mp3?v=d11af31c"></audio>

**Table track 0x84** (0x84)

Asked for by ninguna llamada directa: está en la tabla de pistas; lasts 11.6 s and starts again at second 11.2.

<audio controls preload="none" src="audio/musica_84.mp3?v=4a05a9ec"></audio>

**Table track 0x96** (0x96)

Asked for by ninguna llamada directa: está en la tabla de pistas; lasts 24.3 s and starts again at second 14.9.

<audio controls preload="none" src="audio/musica_96.mp3?v=b0aa8de1"></audio>

**Table track 0x9D** (0x9D)

Asked for by ninguna llamada directa: está en la tabla de pistas; lasts 29.9 s.

<audio controls preload="none" src="audio/musica_9D.mp3?v=b0c0cc74"></audio>

**Table track 0x9E** (0x9E)

Asked for by ninguna llamada directa: está en la tabla de pistas; lasts 29.9 s.

<audio controls preload="none" src="audio/musica_9E.mp3?v=8e1554d5"></audio>

**Table track 0xA0** (0xA0)

Asked for by ninguna llamada directa: está en la tabla de pistas; lasts 2.6 s.

<audio controls preload="none" src="audio/musica_A0.mp3?v=cdfe6351"></audio>

**Table track 0xA1** (0xA1)

Asked for by ninguna llamada directa: está en la tabla de pistas; lasts 2.6 s.

<audio controls preload="none" src="audio/musica_A1.mp3?v=a1da126b"></audio>

**Table track 0xA3** (0xA3)

Asked for by ninguna llamada directa: está en la tabla de pistas; lasts 2.6 s.

<audio controls preload="none" src="audio/musica_A3.mp3?v=ed34a4fc"></audio>

**Table track 0xA4** (0xA4)

Asked for by ninguna llamada directa: está en la tabla de pistas; lasts 2.6 s.

<audio controls preload="none" src="audio/musica_A4.mp3?v=5b894ecb"></audio>
