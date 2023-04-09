#!/usr/bin/env bash

pushd "$(dirname -- "${BASH_SOURCE[0]}")"/../../ &>/dev/null || exit 1

SECRETS_DIR=system/"$HOSTNAME"/.secrets
SOPS_KEYS=/persist/var/lib/sops/keys.txt
SECRETS_FILE=${SECRETS_DIR}/${HOSTNAME}.yaml

[ ! -f "$SECRETS_FILE" ] &&
        echo "example: value" | sudo tee "$SECRETS_FILE" &>/dev/null &&
        sudo nix-shell -p sops --run "SOPS_AGE_KEY_FILE=$SOPS_KEYS sops -e -i ${SECRETS_FILE}"

popd &>/dev/null || exit 1