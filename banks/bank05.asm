;Mega Man: Dr. Wily's Revenge disassembly - ROM bank $05
;The four robot master stages: Cut Man, Ice Man, Fire Man and Elec Man. Each is
;a stage header, restart points, checkpoints, rooms, a little per-stage code,
;room layouts, a blockset and a collision table, in that order - one file per
;stage under data/stages/, written with the macros in macros/stages.inc. The
;format is in docs/LEVELS.md and tools/leveldump.py renders it.
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?]
;unverified guess. See docs/CONVENTIONS.md.

SECTION "bank5", ROMX[$4000], BANK[$5]

;The stage pointers LoadStage reaches through the ROM0 slots $033B-$0341.
;Bank order is Cut, Ice, Fire, Elec; StageLoadTab's is Cut, Ice, Elec, Fire.	;[ok]
StagePtr_CutMan:	;[dc]
	dw CutManStageData
StagePtr_IceMan:	;[dc]
	dw IceManStageData
StagePtr_FireMan:	;[dc]
	dw FireManStageData
StagePtr_ElecMan:	;[dc]
	dw ElecManStageData

INCLUDE "data/stages/cut_man.asm"
INCLUDE "data/stages/ice_man.asm"
INCLUDE "data/stages/fire_man.asm"
INCLUDE "data/stages/elec_man.asm"

;$6AAD-$6FFF is not data: from $6AC0 it is 32 bytes of $FF and 32 of $00 in
;turn, the pattern uninitialised memory leaves, with a stray set bit here and
;there (at $6B39, $6B7F, $6BBE, $6D60 and $6F20); $6AAD-$6ABF is the tail of
;one of its $00 runs. Written with uninit_fill (macros/filler.inc); unlike bank
;$04 the $FF runs sit where address bit 5 is clear. Each stray byte is a single
;set bit inside a $00 run. Nothing reads any of it, so a stage that needs to
;grow can delete it. The calls name absolute addresses, so a stage that grows
;past $6B39 trips uninit_fill's ASSERT - delete this block (and its label) then.
;The rest of the bank is $FF, sized to whatever the stages leave.	;[ok]
Unused_05_6AAD:
	uninit_fill $6B39, $FF
	db $01	;stray bit at $6B39
	uninit_fill $6B7F, $FF
	db $80	;stray bit at $6B7F
	uninit_fill $6BBE, $FF
	db $01	;stray bit at $6BBE
	uninit_fill $6D60, $FF
	db $80	;stray bit at $6D60
	uninit_fill $6F20, $FF
	db $80	;stray bit at $6F20
	uninit_fill $7000, $FF

	ds $8000 - @, $FF
