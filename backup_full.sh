#!/bin/bash
DATE=$(date +%Y-%m-%d-%H%M%S)

# pfad sollte nicht mit "/" enden!
# Dies ist nur ein Beispiel - bitte an eigene Bedürfnisse anpassen.
# Man muß schreibberechtigt im entsprechenden Verzeichnis sein.
BACKUP_DIR="/mnt/backup/backups/ewdt"

# Hier Verzeichnisse auflisten, die gesichert werden sollen.
# Dies ist nur ein Beispiel - bitte an eigene Bedürfnisse anpassen.
# Bei Verzeichnissen, für die der User keine durchgehenden Leserechte hat (z.B. /etc) sind Fehler vorprogrammiert.
# Pfade sollte nicht mit "/" enden!
SOURCE="$HOME "
EXCLUDE_1="$HOME/oe/arago/build/arago-tmp-external-arm-glibc"	 	#Exclude the build output of arago
EXCLUDE_2="$HOME/oe/arago/build/cache" 					#Exclude the cache output of arago
EXCLUDE_3="$HOME/oe/arago/build/sstate-cache" 				#Exclude the sstate-cache output of arago
EXCLUDE_4="$HOME/oe/yocto/build-rpi/tmp"			  	#Not used ATM. Exclude the tmp output of Machine "rpi"
EXCLUDE_5="$HOME/oe/yocto/build-rpi/cache"			  	#Not used ATM. Exclude the cache output of Machine "rpi"
EXCLUDE_6="$HOME/oe/yocto/build-rpi/sstate-cache"		  	#Not used ATM. Exclude the sstate-cache output of Machine "rpi"
EXCLUDE_7="$HOME/oe/tda4vmx/build/arago-tmp-external-arm-toolchain" 	#Not used ATM. Exclude the build output of tda4vmx
EXCLUDE_8="$HOME/oe/tda4vmx/build/cache" 				#Not used ATM. Exclude the cache output of tda4vmx
EXCLUDE_9="$HOME/oe/tda4vmx/build/sstate-cache" 			#Not used ATM. Exclude the sstate-cache output of tda4vmx

echo "Starting backup..."
XZ_OPT="-1 -T18" tar --exclude=$EXCLUDE_1 --exclude=$EXCLUDE_2 --exclude=$EXCLUDE_3 --exclude=$EXCLUDE_4 \
--exclude=$EXCLUDE_5 --exclude=$EXCLUDE_6 --exclude=$EXCLUDE_7 --exclude=$EXCLUDE_8 --exclude=$EXCLUDE_9 \
-cvJpf $BACKUP_DIR/ewdt-backup-$DATE.tar.xz $SOURCE
# Options: 
# XZ_OPT = Options for xz compression: -1 = less compression, -T6 = use 6 Cores
# tar: c = create archive, v = verbose, J = use xz as compression, p = preserve permissions, f = archive file
# --exclude=<Directories which should exclude from backup>, (Notice. Write single directories and set this before $SOURCE)

# Um ein Backup wieder zu entpacken könnte folgender Befehl verwendet werden
# tar -xvpjf backup-2019-11-14-064214.tar.bz2 --numeric-owner
# Options: x = Extract, v = verbose, p = preserve permissions, z/J = bzip2/xz, f = file
