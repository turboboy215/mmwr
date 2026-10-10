# Data Crystal's ROM map, and the regional versions

Data Crystal's [ROM map page](https://datacrystal.tcrf.net/wiki/Mega_Man:_Dr._Wily%27s_Revenge/ROM_map)
is the only substantial third-party map of this game.

**It is written against the European ROM.** Every code address on it lands exactly
in `Megaman - Dr. Wily's Revenge (E) [!].gb` — ten out of ten claims, no offset, no
exceptions. Our base ROM is the US dump, where most of those addresses are shifted.

> An earlier version of this document concluded that Data Crystal's addresses were
> simply unreliable, because the errors did not follow a single offset. That was
> wrong. The varying offsets are the genuine (U)↔(E) divergence: the two builds
> differ by different amounts in different banks, and are identical in most of them.
> Data Crystal is accurate; it is just accurate about a different ROM.

## The three dumps

| | sha1 (first 16) | crc32 | Header title |
|---|---|---|---|
| `Megaman - Dr. Wily's Revenge (U) [!].gb` | `277edb3c844e812b` | `47e70e08` | `MEGAMAN` |
| `Megaman - Dr. Wily's Revenge (E) [!].gb` | `11255a24344e9fed` | `2ea4b976` | `MEGAMAN` |
| `Rockman World (J) [!].gb` | `91318509322fbcd1` | `3be6ac04` | `ROCKMAN WORLD` |

All three are 256 KB. A Japanese prototype is also known to exist but has not been
checked here.

### What differs between them

| | bytes differing | affected banks |
|---|---:|---|
| U vs E | 31,168 (11.9%) | `$00` 13143, `$01` 4784, `$04` 3, `$05` 4, `$06` 13234 |
| U vs J | 31,164 (11.9%) | `$00` 11282, `$01` 4708, `$04` 1657, `$05` 681, `$06` 12836 |
| E vs J | 33,887 (12.9%) | `$00` 13061, `$01` 4849, `$04` 1655, `$05` 677, `$06` 13645 |

The useful half of that table: **eleven of the sixteen banks — `$02`, `$03`, `$07`,
`$08`, `$09`, `$0A`, `$0B`, `$0C`, `$0D`, `$0E`, `$0F` — are byte-identical across
all three versions.** For anything in those banks, a Data Crystal address is our
address, and so is any other regional documentation.

The five that move are bank `$00` and `$01` (the code), bank `$06` (screen text and
tilemaps, which is what you would expect to be localised), and small patches of
banks `$04` and `$05`. (J) additionally has genuinely different graphics and stage
data in `$04`/`$05` — 1,657 and 681 bytes against (U)'s 3 and 4 — so it is a more
distant relative than (E) is.

Because banks `$02` and `$0A` are identical everywhere, **the audio disassembly
applies unchanged to all three versions.**

### Observed offsets, US relative to European

These are what the checked claims actually showed. They are not a formula — they are
measurements at particular points, and the drift accumulates differently along each
bank.

| Region | Δ (U − E) |
|---|---:|
| Bank `$00`, `$0855` through `$20E1` | −2 |
| Bank `$01`, up to and including `$5766` | 0 |
| Bank `$01`, from `$6142` on | −30 |
| Banks `$02`–`$05`, `$07`–`$0F` | 0 at every point checked |

## The claims, checked

Every one of these was located by searching for the byte pattern in Data Crystal's
own listing, using `tools/findbytes.py`.

| What | DC / (E) | in our (U) ROM | Δ |
|---|---|---|---:|
| Write starting weapon `$01` → `$DFA1` | `$0857` | `$0855` | −2 |
| Write starting energy `$98` → `$DFA3` | `$0B26` | `$0B24` | −2 |
| Decrement lives at `$C108` | `$0BCA` | `$0BC8` | −2 |
| Write starting lives `$03` → `$C108` | `$0CCE` | `$0CCC` | −2 |
| Installer that copies the OAM DMA routine to HRAM | `$15D4` | `$15D2` | −2 |
| The OAM DMA routine itself | `$15E2` | `$15E0` | −2 |
| Stage-name table (`CUTMAN`/`ICEMAN`/`ELECMAN`/`FIREMAN`) | `$20E1`–`$2108` | `$20CA`–`$20F1` | −23 |
| Increase lives, cap at 10 | `$5766` | `$5766` | 0 |
| Menu cursor placement | `$6160` | `$6142` | −30 |
| Stage-select box corner coordinates | `$6529` | `$650B` | −30 |
| Bank `$05` pointer list and the four stage ranges | `$14000`–`$16AAC` | same | 0 |
| Bank `$06` menu text | `$1803C` | same | 0 |

Two of their hex listings contain typos that survive the version question, i.e. they
are wrong about the European ROM too:

* `$0B26`: printed as `3D 98 ld a,$98`. `3D` is `dec a`; the byte is `3E`.
* `$0BCD`: printed as `34 dec [hl]`. `34` is `inc [hl]`; the byte is `35`. The
  mnemonic is right, the hex is not — which matters, because the page goes on to
  suggest patching that address for infinite lives (and misprints it as `$0BC4`).

## Bank-end figures

Their per-bank "unused from" figures are approximate and appear to have been
gathered separately from the code listings — they match neither version cleanly:

