#!/bin/bash

#This script will pull a linux rootfs image archive from ibg Linux build server
#and extract it to defined PSDKLA NFS folder for network boot on TDA4EVMX
REMOTEMACHINE="172.16.1.18"
REMOTESOURCEDIR="/home/ewdt/oe/arago/build/arago-tmp-external-arm-glibc/deploy/images/e3mc"
LOCALTARGETDIRROOTFS="/home/thomas/e3mc_1"
LOCALTARGETDIRKERNEL="/tftpboot/e3mc"
KERNELIMAGE="Image-e3mc.bin"
DEVICETREE="k3-j721e-common-proc-board-e3mc.dtb"
DEVICETREEOVERLAY="e3mc.dtbo"
ROOTFSIMAGE="e3mc-image-e3mc.tar.xz"
#ROOTFSIMAGE="tisdk-default-image-j7-evm.tar.xz"

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
echo "Warning: LOCALTARGETDIRROOTFS will get deleted!!!"
echo ""
echo "Remote machine:	 	$REMOTEMACHINE"
echo "Remote source dir: 	$REMOTESOURCEDIR"
echo "Local target rootfs dir:  $LOCALTARGETDIRROOTFS"
echo "Local target kernel dir:  $LOCALTARGETDIRKERNEL"
echo "Name rootfs image: 	$ROOTFSIMAGE"
echo "Name kernel image:	$KERNELIMAGE"
echo "Name devicetree:		$DEVICETREE"
echo "Name devicetree overlay:	$DEVICETREEOVERLAY"
echo ""

read -n1 -r -p "Press space to continue..." key

if [ "$key" = '' ]; then
    # Space pressed, do something
    echo [$key] is empty when SPACE is pressed # uncomment to trace
else
    exit
fi

# 1. Delete everything in local targetdir
echo "Delete everything in LOCALTARGETDIRROOTFS"
if test -d "$LOCALTARGETDIRROOTFS"; then
    echo "rm -rf $LOCALTARGETDIRROOTFS/*"
    sudo rm -rf ${LOCALTARGETDIRROOTFS}/*
else
    echo "$LOCALTARGETDIRROOTFS not found. Cannot delete. Abort!"
    exit
fi

# 2. Fetch rootfs image from server and extract in targetdir
echo "Start fetching stuff from REMOTEMACHINE"
scp -r "ewdt@$REMOTEMACHINE:$REMOTESOURCEDIR/$ROOTFSIMAGE" "$LOCALTARGETDIRROOTFS"
cd "$LOCALTARGETDIRROOTFS"
tar -xvJf "$ROOTFSIMAGE"
cd -


# 3. Copy kernel and dtb stuff into tftp directory.

scp -r "ewdt@$REMOTEMACHINE:$REMOTESOURCEDIR/$KERNELIMAGE" "$LOCALTARGETDIRKERNEL"
scp -r "ewdt@$REMOTEMACHINE:$REMOTESOURCEDIR/$DEVICETREE" "$LOCALTARGETDIRKERNEL"
scp -r "ewdt@$REMOTEMACHINE:$REMOTESOURCEDIR/$DEVICETREEOVERLAY" "$LOCALTARGETDIRKERNEL"

echo "!!!      FINISHED     !!!"
