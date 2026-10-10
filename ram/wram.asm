;WRAM layout.
;
;Only addresses actually traced to code are named. Sections are deliberately
;small and pinned to fixed addresses rather than being laid out with `ds` runs,
;because we do not yet know most variables' extents and a `ds 12` would be an
;invented fact. As regions become clear, merge their sections and give the
;sizes real `ds` values.
;
;The audio engine's own block ($D93A-$DCBB) lives in ram/audio_ram.asm and is
;laid out properly there.
;
;docs/RAMMAP.md has the full reference tally, including the ~100 addresses that
;are touched but not yet understood.

; ============================================================================
; $C000-$C0FF - display
; ============================================================================

;Shadow OAM, 40 sprites x 4 bytes (Y, X, tile, attributes), DMA'd to $FE00 by
;the HRAM routine every frame. CopyToShadowOAM fills it from a source buffer and
;zero-fills the remainder up to offset $A0, which is what pins the size.	;[ok]
SECTION "Shadow OAM", WRAM0[$C000]
wShadowOAM::	ds $A0	;$C000-$C09F

;$C0A4-$C0FF is 92 bytes that ClearRamCode memsets to $C9 - a solid block of
;`ret` - and that the game then writes small pieces of code into. Two entry
;points are known, so they are declared as separate one-byte sections rather
;than a `ds` run that would imply we know where each piece ends.

;Start of that block, and also the target of the LCDC/STAT interrupt vector at
;$0048, which is `jp $C0A4`. With the block memset to `ret`, the STAT handler is
;a no-op until something installs one here. Declared as one byte because the
;block's internal layout is not known - ClearRamCode's `ld bc,$5C` is what gives
;the 92-byte extent.	;[ok]
SECTION "RAM Code", WRAM0[$C0A4]
wRamCode::	ds 1	;$C0A4, start of the 92-byte block

;Two `jp` hooks that bank $01 installs on entry ($1:411E and $1:412F):
;$C0AA gets `jp $4140` and $C0AD gets `jp $42AE`. StageFrameLoop calls $C0AD
;once per frame. Who calls $C0AA is not yet traced.	;[ok]
SECTION "RAM Hooks", WRAM0[$C0AA]
wHookA::	ds 3	;$C0AA-$C0AC
wHookB::	ds 3	;$C0AD-$C0AF

