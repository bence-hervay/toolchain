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
  graphviz \
  cargo \
  rustc \
  npm \
  opam \
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

git config --global push.default current
git config --global push.autoSetupRemote true
git config --global remote.pushDefault origin

git config --global merge.conflictStyle diff3

git config --global alias.fpush 'push --force-with-lease'

git config --global alias.submit '!f() {
  set -e

  slugify() {
    printf "%s" "$1" \
      | tr "[:upper:]" "[:lower:]" \
      | sed -E "s/[^[:alnum:]]+/-/g; s/^-+//; s/-+$//; s/-+/-/g"
  }

  if [ $# -eq 0 ]; then
    echo "usage: git submit <commit-or-message>"
    exit 2
  fi

  if [ $# -eq 1 ] \
    && printf "%s" "$1" | grep -Eq "^[0-9a-fA-F]{4,40}$" \
    && git rev-parse --verify -q "$1^{commit}" >/dev/null; then
    commit="$1"

    if ! git diff --quiet || ! git diff --cached --quiet; then
      echo "working tree is not clean"
      exit 1
    fi

    git fetch -q origin main

    subject=$(git log -1 --format=%s "$commit")
    short=$(git rev-parse --short "$commit")

    slug=$(slugify "$subject")
    branch="${slug:+$slug-}$short"

    if ! git check-ref-format --branch "$branch" >/dev/null 2>&1; then
      echo "could not generate a valid branch name from: $subject"
      exit 1
    fi

    git switch -c "$branch" --no-track origin/main
    git cherry-pick "$commit"
    git push -u origin HEAD
    exit 0
  fi

  message="$*"

  if git diff --cached --quiet; then
    echo "no staged changes to commit"
    exit 1
  fi

  branch=$(slugify "$message")

  if ! git check-ref-format --branch "$branch" >/dev/null 2>&1; then
    echo "could not generate a valid branch name from: $message"
    exit 1
  fi

  git switch -c "$branch"
  git commit -m "$message"
}; f'

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
