#!/usr/bin/env bash

set -e
trap "exit" SIGINT

if [ "$USER" == "root" ]
then
	echo "Must not be executed as user \"root\"!"
	exit -1
fi

if ! [ -x "$(command -v jq)" ]
then
	echo "JSON Parser \"jq\" is required but not installed!"
	exit -2
fi

if ! [ -x "$(command -v curl)" ]
then
	echo "\"curl\" is required but not installed!"
	exit -3
fi

CURRENT_VERSION=$(git describe --tags --abbrev=0)
NEXT_VERSION="$CURRENT_VERSION"

# SteamCMD
CURRENT_STEAMCMD_VERSION=$(cat Dockerfile | grep "FROM hetsh/steamcmd:")
CURRENT_STEAMCMD_VERSION="${CURRENT_STEAMCMD_VERSION#*:}"
STEAMCMD_VERSION=$(curl -L -s 'https://registry.hub.docker.com/v2/repositories/hetsh/steamcmd/tags' | jq '."results"[]["name"]' | grep -P -o "(\d+\.)+\d+-\d+" | head -n 1)
if [ "$CURRENT_STEAMCMD_VERSION" != "$STEAMCMD_VERSION" ]
then
	echo "SteamCMD $STEAMCMD_VERSION available!"

	RELEASE="${CURRENT_VERSION#*-}"
	NEXT_VERSION="${CURRENT_VERSION%-*}-$((RELEASE+1))"
fi

# Stationeers Manifest
CURRENT_MANIFEST_ID=$(cat Dockerfile | grep "ARG RS_MANIFEST_ID=.*")
CURRENT_MANIFEST_ID=${CURRENT_MANIFEST_ID#*=}
MANIFEST_ID=$(curl -L -s 'https://steamdb.info/depot/600762/' | grep -P -o "<td>\d+" | tr -d '<td>' | tail -n 1)
if [ "$CURRENT_MANIFEST_ID" != "$MANIFEST_ID" ]
then
	echo "Manifest ID $MANIFEST_ID available!"

	RELEASE="${CURRENT_VERSION#*-}"
	NEXT_VERSION="${CURRENT_VERSION%-*}-$((RELEASE+1))"
fi

# Stationeers Version
CURRENT_STATIONEERS_VERSION="${CURRENT_VERSION%-*}"
STATIONEERS_VERSION=$(curl -L -s "https://store.steampowered.com/news/?appids=544550&appgroupname=Stationeers" | grep -P -o "(\d+\.){3}\d+" | head -n 1)
if [ "$CURRENT_STATIONEERS_VERSION" != "$STATIONEERS_VERSION" ]
then
	echo "Stationeers Server $STATIONEERS_VERSION available"

	NEXT_VERSION="$STATIONEERS_VERSION-1"
fi

if [ "$CURRENT_VERSION" == "$NEXT_VERSION" ]
then
	echo "Nothing changed."
else
	read -p "Save changes? [y/n]" -n 1 -r && echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		if [ "$CURRENT_STEAMCMD_VERSION" != "$STEAMCMD_VERSION" ]
		then
			sed -i "s|FROM hetsh/steamcmd:.*|FROM hetsh/steamcmd:$STEAMCMD_VERSION|" Dockerfile
		fi

		if [ "$CURRENT_MANIFEST_ID" != "$MANIFEST_ID" ]
		then
			sed -i "s|ARG RS_MANIFEST_ID=\".*\"|ARG RS_MANIFEST_ID=\"$MANIFEST_ID\"|" Dockerfile
		fi

		read -p "Commit changes? [y/n]" -n 1 -r && echo
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			git add Dockerfile
			git commit -m "Version bump to $NEXT_VERSION"
			git push
			git tag "$NEXT_VERSION"
			git push origin "$NEXT_VERSION"
		fi
	fi
fi
