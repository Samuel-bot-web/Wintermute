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

## Aktueller Stand (12.07.2026, Ende Session)

### Vollständig abgeschlossen
- Proxmox VE 9.2.4 auf Debian 13 (encrypted LVM), local-lvm Thin-Pool
  eingerichtet
- Netzwerk-Bridge vmbr0 eingerichtet
- VM100 (Ubuntu 26.04 LTS, 192.168.178.36): Docker installiert, Fritz!Box-
  Reservierung aktiv
- VM101 (Home Assistant OS 18.1, 192.168.178.38): läuft, Onboarding
  durchgeführt, Fritz!Box-Reservierung aktiv
- 4-TB-Medienplatte (Serial Z1Z4AZBH): neu mit LUKS2 verschlüsselt,
  Keyfile-Kopplung an System-Passphrase (ein Dropbear-Unlock genügt für
  beide Platten), Keyfile extern gesichert (Passwort-Manager/USB-Stick)
- Alte Daten (3,78 TB) vollständig migriert: 4-TB (alt, NTFS) ->
  6-TB (Staging, ext4) -> 4-TB (neu, verschlüsselt, ext4), doppelt per
  rsync-Dry-Run verifiziert
- Windows-Altlasten von der 4-TB-Platte entfernt (~115 GB: Recycle Bin,
  Recovery, PnP, System Volume Information)
- 4-TB-Platte per virtiofs an VM100 angebunden (/mnt/media auf Host und
  VM100 identisch, kein Passthrough)
- Docker-Stacks auf VM100 wiederhergestellt: Homepage (mit Hintergrund-
  bild), Glances, AdGuard (neu eingerichtet, altes Backup war leer),
  Portainer, Jellyfin - alle mit migrierten Daten aus migration-backup/
  bzw. neu eingerichtet
- Watchtower-API-Token aus Compose-Datei in .env ausgelagert
- Diverse kleinere Fixes: Homepage-Netzwerk-Widget (enp5s0 -> ens18),
  systemd-resolved Port-53-Konflikt (DNSStubListener=no), Homepage-YAML-
  Syntaxfehler

### Bekannte offene Probleme (bewusst zurückgestellt)
- Home-Assistant-Live-Status-Widget in Homepage wirft 401 Unauthorized,
  obwohl der Long-Lived-Access-Token nachweislich funktioniert (curl-
  Test erfolgreich). Bestätigter Upstream-Bug bei gethomepage/homepage,
  siehe GitHub Discussion #5074. Workaround: einfacher Link ohne Live-
  Status-Widget ist aktiv. Bei Interesse künftig Homepage-Updates
  beobachten, ob der Bug behoben wurde.
- Home-Assistant-API-Token wurde einmalig im Chat-Verlauf geteilt -
  sollte bei Gelegenheit in Home Assistant widerrufen und durch einen
  neuen Token ersetzt werden (nur direkt in .env eintragen, nicht mehr
  im Chat teilen).

### Nächste Schritte (Ziel der kommenden Session)
1. 6-TB-Platte (Serial WPR0CY3K, aktuell /dev/sdb, unverschlüsseltes
   ext4-Staging mit den migrierten Mediendaten drauf) neu einrichten:
   - WICHTIG: Die Daten liegen aktuell NUR auf der 6-TB-Platte als
     Staging UND vollständig auf der 4-TB-Platte (verifiziert identisch).
     Die 6-TB-Platte kann daher gefahrlos neu formatiert werden, sobald
     das nochmal kurz gegengeprüft wurde.
   - Verschlüsselung analog zur 4-TB-Platte: LUKS2 + Keyfile-Kopplung
     an dieselbe System-Passphrase (gemeinsamer Boot-Unlock)
   - Vorgesehener Zweck laut ursprünglicher Planung: Paperless, Nextcloud
   - Einbindung an VM100 vermutlich wieder per virtiofs (analog 4-TB)
2. Samba-Freigabe einrichten (stacks/samba/, siehe Planungsnotiz in
   50-Docker.md):
   - Zugriff auf /mnt/media (4-TB) und die neue 6-TB-Platte
   - Benutzername/Passwort-Absicherung, kein anonymer Zugriff
   - Läuft unabhängig von Jellyfin, kein Konflikt

### Noch offene Kleinigkeiten (niedrige Prioritaet, bei Gelegenheit)
- Altlast backups/docker-monolith-backup/ (2,9 GB) pruefen und ggf.
  loeschen
- Homepage "Dienste hinzufuegen/entfernen"-Workflow klaeren
- /mnt/media/Neuer Ordner/ (3,8 GB) und Plex-Bibliothek auf Duplikate
  pruefen, sobald die 6-TB-Platte als NAS-Ziel zur Verfuegung steht

### Zugriff / Referenzen
- Proxmox-Webinterface: https://192.168.178.37:8006
- SSH Proxmox-Host: ssh samuel@192.168.178.37 (nach LUKS-Unlock, siehe
  70-Sicherheit.md)
- SSH VM100: ssh samuel@192.168.178.36
- Homepage-Dashboard: http://192.168.178.36:3001
- Jellyfin: http://192.168.178.36:8096
- AdGuard: http://192.168.178.36:3000 (Weboberfläche), Port 80 (Admin
  laut Assistent)
