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

if [[ "$(uname)" -eq "Linux" ]] &&  type gnome-terminal > /dev/null ; then
    #Inform the user demo being built in terminal window
    #Geometry= set window to size needed & not in front of desktop files
    gnome-terminal --geometry=39x10+300+100 -e "bash -c \"
    echo Vehicle Lifecycle Demo is now starting.;
    echo ;
    echo Please wait 5 min whilst we build the;
    echo network and apps for you. They will;
    echo open automatically.;
    echo ;
    echo Close this window at any time;
    exec bash\""
fi

source $BASEDIR/utils.sh

BASEDIR=$(get_full_path "$BASEDIR")

#################
# SETUP LOGGING #
#################
LOG_PATH=$BASEDIR/logs
mkdir -p $LOG_PATH

exec > >(tee -i $LOG_PATH/start.log)
exec 2>&1

mkdir -p $BASEDIR/tmp

APPS_DIR=$BASEDIR/../apps

REQUIRED_INSTALL_AND_BUILDS=("$BASEDIR/cli_tools")

MISSING=false
for REQUIRED in "${REQUIRED_INSTALL_AND_BUILDS[@]}"; do
    if [ ! -d "$REQUIRED/node_modules" ]; then
        MISSING=true
    elif [ ! -d "$REQUIRED/dist" ]; then
        MISSING=true
    fi
done

if [ "$MISSING" = true ]; then
    echo "###########################################"
    echo "# INSTALL NOT COMPLETE. RUNNING INSTALLER #"
    echo "###########################################"

    $BASEDIR/install.sh
fi

APPS_DOCKER_COMPOSE_DIR=$BASEDIR/apps/docker-compose

echo "####################"
echo "# BUILDING NETWORK #"
echo "####################"
"$BASEDIR/network/build.sh"

echo "#################"
echo "# SETUP CHANNEL #"
echo "#################"
"$BASEDIR/network/setup-channel.sh"

echo "#####################################"
echo "# INSTALL AND INSTANTIATE CHAINCODE #"
echo "#####################################"
"$BASEDIR/network/instantiate-chaincode.sh"

echo "#######################"
echo "# REGISTER IDENTITIES #"
echo "#######################"
"$BASEDIR/network/register-identities.sh"

echo "############################"
echo "# COPY CONNECTION PROFILES #"
echo "############################"
FABRIC_CONFIG_NAME=vehiclemanufacture_fabric

ARIUM_LOCAL_FABRIC=$APPS_DIR/manufacturer/$FABRIC_CONFIG_NAME
VDA_LOCAL_FABRIC=$APPS_DIR/regulator/$FABRIC_CONFIG_NAME
PRINCEINSURANCE_LOCAL_FABRIC=$APPS_DIR/insurer/$FABRIC_CONFIG_NAME

OUTPUT_FOLDER=$BASEDIR/network/output

cp "$OUTPUT_FOLDER/Arium/Connection Profiles/Gateway.json" "$ARIUM_LOCAL_FABRIC/connection.json"
cp "$OUTPUT_FOLDER/PrinceInsurance/Connection Profiles/Gateway.json" "$PRINCE_LOCAL_FABRIC/connection.json"
cp "$OUTPUT_FOLDER/VDA/Connection Profiles/Gateway.json" "$VDA_LOCAL_FABRIC/connection.json"

echo "####################"
echo "# IMPORTING USERS #"
echo "####################"
CLI_DIR=$BASEDIR/cli_tools

PARTIES=("Arium" "PrinceInsurance" "VDA")

