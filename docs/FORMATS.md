# Data formats

Every data format in the game in one place (step 7.5). Each entry says where the
data lives, how it is laid out and what reads it; the longer write-ups are linked
rather than repeated. Offsets are in hex, `dw` is little-endian, and object
types are **one-based** (1-56) everywhere. Confidence is as in the source: what
is written here was checked there (`;[ok]`) unless it says otherwise.

| Area | Format | Source | Details |
|---|---|---|---|
| [Numbers](#numbers-and-coordinates) | fixed point, coordinates | — | below |
| [Graphics](#graphics) | 2bpp tiles, tile headers, pointer tables | `gfx/`, `banks/bank04.asm`, `bank07.asm` | `gfx/README.md` |
| [Tilemaps](#tilemaps-and-screen-text) | raw maps, rect headers, screen text | `gfx/tilemaps/`, `banks/bank06.asm` | ROMMAP.md "Text encoding" |
| [Text](#text-encodings) | five encodings, four charmaps | `constants/charmap.inc` | CONVENTIONS.md "Text" |
| [Metasprites](#metasprites) | grid + free tiles | `engine/sprites.asm` | below |
| [Object frames](#object-frames-and-animation) | frame tables, hitbox + metasprite | `data/`, `engine/objects/` | below |
| [Object tables](#object-tables) | stats, handlers, tilesets, boss damage | `data/object_tables.asm`, `engine/` | below |
| [Object record](#object-record-40-bytes) | `$40` bytes at `$C600` | `constants/objects.inc` | BANKS.md, RAMMAP.md |
| [Stages](#stages) | header, restart points, rooms, layouts, blocks | `data/stages/`, `macros/stages.inc` | **LEVELS.md** |
| [Weapons](#weapons) | 16-byte `WeaponTab` records | `engine/weapons.asm` | below |
| [Small pools](#enemy-shots-explosions-items) | enemy shots, explosions, items | `engine/enemy_shots.asm`, … | below |
| [Appearing blocks](#appearing-block-schedules) | timed block schedules | `engine/objects/appearing_block.asm` | below |
| [Passwords](#passwords) | 16 cell masks | `banks/bank0c.asm` | below |
| [Stage select](#stage-select-sprites) | tile lists, 8x16 frames, jump arcs | `banks/bank07.asm`, `engine/stage_select.asm` | below |
| [Ending](#ending-roll-call) | roll-call script and tables | `engine/ending/roll_call_data.asm` | below |
| [Audio](#audio) | sound table, headers, two-byte commands | `audio/bank02.asm`, `bank0a.asm` | **AUDIO.md** |
| [Header](#cartridge-header) | header fields, checksums | `engine/header.asm` | PROGRESS.md 7.4 |

## Numbers and coordinates

* **Speeds** are 8.8 fixed point (a pixel byte and a fraction byte) or, for the
  small steps in jump arcs and object movement, signed **4.4** (whole pixels in
  the high nibble). The object library has both (`ObjStepX`/`ObjMoveX` use a
  1/16-pixel speed and a sub-pixel counter at offset `$1C`; `NextJumpArcStep`
  adds 4.4 steps with the fraction kept in RAM).
* **X** comes in three kinds: *room-relative* (spawn columns, restart-point X),
  *stage* X (16-bit; Mega Man's is `$D80D`/`$D80E`, an object's offset `$0A`) and
  *screen* X (an object's offset `$0D` = stage X minus the screen's left edge at
  `$D811`). Rooms are lined up by their X offsets; moving between rooms shifts X
  by old offset − new offset. Y is 8-bit and screen-relative.
* **Blocks** are 16×16 pixels; rooms are 8 blocks high; the visible blocks are
  mirrored in the 16×16 grid at `$DE00`.

## Graphics

* **Tiles** are Game Boy 2bpp. Every tile run in the ROM is a PNG under `gfx/`
  (grayscale, white = colour 0), turned into `.2bpp` by `rgbgfx` at build time and
  `INCBIN`ed, cut to the real tile count with `INCBIN "x.2bpp", 0, N * 16` where a
  PNG row is not full. No graphics anywhere are compressed (step 3.4).
* **Tile headers** (banks `$04`, `$0E` and others): `dw byte_count, dw source` -
  e.g. `MegaManGfxHeader: dw 114*16, MegaManTiles`.
* **Tileset records** (bank `$07`, for `LoadObjectTiles`): `db tile_count, dw
  source`.
* **Pointer tables**: bank `$04` starts with 42 `dw` pointers to tile headers
  (Mega Man, the item pickup, the eleven weapons in unlock-bit order, the HUD,
  the stage select, then object types 1-29), bank `$07` with 31 (object types 30
  and up, then the stage-select robot masters). Bank `$00` never points into
  these tables directly: it has a word per slot (`GfxRef_*`, `$02E7`-`$03A9`) that
  holds the slot's address, and `ObjectTilesetPtrs` (`$249B`, 56 entries) points
  at those words. So loading a type's tiles is type → `ObjectTilesetPtrs` → ROM0
  slot → bank `$04`/`$07` pointer → record → tiles; types below `$1E` are in bank
  `$04`, the rest in `$07`.
* **VRAM use**: object tiles are allocated upward from sprite tile `$8B` by the
  12-entry type→tile cache at `$C3C4` (allocator `$C3B3`). Stage BG tiles are at
  `$9000` (0-127), with the shared runs at tiles 98 and 112.

## Tilemaps and screen text

* **Raw maps** (`gfx/tilemaps/*.tilemap`): one tile number per byte, row by row.
  Some carry a size header for `CopyTilemapRect` (`db width, height`, e.g. the
  20×10 title logo and the 20×18 password grid); the stage-select portrait
  halves are bare 20×9 maps drawn by `CopyTilemap20x9`.
* **Screen text** (bank `$06`): records of `dw BG map address` followed by a
  `$00`-terminated string in the `screen` charmap. The full list is in ROMMAP.md.

## Text encodings

Five encodings, each a named charmap in `constants/charmap.inc` (switch with
`SETCHARMAP`, and always back to `main`):

| Charmap | Rule | Used by |
|---|---|---|
| `main` | plain ASCII | the bank `$00` boss names (four 10-byte NUL-padded records at `$20CA`) |
| `screen` | ASCII + `$60`; space `$6C`, © at `$A0`; `$00` ends | bank `$06` screen text |
| `getscreen` | ASCII + `$80`; space `$93` | weapon-get screen (`$21C7`) and bank `$01`'s "AND CARRY" |
| `menu` | font at `$8900`: A = `$90`; `$70` blank | pause-menu weapon letters (`WeaponLetters`) |
| `rollcall` | ASCII − `$20`; `$00` (the space) ends a string, `$FF` goes on to another (address, text) line | the ending's roll call |

The password screen draws its letters with sprites from `password_sprites.png`;
which glyphs it actually uses is still an open question.

## Metasprites

`DrawMetasprite` (bank `$00` `$2CF0`), for objects, shots and items:

```
db dx, dy              ; added to $FFA2 + 8 (X) and $FFA3 + $10 (Y)
db cols << 4 | rows    ; a grid of tile bytes follows, $FF = no sprite there
db tile, …             ; rows × cols
db dx, dy, tile        ; free-placed tiles, repeated
db $80                 ; end
```

Tile bytes: bits 0-5 (0-6 while `$CE57` is set) are added to the tile base in
`$CE55`; bit 7 flips X and bit 6 flips Y on top of the attributes in `$D3EA`.
Mega Man's and the weapons' frames (`data/megaman_frames.asm`,
`data/weapon_frames.asm`) use the same format. Variants: bank `$07`'s stage-select
frames (below) and bank `$0E`'s roll call, whose tile bytes are added whole (no
flip bits). `tools/objframes.py` draws any object's frames.

## Object frames and animation

* **Frame table** (an object's `OBJ_FRAMES`, offset `$15`): a list of `dw`
  pointers to frames, indexed by `OBJ_FRAME` (offset `$17`).
* **Frame**: a 4-byte hitbox (x1, x2, y1, y2 relative to the object) followed by
  a `DrawMetasprite` metasprite. The collision pass reads the hitbox
  (`GetObjectHitbox`), the draw code the rest.
* **Animation record** (`AnimateObject`; the same format bank `$01` uses):
  `dw frame_table, db frames_per_step, db frame, frame, …, $FF` (loop). It points
  `OBJ_FRAMES` at the table, counts offset `$25`, steps offset `$26` and puts the
  frame number in `OBJ_FRAME`. `AnimateObjectFacing` then adds the facing (offset
  `$24`): those frame tables list each frame twice, left and right. The
  `Data_`/`Frame_`/`FrameTable_` labels in the object banks are these tables and
  records; they are still provisional names.

## Object tables

All in bank `$00`, indexed by type (one-based):

| Table | Address | Record | Read by |
|---|---|---|---|
| `ObjectStatsTab` | `$34D3` | 8 bytes: OAM entries (0 = no sprite), dx, dy (spawn offsets), hit points (→ `$18`; `$FE`/`$FF` = not meant to die), touch damage (→ `$1A`), flags (→ `$11`: bit 0 hurts Mega Man, bit 2 visible, bit 6 boss), b6 (→ `$03`, not traced), 0 | `SpawnObject` |
| `ObjectTypeTab` | `$3693` | 4 bytes: `dw` handler (a slot in the target bank's `jp` table at `$4000`), `db` bank, `db 0` | `SpawnObject`, `CallObjectRoutine` |
| `ObjectTilesetPtrs` | `$249B` | `dw` ROM0 slot (see Graphics) | `LoadObjectTiles` |
| `BossDamageTab` | `$11B8` | 11 `dw` row pointers for types 30-49 (row = (type − 30) / 2, 48 skipped); a row is one byte per weapon in `wCurrentWeapon` order, `$FF` = normal damage | `ApplyBossDamageTab` |
| `ObjectTablePtrs` | `$01B9` | `dw ObjectStatsTab, ObjectTypeTab` | banks `$03`/`$09`/`$0D` |

The object banks (`$03`, `$09`, `$0D`) each start with an **entry table** - one
`jp` per type they hold, in `ObjectTypeTab` order - followed by the shared object
library. An object routine is called with B = mode (0 spawn, 1 frame, 2 killed,
3 frozen) and returns B = 0 to remove itself. Spawning a child:
`SpawnChildObject` with the type in `$CC07` and the position in `$CC0D`/`$CC0F`.

## Object record (`$40` bytes)

24 slots at `$C600` (page-aligned; addressed `ld a,OFFSET / add a,c / ld l,a`
with H fixed). Known fields:

| Offset | Field |
|---|---|
| `$00`-`$01` | routine address |
| `$03` | from `ObjectStatsTab` byte 6 (not traced) |
| `$07` | object type |
| `$0A`-`$0B` | stage X (16-bit) |
| `$0D` | screen X |
| `$0F` | Y |
| `$10` | sprite handle (`AllocSprite`/`FreeSprite`) |
| `$11` | flags (`OBJ_FLAGS`) |
| `$15`-`$16` | `OBJ_FRAMES`, the frame table |
| `$17` | `OBJ_FRAME` |
| `$18` | hit points (weapon damage subtracts here) |
| `$1A` | touch damage |
| `$1B` | `OBJ_BANK` |
| `$1C`-`$1F` | X then Y sub-pixel counters and pixel steps (`ObjMoveX`/`ObjMoveY`) |
| `$22`-`$23` | Ice Slasher freeze timer |
| `$24` | facing (1 = right) |
| `$25`-`$26` | animation counter and record |
| `$27`-`$3F` | per-type state; common uses: `$27` state, `$28`/`$29` counters, `$2E`/`$2F` X speed, `$31`-`$33` jump arc (X speed, Y speed, gravity), `$34` zone half-width (`ObjGetPlayerZoneX`), `$3E`/`$3F` the Wily Machine's state pointer |

The stage-time **spawn records** are 8 bytes each from `$C400`, built by
`LoadSpawnList` from the room's 4-byte spawn list (LEVELS.md).

## Stages

Fully specified in [LEVELS.md](LEVELS.md), with an editing guide. In short: a
4-byte stage header (`dw restart_points, checkpoints`) → restart-point records
(14 bytes: blockset, collision, init, frame hook, start X/Y, start room) → room
records (id, routine, layout, X offset, two 5-byte exits, a 4-byte spawn list
ended by 0) → layouts (`db width, height` then blocks, 8 rows) → blockset
(`db count`, then 4 tiles per block) → collision table (one byte per block: 0
passable, 1 lower half solid, 2 upper half solid, 3 solid). Stages are written
with the macros in `macros/stages.inc`; `StageLoadTab` gives each stage's bank
(`$05` robot masters, `$08` Wily castle) and header.

## Weapons

`WeaponTab` (bank `$01` `$4007`), 16 bytes per weapon in `wCurrentWeapon` order
(Mega Buster, Rolling Cutter, Thunder Beam, Ice Slasher, Fire Storm, Carry,
Atomic Fire, Time Stopper, Quick Boomerang, Bubble Lead, Mirror Buster), copied
by `EquipWeapon`:

```
db tileset             ; LoadObjectTiles type for the shots' sprite   -> $C22B
db max_shots           ;                                               -> $C22C
db state               ; a new shot's offset $00                       -> $C22D
db damage              ; copied to each shot's offset $0B              -> $C203
db x1, x2, y1, y2      ; the shots' hitbox                             -> $C205
db cost                ; energy per shot                               -> $C22E
db pierce              ; how a hit treats the shot (wWeaponPierce)     -> $C235
dw fire, update        ; installed as `jp` at wWeaponFire / wWeaponUpdate
db 0, 0
```

Shots live in three `$20`-byte records at `wShotSlots` (`$C239`). The pause menu's
two-letter names are `WeaponLetters` in the `menu` charmap.

## Enemy shots, explosions, items

Three small pools outside the object system, all built the same way (an active
list, a count, a free stack with its pointer, fixed records):

| Pool | Records | Layout |
|---|---|---|
| enemy shots | 12 × 16 bytes at `$CD1B` | `+$01`/`+$02` X velocity and fraction, `+$03`/`+$04` X velocity high / X, `+$05`-`+$08` the same for Y, `+$09` tile, `+$0A` touch damage, `+$0B` sprite handle |
| explosions | 12 × 16 bytes at `$D31A` | built from a direction (index into `ParticleVelocities`) and 3 parameter bytes by `SpawnExplosionParticle` |
| items | 10 × 16 bytes at `$D417` | spawn parameters `$D4B7`-`$D4BD`; the placed-item list at `$D4C3` is 3 bytes per item |

Item drops: a random byte below `$9A` drops nothing; above it 1/256 extra life,
3 big health, 24 small health, 10 big energy, 64 small energy.

## Appearing-block schedules

`AppearingBlockSchedules` (bank `$03` `$714C`), one list per object parameter
(index 0 duplicates 1 and is unused):

```
dw start_frame
db duration            ; $B4 (180 frames) in every entry
db column, row         ; spawn-list column, 16-px row of the room
db y_offset            ; always 0
...
dw cycle_length
db $FF
```

The timer runs from 0 to the cycle length and wraps, once Mega Man is within
160 px.

## Passwords

`PasswordTable` (bank `$0C` `$6C67`): 16 words, one per combination of beaten
robot masters, indexed by `wWeaponsUnlocked1` bits 1-4. Each is a mask of the
4×4 grid - first byte cells A1-B4, second C1-D4, high bit first - with exactly
five bits set. The decoded table is in the source.

## Stage-select sprites

Bank `$07` `$6D2F`, read by `engine/stage_select.asm`:

* **Tile lists**: `db count`, then one byte per destination tile - the source
  tile in that robot master's tileset, or `$FF` for blank.
* **Frames** (`DrawSpriteGrid`, 8×16 sprites): `db cols << 4 | rows`, then rows ×
  cols `(tile, attributes)` pairs 8 px across and 16 px down, then extra sprites
  as `(dx, dy, tile, attributes)`, ended by `$80`.
* **Jump arcs**: one signed 4.4 Y step per frame, accumulated by
  `NextJumpArcStep`; a 0 entry leaves Y alone.

## Ending roll call

`engine/ending/roll_call_data.asm` (bank `$0E`):

* **Script**: `(frame, entry)` pairs - an enemy every 450 frames from frame 1160.
  Entries 3 (DRILLUN) and 16 (PICOPICO) are complete but never in the script.
* Per entry, one-based: `RollCallTextPtrs` (name), `RollCallFramePtrs`
  (metasprite; the nine robot masters share one 4×2 head), the tileset to load
  to `$8000` (0 = none).
* **Tilesets**: `dw byte_count, source`.
* **Names**: `dw BG map address`, then text in the `rollcall` charmap, ended by
  `$00`, or by `$FF` for another (address, text) line.

## Audio

Fully specified in [AUDIO.md](AUDIO.md). In short: `SoundTab` (`$4015` in banks
`$02` and `$0A`, 49 pointers; ID = index + 1) → a header (`db tempo` = frames per
tick − 1, `db priority`, then four `dw track, db track_ram` - the entry's
position is its channel) → a track of **two-byte commands**: rests `$00`-`$0F`,
notes `$10`-`$8F` (noise indices on channel 4), `9x`/`Ax`/`Bx` jumps and repeats
with a signed **word** offset, `$E6`-`$FF` events (envelope, duty, sweep, pan,
waveform, the `E6` song→game cue, `FF` end). The driver's tables (waveforms,
envelope sequences, vibrato, noise, frequencies) sit between the driver code and
the sound data, at `$4D3D`-`$4FFF` in bank `$02`. Music and effects are
queued through `wSoundQueue` (`$D920`).

## Cartridge header

`engine/header.asm` (`$0100`-`$014F`): entry jump, logo, `HEADER_*` constants for
title, licensee, type (MBC1), ROM size (256 KB) and RAM size (none). Since step
7.4 `HeaderChecksum` (`$014D`) is computed by the assembler from those fields, and
`HeaderGlobalChecksum` (`$014E`) is written out as `$C25B` - no Game Boy checks
it; after a modification, `rgbfix -f g mmwr.gb` will fix it if wanted.