;Code, not a table: banks $0B, $0C and $0E each copy a 23-byte trampoline here
;(bank $0C's FarCallBank1 at $C:4016 is the traced one) that pages in bank $01,
;calls the routine whose address was patched into it, and restores the caller's
;bank. That is why it lives inside the RAM-code block.	;[ok]
SECTION "Bank 1 Trampoline", WRAM0[$C0B0]
wBank1Trampoline::	ds $17	;$C0B0-$C0C6

;CallBank1Routine assembles `jp <target>` here on every call and then calls it.
;Three bytes: the $C3 opcode and the address.	;[ok]
SECTION "Bank Call Jump", WRAM0[$C0D0]
wBank1CallJump::	ds 3	;$C0D0-$C0D2

; ============================================================================
; $C100-$CFFF - game state and scratch
; ============================================================================

;Lives. Set to 3 by SetStartingLives ($0CC9), decremented at $0BC8, and capped
;at 10 by the routine at bank $01:$5766.	;[dc]
SECTION "Lives", WRAM0[$C108]
wLives::	ds 1	;$C108

;Weapon and shot state, all bank $01 (step 5.1). EquipWeapon fills $C203-$C235
;from the weapon's WeaponTab record; UpdateShots rebuilds the two hit lists
;every frame, and the collision pass in bank $00 ($1093) tests enemies against
;them. A list entry is (slot, X, Y); the list ends with 0.	;[ok]
SECTION "Shot State", WRAM0[$C200]
wShotCount::	ds 1	;$C200, shots alive
wShootTimer::	ds 1	;$C201, $10 on firing, counts down; Mega Man's shooting pose
wShotListEnd::	ds 1	;$C202, low byte of the hit list's write pointer
wWeaponDamage::	ds 1	;$C203, copied to each new shot's offset $0B
wShotListActive::	ds 1	;$C204, non-zero when the hit list has entries
wShotHitbox::	ds 4	;$C205-$C208, x1, x2, y1, y2 relative to each shot
wShotList::	ds 1	;$C209, the list's first entry
SECTION "Shot List 2", WRAM0[$C216]
wShotList2End::	ds 1	;$C216
	ds 1	;$C217, set by Thunder Beam, Fire Storm and Mirror Buster; not traced
wShotList2Active::	ds 1	;$C218
wShotHitbox2::	ds 4	;$C219-$C21C
wShotList2::	ds 1	;$C21D
SECTION "Weapon Record", WRAM0[$C22B]
wWeaponTileset::	ds 1	;$C22B, LoadObjectTiles type for the shots
wWeaponMaxShots::	ds 1	;$C22C
wWeaponShotState::	ds 1	;$C22D, a new shot's offset $00 (non-zero = in use)
wWeaponCost::	ds 1	;$C22E, energy per shot
wWeaponFire::	ds 3	;$C22F, `jp` to the fire routine (TryFireWeapon jumps here)
wWeaponUpdate::	ds 3	;$C232, `jp` to the update routine (UpdateShots calls it)
;How a hit treats the shot (bank $00 $110F). The enemy's value in $CC46 is
;subtracted from the shot's damage byte unless bit 0 is set; bit 2 skips that
;when the shot's damage is at least as large; bit 1 makes the hit do no damage.
;$FF in $CC46 destroys any shot, $FE deflects it (sound $0A, damage byte $80).
wWeaponPierce::	ds 1	;$C235
;Three $20-byte shot records; the layout is under UpdateShots in bank $01.	;[ok]
SECTION "Shot Slots", WRAM0[$C239]
wShotSlots::	ds 3 * $20	;$C239-$C298
;Mirror Buster's capture list: write pointer, then 6-byte records (X speed,
;X, Y speed, Y) of enemy shots it blocked.	;[ok]
SECTION "Captured Shots", WRAM0[$C299]
wCapturedShotsEnd::	ds 1	;$C299
wCapturedShots::	ds 1	;$C29A, first record


;Scratch for DrawSpriteGrid, which draws a rectangular block of sprites into
;shadow OAM from a metasprite definition. The first source byte packs the grid
;size, high nibble into wMetaspriteCols and low nibble into wMetaspriteRows.
;The Base pair is the block's origin; the Cur pair walks across it.	;[ok]
SECTION "Metasprite Scratch", WRAM0[$CC4B]
wMetaspriteBaseX::	ds 1	;$CC4B
wMetaspriteBaseY::	ds 1	;$CC4C
wMetaspriteCurX::	ds 1	;$CC4D
wMetaspriteCurY::	ds 1	;$CC4E
wMetaspriteCols::	ds 1	;$CC4F
wMetaspriteRows::	ds 1	;$CC50

;Stage-select screen: where each of the four robot master sprites currently
;sits, as (X, Y) pairs. Initialised by LoadStageSelectBosses to (24,28), (74,28),
;(24,78), (74,78) and then nudged a pixel at a time by the zoom-in animation.
;Read back by the four accessors at $2022/$202E/$203A/$2046.	;[ok]
SECTION "Stage Select Positions", WRAM0[$CC51]
wStageSelectPos::			;$CC51-$CC58, four X/Y pairs
wStageSelectPos1X::	ds 1
wStageSelectPos1Y::	ds 1
wStageSelectPos2X::	ds 1
wStageSelectPos2Y::	ds 1
wStageSelectPos3X::	ds 1
wStageSelectPos3Y::	ds 1
wStageSelectPos4X::	ds 1
wStageSelectPos4Y::	ds 1

;Stage-select animation state.	;[ok]
SECTION "Stage Select Anim", WRAM0[$CCF6]
;Cycles 0/1/2 to pick which animation frame the idle loop shows next.
wStageSelectAnimPhase::	ds 1	;$CCF6

