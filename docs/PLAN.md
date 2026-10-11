# Disassembly plan

Each numbered step is sized to fit comfortably inside **one session**, ending with a
green `./build.sh` and a commit. Steps within a phase are ordered, but Phase 3–6
work can be interleaved if one area gets tedious.

Tick a step's box when it is done and add a line to [PROGRESS.md](PROGRESS.md).

Read [SESSION_START.md](SESSION_START.md) before starting any step.

---

## Phase 0 — Foundation

- [x] **0.1 — Verified base, byte-perfect build, merged audio, tooling.**
  ROM confirmed identical to iimarckus's `base1.gb`. His `1.s` ported to modern
  RGBDS and split per bank. Will's audio disassembly imported as banks `$02`/`$0A`
  and confirmed to reproduce both banks with zero differing bytes. `./build.sh`
  green. Coverage: **16.7%** of real content.

---

## Phase 1 — Maps and conventions

Cheap, high-leverage work. Everything after this reads more easily because of it.

- [x] **1.1 — Name the audio interface in ROM0.** Seven stubs named, `FarCallAudio`
  and `CallBank1Routine` documented, `wCurrentBank`/`wAudioBank`/`hFarCall*` labelled,
  and the tail-call question answered (it is an ordinary call — see `docs/BANKS.md`).
  Left over from this step: `AudioSoundTabPtrs` at `$024B` — 49 words running
  `$4015`, `$4017` … `$4075` with no gaps or repeats, i.e. pointers to consecutive
  entries of the audio bank's `SoundTab`. No caller traced yet, and as an identity
  mapping it appears to buy nothing. **Resolved in 2.1:** `StageMusicTab` and
  the boss/victory music selection read it.

- [x] **1.2 — Build the RAM map.** `tools/ramrefs.py` tallies every RAM address
  the ROM touches, classified by whether the referencing site is real source or
  still `INCBIN`. 120 addresses are reachable from disassembled non-audio code;
  44 are named in `ram/wram.asm` / `ram/hram.asm`, and the rest are listed with
  reference counts in `docs/RAMMAP.md`. 157 numeric literals in the source became
  labels. A complete RAM map is not reachable until far more of the ROM is
  disassembled — rerun the tool after each step and it sharpens for free.

- [x] **1.3 — Hardware register names.** All `$FFxx` register literals in the
  disassembled source now use `hardware.inc` names, and VRAM/OAM/stack addresses
  use constants from the new `constants/memory.inc`. Tilemap addresses are written
  as `TILEMAP0 + $0CD` rather than `$98CD`. Added `constants/joypad.inc`
  (`PADF_*`, `P1F_GET_*`) because this copy of hardware.inc has neither, and
  disassembled `ReadJoypad`, `InstallOAMDMA` and `OAMDMARoutine` — the joypad
  routine is what defines `hJoypadHeld` / `hJoypadPressed` and it turned up the
  soft-reset combo. 53 substitutions. Note `ld hl,$FFF2` at `$23C7` is *not* an
  address: it is −14, used to subtract from DE.

- [x] **1.4 — Find the computed bank tables.** There are two, both now expressed as
  source. `StageLoadTab` (`$2F93`, 8 records) supplies banks `$05`/`$08` via
  `wStageBank`; `ObjectTypeTab` (`$3693`, 56 records) supplies `$03`/`$09`/`$0D`
  via each object's `OBJ_BANK` field. Every entry-table slot in those three banks
  is referenced exactly once. Full write-up in `docs/BANKS.md` →
  "The banks no literal selects".
  Left over: nothing has been traced *writing* `OBJ_BANK` — the field is filled at
  spawn by some route other than the `ld a,$1B / add a,c` idiom. Finding the spawn
  path should also name the 56 object types.

