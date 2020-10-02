#!/bin/bash

SOURCEDIR="/home/thomas/deleteMe/j7-evm"
ROOTFSIMAGE="tisdk-default-image-j7-evm.tar.xz"

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

echo "Start copying boot stuff to sdc1"
cp -L -f -v ${SOURCEDIR}/tiboot3.bin /media/thomas/BOOT/
cp -L -f -v ${SOURCEDIR}/tispl.bin /media/thomas/BOOT/
cp -L -f -v ${SOURCEDIR}/u-boot.img /media/thomas/BOOT/
cp -L -f -v ${SOURCEDIR}/sysfw.itb /media/thomas/BOOT/
sync

echo ""
echo "Start copying rootfs to sdc2"
sudo rm -rf /media/thomas/rootfs/*

cp -L -f -v ${SOURCEDIR}/${ROOTFSIMAGE} /media/thomas/rootfs/
sync
echo "Start with extracting"
cd /media/thomas/rootfs
tar -xvJf ${ROOTFSIMAGE}
cd -
rm /media/thomas/rootfs/${ROOTFSIMAGE}
sync
echo "!!!!!!!!! FINISHED!!!!!!!!!!!!"
