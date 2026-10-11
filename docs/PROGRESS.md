# Progress

## Coverage

`python3 tools/coverage.py --md`, as of step 7.5 (unchanged since 7.1):

| Bank | Assembly | Raw INCBIN | Padding | Bank done |
|-----:|---------:|-----------:|--------:|----------:|
| $00 | 16,384 | 0 | 0 | 100.0% |
| $01 | 16,384 | 0 | 0 | 100.0% |
| $02 | 16,384 | 0 | 0 | 100.0% |
| $03 | 16,384 | 0 | 0 | 100.0% |
| $04 | 16,384 | 0 | 0 | 100.0% |
| $05 | 16,384 | 0 | 0 | 100.0% |
| $06 | 16,384 | 0 | 0 | 100.0% |
| $07 | 16,384 | 0 | 0 | 100.0% |
| $08 | 16,384 | 0 | 0 | 100.0% |
| $09 | 16,384 | 0 | 0 | 100.0% |
| $0A | 16,384 | 0 | 0 | 100.0% |
| $0B | 16,384 | 0 | 0 | 100.0% |
| $0C | 16,384 | 0 | 0 | 100.0% |
| $0D | 16,384 | 0 | 0 | 100.0% |
| $0E | 16,384 | 0 | 0 | 100.0% |
| $0F | 16,384 | 0 | 0 | 100.0% |
| **Total** | **262,144** | **0** | **0** | **100.00%** |

"Bank done" is assembly as a share of that bank's real (non-padding) content.
Nothing in the source reads the base ROM any more: no `INCBIN "baserom.gb"` (7.1)
and no `freespace` (7.2). Bank tails are explicit `ds` fills and count as assembly,
so bank `$0F` (all `$FF`) now reads 100%. Real content, without padding, is 194 KB.

## Session log

### Step 7.5 — final pass (2026-10-10). Phase 7 done; the plan is complete.

* **Names:** `ObjLibFunc_000` → `ObjGetPlayerZoneX` (E = 4/3/2/1 for well left /
  just left / just right / well right of the object's X, widened by the
  half-width at offset `$34`; D = 1 on the right; used by Cut Man and the Rolling
  Cutter) and `ObjLibFunc_08D` → `ObjCheckPlayerWithinX` (A = 1 if Mega Man is
  within E px on side D; the fixed Metall sets D with `ObjFaceMegaMan` and asks
  for `$28`). Both `;[ok]`, re-read against the code. Renamed in the library, the
  three callers' files, `tools/bankgen/objlib.py`/`bank09.py` and UNUSED.md. No
  provisional code label is left; the `Data_`/`Frame_`/`FrameTable_` data labels
  still are (PLAN.md "After the plan").
* **`docs/FORMATS.md`** (new): numbers and coordinates, graphics and pointer
  chains, tilemaps, the five text encodings, metasprites, frames and animation
  records, the object tables and record, stages (summary of LEVELS.md), weapons,
  the three small pools, appearing-block schedules, passwords, stage-select
  sprites, the roll call, audio (summary of AUDIO.md), the header.
* **RAM map:** `tools/rammap.py` (new) expands main.asm's includes in order,
  tracks each SECTION's bank from `mmwr.map`, and records every `ld`/`ldh`/`call`/
  `jp`/`dw` operand that evaluates to WRAM or HRAM - names resolved through
  `mmwr.sym` and the `def ... equ` constants. 586 addresses, 4,427 references;
  247 named or inside a named block, 339 not. For each unnamed one it quotes the
  source comment that mentions it, else its region, and lists the routines using
  it. Two traps it handles: `ld hl,$FFxx` is usually a negative constant (kept
  only when the next instruction dereferences the pair - `ObjMoveCollideY`'s
  `ld hl,$FFA8 / ld a,[hl+]` is a real HRAM pointer), and fields reached by offset
  (object slots, audio track RAM) are invisible to it by design. `docs/RAMMAP.md`
  rebuilt: method, a fuller region table (sorted; `$C100`-`$C132`, `$DF00`
  corrected from "hitbox list" to the solid-box list, new rows for `$CC40`-`$CC5D`,
  `$D84E`-`$D876`, `$DCD0`-`$DDFB`, `$DFC5`-`$DFD4`, HRAM scratch), the generated
  table, leads. **`$CD25` is not an address**: every one of the step-1.2 hits (and all 16 `21 25 CD` patterns in bank `$00`) is
  `CD 21 25 CD` - `call $2521` followed by another `call`. That open question is
  closed.
* **Badges and CI:** README badges (byte-perfect, 100% source, RGBDS 0.9.4) and a
  commented live-badge line for when the repository has a GitHub URL.
  `build.sh` checks the output's SHA-256 when `baserom.gb` is absent (tested both
  ways, and with a deliberately changed byte, which fails);
  `.github/workflows/build.yml` builds RGBDS 0.9.4 (cached) and runs it.
  `make.bat` is unchanged and still compares against `baserom.gb`.
* **Bank `$0F`:** BANKS.md gains a free-space table per bank and a section on what
  an expansion could do: the routes that already take a bank from a table
  (`ObjectTypeTab`, `StageLoadTab` / `wStageBank`, the bank-`$01` trampoline),
  what new object types or stages would also need (the bank-`$00` tables to move,
  `LoadObjectTiles`' `$1E` test), and what does not stretch (audio banks).
* Also: README brought up to date (layout, docs list, credits), CONVENTIONS.md's
  text section lists all five charmaps, SESSION_START.md lists `rammap.py`.
  ROM byte-identical throughout; coverage unchanged at 100.00%.

### Step 7.4 — header checksums in source, no `rgbfix` (2026-10-10).

* `engine/header.asm`: the header fields are now `HEADER_*` constants, emitted as
  before, and `HeaderChecksum` is `LOW(-sum - 25)` over them - the boot ROM's own
  rule (subtract each byte of `$0134`-`$014C` plus one). The title is summed
  character by character with `STRSLICE` (a one-character string is a number in
  RGBDS 0.9.4; no warnings under `-Weverything`). Verified both ways: the
  unchanged source gives `$E4`, and a test build with the title "ROCKMAN WORLD"
  and version 1 stored `$26`, matching an independent computation over the linked
  bytes (then reverted).
* `HeaderGlobalChecksum` is `db $C2, $5B`, written out: it covers the whole linked
  ROM, which the assembler cannot see, and no Game Boy checks it. A modified ROM
  keeps the old value unless fixed with `rgbfix -f g` (the header comment says so;
  `tools/bootstrap-rgbds.sh` still installs `rgbfix` for that).
* `build.sh` and `make.bat` now just assemble, link and compare. ROM byte-identical.
  Next: 7.5.

### Step 7.3d — the last `Func_` labels, banks `$03`, `$0B`-`$0E` (2026-10-10). Step 7.3 done.

* All 45 remaining `Func_BB_AAAA` labels renamed (`$03` 20, `$0D` 14, `$0E` 6, `$0B`
  4, `$0C` 1), each with an `;[ok]` comment or the one it already had; none kept
  provisional, none made local. **No `Func_BB_AAAA` label is left in the source.**
  ROM byte-identical. Names recorded in `NAMES.update` blocks at the end of
  `tools/bankgen/bank03.py`, `bank0b.py`, `bank0d.py` and `bank0e.py`.
* Bank `$09`'s patterns hold in `$03`/`$0D`: mode-3 handlers that are just
  `jp ObjClearFreeze` are `<Type>ClearFreeze` (Cut Man, Elec Man and Quick Man
  also jump there every frame while `wFreezeFlags` is set), and frame tails that
  update the stage X and return B = 1 are `<Type>EndFrame`.
* Kit copies take their originals' names with the bank suffix. `Func_0B_4153` was
  tagged `[?]` as the left edge of `QueueScrollColumn`; compared instruction by
  instruction with bank `$00`'s `.leftEdge` path it is exactly that (the only
  difference is `wRoomRowPtrs + 1` written as `$D878`), now
  `QueueLeftScrollColumn_0B` `[ok]`, matching bank `$0E`'s
  `QueueLeftScrollColumn_0E`. Bank `$0C`'s unreferenced tile-copy pair now has
  both labels: `QueueTileCopy_0C` and a new `CopyQueuedTiles_0C` at `$690A` (the
  second routine had no label).
* Fire Man: `FireManWalkCheckStub` (`$6756`) is `xor a / ret`, so `FireManWalk`'s
  branch to `FireManToAttack` after it is never taken; he only attacks through
  `FireManChooseMove`. Metall's fixed variant (param bit 0 clear) is states 0-2:
  `MetallFixedWait`, `MetallFixedOpen`, `MetallFixedShut`.
* New open question: four boss inits (Ice, Heat, Bubble and Quick Man) return
  B = 0 from mode 0; Cut, Elec, Fire, Flash Man and Enker return B = 1. What the
  spawner does with B = 0 from an init is not traced.
* Still provisional, outside 7.3: the object library's `ObjLibFunc_000` and
  `ObjLibFunc_08D` (both commented `[ok]`; named in 7.5) and the `Data_`/`Frame_`/
  `FrameTable_` data labels (174/470/56). Next: 7.4.

Old name -> new name (`Func_` dropped from the old names):

| Old | New | Old | New | Old | New |
|---|---|---|---|---|---|
| `03_4AB5` | `CutManClearFreeze` | `03_758B` | `Unused_03_758B` | `0D_4F75` | `WilyMachineBitingHeadEndFrame` |
| `03_5508` | `CutManRollingCutterFrozen` | `03_77EA` | `MetallFixedWait` | `0D_50BC` | `WilyMachineCannonShotRemove` |
| `03_5509` | `CutManRollingCutterClearFreeze` | `03_780D` | `MetallFixedOpen` | `0D_50BF` | `WilyMachineCannonShotClearFreeze` |
| `03_5851` | `SuperCutterPlaceAndFace` | `03_786F` | `MetallFixedShut` | `0D_50DF` | `WilyMachineCannonShotUpdate` |
| `03_5FD8` | `ElecManFaceMegaManUnused` | `03_7AAB` | `MoleSlotToMask` | `0D_5211` | `WilyMachineCuttingWheelUpdate` |
| `03_6074` | `ElecManSyncStageXUnused` | `0B_40CA` | `AccumulatePlayerDX_0B` | `0D_5A88` | `QuickManClearFreeze` |
| `03_60A2` | `ElecManClearFreeze` | `0B_40EC` | `SetPlayerScreenX_0B` | `0D_5A8B` | `QuickManInit` |
| `03_6672` | `FireManToAttack` | `0B_40F4` | `GetPlayerScreenX_0B` | `0D_5B11` | `QuickManEndFrame` |
| `03_6688` | `FireManToChoose` | `0B_4153` | `QueueLeftScrollColumn_0B` | `0D_6049` | `QuickBoomerangEndFrame` |
| `03_66D2` | `FireManAttackStand` | `0C_68EE` | `QueueTileCopy_0C` | `0E_40CA` | `AccumulatePlayerDX_0E` |
| `03_66FB` | `FireManToWalk` | `0D_4981` | `WilyMachineAnimateUnused` | `0E_40EC` | `SetPlayerScreenX_0E` |
| `03_6756` | `FireManWalkCheckStub` | `0D_4F13` | `WilyMachineBitingHeadBeaten` | `0E_40F4` | `GetPlayerScreenX_0E` |
| `03_6B59` | `BunbyHeliFrozen` | `0D_4F29` | `WilyMachineBitingHeadClearFreeze` | `0E_42C6` | `DrawSpriteRecordIndirectHandle_0E` |
| `03_6DF7` | `Unused_03_6DF7` | `0D_4F4E` | `WilyMachineBitingHeadUpdate` | `0E_42E1` | `DrawSpriteRecordIndirect_0E` |
| `03_6F00` | `Unused_03_6F00` | `0D_4F6F` | `WilyMachineBitingHeadAnimate` | `0E_430C` | `DrawSpriteRecord_0E` |

### Step 7.3c — bank `$09`'s `Func_` labels (2026-10-10). None left in bank `$09`.

* All 46 `Func_09_AAAA` labels renamed, each with an `;[ok]` comment; none kept
  provisional. None could become local: each is reached from another routine, or
  has a global label (a sibling routine or a `Data_09_` record) between it and its
  only users. Most were mode-dispatch targets and shared tails inside the object
  files that step 5.2 had described in each file's header comment. ROM
  byte-identical. The names are recorded in a `NAMES.update` block at the end of
  `tools/bankgen/bank09.py`.
* **How Ice Slasher is shrugged off:** Enker, Bubble Man, Flash Man and Kaminari
  Goro's shot handle mode 3 with `ObjClearFreeze`, which ends the freeze at once
  (`<Type>ClearFreeze`; the headers' "Ice Slasher does nothing to him"). The three
  bosses' updates also jump there while `wFreezeFlags` is set (Flash Man: bits
  0-3), so the freeze flags, unlike Ice Slasher, do hold them.
* Three objects end their frame with an inline copy of `ObjSyncAndCheckOnScreen`
  instead of calling it: `KaminariGoroShotCheckOnScreen` (which then tells the
  thrower, by writing `$A5` to its `$28`, that it may throw again),
  `ScwormSpawnCheckOnScreen` and `SniperJoeSetFlags`.
* Dead code now has names (UNUSED.md updated): `Unused_09_4DED`, `Unused_09_58EA`
  (lone `ret`s), `Unused_09_7262` (a `jr`), `KaminariGoroScrollUnused`,
  `BossDoorDrawBGUnused` with `BossDoorGetBGAddress`, and `GetDirectionToPoint_09`
  (the bank `$0D` routine's twin, with its `_09` suffix like the library's).
* Remaining provisional labels: **45** (`$03` 20, `$0D` 14, `$0E` 6, `$0B` 4,
  `$0C` 1). Next: 7.3d. (The `Data_09_` labels are data, outside 7.3.)

Old name -> new name (`Func_09_` dropped from the old names):

