#!/bin/bash

# Program name:	get_logs.sh
# Created by:	Talon Jones
# Created:	3 Nov. 2016
# Updated:	10 Nov. 2016
# Purpose:	Retrieve any iperf log files from boards listed in ipconfig.txt.
# Usage:	./get_logs.sh {board}

filename="ipconfig.txt"
board=$1
mkdate=$(date +"%F_%H")

echo "Enter device password:"
read -s pw

if [ -n "$board" ]; then
	e=$(grep -w $board $filename)
	initVIP=$(echo "$e" | awk '{printf $4}')
	if [ -n "$initVIP" ]; then
		mkdir -p $mkdate/log_test1/logs/
        	mkdir -p $mkdate/log_test2/logs/
	        mkdir -p $mkdate/log_test3/logs/
		echo "Running get_logs on $board."
		./get_logs $initVIP $pw $board $mkdate
		echo "Retrieved logs from $board."
	else
		echo "$board not found in $filename."
	fi

else
	readarray -t boardIP < $filename
	mkdir -p $mkdate/log_test1/logs/
	mkdir -p $mkdate/log_test2/logs/
	mkdir -p $mkdate/log_test3/logs/

	for e in "${boardIP[@]}"
	do
		initVIP=$(echo "$e" | awk '{printf $4}')
		board=$(echo "$e" | awk '{printf $4}')
		if [ "$initVIP" != "[VLAN" ]; then
			echo "Running get_logs on $board."
			./get_logs $initVIP $pw $board $mkdate
			echo "Retrieved logs from $board."
		fi
	done
fi