for PARTY in "${PARTIES[@]}" ; do
    LOCAL_FABRIC_VAR=$(echo "${PARTY}_LOCAL_FABRIC" | tr a-z A-Z)
    ADMIN_CERT=$BASEDIR/tmp/${PARTY}_admin.pem
    ADMIN_KEY=$BASEDIR/tmp/${PARTY}_admin.key

    jq -r '.cert' $OUTPUT_FOLDER/$PARTY/Admin.json | base64 --decode > $ADMIN_CERT
    jq -r '.private_key' $OUTPUT_FOLDER/$PARTY/Admin.json | base64 --decode > $ADMIN_KEY

    node $CLI_DIR/dist/index.js import -w ${!LOCAL_FABRIC_VAR}/wallet -m ${PARTY}MSP -n admin -c $ADMIN_CERT -k $ADMIN_KEY -o $PARTY

    find $OUTPUT_FOLDER/$PARTY/Identities -name '*.json' -print0 | while IFS= read -r -d '' FILE; do
        IDENTITY=$(jq -r '.name' $FILE)
        CERT=$BASEDIR/tmp/${PARTY}_${IDENTITY}.pem
        KEY=$BASEDIR/tmp/${PARTY}_${IDENTITY}.key

        jq -r '.cert' $FILE | base64 --decode > $CERT
        jq -r '.private_key' $FILE | base64 --decode > $KEY

        node $CLI_DIR/dist/index.js import -w ${!LOCAL_FABRIC_VAR}/wallet -m ${PARTY}MSP -n $IDENTITY -c $CERT -k $KEY -o $PARTY
    done
done

# echo "###########################"
# echo "# SET ENV VARS FOR DOCKER #"
# echo "###########################"
# set_docker_env $APPS_DOCKER_COMPOSE_DIR

# echo "################"
# echo "# STARTUP APPS #"
# echo "################"

# INSURER_DIR=$APPS_DIR/insurer
# CAR_BUILDER_DIR=$APPS_DIR/car_builder
# MANUFACTURER_DIR=$APPS_DIR/manufacturer
# REGULATOR_DIR=$APPS_DIR/regulator

# docker-compose -f $APPS_DOCKER_COMPOSE_DIR/docker-compose.yaml -p node up -d

# CAR_BUILDER_PORT=6001
# ARIUM_PORT=6002
# VDA_PORT=6003
# PRINCE_PORT=6004

# cd $BASEDIR
# for PORT in $CAR_BUILDER_PORT $ARIUM_PORT $VDA_PORT $PRINCE_PORT
# do
#     echo "WAITING FOR REST SERVER ON PORT $PORT"
#     wait_until "curl --output /dev/null --silent --head --fail http://localhost:$PORT" 30 2
# done

# echo "###################################"
# echo "# SETTING MANUFACTURER PROPERTIES #"
# echo "###################################"

# docker exec arium_app node server/dist/setup.js

# echo "#####################"
# echo "# STARTING BROWSERS #"
# echo "#####################"

# URLS="http://localhost:$CAR_BUILDER_PORT http://localhost:$ARIUM_PORT http://localhost:$VDA_PORT http://localhost:$PRINCE_PORT http://localhost:$ARIUM_PORT/node-red"
# case "$(uname)" in
#     "Darwin")
#         open ${URLS}
#         ;;
#     "Linux")
#         if [ -n "$BROWSER" ] ; then
#             $BROWSER ${URLS}
#         elif which x-www-browser > /dev/null ; then
#             nohup x-www-browser ${URLS} < /dev/null > /dev/null 2>&1 &
#         elif which xdg-open > /dev/null ; then
#             for URL in ${URLS} ; do
#                 xdg-open ${URL}
#             done
#         elif which gnome-open > /dev/null ; then
#             gnome-open ${URLS}
#         else
#             echo "Could not detect web browser to use - please launch the demo in your chosen browser. See the README.md for which hosts/ports to open"
#         fi
#         ;;
#     *)
#         echo "Demo not launched. OS currently not supported"
#         ;;
# esac

# echo "#############################"
# echo "# CLEAN ENV VARS FOR DOCKER #"
# echo "#############################"
# unset $(cat $NETWORK_DOCKER_COMPOSE_DIR/.env | sed -E 's/(.*)=.*/\1/' | xargs)
# unset $(cat $APPS_DOCKER_COMPOSE_DIR/.env | sed -E 's/(.*)=.*/\1/' | xargs)

# echo "####################"
# echo "# STARTUP COMPLETE #"
# echo "####################"
