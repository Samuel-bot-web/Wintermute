# Wartung

## Update-Strategie: Dockhand statt Portainer + Watchtower (22.08.2026)

Umstieg von Portainer + Watchtower auf Dockhand (fnsys/dockhand), da:
- Watchtower aktualisierte blind alle Container zur gleichen Uhrzeit
  (04:00 nachts), ohne Rücksicht auf Abhängigkeiten zwischen Containern
  (siehe Incident in 50-Docker.md)
- Portainer bot keine Update-Übersicht, dafür wurde ohnehin Watchtower
  zusätzlich gebraucht
- Dockhand vereint Container-/Stack-Verwaltung, Update-Tracking und
  Auto-Update in einem Tool, mit Kontrolle pro Container

### Setup
- Stack: stacks/dockhand/compose.yml, Port 9002 (3000 war durch AdGuard
  belegt)
- Datenverzeichnis: stacks/dockhand/data, muss Benutzer 1000:1000 gehören
  (nicht root)
- Docker-Socket-Zugriff: group_add mit der GID der docker-Gruppe des
  Hosts (`getent group docker`), Container läuft NICHT als root
- Environment „vm100-docker" als Unix-Socket-Verbindung eingerichtet

### Auto-Update-Policy pro Container
Grundsatz: unkritische Container automatisch, datensensible/kritische
Container nur mit Update-Benachrichtigung, manuell bestätigt.

- Automatisch (z.B. Radarr, Sonarr, Prowlarr, Jellyfin, Speedtest
  Tracker): Settings-Tab im jeweiligen Container-Editor, Cron-Zeitplan
  gesetzt
- Manuell (z.B. Immich, Nextcloud, Paperless, Home Assistant,
  Vaultwarden): Auto-Update aus, nur Update-Anzeige nutzen

Wichtig: Watchtower und Dockhand NICHT parallel mit Auto-Update auf
denselben Containern laufen lassen - beide haben sich in der Praxis
gegenseitig ins Gehege gekommen. Watchtower wurde am 23.08.2026 komplett
entfernt (`docker stop watchtower && docker rm watchtower`).

## Regelmäßiges Docker-Cleanup

Ursache eines Ausfalls am 22.08.2026: Root-Partition (/dev/sda2, 125 GB)
lief durch angesammelte alte Docker-Images auf 95% voll, wodurch mehrere
Container beim Schreiben von Logs/DB-Dateien abstürzten (Exit 128).

Manuelles Aufräumen bei Bedarf:
docker image prune -a
docker builder prune -a
docker system df    # zur Kontrolle, wie viel reclaimable ist

Noch offen: automatisches, regelmäßiges Cleanup einrichten (Cronjob oder
Dockhand-eigene Prune-Schedules), damit sich das nicht wiederholt.

## Netzwerk-Abhängigkeiten (network_mode: service:X)

Container, die über network_mode: "service:gluetun" (oder ähnliche
Konstruktionen) das Netzwerk eines anderen Containers mitbenutzen,
brauchen zwingend:
- Healthcheck gegen eine Ressource des Basis-Containers (nicht nur
  gegen sich selbst) - Beispiel media-automation-Stack: alle Container
  prüfen Gluetuns Health-Port 127.0.0.1:9999
- depends_on mit condition: service_healthy
- autoheal-Container (willfarrell/autoheal) mit Label autoheal=true,
  da Docker selbst unhealthy-Container nicht automatisch neustartet

Details und Incident-Historie: siehe 50-Docker.md.
