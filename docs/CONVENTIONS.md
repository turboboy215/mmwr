# Conventions

Consistency matters more than elegance here, because a different session writes each
chunk. When in doubt, match the surrounding file.

## Formatting

* Tabs for indentation. Instructions indented one tab; labels at column 0.
* `ld a, [hl]` — space after the comma, lowercase mnemonics and registers.
* Hex uppercase with a `$` prefix: `$FF40`, `$0A`. Decimal only for small counts.
* One blank line between routines. A comment block above each routine describing
  what it does, its inputs and its outputs.
* Address comments (`; $1758`) are welcome on routine entry points while a region is
  fresh; they are noise once the region is fully named, and may be dropped then.

## Naming

| Kind | Style | Example |
|---|---|---|
| Understood routine | `PascalCase`, verb first | `LoadStageTilemap`, `FarCallAudio` |
| Not-yet-understood routine | `Func_BB_AAAA` | `Func_00_1B6B`, `Func_09_4045` |
| Not-yet-understood data | `Data_BB_AAAA` | `Data_00_0D5D` |
| Not-yet-understood pointer | `Ptr_BB_AAAA` | `Ptr_06_4012` |
| Bank entry-table slot | `Entry_BB_AAAA` | `Entry_0D_4000` |
| Local label inside a routine | `.lowercase` | `.loop`, `.done`, `.restoreBank1` |
| Pointer/jump table | `…Ptrs`, `…Tab` | `AudioSoundTabPtrs`, `WeaponTab` |
| Graphics header / tile data | `…GfxHeader`, `…Tiles` | `IceSlasherGfxHeader`, `IceSlasherTiles` |
| Stage data | `…StageData` | `CutManStageData` |
| WRAM label | `w` + `PascalCase` | `wCurrentBank`, `wAudioBank` |
| HRAM label | `h` + `PascalCase` | `hFarCallA` |
| Constant | `SCREAMING_SNAKE` | `MUS_TITLE`, `WEAPON_COUNT` |

`BB` is the **bank in hex**, `AAAA` the **address as the CPU sees it** — so
`Func_09_4045` is at `$4045` when bank `$09` is paged in, which is ROM offset
`$24045`. Carrying the bank in the name means `$4190` in bank `$01` and `$4190` in
bank `$09` never get confused for each other.

These names are **provisional**. Renaming one to something descriptive is always an
improvement — but only once you can say in one sentence what it does.

Use `::` (exported) only for labels referenced from another bank. Everything else
stays single-colon so the linker catches accidental cross-bank references.

### Confidence tags

Every descriptive name carries a tag saying how much to trust it. This matters more
than usual here, because much of the early labelling came from other people's work.

| Tag | Means |
|---|---|
| `;[ok]` | verified in this repo — the bytes were read and the behaviour traced |
| `;[dc]` | corroborated by Data Crystal, but not independently traced here |
| `;[?]` | a guess, usually inherited from the iimarckus skeleton |

A `;[?]` label is a hypothesis wearing a name. Promote it to `;[ok]` when you have
actually checked it, and say in a comment what you checked. Do not promote a label
just because it has been sitting there a while.

Data Crystal documents the *European* ROM — see [ROMMAP.md](ROMMAP.md) — so `;[dc]`
means "their description matched bytes we located ourselves in our own dump", never
"their address was taken on trust".

### Audio is an exception

`audio/bank02.asm` and `audio/bank0a.asm` keep their existing `Audio1_` / `Audio2_`
prefixes and their own RAM label style. They are kept close to Will's standalone
sound-player project so changes can flow between the two. Do not reformat them.

## Replacing an INCBIN

The skeleton covers unknown regions with

```
INCBIN "baserom.gb",$1694,$1758-$1694
```

To disassemble part of a region, split the INCBIN around the new source and keep the
arithmetic in `$start,$end-$start` form so the numbers stay checkable by eye:

```
INCBIN "baserom.gb",$1694,$1758-$1694     ; still unknown
FuncRNG::
	push hl
	...
	ret
INCBIN "baserom.gb",$176F,$1AE3-$176F     ; still unknown
```

`./build.sh` will catch a length that does not add up.

Since step 7.1 no `INCBIN "baserom.gb"` is left in the source. Filler that is noise
rather than a fill (the uninitialised-memory pattern in banks `$04`/`$05`) is written
with `uninit_fill END, LOW_BYTE` from `macros/filler.inc`, with stray bytes as `db`.

## Data over `db` soup

Prefer meaning to bytes. A 256-byte random table is `INCBIN` with a label and a
comment, not 16 lines of `db`. A 12-entry pointer table is 12 `dw` lines with real
names. A tile is a PNG under `gfx/`, turned into `.2bpp` by `rgbgfx` at build time, not
`db $00,$00,$40,$40,…`. Extract with `tools/gfx.py`; the build proves the round trip.

## Stage data

Stages live in `data/stages/<stage>.asm` and use the macros in
`macros/stages.inc` - never raw `db`/`dw` for a structure a macro covers. Labels
are `<Stage>StageData`, `<Stage>RestartN`, `<Stage>RoomN` (numbered in ROM order,
not by room id; the id is the macro's first argument), `<Stage>RoomNLayout`,
`<Stage>Blocks`, `<Stage>Collision`/`<Stage>CollisionEnd`. Object types in
`spawn` are decimal, matching the ObjectTypeTab comments; a named type gets a
comment (`;fan`).

## Text

The game has several encodings and RGBDS charmaps are global, so:

* plain-ASCII strings (the bank `$00` boss names) use the default `main` charmap;
* screen text uses the named `screen` charmap from `constants/charmap.inc`;
* the weapon-get strings use the named `getscreen` charmap;
* the bank `$0E` roll call (ASCII − `$20`) will need a fourth when it is extracted.

Wrap text in `SETCHARMAP <name>` … `SETCHARMAP main` and always switch back.
If a string comes out wrong, `./build.sh` will say so — the charmap is the thing
to fix, not the string.

## Moving code out of `banks/`

Code moves into `engine/` (and data into `data/`) a contiguous chunk at a time,
each chunk opening with its own pinned section:

```
SECTION "Sprite System", ROM0[$2BC7]
```

The address is that of the chunk's first byte, which keeps the ROM exact whatever
order the files are included in. A chunk boundary must fall at a global label,
since local labels do not cross it. Section names are global across ROM and RAM,
so pick one no `ram/` file uses (`ReadJoypad`, not `Joypad`). Fall-through from
one chunk into the next is fine - the bytes are still adjacent - but say so in a
comment. Bank `$00` was split this way in step 2.7; see `engine/README.md`.

## Bank tails

Every bank ends in an explicit fill, `ds $8000 - @, $FF` in a pinned section (or
`ds $8000 - $XXXX, $FF` with the start written out). The skeleton's `freespace`
macro, which copied tails out of the base ROM, was removed in step 7.2. Banks
`$04` and `$05` carry uninitialised-memory filler before their `$FF` tails; that is
`uninit_fill` (see "Replacing an INCBIN" above).
