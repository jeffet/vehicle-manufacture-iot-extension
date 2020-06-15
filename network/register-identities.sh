#
# SPDX-License-Identifier: Apache-2.0
#
set -e

cd "$(dirname "$0")"

set -x

mkdir output/Arium
mkdir output/PrinceInsurance
mkdir output/VDA

# TODO - MAKE IT HANDLE ATTRIBUTES
ansible-playbook identity/register-arium-identity.yml --extra-vars "enrollment_id=registrar enrollment_secret=registrarpw enrollment_type=client"