;Mega Man: Dr. Wily's Revenge disassembly - ROM bank $08
;The Wily castle: Wily stages 1-3 (one file each under data/stages/), Wily 2's
;teleporter hub and boss rooms, an unreferenced test stage for Wily 2's rooms,
;and the unused alternate Fire Man stage. All in the stage format of
;docs/LEVELS.md, written with macros/stages.inc. Confidence tags: [ok] verified
;here, [dc] corroborated by Data Crystal, [?] unverified guess. See
;docs/CONVENTIONS.md.

SECTION "bank8", ROMX[$4000], BANK[$8]

;The stage pointers LoadStage reaches through the ROM0 slots $03AB-$03B1.	;[ok]
StagePtr_Wily1:
	dw Wily1StageData
StagePtr_Wily2:
	dw Wily2StageData
StagePtr_Wily3:
	dw Wily3StageData
;StageLoadTab index 8 - but nothing ever selects it. See docs/UNUSED.md.	;[ok]
StagePtr_FireManAlt:
	dw FireManAltStageData

;$4008: set up a chunked copy of BC bytes from HL to DE (in VRAM), A bytes at a
;time; each CopyQueuedTiles call then copies one chunk through JumpCopyVRAM. Wily
;1's frame hook uses the pair to stream Wily 2's tiles in over 19 frames while
;the screen is blanked. Bank $0C has an unreferenced byte-for-byte copy of both
;routines ($C:68EE).	;[ok]
QueueTileCopy:
	ld [wTileCopyChunk], a
	ld a, l
	ld [wTileCopySource], a
	ld a, h
	ld [wTileCopySource + 1], a
	ld a, e
	ld [wTileCopyDest], a
	ld a, d
	ld [wTileCopyDest + 1], a
	ld a, c
	ld [wTileCopyLeft], a
	ld a, b
	ld [wTileCopyLeft + 1], a
	ret

;$4024: copy the next chunk of the queued copy, if any is left.	;[ok]
CopyQueuedTiles:
	ld a, [wTileCopyChunk]
	ld h, a
	ld a, [wTileCopyLeft]
	ld c, a
	ld a, [wTileCopyLeft + 1]
	ld b, a
	ld e, c
	ld d, b
	ld a, b
	or c
	jr z, .done
	ld a, b
	or a
	jr nz, .fullChunk
	ld a, c
	cp h
	jr c, .gotLength
.fullChunk
	ld c, h
	ld b, $00
.gotLength
	ld a, e
	sub c
	ld [wTileCopyLeft], a
	ld a, d
	sbc a, b
	ld [wTileCopyLeft + 1], a
	ld a, [wTileCopySource]
	ld l, a
	ld a, [wTileCopySource + 1]
	ld h, a
	ld a, [wTileCopyDest]
	ld e, a
	ld a, [wTileCopyDest + 1]
	ld d, a
	push hl
	push de
	push bc
	call JumpCopyVRAM
	pop bc
	pop de
	pop hl
	add hl, bc
	ld a, l
	ld [wTileCopySource], a
	ld a, h
	ld [wTileCopySource + 1], a
	ld l, e
	ld h, d
	add hl, bc
	ld a, l
	ld [wTileCopyDest], a
	ld a, h
	ld [wTileCopyDest + 1], a
.done
	ret

INCLUDE "data/stages/wily1.asm"
INCLUDE "data/stages/wily2.asm"
INCLUDE "data/stages/wily3.asm"
INCLUDE "data/stages/wily2_test.asm"
INCLUDE "data/stages/fire_man_alt.asm"

;The rest of the bank is $FF, sized to whatever the stages leave.	;[ok]
	ds $8000 - @, $FF
