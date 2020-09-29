#!/bin/bash
STARTDIR=$(pwd)
GITDIR=$1

if [ -z "$GITDIR" ]
then
	echo "This script will print status of every (git)-folder of given directory."
	echo "Usage: gitstatus.sh /folder/of/gitdirectories/"
fi

for FOLDER in $GITDIR*
	do
		#echo "Try to do $FOLDER"
		[ -d $FOLDER ] && cd "$FOLDER" && echo "Entering into $FOLDER"
		git status
		echo "-----------------------------------------------------------------"
		echo ""
	done;

cd "$STARTDIR"
