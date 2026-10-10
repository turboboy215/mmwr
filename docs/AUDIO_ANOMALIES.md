# Audio anomalies

What is broken, half-built or left over in the sound driver and its data, with
the exact place and the reason for each. Step 6.2 of [PLAN.md](PLAN.md). How the
driver is meant to work is in [AUDIO.md](AUDIO.md); section numbers (§) refer to
it. Addresses are bank `$02`'s; bank `$0A` has the same driver 14 bytes later.
Labels are the post-6.2 names (old names in AUDIO.md, "Labels renamed in 6.2").

**How each item was checked.** *Code*: read in `audio/bank02.asm`. *Data*: counted
over every sound in both banks with `tools/audiodump.py`. *Emulator*: reproduced in
PyBoy 2.8.1 by loading `baserom.gb`, waiting 200 frames on the title screen, and
poking the sound queue (`wSoundQueue`, `$D920`) or `wAudioBank` from Python. The
emulator scripts are summarised under each item so they can be rerun. Will's
confirmations are by ear on real play.

| # | What | Heard in play? | Checked by |
|---|---|---|---|
| A1 | Wily 1's channel-1 loop jumps into another channel's data | **yes** (Will) | data, emulator |
| A2 | While slot 4 is busy, sounds that need a free track are refused | when 4 sounds play at once | code, emulator |
| A3 | Sounds inherit settings from the previous user of a track RAM; the boss theme's rests depend on the stage | **yes** (rest volume 3 vs 6) | code, data, emulator |
| A4 | Repeat counters survive a cut-off sound; the next one repeats too few times | when an effect is cut mid-repeat | code, emulator |
| B1 | Vibrato is never run, and its output step could not work | no | code |
| B2 | `LoadSong`'s loop-forever flag is overwritten | no | code |
| B3 | One-byte ("automatic length") mode is broken | no (never used) | code |
| B4 | Channel 1 is muted for one frame after each `InitAudio` | barely | code, emulator |
| B5 | `NR52` is read and the result thrown away | no | code |
| B6 | `F9` (length) can never take effect | no | code, data |
| B7 | Events the data uses on channels that ignore them | no | data |
| B8 | Random mode would advance the game's RNG from inside VBlank | no (never used) | code |
| B9 | Some writes bypass the channel stacks | no (latent) | code, emulator |
| C | Dead code, dead tables, unused commands and RAM | – | code, data |
| D | Data oddities: envelope sequences made of waveform bytes, jingles on effect tracks | – | data |

---

## A. Bugs with an effect on play

### A1. Wily 1's loop overflows the jump range

* **Where:** `Audio1_Wily1C1`, the last command, `$02:70AD`: `B0 59`.
* **Why:** jump offsets are a signed byte counting **words** from the jump command
  (§6). Channel 1 has to go back 167 words to `$6F5F`, where its first `A1` loop
  also points. −167 is out of range and was stored as `$59` (−167 + 256 = +89), so
  the loop goes **forward** 89 words to `$715F`. That is an odd address in the middle
  of channel 2's track, so channel 1 reads channel 2's bytes out of step.
* **What plays (emulator):** the song started with `wAudioBank`=2 and queue ID `$22`,
  following `Mus1`'s pointer (`$DB47`) every frame.
  * 0 – 38.6 s: normal.
  * 38.6 s: the jump. The misread pairs are almost all rests of 57 ticks (on a tone
    channel `$0x` is a rest), with one low E (`14 39`, E2). A rest retriggers at the
    rest volume (`EnvRest` 3, falling envelope), so you hear one loud E and then a
    faint E blip about every 2.9 s.
  * About 116 s: channel 1 reaches channel 3's track (the wave bass) exactly in step
    at `$7193` and **doubles the bass line on pulse 1** from then on. It skips that
    track's `F2 01` (waveform), which channel 1's table ignores.
