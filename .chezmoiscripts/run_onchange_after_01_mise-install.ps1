# config.toml hash: {{ include "private_dot_config/mise/config.toml.tmpl" | sha256sum}}

Write-Host "🔄 Changes to mise.toml have been detected. Proceeding with tool installation/update..."
mise install --yes
Write-Host "✅ The installation is complete!"
