#!/usr/bin/env bash

pushd "$(dirname -- "${BASH_SOURCE[0]}")"/../../ &>/dev/null || exit 1

sudo nixos-rebuild switch --flake ./system/"$HOSTNAME"

popd &>/dev/null || exit 1
