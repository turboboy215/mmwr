;Stage data macros (step 4.2). The format is documented in docs/LEVELS.md; these
;macros write it in a form a person can edit, and assert what they can so a
;broken edit fails the build instead of producing a corrupt stage.
;
;A stage file (data/stages/*.asm) is, in order:
;   <Stage>StageData:      dw restart points, dw checkpoints
;   <Stage>RestartPoints:  dw per restart point
;   <Stage>Checkpoints:    checkpoint ... end_checkpoints
;   restart_point records, room records, the stage's own code,
;   layouts, the blockset and the collision table.

;Exit flag bits, read by BuildExitBox ($3412).
DEF EXIT_SIDE_WALL EQU 1 << 0	;box runs down a side wall; never used in the game
DEF EXIT_FAR_EDGE  EQU 1 << 1	;bottom (or right) edge rather than top (or left)

DEF ROOM_HEIGHT EQU 8	;every room in the game is 8 blocks tall

;restart_point blockset, collision, init, frame_hook, x, y, room
;One 14-byte restart-point record. x and y are Mega Man's start position in
;pixels, x relative to the room's left edge. The leading 0 is skipped by
;LoadRestartPoint and is 0 in every record of the game.
MACRO restart_point
	ASSERT _NARG == 7, "restart_point takes 7 arguments"
	db 0
	dw \1	;blockset
	dw \2	;collision table
	dw \3	;init routine
	dw \4	;frame hook
	dw \5	;Mega Man X
	db \6	;Mega Man Y
	dw \7	;room
ENDM

;checkpoint room_id, unused
;Entering the room with this id makes the checkpoint the restart point. The
;second byte is never read ($04 throughout bank $05).
MACRO checkpoint
	db \1, \2
ENDM

MACRO end_checkpoints
	db $FF
ENDM

;room id, routine, layout, x_offset
;The fixed part of a room record. Follow it with two exits (exit_up, exit_down,
;exit or no_exit), any number of spawns, and end_spawns.
MACRO room
	ASSERT _NARG == 4, "room takes 4 arguments"
	db \1	;id
	dw \2	;routine
	dw \3	;layout
	dw \4	;x offset in the stage, pixels
ENDM

MACRO no_exit
	db 0
ENDM

;exit_down first_column, length, room
;A floor exit: a box along row 7, `length` columns wide.
MACRO exit_down
	ASSERT (\2) >= 1 && (\2) <= 15, "exit length must be 1-15 columns"
	db (\2) << 4 | (ROOM_HEIGHT - 1), \1, EXIT_FAR_EDGE
	dw \3
ENDM

;exit_up first_column, length, room
;A ceiling exit: a box along row 0, `length` columns wide.
MACRO exit_up
	ASSERT (\2) >= 1 && (\2) <= 15, "exit length must be 1-15 columns"
	db (\2) << 4 | 0, \1, 0
	dw \3
ENDM

;exit length_and_row, column, flags, room
;The raw form, for anything exit_up/exit_down cannot express. Unused at present.
MACRO exit
	ASSERT (\1) != 0, "an exit's first byte cannot be 0 (that means no exit)"
	db \1, \2, \3
	dw \4
ENDM

;spawn type, column, y, extra
;One object placement. type is the one-based ObjectTypeTab index, column is in
;blocks within the room, and SpawnObject uses y & $F0 as the pixel row. Spawns
;must be in column order: the activation window walks the list in order.
MACRO spawn
	ASSERT (\1) != 0, "object type 0 would end the spawn list"
	db \1, \2, \3, \4
ENDM

MACRO end_spawns
	db 0
ENDM

;layout width
;    lrow "xx xx xx ..."   ; ROOM_HEIGHT rows, each `width` blocks in hex
;end_layout
;A room layout. Each lrow is one row of block numbers, two hex digits each,
;separated by single spaces, so the rows line up as a picture of the room.
MACRO layout
	ASSERT _NARG == 1, "layout takes the width in blocks"
	db \1, ROOM_HEIGHT
	REDEF LAYOUT_W = \1
	REDEF LAYOUT_ROWS = 0
ENDM

MACRO lrow
	ASSERT FATAL, STRLEN(\1) == LAYOUT_W * 3 - 1, \
		"layout row is not {d:LAYOUT_W} blocks wide (or not 'xx xx ...' hex)"
	FOR LROW_I, LAYOUT_W
		REDEF LROW_HEX EQUS STRSLICE(\1, LROW_I * 3, LROW_I * 3 + 2)
		db ${LROW_HEX}
	ENDR
	PURGE LROW_HEX, LROW_I
	REDEF LAYOUT_ROWS = LAYOUT_ROWS + 1
ENDM

MACRO end_layout
	ASSERT LAYOUT_ROWS == ROOM_HEIGHT, "layout has {d:LAYOUT_ROWS} rows, not {d:ROOM_HEIGHT}"
ENDM

;blockset <Stage>
;    block tl, tr, bl, br    ; one per block, in block-number order
;<Stage>Collision:
;    db ...                  ; one collision byte per block
;<Stage>CollisionEnd:
;The count byte is worked out from the labels, so adding or removing a block
;only means keeping the collision table the same length (asserted).
MACRO blockset
	db (\1Collision - \1Blocks - 1) / 4
	ASSERT (\1Collision - \1Blocks - 1) % 4 == 0
	ASSERT \1CollisionEnd - \1Collision == (\1Collision - \1Blocks - 1) / 4, \
		"\1: the collision table must have one byte per block"
	ASSERT \1CollisionEnd - \1Collision <= 64, "\1: at most 64 blocks (wBlockCollision)"
ENDM

;block top_left, top_right, bottom_left, bottom_right
;Tile numbers as they appear on screen. Stored in the order DrawBlock reads
;them: top left, bottom left, top right, bottom right.
MACRO block
	ASSERT _NARG == 4, "block takes 4 tile numbers"
	db \1, \3, \2, \4
ENDM
