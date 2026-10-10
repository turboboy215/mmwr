;Mega Man: Dr. Wily's Revenge disassembly - object type 54, FlashManFreeze
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "FlashManFreeze (type 54)", ROMX[$7239], BANK[$9]

;Type 54: never placed; spawned by Flash Man (FlashManSpawnFreeze). For 90
;frames it sets wFreezeFlags bit 4, which stops Mega Man (StopPlayer) - cleared
;while he is being hurt - and draws eight one-tile sprites at fixed screen
;positions, cycling three layouts. Then, or when killed, it frees them, clears
;bit 4 and is removed.	;[ok]
;Flash Man freezing Mega Man is his Time Stopper.	;[?]
FlashManFreezeRoutine:	;$7239
	ld a, b
	or a
	jr z, FlashManFreezeInit
	dec a
	jr z, FlashManFreezeUpdate
	dec a
	jr z, FlashManFreezeRemove
	dec a
	jr z, FlashManFreezeUpdate

FlashManFreezeRemove:	;$7246
	ld a, $2F
	add a, c
	ld l, a
	ld b, $08
.l724C
	ld a, [hl+]
	push hl
	push bc
	call JumpFreeSprite
	pop bc
	pop hl
	dec b
	jr nz, .l724C
	ld a, [wFreezeFlags]
	res 4, a
	ld [wFreezeFlags], a
	ld b, $00
	ret

;Unused: a jr to FlashManFreezeUpdate that nothing reaches.	;[ok]
Unused_09_7262:	;$7262
	jr FlashManFreezeUpdate

FlashManFreezeInit:	;$7264
	ld a, $2F
	add a, c
	ld l, a
	ld b, $08
.l726A
	push hl
	push bc
	ld a, $01
	call JumpAllocSprite
	pop bc
	pop hl
	ld [hl+], a
	dec b
	jr nz, .l726A
	ld de, Data_09_73A7
	call AnimateObject_09
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $5A
	ret

FlashManFreezeUpdate:	;$728A
	ld a, [wFreezeFlags]
	and $01
	jp nz, .l72EA
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $20
	ld a, [$D838]
	ld b, a
	ld a, [wHurtTimer]
	or b
	jr z, .l72AC
	ld a, [wFreezeFlags]
	res 4, a
	ld [wFreezeFlags], a
	jr .l72B4
.l72AC
	ld a, [wFreezeFlags]
	set 4, a
	ld [wFreezeFlags], a
.l72B4
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, FlashManFreezeRemove
	dec [hl]
	ld de, Data_09_73A7
	call AnimateObject_09
	ld a, $17
	add a, c
	ld l, a
	ld a, [hl]
	cp $03
	jr nz, .l72E4
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l72EA
	ld [hl], $01
	ld a, $29
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $03
	jr c, .l72EA
	ld [hl], $00
	jr .l72EA
.l72E4
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
.l72EA
	ld a, $10
	ld [$D3EA], a
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CE55], a
	ld a, $01
	ld [$CE57], a
	ld a, $17
	add a, c
	ld l, a
	ld a, [hl]
	and $03
	ld de, Frame_73B9 + 4
	jr z, .l7317
	dec a
	ld de, Frame_73C2 + 4
	jr z, .l7317
	dec a
	ld de, Frame_73CB + 4
	jr z, .l7317
	ld de, Frame_73D4 + 4
.l7317
	ld a, e
	ld [$CC15], a
	ld a, d
	ld [$CC16], a
	ld d, h
	ld a, $2F
	add a, c
	ld e, a
	push hl
	ld a, $29
	add a, c
	ld l, a
	ld a, [hl]
	ld hl, FlashManFreezeLayouts
	call JumpGetTablePointer
	ld b, $08
.l7332
	ld a, [hl+]
	ldh [$FFA2], a
	ld a, [hl+]
	ldh [$FFA3], a
	push bc
	push hl
	ld a, [$CC15]
	ld l, a
	ld a, [$CC16]
	ld h, a
	ld a, [de]
	inc de
	push de
	call JumpDrawMetasprite
	pop de
	pop hl
	pop bc
	dec b
	jr nz, .l7332
	pop hl
	ld b, $01
	ret

FlashManFreezeLayouts:	;$7352
	dw Data_09_7377, Data_09_7387, Data_09_7397

FlashManSpawnFreeze:	;$7358
	ld a, $2B
	call JumpQueueSound
	ld l, c
	push hl
	ld a, $36
	ld [$CC07], a
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	add a, $56
	ld [$CC05], a
	call SpawnChildObject_09
	call FlashManFreezeInit
	pop hl
	ld c, l
	ret

Data_09_7377:	;$7377
	db $97, $10
	db $80, $40
	db $78, $50
	db $70, $18
	db $58, $70
	db $30, $68
	db $28, $5A
	db $10, $60
Data_09_7387:	;$7387
	db $90, $30
	db $88, $50
	db $60, $28
	db $50, $52
	db $38, $38
	db $38, $62
	db $20, $30
	db $10, $52
Data_09_7397:	;$7397
	db $80, $28
	db $78, $70
	db $68, $58
	db $50, $38
	db $40, $20
	db $40, $50
	db $28, $08
	db $10, $18

Data_09_73A7:	;$73A7
	dw FrameTable_73B1
	db 2	;frames per step
	db $03, $02, $01, $00, $01, $02, $FF

FrameTable_73B1:	;$73B1
	dw Frame_73B9, Frame_73C2, Frame_73CB, Frame_73D4

Frame_73B9:	;$73B9
	db $00, $00, $00, $00	;hitbox
	db $FC, $FD, $11	;dx, dy, 1x1
	db $00
	db $80

Frame_73C2:	;$73C2
	db $00, $00, $00, $00	;hitbox
	db $FC, $FD, $11	;dx, dy, 1x1
	db $01
	db $80

Frame_73CB:	;$73CB
	db $00, $00, $00, $00	;hitbox
	db $FC, $FD, $11	;dx, dy, 1x1
	db $02
	db $80

Frame_73D4:	;$73D4
	db $00, $00, $00, $00	;hitbox
	db $FC, $FD, $11	;dx, dy, 1x1
	db $FF
	db $80
