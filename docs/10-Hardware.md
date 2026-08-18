# Hardware – Wintermute

Stand: 18.07.2026

## System
- **Mainboard:** Gigabyte Z170-HD3P-CF
- **CPU:** Intel Core i7-7700 @ 3.60GHz (4 Kerne, 2 Threads/Kern,
  Hyperthreading, 8 Threads insgesamt)
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
## RAM-Aufruestung abgeschlossen (17.08.2026)

Physischer Einbau der bereits am 17.07. bestellten RAM-Module durchgefuehrt.
Host verfuegt jetzt ueber **32GB RAM** (vorher 16GB).

### Tatsaechliche Bestueckung (per `sudo lshw -short` / `inxi -Fxz` verifiziert)

| Slot | Groesse | Typ |
|------|---------|-----|
| 0    | 8GiB    | DDR4 Synchronous 2400 MHz |
| 1    | 16GiB   | DDR4 Synchronous 2400 MHz |
| 2    | 8GiB    | DDR4 Synchronous 2400 MHz |
| 3    | leer    | - |

**Abweichung vom urspruenglichen Plan:** Der Eintrag vom 17.07. sah 4x8GB auf
allen 4 Slots vor (2x vorhandene Crucial Ballistix + 2x neu bestellte BRAINZAP-
Module). Tatsaechlich zeigt die Auslesung ein 16GB-Modul in Slot 1 und nur 3 von
4 Slots belegt (Slot 3 leer). Gesamtkapazitaet (32GB) stimmt mit dem Ziel
ueberein, die Modul-Aufteilung weicht aber ab - moeglicherweise wurde eines der
neuen Module durch ein bereits vorhandenes 16GB-Modul ersetzt/ergaenzt statt wie
geplant zusaetzlich 2x8GB zu verbauen. Nicht weiter kritisch (funktioniert, volle
32GB erkannt), aber bei zukuenftiger Board-/RAM-Arbeit im Hinterkopf behalten -
Slot 3 hat noch Platz fuer weitere Aufruestung, falls gewuenscht.

### Speicherauslastung nach Upgrade (Stand 17.08., VM100 mit vollem Docker-Stack aktiv)
- Gesamt: 32GB, davon 26,73GB genutzt (85,6%)
- Grund: VM100 laeuft mit 20GB zugewiesenem RAM (`-m 20480` in der qm-Config),
  VM101 zusaetzlich - der Host selbst hat davon unabhaengig wenig eigenen Bedarf
- Swap: 12,06GB konfiguriert, davon nur 20KiB genutzt (0,0%) - deutliche
  Verbesserung gegenueber vorher (3,1GB Swap-Nutzung bei 16GB RAM), Ziel der
  Aufruestung damit erreicht
- Perspektivisch pruefen, ob VM100/VM101-Speicherzuweisungen angesichts der
  jetzt verfuegbaren 32GB noch weiter angepasst werden sollten (z.B. mehr RAM
  fuer VM100 wegen des mittlerweile umfangreichen Docker-Stacks)

### Werkzeuge fuer Hardware-Auslesung installiert
`lshw`, `inxi`, `hwinfo` auf dem Host installiert (zuvor nicht vorhanden) -
nuetzlich fuer kuenftige Hardware-Checks:
```bash
inxi -Fxz              # uebersichtliche Gesamtuebersicht (System, CPU, RAM, Storage, Netzwerk)
sudo lshw -short        # kompakte Hardwareliste
sudo hwinfo --short      # alternative Uebersicht
```

### CPU/System zur Referenz (unveraendert, per inxi bestaetigt)
- Intel Core i7-7700 (Kaby Lake), 4 Kerne / 8 Threads, bis 4200 MHz
- Board: Gigabyte Z170-HD3P-CF, BIOS F22g
- Kernel: 7.0.14-5-pve (Proxmox VE)
