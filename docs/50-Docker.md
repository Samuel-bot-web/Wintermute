
## Geplant: Samba-Freigabe (NAS-Funktion)

- Neuer Stack: stacks/samba/, auf VM100
- Protokoll: SMB/CIFS (kompatibel mit Windows, macOS, Linux, Android)
- Zugriff auf: /mnt/media (4-TB-Platte), später auch 6-TB-Platte
- Absicherung: Benutzername/Passwort erforderlich, kein anonymer Zugriff
- Umsetzung: NACH erfolgreicher Proxmox-Migration und stabilem VM100,
  nicht Teil der Kern-Migration
- Läuft unabhängig von Jellyfin (Jellyfin = Streaming, Samba = Datei-Zugriff),
  kein Konflikt bei gleichzeitiger Nutzung

## Wiederherstellung der Docker-Stacks nach Migration (12.07.2026)

Nach Abschluss der Datenmigration (siehe 30-Storage.md, 70-Sicherheit.md)
wurden die Docker-Stacks auf VM100 wiederhergestellt.

### AdGuard: Backup war leer, Neueinrichtung nötig

Das Archiv migration-backup/adguard-conf.tar.gz enthielt nur eine leere
conf/-Ordnerstruktur ohne AdGuardHome.yaml - vermutlich wurde das Backup
vor der eigentlichen Konfiguration erstellt. AdGuard wurde daher neu
eingerichtet (Assistent, Standard-Ports 53/80/3000).

Lehre: Vor künftigen Migrationen prüfen, ob Backup-Archive tatsächlich
Inhalt haben (z.B. `tar -tzvf archiv.tar.gz | wc -l`), nicht nur ob die
Datei existiert.

### Port-53-Konflikt mit systemd-resolved

AdGuard konnte Port 53 nicht binden, da systemd-resolved auf Ubuntu
standardmäßig einen DNS-Stub-Listener auf 127.0.0.53 betreibt, der mit
Docker-Portmapping (0.0.0.0:53) kollidiert.

Lösung: In /etc/systemd/resolved.conf auf VM100:
DNSStubListener=no
Danach `systemctl restart systemd-resolved`. VM100s eigene DNS-Auflösung
lief über die in /etc/resolv.conf gelisteten Upstream-Server unverändert
weiter, kein Ausfall.

### Faustregel bei fehlgeschlagenem Container-Start

Nach einem fehlgeschlagenen `docker compose up -d` (z.B. Port-Konflikt)
reicht ein erneutes `up -d` oft nicht aus, da Docker den bereits
angelegten, fehlerhaften Container-Zustand wiederverwendet (z.B. ohne
Portmappings). Stattdessen:
docker compose down
docker compose up -d --force-recreate

### Jellyfin und Portainer

Beide liefen nach Wiederherstellung der Backups (jellyfin-config.tar.gz,
portainer-data.tar.gz) direkt sauber mit den ursprünglichen Daten hoch,
kein manueller Eingriff nötig.

### media-automation
- Zweck: Automatisierte Mediensuche/-beschaffung über Usenet (Radarr,
  Sonarr, Prowlarr, NZBGet), Anfrage-Portal für Freunde (Seerr)
- Konfiguration: stacks/media-automation/compose.yml, .env (WireGuard-
  Key, NZBGet-Login - nicht im Git-Repo)
- Netzwerk-Besonderheit: alle Container außer gluetun selbst nutzen
  network_mode: "service:gluetun" - kein eigenes Docker-Netzwerk,
  Erreichbarkeit untereinander per "localhost"
- Daten: Configs auf 6-TB-Platte (/mnt/nas6tb/media-automation/...),
  Mediendateien direkt auf 4-TB-Platte (/mnt/media/...)
- Auto-Update: über Dockhand, pro Container einzeln konfigurierbar
  (siehe 80-Wartung.md)

## Incident: Gluetun-Update reißt abhängige Container mit (22./23.08.2026)

Watchtower hat nachts (04:00 lokal / 02:00 UTC) automatisch ein neues
Gluetun-Image gezogen und den Container komplett neu erstellt (nicht nur
neugestartet). Da Radarr, Sonarr, Prowlarr, NZBGet und Seerr per
network_mode: "service:gluetun" Gluetuns Netzwerk-Namespace mitbenutzen,
verloren sie beim Neubau ihre Netzwerkverbindung (ENETUNREACH). Erste
Nacht: mehrere Container crashten direkt (Exit 128), zusätzlich verschärft
durch eine fast volle Root-Partition (95%). Zweite Nacht: nur Seerr gab
nach ~25 Min. dauerhafter Verbindungsfehler auf (Exit 143), die anderen
liefen scheinbar weiter, aber ohne funktionierende Netzwerkverbindung.

Ursache: Gluetuns Neuerstellung invalidiert den Netzwerk-Namespace, auf
den die abhängigen Container beim Start verwiesen haben. Ein einfacher
Neustart der abhängigen Container behebt es, passiert aber nicht
automatisch.

Lösung (siehe auch 80-Wartung.md):
- Healthcheck bei nzbget/radarr/sonarr/prowlarr/seerr prüft jetzt
  Gluetuns eigenen Health-Port (127.0.0.1:9999) statt nur sich selbst
- depends_on: gluetun: condition: service_healthy
- Zusätzlicher autoheal-Container (willfarrell/autoheal) startet
  Container mit Label autoheal=true automatisch neu, sobald Docker sie
  als unhealthy markiert (Docker selbst tut das nicht von sich aus)
- Getestet per `docker restart gluetun`: abhängige Container erkannten
  den Ausfall und erholten sich innerhalb ~1 Minute automatisch

Lehre: Bei network_mode: "service:X"-Konstruktionen (Gluetun & Co.)
gehört ein Healthcheck gegen die geteilte Netzwerkressource + Autoheal
zur Grundausstattung, nicht nur ein Healthcheck gegen sich selbst -
letzterer erkennt kaputte Netzwerk-Namespaces oft gar nicht.
