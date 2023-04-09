#!/usr/bin/env bash

pushd "$(dirname -- "${BASH_SOURCE[0]}")"/../../ &>/dev/null || exit 1

SOPS_KEYS_DIR=/persist/var/lib/sops
SECRETS_DIR=system/"$HOSTNAME"/.secrets
SOPS_KEYS="$SOPS_KEYS_DIR"/keys.txt

[ -d $SECRETS_DIR ] && sudo test ! -f $SOPS_KEYS &&
        echo "Secrets exist, but no key found for decryption." && exit

# Generate age keys if not present
if sudo test ! -f $SOPS_KEYS; then
        sudo mkdir -p $SOPS_KEYS_DIR
        sudo nix-shell -p age --run "age-keygen -o $SOPS_KEYS" ||
                ( echo "Failed to generate age keys"; exit )
fi

# Generate secrets directory if not present
[ ! -d $SECRETS_DIR ] && sudo mkdir $SECRETS_DIR

popd &>/dev/null || exit 1