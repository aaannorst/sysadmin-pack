#!/bin/bash

# delete files from your backup folder only if they exist elsewhere on the system

BACKUP_DIR="/path/to/your/backup"  # ← Change this
TEMP_FILE=$(mktemp)

# Find all files outside the backup directory and compute their hashes
find / -path "$BACKUP_DIR" -prune -o -type f -exec md5sum {} \; 2>/dev/null | cut -d' ' -f1 > "$TEMP_FILE.hashes"

# Process each file in the backup folder
find "$BACKUP_DIR" -type f | while read file; do
    hash=$(md5sum "$file" | cut -d' ' -f1)
    if grep -q "$hash" "$TEMP_FILE.hashes"; then
        echo "Deleting duplicate: $file"
        rm "$file"
    fi
done

rm -f "$TEMP_FILE.hashes"
echo "Cleanup complete."   