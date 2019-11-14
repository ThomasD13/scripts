#!/bin/bash
DATE=$(date +%Y-%m-%d-%H%M%S)

# pfad sollte nicht mit "/" enden!
# Dies ist nur ein Beispiel - bitte an eigene Bedürfnisse anpassen.
# Man muß schreibberechtigt im entsprechenden Verzeichnis sein.
BACKUP_DIR="/mnt/ssd/backups"

# Hier Verzeichnisse auflisten, die gesichert werden sollen.
# Dies ist nur ein Beispiel - bitte an eigene Bedürfnisse anpassen.
# Bei Verzeichnissen, für die der User keine durchgehenden Leserechte hat (z.B. /etc) sind Fehler vorprogrammiert.
# Pfade sollte nicht mit "/" enden!
SOURCE="$HOME "
EXCLUDE_1="$HOME/oe/tisdk/build/arago-tmp-external-arm-toolchain" #Exclude the build output of arago
EXCLUDE_2="$HOME/oe/yocto/build-rpi/tmp"			  #Exclude the build output of Machine "rpi"

XZ_OPT="-1 -T6" tar -cvJpf $BACKUP_DIR/backup-$DATE.tar.xz --exclude=$EXCLUDE_2 $SOURCE
# Options: 
# XZ_OPT = Options for xz compression: -1 = less compression, -T6 = use 6 Cores
# tar: c = create archive, v = verbose, J = use xz as compression, p = preserve permissions, f = archive file
# --exclude=<Directories which should exclude from backup>, (Notice. Write single directories and set this before $SOURCE)

# Um ein Backup wieder zu entpacken könnte folgender Befehl verwendet werden
# tar -xvpjf backup-2019-11-14-064214.tar.bz2 --numeric-owner
# Options: x = Extract, v = verbose, p = preserve permissions, z/J = bzip2/xz, f = file
