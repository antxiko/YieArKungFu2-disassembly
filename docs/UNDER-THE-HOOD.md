# Under the hood

## Getting started

Everything here is reproducible. The listing is not stored as a finished file
you have to trust: it is **generated** from the cartridge, and reassembling it
gives the cartridge back byte for byte.

### What you need

    python3        3.8 or later, no libraries
    pasmo          to reassemble
    z80dasm        to disassemble
    make
    openMSX        only for the emulator checks

### The cartridge is not distributed

This repository does not ship the game. Put the ROM in the root of the project
as `yiear2.rom`, 32,768 bytes exactly, and check it is the same one:

    make comprueba

    bcb41b35ec0dddfd81ee9bd46998c0ea9c9435d6292e973d46c1324cc36e6150  yiear2.rom

### The whole thing

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

### What a reassembly cannot catch

Reading data as code produces the same bytes. `make sanity` is what catches
that, and it is four separate checks:

- **no byte declared as data may come out as code** — `check_trace.py` and
  `check_datos_como_codigo.py`;
- **no entry point may land inside a data range** — `check_entradas.py`, nine
  entry points against 160 declared data ranges;
- **not one byte of the cartridge left unassigned** — `presupuesto.py`, which
  has to add up to 32,768.

### The pictures

    make imagenes

`tools/graficos.py` and `tools/figuras.py` build the screens by running in
Python the same scripts, mirrors and figure readers the Z80 runs. There is not
one screen capture in this repository.

### And the check that closes the doubt

    make vram

This boots the cartridge in openMSX, lets its own demo play, dumps the 16 KB of
VRAM at nine moments and subtracts the VRAM that Python built. Looking at a
picture is not enough; this is.

    9 pantallas cotejadas, 0 bytes distintos en las tablas estaticas

### The rest of the targets

| target | what it is for |
|---|---|
| `make densidad` | how much of the listing is commented, and which routines fall short |
| `make sonda` | which scene the cartridge is in at each emulated second |
| `make web` | rebuilds the pictures and regenerates this site |

## The cartridge

    file       yiear2.rom
    size       32,768 bytes
    sha256     bcb41b35ec0dddfd81ee9bd46998c0ea9c9435d6292e973d46c1324cc36e6150
    catalogue  RC-737
    machine    MSX1

### Where it lives

A 32 KB cartridge in **pages 1 and 2**, `0x4000..0xBFFF`. No paging, no mapper:
all 32 KB are there at once and the Z80 sees the lot.

### The two headers

The first is the usual one: at `0x4000` sit the `"AB"` signature and the address
of INIT, which here is `0x4070`. STATEMENT, DEVICE and TEXT are zero, and so are
the six reserved bytes.

The second, at `0x4010`, is not an MSX thing: it is the **Konami Game Master**
header, for the house's cheat cartridge that plugs into the other slot. It is
`"AB" 07 37` — the `0x07` of the RC-7xx range and the `0x37` of RC-737 — and
behind it come seven addresses, the variables the Game Master is allowed to
touch:

| address | what it is |
|---|---|
| `0x6400` | the routine the Game Master hooks |
| `0xE000` | the scene |
| `0xE002` | the scene flags |
| `0xE055` | the lives |
| `0xE066` | the round |
| `0xE048` | the score |
| `0xE04E` | the score of the player in play |

This cartridge **never reads it**: `tools/quien_lee.py` gives zero references to
`0x4010..0x4025`. It is there for the cartridge next door.

### The hidden mark

The last fifteen bytes, closing exactly at `0xBFFF`:

    FF 32 00 BA 9B AC 85 B9 A8 80 B9 BA 81 0C 37 AA

Behind them are `RC-737` and the title in **katakana, written backwards**. It is
the mark **Manuel Pazos** found in Konami's cartridges — the RC number and the
Japanese title tucked into the last bytes of the ROM — and this one carries it.
`tools/marca_konami.py` reads it and `tools/busca_marca_konami.py` looks for it
anywhere in the image.

