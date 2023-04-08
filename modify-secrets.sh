#!/usr/bin/env bash

SOPS_KEYS_DIR=/persist/var/lib/sops
SECRETS_DIR="$SOPS_KEYS_DIR"/.secrets
SOPS_KEYS="$SOPS_KEYS_DIR"/keys.txt
EDITOR=${EDITOR:-nvim}
DEFAULT_SECRETS_FILE=${SECRETS_DIR}/${HOSTNAME}.yaml

./generate-age-keys.sh

[ ! -f "$DEFAULT_SECRETS_FILE" ] &&
        echo "example: value" | sudo tee "$DEFAULT_SECRETS_FILE" &>/dev/null &&
        sudo nix-shell -p sops --run "SOPS_AGE_KEY_FILE=$SOPS_KEYS sops -e -i ${DEFAULT_SECRETS_FILE}"

pushd "$SECRETS_DIR" &>/dev/null || exit 1
SECRETS_FILES=(*)
popd &>/dev/null || exit 1

for ((i = 0; i < "${#SECRETS_FILES[@]}"; ++i)); do
        echo "$i: ${SECRETS_FILES[i]}"
done

read -rp "Choose a secrets file to modify: " chosen_file

sudo nix-shell -p sops --run "EDITOR=$EDITOR SOPS_AGE_KEY_FILE=$SOPS_KEYS sops ${SECRETS_DIR}/${SECRETS_FILES[chosen_file]}"
