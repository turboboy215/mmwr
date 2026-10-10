# Stage data format

Worked out in step 4.1 from the loader code in `engine/stage_load.asm` and the
bank `$05` data, and proven by the build: every pointer in the stage source is a
label, so the ROM only comes out identical if this description is right.
`tools/leveldump.py` dumps and renders it; renders of all the stages are in
`docs/levels/`, and Will has confirmed they match the game (apart from the
Wily Machine room - see "Render limits").

All eight stages use the same format, and so does a ninth that nothing points
at. Bank `$05` holds the robot masters; bank `$08` the Wily castle (step 4.3,
below), an unreferenced test stage, and the unused alternate Fire Man stage,
whose layouts are the only ones that place the shutter blocks, including a door
in the side wall of its boss room (`docs/UNUSED.md`). Every stage in both banks is
source, and every one is rendered in `docs/levels/`.

## Editing a stage

Since step 4.2 every stage that is decoded is plain, editable source: one file
per stage in `data/stages/` (`cut_man.asm`, `ice_man.asm`, `fire_man.asm`,
`elec_man.asm`, `wily1.asm`, `wily2.asm`, `wily3.asm`, `wily2_test.asm`,
`fire_man_alt.asm`), written with the macros in
`macros/stages.inc`. Nothing in them is `INCBIN`. A room looks like this:

```
CutManRoom2:
	room $02, CutManRoomRoutine, CutManRoom2Layout, $0320
	exit_up 7, 2, CutManRoom1        ; columns 7-8 of the top row
	exit_down 1, 1, CutManRoom3      ; column 1 of the bottom row
	spawn 1, 2, $13, $00             ; object type 1 at column 2, y $13
	spawn 1, 5, $51, $00
	end_spawns
...
CutManRoom2Layout:	;10 x 8
	layout 10
	lrow "0D 20 21 21 21 21 21 22 00 0D"
	lrow "0D 17 15 15 15 15 15 18 00 0D"
	...                              ; 8 rows of block numbers in hex
	end_layout
```

