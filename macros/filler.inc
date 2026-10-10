;uninit_fill END, LOW_BYTE
;Emits the pattern uninitialised memory leaves behind, from @ up to (not including)
;END: each byte is LOW_BYTE where address bit 5 is clear and its complement where
;bit 5 is set, so the fill alternates in 32-byte runs that line up with $20
;boundaries. Banks $04 and $05 carry this left over from the tools that built the
;ROM (nothing reads it); bank $04's runs start with $00 at a $40 boundary
;(LOW_BYTE = $00), bank $05's with $FF (LOW_BYTE = $FF). The few stray set bits
;inside those runs are written between calls as plain db.	;[ok]
MACRO uninit_fill
	ASSERT (\1) >= @, "uninit_fill: END is behind the current address"
	ASSERT (\2) == $00 || (\2) == $FF, "uninit_fill: LOW_BYTE must be $00 or $FF"
	REPT (\1) - @
		IF @ & $20
			db (\2) ^ $FF
		ELSE
			db \2
		ENDC
	ENDR
ENDM
