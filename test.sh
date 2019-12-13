#!/usr/bin/env bash

set -e
trap "exit" SIGINT

if ! docker version &> /dev/null
then
    echo "Docker daemon is not running or you have unsufficient permissions!"
    exit 1
fi

docker build --tag "stationeers" .

TMP_DIR=$(mktemp -d /tmp/stationeers-XXXXXXXXXX)
trap "rm -rf $TMP_DIR" exit
chown -R 1358:1358 "$TMP_DIR"
docker run --rm --interactive --name stationeers --publish 27500:27500/udp --publish 27015:27015/udp --mount type=bind,source="$TMP_DIR",target=/stationeers stationeers
