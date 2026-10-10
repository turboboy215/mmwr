;Mega Man: Dr. Wily's Revenge disassembly - LCD control and frame waits
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "LCD Control", ROM0[$15EA]

;$15EA: turn the LCD off safely. If it is on, wait until LY is inside VBlank
;($91-$96) first - switching it off mid-frame can damage real hardware.	;[ok]
DisableLCD::	;$15EA
	ldh a, [rLCDC]
	and $80
	ret z
.l15EF
	ldh a, [rLY]
	cp $91
	jr c, .l15EF
	cp $97
	jr nc, .l15EF
	ldh a, [rLCDC]
	and $7F
	ldh [rLCDC], a
	ret

;$1600: the stage loop's frame wait. Sleep until the VBlank handler has run,
;as DelayFrame does, then start the next frame's sprites (BeginSpriteFrame) and
;pass queued sounds to the driver (DrainSoundQueue) - DelayFrame does the
;sound first and has no sprite step. Called by StageFrameLoop.	;[ok]
DelayFrameWithSprites:	;$1600
	ldh a, [rLY]
	cp $91
	jr nc, DelayFrameWithSprites
	ei
	xor a
	ld [wVBlankBusy], a
.l160B
	halt
	ld a, [wVBlankBusy]
	or a
	jr z, .l160B
	call BeginSpriteFrame
	jp DrainSoundQueue

;$1618: DrainSoundQueue, then sleep until the VBlank handler has run: wait for LY to
;leave the VBlank lines, clear wVBlankBusy, and `halt` until the handler sets it
;again.	;[ok]
DelayFrame::	;$1618
	call DrainSoundQueue
.l161B
	ldh a, [rLY]
	cp $91
	jr nc, .l161B
	ei
	xor a
	ld [wVBlankBusy], a
.l1626
	halt
	ld a, [wVBlankBusy]
	or a
	jr z, .l1626
	ret

;$162E: busy-wait for LY to reach line 0.	;[ok]
WaitForLY0::	;$162E
	ei
	ldh a, [rLY]
	or a
	jr nz, WaitForLY0
	ret

;$1635: busy-wait for LY to equal L.	;[ok]
WaitForLYL::	;$1635
	ei
	ldh a, [rLY]
	cp l
	jr nz, WaitForLYL
	ret

;$163C: DE = -DE.	;[ok]
NegateDE::	;$163C
	ld a, e
	cpl
	ld e, a
	ld a, d
	cpl
	ld d, a
	inc de
	ret

;$1645 / $164C / $1654: switch the LCD on with the background only, the sprites
;only, or both. Only the last waits for VBlank, and only if the LCD is already on;
;the first two write rLCDC immediately.	;[ok]
EnableLCDBG::	;$1645
	ld a, LCDC_ON | LCDC_BG_ON
	ld [wShadowLCDC], a
	ldh [rLCDC], a
	ret
EnableLCDOBJ::	;$164C
	ld a, LCDC_ON | LCDC_OBJ_ON
	ld [wShadowLCDC], a
	ldh [rLCDC], a
	ret

EnableLCD::	;$1654
	ld a, LCDC_ON | LCDC_OBJ_ON | LCDC_BG_ON
	ld [wShadowLCDC], a
	ld b, a
	ldh a, [rLCDC]
	and $80
	jr z, .l166A
.l1660
	ldh a, [rLY]
	cp $91
	jr c, .l1660
	cp $97
	jr nc, .l1660
.l166A
	ld a, b
	ldh [rLCDC], a
	ret

;$166E: hide all 40 sprites by setting their Y to $A0. Does exactly what
;HideAllSprites at $2F83 does, written slightly differently (B and C packed into
;one `ld bc`). Followed by a stray `ret` that nothing can reach. Both are notes
;for the Phase 6 tally.	;[ok]
HideAllSpritesAlt::	;$166E
	ld hl, wShadowOAM
	ld de, $0004
	ld bc, $28A0
.l1677
	ld [hl], c
	add hl, de
	dec b
	jr nz, .l1677
	ret
	ret			;unreachable
