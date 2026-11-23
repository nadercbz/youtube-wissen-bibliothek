#!/bin/bash
# Holt Titel und Untertitel eines YouTube Videos und baut ein Transkript mit Minuten Zeitmarken.
# Aufruf: bash werkzeuge/youtube_holen.sh "<YouTube URL>" [Sprache, Standard de]
# Ergebnis: videos/<ID>/transkript.txt, untertitel.vtt, meta.json
set -euo pipefail
URL="$1"; LANG_CODE="${2:-de}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ID=$(yt-dlp --get-id "$URL" 2>/dev/null | head -1 || true)
if [ -z "$ID" ]; then ID=$(echo "$URL" | sed -E 's#.*(youtu\.be/|v=|shorts/)([A-Za-z0-9_-]{11}).*#\2#'); fi
OUT="$ROOT/videos/$ID"; mkdir -p "$OUT"
TMP=$(mktemp -d)
cd "$TMP"
# Original Sprache zuerst, dann automatische, dann Englisch
yt-dlp --skip-download --write-auto-subs --write-subs --sub-langs "${LANG_CODE}-orig,${LANG_CODE},en-orig,en" \
  --sub-format vtt -o "v" "https://youtu.be/$ID" >/dev/null 2>&1 || true
VTT=$(ls v.${LANG_CODE}-orig.vtt v.${LANG_CODE}.vtt v.en-orig.vtt v.en.vtt 2>/dev/null | head -1 || true)
if [ -z "$VTT" ]; then echo "FEHLER: keine Untertitel gefunden (evtl. HTTP 429, später nochmal)"; exit 1; fi
cp "$VTT" "$OUT/untertitel.vtt"
curl -s "https://www.youtube.com/oembed?url=https://youtu.be/$ID&format=json" > "$OUT/meta.json" || true
python3 -I - "$OUT" <<'EOF'
import re, sys
out = sys.argv[1]
blocks = open(out + "/untertitel.vtt").read().split("\n\n")
res, last, mark, ende = [], "", -60, 0
for b in blocks:
    m = re.search(r"(\d\d):(\d\d):(\d\d)\.\d+ -->", b)
    if not m: continue
    s = int(m[1]) * 3600 + int(m[2]) * 60 + int(m[3]); ende = s
    for l in b.split("\n")[1:]:
        t = re.sub(r"<[^>]+>", "", l).strip()
        if t and t != last:
            if s - mark >= 60:
                res.append(f"\n[{s//3600}:{s%3600//60:02d}:{s%60:02d}] "); mark = s
            res.append(t + " "); last = t
open(out + "/transkript.txt", "w").write("".join(res))
print(f"Dauer ca. {ende//3600}:{ende%3600//60:02d}:{ende%60:02d}, {len(''.join(res).split())} Wörter")
EOF
rm -rf "$TMP"
echo "OK: $OUT"