| Old | New | Old | New | Old | New |
|---|---|---|---|---|---|
| `47D3` | `FireBeamAnimateUp` | `512C` | `KaminariGoroShotCheckOnScreen` | `5FC5` | `EnkerGetSide` |
| `47DB` | `FireBeamAnimateLeft` | `5161` | `KaminariGoroScrollUnused` | `62D0` | `SniperJoeEndFrame` |
| `47E3` | `FireBeamAnimateRight` | `553B` | `PipiEggFrozen` | `62D7` | `SniperJoeEndFrameFar` |
| `47EB` | `FireBeamStepRight` | `555A` | `PipiEggUpdate` | `62D9` | `SniperJoeSetFlags` |
| `4AF3` | `ChangkeyRemove` | `5565` | `PipiEggCheckOnScreen` | `6364` | `SniperJoeUpdateJumper` |
| `4B02` | `ChangkeyHold` | `5675` | `PipiEggMoveHalves` | `6402` | `SniperJoeJumpChosen` |
| `4B66` | `ChangkeyAnimateThrown` | `58EA` | `Unused_09_58EA` | `6405` | `SniperJoeAirborneDone` |
| `4DED` | `Unused_09_4DED` | `5989` | `ScwormSpawnFrozen` | `68FE` | `BubbleManClearFreeze` |
| `4F1C` | `KaminariGoroThrowerUpdate` | `59FD` | `ScwormSpawnAnimate` | `703B` | `FlashManClearFreeze` |
| `4F22` | `KaminariGoroThrowerStep` | `5A09` | `ScwormSpawnCheckOnScreen` | `7262` | `Unused_09_7262` |
| `4F51` | `KaminariGoroThrowerAnimate` | `5AF9` | `ScwormSpawnMoveLanded` | `7C1B` | `BossDoorStay` |
| `4F57` | `KaminariGoroThrowerShowShot` | `5C7D` | `EnkerClearFreeze` | `7C44` | `BossDoorDrawBGUnused` |
| `4F6B` | `KaminariGoroThrowerCheckParent` | `5D6A` | `EnkerIntroPose` | `7C66` | `BossDoorGetBGAddress` |
| `4FF8` | `KaminariGoroThrowerHoldThrow` | `5D70` | `EnkerIntroWait` | `7CF3` | `GetDirectionToPoint_09` |
| `50F2` | `KaminariGoroShotRemove` | `5D73` | `EnkerIntroStopFlash` |  |  |
| `50F5` | `KaminariGoroShotClearFreeze` | `5D80` | `EnkerIntroEnd` |  |  |

### Step 7.3b — bank `$01`'s `Func_` labels (2026-10-10). None left in bank `$01`.

* All 47 `Func_01_AAAA` labels renamed; every one already had a step-5.1 comment, so
  this was mostly naming what was written down, plus checking the three that were
  not `[ok]`. None needed to stay provisional, and none became local: each is
  reached from more than one routine, or sits after an intervening global label
  (`Unused_01_5729`, a sibling routine) so it cannot be a local. ROM byte-identical.
  The names were also added to `tools/bankgen/bank01.py`'s `N`, and the comments in
  banks `$0B`/`$0E` that pointed at `Func_01_6AEE` now say `AccumulatePlayerDX`.
* **`KeepChosenBossSprites` (`$65AB`) is settled** (was `[?]`, an open question):
  its four shadow-OAM blocks are exactly where `LoadStageSelectBosses` draws each
  robot master (Cut Man `$34`, Ice Man `$54`, Elec Man `$70`, Fire Man `$10`), so
  after a stage is picked it keeps that boss and clears the rest.
* **`$DF93` is a no-damage flag nothing sets.** While it is non-zero `PlayerControl`
  discards the pending damage (`$D838`) and skips the knockback code entirely, but
  the ROM's only `ld [$DF93],a` is `ClearNoDamageFlag`'s `xor a` write and there is
  no `ld hl,$DF93` (byte search). Probably a debug invincibility switch; noted in
  UNUSED.md.
* **Two dead tests in Mega Man's wall collision:** `CheckPlayerWalls` does `cp $9C`
  and `CheckPlayerWallsLeft` `cp $04` on `$D827`, this frame's whole-pixel X
  movement - values a speed never takes in that direction - so neither ever fires.
  They read like screen-edge checks meant for `wPlayerX`. (5.1's comment had called
  the second "the screen edge"; corrected.)
* `CheckPlayerOnCarry` (`$49AF`, was `[?]`): Mega Man counts as on the Carry when he
  stands at its top or falls through it this frame; the overshoot goes into `$D833`
  (high byte of the Y push `ApplyPlayerGravity` adds to his speed) to lift him back
  onto it. Nothing else stores to `$D833` by address; `ApplyPlayerGravity` clears
  it after use.
* Remaining provisional labels: **91** (`$09` 46, `$03` 20, `$0D` 14, `$0E` 6,
  `$0B` 4, `$0C` 1). Next: 7.3c, bank `$09`.

Old name -> new name (`Func_01_` dropped from the old names):

| Old | New | Old | New | Old | New |
|---|---|---|---|---|---|
| `4928` | `AddCarrySolidBox` | `5DD0` | `CountLowSixBits` | `6A7B` | `SetPlayerAnim` |
| `493B` | `DestroyCarryShot` | `64B6` | `FillZoomRowBG` | `6A9B` | `ChooseLadderAnim` |
| `49AF` | `CheckPlayerOnCarry` | `64C9` | `FillZoomRowWindow` | `6AD6` | `ChooseAirAnim` |
| `49EA` | `CheckCarryInWall` | `64DA` | `Fill8Bytes` | `6AEE` | `AccumulatePlayerDX` |
| `4A07` | `CheckCarryCorner` | `65AB` | `KeepChosenBossSprites` | `6B10` | `StartJump` |
| `4A51` | `AtomicFireNoEnergy` | `66C5` | `ClearNoDamageFlag` | `6B24` | `UpdatePlayerAir` |
| `4B5F` | `UpdateAtomicFireFlight` | `66D6` | `RoomFreeHurtSpark` | `6BE8` | `UpdatePlayerLadder` |
| `4E11` | `CheckBubbleLeadFront` | `6841` | `PlayerControlMove` | `6D20` | `CheckPlayerFloorCeiling` |
| `4EDF` | `UpdateReflectedShot` | `68A8` | `PlayerControlEnd` | `6D7B` | `CheckPlayerWalls` |
| `5048` | `AnimateShotOnList` | `68BE` | `HandlePlayerDamage` | `6D95` | `BlockPlayerX` |
| `572C` | `ItemLeftScreen` | `6976` | `EndHurtSpark` | `6DAA` | `CheckPlayerWallsLeft` |
| `5730` | `ItemCollected` | `6986` | `DrawHurtSpark` | `6DBF` | `CheckPlayerWallsMid` |
| `5732` | `EndItem` | `69D6` | `ClimbDownLadderTop` | `7359` | `StepTeleportBeam` |
| `5749` | `RemoveItem` | `69EC` | `ChooseHurtAnim` | `7372` | `TeleportBeamNotDone` |
| `5824` | `CheckItemAgainstStage` | `6A10` | `ChoosePlayerAnim` | `7374` | `StepTeleportBeamFast` |
| `5A5A` | `RemoveExplosion` | `6A16` | `ChooseMotionAnim` |  |  |

### Step 7.3a — bank `$00`'s `Func_` labels (2026-10-09). None left in bank `$00`.

* All 109 `Func_00_AAAA` labels are gone: 73 renamed and documented with `;[ok]`
  comments; 36 that were only ever reached from inside their own routine (fall-through
  entries and branch targets) became local labels, or were dropped where nothing
  referred to them at all (`$10C6`, `$1312`) - the boss-intro and stage-select
  animation code in `engine/stage_select.asm` was most of those. `.laterWilyStage`
  (was `Func_00_08FE`) is now a local of `NewGame`. Raw `call $XXXX`/`jp $XXXX` to
  these routines became names too (`jp $675` in the VBlank vector, the stage-select
  `call $1c6d`s, `jp $213f` -> `TypeYouGot.typeLetter`, ...). ROM byte-identical.
* What the names say, in short: the VBlank handler runs three queued BG-map copies -
  a scrolling column (`QueueScrollColumn` -> `VBlankDrawColumn`, 16 tiles at `$DDD0`),
  a room-transition row (`QueueTransitionRow` -> `VBlankDrawRow`, 24 tiles at `$DDE0`)
  and the HUD (`VBlankCopyHUD`). `UpdateCamera` turns Mega Man's stage X into the
  camera, SCX movement and the spawn window; `UpdateSpawnWindow` and `UpdateObjects`
  are the per-frame object loop; `CheckShotHit` is the shot-vs-box test behind the
  collision pass; `GetGfxBlock`/`DoubleDeref`/`TripleDeref` are the graphics loaders'
  pointer-following helpers.
* Small facts the reading turned up: the **Mega Buster does no damage to Gabyoall**
  (type 3) and stops it for 180 frames instead (`ApplyWeaponSideEffects`); **bosses
  killed in the Wily castle drop a big health pickup** until all five hub bosses are
  beaten (`ExplodeBoss`); the stage loop's frame wait (`DelayFrameWithSprites`) is
  the only place `BeginSpriteFrame` alternates the pooled OAM order (ascending on
  odd `$DF86` frames, descending on even); `NextJumpArcStep` leaves E unchanged on
  a zero arc entry, and `AddFixedPoint44` keeps its fraction as a magnitude.
* New unused code: `CopyBytesBackward` (`$1689`), `UnusedReti1`/`UnusedReti2`/
  `UnusedJumpReadJoypad` (`$07B7`-`$07BB`); `docs/UNUSED.md` updated.
* Left alone: two raw mid-routine calls with no label to name them by - `call $0D07`
  (inside `InitHitboxViewer`, from `LoadRoom`) and `call $0CCC` (inside
  `SetStartingLives`, three times in `main.asm`).
* Remaining provisional labels: **138** (`$01` 47, `$09` 46, `$03` 20, `$0D` 14,
  `$0E` 6, `$0B` 4, `$0C` 1). Next: 7.3b, bank `$01`.

Old name -> new name (locals marked `.`):

| Old | New | Old | New | Old | New |
|---|---|---|---|---|---|
| `01AD` | `JumpCheckShotHit` | `1093` | `CheckShotHit` | `1EBF` | `UpdateBossJump` |
| `01B0` | `JumpBeginSpriteFrame` | `10AE` | `CheckShotListHit` | `1F0F`-`2008` | `UpdateBossJump.*` |
| `01B3` | `JumpLoadSkullShipScreenAlt` | `10C6` | (dropped) | `2022` | `GetFireManSpritePos` |
| `01BD` | `LoadSkullShipScreenAlt` | `10E3` | `CheckShotListHit.noHit` | `202E` | `GetCutManSpritePos` |
| `01E6` | `CopyTilemapRowsUnskipped` | `1143` | `ApplyBossDamageTab` | `203A` | `GetIceManSpritePos` |
| `0675` | `VBlankHandler` | `114F` | `ApplyBossDamageTab.byType` | `2046` | `GetElecManSpritePos` |
| `06E4` | `VBlankCopyHUD` | `1246` | `UpdateScrolling` | `2052` | `NextJumpArcStep` |
| `071C` | `VBlankDrawColumn` | `125E` | `QueueScrollColumn` | `2075` | `AddFixedPoint44` |
| `076E` | `VBlankDrawRow` | `1280` | `QueueScrollColumn.column` | `2133` | `TypeYouGot` |
| `07B7` | `UnusedReti1` | `1312` | (dropped) | `215B` | `GetWeaponGetEntry` |
| `07B8` | `UnusedReti2` | `136F` | `UpdateCamera` | `216B` | `TypeWeaponNameLine1` |
| `07B9` | `UnusedJumpReadJoypad` | `1401` | `UpdateRoomTransition` | `2187` | `TypeWeaponNameLine2` |
| `07BC` | `HUDSplitHandler` | `146F` | `QueueTransitionRowDown` | `230F` | `LoadPlayerTiles` |
| `08FE` | `NewGame.laterWilyStage` | `1485` | `QueueTransitionRowUp` | `2338` | `LoadHUDTiles` |
| `0CDC` | `ClearStageRAM` | `14A1` | `QueueTransitionRow` | `2361` | `LoadWeaponShotTiles` |
| `0F04` | `StartTeleportIn` | `155D` | `CopyToGridRow` | `250B` | `GetGfxBlockShort` |
| `0F13` | `TeleportOutWhenGrounded` | `156D` | `FillGridRow` | `2516` | `GetGfxBlock` |
| `0F2D` | `GameOverMenu` | `1600` | `DelayFrameWithSprites` | `2521` | `TripleDeref` |
| `1043` | `SetPlayerScreenX` | `1689` | `CopyBytesBackward` | `2524` | `DoubleDeref` |
| `104B` | `GetPlayerScreenX` | `1B88` | `LoadStageSelectBosses` | `252B` | `UpdateObjects` |
| `1079` | `SetPlayerHitbox` | `1BF9`-`1C64` | `LoadStageSelectBosses.*` | `25E9` | `ExplodeBoss` |
| `2A1E` | `ApplyWeaponToObject` | `1C6D` | `DrawSpriteGrid` | `262E` | `ClearAllObjects` |
| `2A25` | `ApplyWeaponSideEffects` | `1CDE` | `AnimateIntroBoss` | `2657` | `InitStageObjects` |
| `2A3E` | `TryIceSlasherFreeze` | `1CF1`-`1E40` | `AnimateIntroBoss.*` | `26C0` | `LoadSpawnList` |
| `2A56` | `ObjectCollisionPass` | `1E5A` | `CopyToShadowOAM` | `28E2` | `UpdateSpawnWindow` |
| `2B99` | `HurtPlayerByShot` | `1E6D` | `GetStageSelectFrame` | `2BC7` | `InitSpriteSystem` |
| `2BA0` | `HurtPlayerByObject` | `1E81` | `CopyListedTiles` | `2C37` | `BeginSpriteFrame` |
| `3261` | `ClearGridEdgeRows` | `1E86`-`1EB4` | `CopyListedTiles.*` | | |

### Step 7.2 — `freespace` gone (2026-10-09). The source no longer reads the base ROM.

* The three remaining calls were pure `$FF`: bank `$02` `$7CA3`-`$7FFF` (861 bytes),
  bank `$0A` `$720D`-`$7FFF` (3,571) and all of bank `$0F` (16,384). Each is now
  `ds $8000 - @, $FF`; the two audio sections were already pinned (`AudioROM`), and
  bank `$0F`'s section is now pinned at `$4000` (where the linker had it).
* The `freespace` macro is deleted from `macros/legacy.inc`; a stale first `FOOTER`
  in `tools/bankgen/bank01.py` that still named it (overridden later in the same
  file) is removed. `coverage.py` keeps its patterns for old checkouts.
* `grep baserom` over `*.asm`/`*.inc` now finds nothing: `baserom.gb` is needed only
  for `build.sh`/`make.bat`'s byte compare. Checked that no `ld a,$0F` feeds a bank
  switch, so bank `$0F` is unreachable as well as empty. ROM byte-identical.

### Step 7.1 — the last `INCBIN`s (2026-10-09). 100.00% source.

* The two remaining `INCBIN "baserom.gb"`s were the uninitialised-memory filler in
  bank `$04` (`$63F8`-`$6FDF`, 3,048 bytes) and bank `$05` (`$6AAD`-`$6FFF`, 1,363).
  Both obey one rule: the byte depends only on address bit 5 (32-byte runs), with
  the phase opposite in the two banks (`$04`: `$00` where bit 5 is clear; `$05`: `$FF`).
