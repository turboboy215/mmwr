;Offsets inside an object record.
;
;Records are addressed as `ld a,OBJ_xxx / add a,c / ld l,a` with H fixed, so the
;array is page-aligned and a record cannot cross a page. $CC40/$CC41 hold the
;pointer to the record being processed.
;
;Only the fields actually traced are named. A scan of every
;`ld a,$NN / add a,c / ld l,a` site finds accesses at 60 distinct offsets from
;$00 to $3F, so a record is on the order of $40 bytes; the heavily-used ones are
;$09, $0A, $0D, $0F, $17, $27 and $28. Naming those is object-engine work
;(Phase 5), not part of this step.

if !def(OBJ_FLAGS)
;Bit 3 is set or cleared by the timer logic at $2893/$289D.	;[?]
def OBJ_FLAGS   equ $11

;The object's frame table, little-endian: a list of pointers to frames (a
;4-byte hitbox, then a DrawMetasprite metasprite). Read at $2A66 for the hitbox
;and by the draw code. Step 5.2 showed it is not a code pointer, as first
;thought (it was named OBJ_HANDLER).	;[ok]
def OBJ_FRAMES  equ $15

;The current frame: an index into OBJ_FRAMES, doubled and added at $2A6F
;(formerly OBJ_HANDLER_IDX).	;[ok]
def OBJ_FRAME   equ $17

;The ROM bank the handler lives in. Read and paged in at $28A3 and $2A5B. This
;is the only route to banks $03, $09 and $0D - see ObjectTypeTab and
;docs/BANKS.md.	;[ok]
def OBJ_BANK    equ $1B
endc
