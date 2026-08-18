#!/usr/bin/env bash
#
# sync-push.sh — commit and push any changes to the Taminaru repo.
#
#   bash scripts/sync-push.sh [commit-message]
#
# With home-manager, the repo is the single source of truth. Edit configs in
# the repo's dotfiles/ or home.nix, then run this script to commit and push.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MSG="${1:-chore: sync dotfiles}"
log(){ printf '\033[1;34m[taminaru]\033[0m %s\n' "$*"; }

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
