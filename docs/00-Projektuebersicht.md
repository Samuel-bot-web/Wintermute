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
