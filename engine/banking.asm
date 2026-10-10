;Mega Man: Dr. Wily's Revenge disassembly - bank $01 dispatch
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "CallBank1Routine", ROM0[$01F4]

;$01F4: call routine number A from the table below, then restore whatever bank
;was paged in on entry. The target list mixes ROM0 and bank $01 addresses, and
;bank $01 is paged in before the call, so both kinds resolve. The call itself is
;made through a three-byte `jp` that this routine writes into wBank1CallJump -
;a dispatch that could have been a plain jump table, and is worth flagging when
;we come back to weigh up this codebase.	;[ok]
CallBank1Routine::	;$01F4
	ldh [hBank1CallIndex],a
	ld a,[wCurrentBank]
	push af
	push hl
	push de
	ldh a,[hBank1CallIndex]
	ld e,a
	ld d,0
	ld hl,.pointers
	add hl,de
	add hl,de
	ld a,[hli]
	ld [wBank1CallJump + 1],a
	ld a,[hli]
	ld [wBank1CallJump + 2],a
	ld a,$C3 ; jump
	ld [wBank1CallJump],a
	pop de
	pop hl
	ld a,1
	bankswitch
	call wBank1CallJump
	pop af
	bankswitch
	ret

.pointers
	dw AudioStopAll
	dw SpawnExplosionBurst
	dw SpawnDeathExplosion
	dw LoadStageSelectScreen
	dw SpawnExplosion
	dw LoadPasswordScreen
	dw LoadEndingScreen
