# In the emulator

Everything here was measured on **openMSX** with a **Philips VG-8020**, the
machine this series uses.

    openmsx -machine Philips_VG_8020 -cart yiear2.rom

## The cartridge plays itself

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

## Getting to all eight sceneries without playing

The demonstration always fights in the first one. `0x5776` leaves the round at
zero and writes the scenery into `(0xE2C0)` three instructions before it builds
the screen, so a breakpoint at `0x5784` — with the zero already written — can
put whichever one is wanted there, and the cartridge then builds **that**
backdrop, **that** floor and **that** rival with its own code.

Nothing is faked: one byte of the game state is changed, the way a player
arriving at that round would have it. That is what `tools/omsx_vram.tcl` does,
and it is how the eight fight screens on this site were checked.

## The check that closes the doubt

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

## What took the longest to get right

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

## Seeing the extras

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

## Poking around

`tools/omsx_sonda.tcl` is the pattern to copy for any measurement: a timer that
reads a handful of bytes of RAM per emulated second and writes them out.
Execution breakpoints are cheap; write watchpoints are cheap in normal play but
must have a cheap callback.
