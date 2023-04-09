#!/usr/bin/env bash

pushd "$(dirname -- "${BASH_SOURCE[0]}")"/../../ &>/dev/null || exit 1

home-manager switch -f ./users/maroka/home.nix

popd &>/dev/null || exit 1
