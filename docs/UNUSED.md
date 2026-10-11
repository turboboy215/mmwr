# Unused and vestigial content

A running register. Each entry says what is known, how it was established, and
whether it is Will's first-hand knowledge (**reported**) or traced in this repo
(**traced**). Things that are merely unreferenced by *literals* are marked as such:
an ID loaded from a table would not show up in a literal search.

## Stages

### Alternate Fire Man stage — traced, matches Will's report

`StageLoadTab` and `StageMusicTab` each have an eighth entry, after the three Wily
stages. Nothing selects it: the Wily branch in the main flow only sets stages 1–3,
and clearing the third jumps to the ending in bank `$0E`.

The record is not empty. It points at bank `$08` `$6F67` — ROM `$22F67`–`$23828`,
2,242 bytes, running right up to the bank's padding. Measured against every other
stage's data:

| Compared with | Shared 8-byte sequences |
|---|---:|
| **Fire Man (bank `$05`)** | **23.4%** |
| Wily stage 3 | 2.8% |
| Elec Man, Wily stage 1 | 2.1% |
| Cut Man | 1.8% |
| Ice Man | 1.5% |
| Wily stage 2 | 1.0% |

with a 76-byte run identical to part of Fire Man's data. Will reports an unused
alternate version of Fire Man's stage; this is it, by every measure short of
rendering it — which is Phase 4's job. It is about two-thirds the size of the final
Fire Man stage (3,352 bytes).

**Rendered in step 4.1b** (`docs/levels/8_fire_man_alt.png`; the final stage is
`4_fire_man.png`). It is a complete, playable-looking stage in the same format,
now source in `banks/bank08.asm`:

| | Final (bank `$05`) | Alternate (bank `$08`) |
|---|---|---|
| Rooms | 13: widths 20, 10, 40, 10, 40, 10, 80, 10, 10, 10, 40, 10, 10 | 9: widths 20, 10, 40, 10, 80, 10, 30, 10, 10 |
| Route | down, up, down | down all the way |
| Spawns | 57 | **4**: type 8 twice, and the boss pair (types 36 and 37) in the boss room, exactly as in the final stage |
| Shutter | object type 55, the boss door, in the room before the boss room | **drawn into the layouts** - see below |
| Blockset | 36 blocks | 36 blocks; 27 identical definitions, identical collision table |
| Frame hook | palette cycle, spikes, behind-BG zone code with an empty table | palette cycle (colour 3 dark grey instead of light), spikes, **no zone code** |
| Restart points | start, room 5, room 12 | start, room 5, room 8 |

Only the first room is nearly the same as the final one (153 of 160 blocks); the
rest is a different layout built from the same parts. With almost no enemies
placed, it looks like a stage whose map was done and whose population was not.

**The shutters are in the map.** The final stages never place the striped
shutter blocks; this one does, twice:

* the 30-block corridor room (room 7) has a 2×4 door of block 3 (passable) at
  columns 19–20, under the same 2×2 arrangement of blocks 4–7 (the "W" sign in
  the renders) that sits beside object type 55 in all four final stages;
* the boss room (room 9) has a 1×4 door of block `$23` (solid) in its **left
  wall** - a door in the side of the boss room.

