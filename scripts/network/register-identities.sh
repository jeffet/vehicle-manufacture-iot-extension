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

# set -x

mkdir -p "output/Arium/Connection Profiles"
mkdir -p "output/Arium/Identities"
mkdir -p "output/PrinceInsurance/Connection Profiles"
mkdir -p "output/PrinceInsurance/Identities"
mkdir -p "output/VDA/Connection Profiles"
mkdir -p "output/VDA/Identities"

register_identities() {
    for i in $(jq -c '.[]' ../apps/${1}/config/users.json); do
        NAME=$(jq -r '.name' <<< "$i")
        ATTRIBUTES=$(jq -c '.attrs' <<< "$i")

        ansible-playbook identity/register-${1}-identity.yml --extra-var="{\"enrollment_id\": \"$NAME\", \"enrollment_secret\": \"${NAME}pw\", \"enrollment_type\": \"client\", \"attributes\": $ATTRIBUTES}"
        ansible-playbook identity/enroll-${1}-identity.yml --extra-var="{\"enrollment_id\": \"$NAME\", \"enrollment_secret\": \"${NAME}pw\"}"
    done

    ansible-playbook identity/create-${1}-connection-profile.yml
}

register_identities manufacturer
register_identities insurer
register_identities regulator