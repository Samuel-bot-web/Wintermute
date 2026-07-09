# ADR-001: Projektstruktur

## Status

Akzeptiert

## Kontext

Das Projekt Wintermute soll langfristig wartbar bleiben. Dafür benötigt das Repository eine klare Trennung zwischen Dokumentation, Skripten und Docker-Stacks.

## Entscheidung

Das Repository wird in folgende Hauptbereiche gegliedert:

- `docs/` für Projektdokumentation
- `docs/adr/` für Architekturentscheidungen
- `scripts/` für Hilfsskripte
- `stacks/` für Docker-Compose-Stacks

Laufzeitdaten, Backups, Caches, Datenbanken, Logs und Secrets werden nicht versioniert.

## Begründung

Diese Struktur trennt dauerhaft zwischen reproduzierbarer Konfiguration und veränderlichen Laufzeitdaten. Dadurch bleibt das Repository klein, nachvollziehbar und gut wartbar.

## Folgen

Das Repository dient als technische Referenz und Wiederaufbaugrundlage, nicht als Speicherort für produktive Daten oder Backups.
