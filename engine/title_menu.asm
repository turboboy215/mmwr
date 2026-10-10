;Mega Man: Dr. Wily's Revenge disassembly - the title screen
;Part of ROM bank $01 (step 5.1). Every section is pinned to its original
;address, so the include order in banks/bank01.asm does not affect the ROM.
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Title Menu", ROMX[$60AF], BANK[$1]

;$1:60AF: the title screen. Starts the title music (ID $2A, bank $0A), ignores
;input for 120 frames, then waits for Start. Leaves wAudioBank on $02.	;[ok]
TitleScreen:	;$60AF
	di
	xor a
	ldh [rSTAT], a
	ld a, [wShadowLCDC]
	and $7B
	ld [wShadowLCDC], a
	call DisableLCD
	call HideAllSpritesAlt
	call LoadTitleScreen
	call LoadTitleCursor
	ld a, $E4
	ld [wShadowBGP], a
	ld a, $0A
	ld [wAudioBank], a
	ld a, $2A
	call QueueSound
	xor a
	ldh [rIF], a
	ld a, $01
	ldh [rIE], a
	call EnableLCD
	ei
	xor a
	ld [$CC00], a
	ld b, $78
.l60E7
	push bc
	call DelayFrame
	call ReadJoypad
	pop bc
	dec b
	jr nz, .l60E7
.l60F2
	call DelayFrame
	call ReadJoypad
	call UpdateTitleCursor
	ldh a, [hJoypadHeld]
	bit 3, a
	jr z, .l60F2
	call AudioStopAll
	ld a, $02
	ld [wAudioBank], a
	ret

;Load the menu cursor tile and set OBP0.	;[ok]
LoadTitleCursor:	;$610A
	ld a, $E4
	ldh [rOBP0], a
	ld hl, MenuCursorTile
	ld de, VRAM_TILES0
	ld bc, MenuCursorTileEnd - MenuCursorTile
	jp FuncFill

MenuCursorTile:	;$611A
	db $00,$00,$40,$40,$60,$60,$70,$50,$78,$48,$70,$50,$60,$60,$40,$40
MenuCursorTileEnd:

;Title menu: up, down or Select toggle $CC00 (sound $0B) and move the cursor
;sprite between the two lines.	;[ok]
UpdateTitleCursor:	;$612A
	ld hl, $CC00
	ldh a, [hJoypadPressed]
	and $C4
	jr z, .l613F
	ld a, $0B
	call QueueSound
	ld hl, $CC00
	ld a, [hl]
	xor $01
	ld [hl], a
.l613F
	ld a, [hl]
	and $01
	ld e, $60
	jr z, .l6148
	ld e, $68
.l6148
	ld hl, wShadowOAM
	ld [hl], e
	inc l
	ld [hl], $30
	inc l
	ld [hl], $00
	inc l
	ld [hl], $00
	ret
