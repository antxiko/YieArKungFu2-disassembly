# The cartridge

    file       yiear2.rom
    size       32,768 bytes
    sha256     bcb41b35ec0dddfd81ee9bd46998c0ea9c9435d6292e973d46c1324cc36e6150
    catalogue  RC-737
    machine    MSX1

## Where it lives

A 32 KB cartridge in **pages 1 and 2**, `0x4000..0xBFFF`. No paging, no mapper:
all 32 KB are there at once and the Z80 sees the lot.

## The two headers

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

## The hidden mark

The last fifteen bytes, closing exactly at `0xBFFF`:

    FF 32 00 BA 9B AC 85 B9 A8 80 B9 BA 81 0C 37 AA

Behind them are `RC-737` and the title in **katakana, written backwards**. It is
the mark **Manuel Pazos** found in Konami's cartridges — the RC number and the
Japanese title tucked into the last bytes of the ROM — and this one carries it.
`tools/marca_konami.py` reads it and `tools/busca_marca_konami.py` looks for it
anywhere in the image.

## What INIT does, in order

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

## The VDP

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

## The RAM

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