* New macro `uninit_fill END, LOW_BYTE` (`macros/filler.inc`) emits that pattern up
  to END; the ten stray bytes (five per bank, each one set bit inside a `$00` run:
  `$04` at `$6640` `$80`, `$66C0` `$02`, `$6D40`/`$6E80`/`$6F40` `$80`; `$05` at
  `$6B39` `$01`, `$6B7F` `$80`, `$6BBE` `$01`, `$6D60`/`$6F20` `$80`) are plain `db`.
* Bank `$04`'s section is now pinned at `$4000` (where the linker already put it),
  because the macro needs a constant `@`. Bank `$05`'s filler got a label,
  `Unused_05_6AAD`; a stage that grows past `$6B39` trips the macro's ASSERT.
* Coverage 98.17% -> **100.00%**. The base ROM is now read only by `freespace`
  (banks `$02`, `$0A`, `$0F`: step 7.2) and by `build.sh`'s compare. ROM byte-identical.

### Step 6.4 — the audio lock (`$C131`/`$C132`) (2026-10-09). Phase 6 done.

* Every reader/writer by byte search (`FA`/`EA 31/32 C1`): 7 in banks `$00`/`$01`, 15 per
  audio bank, all already in source; no HL-based access. It is a lock on the
  per-frame audio update (`wAudioLock`) and a one-deep saved copy (`wAudioLockSave`),
  not "conditional flags". Write-up in AUDIO.md §2.
* Bank `$01` holds it only after a stage is picked (scroll, starfield, boss name)
  and on the weapon-get screen, and calls `$0405` (now `RunAudioUpdate`) every loop.
  PyBoy hooks at `$06B3` and `$400F`: in the intro, VBlank skipped 299 times and the
  main loop ran the update 299 times, so the music rate is unchanged. In Cut Man's
  stage, firing every 8 frames for 6,000 frames (437 sound loads), the lock was
  never held when VBlank came: loads happen in `DelayFrame`'s queue drain.
* Named from this: `DrainSoundQueue` ($03E4), `PickQueuedSound` ($07DD; restores bank
  $01 hard-coded, which is right because every `DelayFrame` caller runs with bank
  $01 paged), `StartPickedSound` ($0826), `StopAllButMusic` ($083A, uncalled),
  `wQueuedSoundPtr` ($D936), `wMusicSlot` ($DCBC). ROM byte-identical.

### Step 6.3 — audio size and efficiency (2026-10-09)

* AUDIO.md §10. Per bank: driver code 3,270, tables 791, sound data 11,342 (`$02`) /
  8,619 (`$0A`); free 862 / 3,571. `$5054`-`$5BE9` (effects, Boss, Victory: 2,966 bytes)
  matches across banks with pointers shifted by 14, so ~7.1 KB is duplicated.
* All audio together ≈ 21.2 KB (≈ 19.5 KB without unreachable songs and vibrato):
  not one bank as encoded. 3,126 of 5,465 notes repeat the previous length, so the
  unused (and broken) one-byte mode could have saved up to ~3 KB. 540 bytes of inert
  `F9`; 10 distinct waveforms in 15 slots. Will: the original question was about
  efficiency, not a literal single bank.

### Step 6.2 — audio anomalies, and the audio labels renamed (2026-10-09)

* Wrote [AUDIO_ANOMALIES.md](AUDIO_ANOMALIES.md): 4 bugs with an effect on play, 9
  latent driver defects, dead code/data, data oddities, each with routine, reason
  and how it was checked. Used PyBoy 2.8.1 (pip) on `baserom.gb`: wait 200 frames on
  the title, then poke `wSoundQueue`/`wAudioBank` and read RAM per frame.
* **Wily 1 (A1), timed in the emulator:** the bad jump comes at 38.6 s. The misread
  bytes are mostly 57-tick rests, which retrigger a quiet low E about every 2.9 s.
  Channel 1 doubles the bass from ~116 s. (6.1's "a few long notes" was wrong;
  AUDIO.md is corrected.)
* **Slot-4 bug (A2) reproduced:** with slots 1, 2 and 4 busy and slot 3 free,
  `SFX_Empty2` (free `SFX2` track) is refused; without the slot-4 sound it loads.
* **Inherited settings (A3):** InitTrackVars leaves `EnvRest`, sweep, duty, waveform
  and repeat state. The boss theme's rests have no `FD` of their own, so they come
  out at volume 3 after Cut Man and 6 after Ice/Fire Man (`NR12` shadow `$33` vs
  `$63`). Tracks that use an unset field are listed.
* **Stale repeat counters (A4):** `SFX_Wheel` cut off by `SFX_PlayerHit` mid-`B2`
  leaves the counter at 2; the next Wheel plays its body twice, not three times,
  and ends 26 frames early.
* **Vibrato (B1):** never called, and `ProcVibSeqs` indexes `PerAddrs` by track (0-7),
  so music tracks would write to `$FF3E` (wave RAM), cart-RAM addresses and the MBC1
  mode register. The one-frame channel-1 mute after `InitAudio` was seen in the
  emulator (`NR51` `$EE` on frame 84 of boot).
* **Renames (Will asked for them):** 22 labels in both audio banks, `ram/audio_ram.asm`,
  the constants and the bank `$00` stubs (`AudioSFXOff` → `AudioStopAll`,
  `AudioCondSoundOff` → `AudioStopSlot`, `CurRNG` → `SongCue`, `ChanSlotVals` →
  `TrackSlots`, …), the envelope-sequence table relabelled 8 bytes per sequence, and
  wrong comments fixed. Bugs marked `BUG:` in the source. ROM unchanged
  (byte-identical). Earlier log entries keep the old names.

### Step 6.1 — `docs/AUDIO.md`, the audio driver (2026-10-09)

* Wrote [AUDIO.md](AUDIO.md): the interface, the queue, slots/tracks/channel
  stacks and priority, timing, the full command table with per-channel
  availability and use counts, envelopes, register output, and the RAM (global
  block and the `$59`-byte track RAM, offset by offset). Added `tools/audiodump.py`,
  which walks every sound in both banks from the ROM (follows jumps, models the
  one- and three-byte commands); `--headers` and `--uses CMD`.
* **The two drivers are one source**: label-normalised, banks `$02` and `$0A` differ
  only in three label names, and `$0A`'s copy is shifted by its 14-byte `Audio2_Empty`.
* **Wily 1's loop is broken** (`$02:70AD`, `B0 59`). Channel 1 needs to jump back
  167 words, which overflows the signed-byte offset to +89. After ~38.6 s, pulse 1
  reads channel 2's data out of step and then doubles channel 3's bass line for
  good. Will reported the bad loop the same session. It is the only jump in either
  bank that leaves its own track.
* **Priority bug**: for a free track RAM the owner lookup reads `SoundPriorities-1`
  = slot 4's busy flag (`$4175`), so while slot 4 is busy, sounds needing a free
  track are refused. Left for 6.2 to judge in play.
* Behaviour vs. labels: `LoadSong` = `LoadSound` (loop-forever path dead),
  `SFXOff` stops all, `CondSoundOff` stops slot `[$CC4A]`, `Slur` is
  hardware-length mode, `E6`/`CurRNG` is a song→game cue ($E1, $E4), `F3` is the
  waveform number, `NoiseEnvs` is the wave volume table, envelope sequence n is
  8 bytes at `EnvSeqs`+8n. Listed in AUDIO.md, not renamed.
* Game side: only the highest-priority sound queued in a frame starts
  (`$07DD`/`$0826`, pending pointer in `$D936`); music slot kept in `$DCBC`;
  `$083A` (stop all but music) is uncalled. Stage select and weapon-get pump the
  audio from the main loop via `$0405` while holding `$C131` (lead for 6.4).

### Follow-up from Will after 5.6 (2026-10-08)

* Types 49 and 50 have no official names (Will), so they are named by role:
  `WilyMachineLowerCannon`, `WilyMachineBitingHead`; with them
  `WilyMachineCannonShot` (51) and `WilyMachineCuttingWheel` (52). Files renamed.
* **Wily's landed frames are his bow** after the fight (Will: not scrambled in
  play). The render was wrong, not the data: those frames use 7-bit tile numbers
  (`$CE57` set - bits 0-6 the tile, bit 7 X flip), which `tools/objframes.py`
  now draws with a final `7` argument.
* **The "bar-fill animation" is a light on the Wily Machine's visor** (Will):
  renamed `DrawVisorLight` / `VisorLightFrames` and friends.

### Step 5.6 — bank `$0D`, the last object bank (2026-10-08)

* **Bank `$0D` is 100% source**, byte-identical (whole ROM **98.17%**; every bank
  is source except bank `$04`'s and `$05`'s filler). Done by a helper agent on
  its own copy from my starting config, merged and checked here (clean build).
  Layout: entry table, the shared library at `$401B`, a copy of
  `QueueTileCopy`/`CopyQueuedTiles`, helpers for the Wily Machine, the fight's
  five types, then Quick Man's, the teleporter light's and the sign's.
* **The Wily Machine fight** (type 48, `WilyMachine`, placed in Wily 3's last
  room) runs as a chain of states held as a code pointer ($3E/$3F,
  `ObjSetState`): set-up (streams the room's 80 background tiles, spawns type
  49), phase 1 (type 49, a lower cannon that bobs and throws type 52, the spiked
  wheel - the fight's Cutting Wheel), then Dr. Wily appears in the cockpit:
  phase 2 adds type 50 (a head that flies at Mega Man) and a cannon whose shots
  (type 51) can only hurt the machine when Mirror Buster sends them back; then
  the explosion, Wily jumps out, wStageState 2, and the victory timer leads
  `StageFrameLoop` to the ending (bank `$0E`).
* **The Wily Machine room's tiles are bank `$0D`'s own** (`$D:5476`), not bank
  `$06`'s cutscene tiles as step 4.4 matched visually; `leveldump.py` fixed and
  the Wily 3 render redone.
* **Quick Man** (46): runs, jumps twice at Mega Man, throws three boomerangs on
  one jump; Time Stopper drains him 1 HP every 50 frames. **Type 47 is his Quick
  Boomerang** - three fanned shots that home on Mega Man, and like every boss's
  companion they end the fight. **Type 53** (teleporter light) blinks only while
  its teleporter's boss is unbeaten; **56** (the sign) blinks every 24 frames.

**Open questions carried forward:**

* Does sending type 51 back with Mirror Buster cost 8 energy in play?

### Follow-up from Will after 5.4 (2026-10-08)

* **Drillun and Picopico are unused enemies** (Will). Drillun (type 13) matches
  its official artwork - a drill with a green cap and eyes - and the code agrees
  it never appears: no placement, no spawner, and the ending skips it. Picopico
  has only its ending entry (name, sprite, tiles, also skipped); Will found
  nothing on it beyond the name's likeness to Picopico-kun, a boss of the NES
  Mega Man 2 `[?]`. Every roll-call name is now accounted for.

### Step 5.4 — banks `$0B` (Wily cutscenes) and `$0E` (the ending) (2026-10-08)

* **Both banks are 100% source**, byte-identical (whole ROM now **95.06%**). Each was
  finished by a helper agent working on its own copy, then merged and checked
  here (clean build from the PNGs). Code in `engine/cutscenes/` and
  `engine/ending/`, graphics in `gfx/cutscenes/` and `gfx/ending/` (make.bat
  updated), two new tilemaps, and a `rollcall` charmap for the ending's text.
* **Bank `$0B` = the Wily cutscenes** (`PlayWilyCutscene`), played before Wily 1
  and Wily 3, skippable with A/B once seen (`$DFCF`, `$DFD0`). Before Wily 1: the
  stage select with all four portraits empty and Dr. Wily in the middle slot,
  then (Start) a flash, Wily's saucer flying in and out, and Mega Man beaming
  down at the castle. Before Wily 3: a saucer rising from the castle, then the
  skull ship fading in under the stars. Scenes wait on the music: a song writes
  $E1 to `CurRNG` ($D9A8) as a cue (so that byte doubles as a track event).
* **Bank `$0E` = the ending.** Scene 1: the skull ship explodes and a small craft
  flies off. Scene 2: stars, a shuttle, big Mega Man, then the **roll call**
  (`RollCallScript`), one enemy every 450 frames with its name. Scene 3: Mega Man
  walks down a corridor with windows on space (a 70x9 room drawn with the stage
  engine), then "THANK YOU FOR PLAYING" forever.
* **The roll call confirms the names** by tile shape (the ending's tiles use other
  colour indices): SUZY = 21, CHANGKEY = 11, DRILLUN = 13, SCREW DRIVER = 2,
  SUPER CUTTER = 5, METALL = 17, GABYOALL = 3, SCWORM = 24, MOLE = 18, PIPI = 19,
  BIGEYE = 6, KAMINARI GORO = 15, CHANGKEY MAKER = 12, BUNBY HERI = 7. CUTTING
  WHEEL is drawn with the Wily Machine's wheel tiles (types 48-51), not type 1's -
  the "other version" Will mentioned. SNIPER JOE and PICOPICO use tiles found
  nowhere else. **The script skips DRILLUN and PICOPICO**: both have full
  entries but are never shown.
* The two banks open with the same kit (far call into bank `$01` through a WRAM
  trampoline, LCD off, queued tile copies, a sprite-system set-up, 8x16
  metasprite drawing), named like their bank `$00`/`$08`/`$0C` counterparts with
  `_0B`/`_0E`. Bank `$0C`'s unused copy is now `InitSpriteSystem_0C` (its address
  in the comment was off by 2).

**Open questions carried forward:**

* The 120-frame "flash" after Start on the Wily stage select: BGP/OBP0 get the
  frame counter (a missing `ld a, e`?). What does it look like?
* Sounds $02/$28 in the ending, and which songs write the $E1 cue.

### Follow-up from Will after 5.3, continued (2026-10-08)

* **Type 13 is Drillun** (Will; the ending lists DRILLUN): renamed `Drillun`,
  file `engine/objects/drillun.asm`. The step 5.2 trace stands - no stage places
  it and nothing spawns it - so it is in the ending's cast but never in play;
  that makes PICOPICO the only roll-call name left unmatched.

### Follow-up from Will after 5.3 (2026-10-08)

* **Bank `$03`'s enemies named** (Will), checked against the ending's roll call:
  type 1 `CuttingWheel` (another version is used in the fight against Dr. Wily),
  2 `ScrewDriver`, 3 `Gabyoall`, 5 `SuperCutter`, 6 `Bigeye`, 7 `BunbyHeli` (the
  ending misspells it BUNBY HERI), 17 `Metall`, 18 `Mole` (the placed object is
  the controller that spawns the moles), 21 `Suzy` (Adhering Suzy, Octopus
  Battery), 22 `ElectricBeam` (an obstacle, so not in the ending). Files renamed
  to match. With bank `$09`'s names, every roll-call name is now matched except
  DRILLUN and PICOPICO - probably among bank `$0D`'s types `[?]`.
