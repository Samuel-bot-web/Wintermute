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

## Aktueller Stand (12.07.2026)

### Abgeschlossen
- Proxmox VE 9.2.4 auf Debian 13 (encrypted LVM) installiert, lauffähig
- Root-Partition verkleinert, local-lvm Thin-Pool eingerichtet
- Netzwerk-Bridge vmbr0 eingerichtet (fehlte bei manueller Debian-
  Installation)
- VM100 (Ubuntu 26.04 LTS, 192.168.178.36) erstellt, Fritz!Box-
  Reservierung eingerichtet
- Docker Engine auf VM100 installiert (offizielles Docker-Repository)
- Git-Repo per Deploy-Key (read-only) auf VM100 geklont
- 4-TB-Medienplatte (Serial Z1Z4AZBH) neu mit LUKS2 verschlüsselt,
  Keyfile-Kopplung an System-Passphrase eingerichtet, Keyfile extern
  gesichert
- 6-TB-Platte (Serial WPR0CY3K) temporär als unverschlüsseltes
  Staging-Ziel eingerichtet (ext4)
- Alte Daten der 4-TB-Platte vollständig auf 6-TB-Platte migriert und
  per rsync-Dry-Run verifiziert
- 4-TB-Platte per virtiofs an VM100 angebunden (/mnt/media)
- Watchtower-API-Token aus Compose-Datei in .env ausgelagert

### In Arbeit
- Rückkopie der Daten von der 6-TB- auf die frisch verschlüsselte
  4-TB-Platte läuft (rsync, Hintergrund-Session)
- Stack-Zielverzeichnisse auf VM100 angelegt (adguard, jellyfin,
  portainer, homeassistant), noch ohne Inhalt

### Offen
- Nach Abschluss der Rückkopie: migration-backup/ (Jellyfin-Config,
  Portainer-Data, AdGuard-Conf) in die jeweiligen Stack-Verzeichnisse
  entpacken
- Docker-Compose-Stacks auf VM100 starten (Reihenfolge noch
  festzulegen)
- 6-TB-Platte final einrichten (verschlüsselt, für Paperless/Nextcloud)
  - aktuelle Formatierung ist nur Zwischenlager
- VM101 (Home Assistant OS) anlegen
- Samba-Freigabe (siehe 50-Docker.md)
- Altlast backups/docker-monolith-backup/ (2,9 GB) ggf. löschen
- Homepage "Dienste hinzufügen/entfernen" klären
