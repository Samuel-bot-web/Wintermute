# Projektübersicht

## Name

Wintermute

## Zweck

Wintermute ist ein privater Homeserver / Homelab-Server.

Das System soll langfristig wartbar, nachvollziehbar dokumentiert und professionell strukturiert sein.

## Grundprinzipien

- Änderungen erfolgen schrittweise.
- Größere Änderungen werden dokumentiert.
- Konfigurationen werden mit Git versioniert.
- Laufzeitdaten, Caches, Datenbanken und Secrets werden nicht versioniert.
- Nach relevanten Änderungen erfolgen Git Commit und Push.
- Kritische Aktionen werden vorab geprüft.

## Zielarchitektur

Wintermute wird künftig auf Proxmox VE betrieben.

Geplant sind mindestens zwei virtuelle Maschinen:

- Ubuntu Server VM für Docker-Dienste
- Home Assistant OS VM

Docker-Dienste laufen nicht direkt auf dem Proxmox-Host.
