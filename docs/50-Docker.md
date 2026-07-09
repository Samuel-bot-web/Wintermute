
## Geplant: Samba-Freigabe (NAS-Funktion)

- Neuer Stack: stacks/samba/, auf VM100
- Protokoll: SMB/CIFS (kompatibel mit Windows, macOS, Linux, Android)
- Zugriff auf: /mnt/media (4-TB-Platte), später auch 6-TB-Platte
- Absicherung: Benutzername/Passwort erforderlich, kein anonymer Zugriff
- Umsetzung: NACH erfolgreicher Proxmox-Migration und stabilem VM100,
  nicht Teil der Kern-Migration
- Läuft unabhängig von Jellyfin (Jellyfin = Streaming, Samba = Datei-Zugriff),
  kein Konflikt bei gleichzeitiger Nutzung
