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

## Aktueller Stand (13.07.2026, während Session)

### Vollständig abgeschlossen
- 6-TB-Platte (Serial WPR0CY3K, /dev/disk/by-id/ata-ST6000VX009-2ZR186_WPR0CY3K):
  altes Staging-ext4 entfernt, neu mit LUKS2 verschlüsselt, Keyfile-
  Kopplung an denselben Keyfile wie media4tb (/etc/cryptsetup-keys.d/
  media-4tb.key), ein Dropbear-Unlock genügt weiterhin für alle Platten
  - crypttab: media6tb_crypt UUID=f48b2e41-0020-4917-b3da-4d9056dfa548
  - Dateisystem: ext4, Label media6tb, UUID a59ab78a-d978-43e3-afd2-592d6d3aa7e6
  - Mountpoint Host: /mnt/nas6tb
  - Reboot-Test erfolgreich: Dropbear fragt weiterhin nur einmal für
    beide Platten
- Proxmox Directory-Mapping angelegt (/etc/pve/mapping/directory.cfg):
  media6tb -> path=/mnt/nas6tb (analog media4tb -> /mnt/media)
- Per virtiofs an VM100 angebunden: virtiofs1 dirid=media6tb,cache=always
  in /etc/pve/qemu-server/100.conf
- VM100 fstab: media6tb /mnt/nas6tb virtiofs defaults 0 0 (analog media4tb)
  - Mount bestätigt in VM100: /mnt/nas6tb, 5,5 TB, 5,2 TB frei
- onboot=1 für VM100 und VM101 gesetzt (fehlte bisher, VM100 war nach
  Host-Reboot deshalb nicht automatisch gestartet - dabei entdeckt)

### Bekannte offene Probleme (bewusst zurückgestellt)
- QEMU Guest Agent läuft nicht in VM100 (sudo qm reboot 100 schlägt mit
  Timeout fehl, Fallback war qm stop/start bzw. qm reboot --skipLock).
  Bei Gelegenheit qemu-guest-agent in VM100 installieren für sauberen
  Soft-Reboot via Proxmox.
