# Bank map and banking architecture

256 KB, 16 banks of 16 KB, MBC1, no cartridge RAM, DMG-only (no SGB or CGB support).

## How banking works

The game uses an unusually tidy scheme, which is good news: most banked code is
reachable only through a small, fixed entry table at the top of its bank.

* **`$DF99` — current bank shadow.** Every bank switch goes through the two-instruction
  idiom captured by the `bankswitch` macro: write A to `$DF99`, then to `$2100`.
  117 sites in the ROM, and **111 of them are in bank `$00`**. Banks `$0B`, `$0C` and
  `$0E` switch on their own only to return to bank `$01`.
* **Bank `$01` is the default resident bank.** Code that switches away restores `$01`
  when it is done.
* **`$DF9A` — selected audio bank.** Written only with `$02` or `$0A`, from banks
  `$00`, `$01`, `$0B` and `$0E` (24 sites). It exists because the music and SFX data
  did not fit in one bank, so the driver is duplicated in both and the caller picks.
* **`rst $08` → `FarCallAudio` (`$02AD`) is the audio far-call trampoline.** `$0008`
  is `jp FarCallAudio`. It stashes A/L/H/E/D in `hFarCallA`–`hFarCallD`
  (`$FF8C`–`$FF90`), pages in `wAudioBank`, reads the target from the `dw` inline
  after the `rst`, pushes `.restoreBank1` and then the target, reloads the registers
  and `ret`s into the target.

  The seven stubs at **`$0236`–`$024A`** are each `rst $08` + `dw`, targeting
  `$4000`, `$4003` … `$4012` — the seven `jp` entries at the top of both audio banks.
  They are now named `AudioInit`, `AudioStopSlot`, `AudioLoadSound`,
  `AudioLoadSong`, `AudioGetSlot`, `AudioPlay`, `AudioStopAll` (the last two stop
  names since 6.2; they were `AudioCondSoundOff` and `AudioSFXOff`).

  *Resolved:* an earlier reading of this suggested tail-call semantics, because the
  trampoline discards the `rst` return address. It does not behave that way. Callers
  reach the audio API with `call AudioLoadSong`, i.e. they `call` the *stub*, and the
  stub executes the `rst`. The discarded address is the stub-internal one; the
  caller's own return address is still on the stack underneath, and `.restoreBank1`'s
  `ret` pops it. So these are ordinary calls that happen to cross a bank boundary,
  and they come back with bank `$01` paged in. Flags and BC pass through untouched.

* **`CallBank1Routine` (`$01F4`) is the general trampoline**, for everything that is
  not audio. Index in A selects from a seven-entry table at `$0228` that mixes ROM0
  and bank `$01` targets. It saves `wCurrentBank`, pages in bank `$01`, calls, then
  restores. The call is made through a three-byte `jp` that the routine *assembles
  into WRAM* at `$C0D0` each time, rather than through a jump table — one for the
  efficiency tally in Phase 6.

## Bank entry tables

Every banked bank except `$01` and `$0F` opens with a fixed dispatch table. This is
the complete public API surface of the ROM, and naming these entries is the single
highest-leverage piece of work available.

