#!/bin/bash
DATE=$(date +%Y-%m-%d-%H%M%S)

# pfad sollte nicht mit "/" enden!
# Dies ist nur ein Beispiel - bitte an eigene Bedürfnisse anpassen.
# Man muß schreibberechtigt im entsprechenden Verzeichnis sein.
BACKUP_SYSTEM_DIR="/mnt/backup/timeshift/snapshots"

#Jetzt den vorletzt erstellen Ordner in diesem Pfad raussuchen
#Vorletzt soll verhindern, dass ein gerade erstellt & noch in Arbeit Ordner verwendet wird
LAST_BACKUP=$(ls -td $BACKUP_SYSTEM_DIR/*/ | head -2 | tail -1)

#Entfernen von / bei Ende des Pfads
LAST_BACKUP=${LAST_BACKUP%/}
BACKUP_NAME=$(basename $LAST_BACKUP)

echo "Starting compressing ${LAST_BACKUP}"
echo "Name of backup $BACKUP_NAME"

XZ_OPT="-1 -T18" tar -cvJpf /mnt/backup/backups/system/system-backup-${BACKUP_NAME}_compressed_at_$DATE.tar.xz $LAST_BACKUP

# Options: 
# XZ_OPT = Options for xz compression: -1 = less compression, -T6 = use 6 Cores
# tar: c = create archive, v = verbose, J = use xz as compression, p = preserve permissions, f = archive file
# --exclude=<Directories which should exclude from backup>, (Notice. Write single directories and set this before $SOURCE)

# Um ein Backup wieder zu entpacken könnte folgender Befehl verwendet werden
# tar -xvpjf backup-2019-11-14-064214.tar.bz2 --numeric-owner
# Options: x = Extract, v = verbose, p = preserve permissions, z/J = bzip2/xz, f = file
