#!/bin/bash

NEXTCLOUD_FOLDER="/mnt/nas6tb/nextcloud/data/samuel/files/Photos/Wallpaper Homepage"
POOL_DIR="/home/samuel/homeserver/stacks/homepage/wallpapers-pool"
TARGET="/home/samuel/homeserver/stacks/homepage/config/images/wallpaper.jpg"
LOG_FILE="/home/samuel/homeserver/stacks/homepage/wallpaper-rotate.log"

rsync -av "$NEXTCLOUD_FOLDER"/ "$POOL_DIR"/ >> "$LOG_FILE" 2>&1

LAST_IMAGE=$(cat /tmp/last-wallpaper.txt 2>/dev/null)
NEW_IMAGE=$(find "$POOL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.avif" -o -iname "*.webp" \) ! -name "$(basename "$LAST_IMAGE" 2>/dev/null)" | shuf -n 1)

if [ -z "$NEW_IMAGE" ]; then
  echo "$(date): Kein Bild im Pool gefunden." >> "$LOG_FILE"
  exit 1
fi

ffmpeg -y -i "$NEW_IMAGE" -update 1 "$TARGET" >> "$LOG_FILE" 2>&1

echo "$NEW_IMAGE" > /tmp/last-wallpaper.txt
chown -R samuel:samuel "$POOL_DIR"
chown samuel:samuel "$TARGET" 2>/dev/null
chown samuel:samuel "$LOG_FILE" 2>/dev/null
echo "$(date): Wallpaper gewechselt zu $NEW_IMAGE" >> "$LOG_FILE"
docker compose -f /home/samuel/homeserver/stacks/homepage/compose.yml restart homepage >> "$LOG_FILE" 2>&1