The second is the only side-wall door in any stage, and it sits in exactly the
place a second boss door would go. Mega Man still reaches the boss room by
dropping in from above, and no exit leads through the wall (nothing in the game
uses `BuildExitBox`'s side-wall form), so it is a closed door that goes nowhere.
Together with the engine's unused side-wall exits, this is the strongest trace
yet of the side-by-side boss doors Will describes in the prototype. The
corridor door's stage X (`$06E0` + 19 × 16 = `$0810`) is also right at the boss
room's left edge (`$0820`), two screens higher up.

This fits Will's report that the prototype's boss doors do nothing and Mega Man
just walks through them. The alternate stage's corridor door is exactly that:
plain map blocks of the *passable* shutter block (collision `$00`), with no
object anywhere near it to open or close it - a door drawn into the scenery. In
the final stages the shutter is no longer in the map at all, and object type 55
- the boss door, per Will - draws it and makes it work.

The frame hook says something about order: Fire Man's final hook is this one
plus the behind-BG zone code copied from Elec Man's, so the zone code was added
to his stage later, and never given any zones.

Its music entry is SoundTab 39 in bank `$02`, one of the emptied `DoNotUse` labels
that now falls through into `Audio1_EndGameAlt` — see below.

### The alternate stage has its own tileset (step 2.4)

`StageTilesetPtrs` (`$248B`) has eight one-based entries like `StageLoadTab`, and
entry 8 — the unused slot — points at `Ptr_0C_400E`, a bank `$0C` tileset that
nothing else references. So the alternate Fire Man stage was given its own
background tiles, not a reuse of Fire Man's (entry 4, `Ptr_0C_4004`). Rendered
in 4.1b: 37 of the 98 own-tile slots hold the same tile as Fire Man's set at the
same number, and both stages use tiles up to 78.

### Side-by-side boss doors — reported; candidate traces found (step 4.1)

In the Japanese prototype the boss doors were meant to sit side by side, as in the
NES games. See `docs/VERSIONS.md`. They are also **completely non-functional
there: Mega Man walks straight through them and they never open (reported by
Will).**

Step 4.1 decoded the stage format (`docs/LEVELS.md`). In the final game each
robot master stage has a single shutter that Mega Man walks through, and then he
drops down a gap into the boss room (**reported** by Will). The engine still
carries one feature that fits a door in the side of a room, unproven as such:

* **Side-wall exits (traced).** `BuildExitBox` (`$3412`) builds a box running down
  a side wall, nudged 12 pixels in from the left or right edge, when bit 0 of an
  exit's flags is set. No exit in any of the eight stages sets it - every exit is
  a floor exit (row 7, flags `$02`) or a ceiling exit (row 0, flags `$00`) - and
  `CheckRoomExits` can only scroll vertically, so a side exit would trigger a
  vertical scroll.

The alternate Fire Man stage (above) has the side-wall door itself: a closed
shutter drawn into the left wall of its boss room.

The striped shutter blocks found in every blockset (block 3 passable, the last
block solid, neither placed in a layout) first looked like a second candidate.
They are not: they are the open and closed states of that one surviving shutter,
drawn at run time by object type 55, the boss door (Will), which every stage spawns once,
at the same spot in the room before the boss room (see `docs/LEVELS.md`). The
side-by-side design lost its *second* door; the room-to-room move through a side
wall that such a door would lead to is the part that survives only in code.

### Fire Man's behind-background zones — traced

Fire Man's room routine and frame hook are byte-for-byte the same code as Elec
Man's, which hides Mega Man and the enemies behind the background inside boxes
listed per room (Elec Man's six sky rooms, behind the clouds). Fire Man's table
gives every room the empty list. Either the effect was planned for his stage and
dropped, or the code was copied over wholesale.

### Stage-format fields nothing uses — traced

* Byte 0 of every restart-point record: 0 in both banks; `LoadRestartPoint` skips it.
* The second byte of every checkpoint record (`$04`, some `$01` in bank `$08`):
  `UpdateRestartPoint` steps over it and nothing else reads the list.
* Bank `$05` `$41AA`: an unreachable `jr z` in Cut Man's frame hook, between two
  palette branches that load the same value anyway.
* Bank `$05` `$5542`: a stray `ret` between Fire Man's zone table and his first
  layout.

## The Wily castle — traced (step 4.3)

### An unreferenced test stage

Bank `$08` `$6D05`–`$6F66` is a complete ninth stage that nothing points at - no
StageLoadTab entry, no pointer to its header anywhere in the ROM. It has three
identical restart points, one 40-block room with no exits and no objects, its own
copy of Wily 2's blockset (one collision byte differs: block `$23` is passable
here) and a trivial frame hook. The room is Wily 2's four layouts - the hub, the
five-teleporter hub, Bubble Man's room and the other boss rooms' room - laid end to
end: a stage for looking at Wily 2's rooms. Source: `data/stages/wily2_test.asm`;
render: `docs/levels/9_wily2_test.png`.

### Restart points nobody can reach

* **Wily 1:** its restart table's third entry is Wily 2's start record
  (`Wily2Restart0`), and the checkpoint that would select it names room `$18`,
  which Wily 1 does not have. Its own third record, `Wily1UnusedRestart` (room
  `$15`, near the end), sits right after the first two with nothing pointing at
  it. Looks like a checkpoint that was dropped when Wily 1 was joined to Wily 2.
* **Wily 3:** `Wily3UnusedRestart` (room `$0D`) follows the four records in the
  table, likewise unreferenced.
* **Wily 2:** both checkpoint records are the same (room `$16`), and restart
  entries 1 and 2 are the same record.

### Smaller leftovers

* `Wily2Teleporters` is preceded by an entry nothing can index (`$4F87`): the
  five-teleporter hub's start position, which the code writes as literals.
* `$08:4FA3`: an eight-entry bit table (`$01`-`$80`) that nothing in bank `$08`
  reads.
* The fourth entry of `Wily2FadePalettes` is never reached.
* Unreachable `ret`s: `$08:42A6` (Wily 1), `$08:5B55` (Wily 3).

## Music — reported by Will; reachability traced

| Song | Where | Reachable? |
|---|---|---|
| `Audio1_EndGameAlt` | bank `$02` | An alternate take of the well-known ending theme, not in common rips. Only reached through emptied `DoNotUse` slots: SoundTab 39 (the alternate Fire Man stage's music entry) and queue ID `$2E` in bank `$02` — but every site that queues `$2E` selects bank `$0A` first, where it means `Password`. Will suspects the emptied slot once held that stage's own music. |
| `Audio1_WilyUnk` | bank `$02`, SoundTab 34 | Unfinished, absent from online rips. Its `AudioSoundTabPtrs` slot (`$028F`) is referenced nowhere, and its queue ID `$23` is never queued by a literal. |
| `Audio2_UnkTheme` | bank `$0A`, SoundTab 44 | Unfinished, absent from online rips. Slot `$02A3` referenced nowhere; queue ID `$2D` never queued by a literal. |

## Audio driver features and routines nothing uses (step 6.1)

Details and addresses in [AUDIO.md](AUDIO.md); the full catalogue of broken and
vestigial audio features, with reasons, is [AUDIO_ANOMALIES.md](AUDIO_ANOMALIES.md) (6.2). Counted over every sound in both
banks with `tools/audiodump.py`.

* **Commands no sound uses:** vibrato (`F7`/`F6`/`EF`), hardware-length mode
  (`EE`), automatic length (`EC`/`EB`), `EA`, call/return (`E9`/`E8`), random
  transpose (`E7`), master volume (`F1`), and `9x` apart from the misaligned
  bytes on Wily 1's broken loop path. `F9` (length) appears 270 times but can't
  take effect without `EE`.
* **Vibrato processing** (`Audio1_ProcVibSeqs`, `$02:4AB5`) is never called, and
  its 15 sequences and `VibTab` are dead data.
* **Envelope sequences 1-4 and 6-11** are never selected; 5-9 duplicate waveform
  bytes. **Waveforms 0 and 2-15** are never selected: every `F2` in the data is `F2 01`.
* `AudioGetSlot` (`$400C`, stub `$024A`) has no caller. The code after
  `Audio1_CheckSlots` (`Audio1_CheckSlotVals`, `$42E2`) and the tables
  `Audio1_NRx2Vals`/`NRx4Vals`/`UnkVals` are unreachable.
* `StopAllButMusic` (`$00:083A`), which stops every slot but the music, has no caller.
* RAM: `$D98D`-`$D9A7`, `$D9A9`-`$D9DC`, `UnkRAM3`, `Slot5`-`8SpeedRAM`, and track
  offsets `$13` (written, never read), `$20` and `$58`.

## Sound effects — notes

* **Composite effects (reported).** Will believes the deflect and boss-door sounds
  are several short beeps played together. No game code queues sounds back-to-back
  (the only pair within 12 bytes is an explosion followed by the ending music), so
  if they are composites the composition lives in the sound data or the driver.
  Bank `$0A`'s table has `SFX_Door1` and `SFX_Door2` as separate entries, and only
  `Door2` (ID `$0D`, three sites in bank `$09`) is ever queued by a literal.
* **`SFX_Empty1` / `SFX_Empty2` are not empty and are used** (traced). `Empty1` has a
  noise-channel track and is queued as ID `$13` from bank `$03`; `Empty2` has a
  square-channel track and is queued as `$14` from banks `$01` and `$03`. Possibly
  very short or deliberate channel cuts.

## A disabled hitbox viewer (bank `$00` `$0CF1`–`$0F03`)

Found because Will could not place the five "background" tiles at `$0D0D` in any
stage map. They are sprite tiles for a developer's **hitbox viewer**: it freezes
play, shows a blinking ring cursor moved with the d-pad (continuously while A is
held), and while B is held brackets the hitbox of whatever is under the cursor —
Mega Man, objects and enemy shots — with four blinking corners. Select switches
it off; Start leaves through bank `$01`'s `PlayerControl` (`$67EA`).

It cannot run in the shipped game: its frame routine (`HitboxViewer`, `$0D76`) has
no caller and no pointer to it exists, and the five sprite handles it needs
(`$DFC0`–`$DFC4`) are never allocated — `InitHitboxViewer` sets `$DFC0` to `$FE`,
which makes `DrawHitboxCorners` return at once. The per-hitbox check is still
called by every collision test, so holding B in a stage runs the overlap test and
throws the result away. Tile `$FF` (a solid grey block) is never drawn even by
the viewer.

## Code and data — unreferenced in bank `$01` (step 5.1)

Found while tracing the whole bank by recursive descent from every entry point:
these bytes are reached by no `call`, `jp`, `jr` or pointer, and no computed
index can land on them.

| Item | Address | Notes |
|---|---|---|
| `ShowWilyCastle`, `ShowSkullShip`, `ShowWilyMachinePhase1`, `ShowWilyMachinePhase2` | `$6411`–`$64B5` | Four picture viewers: each loads one cutscene picture with the bank `$00` loader, turns the screen on and waits for Start. The ending in bank `$0E` uses the loaders through ROM0 stubs instead. A testing aid, probably. |
| `Unused_01_4494` | `$4494` | `xor a / ret` after `UpdateMegaBusterShot`'s `ret`. |
| `Unused_01_41E6` | `$41E6` | Eleven bytes, one per weapon (`4, $0E, $1D, $1B, $1C, 0, 4, 4, 4, 4, 4`), right after `BusterOffsets`. For nine of the eleven weapons the byte is the sound their fire routine plays (buster, Quick Boomerang and Bubble Lead `$04`, Rolling Cutter `$0E`, Thunder Beam `$1D`, Ice Slasher `$1B`, Fire Storm `$1C`, Carry `$00`); Atomic Fire (`$1C` on release) and Time Stopper (`$2B`) differ. Probably a per-weapon firing-sound table that the fire routines replaced with their own `ld a, n`. |
| `MirrorBusterAnimUnused` | `$4EDA` | A third Mirror Buster animation (frame 14, $64 frames per step). |
| `Unused_01_5729` | `$5729` | Three bytes after `UpdateItem`'s `ret`: a `jr` back into its last lines (`$5726`) and a `$00`. |
| `ItemFrameUnused` | `$58D0` | An item frame (a single tile) ahead of `ItemFrames`, not in the table. |
| `Unused_01_5A59` | `$5A59` | One `$00` between two routines. |
| `Unused_01_66CA` | `$66CA` | A hang trap: returns unless bit 7 of `$D80E` is set, then loops forever. |

**A no-damage flag nothing sets (step 7.3b):** while `$DF93` is non-zero,
`PlayerControl` throws away the damage waiting in `$D838` and skips knockback -
Mega Man is invincible. The only write to it by address is `ClearNoDamageFlag`
(`$66C5`, clearing it after the title screen); no `ld [$DF93],a` stores a
non-zero value and no `ld hl,$DF93` exists. Most likely a debug switch.

**Two dead tests (step 7.3b):** `CheckPlayerWalls` (`cp $9C`) and
`CheckPlayerWallsLeft` (`cp $04`) compare `$D827`, this frame's whole-pixel X
movement, with values it never takes in that direction; they look like screen-edge
checks meant for `wPlayerX`.

Also worth knowing: `FreeAllShots` (`$4429`) frees only the first two of the
three shot slots - its loop stops at `$60` - though it zeroes the shot count.
Pausing with three shots out leaves the third slot live, with its sprite.

## Code — unreferenced routines in bank `$00`

Found in step 2.3 by searching the whole ROM for `call`/`jp` (all conditions) to
each address and for the address as a little-endian pointer. "No reference" can
still mean a computed jump we have not seen, but none of these sit in a table.

| Routine | Address | Notes |
|---|---|---|
| `Mul16x16` | `$16CB` | HL × DE → BC:HL. Correct. |
| `Div16` | `$16E5` | HL ÷ DE → HL, remainder DE. Correct. |
| `Div32By16` | `$1711` | BC:DE ÷ [HL]. Drops a bit each round, so wrong for divisors above `$8000`. |
| `RandomBelow` | `$173E` | Random 0…A−1 by masking and rerolling; hangs for A = 0. The game calls `FuncRNG` directly instead. |
| `GetTableByte` | `$1962` | Byte-table lookup; its word-sized twin `GetTablePointer` is used. |
| `MemsetVRAM.alwaysSafe`, `WriteVRAMByte.alwaysSafe` | `$187C`, `$18A0` | Second entry points that skip the LCD-on check. |
| unreachable `ret` | after `HideAllSpritesAlt` (`$167D`) | Found in step 2.2. |
| `CopyBytesBackward` | `$1689` | `FuncFill` walking downwards (HL and DE decrementing). Nothing calls it. Step 7.3a. |
| `UnusedReti1` / `UnusedReti2` / `UnusedJumpReadJoypad` | `$07B7`–`$07BB` | Two lone `reti`s and a `jp ReadJoypad` after the VBlank code, with nothing jumping to them. Step 7.3a. |
| `FreeOneOAMSlot` | `$2F70` | Returns a single OAM entry to the pool and hides it; the sprite system only ever frees whole chains. |
| dead computation | `$2FB3` | `UpdateRestartPoint` builds B from `$D80D`/`$D80E` and never uses it. |
| unreachable `jr` + `$00` | `$387D`–`$387F` | After `UpdateEnemyShot`'s `ret`: a `jr` back to that `ret` and a padding byte. |
| `ObjectStatsTab` byte 7 | `$34D3` + 8n + 7 | Always 0; `SpawnObject` never reads it. |
| filler | bank `$04` `$63F8`–`$6FDF`, bank `$05` `$6AAD`–`$6FFF` | 3,048 and 1,363 bytes of alternating `$FF`/`$00` 32-byte runs with stray bits — uninitialised-memory pattern, unreferenced. Source since 7.1 as `uninit_fill` (`macros/filler.inc`) plus `db`s for the ten stray bytes. |
| `Data_04_4F59` | bank `$04` `$4F59` | Two bytes (`$04, $08`) between the HUD tiles and `StageSelectTiles`; nothing points at them. |
| type 8's tileset record | bank `$04` `$4FED` | Count 0, so it loads nothing; its second byte (`$80`) is never read. **Step 5.1:** that is by design - type 8 is the placed item pickup (`PlacedItemRoutine`, bank `$01`), which turns itself into an item at once, and items load their own tiles (`ItemTilesets`). |
| object type 13 (Drillun) | bank `$04` `ObjTilesType13` | **After 5.3 Will names it Drillun** (in the ending's roll call), so it is in the game's cast but, per the trace below, never in play in this ROM. Earlier: Will he does not recognise its graphics and suspects it is unused. **Steps 4.1 and 4.3: no spawn list in any stage places it, nor type 14** - every room of both stage banks is now decoded. Also never placed: types 25-28, 35, 39, 49-52 and 54. `SpawnObject` has a single caller (`$29FA`, the spawn-window code), so unless an object spawns another by some other route, both are unused. **Step 5.2: type 13 is unused** (traced): no stage places it and no `SpawnChildObject` call in the whole ROM (banks `$03`, `$09`, `$0D`) spawns it. Its code (`DrillunRoutine`, bank `$09`) falls and rises as a solid object and looks unfinished - it calls `CheckPlayerOnObject` with no box set up. Type 14 is not unused: each type 15 spawns one. Of the other never-placed types, 25-28, 39 and 54 are spawned by other objects (step 5.2); 35 and 49-52 by objects in banks `$03`/`$0D`. |
| "WORLD" in the title logo tiles | bank `$06` `TitleLogoTiles` (tiles 75–95 etc.) | Spotted by Will: the title tiles include WORLD in the logo's lettering, but the title map never places them. The Japanese release is *Rockman World*, so the US logo was probably once going to read *Mega Man World*. 32 of the 110 tiles are unplaced in all, also a ©, a period and a small arrow. Checked against the other versions: the European ROM has the identical 110 tiles (WORLD unused there too); *Rockman World* draws its WORLD in a different, grey italic style, and those Japanese tiles appear nowhere in the US ROM. So the US/EU WORLD was drawn new, in the *MEGA MAN* logo's own striped lettering — a logo made for *Mega Man World* and then cut. |
| title logo 11th row | bank `$06` `$4213` | 20 blank bytes after the 20x10 title map; the header says 10 rows. |
| stage-select extra rows | bank `$06` `$5213` | Three 20-byte rows after the bottom stage-select map, never drawn. |
| `LoadSkullShipScreenAlt` / `CopyTilemapRowsUnskipped` | `$01BD` | A second loader for the skull-ship picture, reachable only through the uncalled stub `$01B3`; its map copy forgets to skip the off-screen columns, so it would draw the picture sheared. |
| dead code copies in bank `$0C` | `$C:68EE`, `$C:72C7` | 113 bytes identical to bank `$08` `$4008` (`QueueTileCopy`/`CopyQueuedTiles`, which Wily 1 does use), and a sprite kit (`InitSpriteSystem_0C`) identical to bank `$0B` `$4210` / `$0E` `$4255` (addresses corrected in step 5.4); nothing in bank `$0C` calls either. |
| ASCII sprite font | bank `$0C` `PasswordSpriteTiles` | The password screen loads 64 glyphs from `!` to `_` (with © and ¥) along with its two ball tiles; the balls-left counter draws some of them. Which glyphs are ever drawn is untraced. |
| type 52's tileset | `ObjectTilesetPtrs` entry 52 | Points at type 1's ROM0 slot (`$0307`), but types `$1E` and up are loaded with bank `$07` paged in, so the slot's target is read in bank `$07`: it would load type 47's two tiles. Type 52 is never placed, so this never happens. Types 49-51 share type 48's tiles and 54 shares 53's; none of those is placed either. |
| `HangUnused` | `$2BC5` | One of five deliberate `jr`-to-self hang traps in the object code; the other four are reached when an internal limit overflows (no free object slot, 24 objects active, hitbox list full, no room for sprite tiles). This one has no jump to it. |
| dead code in bank `$09` | `Unused_09_4DED`, `Unused_09_58EA`, `KaminariGoroScrollUnused` (`$5161`), `Unused_09_7262`, `BossDoorDrawBGUnused` (`$7C44`), `GetDirectionToPoint_09` (`$7CF3`) | Step 5.2, traced (nothing calls or points at them); named in 7.3c: two lone `ret`s (`$4DED` before type 13, `$58EA` before type 24); `$5161`, a duplicate of type 15's scroll correction; `$7262`, a `jr` into type 54's update; `$7C44`, a routine that writes background tiles `$78`/`$79` down 8 rows at the boss door's position (with its helper `BossDoorGetBGAddress`, `$7C66`, and data `$7C64`, used only by it) - perhaps an earlier way of drawing the door into the background; `$7CF3`, the same code as bank `$0D`'s `GetDirectionToPoint` (the direction 0-7 of one point from another). |
| unused object-library routines in bank `$09` | `ObjGetPlayerZoneX_09`, `ObjCheckPlayerWithinX_09`, `SwapObjectOrder_09`, `ObjFallWithCollision_09`, `GetObjectHitbox_09`, `ObjLibBitMasks_09` | Step 5.2: the shared object library is copied whole into banks `$03`, `$09` and `$0D`; these parts of it are not used by bank `$09`'s objects (whether banks `$03`/`$0D` use them is for steps 5.3/5.6). |
| orphan frames in bank `$09` | `Frame_48E3`, `Frame_48F7`, `Frame_490B`, `Frame_493C` (type 10, fire beams), `Frame_7CEA` (boss door frame 5) | Step 5.2: frames no frame table points at. Type 10's first nine table entries are all one blank frame, padding so its frames 9-11 index correctly. |
| unused targets of Copipi (type 28) | `CopipiTargets` entries 6-7 | Pipi's egg (type 27) spawns its six Copipis with indexes 0-5; the last two offsets are never read. |
| unreachable branches in bank `$09` | Sniper Joe (type 4) `$640F`-`$641B`; Enker `$5D5E`, `$5F04` | Step 5.2: type 4 compares the address byte (`ld a, $2D / add a, c / ld l, a / cp $02`) instead of the field, so its reset block never runs; two of Enker's conditional jumps always go one way. |
| dead code in bank `$03` | `ElecManFaceMegaManUnused` (`$5FD8`), `ElecManSyncStageXUnused` (`$6074`), `Unused_03_6DF7`, `Unused_03_6F00`, `Unused_03_758B` | Step 5.3, traced: two Elec Man helpers nothing calls (face Mega Man; stage X and B = 1), and three lone `ret`/`ld b,1 / ret` tails. Named in 7.3d. |
| Elec Man's shot, modes 2/3 | `ElecManShotInitUp`/`Down`/`Vertical`, `ElecManShotMoveVertical`, `FrameTable_03_6507` and its frames | Step 5.3: a vertical version of type 35 (8 px every 3 frames, its own frames); Elec Man only ever passes mode 0 or 1. |
| unused frames in bank `$03` | `Frame_03_4B22`, `Frame_03_4BB0` (Cut Man), `Frame_03_6161` (Elec Man frame 1), `Frame_03_6989` (Fire Man), `Frame_03_6B31`, `Frame_03_6B3D` (Fire Storm) | Step 5.3: in no frame table, or in one but never selected. Ice Man's frame-table entries 9-11 repeat 1-3 and are never selected. |
| appearing-block schedule 0 | `AppearingBlockSchedules` entry 0 | Duplicates entry 1; no spawn uses param 0. |
| `$DFC5` | type 3 | Written 1/2/3 by type 3 (spawned/waiting/moving) and read by nothing - just past the disabled hitbox viewer's RAM; perhaps debug. |
| unreachable code in bank `$03` | Cut Man's jump-again check (after `CutManJump` sets `$35` and tests it), Ice Man's `.l4F53` (stores an address byte, so the slide always runs), Fire Man's `$6756` stub (`FireManWalkCheckStub`, 7.3d: always returns 0, so `FireManWalk` never branches to `FireManToAttack`) | Step 5.3: each a branch that can never be taken. |
| roll-call entries never shown | bank `$0E` `RollCallScript` | Step 5.4, traced: the ending has a full entry - name, sprite, tiles - for all 17 enemies, but the script skips entries 3 (DRILLUN) and 16 (PICOPICO), so neither is shown. PICOPICO's tiles exist nowhere else in the ROM. **Will:** both are unused enemies. Drillun (type 13) matches its official artwork, a drill with a green cap and eyes; he found nothing on Picopico except the name's likeness to Picopico-kun, a boss of the NES Mega Man 2. |
| unused code in banks `$0B`/`$0E` | the kits' `QueueTileCopy`/`CopyQueuedTiles`, `ClampToScrollLimits`, `AccumulatePlayerDX_0B`, `SetPlayerScreenX_0B`/`GetPlayerScreenX_0B`, `QueueLeftScrollColumn_0B`, the 16-px-row DrawMetasprite variants, `WaitForButtonHeld_0B` ($4A41); `AccumulatePlayerDX_0E`, `WaitForButtons_0E`, `DrawSpriteRecordIndirectHandle_0E`/`DrawSpriteRecordIndirect_0E`/`DrawSpriteRecord_0E`, `Data_0E_4251` | Step 5.4: each bank carries the whole kit and uses part of it. |
| unused ending data | bank `$0E` | Three of the four big-Mega-Man walk animation records (`$4EAA`/`$4EB2`/`$4EBA`); craft tiles `$00`-`$0B` of `skull_ship_sprites`; a stray `$C9` at the end of `CorridorStepTab`; the corridor's 9th row (8 are drawn). |
| unused cutscene data | bank `$0B` | Frame hitboxes the code points past ($4B0D, $4B2D, $4B47, $4D34, $4D45, $4D53, $5587); tiles 1-7 and 19-66 of the 67-tile set loaded for the Wily stage-select scene. |
| unused content in bank `$0D` | `WilyMachineAnimateUnused` (`$4981`) and its record `$527A`; `$4A3E`; `$625A` | Step 5.6: an animation cycling all 22 Wily Machine frames (frame `$15` is in no other use); an unreachable `AudioStopAll` call; two stray bytes after the teleporter light's empty frame. Only the first byte of each 3-byte `WilyFadePalettes` entry is read. Bank `$09`'s unreferenced `GetDirectionToPoint_09` (`$7CF3`) is the same code as bank `$0D`'s `GetDirectionToPoint`, which Quick Man uses. |