SECTION "Screen Counter", WRAM0[$CCF9]
;A general-purpose counter that several screens reuse for different things, so
;the name is deliberately vague. Three uses traced:
;  - boss intro (bank $01, $6294): counts frames 0-$77, and TypeBossName uses it
;    as the index of the next letter to draw, so the name appears one letter per
;    frame
;  - stage select: set to $2C as an end-of-zoom sentinel
;  - $1E81: loaded from a data byte and counted down as a tile-copy loop counter
;Previously named wTileCopyCount after the third use alone.	;[?]
wScreenCounter::	ds 1	;$CCF9

;What the running stage is doing; StageFrameLoop branches on it every frame.
;  0 playing, 1 boss room entered, 2 boss just beaten, 3 victory countdown.	;[ok]
SECTION "Stage State", WRAM0[$CCFD]
wStageState::	ds 1	;$CCFD

SECTION "Stage Select Timer", WRAM0[$CCFE]
;Frame timer for the stage-select screen. Counts up; at $78 the zoom-in starts.
wStageSelectTimer::	ds 1	;$CCFE
;Index into the animation frame pointer table, scaled by 2 in GetStageSelectFrame.
wStageSelectFrame::	ds 1	;$CCFF

; ============================================================================
; $D000-$DFFF
; ============================================================================

;Mega Man, as bank $01's player code uses him (step 5.1).	;[ok]
SECTION "Player State", WRAMX[$D802]
;1 alive, 2 just died, 3 dying (UpdatePlayerState).
wPlayerState::	ds 1	;$D802
;1 facing right, 0 left (SetWalkVelocity).
wPlayerFacing::	ds 1	;$D803
SECTION "Player Animation", WRAMX[$D80A]
;Even index into MegaManFrames; DrawPlayer adds wPlayerFacing.
wPlayerAnim::	ds 1	;$D80A
SECTION "Player Position", WRAMX[$D821]
;Screen position in pixels; $D820 and $D823 hold the fractions.
wPlayerX::	ds 1	;$D821
	ds 2	;$D822-$D823
wPlayerY::	ds 1	;$D824
SECTION "Player Hurt Timer", WRAMX[$D839]
;Set to $88 when Mega Man is hit and counted down; above $5A he is knocked back
;and cannot act, below it he blinks.
wHurtTimer::	ds 1	;$D839
SECTION "Player Joypad", WRAMX[$D83F]
;ReadPlayerJoypad's copies of hJoypadPressed and hJoypadHeld.
wPlayerPressed::	ds 1	;$D83F
wPlayerHeld::	ds 1	;$D840
SECTION "Player Motion", WRAMX[$D846]
;0 in the air, 1 on the ground, 2 on a ladder (CheckPlayerLanding, GrabLadder).
wPlayerMotion::	ds 1	;$D846
SECTION "Floor Type", WRAMX[$D908]
;What Mega Man stands on, set by the stages' collision code: 2 is Ice Man's
;slippery blocks. Picks his walking acceleration and friction (SetWalkVelocity,
;MovePlayerX).
wFloorType::	ds 1	;$D908
;Set every frame by Bubble Man's room's hook and cleared by the other rooms':
;lower gravity and speed (ApplyPlayerGravity, ClampPlayerSpeedX).
wUnderwater::	ds 1	;$D909


;Loop counter for Div32By16, which is itself never called.	;[ok]
SECTION "Div Loop Count", WRAMX[$D8A4]
wDivLoopCount::	ds 1	;$D8A4

;LineStepInit / LineStep state. Banks $03, $09 and $0D have their own copies of
;those routines that use the same nine bytes.	;[ok]
SECTION "Line Step", WRAMX[$D8AC]
wLineError::	ds 1	;$D8AC, error accumulator, starts at 2
wLineFromX::	ds 1	;$D8AD
wLineFromY::	ds 1	;$D8AE
wLineToX::	ds 1	;$D8AF
wLineToY::	ds 1	;$D8B0
wLineDX::	ds 1	;$D8B1, |ToX - FromX|
wLineStepX::	ds 1	;$D8B2, +C or -C
wLineDY::	ds 1	;$D8B3, |ToY - FromY|
wLineStepY::	ds 1	;$D8B4, +C or -C

