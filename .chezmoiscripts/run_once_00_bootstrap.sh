#!/usr/bin/env bash
set -euo pipefail

echo "[chezmoi] [bootstrap.sh] 🚀 Starting bootstrap script..."
echo "[chezmoi] [bootstrap.sh] 🤔 Checking sudo..."
sudo -v

echo "[chezmoi] [bootstrap.sh] 🌐 Checking network..."
curl -fsSL https://www.google.com > /dev/null || true

echo "[chezmoi] [bootstrap.sh] 📁 adding chezmoi path"
if [ -f "$HOME/bin/chezmoi" ]; then
    export PATH="$HOME/bin:$PATH"
fi

echo "[chezmoi] [bootstrap.sh] 🎉 Bootstrap script completed."
