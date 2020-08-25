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
MAN_ID="MANIFEST_ID" # Steam depot id for identification
MAN_REGEX="\d{17,19}"
CURRENT_RS_VERSION=$(cat Dockerfile | grep -P -o "(?<=$MAN_ID=)$MAN_REGEX")
NEW_RS_VERSION=$(curl --silent --location "https://steamdb.info/depot/600762" | grep -P -o "(?<=<td>)$MAN_REGEX(?=</td>)" | tail -n 1)
if [ "$CURRENT_RS_VERSION" != "$NEW_RS_VERSION" ]; then
	prepare_update "$MAN_ID" "Stationeers" "$CURRENT_RS_VERSION" "$NEW_RS_VERSION"
	update_version "$NEW_RS_VERSION"
fi

if ! updates_available; then
	#echo "No updates available."
	exit 0
fi

# Perform modifications
if [ "${1-}" = "--noconfirm" ] || confirm_action "Save changes?"; then
	save_changes

	if [ "${1-}" = "--noconfirm" ] || confirm_action "Commit changes?"; then
		commit_changes
	fi
fi