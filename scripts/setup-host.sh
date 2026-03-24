#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(dirname -- "${BASH_SOURCE[0]}")/config.sh"

echo "[setup-host] Installing base packages"
sudo apt-get update -qq
sudo apt-get install -y -qq \
  git \
  curl \
  wget \
  ca-certificates \
  gnupg \
  openssh-client \
  tmux \
  tree \
  nano \
  ncdu \
  htop \
  btop \
  jq \
  ffmpeg \
  earlyoom \
  cargo \
  build-essential \
  cmake \
  libopencv-dev \
  libboost-all-dev \
  libeigen3-dev \
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

echo "[setup-host] Updating bashrc"
BASHRC_PATH="$HOME/.bashrc"
BASHRC_START="# TOOLCHAIN BLOCK START"
BASHRC_END="# TOOLCHAIN BLOCK END"
temp_file="$(mktemp)"
touch "$BASHRC_PATH"

awk -v start="$BASHRC_START" -v end="$BASHRC_END" '
  $0 == start { skip = 1; next }
  $0 == end { skip = 0; next }
  !skip { print }
' "$BASHRC_PATH" > "$temp_file"

{
  cat "$temp_file"
  printf "\n%s\n" "$BASHRC_START"
  cat "$BASHRC_BLOCK_PATH"
  printf "\n%s\n" "$BASHRC_END"
} > "$BASHRC_PATH"

rm -f "$temp_file"

echo "[setup-host] Done"
