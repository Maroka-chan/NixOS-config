#!/usr/bin/env bash

set -e

menu() { xargs whiptail "$@" 3>&1 1>&2 2>&3 3>&- ; }
get_usbs() { lsblk -ndo NAME,SIZE,RM,TRAN,TYPE --paths --raw | grep " 1 usb disk$" | cut --delimiter " " --fields 1,2 ; }

keyfile="$1"
if [ ! -f "$keyfile" ]; then echo "Specify a keyfile." && exit 1; fi

usb=$(get_usbs | menu --title "Choose USB" --menu "Choose USB" 0 0 0)

sector_size=$(sudo blockdev --getss "$usb") # in bytes
key_size=$(wc -c < "$keyfile") # in bytes

part_sector_size=$(("$key_size" / "$sector_size")) # Size of keyfile partition in sectors
# We align the partition to 1 MiB(1048576 bytes)
# example:
# Sector size = 512
# 1048576 / 512 = 2048 sectors.
start_sector=$((1048576 / "$sector_size"))
end_sector=$(("$start_sector" + "$part_sector_size" - 1))

sudo wipefs --all --force "$usb"

#sudo parted "$usb" mklabel gpt
#sudo parted "$usb" mkpart primary "$start_sector"s "$key_part_size"s
sudo sgdisk --set-alignment="$start_sector" -n 1:"$start_sector":"$end_sector" -c CRYPTKEY "$usb"

