#!/usr/bin/env bash

pushd "$(dirname -- "${BASH_SOURCE[0]}")"/../../ &>/dev/null || exit 1

SOPS_DIR=/persist/var/lib/sops
SECRETS_DIR="$SOPS_DIR"/.secrets
SOPS_KEYS="$SOPS_DIR"/keys.txt
SECRETS_FILE=${SECRETS_DIR}/${HOSTNAME}.yaml
PUB_KEY=$(sudo nix-shell -p age --run "age-keygen -y $SOPS_KEYS")

[ ! -f "$SECRETS_FILE" ] &&
        echo "example: value" | sudo tee "$SECRETS_FILE" &>/dev/null &&
        sudo nix-shell -p sops --run "sops --age $PUB_KEY -e -i $SECRETS_FILE"

popd &>/dev/null || exit 1