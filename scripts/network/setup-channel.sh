#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

set -x

ansible-playbook channel/create-channel.yml

ansible-playbook channel/join-regulator-peer-to-channel.yml
ansible-playbook channel/add-regulator-anchor-peer-to-channel.yml

ansible-playbook channel/join-manufacturer-peer-to-channel.yml
ansible-playbook channel/add-manufacturer-anchor-peer-to-channel.yml

ansible-playbook channel/join-insurer-peer-to-channel.yml
ansible-playbook channel/add-insurer-anchor-peer-to-channel.yml