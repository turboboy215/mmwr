;Mega Man: Dr. Wily's Revenge disassembly - the interface to the audio banks
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Audio API", ROM0[$0236]

;$0236: the audio API. Seven three-byte stubs, each `rst $08` followed by an
;inline target address. $0008 is `jp FarCallAudio`, which reads that address,
;pages in the bank named by wAudioBank ($02 or $0A) and jumps to it. So
;`call AudioInit` from anywhere in ROM0 or bank $01 behaves like an ordinary
;call into whichever audio bank is currently selected.
;
;The targets are the seven `jp` entries at the top of both audio banks, in the
;order audio/bank02.asm declares them.	;[ok]
MACRO farcall_audio
	rst $08
	dw \1
ENDM

AudioInit::			;$4000 Audio1_InitAudio
	farcall_audio $4000
AudioStopSlot::		;$4003 Audio1_StopRequestedSlot
	farcall_audio $4003
AudioLoadSound::		;$4006 Audio1_LoadSound
	farcall_audio $4006
AudioLoadSong::			;$4009 Audio1_LoadSong
	farcall_audio $4009
AudioGetSlot::			;$400C Audio1_GetSlot
	farcall_audio $400C
AudioPlay::			;$400F Audio1_PlayAudio
	farcall_audio $400F
AudioStopAll::			;$4012 Audio1_StopAllSounds
	farcall_audio $4012

;$024B: 49 words running $4015, $4017 ... $4075 with no gaps and no repeats.
;$4015 is Audio1_SoundTab in both audio banks, whose entries are two bytes each,
;so this is a table of pointers to consecutive SoundTab entries - an identity
;mapping, and an indirection that buys nothing: the driver itself indexes
;SoundTab directly. Read by StageMusicTab and by the boss/victory music switches
;in StageFrameLoop, always through two further pointer hops.	;[ok]
AudioSoundTabPtrs::
	dw $4015
	dw $4017
	dw $4019
	dw $401B
	dw $401D
	dw $401F
	dw $4021
	dw $4023
	dw $4025
	dw $4027
	dw $4029
	dw $402B
	dw $402D
	dw $402F
	dw $4031
	dw $4033
	dw $4035
	dw $4037
	dw $4039
	dw $403B
	dw $403D
	dw $403F
	dw $4041
	dw $4043
	dw $4045
	dw $4047
	dw $4049
	dw $404B	
	dw $404D
	dw $404F
	dw $4051
	dw $4053
	dw $4055
	dw $4057
	dw $4059
	dw $405B
	dw $405D
	dw $405F
	dw $4061
	dw $4063
	dw $4065
	dw $4067
	dw $4069
	dw $406B
	dw $406D
	dw $406F
	dw $4071
	dw $4073
	dw $4075

;$02AD: far-call trampoline for the audio banks. Entered only via `rst $08`,
;which the seven stubs at $0236 use; $0008 holds `jp FarCallAudio`.
;
;On entry the top of the stack is the `rst` return address, which points at the
;inline `dw` that follows the rst in the stub. That word is the routine to call
;in the audio bank.
;
;   - stash A/L/H/E/D in HRAM, since the bank switch and the address fetch need
;     registers
;   - page in wAudioBank ($02 or $0A)
;   - pop the rst return address into HL and read the inline target through it
;   - push .restoreBank1, then push the target, so `ret` enters the target and
;     the target's own `ret` lands on .restoreBank1
;   - reload the caller's registers and `ret` into the target
;
;The rst return address is deliberately discarded: control comes back through
;.restoreBank1, whose `ret` pops the return address of whoever called the stub.
;So `call AudioLoadSong` returns normally to its caller, with bank $01 paged
;back in. Flags and BC pass through untouched.	;[ok]
FarCallAudio::	;$02AD
	ldh [hFarCallA],a
	ld a,l
	ldh [hFarCallL],a
	ld a,h
	ldh [hFarCallH],a
	ld a,e
	ldh [hFarCallE],a
	ld a,d
	ldh [hFarCallD],a
	ld a,[wAudioBank]
	bankswitch
	pop hl			;HL = address of the stub's inline dw
	ld de,.restoreBank1
	push de
	ld e,[hl]
	inc hl
	ld d,[hl]
	push de			;target address, entered by the ret below
	ldh a,[hFarCallL]
	ld l,a
	ldh a,[hFarCallH]
	ld h,a
	ldh a,[hFarCallE]
	ld e,a
	ldh a,[hFarCallD]
	ld d,a
	ldh a,[hFarCallA]
	ret