* The Wily fight's Cutting Wheel variant is probably the wheel enemy the Wily
  Machine shoots (types 49-51, bank `$0D`) `[?]` - step 5.6.

### Step 5.3 — bank `$03`, the second object bank (2026-10-08)

* **Bank `$03` is 100% source**, byte-identical (whole ROM **85.40%**), with the
  same layout as bank `$09`: entry table, the shared object library, and 22
  object types, one file each in `engine/objects/`. Bootstrapped with
  `tools/bankgen.py` and `tools/bankgen/bank03.py`; the library's names and
  comments now live in `tools/bankgen/objlib.py` (by offset), so a bank config
  just calls `lib(base)`. When the shared file already exists, bankgen checks
  it comes out the same and writes `.new` if not - which caught one label bank
  `$03` needs: `GiveBossFullEnergy` (the end of `FillBossEnergy`).
* **The first four robot masters** - Cut Man (30), Ice Man (32), Elec Man (34),
  Fire Man (36) - work like the Wily 2 bosses: their shots are separate objects
  placed beside them and parked off screen until asked for through `$CCF6` (31
  Rolling Cutter, which flies out and homes back; three 33 Ice Slashers; 37 Fire
  Storm), and the shots, not the bosses, end the fight. **Why Fire Storm is
  beside Elec Man** (open since 4.3): Elec Man fires his own shot, type 35 (a
  7-tile zig-zag chain - the Thunder Beam `[?]`), and never asks for a type 37;
  it is there only to end his fight.
* **Every routine has a behaviour comment** (read with four helper agents, then
  spot-checked). Named from the code: Elec Man's shot (`ElecManShot`), the fan,
  the ice platform (Will: it melts while stood on - the code counts frames of
  standing, 90 and it is gone), the appearing blocks (one object runs a whole
  schedule; the format is decoded, `AppearingBlockSchedules`), the icicle, and
  about 150 internal routines and tables (23 still `Func_03_`, each inside a
  commented object). Types 1, 2, 3, 5, 6, 7, 17, 18, 21 and 22
  keep `ObjNN` names until Will identifies them (renders:
  `bank03_unnamed_objects.png`).
* Found: type 18 is placed as an invisible controller that spawns type-18
  children from four fixed screen points; the spawn "param" (+06) of every
  object is the low nibble of its spawn record's Y byte; `ObjLibFunc_08D`'s
  comment had its result backwards (fixed); type 5 can only be hurt with Ice
  Slasher; type 3 writes `$DFC5`, which nothing reads. Dead code and unused data
  in UNUSED.md.

**Open questions carried forward:**

* Is type 35 the Thunder Beam, and type 6 hittable only when tall?

### Follow-up from Will after 5.2 (2026-10-08)

* **Bank `$09`'s enemies named** (Will), checked against the ending's roll call:
  type 4 `SniperJoe`, 10 `FireBeam` (several directions), 11 `Changkey`, 12
  `ChangkeyMaker`, 15 `KaminariGoro` (Lightning Lord), 19 `Pipi` (drops eggs with
  Copipi inside: 27 `PipiEgg`, 28 `Copipi`), 24 `Scworm`. Their children are
  named from the code: 14 `KaminariGoroThrower` (rides 15 and throws), 26
  `KaminariGoroShot`, 25 `ScwormSpawn`. Files renamed to match; type 13 stays
  `Obj13` (unused; named Drillun after 5.3).
* **The ending's roll call** (bank `$0E`, `$50A4`-`$51CC`, ASCII − `$20`, not yet
  source) names, in order: SUZY, CHANGKEY, DRILLUN, CUTTING WHEEL, SCREW DRIVER,
  SUPER CUTTER, METALL, GABYOALL, SCWORM, MOLE, PIPI, SNIPER JOE, BIGEYE, KAMINARI
  GORO, CHANGKEY MAKER, PICOPICO, BUNBY HERI, then the eight robot masters and
  ENKER. Spellings used here follow it (PIPI, so `Copipi`; SCWORM, which Will
  confirms is the proper spelling). Fire beams and Copipi are not in the list. The rest
  are candidates for types 1-29 in banks `$01`/`$03`/`$0D` - to be matched by the
  ending's sprites when bank `$0E` is done.
* **Render fix** (Will spotted scrambled frames for types 12, 15 and 24/25):
  the frames were right, the renderer was not. An object's frame tiles count
  from its tile base, and Changkey Maker (+8), Kaminari Goro (+$11) and
  Scworm's spawn (+1) add to theirs at spawn, past tiles a related type uses.
  `tools/objframes.py` takes that offset as an optional last argument now.

### Step 5.2 — bank `$09`, the first object bank (2026-10-08)

* **Bank `$09` is 100% source**, byte-identical (whole ROM **79.23%**). It was
  bootstrapped by `tools/bankgen.py`, the step 5.1 generator made general (one
  config per bank: `tools/bankgen/bank09.py`; `bank01.py` reproduces bank `$01`).
  `banks/bank09.asm` is the include list and map; `engine/objects/` has the entry
  table and one file per object type.
* **The object library.** Bytes `$4048`-`$4749` are 1794 bytes of helpers that
  banks `$03` (`$4042`) and `$0D` (`$401B`) carry too, identical except for
  addresses. It is one file, `engine/object_library.asm`, included by all three
  banks with `OBJBANK` = `_03`/`_09`/`_0D` interpolated into its labels; so banks
  `$03` and `$0D` are now 12% and 20% source.
* **How objects make objects** (the open question from 4.3): `SpawnChildObject`
  - the type in `$CC07`, position `$CC0D`/`$CC0F`, tile base and params
  `$CC05`-`$CC08`; the parent then runs the child's init itself. Every caller in
  the ROM was found: in bank `$09`, 12 spawns 11, 15 spawns 14, 14 spawns 26, 24
  spawns 25, 19 spawns 27, 27 spawns six 28s, Enker (38) spawns 39 and Flash Man
  (42) spawns 54; bank `$03` spawns 18 and 35, bank `$0D` 49-52. **Type 13 is
  unused**: nothing places or spawns it (UNUSED.md) - an unfinished platform.
* **Object routine modes**: B = 0 spawn, 1 frame, 2 hit points gone, 3 frozen by
  Ice Slasher; return B = 0 to be removed. **Offsets `$15`/`$17` are the frame
  table and frame**, not a handler and its index: renamed `OBJ_FRAMES` and
  `OBJ_FRAME` (`constants/objects.inc`). The routine address is the record's
  first two bytes.
* **Every routine has a behaviour comment** (read for this step, with the frames
  drawn by the new `tools/objframes.py`). Named, from the code: Enker and his shot
  (39, `EnkerShot`: power from the damage he absorbs), `FlashManFreeze` (54: stops
  Mega Man for 90 frames - presumably the Time Stopper `[?]`),
  `FlashManDefeatWatcher` (43), and 125 internal routines and tables. The five type
  41s and three type 45s **are Bubble Man's and Heat Man's shots** during the
  fight (asked for through `$CCF6`), not weapons placed for afterwards as step 4.3
  read them; with the parked type 43 beside Flash Man, they end those bosses'
  fights. Enker takes damage only while jumping or absorbing, from the Mega
  Buster `[?]`. The 14 enemy types keep `ObjNN` names until Will identifies them.
* Bank `$00`: the object banks' stubs are named (`JumpCheckSolidPoint`,
  `JumpSpawnExplosionBurst`, `JumpAddSolidBox`; `CheckSolidPoint` at `$0F96`).
  `CheckPlayerInBox` returns carry when Mega Man is *outside* the box.
* `$CCF2`-`$CCFA` double as boss-fight state (RAMMAP): `$CCF5`, which step 5.1
  saw cancel damage, is the boss-beaten flag.
* Found along the way (UNUSED.md): six dead routines, including one that writes
  background tiles where the boss door is; five library routines bank `$09`
  never uses; five orphan frames; two unreachable branches.

**Open questions carried forward:**

* Is type 54 the Time Stopper, and type 39 the Mirror Buster (offset `$1A` as a
  shot's damage to Mega Man)?

### Step 5.1 — bank `$01`, the resident bank (2026-10-07)

* **Bank `$01` is 100% source**, byte-identical (whole ROM **70.45%**; the bank's
  `$FF` tail is now an explicit `ds`, which the tool counts as assembly, so part
  of the jump from 64.16% is that). It is split by subsystem like bank `$00`:
  `engine/weapons.asm`, `items.asm`, `explosions.asm`, `pause_menu.asm`,
  `hud.asm`, `title_menu.asm`, `stage_select_menu.asm`, `weapon_get_screen.asm`,
  `picture_viewer.asm`, `player.asm`, and `data/weapon_frames.asm`,
  `data/megaman_frames.asm`; `banks/bank01.asm` is the include list and map.
  Code was found by recursive descent from every entry point (bank `$00`'s calls,
  `CallBank1Routine`, the RAM hooks, `ObjectTypeTab`'s type 8, WeaponTab's 22
  handlers); everything else was classified by hand. 424 labels; 47 (all code)
  are still provisional, nearly all tails of the player physics and the item
  and explosion loops, and each has a comment.
* **The bank is the player and his weapons**, not the HUD-and-menus bank the plan
  expected (those are 2 KB of the 13): WeaponTab (one 16-byte record per weapon,
  including the fire and update routines), `TryFireWeapon`/`UpdateShots` and
  three `$20`-byte shot slots at `$C239`, each weapon's behaviour (Rolling Cutter's
  arc and homing return, Thunder Beam's three bolts, Fire Storm's orbiting shield,
  Atomic Fire's charge levels, Time Stopper's `$DFB1` bit 3, Mirror Buster
  catching enemy shots and firing them back), items and drops, explosions, the
  pause menu, the HUD, the title and stage-select screens, the weapon-get screen,
  and all of Mega Man's movement - walking, jumping (variable height), ladders,
  knockback, gravity (lower under water), collision, drawing, teleporting.
* **Answers to carried questions.** `wHookA` (`$C0AA`) is called by
  `UpdatePlayer` whenever Mega Man can act - it is the fire button. Collision
  values: 0 passable, 3 solid, 1 solid in the block's lower half (spikes), 2 in
  its upper half (ladder tops); blocks 1 and 2 are tested by number as ladder and
  ladder top (`CheckSolidAt`, bank `$00`). `$D908` is the floor type (2 = ice:
  walking accelerates at 4 instead of $40), `$D909` the underwater flag.
* **Shot damage.** A shot's offset `$0B` is its damage, and the hit list points
  the collision pass straight at it: a hit subtracts the enemy's value from it,
  so a shot can survive a weak enemy, per the weapon's pierce flags. Atomic Fire's
  charge levels do 1, 2 and 5, and bank `$00` scales boss damage by the same.
* **Item drops**: one FuncRNG roll per kill. Below `$9A` nothing, `$9A` an extra
  life, then big health, small health, big energy and small energy (3, 24, 10
  and 64 values of 256). Placed items (object type 8) are
  remembered once collected.
* **Found along the way:** `FreeAllShots` stops after two of the three slots;
  four unused picture viewers; an unreachable hang trap; three unreferenced data
  items (UNUSED.md). The weapons' two-letter names (P, CU, EL, IC, FI, CA, HE, FL,
  QU, BU, EN) are the bosses' initials, now text in a new `menu` charmap; "AND
  CARRY" is text in `getscreen`.
* RAM: 40 new labels for the shot state (`$C200`-`$C29A`), the weapon record,
  Mega Man (`wPlayerX/Y`, facing, motion, animation, hurt timer, joypad copies),
  `wFloorType`, `wUnderwater`, `wFreezeFlags` (`$DFB1`), `wTeleportState`; bank
  `$00` now uses them, and its calls into bank `$01` are by name.

**Open questions carried forward:**

