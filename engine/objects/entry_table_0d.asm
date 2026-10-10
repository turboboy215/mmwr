;Mega Man: Dr. Wily's Revenge disassembly - bank $0D's entry table
;Part of ROM bank $0D (step 5.6), included from banks/bank0d.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Bank D Entry Table", ROMX[$4000], BANK[$D]

Entry_0D_4000:	;$4000
	jp WilyMachineRoutine

Entry_0D_4003:	;$4003
	jp WilyMachineLowerCannonRoutine

Entry_0D_4006:	;$4006
	jp WilyMachineBitingHeadRoutine

Entry_0D_4009:	;$4009
	jp WilyMachineCannonShotRoutine

Entry_0D_400C:	;$400C
	jp WilyMachineCuttingWheelRoutine

Entry_0D_400F:	;$400F
	jp QuickManRoutine

Entry_0D_4012:	;$4012
	jp QuickManQuickBoomerangRoutine

Entry_0D_4015:	;$4015
	jp TeleporterLightRoutine

Entry_0D_4018:	;$4018
	jp TeleportSystemSignRoutine
