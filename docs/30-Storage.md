
## Neue 6-TB-Platte (Einbau 10.07.2026)

- Modell/Serial: [nach Einbau morgen per lsblk ergänzen]
- Zweck: Speicher für zukünftige Dienste (Paperless, Nextcloud)
- Wird als verschlüsselter Storage-Pool in Proxmox eingebunden (LUKS),
  virtuelle Platte wird an VM100 durchgereicht.

## Geplante spätere Migration: /dev/sda (4 TB, NTFS)

1. Daten von sda auf 6-TB-Platte kopieren (temporär)
2. sda mit LUKS + Dateisystem neu einrichten
3. Daten von 6-TB zurück auf sda kopieren
4. Kein Backup für sda vorgesehen (bewusstes Risiko, Single Point of Failure)

## 4-TB-Medienplatte per virtiofs an VM100 angebunden (12.07.2026)

Architekturentscheidung: Statt echtem Disk-Passthrough (VM100 verwaltet
Verschlüsselung/Dateisystem selbst) wird die 4-TB-Platte zentral vom
Proxmox-Host verwaltet (LUKS-Verschlüsselung, ext4, siehe
70-Sicherheit.md) und als Verzeichnis per virtiofs an VM100
durchgereicht.

Begruendung: Zentrale Verschlüsselungsverwaltung auf Host-Ebene (ein
Satz Keys, ein Ort fuer Backups), zukünftige Erweiterbarkeit (weitere
VMs oder der Host selbst könnten bei Bedarf ebenfalls zugreifen),
gute Performance ohne Netzwerkstack (im Gegensatz zu NFS/SMB).

### Einrichtung

Directory Mapping auf Host-Ebene angelegt:
pvesh create /cluster/mapping/dir --id media4tb 
--map node=wintermute,path=/mnt/media

virtiofs-Gerät zu VM100 hinzugefügt:
qm set 100 -virtiofs0 dirid=media4tb,cache=always

In VM100 gemountet (Mount-Tag entspricht der dirid):
mount -t virtiofs media4tb /mnt/media

Dauerhaft in /etc/fstab (VM100) eingetragen, inkl. systemd daemon-reload:
media4tb /mnt/media virtiofs defaults 0 0

### Bekannte Einschränkungen (laut Proxmox-Doku)

- Live-Migration, Snapshots und Memory-Hotplug funktionieren nicht in
  Kombination mit virtiofs. Fuer den Single-Host-Betrieb ohne Cluster
  irrelevant.
- Falls virtiofsd auf dem Host abstürzt, hängt der Mount-Punkt in der
  VM bis zum kompletten VM-Neustart - ähnlich einem unerreichbaren NFS.

## Fritz!Box-Reservierung VM100 (12.07.2026)

VM100 (MAC BC:24:11:A0:41:5F) dauerhaft auf 192.168.178.36 reserviert.
