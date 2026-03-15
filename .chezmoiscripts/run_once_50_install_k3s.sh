#!/usr/bin/env bash
set -euo pipefail

if ! command -v k3s > /dev/null 2>&1; then
    echo "k3s is not installed, installing k3s..."
    curl -sfL https://get.k3s.io | sh -s - \
        --disable traefik \
        --disable servicelb \
        --disable local-storage
else
    echo "k3s is already installed, skipping installation."
    exit 0
fi
