#!/bin/bash

# Program name:	ssh_install.sh
# Created by:	Talon Jones
# Created:	12 Oct. 2016
# Updated:	4 Nov. 2016
# Purpose:	Automate ssh_install for every board/IP listed in [filename].
# Usage:	./ssh_install.sh {board}

filename="ipconfig.txt"

echo "Enter device password:"
read -s pw

board=$1

if [ -n "$board" ]; then
	e=$(grep -w $board $filename)
	initVIP=$(echo "$e" | awk '{printf $4}')
        newVIP=$(echo "$e" | awk '{printf $3}')
        newLIP=$(echo "$e" | awk '{printf $2}')
	if [ -n "$initVIP" ]; then
		echo "Running ssh_install on $board."
                ./ssh_install $initVIP $newVIP $newLIP $pw >> ssh_install.log
                sed -i "s/$initVIP/$newVIP/g" ipconfig.txt
                echo "Install completed on $board."
	else
		echo "$board not found in $filename."
	fi

else
	readarray -t boardIP < $filename

	#boardIP=$(awk '{printf $2}' $filename)

	for e in "${boardIP[@]}"
	do
		initVIP=$(echo "$e" | awk '{printf $4}')
		newVIP=$(echo "$e" | awk '{printf $3}')
		newLIP=$(echo "$e" | awk '{printf $2}')
		board=$(echo "$e" | awk '{printf $1}')
		#echo "-$initVIP-"
		if [ "$initVIP" != "[VLAN" ]; then
			echo "Running ssh_install on $board."
			./ssh_install $initVIP $newVIP $newLIP $pw >> ssh_install.log
			sed -i "s/$initVIP/$newVIP/g" ipconfig.txt
			echo "Install completed on $board."
		fi
	done
fi
