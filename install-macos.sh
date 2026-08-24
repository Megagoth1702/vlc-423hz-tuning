#!/usr/bin/env sh
set -eu

script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
source_file="$script_directory/VLC-432Hz-tuning.lua"
extensions_directory="$HOME/Library/Application Support/org.videolan.vlc/lua/extensions"
destination_file="$extensions_directory/VLC-432Hz-tuning.lua"

if [ ! -f "$source_file" ]; then
    printf '%s\n' "ERROR: VLC-432Hz-tuning.lua was not found beside this installer." >&2
    exit 1
fi

mkdir -p "$extensions_directory"
cp "$source_file" "$destination_file"
chmod 0644 "$destination_file"

printf '\n%s\n' "VLC 432 Hz Tuning was installed successfully."
printf '%s\n' "Destination: $destination_file"
printf '%s\n' "Restart VLC, then open View > 432 Hz Tuning."
