# RAM map

Generated and curated by step 1.2. The tool is `tools/ramrefs.py`; the named
addresses live in `ram/wram.asm`, `ram/hram.asm` and `ram/audio_ram.asm`.

## What this can and cannot tell us yet

`tools/ramrefs.py` scans the ROM for the instruction forms that carry a RAM
address (`ld [nn],a`, `ld a,[nn]`, `ld hl/de/bc,nn`, `ldh`) and tallies them. It
is a byte scan, not a decode, so it classifies each hit by whether the ROM
offset sits in a region the source has already disassembled:

* **`code`** — inside real source. The hit is an instruction; the reference is
  real.
* **`blob`** — inside an `INCBIN`. It might be an instruction we have not
  reached yet, or it might be two bytes of a sprite that happen to look like
  one. A lead, not a fact.

Across the whole ROM the scan finds 718 WRAM and 103 HRAM addresses, but most of
those counts are `blob` noise — bank `$04`'s graphics alone produce hundreds of
false `ld hl,$Cxxx` hits. **83% of the ROM is still `INCBIN`, so a complete RAM
map is not reachable at this stage.** What is reachable, and what this step did,
is the set of addresses referenced from code we have actually disassembled.

Excluding the two audio banks (whose RAM is already fully mapped in
`ram/audio_ram.asm`), that set is **120 addresses**, of which **44 are now
named**. The rest are listed below with their reference counts, because a count
is information: `$CD25` being loaded into HL nine times says it is a table or a
buffer, even before we know which.

No `wUnknown_XXXX` placeholder labels were created. Replacing `$CCF7` with
`wUnknown_CCF7` in the source adds a name but no knowledge, and it makes the
next reader think the address has been looked at. The table below is the honest
form of the same information.

## Regions

