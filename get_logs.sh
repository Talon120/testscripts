#!/bin/bash

# Program name:	get_logs.sh
# Created by:	Talon Jones
# Created:	3 Nov. 2016
# Updated:	16 Nov. 2016
# Purpose:	Retrieve any iperf log files from boards listed in ipconfig.txt.
# Usage:	./get_logs.sh {board}

filename="ipconfig.txt"
board=$1
mkdate=$(date +"%F_%H")
logBreak="- - - - - - - - - - - - - - - - - - - - - - - - -"
logServ="Accepted connection"
logEnd="iperf Done."
logErr="iperf3: error"

logParse() {
	for logFolders in $mkdate/*
	do
		for logFilename in $logFolders/*.txt
		do
			echo $logFilename
			echo $logFolders
			echo -e "- - - $logFilename - - -\n" >> $logFolders/summary
			if [[ "$logFolders" == *servers ]]; then
				sed -n "/$logBreak/,/$logServ/p" $logFilename >> $logFolders/summary
			else
				sed -n "/$logBreak/,/$logEnd/{/$logBreak/b;/$logEnd/b;p}" $logFilename >> $logFolders/summary
			fi
			grep -s "$logErr" $logFilename >> $logFolders/summary
		done
	done

return 0
}

echo "Enter device password:"
read -s pw

if [ -n "$board" ]; then
	e=$(grep -w $board $filename)
	initVIP=$(echo "$e" | awk '{printf $4}')
	if [ -n "$initVIP" ]; then
		mkdir -p iperflogs/$mkdate/log_test1/
        	mkdir -p iperflogs/$mkdate/log_test2/
	        mkdir -p iperflogs/$mkdate/log_test3/
		mkdir -p iperflogs/$mkdate/servers/
		echo "Running get_logs on $board."
		./get_logs $initVIP $pw $board iperflogs/$mkdate
		echo "Retrieved logs from $board."
		logParse
	else
		echo "$board not found in $filename."
	fi

else
	readarray -t boardIP < $filename
	mkdir -p iperflogs/$mkdate/log_test1/
	mkdir -p iperflogs/$mkdate/log_test2/
	mkdir -p iperflogs/$mkdate/log_test3/
	mkdir -p iperflogs/$mkdate/servers/

	for e in "${boardIP[@]}"
	do
		initVIP=$(echo "$e" | awk '{printf $4}')
		board=$(echo "$e" | awk '{printf $1}')
		if [ "$initVIP" != "[VLAN" ]; then
			echo "Running get_logs on $board."
			./get_logs $initVIP $pw $board iperflogs/$mkdate
			echo "Retrieved logs from $board."
		fi
	done
	logParse
fi

