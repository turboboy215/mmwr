;Mega Man: Dr. Wily's Revenge disassembly - bank $0D's copy of the queued tile copy
;Part of ROM bank $0D (step 5.6), included from banks/bank0d.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Tile Copy 0D", ROMX[$471D], BANK[$D]

;Set up a chunked copy of BC bytes from HL to DE, A bytes at a time, for
;CopyQueuedTiles_0D. Byte-identical to bank $08's QueueTileCopy. The Wily Machine
;streams its background tiles in with the pair.	;[ok]
QueueTileCopy_0D:	;$471D
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

;Copy the next chunk of the queued copy through JumpCopyVRAM. As bank $08's
;CopyQueuedTiles, plus a `scf` (as in banks $0B and $0E): returns carry when it
;copied a chunk, NC when nothing was left.	;[ok]
CopyQueuedTiles_0D:	;$4739
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
	jr z, .l478E
	ld a, b
	or a
	jr nz, .l4753
	ld a, c
	cp h
	jr c, .l4756
.l4753
	ld c, h
	ld b, $00
.l4756
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
	scf
.l478E
	ret
