# Findings

## The game checks Yie Ar Kung-Fu (RC-725) in the second slot

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
flag is `0x74A3`, and it also demands **level 3 or later** (`0xE053`), a
**single player** (bit 5 of `0xE002`, tested at `0x732F`) and phase 3.

**And what it gives is now known.** It shows up when **both** energy bars are
nearly empty -the player's below 9 and the rival's below 13, out of `0x24`
full-: a 4x3 tile sign (`0x7525`, row 6 column 14) and a **drink** that comes
down, the sprite from the four bytes at `0x74F1`.

![The sign and the two items](imagenes/cartel.png)

Taking it jumps to `0x738C` with B = 1: `0x10` rest frames and, when they run
out, `0x7356` puts the **player's** bar back to `0x24`. The rival's is left
alone, and since `(0xE266)` is 1 nobody loses a life. Measured in openMSX: the
bars go from `(0x08, 0x0C)` to `(0x24, 0x0C)`.

And it has **nothing to do with the soup**: they are two separate items in two
separate attributes -`0xE250` for the soup, `0xE254` for the drink- and the
neighbour flag does not appear anywhere along the soup's path.

This is not the Game Master header: that is a cartridge reading a *cheat
device*. This is a game looking for **another game**. If Konami did it once it
may be in more places, and the trail is a very early `call` out of INIT that
touches `0xFCC1` and `ENASLT`.

## The soup: you must STRIKE a different spot in every round

The steaming bowl that makes you invulnerable for a while does not come out at
random, and the spot is not the same in every round.

![The two items that drop](imagenes/piezas.png)

At the start of a round `0x5027` copies into `0xE300` the pair that belongs to
it from a table of **eight** at `0x507A`, two bytes per round: **row and
column**. That table was already in the listing, with nobody knowing what it
was for.

    round 1   (0x7E, 0x80)      round 5   (0x9E, 0x90)
    round 2   (0x8E, 0xE0)      round 6   (0x68, 0x10)
    round 3   (0x68, 0xD8)      round 7   (0x68, 0x80)
    round 4   (0x8E, 0x03)      round 8   (0x8E, 0x80)

Then, one frame in two, `0x73FD` asks whether the player is there. But it does
not look at where the figure is: it looks at `0xE12C`, the **fourth** of the
four boxes built by `0x684A` -the **strike** box, the very one `0x53B3` uses to
decide whether the player reaches the rival-. It has to fall inside an **11x11**
window starting two beyond that pair.

And that fourth box **does not exist in every frame**:

![The point of the blow](imagenes/golpes.png)

Of the ten drawings at `0x6C83` only 1, 3, 5 and 6 carry it, and those are the
**four attacks**. In the other six the script has `0x80`, `0x684A` leaves the
box at zero and the `and a` at `0x65C6` knocks it out. So standing on the spot
is not enough: **you have to strike** there.

On top of that, only in **phase 3** of the round -`0x733E` demands
`(0xE107) = 3`, which is what the table at `0x508A` gives for `(0xE060) = 3`-
and with a **single player** (`0x732F`).

**What it gives.** `(0xE29E) = 0xA8`, counting down by one every other frame:
six and a half seconds at 50 Hz. While it is not zero:

| where | what stops happening |
| --- | --- |
| `0x53F4` | the player's blow does not count |
| `0x5588` | the rival throws nothing |
| `0x566F` | whatever was already flying gets caught instead of hitting |
| `0x7734` | the slots cannot be broken |
| `0x798C` | nothing touches the player |
| `0x6C1E` | and the figure blinks |

`coge_el_premio` also adds 5 to the hundreds byte of the score: 500 points. And
**once per round only**: when it runs out, `0x7496` sets `(0xE261) = 1` and
scene 0 stops asking.

**Checked in openMSX.** During the demo `(0xE300) = (0x7E, 0x80)`, the first
pair of the table. Moving the spot onto the player -without touching a byte of
the cartridge- makes the bowl drop, and touching it sets `0xE29E` to `0xA8`,
counting down to zero at 25 a second.

Along the way, the listing had two routines called `mira_la_invulnerabilidad`
and `baja_la_invulnerabilidad` that are **not** that: they read `0xE181`, which
is the **grab** counter. That is why it drops four at a time while the fire
button is held: that is struggling free. They have been renamed.

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
