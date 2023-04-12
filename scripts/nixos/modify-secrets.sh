#!/usr/bin/env bash

pushd "$(dirname -- "${BASH_SOURCE[0]}")"/../../ &>/dev/null || exit 1

SOPS_DIR=/persist/var/lib/sops
SECRETS_DIR="$SOPS_DIR"/.secrets
SOPS_KEYS="$SOPS_DIR"/keys.txt
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