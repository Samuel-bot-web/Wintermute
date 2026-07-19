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
