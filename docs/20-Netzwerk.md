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