;$02DC: reached when the audio routine returns. Restores the resident bank and
;returns to the caller of the stub.
.restoreBank1	;$02DC
	push af
	ld a,1
	bankswitch
	pop af
	ret

SECTION "QueueSound", ROM0[$03CD]

;$03CD: queue sound A. Nothing plays here: the ID is appended to wSoundQueue
;(a count followed by up to 20 entries) unless the queue is full, and the audio
;side drains it later. Reachable from other banks through the stub at $016E.
;
;An ID is the SoundTab index plus one, resolved in whichever audio bank
;wAudioBank selects - so the same ID can mean different things in banks $02 and
;$0A. That rule fits every case checked: title $2A -> Title, password $2E ->
;Password, stage select $26 -> StageSelect, and the ending in bank $0E queuing $28
;-> EndGame - and Will has confirmed three by ear on the password screen: $10
;(correct password) is SFX_ExtraLife, $02 and $0F (wrong password) are
;SFX_Explode and SFX_PlayerExplode. The consumer that subtracts the one has not
;been traced yet.	;[ok]
;
;Every ID the ROM queues with a literal, against Will's names in each bank:
;   ID   bank $02               bank $0A
;   $00  (nothing - queued as a placeholder)
;   $01  SFX_UFO                SFX_UFO
;   $02  SFX_Explode            SFX_Explode
;   $03  SFX_Electricity        SFX_Electricity
;   $04  SFX_Shoot              SFX_Shoot
;   $05  SFX_EnemyShoot         SFX_EnemyShoot
;   $06  SFX_PlayerHit          SFX_PlayerHit
;   $07  SFX_Click              SFX_Click
;   $08  SFX_Land               SFX_Land
;   $09  SFX_EnemyHit           SFX_EnemyHit
;   $0A  SFX_Deflect            SFX_Deflect
;   $0B  SFX_Select             SFX_Select
;   $0D  SFX_Door2              SFX_Door2
;   $0E  SFX_CutAttack          SFX_CutAttack
;   $0F  SFX_PlayerExplode      SFX_PlayerExplode
;   $10  SFX_ExtraLife          SFX_ExtraLife
;   $11  SFX_Wheel              SFX_Wheel
;   $12  SFX_Health             SFX_Health
;   $13  SFX_Empty1             SFX_Empty1
;   $14  SFX_Empty2             SFX_Empty2
;   $19  Boss                   Boss
;   $1B  SFX_IceAttack          SFX_IceAttack
;   $1C  SFX_FireAttack         SFX_FireAttack
;   $1D  SFX_ElecAttack         SFX_ElecAttack
;   $1E  SFX_Block              SFX_Block
;   $1F  SFX_BigEye             SFX_BigEye
;   $21  SFX_Teleport           SFX_Teleport
;   $24  DoNotUse23             StageStart
;   $26  DoNotUse25             StageSelect
;   $27  WilyIntro              WilyIntro
;   $28  DoNotUse27             EndGame
;   $29  DoNotUse28             GetWeapon
;   $2A  DoNotUse29             Title
;   $2B  SFX_Shing              SFX_Shing
;   $2E  EndGameAlt             Password
QueueSound::	;$03CD
	push hl
	push de
	ld d,a
	ld hl,wSoundQueue
	ld a,[hl]
	cp $14
	jr z,.next
	inc [hl]
	inc hl
	add l
	ld l,a
	ld a,h
	adc 0
	ld h,a
	ld [hl],d
