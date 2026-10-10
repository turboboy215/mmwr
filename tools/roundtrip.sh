#!/bin/sh
# Round-trip check for tools/disasm.py: disassemble a ROM range, assemble the
# result, and confirm the bytes come back identical. Use it on a new range
# before pasting the output into a bank file.
#
#   sh tools/roundtrip.sh <start> <end> <bank>
#   sh tools/roundtrip.sh 0x4190 0x4300 1
set -e
S=$1; E=$2; B=$3
[ -n "$B" ] || { echo "usage: $0 <start> <end> <bank>"; exit 2; }

python3 tools/disasm.py baserom.gb "$S" "$E" --bank "$B" | sed 's/;.*//' > /tmp/rt.body
if [ "$B" = "0" ]; then
  ADDR=$(python3 -c "print(hex($S))"); HDR="SECTION \"roundtrip\", ROM0[$ADDR]"
else
  ADDR=$(python3 -c "print(hex($S - $B*0x4000 + 0x4000))")
  HDR="SECTION \"roundtrip\", ROMX[$ADDR], BANK[$B]"
fi
{ echo "$HDR"; cat /tmp/rt.body; } > /tmp/rt.asm
rgbasm -o /tmp/rt.o /tmp/rt.asm
rgblink -o /tmp/rt.gb /tmp/rt.o
python3 - "$S" "$E" <<'PY'
import sys
s=int(sys.argv[1],0); e=int(sys.argv[2],0)
got=open('/tmp/rt.gb','rb').read()[s:e]; want=open('baserom.gb','rb').read()[s:e]
if got==want:
    print("MATCH: %05X-%05X (%d bytes) round-trips exactly" % (s,e,e-s)); raise SystemExit(0)
for i in range(len(want)):
    if i>=len(got) or got[i]!=want[i]:
        print("DIFF at %05X: got %02X want %02X" % (s+i, got[i] if i<len(got) else -1, want[i])); break
raise SystemExit(1)
PY