| Bank | Entry table at `$4000` | Content |
|---|---|---|
| `$00` | — (ROM0) | **Every routine named (step 7.3a).** Reset/interrupt vectors, the VBlank handler and its queued BG copies, game flow and stage loop, camera and scrolling, room transitions, collision, the object and sprite systems, graphics loaders, stage-select and weapon-get screen code, bank switching, audio thunks |
| `$01` | `InstallWeaponHooks`: `call` / `call` / `ret` | **100% source (step 5.1).** The resident bank: Mega Man (movement, collision, drawing), his weapons and shots, items, explosions, the pause menu, the HUD, the title, stage-select and weapon-get screens |
| `$02` | 7 × `jp` | **audio engine + music/SFX set A — 100% disassembled** |
| `$03` | 22 × `jp` | **100% source (step 5.3).** Object code: Cut Man, Ice Man, Elec Man, Fire Man and their shots, the fan, ice platform, appearing blocks, icicle, electric beam and nine enemies (Cutting Wheel, Screw Driver, Gabyoall, Super Cutter, Bigeye, Bunby Heli, Metall, Mole, Suzy) |
| `$04` | 42 × `dw` | sprite graphics (Mega Man, weapons, items, HUD, 7-segment digits) |
| `$05` | 4 × `dw` | the four robot master stages - format in `docs/LEVELS.md` (step 4.1), with a little per-stage code (frame hooks: conveyors, spikes, ice, palette effects, behind-BG zones) |
| `$06` | 21 × `dw` | tilemaps (title screen identified) |
| `$07` | 31 × `dw` | **100% source (step 4.4).** Sprite tiles for object types 30-56 (robot masters, Wily bosses, castle objects; `gfx/bosses/`) and the stage select's robot master sprites (tile lists, metasprite frames, jump arcs) |
| `$08` | 4 × `dw` | **100% source (step 4.3).** The Wily castle - Wily 1, Wily 2's teleporter hub and five boss rooms, Wily 3 and the Wily Machine room - plus an unreferenced test stage and the unused alternate Fire Man stage; `docs/LEVELS.md` |
| `$09` | 24 × `jp` | **100% source (step 5.2).** Object code: the shared object library and 24 object types (Enker, Bubble Man, Flash Man, Heat Man and their shots, the boss door, the Atomic Fire block, Sniper Joe, fire beams, Changkey and Changkey Maker, Kaminari Goro, Pipi and Copipi, Scworm, and the unused type 13) |
| `$0A` | 7 × `jp` | **music/SFX set B — 100% disassembled** |
| `$0B` | 1 × `jp` + kit | **100% source (step 5.4).** The Wily cutscenes, before Wily 1 and Wily 3 (`engine/cutscenes/`); 10.5 KB empty |
| `$0C` | 8 × `dw`, then `jp` × 2 | stage background tilesets (one per stage), and the password screens (entry `$4010`, display `$4013`) — step 3.3 |
| `$0D` | 9 × `jp` | **100% source (step 5.6).** Object code: the Wily Machine fight (types 48-52), Quick Man and his boomerangs, the teleporter lights and sign; 7.2 KB empty |
| `$0E` | 1 × `jp` + kit | **100% source (step 5.4).** The ending: skull ship explosion, enemy roll call, corridor, closing text (`engine/ending/`) |
| `$0F` | — | **completely empty ($FF × 16384)** |

## Bank `$01` (step 5.1)

Bank `$01` has no entry table because it does not need one: it is paged in
whenever nothing else is, so bank `$00` simply `call`s into it (about 30 sites,
all by name now). The other ways in are `CallBank1Routine` indexes 1, 2 and 4
(`SpawnExplosionBurst`, `SpawnDeathExplosion`, `SpawnExplosion`), the two RAM
hooks it installs at `$4000` (`wHookA` = `TryFireWeapon`, called by
`UpdatePlayer`; `wHookB` = `UpdateShots`, called by `StageFrameLoop`), the
`jp`s in the weapon record (`wWeaponFire`, `wWeaponUpdate`, from `WeaponTab`),
object type 8 (`PlacedItemRoutine`, through `OBJ_BANK` = `$01`) and the ROM0
stub `$0171`. Bank `$00` also reads two of its tables directly: `BitMasks` and
`AtomicFireDamage`. Bank `$01` never switches banks itself; its only far reach
is through bank `$00` helpers such as `LoadObjectTiles` and the screen loaders.

What it holds, in ROM order, is listed at the top of `banks/bank01.asm`. Nearly
three quarters of it is Mega Man and his weapons; the menus and HUD that the plan
expected to dominate are about 2 KB.

Since step 7.3b every label in the bank is descriptive. Mega Man's frame, for
orientation: `UpdatePlayer` -> `UpdatePlayerState` -> `PlayerControl` ->
(`HandlePlayerDamage`) -> `PlayerControlMove`, which branches on `wPlayerMotion` to
`UpdatePlayerAir` / `UpdatePlayerLadder` / the ground code, all ending in
`PlayerControlEnd` -> `ChoosePlayerAnim` -> `SetPlayerAnim`. Collision is
`CheckPlayerFloorCeiling` and `CheckPlayerWalls` (`BlockPlayerX` undoes the X move).