- [x] **1.5 — Extract the text.** All of it is now source. `constants/charmap.inc`
  declares a named `screen` charmap (ASCII + `$60`, space `$6C`, `©` at `$A0`)
  alongside the default plain-ASCII one, since the game uses both. Bank `$06`'s
  four groups are `screentext` macro calls under `PasswordText`, `EndingText`,
  `GameOverText` and `TitleScreenText`, reached through four named pointer slots.
  *(Corrected in 2.4: the sweep only tried two encodings and missed three
  blocks — see ROMMAP.md.)* A whole-ROM sweep in both encodings found no other
  text beyond those 19 strings, the bank `$00` stage-name table (already source)
  and the cartridge header. Also named `TypeBossName` (`$2097`), which reveals the
  boss name one letter per frame, and corrected `wTileCopyCount` → `wScreenCounter`.

**Phase 1 is complete.**

---

## Phase 2 — ROM0 (bank `$00`), the engine core

Bank `$00` is 14.4 KB of real content, currently 26% disassembled. It holds the main
loop, the VBlank handler, joypad reading, OAM handling, the RNG and all bank
switching, so it unlocks every other bank. Work through the gaps in order.

- [x] **2.1 — `$041E`–`$05FE` and `$0855`–`$0CC9`** (≈1.6 KB). The font and health
  bar are PNGs under `gfx/` built by `rgbgfx`; the code is the game's main flow —
  `NewGame`, `PlayStage`, `StageFrameLoop`, `LoseLife`, `BossDefeated`,
  `StageMusicTab` and friends. Bank `$00` 26% → 41%.
- [x] **2.2 — `$0CDC`–`$167E`** (≈2.4 KB), plus the cartridge header. All of it is
  source now; the utility routines (`DisableLCD`, `DelayFrame`, `EnableLCD`…),
  `Init`/`.softReset`, `TitleScreen` and a 5-tile BG graphic are named, the rest
  stays `Func_00_AAAA`. The header is in source with named constants
  (`constants/cartridge.inc`). Bank `$00` 41% → 57%.
- [x] **2.3 — `$16CB`–`$1758`, `$186F`–`$1AE3`, `$1AFC`–`$1B6B`** (≈0.9 KB). An
  unused arithmetic library (`Mul16x16`, `Div16`, `Div32By16`, `RandomBelow`), the
  VRAM-safe memset/copy family, `GetTablePointer`, a line-stepper, and the
  title / game-over / password / ending screen loaders. Bank `$00` 57% → 63%.
