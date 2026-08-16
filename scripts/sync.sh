#!/usr/bin/env bash
#
# sync.sh — pull latest Taminaru and re-apply dotfiles with chezmoi.
#
#   bash scripts/sync.sh
#
# Pulls the latest commits (ff-only), then re-applies the dotfiles/ chezmoi
# source to $HOME so this machine reflects the repo. Safe to run anytime.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
log(){ printf '\033[1;34m[taminaru]\033[0m %s\n' "$*"; }

log "📥 Pulling latest Taminaru..."
git -C "$REPO_DIR" pull --ff-only

log "🎯 Re-applying dotfiles with chezmoi..."
if command -v chezmoi >/dev/null 2>&1; then
  chezmoi --source "$REPO_DIR/dotfiles" apply
else
  mise x chezmoi -- chezmoi --source "$REPO_DIR/dotfiles" apply
fi

log "✅ Done."