## Bank `$09` and the object library (step 5.2)

The three object banks are built the same way: an entry table of one `jp` per
object type, in `ObjectTypeTab` order; then the **object library**, 1794 bytes of
helpers (movement in 8.8 and 4.4 fixed point, gravity, block collision, facing,
animation, boss set-up and the boss bar, `SpawnChildObject`, solid platforms,
line movement); then the object routines. The library is identical in all three
banks except for its addresses (`$03`:`$4042`, `$09`:`$4048`, `$0D`:`$401B`), so it
is one file, `engine/object_library.asm`, included by each bank in its own pinned
section with `OBJBANK` set to the bank's label suffix (`_03`, `_09`, `_0D`).

An object routine gets B = 0 at spawn, 1 every frame, 2 when its hit points reach
zero and 3 (instead of 1) while Ice Slasher's freeze timer runs; B = 0 on return
removes it. Objects make objects with `SpawnChildObject`: the type in `$CC07`, the
position in `$CC0D`/`$CC0F`, then the parent runs the child's init itself. Bank
`$09`'s 24 types are listed with their spawners in `banks/bank09.asm`; each has
its own file in `engine/objects/` with a comment on its behaviour.

Since step 7.3c every code label in bank `$09` is descriptive. Two patterns run
through the objects: several handle mode 3 by ending Ice Slasher's freeze at once
(`EnkerClearFreeze`, `BubbleManClearFreeze`, `FlashManClearFreeze`,
`KaminariGoroShotClearFreeze` - `ObjClearFreeze`, so the freeze holds them a frame
at most), and several end their frame with a copy of `ObjSyncAndCheckOnScreen`
written inline (`KaminariGoroShotCheckOnScreen`, `ScwormSpawnCheckOnScreen`,
`SniperJoeSetFlags`). The `Data_09_` labels (animation records and tables) are
still provisional.

Bank `$03` (step 5.3) has the same layout: entry table at `$4000`, the library
at `$4042`, 22 types from `$4744`, free space from `$7BE5`.

Since step 7.3d no `Func_BB_AAAA` label is left anywhere: banks `$03` and `$0D`
follow bank `$09`'s patterns (`CutManClearFreeze`, `ElecManClearFreeze`,
`QuickManClearFreeze`, `CutManRollingCutterClearFreeze` and the Wily Machine's
biting head and cannon shot), and the kits' copies take their originals' names
with the bank suffix (`AccumulatePlayerDX_0B`/`_0E`, `GetPlayerScreenX_0B`/`_0E`,
`SetPlayerScreenX_0B`/`_0E`, `QueueLeftScrollColumn_0B` - the left-edge path of
bank `$00`'s `QueueScrollColumn`, like `QueueLeftScrollColumn_0E` -, bank `$0E`'s
three `DrawSpriteRecord*_0E`, bank `$0C`'s unreferenced `QueueTileCopy_0C` and
`CopyQueuedTiles_0C`). Fire Man's walk calls `FireManWalkCheckStub`, which
always returns 0, so its branch to `FireManToAttack` is dead. Four boss inits
(Ice, Heat, Bubble and Quick Man) return B = 0, the other five B = 1; what B = 0
from an init does is not yet traced.

The bosses do not end their own fights. In bank `$03`, the Rolling Cutter (31),
the three Ice Slashers (33) and the Fire Storm (37) are their bosses' shots and
end the fights; Elec Man's type 37 never fires. In bank `$09`, Bubble Man's and Heat Man's shots
(types 41 and 45 there, placed in the boss rooms and parked off screen until the boss
asks for them through `$CCF6`) and a parked type 43 beside Flash Man watch for the
boss's death (`CheckBossDead`) and start the victory countdown.

## The banks no literal selects

Banks `$03`, `$05`, `$08`, `$09` and `$0D` are never bank-switched to by a literal.
Of the 117 `bankswitch` sites, 26 take their value from somewhere else, and they sort
into exactly four mechanisms:

