# The code

    13,725 bytes of code   41.89 %
    19,043 bytes of data   58.11 %
         0 unexplained      0.00 %
     1,027 named routines, none below 10 % commented
     7,142 instructions, 2,919 line comments — 40.9 %

## Everything hangs off the interrupt

INIT ends in `jr $` at `0x40C1`. From there on nothing happens in the main flow:
`0x409B` has written a `jp cada_cuadro` into the hook at `0xFD9A`, and
`cada_cuadro` (`0x402E`) is the whole game.

It reads the VDP status to clear the interrupt request, plays one frame of
sound, and guards itself with `(0xE005)` so a frame that takes too long does not
re-enter. Then it reads the pads and calls `haz_el_cuadro`.

## One scene, one subscene, and one indirect jump

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

## The eight scenes

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

## The four data formats

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
`L_48E7` is the same thing with the destination already in HL.

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

## Building a screen

`monta_la_pantalla_de_combate` (`0x597F`) is the clearest piece of code in the
cartridge. First what never changes — the frame and the icons — then the three
bands and the floor, each from its own pair of tables among the six laid end to
end from `0x592F` to `0x597E`.

Colour goes up **twice** and the pattern **once**, and the reason is the mirror:
`espeja_el_decorado` (`0x5A4D`) copies three stretches of the pattern table over
themselves through `vuelve_los_bits`, and the right half of the scenery is the
same drawings reversed. The offsets check out: `0x0560-0x0260 = 0x300` and the
other two `0x3C0`, exactly the distance of each copy.

The name table is filled separately: row 3 by `L_5B42`, rows 5 and down by
`L_5B4E`, and the bottom two rows only for backdrops 0 and 3.

## The figures on screen

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

## Sound

`suena_el_cuadro` runs one frame of music per interrupt, and `pide_pieza` picks
the tune. The PSG mixer goes through `escribe_el_mezclador`, and
`suena_con_pantalla_apagada` (`0x40C3`) clears bit 6 of the copy of the VDP
register at `0x4964` so a beep can play with the screen off.

## Code nobody calls

Five routines — `0x47B0`, `0x4875`, `0x488A`, `0x544F` and `0x6EB5` — are named
by no `call`, no `jp` and no table. They are declared in `src/yiear2.entries`
with the reason written down, so the tracer treats them as code and they do not
end up as a wall of bytes in the middle of the listing.
