#!/bin/bash

# Program name:	ping_test.sh
# Created by:	Talon Jones
# Created:	20 April 2017
# Purpose:	Automate ping_test for every board/IP listed in [filename].
# Usage:	./ping_test.sh {board}

filename="ipconfig.txt"
mkdate=$(date +"%F_%H")

echo "Enter device password:"
read -s pw
echo "Enter server IP:"
read serverIP
echo "Enter test duration (seconds):"
read dur

board=$1

if [ -n "$board" ]; then
	e=$(grep -w $board $filename)
        boardIP=$(echo "$e" | awk '{printf $3}')
	if [ -n "$boardIP" ]; then
		echo "Running ping_test on $board."
                ./ping_test t $boardIP $pw $serverIP $dur
                echo "Running ping_test on $board for $dur seconds."
		sleep $dur
		echo "Retrieving logs from $board."
		/usr/bin/expect -c "spawn rsync --info=progress2 --remove-source-files odroid@$boardIP:ping_test.txt pinglogs/$mkdate/$board-ping-log.txt ; expect \"password:\" { send -- \"$pw\r\" } ; expect eof"
                echo "Log retrieved from $board."
		grep 'icmp_seq=' pinglogs/$mkdate/$board-ping-log.txt | sed 's/.*icmp_seq=\([0-9]*\).*/\1/' > $board-seq.txt

		count=0
		dcCount=0
		readarray -t seqN < $board-seq.txt
		for e in ${seqN[@]}
		do
			if [ $((e-5)) -gt $count ]; then
				((dcCount++))
			fi
			count=$e
		done

		if [ $count -ne $dur ]; then
			((dcCount++))
		fi

		echo "$board: $dcCount disconnects over $dur seconds" >> pinglogs/$mkdate/disconnect-log.txt
		rm -f $board-seq.txt
	else
		echo "$board not found in $filename."
	fi

else
	readarray -t boardData < $filename

	#boardIP=$(awk '{printf $2}' $filename)

	for e in "${boardData[@]}"
	do
		boardIP=$(echo "$e" | awk '{printf $3}')
		board=$(echo "$e" | awk '{printf $1}')
		if [ "$board" != "[Board]" ]; then
			echo "Running ping_test on $board."
                	./ping_test $boardIP $pw $serverIP $dur
                	echo "Running ping_test on $board for $dur seconds."
		fi
	done

	echo "Sleeping for $dur seconds."
	sleep $dur

	for e in "${boardData[@]}"
	do
		boardIP=$(echo "$e" | awk '{printf $3}')
		board=$(echo "$e" | awk '{printf $1}')
		count=0
		dcCount=0
		echo "Collecting logs."
		if [ "$boardData" != "IP]" ]; then
			/usr/bin/expect -c "spawn rsync --info=progress2 --remove-source-files odroid@$boardIP:ping_test.txt pinglogs/$mkdate/$board-ping-log.txt ; expect \"password:\" { send -- \"$pw\r\" } ; expect eof"
                	echo "Log retrieved from $board."
			grep 'icmp_seq=' $board-ping-log.txt | sed 's/.*icmp_seq=\([0-9]*\).*/\1/' > $board-seq.txt

			readarray -t seqN < $board-seq.txt
			for e in ${seqN[@]}
			do
				if [ $((e-5)) -gt $count ]; then
					((dcCount++))
				fi
				count=$e
			done

			if [ $count -ne $dur ]; then
				((dcCount++))
			fi

			echo "$board: $dcCount disconnects over $dur seconds" >> pinglogs/$mkdate/disconnect-log.txt
			rm -f $board-seq.txt
		fi
	done
fi