and a block is `block top_left, top_right, bottom_left, bottom_right` in tile
numbers, as it appears on screen (the macro stores them in the game's order).

The macros check what they can: every `lrow` must have exactly the layout's width
in `xx` hex pairs, a layout must have 8 rows, an exit must be 1-15 columns, an
object type cannot be 0 (it would end the spawn list), the block count byte is
worked out from the labels, and the collision table must have one byte per block
(at most 64). Room order, exit targets and restart points are all labels, so rooms
can be added, removed or reordered freely.

To see an edit, build and render the result:

```
./build.sh                       # will now report MISMATCH - expected after an edit
python3 tools/leveldump.py mmwr.gb --stage 1 --png out/ --objects
```

Bank `$05` ends in 1,363 bytes of uninitialised-memory filler and then `$FF`
padding sized with `ds $8000 - @`, so a stage can grow by up to about 5 KB in
total (delete the filler `INCBIN` for the last 1.3 KB). The alternate Fire Man
stage in bank `$08` still sits before a fixed `freespace` and cannot grow until
bank `$08` is finished.

## Vocabulary

| Term | What it is |
|---|---|
| **stage** | one StageLoadTab entry: Cut Man, Ice Man, … |
| **restart point** | where Mega Man comes back after losing a life: the stage start (0) or a checkpoint (1, 2, …). Earlier notes called these "sections". |
| **room** | one screen-high strip of level, 8 blocks tall and 10–80 blocks wide, that the camera scrolls along horizontally. Earlier notes called these "sub-sections". |
| **exit** | a box at the top or bottom edge of a room; touching it scrolls vertically to another room |
| **block** | a 16×16 metatile: four tile numbers |

## How it is reached

```
StageLoadTab ($00:2F93, one-based)  -> ROM0 slot ($033B…) + data bank (wStageBank)
ROM0 slot                           -> stage pointer at the start of the bank ($4000…)
stage pointer                       -> stage header
```

`LoadStage` copies the header to `wRestartPointsPtr` / `wCheckpointsPtr`, picks
restart point `wRestartPoint` and falls into `LoadRestartPoint`, which calls
`LoadRoom`. Stage tiles come from a parallel chain (`StageTilesetPtrs` at
`$00:248B` → ROM0 slot → bank `$0C` list); both chains are indexed by the same
stage number, so a stage's data and tiles always match. Note the bank order is
Cut, Ice, Fire, Elec, while StageLoadTab's order is Cut, Ice, Elec, Fire.

## Structures

### Stage header (4 bytes)

```
dw restart_points      ; table of restart-point records
dw checkpoints         ; checkpoint list
```

### Restart-point table

One `dw` per restart point. Entry 0 is the stage start; entry *n* is used after
Mega Man has entered the room that checkpoint *n* names. The table has no count:
it has one more entry than the checkpoint list.

### Checkpoint list

```
db room_id, ?          ; repeated
db $FF
```

`UpdateRestartPoint` runs every frame: if `wRoomID` matches a record's first byte,
`wRestartPoint` becomes that record's one-based position. **The second byte is
never read** — it is `$04` in all bank `$05` records (`$01` in some of bank `$08`).

### Restart-point record (14 bytes)

```
db 0                   ; skipped by LoadRestartPoint; 0 in every record of both banks
dw blockset
dw collision
dw init                ; called once at the end of LoadRestartPoint
dw frame_hook          ; installed as `jp` at wStageHook; called every frame
dw x                   ; Mega Man's start X ($D80D), room-relative pixels
db y                   ; Mega Man's start Y ($D824)
dw room                ; the room to start in
```

In bank `$05` every restart point of a stage shares the blockset, collision table,
init and frame hook; only the position and room differ.

### Room record (variable)

```
db id                  ; wRoomID - what checkpoints and zone tables key on
dw routine             ; called at the end of LoadRoom
dw layout
dw x_offset            ; the room's left edge in stage coordinates (pixels)
exit                   ; first exit:  db 0, or 5 bytes (below)
exit                   ; second exit
db type, column, y, extra   ; spawn list, repeated
db 0                   ; end of spawns
```

When Mega Man moves to another room, his X changes by *old offset − new offset*,
so positions inside a room are room-relative while the offsets line rooms up with
each other. Room ids are 1, 2, 3, … in order. In Cut Man's and Ice Man's stages the
last two rooms (the approach and the boss room) share id `$08`.

**Exit** (5 bytes, read by `BuildExitBox`):

```
db length << 4 | row   ; row 0 = top of the room, row 7 = bottom
db column              ; first column, in blocks
db flags               ; bit 0: the box runs down a side wall (length in rows)
                       ;        rather than along the floor/ceiling (length in columns)
                       ; bit 1: the far edge (bottom/right); the box is pulled
                       ;        12 pixels in from whichever edge it is on
dw room                ; where the exit leads
```

`BuildExitBox` turns it into an 8-byte box in `wExitBoxes` — `dw left, dw right,
db top, db bottom, dw room` in pixels. `CheckRoomExits` tests Mega Man against the
two boxes every frame and, on a hit, loads the new room and scrolls 2 pixels a
step, down if his Y is past `$70`, up otherwise.

**Every exit in all eight stages is either `row 7, flags $02` (down) or `row 0,
flags $00` (up).** Flag bit 0 is never set, and the transition code can only
scroll vertically. See "Vestigial fields" below.

**Spawn record** (4 bytes, read by `LoadSpawnList`): object type (one-based
ObjectTypeTab index), column in blocks within the room, Y (`SpawnObject` uses
`y & $F0` as the pixel row; the low nibble is not traced), and an extra byte.
Records are in column order, which the activation window (camera column ± 6,
`$D856`/`$D857`) relies on.

### Layout

```
db width, height       ; in blocks; height is 8 in every room
db block, block, …     ; width * height bytes, row by row
```

`LoadRoom` points `wRoomRowPtrs` at the 8 rows and sets the camera limits
`wScrollMinX = $50`, `wScrollMaxX = width * 16 − $50`. A layout can be shared:
Elec Man's rooms 14, 15 and 16 all use one.

### Blockset

```
db count
db tl, bl, tr, br      ; count times: tile numbers, top left, bottom left,
                       ; top right, bottom right
```

Tile numbers are BG tiles from `$9000` (0–127): the stage's own tiles at 0, the
shared runs at 98 and 112. No bank `$05` block uses a tile number of 128 or more.
`DrawBlock` draws one block and records its number in the `$DE00` block grid.

### Collision table

One byte per block (the table is `count` bytes long, though `LoadRestartPoint`
copies 64 to `wBlockCollision`, running on into whatever follows). Values seen:
`$00`, `$01`, `$02`, `$03`. Blocks 0–8 have the same collision bytes in all four
stages (`00 00 02 00 03 03 03 03 01`), and block 8 is the spike block in all four.
**Step 5.1:** `CheckSolidAt` (bank `$00` `$0F95`) is the test, and the values
are `$00` passable, `$03` solid, `$01` solid in the block's lower half only (block
8, the spikes, which are half a block tall) and `$02` solid in its upper half only
(block 2, the top of a ladder: Mega Man stands on it and climbs down through it).
The ladder itself is block 1, collision `$00`; bank `$01`'s player code tests
the block numbers 1 and 2 directly, which is why they are the same in every
blockset.

