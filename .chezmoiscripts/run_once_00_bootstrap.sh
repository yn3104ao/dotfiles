#!/usr/bin/env bash
set -euo pipefail

echo "[bootstrap.sh] Starting bootstrap script..."
echo "[bootstrap.sh] Checking sudo..."
sudo -v

echo "[bootstrap.sh] Checking network..."
curl -fsSL https://www.google.com > /dev/null || true

echo "[bootstrap.sh] adding chezmoi path"
if [ -f "$HOME/bin/chezmoi" ]; then
    export PATH="$HOME/bin:$PATH"
fi

echo "[bootstrap.sh] Bootstrap script completed."