* `$C22D` (a new shot's offset `$00`): non-zero marks the slot in use, bit 1
  puts the shot on the hit list, 1 is a deflected pellet - the rest is untraced.
* `$C217`, `$DF93`, `$D869`, `$D845` are used by bank `$01` but not
  understood (`$DF93` stops contact damage).
* `Func_01_65AB` (after a stage is chosen) and the HUD digit table's layout.
* `$41E6`: eleven bytes per weapon that nothing reads - nine match the weapons'
  firing sounds (UNUSED.md).

### Follow-up from Will after 4.4 (2026-10-07)

* **Boss weapons and Wily objects identified** (labels renamed in bank `$07`,
  `data/gfx_pointers.asm` and `ObjectTilesetPtrs`; spawns and ObjectTypeTab
  annotated): 31 Rolling Cutter, 33 Ice Slasher, 37 Fire Storm, 41 Bubble Lead, 45
  Atomic Fire, 47 Quick Boomerang (each placed beside its boss), 48 Dr. Wily and
  the Wily Machine's sprite parts including its wheel enemy, 53 the light on an
  active teleporter, 55 the boss door; 39 possibly the Mirror Buster. The PNGs
  keep their `obj_typeNN` names for now.
* Consequence: objects can create other objects - the wheel enemy (likely 49-51,
  which share 48's tiles) and maybe 39 are never in a spawn list. That route is
  not in `SpawnObject`'s one caller; Phase 5.
* Open: type 37 (Fire Storm) is also placed beside Elec Man; type 43 (beside
  Flash Man) loads the Rolling Cutter's tiles.

### Step 4.4 — bank `$07` (2026-10-07)

* **Bank `$07` is 100% source**, byte-identical on the first build; whole ROM
  **64.16%**. **Phase 4 is complete.** The bank is graphics, not object placement
  (placement is in the room records, 4.1).
* **Object types 30-56:** 21 tileset records and their tiles, now PNGs in
  `gfx/bosses/` - `cut_man`, `ice_man`, `elec_man`, `fire_man` (each spawned in
  that master's boss room, and loaded for his stage-select portrait), `enker`,
  `bubble_man`, `flash_man`, `heat_man`, `quick_man` (4.3), the rest by type.
  Shared: 43 uses 31's tiles, 35 uses 33's, 49-51 use 48's, 54 uses 53's.
* **What the tiles show:** type 56's spell "DR.WILY TELEPORT SYSTEM" - it is the
  hub's sign, not a teleporter (corrects the 4.3 guess); type 41's are bubbles
  (Bubble Man's room); type 55's are the shutter stripes, which backs type 55 as
  the boss shutter; type 48 has 116 tiles, almost all of sprite VRAM.
* **The stage-select robot masters** are bank `$07` data too: four tile lists
  (count, then a source tile per destination tile, `$FF` blank) that
  `Func_00_1B88` uses to build each master's sprite tiles out of his boss
  tileset, 19 metasprite frames (`Func_00_1C6D`'s format: cols/rows byte,
  8x16 tile pairs, extras to `$80`), and two 45-step jump arcs. Rendered with the
  new `tools/stageselect.py` to `docs/sprites/stage_select_robot_masters.png`:
  standing poses and the jump frames, all four correct. The ROM0 slots
  `$036D`-`$03A9` are now `GfxRef_*` names, and `engine/stage_select.asm` uses
  them instead of literals.
* **The Wily Machine room solved:** its blockset draws background tiles 0-`$4F`
  of bank `$06`'s Wily Machine cutscene graphics - with those, the room shows the
  machine as background. `leveldump.py` loads them (`BLOCKSET_TILES`); the
  render in `docs/levels/7_wily3.png` is fixed. The loading code is not traced.
* Type 52's tileset entry would load type 47's tiles (UNUSED.md).

### Follow-up from Will after 4.3 (2026-10-06)

* The Wily renders match the game, except the Wily Machine room, which fades in
  from black with a tileset the stage data does not name, so the render is
  garbled. Source of those tiles still untraced (LEVELS.md "Render limits").
* Object types, as Will's identifications (`[?]` until traced): 53 teleporter
  (spawned with its number as Y), 56 the teleporter to Enker (placed at Enker's
  teleporter's X), 48 the Wily Machine or part of it. Bubble Man's room is the
  game's only underwater area and has bubbles, which fits `$D909` and maybe
  type 41. Annotated in `data/object_tables.asm` and the Wily stage files.

### Step 4.3 — the Wily castle (2026-10-06)

* **Bank `$08` is 100% source**, byte-identical on the first build; whole ROM
  **57.18%**. New stage files `wily1.asm`, `wily2.asm`, `wily3.asm` and
  `wily2_test.asm`; bank `$08` pinned at `$4000` with a `ds` tail. Renders for
  stages 5-7 and 9 in `docs/levels/`.
* **Wily 1 runs straight into Wily 2.** Its last room's exit leads into Wily 2's
  hub room; on the way down its frame hook streams Wily 2's tiles into VRAM in
  $40-byte chunks (`QueueTileCopy`/`CopyQueuedTiles` at `$08:4008` - the routine
  bank `$0C` has a dead copy of - from a second copy of the tiles kept in bank
  `$08`), and the hub's room routine swaps in Wily 2's blockset and hooks with
  `SwapRestartData`. Wily 3 uses the same call to switch to the Wily Machine
  room's own blockset.
* **Wily 2 is the teleporter hub.** A state machine fades in, watches for Mega Man
  standing exactly on one of five teleporters, fades out and loads that
  teleporter's restart record through `JumpLoadRestartPoint`, so each boss room
  starts as a stage. Bosses, named through the weapon each awards
  (`wHubTeleporter` + 4 on the weapon-get screen): **Quick Man (type 46),
  Bubble Man (40), Flash Man (42), Heat Man (44), Enker (38)**. The plan's list of
  six Mega Man 2 bosses was wrong. Wily 3's last room spawns type 48.
* **RAM:** `wWilyProgress` (`$DF96`: hub bosses beaten, bit 7 hub reached),
  `wHubTeleporter` (`$DF97`), the hub state `$D90A`-`$D90F` and the tile copy
  `$D910`-`$D916`, substituted through the engine.
* **Leftovers:** an unreferenced ninth stage at `$08:6D05` that lays out Wily 2's
  four room layouts side by side (a test stage); Wily 1's third restart point is
  Wily 2's start and unreachable, with an orphaned Wily 1 record beside it; an
  orphaned Wily 3 record; duplicate Wily 2 checkpoints; an unreadable teleporter
  table entry. All in UNUSED.md.
* **Unplaced object types, now final for the stage data:** 13, 14, 25-28, 35, 39,
  49-52, 54.
* `leveldump.py` handles all nine stages: per-room blocksets, restart records
  outside the table, exits that leave a stage.

### Step 4.2 — stages as macros (2026-10-06)

* **Every decoded stage is now editable source** in `data/stages/` (Cut Man,
  Ice Man, Fire Man, Elec Man, alternate Fire Man), written with the new
  `macros/stages.inc`. Layouts are `lrow "0D 20 21 ..."` strings - one row of
  hex block numbers per line, so a room reads as a picture - and blocks are
  `block tl, tr, bl, br` in on-screen order. Byte-identical on the first build.
* **The macros guard edits:** row width and row count per layout, exit length,
  no type-0 spawn, the block count computed from labels, and a collision table of
  exactly one byte per block (at most 64). Each check was tested by breaking a
  copy of the source on purpose.
* **Bank `$05` is pinned at `$4000`** and its padding is `ds $8000 - @, $FF`
  instead of `freespace`, so stages can grow by about 4 KB (5.3 KB if the
  filler `INCBIN` is deleted). Coverage counts that padding as assembly, as it
  does for banks `$00`/`$06`/`$0C`: bank `$05` 22.3% → 91.7% (the 8.3% left is
  the filler), bank `$08` 2.4% → 15.6%, whole ROM **51.08%**.
* Docs: LEVELS.md "Editing a stage" (with how to preview an edit through
  `leveldump.py mmwr.gb`), a "Stage data" section in CONVENTIONS.md.

### Follow-up from Will after 4.1b (2026-10-06)

* **Prototype boss doors are non-functional** - Mega Man walks through them and
  they never open. That matches the alternate Fire Man stage's corridor door,
  which is passable map blocks with no object attached (UNUSED.md).
* **Object type 9 is a fan** that blows Mega Man away; **type 29 is a block only
  Atomic Fire can destroy**. Labels renamed (`FanTiles`/`FanGfx`/`GfxPtr_Fan`,
  `AtomicFireBlockTiles`/`AtomicFireBlockGfx`/`GfxPtr_AtomicFireBlock`) and the
  ObjectTypeTab entries and bank `$05` spawns annotated. The PNGs keep their
  `obj_typeNN.png` names for now. Fans are placed in Elec Man's stage and Wily
  stages 1 and 3; the Atomic Fire blocks only in Wily stage 3 (four).

### Step 4.1b — the alternate Fire Man stage (2026-10-06)

* **Rendered** (`docs/levels/8_fire_man_alt.png`) and **made source**: bank `$08`
  `$6F67`–`$7828` is now records, code and labelled layout/blockset `INCBIN`s
  like bank `$05`, so the build proves the parse. `StagePtr_FireManAlt` replaces
  `Ptr_08_4006`. Bank `$08` 0.1% → 2.4%; whole ROM **45.29%**.
* **Compared with the final stage:** 9 rooms against 13, all downward; only the
  first room is (nearly) the same; 4 spawns against 57 - two type 8 and the boss
  pair, so the map looks finished and the enemies not placed. Same block parts
  (27 of 36 definitions identical, identical collision), own tileset.
* **The shutters are drawn into its layouts** - the only stage where they are: a
  passable 2×4 door of block 3 in the corridor room (beside the same blocks 4–7
  group that flanks object type 55 in the final stages), and a solid 1×4 door of
  the last block in the **left wall of the boss room**. That is the only
  side-wall door anywhere, nothing leads through it, and it is the strongest
  trace yet of the side-by-side boss doors. Written up in UNUSED.md.
* **Its frame hook** is Fire Man's palette cycle (colour 3 darker) and the spike
  test, without the behind-BG zone code - so that code, identical to Elec Man's,
  was added to the final Fire Man hook later and never given any zones.
* `leveldump.py` gained the stage's first-frame palette (`$8F`).

### Step 4.1 — bank `$05` level data format (2026-10-06)

* **Format decoded and proven by the build** — written up in `docs/LEVELS.md`.
  Stage header → restart points (start + one per checkpoint; 14-byte records:
  blockset, collision table, init, frame hook, Mega Man's start X/Y, start room)
  and a checkpoint list → rooms (id, routine, layout, X offset, two exits, spawn
  list). Layouts are 8 rows of 16×16 blocks; blocks are 4 tile numbers (TL, BL, TR,
  BR); one collision byte per block. Rooms connect only vertically. The old notes'
  "sections" are restart points and "sub-sections" are rooms.
* **Bank `$05` 0.1% → 22.3%**, whole ROM **45.13%**. Every header, restart point,
  checkpoint, room, exit and spawn is `db`/`dw` source with labelled pointers, so
  any mistake in the format would have broken the build. Layouts and blocksets
  are still `INCBIN` (labelled), for 4.2. The four stages' own code is source:
  Cut Man's conveyor belts and palette flicker, Ice Man's ice blocks (`$D908`),
  spikes (block 8, all stages), Fire Man's palette cycle, and the behind-BG zones
  that put Mega Man behind Elec Man's clouds - Fire Man has the same code with an
  empty table.
* **Bank `$00` loader named:** `UpdateRestartPoint`, `LoadRestartPoint`,
  `CheckRoomExits`, `DrawRoomView`, `LoadRoom`, `BuildExitBoxes`,
  `BuildExitBox`, `DrawBlock`, `JumpLoadRestartPoint`; 18 WRAM labels for the room
  state (`wRestartPoint`, `wRoomID`, `wExitBoxes`, `wBlockCollision`, …).
  `wStageParams` became `wRestartPointsPtr` + `wCheckpointsPtr`.
* **`tools/leveldump.py`** dumps any stage and renders it to PNG (`--objects`
  marks spawns by type, `--blocks` writes the blockset sheet), pairing data and
  tiles through the game's own tables. Renders of stages 1–4 are in
  `docs/levels/` - confirmed against the game by Will.
* **`$16AAD`–`$16F21` explained:** the stage data ends at `$16AAD`; the rest of
  `$6AAD`–`$6FFF` is the same uninitialised-memory filler as bank `$04`'s.
* **Vestigial boss-door candidate** (UNUSED.md): side-wall exits that
  `BuildExitBox` supports and no stage uses. Also unused: restart-point byte 0,
  the checkpoint records' second byte. **Object types 13 and 14 are never placed.**
* **Follow-up from Will:** the renders match the game. The final game has one
  boss shutter per stage (walk through it, then drop into the boss room), so the
  striped open/closed block pair that no layout places is that shutter, drawn at
  run time - most likely by object type 55 (bank `$09` slot 23), which each stage
  spawns once at column 5, Y `$30` of the room before the boss room.
* **Password sounds confirmed by Will:** a correct password plays the extra-life
  jingle (ID `$10`), a wrong one explosions (`$02`) and Mega Man's death explosion
  (`$0F`). That matches the "SoundTab index + 1" rule in `QueueSound`'s notes;
  bank `$0C` comments updated.
* Correction: `LoadStage` does not page in bank `$05` "for shared stage code" - there
  is none; the write is redundant.

### Step 3.3 — bank `$0C` (2026-10-05)

* **Bank `$0C` is 100% source**, byte-identical; whole ROM **43.82%**. Step 3.4's
  compression audit closes with nothing found: banks `$04`, `$06` and `$0C` hold
  only plain tiles and maps.
* **Stage tilesets.** Eight `LoadStageTiles` lists, one per stage, each loading the
  stage's own tiles at tile 0 plus two shared runs at 98 and 112. PNGs in
  `gfx/stages/`. The unused eighth slot's set (`fire_man_alt.png`) is 79 tiles like
  Fire Man's, in the same style, with 18 tiles identical to his.
* **`wBank1Trampoline`** (`$C0B0`) is code, not a table: `FarCallBank1` (`$C:4016`)
  copies a 23-byte call-into-bank-1 routine there. Banks `$0B`/`$0E` carry the same
  kit. Closes the open question about `$C0B0` overlapping the RAM-code block.
* **The password system.** `$4010` is `EnterPassword`, `$4013` `ShowPassword`.
  Passwords are five balls on a 4×4 grid (rows A–D, columns 1–4); a password
  encodes only which of the four robot masters are beaten, so there are exactly
  16, all in `PasswordTable` (decoded in the source). A match rebuilds
  `wWeaponsUnlocked1`; a wrong password plays an ERROR sequence and then
  `CheckPasswordEntry` (now `[ok]`) resets the game. The password screen reuses
  the stage-select graphics through `LoadStageSelectScreen` (CallBank1Routine 3),
  which answers how it shares the cursor look; its grid is
  `gfx/tilemaps/password.tilemap`, its sprites a full ASCII font plus the balls
  (`gfx/screens/password_sprites.png`).
* Dead code: copies of a bank-`$08` routine and of the bank-`$0B`/`$0E` sprite kit.
* Also named every `$0150` jump stub after its target (`JumpQueueSound`, …).
* **The `$0D0D` tiles are a disabled hitbox viewer** — see the 3.2 follow-up note
  below and UNUSED.md.

### Step 3.2 — bank `$06` tilemaps (2026-10-05)

* **Bank `$06` is 100% source** (whole ROM **36.55%**), byte-identical. Nothing in it is compressed: the
  21 pointer slots lead to plain (byte count, tiles) records read by
  `Func_00_2516` and plain tilemap pointers read by `Func_00_2521`. Tiles are
  PNGs in `gfx/screens/` (9 files), maps are raw `gfx/tilemaps/*.tilemap` (8 files).
* Each screen was rendered by replaying its loader into a simulated VRAM: the
  **title logo** (20x10 map with a size header — iimarckus's label was 3 bytes
  late because it missed the header), the **menu font**, the **stage-select**
  portrait grid (two 20x9 halves, the second on the window), the
  **weapon-get** screen (Mega Man in cutaway, a raw 32x18 map), and four
  cutscene pictures bank `$01` shows in a row — **Dr. Wily's skull castle**, a
  **skull-faced flying machine**, and a **beaked machine** in two versions. The
  last two are named by what they show, `[?]`, pending Will.
* Named the loaders: `LoadWeaponGetScreen`, `LoadWilyCastleScreen`,
  `LoadSkullShipScreen`, `LoadBirdMachineScreenA`/`B`, `CopyTilemap20x18`, and the
  `GfxRef_*` slots in bank `$00`.
* Unused: a blank 11th row after the title map, three rows after the stage-select
  map, and `Func_00_01BD` — an uncalled second skull-ship loader whose row copy
  would shear the picture.
* Step 3.4's compression audit is half answered: bank `$06` has none.

* **Follow-up with Will.** The beaked machine is the **Wily Machine**, the final
  boss: the map with the dome is phase 1, the one without is phase 2 with Dr. Wily
  visible. Renamed to `WilyMachine*` (`wily_machine.png`,
  `wily_machine_phase1/2.tilemap`). Will also spotted **WORLD** among the title
  tiles: 32 of the 110 title tiles are never placed by the map, including WORLD in
  the logo's lettering — a trace of a *Mega Man World* title, matching Japan's
  *Rockman World*. Checked the other ROMs: Europe has the same unused tiles,
  while *Rockman World*'s WORLD is a different, grey italic drawing not found in
  the US ROM — so the US WORLD was drawn in the *MEGA MAN* lettering for an
  English logo that was then cut. Logged in UNUSED.md.

* **The `$0D0D` tiles are a disabled hitbox viewer.** Will could not find the five
  "background" tiles in any stage map; following their code showed they are
  sprite tiles for a developer tool: freeze play, move a ring cursor, hold B to
  bracket the hitbox under it. Its frame routine (`$0D76`, previously "a
  Start-button check with no caller") is unreachable and its sprite handles are
  never allocated. The `$0D5D` "records" are five one-tile metasprites (four
  flips of a corner, plus the cursor). Named `HitboxViewer*`, documented in
  UNUSED.md and RAMMAP.md; `gfx/bg_tiles_0d0d.png` → `gfx/hitbox_viewer.png`.

### Step 3.1 — bank `$04` sprite graphics (2026-10-05)

* **Every tile run in bank `$04` is a PNG** under `gfx/sprites/` — 39 files — built by
  `rgbgfx`, and the ROM is byte-identical on the first build. `build.sh` and
  `make.bat` now also convert `gfx/*/*.png`. Bank `$04` 1% → 81%; the remaining
  19% is 3,048 bytes of uninitialised-memory filler at `$63F8`, kept as `INCBIN`,
  and the `$FF` tail is now `ds`. Whole ROM **28.90%**.
* **Mega Man, the item pickups, all eleven weapon shots, the health bar and the
  seven-segment digits** were rendered and match their names; promoted to `[ok]`.
* **The 27 unnamed pointers** are one stage-select graphic (`Ptr_04_401E` →
  `Tiles_04_4F5B`, a ring and dots, loaded by `Func_00_1B6B`) and 26 object-type
  tileset records for types 1–29. Named by type — `GfxPtr_ObjTypeNN`,
  `ObjGfxTypeNN`, `ObjTilesTypeNN` — because rendered in tile order they are
  fragments, not recognisable enemies; assembling them needs the metasprite data
  in the object banks (Phase 5). A labelled contact sheet went to Will.
* Sharing: type 11 loads the first 8 of type 12's 42 tiles; types 25–28 share a
  record that loads 5 of type 24's 6 tiles; type 8's record has a count of 0.
* Unused: the filler, two orphan bytes at `$4F59`, and a never-read `$80` in type
  8's record.

* **Follow-up with Will's notes.** The stages and title screen use 8x8 sprites
  (`PlayStage` and `TitleScreen` clear LCDC bit 2 with `and $7B`), so the PNGs —
  plain 8x8 tiles in ROM order — are the right shape. *Correction, same day:* the
  stage select ORs `$64` into `wShadowLCDC`, which sets bit 2, so that one screen
  uses 8x16 sprites. Renamed per Will: `SevenSegDigits` → `HUD` (`hud.png`), type 20 →
  `AppearingBlock`, type 23 → `Icicle`. Type 20's stats flags are `$00` (not
  visible at spawn), which fits a block that appears; type 23 asks for 0 OAM
  entries, left for Phase 5. Will suspects type 13 is unused — logged in
  UNUSED.md, to be settled by the Phase 4 spawn lists, since `SpawnObject` has a
  single caller. Will thought `Tiles_04_4F5B` might be enemy shots, but in stages
  `FireEnemyShot` callers pass tile `$66`, a ring in Mega Man's own tile set
  (tile 102); `Tiles_04_4F5B` is loaded by bank `$01` beside `Func_00_1AFC`'s
  screen, so it belongs to a non-stage screen. Will also notes the ending shows
  each enemy's sprite with its name, which will name the object types.

* **The ring and dots are the stage-select sprites** (Will): the ring is the cursor
  on the stage select and password screen, the dots are the background stars of
  the stage-chosen animation. Corroborated: their only loader is called from bank
  `$01`'s stage-select setup (`$1:6181`, after it picks the first undefeated boss),
  and that screen uses 8x16 sprites, so the 8 tiles are four 8x16 images with
  blank lower halves. Renamed `StageSelectTiles` / `stage_select.png`,
  `LoadStageSelectSprites` (`$1B6B`), and `LoadStageSelectScreen` (`$1AFC`, the
  two-tilemap loader called just before it — which answers the open question of
  what screen it draws).

### Step 2.7 — bank `$00` split into `engine/` and `data/` (2026-10-04)

* `banks/bank00.asm` (8,642 lines) is gone. Bank `$00` is now 27 files — 24 under
  `engine/` and 3 under `data/` — holding 40 sections (the 7 vectors, the header
  and 32 code/data chunks), each pinned to its original ROM0 address, plus the
  free-space `ds` in `main.asm`. The ROM is byte-identical.
* No chunk falls through into another file: every chunk ends in an
  unconditional `ret`/`jp`/`jr`/`reti` or in data (checked by script).
* Pinning means a file can gather a subsystem from non-adjacent code: for
  example `engine/audio_interface.asm` holds the audio API stubs ($0227), the
  sound queue ($03CD) and the queue drain ($07DD); `engine/memory.asm` holds the
  copy/fill routines and the table lookups; `engine/screens.asm` holds the
  `$01BD` loader and the text screens; `data/object_tables.asm` holds
  `ObjectTablePtrs`, `ObjectStatsTab` and `ObjectTypeTab`.
* Fall-throughs inside files, unchanged:
  `ResetAndLoadStage` → `LoadStage` → `Func_00_3057` (all in `stage_load.asm`), and
  `Func_00_2A1E` → `Func_00_2A25` (in `objects.asm`).
* Three section names first collided with WRAM/HRAM sections (`Joypad`, `OAM DMA`,
  `Sound Queue`); section names are global, so the ROM ones were renamed. Added a
  "Moving code out of `banks/`" section to CONVENTIONS.

### Step 2.6 — `$34D3`–`$3979`, and bank `$00` finished (2026-10-04)

* **Bank `$00` is 100% source.** Its last `INCBIN "baserom.gb"` (`RNGTable`) is now
  16 rows of `db`, and the `freespace` tail is `ds $4000 - $3979, $FF` (all 1,671
  bytes checked to be `$FF`). Whole ROM **22.91%** (padding included).
* **`ObjectStatsTab`** (`$34D3`): eight bytes per object type, one-based — OAM
  entries, spawn X/Y offsets, hit points (offset `$18`), touch damage (`$1A`),
  flags (`$11`), an untraced byte (`$03`) and an unused zero. `ObjectTablePtrs`
  (`$01B9`) points the object banks at it and at `ObjectTypeTab`.
* **`BossDamageTab` confirmed** (was `Data_00_11B8`, `[?]`). The lookup keys on the
  struck object's type: types 30–49 except 48 pick a row, and those are exactly
  the boss records in `ObjectStatsTab` (hp `$13`, flag bit 6). The result is
  subtracted from hit points. Now `[ok]`.
* **Enemy shots** (`$3773`–`$3978`): a separate pool of 12 small projectiles at
  `$CD00`. `FireEnemyShot` (stub `$0153`) takes a position, one of 16 directions,
  a tile and touch damage; `EnemyShotVelocities` is 16 directions at 3 px/frame in
  8.8 fixed point, with slightly uneven diagonals. `UpdateEnemyShot` moves, culls,
  hurts Mega Man and — with **Mirror Buster** equipped — lets a Mirror Buster shot
  hit it and hands off to bank `$01` `$4FD0`, presumably the reflection. Also
  `InitEnemyShots`, `ClearEnemyShots`, `UpdateEnemyShots`.
* `RNGTable` is not quite a permutation: `$09` and `$BA` twice, `$00` and `$DA`
  missing.
* Unused: a `jr` + `$00` after a `ret` at `$387D`, and `ObjectStatsTab`'s byte 7.

### Step 2.5 — `$2C6B`–`$3496` (2026-10-04)

* **The three gaps are source**, byte-identical. Bank `$00` 78% → 92%; whole ROM
  **21.65%**. Only `$34D3`–`$3693` and `$3773`–`$3979` remain in bank `$00`.
* **The sprite system** (`$2C6B`–`$2F7F`). Objects hold a *sprite handle* (0–`$3F`,
  `$40` = none) rather than OAM entries. `AllocSprite` gets a handle sized in OAM
  entries; if the OAM pool (26 entries at start, by our reading) cannot cover it
  the sprite waits, and
  `RotateSpriteOAM`, run every frame, takes entries from the oldest holders and
  gives them to waiting sprites — the game's sprite flicker. Also `FreeSprite`,
  `UnlinkSprite`, handle and OAM-pool allocators, `DrawMetasprite` (header,
  tile grid, then a free-placed list; format documented at the routine),
  `DrawMetaspriteList`, `DrawObjectSprite`. Three more hang traps.
* **Correction:** object offset `$10` is that sprite handle. Step 2.4 had it as
  "a byte passed to `$2F0A` on death" and guessed at an explosion or item drop;
  `$2F0A` is `FreeSprite`. Comments and RAMMAP fixed.
* `ResetAndLoadStage` (`$2FF6`) zeroes `$D800`–`$D84D` and falls into `LoadStage`,
  which itself falls into the section loader at `$3057`.
* **The `$DF80` mystery is solved**: the section loader writes a `jp` there from the
  section record, and `StageFrameLoop` calls it each frame. Named `wStageHook`.
* Stage-section machinery, left provisional with comments for Phase 4:
  `Func_00_3057` (section record layout sketched), `Func_00_32F2` (sub-section
  setup), `Func_00_312F` (transition-box test — vertical screen scrolls),
  `Func_00_33F8`/`3412` (build the boxes), `Func_00_327F` (draw the screen).
  Named helpers: `CallHL`, `ClampToScrollLimits`, `PixelToBGMapAddr`,
  `PixelToBlockGridAddr` (a 16×16 grid of 16-pixel blocks at `$DE00`).
* Unused: `FreeOneOAMSlot` (`$2F70`), and a dead computation in `Func_00_2FB3`.

### Step 2.4 — `$21C7`–`$2245`, `$23A8`–`$2516`, `$252B`–`$2C37` (2026-10-04)

* **All three gaps are source**, byte-identical. Bank `$00` 63% → 78%; whole ROM
  **20.66%**.
* **Correction: step 1.5's "there is no other text" was wrong.** `$21C7` is the
  weapon-get screen's text (`YOU GOT`, then each weapon name on two lines) in a
  third encoding, ASCII + `$80` — the same font loaded 32 tiles higher. It is
  source now through a new `getscreen` charmap, with `WeaponNameLine1Ptrs` /
  `WeaponNameLine2Ptrs`. A re-sweep at all 256 byte shifts also found `ANDCARRY`
  in bank `$01` and the ending's enemy roll call in bank `$0E` (ASCII − `$20`),
  left raw for their own banks. The roll call names the enemies, which should
  help with the object types. ROMMAP, CONVENTIONS, PLAN and bank `$06` corrected.
* `LoadStageTiles` (bank `$0C` tilesets via one-based `StageTilesetPtrs`) — the
  unused eighth stage has **its own tileset**. `LoadObjectTiles` (12-entry type
  cache, sprite tiles from banks `$04`/`$07`, allocator `$C3B3`) and `CopyTiles`.
* **Object types are one-based.** `SpawnObject` indexes `ObjectTypeTab - 4` and
  `LoadObjectTiles` indexes `ObjectTilesetPtrs - 2`; `ObjectTypeTab`'s comments
  are renumbered 1-56 (they counted from 0).
* The object system core: `AllocObjectSlot` / `FreeObjectSlot` (stubs `$0174` /
  `$0177`), `SpawnObject`, `CallObjectRoutine` (jumps to the address in the
  object's first two bytes in its own bank, return to `.handlerReturn`; banks
  `$03`/`$09`/`$0D` also jump to `ObjectHandlerDone` at `$28B7`), `ClearObjectRAM`.
  The slot layout so far is in RAMMAP.
* **Ice Slasher's freeze** is traced: weapon 3 sets the object's timer at offset
  `$22` to 312 frames and does no damage; `CallObjectRoutine` counts it down.
  The weapon-hit path goes through `Func_00_1143`, the reader of `Data_00_11B8`,
  and subtracts the result from offset `$18` — which supports that table being
  weapon damage (still `[?]` until the lookup itself is traced).
* **Five deliberate hang traps** (`jr` to self) guard internal limits; one is
  never used. See UNUSED.md.
* Still provisional, with comments: `Func_00_252B` (retire dead objects),
  `25E9`, `262E`, `2657`, `26C0` (spawn list), `28E2` (scroll window), `2A1E`,
  `2A25`, `2A3E`, `2A56` (collision pass), `2B99`/`2BA0`, `2BC7`.
* `tools/srcgen.py`: byte-scan "callers" inside source are now believed only if
  linear decoding from the nearest symbol lands on them, and the audio banks no
  longer count. That removed four false labels in this range.

### Step 2.3 — `$16CB`–`$1758`, `$186F`–`$1AE3`, `$1AFC`–`$1B6B` (2026-10-04)

* **All three gaps are source**, byte-identical on the first build. Bank `$00`
  57% → 63%; whole ROM **19.51%**.
* **Unused arithmetic library at `$16CB`** (`Mul16x16`, `Div16`, `Div32By16`,
  `RandomBelow`). Nothing in the ROM calls, jumps to or points at any of them.
  Each was checked by simulating its exact instruction semantics against Python
  arithmetic on 20,000 random inputs: the multiply and 16-bit divide are correct;
  `Div32By16` drops the bit shifted out of B each round, so ~89% of results are
  wrong once the divisor exceeds `$8000`; `RandomBelow` never returns for A = 0.
  Listed in `docs/UNUSED.md`.
* **VRAM-safe routines** `MemsetVRAM`, `WriteVRAMByte`, `CopyVRAM` (+ the
  `CopyVRAMHBlank` path bank `$01` calls directly, and 3/2/1-byte burst helpers).
  With the LCD on they write only at the start of each HBlank — one burst per
  scanline and nothing during VBlank — so blanking a 1 KB map takes about seven
  frames. `MemsetVRAM` and `WriteVRAMByte` each have a second, uncalled entry
  that skips the LCD check.
* `GetTablePointer` (`$1968`, HL = word at HL + 2A; stub `$015F`, nine callers) and
  its unused byte twin `GetTableByte`.
* **Line-stepper** `LineStepInit` / `LineStep` (`$1973` / `$19B5`, stubs `$0189` /
  `$018C`): Bresenham-style stepping from (L,H) toward (E,D), C pixels per step,
  returning NZ when a coordinate wraps. State at `$D8AC`–`$D8B4` (`wLine*`). Banks
  `$03`, `$09`, `$0D` each contain **their own copy** of this code on the same RAM.
  The setup gets the direction wrong when the start coordinate is 0.
* **Screen loaders**, tied to the bank `$06` text groups: `LoadGameOverScreen`,
  `LoadPasswordScreen` (CallBank1Routine index 5), `LoadEndingScreen` (index 6),
  their shared `LoadTextScreenBase` (tiles + map blanked to the `$6C` space tile),
  `DrawTextList` / `DrawTextString` (the reader of the `screentext` format),
  `LoadTitleScreen` and `CopyTilemapRect` (the title logo). `PlayStage` also calls
  `LoadTitleScreen` on entry to every stage — probably for its tile blocks; `[?]`.
* `Func_00_1AFC` (CallBank1Routine index 3, stub `$019B`, bank `$01` `$617E`) loads
  a two-map layout of 20×9 tilemaps via `CopyTilemap20x9`; which screen it is
  remains open.

### Step 2.2 — `$0CDC`–`$167E` and the cartridge header (2026-10-03)

* **Header in source** (Will's request). `SECTION "Header"` at `$0100`: entry
  `nop`/`jp Start`, the logo, title `MEGAMAN`, DMG-only, cartridge type MBC1,
  256 KB ROM, no SRAM, non-Japanese, old licensee `$08` (Capcom), version 0. The
  values are named in `constants/cartridge.inc`. `rgbfix -f hg` now only fills the
  header and global checksums ($E4 / $C25B).
* **Whole range is source**, byte-identical. Bank `$00` 41% → 57%; whole ROM now **19.07%**.
* Named with `;[ok]`: `Start`, `Init` and its `.softReset` entry (ReadJoypad's
  soft-reset combo jumps there), `ClearRamCode`, `DisableLCD`, `DelayFrame`,
  `WaitForLY0`, `WaitForLYL`, `NegateDE`, `EnableLCDBG`, `EnableLCDOBJ`,
  `EnableLCD`, and bank `$01`'s `TitleScreen` ($1:60AF: title music `$2A`, 120
  frames of ignored input, then waits for Start).
* `HideAllSpritesAlt` ($166E) duplicates `HideAllSprites` ($2F83) and is followed
  by an unreachable `ret`.
* `BGTiles_0D0D`: five tiles loaded to `$8FB0` (tiles `$FB`–`$FF`), now
  `gfx/bg_tiles_0d0d.png`. Will reads them as background graphics; `Data_00_0D5D`
  holds five 5-byte records that place them. Purpose still `;[?]`.
* `Data_00_11B8`: ten 12-byte rows indexed by object class and `wCurrentWeapon`,
  with `$FF` meaning "keep the default". Probably the weapon damage table — `;[?]`
  until the caller is traced in Phase 5.
* **RAM hooks**: bank `$01` installs `jp $4140` at `$C0AA` (`wHookA`) and
  `jp $42AE` at `$C0AD` (`wHookB`); `StageFrameLoop` calls `wHookB` every frame.
* `$0D76` (a Start-button check) has no direct callers; how it is reached is open.
* `tools/srcgen.py --trace` undershoots where code is reached only from banks still
  under INCBIN, so the policy is: decode as code, and mark as data only what has
  been confirmed as data.

### Audio notes, the alternate Fire Man stage, and `QueueSound` (2026-10-03)

Prompted by Will's notes on unused content. New `docs/UNUSED.md` keeps a register.

* **The unused eighth stage slot is the alternate Fire Man stage.** Its record
  points at real data in bank `$08` (`$22F67`–`$23828`), which shares 23.4% of its
  8-byte sequences with Fire Man's stage against 1–3% for every other stage,
  including a 76-byte identical run. Will had reported the alternate stage; this
  locates it. Rendering it is Phase 4.
* **`Func_00_03CD` is `QueueSound`.** It doesn't play anything: it appends the ID to
  the new `wSoundQueue` (`$D920`, a count plus 20 entries). **An ID is the SoundTab
  index plus one**, resolved in whichever bank `wAudioBank` selects — confirmed by
  four independent cases. iimarckus's hand-written ID list in the comment has been
  replaced by a table generated from Will's two SoundTabs, covering every ID the
  ROM queues with a literal.
* **`WilyUnk` and `UnkTheme`** — neither pointer slot is referenced anywhere and
  neither ID is ever queued by a literal. Consistent with Will's "unused".
* **`SFX_Empty1`/`SFX_Empty2` are queued by the game** (IDs `$13`, `$14`, from object
  code in banks `$01`/`$03`) and each carries one track — not empty.
* **No composite sounds at the call sites.** Nothing queues two sounds back-to-back,
  so any composition is inside the sound data or the driver.

### Phase 2.1 — the font, and the game's main flow (2026-10-03)

Coverage 17.07% → **17.88%**; bank `$00` 26% → **40.8%**.

**Graphics now build from PNGs.** `$041E`–`$05BD` is a 26-tile A–Z font and
`$05BE`–`$05FD` four tiles of a health bar at four fill levels (identified by Will).
`LoadFontTiles` (`$03C3`) copies all 30 to VRAM in one go. Both are now
`gfx/font.png` and `gfx/health_bar.png`; `build.sh` and `make.bat` run `rgbgfx` over
`gfx/*.png` before assembling, and the round trip is exact with rgbgfx's default
grayscale mapping. `tools/gfx.py` extracts tiles to PNG.

**`tools/srcgen.py`** turns a ROM range into assemble-ready source: labels for
every branch target, symbols from `mmwr.sym` substituted into operands, hardware
register names, `bankswitch` collapsed to the macro, and `--data`/`--words` ranges.
Getting it right took three corrections, all caught by the build:

* byte-scan "callers" that land mid-instruction created labels that were never
  emitted — labels are now only placed on instruction boundaries;
* `call $15EA` came out as `call OAMDMARoutineEnd`, because an end-marker label
  shares that address — `…End` labels are never used as operands now;
* a byte-scan caller is only believed if its target follows a `ret`/`jp`/`jr`, or if
  the caller sits in already-disassembled code. One false global (`$0B21`) still
  got through, from a `dw` table that looks like a `jp`, and was folded back by hand.

**`$0855`–`$0CC9` is the main game flow**, 1,140 bytes, all source now:

* `NewGame` — buster unlocked, progress cleared, title screen, then the loop.
* Stage choice: robot master select, or the Wily castle once all four bosses are
  down (`wWilyStageSet`), with Wily progress tracked in `$DF96`.
* `PlayStage` — palettes, interrupts, stage music, then `StageFrameLoop`, which
  branches every frame on the new **`wStageState`** (`$CCFD`): 0 playing, 1 boss room
  entered (switch to `Audio1_Boss`), 2 boss beaten (`BossDefeated` plays
  `Audio1_Victory` and sets the new **`wVictoryTimer`** to `$01E0` — eight seconds),
  3 counting that down. Then the boss is marked defeated and play returns to stage
  selection. Clearing the third Wily stage goes to bank `$0E` instead.
* `LoseLife`, `ResetGameState`, `RefillWeaponEnergy`, `FetchSongPointer`, and
  `CheckPasswordEntry` (`[?]` — the screen it runs is inferred to be the password
  screen, not traced).
* `call $DF80` in the frame loop calls into WRAM — another piece of RAM-resident
  code alongside the `$C0A4` block.

**`StageMusicTab` (`$09F5`) is the missing reader of `AudioSoundTabPtrs`**, closing
that Phase 1 question. It's indexed one-based from `StageMusicTab - 2`, the same
trick as `StageLoadTab`, and resolves through two more levels of pointers to bank
`$02`'s SoundTab: stages 1–4 → `CutMan`/`IceMan`/`ElecMan`/`FireMan`, the first two
Wily stages share `Wily1`, the third gets `Wily2`.

**Stage 8 is never selected.** Its music entry points at SoundTab 39 — one of the
`DoNotUse` labels that fall through into `Audio1_EndGameAlt` — and its
`StageLoadTab` record points at bank `$08` like the other Wily stages. But the Wily
branch only ever sets stages 1–3, and clearing stage 3 goes straight to the ending.
So there is a complete, wired-up fourth Wily slot that this code never reaches, and
the track Will catalogued as the alternate end-game theme is the music assigned to
it.

### Phase 1.5 — the text (2026-10-03). Phase 1 complete.

Coverage 16.93% → **17.07%**.

* **`constants/charmap.inc`** declares a named `screen` charmap — tile index =
  ASCII + `$60`, space `$6C`, `©` at `$A0` — and leaves the default `main` charmap as
  plain ASCII, because the game uses both encodings and RGBDS charmaps are global.
  Source switches with `SETCHARMAP screen` / `SETCHARMAP main` around the strings.
  The UTF-8 `©` goes through the charmap cleanly; the build was byte-identical on
  the first attempt.
* **Bank `$06`'s four string groups are source**, as `screentext <dest>, "<text>"`
  macros with `endscreentext` for the null-destination terminator. Destinations
  read as `TILEMAP0 + $105` rather than raw hex. The four groups are
  `PasswordText`, `EndingText`, `GameOverText` and `TitleScreenText`, reached through
  named pointer slots at `$18034`–`$1803B`, which are themselves slots 3-6 of the
  bank's top-level pointer table.
* **There is no other text in the game.** A sweep of the entire ROM in both
  encodings, with and without the record framing, finds only those 19 strings, the
  bank `$00` stage-name table (already source, in plain ASCII) and the cartridge
  header title. Everything else that matched was a run of sequential tile indices —
  `ABCDEFG…` for tilemaps, and reversed runs like `PONMTSRQ…` for mirrored sprites.
  So the open question "where is the ending text" has an answer: the ending's only
  text is `EndingText` — `THANK YOU / FOR PLAYING / PRESENTED BY / CAPCOM`. If there
  is a staff roll, it is drawn as graphics, not stored as text.
* Bonus, from splitting that `INCBIN`: the two four-byte records at `$1802A` are
  `(length, source)` pairs — `$06E0` bytes from `$4227`, then `$0400` from `$4907` —
  and `$4227 + $06E0 = $4907`, so they describe one contiguous run starting at
  `$18227`. Almost certainly screen tile graphics. Left as `Data_06_402A` /
  `Data_06_402E` with `[?]` for Phase 3. And the record at `$18032` points at
  `$18149`, three bytes *before* iimarckus's `TitleScreenData` label, so that label
  is probably three bytes late.
* **`TypeBossName` (`$2097`)** named. Bank `$01`'s boss-intro loop at `$6294` calls
  it once per frame for 120 frames, and it draws the letter whose index is the frame
  count — so the robot master's name types itself out over the first nine frames.
  The same loop then increments `wSelectedStage`, which is the zero-to-one-based
  conversion step 1.4 relied on — now seen directly rather than inferred.
* **`wTileCopyCount` was the wrong name**, and is now `wScreenCounter`. Tracing
  `TypeBossName` showed `$CCF9` is the boss-intro frame counter and letter index;
  it is also the stage-select zoom sentinel and, in one routine, a tile-copy loop
  counter. A general counter that several screens reuse. The old name described the
  least important of its three uses. It stays `[?]`.

**Phase 1 is complete.** Every computed bank switch is explained, the RAM and
hardware names are in, the version picture is clear, and all the game's text is
readable source. Phase 2 — working through bank `$00` — is next.

### Phase 1.4 — the computed bank tables (2026-10-02)

Coverage 16.74% → **16.93%**. Both tables are now source rather than `INCBIN`.

Of the 117 `bankswitch` sites, 26 take their value from somewhere other than an
immediately preceding literal, and they sort into exactly four mechanisms:

| Mechanism | Sites | Banks it can select |
|---|---:|---|
| `ld a,[wAudioBank]` | 6 | `$02`, `$0A` |
| `pop af` (restore a saved bank) | 7 | whatever was saved |
| `ld a,[wStageBank]` | 10 | `$05`, `$08`, `$0E` |
| `ld a,[hl]` at `OBJ_BANK` | 2 | `$03`, `$09`, `$0D`, `$01` |

**`StageLoadTab` (`$2F93`)** — eight four-byte records, `dw <ROM0 pointer slot>` +
`db <bank>` + an unused `$00`. `LoadStage` (`$3000`, also now source) pages in bank
`$05`, indexes the table, and stashes the record's bank in `wStageBank` (`$DF9B`,
newly named) before paging it in. The four robot master stages point at bank `$05`,
the four Wily stages at bank `$08`, chosen by `wWilyStageSet` (`$DFC8`) adding 4 to
the index. The loader then follows two levels of indirection — a ROM0 pointer slot
in the `$0305`-`$03C1` table, then a pointer inside the stage's bank — and copies
four header bytes out as `wStageParams`.

The table is indexed **one-based**: `LoadStage` loads HL with `$2F8F`, four bytes
early, so index 1 lands on the first record. That bias points into the
`dec b / jr nz / ret` tail of `HideAllSprites`, not into padding, which is why the
table looked like it started with a garbage record (`bank $FB`) on the first read.
`wSelectedStage` is zero-based on the stage-select screen and incremented by bank
`$01` at `$062BA` before the load, which reconciles the two.

**`ObjectTypeTab` (`$3693`)** — 56 four-byte records, `dw <handler>` + `db <bank>` +
an unused `$00`. Each live object carries its handler's bank in its own record at
`OBJ_BANK` (`+$1B`); the far-call sites at `$28A3` and `$2A5B` read it back and page
it in before jumping to `OBJ_HANDLER` (`+$15`) offset by `OBJ_HANDLER_IDX` (`+$17`)
× 2.

The clincher: every handler address in that table is a slot in the target bank's
entry table, and **every slot in banks `$03`, `$09` and `$0D` is referenced exactly
once, in order** — 22, 24 and 9, which is precisely how many `jp` entries each of
those banks has (measured independently back in Phase 0). The 56th record points at
a lone bank `$01` address. Those three banks exist to hold object behaviour code and
this table is their complete index.

Also added `constants/objects.inc` with the four object-record offsets traced so
far, and `HideAllSprites` (`$2F83`) as source.

**Mistakes worth recording.** Two, both caught by the build:

* I inserted a new WRAM section above `wRNGSeed`, which had been following `wEnergy`
  implicitly, and silently relocated it from `$DFAE` to `$DFC9`. `./build.sh` caught
  it; `ram/wram.asm` now pins the RNG to its own section, and the comment there says
  why.
* `$0072F` looked like a 15-entry far-pointer table in the heuristic scan. It is a
  repeated `1c 77 09 1a` fill pattern — a false positive, discarded.

**Open:** nothing has been traced *writing* `OBJ_BANK`. Both sites that touch it only
read, so the field is filled at spawn by a route that does not use the
`ld a,$1B / add a,c` idiom — probably a bulk copy from a template. Finding the spawn
path should also give the 56 object types their names.

### Version notes and corrected string table (2026-09-22)

Will supplied first-hand notes on the four regional versions; `docs/VERSIONS.md`
now holds them, separating what was checked here from what was not.

His account of the title screens is **confirmed**, by walking each version's bank
`$06` string block:

* **(U)** carries the credits on the title screen itself — `@CAPCOM CO.,LTD.1991`,
  `@CAPCOM U.S.A.,` / `INC.1991`, `LICENSED BY NINTENDO`.
* **(E)**, published by Nintendo, has **no Capcom USA line anywhere** and no
  title-screen credits. Its block instead opens with six strings the other versions
  do not have — `@ 1991 CAPCOM`, `MEGAMAN IS`, `A TRADEMARK`, `OF CAPCOM`,
  `LICENSED TO`, `NINTENDO FROM`, `CAPCOM` — the separate splash screen he
  described. The block then stops after `PASS WORD` where (U) continues.
* **(J)** has a single `@CAPCOM 1991`, lacks `GAME END` and `START BUTTON`
  entirely, and sends its menu strings to different tilemap positions, so those
  screens are laid out differently rather than merely translated.

Not verified, because no dump was available: the Japanese prototype's palette and
music differences, and its unimplemented boss doors. The last of those is recorded
as something to watch for in Phase 4.1 — if the prototype's layouts encode
side-by-side doors, the final stage data may still carry vestigial fields for them.

Two corrections came out of this:

* `tools/strings.py` now walks the `dw`/string/`$00` records properly, and its
  output replaced the transcript in `docs/ROMMAP.md`, which I had done by eye and
  got wrong in several places — `FOR PLAYING` is at `$9884` not `$9824`,
  `START BUTTON` at `$99A3` not `$9943`, and `ERROR !!` has a space in it.
* The tool can emit RGBDS source with `--asm`, which is most of step 1.5.

### Phase 1.3 — hardware names, and the regional-version question (2026-09-22)

Coverage 16.69% → **16.74%**.

**Data Crystal's map is the European ROM.** Will suspected this and he was right.
Ten of its ten code addresses land exactly in `Megaman - Dr. Wily's Revenge (E)
[!].gb`. The step-1.1 conclusion that its addresses were "unreliable, and not by a
constant offset" was wrong: the varying offsets are the genuine (U)↔(E) divergence.
`docs/ROMMAP.md` has been rewritten, and the wrong conclusion is flagged there
rather than quietly deleted.

Comparing the three dumps (U, E, and Rockman World (J)) gave something better than
a correction:

* **Eleven of the sixteen banks are byte-identical across all three versions** —
  `$02`, `$03`, `$07`, `$08`, `$09`, `$0A`, `$0B`, `$0C`, `$0D`, `$0E`, `$0F`. Only
  `$00`, `$01`, `$06` and small patches of `$04`/`$05` differ. So documentation
  about those eleven banks needs no address correction at all, and the audio
  disassembly applies to every region unchanged.
* (J) is the more distant relative: 1,657 differing bytes in bank `$04` and 681 in
  `$05`, against (U)-vs-(E)'s 3 and 4.
* Observed (U)−(E) offsets: bank `$00` −2 from `$0855` to `$20E1`; bank `$01` 0 up
  to `$5766` then −30; everything else 0 at every point checked.

**`tools/findbytes.py`** operationalises the rule — give it a byte pattern from
whatever source you are reading (with `??` wildcards if needed) and it reports where
that pattern really is, in our ROM and in any other dumps you point it at.

Step 1.3 proper:

* All `$FFxx` register literals in the source now use `hardware.inc` names.
  `constants/memory.inc` adds `VRAM_TILES0/1/2`, `OAMRAM` and `STACK_TOP`, all
  guarded so a future hardware.inc update cannot collide. Tilemap addresses are now
  `TILEMAP0 + $0CD` rather than `$98CD`.
* `constants/joypad.inc` adds `PADF_*` and `P1F_GET_*`; this copy of hardware.inc
  (5.3.0) has neither those nor the `_VRAM*` area constants.
* **`ReadJoypad` (`$157D`)** disassembled. Reads the d-pad twice and the buttons
  eight times, OR-ing the button reads so a bouncing contact reads as not-pressed;
  `cpl` to active-high; d-pad swapped into the high nibble. `xor`/`and` against the
  previous state gives the newly-pressed edge. Then two things worth knowing: **A +
  B + Select + Start held together is a soft reset** (jumps to `$0605`), and the
  routine **stirs the RNG with the held input**, folding it together with
  `wVBlankCount` into `wRNGSeed`. Player input as an entropy source.
* **`InstallOAMDMA` (`$15D2`)** and **`OAMDMARoutine` (`$15E0`)** disassembled; the
  ten HRAM bytes are now source, with the 40-iteration wait written as `ld a,40`.
* A useful false positive: `ld hl,$FFF2` at `$23C7` is not an HRAM address, it is
  −14 being added to DE. `tools/ramrefs.py` counted it as an HRAM reference. The
  source now says `ld hl,-14`.

One mistake worth recording: the first attempt at `ReadJoypad` wrote the button
read-back loop as `REPT 5` when the ROM has six reads. `./build.sh` caught it
immediately — everything after `$159A` shifted by two bytes.

### Phase 1.2 — RAM map (2026-09-22)

Coverage 16.66% → **16.69%**. The gain is small because this step's output is
names, not bytes; the 55 bytes came from two routines that had to be disassembled
to justify a RAM label.

* **`tools/ramrefs.py`** tallies every RAM address the ROM touches, scanning for
  `ld [nn],a`, `ld a,[nn]`, `ld hl/de/bc,nn` and `ldh`. Its one idea worth keeping:
  each hit is classified `code` or `blob` depending on whether its ROM offset is
  inside real source or still inside an `INCBIN`. Raw counts across the whole ROM
  are mostly noise — bank `$04`'s graphics alone throw hundreds of false
  `ld hl,$Cxxx` hits — so the `code` subset is the only trustworthy part.
* **120 addresses are reachable from disassembled non-audio code. 44 are now
  named** in `ram/wram.asm` and `ram/hram.asm`; the remaining 76 are tabulated with
  reference counts in `docs/RAMMAP.md`.
* **157 numeric literals became labels** across `banks/bank00.asm` and
  `banks/bank01.asm`. 33 and 41 raw `$Cxxx`/`$Dxxx`/`$FFxx` literals remain in
  those two files respectively, all of them addresses we cannot yet justify a name
  for.
* **No `wUnknown_XXXX` placeholders were created.** Replacing `$CCF7` with
  `wUnknown_CCF7` adds a name but no knowledge, and it would make the next reader
  think the address had been looked at. The plan called for them; the table in
  `docs/RAMMAP.md` is the honest form of the same information.

What the VBlank handler at `$0675` gave up, all of it plainly readable once the
labels were in: `wFrameCounter` (every frame), `wVBlankCount` (16-bit, only on
frames that do work), `wVBlankBusy` as the re-entrancy guard, `wVBlankDone` as the
flag the main loop waits on, and the four LCD shadows `wShadowSCX`, `wShadowSCY`,
`wShadowLCDC`, `wShadowBGP`. It also showed the audio tick being called by paging
the bank manually and `call $400F`, rather than through the `AudioPlay` stub named
in step 1.1 — the two paths coexist.

Other findings:

* **`$C0A4`–`$C0FF` is a 92-byte block of RAM that the game executes.**
  `Func_00_066A` memsets it to `$C9` (`ret`), the LCDC/STAT vector at `$0048` is
  `jp $C0A4`, and `CallBank1Routine` assembles a `jp` at `$C0D0` inside it. Banks
  `$0B`/`$0E` also copy a 23-byte table to `$C0B0`, which overlaps — unresolved,
  and flagged `[?]` in `ram/wram.asm`.
* **The stage-select screen is now legible.** `wSelectedStage`, `wBossesDefeated`
  (bits 3/0/1/2 gate the four portraits), the four `wStageSelectPos` X/Y pairs, the
  animation timer/phase/frame, and the metasprite scratch block `wMetaspriteBaseX`
  … `wMetaspriteRows` used by the block-drawing routine at `$1C6D`.
* **`wCurrentWeapon` (`$DFA0`)** — bank `$01`'s refill code adds it to the
  `wEnergy` base to pick which meter to top up, which is what names it.
* **Disassembled `FuncMemset` (`$1694`)** — writes A to `[HL]` then falls into
  `FuncFill` with DE = HL+1, dragging the value along the run. 19 call sites. And
  **`Mul8x8` (`$169F`)**, a fully unrolled 8×8→16 multiply, written back as a
  `REPT` that assembles to the identical bytes.

### Phase 1.1 — audio interface, label rename, Data Crystal audit (2026-09-22)

Coverage is unchanged at 16.66%: this session converted no new `INCBIN` bytes. What
it produced was understanding, and a source tree that is now this project's own work
rather than a copy of someone else's labels.

* **Renamed every inherited label.** 386 labels moved from the iimarckus skeleton's
  `FunctionXXXX`/`PointerXXXXX` shapes to bank-qualified `Func_BB_AAAA`,
  `Ptr_BB_AAAA`, `Data_BB_AAAA`, `Entry_BB_AAAA` — 540 replacements, driven from the
  symbol table so a label's bank and address are always right. A further 123
  replacements reworded the ~60 descriptive guesses into our own terms.
* **Added confidence tags.** Every descriptive label now carries `;[ok]`, `;[dc]` or
  `;[?]` — see `docs/CONVENTIONS.md`. Current census: 3 `[ok]`, 30 `[dc]`, 11 `[?]`.
* **Identified the Mega Buster shot graphics.** iimarckus's `UnknownBulletGFX` sits in
  slot 3 of bank `$04`'s pointer table, and slots 3–13 of that table are the weapons
  in exactly the order of the unlock bits at `$DFA1`/`$DFA2`. Slot 3 is the Mega
  Buster. Renamed `MegaBusterShot`.
* **Step 1.1 done.** The seven audio stubs at `$0236`–`$024A` are named after the
  entries they reach in `audio/bank02.asm`; `Func_00_02AD` is now `FarCallAudio` with
  its mechanism written out; `Func_00_01F4` is `CallBank1Routine`.
  `ram/wram.asm` and `ram/hram.asm` name `wCurrentBank`, `wAudioBank`,
  `hFarCallA`–`hFarCallD` and `hBank1CallIndex`, and the `bankswitch` macro uses them.
* **The tail-call question is settled** — it was a false alarm. Callers `call` the
  3-byte stub, and the stub runs the `rst $08`; the return address the trampoline
  discards is the stub-internal one, not the caller's. These are ordinary calls that
  cross a bank boundary. Recorded in `docs/BANKS.md`.
* **Audited Data Crystal's ROM map** (supplied by Will) — `docs/ROMMAP.md`. Its
  descriptions are all correct; its addresses are not, and not by a single offset:
  bank `$00` entries are 2 bytes high, bank `$01` entries past `$5772` are 30 bytes
  high, bank `$05` and `$06` are exact. Their bank-end figures match our measurements
  for 14 of 16 banks. Two of their hex listings contain typos that reverse the
  meaning (`34`/`35`, `3D`/`3E`). Every claim has been re-derived by byte search.
* **Cracked the text encoding**, as a side effect of checking their "name enemies"
  entry. Screen text is tile index = ASCII + `$60`, space `$6C`, `$00` terminator,
  each string preceded by a little-endian BG tilemap destination. Bank `$00`'s name
  table at `$20CA` is plain ASCII. The whole bank `$06` string block decodes cleanly
  — transcribed in `docs/ROMMAP.md`. Step 1.5 is now extraction, not discovery.

**Open questions carried forward:**

* `AudioSoundTabPtrs` (`$024B`, 49 words) is an identity mapping onto the audio
  bank's `SoundTab`. Nothing has been traced reading it.
* `CallBank1Routine` builds a `jp` in WRAM at `$C0D0` rather than using a jump table.
  Noted for the Phase 6 efficiency tally.
* Bank `$05`: `$16AAD`–`$16F21` sits past the end of the stage data and before the
  padding, and nothing accounts for it.
* The ending text has not been located; it is probably in bank `$0E`.

### Phase 0.1 — foundation (2026-09-21)

* Confirmed the supplied ROM (`Megaman - Dr. Wily's Revenge (U) [!].gb`, 262144 bytes)
  is byte-identical to the `base1.gb` that iimarckus's disassembly expects
  (sha256 `33d163…`).
* Built RGBDS 0.9.4 from source — it is not packaged in Ubuntu. `tools/bootstrap-rgbds.sh`
  reproduces this in about a minute.
* Ported `1.s` from the iimarckus repo to modern RGBDS. Three mechanical
  incompatibilities, all from RGBDS 0.6's syntax break:
  1. `name: MACRO` → `MACRO name`
  2. labels declared without a trailing colon
  3. `ld [$FFxx], a` / `ld a, [$FFxx]` — old RGBDS silently folded these into the
     2-byte `ldh` form; current RGBDS emits the 3-byte `ld [n16]` form. 37 lines
     affected, and this was the whole cause of the initial size overflow.
  With those fixed, `1.s` reproduces the ROM byte for byte. It is a labelled
  skeleton rather than a real disassembly — 472 labels over 4.9 KB of assembly and
  189 KB of `INCBIN` — but it is a *verified* one, and it gave us the section
  layout for all 16 banks for free.
* Split it into `banks/bank00.asm` … `banks/bank0f.asm`.
* Imported Will's audio disassembly as `audio/bank02.asm` and `audio/bank0a.asm`
  (from `MM1A.ASM` / `MM1B.ASM`, bank numbers corrected from the standalone
  player's `$1`/`$2` to the real `$02`/`$0A`), with `RAM.INC` split into
  `constants/audio_ram_constants.inc` and `ram/audio_ram.asm`. **Both banks
  reproduce the original with zero differing bytes.** That alone took the project
  from 1.9% to 16.7% coverage.
* Wired the audio banks' `JumpRNG`/`JumpFill` calls to real ROM0 labels at `$0159`
  and `$0162`.
* Disassembled `FuncRNG` (`$1758`, 23 bytes) from Will's `FUNCTIONS.ASM` and, in
  the process, identified the 256-byte `RNGTable` at `$176F` that it indexes —
  the first region disassembled by this repo rather than inherited.
* Wrote `tools/coverage.py`, `tools/disasm.py` (a straight-line disassembler in
  RGBDS syntax) and `tools/roundtrip.sh`. `disasm.py` round-trips exactly on seven
  sampled ranges across banks `$00`, `$01`, `$02` and `$09`.
* Mapped the banking architecture — see `docs/BANKS.md`. The important findings:
  111 of 117 bank switches are in bank `$00`; bank `$01` is the resident default;
  `$DF9A` selects between the two audio banks; `rst $08` → `$02AD` is the audio
  far-call trampoline, with seven thunks at `$0236`–`$024A`; and every banked bank
  except `$01` and `$0F` opens with a `jp` or `dw` entry table.
* Bank `$0F` is entirely empty (16 KB of `$FF`).

**Not done / open questions carried forward:**

* Data Crystal's *ROM map* and *Text table* subpages both returned HTTP 403 and
  have not been read. Retry them in step 1.5.
* The audio far-call trampoline appears to have tail-call semantics (it discards
  the caller's return address). Confirm under an emulator before relying on it.
* Banks `$03`, `$08`, `$09`, `$0D` have no literal bank switch pointing at them;
  the table that reaches them is step 1.4.