### Per-stage code

Each stage's init, room routine and frame hook live in bank `$05` between the
rooms and the layouts. All are disassembled in `banks/bank05.asm`:

| Stage | Init | Room routine | Frame hook |
|---|---|---|---|
| Cut Man | `ret` | `ret` | conveyor belts (blocks `$10`–`$13` push `$D830` by ∓`$B0`); BGP flicker `$90`/`$92` |
| Ice Man | `ret` | `ret` | BGP `$E4`; spikes; blocks `$1D`/`$22`/`$23` set `$D908` = 2 (slippery ice `[?]`) |
| Fire Man | `ret` | behind-BG flag for objects | BGP cycle `$4F`/`$4B`/`$47`; spikes; behind-BG zones for Mega Man |
| Elec Man | `ret` | behind-BG flag for objects | BGP `$C6`; spikes; behind-BG zones for Mega Man |

**Spikes:** standing on block 8 sets `$D838` (the contact-damage accumulator) to
`$14`. Cut Man's hook has no spike test, and his stage places no block 8.

**Behind-BG zones** (Fire Man and Elec Man): a table indexed by room id points at a
list of boxes (`dw left, dw right, db top, db bottom`, ended by `$FFFF`). Inside a
box, bit 7 of `$D80B` — the OAM attribute byte bank `$01` gives Mega Man's sprites
— is set, which draws him behind background colours 1–3; and in any room that has
a list, `$D3ED` bit 7 does the same for every object. Elec Man has zones in six
rooms (the sky rooms with clouds). **Fire Man's table points every room at the
empty list** — the code is there, the data is not.

## Vestigial fields and unused data

Things the format carries that the game never uses. Some may be what is left of
the side-by-side boss doors Will describes in the Japanese prototype; that link is
**not** established, only that these are unused.

* **Side-wall exits.** `BuildExitBox` fully supports flag bit 0 — a box running
  down a side wall, nudged 12 pixels in from the left or right edge — but no exit
  in any of the eight stages sets it, and `CheckRoomExits` can only scroll up or
  down. A horizontal room-to-room transition through a wall is exactly what a door
  in the side of a room would need.
* **The shutter blocks are not unused after all.** Every bank `$05` blockset has
  the same horizontally striped graphic twice: block 3 (collision `$00`,
  passable) and the last block (collision `$03`, solid). No layout places either,
  but Will confirms each robot master stage has one boss shutter that Mega Man
  walks through before dropping down a gap into the boss room - so the shutter is
  drawn at run time, and these are presumably its open and closed states.
  **Object type 55 is the boss door** (Will; its own two tiles are the same
  stripes). It is spawned once per stage, always at column 5, Y `$30` of the
  room before the boss room (Cut Man and Ice Man room `$08`, Elec Man `$12`, Fire
  Man `$0C`). How it writes the blocks is Phase 5 (bank `$09`, slot 23).
