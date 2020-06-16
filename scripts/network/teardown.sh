#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

set -x

ansible-playbook teardown/teardown-manufacturer.yml
ansible-playbook teardown/teardown-insurer.yml
ansible-playbook teardown/teardown-regulator.yml
ansible-playbook teardown/teardown-ordering-service.yml

rm -r output/*