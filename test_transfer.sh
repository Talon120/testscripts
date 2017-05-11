#!/bin/bash
#
# Program name:	test_iperf.sh
# Created by:	Talon Jones
# Created:	22 Nov. 2016
# Purpose:	Automate the file transfer test between the central server and two test boards.


filename="ipconfig.txt"
mkdate=$(date +"%F_%H")
board="Odroid"

echo "This test will transfer the designated file from: Server->Board1->Board2->Server"
echo "Enter Server IP: "
read serverIP
echo "Enter Server Username: "
read serverUser
echo "Enter Server Password: "
read -s serverPass
echo "Enter first board #: "
read boardC
echo "Enter second board #: "
read boardS
echo "Enter password: [Note: password needs to be the same for both boards]"
read -s pw

boardC="$board$boardC"
boardS="$board$boardS"

echo -e "\nClient board lookup: $boardC     Server board lookup: $boardS"

boardCLanIP=$(grep -w $boardC $filename | awk '{printf $2}')
boardSLanIP=$(grep -w $boardS $filename | awk '{printf $2}')
boardCVlanIP=$(grep -w $boardC $filename | awk '{printf $3}')
boardSVlanIP=$(grep -w $boardS $filename | awk '{printf $3}')

echo -e "Client board Internal IP: $boardCLanIP     VLAN IP: $boardCVlanIP"
echo -e "Server board Internal IP: $boardSLanIP     VLAN IP: $boardSVlanIP"

echo -e "\nName of file to transfer: [1GB, 512MB, 200MB, 100MB, 50MB, 20MB, 10MB, 5MB]"
read transferFile

if [[ $(ls | grep "$transferFile.zip") ]]; then
	echo -e "\n\nControl file found on server.\n"
else
	echo -e "\n\nControl file not found. Downloading now.\n"
	wget "download.thinkbroadband.com/$transferFile.zip"
fi

echo -e "Number of times to loop: "
read numloop

echo -e "\n\n$mkdate\n" >> transferlog.txt

while [ $numloop -gt 0 ]; do

	echo -e "\nRunning transfer..."

	./test_transfer $boardCLanIP $boardSLanIP $pw "$transferFile.zip" $boardCVlanIP $boardSVlanIP $serverUser $serverPass $serverIP

	echo -e "\nRelocating file."
	mv $transferFile.zip.new .

	echo -e "\nChecking file differences:\n"
	diff "$transferFile.zip" "$transferFile.zip.new"
	ret=$?

	if [[ $ret -eq 0 ]]; then
		echo -e "No differences found between:\nControl File:\t$transferFile.zip\nTransfered File:\t$transferFile.zip.new\n" >> transferlog.txt
	else
		echo "Error: diff command failed with filenames given: $transferFile.zip and $transferFile.zip.new" >> transferlog.txt
	fi

	numloop=$[$numloop-1]

done
