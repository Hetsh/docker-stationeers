#!/usr/bin/env bash


# Abort on any error
set -e -u

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh
source libs/docker.sh

# Check dependencies
assert_dependency "jq"
assert_dependency "curl"

# Base Image
update_image "hetsh/steamcmd" "SteamCMD" "(\d+\.)+\d+-\d+"

# Stationeers
RS_PKG="MANIFEST_ID" # Steam depot id for identification
RS_NAME="Stationeers"
RS_REGEX="\d+"
CURRENT_RS_VERSION=$(cat Dockerfile | grep -P -o "$RS_PKG=\K$RS_REGEX")
NEW_RS_VERSION=$(curl -L -s "https://steamdb.info/depot/600762/" | grep -P -o "<td>\K$RS_REGEX" | tail -n 1)
if [ "$CURRENT_RS_VERSION" != "$NEW_RS_VERSION" ]; then
	prepare_update "$RS_PKG" "$RS_NAME" "$CURRENT_RS_VERSION" "$NEW_RS_VERSION"

	# Scrape actual stationeers Version
	NEW_ACTUAL_RS_VERSION=$(curl -L -s "https://store.steampowered.com/news/?appids=544550&appgroupname=Stationeers" | grep -P -o "(\d+\.){3}\d+" | head -n 1)
	CURRENT_ACTUAL_RS_VERSION="${_CURRENT_VERSION%-*}"
	if [ "$CURRENT_ACTUAL_RS_VERSION" != "$NEW_ACTUAL_RS_VERSION" ]; then
		update_version "$NEW_ACTUAL_RS_VERSION"
	else
		update_release
	fi
fi

if ! updates_available; then
	echo "No updates available."
	exit 0
fi

# Perform modifications
if [ "${1+}" = "--noconfirm" ] || confirm_action "Save changes?"; then
	save_changes

	if [ "${1+}" = "--noconfirm" ] || confirm_action "Commit changes?"; then
		commit_changes
	fi
fi