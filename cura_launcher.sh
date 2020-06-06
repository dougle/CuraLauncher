#!/bin/bash

CURA_DIR=$HOME/.cache/cura_launcher
LATEST_URL=https://github.com/Ultimaker/Cura/releases/latest
[ -d $CURA_DIR ] || mkdir -p $CURA_DIR

verlte() {
		[  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ] && return 0 || return 1
}
verlt() {
		[ "$1" = "$2" ] && return 1 || verlte $1 $2
}

current_version=$([ -s $CURA_DIR/version ] && cat $CURA_DIR/version)
latest_version=$(curl --head $LATEST_URL 2>&1|grep -i location|grep -Po '(?<=/)[0-9\.]+')

download_path="$CURA_DIR/Cura-$latest_version.AppImage"

if [ -z "$current_version" ] || verlt $current_version $latest_version ;then
	downlaod_url="https://github.com/Ultimaker/Cura/releases/download/$latest_version/Cura-$latest_version.AppImage"
	if [ -n $(which axel) ];then
		axel -ao "$download_path" "$downlaod_url"
	elif [ -n $(which wget) ]; then
		wget -O "$download_path" "$downlaod_url"
	elif [ -n $(which curl) ];then
		curl "$downlaod_url" > "$download_path"
	fi

	chmod a+x "$download_path"
	[ -e "$CURA_DIR/Cura-$current_version.AppImage" ] && rm "$CURA_DIR/Cura-$current_version.AppImage"
	current_version=$latest_version
fi

if [ ! -f "$CURA_DIR/Cura-$current_version.AppImage" ];then
	echo "Cannot find Cura AppImage" >&2
	exit 1
fi

echo -n "$latest_version" > $CURA_DIR/version
$CURA_DIR/Cura-$current_version.AppImage &

exit 0;
