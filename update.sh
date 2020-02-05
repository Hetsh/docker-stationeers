#!/usr/bin/env bash


# Abort on any error
set -eu

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh
source libs/docker.sh

# Check dependencies
assert_dependency "jq"
assert_dependency "curl"

# Current version of docker image
CURRENT_VERSION=$(git describe --tags --abbrev=0)
register_current_version "$CURRENT_VERSION"

# Base Image
IMAGE_PKG="hetsh/steamcmd"
IMAGE_NAME="SteamCMD"
IMAGE_REGEX="(\d+\.)+\d+-\d+"
IMAGE_TAGS=$(curl -L -s "https://registry.hub.docker.com/v2/repositories/$IMAGE_PKG/tags" | jq '."results"[]["name"]' | grep -P -w "$IMAGE_REGEX" | tr -d '"')
IMAGE_VERSION=$(echo "$IMAGE_TAGS" | sort | tail -n 1)
CURRENT_IMAGE_VERSION=$(cat Dockerfile | grep -P -o "$IMAGE_PKG:\K$IMAGE_REGEX")
if [ "$CURRENT_IMAGE_VERSION" != "$IMAGE_VERSION" ]; then
	echo "$IMAGE_NAME $IMAGE_VERSION available!"
	update_release
fi

# Stationeers
RS_PKG="MANIFEST_ID" # Steam depot id
RS_NAME="Stationeers"
RS_REGEX="\d+"
RS_VERSION=$(curl -L -s "https://steamdb.info/depot/600762/" | grep -P -o "<td>$RS_REGEX" | tr -d '<td>' | tail -n 1)
CURRENT_RS_VERSION=$(cat Dockerfile | grep -P -o "$RS_PKG=\K$RS_REGEX")
if [ "$CURRENT_RS_VERSION" != "$RS_VERSION" ]; then
	# Scrape actual stationeers Version
	ACTUAL_RS_VERSION=$(curl -L -s "https://store.steampowered.com/news/?appids=544550&appgroupname=$RS_NAME" | grep -P -o "(\d+\.){3}\d+" | head -n 1)
	ACTUAL_CURRENT_RS_VERSION="${CURRENT_VERSION%-*}"
	if [ "$ACTUAL_CURRENT_RS_VERSION" != "$ACTUAL_RS_VERSION" ]; then
		echo "$RS_NAME $ACTUAL_RS_VERSION available!"
		update_version "$ACTUAL_RS_VERSION"
	else
		echo "$RS_NAME ID:$RS_VERSION available!"
		update_release
	fi
fi

if ! updates_available; then
	echo "No updates available."
	exit 0
fi

# Perform modifications
if [ "${1+}" = "--noconfirm" ] || confirm_action "Save changes?"; then
	if [ "$CURRENT_IMAGE_VERSION" != "$IMAGE_VERSION" ]; then
		sed -i "s|$IMAGE_PKG:$CURRENT_IMAGE_VERSION|$IMAGE_PKG:$IMAGE_VERSION|" Dockerfile
		CHANGELOG+="$IMAGE_NAME $CURRENT_IMAGE_VERSION -> $IMAGE_VERSION, "
	fi
	if [ "$CURRENT_RS_VERSION" != "$RS_VERSION" ]; then
		sed -i "s|$RS_PKG=$CURRENT_RS_VERSION|$RS_PKG=$RS_VERSION|" Dockerfile
		CHANGELOG+="$RS_NAME $CURRENT_RS_VERSION -> $RS_VERSION, "
	fi
	CHANGELOG="${CHANGELOG%,*}"

	if [ "${1+}" = "--noconfirm" ] || confirm_action "Commit changes?"; then
		commit_changes "$CHANGELOG"
	fi
fi
