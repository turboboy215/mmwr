;Mega Man: Dr. Wily's Revenge disassembly - the weapon-get screen
;Part of ROM bank $01 (step 5.1). Every section is pinned to its original
;address, so the include order in banks/bank01.asm does not affect the ROM.
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Weapon Get Screen", ROMX[$62D1], BANK[$1]

;The weapon-get screen after a boss: music $29, scroll the picture in, type
;the text, award the weapon (WeaponAwardBits) - and after the fourth robot
;master, Carry too ("AND CARRY").	;[ok]
WeaponGet:	;$62D1
	ld a, $00
	ld [wShadowBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	xor a
	ld [wShadowSCY], a
	ldh [rSCY], a
	ld a, $0A
	ld [wAudioBank], a
	ld a, $29
	call QueueSound
	ld a, $FF
	ld [wAudioLock], a
	di
	ld a, $03
	ld [wShadowLCDC], a
	call DisableLCD
	call HideAllSpritesAlt
	call LoadWeaponGetScreen
	ld a, $E4
	ld [wShadowBGP], a
	ld a, $F8
	ld [wShadowSCX], a
	ldh [rSCX], a
	xor a
	ld [wScreenCounter], a
	ldh [rIF], a
	ld a, $01
	ldh [rIE], a
	call EnableLCD
	ei
.l6318
	call RunAudioUpdate
	call DelayFrame
	ld a, [wScreenCounter]
	inc a
	cp $78
	jr nc, .l632B
	ld [wScreenCounter], a
	jr .l6318
.l632B
	call RunAudioUpdate
	call DelayFrame
	ld a, [wShadowSCX]
	sub $02
	ld [wShadowSCX], a
	cp $62
	jr z, .l633F
	jr .l6318
.l633F
	xor a
	ld [wScreenCounter], a
	ld [$CCF7], a
	ld [$CCF8], a
	ld [$CCFC], a
.l634C
	call RunAudioUpdate
	call DelayFrame
	ld a, [$CCFC]
	or a
	jr nz, .l6363
	ld a, [wScreenCounter]
	or a
	jr nz, .l637D
	call TypeYouGot
	jr .l637D
.l6363
	dec a
	jr nz, .l6371
	ld a, [wScreenCounter]
	or a
	jr nz, .l637D
	call TypeWeaponNameLine1
	jr .l637D
.l6371
	dec a
	jr nz, .l6388
	ld a, [wScreenCounter]
	or a
	jr nz, .l637D
	call TypeWeaponNameLine2
.l637D
	ld a, [wScreenCounter]
	inc a
	and $07
	ld [wScreenCounter], a
	jr .l634C
.l6388
	ld hl, wScreenCounter
	inc [hl]
	ld a, [hl]
	cp $3C
	jr z, .l63CD
	cp $B4
	jr c, .l634C
	xor a
	ld [wScreenCounter], a
	ld [wShadowSCX], a
	ld a, [wWilyStageSet]
	or a
	jr nz, .l63A7
	ld a, [wSelectedStage]
	jr .l63AC
.l63A7
	ld a, [wHubTeleporter]
	add a, $04
.l63AC
	ld hl, WeaponAwardBits - 2
	ld b, $00
	ld c, a
	add hl, bc
	add hl, bc
	ld a, [wWeaponsUnlocked1]
	or [hl]
	ld [wWeaponsUnlocked1], a
	inc hl
	ld a, [wWeaponsUnlocked2]
	or [hl]
	ld [wWeaponsUnlocked2], a
	xor a
	ld [wAudioLock], a
	ld a, $02
	ld [wAudioBank], a
	ret
.l63CD
	ld a, [wBossesDefeated]
	cp $0F
	jr nz, .l63F4
	ld a, [wWeaponsUnlocked1]
	or $20
	ld [wWeaponsUnlocked1], a
	ld hl, AndText
	ld de, $992D
	ld bc, $0003
	call CopyVRAM
	ld hl, CarryText
	ld de, $994D
	ld bc, $0005
	call CopyVRAM
.l63F4
	jp .l634C

;"AND" and "CARRY", ASCII + $80, typed on the weapon-get screen after the
;last robot master. The award table below starts inside "CARRY": it is
;indexed from $63FD, one-based.	;[ok]
AndText:	;$63F7
	SETCHARMAP getscreen
	db "AND"
	SETCHARMAP main

CarryText:	;$63FA
	SETCHARMAP getscreen
	db "CARRY"
	SETCHARMAP main

;Weapon unlock bits awarded per stage (1-4) and per Wily teleporter (5-9):
;dw wWeaponsUnlocked1 | wWeaponsUnlocked2 << 8.	;[ok]
WeaponAwardBits:	;$63FF
	dw $0002, $0008, $0004, $0010
	dw $0100, $0200, $0080, $0040
	dw $0400