### What INIT does, in order

`0x4070`, and the order matters:

1. asks the BIOS which primary slot it is in (`RSLREG`), works out its own
   slot and subslot from `0xFCC1` and stores the result in `(0xE451)`;
2. switches **page 2** to that same slot with `ENASLT`, so all 32 KB answer;
3. calls `prepara_y_vuelve_a_mi_ranura` — the **slot scan that looks for the
   first part, Yie Ar Kung-Fu (RC-725)**, in the other slots, and it happens
   before anything else;
4. writes a `jp cada_cuadro` into the interrupt hook at `0xFD9A`;
5. puts the stack at `0xE400` and clears `0xE000..0xE3FF`;
6. turns the screen on, enables interrupts and falls into `jr $`.

From that `jr $` onwards nothing happens in the main flow: **the whole game
hangs off the interrupt**.

### The VDP

`pon_los_registros_del_vdp` (`0x4952`) writes eight bytes from `0x4963` into
registers 0 to 7:

    02 E2 0E 7F 07 76 03 E4

Which gives, and this is the part that surprises:

| table | address |
|---|---|
| colour | `0x0000..0x17FF` |
| sprite patterns | `0x1800..0x1FFF` |
| patterns | `0x2000..0x37FF` |
| names | `0x3800..0x3AFF` |
| sprite attributes | `0x3B00` |

**The banks are the other way round from usual**: patterns at `0x2000` and
colour at `0x0000`. R3 and R4 are not addresses but base and mask, and reading
them as addresses is what puts the colour table where the patterns are. The
practical consequence is all over the code: the same drawing is two scripts with
the same offset and `0x2000` between them, as in `monta_la_pantalla_de_combate`,
which loads `0x01F0` and `0x21F0` with the same shape.

R7 is `0xE4`: border and everything transparent come out **colour 4**, dark
blue. Sprites are 16x16 (bit 1 of R1).

### The RAM

Everything the game uses sits from `0xE000` up:

| range | what it is |
|---|---|
| `0xE000..0xE00F` | scene, subscene, frame counter, waits, controls |
| `0xE04A..0xE066` | score, level, lives, round |
| `0xE080..0xE0FF` | the copy of the sprite attribute table |
| `0xE100..0xE1FF` | the fighter, the rival and their figures |
| `0xE2C0..0xE2E0` | the strip of scenery per round, and the current backdrop |
| `0xE400` | the stack, growing downwards |
| `0xE450..0xE451` | the mark of the first part, and this cartridge's own slot |

Note that `0xE450` and `0xE451` are **above** the block INIT clears
(`0xE000..0xE3FF`), and that is not an accident: the slot scan writes them
before the clear.

## The code

    13,725 bytes of code   41.89 %
    19,043 bytes of data   58.11 %
         0 unexplained      0.00 %
     1,027 code blocks measured, none below 10 % commented
       430 of the 1,168 labels carry a name; the rest are internal jumps
     7,142 instructions, 2,923 line comments — 40.9 %

### Everything hangs off the interrupt

INIT ends in `jr $` at `0x40C1`. From there on nothing happens in the main flow:
`0x409B` has written a `jp cada_cuadro` into the hook at `0xFD9A`, and
`cada_cuadro` (`0x402E`) is the whole game.

It reads the VDP status to clear the interrupt request, plays one frame of
sound, and guards itself with `(0xE005)` so a frame that takes too long does not
re-enter. Then it reads the pads and calls `haz_el_cuadro`.

### One scene, one subscene, and one indirect jump

`haz_el_cuadro` (`0x40CB`) counts the frame and dispatches on `(0xE000)`, the
scene, through the eight-entry table at `0x40E9`. Inside each scene the same
trick repeats with `(0xE001)`, the subscene, and always through the same
routine:

    reparte_por_tabla:
        pop hl        ; the table IS the return address
        add a,a
        ...
        jp (hl)