* **Uniqueness:** every jump in both banks was checked; this is the only one whose
  target lies outside its own track. The stray `D6` and `9x` that `audiodump.py`
  reports for bank `$02` are bytes on this path.
* **Will:** confirmed by ear that the theme's loop is wrong.
* **Fix, for a romhack (not this disassembly):** the loop can't be expressed as one
  `B0` jump. Two `B0` jumps chained through a midpoint would do it.

### A2. Slot 4's busy flag blocks sounds that need a free track

* **Where:** `Audio1_LoadChPriorityVals`, `$4175`: `ld hl, SoundPriorities-1`
  `/ add hl, bc`, with C = `TrackSlots[track]`.
* **Why:** the check asks "is this track RAM owned by a sound of higher priority?"
  by reading the owner's priority. When the track RAM is free, its owner is 0, and
  `SoundPriorities-1+0` is the byte before the table: `SoundSlots+3`, **slot 4's busy
  flag**. When slot 4 is busy that byte is `$FF`, higher than any priority, so the
  load is refused even though the track and a slot are free.
* **Emulator:** UFO (`$01`, loops), Door2 (`$0D`), Wheel (`$11`) queued at frames 0,
  3 and 6 fill slots 2, 3 and 4 (title music has slot 1). Door2 ends at frame 10,
  freeing slot 3. `SFX_Empty2` (`$14`), which needs the free `SFX2` track, is queued
  at frame 20: **refused** (`TrackSlots` unchanged). The same run without the Wheel
  loads it into slot 3.
* **When it bites:** only while four sounds are playing: the music plus three
  effects that use different track RAMs. An effect that shares a track RAM with a
  lower-priority one still works, because that track RAM has an owner. How often
  this happens in a stage hasn't been measured.

### A3. Sounds inherit settings from whatever last used their track RAM

* **Where:** `Audio1_InitTrackVars` (`$4C63`) resets only start pointer, transpose,
  volume, gate, delay, envelope-sequence speed and counter, two vibrato fields, pan,
  envelope sequence (off), `$53` and NRx2. **Not reset:** `EnvRest` (`$09`), envelope
  sweep (`$14`), duty and length (`$54`), waveform number (`$07`), random mode
  (`$06`), the `$21` length mode, and all repeat state (`$22`-`$52`, see A4).
* **Why it matters:** a sound that uses a field before setting it gets the previous
  user's value. Of the fields that matter, `EnvRest` is used by every rest and, with
  an envelope sequence and a gate, by every release. The envelope sweep is used by
  every note without a sequence. Tracks that use one before setting it (first pass,
  same in both banks unless noted):

  | Sound | Track | Uses unset | Typically follows |
  |---|---|---|---|
  | Boss ch1, ch2 | `Mus1`, `Mus2` | `EnvRest` (8 rests, 4 releases) | a stage theme |
  | Boss ch4 | `Mus4` | sweep (1 rest) | a stage theme |
  | Victory ch1, ch4 | `Mus1`, `Mus4` | sweep (34 notes, 7 rests) | Boss |
  | EndGameAlt ch4 (`$02`), EndGame ch4 (`$0A`) | `Mus4` | sweep and `EnvRest` | – |
  | Title ch3 (`$0A`) | `Mus3` | `EnvRest` (wave volume of a rest) | – |
  | SFX_Explode ch2, SFX_CutAttack ch1 | `SFX2`, `SFX3` | `EnvRest` (rests) | any effect |
  | SFX_Land ch1 | `SFX1` | `EnvRest` (releases) | any effect |
  | SFX_Empty2 ch4, SFX_FireAttack ch4 | `SFX2`, `SFX4` | sweep | any effect |
  | StageStart ch4, GetWeapon ch4 (`$0A`) | `SFX4` | `EnvRest` (5 rests each) | any effect |

