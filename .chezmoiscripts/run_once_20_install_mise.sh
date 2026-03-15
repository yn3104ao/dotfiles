#!/usr/bin/env bash
set -euo pipefail

if ! command -v mise > /dev/null 2>&1; then
    curl https://mise.run | sh
fi

# Sprcify MISE_USE_VERSIONS_HOST=1 to retrieve the latest version information without using the GitHub API.
export MISE_USE_VERSIONS_HOST=1

# Use commands that are already in your PATH or located in the defalett installation directory (~/.local/bin/mise)
MISE_BIN="$HOME/.local/bin/mise"
if command -v mise > /dev/null 2>&1; then
    MISE_BIN="mise"
fi

$MISE_BIN install --yes
$MISE_BIN prune --yes