.next
	pop de
	pop hl
	ret

;$03E4: start this frame's queued sound. Empties wSoundQueue, keeping the queued
;sound with the highest header priority (later wins a tie; PickQueuedSound), then
;loads only that one (StartPickedSound). Called by DelayFrame and DelayFrameWithSprites, so once
;per main-loop frame, with bank $01 paged in.	;[ok]
DrainSoundQueue: ; $3E4
	push hl
	push de
	push bc
	ld hl,wSoundQueue
	ld a,[hl]
	ld [hl],0
	inc hl
	add l
	ld d,a
.loop
	ld a,l
	cp d
	jr z,.next
	ld a,[hli]
	push hl
	push de
	call PickQueuedSound
	pop de
	pop hl
	jr .loop
.next
	call StartPickedSound
	pop bc
	pop de
	pop hl
	ret

;$0405: run the audio update (PlayAudio, $400F) from the main loop. Used only by
;bank $01's stage-intro sequence and weapon-get screen, which hold wAudioLock so
;that VBlank skips its own call: the music advances once per loop iteration
;instead, one DelayFrame each, so at the same rate (checked in an emulator).
;Unlike the VBlank path it does not touch wAudioLock itself.	;[ok]
RunAudioUpdate: ; $405
	ld a,[wCurrentBank]
	push af
	ei
	ld a,[wAudioBank]
	bankswitch
	call $400F
	pop af
	bankswitch
	ret

SECTION "Sound Queue Drain", ROM0[$07DD]

;$07DD: sound ID A (SoundTab index + 1; 0 = nothing): look its header up in the
;audio bank ($4013 + 2*A) and keep it in wQueuedSoundPtr if its priority (header
;byte 1) is at least the kept one's. Switches back to bank $01, not the bank it
;was called from: right for every caller (DelayFrame runs with bank $01 paged).	;[ok]
PickQueuedSound:
	or a
	ret Z
	ld [$cc47],a
	push de
	push hl
	ld a,[$cc47]
	ld e,a
	ld d,$00
	ld hl,$4013
	add hl,de
	add hl,de
	ld a,[wAudioBank]
	bankswitch
	ldi a,[hl]
	ld h,[hl]
	ld l,a
	ld a,$01
	bankswitch
	push hl
	inc hl
	ld a,[hl]
	ld e,a
	ld a,[wQueuedSoundPtr]
	ld l,a
	ld a,[wQueuedSoundPtr+1]
	ld h,a
	or l
	jr Z,.next1
	inc hl
	ld a,e
	cp [hl]
	jr nC,.next1
	pop hl
	jr .next2
.next1
	pop hl
	ld a,h
	ld [wQueuedSoundPtr+1],a
	ld a,l
	ld [wQueuedSoundPtr],a
.next2
	pop hl
	pop de
	ret

;$0826: load the sound picked this frame, if any, and clear the pick.	;[ok]
StartPickedSound:
	ld a,[wQueuedSoundPtr]
	ld l,a
	ld a,[wQueuedSoundPtr+1]
	ld h,a
	or l
	call nz,AudioLoadSound
	xor a
	ld [wQueuedSoundPtr],a
	ld [wQueuedSoundPtr+1],a
	ret

;$083A: stop every slot except wMusicSlot (it tries 1-9; only 1-4 exist) and empty
;the sound queue. No caller in the ROM (docs/UNUSED.md).	;[ok]
StopAllButMusic:
	ld a,[wMusicSlot]
	ld b,a
	ld c,1
.loop
	ld a,c
	cp b
	push bc
	ld [wAudioStopSlot],a
	call nz,AudioStopSlot
	pop bc
	inc c
	ld a,c
	cp $A
	jr c,.loop
	xor a
	ld [wSoundQueue],a
	ret
