
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
