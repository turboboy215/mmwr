;Mega Man: Dr. Wily's Revenge disassembly - ROM bank $0B
;
;The Wily cutscenes. Bank $00's main flow pages this bank in and calls $4000
;twice in a game, only while $DCD0 is non-zero: before Wily stage 1 is entered,
;and before Wily 3 (wWilyProgress & $1F = $1F). 100% source since step 5.4.
;
;  $4000-$4515  engine/cutscenes/kit_0b.asm: the `jp` to PlayWilyCutscene, then
;               a kit of helpers that bank $0E carries too (its copy is at $4002-
;               $455B); labels end in _0B. About half of it is never called here.
;  $4516-$4921  engine/cutscenes/castle_cutscene.asm: the entry and the first
;               cutscene - the stage select with Dr. Wily in the middle, then
;               (after the saucer scene) Mega Man beaming down at the castle
;  $4922-$4C60  engine/cutscenes/wily_saucer.asm: Wily's saucer on a dark screen
;  $4C61-$4CA5  engine/cutscenes/helpers_0b.asm: tilemap copy and the
;               skippable frame waits of the first cutscene
;  $4CA6-$52F8  engine/cutscenes/wily_stage_select.asm: the stage-select
;               cursor and portrait, their tilemap and sprite tiles
;  $52F9-$55CF  engine/cutscenes/skull_ship_cutscene.asm: the second cutscene -
;               a saucer leaves the castle and flies to the skull ship
;  $55D0-$7FFF  unused, all $FF
;
;Both cutscenes run with bank $0B paged in and reach the bank $00 screen
;loaders through FarCallBank1_0B (see there for why). Each can be skipped with
;A or B, but only after it has been seen once: the first sets $DFCF and the
;second $DFD0 to $FF when they finish. The scenes keep their sprites in 7-byte
;"sprite records" drawn by DrawSpriteRecord_0B, in the shot-state RAM from
;$C200 (wShotCount), which no shot uses outside a stage.
;
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?]
;unverified guess. See docs/CONVENTIONS.md.

include "engine/cutscenes/kit_0b.asm"
include "engine/cutscenes/castle_cutscene.asm"
include "engine/cutscenes/wily_saucer.asm"
include "engine/cutscenes/helpers_0b.asm"
include "engine/cutscenes/wily_stage_select.asm"
include "engine/cutscenes/skull_ship_cutscene.asm"

;$55D0-$7FFF: unused, all $FF.	;[ok]
SECTION "Bank B Free Space", ROMX[$55D0], BANK[$B]
	ds $8000 - $55D0, $FF
