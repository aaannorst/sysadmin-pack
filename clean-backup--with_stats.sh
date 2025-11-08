#!/bin/bash

# delete files from your backup folder only if they exist elsewhere on the system, WITH STATS

BACKUP_DIR="/path/to/your/backup"  # ← Change this
LOG_FILE="/tmp/cleanup_report.txt"
TEMP_HASHES="/tmp/backup_hashes.txt"

echo "=== Disk Cleanup Report ===" > "$LOG_FILE"
echo "Start: $(date)" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Before: Disk usage
echo "📊 Disk usage BEFORE:" >> "$LOG_FILE"
df -h "$BACKUP_DIR" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Build hash list of all files outside backup
echo "🔍 Building file hash database..." >> "$LOG_FILE"
find / -path "$BACKUP_DIR" -prune -o -type f -exec md5sum {} \; 2>/dev/null | cut -d' ' -f1 > "$TEMP_HASHES"

# Count and size before
before_count=$(find "$BACKUP_DIR" -type f | wc -l)
before_size=$(du -sh "$BACKUP_DIR" | cut -f1)

# Delete duplicates
echo "🧹 Removing duplicates from $BACKUP_DIR" >> "$LOG_FILE"
deleted_count=0
while IFS= read -r file; do
    hash=$(md5sum "$file" | cut -d' ' -f1)
    if grep -q "^$hash" "$TEMP_HASHES"; then
        rm "$file" && ((deleted_count++))
    fi
done < <(find "$BACKUP_DIR" -type f)

# After: Disk usage
echo "" >> "$LOG_FILE"
echo "✅ Disk usage AFTER:" >> "$LOG_FILE"
df -h "$BACKUP_DIR" >> "$LOG_FILE"

# Summary
after_size=$(du -sh "$BACKUP_DIR" | cut -f1)
echo "" >> "$LOG_FILE"
echo "📈 Summary:" >> "$LOG_FILE"
echo "Files removed: $deleted_count" >> "$LOG_FILE"
echo "Size before: $before_size" >> "$LOG_FILE"
echo "Size after: $after_size" >> "$LOG_FILE"

echo "" >> "$LOG_FILE"
echo "Cleanup complete. Report saved to $LOG_FILE"

cat "$LOG_FILE"