- Portainer: https://192.168.178.36:9443
- Home Assistant: http://192.168.178.38:8123
- Git-Repo: git@github.com:Samuel-bot-web/Wintermute.git, lokal unter
  /home/samuel/homeserver (Host) bzw. ~/homeserver (VM100, read-only
  Deploy-Key)
## Aktueller Stand (12.07.2026, Ende Session)

### Vollständig abgeschlossen
- Proxmox VE 9.2.4 auf Debian 13 (encrypted LVM), local-lvm Thin-Pool
  eingerichtet
- Netzwerk-Bridge vmbr0 eingerichtet
- VM100 (Ubuntu 26.04 LTS, 192.168.178.36): Docker installiert, Fritz!Box-
  Reservierung aktiv
- VM101 (Home Assistant OS 18.1, 192.168.178.38): läuft, Onboarding
  durchgeführt, Fritz!Box-Reservierung aktiv
- 4-TB-Medienplatte (Serial Z1Z4AZBH): neu mit LUKS2 verschlüsselt,
  Keyfile-Kopplung an System-Passphrase (ein Dropbear-Unlock genügt für
  beide Platten), Keyfile extern gesichert (Passwort-Manager/USB-Stick)
- Alte Daten (3,78 TB) vollständig migriert: 4-TB (alt, NTFS) ->
  6-TB (Staging, ext4) -> 4-TB (neu, verschlüsselt, ext4), doppelt per
  rsync-Dry-Run verifiziert
- Windows-Altlasten von der 4-TB-Platte entfernt (~115 GB: Recycle Bin,
  Recovery, PnP, System Volume Information)
- 4-TB-Platte per virtiofs an VM100 angebunden (/mnt/media auf Host und
  VM100 identisch, kein Passthrough)
- Docker-Stacks auf VM100 wiederhergestellt: Homepage (mit Hintergrund-
  bild), Glances, AdGuard (neu eingerichtet, altes Backup war leer),
  Portainer, Jellyfin - alle mit migrierten Daten aus migration-backup/
  bzw. neu eingerichtet
- Watchtower-API-Token aus Compose-Datei in .env ausgelagert
- Diverse kleinere Fixes: Homepage-Netzwerk-Widget (enp5s0 -> ens18),
  systemd-resolved Port-53-Konflikt (DNSStubListener=no), Homepage-YAML-
  Syntaxfehler

### Bekannte offene Probleme (bewusst zurückgestellt)
- Home-Assistant-Live-Status-Widget in Homepage wirft 401 Unauthorized,
  obwohl der Long-Lived-Access-Token nachweislich funktioniert (curl-
  Test erfolgreich). Bestätigter Upstream-Bug bei gethomepage/homepage,
  siehe GitHub Discussion #5074. Workaround: einfacher Link ohne Live-
  Status-Widget ist aktiv. Bei Interesse künftig Homepage-Updates
  beobachten, ob der Bug behoben wurde.
- Home-Assistant-API-Token wurde einmalig im Chat-Verlauf geteilt -
  sollte bei Gelegenheit in Home Assistant widerrufen und durch einen
  neuen Token ersetzt werden (nur direkt in .env eintragen, nicht mehr
  im Chat teilen).

### Nächste Schritte (Ziel der kommenden Session)
1. 6-TB-Platte (Serial WPR0CY3K, aktuell /dev/sdb, unverschlüsseltes
   ext4-Staging mit den migrierten Mediendaten drauf) neu einrichten:
   - WICHTIG: Die Daten liegen aktuell NUR auf der 6-TB-Platte als
     Staging UND vollständig auf der 4-TB-Platte (verifiziert identisch).
     Die 6-TB-Platte kann daher gefahrlos neu formatiert werden, sobald
     das nochmal kurz gegengeprüft wurde.
   - Verschlüsselung analog zur 4-TB-Platte: LUKS2 + Keyfile-Kopplung
     an dieselbe System-Passphrase (gemeinsamer Boot-Unlock)
   - Vorgesehener Zweck laut ursprünglicher Planung: Paperless, Nextcloud
   - Einbindung an VM100 vermutlich wieder per virtiofs (analog 4-TB)
2. Samba-Freigabe einrichten (stacks/samba/, siehe Planungsnotiz in
   50-Docker.md):
   - Zugriff auf /mnt/media (4-TB) und die neue 6-TB-Platte
   - Benutzername/Passwort-Absicherung, kein anonymer Zugriff
   - Läuft unabhängig von Jellyfin, kein Konflikt

### Noch offene Kleinigkeiten (niedrige Prioritaet, bei Gelegenheit)
- Altlast backups/docker-monolith-backup/ (2,9 GB) pruefen und ggf.
  loeschen
- Homepage "Dienste hinzufuegen/entfernen"-Workflow klaeren
- /mnt/media/Neuer Ordner/ (3,8 GB) und Plex-Bibliothek auf Duplikate
  pruefen, sobald die 6-TB-Platte als NAS-Ziel zur Verfuegung steht

### Zugriff / Referenzen
- Proxmox-Webinterface: https://192.168.178.37:8006
- SSH Proxmox-Host: ssh samuel@192.168.178.37 (nach LUKS-Unlock, siehe
  70-Sicherheit.md)
- SSH VM100: ssh samuel@192.168.178.36
- Homepage-Dashboard: http://192.168.178.36:3001
- Jellyfin: http://192.168.178.36:8096
- AdGuard: http://192.168.178.36:3000 (Weboberfläche), Port 80 (Admin
  laut Assistent)
- Portainer: https://192.168.178.36:9443
