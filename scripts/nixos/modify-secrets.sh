#!/usr/bin/env bash

pushd ~/.dotfiles &>/dev/null || exit 1

SECRETS_DIR=system/"$HOSTNAME"/.secrets
SOPS_KEYS=/var/lib/sops/keys.txt
EDITOR=${EDITOR:-nvim}
SECRETS_FILE=${SECRETS_DIR}/${HOSTNAME}.yaml

./scripts/nixos/generate-age-keys.sh
./scripts/nixos/create-secrets-file.sh

pushd "$SECRETS_DIR" &>/dev/null || exit 1
SECRETS_FILES=(*)
popd &>/dev/null || exit 1

# write if more than one secrets file
if (( "${#SECRETS_FILES[@]}" > 1 )); then
        for ((i = 0; i < "${#SECRETS_FILES[@]}"; ++i)); do
                echo "$i: ${SECRETS_FILES[i]}"
        done

        read -rp "Choose a secrets file to modify: " chosen_file
fi

sudo nix-shell -p sops --run "EDITOR=$EDITOR SOPS_AGE_KEY_FILE=$SOPS_KEYS sops ${SECRETS_DIR}/${SECRETS_FILES[${chosen_file:-0}]}"

popd &>/dev/null || exit 1