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

BASEDIR=$(dirname "$0")

source $BASEDIR/utils.sh

BASEDIR=$(get_full_path "$BASEDIR")

#################
# SETUP LOGGING #
#################
LOG_PATH=$BASEDIR/logs
mkdir -p $LOG_PATH

exec > >(tee -i $LOG_PATH/install.log)
exec 2>&1

echo "###################"
echo "# BUILD CLI_TOOLS #"
echo "###################"
cd $BASEDIR/cli_tools
npm install
npm run build
cd $BASEDIR

echo "#############################"
echo "# CLEAN ENV VARS FOR DOCKER #"
echo "#############################"
unset $(cat $NETWORK_DOCKER_COMPOSE_DIR/.env | sed -E 's/(.*)=.*/\1/' | xargs)

echo "####################"
echo "# INSTALL COMPLETE #"
echo "####################"
