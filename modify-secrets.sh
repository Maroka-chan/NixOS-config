#!/usr/bin/env bash

pushd ~/.dotfiles || exit

SOPS_KEYS_DIR=/var/lib/sops
SECRETS_DIR="$SOPS_KEYS_DIR"/.secrets
SOPS_KEYS="$SOPS_KEYS_DIR"/keys.txt
EDITOR=${EDITOR:-nvim}

[ -d $SECRETS_DIR ] && sudo test ! -f $SOPS_KEYS &&
        echo "Secrets exist, but no key found for decryption." && exit

# Generate age keys if not present
if sudo test ! -f $SOPS_KEYS; then
        sudo mkdir -p $SOPS_KEYS_DIR
        sudo nix-shell -p age --run "age-keygen -o $SOPS_KEYS" ||
                ( echo "Failed to generate age keys"; exit )
fi

PUB_KEY=$(sudo nix-shell -p age --run "age-keygen -y $SOPS_KEYS")

cat >.sops.yaml <<EOL
keys:
        - &${HOSTNAME} ${PUB_KEY}
creation_rules:
        - path_regex: ${SECRETS_DIR}/[^/]+\.yaml\$
          key_groups:
          - age:
                - *${HOSTNAME}
EOL


# Generate secrets directory if not present
[ ! -d $SECRETS_DIR ] && sudo mkdir $SECRETS_DIR


sudo nix-shell -p sops --run "EDITOR=$EDITOR SOPS_AGE_KEY_FILE=$SOPS_KEYS sops ${SECRETS_DIR}/${HOSTNAME}.yaml"

popd || exit
