
## Proxmox VE Installation (11.-12.07.2026)

- Installiert via Debian 13.5 "Trixie" (encrypted LVM) + nachträgliche
  Proxmox-VE-Paketinstallation (offizieller, unterstützter Weg)
- Grund für diesen Weg statt direktem Proxmox-Installer: Keine native
  LUKS-Verschlüsselung im grafischen Proxmox-Installer verfügbar
- Proxmox VE Version: 9.2.4
- Kernel: 7.0.14-4-pve
- Root-Passwort gesetzt für Webinterface-Login (separat von SSH-Root-Login)

### Aufgetretene Probleme und Lösungen

- Ungültiger Archiv-Spiegel während Debian-Installation → ohne Spiegel
  fortgesetzt, Paketquellen nachträglich manuell in /etc/apt/sources.list
  eingetragen
- DNS-Auflösung funktionierte nach Netzwerk-Umstellung auf statische IP
  nicht (dns-nameservers in /etc/network/interfaces griff nicht ohne
  resolvconf) → resolvconf installiert, Netzwerk neu gestartet, seitdem
  stabil
- Proxmox-Host bekam initial automatisch 192.168.178.36 statt .37
  zugewiesen (alte Fritz!Box-DHCP-Reservierung an unveränderte MAC-Adresse
  gebunden) → auf statische IP umgestellt, Fritz!Box-Reservierung auf
  .37 angepasst

### Zugriff

- Proxmox-Webinterface: https://192.168.178.37:8006
- SSH: ssh samuel@192.168.178.37 (nach LUKS-Unlock, siehe 70-Sicherheit.md)

## Root-Partition verkleinert für VM-Speicher (12.07.2026)

Problem: Bei der Debian-Installation wurde "gesamte Platte in eine Partition"
gewählt - das belegte 100% der Volume Group, kein Platz für lokalen
VM-Speicher (local-lvm) übrig.

Lösung: Root-LV nachträglich per Rescue-Mode verkleinert.

- root: 225,43 GiB -> 40 GiB
- Freier Platz in wintermute-vg: 185,44 GiB (für VM-Festplatten)
- Vorgehen: Boot von Debian-Stick -> Advanced options -> Rescue mode ->
  LUKS-Passphrase eingeben -> Shell in installer environment (NICHT im
  Zielsystem, sonst bleibt /target gemountet)
- Alle Sub-Mounts unter /target (dev, proc, sys, boot, run) müssen einzeln
  ausgehängt werden, bevor e2fsck/resize2fs/lvreduce funktionieren:
  umount /target/dev /target/proc /target/sys /target/boot /target/run
  umount /target
- Reihenfolge: e2fsck -f -> resize2fs <LV> <Zielgröße> -> lvreduce -L <Größe>
  -> resize2fs <LV> (final, ohne Größenangabe)

Lehre für künftige Proxmox-Installationen: Bei der Debian-Partitionierung
NICHT "alle Dateien in eine Partition" wählen, sondern manuell eine kleinere
Root-Partition (z.B. 40 GB) anlegen und den Rest der Volume Group von
vornherein frei lassen.

## Thin-Pool und local-lvm Storage (12.07.2026)

- Thin-Pool "data" in wintermute-vg per lvcreate erstellt, nutzt den
  bei der Root-Verkleinerung freigegebenen Platz (~176 GiB nutzbar,
  Differenz zu 185 GiB durch Thin-Pool-Metadaten)
- Als Proxmox-Storage "local-lvm" registriert (content: images,rootdir)
- Verifiziert per `pvesm status`: Status active, 0% belegt bei Erstellung
- Damit ist die Storage-Grundlage für VM100 und VM101 vorhanden

## Thin-Pool und local-lvm Storage (12.07.2026)

- Thin-Pool "data" in wintermute-vg per lvcreate erstellt, nutzt den
  bei der Root-Verkleinerung freigegebenen Platz (~176 GiB nutzbar,
  Differenz zu 185 GiB durch Thin-Pool-Metadaten)
- Als Proxmox-Storage "local-lvm" registriert (content: images,rootdir)
- Verifiziert per `pvesm status`: Status active, 0% belegt bei Erstellung
- Damit ist die Storage-Grundlage für VM100 und VM101 vorhanden
