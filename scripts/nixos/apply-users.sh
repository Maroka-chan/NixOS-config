#!/usr/bin/env bash

pushd ~/.dotfiles &>/dev/null || exit
home-manager switch -f ./users/maroka/home.nix
popd &>/dev/null || exit
