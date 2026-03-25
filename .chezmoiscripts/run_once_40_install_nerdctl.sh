#!/usr/bin/env bash
set -euo pipefail

if ! command -v nerdctl > /dev/null 2>&1; then
    echo "[chezmoi] [install_nerdctl.sh] nerdctl is already installed. Skipping."
    exit 0
fi

NERDCTL_VERSION="1.7.6"

curl -LO "https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION}-linux-amd64.tar.gz"
sudo tar Cxzvvf /usr/local/bin nerdctl-${NERDCTL_VERSION}-linux-amd64.tar.gz
rm nerdctl-${NERDCTL_VERSION}-linux-amd64.tar.gz
