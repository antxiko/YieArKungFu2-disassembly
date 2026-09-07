# Open questions

The listing is complete: 32,768 bytes, none unexplained. That does not mean
everything about the cartridge is known. What is not, is here.

## What the first part actually gets you

`0x74A3` is the only reader of the flag the slot scan leaves at `(0xE450)`, and
it copies four bytes from `0x74F1` and calls `0x7518`, which paints the 3x4
figure at `0x7525` at row 6, column 14. That much is read off the code.

What has **not** been done is recording it: two cartridges in openMSX, a
single-player game, round 3 or later, and a capture of what appears. Until that
is done, what the extra *means* in play is not settled — and this series does
not put guesses on a page.

## Where the wave screens get their tiles

`monta_la_oleada` (`0x5B70`) is read and checked: four strips of twelve bytes,
eight nibbles each picking one of the thirty figures at `0x5C64`, painted four
columns apart. The tests verify all of it off the bytes.

What does **not** work is drawing one. Built on top of the VRAM the fight
screen leaves, those figures ask for tiles that are the font there, and the
result reads as `1PLAYER` and `2PLAYERS`. So something else loads patterns
before a wave screen and it has not been found: nothing in the round-start
path (`0x50BB`) does it, and outside mode 3 that path skips the floor and the
well script.

Two attempts, and then a stop. There is no picture of a wave screen on this
site, because what is not understood is not published.

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
