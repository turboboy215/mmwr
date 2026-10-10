;Mega Man: Dr. Wily's Revenge disassembly - object type 26, KaminariGoroShot
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "KaminariGoroShot (type 26)", ROMX[$50E8], BANK[$9]

;Kaminari Goro's shot (named from the code).	;[ok]
;Object type 26: never placed; type 14's shot (KaminariGoroThrowerSpawnShot points its
;$28/$29 at the thrower's $28 and runs KaminariGoroShotInit). Moves 1.5 px a frame the way
;it faces; Time Stopper holds it. Off screen: removed, writing $A5 to the
;thrower's $28. Killed: removed without telling the thrower. There is no mode 0
;case.	;[ok]
KaminariGoroShotRoutine:	;$50E8
	ld a, b
	dec a
	jr z, KaminariGoroShotUpdate
	dec a
	jr z, KaminariGoroShotRemove
	dec a
	jr z, KaminariGoroShotClearFreeze

;Remove the object (B = 0). Also the jump target KaminariGoroThrowerCheckParent
;uses to remove the thrower.	;[ok]
KaminariGoroShotRemove:	;$50F2
	ld b, $00
	ret

;Mode 3: ObjClearFreeze (B = 1) ends Ice Slasher's freeze at once.	;[ok]
KaminariGoroShotClearFreeze:	;$50F5
	jp ObjClearFreeze_09

KaminariGoroShotInit:	;$50F8
	ld a, $24
	add a, c
	ld l, a
	ld d, [hl]
	ld a, $17
	add a, c
	ld l, a
	ld [hl], d
	ld a, $15
	add a, c
	ld l, a
	ld [hl], LOW(Data_09_514D)
	inc l
	ld [hl], HIGH(Data_09_514D)
	jr KaminariGoroShotCheckOnScreen

KaminariGoroShotUpdate:	;$510D
	ld a, [wFreezeFlags]
	or a
	jp nz, KaminariGoroShotCheckOnScreen
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	ld de, $0180
	or a
	jr nz, .l5122
	ld de, $FE80
.l5122
	ld a, $0C
	add a, c
	ld l, a
	ld a, [hl]
	add a, e
	ld [hl+], a
	ld a, [hl]
	adc a, d
	ld [hl], a

;Update the stage X from the screen X and the scroll (as
;ObjSyncAndCheckOnScreen), ObjCheckOnScreen; when it goes off screen, write $A5
;to the thrower's $28 (pointer in this object's $28/$29) so it can throw again.	;[ok]
KaminariGoroShotCheckOnScreen:	;$512C
	ld de, $D811
	ld a, $0D
	add a, c
	ld l, a
	ld a, [de]
	ld e, [hl]
	add a, [hl]
	ld d, a
	ld a, $0A
	add a, c
	ld l, a
	ld [hl], d
	call ObjCheckOnScreen_09
	ld a, b
	or a
	ret nz
	ld a, $28
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	ld a, $A5
	ld [de], a
	ret

Data_09_514D:	;$514D
	dw Frame_5085, Frame_508F
