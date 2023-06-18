set -euo pipefail

mkdir -p /mnt
mount -t btrfs ${cfg.root} /mnt

OLD_TRANSID=$(sudo btrfs subvolume find-new /mnt/${cfg.blank-root-subvol} 9999999)
OLD_TRANSID=${OLD_TRANSID#transid marker was }

sudo btrfs subvolume find-new "/mnt/${cfg.root-subvol}" "$OLD_TRANSID" |
sed '$d' |
cut -f17- -d' ' |
sort |
uniq |
while read path; do
path="/$path"
if [ -L "$path" ]; then
    : # The path is a symbolic link, so is probably handled by NixOS already
elif [ -d "$path" ]; then
    : # The path is a directory, ignore
else
    echo "$path"
fi
done

umount /mnt