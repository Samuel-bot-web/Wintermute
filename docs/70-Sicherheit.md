
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
