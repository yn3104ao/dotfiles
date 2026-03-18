# config.toml hash: {{ include "private_dot_config/mise/config.toml.tmpl" | sha256sum}}

Write-Host "[chezmoi] [mise-install.ps1] 🔄 Changes to mise.toml have been detected. Proceeding with tool installation/update..."
mise install --yes
Write-Host "[chezmoi] [mise-install.ps1] ✅ The installation is complete!"
