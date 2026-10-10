;Mega Man: Dr. Wily's Revenge disassembly - VBlank handler
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "VBlank", ROM0[$0675]

;$0675: the VBlank interrupt handler (the vector at $0040 jumps here). Counts
;wFrameCounter and copies the four LCD shadows to the registers. Only if the
;main loop is waiting in DelayFrame (wVBlankBusy clear - on a lag frame it is
;still set) does it set wVBlankBusy, run the OAM DMA routine in HRAM ($FF80) and
;the three queued BG-map copies below - the scrolling column, the
;room-transition row and the HUD - and count wVBlankCount.
;Then the audio update, and wVBlankDone for the main loop.	;[ok]
VBlankHandler:	;$0675
	push af
	push hl
	push de
	push bc
	ld a,[wFrameCounter]
	inc a
	ld [wFrameCounter],a
	ld a,[wShadowSCX]
	ldh [rSCX],a
	ld a,[wShadowSCY]
	ldh [rSCY],a
	ld a,[wShadowLCDC]
	ldh [rLCDC],a
	ld a,[wShadowBGP]
	ldh [rBGP],a
	ld a,[wVBlankBusy]
	or a
	jr nZ,.next1
	ld a,$01
	ld [wVBlankBusy],a
	call $ff80
	call VBlankDrawColumn
	call VBlankDrawRow
	call VBlankCopyHUD
	ld hl,wVBlankCount
	inc [hl]
	jr nZ,.next1
	inc hl
	inc [hl]
.next1
	;The audio update, unless wAudioLock is held (by a driver entry point the main
	;code is in, or by bank $01's stage-intro and weapon-get loops, which run it
	;themselves). Taken around the call; interrupts are re-enabled first, so a
	;VBlank arriving during a long update finds the lock and skips.	;[ok]
	ld a,[wAudioLock]
	or a
	jr nZ,.next2
	dec a
	ld [wAudioLock],a
	ld a,[wCurrentBank]
	push af
	ei
	ld a,[wAudioBank]
	bankswitch
	call $400f	;PlayAudio in the selected audio bank
	pop af
	bankswitch
	ei
	xor a
	ld [wAudioLock],a
.next2
	pop bc
	pop de
	pop hl
	ld a,$01
	ld [wVBlankDone],a
	pop af
	reti

;If a HUD copy is queued at $C102 (QueueHUDCopy, bank $01: a non-zero count
;byte, BG map address, buffer address), clear the flag and copy two rows of 7
;tiles from the buffer (20 bytes apart) to the map (32 apart). The count byte
;only flags the request: 7 tiles are always copied.	;[ok]
VBlankCopyHUD:	;$06E4
	ld hl,$c102
	ld a,[hl]
	or a
	ret Z
	ld [hl],$00
	inc l
	ld e,[hl]
	inc l
	ld d,[hl]
	inc l
	ldi a,[hl]
	ld h,[hl]
	ld l,a
	ld b,$02
.loop
	push bc
	push hl
	ldi a,[hl]
	ld [de],a
	inc e
	ldi a,[hl]
	ld [de],a
	inc e
	ldi a,[hl]
	ld [de],a
	inc e
	ldi a,[hl]
	ld [de],a
	inc e
	ldi a,[hl]
	ld [de],a
	inc e
	ldi a,[hl]
	ld [de],a
	inc e
	ldi a,[hl]
	ld [de],a
	ld hl,$001a
	add hl,de
	ld e,l
	ld d,h
	pop hl
	ld bc,$0014
	add hl,bc
	pop bc
	dec b
	jr nZ,.loop
	ret