* **Constant fields:** byte 0 of every restart-point record (always 0, skipped),
  and the second byte of every checkpoint record (never read).
* **Fire Man's empty zone table** (above).
* **Unplaced object types.** With every room of both banks decoded (step 4.3),
  types **13, 14, 25–28, 35, 39, 49–52 and 54** appear in no spawn list.
  `SpawnObject` has one caller (the spawn-window code), yet some of these must
  appear in the game: Will identifies type 48 as Dr. Wily and the Wily Machine's
  sprite parts *including the wheel enemy it shoots* - so 49-51, which share 48's
  tiles, are likely the machine's spawned parts - and type 39 as possibly
  Enker's Mirror Buster. So objects can create other objects by a route not yet
  traced (Phase 5), and "never placed" is not the same as "unused".

## The Wily castle (bank `$08`, step 4.3)

The three Wily stages use the same records, plus three tricks.

**Restart records outside the table.** A restart-point record can be loaded
directly with `JumpLoadRestartPoint` (`$01AA`), not just through a stage's
restart table. Wily 2's teleporter hub does exactly that for its five boss rooms,
so each boss fight starts like a fresh stage.

**Changing stage data mid-level.** `SwapRestartData` (`$08:4E4A`) copies just the
blockset, collision table, init and frame hook out of a restart record, without
moving Mega Man or loading a room. Wily 1's last room drops straight into Wily
2's hub (an exit into another stage's room); on the way down `Wily1FrameHook`
streams Wily 2's tiles into VRAM (`QueueTileCopy` / `CopyQueuedTiles`, from a
copy of the tiles kept in bank `$08`), and the hub's room routine then swaps in
Wily 2's blockset. Wily 3's last room swaps to the Wily Machine's own blockset
the same way.

**The teleporter hub.** Wily 2 is one room - the hub - plus five boss rooms. The
hub's frame hook (`Wily2HubFrameHook`) is a little state machine: fade in, then
compare Mega Man's position with `Wily2Teleporters` every frame; standing exactly
on one (whose boss is not beaten yet) fades out and loads that teleporter's
restart record. `wHubTeleporter` remembers which (1-5), `wWilyProgress` collects
a bit per beaten boss, and once bits 0-3 are set the hub is reloaded as its
five-teleporter version with Enker's teleporter.

| Teleporter | Position (X, Y) | Boss (object type) | Weapon |
|---|---|---|---|
| 1, top left | `$0F`, `$23` | Quick Man (46, with three 47) | Quick Boomerang |
| 2, top right | `$8F`, `$23` | Bubble Man (40, with five 41); his room alone sets `$D909` (water? `[?]`) | Bubble Lead |
| 3, bottom left | `$0F`, `$53` | Flash Man (42, with 43) | Time Stopper |
| 4, bottom right | `$8F`, `$53` | Heat Man (44, with three 45) | Atomic Fire |
| 5, bottom centre | `$4E`, `$63` | Enker (38) | Mirror Buster |

The boss names come from the weapons: after a hub boss the weapon-get screen
shows weapon number `wHubTeleporter` + 4 (`WeaponNameLine1Ptrs`), and teleporter
*n* is the one that leads to the room spawning that boss.

