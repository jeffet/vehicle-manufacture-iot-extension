#!/bin/bash

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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