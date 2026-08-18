#!/usr/bin/env bash
#
# sync.sh — pull latest Taminaru and re-apply dotfiles with home-manager.
#
#   bash scripts/sync.sh
#
# Pulls the latest commits (ff-only), then rebuilds and activates the
# home-manager configuration so this machine reflects the repo. Safe to
# run anytime.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
log(){ printf '\033[1;34m[taminaru]\033[0m %s\n' "$*"; }

log "📥 Pulling latest Taminaru..."
git -C "$REPO_DIR" pull --ff-only

log "🔧 Rebuilding home-manager configuration..."
nix build "$REPO_DIR#homeConfigurations.taminaru.activationPackage" \
  --extra-experimental-features "nix-command flakes" \
  --out-link "$REPO_DIR/result"

log "🔄 Activating home-manager profile..."
./result/activate

log "✅ Done."
