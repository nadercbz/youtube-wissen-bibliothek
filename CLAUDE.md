# 125 Youtube Wissen Agent

Gedächtnis und Bibliothek des **Youtube Wissen Agent** (Sub Agent `youtube-wissen-agent`, Agents/19). Seit 23.11.2026.
Der Agent speichert das gesamte Wissen aus YouTube Videos als "Bücher" (ein Buch je Thema) und zeigt sie im Bibliothek Dashboard.

## Aufbau
- `videos/<VideoID>/wissen.json` ist die einzige Quelle je Video (Video Infos plus Bücher). Daneben `transkript.txt` (mit Minuten Zeitmarken), `untertitel.vtt`, `meta.json`.
- `bibliothek/index.html` Dashboard im Archiv Look (schwarze Seitenleiste mit Search, Categories, Collections, Tags, weißes Raster mit Buchcovern). Covers werden aus Titel und Nummer als SVG erzeugt (7 Stile: buchstabe, figur, raster, streifen, kreis, terminal, bogen, im Buch per `"cover": {"stil": "..."}` erzwingbar).
- `bibliothek/data/bibliothek.js` ist generiert. Nie von Hand ändern, immer `python3 -I werkzeuge/bibliothek_bauen.py`.
- `werkzeuge/youtube_holen.sh "<URL>" [de|en]` holt Untertitel und baut das Transkript.

## Ansehen
Port 8125: `python3 -m http.server 8125 -d bibliothek`, dann http://localhost:8125. Ein Buch direkt: `#<buch-id>`.
Ohne Server geht es auch per Doppelklick auf `bibliothek/index.html`.

## Regeln
- Ablauf für neue Videos steht in `Agents/19_Youtube Wissen Agent/AGENT.md`.
- Alles ist Wiedergabe des Videos, keine geprüften Fakten. Strittige oder unbelegte Aussagen bekommen ein Feld `einordnung`.
- Zitate kurz halten (ein Satz), keine langen Transkript Passagen ins Dashboard.
- Keine Gedankenstriche in Texten.
