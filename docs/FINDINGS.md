# Findings

## The cartridge looks for its own first part in the next slot

The very first thing INIT does, before it even installs the interrupt hook, is
call `0xBF6C`. There sits a slot scan: it walks the four primary slots from
`0xFCC1`, descends into subslots when bit 7 asks for it, switches **page 1** of
each with `ENASLT` and takes **two 16-byte sums**, one from `0x5300` and one
from `0x6700`.

It compares them against the two pairs written at `0xBFD9`:

    5A 47   Yie Ar Kung-Fu (RC-725), the easy build
    23 70   Yie Ar Kung-Fu (RC-725), the hard build

It recognises **the two builds separately**. Running those same two sums over
the other ROMs in this series matches none of them, so the identification is not
a guess.

If it finds it, `(0xE450) = 1`. The **only** place in the game that reads that
flag is `0x74A3`, and it also demands **round 3 or later** (`0xE053`) and a
**single player** (bit 5 of `0xE002`, tested at `0x732F`). The reward is four
bytes copied from `0x74F1` and a 3x4 tile figure at `0x7525`, which `0x7518`
paints at row 6, column 14.

This is not the Game Master header: that is a cartridge reading a *cheat
device*. This is a game looking for **another game**. If Konami did it once it
may be in more places, and the trail is a very early `call` out of INIT that
touches `0xFCC1` and `ENASLT`.

## Half a screen and a mirror

`0x597F` builds the fight screen from forty scripts pointed at by forty pointers
spread over six contiguous tables, `0x592F` to `0x597E`. The mapping is exact
and the twenty pattern/colour pairs dump the same amount of VRAM, all twenty of
them.

But only half of it is drawn. `0x5A4D` copies three stretches of the pattern
table onto themselves through `vuelve_los_bits`, and the right half of the
scenery is the same drawings with all eight bits reversed. That is why **colour
is written twice and the pattern once** — the mirror never touches colour — and
the arithmetic checks out on all three bands: `0x0560-0x0260 = 0x300` and the
other two `0x3C0`, exactly the offset of each copy.

## Two figure readers that look alike and are not

`0x67F5` and `0x67A7` read the same format except for the `0xE0..0xEF` order,
and there they differ in both ways at once: the first repeats the byte that
follows and takes two bytes, the second writes zeros and takes one.

Mixing them up does not blow up: it gives a figure that almost fits and overruns
by two or three bytes per figure. What proves which is which is that the
**thirty wave figures fit only the first** and the rivals' blocks only the
second.

## The eight rivals

Each scenery has its own, and they hang off two tables of eight indexed the same
way: `0x6922` for the frames and `0x7FDB` for the behaviour. Each block is 22
pointers closing at 44 bytes, and the **168 stretches between consecutive
entries close with no gap and no overlap** — all 168 of them.

The **odd frame is the even one facing the other way**: the `bit 0,a` at
`0x677C` follows a two-byte pointer instead of reading a drawing, and the same
bit negates x at `0x686A`.

## The fighter is eight sprites, and half of him is computed

One LEE YOUNG frame is four HIT BOXES plus up to eight `[y][x][pattern]`
triples, hanging off the twenty pointers at `0x6C83` — ten drawings in the even
entries and ten two-byte redirections in the odd ones.

Facing one way the eight sprites use **patterns 0 to 7**, which `0x6BE6` uploads
to `0x1800` following up to fifteen scripts carried by the frame itself; facing
the other, the triples carry pattern numbers landing in the **mirrored** bank
that `espeja_sprites` (`0x490C`) left behind. One drawing, two directions, only
one half stored.

Those four leading entries have a sprite's shape -`[y][x]` and two more bytes-
and that is what makes them easy to mistake for one, but they are not: they land
in `0xE120`, and the RAM sprite attribute table is `0xE080..0xE0FF`, the `0x80`
bytes that `0x500F` parks with `0xE0` in the y. What reads them is the collision
code: `se_tocan` (`0x654F`) walks **three** four-byte boxes -twelve bytes, exactly
what the first three entries take- and adds the third byte to the first and the
fourth to the second to get both edges.

The sprite scripts **start two bytes earlier** than they look: the word that
reads like a tail belongs in front and is the VRAM destination `guion_rle`
(`0x48E1`) consumes. Corrected from `0xA490` to `0xA48E`, and confirmed by a
second route — the 34 script pointers carried by the player's frames all land on
script starts computed independently.

## A wave screen is four bytes

The strip at `0x5BE8` for that backdrop carries eight nibbles in four bytes;
each one picks one of the thirty figures at `0x5C64`, and the eight are painted
in a row four columns apart. Even ones come from the low nibble and odd ones
from the high one, which is what the `bit 0,b` at `0x5B9F` says.

## Rounds wrap at eight, and the strip has ten

`0x44E4` fills `0xE2C0` with ten sceneries, 0 to 9 in order. But `0x430F`
increments the round and `0x4311` compares it against 8, wrapping to zero. The
last two entries of the strip are never read.

## The lives trick

`0x43B8` keeps the first ten key presses since power-on and compares them
against the ten bytes at `0x43ED`:

    01 04 04 02 02 02 08 08 08 08

With the PSG bit layout that reads **up once, left twice, down three times and
right four**, a 1-2-3-4. If it matches, `(0xE055)` goes from 3 lives to `0x95`.

## Two players: the second pad drives the rival

The five bits of `(0xE052)` go straight into the table of 32 at `0x7DA2`,
exactly the way the player's own go into `0x6990`. With one player, `0x7E7E`
makes them up.

## The seven entries per scenery are distance bands, not states

`0x6E1D` subtracts the two x positions and sorts the result into seven bands
with six cuts — three fixed and three read from the strip at `0x6E5F`. So each
scenery has **its own reach**, and what looked like a state machine is a
distance table.

## One row higher than asked for

`pon_la_figura_en_la_pantalla` (`0x66F1`) steps down 32 tiles **`row - 1`**
times, because of the `dec a` at `0x66FB`. A figure asked for at row 4 starts at
row 3, and row 0 is the exception because the `jr z` at `0x66F9` skips the loop.

It is not a curiosity: without it the title logo lands four rows too low and
three columns too far left, and the VRAM comparison says so — 165 tiles wrong
before, 0 after.

## The hidden mark, and the second header

The last fifteen bytes, closing at `0xBFFF`, carry `RC-737` and the title in
katakana written backwards. It is the mark **Manuel Pazos** found in Konami's
cartridges, and this one has it.

There is also a second header at `0x4010`, `"AB" 07 37`, for the **Konami Game
Master** in the other slot. The cartridge never reads it itself.

## Code nobody calls

Five routines — `0x47B0`, `0x4875`, `0x488A`, `0x544F` and `0x6EB5` — are named
by no `call`, no `jp` and no table.

## Two captions that were being read wrong

- `0x447B` says **LEE YOUNG**, the fighter you control, and the eight at
  `0x4497` are the rivals' names. They had been read as one run of nine scripts,
  which added up in bytes — `0x447B + 94 = 0x44D9` — but the second half is not
  a script: it is the table of eight pointers plus the first name.
- `0x572A` is not the pause caption: it says **PERFECT 5000**, and it is only
  painted when the round ends with the bar full (`0x5328` against `0x24`).
