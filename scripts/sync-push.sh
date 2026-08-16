#!/usr/bin/env bash
#
# sync-push.sh — capture changed home dotfiles back into the chezmoi source,
# then commit + push them.
#
#   bash scripts/sync-push.sh [commit-message]
#
# Captures any changes you made to managed files under $HOME (e.g. editing
# ~/.config/nvim/init.lua) back into dotfiles/, commits with an optional
# message (default: "chore: sync dotfiles via chezmoi"), and pushes.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MSG="${1:-chore: sync dotfiles via chezmoi}"
log(){ printf '\033[1;34m[taminaru]\033[0m %s\n' "$*"; }

export CHEZMOI_SOURCE="$REPO_DIR/dotfiles"
if command -v chezmoi >/dev/null 2>&1; then
  CHEZMOI=(chezmoi --source "$CHEZMOI_SOURCE")
else
  CHEZMOI=(mise x chezmoi -- chezmoi --source "$CHEZMOI_SOURCE")
fi

log "📤 Capturing changed home files back into dotfiles/..."
"${CHEZMOI[@]}" re-add

if [ -z "$(git -C "$REPO_DIR" status --porcelain)" ]; then
  log "No changes to commit."
  exit 0
fi

git -C "$REPO_DIR" diff --stat
git -C "$REPO_DIR" add -A
git -C "$REPO_DIR" commit -m "$MSG"
log "🚀 Pushing..."
git -C "$REPO_DIR" push

log "✅ Done."
