#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

# set -x

# ansible-playbook components/create-ordering-service-components.yml
# ansible-playbook components/create-manufacturer-components.yml
# ansible-playbook components/create-insurer-components.yml
# ansible-playbook components/create-regulator-components.yml

# set +x

for file in $(find components -name '*.json'); do
    # TODO MOVE TO OUTPUT FOLDER AND RENAME IN FORMAT output/{ORG}/Admin.json or CA Admin.json
    echo $file
done

# TODO MOVE OUTPUTTED FILES TO THE OUTPUT FOLDER

# set -x

# ansible-playbook consortium/add-manufacturer-to-consortium.yml
# ansible-playbook consortium/add-insurer-to-consortium.yml
# ansible-playbook consortium/add-regulator-to-consortium.yml