#!/bin/bash
#
# Program name:	test_iperf.sh
# Created by:	Talon Jones
# Created:	6 Oct. 2016
# Updated:	18 Oct. 2016
# Purpose:	Automate the ssh connection and iperf testing between test
#		devices.

filename="ipconfig.txt"
board="Odroid"

echo "Enter client board #: "
read boardC
echo "Enter server board #: "
read boardS

boardC="$board$boardC"
boardS="$board$boardS"

echo "Client board lookup: $boardC"
echo "Server board lookup: $boardS"

boardCip=$(grep -w $boardC $filename | awk '{printf $2}')
boardSip=$(grep -w $boardS $filename | awk '{printf $2}')

echo "Client board IP: $boardCip"
echo "Server board IP: $boardSip"

echo ""
echo "Select a test to run:
1) UDP test
2) TCP test"
read optnum

echo "Enter test duration: [min]"
read testlength
testlength=$(($testlength * 60))

set timeout -1
ssh -o PubkeyAuthentication=no host.example.com
expect -exact "password: "
send -- "odroid\r"
expect {\$\s*} {interact}