;Sound request queue, filled by QueueSound: a count, then up to 20 sound IDs.	;[ok]
SECTION "Sound Queue", WRAMX[$D920]
wSoundQueue::	ds 1 + 20	;$D920-$D934

;Horizontal camera limits for the room: ClampToScrollLimits keeps the camera X
;between them. LoadRoom sets the minimum to $50 and the maximum to
;width * 16 - $50, from the room layout's width byte.	;[ok]
SECTION "Scroll Limits", WRAMX[$D861]
wScrollMinX::	ds 2	;$D861-$D862
wScrollMaxX::	ds 2	;$D863-$D864

;Room state, all written by LoadRoom (and LoadRestartPoint) from the stage data
;in bank $05/$08. Formats in docs/LEVELS.md.	;[ok]
SECTION "Room State", WRAMX[$D877]
wRoomRowPtrs::	ds 2 * 8	;$D877-$D886, one pointer per layout row
wRoomPtr::	ds 2	;$D887, the room record
wRoomLayoutPtr::	ds 2	;$D889, its layout
wRoomRoutinePtr::	ds 2	;$D88B, called once the room is set up
wRoomXOffset::	ds 2	;$D88D, the room's X in stage coordinates
SECTION "Exit Boxes", WRAMX[$D892]
;Up to two 8-byte boxes (dw left, dw right, db top, db bottom, dw room)
;built by BuildExitBoxes; unused slots are filled with $80. CheckRoomExits
;tests Mega Man's position against them.	;[ok]
wExitBoxes::	ds 2 * 8	;$D892-$D8A1
;The restart point's init routine, called at the end of LoadRestartPoint.	;[ok]
wRestartInitPtr::	ds 2	;$D8A2-$D8A3

;The room layout's width and height in blocks (LoadRoom).	;[ok]
SECTION "Room Size", WRAMX[$D8C0]
wRoomWidth::	ds 1	;$D8C0
wRoomHeight::	ds 1	;$D8C1

;The stage's blockset, from the restart-point record: a pointer to the first
;4-byte block definition, the block count, and the per-block collision table
;(64 bytes are copied whatever the count). DrawBlock reads the first.	;[ok]
SECTION "Blockset", WRAMX[$D8C4]
wBlocksetPtr::	ds 2	;$D8C4-$D8C5
wBlockCount::	ds 1	;$D8C6
SECTION "Block Collision", WRAMX[$D8C8]
wBlockCollision::	ds 64	;$D8C8-$D907

;Wily 2 teleporter hub state (bank $08, Wily2HubFrameHook): wHubState 0 waiting,
;1 fading in, 2 playing, 3 teleporting out; the fade's timer and step; and the
;restart record the chosen teleporter leads to.	;[ok]
SECTION "Hub State", WRAMX[$D90A]
wHubState::	ds 1	;$D90A
wHubFadeTimer::	ds 1	;$D90B
wHubFadeStep::	ds 1	;$D90C
	ds 1	;$D90D, not seen used
wHubDestination::	ds 2	;$D90E-$D90F

;A chunked copy to VRAM, set up by QueueTileCopy and advanced one chunk per call
;by CopyQueuedTiles (bank $08): chunk size, source, destination, bytes left.
;Wily 1 uses it to stream Wily 2's tiles in.	;[ok]
SECTION "Tile Copy", WRAMX[$D910]
wTileCopyChunk::	ds 1	;$D910
wTileCopySource::	ds 2	;$D911-$D912
wTileCopyDest::	ds 2	;$D913-$D914
wTileCopyLeft::	ds 2	;$D915-$D916

;Scroll shadows, copied to rSCX/rSCY at the top of every VBlank.	;[ok]
SECTION "Scroll Shadow", WRAMX[$D85F]
wShadowSCX::	ds 1	;$D85F -> rSCX
wShadowSCY::	ds 1	;$D860 -> rSCY

