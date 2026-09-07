# Yie Ar Kung-Fu II (Konami, MSX1) — a commented disassembly

*(También [en castellano](README.es.md).)* ·
**[Read it on the web](https://antxiko.github.io/YieArKungFu2-disassembly/)**

A complete, commented disassembly of Konami's **Yie Ar Kung-Fu II: The Emperor
Yie-Gah** for the MSX (RC-737, 32 KB, 1985). Every one of the 32,768 bytes is
accounted for, and the listing reassembles into the ROM **byte for byte**.

    explained          32,768 of 32,768   100 %
    comment density    2,919 of 7,142     40.9 %
    blocks below 10 %        0 of 1,027
    tests                   44, green
    reassembly         same sha256 as the cartridge

## What is here

    src/yiear2.asm       the commented listing, generated
    src/yiear2.notes     the comments and the data blocks, with their measure
    src/yiear2.entries   the entry points that cannot be deduced statically
    tools/               the tools: trace, listing, pictures, VRAM check
    tests/               44 checks that do not need the cartridge
    docs/                the bilingual website

## The cartridge is not here

`yiear2.rom` is not distributed. Put your own copy in the root; it is exactly
32,768 bytes and

    sha256  bcb41b35ec0dddfd81ee9bd46998c0ea9c9435d6292e973d46c1324cc36e6150

## Reproducing it

    make comprueba     # checks your ROM is the same one
    make               # listing, reassembly, sanity checks and tests
    make imagenes      # draws the screens and the figures from the ROM
    make vram          # checks those pictures against openMSX's VRAM

## Not one screen capture

Every picture in this repository is **drawn from the bytes of the ROM**, by
running in Python the same scripts, mirrors and figure readers the Z80 runs.
And they are checked byte for byte against the emulator's VRAM: **nine screens,
zero differences** in colour (6,144 bytes), patterns (6,144) and sprite
patterns (1,792). The title screen matches its name table as well, 768 of 768
tiles.

## What turned up

- **The cartridge looks for its own first part in the next slot.** Before it
  installs the interrupt hook it scans the four slots and takes two 16-byte
  sums, and it tells the two builds of Yie Ar Kung-Fu (RC-725) apart.
- **Half a screen and a mirror**: the scenery is drawn only on the left, and
  the right half is the same patterns with all eight bits reversed. Which is
  why colour is written twice and the pattern once.
- **The fighter is twelve sprites**, and one of his two directions is computed
  from the other rather than stored.
- **A wave screen is four bytes**: eight nibbles picking eight of thirty
  figures.
- **The lives trick**: up once, left twice, down three times, right four.
- **The demo is a recorded game**: 33 key presses and their durations.

The lot, with its measurements, in
[Findings](https://antxiko.github.io/YieArKungFu2-disassembly/FINDINGS.html),
and what is *not* known in
[Open questions](https://antxiko.github.io/YieArKungFu2-disassembly/OPEN-QUESTIONS.html).

## Licence and credit

The tools, comments, analysis and documentation are MIT — see `LICENSE`. The
game is not ours: read [LEGAL-NOTICE.md](LEGAL-NOTICE.md).

Konami's hidden mark was uncovered by **Manuel Pazos**.
