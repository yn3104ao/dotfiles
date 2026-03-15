#!/usr/bin/env bash
set -euo pipefail

SRC="$HOME/.config/nerdctl/nerdctl.toml"
DST="/etc/nerdctl/nerdctl.toml"

if [ ! -f "$SRC" ]; then
    echo "$SRC does not exist, skipping nerdctl rootful settings installation."
    exit 0
fi

echo "Installing nerdctl system config..."

sudo mkdir -p "$(dirname "$DST")"
sudo cp "$SRC" "$DST"
sudo chown root:root "$DST"
sudo chmod 644 "$DST"

echo "nerdctl system config installed successfully at $DST."
