#!/bin/bash

# fancyupdater.sh - Implementing progress bar dialog in full system
# update and other utilities.
#
# This utility requires root priviledges to work properly.


# CHANGE THIS TO YOUR OWN USERNAME (/home/username)
# But if you're gonna be using this updater through the setup.sh script
# then you can leave this line alone
USR=username

reset

NGALAN="Fancy Updater Utility v.0.1"

function updater() {
	# Take care SELinux if it's active
	TLUPD="SYSTEM UPDATE"
	SEDIR=/etc/selinux
	SEENF=/usr/sbin/getenforce
	TEMP=/home/$USR/.uutf1
	if [[ -d $SEDIR && -f $SEENF ]]; then
		if [ -f $TEMP ]; then
			/bin/rm -f $TEMP &>/dev/null
		fi
		# If there SELinux and enforcing is 1, set it to 0 temporarily
		if [ $(getenforce) == 'Enforcing' ]; then
			touch $TEMP &>/dev/null
			setenforce 0 &>/dev/null
		fi
	fi

	# Unlock repositories if it's locked
	LOCK=/var/lib/apt/lists/lock
	if [ -f $LOCK ]; then
		/bin/rm -f $LOCK &>/dev/null
	fi

	# Update system from standard repositories
	( if apt-get update --fix-missing; then
		for i in $(seq 0 1 100); do
			echo $i
			sleep 1
		done
	fi
	) | dialog --backtitle "$NGALAN" \
		--title "$TLUPD" \
		--gauge "\nUpdating packages from standard repositories. Please wait..." 8 70 0
	clear

	# Check if there's an antivirus program installed
	TLVSC="CHECK ANTI-VIRUS PROGRAM (ClamAV)"
	CLAMAVI=/usr/bin/clamscan
	CLAMAVLOG=/var/log/clamav/freshclam.log
	TODAY=$(date '+%b %d')
	if [ ! -f $CLAMAVI ]; then
		# If there's no antivirus installed let's install one (ClamAV)
		( if apt-get install -y clamav clamav-daemon; then
			for i in $(seq 0 1 100); do
				echo $i
				sleep 1
			done
		fi
		) | dialog --backtitle "$NGALAN" \
			--title "$TLVSC" \
			--gauge "\nAnti-virus not detected. Installing ClamAV..." 8 70 0
		clear
	# Update ClamAV virus database - if needed
	else
		# If freshclam is locked by another process or not updated
		if ! grep "$TODAY" $CLAMAVLOG &>/dev/null; then
			( if freshclam; then
				for i in $(seq 0 1 100); do
					echo $i
					sleep 1
				done
			fi
			) | dialog --backtitle "$NGALAN" \
				--title "$TLVSC" \
				--gauge "\nUpdating ClamAV virus database. Please wait..." 8 70 0
		fi
		clear
	fi

	# Initiate virus scan
	# Prepare quarantine folder for infected files
	TLHDR="SCANNING HOME DIRECTORY"
	VIRUSBIN=/home/$USR/Quarantine-$RANDOM
	if [ -d $VIRUSBIN ]; then
		/bin/rm -fR $VIRUSBIN &>/dev/null
		/bin/mkdir $VIRUSBIN &>/dev/null
	else
		/bin/mkdir $VIRUSBIN &>/dev/null
	fi
	# Start scanning
	( if clamscan -voi --move=$VIRUSBIN /home/$USR/*; then
		for i in $(seq 0 1 100); do
			echo $i
			sleep 1
		done
	fi
	) | dialog --backtitle "$NGALAN" \
		--title "$TLHDR" \
		--gauge "\nPerforming virus scan. This might take a while..." 8 70 0
	clear

	# Set SELinux back into enforced mode - if needed
	if [[ -d $SEDIR && -f $SEENF && -f $TEMP ]]; then
		/bin/rm -f $TEMP &>/dev/null
		setenforce 1 &>/dev/null
	fi

	# Remove outdate packages
	TLCLN="CLEANUP UTILITY"
	( if apt-get autoremove -y; then
		for i in $(seq 0 2 100); do
			echo $i
			sleep 1
		done
	fi
	) | dialog --backtitle "$NGALAN" \
		--title "$TLCLN" \
		--gauge "\nCleaning/removing broken packages. Please wait..." 8 70 0
	clear

	# When everything is said and done :)
	dialog --backtitle "$NGALAN" --title "" \
		--msgbox "\nCongratulations! Your computer is now clean and up to date :)" 7 70
	reset
}

dialog --backtitle "$NGALAN" --title "INTRODUCTION" \
	--yesno "\n$NGALAN will try to:\n\n \
    + Update/Upgrade your system from the Standard Repositories.\n \
    + Update ClamAV and perform a Smart-Scan of your system.\n \
    + Infected files will be moved to a folder called Quarantine-.\n \
    + If no Anti-virus is found, Updater will install ClamAV.\n \
    + Updater will also clean unused/outdated packages from Repo.\n\n \
    Select <Yes> to Continue or <No> (Esc) to Cancel..." \
	15 75

RESPONSE=$?

case $RESPONSE in
	0) updater;;
	1) reset;;
	255) reset;;
esac
exit
