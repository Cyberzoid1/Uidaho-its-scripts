#!/bin/bash

# Instructions
# Download and save this file
# Open terminal and navigate to saved location. 
# If this file is not executable run 'chmod +x linux-add-drives.sh'
# Run file with './linux-add-drives.sh'


# check for root
if [ $(id -u) != 0 ]; then
    echo "Need root"
    sudo sh -c $0
    exit
fi

# double check before continuing
if [ $(id -u) != 0 ]; then
    echo "You are NOT root"
    exit
fi

# get local username
LUSER=${SUDO_USER:-$USER}
echo "Local User: $LUSER"

# Configuration
CREDENTIAL_FILE="/home/$LUSER/.ui-smbcredentials"
MOUNT_DIR_U="/mnt/udrive"
MOUNT_DIR_S="/mnt/sdrive"
ADDR_S="files.uidaho.edu/shared"
# the function f_get_ui_credentials updates the username for this address
ADDR_U="# udrive address not set"

f_Banner()
{
  # Banner creator: http://patorjk.com/software/taag/#p=display&f=Doom&t=UIdaho
  # find replace all ` with \`
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
  * Ask for root. (required for some operations)
  * Ask user for information
  * Create a credential file at /home/$USER/.ui-smbcredentials for storing your ui username and password
  * Create directories: /mnt/udrive /mnt/sdrive for mount points
  * Change permissions on that file to be only viewable by root for security
  * Install cifs_utils. (required for mounting window's shares)
  * Add a configuration line in /etc/fstab for mounting the drives"

  # instructions
  echo "These drives will only auto connect at startup and only when connected to AirVandalGold or ethernet"
  echo "To mount, run the command 'sudo mount -a'
  To mount individually, run 'sudo mount $MOUNT_DIR_S'
  To unmount a drive, run 'sudo umount $MOUNT_DIR_U'"
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
  # update udrive address
  ADDR_U="users.uidaho.edu/users/$(echo "$UI_USER" | head -c 1)/$UI_USER"
}



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
  # change permissions so no one except root can view file
  sudo chmod 400 $CREDENTIAL_FILE
  # Insert credentials into file
  sudo echo -e "username=$UI_USER\npassword=$UI_PASS" >> $CREDENTIAL_FILE
}


# create mount points if they dont exist
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

# Installs system dependencies
f_install_cifs()
{
  echo -e "\nInstalling cifs-utils"
  sudo apt-get update -q
  sudo apt-get install cifs-utils # || echo -e "\nInstalling cifs-utils failed. Please try manually installing cifs-utils"; exit
  echo "cifs-utils installation complete"
}

# Creates and updates system configurations for mounting the drives
f_update_mountcode()
{
  echo -e "\nCreating mount entry in /etc/fstab"
  MOUNTCODE_U="//$ADDR_U $MOUNT_DIR_U cifs credentials=$CREDENTIAL_FILE,uid=$LUSER,gid=$LUSER 0 0"
  MOUNTCODE_S="//$ADDR_S $MOUNT_DIR_S cifs credentials=$CREDENTIAL_FILE,uid=$LUSER,gid=$LUSER 0 0"
  echo "Mountcode U: $MOUNTCODE_U"
  echo "Mountcode S: $MOUNTCODE_S"

  # find the line that matches /mnt/sdrive then delete line
  sed -i '/\/mnt\/udrive/D' /etc/fstab
  sed -i '/\/mnt\/sdrive/D' /etc/fstab

  # Add mountcode to fstab if substring is not found
  grep -F "$MOUNT_DIR_U" /etc/fstab || echo "$MOUNTCODE_U" >> /etc/fstab
  grep -q -F "$MOUNT_DIR_S" /etc/fstab || echo "$MOUNTCODE_S" >> /etc/fstab
}

# executes the mount command
f_mount_drives()
{
  echo -e "\nMounting the drives with the command \"sudo mount -a\""
  sudo mount -a     # mount the ramdisk
}

# Displays files in the shared and udrive
f_show_files()
{
  echo -e "\n---------------------------------------"
  echo -e "These are the files in your udrive"
  ls $MOUNT_DIR_U
  echo -e "\nThese are the files in your sdrive"
  ls $MOUNT_DIR_S
}


# function calls
f_Banner
f_get_ui_credentials
f_create_credential_file
f_install_cifs
f_create_mountpoints
f_update_mountcode
f_mount_drives
f_show_files
