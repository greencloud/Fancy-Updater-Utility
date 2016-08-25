#!/bin/bash

# install.sh - Install Fancy Updater Utility in the home directory

clear
TRIGGER=sysupdate
APPNAME="Fancy-Updater-Utility"
BASHRC=/home/$USER/.bashrc
UTILITY=/home/$USER/$APPNAME/utility-v.0.1.sh
ACTIVE=/home/$USER/.utility-v.0.1.sh

if [ -f $UTILITY ]; then
	# Make updater hidden and executable
	( if cp $UTILITY $ACTIVE &>/dev/null; then
		for i in $(seq 0 2 100); do
			echo $i
			sleep 1
		done
	fi
	) | dialog --backtitle "Fancy Updater Utility Installation" \
		--title "FANCY UPDATER UTILITY" \
		--gauge "\nInstalling script. Please wait..." 8 70 0

	if [ -f $BASHRC ]; then
		# Append an alias for the updater in the .bashrc file
		echo "alias $TRIGGER='sudo ./.ub_updater.sh'" >> $BASHRC
	else
		touch $BASHRC
		echo "alias $TRIGGER='sudo ./.ub_updater.sh'" >> $BASHRC
	fi

	# Configure active installation
	sed -i '12s/.*/USR='$USER'/' $ACTIVE

	# Make sure our utility is executable
	chmod +x $ACTIVE &>/dev/null

	# Confirmation dialogue box
	dialog --backtitle "Fancy Updater Utility Installation" \
		--title "FANCY UPDATER UTILITY" \
		--msgbox "\nCongratulations. You have successfully installed Fancy Updater\n \
			Utility on this computer. To use this utility, simply open\n \
			another terminal and type in:\n\n \
			$ sysupdate\n\n \
			This utility will take care all the updating for your." 13 70
else
	dialog --backtitle "FANCY UPDATER UTILITY" --title "" \
		--msgbox "\nOoops, unable to locate utility script." 7 70
	reset
fi
