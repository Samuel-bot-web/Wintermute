
## Festplattenverschlüsselung

- Proxmox-Host (sdb) und neue 6-TB-Platte werden mit LUKS verschlüsselt.
- Entsperrung erfolgt remote per SSH (Dropbear im initramfs) – kein Monitor nötig,
  manueller Login nach jedem Reboot erforderlich.
- Bewusste Entscheidung gegen TPM-Autounlock: schützt nicht gegen Diebstahl
  des kompletten Geräts, nur gegen Ausbau der Platte allein.
- Installation erfolgt über Debian 13 Netinst (guided encrypted LVM) statt
  über den Proxmox-Installer, da dieser keine native LUKS-Option bietet.
  Proxmox VE wird anschließend als Paket auf das fertige Debian-System installiert.
- /dev/sda (4-TB-Medienplatte) bleibt vorerst UNVERSCHLÜSSELT (NTFS).
  Grund: Kann nicht ohne Neuformatierung verschlüsselt werden, verstößt sonst
  gegen "niemals formatieren"-Vorgabe. Migration zu LUKS ist für später geplant
  (siehe Storage.md).

## Verschlüsselung der 4-TB-Medienplatte per Keyfile-Kopplung (12.07.2026)

Ziel: 4-TB-Platte (Serial Z1Z4AZBH) verschlüsseln, ohne beim Boot eine
zweite Passphrase manuell eingeben zu müssen.

### Migration

Vor der Verschlüsselung wurden alle Daten (3,78 TB, NTFS) per rsync auf
die neue 6-TB-Platte als temporäres Staging-Ziel kopiert und per
Dry-Run-Vergleich (`rsync -avhn --delete`) auf Vollständigkeit verifiziert,
bevor die Originaldaten überschrieben wurden.

### Funktionsweise Keyfile-Kopplung

- Zufälliges Keyfile (2 KiB aus /dev/urandom) unter
  /etc/cryptsetup-keys.d/media-4tb.key erzeugt, chmod 600, root:root
- Das Keyfile liegt auf der bereits LUKS-verschlüsselten System-Partition
  (wintermute-vg-root) - dadurch bleibt die Sicherheitskette intakt: nur
  wer das System-Volume per Dropbear-Passphrase entsperrt, kann das
  Keyfile lesen und damit die 4-TB-Platte entschlüsseln
- 4-TB-Platte mit `cryptsetup luksFormat --type luks2 /dev/sda
  /etc/cryptsetup-keys.d/media-4tb.key` initialisiert (komplette Platte,
  keine Partitionstabelle - alte NTFS/Windows-Partitionierung verworfen)
- Mapped als media4tb_crypt, formatiert mit ext4, Label media4tb

### Boot-Reihenfolge

1. Dropbear/SSH-Passphrase eingeben -> System-LUKS (sdb5_crypt) entsperrt
2. Root-Dateisystem wird gemountet -> Keyfile wird lesbar
3. systemd verarbeitet /etc/crypttab weiter -> media4tb_crypt wird
   automatisch mit dem Keyfile entsperrt (kein x-initrd.attach nötig,
   da das Keyfile im Initramfs-Stadium noch nicht erreichbar ist)
4. fstab hängt /mnt/media automatisch ein

Verifiziert per Reboot-Test: /mnt/media war nach dem einmaligen
Dropbear-Unlock automatisch verfügbar, ohne zweite manuelle Eingabe.

### Relevante Konfigurationseinträge

/etc/crypttab:
media4tb_crypt UUID=c5ab45b5-2daa-4df2-86e3-656b23b3f2f7 /etc/cryptsetup-keys.d/media-4tb.key luks

/etc/fstab:
/dev/mapper/media4tb_crypt /mnt/media ext4 defaults 0 2

### Sicherheitshinweis

Das Keyfile selbst existiert nur einmal (kein Backup außerhalb des
Systems). Bei Verlust/Neuinstallation der System-Platte ist die 4-TB-
Platte ohne das Keyfile nicht mehr entschluesselbar. Empfehlung: Vor
groesseren System-Eingriffen ein Backup des Keyfiles an einem sicheren,
getrennten Ort aufbewahren (z.B. Passwort-Manager, verschluesselter
USB-Stick), NICHT im Git-Repo, da dieses oeffentlich auf GitHub liegt.