;If $D865 is set (QueueScrollColumn), clear it and write the 16 tiles at $DDD0
;down one BG map column from the address in $D866/$D867 - the column of blocks
;scrolling into view.	;[ok]
VBlankDrawColumn:	;$071C
	ld hl,$d865
	ld a,[hl]
	or a
	ret Z
	ld [hl],$00
	inc hl
	ldi a,[hl]
	ld h,[hl]
	ld l,a
	ld de,$ddd0
	ld bc,$0020
	ld a,[de]
	inc e
	ld [hl],a
	add hl,bc
	ld a,[de]
	inc e
	ld [hl],a
	add hl,bc
	ld a,[de]
	inc e
	ld [hl],a
	add hl,bc
	ld a,[de]
	inc e
	ld [hl],a
	add hl,bc
	ld a,[de]
	inc e
	ld [hl],a
	add hl,bc
	ld a,[de]
	inc e
	ld [hl],a
	add hl,bc
	ld a,[de]
	inc e
	ld [hl],a
	add hl,bc
	ld a,[de]
	inc e
	ld [hl],a
	add hl,bc
	ld a,[de]
	inc e
	ld [hl],a
	add hl,bc
	ld a,[de]
	inc e
	ld [hl],a
	add hl,bc
	ld a,[de]
	inc e
	ld [hl],a
	add hl,bc
	ld a,[de]
	inc e
	ld [hl],a
	add hl,bc
	ld a,[de]
	inc e
	ld [hl],a
	add hl,bc
	ld a,[de]
	inc e
	ld [hl],a
	add hl,bc
	ld a,[de]
	inc e
	ld [hl],a
	add hl,bc
	ld a,[de]
	inc e
	ld [hl],a
	ret

;If $D86B is set (QueueTransitionRow), clear it and write the 24 tiles at
;$DDE0 along one BG map row from the address in $D86C/$D86D, wrapping round
;within the 32-tile row - one tile row of the room scrolling in during a
;vertical room transition.	;[ok]
VBlankDrawRow:	;$076E
	ld hl,$d86b
	ld a,[hl]
	or a
	ret Z
	ld [hl],$00
	ld hl,$dde0
	ld a,[$d86c]
	ld e,a
	ld a,[$d86d]
	ld d,a
	ld a,e
	and $e0
	ld c,a
	ld b,$1f
	ld a,$03
.loop
	push af
	ldi a,[hl]
	ld [de],a
	inc e
	ldi a,[hl]
	ld [de],a
	ld a,e
	inc a
	and b
	or c
	ld e,a
	ldi a,[hl]
	ld [de],a
	inc e
	ldi a,[hl]
	ld [de],a
	ld a,e
	inc a
	and b
	or c
	ld e,a
	ldi a,[hl]
	ld [de],a
	inc e
	ldi a,[hl]
	ld [de],a
	ld a,e
	inc a
	and b
	or c
	ld e,a
	ldi a,[hl]
	ld [de],a
	inc e
	ldi a,[hl]
	ld [de],a
	ld a,e
	inc a
	and b
	or c
	ld e,a
	pop af
	dec a
	jr nZ,.loop
	ret

;$07B7-$07BB: two lone `reti`s and a `jp ReadJoypad` that nothing jumps to.
;Unused.	;[ok]
UnusedReti1:	;$07B7
	reti

UnusedReti2:	;$07B8
	reti

UnusedJumpReadJoypad:	;$07B9
	jp ReadJoypad

;The STAT (LYC) handler InstallHUDSplit puts in wRamCode: wait for the next
;HBlank, then switch to the HUD's settings for the rest of the screen - SCX 0,
;SCY from $DF9E, LCDC from $DF9D, BGP from $DF9F.	;[ok]
HUDSplitHandler:	;$07BC
	push af
.loop1
	ldh a,[rSTAT]
	and $03
	jr Z,.loop1
.loop2
	ldh a,[rSTAT]
	and $03
	jr nZ,.loop2
	xor a
	ldh [rSCX],a
	ld a,[$df9e]
	ldh [rSCY],a
	ld a,[$df9d]
	ldh [rLCDC],a
	ld a,[$df9f]
	ldh [rBGP],a
	pop af
	reti