;The current stage section's per-frame routine: the section loader at $3057
;writes `jp <address from the section record>` here, and StageFrameLoop calls it
;every frame.	;[ok]
SECTION "Stage Hook", WRAMX[$DF80]
wStageHook::	ds 3	;$DF80-$DF82

;VBlank bookkeeping, all from the handler at $0675.	;[ok]
SECTION "VBlank State", WRAMX[$DF83]
;16-bit counter, incremented once per VBlank that actually did work.
wVBlankCount::	ds 2	;$DF83-$DF84
;8-bit frame counter, incremented on every VBlank without exception.
wFrameCounter::	ds 1	;$DF85

SECTION "VBlank Flags", WRAMX[$DF88]
;Set to 1 as the handler returns; the main loop waits on it.
wVBlankDone::	ds 1	;$DF88
;Re-entrancy guard. Zero means the per-frame work has not run yet this frame;
;the handler sets it to 1 before doing the OAM DMA and the update calls.
wVBlankBusy::	ds 1	;$DF89
;LCDC shadow, copied to rLCDC every VBlank.
wShadowLCDC::	ds 1	;$DF8A

;Which restart point a lost life sends Mega Man back to: 0 is the stage start,
;n is the room named by the n-th checkpoint record. UpdateRestartPoint sets it
;every frame, LoadStage passes it to GetTablePointer on the restart-point
;table, and NewGame and the stage-clear paths zero it.	;[ok]
SECTION "Restart Point", WRAMX[$DF8D]
wRestartPoint::	ds 1	;$DF8D

;Which stage is selected. The stage-select screen treats it as 0-3, branching on
;it with a chain of `dec a`; bank $01 increments it at $062BA, and LoadStage
;indexes StageLoadTab with it one-based.	;[ok]
SECTION "Selected Stage", WRAMX[$DF8C]
wSelectedStage::	ds 1	;$DF8C

;The stage header, copied out by LoadStage: the stage's restart-point table and
;its checkpoint list (docs/LEVELS.md). UpdateRestartPoint scans the second.	;[ok]
SECTION "Stage Header Copy", WRAMX[$DF8E]
wRestartPointsPtr::	ds 2	;$DF8E-$DF8F
wCheckpointsPtr::	ds 2	;$DF90-$DF91

;The id byte of the room Mega Man is in, from the room record (LoadRoom).
;UpdateRestartPoint matches it against the checkpoint list; the Fire Man and
;Elec Man room routines and frame hooks index their behind-BG box tables
;with it.	;[ok]
SECTION "Room ID", WRAMX[$DF92]
wRoomID::	ds 1	;$DF92

;Bitfield of defeated robot masters. LoadStageSelectBosses tests bits 3, 0, 1 and 2 in
;turn to decide whether to draw each portrait on the stage select.	;[ok]
SECTION "Bosses Defeated", WRAMX[$DF95]
wBossesDefeated::	ds 1	;$DF95

;Wily castle progress. Bits 0-3: the bosses behind teleporters 1-4 are beaten
;(Quick Man, Bubble Man, Flash Man, Heat Man), bit 4: Enker; bank $00 ORs the bit
;in from a table at $1:5EB6 indexed by wHubTeleporter. Bit 7: Mega Man has reached
;the hub (Wily2HubRoutine). $0F selects the five-teleporter hub, $1F Wily 3;
;Wily 3's inits write $9F. Wily 1 clears it on the way down to the hub.	;[ok]
SECTION "Wily Progress", WRAMX[$DF96]
wWilyProgress::	ds 1	;$DF96
;The teleporter Mega Man last used, 1-5 (0 = none). Set by Wily2CheckTeleporters;
;it places him back on that teleporter, picks the wWilyProgress bit, and the
;weapon-get screen shows weapon wHubTeleporter + 4.	;[ok]
wHubTeleporter::	ds 1	;$DF97

;Shadow of the MBC1 bank register. The `bankswitch` macro writes A here and to
;$2100 together, so code can read back which bank is paged in - $2100 is
;write-only. Every bank switch in the ROM goes through that pair.	;[ok]
SECTION "Bank State", WRAMX[$DF99]
wCurrentBank::	ds 1	;$DF99

