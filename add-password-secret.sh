#!/usr/bin/env bash

SOPS_KEYS_DIR=/persist/var/lib/sops
SECRETS_DIR="$SOPS_KEYS_DIR"/.secrets
SOPS_KEYS="$SOPS_KEYS_DIR"/keys.txt
EDITOR=${EDITOR:-nvim}
SECRETS_FILE=${SECRETS_DIR}/${HOSTNAME}_passwords.yaml

./generate-age-keys.sh

USERNAME=$(read -rp "Username: ")
PASSWORD=$(sudo mkpasswd -m sha-512 "$(read -srp "Password: ")")

[ ! -f "$SECRETS_FILE" ] && sudo touch "$SECRETS_FILE"
sudo nix-shell -p yq-go --run "yq -i '.$USERNAME = \"$PASSWORD\"' $SECRETS_FILE"

sudo nix-shell -p sops --run "SOPS_AGE_KEY_FILE=$SOPS_KEYS sops -ei $SECRETS_FILE"
