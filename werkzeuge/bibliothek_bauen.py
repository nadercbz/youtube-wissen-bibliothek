#!/usr/bin/env python3
"""Fuegt alle videos/*/wissen.json zu bibliothek/data/bibliothek.js zusammen.
Aufruf: python3 -I werkzeuge/bibliothek_bauen.py
Prueft Pflichtfelder und vergibt fortlaufende Buchnummern (stabil nach Reihenfolge der Videos)."""
import json, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PFLICHT = ["id", "titel", "untertitel", "kategorie", "tags", "zusammenfassung", "kernaussagen"]

def main():
    videos, buecher, fehler = [], [], []
    dateien = sorted(ROOT.glob("videos/*/wissen.json"),
                     key=lambda p: json.loads(p.read_text())["video"].get("hinzugefuegt", ""))
    nr = 0
    for f in dateien:
        d = json.loads(f.read_text())
        v = d["video"]
        videos.append(v)
        for b in d["buecher"]:
            for k in PFLICHT:
                if not b.get(k):
                    fehler.append(f"{f.parent.name}/{b.get('id','?')}: Feld '{k}' fehlt")
            nr += 1
            b = dict(b, nr=nr, video=v["id"], sammlung=v.get("sammlung", v["titel"]))
            buecher.append(b)
    if fehler:
        print("\n".join(fehler)); sys.exit(1)
    ids = [b["id"] for b in buecher]
    doppelt = {i for i in ids if ids.count(i) > 1}
    if doppelt:
        print("Doppelte Buch IDs:", doppelt); sys.exit(1)
    out = ROOT / "bibliothek/data/bibliothek.js"
    out.write_text("// generiert von werkzeuge/bibliothek_bauen.py, nicht von Hand bearbeiten\nwindow.BIBLIOTHEK = "
                   + json.dumps({"videos": videos, "buecher": buecher}, ensure_ascii=False, indent=1) + ";\n")
    print(f"OK: {len(videos)} Videos, {len(buecher)} Bücher -> {out.relative_to(ROOT)}")

if __name__ == "__main__":
    main()
