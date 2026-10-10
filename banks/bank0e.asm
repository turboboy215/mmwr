;Mega Man: Dr. Wily's Revenge disassembly - ROM bank $0E
;
;The ending. StageFrameLoop.ending in bank $00 pages this bank in and jumps to
;$4000 when a defeated boss's index is 6 (the game's last), and the bank never
;returns: it ends in an endless frame loop on the closing text screen. 100%
;source since step 5.4. The bank is:
;
;  $4000-$455A  engine/ending/kit.asm: the entry jump, then a kit of copies of
;               bank $00/$01 routines (far call to bank $01, LCD off, queued
;               tile copy, scroll and block helpers, frame waits, the sprite
;               system's setup and an 8x16 DrawMetasprite). Bank $0B opens
;               with a near-identical kit; labels here end in _0E.
;  $455B-$4B05  engine/ending/skull_ship.asm: scene 1, the skull ship blows up
;  $4B06-$4FA7  engine/ending/roll_call.asm: scene 2, a shuttle in space, then
;               Mega Man and the enemy roll call
;  $4FA8-$7040  engine/ending/roll_call_data.asm: its script, names, sprites
;               and tiles (gfx/ending/)
;  $7041-$7BAE  engine/ending/corridor.asm: scene 3, Mega Man walks down a
;               corridor with windows on space, then the closing text
;  $7BAF-$7FFF  unused, all $FF
;
;The ending runs with 8x16 sprites (LCDC $87). Its scenes keep their state in
;$CC00-$CC1B, and borrow the object records at $C600-$C7xx and the stage
;engine's scroll and room variables. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] unverified guess. See docs/CONVENTIONS.md.

include "engine/ending/kit.asm"
include "engine/ending/skull_ship.asm"
include "engine/ending/roll_call.asm"
include "engine/ending/roll_call_data.asm"
include "engine/ending/corridor.asm"

;$7BAF-$7FFF: unused, all $FF. (CorridorScene's tile copy reads the first 11 of
;these bytes as the end of its last tile.)	;[ok]
SECTION "Bank E Free Space", ROMX[$7BAF], BANK[$E]
	ds $8000 - $7BAF, $FF