`reparte_por_tabla` (`0x4066`) pops its own return address to find the table,
which is why in the listing every dispatch table sits **immediately after the
`call`**. And that `jp (hl)` at `0x406F` is the **only indirect jump in the
cartridge**: everything else is decidable statically.

There is one more twist. Before dispatching, `0x40D4` pushes a *finisher* —
`0x47AF` if bit 6 of `(0xE002)` is set, `0x4358` if not — so the scene returns
into it without knowing.

### The eight scenes

| `(0xE000)` | at | what it is |
|---|---|---|
| 0 | `0x40F9` | the presentation, with the sign coming down |
| 1 | `0x4131` | the title screen and PLAY SELECT |
| 2 | `0x413E` | the game, and the demonstration |
| 3 | `0x416B` | the wait before a game |
| 4 | `0x41C5` | starting a round |
| 5 | `0x4240` | between rounds |
| 6 | `0x425E` | the endings |
| 7 | `0x433A` | game over |

### The four data formats

Nothing in this cartridge is stored flat. Everything is a script, and all four
readers are translated in `tools/formatos.py`:

**Literal script** — `guion_literal` (`0x48C8`). A word of VRAM destination and
then tiles, one at a time; `0xFE` closes the stretch and opens another with a
new destination, `0xFF` closes the script. The same routine also **erases**: the
`and c` at `0x48D6` with `C = 0` turns everything written into zeros, and that
is `borra_guion`.

**RLE script** — `guion_rle` (`0x48E1`). `0x01..0x7F` repeats the byte that
follows N times, `0x81..0xFF` copies the N bytes that follow, `0x80` closes the
stretch and opens another with a new destination, `0x00` closes the script.
`vuelca_el_guion_con_destino_en_hl` is the same thing with the destination already in HL.

Careful with the `0x80`. Reading it as "does nothing" gives a script that also
seems to fit — `0x49F5` came out as 53 bytes and landed cleanly on `0x4A2A`,
skipping the script at `0x4A06` on the way, and it even spat out readable text.
What gives it away is that the whole chain of consecutive scripts only closes
with no gaps and no overlaps on the right reading.

**Figure** — two of them, and they are not the same. Both read height and width
first and both treat `0xF0..0xFF` as an ascending run, but the `0xE0..0xEF`
order differs **in both ways at once**: `0x67F5` repeats the byte that follows
and takes two bytes, `0x67A7` writes **zeros** and takes one. The first draws
the wave figures, the second the rivals'.

### Building a screen

`monta_la_pantalla_de_combate` (`0x597F`) is the clearest piece of code in the
cartridge. First what never changes — the frame and the icons — then the three
bands and the floor, each from its own pair of tables among the six laid end to
end from `0x592F` to `0x597E`.

Colour goes up **twice** and the pattern **once**, and the reason is the mirror:
`espeja_el_decorado` (`0x5A4D`) copies three stretches of the pattern table over
themselves through `vuelve_los_bits`, so every band tile has a reversed twin.
The offsets check out: `0x0560-0x0260 = 0x300` and the other two `0x3C0`,
exactly the distance of each copy. The screen itself is not symmetric: the
name-table scripts use the twins only where they want them (see the
[findings](CURIOSITIES.html)).

The name table is filled separately: row 3 by `pinta_la_fila_3_y_los_dos_nombres`, rows 5 and down by
`monta_el_decorado_o_la_oleada`, and the bottom two rows only for backdrops 0 and 3.

### The figures on screen

`pinta_la_figura` (`0x66D8`) unpacks a figure into `0xE480` and sends it to the
name table row by row, clipping what falls off each side — the `add a,c` at
`0x670C` when the column is negative and the `sub 020h` at `0x671C` when it runs
past 32.

Two details that are easy to get wrong, and both were measured against the
emulator:

