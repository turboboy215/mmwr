;Mega Man: Dr. Wily's Revenge disassembly - ROM bank $03
;
;One of the three object banks ($03, $09, $0D): code for 22 object types,
;reached only through ObjectTypeTab. 100% source since step 5.3. The bank is:
;
;  $4000-$4041  the entry table: one `jp` per object type, in ObjectTypeTab
;               order
;  $4042-$4743  the object library, engine/object_library.asm (shared with
;               banks $09 and $0D; its labels end in {OBJBANK}, _03 here)
;  $4744-$7BE4  the 22 objects' routines and data, one file per type in
;               engine/objects/, in ROM order: the four robot masters of the
;               first half (Cut Man, Ice Man, Elec Man, Fire Man) with their
;               shots, and the enemies and stage objects of their stages
;  $7BE5-$7FFF  unused, all $FF
;
;Object modes are as in bank $09: B = 0 spawn, 1 frame, 2 killed, 3 frozen by
;Ice Slasher; B = 0 on return removes the object. The robot masters do not end
;their own fights: the shot objects placed beside them do (types 31, 33, 37).
;
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?]
;unverified guess. See docs/CONVENTIONS.md.

DEF OBJBANK EQUS "_03"

include "engine/objects/entry_table_03.asm"
SECTION "Object Library 03", ROMX[$4042], BANK[$3]
include "engine/object_library.asm"
include "engine/objects/cut_man.asm"
include "engine/objects/ice_man.asm"
include "engine/objects/ice_man_ice_slasher.asm"
include "engine/objects/cut_man_rolling_cutter.asm"
include "engine/objects/cutting_wheel.asm"
include "engine/objects/super_cutter.asm"
include "engine/objects/screw_driver.asm"
include "engine/objects/gabyoall.asm"
include "engine/objects/bigeye.asm"
include "engine/objects/elec_man.asm"
include "engine/objects/elec_man_shot.asm"
include "engine/objects/fire_man.asm"
include "engine/objects/fire_man_fire_storm.asm"
include "engine/objects/bunby_heli.asm"
include "engine/objects/fan.asm"
include "engine/objects/ice_platform.asm"
include "engine/objects/appearing_block.asm"
include "engine/objects/suzy.asm"
include "engine/objects/electric_beam.asm"
include "engine/objects/icicle.asm"
include "engine/objects/metall.asm"
include "engine/objects/mole.asm"

;$7BE5-$7FFF: unused, all $FF.	;[ok]
SECTION "Bank 3 Free Space", ROMX[$7BE5], BANK[$3]
	ds $8000 - $7BE5, $FF

PURGE OBJBANK
