;Mega Man: Dr. Wily's Revenge disassembly - OAM DMA
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "InstallOAMDMA", ROM0[$15D2]

;$15D2: copy OAMDMARoutine into HRAM at hOAMDMA. The transfer blocks the bus,
;so the routine that starts it and waits has to be executing from HRAM.	;[ok]
InstallOAMDMA::	;$15D2
	ld c,LOW(hOAMDMA)
	ld b,OAMDMARoutineEnd - OAMDMARoutine
	ld hl,OAMDMARoutine
.loop
	ld a,[hl+]
	ldh [c],a
	inc c
	dec b
	jr nz,.loop
	ret

;$15E0: the ten bytes that run from HRAM. Starts the transfer, then burns 40
;iterations, which is the 160 cycles the DMA needs.	;[ok]
OAMDMARoutine::	;$15E0
	ld a,HIGH(wShadowOAM)
	ldh [rDMA],a
	ld a,40
.wait
	dec a
	jr nz,.wait
	ret
OAMDMARoutineEnd::
