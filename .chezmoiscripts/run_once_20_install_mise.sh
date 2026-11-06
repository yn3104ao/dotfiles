#!/usr/bin/env bash
set -euo pipefail

if ! command -v mise > /dev/null 2>&1 && [ ! -x "$HOME/.local/bin/mise" ]; then
    curl https://mise.run | sh
fi

# Use commands that are already in your PATH or located in the default installation directory (~/.local/bin/mise)
MISE_BIN="$HOME/.local/bin/mise"
if command -v mise > /dev/null 2>&1; then
    MISE_BIN="mise"
fi

"$MISE_BIN" --version

# Tool installation is handled by run_onchange_after_91_mise-install.sh,
# which runs after ~/.config/mise/config.toml has been written.
