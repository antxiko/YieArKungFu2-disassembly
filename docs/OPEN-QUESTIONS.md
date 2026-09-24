# Open questions

The listing is complete: 32,768 bytes, none unexplained. That does not mean
everything about the cartridge is known. What is not, is here.

## ~~What the first part actually gets you~~

**CLOSED** on 2026-09-09, at theNestruo's request. It is a **drink** that
refills the player's energy bar when both bars are nearly empty, and the sign at
`0x7525` is its announcement. Measured in openMSX with `(0xE450) = 1`: the bars
go from `(0x08, 0x0C)` to `(0x24, 0x0C)`. It is in the
[findings](FINDINGS.html).

## ~~Where the wave screens get their tiles~~

**CLOSED** on 2026-09-24, at theNestruo's request (issue #2). From the fight
screen's own bands: the twelve wave screens dump the same patterns and colours
as the fights, byte for byte, in openMSX (`tools/omsx_oleadas.tcl`). What was
wrong was the reader here — the nibbles backwards, and the curtain at `0x41D1`
that wipes the title before a game starts was missing — not the cartridge. The
twelve are in [the game](THE-GAME.html).

## Is any other Konami cartridge doing the same?

The slot scan at `0xBF6C` is a game looking for **another game**, which is not
the Game Master mechanism. The obvious question is whether it appears anywhere
else in the RC-7xx range. The trail to follow is a very early `call` out of INIT
that touches `0xFCC1` and `ENASLT`.

Not checked across the rest of the series yet.

## What decides which build of the first part matters

The scan tells the two builds of RC-725 apart, `5A 47` for the easy one and
`23 70` for the hard one, and stores the same `1` in `(0xE450)` either way. So
the cartridge goes to the trouble of recognising two builds separately and then
does not distinguish them. Whether that is a leftover, a second table that was
never used, or something read elsewhere, is not known.

## The two unread sceneries

`0x44E4` fills the strip at `0xE2C0` with ten sceneries, 0 to 9, but the round
wraps at eight (`0x4311`). Entries 8 and 9 are never read. Whether that is a
leftover from a longer game or just a round number is not known.

## The endings

Scene 6 (`0x425E`) handles the endings and `0x58F9` holds their captions, which
read as a congratulation. They have not been reached in play here, so what the
sequence looks like end to end is described from the code and not from having
seen it.
