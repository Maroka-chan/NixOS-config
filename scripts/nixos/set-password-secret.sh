#!/usr/bin/env bash

pushd "$(dirname -- "${BASH_SOURCE[0]}")"/../../ &>/dev/null || exit 1

SECRETS_DIR=system/"$HOSTNAME"/.secrets
SOPS_KEYS=/var/lib/sops/keys.txt
EDITOR=${EDITOR:-nvim}
SECRETS_FILE=${SECRETS_DIR}/${HOSTNAME}.yaml

./scripts/nixos/generate-age-keys.sh
./scripts/nixos/create-secrets-file.sh

read -rp "Username: " USERNAME
read -srp "Password: " PASSWORD
PASSWORD=$(sudo mkpasswd -m sha-512 "$PASSWORD")

[ ! -f "$SECRETS_FILE" ] && sudo touch "$SECRETS_FILE"
sudo nix-shell -p sops --run "SOPS_AGE_KEY_FILE=$SOPS_KEYS sops -d -i $SECRETS_FILE"
sudo nix-shell -p yq-go --run "yq -i '.${USERNAME}-password = \"$PASSWORD\"' $SECRETS_FILE"
sudo nix-shell -p sops --run "SOPS_AGE_KEY_FILE=$SOPS_KEYS sops -e -i $SECRETS_FILE"

popd &>/dev/null || exit 1