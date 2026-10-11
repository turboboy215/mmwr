# Mega Man: Dr. Wily's Revenge — disassembly

![build: byte-perfect](https://img.shields.io/badge/build-byte--perfect-brightgreen)
![source: 100%](https://img.shields.io/badge/source-100%25-brightgreen)
![RGBDS 0.9.4](https://img.shields.io/badge/RGBDS-0.9.4-blue)

<!-- Once this repository is on GitHub, replace the first badge with the live one
from .github/workflows/build.yml:
![build](https://github.com/OWNER/REPO/actions/workflows/build.yml/badge.svg) -->

A complete, labelled disassembly of **Mega Man: Dr. Wily's Revenge** (Game Boy,
Capcom / Minakuchi Engineering, 1991, US release) in RGBDS assembly.

The build is **byte-perfect**: `./build.sh` reassembles the source and checks the
result against the original ROM. All 256 KB is source - code, data, graphics
(PNG), stages (macros), music and sound - and nothing in the source reads the
base ROM. Every routine has a descriptive name with a confidence tag, and the
docs below describe every data format, RAM address and bank.

## Building

You need [RGBDS](https://rgbds.gbdev.io/) 0.9 or newer (`tools/bootstrap-rgbds.sh`
builds 0.9.4 from source on Linux).

```
./build.sh            # POSIX
make.bat              # Windows (needs baserom.gb)
```

With the original ROM copied in as `baserom.gb`, `build.sh` compares the output
byte for byte; without it, it checks the output's SHA-256 - the same test, since
the source no longer needs the ROM. `.github/workflows/build.yml` runs exactly
that on every push.

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
engine/objects/          one file per object type (banks $03, $09, $0D) and their entry tables
engine/object_library.asm  helpers shared by the object banks $03, $09 and $0D
engine/cutscenes/        bank $0B, the Wily cutscenes
engine/ending/           bank $0E, the ending
data/                    data tables (object tables, graphics pointers, font, frames)
data/stages/             one editable file per decoded stage (docs/LEVELS.md)
banks/bank**.asm         one file per bank $01-$0F: include lists, graphics, tilemaps
audio/bank02.asm         sound driver + music/SFX set A
audio/bank0a.asm         sound driver + music/SFX set B
constants/               hardware.inc, audio and RAM constants
macros/                  project macros (stages.inc: the stage data macros)
ram/                     WRAM/HRAM layout
gfx/                     PNG sources, converted by rgbgfx at build time
tools/                   coverage and RAM-map reports, stage/frame/audio dumpers, bank
                         generator, RGBDS bootstrap
docs/                    the plan, conventions, bank map, progress log
```

Code lives under `engine/`, data under `data/` and `gfx/`, by subsystem. Each
file holds one or more sections pinned to their original addresses, so a file can
group a subsystem even when its code is not contiguous; `banks/` keeps each
bank's include list and the banks that are mostly graphics.

## Documentation

* **[docs/SESSION_START.md](docs/SESSION_START.md)** — read this first every session.
* **[docs/PLAN.md](docs/PLAN.md)** — the phased plan, one step per session.
* **[docs/CONVENTIONS.md](docs/CONVENTIONS.md)** — naming and style rules.
* **[docs/BANKS.md](docs/BANKS.md)** — what is in each bank, how banking works, free
  space, and what a hack could do with the empty bank `$0F`.
* **[docs/ROMMAP.md](docs/ROMMAP.md)** — Data Crystal's map, audited against the ROM.
* **[docs/FORMATS.md](docs/FORMATS.md)** — every data format in one place.
* **[docs/RAMMAP.md](docs/RAMMAP.md)** — every RAM address the code refers to.
* **[docs/LEVELS.md](docs/LEVELS.md)** — the stage data format; renders in `docs/levels/`.
* **[docs/AUDIO.md](docs/AUDIO.md)** — the sound driver; its bugs in [AUDIO_ANOMALIES.md](docs/AUDIO_ANOMALIES.md).
* **[docs/UNUSED.md](docs/UNUSED.md)** — unused stages, enemies, songs, code and a debug hitbox viewer.
* **[docs/VERSIONS.md](docs/VERSIONS.md)** — how the US, European and Japanese dumps differ.
* **[docs/PROGRESS.md](docs/PROGRESS.md)** — coverage numbers and the session log.

## Credits and provenance

* Audio engine and all music/SFX data (banks `$02` and `$0A`) — disassembled by
  **Will Trowbridge**, imported from his standalone Game Boy sound player project.
  Verified here as reproducing both banks with zero differing bytes.
* The initial skeleton for the remaining banks — the section layout and the
  `bankswitch` macro; every label has since been replaced — is ported from
  **iimarckus**'s unfinished multi-game disassembly at <https://github.com/iimarckus/megaman>, modernized for
  current RGBDS (see `docs/PROGRESS.md` for exactly what changed).
* `constants/hardware.inc` is the community [hardware.inc](https://github.com/gbdev/hardware.inc) (CC0).