The four hub bosses are the Mega Man 2 robot masters Quick Man, Bubble Man,
Flash Man and Heat Man (the plan's older list of six was wrong), with Enker as
the fifth. Wily 3's last room spawns object type 48, presumably the Wily Machine.

**Objects (Will, after 4.3 and 4.4):** type 53 is the light shown on an active
teleporter (four in the hub, five in the five-teleporter version, each spawned
with its number 0-4 as its Y); type 56's tiles spell "DR.WILY TELEPORT SYSTEM" -
the sign over the teleporters; type 48 is Dr. Wily and the Wily Machine's sprite
parts, including the wheel enemy it shoots. The objects placed just after each
boss are its weapon: Rolling Cutter (31), Ice Slasher (33, three), Fire Storm (37
- beside Fire Man, and also beside Elec Man, which is not explained yet), Bubble
Lead (41, five - Bubble Man's room is the game's only underwater area, which fits
its hook setting `$D909`), Atomic Fire (45, three) and Quick Boomerang (47,
three). Flash Man's companion, 43, loads the Rolling Cutter's tiles; Enker has
none (type 39, perhaps his Mirror Buster, is never placed).

**Correction (steps 5.2, 5.3):** these companions are not weapons placed for
after the fight. Each is the boss's own shot, parked off screen until the boss
asks for it (`$CCF6`), and the companions - not the bosses - end the fight
(`CheckBossDead`, wStageState 2, the victory countdown). That explains the Fire
Storm (37) beside Elec Man: Elec Man fires his own type 35 and never asks for a
type 37, which is there only to end his fight. Type 43 beside Flash Man does the
same and nothing else.

**Render limits.** Will confirms the Wily renders match the game except where
the game changes graphics mid-stage: Wily 1's last two shafts (blanked while Wily
2's tiles stream in) and the Wily Machine room, which fades in from black with a
different tileset that the stage data does not name. **Step 4.4 found it:** the
room's blockset uses background tiles 0-`$4F` of bank `$06`'s Wily Machine
cutscene graphics (`WilyMachineGfx`) - drawn with those, the room shows the
machine itself as background. `leveldump.py` now loads them for that blockset
(`BLOCKSET_TILES`). **Step 5.6 corrected this:** the tiles the room really uses
are bank `$0D`'s own (`$D:5476`, 80 tiles, `gfx/wily_machine/room.png`), which
type 48 (`WilyMachine`) streams to `$9000` at spawn - bank `$06`'s cutscene
tiles only look alike (one tile of the 80 matches). `leveldump.py` loads the
bank `$0D` tiles now, and the room renders cleanly.

| Stage | Rooms | Restart points | Notes |
|---|---|---|---|
| Wily 1 | 23 | 3 (the third is Wily 2's start, and unreachable) | ends by dropping into the hub; one orphaned restart record |
| Wily 2 | hub ×2, 5 boss rooms | 2 (+5 boss records) | both checkpoints name Enker's room |
| Wily 3 | 27 | 4 (the last is the Wily Machine room) | 100-block opening room; one orphaned restart record |
| test (9) | 1 | 3, identical | Wily 2's four layouts in a row; no exits, no objects |

## Bank `$08` layout

| Range | Contents |
|---|---|
| `$4000`–`$4007` | four stage pointers (Wily 1-3, alternate Fire Man) |
| `$4008`–`$4078` | `QueueTileCopy`, `CopyQueuedTiles` |
| `$4079`–`$4DD8` | Wily 1 |
| `$4DD9`–`$5349` | Wily 2: records, hub and boss-room code, rooms, layouts, blockset |
| `$534A`–`$5809` | `Wily2HubTiles`, a copy of Wily 2's 76 tiles for the hand-over |
| `$580A`–`$6D04` | Wily 3, with two blocksets |
| `$6D05`–`$6F66` | the unreferenced test stage |
| `$6F67`–`$7828` | the alternate Fire Man stage |
| `$7829`–`$7FFF` | `$FF` |

## Bank `$05` layout

| Range | Contents |
|---|---|
| `$4000`–`$4007` | four stage pointers |
| `$4008`–`$492E` | Cut Man: header, 3 restart points, 9 rooms, code `$416F`–`$41BE`, layouts, 41 blocks |
| `$492F`–`$5259` | Ice Man: 3 restart points, 9 rooms, code `$4AC2`–`$4AE9`, 41 blocks |
| `$525A`–`$5F71` | Fire Man: 3 restart points, 13 rooms, code and zone table `$5455`–`$5542`, 36 blocks |
| `$5F72`–`$6AAC` | Elec Man: 3 restart points, 19 rooms, code and zones `$61A9`–`$62B9`, 48 blocks |
| `$6AAD`–`$6FFF` | uninitialised-memory filler: alternating 32-byte runs of `$FF` and `$00` with a few stray bits. This is the "`$16AAD`–`$16F21`" the plan listed as unexplained; `$6F20` is just the last stray bit. |
| `$7000`–`$7FFF` | `$FF` |
