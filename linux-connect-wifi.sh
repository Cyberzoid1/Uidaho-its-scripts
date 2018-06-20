#!/bin/bash

echo "TODO check mac address setting"
echo ""

# --Settings -------------------------------------
# Location of network connection config file
WIFI_CONF_PATH="/etc/NetworkManager/system-connections/AirVandalGold"

# The actual name of the certificate. Once unziped from downloaded .zip file
CERT_NAME="Root-USERTrust.crt"

# The file location where the certificate will be stored.
CERT_DESTINATION="/etc/ssl/certs"
# ------------------------------------------------

AirVandalGold_Conf="""
[connection]
id=AirVandalGold
uuid=2b77c656-1e3b-4432-a4db-0940961bdaaf
type=wifi
permissions=

[wifi]
mac-address=24:77:03:3A:74:10
mac-address-blacklist=
mode=infrastructure
ssid=AirVandalGold

[wifi-security]
key-mgmt=wpa-eap

[802-1x]
ca-cert=$CERT_DESTINATION/$CERT_NAME
eap=peap;
identity=NotSet
password=NotSet
phase2-auth=mschapv2

[ipv4]
dns-search=
method=auto

[ipv6]
addr-gen-mode=stable-privacy
dns-search=
method=auto
"""


# Copied from Root-USERTrust.crt on 5/16/2018
# Download location: https://support.uidaho.edu/TDClient/KB/ArticleDet?ID=230#airvandalgold-certificates-linux
CERTIFICATE="""
-----BEGIN CERTIFICATE-----
MIIF3jCCA8agAwIBAgIQAf1tMPyjylGoG7xkDjUDLTANBgkqhkiG9w0BAQwFADCB
iDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0pl
cnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNV
BAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTAw
MjAxMDAwMDAwWhcNMzgwMTE4MjM1OTU5WjCBiDELMAkGA1UEBhMCVVMxEzARBgNV
BAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVU
aGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2Vy
dGlmaWNhdGlvbiBBdXRob3JpdHkwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIK
AoICAQCAEmUXNg7D2wiz0KxXDXbtzSfTTK1Qg2HiqiBNCS1kCdzOiZ/MPans9s/B
3PHTsdZ7NygRK0faOca8Ohm0X6a9fZ2jY0K2dvKpOyuR+OJv0OwWIJAJPuLodMkY
tJHUYmTbf6MG8YgYapAiPLz+E/CHFHv25B+O1ORRxhFnRghRy4YUVD+8M/5+bJz/
Fp0YvVGONaanZshyZ9shZrHUm3gDwFA66Mzw3LyeTP6vBZY1H1dat//O+T23LLb2
VN3I5xI6Ta5MirdcmrS3ID3KfyI0rn47aGYBROcBTkZTmzNg95S+UzeQc0PzMsNT
79uq/nROacdrjGCT3sTHDN/hMq7MkztReJVni+49Vv4M0GkPGw/zJSZrM233bkf6
c0Plfg6lZrEpfDKEY1WJxA3Bk1QwGROs0303p+tdOmw1XNtB1xLaqUkL39iAigmT
Yo61Zs8liM2EuLE/pDkP2QKe6xJMlXzzawWpXhaDzLhn4ugTncxbgtNMs+1b/97l
c6wjOy0AvzVVdAlJ2ElYGn+SNuZRkg7zJn0cTRe8yexDJtC/QV9AqURE9JnnV4ee
UB9XVKg+/XRjL7FQZQnmWEIuQxpMtPAlR1n6BB6T1CZGSlCBst6+eLf8ZxXhyVeE
Hg9j1uliutZfVS7qXMYoCAQlObgOK6nyTJccBz8NUvXt7y+CDwIDAQABo0IwQDAd
BgNVHQ4EFgQUU3m/WqorSs9UgOHYm8Cd8rIDZsswDgYDVR0PAQH/BAQDAgEGMA8G
A1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQEMBQADggIBAFzUfA3P9wF9QZllDHPF
Up/L+M+ZBn8b2kMVn54CVVeWFPFSPCeHlCjtHzoBN6J2/FNQwISbxmtOuowhT6KO
VWKR82kV2LyI48SqC/3vqOlLVSoGIG1VeCkZ7l8wXEskEVX/JJpuXior7gtNn3/3
ATiUFJVDBwn7YKnuHKsSjKCaXqeYalltiz8I+8jRRa8YFWSQEg9zKC7F4iRO/Fjs
8PRF/iKz6y+O0tlFYQXBl2+odnKPi4w2r78NBc5xjeambx9spnFixdjQg3IM8WcR
iQycE0xyNN+81XHfqnHd4blsjDwSXWXavVcStkNr/+XeTWYRUc+ZruwXtuhxkYze
Sf7dNXGiFSeUHM9h4ya7b6NnJSFd5t0dCy5oGzuCr+yDZ4XUmFF0sbmZgIn/f3gZ
XHlKYC6SQK5MNyosycdiyA5d9zZbyuAlJQG03RoHnHcAP9Dc1ew91Pq7P8yF1m9/
qS3fuQL39ZeatTXaw2ewh0qpKJ4jjv9cJ2vhsE/zB+4ALtRZh8tSQZXq9EfX7mRB
VXyNWQKV3WKdwrnuWih0hKWbt5DHDAff9Yk2dDLWKMGwsAvgnEzDHNb842m1R0aB
L6KCq9NjRHDEjf8tM7qtj3u1cIiuPhnPQCjY/MiQu12ZIvVS5ljFH4gxQ+6IHdfG
jjxDah2nGN59PRbxYvnKkKj9
-----END CERTIFICATE-----
"""

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
  
  # Replace credentials in AirVandalGold_Conf variable
  AirVandalGold_Conf="$(echo "$AirVandalGold_Conf" | sed -e "s/identity=NotSet/identity=$UI_USER/g")"
  AirVandalGold_Conf="$(echo "$AirVandalGold_Conf" | sed -e "s/password=NotSet/password=$UI_PASS/g")"
}


