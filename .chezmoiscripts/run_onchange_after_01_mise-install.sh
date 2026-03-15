#!/usr/bin/env bash
set -euo pipefail

# config.toml hash: {{ include "private_dot_config/mise/config.toml.tmpl" | sha256sum}}

# To avoid GitHub API rate limits, use the mise versions host and check for gh auth.
export MISE_USE_VERSIONS_HOST=1

# Check if logged in to GitHub CLI to avoid API rate limits.
if command -v gh &> /dev/null; then
    if ! gh auth status &> /dev/null; then
        echo "🔐 You are not logged in to GitHub CLI. Please log in to avoid API rate limits."
        gh auth login
    fi
else
    echo "⚠️ gh command not found. Skipping GitHub auth check. This might lead to API rate limits."
fi

echo "🔄 Changes to mise.toml have been detected. Proceeding with tool installation/update..."

mise install --yes
echo "✅ The installation is complete!"
