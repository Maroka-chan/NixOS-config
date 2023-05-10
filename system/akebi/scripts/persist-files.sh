# Persist files
echo "Persisting files"
PERSIST_DIR=/mnt/persist

sudo mkdir -p "$PERSIST_DIR"/etc/ssh

sudo cp {$1,"$PERSIST_DIR"}/etc/ssh/ssh_host_ed25519_key
sudo cp {$1,"$PERSIST_DIR"}/etc/ssh/ssh_host_ed25519_key.pub
sudo cp {$1,"$PERSIST_DIR"}/etc/machine-id