- [x] **2.4 — `$21C7`–`$2245`, `$23A8`–`$2516`, `$252B`–`$2C37`** (≈2.2 KB). The
  weapon-get text (a third encoding, which overturned 1.5's "no other text"),
  stage and object tile loading, and the object system's core: slot allocation,
  `SpawnObject`, `CallObjectRoutine`, the collision pass and the Ice Slasher freeze.
  Object types are one-based. Bank `$00` 63% → 78%.
- [x] **2.5 — `$2C6B`–`$3496`** (≈2.0 KB). The sprite system (handles, an OAM
  pool, metasprite drawing, and the round-robin rotation that makes sprites
  flicker), `ResetAndLoadStage`, and the stage-section loader that installs
  `wStageHook`. Bank `$00` 78% → 92%.
- [x] **2.6 — `$34D3`–`$3979`** (≈1.2 KB). `ObjectStatsTab` (per-type spawn
  attributes), the enemy-shot system, `BossDamageTab` confirmed, and the last
  `INCBIN` (`RNGTable`) and the `freespace` tail turned into source. **Bank `$00`
  is 100% source** and no longer reads `baserom.gb`.
- [x] **2.7 — Move bank `$00` out of `banks/`.** Done: 27 files (24 in `engine/`,
  3 in `data/`), 40 pinned sections, free space as `ds`. See PROGRESS.
  Split the finished bank into `engine/` files by subsystem (`engine/main.asm`,
  `engine/vblank.asm`, `engine/joypad.asm`, `engine/oam.asm`, `engine/banking.asm`,
  `engine/rng.asm`, `engine/audio_interface.asm`) and replace its `freespace` with
  an explicit `ds` fill.

**Method for each 2.x step:** `./build.sh` (to refresh `mmwr.sym`), then
`python3 tools/srcgen.py START END --bank 0 [--words A B] [--data A B]` to get a
labelled, symbolised first draft. Read it, mark data ranges and rerun, paste it in
place of the `INCBIN`, name what you understand, leave `Func_BB_AAAA` for what you do not, and
`./build.sh`. Do not try to name everything — a correctly-delimited, unnamed
routine is real progress; a misnamed one is a debt.

---

## Phase 3 — Graphics and tilemaps

- [x] **3.1 — Bank `$04` sprite graphics.** Done: every tile run is a PNG under
  `gfx/sprites/` (39 files), round trip exact. The 27 unnamed slots turned out to
  be one stage-select graphic and 26 object-type tilesets; they are named by
  object type (`ObjTilesType01` …), since raw tiles do not assemble into
  recognisable enemies without the metasprite data (Phase 5). Only the filler at
  `$63F8` is still `INCBIN "baserom.gb"`. Original text:
  42 pointers, and iimarckus already named 15 of the targets (Mega Man, each
  weapon, the health bar, the 7-segment digits). Extract each run to a `.2bpp`
  file under `gfx/`, add an `rgbgfx` step to `build.sh`, and confirm the
  round-trip is lossless (`rgbgfx` must reproduce the original bytes exactly —
  if it cannot for some run, keep that run as `INCBIN` and say why).
  Name the remaining 27 pointers by rendering them and looking.
- [x] **3.2 — Bank `$06` tilemaps.** Done: no compression anywhere in the bank.
  Tiles are PNGs in `gfx/screens/`, maps are raw `gfx/tilemaps/*.tilemap`; the
  21 slots are the title logo, menu font, four text groups, the stage select,
  the weapon-get screen and four cutscene pictures. Bank `$06` is 100% source.
  Original text: 21 pointers; `TitleScreenTilemap` is known.
  Determine whether tilemaps are raw or RLE-compressed, then decode and name them.
- [x] **3.3 — Bank `$0C`.** Done, 100% source: the 8 stage tilesets (PNGs in
  `gfx/stages/`) with their LoadStageTiles lists, the bank-1 trampoline kit, and
  the **password system** — entry and display screens, the 16-password table,
  graphics — plus two dead copies of code from other banks.
- [x] **3.4 — Compression audit.** Neither 3.2 nor 3.3 found any compression:
  banks `$04`, `$06` and `$0C` are all plain tiles and maps. Nothing to write. Original:
  If 3.2 or 3.3 turns up a compression format,
  document it in `docs/FORMATS.md` and write `tools/decompress.py` so later steps
  can read compressed blobs without guessing.

---

## Phase 4 — Level data

- [x] **4.1 — Bank `$05`: the level data format.** Done; format in
  [LEVELS.md](LEVELS.md), renders in `docs/levels/`, `tools/leveldump.py` dumps and
  renders any stage. A stage is a header → restart points (start + checkpoints,
  14-byte records holding the blockset, collision table, init, frame hook, start
  position and room) → rooms (id, routine, layout, X offset, two exits, spawn
  list), with 16×16 blocks and an 8-row layout per room; rooms connect only
  vertically. The bank `$05` data is now `db`/`dw` source with every pointer a
  label (layouts and blocksets stay `INCBIN` for 4.2), the four stages' code is
  disassembled (conveyors, spikes, ice, palette effects, behind-BG zones), and the
  stage loader in bank `$00` is named (`LoadRestartPoint`, `LoadRoom`,
  `CheckRoomExits`, `BuildExitBox`, `DrawBlock`, …). `$16AAD`–`$16FFF` is
  uninitialised-memory filler. Will confirmed the renders match the game.
  Vestigial candidate for the side-by-side boss doors: side-wall exits the engine
  supports and no stage uses (UNUSED.md). The unplaced open/closed shutter block
  pair is the one real shutter, drawn at run time - probably by object type 55
  (bank `$09`), spawned once per stage before the boss room. Types 13 and 14 are
  never placed.
  Original text: Pointers are named for Cut Man, Ice Man, Fire Man and Elec Man;
  each stage's data is nested; `$16AAD`–`$16F21` unexplained; watch for vestigial
  boss-door fields; derive it, write `tools/leveldump.py`, confirm against the game.
- [x] **4.1b — Render the alternate Fire Man stage.** Done: render in
  `docs/levels/8_fire_man_alt.png`, and the stage (bank `$08` `$6F67`–`$7828`) is
  source in `banks/bank08.asm` like the bank `$05` stages. 9 rooms against the
  final's 13, a straight descent, only 4 spawns (two type 8 and the boss pair), the
  same blockset parts. Its layouts draw the shutters into the map - a passable
  2×4 door in the corridor and a **closed door in the boss room's left wall**,
  the only side-wall door in the game (UNUSED.md). Its frame hook lacks the
  behind-BG zone code, so that was added to Fire Man later.
- [x] **4.2 — Express levels as macros.** Done: one file per stage in
  `data/stages/` (the four robot masters and the alternate Fire Man), written with
  `macros/stages.inc` - `room`, `exit_up`/`exit_down`, `spawn`, `restart_point`,
  `checkpoint`, `layout`/`lrow` (a row of hex block numbers as a string), `block`,
  `blockset`. The macros assert row widths, row counts, exit lengths, the block
  count and the collision-table length. No stage data is `INCBIN` any more; bank
  `$05` is pinned at `$4000` and its tail is `ds $8000 - @`, so stages can grow.
  How to edit and preview: LEVELS.md, "Editing a stage".
  Original text: Once the format is understood, replace the `INCBIN`s with
  `macro`-based source so a stage is editable. `./build.sh` proves the macros are
  right.
- [x] **4.3 — Wily stages and the remaining bosses.** Done: bank `$08` is 100%
  source - `data/stages/wily1.asm`, `wily2.asm`, `wily3.asm` and an unreferenced
  test stage `wily2_test.asm`, renders in `docs/levels/`. Wily 1 drops straight
  into Wily 2's teleporter hub, swapping blocksets and streaming tiles mid-level
  (`SwapRestartData`, `QueueTileCopy`); the hub's state machine warps to five boss
  rooms through `JumpLoadRestartPoint`: Quick Man, Bubble Man, Flash Man, Heat Man
  (the four Mega Man 2 bosses - the old list of six was wrong) and Enker, named
  through the weapon each awards. Wily 3 ends in the Wily Machine room with its
  own blockset. `wWilyProgress` (`$DF96`) and `wHubTeleporter` (`$DF97`) are
  decoded. Leftovers: two orphaned restart records, an unreachable Wily 1 restart
  point, the test stage (UNUSED.md).
  Original text: The Wily stages and the returning Mega Man 2 bosses (Quick Man,
  Air Man, Crash Man, Heat Man, Flash Man, Bubble Man) live outside bank `$05`;
  find them.
- [x] **4.4 — Bank `$07`.** Done, 100% source: not placement but graphics. 21
  tileset records and the tiles for object types 30-56 (PNGs in `gfx/bosses/`,
  named for the eight robot masters and Enker; the rest by type number), and the
  stage select's robot master sprites - four tile lists that build each master's
  sprite VRAM out of his boss tiles, 19 metasprite frames and two jump arcs (render:
  `docs/sprites/stage_select_robot_masters.png`, `tools/stageselect.py`). Type 56's
  tiles spell "DR.WILY TELEPORT SYSTEM"; type 41's are bubbles; type 55's are the
  shutter stripes. Also found: the Wily Machine room's background tiles are bank
  `$06`'s cutscene graphics. **Phase 4 is complete.**
  Original text: Bank `$07` (31 pointers). Likely enemy/object placement per
  screen.

---

## Phase 5 — Object and enemy engine

- [x] **5.1 — Bank `$01`, the resident bank.** Done, 100% source, split into
  `engine/` and `data/` files by subsystem. Mostly not menus but Mega Man: the
  weapon system (`WeaponTab`, `TryFireWeapon`, `UpdateShots`, three shot slots, all
  eleven weapons' fire and update routines, animations and frames), item drops and
  placed items, the meter refill, explosions, the pause menu, the HUD, the title,
  stage-select and weapon-get screens, and all of Mega Man's movement, collision,
  drawing and teleporting. Answered: who calls `wHookA` (the fire button, from
  `UpdatePlayer`), what the collision values mean (`CheckSolidAt`), `$D908`/`$D909`
  (floor type, underwater). 47 tails of routines keep provisional names.
  Original text: Bank `$01`, the resident bank (13 KB, 3.7% done). HUD, menus,
  title screen, health and weapon energy. iimarckus named the energy-refill logic
  (`Func_01_574E` and friends) — start there.
- [x] **5.2 — Bank `$09`.** Done, 100% source in one session (a generalised
  generator, `tools/bankgen.py`). The bank is an entry table, the **object
  library** (1794 bytes of helpers that banks `$03` and `$0D` carry too - now one
  shared file, `engine/object_library.asm`, so those banks start at 12% and 20%),
  and 24 object types, one file each in `engine/objects/`: Enker, Bubble Man,
  Flash Man, Heat Man and their shots, the boss door, the Atomic Fire block,
  and the enemies (named by Will after the step: Sniper Joe, fire beams,
  Changkey, Changkey Maker, Kaminari Goro, Pipi/Copipi, Scworm). Answered: how
  objects spawn objects (`SpawnChildObject`), what offsets `$15`/`$17` are (the
  frame table, not a handler), which never-placed types are children (all but
  13, which is unused). Original text: Bank `$09` (24-entry jump table, 15.3 KB,
  code-heavy).
- [x] **5.3 — Bank `$03`.** Done, 100% source. 22 object types: the first four
  robot masters and their shots (which end their fights - so the Fire Storm
  beside Elec Man only ends his), the fan, ice platform, appearing blocks
  (schedule format decoded), icicle, the electric beam and nine enemies (named by Will after the step:
  Cutting Wheel, Screw Driver, Gabyoall, Super Cutter, Bigeye, Bunby Heli,
  Metall, Mole, Suzy). Library
  config moved to `tools/bankgen/objlib.py`. Original text: Bank `$03` (22-entry
  jump table, 15 KB, code-heavy).
- [x] **5.4 — Banks `$0B` and `$0E`.** Done, both 100% source: `$0B` is the Wily
  cutscenes (before Wily 1 and Wily 3), `$0E` the ending (skull ship explosion,
  roll call, corridor, closing text). The roll call confirms the enemy names by
  tile shape and skips DRILLUN and PICOPICO. Original text: Bank `$0B` (5.5 KB of
  content, 10.5 KB empty) and bank `$0E` (15 KB). These two share an entry idiom,
  so do them together.
- [x] **5.5 — Bank `$08`.** Already 100% source since step 4.3 (the Wily castle).
- [x] **5.6 — Bank `$0D`.** Done, 100% source: the Wily Machine fight (48 runs
  it as a state chain; 49 lower cannon, 50 flying head, 51 cannon shot Mirror
  Buster returns, 52 spiked wheel), Quick Man and his boomerangs, the teleporter
  lights and the sign. The Wily Machine room's tiles are bank `$0D`'s own.
  **Phase 5 is complete.** Original text: Bank `$0D` (9-entry jump table, 9 KB of
  content; the object library is already done).

Each of these is several sessions. Split by entry-table entry: take three or four
entries, trace each one to its end, name them, commit. The entry table gives natural
seams that a fresh session can pick up from.

---

## Phase 6 — Audio engine writeup

The code is done; what is missing is the analysis.

- [x] **6.1 — `docs/AUDIO.md`.** Document the command/event language, the slot and
  priority system, and the RAM layout, from `audio/bank02.asm`. *Done 2026-10-09;
  `tools/audiodump.py` walks every sound in both banks. Two bugs found for 6.2:
  Wily 1's channel-1 loop offset overflows (confirmed by Will), and the
  free-track priority lookup reads slot 4's busy flag. AUDIO.md's last section
  lists the leads for 6.2-6.4.*
- [x] **6.2 — Catalogue the anomalies.** Vibrato is non-functional; there are other
  broken or vestigial features. Write down, for each, the exact routine and the
  reason it does not work. *Done 2026-10-09: [AUDIO_ANOMALIES.md](AUDIO_ANOMALIES.md).
  Four bugs with an effect on play, all reproduced in an emulator (PyBoy): the Wily 1
  loop, the slot-4 priority lookup, settings inherited between sounds (the boss
  theme's rests are twice as loud after Ice/Fire Man as after Cut Man), and stale
  repeat counters (a cut-off `SFX_Wheel` replays short). Vibrato would write to the
  wrong registers even if it were called. At Will's request, the misleading audio
  labels were renamed in both banks (table at the end of AUDIO.md).*

- [x] **6.3 — Test the "it should have fit in one bank" claim.** *Done 2026-10-09
  (AUDIO.md §10). Will's point was efficiency, not one bank: ~7.1 KB (driver,
  tables, all effects, Boss, Victory) is stored twice; everything together is
  ~21.2 KB, so it would not fit one bank as encoded, but the unused one-byte note
  mode could have saved up to ~3 KB. MM2/MM3 comparison not done (no ROMs).*

- [x] **6.4 — The conditional flags (`CondFlag1`/`CondFlag2`, `$C131`/`$C132`).**
  *Done 2026-10-09 (AUDIO.md §2).* Not "conditional flags": a lock on the per-frame
  audio update and its saved copy, renamed `wAudioLock`/`wAudioLockSave`. VBlank
  takes it around `PlayAudio`; driver entry points save/take/restore it so the
  update can't run on half-changed tables; bank `$01` holds it through the
  stage-intro sequence and the weapon-get screen and pumps the update itself
  (`RunAudioUpdate`, `$0405`), so the music keeps going there. Emulator: the main
  loop takes over one-for-one in the intro, and in 6,000 frames of play with 437
  sound loads the lock never caught a VBlank. Also named `DrainSoundQueue`,
  `PickQueuedSound`, `StartPickedSound`, `StopAllButMusic`, `wQueuedSoundPtr`,
  `wMusicSlot`.

---

## Phase 7 — Finishing

- [x] **7.1 — Eliminate every `INCBIN "baserom.gb"`.** Done: the `$04`/`$05`
  filler is `uninit_fill` (`macros/filler.inc`, a 32-byte `$00`/`$FF` alternation keyed
  on address bit 5) plus ten stray `db`s. Coverage **100.00%**. The base ROM is still
  read by the three `freespace` calls (7.2) and by `./build.sh`'s compare.
- [x] **7.2 — Replace all `freespace` calls with explicit `ds` fills**, and delete
  the macro. Done: banks `$02`, `$0A`, `$0F` end in `ds $8000 - @, $FF`; the macro
  is gone and no source file reads `baserom.gb`.
- [x] **7.3 — Rename every remaining `Func_BB_AAAA`.** Split per bank; a routine
  whose purpose is still unclear keeps its provisional name with a comment.
  - [x] **7.3a — bank `$00`** (109 labels): 73 renamed, 36 made local or dropped.
    No `Func_00_` label is left. 138 remain elsewhere.
  - [x] **7.3b — bank `$01`** (47): all renamed, none kept provisional. No
    `Func_01_` label is left; 91 remain (`$09` 46, `$03` 20, `$0D` 14, `$0E` 6,
    `$0B` 4, `$0C` 1).
  - [x] **7.3c — bank `$09`** (46): all renamed, none kept provisional, none could
    become local. No `Func_09_` label is left; 45 remain (`$03` 20, `$0D` 14,
    `$0E` 6, `$0B` 4, `$0C` 1).
  - [x] **7.3d — the rest** (45: `$03` 20, `$0D` 14, `$0E` 6, `$0B` 4, `$0C` 1): all
    renamed, none kept provisional. **No `Func_BB_AAAA` label is left in the
    source.** Still provisional by design: the object library's two
    `ObjLibFunc_000`/`ObjLibFunc_08D` (named by library offset, both fully
    commented; named in 7.5) and the `Data_`/`Frame_`/`FrameTable_` data labels
    (still provisional after 7.5 - see "After the plan").
- [x] **7.4 — Drop `rgbfix` from the build** by putting the real header bytes
  (logo, title, checksums) in source. Logo, title, licensee, type, sizes and
  destination were source since 2.2; now the header checksum (`$014D`) is computed
  by the assembler from the header fields (so edits to them stay bootable) and the
  global checksum (`$014E`, checked by no Game Boy) is written out as `$C25B`.
  `build.sh` and `make.bat` no longer call `rgbfix`.
- [x] **7.5 — Final pass.** Done (2026-10-10):
  - the library's two provisional labels named: `ObjGetPlayerZoneX` (was
    `ObjLibFunc_000`: which of four zones Mega Man's X is in, relative to the
    object and a half-width at offset `$34`) and `ObjCheckPlayerWithinX` (was
    `ObjLibFunc_08D`: is he within E px on side D), both `;[ok]`;
  - `docs/FORMATS.md`: every data format in one place, linking to LEVELS.md and
    AUDIO.md for the long ones;
  - a complete RAM map: `tools/rammap.py` reads the source as rgbasm does and lists
    all 586 RAM addresses the code refers to (247 named or inside a named block,
    339 not), with uses, banks, routines and what the source's comments say;
    `docs/RAMMAP.md` rebuilt around it. The step-1.2 lead `$CD25` was a byte-scan
    false positive (`call $2521` + `call`);
  - build badges in README.md, and `build.sh` now checks the output's SHA-256 when
    there is no `baserom.gb`, so `.github/workflows/build.yml` can verify the build
    on GitHub without the ROM (the live Actions badge needs the repository's URL);
  - BANKS.md: free space per bank and what a bank-`$0F` expansion could do with
    the existing banked routes (object types, stages, bank-`$01` callbacks).

  **Phase 7 is complete, and with it the plan.**

## After the plan

Optional, in no order - none of it changes what the ROM assembles to:

* Name the `Data_`/`Frame_`/`FrameTable_` labels in the object banks (animation
  records and frame tables; FORMATS.md has their formats).
* Name the most-used unnamed RAM (`tools/rammap.py --unnamed`), where the source
  comments already say what an address is.
* The open questions carried forward in the project's plan document and the
  PROGRESS.md log (e.g. what B = 0 from a boss init does, `$DF96`'s bit layout).

---

## Sizing note

Real content is 194 KB (61.8 KB of the ROM is padding). Phase 0 covered 32.4 KB of
it. The remaining ~162 KB, at the 1.5–2.5 KB per session that careful, named,
round-tripped disassembly actually takes, is on the order of 70–100 sessions for a
complete job — less if the data banks turn out to be large regular tables, which
several of them look like. Phases 1–4 are where almost all of the *understanding*
lives; Phase 5 is the long grind.
