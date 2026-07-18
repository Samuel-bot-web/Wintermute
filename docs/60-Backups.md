# Backup & Restore – Wintermute

Stand: 18.07.2026

## Überblick

Backups laufen automatisiert jede Nacht um 3 Uhr (`/root/backup-nightly.sh`,
Cronjob auf dem Proxmox-Host) auf eine externe, verschlüsselte 4-TB-USB-Platte.
Backup-Tool: **Kopia** (Repository, Versionierung, Deduplizierung).

**Gesichert wird:**
- Paperless-ngx, Nextcloud, Immich, Kavita (Daten aus `/mnt/nas6tb/...`)
- Postgres-Datenbanken (Paperless, Nextcloud) als saubere `pg_dump`-Exporte
- Alle Docker-Compose-Configs (`~/homeserver/stacks/...` auf VM100)
- Home Assistant (VM101) als eigenständiges HA-Backup-Archiv

**Nicht gesichert:** Jellyfin-Mediathek (`/mnt/media`) – bewusst ausgeschlossen,
da Filme/Serien ersetzbar sind und die Datenmenge den Backup-Speicher sprengen
würde.

---

## 1. Backup-Platte manuell öffnen (für jeden Restore nötig)

Die Backup-Platte ist im Normalbetrieb verschlossen (kein automatischer
Boot-Unlock). Für einen Restore muss sie manuell geöffnet werden.

Auf dem **Proxmox-Host**:

```bash
sudo cryptsetup luksOpen --key-file /etc/cryptsetup-keys.d/backup-4tb.key \
  /dev/disk/by-id/ata-WDC_WD40NDZW-11A8JS1_WD-WXU2E7032L5S backup4tb_crypt
sudo mount /dev/mapper/backup4tb_crypt /mnt/backup4tb
```

Falls das Keyfile nicht verfügbar ist (z.B. bei komplettem Systemausfall),
alternativ mit der separaten Backup-Passphrase (im Passwort-Manager
hinterlegt, NICHT identisch mit media4tb/media6tb):

```bash
sudo cryptsetup luksOpen /dev/disk/by-id/ata-WDC_WD40NDZW-11A8JS1_WD-WXU2E7032L5S backup4tb_crypt
sudo mount /dev/mapper/backup4tb_crypt /mnt/backup4tb
```


---

## 3. Restore-Ablauf je nach Szenario

### Szenario A: Einzelne Datei oder Ordner versehentlich gelöscht/beschädigt

1. In der Weboberfläche: **Snapshots** → betroffenen Dienst auswählen
   (z.B. `/mnt/nas6tb/nextcloud`)
2. Gewünschten Snapshot-Zeitpunkt wählen (Historie ist einsehbar,
   Retention: 7 täglich / 4 wöchentlich / 24 monatlich / 3 jährlich)
3. Im Snapshot-Browser zur betroffenen Datei/zum Ordner navigieren
4. **"Restore"** klicken
5. Als Ziel einen **Test-Ordner** angeben (z.B. `/root/restore-test/...`),
   NICHT direkt den Originalpfad überschreiben
6. Nach Prüfung die wiederhergestellte Datei manuell an den richtigen Ort
   kopieren (per `cp` oder über die Samba-Freigabe)

### Szenario B: Kompletter Dienst muss wiederhergestellt werden (z.B. nach Datenkorruption)

Am Beispiel Paperless (analog für Nextcloud, Kavita):

1. Betroffenen Docker-Stack stoppen, damit keine Datenbank-Schreibzugriffe
   während des Restores passieren:
```bash
   ssh samuel@192.168.178.36 "cd ~/homeserver/stacks/paperless && docker compose down"
```
2. In der Kopia-Weboberfläche den gewünschten Snapshot von
   `/mnt/nas6tb/paperless` auswählen
3. Restore mit Ziel `/mnt/nas6tb/paperless` und "Overwrite Files" /
   "Overwrite Directories" aktiviert (im Gegensatz zum Test-Restore in
   Szenario A - hier wollen wir bewusst überschreiben)
4. Nach Abschluss: Docker-Stack neu starten:
```bash
   ssh samuel@192.168.178.36 "cd ~/homeserver/stacks/paperless && docker compose up -d"
```
5. Funktionstest im Browser (`http://192.168.178.36:8010`)

### Szenario C: Postgres-Datenbank aus SQL-Dump wiederherstellen

Falls nur die Datenbank beschädigt ist (nicht die Dateien selbst):

1. In der Kopia-Weboberfläche den Snapshot mit Tag "service:db-dumps"
   auswählen
2. Restore-Ziel: `/root/restore-test/db-dumps`
3. Passende .sql-Datei anhand des Datumsstempels im Dateinamen auswählen
   (z.B. paperless-20260718.sql)
