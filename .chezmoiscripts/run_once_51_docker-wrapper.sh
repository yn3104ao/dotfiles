#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="$HOME/.local/bin"
DOCKER_WRAPPER="$BIN_DIR/docker"


# If ~/.local/bin doesn't exist, create it
if [ ! -d "$BIN_DIR" ]; then
    mkdir -p "$BIN_DIR"
fi

# If Docker wrapper already exists, do nothing
if [ -f "$DOCKER_WRAPPER" ]; then
    echo "Docker wrapper already exists at $DOCKER_WRAPPER, skipping installation."
    exit 0
fi

# Do note crerate in environmentes without nerdctl
if ! command -v nerdctl &> /dev/null; then
    echo "nerdctl command not found, skipping Docker wrapper installation."
    exit 0
fi

# Docker wrapper Creation
echo "Creating Docker wrapper at $DOCKER_WRAPPER..."
cat << 'EOF' > "$DOCKER_WRAPPER"
#!/usr/bin/env bash
#Docker wrapper -> nerdctl
# managed by chezmoi (run_once)
set -euo pipefail

exec nerdctl "$@"
EOF

chmod +x "$DOCKER_WRAPPER"

if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo "Docker wrapper created successfully at $DOCKER_WRAPPER."
