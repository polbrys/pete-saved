# !/bin/bash
# pull_nagios_confs.sh
# This script pulls the Apperian defined Nagios configuration files
#	from Subversion, and places them in the correct location on the host.
#   It then changes the permissions of the files accordingly.
# Author: polbrys
# Date: 02/12/2014
#

# Variables:
NAGIOS_DIR=/etc/nagios
COMMON_DIR=/etc/nagios/apperian
LOOP_SWITCH=0

# Verify Script Run as Root
if [ "$(id -u)" != "0" ]; then
	echo "Please re-run script as root"
	exit 1
fi

echo "NOTE: HOST SPECIFIC DIRECTORY AND FILES MUST BE CREATED IN SUBVERSION BEFORE RUNNING THIS SCRIPT"

# Read input from user in loop, exit loop when name is confirmed
while [ $LOOP_SWITCH == 0 ]; do

	# Set conditional statement to NO by default
	LOOP_ANSWER="n"
	
	echo "WARNING: This script will overwrite old config files."
	echo "Enter nagios HOST_INPUT without .apperian.com: "
	read HOST_INPUT
	echo "$HOST_INPUT"
	
	# Set HOST_INPUT_IN to lowercase
	declare -l HOST_INPUT
	HOST_INPUT=$HOST_INPUT
	echo "$HOST_INPUT converted to lowercase"
	
	echo "Entry: $HOST_INPUT - Is this correct y/n/exit?:"
	read LOOP_ANSWER

	# Check if answer is exit
	if [ "${LOOP_ANSWER,,}" == "exit" ]; then
		echo "Exiting script"
		exit 1
	fi
	
	#Verify answer is OK
	if [ "${LOOP_ANSWER,,}" == "y" ]; then
	
		#Check if nagios is installed on the host
		if [ ! -d "/etc/nagios" ]; then
			echo "Nagios not installed on $HOST_INPUT"
			exit 1
		fi
		
		echo "Adding common and $HOST_INPUT specific nagios configuration files to /etc/nagios/"
		 LOOP_SWITCH=1
	fi
done


# Check if /etc/nagios/apperian exists
	if [ ! -d "/etc/nagios/apperian" ]; then
		echo "This is the first time nagios has been configured on this host, adding $COMMON_DIR directory"
		mkdir $COMMON_DIR
		chown nagios:nagios $COMMON_DIR
	fi


# Pull common_XXX.cfg files from configs directory and set permissions

echo "Pulling common_cmds.cfg and changing permissions"
svn export --force <insert svn repo address here>
chown nagios:nagios /etc/nagios/apperian/common_cmds.cfg
echo "done"

echo "Pulling common_contacts.cfg and changing permissions"
svn export --force <insert svn repo address here>
chown nagios:nagios /etc/nagios/apperian/common_contacts.cfg
echo "done"

echo "Pulling common_templates.cfg and changing permissions"
svn export --force <insert svn repo address here>
chown nagios:nagios /etc/nagios/apperian/common_templates.cfg
echo "done"

echo "Pulling common_time.cfg and changing permissions"
svn export --force <insert svn repo address here>
chown nagios:nagios /etc/nagios/apperian/common_time.cfg
echo "done"


# Pull nagios.cfg and nrpe.cfg and set permissions

echo "Pulling the Apperian nagios.cfg and changing permissions"
svn export --force <insert svn repo address here>
chown nagios:nagios /etc/nagios/nagios.cfg
echo "done"

echo "Pulling the Apperian nrpe.cfg and changing permissions"
svn export --force <insert svn repo address here>
chown nagios:nagios /etc/nagios/nrpe.cfg
echo "done"


# Pull host specific configs from configs/HOST_INPUT directory

echo "Pulling the $HOST_INPUT specific config and changing permissions"
svn export --force <insert svn repo address here>
chown nagios:nagios /etc/nagios/apperian/$HOST_INPUT.cfg
echo "done"

echo "Pulling the $HOST_INPUT specific resource.cfg file and changing permissions"
svn export --force <insert svn repo address here>
chown nagios:nagios /etc/nagios/resource.cfg
echo "done"

exit 1