| Range | Contents |
|---|---|
| `$C000`–`$C09F` | shadow OAM, 40 sprites x 4 bytes |
| `$C0A4`–`$C0FF` | 92 bytes memset to `$C9` (`ret`) at init, then written with small routines. The LCDC/STAT vector jumps to `$C0A4`; `CallBank1Routine` assembles a `jp` at `$C0D0`; banks `$0B`/`$0E` copy a 23-byte table to `$C0B0`, which overlaps and is not yet explained |
| `$C100`–`$C1FF` | game state — lives at `$C108` |
| `$C380`–`$C3E2` | object system: active list `$C380` (count `$C398`), slot free list `$C399`–`$C3B2` (pointer `$C3B1`), spawn-record count `$C3B2`, sprite-tile allocator `$C3B3`, 12-entry type→tile cache `$C3C4`–`$C3DB` |
| `$C400`– | stage spawn records, 8 bytes each |
| `$C600`–`$CBFF` | 24 object slots of `$40` bytes. Known offsets: `$00` routine address, `$0A` X, `$0D` screen X, `$10` sprite handle (`AllocSprite` / `FreeSprite`), `$11` flags, `$15`/`$17` hitbox table and index, `$18` hit points (weapon damage subtracts here), `$1A`, `$1B` bank, `$22`–`$23` freeze timer |
| `$CC00`–`$CC1B` | `SpawnObject`'s header buffer; `$CC40`/`$CC41` current object pointer |
| `$DFB0`–`$DFC4` | hitbox viewer (disabled): `$DFB0` cleared on exit, `$DFB1` = `wFreezeFlags` (step 5.1): bit 0 the viewer has play frozen, bit 1 a meter refill, bit 3 Time Stopper; object code in many banks reads it, cursor `$DFB2`/`$DFB3`, box corners `$DFB8`–`$DFBF`, sprite handles `$DFC0`–`$DFC4` (never allocated) |
| `$DF00`–`$DF40` | per-frame hitbox list, count byte first |
| `$DF80`–`$DF82` | `wStageHook`: a `jp` to the stage's frame hook, installed by `LoadRestartPoint` (`$3057`); `StageFrameLoop` calls it every frame |
| `$D861`–`$D8C8`+ | stage and room state (step 4.1, `docs/LEVELS.md`): camera limits `wScrollMinX`/`wScrollMaxX` `$D861`–`$D864`, `wRoomRowPtrs` `$D877`, `wRoomPtr`/`wRoomLayoutPtr`/`wRoomRoutinePtr`/`wRoomXOffset` `$D887`–`$D88E`, `wExitBoxes` `$D892`–`$D8A1`, `wRestartInitPtr` `$D8A2`, `wRoomWidth`/`wRoomHeight` `$D8C0`, `wBlocksetPtr`/`wBlockCount` `$D8C4`–`$D8C6`, `wBlockCollision` `$D8C8`–`$D907`. Used by the stage hooks: `$D8C7` the block under Mega Man's feet (`CheckPlayerLanding`), `wFloorType` `$D908` (2 on Ice Man's ice; picks walking acceleration and friction), `$D838` damage waiting to be taken, `$D830` (16-bit) a push added to Mega Man's X movement for one frame and cleared (conveyors add ∓`$B0`; `$D832` is the same for Y, used by Carry), `$D80B` Mega Man's OAM attributes, `$D3ED` objects' OAM priority bit |
| `$D90A`–`$D916` | Wily 2 hub state (`wHubState`, `wHubFadeTimer`, `wHubFadeStep`, `wHubDestination`) and the chunked tile copy (`wTileCopyChunk`, `wTileCopySource`, `wTileCopyDest`, `wTileCopyLeft`) - step 4.3. `wUnderwater` `$D909` is set in Bubble Man's room: lower gravity, jump and top speed (step 5.1) |
| `$DF96`–`$DF97` | `wWilyProgress` (bits 0-4 hub bosses beaten, bit 7 reached the hub), `wHubTeleporter` (1-5) |
| `$DF8D`–`$DF92` | `wRestartPoint`, the stage header copy (`wRestartPointsPtr`, `wCheckpointsPtr`), `wRoomID` |
| `$D000`–`$D28B` | sprite system: handle records `$D0xx`, handle → record `$D100`, handle pool `$D240` (pointer `$D280`), holder / waiting lists `$D281`–`$D286`, link table `$D2xx` |
| `$CD00`–`$CDDA` | enemy shots: active list `$CD00`–`$CD0B`, count `$CD0D`, free stack `$CD0E`–`$CD19` (pointer `$CD1A`), twelve 16-byte records `$CD1B`–`$CDDA` |
| `$C600`–`$C615` (password screen only) | `$C600` result / debounce, `$C601`/`$C602` cursor column/row, `$C603` button debounce, `$C604` sprite tile, `$C608` next OAM offset, `$C60F` balls left, `$C611`–`$C615` ball cells — reusing object-slot RAM outside the stages |
| `$CE28`–`$CF77` | OAM entry pool (`$CE28`–`$CE4F`, pointer `$CE50`), links `$CExx`, OAM offsets `$CFxx`; `$CE53`–`$CE57` drawing scratch |
| `$DE00`–`$DEFF` | 16×16 grid of 16-pixel blocks for the visible area (`PixelToBlockGridAddr`) |
| `$C200`–`$C29A` | weapon and shot state (step 5.1, `ram/wram.asm`): `wShotCount`, `wShootTimer`, hit list 1 (`wShotListEnd`, `wShotListActive`, `wShotHitbox`, entries from `wShotList` `$C209`), hit list 2 (`$C216`–`$C21D`+), the weapon record copied from `WeaponTab` (`wWeaponDamage` `$C203`, `wWeaponTileset` … `wWeaponPierce` `$C22B`–`$C235`), `$C22A`/`$C236` the collision pass's hit slot and hit flag, `$C237`/`$C238` weapon scratch, three `$20`-byte shot records `wShotSlots` `$C239`, the Mirror Buster capture list `$C299`–. `$C300`–`$C302`: the pause menu's selection, previous selection and blink timer |
| `$D300`–`$D3ED` | explosions: live list `$D300` (count `$D30C`), free list `$D30D` (pointer `$D319`), twelve `$10`-byte records from `$D31A`; `$D3DA`–`$D3E9` a record being built; `$D3EB`/`$D3EC` where an enemy died (explosion and drop position) |
| `$D400`–`$D4C5`+ | items: live list `$D400` (count `$D40B`), free list `$D40C` (pointer `$D416`), ten `$10`-byte records from `$D417`; spawn parameters `$D4B7`–`$D4BD`; refill: `$D4BE` delay, `$D4BF`/`$D4C0` the meter, `$D4C1` points left; placed-item list `$D4C3`– (end pointer `$D4C2`, 3 bytes per item) |
| `$D802`–`$D84E` | Mega Man (step 5.1): `wPlayerState` `$D802`, `wPlayerFacing` `$D803`, animation and ladder-transition counters `$D804`–`$D809`, `wPlayerAnim` `$D80A`, OAM attributes `$D80B`, X `$D820`/`wPlayerX`, Y `$D823`–`$D825` (`wPlayerY` = `$D824`), this frame's movement `$D826`/`$D827`, Y speed `$D828`/`$D829`, X speed `$D82A`/`$D82B`, external pushes `$D830`/`$D832`, knockback speed `$D834`, damage `$D838`, `wHurtTimer` `$D839`, hit spark `$D83A`–`$D83E`, `wPlayerPressed`/`wPlayerHeld` `$D83F`/`$D840`, his box `$D841`–`$D844`, `wPlayerMotion` `$D846`, rise timer `$D84A`, jump speed `$D84B` |
| `$CC4B`–`$CC58` | metasprite drawing scratch, then the four stage-select sprite positions |
| `$CCF2`–`$CCFA` | stage-select animation state (`$CCF6`-), **and in boss fights** (step 5.2, object library): boss position `$CCF2`/`$CCF3`, boss beaten `$CCF5` (set by `CheckBossDead`), the boss's attack request to its shot objects `$CCF6` (Bubble Man 1/2, Heat Man 3; the RAM keeps its stage-select name `wStageSelectAnimPhase`), once-only flags for wStageState 2 and the victory countdown `$CCF7`/`$CCF8`, the boss's record `$CCFA` |
| `$D85F`–`$D860` | scroll shadows |
| `$D8A4` | `Div32By16` loop counter (routine unused) |
| `$D8AC`–`$D8B4` | line-stepper state (`wLine*`), shared by bank `$00`'s `LineStep` and the copies in banks `$03`/`$09`/`$0D` |
| `$D93A`–`$DCBB` | audio engine — see `ram/audio_ram.asm` |
| `$DF83`–`$DF9C` | VBlank bookkeeping, banking, LCD shadows, selected stage, defeated bosses |
| `$DFA1`–`$DFAF` | weapon unlocks, energy meters, RNG state |
| `$FF80`–`$FF89` | OAM DMA routine, copied here at boot |
| `$FF8A`–`$FF8B` | joypad held / newly-pressed |
| `$FF8A`–`$FFFB` | the HRAM variable area, memset to zero at boot |
| `$FF8C`–`$FF91` | far-call register scratch |

