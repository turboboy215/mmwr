;Mega Man: Dr. Wily's Revenge disassembly - ROM bank $0D
;
;The third object bank ($03, $09, $0D): code for 9 object types, reached only
;through ObjectTypeTab - Quick Man and his Quick Boomerangs, the Wily Machine
;fight (types 48-52), the hub's teleporter lights and its sign. 100% source
;since step 5.6. The bank is:
;
;  $4000-$401A  the entry table: one `jp` per object type, in ObjectTypeTab
;               order (slot n is the type listed against it there)
;  $401B-$471C  the object library, engine/object_library.asm (shared with
;               banks $03 and $09; its labels end in {OBJBANK}, _0D here)
;  $471D-$478E  copies of bank $08's QueueTileCopy/CopyQueuedTiles (with the
;               `scf` that banks $0B and $0E have), engine/objects/tile_copy_0d.asm
;  $478F-$48D8  helpers the Wily Machine types share: a state pointer at
;               offsets $3E/$3F, the boss-bar fill, the part record
;  $48D9-$5A75  the Wily Machine fight: types 48-52, then their animations,
;               frames and the room's background tiles (wily_machine_data.asm)
;  $5A76-$6310  Quick Man (46), his Quick Boomerang (47), the teleporter light
;               (53) and the teleport system sign (56), each with its data,
;               ending with a direction helper Quick Man and type 47 share
;  $6311-$7FFF  unused, all $FF
;
;Object modes are as in banks $03 and $09: B = 0 spawn, 1 frame, 2 killed, 3
;frozen by Ice Slasher; B = 0 on return removes the object. Quick Man does not
;end his own fight - the three type 47s placed beside him do. Types 48-52 run
;on a state pointer instead of a state number: ObjSetState stores a handler's
;address at offsets $3E/$3F and the frame call jumps there.
;
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?]
;unverified guess. See docs/CONVENTIONS.md.

DEF OBJBANK EQUS "_0D"

include "engine/objects/entry_table_0d.asm"
SECTION "Object Library 0D", ROMX[$401B], BANK[$D]
include "engine/object_library.asm"
include "engine/objects/tile_copy_0d.asm"
include "engine/objects/wily_machine_helpers.asm"
include "engine/objects/wily_machine.asm"
include "engine/objects/wily_machine_lower_cannon.asm"
include "engine/objects/wily_machine_biting_head.asm"
include "engine/objects/wily_machine_cannon_shot.asm"
include "engine/objects/wily_machine_cutting_wheel.asm"
include "engine/objects/wily_machine_data.asm"
include "engine/objects/quick_man.asm"
include "engine/objects/quick_man_quick_boomerang.asm"
include "engine/objects/teleporter_light.asm"
include "engine/objects/teleport_system_sign.asm"
include "engine/objects/get_direction_to_point.asm"

;$6311-$7FFF: unused, all $FF.	;[ok]
SECTION "Bank D Free Space", ROMX[$6311], BANK[$D]
	ds $8000 - $6311, $FF

PURGE OBJBANK
