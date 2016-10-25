#!/bin/bash

# Program name:	ssh_install.sh
# Created by:	Talon Jones
# Created:	12 Oct. 2016
# Updated:	25 Oct. 2016
# Purpose:	Automate ssh_install for every board/IP listed in [filename].
# Usage:	./ssh_install.sh

filename="ipconfig.txt"

echo "Enter device password:"
read pw

readarray -t boardIP < $filename

#boardIP=$(awk '{printf $2}' $filename)

for e in "${boardIP[@]}"
do
	e=$(echo "$e" | awk '{printf $3}')
	echo "$e"
	./ssh_install $e $pw
done
