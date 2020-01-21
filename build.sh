#!/usr/bin/env bash

set -e
trap "exit" SIGINT

if ! docker version &> /dev/null
then
	echo "Docker daemon is not running or you have unsufficient permissions!"
	exit -1
fi

WORK_DIR="${0%/*}"
cd "$WORK_DIR"

APP_NAME="stationeers"
docker build --tag "$APP_NAME" .

read -p "Test image? [y/n]" -n 1 -r && echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	TMP_DIR=$(mktemp -d "/tmp/$APP_NAME-XXXXXXXXXX")
	trap "rm -rf $TMP_DIR" exit

	APP_UID=1358
	chown -R "$APP_UID":"$APP_UID" "$TMP_DIR"
	
	docker run \
	--rm \
	--interactive \
	--publish 27500:27500/udp \
	--publish 27500:27500/tcp \
	--publish 27015:27015/udp \
	--mount type=bind,source="$TMP_DIR",target="/$APP_NAME" \
	--name "$APP_NAME" \
	"$APP_NAME"
fi
