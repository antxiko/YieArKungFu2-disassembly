# Getting started

Everything here is reproducible. The listing is not stored as a finished file
you have to trust: it is **generated** from the cartridge, and reassembling it
gives the cartridge back byte for byte.

## What you need

    python3        3.8 or later, no libraries
    pasmo          to reassemble
    z80dasm        to disassemble
    make
    openMSX        only for the emulator checks

## The cartridge is not distributed

This repository does not ship the game. Put the ROM in the root of the project
as `yiear2.rom`, 32,768 bytes exactly, and check it is the same one:

    make comprueba

    bcb41b35ec0dddfd81ee9bd46998c0ea9c9435d6292e973d46c1324cc36e6150  yiear2.rom

## The whole thing

    make

That runs four steps in order:

| step | what it does |
|---|---|
| `listado` | traces the flow from the declared entry points and writes `src/yiear2.asm` |
| `verify` | reassembles it with pasmo and compares sha256 against the ROM |
| `sanity` | the four checks a reassembly cannot make |
| `test` | the repository's own tests |

`verify` is the one that decides whether the disassembly is trustworthy:

    == ensamblando src/yiear2.asm (org 0x4000) ==
      ensamblado : 32768 bytes  bcb41b35...
      original   : 32768 bytes  bcb41b35...
    OK: reproducible byte a byte

## What a reassembly cannot catch

Reading data as code produces the same bytes. `make sanity` is what catches
that, and it is four separate checks:

- **no byte declared as data may come out as code** — `check_trace.py` and
  `check_datos_como_codigo.py`;
- **no entry point may land inside a data range** — `check_entradas.py`, nine
  entry points against 160 declared data ranges;
- **not one byte of the cartridge left unassigned** — `presupuesto.py`, which
  has to add up to 32,768.

## The pictures

    make imagenes

`tools/graficos.py` and `tools/figuras.py` build the screens by running in
Python the same scripts, mirrors and figure readers the Z80 runs. There is not
one screen capture in this repository.

## And the check that closes the doubt

    make vram

This boots the cartridge in openMSX, lets its own demo play, dumps the 16 KB of
VRAM at nine moments and subtracts the VRAM that Python built. Looking at a
picture is not enough; this is.

    9 pantallas cotejadas, 0 bytes distintos en las tablas estaticas

## The rest of the targets

| target | what it is for |
|---|---|
| `make densidad` | how much of the listing is commented, and which routines fall short |
| `make sonda` | which scene the cartridge is in at each emulated second |
| `make web` | rebuilds the pictures and regenerates this site |
