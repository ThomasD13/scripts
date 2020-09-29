#!/bin/bash

echo "Start copying boot stuff to sdc1"
SOURCEDIR="/home/thomas/tda4vmx/psdk-linux-automotive-j7-evm-07_00_01/yocto-build/build/arago-tmp-external-arm-glibc/deploy/images/j7-evm"
cp -L -f -v ${SOURCEDIR}/tiboot3.bin /media/thomas/BOOT/
cp -L -f -v ${SOURCEDIR}/tispl.bin /media/thomas/BOOT/
cp -L -f -v ${SOURCEDIR}/u-boot.img /media/thomas/BOOT/
cp -L -f -v ${SOURCEDIR}/sysfw.itb /media/thomas/BOOT/
sync

echo ""
echo "Start copying rootfs to sdc2"
sudo rm -rf /media/thomas/rootfs/*

cp -L -f -v ${SOURCEDIR}/tisdk-default-image-j7-evm.tar.xz /media/thomas/rootfs/
sync
echo "Start with extracting"
cd /media/thomas/rootfs
tar -xvJf tisdk-default-image-j7-evm.tar.xz
cd -
rm /media/thomas/rootfs/tisdk-default-image-j7-evm.tar.xz
sync
echo "!!!!!!!!! FINISHED!!!!!!!!!!!!"
