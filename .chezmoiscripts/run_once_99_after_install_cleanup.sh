#!/usr/bin/env bash
set -euo pipefail

echo "[cleanup.sh] Starting cleanup script..."
echo "[cleanup.sh] Removing apt cache..."
sudo apt -q clean
sudo rm -rf /var/lib/apt/lists/*

echo "[cleanup.sh] journal log cleanup (keep last 2 days)..."
sudo journalctl --vacuum-time=2d

K3S_CONTAINERD="/run/containerd/containerd.sock"

if command -v nerdctl > /dev/null 2>&1 && [ -S "$K3S_CONTAINERD" ]; then
    echo "[cleanup.sh] K3s detected, stopping k3s service..."
    sudo systemctl stop k3s
    echo "[cleanup.sh] Removing K3s container images..."
    sudo nerdctl \
        --namespace k8s.io \
        --address "$K3S_CONTAINERD" \
        image prune -a -f
else
    echo "[cleanup.sh] skip containerd cleanup (k3s not running)."
fi

echo "[cleanup.sh] Removing user cache..."
rm -rf ~/.cache/*

echo "[cleanup.sh] Removing temporary files..."
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

echo "[cleanup.sh] Cleanup script completed."
