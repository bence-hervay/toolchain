#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/config.sh"

echo "[setup-host] Installing base packages"
sudo apt-get update -qq
sudo apt-get install -y -qq \
  git \
  curl \
  ca-certificates \
  gnupg \
  openssh-client \
  tmux \
  tree \
  nano \
  ncdu \
  htop \
  earlyoom \
  cargo \
  python3 \
  python-is-python3

echo "[setup-host] Installing uv"
curl -LsSf https://astral.sh/uv/install.sh | sh

echo "[setup-host] Installing docker"
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sudo sh /tmp/get-docker.sh
  rm -f /tmp/get-docker.sh
  sudo usermod -aG docker "$USER" || true
fi

echo "[setup-host] Setting up git"
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"
git config --global core.autocrlf input
git config --global core.eol lf

echo "[setup-host] Done"
