#!/usr/bin/env bash

PERSIST_DIR=/persist

sudo mkdir -p ${PERSIST_DIR}/etc/ssh
sudo mkdir -p ${PERSIST_DIR}/var/lib

sudo cp -r {,/persist}/var/lib/sops
sudo cp {,$PERSIST_DIR}/etc/ssh/ssh_host_ed25519_key
sudo cp {,$PERSIST_DIR}/etc/ssh/ssh_host_ed25519_key.pub
sudo cp {,$PERSIST_DIR}/etc/NIXOS
sudo cp {,$PERSIST_DIR}/etc/machine-id