| Mechanism | Sites | Banks it can select |
|---|---:|---|
| `ld a,[wAudioBank]` — the audio pair | 6 | `$02`, `$0A` |
| `pop af` — restore a saved bank | 7 | whatever was saved |
| `ld a,[wStageBank]` — the current stage's data bank | 10 | `$05`, `$08`, `$0E` |
| `ld a,[hl]` at `OBJ_BANK` — an object's own code bank | 2 | `$03`, `$09`, `$0D`, `$01` |

**Stage banks come from `StageLoadTab` (`$2F93`).** `LoadStage` (`$3000`) pages in
bank `$05` first (there is no shared stage code there - step 4.1 found bank `$05`
is all stage data plus each stage's own hooks - and `LoadStageTiles` switches to
`$0C` straight away, so the write looks redundant), indexes the table with `wSelectedStage`, and
stashes the record's bank byte in `wStageBank` (`$DF9B`) before paging it in. Eight
four-byte records: the four robot master stages point at bank `$05`, the four Wily
stages at bank `$08`, selected by `wWilyStageSet` adding 4 to the index.

The table is indexed **one-based** — `LoadStage` loads `HL` with `$2F8F`, four bytes
before the data, so index 1 lands on the first record. Those four bytes are the
`dec b / jr nz / ret` tail of `HideAllSprites`, so the bias points into code rather
than padding. `wSelectedStage` is zero-based on the stage-select screen and
incremented by bank `$01` at `$062BA` before the load, which reconciles the two.

**Object banks come from `ObjectTypeTab` (`$3693`).** 56 four-byte records, each
`dw <handler>` + `db <bank>` + an unused `$00`. When an object is processed, the
far-call sites at `$28A3` and `$2A5B` read the bank out of the object's own record at
`OBJ_BANK` (`+$1B`) and page it in before jumping to the routine address in the
record's first two bytes (`CallObjectRoutine`). Offsets `+$15`/`+$17`, once read
as a handler and its jump index, are the frame table (`OBJ_FRAMES`) and frame
(`OBJ_FRAME`) - step 5.2.

Every handler address in that table is a slot in the target bank's entry table, and
**every slot in banks `$03`, `$09` and `$0D` is referenced exactly once, in order** —
22, 24 and 9 respectively, which is precisely how many `jp` entries each of those
banks has. The 56th record points at a lone bank `$01` address. So those three banks
exist to hold object behaviour code, and `ObjectTypeTab` is their complete index.

Still open: nothing has been traced *writing* `OBJ_BANK`. The two sites that touch it
only read it, so the field is filled at spawn time by a route that does not use the
`ld a,$1B / add a,c` idiom — probably a bulk copy from a template. Finding the spawn
path is the next thread, and it should also give the 56 object types their names.

## Regional versions

Eleven of the sixteen banks — `$02`, `$03`, `$07`, `$08`, `$09`, `$0A`, `$0B`, `$0C`,
`$0D`, `$0E`, `$0F` — are byte-identical across the US, European and Japanese dumps.
Only `$00`, `$01`, `$06` (code and localised screen data) and small patches of `$04`
and `$05` differ. See `docs/VERSIONS.md`. Two consequences worth remembering: the audio
disassembly applies to every version unchanged, and third-party documentation about
those eleven banks needs no address correction.

## Free space

About 61.8 KB of the 256 KB is padding — bank `$0F` entirely, plus 10.5 KB in `$0B`
and 7.2 KB in `$0D`. All tails are pure `$FF` except banks `$04` (95 `$00` bytes),
`$05` (127) and `$07` (4).

Before their `$FF` tails, banks `$04` (`$63F8`-`$6FDF`) and `$05` (`$6AAD`-`$6FFF`)
carry uninitialised-memory filler: 32-byte `$00`/`$FF` runs keyed on address bit 5,
in opposite phase in the two banks, with five stray set bits each. Step 7.1 writes it
as `uninit_fill` (`macros/filler.inc`). Nothing reads it, so it is free space too.

### Free space by bank (step 7.5)

`$FF` tails, from the ROM (the build writes each as `ds $8000 - @, $FF`):

