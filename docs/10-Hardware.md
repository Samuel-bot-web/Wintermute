# Hardware – Wintermute

Stand: 18.07.2026

## System
- **Mainboard:** Gigabyte Z170-HD3P-CF
- **CPU:** Intel Core i5-6600 @ 3.30GHz (4 Kerne, 1 Thread/Kern, kein
  Hyperthreading)
- **GPU (integriert, kein Passthrough eingerichtet):** Intel HD
  Graphics 530
- **Netzwerk:** Realtek RTL8111/8168/8211/8411 PCIe Gigabit Ethernet
  (onboard), Interface enp5s0, Proxmox-Bridge vmbr0 auf
  192.168.178.37/24

## Arbeitsspeicher
- **Gesamt:** 16 GB (2x 8 GB)
- **Typ/Geschwindigkeit:** DDR4, 2400 MT/s
- **Hersteller:** Manufacturer-ID 1315 (nicht auflösbar über
  dmidecode, vermutlich Markenlücke im SPD-EEPROM - Modul-Hersteller
  bei Bedarf durch Sichtprüfung/Ausbau ermitteln)
- Swap: 12 GB (auf LVM, siehe Storage)

## Storage

| Device | Modell | Seriennummer | Größe | Zweck |
|---|---|---|---|---|
| sda | Seagate ST4000NM0053 | Z1Z4AZBH | 4 TB | Medien (LUKS2, media4tb_crypt), /mnt/media |
| sdb | Seagate ST6000VX009-2ZR186 | WPR0CY3K | 6 TB | Cloud-Dienste (LUKS2, media6tb_crypt), /mnt/nas6tb |
| sdc | SanDisk SD8SBAT256G1122 (SSD) | 161709402436 | 256 GB | Proxmox-System (Boot, LVM, VM-Disks) |
| sdd | Seagate ST1000LM024 HN-M101MBB | S318J9EG306168 | ~931 GB (932GB) | Externe USB-Platte, nur temporär fürs Kopieren angeschlossen, nicht dauerhaft verbaut |

### Systemplatte (sdc) - Partitionierung
- sdc1: 976M, /boot
- sdc5: 237,5G, LUKS2-verschlüsselt (sdb5_crypt) → LVM
  (wintermute-vg):
  - root: 40G
  - swap_1: 12,1G
  - data (Thin-Pool): 176G, enthält:
    - vm-100-disk-1: 64G (VM100, Ubuntu Docker-Host)
    - vm-100-disk-0: 4M (EFI/Boot-Hilfsdisk)
    - vm-101-disk-1: 32G (VM101, Home Assistant OS)
    - vm-101-disk-0: 4M (EFI/Boot-Hilfsdisk)

## Virtualisierung
- **Proxmox VE:** 9.2.4 (pve-manager/9.2.4/5e5ae681198514d4)
- **Kernel:** 7.0.14-4-pve

## VMs
- **VM100** (Ubuntu 26.04 LTS, Docker-Host): 64 GB Disk, IP
  192.168.178.36
- **VM101** (Home Assistant OS 18.1): 32 GB Disk, IP 192.168.178.38

## Bekannte Limitierungen / Hinweise
- CPU ohne Hyperthreading, nur 4 Threads insgesamt - bei steigender
  Anzahl paralleler Dienste (aktuell u.a. Paperless, Nextcloud, Immich
  mit jeweils eigener DB+Redis) im Blick behalten, ob die CPU zum
  Flaschenhals wird
- RAM mit 16 GB bei aktuell 8,2 GB genutzt + 12 GB Swap in Nutzung
  (3,1 GB Swap belegt) - Swap-Nutzung deutet auf spürbaren
  Speicherdruck hin, bei weiterem Ausbau (z.B. mehr Dienste) RAM-
  Erweiterung in Erwägung ziehen
- Integrierte GPU (HD Graphics 530) aktuell ungenutzt für
  Transcoding/KI - Immich-Machine-Learning läuft bei Bedarf extern auf
  einem Gaming-PC mit RTX 3080 (siehe 00-Projektuebersicht.md)
- Externe USB-Platte (sdd) ist nicht dauerhaft am Server - nur für
  Foto-Import-Vorgänge angeschlossen, taucht daher nicht immer in
  lsblk auf
