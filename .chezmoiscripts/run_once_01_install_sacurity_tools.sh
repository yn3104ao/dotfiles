#!/usr/bin/env bash
set -euo pipefail

if command -v safe-chain > /dev/null 2>&1; then
    echo "✅ safe-chain is already installed. Skipping installation."
    exit 0
fi

echo "📦 Installing safe-chain..."

curl -fsSL https://github.com/AikidoSec/safe-chain/releases/latest/download/install-safe-chain.sh | sh

echo "✅ safe-chain installation completed!"
