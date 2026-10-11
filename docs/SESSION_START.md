# Read this first

This project is deliberately built to be worked on **one step per session**, because
a full 256 KB disassembly does not fit in one conversation. Everything a session
needs to know lives in this repository, not in chat history.

## Session protocol

1. **Bootstrap the toolchain** (fresh Linux/cloud container has no RGBDS):

   ```
   sh tools/bootstrap-rgbds.sh && export PATH="$HOME/bin:$PATH"
   ```

   On Windows, RGBDS is already installed; use `make.bat`.

2. **Put `baserom.gb` in the repo root** if it is not there (it is gitignored).
   Verify: `sha256sum baserom.gb` → `33d16365318411f063edd9100c79458aabb7ea71bb1873e30f38b93814f0ec6e`

3. **Confirm the build is green before touching anything:**

   ```
   ./build.sh      # must print: OK: mmwr.gb is byte-identical to baserom.gb
   ```

   If this fails on a clean checkout, stop and fix that first. A red baseline makes
   every later change unverifiable.

4. **Pick the next unchecked step in [PLAN.md](PLAN.md).** Do exactly that one step.
   Do not wander into the next one; a half-finished step is worse than a small one.

5. **`./build.sh` after every meaningful edit.** This is the whole safety net: the
   ROM either comes out identical or the change is wrong. Do not batch up an hour of
   edits and then check.

6. **Before finishing:**
   * `python3 tools/coverage.py` and paste the numbers into [PROGRESS.md](PROGRESS.md)
   * tick the step in [PLAN.md](PLAN.md) and write 2–5 lines in the PROGRESS.md log
     about what was learned (formats, addresses, dead ends)
   * record anything surprising in [BANKS.md](BANKS.md), and any Data Crystal claim
     you checked in [ROMMAP.md](ROMMAP.md)
   * commit

## The two rules that matter

* **Never change what the ROM assembles to.** This is a disassembly, not a
  decompilation or a romhack. `./build.sh` is the definition of correct.
* **Never guess a name.** A wrong descriptive name is worse than `Func_00_1B6B`,
  because the next session trusts it. If a routine's purpose is unclear, leave the
  provisional name and say so in a comment. Every descriptive name carries a
  confidence tag — `;[ok]`, `;[dc]` or `;[?]`; see [CONVENTIONS.md](CONVENTIONS.md).
  Do not promote a `;[?]` to `;[ok]` without actually checking it.

* **Third-party documentation is usually about the European ROM.** Data Crystal's
  map is, and its addresses are exact — for that build. Ours is the US dump, and the
  two differ in banks `$00`, `$01`, `$04`, `$05` and `$06` by varying amounts. The
  other eleven banks are byte-identical across all three regional versions, so an
  address in those is our address. Either way, search for the byte pattern rather
  than trusting an address: `python3 tools/findbytes.py "3e 01 ea a1 df"`.
  [ROMMAP.md](ROMMAP.md) has the version comparison and the checked claims.

## Helper tools

```
python3 tools/coverage.py [--md]                  coverage per bank
python3 tools/srcgen.py START END --bank N [--words A B] [--data A B]
                                                  assemble-ready source for a range
python3 tools/disasm.py baserom.gb START END --bank N   straight-line listing, for reading
python3 tools/gfx.py extract baserom.gb START COUNT out.png    tiles to PNG
python3 tools/leveldump.py baserom.gb [--stage N] [--png DIR [--objects] [--blocks]]
                                                  dump or render stage data (docs/LEVELS.md);
                                                  give it mmwr.gb to preview an edited stage
python3 tools/stageselect.py baserom.gb out.png   stage-select robot master sprites (bank $07)
python3 tools/rammap.py [--md|--unnamed|--sites ADDR]
                                                  every RAM address the source refers to,
                                                  with users (docs/RAMMAP.md; build first)
sh tools/roundtrip.sh START END N                 prove that output reassembles exactly
python3 tools/bankgen.py tools/bankgen/bankNN.py   bootstrap a whole bank into source from a
                                                  config (entry points, data items, names,
                                                  comments); see bank03.py (the object
                                                  library's config is objlib.py). Overwrites files:
                                                  only for a bank not yet hand-edited
python3 tools/objframes.py baserom.gb TYPE BANK START END out.png
                                                  draw an object's frames with its tileset
                                                  (build first: reads mmwr.sym)
```

`disasm.py` does not follow branches and does not know where code stops. It is a
typing-saver, not an oracle: read its output, decide what is actually data, and
round-trip the range before pasting it in.
