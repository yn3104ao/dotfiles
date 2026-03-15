#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="$HOME/.local/bin"
OP_WRAPPER="$BIN_DIR/op"


# If ~/.local/bin doesn't exist, create it
if [ ! -d "$BIN_DIR" ]; then
    mkdir -p "$BIN_DIR"
fi

# If op already exists, do nothing
if [ -f "$OP_WRAPPER" ]; then
    echo "op wrapper already exists at $OP_WRAPPER, skipping installation."
    exit 0
fi

# Do note crerate in environmentes without op.exe
if ! command -v op.exe &> /dev/null; then
    echo "op command not found, skipping op wrapper installation."
    exit 0
fi

# op.exe Wrapper Creation
echo "Creating op wrapper at $OP_WRAPPER..."
cat << 'EOF' > "$OP_WRAPPER"
#!/usr/bin/env bash
#op wrapper -> op.exe
# managed by chezmoi (run_once)
set -euo pipefail

exec op.exe "$@"
EOF

chmod +x "$OP_WRAPPER"

if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo "op wrapper created successfully at $OP_WRAPPER."
