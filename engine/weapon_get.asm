;Mega Man: Dr. Wily's Revenge disassembly - weapon-get screen
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Weapon Get", ROM0[$20F2]

;Load the weapon-get screen (Mega Man in cutaway): the menu font to $8A00,
;its own tiles to $9000 and $8800, and its 32x18 map to $9800. Called from bank
;$01 at $1:62FB.	;[ok]
LoadWeaponGetScreen:
	ld a,$06
	bankswitch
	ld de,$8a00
	ld hl,GfxRef_MenuFont
	call GetGfxBlock
	call FuncFill
	ld de,VRAM_TILES2
	ld hl,GfxRef_WeaponGet
	call GetGfxBlock
	call FuncFill
	ld de,VRAM_TILES1
	ld hl,GfxRef_WeaponGetExtra
	call GetGfxBlock
	call FuncFill
	ld de,TILEMAP0
	ld hl,GfxRef_WeaponGetTilemap
	call GetGfxBlock
	call FuncFill
	ld a,$01
	bankswitch
	ret

;The weapon-get screen's typing, one letter per call from bank $01's loop
;(every 8 frames). TypeYouGot writes letter $CCF7 of "YOU GOT" to the BG map
;and counts $CCF7 on; at the $00 it resets $CCF7 and moves the screen's phase
;($CCFC) on. The two name typers below do the same for the weapon's two lines,
;entering at .typeLetter.	;[ok]
TypeYouGot:	;$2133
	ld a,[$ccf7]
	ld de,TILEMAP0 + $08D
	ld b,$00
	ld c,a
	ld hl,YouGotText
.typeLetter	;$213F, also entered by the two weapon-name typers
	add hl,bc
	add e
	ld e,a
	ld a,[hl]
	or a
	jr Z,.next
	ld [de],a
	ld a,[$ccf7]
	inc a
	ld [$ccf7],a
	ret
.next
	xor a
	ld [$ccf7],a
	ld a,[$ccfc]
	inc a
	ld [$ccfc],a
	ret

;A = which weapon the screen shows, one-based: wSelectedStage for a robot
;master, or wHubTeleporter + 4 in the Wily castle (wWilyStageSet set).	;[ok]
GetWeaponGetEntry:	;$215B
	ld a,[wWilyStageSet]
	or a
	jr nz,.next
	ld a,[wSelectedStage]
	ret
.next
	ld a,[wHubTeleporter]
	add 4
	ret

;Type the next letter of the weapon name's first / second line.	;[ok]
TypeWeaponNameLine1:	;$216B
	call GetWeaponGetEntry
	dec a
	sla a
	ld b,$00
	ld c,a
	ld hl,WeaponNameLine1Ptrs
	add hl,bc
	ldi a,[hl]
	ld h,[hl]
	ld l,a
	ld a,[$ccf7]
	ld de,TILEMAP0 + $0CD
	ld b,$00
	ld c,a
	jp TypeYouGot.typeLetter

TypeWeaponNameLine2:	;$2187
	call GetWeaponGetEntry
	dec a
	sla a
	ld b,$00
	ld c,a
	ld hl,WeaponNameLine2Ptrs
	add hl,bc
	ldi a,[hl]
	ld h,[hl]
	ld l,a
	ld a,[$ccf7]
	ld de,TILEMAP0 + $0ED
	ld b,$00
	ld c,a
	jp TypeYouGot.typeLetter

;Weapon names for the weapon-get screen, first and second line, one entry per
;stage in the order of wSelectedStage (one-based - the readers subtract one):
;the four robot masters, then five for the Wily castle, picked by wHubTeleporter + 4.	;[ok]
WeaponNameLine1Ptrs:
	dw WeaponName_Rolling
	dw WeaponName_Ice
	dw WeaponName_Thunder
	dw WeaponName_Fire
	dw WeaponName_Quick
	dw WeaponName_Bubble
	dw WeaponName_Time
	dw WeaponName_Atomic
	dw WeaponName_Mirror
WeaponNameLine2Ptrs:
	dw WeaponName_Cutter
	dw WeaponName_Slasher
	dw WeaponName_Beam
	dw WeaponName_Storm
	dw WeaponName_Boomerang
	dw WeaponName_Lead
	dw WeaponName_Stopper
	dw WeaponName_Fire2
	dw WeaponName_Buster

;$21C7: the weapon-get screen's text, typed out a letter per frame. "YOU GOT"
;first, then each weapon name as two $00-terminated lines, in the getscreen
;charmap (constants/charmap.inc). Step 1.5's sweep missed these because they use
;a third encoding.	;[ok]
SETCHARMAP getscreen
YouGotText:	db "YOU GOT", 0	;$21C7
WeaponName_Rolling:	db "ROLLING", 0	;$21CF
WeaponName_Cutter:	db "CUTTER", 0	;$21D7
WeaponName_Ice:	db "ICE", 0	;$21DE
WeaponName_Slasher:	db "SLASHER", 0	;$21E2
WeaponName_Thunder:	db "THUNDER", 0	;$21EA
WeaponName_Beam:	db "BEAM", 0	;$21F2
WeaponName_Fire:	db "FIRE", 0	;$21F7
WeaponName_Storm:	db "STORM", 0	;$21FC
WeaponName_Quick:	db "QUICK", 0	;$2202
WeaponName_Boomerang:	db "BOOMERANG", 0	;$2208
WeaponName_Time:	db "TIME", 0	;$2212
WeaponName_Stopper:	db "STOPPER", 0	;$2217
WeaponName_Bubble:	db "BUBBLE", 0	;$221F
WeaponName_Lead:	db "LEAD", 0	;$2226
WeaponName_Atomic:	db "ATOMIC", 0	;$222B
WeaponName_Fire2:	db "FIRE", 0	;$2232
WeaponName_Mirror:	db "MIRROR", 0	;$2237
WeaponName_Buster:	db "BUSTER", 0	;$223E
SETCHARMAP main
