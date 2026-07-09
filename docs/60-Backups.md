
## Migrations-Backup (09.07.2026)

Vor der Proxmox-Migration gesichert nach /mnt/media/migration-backup/:
- jellyfin-config.tar.gz (Metadaten, Bibliothekseinstellungen)
- portainer-data.tar.gz (Verwaltungs-DB)

NICHT gesichert (bewusste Entscheidung):
- AdGuard-Konfiguration (unkritisch, Neukonfiguration akzeptabel)
- Home Assistant (kein produktiver Container vorhanden, wird als VM101/HAOS neu aufgesetzt)

## Offsite-Backup (geplant, später)

Backup-Ziel: Homeserver eines Freundes. Umsetzung nach Abschluss der
Proxmox-Migration und sda-Verschlüsselung.
