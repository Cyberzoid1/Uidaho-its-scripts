#!/bin/bash

# Instructions
# Download and save this file
# Open terminal and navigate to saved location.
# If this file is not executable run 'chmod +x linux-add-drives.sh'
# Run file with './linux-add-drives.sh'
# For password update run './linux-add-drives.sh -p'

# get local username
LUSER=${SUDO_USER:-$USER}

# Configuration
VERSION="0.1.1"
LAST_UPDATED="5/09/2018"
CREDENTIAL_FILE="/home/$LUSER/.ui-smbcredentials"
MOUNT_DIR_U="/mnt/udrive"
MOUNT_DIR_S="/mnt/sdrive"
ADDR_S="files.uidaho.edu/shared"
# the function f_get_ui_credentials updates the username for this address
ADDR_U="# udrive address not set"

f_Banner()
{
  # Banner creator: http://patorjk.com/software/taag/#p=display&f=Doom&t=UIdaho
  # will need to find replace all ` with \`
  echo "
   _   _ _____    _       _
  | | | |_   _|  | |     | |
  | | | | | |  __| | __ _| |__   ___
  | | | | | | / _\` |/ _\` | '_  \ / _ \\
  | |_| |_| || (_| | (_| | | | | (_) |
   \___/ \___/\__,_|\__,_|_| |_|\___/
  "
  echo "
  This script will mount the shared drive and userdrive to the user's computer

  This script will preform the following opperations:
  * Ask for root. (required for most operations)
  * Ask user for information
  * Create a credential file at /home/$USER/.ui-smbcredentials for storing your ui username and password
  * Create directories: /mnt/udrive /mnt/sdrive for mount points
  * Change permissions on credential file to be only viewable by root for added security
  * Install cifs_utils. (required for mounting drives)
  * Add a configuration line in /etc/fstab for mounting the drives"

  # Instructions
  echo "These drives will only auto connect at startup and only when connected to AirVandalGold or Ethernet

  To mount, run the command 'sudo mount -a'
  To mount individually, run 'sudo mount $MOUNT_DIR_S'
  To unmount a drive, run 'sudo umount $MOUNT_DIR_U'
  To update your password, run script with -p flag. '$0 -p'"

  read -r -p "Do you want to continue? [y/N] " response
  if [[ !("$response" =~ ^([yY][eE][sS]|[yY])+$) ]]
  then
     echo "Exiting"
     exit
  fi
}

# checks for root. Re-start script with root privliges
f_rootcheck()
{
  # check for root
  if [ $(id -u) != 0 ]; then
      echo "Need root"
      args="$@ --nobanner"   # append no banner flag to args
      sudo sh -c "$0 $args"  # call script again with root
      exit
  fi

  # double check before continuing
  if [ $(id -u) != 0 ]; then
      echo "You are NOT root"
      exit
  fi
}

f_get_ui_credentials()
{
  # Get UI credentials from user
  echo -e "\nUniversity of Idaho credentials"
  echo "What is your UI Username? (vand1234 or jvandal)"
  read -p "Username: " UI_USER
  echo "What is your UI Password? (characters will be invisible, hold backspace to clear)"
  read -s -p "Password: " UI_PASS
  echo -e "\n"
  # Update udrive address
  ADDR_U="users.uidaho.edu/users/$(echo "$UI_USER" | head -c 1)/$UI_USER"
}

# Only update password
f_update_password()
{
  echo -e "\nUpdate Password"
  sudo umount $MOUNT_DIR_U  # unmount drives for new password
  sudo umount $MOUNT_DIR_S
  echo "What is your current UI Password? (characters will be invisible, hold backspace to clear)"
  read -s -p "Password: " UI_PASS
  # Delete password line in the credential file
  sed -i '/password/D' $CREDENTIAL_FILE
  # Insert new password into credential file
  sudo echo -e "password=$UI_PASS" >> $CREDENTIAL_FILE
  f_mount_drives
  f_show_files
  echo "If this failed to mount, run the script @0 without the password flag"
}

# Create and write UI credentials to a file
f_create_credential_file()
{
  echo -e "\nCreating credential file at $CREDENTIAL_FILE"
  # remove credential file if it exists
  if [ -e $CREDENTIAL_FILE ]; then
    sudo rm -f $CREDENTIAL_FILE
  fi
  # create credential file
  touch $CREDENTIAL_FILE
  # change owner to root
  sudo chown root:root $CREDENTIAL_FILE
  # change permissions so no one except root can read the file
  sudo chmod 400 $CREDENTIAL_FILE
  # Insert credentials into file
  sudo echo -e "username=$UI_USER\npassword=$UI_PASS" >> $CREDENTIAL_FILE
}

# Create mount points if they dont exist
f_create_mountpoints()
{
  echo -e "\nCreating mount points"
  if [ ! -d "$MOUNT_DIR_U" ]; then
    echo "Creating mount point $MOUNT_DIR_U"
    sudo mkdir -p $MOUNT_DIR_U
  else
    echo "$MOUNT_DIR_U already exists"
  fi
  if [ ! -d "$MOUNT_DIR_S" ]; then
    echo "Creating mount point $MOUNT_DIR_S"
    sudo mkdir -p $MOUNT_DIR_S
  else
    echo "$MOUNT_DIR_S already exists"
  fi
}

# Install system dependencies
f_install_cifs()
{
  echo -e "\n"
  /usr/bin/dpkg-query --show --showformat='${db:Status-Status}\n' 'cifs-utils' | grep -q 'installed'
  if [ $? == 0 ]; then
    echo "Dependancy: cifs-utils installed"
  else
    echo "Dependancy: cifs-utils not installed. Installing now"
	sudo apt-get update -q
    sudo apt-get install -y cifs-utils
	
	# Check if successfull
    /usr/bin/dpkg-query --show --showformat='${db:Status-Status}\n' 'cifs-utils' | grep -q 'installed'
    if [ $? == 0 ]; then
      echo "cifs-utils installation complete"
	else
      echo "cifs-utils failed to install. Please try to install cifs-utils manually"
	  sleep 2
    fi
  fi
}

# Creates and updates system configurations for mounting the drives
f_update_mountcode()
{
  echo -e "\nCreating mount entry in /etc/fstab"
  MOUNTCODE_U="//$ADDR_U $MOUNT_DIR_U cifs vers=3.0,credentials=$CREDENTIAL_FILE,uid=$LUSER,gid=$LUSER 0 0"
  MOUNTCODE_S="//$ADDR_S $MOUNT_DIR_S cifs vers=3.0,credentials=$CREDENTIAL_FILE,uid=$LUSER,gid=$LUSER 0 0"
  echo "Mountcode U: $MOUNTCODE_U"
  echo "Mountcode S: $MOUNTCODE_S"

  # find the line that matches /mnt/sdrive then delete line
  sed -i '/\/mnt\/udrive/D' /etc/fstab
  sed -i '/\/mnt\/sdrive/D' /etc/fstab

  # Add mountcode to fstab if substring is not found
  grep -q -F "$MOUNT_DIR_U" /etc/fstab || echo "$MOUNTCODE_U" >> /etc/fstab
  grep -q -F "$MOUNT_DIR_S" /etc/fstab || echo "$MOUNTCODE_S" >> /etc/fstab
}

# Executes the mount command
f_mount_drives()
{
  echo -e "\nMounting the drives with the command \"sudo mount -a\""
  sudo mount -a     # mount the ramdisk
}

# Displays files in the shared and udrive
f_show_files()
{
  echo -e "\n---------------------------------------"
  echo -e "These are the first 10 files in your udrive"
  ls $MOUNT_DIR_U | head -n 10
  echo -e "\nThese are the first 10 files in your sdrive"
  ls $MOUNT_DIR_S | head -n 10
}

f_uninstall()
{
  echo -e "\nRemoving shared drives and credential file"
  # unmount drives
  sudo umount $MOUNT_DIR_U
  sudo umount $MOUNT_DIR_S

  # remove credential file if it exists
  if [ -e $CREDENTIAL_FILE ]; then
    sudo rm -f $CREDENTIAL_FILE
  fi

  #remove mount points
  rmdir $MOUNT_DIR_U
  rmdir $MOUNT_DIR_S

  # remove fstab entries
  # find the line that matches /mnt/sdrive then delete line
  sed -i '/\/mnt\/udrive/D' /etc/fstab
  sed -i '/\/mnt\/sdrive/D' /etc/fstab
}

f_helpInfo()
{
  echo "Usage: $0 [options]"
  echo "     --nobanner		Hides banner text"
  echo "-h   --help		Shows this help dialogue"
  echo "-ls  --list-files	Show files in mountpoints for testing"
  echo "-p   --password		Update password only"
  echo "-U   --uninstall	Uninstalls the shared drives and configurations"
  echo "-v   --version		Shows version info"
  echo -e "\n"

  # Instructions
  echo "To mount, run the command 'sudo mount -a'
To mount individually, run 'sudo mount $MOUNT_DIR_S'
To unmount a drive, run 'sudo umount $MOUNT_DIR_U'
To update your password, run script with -p flag. '$0 -p'"
}


case $1 in
  -h|--help|help)
    #f_Banner
    f_helpInfo
    ;;
  -ls|--list-files)
    f_show_files
    ;;
  -p|--password)
    f_rootcheck $@
    f_update_password
    ;;
  -v|--version|version)
    echo "Version: $VERSION. Last updated on $LAST_UPDATED"
    ;;
  -U|uninstall|--uninstall|remove|--remove)
    f_rootcheck $@
    f_uninstall
    ;;

  ""|"--nobanner") # normal call
    # function calls
    if [[ $@ !=  *'--nobanner'* ]]; then
      f_Banner $@
    fi
    f_rootcheck $@
    f_get_ui_credentials
    f_create_credential_file
    f_install_cifs
    f_create_mountpoints
    f_update_mountcode
    f_mount_drives
    f_show_files
    ;;

  *)
    echo "Unrecognized argument"
    f_helpInfo
    ;;
esac