| Bank | Free from | Bytes | | Bank | Free from | Bytes |
|---|---|---:|---|---|---|---:|
| `$00` | `$3979` | 1,671 | | `$08` | `$7829` | 2,007 |
| `$01` | `$738D` | 3,187 | | `$09` | `$7D32` | 718 |
| `$02` | `$7CA2` | 862 | | `$0A` | `$720D` | 3,571 |
| `$03` | `$7BE5` | 1,051 | | `$0B` | `$55D0` | 10,800 |
| `$04` | `$6FE0` | 4,128 + filler from `$63F8` | | `$0C` | `$7395` | 3,179 |
| `$05` | `$7000` | 4,096 + filler from `$6AAD` | | `$0D` | `$6311` | 7,407 |
| `$06` | `$7BB7` | 1,097 | | `$0E` | `$7BAF` | 1,105 |
| `$07` | `$7813` | 2,029 | | `$0F` | `$4000` | 16,384 |

## Bank `$0F`: what an expansion could do with it (step 7.5)

Bank `$0F` is 16 KB of `$FF` that nothing switches to (no `ld a,$0F` feeds a bank
switch; step 7.2). The cartridge is MBC1 with 16 banks, so it is the only whole
bank a hack gets without growing the ROM - and growing it is easy now: the
header's ROM-size byte is a `HEADER_*` constant and the header checksum is
computed by the assembler (step 7.4), so a 512 KB build only needs the constant
changed and the new banks declared. What follows is a map of the existing
routes into a bank, as a starting point, not a tested recipe.

**Routes that already take a bank number from a table** - the cheapest ways in,
because the engine pages the bank in itself:

