#!/bin/bash

#This script will pull a linux rootfs image archive from ibg Linux build server
#and extract it to defined PSDKLA NFS folder for network boot on TDA4EVMX
REMOTEMACHINE="172.16.1.150"
REMOTESOURCEDIR="/home/ewdt/oe/arago/build/arago-tmp-external-arm-glibc/deploy/images/j7-evm"
LOCALTARGETDIR="/home/thomas/tda4vmx/psdk-linux-automotive-j7-evm-07_00_01/targetNFS"
ROOTFSIMAGE="viop-image-j7-evm.tar.xz"

if [ "$1" != "" ]; then
    echo "Testing $SOURCEDIR/$1"
    if test -f "$SOURCEDIR/$1"; then
        echo "Given argument is used as rootfsimage name: $1"
        ROOTFSIMAGE="$1"
    else
	echo "Given rootfsimage not found: $SOURCEDIR/$1"
	echo "Stop here!"
	exit
    fi
else
    echo "Positional parameter 1 is empty"
fi

echo "Please check following settings and confirm with SPACE or CTRL-C to stop!"
echo "Warning: LOCALTARGETDIR will get deleted!!!"
echo ""
echo "Remote machine:	 $REMOTEMACHINE"
echo "Remote source dir: $REMOTESOURCEDIR"
echo "Local target dir:  $LOCALTARGETDIR"
echo "Name rootfs image: $ROOTFSIMAGE"
echo ""

read -n1 -r -p "Press space to continue..." key

if [ "$key" = '' ]; then
    # Space pressed, do something
    echo [$key] is empty when SPACE is pressed # uncomment to trace
else
    exit
fi

# 1. Delete everything in local targetdir
echo "Delete everything in LOCALTARGETDIR"
if test -d "$LOCALTARGETDIR"; then
    echo "rm -rf $LOCALTARGETDIR/*"
    sudo rm -rf ${LOCALTARGETDIR}/*
else
    echo "$LOCALTARGETDIR not found. Cannot delete. Abort!"
    exit
fi

# 2. Fetch rootfs image from server and extract in targetdir
echo "Start fetching stuff from REMOTEMACHINE"
scp -r "ewdt@$REMOTEMACHINE:$REMOTESOURCEDIR/$ROOTFSIMAGE" "$LOCALTARGETDIR"
cd "$LOCALTARGETDIR"
tar -xvJf "$ROOTFSIMAGE"
cd -

echo "!!!      FINISHED     !!!"

# 3. TODO: Maybe copy kernel and dtb stuff into tftp directory. For now only apply rootfs from arago build


#cp -L -f -v ${SOURCEDIR}/tiboot3.bin /media/thomas/BOOT/
#cp -L -f -v ${SOURCEDIR}/tispl.bin /media/thomas/BOOT/
#cp -L -f -v ${SOURCEDIR}/u-boot.img /media/thomas/BOOT/
#cp -L -f -v ${SOURCEDIR}/sysfw.itb /media/thomas/BOOT/