;Mega Man: Dr. Wily's Revenge disassembly - ROM bank $0F
;Section layout ported from the iimarckus/megaman skeleton; all labels are this
;project's own. Confidence tags: [ok] verified here, [dc] corroborated by Data
;Crystal, [?] unverified guess. See docs/CONVENTIONS.md.

SECTION "bankF",ROMX[$4000],BANK[$F]

;Bank $0F is empty: all 16,384 bytes are $FF. Nothing switches to it.	;[ok]
	ds $8000 - @, $FF
