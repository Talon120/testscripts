Created by:	Talon Jones

Testscripts repository is for scripts used to automate network testing and tool installations.

# Files and Script Usage:

##ipconfig.txt
	A plain text file containing a complete list of boards and their LAN and WAN IP addresses.
	The WAN IP will be used to remotely SSH into the boards to execute scripts, and the LAN IP
	will be used for iperf testing to automatically connect two boards on the same LAN.
	Format will be:
		[Board] [Internal IP] [VLAN IP] [INIT IP]
	E.g.:	Odroid1 192.168.1.5 10.10.10.24 10.10.10.4
	Internal IP:	The IP address that will be used for iperf sessions.
	VLAN IP:	The IP address that will be used for SSH connections from the central
			server.
	INIT IP:	The IP address that is currently assigned for SSH connections from the
			central	server. This will be updated to [VLAN IP] after running
			ssh_install.sh (SOON).

##ssh_install.sh {board}
	This file will remotely install iperf tools and all dependent libraries. Running this
	script without an argument will initiate the install process on ALL boards listed in the
	ipconfig.txt file. Specifying a {board} will cause the script to run only on that one
	board, if found, using the IP addresses given to it in ipconfig.txt.

##ssh_intall [IP] [NEW VLANIP] [NEW LANIP] [PW]
	This expect script will be run by ssh_install.sh for the [IP] given, and will use the
	given [PW] to authorize any SSH/sudo commands. This script will only be used by the
	ssh_install.sh script, and does not need to be run manually.

##setup_iperf.sh
	This script will automatically install iperf tools and all dependent libraries on the
	current machine. Unless manually running this script on a test board to correct for any
	installation issues, this script will not be used.

##test_iperf.sh
	This script will assist the tester in initiating an iperf test session between two boards.
	This script has no arguments since it will walk the user through the startup process. The
	format of ipconfig.txt needs to be correct as the script will look for [board]# when
	looking up IP addresses. There are currently three default tests to choose from: UDP test,
	TCP test, and TCP periodic test.
	UDP test:
		Will initate a UDP test between the two boards for [x] duration. This test will
		do 1 second bandwidth checks every second and also track data loss. Logs will be
		kept in log_test1.
	TCP test:
		Will initate a TCP test between the two boards for [x] duration. This test will
		do 1 second bandwidth checks every second using TCP and track the window needed
		to receive the entire packet. Logs will be kept in log_test2.
	TCP periodic test:
		Will initate a TCP test between the two boards for [x] duration. This test will
		do 1 second bandwidth checks every 10 seconds using TCP and track the window
		needed to receive the entire packet. Logs will be kept in log_test3.

##test_iperf [IPclient] [IP server] [PW] [Test#] [Duration]
	This expect script will be run by test_iperf.sh using the arguments given by user input.
	It will SSH into each of the two boards and run the following process:
	Server:
		If iperf server session is not running, or is but log files are not found, it will
		[re]start the iperf server.
	Client:
		Initiate an iperf session using the parameters needed to run the specified test.

get_logs.sh

get_logs
