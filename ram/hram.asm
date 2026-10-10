;HRAM layout.
;
;Only addresses actually traced to code are named; docs/RAMMAP.md has the full
;reference tally. Hardware registers ($FF00-$FF7F, plus rIE at $FFFF) are not
;listed here - those come from constants/hardware.inc.

;The OAM DMA routine, which has to run from HRAM because the bus is blocked
;during the transfer. The installer at $15D2 copies 10 bytes from $15E0 here at
;boot, and the VBlank handler calls it as `call $FF80`.	;[ok]
SECTION "OAM DMA", HRAM[$FF80]
hOAMDMA::	ds 10	;$FF80-$FF89

;Joypad state, both written by ReadJoypad ($157D). Bit layout is in
;constants/joypad.inc: buttons in the low nibble, d-pad in the high nibble,
;active high.	;[ok]
SECTION "Joypad", HRAM[$FF8A]
hJoypadHeld::		ds 1	;$FF8A, everything currently down
hJoypadPressed::	ds 1	;$FF8B, the 0 -> 1 edge since the last read

SECTION "Far Call Scratch", HRAM[$FF8C]

;FarCallAudio ($02AD) parks the caller's registers here while it switches banks,
;then reloads them just before jumping to the target. Five bytes, in the order
;A, L, H, E, D.	;[ok]
hFarCallA::	ds 1	;$FF8C
hFarCallL::	ds 1	;$FF8D
hFarCallH::	ds 1	;$FF8E
hFarCallE::	ds 1	;$FF8F
hFarCallD::	ds 1	;$FF90

;Routine index passed to CallBank1Routine ($01F4), held across the push/pop of
;the caller's registers.	;[ok]
hBank1CallIndex::	ds 1	;$FF91

;$FF8A-$FFFB is memset to zero during boot (at $0661, 114 bytes), which is what
;marks it out as the HRAM variable area. $FF80-$FF89 is left alone because the
;OAM DMA routine has already been copied there.	;[ok]
