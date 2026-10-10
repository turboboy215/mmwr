Data split out of the banks: bank $00's object tables, graphics pointer tables
and font, bank $01's weapon and Mega Man frames (weapon_frames.asm,
megaman_frames.asm, step 5.1), and (since step 4.2) the stages in stages/ - one file per stage,
included from banks/bank05.asm (the robot masters) and banks/bank08.asm (the
Wily castle, the test stage and the alternate Fire Man), written with the macros in
macros/stages.inc. Each stage file also holds that stage's own small routines
(init, room routine, frame hook), since they belong to it and nowhere else.
