# The audio driver

How the sound driver in `audio/bank02.asm` works: its interface to the game, the
slot / track / channel / priority system, the timing model, the command language
the songs are written in, and the RAM it uses. Step 6.1 of [PLAN.md](PLAN.md).

The source is Will Trowbridge's audio disassembly, and most labels are his. Those
that described something the code doesn't do were renamed in step 6.2; the old
names are listed under [Labels renamed in 6.2 and 6.4](#labels-renamed-in-62-and-64). What is broken or
vestigial in the driver and the data is catalogued in
[AUDIO_ANOMALIES.md](AUDIO_ANOMALIES.md). Addresses are bank `$02`'s. Confidence tags as
in [CONVENTIONS.md](CONVENTIONS.md): everything here is `[ok]`, read from the code
and, for the "used by the data" columns, counted by `tools/audiodump.py`, unless
it says otherwise.

```
python3 tools/audiodump.py baserom.gb               what both banks' data uses
python3 tools/audiodump.py baserom.gb --headers     every SoundTab entry: tempo, priority, tracks
python3 tools/audiodump.py baserom.gb --uses F5     where a command appears
```

## 1. Two banks, one driver

Banks `$02` and `$0A` each hold a complete copy of the driver followed by their own
sound data. **The two drivers are the same source.** With the labels normalised
(`Audio1_`/`Audio2_`), lines 82-3410 of `bank02.asm` and 93-3421 of `bank0a.asm`
differ only in two local label names. Bank `$0A`'s copy sits 14 bytes later because
it has an extra 14-byte empty song header (`Audio2_Empty`) right after its
SoundTab. The tables (waveforms, envelope sequences, vibrato, noise, frequencies)
are identical too. `wAudioBank` (`$DF9A`) picks the bank, and every call goes
through it (see [BANKS.md](BANKS.md)). How much this duplication costs is step 6.3.

| Bank `$02` | Size | What |
|---|---|---|
| `$4000`-`$4014` | 21 | seven `jp` entry points |
| `$4015`-`$4076` | 98 | `Audio1_SoundTab`: 49 sound pointers |
| `$4077`-`$4D3C` | ~3.2 KB | driver code |
| `$4D3D`-`$4FFF` | ~700 | tables: waveforms, envelope sequences, vibrato, noise, frequencies |
| `$5054`- | | sound data (headers + tracks) |

## 2. The interface

### Entry points

| Addr | Label (stub in bank `$00`) | What it does |
|---|---|---|
| `$4000` | `InitAudio` | Reset the APU (`NR52`=`$80`, `NR50`=`$77`, `NR51`=`$EE`, NRx2/NRx4 defaults) and zero `$D936`-`$DCBD`: all driver RAM, plus the game's pending-sound pointer and music-slot byte (below). |
| `$4003` | `StopRequestedSlot` (`AudioStopSlot`) | Stop the one slot whose number is in `wAudioStopSlot` (`$CC4A`). Does nothing if that is 0. |
| `$4006` | `LoadSound` | Start the sound whose header is at HL (in this bank). Returns the slot (1-4) in A with Z clear, or carry if it was refused. |
| `$4009` | `LoadSong` | Same as `LoadSound`. Entered with A=0 it was meant to make the sound loop forever, but `ld a,1` overwrites that value (`$40DF`), so both entries behave identically. |
| `$400C` | `GetSlot` | A = `SoundSlots[A-1]`: non-zero if slot A is busy. No caller anywhere in the ROM. |
| `$400F` | `PlayAudio` | The once-per-frame update. |
| `$4012` | `StopAllSounds` (`AudioStopAll`) | Stop slots 1-4, i.e. **all** sound, music included. |

The game reaches them through the seven `rst $08` stubs at `$0236`
([engine/audio_interface.asm](../engine/audio_interface.asm)). The one
exception is the VBlank handler, which pages the bank in and calls `$400F` itself.

### How the game plays a sound

There are two routes.

* **Sound effects and jingles go through a queue.** `QueueSound` (`$03CD`) appends
  an ID to `wSoundQueue` (`$D920`: a count plus up to 20 IDs). An ID is the SoundTab
  index plus one, and 0 means "nothing". Once per frame, `DelayFrame` → `DrainSoundQueue` (`$03E4`) empties
  the queue. For each ID, `PickQueuedSound` (`$07DD`) looks the header up in the current audio bank
  (`$4013 + 2*ID`) and keeps the pointer in `wQueuedSoundPtr` (`$D936`) **if its priority (header
  byte 1) is at least the one already kept**. Then `StartPickedSound` (`$0826`) calls `LoadSound` on the
  winner and clears the pointer. So whatever is queued in a frame, **only one sound
  starts**: the highest-priority one, with the later of any tie winning.
  `wQueuedSoundPtr` sits inside the driver's RAM block, so `InitAudio` clears them.
* **Music is loaded directly.** `NewGame`, the boss fight switch and `BossDefeated`
  call `LoadSong`/`LoadSound` with a header pointer fetched through
  `AudioSoundTabPtrs`, and store the returned slot in `wMusicSlot` (`$DCBC`).
  When Mega Man dies, `wMusicSlot` is copied to `wAudioStopSlot` and `AudioStopSlot` stops just the
  music, letting the death sound play out.

`StopAllButMusic` (`$083A`) loops `wAudioStopSlot` over 1-9 and calls `AudioStopSlot` for every slot except
`wMusicSlot`, then empties the queue. No `call` or `jp` to it
exists. It is listed here and not yet in [UNUSED.md](UNUSED.md).

### Calling the update: the audio lock (`wAudioLock`, `$C131`; step 6.4)

`$C131`/`$C132` were Will's `CondFlag1`/`CondFlag2`. They are a **lock on the
per-frame update** and its saved copy, now `wAudioLock`/`wAudioLockSave`. Every
reader and writer in the ROM (7 in bank `$00`/`$01`, 15 in each audio bank, found by
byte search as well as in source):

* **VBlank** (`$06B3`): runs `PlayAudio` only if `wAudioLock` is 0, sets it to `$FF`
  around the call and clears it after. It re-enables interrupts *before* calling, so
  a VBlank that arrives during a long update finds the lock and skips. It doesn't
  run the update a second time on top of the first.
* **Driver entry points that change state** (`InitChan` (so `InitAudio`), `LoadSong`/
  `LoadSound`, `StopSlotLocked` (so `StopRequestedSlot` and `StopAllSounds`)): save the
  lock in `wAudioLockSave`, set `$FF`, and restore the saved value on the way out. So
  a VBlank arriving while the main code is half-way through loading or stopping a
  sound skips the update, and doesn't run it on half-changed tables. Restoring
  rather than clearing keeps a lock that bank `$01` is holding. One save slot is
  enough: none of these routines calls another of them (`LoadSong` evicts with
  `StopSlot`, which doesn't touch the lock).
* **Bank `$01`** (`StageSelect` after a stage is picked: the scroll, starfield and boss
  name, `$61F7`-`$62C8`; and `WeaponGet`, `$62EC`-`$63C4`): sets the lock to `$FF` and
  calls `RunAudioUpdate` (`$0405`: page in the audio bank, `call $400F`) once per loop
  iteration, then clears the lock on the way out. VBlank skips; the music is pumped
  from the main loop.

**Emulator (PyBoy), counting the VBlank check at `$06B3` and calls to `$400F`:**

| Screen | Frames | VBlank ran the update | VBlank skipped | `RunAudioUpdate` calls |
|---|---:|---:|---:|---:|
| boot and title | 400 | 317 | 0 | 0 |
| stage select | 180 | 180 | 0 | 0 |
| after picking Cut Man: intro sequence | 660 | 349 | 299 | 299 |
| Cut Man's stage, firing every 8 frames (437 sounds loaded) | 6,000 | 6,000 | **0** | 0 |

So during the intro the main loop takes over one-for-one and the music keeps its
rate. In play, the lock **never** caught a VBlank in 6,000 frames: sounds are loaded
by the queue drain at the start of `DelayFrame`, far from VBlank. It's a safety
measure that, as far as this test shows, only matters when bank `$01` takes it on
purpose. (The boot frames with no update are frames when VBlank doesn't run the
handler's audio part at all, e.g. with the LCD off during loads.) Why bank `$01`
pumps the audio itself on those two screens, rather than leaving it to VBlank, is
not visible in the code `[?]`.

## 3. Sounds

### SoundTab and IDs

`SoundTab` (`$4015`) holds 49 pointers to sound headers. Index *n* is queue ID
*n*+1. The first 20 entries and several later ones are the same SFX in both banks.
The music entries differ (bank `$02` has the stage themes, bank `$0A` the menus,
ending and jingles), and the slots a bank doesn't use point at a filler song
(`$0A`'s `Audio2_Empty`, which has no tracks and so is always refused) or fall
through into a neighbour (bank `$02`'s `DoNotUseNN`). `--headers` lists them all.
[UNUSED.md](UNUSED.md) covers the orphans.

### Header

```
db tempo        frames per tick, minus one
db priority     0 for every song, 1-11 for effects (PlayerExplode = 11, the highest)
dw track1  db n1    channel 1 (pulse 1 + sweep)
dw track2  db n2    channel 2 (pulse 2)
dw track3  db n3    channel 3 (wave)
dw track4  db n4    channel 4 (noise)
```

**A header entry's position is its hardware channel.** The byte after each pointer
picks which of the eight **track RAMs** runs it: 0-3 = `SFX1`-`SFX4`, 4-7 =
`Mus1`-`Mus4`. A null pointer leaves that channel out; the track byte is still
present. Track RAM and channel are independent. `SFX_Door2` plays track `SFX3` on
channel 1, `SFX_CutAttack` plays `SFX3` on channel 1 and `SFX2` on channel 4, and
`SFX_Wheel` plays `SFX4` on channel 1. Every song uses `Mus1`-`Mus4` on channels 1-4
in order. The jingles `StageStart` and `GetWeapon` (bank `$0A`) are the exception:
they are priority-0 songs written on `SFX1`-`SFX4`.

## 4. Slots, tracks, channels and priority

There are three layers.

* **Slots (4): one per sound that is playing.** `SoundSlots` holds busy flags, and
  `SoundPriorities` holds each slot's priority. Each slot has its own tempo
  state (play count, tempo, tick counter: `Slot1SpeedRAM`…). The update copies it
  into `MasterSlot*`, runs the slot, and copies it back. The tables have room for 8
  slots, but `CheckSlots` only hands out 1-4.
* **Tracks (8): one per track RAM.** `TrackSlots[t]` is the slot that owns track
  *t* (0 = free). `TrackPlaying[t]` is `$FF` while it is playing.
* **Channels (4): one per APU channel.** `Ch1IDRAM`-`Ch4IDRAM` are 4-entry stacks of
  track numbers (1-8), sorted by priority, highest first. **Only the top track of a
  stack reaches the hardware.** The tracks underneath keep running in silence and
  stay in time.

Loading a sound (`LoadSong`, `$40DF`):

1. **Track ownership** (`LoadChPriorityVals`, `CheckPriorities`). If any track RAM the
   new sound names is owned by a slot of *higher* priority, the load is refused
   (carry). **Bug:** for a track RAM nobody owns, the owner is 0, so the lookup
   `SoundPriorities-1+0` (`$4175`) reads the byte before the table, which is slot 4's
   busy flag. So **while slot 4 is busy, any sound that needs a free track RAM is
   refused.** That byte is `$FF` when busy and beats every priority. Confirmed in an
   emulator ([AUDIO_ANOMALIES.md](AUDIO_ANOMALIES.md) A2). Otherwise every slot that owns one of those track RAMs is stopped
   **whole** (`StopSlot`), even if it shares only one track with the new sound. A
   sound with no tracks is refused.
2. **A free slot** (`CheckSlots`). If all four are busy, the load is refused. It
   does not evict anything.
3. **Set-up** (`InitSlot`, `GetChannelPtrs`, `SetupChan`). The slot is marked busy
   and gets its priority. Its tempo state is set to (tempo+1, tick counter 1, play
   count `PlayCount`=1). Each track gets its start pointer, channel, owner and
   play-flag 0, and is inserted into its channel's stack (`CheckIDs`): it goes
   above every entry of equal or lower priority, so **among equals the newest
   wins**. If the stack has no room the track is still started, but it never sounds.

The tracks don't start yet. On the slot's first tick `CheckChSlots` finds none
playing, sees play count 1, counts it down to 0, and initialises every track
(`InitTrackVars`). When every track of a slot has hit `FF` and the play count is 0,
the slot is freed (`StopSlot`). A play count of `$FF` would replay the sound forever.
Nothing can set that (see `LoadSong` above), so songs loop with an unconditional
jump and never end on their own.

**Stopping** (`StopSlot`, `$4341`) clears the slot and each of its tracks, and takes
each track off its channel stack (`RemoveTrackFromChannel`/`CheckTrackVar`, which checks channels
in the order 1, 2, 4, 3). If the track was on top, the channel is muted in `NR51`
straight away. For channel 3, if a track is left underneath, that track's waveform
is reloaded into wave RAM. Nothing retriggers the uncovered track, so it is heard
again only from its next note.

In practice: songs (priority 0, `Mus` tracks) and effects (1-11, `SFX` tracks) never
share track RAM, so effects never evict music. They just sit above it on the
channel stacks. Effects evict each other by track RAM, and only when the newcomer's
priority is at least the incumbent's.

## 5. Timing

`PlayAudio` (`$43F3`) runs once per frame:

1. `ProcSlots`: for each busy slot (1→4), count its tick counter down. When it
   reaches 0, reload it with tempo+1 and run one **tick** of each of the slot's
   playing tracks.
2. `ProcEnvSeqs`: step the envelope sequences of all 8 tracks. This runs **every
   frame**, not every tick.
3. `ProcRegs`: write the hardware registers and `NR51`.

So a header tempo *t* means one tick every *t*+1 frames: tempo 0 is 60 ticks a
second, and Wily 1's tempo 2 is 20.

On each tick a track (`CheckNoteDur`, `CheckDelay`):

* Counts down its **gate** (`$0B`) unless hardware-length mode (`$21`) is on. When the
  gate reaches 0 it sets the envelope-sequence counter to 1, so the release level
  applies on the next frame.
* Counts down its **delay** (`$0C`). When that reaches 0 it reads commands until it
  reaches a note or rest, which sets a new delay.

A note's parameter is its **length**, the number of ticks until the next command (0
gives 256). The gate is length − `F8`, but at least 1. `F8` is only ever 0 or 1 in
this game.

## 6. The command language

A track is a stream of **two-byte commands**, `cc pp`, read by `ContTrack`/`GetCommand`
(`$448A`). The exceptions are `E9` (three bytes), `EA` and `EC` (one byte each), and
anything read while automatic length is on (one byte, see `EC`).

| Byte | Meaning |
|---|---|
| `$00`-`$0F` | rest (channels 1-3: the low nibble is ignored) |
| `$10`-`$8F` | note (channels 1-3); on channel 4 every byte `$01`-`$FF` below `$90` is a noise index |
| `$90`-`$9F` | jump on the last pass (9x) |
| `$A0`-`$AF` | repeat, nestable (Ax) |
| `$B0`-`$BF` | repeat, single level / loop (Bx) |
| `$C0`-`$E5` | ignored: the parameter is consumed, nothing happens (`$47A2` returns) |
| `$E6`-`$FF` | events, dispatched through a per-channel table (`$47CE`) |

### Notes and rests

* **Pitch.** For a note `$hl`, the index is (h−1)·12 + l, plus the track's signed
  transpose (`$05`, in semitones). It looks up `FreqTab` (`$4F96`): 84 periods for 7
  octaves from `$10` = C2 (`$002C`, 65.4 Hz) up, then 6 more values (`$01DF`…) that
  only notes `$7C`-`$7F` and `$80`-`$85` could reach. The data never goes above `$72` or uses a low
  nibble of 12 or more.
* **Noise** (channel 4): the byte indexes `NoiseVals` (`$4F65`, 49 `NR43` values,
  1-based). 0 is a rest. Both banks use indices 2, 3, 32, 36-40 and 42-49.
* Every note and rest sets the trigger bit of the NRx4 shadow (`$57`), plus the
  length-enable bit if `$21` is set, and loads the starting volume. A note uses
  `Env` (`$08`); a rest uses `EnvRest` (`$09`), and its gate is 0. **So a rest
  retriggers the channel at the rest volume.** It isn't silence unless `EnvRest`
  is 0, which is how the songs get echoes.

### Jumps and repeats

The offset `yy` is a signed count of **words**, from the address of the jump command
itself: target = addr + 2·`yy`. So a jump reaches at most 128 words (256 bytes)
back. With x = 0, all three kinds jump unconditionally; that is how songs loop.

| | First time reached | Later times | Effect with x = n |
|---|---|---|---|
| `Bx yy` | store n in `$22`, jump | count down; jump while not 0 | body played n+1 times. One counter per track, so not nestable. |
| `Ax yy` | store n in a free one of 8 (address, count) slots at `$23`/`$33`, keyed by the command's address; jump | count down; jump while not 0, then free the slot | body played n+1 times; nestable 8 deep. If all 8 slots are taken, it falls through without jumping. |
| `9x yy` | store n in its own 8 slots (`$3B`/`$4B`); **don't** jump | count down; jump when it reaches 0 | jumps on pass n+1: a "skip to the ending on the last time round" |

`9x` is never used legitimately. The one place the walker meets it, `$7191`, is in
the misaligned bytes described next.

**The range limit is hit once, in Wily 1** (bank `$02`, channel 1, `$70AD`: `B0 59`).
The loop needs to go back 167 words to `$6F5F`, where channel 1's first `A1` loop
also points. −167 doesn't fit in a signed byte and wraps to `$59`, +89. So after its
first pass (768 ticks at tempo 2, **about 38.6 s into the stage**), pulse 1 jumps
*forward* to `$715F`. That address is odd and in the middle of channel 2's data, so
the pulse channel reads channel 2's bytes out of step:

* 24 pairs that are almost all rests of 57 ticks (`04 39`, `0C 37` …: `$0x` is a rest
  on a tone channel), with one low E (`14 39`) among them. Because a rest retriggers
  at the rest volume (3 here, falling), what you hear is one E at full volume and
  then a faint E blip about every 2.9 s for about 70 s;
* a stray `D6` (ignored) and `97 FF` (a 9x that never fires);
* then, at about **116 s**, it runs into channel 3's track (the wave bass) exactly in
  step at `$7193`. That track's `F2 01` (waveform) does nothing here, because
  channel 1's table has no `F2`.

From then on pulse 1 **doubles the bass line** for as long as the stage lasts.
Will has confirmed by ear that the theme's loop is broken, and the timings above
come from playing the song in an emulator and following channel 1's pointer. This is the only jump
in either bank whose target falls outside its own track
(checked for every jump by the walker). The bank `$02` counts below include the
`D6`, `9x` and channel-1 `F2` that this path produces.

### Events (`$E6`-`$FF`)

The dispatcher inverts the command byte to index a 26-entry table, one table per
channel. A 0 entry means the command is ignored on that channel (the parameter is
still consumed). The used columns count both banks (`$02` / `$0A`).

| Cmd | Param | Label | What it does | Ch | Used |
|---|---|---|---|---|---|
| `FF` | – | `EventStop` | End the track: play flag 0, trigger flag 0, `Env`=0, and mute the channel in `NR51` (`MuteTrackChannel`→`MuteChannel`). | 1234 | 43/47 |
| `FE` | `-v` | `EventEnv` | Note volume / envelope start level, 0-F (`$08`). | 1234 | 404/289 |
| `FD` | `-v` | `EventEnvRest` | Volume used by rests and, with an envelope sequence, the release level after the gate (`$09`). | 1234 | 67/53 |
| `FC` | `-n` | `EventEnvSeq` | Envelope sequence n (0 = off) (`$0D`). See §7. | 1234 | 86/67 |
| `FB` | `-p` | `EventEnvSweep` | NRx2 low nibble (direction + pace) when no envelope sequence is active (`$14`). Only decreasing values 0-6 are used. | 12-4 | 203/144 |
| `FA` | `nn` | `EventEnvSpeed` | Envelope-sequence step, in **frames** (`$0E`, default 2). | 1234 | 43/31 |
| `F9` | `nn` | `EventChanLen` | Length timer. Channel 3: the whole byte goes to `NR31`. Others: low 6 bits into NRx1. Only matters if length-enable is on (`EE`), which nothing turns on, so **it never has an effect**. | 1234 | 162/108 |
| `F8` | `nn` | `EventNoteDur` | Gate shortening: gate = length − nn (`$0A`). | 1234 | 79/73 |
| `F7` | `-n` | `EventVibrato` | Vibrato sequence (`$15`). Its processing (`ProcVibSeqs`, `$4AB5`) is never called, so it does nothing. | 123- | 0/0 |
| `F6` | `nn` | `EventVibWait` | Vibrato start wait (`$16`). Never processed. | 123- | 0/0 |
| `F5` | `nn` | `EventSweep` | `NR10` sweep (`$53`). | 1--- | 46/46 |
| `F4` | `d-` | `EventDuty` | Duty, top 2 bits of NRx1 (00/40/80/C0 all used). | 12-- | 60/53 |
| `F3` | | – | none on any channel | ---- | 0/0 |
| `F2` | `-n` | `EventWaveform` | Load waveform n (16 bytes) into wave RAM, and remember n (`$07`) so `RemoveTrackFromChannel` can restore it. Only n=1 is ever used. | --3- | 11/9 |
| `F1` | `nn` | `EventMasterVol` | Write `NR50` directly. | 1234 | 0/0 |
| `F0` | `-p` | `EventPan` | Pan: bit 1 = left, bit 0 = right (3 both, 0 neither), shifted into place for the channel (`InitPan`, `$4CF5`). Stored per track; the default is 3. | 1234 | 63/7 |
| `EF` | `-n` | `EventVibPeriod` | Vibrato step period (`$18`). Never processed. | 123- | 0/0 |
| `EE` | `nn` | `EventHWLength` | Non-zero: hardware-length mode. Sets NRx4 bit 6 on each note and skips the software gate countdown (`$21`). Never used. | 1234 | 0/0 |
| `ED` | `nn` | `EventTranspose` | Signed transpose in semitones (`$05`). | 123- | 0/1 |
| `EC` | – | `EventAutoLenOn` | One byte. From here on every command is **one** byte, and its parameter is the length of the last note or rest (`$1C`/`$1D`). | 1234 | 0/0 |
| `EB` | (–) | `EventAutoLenOff` | Back to two-byte commands. In two-byte mode it wastes a parameter byte. | 1234 | 0/0 |
| `EA` | – | `EventDecTrackPtr` | Step the pointer back one byte. The effect: a one-byte no-op. | 1234 | 0/0 |
| `E9` | `lo hi` | `EventMacro` | Call: three bytes. Return address in `$1E`, one level only. | 1234 | 0/0 |
| `E8` | – | `EventMacroRet` | Return to `$1E`. | 1234 | 0/0 |
| `E7` | `nn` | `EventRandomize` | Non-zero: before **every command read**, pick a random (transpose, volume) pair from six fixed ones (`RandomizeNote`, `$49C1`, which calls the game's RNG through `JumpRNG`); 0 turns it off (`$06`). | 123- | 0/0 |
| `E6` | `nn` | `EventCue` | Write nn to `SongCue` (`$D9A8`). The driver never reads it: **it is a cue from the song to the game.** `$E1` is posted by Victory ch4 (both banks) and WilyIntro ch1 (`$0A`), and the castle cutscene waits for it (`engine/cutscenes/castle_cutscene.asm`). `$E4` is posted by StageStart ch1 (`$0A`). | 1234 | 1/3 |

The tables also leave some commands out per channel, and the data uses three such
combinations. `F5` (sweep) on channel 2 appears in bank `$02`'s WilyIntro (`$7832`)
and bank `$0A`'s StageSelect and WilyIntro; it's ignored, since channel 2 has no
sweep. The other is the channel-1 `F2` in the Wily 1 path above.

**Never used by any sound in either bank:** `F7`/`F6`/`EF` (vibrato), `EE`, `EC`/`EB`,
`EA`, `E9`/`E8`, `E7`, `F1`, `9x` (apart from the Wily 1 path). So the language
supports subroutines, compact one-byte notes, random pitch and vibrato, and the
game's sound data uses none of them.

## 7. Volume and envelopes

Every frame, `ProcEnvSeqs` (`$4A12`) handles each track that has an envelope
sequence (`$0D` non-zero) once its step counter (`$0F`, reloaded from `$0E`) runs out:

* **While the gate is open**, it takes the next nibble of the sequence. The index
  (`$10`) runs 0-15 and then sticks at 15. The sequence is 8 bytes, high nibble
  first.
* **Once the gate has closed, or the track has stopped**, it takes `EnvRest`, or 0
  if stopped.
* **Volume** = `Env` + nibble − 15, and nothing if that is below 0. So `F` means
  "full `Env`" and each step down drops one level. For channel 3, volume is turned
  into `NR32`'s four levels by the 4-byte table at `$461E` (`WaveVolumes`).
* If the NRx2 value changes, it sets the trigger bit and the track's trigger flag,
  so the note restarts at the new volume. That's how the Game Boy APU changes the
  volume of a playing note.

Without a sequence, a note writes NRx2 = `Env`·16 + `FB`'s value once, and the
hardware envelope does the rest.

**Sequence n is the 8 bytes at `Audio1_EnvSeqs` + 8n** (`$4E35`), n = 1-15. The labels
`.EnvSeq0`-`.EnvSeqF` mark them (before 6.2 they marked 16-byte pairs). Used: 5, 12,
13, 14, 15. **Sequences 5-9 are byte-for-byte the second halves of waveforms 5-9.**
Of those, only 5 is used: a falling saw (`F D B 9 7 5 3 1 E C A 8 6 4 2 0`).
Sequence 15 is all `F`s (hold). The waveform table (`$4D3D`) is 248 bytes, not 256:
the last 8 bytes of waveform `F` are the first 8 bytes of `EnvSeqs`, which form
sequence 0 and are never read as a sequence. Every `F2` in the data selects waveform 1.

## 8. Writing the hardware

`ProcRegs` (`$4B50`) looks at the top track of each channel stack:

* It ORs that track's pan bits (`TrackPanVals`) into the frame's `NR51` value.
* If the track's trigger flag is set, it clears the flag and copies the track's
  register shadow to the hardware with `OutputAudio` (`$4BB0`): five registers from
  `$53` for channels 1 and 3 (`NR10`-`NR14`, `NR30`-`NR34`), four from `$54` for
  channels 2 and 4. It then clears the shadow's trigger bit.
* For channel 3, it turns the DAC off before the copy and back on after it.
* A channel with no track gets no `NR51` bits, so it is silent.

The trigger flag is set whenever the track reads commands and whenever its envelope
step changes NRx2, so registers are written only when something changes.

Two oddities ([AUDIO_ANOMALIES.md](AUDIO_ANOMALIES.md) B4, B5): `OutputAudio` masks
channel 1 out of `NR51` for one frame the first time channel 1 is written after
`InitAudio`, using bit 4 of `Ch1MutedOnce` (`$D9DD`), which nothing else touches.
It also reads `NR52`, ORs in 4, and discards the result.

## 9. RAM

### Global block (`$D935`-`$DCBD`, cleared by `InitAudio`)

| Addr | Label | What |
|---|---|---|
| `$D935` | (`AudioRAM`) | the zero that the clear copies forward; otherwise unused |
| `$D936`-`$D937` | `wQueuedSoundPtr` | **the game's**: the highest-priority sound queued this frame (`PickQueuedSound`/`StartPickedSound`) |
| `$D93A` | `CurSoundSlot` | slot being processed (1-4) |
| `$D93B` | `CurTempoChan` | → that slot's tempo state |
| `$D93D` | `SoundSlots` ×4 | `$FF` = slot busy |
| `$D941` | `SoundPriorities` ×4 | slot priority |
| `$D945` | `CurTrackIndex` | track being processed (1-8) |
| `$D946` | `CurTrackRAM` | → its track RAM |
| `$D948` | `TrackSlots` ×8 | per track: owning slot, 0 = free |
| `$D950` | `TrackPlaying` ×8 | per track: `$FF` = playing |
| `$D958` | `TrackPanVals` ×8 | per track: its `NR51` bits |
| `$D960` | `TrackTrigVals` ×8 | per track: registers need writing |
| `$D968` | `Ch1IDRAM`-`Ch4IDRAM` ×4×4 | per channel: stack of track numbers, highest priority first |
| `$D978` | `ChanPanVal` | the `NR51` value being built this frame |
| `$D979` | `MasterSlot*` (= `UnkD979`) | working copy of the current slot's play count, tempo, tick counter |
| `$D97C`-`$D987` | `Slot1`-`Slot4SpeedRAM` | each slot's saved copy. `Slot5`-`8` (`$D988`-`$D993`) are in the pointer table but never used, and `CurTrackCh` overlaps them. |
| `$D98C` | `CurTrackCh` | channel of the track being set up |
| `$D98D`-`$D9A7` | `UnkRAM1` | no reference in either driver |
| `$D9A8` | `SongCue` | **cue byte** written by `E6`, read by the game's cutscenes |
| `$D9A9`-`$D9DC` | `UnkRAM2` | no reference in either driver |
| `$D9DD` | `Ch1MutedOnce` | bit 4: channel 1 has been written once since init (§8) |
| `$D9E1` | `SFX1RAM`… | the eight track RAMs, `$59` bytes each: `SFX1` `$D9E1`, `SFX2` `$DA3A`, `SFX3` `$DA93`, `SFX4` `$DAEC`, `Mus1` `$DB45`, `Mus2` `$DB9E`, `Mus3` `$DBF7`, `Mus4` `$DC50` |
| `$DCA9`-`$DCBB` | `CurEnvIndexTrack` … `CurParameter` | scratch: track being processed by the envelope pass, `RemoveTrackFromChannel`'s channel, repeat count, envelope, 6 unused bytes (`UnkRAM3`), `CurPan` (`NR51` mask, normally `$FF`), channel, `PlayCount`, priority, header pointer, slot, track, parameter byte |
| `$DCBC` | `wMusicSlot` | **the game's**: slot of the current music |

Outside the block: `$C131`/`$C132` (`wAudioLock`/`wAudioLockSave`, §2), `$CC4A` (`wAudioStopSlot`, the slot for
`StopRequestedSlot`), `$CC47` (scratch for the queue drain), `wSoundQueue` `$D920`-`$D934`.

### Track RAM (`$59` bytes)

| Off | Label | What |
|---|---|---|
| `$00` | `Start` | track start; restart point for a replay |
| `$02` | `CurPos` | read pointer |
| `$04` | `Chan` | hardware channel, **1-4** |
| `$05` | `Trans` | signed transpose, semitones (`ED`, `E7`) |
| `$06` | `Random` | random mode on (`E7`) |
| `$07` | `Waveform` | waveform number (`F2`), reloaded by `RemoveTrackFromChannel` |
| `$08` | `Env` | note volume (`FE`) |
| `$09` | `EnvRest` | rest / release volume (`FD`) |
| `$0A` | `Dur` | gate shortening (`F8`) |
| `$0B` | `DurLeft` | gate countdown, ticks |
| `$0C` | `Delay` | ticks until the next command |
| `$0D` | `EnvSeq` | envelope sequence (`FC`) |
| `$0E` | `EnvSeqSpeed` | frames per step (`FA`, default 2) |
| `$0F` | `EnvSeqSpeed1Left` | step countdown |
| `$10` | `EnvSeqIndex` | nibble index, 0-16 |
| `$11` | `EnvSeqPtr` | → sequence |
| `$13` | `Unk13` | zeroed on each note, never read |
| `$14` | `EnvSweepPace` | NRx2 low nibble (`FB`) |
| `$15`-`$1B` | `Vib*` | vibrato state (`F7`/`F6`/`EF`: `VibSeq`, `VibWait`, `VibWaitLeft`, `VibPeriod`, `VibPeriodLeft`, `VibSeqPtr`). Set up on each note (`$15` index → `VibTab`, `$16`→`$17`, `$19`=1, `$1A` = pointer) but never processed. |
| `$1C` | `AutoLen` | one-byte mode on (`EC`) |
| `$1D` | `LastLen` | length of the last note or rest |
| `$1E` | `MacroRet` | `E9` return address |
| `$20` | `Unk20` | never touched |
| `$21` | `HWLength` | hardware-length mode (`EE`) |
| `$22` | `RepeatBNum` | `Bx` counter |
| `$23`/`$33` | `RepeatABPos`/`RepeatANum` | `Ax`: 8 command addresses / counts |
| `$3B`/`$4B` | `RepeatDPos`/`RepeatDNum` | `9x`: 8 command addresses / counts |
| `$53`-`$57` | `NRx0`-`NRx4` | register shadow. `$53` is `NR10` sweep for channel 1 (default `$08`), `NR30` for channel 3 (default `$80`), and not written out for channels 2 and 4. |
| `$58` | – | never touched |

`InitTrackVars` (`$4C63`) resets only `$02` (= `$00`), `$05`, `$08` (=15), `$0A`, `$0C`
(=1), `$0E` (=2), `$0F`, `$16` (=40), `$18` (=2), the pan (both sides), `$0D` (off),
`$53`, and the hardware NRx2 (`$08`). The rest keeps whatever the previous user of
that track RAM left: duty, length, `EnvRest`, sweep, waveform number, the repeat
slots. So **a sound inherits settings it doesn't set itself** from whatever last
used that track RAM. It is audible: the boss theme's rests come out twice as loud
after Ice, Elec or Fire Man's stage as after Cut Man's, and a stale repeat counter
shortens `SFX_Wheel` ([AUDIO_ANOMALIES.md](AUDIO_ANOMALIES.md) A3, A4).

## 10. Size, and what could have been smaller (6.3)

Measured on the ROM (`tools/audiodump.py`, the sym file, and a byte comparison of the
two banks that allows for the 14-byte shift):

| | Bank `$02` | Bank `$0A` |
|---|---:|---:|
| entry points + SoundTab (+ `Audio2_Empty`) | 119 | 133 |
| driver code | 3,270 | 3,270 |
| tables (waveforms … frequencies) | 791 | 791 |
| sound data | 11,342 | 8,619 |
| **used / free** | **15,522 / 862** | **12,813 / 3,571** |

* **Duplicated:** the whole driver and its tables, and `$5054`-`$5BE9` (2,966 bytes:
  all 31 effects plus Boss and Victory), are byte-identical in both banks apart from
  relocated pointers. That's **about 7.1 KB stored twice.**
* **One bank would not have held it all as written:** shared 7.1 KB + bank `$02`'s
  own music (8,376) + bank `$0A`'s (5,653) ≈ 21.2 KB, against 16 KB. Even without the
  unreachable songs (`EndGameAlt` 955, `WilyUnk` 171, `UnkTheme` 206) and the dead
  vibrato (code 155, sequences and table 176), about 19.5 KB. So the split was needed
  *with this encoding*; the cost is the duplication, not the second bank.
* **Where the data is loose:**
  * Every note is two bytes. Of 5,465 note/rest commands (first pass of every
    track), **3,126 repeat the previous note's length**, so the driver's one-byte
    mode (`EC`) could have saved up to about 3 KB, more than the gap above. It was
    never used, and as written it can't be: jumps and events break inside it
    ([AUDIO_ANOMALIES.md](AUDIO_ANOMALIES.md) B3).
  * The call command (`E9`/`E8`) is never used, so repeated phrases are stored again
    rather than shared. Not measured.
  * 270 `F9` commands (540 bytes) can't take effect (B6), and about 60 events set a
    value that is already set.
  * Waveforms 10-15 are copies of one wave (15 only half of it), and 1 and 4 are
    identical: 10
    distinct waves in 15 slots, of which one is ever used.
* **Single-bank layouts in Mega Man II/III** (as PLAN.md 6.3 suggested comparing):
  not done, since those ROMs aren't in the project.

## Labels renamed in 6.2 and 6.4

Byte-for-byte the same ROM; only names and comments changed. `Audio1_`/`Audio2_`
prefixes apply in both banks, and per-track fields apply to all eight track RAMs
(`SFX1`…`Mus4`).

| Old | New | Why |
|---|---|---|
| `SFXOff` (bank `$02`) / `SoundOff` (bank `$0A`) | `StopAllSounds` | stops all four slots, music too |
| `CondSoundOff` | `StopRequestedSlot` | stops the slot in `$CC4A`; the "condition" is only "not 0" |
| `SFXOffFlags` | `StopSlotLocked` | takes the update lock, stops slot A |
| `EndSound` | `StopSlot` | stops slot A (music or effect) |
| `ClearTrack` | `RemoveTrackFromChannel` | takes a track off its channel stack |
| `InitSlot1` | `InitSlot` | initialises whichever slot is current |
| `GetCurPos` | `MuteTrackChannel` | reads the track's channel and mutes it |
| `ChanOff` | `MuteChannel` | masks a channel out of `NR51` |
| `EventSlur`, `…Slur` (`$21`) | `EventHWLength`, `…HWLength` | hardware-length mode; no slur involved |
| `EventRNG`, `DoRNG`, `…RNG` (`$06`) | `EventRandomize`, `RandomizeNote`, `…Random` | random transpose and volume |
| `EventRNGVal`, `CurRNG` | `EventCue`, `SongCue` | a cue from the song to the game |
| `…F3` (`$07`) | `…Waveform` | waveform number |
| `NoiseEnvs` | `WaveVolumes` | channel 3's `NR32` volume table |
| `EventVibSpeed`, `…VibSpeed(Left)` | `EventVibWait`, `…VibWait(Left)` | wait before vibrato starts, going by `ProcVibSeqs` |
| `EventVibDelay`, `…VibDelay(Left)` | `EventVibPeriod`, `…VibPeriod(Left)` | frames per vibrato step |
| `…AutoLenAmt` (`$1D`) | `…LastLen` | length of the last note or rest |
| `ChanSlotVals`, `ChanPlayVals` | `TrackSlots`, `TrackPlaying` | indexed by track, not channel |
| `PlayFlag` | `PlayCount` | play count of the slot being loaded |
| `UnkCC4A` | `wAudioStopSlot` | the slot `StopRequestedSlot` stops |
| `CondFlag1`, `CondFlag2` (6.4) | `wAudioLock`, `wAudioLockSave` | the update lock and its saved copy (§2) |
| `Func_00_03E4`, `_07DD`, `_0826`, `_0405`, `_083A` (6.4) | `DrainSoundQueue`, `PickQueuedSound`, `StartPickedSound`, `RunAudioUpdate`, `StopAllButMusic` | §2 |
| `$D936`, `$DCBC` (no label) (6.4) | `wQueuedSoundPtr`, `wMusicSlot` | §2 |
| `UnkD9DD` | `Ch1MutedOnce` | bit 4: channel 1's one-frame mute has happened |
| `.EnvSeq0`-`.EnvSeq7` (16-byte pairs) | `.EnvSeq0`-`.EnvSeqF` (8 bytes each) | sequence n = `EnvSeqs` + 8n |
| `AudioSFXOff`, `AudioCondSoundOff` (bank `$00` stubs) | `AudioStopAll`, `AudioStopSlot` | as above |

Comments fixed at the same time: "channel 4 (noise)" at the `cp 3` tests (they mean
channel 3, wave: `$04` is 1-based), `EventAutoLenOn`'s note that the length is
never set (`$1D` takes every note's length), the "conditional flags?" and
"unknown value" comments, and `InitTrackVars`' "Set ? to 2". The confirmed bugs are
marked `BUG:` in the source.

## Left for later steps

Phase 6 is complete.
