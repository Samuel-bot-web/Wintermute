
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

## Dropbear-Remote-Unlock: SSH-Zugang (11.11.2026)

### Ausgangslage
Nach einem Ausschalten des Servers war der Remote-Unlock nicht möglich:
Der Laptop (Samuel-Laptop, Ubuntu) hatte keinen SSH-Schlüssel mehr in
~/.ssh/, Dropbear akzeptiert aber nur Public-Key-Login. Unlock erfolgte
deshalb einmalig lokal mit Monitor und Tastatur. Welcher Schlüssel
vorher für Dropbear hinterlegt war, ist nicht dokumentiert.

### Eckdaten Dropbear
- Version: dropbear_2025.89 (im initramfs)
- Erreichbar: 192.168.178.37, Port 22, Benutzer root
- Authentifizierung: nur Public Key, kein Passwort
- Schlüsseldatei auf dem Host: /etc/dropbear/initramfs/authorized_keys
- Nach jeder Änderung daran: initramfs neu bauen (vorher prüfen, dass
  /boot gemountet ist, sonst stiller Fehlschlag):
  mount | grep /boot
  sudo update-initramfs -u -k all
- Meldung "No /etc/kernel/proxmox-boot-uuids found, skipping ESP sync"
  ist normal (Boot über GRUB, nicht über proxmox-boot-tool)

### Hinterlegter Schlüssel
- Typ: ed25519
- Fingerprint: SHA256:xH0TNldl//kYfYZXoeCcktdH+wu2PG6TYtLO424spXg
- Kommentar: samuel@Samuel-Laptop
- Ablage auf dem Laptop: ~/.ssh/wintermute (+ .pub)
- Wird für Dropbear (root) UND den normalen Host-Login (samuel) genutzt
- Private Key zusätzlich im Passwort-Manager gesichert

### Zwei Host-Keys unter derselben IP
Dropbear und OpenSSH (nach dem Unlock) haben unterschiedliche Host-Keys.
Ohne Gegenmaßnahme meldet SSH nach jedem Wechsel "REMOTE HOST
IDENTIFICATION HAS CHANGED". Lösung: getrennte Einträge mit
HostKeyAlias in ~/.ssh/config auf dem Laptop.

- Dropbear:  SHA256:wpwGVt/Cpd0QIyABKHWQbL3gBaH11+JIiUJ7DhADZbQ
- OpenSSH:   SHA256:Pdfdf5goTq6VwhcBPVm70h6jGOA8IKIK4YeYUdzRbfE

~/.ssh/config auf dem Laptop:

    Host wintermute-unlock
        HostName 192.168.178.37
        User root
        IdentityFile ~/.ssh/wintermute
        HostKeyAlias wintermute-dropbear

    Host wintermute
        HostName 192.168.178.37
        User samuel
        IdentityFile ~/.ssh/wintermute
        HostKeyAlias wintermute-proxmox

### Ablauf nach Ausschalten / Neustart
1. Server einschalten
2. ssh wintermute-unlock
3. cryptroot-unlock  (erst NACH erfolgreichem Login eingeben, nicht
   zusammen mit Schritt 2 einfügen)
4. System-Passphrase eingeben, Verbindung bricht danach ab (normal)
5. 4-TB- und 6-TB-Platte werden per Keyfile automatisch entsperrt,
   VM100/VM101 starten per onboot=1, Container per restart-Policy
6. Kontrolle: https://192.168.178.37:8006 und http://192.168.178.36:3001

Fallback: Monitor und Tastatur direkt am Server, Passphrase lokal
eingeben.
