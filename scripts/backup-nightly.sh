#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

set -e

LOCKFILE="/var/run/backup-nightly.lock"
LOG_FILE="/var/log/kopia-backup.log"
BACKUP_KEYFILE="/etc/cryptsetup-keys.d/backup-4tb.key"
BACKUP_DEVICE="/dev/disk/by-id/ata-WDC_WD40NDZW-11A8JS1_WD-WXU2E7032L5S"
BACKUP_MAPPER="backup4tb_crypt"
BACKUP_MOUNT="/mnt/backup4tb"

if [ -e "$LOCKFILE" ]; then
  echo "=== Backup übersprungen: läuft bereits (Lock-Datei vorhanden) - $(date) ===" >> "$LOG_FILE"
  exit 1
fi
touch "$LOCKFILE"

cleanup() {
  rm -f "$LOCKFILE"
  # Egal was vorher schiefging: Backup-Platte in jedem Fall sauber schließen
  if mountpoint -q "$BACKUP_MOUNT"; then
    umount "$BACKUP_MOUNT" 2>>"$LOG_FILE"
  fi
  if cryptsetup status "$BACKUP_MAPPER" >/dev/null 2>&1; then
    cryptsetup luksClose "$BACKUP_MAPPER" 2>>"$LOG_FILE"
  fi
}
trap cleanup EXIT
VM100_HOST="samuel@192.168.178.36"
SSH_KEY="/root/.ssh/id_ed25519_backup"
STAGING="/root/backup-staging"

echo "=== Backup gestartet: $(date) ===" >> "$LOG_FILE"

# 1. Backup-Platte öffnen und mounten
cryptsetup luksOpen --key-file "$BACKUP_KEYFILE" "$BACKUP_DEVICE" "$BACKUP_MAPPER" 2>>"$LOG_FILE"
mount /dev/mapper/"$BACKUP_MAPPER" "$BACKUP_MOUNT" 2>>"$LOG_FILE"

# Status für Homepage-Widget erfassen (letzter bekannter Stand)
DISK_INFO=$(df -h --output=size,used,avail,pcent "$BACKUP_MOUNT" | tail -1)
DISK_SIZE=$(echo "$DISK_INFO" | awk '{print $1}')
DISK_USED=$(echo "$DISK_INFO" | awk '{print $2}')
DISK_AVAIL=$(echo "$DISK_INFO" | awk '{print $3}')
DISK_PCENT=$(echo "$DISK_INFO" | awk '{print $4}')

cat > /var/www/backup-status/backup-status.json <<JSONEOF
{
  "size": "$DISK_SIZE",
  "used": "$DISK_USED",
  "avail": "$DISK_AVAIL",
  "percent": "$DISK_PCENT",
  "updated": "$(date '+%d.%m.%Y %H:%M')"
}
JSONEOF

# 2. Postgres-Datenbanken auf VM100 dumpen
mkdir -p "$BACKUP_MOUNT/db-dumps"

ssh -i "$SSH_KEY" "$VM100_HOST" "docker exec paperless-db pg_dump -U paperless paperless" > "$BACKUP_MOUNT/db-dumps/paperless-$(date +%Y%m%d).sql" 2>>"$LOG_FILE"
ssh -i "$SSH_KEY" "$VM100_HOST" "docker exec nextcloud-db pg_dump -U nextcloud nextcloud" > "$BACKUP_MOUNT/db-dumps/nextcloud-$(date +%Y%m%d).sql" 2>>"$LOG_FILE"
ssh -i "$SSH_KEY" "$VM100_HOST" "docker exec romm-db sh -c 'exec mariadb-dump -uroot -p\"\$MARIADB_ROOT_PASSWORD\" romm'" > "$BACKUP_MOUNT/db-dumps/romm-$(date +%Y%m%d).sql" 2>>"$LOG_FILE"
ssh -i "$SSH_KEY" "$VM100_HOST" "docker exec hortusfox-db sh -c 'exec mariadb-dump -uroot -p\"\$MARIADB_ROOT_PASSWORD\" hortusfox'" > "$BACKUP_MOUNT/db-dumps/hortusfox-$(date +%Y%m%d).sql" 2>>"$LOG_FILE"