* **Audible case: the boss theme's rests.** The riff on channels 1 and 2 plays rests
  (`00 01`) with no `FD` of its own, so their volume is whatever the stage theme
  left in `Mus1`/`Mus2`. The stage themes use `FD 3` or `6` (Cut Man), `6` (Ice and
  Fire Man), `6`-`8` (Elec Man), `1`/`3` (Wily). **Emulator:** stage theme for 300 to
  1500 frames, then Boss (`$19`), reading the `NR12` shadow. After Cut Man the rests
  come out at `$33` (volume 3); after Ice Man and Fire Man at `$63` (volume 6), and
  by its data the same after Elec Man (not run). So the boss theme's staccato is
  twice as loud in Ice, Fire and probably Elec Man's stages as in Cut Man's. Cut
  Man's theme also uses `FD 6` in places, so its value depends on where the music
  was when the boss door opened; both emulator runs (300 and 1500 frames) left 3. Victory
  always follows Boss, so its inherited sweep is always Boss's (`FB 3` on ch1).
* **Will to check by ear:** the boss music's riff after Cut Man vs after Ice Man.

### A4. Repeat counters outlive a cut-off sound

* **Where:** the `Bx` counter `$22` and the `Ax`/`9x` slots `$23`-`$52` of a track RAM.
  `Audio1_StopSlot` and `InitTrackVars` don't clear them. A repeat that finishes
  normally clears its own state; a sound **stopped in the middle** of a counted
  repeat leaves it set.
* **Effect:** the next sound on that track RAM meets its first `Bx` with a non-zero
  counter and counts it down instead of loading its own count, so it repeats too few
  times. A stale `Ax` slot only matches the same address, i.e. the same sound
  restarted, with the same result. Stale `Ax` slots also use up the 8 available, and
  when all 8 are taken a repeat falls through without jumping.
* **Emulator:** `SFX_Wheel` (`$11`, `B2` on `SFX4`) alone: counter loaded at frame
  106, stops at frame 160 (body played 3 times). Cut off by `SFX_PlayerHit` (`$06`,
  priority 4, also `SFX4`) at frame 115, then replayed at frame 200: the counter is
  still 2, the body plays **twice**, and the sound ends **26 frames early**.
* **Sounds with counted repeats on effect tracks** (both banks): `SFX_Electricity`
  (`A8`, `B1`), `SFX_CutAttack` (`B3`; `A1`, `A3`), `SFX_Wheel` (`B2`), and in `$0A`
  `GetWeapon` (`A3`×2, `A6` on `SFX4`). Songs on `Mus` tracks are never cut by
  effects (§4), only replaced by another song, which also inherits.

---

## B. Driver defects without an audible effect

### B1. Vibrato: switched off, and broken underneath

* **Never run.** `Audio1_PlayAudio` (`$43F3`) calls `ProcSlots`, `ProcEnvSeqs` and
  `ProcRegs`. Nothing calls `Audio1_ProcVibSeqs` (`$4AB5`). The commands that set it
  up (`F7` sequence, `F6` wait, `EF` period) are accepted on channels 1-3, and no
  sound uses them (data).
* **Still set up on every note.** `ProcNoteParams` loads `VibTab[$15-1]` into the
  sequence pointer. The default sequence is 0, so it reads the word **before**
  `VibTab`: the last two bytes of `VibSeq0E` (`$00 $80`), i.e. pointer `$8000`. That is
  harmless only because nothing follows the pointer.
