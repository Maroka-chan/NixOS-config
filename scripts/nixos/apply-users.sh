#!/usr/bin/env bash

pushd ../../ &>/dev/null || exit 1

home-manager switch -f ./users/maroka/home.nix

popd &>/dev/null || exit 1