- the position comes in `(0xE170)` **row** and `(0xE171)` **column**, in that
  order, because `ld (nn),bc` puts C first;
- the loop at `0x66FD` steps down **`row - 1`** times, so a figure asked for at
  row 4 starts at row 3. Row 0 is the exception: the `jr z` at `0x66F9` skips
  the loop.

### Sound

`suena_el_cuadro` runs one frame of music per interrupt, and `pide_pieza` picks
the tune. The PSG mixer goes through `escribe_el_mezclador`, and
`suena_con_pantalla_apagada` (`0x40C3`) clears bit 6 of the copy of the VDP
register at `0x4964` so a beep can play with the screen off.

### Code nobody calls

Five routines — `0x47B0`, `0x4875`, `0x488A`, `0x544F` and `0x6EB5` — are named
by no `call`, no `jp` and no table. They are declared in `src/yiear2.entries`
with the reason written down, so the tracer treats them as code and they do not
end up as a wall of bytes in the middle of the listing.

## In the emulator

Everything here was measured on **openMSX** with a **Philips VG-8020**, the
machine this series uses.

    openmsx -machine Philips_VG_8020 -cart yiear2.rom

### The cartridge plays itself

You do not have to play to measure it. From a cold start it chains
presentation → title → **demonstration**, and the demonstration is a *recorded
game*: 33 key presses at `0x57E4` with their durations at `0x5806`, ending in
the `0xFF` that `0x57DA` looks for. Two power-ons give exactly the same thing,
which is what makes any of this comparable.

`make sonda` writes down which scene it is in at each emulated second:

    t=  5.00 escena=  0 sub=  0     the presentation
    t= 12.00 escena=  1 sub=  0     the title
    t= 17.00 escena=  2 sub=  0     the game starts
    t= 22.00 escena=  2 sub=  1     the demonstration, fighting
    t= 41.00 escena=  0 sub=  1     and round again

### Getting to all eight sceneries without playing

The demonstration always fights in the first one. `0x5776` leaves the round at
zero and writes the scenery into `(0xE2C0)` three instructions before it builds
the screen, so a breakpoint at `0x5784` — with the zero already written — can
put whichever one is wanted there, and the cartridge then builds **that**
backdrop, **that** floor and **that** rival with its own code.

Nothing is faked: one byte of the game state is changed, the way a player
arriving at that round would have it. That is what `tools/omsx_vram.tcl` does,
and it is how the eight fight screens on this site were checked.

### The check that closes the doubt

    make vram

It dumps the 16 KB of VRAM at nine moments, and `tools/coteja_vram.py`
subtracts the VRAM that `tools/vram.py` builds in Python:

| screen | colour | sprite patterns 8-63 | patterns |
|---|---|---|---|
| the title | 0/6144 | 0/1792 | 0/6144 |
| sceneries 1 to 8 | 0/6144 | 0/1792 | 0/6144 |

**Nine screens, zero bytes different in every static table.** The title screen
matches its name table as well, 768 of 768 tiles.

Two regions are left out of that count on purpose, because they are not static
and the emulator is mid-game when the dump happens:

- **sprite patterns 0 to 7** (`0x1800..0x18FF`), which are the fighter's live
  pose — `sube_los_patrones_del_fotograma` (`0x6BE6`) rewrites them whenever the
  frame changes;
- **the name table**, where the rival, the scoreboard and the energy bar are
  repainted every frame.

### What took the longest to get right

Three things, and none of them shows up as a wrong-looking picture:

1. **The cartridge only clears the name table when the scene changes.** Not the
   patterns, not the colour. Building one screen from scratch left hundreds of
   bytes different that were not a misreading but *inheritance that was
   missing*; the comparison only closes at zero when the whole chain from
   power-on is replayed.
2. **Scenery 4 carries a phase marker and the other seven do not** — the
   `cp 003h` at `0x5A7A`, right at the tail of `espeja_el_decorado`.