4. Datenbank-Container leeren und Dump einspielen:
```bash
   ssh samuel@192.168.178.36
   cd ~/homeserver/stacks/paperless
   docker compose stop paperless
   docker exec -i paperless-db psql -U paperless -c "DROP DATABASE paperless;"
   docker exec -i paperless-db psql -U paperless -c "CREATE DATABASE paperless;"
   cat /root/restore-test/db-dumps/paperless-20260718.sql | docker exec -i paperless-db psql -U paperless paperless
   docker compose up -d paperless
```

Für Nextcloud denselben Ablauf mit nextcloud-db und Datenbankname
nextcloud durchführen.

### Szenario D: Home Assistant (VM101) wiederherstellen

1. In der Kopia-Weboberfläche den Snapshot mit Tag "service:homeassistant"
   auswählen, gewünschte .tar-Datei restoren nach
   `/root/restore-test/homeassistant/`
2. Datei zurück auf VM101 übertragen:
```bash
   sudo scp -i /root/.ssh/id_ed25519_backup -P 22222 \
     -o MACs=hmac-sha2-256-etm@openssh.com \
     /root/restore-test/homeassistant/DATEINAME.tar \
     samuel@192.168.178.38:/backup/
```
   Falls scp wegen SFTP-Konfiguration nicht funktioniert, Datei
   stattdessen per cat uebertragen, analog zum Backup-Skript.
3. Über die Home-Assistant-Weboberfläche: Einstellungen -> System ->
   Sicherungen -> das übertragene Backup sollte in der Liste auftauchen
   -> Wiederherstellen klicken
4. Home Assistant startet währenddessen neu

### Szenario E: Docker-Compose-Configs wiederherstellen (z.B. nach Fehlkonfiguration)

1. Snapshot mit Tag "service:configs" auswählen
2. Restore nach `/root/restore-test/homeserver`
3. Gewünschte einzelne compose.yml/.env-Datei heraussuchen und gezielt
   auf VM100 zurückkopieren:
```bash
   scp /root/restore-test/homeserver/stacks/DIENSTNAME/compose.yml \
     samuel@192.168.178.36:~/homeserver/stacks/DIENSTNAME/compose.yml
```

### Szenario F: Kompletter Wintermute-Neuaufbau (Proxmox-Host komplett verloren)

Worst-Case-Szenario, Reihenfolge:

1. Proxmox VE neu installieren
2. LUKS-Passphrasen aus dem Passwort-Manager bereithalten (media4tb,
   media6tb, backup4tb - alle DREI sind unterschiedlich!)
3. Backup-Platte anschließen, mit der Passphrase entsperren (Schritt 1)
4. Kopia installieren (siehe 00-Projektuebersicht.md), Repository mit
   dem Kopia-Repository-Passwort öffnen:
```bash
   kopia repository connect filesystem --path=/mnt/backup4tb/kopia-repo
```
5. Alle Snapshots nacheinander an die korrekten Zielpfade restoren
   (Szenario B für jeden Dienst)
6. VMs (VM100, VM101) neu aufsetzen bzw. aus Proxmox-Backups
   wiederherstellen, falls vorhanden
7. Docker-Stacks aus den wiederhergestellten Configs neu starten
8. Datenbanken aus den SQL-Dumps einspielen (Szenario C)
9. Home Assistant aus dem HA-Backup wiederherstellen (Szenario D)
10. Vollständigen Funktionstest aller Dienste durchführen

---

## 4. Nach jedem Restore: Backup-Platte wieder schließen

```bash
sudo umount /mnt/backup4tb
sudo cryptsetup luksClose backup4tb_crypt
```

---

## 5. Getestete Restores (Verlauf)

| Datum | Was | Ergebnis |
|---|---|---|
| 18.07.2026 | Paperless-Vollrestore (Testordner, 75MB) | Erfolgreich, alle Unterordner (data/media/redisdata/consume/pgdata/export) korrekt und vollständig wiederhergestellt |

Noch nicht getestet: Szenario B (echtes Ueberschreiben mit Container-Stop/
-Start), Szenario C (SQL-Dump-Restore), Szenario D (Home Assistant),
Szenario F (kompletter Neuaufbau). Diese Anleitungen sind bislang nur
theoretisch beschrieben, nicht praktisch verifiziert - bei Gelegenheit
nachholen.

## 6. Wichtige Zugangsdaten (Aufbewahrungsort)

Folgende Geheimnisse werden für einen Restore benötigt und sollten
außerhalb des Servers (Passwort-Manager) hinterlegt sein:

- LUKS-Passphrase media4tb_crypt
- LUKS-Passphrase media6tb_crypt
- LUKS-Passphrase backup4tb_crypt (separat von den beiden anderen!)
- Kopia-Repository-Passwort
- Kopia-Web-UI-Login (samuel + Passwort)