* **Object types.** `ObjectTypeTab` (`$3693`) gives each type a handler address
  and a bank, and the object loop pages that bank in around every call ("How banking
  works" above). A bank `$0F` laid out like `$03`/`$09`/`$0D` - an
  entry table of `jp`s at `$4000`, a copy of `engine/object_library.asm` (include
  it with `OBJBANK` set to `_0F`), then the routines - can hold new enemies or
  replacements for existing ones. Pointing an existing type's record at bank
  `$0F` is a two-byte change. *New* type numbers need room in four tables that
  are pinned in bank `$00` with code right after them - `ObjectStatsTab` (8 bytes
  a type), `ObjectTypeTab` (4), `ObjectTilesetPtrs` (2) and, for a boss,
  `BossDamageTab` - so they would have to move into bank `$00`'s 1,671 free bytes
  and their users be repointed (`SpawnObject`, `LoadObjectTiles`, the `$01B9`
  pointer pair the object banks read). `LoadObjectTiles` also hard-codes where
  tiles come from - bank `$04` below type `$1E`, bank `$07` from `$1E` up - so a
  new type's tiles go in bank `$07` (2,029 bytes free) unless that test changes.
* **Stages.** `StageLoadTab` (`$2F93`) gives each stage a ROM0 pointer slot and a
  bank, stored in `wStageBank`, which `LoadStage`, the loaders and the per-frame
  call to the stage hook (`StageFrameLoop`) all page in. A stage in bank `$0F`
  therefore keeps its data, room routines, init and frame hook there. The table
  has eight records and is followed by code, so a ninth stage means moving it
  (and `LoadStage`'s `ld hl, StageLoadTab - 4`), adding a ROM0 pointer slot, and
  entries in `StageMusicTab` and the stage tileset pointers; the Wily stage select and the
  ending decide which stages are reachable. The format and macros are in
  LEVELS.md - eight stages' worth of examples.
* **Bank `$01` callbacks.** Code in any bank can call bank `$01`'s routines through
  `wBank1Trampoline` (banks `$0B`, `$0C`, `$0E` do), so new code in `$0F` can reuse
  the player, weapon, item and explosion code.

**Routes that do not stretch as easily:** audio (`wAudioBank` only ever holds
`$02` or `$0A`, and each audio bank carries its own copy of the driver - a third
sound bank would need a third driver copy, or new songs in the 862 + 3,571 free
bytes of the existing two; AUDIO.md §10); and graphics loaded by fixed `BANK()`
references in bank `$00` (move the data, update the reference).

**What 16 KB is, in this game's units:** bank `$05` holds the four robot master
stages and their per-stage code in about 11 KB, and bank `$03` holds 22 object
types, its entry table and its object-library copy in about 15 KB. So bank `$0F`
is room for roughly another four stages, or another object bank's worth of
enemies - not both.

## What the audio disassembly already tells us

`audio/bank02.asm` holds the whole sound engine, and [AUDIO.md](AUDIO.md) describes
it (step 6.1). Four slots (one per sound playing), eight track RAMs (`SFX1`-`4`,
`Mus1`-`4`), and per-channel priority stacks that let effects play over music
without stopping it. The command language supports envelope sequences, sweeps,
duty and waveforms, one-level calls, a one-byte "automatic length" mode, random
transpose and vibrato. The game's data uses none of the last four, and the vibrato
processing is never called. Bank `$0A` is the same driver source again (14 bytes
later) with a different music set. Correction to the earlier wording here: the
"eight slots" are eight tracks, there are four slots, and `E6` is a cue byte for
the game, not an RNG parameter.

## RAM addresses known so far

The authoritative list is now `ram/wram.asm`, `ram/hram.asm` and
`docs/RAMMAP.md`. What follows is the short version.

| Address | Meaning | Source |
|---|---|---|
| `$C000`–`$C09F` | OAM mirror, 4 bytes/sprite (Y, X, tile, attributes) | Data Crystal |
| `$C0D0`–`$C0D2` | three-byte `jp` that `CallBank1Routine` writes and then calls | this repo |
| `$C0B0`–`$C0C6` | `wBank1Trampoline`: 23 bytes of code copied in by banks `$0B`/`$0C`/`$0E` to call into bank `$01` (step 3.3) | this repo |
| `$C108` | lives | Data Crystal |
| `$C200`–`$C29A` | weapon and shot state: shot count, shoot timer, two hit lists, the equipped weapon's record (`wWeaponDamage` … `wWeaponPierce`, with its fire/update `jp`s), three shot slots at `$C239`, Mirror Buster's capture list (step 5.1) | this repo |
| `$D300`–`$D3D9` | explosions: twelve `$10`-byte records, free list, count `$D30C` (step 5.1) | this repo |
| `$D400`–`$D4C5`+ | items: ten `$10`-byte records, lists, refill state `$D4BE`–`$D4C1`, placed-item list `$D4C3` (step 5.1) | this repo |
| `$D802`–`$D846` | Mega Man: `wPlayerState`, `wPlayerFacing`, `wPlayerAnim`, `wPlayerX`/`wPlayerY`, `wHurtTimer`, joypad copies, `wPlayerMotion` (step 5.1) | this repo |
| `$C131` | `wAudioLock`: audio update lock (Will's `CondFlag1`; AUDIO.md §2) | audio disassembly, step 6.4 |
| `$D935`+ | audio engine RAM (see `ram/audio_ram.asm`) | audio disassembly |
| `$DF99` | `wCurrentBank` — current ROM bank shadow | this repo |
| `$DF9A` | `wAudioBank` — selected audio bank (`$02` or `$0A`) | this repo |
| `$DFA1` | unlocked weapons bitfield 1 (Buster/Cutter/Thunder/Ice/Fire/Carry/Atomic/Time) | Data Crystal |
| `$DFA2` | unlocked weapons bitfield 2 (Quick Boomerang/Bubble Lead/Mirror Buster) | Data Crystal |
| `$DFA3`–`$DFAD` | energy: HP first, Mirror Buster last, caps at 98 | Data Crystal |
| `$DFAE` | RNG seed | this repo |
| `$DFAF` | RNG table index | this repo |
| `$FF8C`–`$FF90` | `hFarCallA`…`hFarCallD` — register save slots for `FarCallAudio` | this repo |
| `$FF91` | `hBank1CallIndex` — routine index held by `CallBank1Routine` | this repo |

Step 1.2 added the VBlank bookkeeping (`wFrameCounter`, `wVBlankDone`,
`wVBlankBusy`, `wVBlankCount`), the LCD shadows (`wShadowLCDC`, `wShadowBGP`,
`wShadowSCX`, `wShadowSCY`), `wShadowOAM`, `wLives`, `wCurrentWeapon`,
`wBossesDefeated`, `wSelectedStage`, the metasprite scratch block and the
stage-select state. See `docs/RAMMAP.md` for all of it plus the unnamed
remainder.
