#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/config.sh"

if [ ! -d "$HOME" ]; then
  echo "[sync-git] $HOME not found" >&2
  exit 0
fi

echo "[sync-git] Syncing git repos in $HOME"

declare -A seen_repos=()

while IFS= read -r -d '' git_path; do
  repo_dir="$(dirname "$git_path")"

  if [ -n "${seen_repos[$repo_dir]:-}" ]; then
    continue
  fi

  seen_repos["$repo_dir"]=1

  branch="$(git -C "$repo_dir" symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
  if [ -z "$branch" ]; then
    branch="detached@$(git -C "$repo_dir" rev-parse --short HEAD)"
  fi

  echo "[sync-git] Updating ${repo_dir#$HOME/}/ ($branch)"
  git -C "$repo_dir" pull --ff-only || echo "[sync-git] Sync failed"
done < <(find "$HOME" \( -type d -name .git -o -type f -name .git \) -print0)

echo "[sync-git] Done"
