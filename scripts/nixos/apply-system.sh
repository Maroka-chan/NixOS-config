#!/usr/bin/env bash

pushd ~/.dotfiles &>/dev/null || exit

sudo nixos-rebuild switch --flake ./system/"$HOSTNAME"

popd &>/dev/null || exit