| Bank | (U) | (E) | (J) | DC says |
|---|---|---|---|---|
| `$00` | `$03979` | `$03990` | `$0396C` | `$03979` — the **US** value |
| `$01` | `$0738D` | `$073AB` | `$07380` | `$073AB` — the **European** value |
| `$05` | `$17000` | `$17000` | `$17000` | `$16AAD` — where the stage data ends; `$16AAD`–`$16FFF` is uninitialised-memory filler (step 4.1), then `$FF` |
| `$06` | `$1BBB7` | `$1BBFF` | `$1BBA8` | `$1BBB7` — the **US** value |
| `$0C` | `$33395` | `$33395` | `$33395` | `$33396` — off by one |
| `$0E` | `$3BBAF` | `$3BBAF` | `$3BBAF` | `$3BBB0` — off by one |

The other ten banks match all three versions and Data Crystal exactly.

## Working rule

Take the **byte pattern** from whatever source you are reading, never the address:

```
python3 tools/findbytes.py "3e 01 ea a1 df" --dc 0x0857
python3 tools/findbytes.py "cd ?? ?? 21 08 c1"          # ?? matches any byte
python3 tools/findbytes.py "21 08 c1" --also /path/to/mmwr-e.gb
```

Record the real address here with an `[ok]` verdict, or record that it does not
exist. Claims applied to the source carry a `;[dc]` tag at the label; anything still
only on someone else's say-so stays `;[?]`.

## Text encoding

Checking the stage-name claim turned up the game's text encodings. Step 1.5 said a
whole-ROM sweep found no other text; **that was wrong**. It only tried two
encodings. Step 2.4 re-swept with every byte offset (all 256 shifts of ASCII) for
a list of words from the game and found three more blocks:

| Where | Encoding | Content | Status |
|---|---|---|---|
| bank `$00` `$21C7`–`$2244` | ASCII + `$80`, space `$93` | weapon-get screen: `YOU GOT` and the nine weapon names, two lines each | source (`getscreen` charmap) |
| bank `$01` `$63F7`–`$63FE` (ROM `$63F7`) | ASCII + `$80` | `ANDCARRY` — presumably `AND` / `CARRY` drawn separately | raw, bank `$01` |
| bank `$0E` `$50A2`–`$51CD` (ROM `$390A2`–`$391CD`) | ASCII − `$20` (`A` = `$21`), each string preceded by a `$98xx` map address, `$FF` ends a group | the ending's roll call of enemies and bosses (`SUZY`, `CHANGKEY`, … `CUTMAN` … `ENKER`) | raw, bank `$0E` |

The roll call is worth a look when bank `$0E` comes up: it names the enemies
(`PICOPICO`, `KAMINARI GORO`, `SNIPER JOE`, …), which is the best source we have
for naming the 56 object types.

**Bank `$00` name table — plain ASCII.** Four fixed 10-byte records, NUL-padded, at
`$20CA` in (U), `$20E1` in (E), `$20BD` in (J).

**Screen text — tile index = ASCII + `$60`, except space = `$6C`.** So `A` is `$A1`,
`1` is `$91`, `!` is `$81`, `.` is `$8E`. `$A0` (`@` + `$60`) is the © glyph. `$00`
terminates a string.

Each string is preceded by a **two-byte little-endian VRAM destination** in the BG
tilemap (`$98xx`–`$9Bxx`). The whole block in bank `$06` of our (U) ROM, walked
programmatically rather than by eye:

| At | Destination | Text |
|---|---|---|
| `$1803C` | `$9905` | `PASS WORD` |
| `$18048` | `$9945` | `ERROR !!` |
| `$18055` | `$9845` | `THANK YOU` |
| `$18061` | `$9884` | `FOR PLAYING` |
| `$1806F` | `$98E4` | `PRESENTED BY` |
| `$1807E` | `$9926` | `CAPCOM` |
| `$18089` | `$9825` | `GAME OVER` |
| `$18095` | `$98A5` | `A BUTTON` |
| `$180A0` | `$98C3` | `STAGE SELECT` |
| `$180AF` | `$9925` | `B BUTTON` |
| `$180BA` | `$9945` | `CONTINUE` |
| `$180C5` | `$99A3` | `START BUTTON` |
| `$180D4` | `$99C5` | `GAME END` |
| `$180E1` | `$9944` | `  GAME START` |
| `$180F0` | `$9966` | `PASS WORD` |
| `$180FC` | `$99A0` | `@CAPCOM CO.,LTD.1991` |
| `$18113` | `$99C0` | `@CAPCOM U.S.A.,` |
| `$18125` | `$99EC` | `INC.1991` |
| `$18130` | `$9A00` | `LICENSED BY NINTENDO` |

The strings are grouped by screen, and a group ends with a **null destination**
(`dw $0000`) where the next record's destination would be. So the full grammar is:

```
group:   record* $00 $00
record:  dw <BG tilemap destination>   ; $9800-$9BFF
         db <chars>, $00
```

Bank `$06` holds four groups, and the eight bytes at `$18034`-`$1803B` are pointers
to them:

| Group | Range | Pointer at | Screen |
|---|---|---|---|
| 1 | `$1803C`-`$18054` | `$18038` (`$403C`) | password entry |
| 2 | `$18055`-`$18088` | `$1803A` (`$4055`) | ending |
| 3 | `$18089`-`$180E0` | `$18036` (`$4089`) | game over / continue |
| 4 | `$180E1`-`$18148` | `$18034` (`$40E1`) | title screen |

`@` here is the copyright glyph. Bank `$06` differs by region, and the same walk over
the European and Japanese ROMs shows real content differences, not just relocation —
see `docs/VERSIONS.md`. (J) uses the same ASCII + `$60` encoding for these strings.

An earlier version of this section transcribed the block by eye and got several
destinations wrong (`FOR PLAYING` as `$9824`, `START BUTTON` as `$9943`, and so on),
and dropped the space in `ERROR !!`. The table above comes from a script that walks
the `dw`/string/`$00` records.
