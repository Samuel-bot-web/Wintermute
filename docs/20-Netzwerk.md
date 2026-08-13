# Netzwerk

## Finales Netzwerkschema

| Host/VM | IP | Rolle |
|---|---|---|
| Proxmox-Host | 192.168.178.37 | Hypervisor |
| VM100 | 192.168.178.36 | Ubuntu + Docker |
| VM101 | 192.168.178.38 | Home Assistant OS |

Fritz!Box-DHCP-Reservierungen sind pro MAC-Adresse eingerichtet.

## Bridge-Einrichtung (12.07.2026)

Problem: Die manuelle Debian-Installation (siehe 40-Virtualisierung.md)
legt standardmäßig keine Netzwerk-Bridge an, sondern konfiguriert die
physische NIC direkt mit statischer IP. Der grafische Proxmox-Installer
würde das automatisch erledigen - bei unserem Weg (Debian + nachträgliches
Proxmox-VE) fehlte dieser Schritt.

Ohne Bridge können VMs nicht am LAN teilnehmen, da ihnen kein Layer-2-
Anschlusspunkt zur Verfügung steht.

Lösung: enp5s0 zu Bridge-Port von vmbr0 umgebaut, IP-Konfiguration auf
vmbr0 verschoben.
### Vorgehen

- Backup der Ausgangskonfiguration: `interfaces.bak-20260712`
- Anwendung per `ifreload -a` (ifupdown2), NICHT per
  `systemctl restart networking` - Risiko eines harten
  SSH-Verbindungsabbruchs bei Bridge-Umstellungen
- Verifiziert: vmbr0 trägt die IP, enp5s0 zeigt `master vmbr0`
  ohne eigene IP, Gateway-Ping erfolgreich, SSH-Session blieb
  während der gesamten Umstellung stabil

Wichtig: SSH/Dropbear-Zugriff für LUKS-Unlock (70-Sicherheit.md) hängt
jetzt an vmbr0 statt direkt an enp5s0. Bei künftigen Netzwerk-Debugging-
Sessions daran denken.

## VM101 Fritz-Box-Reservierung (12.07.2026)

VM101 (Home Assistant OS, MAC BC:24:11:41:67:BA) fest auf
192.168.178.38 reserviert.


## Port-Belegung VM100 (Stand 01.08.2026)

Bestandsaufnahme per `sudo ss -tulpn | grep LISTEN`. Vor der Vergabe
eines neuen Ports für einen Dienst hier nachsehen bzw. die Tabelle
danach ergänzen.

| Port  | Dienst                          | Bemerkung                          |
|-------|----------------------------------|-------------------------------------|
| 22    | SSH                              |                                      |
| 53    | AdGuard Home                     | DNS                                  |
| 80    | Nginx Proxy Manager               | Proxy-Traffic (HTTP)                |
| 81    | Nginx Proxy Manager               | Admin-UI                            |
| 139   | Samba                             | NetBIOS                             |
| 443   | Nginx Proxy Manager               | Proxy-Traffic (HTTPS)               |
| 445   | Samba                             | SMB                                  |
| 2283  | Immich                            |                                      |
| 3000  | AdGuard Home                      | Web-UI (von Port 80 hierher verlegt)|
| 3001  | Homepage-Dashboard                |                                      |
| 3002  | ? – zu klären                     |                                      |
| 8010  | Paperless-ngx                     |                                      |
| 8020  | Nextcloud                         |                                      |
| 8030  | Kavita                            |                                      |
| 8040  | RomM                              | neu, 01.08.2026                     |
| 8080  | ? – zu klären                     |                                      |
| 8082  | ? – zu klären                     |                                      |
| 8096  | Jellyfin                          |                                      |
| 9000  | Portainer                         | vermutlich Edge-Agent-Port          |
| 9443  | Portainer                         | Web-UI (HTTPS)                      |
| 13378 | ? – zu klären                     | Default-Port von Audiobookshelf, falls sowas läuft |
| 61208 | Glances                           |                                      |
| 8050  | TREK                              | Reise-Planer                        |
| 8060  | HortusFox                         | Pflanzenverwaltung                  |
| 8070  | Gramps Web                        | Ahnenforschung                      |
| 5055  | Jellyseerr                        |                                      |
| 6789  | NZBGet                             |                                      |
| 7878  | Radarr                            |                                      |
| 8989  | Sonarr                            |                                      |
| 9696  | Prowlarr                          |                                      |