# This function copies the network configuration file and restarts the Network Manager service to apply
f_WriteWiFiConfig()
{
  echo "Writing configuration file to $WIFI_CONF_PATH"
  
  # Remove old configureation file first
  if [ -e $WIFI_CONF_PATH ]; then
    sudo rm $WIFI_CONF_PATH
  fi
  
  # Write the config file
  sudo echo "$AirVandalGold_Conf" > $WIFI_CONF_PATH

  # Restrict the setup file to be readable by only root
  if [ -e $WIFI_CONF_PATH ]; then
    sudo chown root:root $WIFI_CONF_PATH 
    sudo chmod 600 $WIFI_CONF_PATH          # read/write for owner only
  else
    echo "$WIFI_CONF_PATH not found. possible error occured in script"
  fi

  # restart network manager
  echo "Restarting Network Manager"
  sudo systemctl restart NetworkManager
}


# This function test and asks to remove AirVandalGuest from system.
f_removeAVGuest()
{
  AirVandalGuest_CONF_PATH="/etc/NetworkManager/system-connections/AirVandalGuest"
  
  # Test if it exists
  if [ -e $AirVandalGuest_CONF_PATH ]; then
    echo -e "\nAirVandalGuest network configuration was found."
    echo "We recommend removing this network from your system as AirVandalGuest is slower and some UI sites are not accessable on this network."
    read -r -p "Would you like to remove this network? [y/N] " response
    if [[ ("$response" =~ ^([yY][eE][sS]|[yY])+$) ]]
    then
       sudo rm -v $AirVandalGuest_CONF_PATH     # Remove if yes
    else
      echo "   Keeping AirVandalGuest"          # Keep
    fi
  fi
}

# This function test and removes AirVandalGold from system.
f_removeAVGold()
{
  AirVandalGuest_CONF_PATH="/etc/NetworkManager/system-connections/AirVandalGuest"
  
  # Test if it exists
  if [ -e $AirVandalGuest_CONF_PATH ]; then
    echo -e "\nAirVandalGold network configuration was found - Removing."
    sudo rm -v $WIFI_CONF_PATH
  else
    echo -e "\nAirVandalGold not found"
  fi
}


# Main

f_rootcheck
f_get_ui_credentials
sudo echo "$CERTIFICATE" > $CERT_DESTINATION/$CERT_NAME
f_WriteWiFiConfig
f_removeAVGuest
echo done
