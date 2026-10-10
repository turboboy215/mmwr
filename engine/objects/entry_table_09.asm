;Mega Man: Dr. Wily's Revenge disassembly - bank $09's entry table
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Bank 9 Entry Table", ROMX[$4000], BANK[$9]

Entry_09_4000:	;$4000
	jp FireBeamRoutine

Entry_09_4003:	;$4003
	jp ChangkeyRoutine

Entry_09_4006:	;$4006
	jp ChangkeyMakerRoutine

Entry_09_4009:	;$4009
	jp DrillunRoutine

Entry_09_400C:	;$400C
	jp KaminariGoroThrowerRoutine

Entry_09_400F:	;$400F
	jp KaminariGoroRoutine

Entry_09_4012:	;$4012
	jp PipiRoutine

Entry_09_4015:	;$4015
	jp ScwormRoutine

Entry_09_4018:	;$4018
	jp ScwormSpawnRoutine

Entry_09_401B:	;$401B
	jp KaminariGoroShotRoutine

Entry_09_401E:	;$401E
	jp PipiEggRoutine

Entry_09_4021:	;$4021
	jp CopipiRoutine

Entry_09_4024:	;$4024
	jp EnkerShotRoutine

Entry_09_4027:	;$4027
	jp EnkerRoutine

Entry_09_402A:	;$402A
	jp SniperJoeRoutine

Entry_09_402D:	;$402D
	jp AtomicFireBlockRoutine

Entry_09_4030:	;$4030
	jp BubbleManRoutine

Entry_09_4033:	;$4033
	jp BubbleManBubbleLeadRoutine

Entry_09_4036:	;$4036
	jp FlashManRoutine

Entry_09_4039:	;$4039
	jp FlashManDefeatWatcherRoutine

Entry_09_403C:	;$403C
	jp HeatManRoutine

Entry_09_403F:	;$403F
	jp HeatManAtomicFireRoutine

Entry_09_4042:	;$4042
	jp FlashManFreezeRoutine

Entry_09_4045:	;$4045
	jp BossDoorRoutine
