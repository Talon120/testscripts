#!/bin/bash

# Program name:	ssh_install.sh
# Created by:	Talon Jones
# Created:	12 Oct. 2016
# Updated:	25 Oct. 2016
# Purpose:	Automate ssh_install for every board/IP listed in [filename].
# Usage:	./ssh_install.sh {board}

filename="ipconfig.txt"

echo "Enter device password:"
read -s pw

board=$1

if [ -n "$board" ]; then
	boardIP=$(grep -w $board $filename | awk '{printf $3}')
	if [ -n "$boardIP" ]; then
		./ssh_install $boardIP $pw
	else
		echo "$board not found in $filename."
	fi

else
	readarray -t boardIP < $filename

	#boardIP=$(awk '{printf $2}' $filename)

	for e in "${boardIP[@]}"
	do
		e=$(echo "$e" | awk '{printf $4}')
		echo "$e"
		f=$(echo "$f" | awk '{printf $3}')
		./ssh_install $e $f $pw
	done
fi
