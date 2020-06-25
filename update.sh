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

# Debian Stable with SteamCMD
update_image "hetsh/steamcmd" "SteamCMD" "false" "(\d+\.)+\d+-\d+"

# Stationeers
RS_PKG="MANIFEST_ID" # Steam depot id for identification
RS_REGEX="\d+"
CURRENT_RS_VERSION=$(cat Dockerfile | grep -P -o "$RS_PKG=\K$RS_REGEX")
NEW_RS_VERSION=$(curl -L -s "https://steamdb.info/depot/600762/" | grep -P -o "<td>\K$RS_REGEX" | tail -n 1)
if [ "$CURRENT_RS_VERSION" != "$NEW_RS_VERSION" ]; then
	prepare_update "$RS_PKG" "Stationeers" "$CURRENT_RS_VERSION" "$NEW_RS_VERSION"
	update_version "$NEW_RS_VERSION"
fi

if ! updates_available; then
	echo "No updates available."
	exit 0
fi

# Perform modifications
if [ "${1-}" = "--noconfirm" ] || confirm_action "Save changes?"; then
	save_changes

	if [ "${1-}" = "--noconfirm" ] || confirm_action "Commit changes?"; then
		commit_changes
	fi
fi