3. **The row/column pair is stored the other way round from how it reads.**
   `ld bc,00704h` followed by `ld (0e170h),bc` means row 4, column 7, and the
   loop at `0x66FD` then paints it one row higher. Before fixing that, the title
   screen had 165 tiles wrong; after, zero.

### Seeing the extras

**The lives trick.** From power-on, before touching anything else, press up
once, left twice, down three times and right four times. `(0xE055)` goes to
`0x95`.

**The first part in the other slot.** Plug Yie Ar Kung-Fu (RC-725) into the
second slot, play a single-player game and reach level 3. The extra shows up
when both energy bars are nearly empty. To see it without getting that far:
`debug write memory 0xE450 1`, `0xE053 3`, `0xE100 8` and `0xE102 12`.

**The soup.** It comes out in phase 3, single player, by STRIKING at the round's
spot -the pair `0x5027` leaves in `(0xE300)`-. To see it without hunting for the
spot, put a breakpoint at `0x7402` that writes the player's own strike box,
`(0xE12C)` minus two, into `0xE300`.

### Poking around

`tools/omsx_sonda.tcl` is the pattern to copy for any measurement: a timer that
reads a handful of bytes of RAM per emulated second and writes them out.
Execution breakpoints are cheap; write watchpoints are cheap in normal play but
must have a cheap callback.

## Code shared with other Konami cartridges

This disassembly has been compared, instruction by instruction, with
every other Konami one in the series. A block counts when the same
instructions, at least six of them from a label to its `ret` or its
unconditional jump, are in both cartridges; the addresses are left
aside, because they change from one cartridge to the next. Of the
other 57, **54** have at least one block in common with this one;
these are the ones that share the most:

| Cartridge | Blocks | Instructions | For example (here = there) |
|---|---:|---:|---|
| [Yie Ar Kung-Fu](https://antxiko.github.io/YieArKungFu-disassembly/) | 35 | 370 | `lee_las_filas_7_y_8_del_teclado` (0x4997) = `lee_el_teclado` |
| [The Goonies](https://antxiko.github.io/Goonies-disassembly/) | 29 | 319 | `guion_rle` (0x48E1) |
| [Knightmare](https://antxiko.github.io/Knightmare-disassembly/) | 28 | 261 | `pinta_guion` (0x48C6) = `pinta_texto` |
| [Hyper Sports 3](https://antxiko.github.io/HyperSports3-disassembly/) | 25 | 284 | `lee_las_filas_7_y_8_del_teclado` (0x4997) = `teclado_del_jugador_1` |
| [Konami's Ping Pong](https://antxiko.github.io/KonamisPingPong-disassembly/) | 25 | 284 | `lee_las_filas_7_y_8_del_teclado` (0x4997) = `lee_teclado_1` |
| [Konami’s Soccer](https://antxiko.github.io/KonamisSoccer-disassembly/) | 25 | 276 | `cada_cuadro` (0x402E) = `latido` |
| [Nemesis / Gradius](https://antxiko.github.io/Nemesis-disassembly/) | 23 | 228 | `guion_rle` (0x48E1) = `descomprime_con_destino` |
| [Q\*bert](https://antxiko.github.io/Qbert-disassembly/) | 22 | 241 | `guion_rle` (0x48E1) |
| [Road Fighter](https://antxiko.github.io/RoadFighter-disassembly/) | 21 | 245 | `guion_rle` (0x48E1) = `descomprime_con_destino_dentro` |
| [Nemesis 2](https://antxiko.github.io/Nemesis2-disassembly/) | 19 | 199 | `guion_rle` (0x48E1) = `descomprime_otra_direccion` |

The whole matrix, the 58 cartridges against each other, is on
[The routines](https://antxiko.github.io/MSX-disassembly-database/THE-ROUTINES.html) in the series database, along
with the method and the program that measures it.