;Which of the two audio banks FarCallAudio should page in. Only ever set to $02
;or $0A; the music and SFX data did not fit in one bank, so the driver exists in
;both and the caller picks before calling any audio routine.	;[ok]
wAudioBank::	ds 1	;$DF9A

;The stage's data bank, taken from StageLoadTab by LoadStage. $05 for the four
;robot master stages, $08 for the four Wily stages, and $0E is written here once
;from bank $0E itself. Nine other sites re-page it rather than re-reading the
;table.	;[ok]
SECTION "Stage Bank", WRAMX[$DF9B]
wStageBank::	ds 1	;$DF9B

;BGP shadow, copied to rBGP every VBlank.	;[ok]
SECTION "Palette Shadow", WRAMX[$DF9C]
wShadowBGP::	ds 1	;$DF9C

;Currently equipped weapon, as an index into wEnergy: 0 is the Mega Buster (and
;the health meter), 1-10 are the weapons in the order of the unlock bits below.
;Bank $01's refill code adds it to the wEnergy base to pick which meter to top
;up, and SetStartingLives clears it.	;[ok]
SECTION "Current Weapon", WRAMX[$DFA0]
wCurrentWeapon::	ds 1	;$DFA0

;Weapon unlock bits. Bit order is what identifies bank $04's graphics pointer
;table - see banks/bank04.asm.
;  $DFA1  $01 Mega Buster  $02 Rolling Cutter  $04 Thunder Beam  $08 Ice Slasher
;         $10 Fire Storm   $20 Carry           $40 Atomic Fire   $80 Time Stopper
;  $DFA2  $01 Quick Boomerang  $02 Bubble Lead  $04 Mirror Buster
;$01 is written to $DFA1 at $0855, which is the Mega Buster you start with. ;[dc]
wWeaponsUnlocked1::	ds 1	;$DFA1
wWeaponsUnlocked2::	ds 1	;$DFA2

;Energy meters: health first, then one per weapon in the same order as the bits
;above, ending with Mirror Buster. $98 is written to the first byte at $0B24,
;and Data Crystal records that all of them cap at 98.	;[dc]
wEnergy::	ds 11	;$DFA3-$DFAD

;FuncRNG's state: a running seed and the index it walks through RNGTable.
;Pinned to its own section. It used to follow wEnergy implicitly, and inserting
;a section above it silently moved it to $DFC9 — the build caught that, but it is
;why every label in this file carries an explicit address.	;[ok]
SECTION "RNG State", WRAMX[$DFAE]
wRNGSeed::	ds 1	;$DFAE
wRNGIndex::	ds 1	;$DFAF

;Non-zero selects the second half of StageLoadTab, which is the four Wily
;stages. Data Crystal calls bank $08 "Wily 1 Data", which is what those four
;records point at.	;[dc]
;Frames left after a boss is beaten before the stage ends. BossDefeated sets it
;to $01E0 (eight seconds); StageFrameLoop counts it down in state 3. 16-bit,
;little-endian.	;[ok]
SECTION "Victory Timer", WRAMX[$DFCA]
wVictoryTimer::	ds 2	;$DFCA-$DFCB

SECTION "Wily Stage Set", WRAMX[$DFC8]
wWilyStageSet::	ds 1	;$DFC8

;Things that stop play. Bit 0: the hitbox viewer is running; bit 1: a meter is
;being refilled (RefillTick); bit 3: Time Stopper. Shots, items and enemy shots
;skip their movement while the low bits are set; TryFireWeapon refuses while
;any of $53 is.	;[ok]
SECTION "Freeze Flags", WRAMX[$DFB1]
wFreezeFlags::	ds 1	;$DFB1

;Mega Man's teleport (UpdateTeleport): 1 beaming in, 2 and 3 beaming out, $FF
;finished. $DFCD is the beam's animation counter.	;[ok]
SECTION "Teleport State", WRAMX[$DFCC]
wTeleportState::	ds 1	;$DFCC
