# config.toml hash: {{ include "private_dot_config/mise/config.toml.tmpl" | sha256sum}}

Write-Hoset "🔄 Changes to mise.toml have been detected. Proceeding with tool installation/update..."
mise install --yes
Write-Hoset "✅ The installation is complete!"