- Home-Assistant-Live-Status-Widget in Homepage: weiterhin 401,
  Upstream-Bug (GitHub Discussion #5074), Workaround aktiv.
- Home-Assistant-API-Token: weiterhin ausstehend zu widerrufen/ersetzen.
- 4-TB-Platte (/mnt/media) ist zu 99% voll (nur noch ~69 GB frei,
  3,4 TB von 3,6 TB belegt) - im Blick behalten, bevor Nextcloud/
  Paperless-Daten oder weitere Medien dazukommen.

### Nächste Schritte (Ziel der kommenden Session)
1. Samba-Freigabe einrichten (stacks/samba/, siehe Planungsnotiz in
   50-Docker.md):
   - Zugriff auf /mnt/media (4-TB) und /mnt/nas6tb (6-TB)
   - Benutzername/Passwort-Absicherung, kein anonymer Zugriff
   - Läuft unabhängig von Jellyfin, kein Konflikt
2. Vorgesehener Zweck der 6-TB-Platte laut ursprünglicher Planung:
   Paperless, Nextcloud - Einrichtung noch offen

### Zugriff / Referenzen (Ergänzung)
- Mountpoint 6-TB auf Host: /mnt/nas6tb
- Mountpoint 6-TB in VM100: /mnt/nas6tb (identisch, wie bei /mnt/media)

## Aktueller Stand (13.07.2026, Ende Session)

### Vollständig abgeschlossen
- Samba-Freigabe eingerichtet (stacks/samba/, dperson/samba-Image):
  - Freigaben: media (-> /mnt/media, 4-TB) und nas6tb (-> /mnt/nas6tb, 6-TB)
  - Zugriff nur mit Benutzername/Passwort (kein Gastzugriff), Nutzer
    "samuel", Passwort in stacks/samba/.env (nicht im Git-Repo, siehe
    .gitignore)
  - Getestet von Windows: beide Freigaben (\\192.168.178.36\media,
    \\192.168.178.36\nas6tb) erfolgreich verbunden
  - Läuft unabhängig von Jellyfin, kein Konflikt festgestellt

### Bekannte offene Probleme (bewusst zurückgestellt)
- QEMU Guest Agent läuft nicht in VM100, sauberer Soft-Reboot via
  Proxmox aktuell nicht möglich (siehe Eintrag 13.07. während Session).
- Home-Assistant-Live-Status-Widget in Homepage: weiterhin 401,
  Upstream-Bug (GitHub Discussion #5074), Workaround aktiv.
- Home-Assistant-API-Token: weiterhin ausstehend zu widerrufen/ersetzen.
- 4-TB-Platte (/mnt/media) ist zu 99% voll (nur noch ~69 GB frei).
- Samba: UID/Permission-Mapping zwischen Container und Host noch nicht
  im Detail geprüft - falls künftig Dateien, die per Samba angelegt
  werden, von anderen Diensten (z.B. Jellyfin) nicht lesbar sind, dort
  ansetzen.

### Nächste Schritte (Ziel der kommenden Session)
1. Einrichtung Paperless und/oder Nextcloud auf der 6-TB-Platte
   (ursprünglich vorgesehener Zweck laut Planung)
2. QEMU Guest Agent in VM100 installieren für sauberen Soft-Reboot
3. Home-Assistant-API-Token widerrufen und neu setzen (nur in .env,
   nicht im Chat teilen)
4. Bei Gelegenheit: 4-TB-Platte Speicherplatz prüfen/aufräumen

### Zugriff / Referenzen (Ergänzung)
- Samba: \\192.168.178.36\media, \\192.168.178.36\nas6tb
  (Benutzer samuel, Passwort siehe stacks/samba/.env auf VM100)

## Aktueller Stand (13.07.2026, während Session - Internet-Zugang vorbereitet)

### Vollständig abgeschlossen
- Domain brueggemann.site (Registrar: INWX) zu Cloudflare migriert:
  Nameserver auf doug.ns.cloudflare.com / june.ns.cloudflare.com
  umgestellt, DNS-Verwaltung läuft jetzt über Cloudflare (kostenloser
  Plan), Registrierung bleibt weiterhin bei INWX
- AdGuard-Webport-Konflikt behoben: interne Weboberfläche lief
  unerwartet auf Port 80 (address: 0.0.0.0:80 in AdGuardHome.yaml),
  kollidierte mit Nginx Proxy Manager. Auf Port 3000 umgestellt
  (sowohl in AdGuardHome.yaml als auch im Docker-Portmapping), Port 80
  im Compose-File entfernt. DNS-Funktion (Port 53) durchgehend
  unterbrechungsfrei, nur die Web-UI betroffen.
- Nginx Proxy Manager eingerichtet (stacks/npm/, Image
  jc21/nginx-proxy-manager): läuft auf Port 81 (Admin-UI), 80/443
  (Proxy-Traffic). Login-Zugangsdaten geändert (Standard-Login ersetzt).
  Zweck: internes Routing von Subdomains zu den jeweiligen Docker-
  Diensten, TLS-Terminierung übernimmt Cloudflare.
- Cloudflare Tunnel eingerichtet (stacks/cloudflared/, Image
  cloudflare/cloudflared): Tunnel-Name wintermute-vm100, Token in
  stacks/cloudflared/.env (nicht im Git-Repo). Tunnel verbindet ohne
  offene Ports an der Fritz!Box - kein Port-Forwarding nötig,
  Datenverkehr läuft ausgehend von VM100 zu Cloudflare.
  - 4 Verbindungen zu Cloudflare-Rechenzentren bestätigt (fra06, fra08,
    fra17), alle Connectivity-Pre-Checks bestanden
- End-to-End-Test erfolgreich: Testroute npm-test.brueggemann.site ->
  192.168.178.36:81 über Mobilfunknetz erreichbar (danach wieder
  entfernt, da NPM nicht dauerhaft öffentlich mit Standard-Zugriff
  erreichbar sein soll)
- Homepage aktualisiert (stacks/homepage/config/services.yaml):
  - AdGuard-Link auf neuen Port 3000 korrigiert
  - Samba-Freigabe ergänzt (Kategorie Netzwerk)
  - Neue Kategorie "Infrastruktur" mit Nginx Proxy Manager ergänzt

### Architektur für öffentlichen Zugriff (Entscheidung getroffen)
Internet -> Cloudflare (TLS-Terminierung, DDoS-Schutz) -> Cloudflare
Tunnel (cloudflared auf VM100, keine offenen Ports) -> Nginx Proxy
Manager (Routing nach Hostname) -> jeweiliger Dienst

Geplante Subdomains:
- paperless.brueggemann.site -> Paperless-ngx
- cloud.brueggemann.site -> Nextcloud
- photos.brueggemann.site -> Immich

Interne Dienste (Homepage, Jellyfin, Portainer, AdGuard, Home
Assistant, Samba) bleiben bewusst NUR im lokalen Netz erreichbar,
werden nicht über den Tunnel veröffentlicht.

### Bekannte offene Probleme (bewusst zurückgestellt)
- QEMU Guest Agent läuft nicht in VM100, sauberer Soft-Reboot via
  Proxmox aktuell nicht möglich.
- Home-Assistant-Live-Status-Widget in Homepage: weiterhin 401,
  Upstream-Bug (GitHub Discussion #5074), Workaround aktiv.
- Home-Assistant-API-Token: weiterhin ausstehend zu widerrufen/ersetzen.
- 4-TB-Platte (/mnt/media) ist zu 99% voll (nur noch ~69 GB frei).

### Nächste Schritte (Ziel der kommenden Session)
1. Paperless-ngx deployen (leichtgewichtigster der drei Dienste,
   erster Praxistest für öffentlichen Zugriff über die neue
   Infrastruktur)
2. Public Hostname-Route in Cloudflare für paperless.brueggemann.site
   anlegen, Proxy Host in NPM einrichten
3. Nach erfolgreichem Test: Nextcloud, danach Immich (in dieser
   Reihenfolge wegen steigendem Ressourcenbedarf)
4. QEMU Guest Agent in VM100 installieren
5. Home-Assistant-API-Token widerrufen und neu setzen

### Zugriff / Referenzen (Ergänzung)
- Nginx Proxy Manager: http://192.168.178.36:81
- Cloudflare Zero Trust Dashboard: https://one.dash.cloudflare.com
- AdGuard-Weboberfläche (korrigiert): http://192.168.178.36:3000
- Domain: brueggemann.site (Registrar INWX, DNS via Cloudflare)

## Aktueller Stand (13.07.2026, Ende Session - Paperless-ngx live)

### Vollständig abgeschlossen
- Paperless-ngx eingerichtet (stacks/paperless/, PostgreSQL 16 + Redis 7
  + ghcr.io/paperless-ngx/paperless-ngx:latest):
  - Daten auf 6-TB-Platte: /mnt/nas6tb/paperless/{data,media,export,
    consume,pgdata,redisdata}
  - Lokal erreichbar: http://192.168.178.36:8010
  - OCR-Sprachen: Deutsch (Standard) + Englisch
  - Superuser samuel angelegt
- Proxy Host in Nginx Proxy Manager: paperless.brueggemann.site ->
  192.168.178.36:8010 (HTTP, Websockets aktiviert, kein eigenes SSL-
  Zertifikat noetig - TLS-Terminierung uebernimmt Cloudflare)
- Published Application Route in Cloudflare Tunnel:
  paperless.brueggemann.site -> 192.168.178.36:80 (zeigt auf NPMs
  Proxy-Port, NICHT auf den Admin-Port 81 - NPM routet dann intern
  per Hostname-Matching zu Paperless)
- Oeffentlicher Zugriff erfolgreich getestet (Mobilfunknetz):
  https://paperless.brueggemann.site laeuft mit gueltigem HTTPS

### Wichtige Lehre: Sonderzeichen in .env-Dateien
Ein Passwort mit "$"-Zeichen in stacks/paperless/.env fuehrte zu
einem stillen Fehler: Docker Compose interpretiert "$" als Beginn
einer Variablen-Referenz (${VARIABLE}) und ersetzt unbekannte
Referenzen durch einen leeren String, OHNE Fehler beim Start zu
werfen (nur eine leicht zu uebersehende WARN-Zeile). Ergebnis: das
tatsaechlich in der Datenbank gespeicherte Passwort unterschied sich
vom absichtlich gesetzten. Erkennbar an: "password authentication
failed" in den Logs trotz vermeintlich korrekter .env.
Lehre fuer alle kuenftigen Stacks: Passwoerter in .env-Dateien OHNE
"$"-Zeichen waehlen (alternativ mit "$$" escapen). Bei "password
authentication failed"-Fehlern trotz korrekt aussehender .env: mit
grep '\$' .env pruefen.

### Bekannte offene Probleme (bewusst zurueckgestellt)
- QEMU Guest Agent laeuft nicht in VM100.
- Home-Assistant-Live-Status-Widget in Homepage: weiterhin 401.
- Home-Assistant-API-Token: weiterhin ausstehend zu widerrufen/ersetzen.
- 4-TB-Platte (/mnt/media) ist zu 99% voll (~69 GB frei).
- Paperless: noch kein Backup-Konzept fuer /mnt/nas6tb/paperless
  (pgdata + media) definiert - bei Gelegenheit klaeren.

### Nächste Schritte (Ziel der kommenden Session)
1. Nextcloud deployen (Daten auf 6-TB-Platte, gleiche Infrastruktur:
   NPM-Proxy-Host + Cloudflare Published Application Route)
2. Danach Immich
3. QEMU Guest Agent in VM100 installieren
4. Home-Assistant-API-Token widerrufen und neu setzen
5. Backup-Konzept fuer Paperless-Daten (und perspektivisch Nextcloud/
   Immich) definieren

### Zugriff / Referenzen (Ergänzung)
- Paperless-ngx (lokal): http://192.168.178.36:8010
- Paperless-ngx (öffentlich): https://paperless.brueggemann.site

## Aktueller Stand (13.07.2026, Ende Session - Paperless-ngx live)

### Vollständig abgeschlossen
- Paperless-ngx eingerichtet (stacks/paperless/, PostgreSQL 16 + Redis 7
  + ghcr.io/paperless-ngx/paperless-ngx:latest):
  - Daten auf 6-TB-Platte: /mnt/nas6tb/paperless/{data,media,export,
    consume,pgdata,redisdata}
  - Lokal erreichbar: http://192.168.178.36:8010
  - OCR-Sprachen: Deutsch (Standard) + Englisch
  - Superuser samuel angelegt
- Proxy Host in Nginx Proxy Manager: paperless.brueggemann.site ->
  192.168.178.36:8010 (HTTP, Websockets aktiviert, kein eigenes SSL-
  Zertifikat noetig - TLS-Terminierung uebernimmt Cloudflare)
- Published Application Route in Cloudflare Tunnel:
  paperless.brueggemann.site -> 192.168.178.36:80 (zeigt auf NPMs
  Proxy-Port, NICHT auf den Admin-Port 81 - NPM routet dann intern
  per Hostname-Matching zu Paperless)
- Oeffentlicher Zugriff erfolgreich getestet (Mobilfunknetz):
  https://paperless.brueggemann.site laeuft mit gueltigem HTTPS
- Homepage aktualisiert: neue Kategorie "Dokumente & Cloud" mit
  Paperless-ngx (lokale URL, damit auch Nextcloud/Immich spaeter dort
  einsortiert werden koennen)

### Wichtige Lehre: Sonderzeichen in .env-Dateien
Ein Passwort mit "$"-Zeichen in stacks/paperless/.env fuehrte zu
einem stillen Fehler: Docker Compose interpretiert "$" als Beginn
einer Variablen-Referenz (${VARIABLE}) und ersetzt unbekannte
Referenzen durch einen leeren String, OHNE Fehler beim Start zu
werfen (nur eine leicht zu uebersehende WARN-Zeile). Ergebnis: das
tatsaechlich in der Datenbank gespeicherte Passwort unterschied sich
vom absichtlich gesetzten. Erkennbar an: "password authentication
failed" in den Logs trotz vermeintlich korrekter .env.
Lehre fuer alle kuenftigen Stacks: Passwoerter in .env-Dateien OHNE
"$"-Zeichen waehlen (alternativ mit "$$" escapen). Bei "password
authentication failed"-Fehlern trotz korrekt aussehender .env: mit
grep '\$' .env pruefen.

### Bekannte offene Probleme (bewusst zurueckgestellt)
- QEMU Guest Agent laeuft nicht in VM100.
- Home-Assistant-Live-Status-Widget in Homepage: weiterhin 401.
- Home-Assistant-API-Token: weiterhin ausstehend zu widerrufen/ersetzen.
- 4-TB-Platte (/mnt/media) ist zu 99% voll (~69 GB frei).
- Paperless: noch kein Backup-Konzept fuer /mnt/nas6tb/paperless
  (pgdata + media) definiert - bei Gelegenheit klaeren.

### Nächste Schritte (Ziel der kommenden Session)
1. Nextcloud deployen (Daten auf 6-TB-Platte, gleiche Infrastruktur:
   NPM-Proxy-Host + Cloudflare Published Application Route)
2. Danach Immich
3. QEMU Guest Agent in VM100 installieren
4. Home-Assistant-API-Token widerrufen und neu setzen
5. Backup-Konzept fuer Paperless-Daten (und perspektivisch Nextcloud/
   Immich) definieren

### Zugriff / Referenzen (Ergänzung)
- Paperless-ngx (lokal): http://192.168.178.36:8010
- Paperless-ngx (öffentlich): https://paperless.brueggemann.site

## Aktueller Stand (13.07.2026, Ende Session - Nextcloud live)

### Vollständig abgeschlossen
- Nextcloud eingerichtet (stacks/nextcloud/, PostgreSQL 16 + Redis 7 +
  nextcloud:latest, Version 34.0.1.2 bei Installation):
  - Daten auf 6-TB-Platte: /mnt/nas6tb/nextcloud/{html,data,pgdata,
    redisdata}
  - Lokal erreichbar: http://192.168.178.36:8020
  - Admin-Nutzer samuel bei Installation automatisch angelegt
  - Trusted Domains gesetzt: cloud.brueggemann.site, 192.168.178.36
  - Reverse-Proxy-Konfiguration per occ gesetzt: trusted_proxies
    (172.26.0.1, Docker-Gateway von nextcloud_default), overwriteprotocol
    (https), overwritehost, overwrite.cli.url (jeweils
    cloud.brueggemann.site)
- Proxy Host in Nginx Proxy Manager: cloud.brueggemann.site ->
  192.168.178.36:8020, inkl. Advanced-Config fuer grosse Uploads
  (client_max_body_size 10G, erweiterte Timeouts fuer Sync/Uploads)
- Published Application Route in Cloudflare Tunnel:
  cloud.brueggemann.site -> 192.168.178.36:80
- Oeffentlicher Zugriff erfolgreich getestet: https://cloud.brueggemann.site
- Homepage: Nextcloud-Eintrag ergaenzt (Kategorie "Dokumente & Cloud",
  lokale URL)

### Wichtige Lehre: NPM-Proxy-Host nicht vergessen
Beim ersten Test von cloud.brueggemann.site wurde faelschlich auf
Paperless umgeleitet. Ursache: der Proxy Host in Nginx Proxy Manager
fuer cloud.brueggemann.site war schlicht noch nicht angelegt worden
(NPM-Schritt vergessen) - Cloudflare-Route existierte zwar, aber ohne
passenden NPM-Eintrag griff eine bestehende/Standard-Weiterleitung.
Lehre: Bei jedem neuen Dienst ZWEI Stellen pruefen, bevor getestet
wird: (1) Proxy Host in NPM (Hosts -> Proxy Hosts), (2) Published
Application Route in Cloudflare. Beide muessen existieren, nicht nur
eine der beiden.

### Bekannte offene Probleme (bewusst zurueckgestellt)
- QEMU Guest Agent laeuft nicht in VM100.
- Home-Assistant-Live-Status-Widget in Homepage: weiterhin 401.
- Home-Assistant-API-Token: weiterhin ausstehend zu widerrufen/ersetzen.
- 4-TB-Platte (/mnt/media) ist zu 99% voll (~69 GB frei).
- Kein Backup-Konzept fuer Paperless- und jetzt auch Nextcloud-Daten
  auf /mnt/nas6tb definiert.

### Nächste Schritte (Ziel der kommenden Session)
1. Immich deployen (letzter der drei geplanten Dienste, hoechster
   Ressourcenbedarf wegen ML-basierter Foto-Indexierung)
2. QEMU Guest Agent in VM100 installieren
3. Home-Assistant-API-Token widerrufen und neu setzen
4. Backup-Konzept fuer Paperless- und Nextcloud-Daten definieren

### Zugriff / Referenzen (Ergänzung)
- Nextcloud (lokal): http://192.168.178.36:8020
- Nextcloud (öffentlich): https://cloud.brueggemann.site

## Aktueller Stand (13.07.2026, Ende Session - alle drei Cloud-Dienste live)

### Vollständig abgeschlossen
- VM100-Systemdisk von 32GB auf 64GB erweitert (Proxmox-Thin-Pool hatte
  reichlich Reserve: 15,53% von 175,99GB belegt). Ablauf: qm resize
  100 scsi0 +32G auf dem Host, danach growpart + resize2fs in der VM
  (kein LVM in VM100, reines Partitionsschema). Grund: 96% Belegung
  durch die vielen neuen Docker-Images (Paperless, Nextcloud, Immich
  zusammen mehrere GB).
- Immich eingerichtet (stacks/immich/, ghcr.io/immich-app/immich-server
  + immich-machine-learning + valkey (redis-fork) + ghcr.io/immich-app/
  postgres mit VectorChord/pgvector-Erweiterung fuer KI-Bildersuche):
  - Daten auf 6-TB-Platte: /mnt/nas6tb/immich/{upload,pgdata,model-cache}
  - Lokal erreichbar: http://192.168.178.36:2283
  - DB_STORAGE_TYPE=HDD gesetzt (6-TB-Platte ist klassische Festplatte,
    keine SSD - passt Postgres-IO-Einstellungen entsprechend an)
  - Admin-Account bei Erstaufruf im Browser angelegt (nicht wie bei
    Nextcloud/Paperless automatisch per .env)
  - Bekannte harmlose Log-Meldung: "database "samuel" does not exist"
    wiederholt sich in den Logs (interner Healthcheck verbindet ohne
    explizite Datenbankangabe, faellt dann auf den Nutzernamen zurueck).
    Alle Container laufen "healthy", Funktion nicht beeintraechtigt.
- Alle drei Cloud-Dienste jetzt live und oeffentlich erreichbar:
  - Proxy Hosts in NPM angelegt fuer photos.brueggemann.site (Port 2283,
    inkl. groesserer Upload-Limits: client_max_body_size 50G fuer
    Videos/RAW-Dateien)
  - Published Application Route in Cloudflare: photos.brueggemann.site
    -> 192.168.178.36:80
  - Oeffentlicher Zugriff getestet: https://photos.brueggemann.site
- Homepage aktualisiert: Immich ergaenzt (Kategorie "Dokumente & Cloud"),
  alle drei Cloud-Dienste (Paperless, Nextcloud, Immich) nutzen
  bewusst die LOKALE URL in der Homepage (schnellerer Zugriff im
  Heimnetz), waehrend der oeffentliche Zugriff von unterwegs ueber die
  brueggemann.site-Subdomains laeuft

### Funktionsklaerung: Nextcloud und Immich sind unabhaengig
Auf Nachfrage geklaert: Nextcloud und Immich teilen sich KEINE Fotos
automatisch - getrennte Datenbanken, getrennte Speicherorte
(/mnt/nas6tb/nextcloud/data vs. /mnt/nas6tb/immich/upload). Bewusste
Entscheidung, beide Dienste getrennt zu betreiben (Immich = Foto-/
Video-Backup mit KI-Funktionen, Nextcloud = Dokumente/Dateien/Sync).
Bei Bedarf liesse sich der Immich-Upload-Ordner spaeter als "External
Storage" read-only in Nextcloud einbinden.

### Naechster Schritt: Partner-Freigabe in Immich
Immich bietet eingebaute Freigabefunktionen (geteilte Alben, oeffentliche
Links mit Passwortschutz/Ablaufdatum, Partner-Sharing fuer dauerhafte
komplette Bibliotheksfreigabe). Einrichtung: zweiter Nutzer-Account unter
Administration -> Users, danach Partner Sharing in den Account Settings
des zweiten Nutzers. Noch nicht final eingerichtet, nur Weg dokumentiert.

### Bekannte offene Probleme (bewusst zurueckgestellt)
- QEMU Guest Agent laeuft nicht in VM100.
- Home-Assistant-Live-Status-Widget in Homepage: weiterhin 401.
- Home-Assistant-API-Token: weiterhin ausstehend zu widerrufen/ersetzen.
- 4-TB-Platte (/mnt/media) ist zu 99% voll (~69 GB frei).
- Kein Backup-Konzept fuer Paperless-, Nextcloud- und jetzt auch
  Immich-Daten auf /mnt/nas6tb definiert - bei drei produktiven
  Diensten mit privaten Daten (Dokumente, Fotos) zunehmend dringend.
- Immich-Partner-Freigabe noch nicht final eingerichtet (nur Weg
  dokumentiert, siehe oben).

### Naechste Schritte (Ziel der kommenden Session)
1. Backup-Konzept fuer /mnt/nas6tb (Paperless, Nextcloud, Immich)
   definieren und umsetzen - hoechste Prioritaet, da jetzt drei
   Dienste mit unwiederbringlichen Nutzerdaten produktiv laufen
2. Immich Partner-Freigabe einrichten (falls gewuenscht)
3. QEMU Guest Agent in VM100 installieren
4. Home-Assistant-API-Token widerrufen und neu setzen
5. Immich Handy-App einrichten (Server-URL: https://photos.brueggemann.site)

### Zugriff / Referenzen (Ergänzung)
- Immich (lokal): http://192.168.178.36:2283
- Immich (öffentlich): https://photos.brueggemann.site
- Alle drei Cloud-Dienste im Überblick:
  - Paperless-ngx: lokal 8010, öffentlich paperless.brueggemann.site
  - Nextcloud: lokal 8020, öffentlich cloud.brueggemann.site
  - Immich: lokal 2283, öffentlich photos.brueggemann.site

## Aktueller Stand (13.07.2026, Ende Session - alle drei Cloud-Dienste live)

### Vollständig abgeschlossen
- VM100-Systemdisk von 32GB auf 64GB erweitert (Proxmox-Thin-Pool hatte
  reichlich Reserve: 15,53% von 175,99GB belegt). Ablauf: qm resize
  100 scsi0 +32G auf dem Host, danach growpart + resize2fs in der VM
  (kein LVM in VM100, reines Partitionsschema). Grund: 96% Belegung
  durch die vielen neuen Docker-Images (Paperless, Nextcloud, Immich
  zusammen mehrere GB).
- Immich eingerichtet (stacks/immich/, ghcr.io/immich-app/immich-server
  + immich-machine-learning + valkey (redis-fork) + ghcr.io/immich-app/
  postgres mit VectorChord/pgvector-Erweiterung fuer KI-Bildersuche):
  - Daten auf 6-TB-Platte: /mnt/nas6tb/immich/{upload,pgdata,model-cache}
  - Lokal erreichbar: http://192.168.178.36:2283
  - DB_STORAGE_TYPE=HDD gesetzt (6-TB-Platte ist klassische Festplatte,
    keine SSD - passt Postgres-IO-Einstellungen entsprechend an)
  - Admin-Account bei Erstaufruf im Browser angelegt (nicht wie bei
    Nextcloud/Paperless automatisch per .env)
  - Bekannte harmlose Log-Meldung: "database "samuel" does not exist"
    wiederholt sich in den Logs (interner Healthcheck verbindet ohne
    explizite Datenbankangabe, faellt dann auf den Nutzernamen zurueck).
    Alle Container laufen "healthy", Funktion nicht beeintraechtigt.
- Alle drei Cloud-Dienste jetzt live und oeffentlich erreichbar:
  - Proxy Hosts in NPM angelegt fuer photos.brueggemann.site (Port 2283,
    inkl. groesserer Upload-Limits: client_max_body_size 50G fuer
    Videos/RAW-Dateien)
  - Published Application Route in Cloudflare: photos.brueggemann.site
    -> 192.168.178.36:80
  - Oeffentlicher Zugriff getestet: https://photos.brueggemann.site
- Homepage aktualisiert: Immich ergaenzt (Kategorie "Dokumente & Cloud"),
  alle drei Cloud-Dienste (Paperless, Nextcloud, Immich) nutzen
  bewusst die LOKALE URL in der Homepage (schnellerer Zugriff im
  Heimnetz), waehrend der oeffentliche Zugriff von unterwegs ueber die
  brueggemann.site-Subdomains laeuft

### Funktionsklaerung: Nextcloud und Immich sind unabhaengig
Auf Nachfrage geklaert: Nextcloud und Immich teilen sich KEINE Fotos
automatisch - getrennte Datenbanken, getrennte Speicherorte
(/mnt/nas6tb/nextcloud/data vs. /mnt/nas6tb/immich/upload). Bewusste
Entscheidung, beide Dienste getrennt zu betreiben (Immich = Foto-/
Video-Backup mit KI-Funktionen, Nextcloud = Dokumente/Dateien/Sync).
Bei Bedarf liesse sich der Immich-Upload-Ordner spaeter als "External
Storage" read-only in Nextcloud einbinden.

### Naechster Schritt: Partner-Freigabe in Immich
Immich bietet eingebaute Freigabefunktionen (geteilte Alben, oeffentliche
Links mit Passwortschutz/Ablaufdatum, Partner-Sharing fuer dauerhafte
komplette Bibliotheksfreigabe). Einrichtung: zweiter Nutzer-Account unter
Administration -> Users, danach Partner Sharing in den Account Settings
des zweiten Nutzers. Noch nicht final eingerichtet, nur Weg dokumentiert.

### Bekannte offene Probleme (bewusst zurueckgestellt)
- QEMU Guest Agent laeuft nicht in VM100.
- Home-Assistant-Live-Status-Widget in Homepage: weiterhin 401.
- Home-Assistant-API-Token: weiterhin ausstehend zu widerrufen/ersetzen.
- 4-TB-Platte (/mnt/media) ist zu 99% voll (~69 GB frei).
- Kein Backup-Konzept fuer Paperless-, Nextcloud- und jetzt auch
  Immich-Daten auf /mnt/nas6tb definiert - bei drei produktiven
  Diensten mit privaten Daten (Dokumente, Fotos) zunehmend dringend.
- Immich-Partner-Freigabe noch nicht final eingerichtet (nur Weg
  dokumentiert, siehe oben).

### Naechste Schritte (Ziel der kommenden Session)
1. Backup-Konzept fuer /mnt/nas6tb (Paperless, Nextcloud, Immich)
   definieren und umsetzen - hoechste Prioritaet, da jetzt drei
   Dienste mit unwiederbringlichen Nutzerdaten produktiv laufen
2. Immich Partner-Freigabe einrichten (falls gewuenscht)
3. QEMU Guest Agent in VM100 installieren
4. Home-Assistant-API-Token widerrufen und neu setzen
5. Immich Handy-App einrichten (Server-URL: https://photos.brueggemann.site)

### Zugriff / Referenzen (Ergänzung)
- Immich (lokal): http://192.168.178.36:2283
- Immich (öffentlich): https://photos.brueggemann.site
- Alle drei Cloud-Dienste im Überblick:
  - Paperless-ngx: lokal 8010, öffentlich paperless.brueggemann.site
  - Nextcloud: lokal 8020, öffentlich cloud.brueggemann.site
  - Immich: lokal 2283, öffentlich photos.brueggemann.site

## Aktueller Stand (13.07.2026, während Session - Watchtower-Fix)

### Vollständig abgeschlossen
- Watchtower-Label ergänzt bei: Nginx Proxy Manager, Samba, Cloudflared
  (com.centurylinklabs.watchtower.enable=true) - diese drei werden ab
  sofort automatisch aktualisiert
- Bewusst OHNE Label gelassen: Paperless-ngx, Nextcloud, Immich -
  diese bleiben manuell aktualisiert, da Versionssprünge bei allen
  dreien potenziell breaking Datenbank-Migrationen mit sich bringen
  können und aktuell noch kein Backup-Konzept existiert
- WICHTIGER BUGFIX gefunden und behoben: Watchtower-Container war
  gestoppt (nicht mehr vorhanden trotz "restart: unless-stopped" in
  der Config - vermutlich manuell gestoppt oder bei einem früheren
  VM-Neustart nicht wiederhochgekommen). Zusätzlich lief die
  Konfiguration in einem Modus, der den Zeitplan de facto deaktivierte:
  WATCHTOWER_HTTP_API_UPDATE=true unterdrückt automatische
  Zeitplan-Läufe, außer man setzt zusätzlich
  WATCHTOWER_HTTP_API_PERIODIC_POLLS=true. Das bedeutet: seit der
  Ersteinrichtung von Watchtower gab es hoechstwahrscheinlich NIE
  automatische, zeitgesteuerte Updates - nur manuelle Ausloesung per
  HTTP-API war moeglich.
- Fix: WATCHTOWER_HTTP_API_PERIODIC_POLLS=true in
  stacks/watchtower/compose.yml ergänzt. Bestätigt per Logs: "Scheduling
  first run: 2026-07-14 04:00:00" - Zeitplan läuft jetzt wie ursprünglich
  vorgesehen (taeglich 4 Uhr)

### Bekannte offene Probleme (bewusst zurueckgestellt)
- Backup-Konzept fuer /mnt/nas6tb weiterhin nicht umgesetzt - solange
  das nicht steht, bleiben Paperless/Nextcloud/Immich bewusst von
  automatischen Updates ausgenommen
- QEMU Guest Agent laeuft nicht in VM100
- Home-Assistant-API-Token weiterhin ausstehend zu widerrufen/ersetzen
- Externe Festplatte 2 (WD, 3,6TB) zeigt einen SMART
  Current_Pending_Sector (1 Sektor) im Ordner
  Bilder/2023/Urlaub bad Schandau/Ausgabe - Datei/Bereich beim Kopieren
  vermutlich uebersprungen, ggf. spaeter erneuten Leseversuch
  unternehmen oder als Verlust hinnehmen

### Nächste Schritte (Ziel der kommenden Session)
1. Backup-Konzept fuer /mnt/nas6tb definieren und umsetzen (weiterhin
   hoechste Prioritaet)
2. Nach Abschluss des Foto-Imports: Watchtower-Label-Strategie fuer
   Paperless/Nextcloud/Immich neu bewerten, sobald Backups stehen
3. QEMU Guest Agent installieren
4. Home-Assistant-API-Token erneuern
5. RAM-Aufruestung (2x 8GB DDR4-2400 UDIMM 2Rx8, bestellt/in Pruefung)
   einbauen und Speicherzuweisung der VMs anpassen

## Aktueller Stand (13.07.2026, Ende Session - GPU-ML, RAM-Planung, 2. Foto-Import)

### Vollständig abgeschlossen
- Immich Machine-Learning-Beschleunigung per Gaming-PC eingerichtet:
  - Docker Desktop + WSL2 auf Windows-Gaming-PC installiert (RTX 3080,
    10GB VRAM, GPU-Passthrough in Docker bestaetigt)
  - Container immich-ml-gpu (ghcr.io/immich-app/immich-machine-learning:
    release-cuda) laeuft auf dem Gaming-PC (192.168.178.25:3003)
  - In Immich (Administration -> Settings -> Machine Learning) als
    PRIMAERE URL eingetragen, Server-interner ML-Dienst bleibt als
    Fallback-URL bestehen (Immich probiert URLs der Reihe nach durch)
  - Bestaetigt per Logs: CUDAExecutionProvider wird fuer alle Modelle
    (Gesichtserkennung, OCR, CLIP/Smart Search) genutzt
  - Gedacht als temporaere Beschleunigung fuer grosse Imports, nicht
    zwingend dauerhaft - Container einfach stoppen/starten
    (docker stop/start immich-ml-gpu), Immich faellt automatisch auf
    den Server-Fallback zurueck

- RAM-Aufruestung geplant (noch nicht eingebaut): 2x 8GB DDR4-2400
  UDIMM 2Rx8 non-ECC bestellt (BRAINZAP, kompatibel zu vorhandenen
  Crucial Ballistix Sport LT BLS8G4D240FSB.16FARG-Modulen, ebenfalls
  Dual-Rank/2Rx8). Board (Gigabyte Z170-HD3P-CF) unterstuetzt bis 64GB
  auf 4 Slots, aktuell 2 belegt/2 frei. Grund: VMs allein beanspruchen
  12GB (VM100: 8GB, VM101: 4GB) von physisch 16GB, Host bekommt nur
  ~4GB, sichtbar an Swap-Nutzung (3,1GB belegt). Ziel nach Einbau:
  32GB gesamt, danach VM-Speicherzuweisungen neu verteilen.

- Watchtower-Bugfix (siehe vorheriger Eintrag) + Labels fuer NPM,
  Samba, Cloudflared ergaenzt - automatische Updates laufen jetzt
  taeglich um 4 Uhr wie vorgesehen.

- Zweite externe Festplatte importiert (WD, 3,6TB, Serial
  WD-WX82DC4KCY74): Bilder-Ordner (1,5TB) per rsync in
  /mnt/nas6tb/immich/external/platte2-bilder/ kopiert. Enthaelt u.a.
  Hochzeitsfotos, Kalenderbilder, Urlaubsfotos (Meer, Senegal),
  Reitsport-Videos (Norma), Lightroom/Luminar-Kataloge, Sprites/
  Wallpaper-Sammlungen.
  - SMART-Check der Quellplatte: Current_Pending_Sector=1,
    Reallocated_Sector_Ct=0, Gesamtstatus PASSED - vermutlich
    isolierter Einzelsektor-Defekt, nicht akut kritisch, aber im
    Blick behalten
  - Betroffener Ordner "2023/Urlaub bad Schandau/Ausgabe" laesst sich
    wegen des Sektordefekts nicht vollstaendig lesen (readdir I/O
    error) - Rest der 1,5TB erfolgreich kopiert und verifiziert

### Wichtige Lehre: Zielordner-Berechtigungen vor rsync pruefen
Der Zielordner platte2-bilder/Wallpaper (und weitere Unterordner)
gehoerten unerwartet dhcpcd:netdev mit 0700-Rechten statt dem
eigenen Nutzer samuel - Ursache nicht abschliessend geklaert
(vermutlich ein anderer Prozess/Container hat den Ordner mit
abweichender UID angelegt, bevor rsync lief). Fuehrte zu hunderten
"Permission denied"-Fehlern beim ersten Kopierversuch.
Lehre: Bei komplexen Zielverzeichnissen (insbesondere unterhalb von
Docker-Volume-Mounts) vor grossen rsync-Uebertragungen pruefen:
stat <zielordner> - insbesondere nach fehlgeschlagenen/abgebrochenen
vorherigen Laeufen. Fix: sudo chown -R <user>:<user> <ordner> &&
sudo chmod -R u+rwX,go+rX <ordner> VOR dem naechsten rsync-Versuch,
nicht danach.

### Bekannte offene Probleme (bewusst zurueckgestellt)
- QEMU Guest Agent laeuft nicht in VM100.
- Home-Assistant-Live-Status-Widget in Homepage: weiterhin 401.
- Home-Assistant-API-Token: weiterhin ausstehend zu widerrufen/ersetzen.
- 4-TB-Platte (/mnt/media) ist zu 99% voll (~69 GB frei).
- Kein Backup-Konzept fuer Paperless-, Nextcloud- und Immich-Daten auf
  /mnt/nas6tb definiert - weiterhin hoechste Prioritaet.
- RAM-Module bestellt, aber noch nicht eingebaut.
- "2023/Urlaub bad Schandau/Ausgabe" auf der WD-Platte teilweise
  unlesbar (SMART-Sektordefekt) - bei Interesse spaeter gezielter
  Rettungsversuch mit ddrescue moeglich.
- Immich Partner-Freigabe weiterhin nicht final eingerichtet.

### Naechste Schritte (Ziel der kommenden Session)
1. RAM-Module einbauen, 32GB verifizieren, VM-Speicherzuweisungen
   anpassen
2. Backup-Konzept fuer /mnt/nas6tb definieren und umsetzen
3. Weitere externe Festplatten nach etabliertem Muster importieren
   (Berechtigungen vorab pruefen!)
4. Immich Partner-Freigabe einrichten
5. QEMU Guest Agent installieren, Home-Assistant-Token erneuern

### Zugriff / Referenzen (Ergänzung)
- Immich Machine Learning (Gaming-PC, temporaer): 192.168.178.25:3003
- Immich External Libraries: /mnt/nas6tb/immich/external/
  {platte1-bilder, platte2-bilder}
  
## Aktueller Stand (17.07.2026 - Intel iGPU Passthrough, kritischer Nextcloud-Vorfall)

### Vollständig abgeschlossen: Intel Quick Sync Hardware-Transkodierung
- VT-d im BIOS war bereits aktiviert (Gigabyte-Board), IOMMU-Kernel-
  Parameter (intel_iommu=on iommu=pt) zusätzlich in GRUB gesetzt -
  WICHTIG: System nutzt klassisches GRUB (BIOS-Boot), NICHT
  proxmox-boot-tool/systemd-boot. Aenderungen gehoeren in
  /etc/default/grub (GRUB_CMDLINE_LINUX_DEFAULT), danach
  sudo update-grub - NICHT /etc/kernel/cmdline, das greift bei diesem
  System nicht.
- vfio-pci als Treiber fuer die iGPU (Intel HD 530, PCI-ID 8086:1912)
  konfiguriert (/etc/modprobe.d/vfio.conf), i915 auf Host-Ebene
  geblacklistet (/etc/modprobe.d/blacklist.conf)
- iGPU per PCI-Passthrough an VM100 durchgereicht:
  sudo qm set 100 -hostpci0 00:02.0,pcie=1,x-vga=0
  Host selbst hat dadurch keine eigene Grafikausgabe mehr fuer die
  Linux-Konsole (BIOS/GRUB-Anzeige bleibt aber erhalten, da vor
  Kernel-Uebernahme durch vfio-pci)
- In VM100 laedt automatisch der i915-Treiber fuer die durchgereichte
  Karte, /dev/dri/{card0,card1,renderD128} verfuegbar
- Jellyfin-Container um GPU-Geraetezugriff erweitert
  (stacks/jellyfin/compose.yml: devices: /dev/dri:/dev/dri)
- Hardware-Beschleunigung in Jellyfin aktiviert (Dashboard -> Playback
  -> Transcoding: Intel QuickSync/QSV, VA-API Device
  /dev/dri/renderD128), inkl. Trickplay-Hardwarebeschleunigung
  (Dashboard -> Playback -> Trickplay)

### WICHTIGE EINSCHRAENKUNG: Kein HDR/Dolby-Vision-Support
Die Intel HD 530 (Skylake, Gen9) kann laut Herstellerspezifikation
KEIN 10-bit-HEVC (HEVC Profile 2) hardwarebeschleunigt decodieren -
das betrifft praktisch alle HDR- und Dolby-Vision-Inhalte. Symptom:
Stream-Abstuerze auf Mobilgeraeten bei HDR-Filmen, Trickplay-Fehler
mit "No support for codec hevc profile 2".
Fix: Dashboard -> Playback -> Transcoding -> "Enable hardware
decoding for" -> HEVC (bzw. "HEVC 10-bit" falls separat aufgefuehrt)
DEAKTIVIERT. Diese Inhalte fallen automatisch auf Software-Decoding
zurueck (funktioniert, aber langsamer gestartet, mehr CPU-Last nur
fuer HDR-Titel). Normales H.264 und 8-bit-HEVC bleiben
hardwarebeschleunigt.
Langfristige Loesung waere ein CPU-Upgrade auf 7. Generation
"Kaby Lake" (z.B. i5-7500 oder i7-7700) - das Board (GA-Z170-HD3P)
unterstuetzt das offiziell per BIOS-Update, volle HEVC-10bit/Dolby-
Vision-Hardwareunterstuetzung ab Gen9.5-Grafik (UHD 630). Nicht
umgesetzt, nur recherchiert als moegliche kuenftige Massnahme.
CPU-Obergrenze fuer dieses Board ist i7-7700 (Coffee Lake/8. Gen wird
von Intel elektronisch gesperrt, kein BIOS-Update hilft dagegen).

### KRITISCHER VORFALL: Nextcloud OOM, System fast kollabiert
Am 17.07. gegen 08:43 Uhr: Host bei CPU 100%, RAM 96,5%, Swap 100%
voll, Load Average 60 auf 4 Kernen. Immich (zu dem Zeitpunkt vom
Nutzer bereits manuell deaktiviert) zeigte "Exited" - vermutlich vom
Kernel OOM-gekillt, nicht die eigentliche Ursache.
Ursache identifiziert: nextcloud-Container zeigte 373% CPU und
17,4GB RAM - dutzende apache2-Worker-Prozesse (400-500MB je Prozess)
ohne jegliches Speicherlimit, ueber Stunden akkumuliert. Auslöser
vermutlich (nicht abschliessend bestaetigt): eine Android-Nextcloud-
App mit veraltetem/ungueltigem App-Passwort, die wiederholt gegen den
eingebauten Brute-Force-Schutz lief (Log zeigt wiederholte
"TooManyRequests"-Exceptions von Nextcloud-android/34.0.1).
Sofortmassnahme: docker compose restart nextcloud - System erholte
sich sofort (RAM von 237MB frei auf 16GB frei, Swap von 100% auf
faktisch leer).
Dauerhafter Fix: Speicherlimit in stacks/nextcloud/compose.yml
ergaenzt (deploy.resources.limits.memory: 4G beim app-Service) -
verhindert kuenftig, dass ein einzelner Container den gesamten Host
in die Knie zwingen kann.

### Sicherheitshinweis aus den Nextcloud-Logs
In den Logs sichtbar: automatisierte Exploit-Scan-Versuche von
aussen (Pfad-Traversal-Versuche wie /etc/passwd, bekannte Router-
Backdoor-Pfade wie /boafrm/formSysCmd). Alle liefen ins Leere
(Nextcloud hat korrekt abgelehnt), aber bestaetigt: seit der
oeffentlichen Freigabe treffen reale automatisierte Angriffsversuche
ein, nicht nur theoretisch. Ueberlegenswert: Cloudflare WAF
(kostenlos im bestehenden Tunnel-Setup verfuegbar) vorschalten, um
solche Anfragen bereits vor Nextcloud abzufangen. Noch nicht
umgesetzt.

### Bekannte offene Probleme (bewusst zurueckgestellt)
- Android-Nextcloud-App-Login pruefen/erneuern (vermutete Ursache des
  OOM-Vorfalls) - noch nicht durchgefuehrt
- 4 Google-Kalender-Abonnements liefern 401 Unauthorized (Google hat
  vermutlich Zugriff widerrufen/URL erfordert jetzt Anmeldung) -
  unter Einstellungen -> Kalender -> Abonnements neu einzurichten
- Cloudflare WAF fuer zusaetzlichen Schutz vor Nextcloud noch nicht
  eingerichtet
- Kein Speicherlimit fuer andere Container gesetzt (nur Nextcloud
  bisher) - ggf. auch fuer andere ressourcenintensive Dienste
  (Paperless, Immich bei Reaktivierung) sinnvoll
- Immich weiterhin vom Nutzer deaktiviert (Grund nicht dokumentiert,
  vermutlich RAM-Engpaesse waehrend der IOMMU/GPU-Arbeiten)
- Backup-Konzept fuer /mnt/nas6tb weiterhin nicht umgesetzt -
  angesichts des heutigen Vorfalls (System nahe am Kollaps) umso
  dringlicher
- Jellyfin oeffentliche Route (jellyfin.brueggemann.site) wurde
  besprochen, aber laut Nutzer-Entscheidung ("Überprüfen wir das
  erst mal") NICHT umgesetzt - Sicherheitscheck (Nutzer-Passwoerter,
  Quick-Connect-Verhalten) wurde durchgefuehrt und fuer unbedenklich
  befunden, NPM/Cloudflare-Route aber nie tatsaechlich angelegt

### Naechste Schritte (Ziel der kommenden Session)
1. Backup-Konzept fuer /mnt/nas6tb definieren und umsetzen (nach dem
   heutigen Beinahe-Ausfall hoechste Prioritaet)
2. Android-Nextcloud-App-Verbindung pruefen und erneuern
3. Speicherlimits fuer weitere Container in Erwaegung ziehen
4. Cloudflare WAF pruefen/einrichten
5. Google-Kalender-Abos in Nextcloud neu verbinden
6. Falls gewuenscht: Jellyfin oeffentliche Route final einrichten
   (Sicherheitscheck bereits erledigt)
7. Falls gewuenscht: CPU-Upgrade auf i5-7500/i7-7700 fuer volles
   HDR/Dolby-Vision-Hardware-Transcoding

### Zugriff / Referenzen (Ergänzung)
- Jellyfin Hardware-Transcoding: aktiv fuer H.264/8bit-HEVC, Software-
  Fallback fuer HDR/10bit-HEVC/Dolby Vision
- GPU-Passthrough: VM100 hostpci0 = Proxmox-Host iGPU (00:02.0)

## Aktueller Stand (17.-18.07.2026 - Backup-System vollstaendig eingerichtet)

### Vollständig abgeschlossen: Verschlüsseltes automatisiertes Backup-System

**Hardware:**
- Externe 4-TB-USB-Festplatte (WD Elements, Serial WD-WXU2E7032L5S,
  Modell WDC_WD40NDZW-11A8JS1), dauerhaft am Proxmox-Host angeschlossen
- LUKS2-verschlüsselt, EIGENE Passphrase (getrennt von media4tb/
  media6tb, bewusst isoliert)
- Automatisierungs-Keyfile (/etc/cryptsetup-keys.d/backup-4tb.key)
  als zusaetzlicher Key-Slot - NICHT in crypttab eingetragen, Platte
  bleibt beim normalen Boot verschlossen, wird nur gezielt vom
  Backup-Skript geoeffnet und nach jedem Lauf wieder geschlossen
  (luksOpen -> Arbeit -> luksClose)

**Software-Stack:**
- Kopia (v0.23.1) nativ auf dem Proxmox-Host installiert (nicht in
  Docker/VM100) - Grund: Backup-Platte haengt am Host, ein LUKS-
  open/close-Zyklus laesst sich so ohne VM-Grenze automatisieren
- Repository liegt auf der Backup-Platte (/mnt/backup4tb/kopia-repo),
  AES256-GCM-HMAC-SHA256-Verschluesselung, eigenes Repository-Passwort
  (dritte, unabhaengige Verschluesselungsebene zusaetzlich zu LUKS)
- Kompression: zstd aktiviert (global policy)
- Standard-Retention: 7 taeglich / 4 woechentlich / 24 monatlich /
  3 jaehrlich (Kopia-Standardwerte, nicht angepasst)
- Kopia-Weboberflaeche als systemd-Dienst (kopia-server.service),
  dauerhaft erreichbar unter https://192.168.178.37:51515
  (selbstsigniertes Zertifikat, Browser-Warnung normal)

### Backup-Skript (/root/backup-nightly.sh)

Ablauf:
1. Lock-Datei-Pruefung (/var/run/backup-nightly.lock) - verhindert
   ueberlappende Laeufe, falls ein Durchlauf ungewoehnlich lange dauert
2. Backup-Platte per Keyfile oeffnen und mounten
3. Postgres-Dumps ueber SSH auf VM100 (pg_dump in paperless-db und
   nextcloud-db Containern, KEIN roher Dateikopie-Ansatz - wichtig fuer
   Konsistenz waehrend die Dienste laufen)
4. rsync des kompletten ~/homeserver-Verzeichnisses von VM100
   (deckt automatisch ALLE Docker-Stack-Configs ab, auch neu
   hinzugefuegte - AUSSER stacks/adguard/work/data und
   AdGuardHome.yaml, die root-only Berechtigungen haben; rsync mit
   || true abgesichert, damit einzelne Permission-Fehler den
   Gesamtlauf nicht abbrechen)
5. Kopia-Snapshots: /mnt/nas6tb/{paperless,nextcloud,kavita,immich}
   (Immich nur falls Ordner existiert - Absicherung falls Dienst
   deaktiviert ist), Datenbank-Dumps, homeserver-Configs
6. Home-Assistant-Backup (VM101): ha backups new per SSH ausgeloest,
   dann per "cat ... | tee" uebertragen (NICHT scp/sftp - siehe
   Lehre unten), danach als eigener Kopia-Snapshot gesichert
7. Backup-Platte sauber unmounten und luksClose

**Explizit NICHT gesichert:** Jellyfin-Mediathek (/mnt/media) - zu
gross fuer 4TB, bewusste Nutzerentscheidung, Filme/Serien sind
ohnehin durch Neubeschaffung ersetzbar

### SSH-Infrastruktur fuer Automatisierung
- Eigener SSH-Keypair auf dem Host fuer root (/root/.ssh/
  id_ed25519_backup), Public Key sowohl in VM100 (~/.ssh/
  authorized_keys) als auch im Home-Assistant-SSH-Add-on
  (authorized_keys-Option) hinterlegt
- VM101/Home Assistant: KEIN Standard-SSH (Port 22 blockiert von
  Home Assistant OS) - "Advanced SSH & Web Terminal"-Add-on
  installiert, laeuft auf Port 22222, im gesicherten Modus

### Wichtige Lehren aus der Einrichtung

**1. rsync/set -e Kombination bricht Skripte bei kleinen Fehlern ab**
Ein einzelner rsync-Fehler (Permission denied bei AdGuard-Dateien)
hat wegen "set -e" am Anfang das GESAMTE Skript abgebrochen, inkl.
offen gebliebener LUKS-Platte. Lehre: kritische, nicht-fatale Schritte
mit "|| true" absichern, damit die Platte in jedem Fall sauber
geschlossen wird.

**2. Manuell im Terminal gestartete Skripte sterben bei SSH-Trennung**
Ein manueller Testlauf (ohne nohup) wurde durch Strg+C des
tail-Befehls in DERSELBEN Sitzung unbeabsichtigt per SIGHUP beendet,
mitten im Kavita-Snapshot, nach ~9 Stunden Laufzeit, ohne
Fehlermeldung im Log - die Platte blieb offen. Lehre: manuelle Tests
IMMER mit "nohup ... & disown" starten, damit SSH-Verbindungsabbrueche
den Prozess nicht toeten. Der automatisierte Cronjob ist von diesem
Problem nicht betroffen (Cron startet grundsaetzlich entkoppelt).

**3. Windows-OpenSSH-Client-Bug bei bestimmten SSH-Servern**
"Corrupted MAC on input"-Fehler beim Verbinden zum Home-Assistant-
SSH-Add-on von Windows aus - bekannter Bug im umac-128-etm-Algorithmus
des Windows-eigenen OpenSSH-Clients. Fix: -o MACs=hmac-sha2-256-etm@
openssh.com erzwingen (per SSH-Flag oder in ~/.ssh/config hinterlegt).
Achtung bei Windows: Notepad speichert config-Dateien gerne als
"config.txt" statt "config" - mit Get-ChildItem pruefen.

**4. Home-Assistant "ha"-CLI braucht Login-Shell**
Nicht-interaktive SSH-Befehle (ssh host "ha backups new") schlagen
mit "unauthorized: missing or invalid API token" fehl, weil die
SUPERVISOR_TOKEN-Umgebungsvariable nur in einer echten Login-Shell
gesetzt wird. Fix: Befehle immer als ssh host "bash -lc 'befehl'"
ausfuehren.

**5. SFTP im Advanced-SSH-Add-on erfordert Nutzername "root"**
Mit ssh.username=samuel UND ssh.sftp=true stuerzt das Add-on beim
Start komplett ab (Crash-Loop). Fix: entweder Username auf root
aendern, ODER (gewaehlter Weg) SFTP deaktiviert lassen und
stattdessen "ssh host cat datei > lokale-datei" fuer Dateitransfer
nutzen - funktioniert ohne SFTP-Subsystem ueber den normalen
SSH-Kanal.

**6. Immich-Erstsicherung ist sehr langwierig**
Erster vollstaendiger Kopia-Snapshot von /mnt/nas6tb/immich (2TB,
viele Einzeldateien: RAW-Fotos, Thumbnails) hat fast 10 Stunden
gedauert. Folgelaeufe werden durch Kopias Deduplizierung (nur
neue/geaenderte Dateien) deutlich schneller erwartet, aber
unbestaetigt - im Blick behalten, ob der taegliche 3-Uhr-Zeitraum
ausreicht.

### Cronjob
0 3 * * * /root/backup-nightly.sh

Als root-Crontab eingetragen (sudo crontab -e). Erster automatischer
Lauf: Nacht auf 19.07.2026.

### Bekannte offene Probleme (bewusst zurueckgestellt)
- Restore-Vorgang noch NICHT getestet - hohe Prioritaet fuer naechste
  Session, ein ungetestetes Backup ist kein verlaessliches Backup
- AdGuard-Konfiguration wird weiterhin NICHT gesichert (Berechtigungs-
  problem umgangen, nicht geloest) - bei Bedarf spaeter Root-Cause
  klaeren (moeglicherweise via docker exec statt rsync-Dateizugriff)
- Immich-Datenbank wird aktuell OHNE pg_dump-Vorstufe roh mitkopiert
  (wie Paperless/Nextcloud vor deren Fix) - potenzielles
  Konsistenzrisiko bei laufendem Snapshot, noch nicht behoben
- Backup-Skript sichert aktuell nur Paperless/Nextcloud/Kavita/Immich
  explizit einzeln aufgelistet - Umstellung auf dynamische Schleife
  ueber alle /mnt/nas6tb/*-Unterordner besprochen, aber nicht
  umgesetzt (würde neue Dienste automatisch mit abdecken, ausser
  deren Datenbank-Dumps)
- Kopia-Weboberflaeche und CLI-gestartete Snapshots laufen als
  getrennte Prozesse - Snapshots aus dem Cronjob erscheinen NICHT im
  "Tasks"-Bereich der Web-UI, nur eigene Server-initiierte Aktionen
  (Wartung etc.) - kein Fehler, nur eine Einschraenkung bei der
  Fortschrittsbeobachtung

### Naechste Schritte (Ziel der kommenden Session)
1. Restore-Test durchfuehren (mind. eine Datei/einen Ordner aus
   einem Snapshot zurueckspielen, um den Ablauf zu verifizieren)
2. Ersten automatischen 3-Uhr-Lauf pruefen (Log durchsehen, Laufzeit
   im Vergleich zum 19h-Erstlauf einordnen)
3. Immich-Postgres-Dump ergaenzen (Konsistenz-Fix analog zu
   Paperless/Nextcloud)
4. AdGuard-Backup-Luecke schliessen
5. Ggf. dynamische Ordner-Schleife fuer /mnt/nas6tb/* einbauen, um
   kuenftige neue Dienste automatisch abzudecken

### Zugriff / Referenzen (Ergänzung)
- Kopia-Weboberflaeche: https://192.168.178.37:51515 (Login: samuel)
- Kopia-Repository-Passwort: separat im Passwort-Manager hinterlegt
- Backup-Skript: /root/backup-nightly.sh
- Backup-Log: /var/log/kopia-backup.log
- Backup-Platte: /dev/disk/by-id/ata-WDC_WD40NDZW-11A8JS1_WD-WXU2E7032L5S
- HA SSH-Add-on: Port 22222, MAC-Algorithmus muss explizit auf
  hmac-sha2-256-etm@openssh.com gesetzt werden (Windows-Client-Bug)

## Aktueller Stand (19.07.2026 - Cron-PATH-Bugfix im Backup-Skript)

### Wichtiger Bugfix: Erster automatischer 3-Uhr-Lauf schlug fehl
Der erste echte Cronjob-Lauf (19.07., 03:00 Uhr) brach sofort mit
"cryptsetup: Kommando nicht gefunden" ab. Ursache: Cron nutzt einen
stark eingeschraenkten PATH (typischerweise nur /usr/bin:/bin), der
/usr/sbin (wo cryptsetup liegt) nicht enthaelt - im Gegensatz zur
interaktiven Shell, in der wir das Skript zuvor erfolgreich getestet
hatten. Das erklaert, warum manuelle Tests immer funktionierten, der
automatisierte Cronjob aber nicht.
Fix: export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
direkt als zweite Zeile im Skript (nach der Shebang) ergaenzt.
Lehre: Bei jedem Cron-gesteuerten Skript, das Systembefehle aus /sbin
oder /usr/sbin nutzt (cryptsetup, mount als root, etc.), den PATH
explizit im Skript setzen - sich nicht auf die interaktive Shell-
Umgebung verlassen, in der getestet wurde.

## Aktueller Stand (19.07.2026 - Kopia-Server TLS-Cert-Bugfix, Mount-Workflow)

### Bugfix: kopia-server.service startete nach Neustart nicht mehr
Nach dem manuellen Aus-/Einhaengen der Backup-Platte (um die Web-UI
kurzzeitig zu nutzen) verweigerte der Dienst den Neustart mit
"TLS cert file already exists". Ursache: die systemd-Unit enthielt
--tls-generate-cert, das bei JEDEM Start versucht ein neues
Zertifikat zu erzeugen - schlaegt fehl, sobald eines schon existiert
(was nach dem ersten erfolgreichen Start immer der Fall ist).
Fix: --tls-generate-cert aus /etc/systemd/system/kopia-server.service
entfernt (Zertifikat existiert ja bereits unter /etc/kopia/kopia.cert
und .key), danach daemon-reload + restart.

### Entscheidung: Backup-Platte bleibt NICHT dauerhaft gemountet
Nach Ueberlegung (Homepage-Button vs. dauerhaftes Mounten vs. manueller
Befehl) hat sich der Nutzer bewusst fuer den manuellen Befehl
entschieden - spart Strom (Festplatte muss nicht dauerhaft laufen),
kein zusaetzlicher Dienst noetig gepflegt zu werden. Konsequenz: die
Kopia-Web-UI zeigt "refresh error" / ist nicht nutzbar, wann immer die
Platte nicht gemountet ist (z.B. ausserhalb des naechtlichen 3-Uhr-
Backup-Fensters) - das ist erwartetes, akzeptiertes Verhalten, kein
Fehler. Bei Bedarf (Restore, Snapshot-Browsing) manuell mounten:
sudo cryptsetup luksOpen --key-file /etc/cryptsetup-keys.d/backup-4tb.key 
/dev/disk/by-id/ata-WDC_WD40NDZW-11A8JS1_WD-WXU2E7032L5S backup4tb_crypt
sudo mount /dev/mapper/backup4tb_crypt /mnt/backup4tb
sudo systemctl restart kopia-server
Danach wieder schliessen:
sudo umount /mnt/backup4tb
sudo cryptsetup luksClose backup4tb_crypt
(Siehe auch docs/60-Backups.md, Abschnitt 1 und 4.)

### Bestaetigt: PATH-Bugfix vom 19.07. erfolgreich
Manueller Testlauf nach dem PATH-Fix lief komplett in 7 Minuten 27
Sekunden durch (16:33:58 - 16:41:25 Uhr), im Vergleich zum
urspruenglichen 19h-Erstlauf - Kopias Deduplizierung funktioniert wie
erwartet. Home-Assistant-Uebertragung lief ebenfalls fehlerfrei (kein
scp/SFTP-Fehler mehr).

## CPU-Tausch: Skylake → Kaby Lake (i7-7700)

**Datum:** 20.07.2026
**Anlass:** Intel HD 530 (Skylake) konnte kein 10-bit-HEVC/HDR/Dolby-Vision
hardwarebeschleunigt decodieren, was zu Jellyfin-Abstürzen bei HDR-Filmen
führte. Kaby Lake (UHD 630, Gen9.5) unterstützt dies.

**Ablauf:**
1. BIOS auf Version F22g (Q-Flash) mit noch eingebauter i5-6600
   aktualisiert, um Kaby-Lake-Support zu aktivieren
2. CPU-Tausch: Intel Core i5-6600 → Intel Core i7-7700
3. Nach dem BIOS-Update (noch mit alter CPU) verschob sich die PCI-
   Enumeration: Netzwerk-Interface wechselte von enp5s0 zu enp6s0.
   Betroffen waren zwei Stellen:
   - /etc/network/interfaces (iface/bridge-ports-Einträge)
   - /etc/initramfs-tools/initramfs.conf (IP=... Zeile für Dropbear/
     LUKS-Remote-Unlock)
   Beide per sed korrigiert, anschließend `update-initramfs -u -k all`
   (erfordert gemountete /boot-Partition, sonst stiller Fehlschlag ohne
   Wirkung). Hinweis für künftige BIOS-Updates: gleiches Muster erwarten,
   ggf. auf udev-basierte .link-Regeln mit fester MAC-Adresse umstellen,
   um Interface-Namen unabhängig von PCI-Reihenfolge zu machen.
4. GPU-Passthrough-Konfiguration geprüft:
   - PCI-Adresse 00:02.0 unverändert
   - Geräte-ID geändert von 8086:1912 (Skylake HD 530) zu 8086:5912
     (Kaby Lake UHD 630)
   - /etc/modprobe.d/vfio.conf entsprechend angepasst (sed), danach
     erneut update-initramfs -u -k all
5. VM100 neu gestartet (qm start 100, da qm reboot am fehlenden
   QEMU Guest Agent scheiterte), GPU-Sichtbarkeit in VM100 bestätigt:
   Kaby Lake UHD 630 unter i915-Treiber sichtbar (lspci -nnk)
6. Jellyfin: HEVC- und HEVC-10bit-Hardwaredekodierung waren bereits
   aktiviert (Dashboard → Playback → Transcoding, QSV-Gerät
   /dev/dri/renderD128)
7. Verifiziert mit HDR-Testfilm: Wiedergabe läuft stabil ohne Absturz

**Ergebnis:** HDR/Dolby-Vision-Wiedergabe funktioniert jetzt über
Hardware-Transkodierung (Intel QuickSync, UHD 630). CPU zusätzlich von
4 auf 8 Threads aufgerüstet (Hyperthreading), behebt auch die zuvor in
10-Hardware.md vermerkte Thread-Limitierung bei paralleler Dienstlast.

**Lessons Learned:** BIOS-Updates auf diesem Board können die PCI-
Enumeration verschieben und damit vorhersagbare Netzwerk-Interface-
Namen (enpXsY) ändern. Betrifft sowohl das laufende System als auch
das initramfs/Dropbear-Setup für Remote-LUKS-Unlock. Beim nächsten
BIOS- oder Hardware-Update: zuerst mit Tastatur+Monitor lokal am
Server arbeiten (nicht ausschließlich auf SSH verlassen), da genau
dieser Fall SSH-Zugriff temporär unmöglich machen kann.
### Nachtrag: Docker-Berechtigungsprobleme nach hartem VM100-Neustart (Redis)
Nach dem harten Stop/Start von VM100 zeigten Nextcloud und Kavita
Fehler: Nextcloud "config-Verzeichnis nicht schreibbar", Kavita
"SQLite Error 8: attempt to write a readonly database". Ursache:
Ordner auf dem virtiofs-Share /mnt/nas6tb (nextcloud/html,
nextcloud/data, kavita/config, kavita/books) hatten UID:GID 100:101
statt der von den Containern erwarteten IDs (Nextcloud: 33:33, Kavita:
1000:1000 laut PUID/PGID-Env). Fix: sudo chown -R 33:33
/mnt/nas6tb/nextcloud/html /mnt/nas6tb/nextcloud/data && sudo chown -R
1000:1000 /mnt/nas6tb/kavita/config /mnt/nas6tb/kavita/books && docker
restart nextcloud kavita.
Zusatzfund: Auch nextcloud-redis (/mnt/nas6tb/nextcloud/redisdata)
hatte 100:101 statt der von Redis erwarteten 999:999. Redis konnte
dadurch keine RDB-Snapshots mehr schreiben ("Permission denied"),
ging in einen MISCONF-Zustand und blockierte alle schreibenden
Befehle - das riss Nextcloud erneut auf 503 runter, obwohl Apache
selbst normal lief und der config-Fix bereits angewendet war.
Erkennbar an "Failed opening the temp RDB file ... Permission denied"
in docker logs nextcloud-redis. Fix: sudo chown -R 999:999
/mnt/nas6tb/nextcloud/redisdata && docker restart nextcloud-redis
nextcloud. paperless-broker (ebenfalls Redis, gleicher Mount-Bereich)
war nicht betroffen und lief unauffaellig weiter.
Lehre: Nach jedem harten VM-Neustart die UID/GID auf allen
Docker-Volume-Mounts unter /mnt/nas6tb pruefen (ls -lan), bevor man
einzelne Container einzeln durchgeht - betraf hier gleich vier
verschiedene Verzeichnisse mit derselben falschen 100:101-Zuordnung.
## Aktueller Stand (29.07.2026 - Home Assistant öffentlich erreichbar)

### Vollständig abgeschlossen
- Home Assistant öffentlich erreichbar gemacht (analog zu Paperless/Nextcloud/
  Immich, gleiche Infrastruktur):
  - Proxy Host in Nginx Proxy Manager: ha.brueggemann.site ->
    192.168.178.38:8123 (VM101, kein Docker-Container), Websockets Support
    aktiviert (notwendig für Live-Updates in der HA-Oberfläche)
  - Published Application Route in Cloudflare Tunnel: ha.brueggemann.site ->
    192.168.178.36:80 (zeigt auf NPMs Proxy-Port, analog zu den anderen
    Diensten)
  - Home Assistant configuration.yaml ergänzt:
    http:
      use_x_forwarded_for: true
      trusted_proxies:
        - 192.168.178.36
  - Home Assistant URL (Einstellungen -> System -> Netzwerk) auf
    https://ha.brueggemann.site gesetzt, lokales Netzwerk bleibt auf
    "Automatisch" (weiterhin schneller interner Zugriff im Heimnetz)
  - Öffentlicher Zugriff erfolgreich getestet (Mobilfunknetz)
- Studio Code Server Add-on in Home Assistant installiert (für die
  Bearbeitung der configuration.yaml)
- Home-Assistant-API-Token erneuert: alter Long-Lived Access Token (der
  einmalig im Chat-Verlauf geteilt worden war) in Home Assistant widerrufen,
  neuer Token direkt in stacks/homepage/.env auf VM100 eingetragen (nicht
  mehr im Chat geteilt), Homepage-Container neu gestartet

### Wichtige Lehre: trusted_proxies bei Diensten auf einer anderen VM
Bei Nextcloud (Docker-Container im selben Docker-Netzwerk wie NPM) war die
korrekte trusted_proxies-IP die Docker-Netzwerk-Gateway-IP (172.26.0.1). Bei
Home Assistant, das nativ auf VM101 läuft (andere VM, kein gemeinsames
Docker-Netzwerk mit NPM), kommt die Anfrage stattdessen von der realen
LAN-IP des NPM-Hosts (192.168.178.36) an - Docker übersetzt die
Absender-IP beim Verlassen des Docker-Netzwerks auf die Host-IP. Führte
zunächst zu "400 Bad Request" von Home Assistant. Lehre: bei
Reverse-Proxy-Zielen auf einer anderen VM als NPM selbst die LAN-IP des
NPM-Hosts (nicht die Docker-Gateway-IP) in trusted_proxies eintragen.

### Nebenbefund: Supervisor hing kurzzeitig im Setup-Zustand
Während der Studio-Code-Server-Installation blieb der Add-on-Installer
scheinbar endlos hängen. Ursache: ein zwischenzeitlicher
"ha supervisor restart" brachte den Supervisor in den Zustand "setup",
in dem er ungewöhnlich lange verblieb (ha info / ha resolution info
schlugen in dieser Zeit mit "System is not ready" fehl). Home Assistant
Core selbst lief währenddessen unbeeinträchtigt weiter (Dashboard normal
erreichbar). Problem löste sich nach einigen Minuten von selbst, kein
manueller Eingriff nötig. Falls erneut: erst pruefen, ob Core (Port 8123)
noch reagiert, bevor an der VM selbst etwas geändert wird.

### Bekannte offene Probleme (bewusst zurückgestellt)
- 2FA für den Home-Assistant-Account noch nicht bestätigt eingerichtet -
  sollte angesichts der jetzt öffentlichen Erreichbarkeit zeitnah erfolgen
- Cloudflare WAF weiterhin nicht eingerichtet (bereits bei Nextcloud als
  Idee notiert) - bei Home Assistant (steuert ggf. physische Geräte)
  zunehmend sinnvoll
- Unverändert bestehende offene Punkte: QEMU Guest Agent auf VM100,
  Home-Assistant-Live-Status-Widget in Homepage weiterhin 401
  (Upstream-Bug gethomepage/homepage #5074)

### Nächste Schritte (Ziel der kommenden Session)
1. 2FA für Home-Assistant-Account einrichten/verifizieren
2. Cloudflare WAF vor Home Assistant (und ggf. Nextcloud) einrichten
3. QEMU Guest Agent in VM100 installieren

### Zugriff / Referenzen (Ergänzung)
- Home Assistant (öffentlich): https://ha.brueggemann.site
- Home Assistant (lokal): http://192.168.178.38:8123
- Alle öffentlichen Dienste im Überblick: Paperless (paperless.),
  Nextcloud (cloud.), Immich (photos.), Home Assistant (ha.) -
  jeweils .brueggemann.site

## VM100-Systemdisk erweitert (01.08.2026)

VM100-Systemdisk von 64GB auf 128GB erweitert (analog zum Vorgehen
vom 17.07.), da durch RomM, TREK, HortusFox und Gramps Web (inkl.
mehrerer MariaDB-Instanzen und Docker-Images) die Belegung auf 95%
gestiegen war (nur noch 3,4GB frei). Ablauf: `qm resize 100 scsi0
+64G` auf dem Host, danach `growpart /dev/sda 2` + `resize2fs
/dev/sda2` in der VM. Neuer Stand: 125GB gesamt, 64GB frei (47%).
Thin-Pool lokal-lvm hat weiterhin ~109GB Reserve für künftiges
Wachstum.

## Aktueller Stand (02.08.2026 - Cloudflare-Haertung, Speicherlimits, Secret-Rotation)

### Vollstaendig abgeschlossen
- Cloudflare-Haertung eingerichtet (Free-Plan):
  - Bot Fight Mode aktiviert
  - Free Managed Ruleset (automatisch aktiv im Free-Plan, deckt u.a. die
    Pfad-Traversal-Angriffsklasse ab, die am 17.07. bei Nextcloud
    beobachtet wurde)
  - 1 Rate-Limiting-Regel (Free-Plan-Limit): Hostname wildcard
    *.brueggemann.site, 150 Requests/10 Sekunden, Aktion Block
  - 1 Custom Rule: ha.brueggemann.site, Aktion Managed Challenge
  - Hinweis: Security Level ist seit Maerz 2025 von Cloudflare automatisiert
    (immer "Always protected"), kein manueller Regler mehr vorhanden
  - Custom-Rule-Versuch mit Managed Challenge auf office.brueggemann.site
    wieder entfernt: brach die Server-zu-Server-Kommunikation zwischen
    Nextcloud und OnlyOffice (Challenge kann von Backend-Requests nicht
    geloest werden) - Nextcloud fiel automatisch auf den eingebauten
    Editor zurueck
- OnlyOffice nachtraeglich als versionierter Compose-Stack angelegt
  (stacks/onlyoffice/compose.yml): lief bisher als loser docker-run-
  Container ausserhalb von Git (dadurch nie dokumentiert, Port 8082 war
  entsprechend lange als "zu klaeren" markiert). JWT-Secret rotiert,
  da der urspruengliche Wert einmalig im Chat sichtbar wurde
- Speicherlimits ergaenzt (analog zum Nextcloud-Vorfall vom 17.07.):
  - Paperless (webserver): 4G
  - Immich (immich-server, immich-machine-learning): je 4G
- Paperless: Secret Key, Admin-Passwort und Postgres-Passwort rotiert,
  nachdem alle drei durch ein unbedachtes `docker compose config`
  (loest ${VARIABLEN} im Klartext auf) im Chat sichtbar wurden
- GitHub-Repo Samuel-bot-web/Wintermute auf public gestellt (vorher
  Secret-Scan der Git-Historie durchgefuehrt: nur ${VARIABLEN}-Referenzen
  gefunden, keine Klartext-Secrets in der Historie)

### Vollstaendige Liste oeffentlich erreichbarer Dienste (Stand 02.08.2026)
Alle ueber Cloudflare Tunnel + Nginx Proxy Manager, jeweils
*.brueggemann.site:
- paperless. -> Paperless-ngx
- cloud. -> Nextcloud
- office. -> OnlyOffice (Nextcloud-Companion)
- photos. -> Immich
- ha. -> Home Assistant (laeuft nativ auf VM101, nicht als Docker-
  Container)
- jellyfin. -> Jellyfin
- kavita. -> Kavita
- audiobookshelf. -> Audiobookshelf
- trek. -> TREK
- hortusfox. -> HortusFox
- grampsweb. -> Gramps Web
- uptime-kuma. -> Uptime Kuma (Absicherung/Exposure-Art noch nicht
  geprueft, siehe offene Punkte)

Nicht (mehr) oeffentlich: interne Verwaltungsoberflaechen (NPM Port 81,
Portainer, Paperless-/Nextcloud-Admin-Bereiche laufen ueber die
regulaeren Logins der jeweiligen Dienste, keine separate Admin-Route).

### Bekannte offene Probleme (bewusst zurueckgestellt)
- Uptime Kuma: noch nicht geprueft, ob hinter der oeffentlichen Route
  eine dedizierte Status-Page oder das volle Admin-Dashboard mit Login
  liegt
- Home-Assistant-VM (VM101): laeuft nativ, kein Docker-Speicherlimit
  moeglich - RAM-Begrenzung muesste stattdessen auf Proxmox-VM-Ebene
  erfolgen, noch nicht umgesetzt
- 2FA fuer den Home-Assistant-Account weiterhin nicht bestaetigt
  eingerichtet (bereits am 29.07. als offen vermerkt)
- Rate-Limiting-Schwelle (150/10s) ist ein Kompromiss aus dem Free-Plan-
  Limit von nur einer Regel fuer die gesamte Domain - grosszuegig genug
  fuer Nextcloud/OnlyOffice-Lastspitzen, aber entsprechend grobmaschiger
  gegen Scanner als eine dienst-spezifische Regel es waere

### Naechste Schritte (Ziel der kommenden Session)
1. Uptime Kuma Exposition pruefen, ggf. absichern oder auf intern
   zurueckstellen
2. RAM-Limit fuer VM101 (Home Assistant) in Proxmox pruefen/setzen
3. 2FA fuer Home-Assistant-Account einrichten


## Aktueller Stand (02.08.2026, Nachtrag - 2FA Home Assistant)

### Vollstaendig abgeschlossen
- 2FA fuer den Home-Assistant-Account eingerichtet (TOTP via Aegis
  Authenticator, offline/lokal auf Android-Geraet, keine Cloud-
  Abhaengigkeit). Backup-Codes im Passwort-Manager gesichert.
- Uptime Kuma geprueft: oeffentliche Route zeigt eine Login-Maske,
  kein ungeschuetztes Admin-Dashboard - keine weitere Massnahme noetig.

Damit ist der am 02.08. begonnene Haertungs-Durchgang
(Cloudflare, Speicherlimits, Secret-Rotation, 2FA) abgeschlossen.
Einzig zurueckgestellter Punkt: RAM-Limit fuer VM101 (Home Assistant)
auf Proxmox-Ebene - bewusst nicht umgesetzt, da bisher nie
Probleme aufgetreten sind.

## Aktueller Stand (13.08.2026 - Media-Automation eingerichtet, öffentlich erreichbar)

### Vollständig abgeschlossen
- IVPN als zentraler VPN-Ausgang eingerichtet (stacks/media-automation/,
  Image qmcgaw/gluetun): WireGuard-Verbindung zu IVPN-Server de2.wg.ivpn.net,
  bestätigt per öffentlichem IP-Check (37.58.60.153, Frankfurt) - identisch
  bei gluetun und allen angehängten Containern (docker exec radarr wget
  -qO- ifconfig.me lieferte dieselbe IP)
- Radarr, Sonarr, Prowlarr, NZBGet, Jellyseerr eingerichtet, alle über
  network_mode: "service:gluetun" hinter dem VPN-Tunnel (kein eigenes
  Docker-Netzwerk, daher untereinander per "localhost" statt Container-
  Namen erreichbar - wichtige Abweichung von den übrigen Stacks)
- Usenet-Zugang und Indexer eingerichtet, NZBGet-Standardlogin (bekannt,
  unsicher: nzbget/tegbzn6789) sofort auf eigenes Login geändert
  (Settings -> Security)
- NZBGet-Kategorien "tv" und "movies" angelegt (Settings -> Categories),
  notwendig da Radarr/Sonarr sonst keine gültige Kategorie zuweisen
  konnten
- Root-Ordner gesetzt: /media/Plex/Movies (Radarr), /media/Plex/TV Shows
  (Sonarr) - Pfade entsprechen /mnt/media/Plex/... auf dem Host, im
  Container unter /media eingehängt. Berechtigungen mit chown 1000:1000
  korrigiert (Ordner waren nicht vom PUID/PGID des linuxserver-Images
  beschreibbar - vermutlich Windows/NTFS-Migrationsrelikt, analog zur
  Lehre vom 20.07.)
- Jellyseerr mit Jellyfin (LAN-IP, eigenes Docker-Netzwerk) sowie Radarr/
  Sonarr (localhost, gemeinsamer Gluetun-Netzwerk-Stack) verknüpft
- Erster Downloadtest erfolgreich: Suche -> NZBGet-Download -> Datei landet
  korrekt in /mnt/media/Plex/... -> von Jellyfin erkannt
- Jellyseerr öffentlich erreichbar gemacht (analog zu Paperless/Nextcloud/
  Immich/Home Assistant, gleiche Infrastruktur):
  - Proxy Host in Nginx Proxy Manager: requests.brueggemann.site ->
    192.168.178.36:5055, Websockets Support aktiviert
  - Published Application Route in Cloudflare Tunnel:
    requests.brueggemann.site -> 192.168.178.36:80
  - Öffentlicher Zugriff getestet
- Homepage aktualisiert: neue Kategorie "Medien-Automatisierung" mit allen
  fünf Diensten (Radarr, Sonarr, Prowlarr, NZBGet, Jellyseerr), inkl. Icons
  und funktionierenden Live-Widgets (Warteschlange/Status)

### Wichtige Lehre: env_file für Homepage-Widget-Secrets
API-Keys/Passwörter für Homepage-Widgets zunächst direkt im Klartext in
services.yaml eingetragen (funktionierte), dann auf Umgebungsvariablen-
Syntax {{HOMEPAGE_VAR_NAME}} mit separater .env umgestellt (Vorbild:
Watchtower-Token-Auslagerung vom 12.07.) - das schlug zunächst fehl, alle
Widgets zeigten "API Error Information". Ursache: eine .env im selben
Ordner wie compose.yml wird von Docker Compose nur zum Auflösen von
${VARIABLEN} INNERHALB der compose.yml selbst genutzt, nicht automatisch
als Umgebungsvariable in den Container hineingereicht. Fix: env_file: -
.env explizit beim homepage-Service in compose.yml ergänzt, danach
docker compose up -d (nicht nur restart, da sich die Container-
Konfiguration geändert hatte). Verifiziert mit docker exec homepage env
| grep HOMEPAGE_VAR.
Lehre: Bei jedem Dienst, der Secrets per {{VARIABLE}}-Syntax aus einer
.env lesen soll, prüfen ob env_file oder environment: im jeweiligen
compose.yml-Service gesetzt ist - eine .env im selben Verzeichnis wird
NICHT automatisch in den Container durchgereicht.

### Bekannte offene Probleme (bewusst zurückgestellt)
- Watchtower-Label bewusst NICHT gesetzt (analog Paperless/Nextcloud/
  Immich) - kein Backup-Konzept für media-automation-Configs vorhanden
- Kein Speicherlimit für die neuen Container gesetzt - bei Bedarf analog
  zum Nextcloud-Vorfall vom 17.07. nachholen
- media-automation-Stack ist noch NICHT im nächtlichen Backup-Skript
  explizit berücksichtigt (nur /mnt/nas6tb/{paperless,nextcloud,kavita,
  immich} einzeln gelistet) - Configs liegen aber unter ~/homeserver und
  werden daher über den bestehenden rsync des kompletten homeserver-
  Verzeichnisses ohnehin mitgesichert
- 4-TB-Platte (/mnt/media) war bereits vor diesem Ausbau zu 99% voll
  (~69 GB frei) - durch automatisierte Downloads jetzt akut im Blick zu
  behalten
- Swap-Nutzung bei 93% beobachtet (Stand 13.08., vor RAM-Erweiterung) -
  fünf zusätzliche Container erhöhen den Speicherdruck auf ohnehin schon
  knappen 16 GB RAM weiter, RAM-Modul-Einbau (siehe Eintrag 17.07.)
  entsprechend dringlicher
- Cloudflare-Rate-Limiting (bestehende Regel, 150 Req/10s für
  *.brueggemann.site) deckt jetzt auch requests.brueggemann.site ab,
  keine dienstspezifische Regel eingerichtet (Free-Plan-Limit von nur
  einer Regel für die gesamte Domain, wie bereits am 02.08. dokumentiert)

### Nächste Schritte (Ziel der kommenden Session)
1. Speicherplatz auf /mnt/media prüfen/aufräumen, bevor automatisierte
   Downloads das Problem verschärfen
2. RAM-Module einbauen (weiterhin ausstehend seit 17.07.), angesichts
   der jetzt höheren Swap-Nutzung dringlicher geworden
3. Ggf. Speicherlimits für die fünf neuen Container ergänzen
4. Media-Automation-Configs explizit ins Backup-Skript aufnehmen (auch
   wenn bereits indirekt über den homeserver-rsync gesichert)

### Zugriff / Referenzen (Ergänzung)
- Radarr (lokal): http://192.168.178.36:7878
- Sonarr (lokal): http://192.168.178.36:8989
- Prowlarr (lokal): http://192.168.178.36:9696
- NZBGet (lokal): http://192.168.178.36:6789 (Login: samuel, Passwort in
  stacks/media-automation/.env)
- Jellyseerr (lokal): http://192.168.178.36:5055
- Jellyseerr (öffentlich): https://requests.brueggemann.site
- Alle öffentlichen Dienste im Überblick (Ergänzung zur Liste vom
  02.08.): ... requests. -> Jellyseerr (neu)
## Aktueller Stand (17.08.2026 - virtiofsd File-Handle-Erschoepfung gefunden und behoben, RAM-Upgrade)

### Vollstaendig abgeschlossen: RAM-Aufruestung
- RAM-Module (2x 8GB DDR4-2400, siehe Eintrag vom 17.07.) eingebaut: Host verfuegt
  jetzt ueber 32GB (vorher 16GB)
- VM100-Speicherzuweisung bereits bei 20GB (siehe qm-Config, `-m 20480`)

### KRITISCHER FUND: virtiofsd File-Handle-Erschoepfung (Ursache fuer wiederholte
"Too many open files in system"-Ausfaelle seit 15./16.08.)

**Symptom:** Nach praktisch jedem VM100-Neustart lief der Host-weite Handle-Vorrat
von virtiofsd (Standardlimit ca. 1.000.000) innerhalb weniger Minuten voll, sobald
alle ~30 Docker-Container gleichzeitig hochfuhren (restart: unless-stopped startet
alle gleichzeitig, nicht gestuft). Betroffen waren praktisch alle Dienste auf
/mnt/nas6tb gleichzeitig: Nextcloud ("Too many open files"-Fehler, .htaccess nicht
lesbar), Paperless, Immich (Postgres-Crash-Loop), RomM/MariaDB (tc.log-Korruption
durch abgebrochene Schreibvorgaenge waehrend der Handle-Erschoepfung), Kavita,
Kopia u.a.

**Fehldiagnosen unterwegs (zur Doku, falls das Muster nochmal auftritt):**
- Docker-Version (29.6.2 vs. 29.7.2) hat KEINEN Einfluss - kontrolliert getestet
  per Downgrade, Fehler trat identisch bei beiden Versionen auf
- Kavitas Cover-Ordner (40.612 Einzeldateien) war ein REALER Mitverursacher,
  aber NICHT die alleinige Ursache - nach Verschiebung von Kavitas config-Volume
  auf lokalen VM100-Speicher (/opt/kavita-config statt /mnt/nas6tb/kavita/config)
  trat das Problem weiterhin auf, ausgeloest durch die Summe aller anderen Dienste
- cache=never fuer den virtiofs-Mount vermeidet zwar den Handle-Aufstau, bricht
  aber SQLite-WAL-Datenbanken (TREK, vermutlich auch Kavita/GrampsWeb/
  Audiobookshelf) mit SQLITE_IOERR_SHMMAP - NICHT verwenden
- fatrace zur Taeterermittlung: in der VM nutzlos (fanotify funktioniert nicht
  zuverlaessig auf virtiofs/FUSE-Mounts), auf dem Host zeigt es immer nur
  virtiofsd selbst als Prozess (da virtiofsd als FUSE-Vermittler alle Zugriffe
  stellvertretend ausfuehrt) - kein Weg, den tatsaechlichen Verursacher-Prozess
  in der VM zu identifizieren

**Bestaetigte Ursache:** virtiofsd referenziert Dateien standardmaessig
(--inode-file-handles=never) ueber O_PATH-Filedescriptoren, die dauerhaft offen
bleiben muessen. Proxmox aktiviert die Alternative (--inode-file-handles=prefer,
nutzt stattdessen File-Handles) nur automatisch fuer Windows-Gaeste
(PVE/QemuServer/Virtiofs.pm, siehe github.com/virtio-win/kvm-guest-drivers-windows/
issues/1136). Bei Linux-Gaesten mit vielen Docker-Containern, die zusammen viele
kleine Dateien anfassen (Kavita-Cover, Immich-Fotos, diverse Postgres/Redis-
Datenbanken), lief der Handle-Vorrat deshalb bei praktisch jedem Neustart voll.
Gefunden ueber: forum.proxmox.com/threads/185388 (Feature-Request-Thread) und
bugzilla.proxmox.com/show_bug.cgi?id=7499

**Baseline-Test zur Bestaetigung (17.08., vor dem Fix):**
- Docker komplett deaktiviert (systemctl disable --now docker.socket
  docker.service containerd) + VM-Neustart: Handle-Vorrat blieb stabil bei 27
- Docker wieder aktiviert (alle 30 Container starten gleichzeitig durch
  restart-Policy): Handle-Vorrat sprang sofort auf 59.000+ und stieg weiter
- Damit zweifelsfrei bestaetigt: Docker/Container-Aktivitaet ist der Ausloeser,
  kein reines virtiofs-Boot-Phaenomen

**Fix (angewendet und verifiziert):**
Auf dem Proxmox-Host in /usr/share/perl5/PVE/QemuServer/Virtiofs.pm die Zeile
```
my $prefer_inode_fh = PVE::QemuServer::Helpers::windows_version($conf->{ostype}) ? 1 : 0;
```
geaendert zu
```
my $prefer_inode_fh = 1; # forced on for Linux guests, siehe forum.proxmox.com/threads/185388
```
Backup der Originaldatei unter Virtiofs.pm.bak. Danach `systemctl restart pvedaemon`
und VM-Neustart noetig, damit virtiofsd mit der neuen Option (sichtbar in
`ps aux | grep virtiofsd`: `--inode-file-handles=prefer`) startet.

**Verifikationstest nach dem Fix:** Alle 30 Docker-Container gleichzeitig
gestartet (identisches Szenario wie beim Baseline-Test), Handle-Vorrat blieb ueber
mehrere Minuten im niedrigen zwei- bis dreistelligen Bereich (44 -> 389 nach
gut 3 Minuten), statt wie vorher auf mehrere hunderttausend zu steigen. Fix
bestaetigt wirksam.

**Bekannte Einschraenkung von --inode-file-handles=prefer:** Beeintraechtigt
POSIX-ACL-Durchsetzung (open_by_handle_at umgeht bestimmte Pfad-basierte
Zugriffspruefungen). Betrifft uns nicht, da auf dem Server keine POSIX-ACLs
(setfacl/getfacl) im Einsatz sind, sondern ausschliesslich klassische Unix-
Rechte (chown/PUID/PGID-basiert).

**WICHTIG fuer die Zukunft:** Der Patch liegt in einer Datei, die zum
qemu-server-Debian-Paket gehoert. Ein kuenftiges `apt upgrade` auf dem HOST
(nicht VM100) kann die Datei ueberschreiben und den Fix zuruecksetzen. Nach
jedem Proxmox-VE-Update pruefen:
```bash
grep prefer_inode_fh /usr/share/perl5/PVE/QemuServer/Virtiofs.pm
```
Sollte `my $prefer_inode_fh = 1;` zeigen. Falls nicht (durch Update
zurueckgesetzt), Fix erneut anwenden wie oben beschrieben.

### Weitere Fixes im Rahmen der Handle-Krise (17.08.)
- Nextcloud: UID/GID-Fix (33:33 html/data, 999:999 redisdata) mehrfach angewendet,
  jetzt automatisiert (siehe naechster Abschnitt)
- RomM/MariaDB: tc.log-Korruption durch abgebrochene Schreibvorgaenge behoben
  (Datei geloescht, MariaDB baut sie beim naechsten sauberen Start neu auf)
- Kavita: durch Watchtower automatisch auf v0.9.0.2 aktualisiert worden, dabei
  fehlgeschlagene DB-Migration (fehlende "Tagline"-Spalte in Series,
  SeriesMetadata, AppUserRating) - manuell per ALTER TABLE nachgetragen, Downgrade
  auf v0.8.6, Watchtower-Label entfernt (com.centurylinklabs.watchtower.enable=false)
- Kavita-Config dauerhaft von /mnt/nas6tb/kavita/config nach /opt/kavita-config
  (lokale VM100-Systemdisk) verschoben - WICHTIG: dieser Pfad liegt jetzt AUSSERHALB
  des taeglichen Backup-Skripts (das nur /mnt/nas6tb/* sichert) - Backup-Skript-
  Anpassung noch offen (siehe naechste Schritte)
- Alter, verwaister Ordner /mnt/nas6tb/kavita/config.old-unused geloescht (nach
  Bestaetigung, dass /opt/kavita-config alles enthaelt, diff -rq war leer)

### Neu: Automatischer Nextcloud-Rechte-Fix nach VM-Neustart
Da das UID/GID-Problem bei Nextcloud (100:101 statt 33:33/999:999) wiederholt
nach harten VM100-Neustarts auftrat, jetzt automatisiert:
- Skript: /root/fix-nextcloud-perms.sh (chown html/data auf 33:33, redisdata auf
  999:999, danach docker restart nextcloud nextcloud-redis, 30s Anlaufzeit)
- Cronjob (root): `@reboot /root/fix-nextcloud-perms.sh >> /var/log/nextcloud-perm-fix.log 2>&1`
- Laeuft bei jedem Boot, unabhaengig davon ob das Problem diesmal auftritt

### Bekannte offene Probleme (bewusst zurueckgestellt)
- Backup-Skript noch nicht um /opt/kavita-config ergaenzt (liegt jetzt ausserhalb
  von /mnt/nas6tb, wird vom bestehenden Kopia-Snapshot-Schema nicht erfasst)
- Analog fuer RomM ist noch kein automatischer tc.log-Check/Fix nach Neustart
  eingerichtet (bisher nur manuell behoben, koennte nach dem virtiofsd-Fix aber
  ohnehin seltener/nie mehr auftreten, da die urspruengliche Ursache - Handle-
  Erschoepfung waehrend MariaDB-Schreibvorgang - behoben ist)
- Separate virtiofs-Mounts pro Dienst (Nextcloud/Immich/Paperless einzeln) waren
  als zusaetzliche Fehlerdomaenen-Isolierung diskutiert, sind nach dem
  virtiofsd-Fix aber nicht mehr zwingend noetig - Ruecksprache bei Bedarf
- QEMU Guest Agent weiterhin nicht in VM100 installiert (unveraendert seit 17.07.)
- Home-Assistant-Live-Status-Widget in Homepage weiterhin 401 (unveraendert)

### Naechste Schritte (Ziel der kommenden Session)
1. Backup-Skript um /opt/kavita-config ergaenzen
2. Restore-Test fuer Kavita-Config am neuen Pfad verifizieren
3. Bei Gelegenheit: RomM-tc.log-Check ins Boot-Skript mit aufnehmen (niedrige
   Prioritaet, da Ursache behoben)
4. VM-Speicherzuweisungen nach RAM-Upgrade (16GB -> 32GB Host) ueberpruefen/
   anpassen - VM100 laeuft bereits mit 20GB, VM101 pruefen

### Zugriff / Referenzen (Ergaenzung)
- Kavita-Config (neu): /opt/kavita-config (lokale VM100-Disk, NICHT mehr auf
  nas6tb/virtiofs)
- virtiofsd-Patch: /usr/share/perl5/PVE/QemuServer/Virtiofs.pm auf dem
  Proxmox-Host (Backup: Virtiofs.pm.bak im selben Verzeichnis)
- Nextcloud-Auto-Fix: /root/fix-nextcloud-perms.sh, Log unter
  /var/log/nextcloud-perm-fix.log

## Aktueller Stand (18.08.2026 - Nachwehen der Handle-Krise behoben, Aufräumarbeiten, Seerr-Migration)

### Vollstaendig abgeschlossen: Restarbeiten nach dem virtiofsd-Fix vom 17.08.
- Kavita und RomM starteten nach VM-Neustart nicht automatisch mit: Ursache war
  eine veraltete Restart-Policy im Docker-internen Zustand (Kavita hatte noch
  `restart: no` aus der Debugging-Phase, RomM/romm-db hatten korrekte Policy in
  der Compose-Datei, aber der laufende Container kannte noch den alten Stand).
  Fix: `docker compose up -d --force-recreate` fuer beide Stacks, danach zeigt
  `docker inspect <name> --format '{{.HostConfig.RestartPolicy}}'` korrekt
  `{unless-stopped 0}`
- RomM-DB: erneut tc.log-Korruption ("Bad magic header in tc log") durch den
  --force-recreate-Vorgang ausgeloest - gleicher Fix wie am 17.08. (tc.log
  loeschen, MariaDB baut sie beim naechsten sauberen Start neu auf). Da das
  jetzt zweimal auftrat, langfristig ggf. automatisierten Check erwaegen
  (niedrige Prioritaet, da urspruengliche Handle-Erschoepfungs-Ursache behoben)
- Kavita auf v0.9.0.2 aktualisiert (kontrolliert, mit vorherigem DB-Backup
  unter /opt/kavita-config/kavita.db.pre-latest-update-backup): Migration lief
  diesmal sauber durch, da die am 16./17.08. manuell nachgetragenen
  Tagline-Spalten (Series, SeriesMetadata, AppUserRating) bereits vorhanden
  waren. Watchtower-Label wieder auf enable=true gesetzt.

### HortusFox und Gramps Web vollstaendig entfernt (nie genutzt)
- Container gestoppt und entfernt (hortusfox, hortusfox-db, grampsweb,
  grampsweb-celery, grampsweb-redis)
- Daten geloescht: /mnt/nas6tb/hortusfox, /mnt/nas6tb/grampsweb
- Stack-Configs geloescht: stacks/hortusfox, stacks/grampsweb
- Homepage-Dashboard-Eintraege entfernt
- Backup-Skript bereinigt (drei Zeilen in /root/backup-nightly.sh entfernt:
  hortusfox-db-Dump und beide Kopia-Snapshot-Befehle)
- NPM Proxy Hosts und Cloudflare Published Routes geprueft/bereinigt
- WICHTIGE LEHRE fuer kuenftige Dienst-Entfernungen: IMMER das Backup-Skript
  mitpruefen (`grep -i <dienstname> /root/backup-nightly.sh`) - Dienste koennen
  dort explizit gelistet sein, auch wenn man das nicht mehr erwartet

### Jellyseerr zu Seerr migriert (Projekt-Rebrand)
Jellyseerr und Overseerr wurden vom Upstream-Projekt zu einem gemeinsamen
Nachfolgeprojekt "Seerr" zusammengefuehrt (seerr-team/seerr). Das alte
fallenbagel/jellyseerr-Image (zuletzt v2.7.3) erhaelt keine Updates mehr.
- Neues Image: ghcr.io/seerr-team/seerr:latest (v3.4.1 zum Zeitpunkt der
  Migration) - WICHTIG: nicht "seerrteam/seerr" (falscher erster Versuch,
  Image existiert nicht)
- Migration ist automatisch: Seerr erkennt die bestehende Jellyseerr-Datenbank
  beim ersten Start und migriert sie selbststaendig (u.a. neue Migrationen
  0007_migrate_arr_tags.js, 0008_migrate_blacklist_to_blocklist.js liefen
  sauber durch), keine manuellen Schritte an den Daten noetig
- Compose-Aenderungen laut offizieller Migrationsanleitung: Container-Name
  jellyseerr -> seerr, `init: true` neu erforderlich (Seerr liefert keinen
  eigenen Init-Prozess mehr mit), kein `user:`-Directive mehr noetig (laeuft
  fest als node-User UID 1000)
- Config-Volume-Pfad bewusst beibehalten (weiterhin
  /mnt/nas6tb/media-automation/jellyseerr/config), nur der Ordnername blieb
  historisch "jellyseerr" - funktioniert einwandfrei, da nur der Pfad zaehlt
- Vor der Migration: Ordner-Eigentuemer musste von 100:101 auf 1000:1000
  umgestellt werden (chown -R 1000:1000), sonst kann der node-User im
  Container nicht schreiben

### WICHTIGE LEHRE: Gluetun-Neustart reisst alle abhaengigen Container offline
Beim Hochfahren von Seerr wurde der gluetun-Container als Dependency neu
erstellt (nicht nur neu gestartet). Alle anderen Container, die
`network_mode: "service:gluetun"` nutzen (Radarr, Sonarr, Prowlarr, NZBGet),
haengen an dem SPEZIFISCHEN Netzwerk-Namespace der jeweiligen Gluetun-Instanz.
Nach einem Gluetun-Neuerstellen zeigen diese Container zwar "Up" in
`docker ps`, sind aber tatsaechlich komplett offline (alter, toter
Namespace) - und `docker restart` behebt das NICHT (Fehler: "joining network
namespace of container: No such container: <alte-ID>").
**Fix:** `docker compose up -d --force-recreate <alle betroffenen Services>`
noetig, nicht nur restart.
**Lehre fuer die Zukunft:** Bei jeder Aenderung an gluetun (Update,
force-recreate, o.ae.) IMMER alle Container mit force-recreate nachziehen,
die network_mode: "service:gluetun" nutzen: radarr, sonarr, prowlarr,
nzbget, seerr.

### VPN-Schutz nach allen Aenderungen re-verifiziert
`docker exec nzbget wget -qO- ifconfig.me`, `docker exec gluetun ...` und
`docker exec radarr ...` liefern uebereinstimmend die IVPN-IP (37.58.60.153,
Frankfurt) - Tunnel funktioniert weiterhin korrekt nach dem Gluetun-Neustart-
Zwischenfall.

### TREK: Login schlug fehl nach Handle-Krise ("secretOrPrivateKey must have a value")
Weiterer Kollateralschaden der Handle-Erschoepfung vom 17.08.: TREKs
JWT-Secret-Datei (data/.jwt_secret) war durch einen abgebrochenen
Schreibvorgang auf 0 Bytes zurueckgeblieben (Zeitstempel exakt in der
Handle-Krise-Zeitspanne), zusaetzlich mit falscher UID/GID (100:101 statt
1000:1000). TREK generiert diesen Secret normalerweise einmalig automatisch
beim ersten Start.
**Fix:** Container gestoppt, leere .jwt_secret-Datei geloescht
(`rm /mnt/nas6tb/trek/data/.jwt_secret`), Container neu gestartet - TREK hat
automatisch einen neuen, gueltigen Secret generiert und mit korrekter
UID/GID (1000:1000) persistiert. Alle bestehenden Sessions wurden dadurch
invalidiert (einmaliges Neu-Einloggen noetig), Trip-Daten selbst (travel.db)
blieben unberuehrt, da Secret und Daten getrennt gespeichert sind.

### Aufraeum-Scan nach 0-Byte-Dateien (praeventiv)
Nach dem TREK-Fund wurde gezielt nach weiteren moeglichen Kollateralschaeden
der Handle-Krise gesucht:
```bash
find /mnt/nas6tb -maxdepth 4 -type f -empty -newer /mnt/nas6tb/trek 2>/dev/null
```
Ergebnis: ueberwiegend harmlose, selbst-aufraeumende Artefakte (Redis
temp-*.rdb-Dateien, Paperless __paperless_write_test_*-Dateien vom
Beschreibbarkeits-Check beim Start, normale DB-Logdateien). Einzig
nextcloud/pgdata/core.26 (vermutlich abgebrochener Postgres-Crash-Dump, 0
Byte) war auffaellig, aber nextcloud-db-Logs zeigten keine Crash-/Signal-
Meldungen - unbedenklich, geloescht. Alle gefundenen Dateien nach Pruefung
entfernt, keine tatsaechlich noch aktiven Probleme gefunden.

### Bekannte offene Probleme (bewusst zurueckgestellt)
- Backup-Skript weiterhin nicht um /opt/kavita-config ergaenzt (unveraendert
  seit 17.08.)
- RomM tc.log-Problem ist jetzt zweimal aufgetreten (17.08. und 18.08.) -
  automatisierter Check/Fix im Boot-Skript waere sinnvoll, niedrige
  Prioritaet

### Naechste Schritte (Ziel der kommenden Session)
1. Backup-Skript um /opt/kavita-config ergaenzen (weiterhin offen)
2. RomM-tc.log-Check ins Boot-Skript aufnehmen, analog zum
   Nextcloud-Auto-Fix (/root/fix-nextcloud-perms.sh als Vorlage)
3. Media-Automation-Stack: seerr statt jellyseerr in Doku-Referenzen
   (20-Netzwerk.md, falls dort mit altem Namen vermerkt) aktualisieren

### Zugriff / Referenzen (Ergaenzung)
- Seerr (vormals Jellyseerr): lokal Port 5055 unveraendert, oeffentlich
  weiterhin https://requests.brueggemann.site
- Seerr-Image: ghcr.io/seerr-team/seerr:latest