## Every address referenced from disassembled non-audio code

| Address | Name | Refs | Access | In banks |
|---|---|---:|---|---|
| `$DF99` | `wCurrentBank` | 58 | read x3, write x55 | $00 |
| `$CCFF` | `wStageSelectFrame` | 18 | read x1, write x17 | $00 |
| `$CCF9` | `wScreenCounter` | 12 | read x8, write x4 | $00 |
| `$CCF6` | `wStageSelectAnimPhase` | 11 | read x4, write x7 | $00 |
| `$CD25` | — | 9 | ld hl x9 | $00 |
| `$DFA0` | `wCurrentWeapon` | 7 | read x6, write x1 | $00, $01 |
| `$C000` | `wShadowOAM` | 6 | ld de x4, ld hl x2 | $00 |
| `$CCF7` | — | 6 | read x4, write x2 | $00 |
| `$CCFE` | `wStageSelectTimer` | 6 | read x5, write x1 | $00 |
| `$DF9A` | `wAudioBank` | 6 | read x4, write x2 | $00, $01 |
| `$DF8C` | `wSelectedStage` | 5 | read x4, write x1 | $00 |
| `$CC4D` | `wMetaspriteCurX` | 4 | read x1, write x3 | $00 |
| `$CC4E` | `wMetaspriteCurY` | 4 | read x2, write x2 | $00 |
| `$CC51` | `wStageSelectPos` | 4 | read x2, write x2 | $00 |
| `$CC52` | `wStageSelectPos1Y` | 4 | read x2, write x2 | $00 |
| `$CC53` | `wStageSelectPos2X` | 4 | read x2, write x2 | $00 |
| `$CC54` | `wStageSelectPos2Y` | 4 | read x2, write x2 | $00 |
| `$CC55` | `wStageSelectPos3X` | 4 | read x2, write x2 | $00 |
| `$CC56` | `wStageSelectPos3Y` | 4 | read x2, write x2 | $00 |
| `$CC57` | `wStageSelectPos4X` | 4 | read x2, write x2 | $00 |
| `$CC58` | `wStageSelectPos4Y` | 4 | read x2, write x2 | $00 |
| `$D936` | `wQueuedSoundPtr` (6.4) | 4 | read x2, write x2 | $00 |
| `$D937` | — | 4 | read x2, write x2 | $00 |
| `$DF95` | `wBossesDefeated` | 4 | read x4 | $00 |
| `$C131` | `wAudioLock` (6.4) | 3 | read x1, write x2 | $00 |
| `$CC4B` | `wMetaspriteBaseX` | 3 | read x2, write x1 | $00 |
| `$CCFC` | — | 3 | read x1, write x2 | $00 |
| `$D920` | — | 3 | ld hl x2, write x1 | $00 |
| `$DF8A` | `wShadowLCDC` | 3 | read x2, write x1 | $00, $01 |
| `$DFB1` | — | 3 | ld hl x2, read x1 | $01 |
| `$FF8F` | `hFarCallE` | 3 | ldh read x1, ldh write x2 | $00 |
| `$FFFF` | — | 3 | ldh write x3 | $00, $01 |
| `$C108` | `wLives` | 2 | ld hl x1, write x1 | $00, $01 |
| `$C200` | — | 2 | read x1, write x1 | $01 |
| `$C201` | — | 2 | ld hl x1, write x1 | $01 |
| `$CB3D` | — | 2 | ld hl x2 | $00 |
| `$CC47` | — | 2 | read x1, write x1 | $00 |
| `$CC4C` | `wMetaspriteBaseY` | 2 | read x1, write x1 | $00 |
| `$CC4F` | `wMetaspriteCols` | 2 | read x1, write x1 | $00 |
| `$CC50` | `wMetaspriteRows` | 2 | read x1, write x1 | $00 |
| `$CCF8` | — | 2 | read x1, write x1 | $00 |
| `$D4BF` | — | 2 | read x1, write x1 | $01 |
| `$D4C0` | — | 2 | read x1, write x1 | $01 |
| `$D4C1` | — | 2 | ld hl x1, write x1 | $01 |
| `$DF85` | `wFrameCounter` | 2 | read x1, write x1 | $00 |
| `$DF89` | `wVBlankBusy` | 2 | read x1, write x1 | $00 |
| `$DF9C` | `wShadowBGP` | 2 | read x1, write x1 | $00, $01 |
| `$DF9F` | — | 2 | read x1, write x1 | $00 |
| `$DFA3` | `wEnergy` | 2 | ld de x1, ld hl x1 | $01 |
| `$DFAE` | `wRNGSeed` | 2 | read x1, write x1 | $00 |
| `$FF8C` | `hFarCallA` | 2 | ldh read x1, ldh write x1 | $00 |
| `$FF8D` | `hFarCallL` | 2 | ldh read x1, ldh write x1 | $00 |
| `$FF8E` | `hFarCallH` | 2 | ldh read x1, ldh write x1 | $00 |
| `$FF90` | `hFarCallD` | 2 | ldh read x1, ldh write x1 | $00 |
| `$FF91` | `hBank1CallIndex` | 2 | ldh read x1, ldh write x1 | $00 |
| `$C010` | — | 1 | ld de x1 | $00 |
| `$C034` | — | 1 | ld de x1 | $00 |
| `$C054` | — | 1 | ld de x1 | $00 |
| `$C070` | — | 1 | ld de x1 | $00 |
| `$C0A4` | `wRamCode` | 1 | ld hl x1 | $00 |
| `$C0AA` | — | 1 | write x1 | $01 |
| `$C0AB` | — | 1 | write x1 | $01 |
| `$C0AC` | — | 1 | write x1 | $01 |
| `$C0AD` | — | 1 | write x1 | $01 |
| `$C0AE` | — | 1 | write x1 | $01 |
| `$C0AF` | — | 1 | write x1 | $01 |
| `$C0D0` | `wBank1CallJump` | 1 | write x1 | $00 |
| `$C0D1` | — | 1 | write x1 | $00 |
| `$C0D2` | — | 1 | write x1 | $00 |
| `$C102` | — | 1 | ld hl x1 | $00 |
| `$C203` | — | 1 | ld de x1 | $01 |
| `$C22B` | — | 1 | write x1 | $01 |
| `$C22C` | — | 1 | write x1 | $01 |
| `$C22D` | — | 1 | write x1 | $01 |
| `$C22E` | — | 1 | write x1 | $01 |
| `$C22F` | — | 1 | ld de x1 | $01 |
| `$C235` | — | 1 | write x1 | $01 |
| `$C239` | — | 1 | ld hl x1 | $01 |
| `$C301` | — | 1 | ld bc x1 | $00 |
| `$C919` | — | 1 | ld bc x1 | $00 |
| `$C9F1` | — | 1 | ld hl x1 | $00 |
| `$CC00` | — | 1 | write x1 | $01 |
| `$CC4A` | `wAudioStopSlot` (6.2) | 1 | write x1 | $00 |
| `$CD03` | — | 1 | ld bc x1 | $00 |
| `$CD15` | — | 1 | write x1 | $01 |
| `$CE58` | — | 1 | read x1 | $00 |
| `$CF36` | — | 1 | ld de x1 | $00 |
| `$CF5E` | — | 1 | ld de x1 | $00 |
| `$D0CD` | — | 1 | ld hl x1 | $00 |
| `$D1C1` | — | 1 | ld sp x1 | $00 |
| `$D421` | — | 1 | ld sp x1 | $00 |
| `$D4BE` | — | 1 | ld hl x1 | $01 |
| `$D83F` | — | 1 | read x1 | $01 |
| `$D840` | — | 1 | read x1 | $01 |
| `$D85F` | `wShadowSCX` | 1 | read x1 | $00 |
| `$D860` | `wShadowSCY` | 1 | read x1 | $00 |
| `$D865` | — | 1 | ld hl x1 | $00 |
| `$D86B` | — | 1 | ld hl x1 | $00 |
| `$D86C` | — | 1 | read x1 | $00 |
| `$D86D` | — | 1 | read x1 | $00 |
| `$D8C4` | `wBlocksetPtr` | 1 | read x1 | $00 |
| `$D8C5` | `wBlocksetPtr + 1` | 1 | read x1 | $00 |
| `$DCBC` | `wMusicSlot` (6.4) | 1 | read x1 | $00 |
| `$DDD0` | — | 1 | ld de x1 | $00 |
| `$DDE0` | — | 1 | ld hl x1 | $00 |
| `$DF83` | `wVBlankCount` | 1 | ld hl x1 | $00 |
| `$DF86` | — | 1 | read x1 | $00 |
| `$DF88` | `wVBlankDone` | 1 | write x1 | $00 |
| `$DF97` | `wHubTeleporter` | 1 | read x1 | $00 |
| `$DF9D` | — | 1 | read x1 | $00 |
| `$DF9E` | — | 1 | read x1 | $00 |
| `$DFAF` | `wRNGIndex` | 1 | ld hl x1 | $00 |
| `$DFC8` | — | 1 | read x1 | $00 |
| `$DFCF` | — | 1 | write x1 | $00 |
| `$DFD0` | — | 1 | write x1 | $00 |
| `$DFD4` | — | 1 | write x1 | $00 |
| `$FF8A` | — | 1 | ldh read x1 | $01 |
| `$FFAF` | — | 1 | ldh read x1 | $00 |
| `$FFB2` | — | 1 | ldh read x1 | $00 |
| `$FFDD` | — | 1 | ldh write x1 | $00 |

## Leads worth following

* **`$CD25`** — loaded into HL nine times and never read or written directly, so
  it is the base of a table or buffer.
* **`$CCFC`** — read/write pair adjacent to the stage-select animation block.
  (`$CCF7`/`$CCF8` are the boss-fight once-only flags - step 5.2.)
* **`$D920`, `$DCBC`, `$DFD4`, `$DFCF`, `$DFD0`** — single references each, all
  from code near save/restore and init paths.
* **`$FFBA`, `$FFB0`, `$FFB7`, `$FF9B`** — HRAM with a handful of `ldh` hits
  each, none yet traced to a purpose.

One entry has already been struck off as a false positive: `$FFF2` was listed
because of `ld hl,$FFF2` at `$23C7`, which is not an address at all — it is −14,
added to DE to subtract from it. Expect more of these. A `ld hl,nn` hit with no
matching read or write anywhere is the signature.

## Rerunning

```
python3 tools/ramrefs.py                 top WRAM and HRAM addresses
python3 tools/ramrefs.py --all --min 2   everything with 2+ references
python3 tools/ramrefs.py --sites CD25    every site that touches one address
```

Rerun after each disassembly step: as `INCBIN` turns into source, hits migrate
from `blob` to `code` and this map gets sharper for free.
