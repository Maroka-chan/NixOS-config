#!/usr/bin/env bash

PERSIST_DIR=/persist

sudo mkdir -p ${PERSIST_DIR}/etc/ssh

sudo cp {,$PERSIST_DIR}/etc/ssh/ssh_host_ed25519_key
sudo cp {,$PERSIST_DIR}/etc/ssh/ssh_host_ed25519_key.pub
sudo cp {,$PERSIST_DIR}/etc/NIXOS
sudo cp {,$PERSIST_DIR}/etc/machine-id