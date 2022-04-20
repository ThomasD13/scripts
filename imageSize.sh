#!/bin/bash

#This will read .map file from tiarmclang linker, search line with "Grand Total" and extract the values for
#instruction code, readonly and readwrite data

DIVISOR=1024
FILE=$1
if [ -z "$FILE" ]
then
	echo "Usage: imageSize.sh binaryFile.map"
fi
CODE=$(grep "Grand Total" $FILE | tr -s ' ' | cut -f4 -d" ")
RO=$(grep "Grand Total" $FILE | tr -s ' ' | cut -f5 -d" ")
RW=$(grep "Grand Total" $FILE | tr -s ' ' | cut -f6 -d" ")

echo "Code: $(( CODE / DIVISOR))kB  RO: $(( RO / DIVISOR ))kB  RW: $(( RW / DIVISOR ))kB"