# Alte Dumps aufräumen (nur die letzten 7 Tage behalten, Kopia sichert die Historie ohnehin)
find "$BACKUP_MOUNT/db-dumps" -name "*.sql" -mtime +7 -delete

# 3. Docker-Compose-Configs von VM100 holen (rsync, ohne .env-Geheimnisse auszulassen - die brauchen wir für ein Restore)
mkdir -p "$STAGING/homeserver"
rsync -az -e "ssh -i $SSH_KEY" --delete \
  --exclude="stacks/adguard/work/data" \
  --exclude="stacks/adguard/conf/AdGuardHome.yaml" \
  "$VM100_HOST:/home/samuel/homeserver/" "$STAGING/homeserver/" 2>>"$LOG_FILE" || true

# 4. Kopia-Snapshots erstellen
export KOPIA_PASSWORD=$(cat /root/.kopia-repo-password)

kopia snapshot create /mnt/nas6tb/paperless --tags="service:paperless" >> "$LOG_FILE" 2>&1
kopia snapshot create /mnt/nas6tb/nextcloud --tags="service:nextcloud" >> "$LOG_FILE" 2>&1
kopia snapshot create /mnt/nas6tb/kavita --tags="service:kavita" >> "$LOG_FILE" 2>&1
kopia snapshot create /mnt/nas6tb/romm --tags="service:romm" >> "$LOG_FILE" 2>&1
kopia snapshot create "$BACKUP_MOUNT/db-dumps" --tags="service:db-dumps" >> "$LOG_FILE" 2>&1
kopia snapshot create "$STAGING/homeserver" --tags="service:configs" >> "$LOG_FILE" 2>&1
kopia snapshot create /mnt/nas6tb/audiobookshelf --tags="service:audiobookshelf" >> "$LOG_FILE" 2>&1 || true
kopia snapshot create /mnt/nas6tb/trek --tags="service:trek" >> "$LOG_FILE" 2>&1
kopia snapshot create /mnt/nas6tb/hortusfox --tags="service:hortusfox" >> "$LOG_FILE" 2>&1
kopia snapshot create /mnt/nas6tb/grampsweb --tags="service:grampsweb" >> "$LOG_FILE" 2>&1

# Immich nur sichern, falls der Ordner existiert und der Dienst wieder aktiv ist
if [ -d /mnt/nas6tb/immich ]; then
  kopia snapshot create /mnt/nas6tb/immich --tags="service:immich" >> "$LOG_FILE" 2>&1
fi

# Home Assistant Backup (VM101) erstellen und abholen
HA_HOST="samuel@192.168.178.38"
HA_PORT="22222"
HA_MAC="hmac-sha2-256-etm@openssh.com"

ssh -i "$SSH_KEY" -p "$HA_PORT" -o MACs="$HA_MAC" "$HA_HOST" "bash -lc 'ha backups new --name nightly-$(date +%Y%m%d)'" >> "$LOG_FILE" 2>&1

mkdir -p "$STAGING/homeassistant"
LATEST_HA_BACKUP=$(ssh -i "$SSH_KEY" -p "$HA_PORT" -o MACs="$HA_MAC" "$HA_HOST" "bash -lc 'ls -t /backup/*.tar | head -1'")
ssh -i "$SSH_KEY" -p "$HA_PORT" -o MACs="$HA_MAC" "$HA_HOST" "cat '$LATEST_HA_BACKUP'" > "$STAGING/homeassistant/$(basename $LATEST_HA_BACKUP)" 2>>"$LOG_FILE"
# Alte lokale HA-Backup-Kopien aufräumen (nur die letzten 7 behalten, Kopia sichert Historie)
find "$STAGING/homeassistant" -name "*.tar" -mtime +7 -delete

kopia snapshot create "$STAGING/homeassistant" --tags="service:homeassistant" >> "$LOG_FILE" 2>&1

# 5. Backup-Platte wieder sauber schließen
umount "$BACKUP_MOUNT"
cryptsetup luksClose "$BACKUP_MAPPER"

echo "=== Backup abgeschlossen: $(date) ===" >> "$LOG_FILE"