* **Could not work if called.** Its last step writes the new period to the address
  `PerAddrs[n]`, indexing the 4-entry table by **track number 0-7** (`CurEnvIndexTrack`),
  not by channel:
  * `SFX1`-`SFX4` get `NR13`, `NR23`, `NR33`, `NR43` whatever channel they play on. For
    example `SFX_Door2` plays `SFX3` on channel 1, so its vibrato would bend channel 3.
  * `Mus1`-`Mus4` read past the table into `ProcRegs`' code (`$4B50`: `3E FF EA B3 DC AF
    EA 78`) and write to `$FF3E` (the last two bytes of **wave RAM**), `$B3EA` and
    `$AFDC` (cartridge RAM, absent on this cart), and `$78EA` (the MBC1 mode
    register).

  It also writes the hardware directly, not the shadow, so a buried track's vibrato
  would bend the sound playing on top. Whether vibrato was disabled *because* of
  this is unknown `[?]`; the code shows only that it is disabled and wouldn't work.

### B2. `LoadSong`'s loop-forever flag is overwritten

* **Where:** `Audio1_LoadSong`, `$40DF`: `or a / jr nz / dec a / ld a, 1 / ld [PlayCount], a`.
* **Why:** entered with A=0 (as `NewGame` and the boss switch do), the `dec a` makes
  `$FF`, the play count for "replay forever" (`CheckChSlots` treats `$FF` as endless).
  The very next `ld a, 1` replaces it, so every sound plays once. `LoadSong` and
  `LoadSound` are therefore identical. Songs still loop, through their own `x=0`
  jumps.

### B3. One-byte ("automatic length") mode is broken

`EC` makes every following command one byte, with the parameter taken from the
last note's length (`$1D`). No sound uses it. If one did:

* **Jumps land a byte early.** `ContTrack` advances the pointer by 1, but the jump
  code (`.JumpBx_4`, `.JumpAx_7`, `.Jump9x_7`) subtracts 2 to get back to the
  command, so targets are off by one.
* **Events get the note length as their parameter.** `FE` would set the volume to
  the last length, and so on. Only `FF`, `E8`, `EB` and `EA`, which ignore it, work.
* **`E9` (call) is garbled:** its low address byte would be the length, not the
  next byte.

### B4. Channel 1 is muted for one frame after `InitAudio`

* **Where:** `Audio1_OutputAudio`, `$4BB0`. The first time channel 1's registers are
  written after `InitAudio` (which clears `Ch1MutedOnce`, `$D9DD`), it sets `CurPan` to
  `$EE`, which masks channel 1 out of that frame's `NR51`, then sets bit 4 of
  `$D9DD` so it never happens again until the next `InitAudio`.
* **Emulator:** at boot, the title music's first channel-1 write is on frame 84:
  `NR51` = `$EE` that frame and `$FF` from frame 85.
* **Effect:** the first 1/60 s of the first channel-1 note after each `InitAudio`
  (three calls, all in `engine/main.asm`) is silent. Why is
  unknown `[?]`. It may have been meant to avoid a click.

### B5. A discarded `NR52` read

`Audio1_OutputAudio`, after writing channel 3: `ldh a, [rNR52] / or %00000100 /
ld a, %10000000 / ldh [rNR30], a`. The read and OR are overwritten at once. It looks
like it meant to mark channel 3 as on, but `NR52`'s channel bits are read-only.

### B6. `F9` (length) can never take effect

`EventChanLen` writes the length timer into NRx1. The hardware only uses it when
NRx4 bit 6 is set, and that bit comes only from `$21` (`EE`, hardware-length mode,
`.GetCommand2`). No sound uses `EE`, so the 270 `F9` commands in the data (162 + 108)
do nothing.

### B7. Events the data uses on channels that ignore them

The per-channel event tables (§6) have holes. The data falls into them three times
outside A1: `F5` (sweep) on channel 2 in WilyIntro (both banks, `$02:7832`) and
StageSelect (`$0A`). Channel 2 has no sweep, so they are skipped. Harmless, and
probably copied from a channel-1 part.

### B8. Random mode would use the game's RNG

`EventRandomize` (`E7`) makes `RandomizeNote` run before every command, and it calls
`JumpRNG` → `FuncRNG`, the game's own generator (`wRNGIndex`/`wRNGSeed`). From the
VBlank update, that would advance the game's random sequence by however many
commands the music read that frame, and could interrupt a `FuncRNG` call already in
progress. No sound uses `E7`, so this never happens.

### B9. Writes that bypass the channel stacks

The channel stacks (§4) are supposed to decide who reaches the hardware, but some
writes skip them:

* `EventWaveform` (`F2`) loads wave RAM directly, even for a buried channel-3 track.
  `EventMasterVol` (`F1`) writes `NR50` directly. Harmless here: only waveform 1 is
  ever used, and `F1` never is.
* `EventStop` / `StopSlot` only mask the channel in `NR51` (`MuteChannel`); they don't
  silence it. If a track is left underneath, `ProcRegs` restores its pan bits on
  the next frame, but its registers are written only at its next trigger (a pending
  note, its next envelope step, or its next note). Until then whatever the effect
  left in the channel can be heard. In the one case tried (Shoot over the title
  music, emulator) the effect had already ended its own note, so nothing was heard.

---

## C. Dead code, dead data, unused features

| What | Where | Why it's dead |
|---|---|---|
| `GetSlot` entry | `$400C` in both banks, stub `AudioGetSlot` `$024A` | no caller |
| `CheckSlotVals` | `$42E2` | follows a `ret`; only its own loop jumps to it |
| `NRx2Vals`, `NRx4Vals`, `UnkVals` (`$FE $FD $FB $F7`) | `$4D29`, `$4D31`, `$4AB1` | unreferenced |
| Vibrato: `ProcVibSeqs`, `PerAddrs`, `VibTab`, 15 sequences | `$4AB5`-`$4B4F`, `$4EB5`-`$4F64` | see B1 |
| Slot 5-8 tempo pointers | `SpeedRAMSlots` | `CheckSlots` hands out 1-4 only |
| `StopAllButMusic` (`$083A`) | bank `$00` | no caller |
| Track fields `$13` (written, never read), `$20`, `$58` | track RAM | – |
| `UnkRAM1` `$D98D`-`$D9A7`, `UnkRAM2` `$D9A9`-`$D9DC`, `UnkRAM3` | audio RAM | no reference |
| `FreqTab` entries 84-89 (`$01DF`…) | `$4F96`+168 | only notes `$7C`-`$85` reach them; the data stops at `$72` |
| Envelope sequences 1-4, 6-11 | `EnvSeqs` | never selected (used: 5, 12-15) |
| Waveforms 0, 2-15 | `Waveforms` | every `F2` is `F2 01` |
| `Audio2_Empty` | bank `$0A` | no tracks, so always refused; fills the stage-theme slots |
| Commands never used | – | `F7`/`F6`/`EF` vibrato, `EE`, `EC`/`EB`, `EA`, `E9`/`E8` calls, `E7`, `F1`, `9x` (bar A1's path) |

The language supports subroutines, one-byte notes, random pitch, vibrato and
master volume, and the game's data uses none of them.

## D. Data oddities

* **Envelope sequences built from waveform bytes.** Sequences 5-9 are byte-for-byte
  the second halves of waveforms 5-9, and the waveform table is 248 bytes, its last
  8 bytes being sequence 0 (§7). Only sequence 5 (a falling saw) is used. The tables
  look like they were made from the same source data `[?]`.
* **Jingles on effect tracks at priority 0.** Bank `$0A`'s `StageStart` and
  `GetWeapon` use `SFX1`-`SFX4` with priority 0, the songs' priority. An effect still
  playing on any of those track RAMs (priority ≥ 1) makes the load fail (§4). `StageStart`
  is queued right after `AudioStopAll` (stage select), so it is safe. `GetWeapon`
  is queued on entering the weapon-get screen with no stop first; whether an effect
  can still be holding an `SFX` track then hasn't been checked.
* **Cue values.** `E6` posts `$E1` (Victory ch4, WilyIntro ch1) and `$E4`
  (StageStart ch1). The castle cutscene waits for `$E1`. Who, if anyone, reads `$E4`
  is open.
