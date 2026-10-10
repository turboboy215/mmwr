# Mega Man: Dr. Wily's Revenge — disassembly

A work-in-progress full disassembly of **Mega Man: Dr. Wily's Revenge** (Game Boy,
Capcom / Minakuchi Engineering, 1991) in RGBDS assembly.

The build is **byte-perfect**: `./build.sh` reassembles the source and checks the
result against the original ROM byte for byte. Every byte of real content is now
source (step 7.1), and since step 7.2 nothing in the source reads the base ROM at
all; `baserom.gb` is needed only for the final byte-for-byte check.

## Building

You need [RGBDS](https://rgbds.gbdev.io/) 0.9 or newer and the original US ROM.

```
cp "Megaman - Dr. Wily's Revenge (U) [!].gb" baserom.gb
./build.sh            # POSIX
make.bat              # Windows
```

Expected base ROM:

```
sha256  33d16365318411f063edd9100c79458aabb7ea71bb1873e30f38b93814f0ec6e
sha1    277edb3c844e812ba4b3eb9a96c9c30414541858
md5     4ba4398181d98958fa7434ba7716f11a
crc32   47e70e08
size    262144 bytes (16 banks, MBC1, no SRAM)
```

The ROM is **not** in this repository and never will be.

## Layout

```
build.sh make.bat        build and verify (POSIX / Windows)
main.asm                 the only file rgbasm is pointed at; includes everything
engine/                  banks $00 and $01, split by subsystem (vblank, objects, sprites,
                         weapons, items, player, pause menu, HUD, ...)
engine/objects/          one file per object type (bank $09 so far) and its entry table
engine/object_library.asm  helpers shared by the object banks $03, $09 and $0D
engine/cutscenes/        bank $0B, the Wily cutscenes
engine/ending/           bank $0E, the ending
data/                    data tables (object tables, graphics pointers, font, frames)
data/stages/             one editable file per decoded stage (docs/LEVELS.md)
banks/bank**.asm         banks $01-$0F; bank $01's file is now just its include list
audio/bank02.asm         sound engine + music/SFX set A   (100% disassembled)
audio/bank0a.asm         music/SFX set B                  (100% disassembled)
constants/               hardware.inc, audio and RAM constants
macros/                  project macros (stages.inc: the stage data macros)
ram/                     WRAM/HRAM layout
gfx/                     PNG sources, converted by rgbgfx at build time
tools/                   coverage report, helper disassembler, bank generator, RGBDS bootstrap
docs/                    the plan, conventions, bank map, progress log
```

`banks/` is the holding pen. As a region is understood it moves out into
`engine/`, `data/` or `gfx/` under a name that says what it is. Bank `$00` has
made the move, and banks `$01` and `$09` since steps 5.1 and 5.2: each file holds one or more
sections pinned to their original addresses, so a file can group a subsystem even
when its code is not contiguous.

## Documentation

* **[docs/SESSION_START.md](docs/SESSION_START.md)** — read this first every session.
* **[docs/PLAN.md](docs/PLAN.md)** — the phased plan, one step per session.
* **[docs/CONVENTIONS.md](docs/CONVENTIONS.md)** — naming and style rules.
* **[docs/BANKS.md](docs/BANKS.md)** — what is in each bank, and how banking works.
* **[docs/ROMMAP.md](docs/ROMMAP.md)** — Data Crystal's map, audited against the ROM.
* **[docs/RAMMAP.md](docs/RAMMAP.md)** — what every known RAM address is for.
* **[docs/LEVELS.md](docs/LEVELS.md)** — the stage data format; renders in `docs/levels/`.
* **[docs/UNUSED.md](docs/UNUSED.md)** — unused stages, songs and sounds.
* **[docs/VERSIONS.md](docs/VERSIONS.md)** — how the US, European and Japanese dumps differ.
* **[docs/PROGRESS.md](docs/PROGRESS.md)** — coverage numbers and the session log.

## Credits and provenance

* Audio engine and all music/SFX data (banks `$02` and `$0A`) — disassembled by
  **Will Trowbridge**, imported from his standalone Game Boy sound player project.
  Verified here as reproducing both banks with zero differing bytes.
* The initial skeleton for the remaining banks — labels, section layout and the
  `freespace`/`bankswitch` macros — is ported from **iimarckus**'s unfinished
  multi-game disassembly at <https://github.com/iimarckus/megaman>, modernized for
  current RGBDS (see `docs/PROGRESS.md` for exactly what changed).
* `constants/hardware.inc` is the community [hardware.inc](https://github.com/gbdev/hardware.inc) (CC0).
