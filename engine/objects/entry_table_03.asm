;Mega Man: Dr. Wily's Revenge disassembly - bank $03's entry table
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Bank 3 Entry Table", ROMX[$4000], BANK[$3]

Entry_03_4000:	;$4000
	jp CuttingWheelRoutine

Entry_03_4003:	;$4003
	jp SuperCutterRoutine

Entry_03_4006:	;$4006
	jp ScrewDriverRoutine

Entry_03_4009:	;$4009
	jp GabyoallRoutine

Entry_03_400C:	;$400C
	jp BigeyeRoutine

Entry_03_400F:	;$400F
	jp BunbyHeliRoutine

Entry_03_4012:	;$4012
	jp FanRoutine

Entry_03_4015:	;$4015
	jp IcePlatformRoutine

Entry_03_4018:	;$4018
	jp AppearingBlockRoutine

Entry_03_401B:	;$401B
	jp SuzyRoutine

Entry_03_401E:	;$401E
	jp ElectricBeamRoutine

Entry_03_4021:	;$4021
	jp IcicleRoutine

Entry_03_4024:	;$4024
	jp CutManRoutine

Entry_03_4027:	;$4027
	jp CutManRollingCutterRoutine

Entry_03_402A:	;$402A
	jp IceManRoutine

Entry_03_402D:	;$402D
	jp IceManIceSlasherRoutine

Entry_03_4030:	;$4030
	jp ElecManRoutine

Entry_03_4033:	;$4033
	jp ElecManShotRoutine

Entry_03_4036:	;$4036
	jp FireManRoutine

Entry_03_4039:	;$4039
	jp FireManFireStormRoutine

Entry_03_403C:	;$403C
	jp MetallRoutine

Entry_03_403F:	;$403F
	jp MoleRoutine
