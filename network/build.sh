#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

set -x

ansible-playbook components/create-ordering-service-components.yml
ansible-playbook components/create-manufacturer-components.yml
ansible-playbook components/create-insurer-components.yml
ansible-playbook components/create-regulator-components.yml

set +x

find components -name '*.json' -print0 | while IFS= read -r -d '' file; do
    OUTPUT_FILE="Admin.json"

    ORG=$(echo "$file" | sed 's/components\/\(.*\)\ Admin.json/\1/')

    if echo "$file" | grep 'CA'; then
        OUTPUT_FILE="CA Admin.json"
        ORG=$(echo "$ORG" | sed 's/\(.*\)\ CA/\1/')
    fi

    mkdir -p "output/$ORG"
    mv "$file" "output/$ORG/$OUTPUT_FILE"
done

set -x

ansible-playbook consortium/add-manufacturer-to-consortium.yml
ansible-playbook consortium/add-insurer-to-consortium.yml
ansible-playbook consortium/add-regulator-to-consortium.yml