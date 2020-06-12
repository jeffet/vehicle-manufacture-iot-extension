#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

set -x

ansible-playbook chaincode/install-chaincode-manufacturer.yml
ansible-playbook chaincode/install-chaincode-insurer.yml
ansible-playbook chaincode/install-chaincode-regulator.yml
ansible-playbook chaincode/instantiate-chaincode.yml