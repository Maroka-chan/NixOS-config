#!/usr/bin/env bash

pushd ../../ &>/dev/null || exit 1

sudo nixos-rebuild switch --flake ./system/"$HOSTNAME"

popd &>/dev/null || exit 1
