#!/bin/sh

bin_dir=$(dirname "$0")
logs_dir="$bin_dir/../logs/"
backups_dir="$bin_dir/../data/backups/"
backup_dir="$backups_dir/`date +"%Y%m%d"`"

exec &> "$logs_dir/$(date '+%Y-%m-%d').log" 2>&1
echo "Starting Nextcloud export..."

# Run a Nextcloud backup
nextcloud_dir="$bin_dir/../app/"
rsync -Aavx $nextcloud_dir $backup_dir/nextcloud.bak

# Run a OnlyOffice Backup
onlyoffice_dir="$bin_dir/../onlyoffice/"
rsync -Aavx $onlyoffice_dir $backup_dir/onlyoffice.bak

# Run a Postgres Backup
docker exec -t nextcloud-db pg_dumpall -c -U nextcloud --password pass > $backup_dir/postgres.sql

# Remove old backups
clean_count=`ls $backups_dir 2>/dev/null | wc -l | xargs -i expr {} - 2`
if [ $clean_count -gt 0 ]; then
  ls $backups_dir -t | tail -n $clean_count | xargs -i rm -r "$backups_dir/{}"
fi