#!/usr/bin/env bash

pushd ~/.dotfiles || exit

sudo nixos-rebuild switch -I nixos-config=./system/"$HOSTNAME"/configuration.nix

popd || exit
