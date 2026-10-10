# Regional versions

Four dumps of this game are known: US, European, Japanese final (*Rockman World*)
and a Japanese prototype. Three are checked here; the prototype has not been
obtained.

| | sha1 (first 16) | crc32 | Header title |
|---|---|---|---|
| `Megaman - Dr. Wily's Revenge (U) [!].gb` | `277edb3c844e812b` | `47e70e08` | `MEGAMAN` |
| `Megaman - Dr. Wily's Revenge (E) [!].gb` | `11255a24344e9fed` | `2ea4b976` | `MEGAMAN` |
| `Rockman World (J) [!].gb` | `91318509322fbcd1` | `3be6ac04` | `ROCKMAN WORLD` |

Our base ROM is **(U)**.

## Which banks differ

| | bytes differing | affected banks |
|---|---:|---|
| U vs E | 31,168 (11.9%) | `$00` 13143, `$01` 4784, `$04` 3, `$05` 4, `$06` 13234 |
| U vs J | 31,164 (11.9%) | `$00` 11282, `$01` 4708, `$04` 1657, `$05` 681, `$06` 12836 |
| E vs J | 33,887 (12.9%) | `$00` 13061, `$01` 4849, `$04` 1655, `$05` 677, `$06` 13645 |

**Eleven of the sixteen banks — `$02`, `$03`, `$07`, `$08`, `$09`, `$0A`, `$0B`,
`$0C`, `$0D`, `$0E`, `$0F` — are byte-identical in all three.** Only the code banks
`$00`/`$01`, the screen-data bank `$06`, and patches of `$04`/`$05` move.

Two things follow. The audio disassembly applies to every version unchanged, since
`$02` and `$0A` are identical everywhere. And third-party documentation about those
eleven banks needs no address correction, whichever dump it was written against.

(J) is the more distant relative: 1,657 differing bytes in bank `$04` and 681 in
`$05`, against (U)-vs-(E)'s 3 and 4. Those are genuine graphics and stage-data
changes, not just relocation.

## Title screen and credits

Will's account, confirmed here by decoding each version's bank `$06` string block
(see `docs/ROMMAP.md` for the encoding):

**(U)** puts the credits on the title screen itself:

```
$99A0  @CAPCOM CO.,LTD.1991
$99C0  @CAPCOM U.S.A.,
$99EC  INC.1991
$9A00  LICENSED BY NINTENDO
```

**(E)**, published by Nintendo rather than Capcom, has **no Capcom USA line at all**
and no title-screen credits. Instead its string block opens with six strings the
other versions do not have — a separate splash screen shown before the title:

```
$98C2  @ 1991 CAPCOM
$9902  MEGAMAN IS
$9923  A TRADEMARK
$9949  OF CAPCOM
$9982  LICENSED TO
$99A4  NINTENDO FROM
$99CC  CAPCOM
```

Its block then ends after `PASS WORD`, where (U) continues into the credits.

**(J)** carries a single `@CAPCOM 1991` at `$99C3` plus `LICENSED BY NINTENDO`, and
is missing `GAME END` and `START BUTTON` entirely. Its menu strings also go to
different tilemap positions — `GAME OVER` at `$9886` against (U)'s `$9825`, `STAGE
SELECT` at `$9946` against `$98C3` — so the screens are laid out differently, not
merely translated.	;[ok]

## The Japanese prototype

Reported by Will; **not verified here**, as no dump of it has been obtained. Recorded
so that a future session knows what to look for if one turns up.

* Unfinished and not completable.
* Palette differences somewhere — stage select is the best guess.
* At least two pieces of music differ substantially from the final: the stage-select
  theme and the stage-start jingle.
* Boss doors are not properly implemented. **The level layouts show they were
  originally meant to be side-by-side, as in the NES games.**

That last point is the one with consequences for this disassembly. If the prototype's
layouts encode side-by-side boss doors, the final game's stage data may still carry
the fields that supported them — vestigial door placement or orientation bytes that
nothing reads any more. Worth watching for in **Phase 4.1**, when the bank `$05`
stage format is derived: a field that is constant across all four stages, or one
whose values do not affect anything, is a candidate.

## Comparing versions

`tools/findbytes.py` takes a byte pattern and reports where it lives in each dump:

```
python3 tools/findbytes.py "3e 01 ea a1 df" --dc 0x0857 \
    --also "/path/to/Megaman - Dr. Wily's Revenge (E) [!].gb" \
           "/path/to/Rockman World (J) [!].gb"
```

Observed (U)−(E) offsets, as measurements rather than a formula:

| Region | Δ (U − E) |
|---|---:|
| Bank `$00`, `$0855` through `$20E1` | −2 |
| Bank `$01`, up to and including `$5766` | 0 |
| Bank `$01`, from `$6142` on | −30 |
| Banks `$02`–`$05`, `$07`–`$0F` | 0 at every point checked |
