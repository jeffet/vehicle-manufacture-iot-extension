#!/bin/bash
set -e

BASEDIR=$(dirname "$0")

source $BASEDIR/utils.sh

BASEDIR=$(get_full_path "$BASEDIR")

check_running() {
    CONTAINERS=$(docker ps -f "status=exited" -q)

    if [ -z "$CONTAINERS" ]; then
        return 0
    fi

    for CONTAINER in "$CONTAINERS"; do
        docker restart $CONTAINER
    done

    return 1
}

wait_until "check_running" 3 10