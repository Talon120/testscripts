#!/bin/bash
#
# Program name:	test_iperf.sh
# Created by:	Talon Jones
# Created:	6 Oct. 2016
# Updated:	25 Oct. 2016
# Purpose:	Automate the ssh connection and iperf testing between test
#		devices.

function work() {
	while : ; do
		sleep 1s
		echo -n " ."
	done
}

function killwork() {
	kill -9 ${1} 2>/dev/null
	wait ${1} 2>/dev/null
}

filename="ipconfig.txt"
board="Odroid"

echo "Enter client board #: "
read boardC
echo "Enter server board #: "
read boardS
echo "Enter password: [Note: password needs to be the same for both boards]"
read pw

boardC="$board$boardC"
boardS="$board$boardS"

echo -e "\nClient board lookup: $boardC     Server board lookup: $boardS"

boardCIP1=$(grep -w $boardC $filename | awk '{printf $2}')
boardSIP1=$(grep -w $boardS $filename | awk '{printf $2}')
boardCIP2=$(grep -w $boardC $filename | awk '{printf $3}')
boardSIP2=$(grep -w $boardS $filename | awk '{printf $3}')

echo -e "Client board Internal IP: $boardCIP1     VLAN IP: $boardCIP2"
echo -e "Server board Internal IP: $boardSIP1     VLAN IP: $boardSIP2"

echo -e "\nSelect a test to run:
1) UDP test
2) TCP test
3) TCP periodic test"
read optNum

echo -e "\nEnter test duration: [min]"
read testLength
testLength=$(($testLength * 60))

./test_iperf $boardCIP1 $boardSIP1 $pw $optNum $testLength
echo ""
work &
work_pid=$!
trap 'killwork ${work_pid}; exit' INT TERM EXIT
sleep $testLength
killwork ${work_pid}
