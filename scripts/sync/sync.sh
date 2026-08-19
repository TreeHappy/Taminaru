#!/usr/bin/env bash
#
# sync.sh — keep the Taminaru repo and this machine in sync.
#
#   bash scripts/sync/sync.sh           # apply (default)
#   bash scripts/sync/sync.sh apply     # git pull --ff-only, rebuild + activate
#   bash scripts/sync/sync.sh push      # commit + push any repo changes
#   bash scripts/sync/sync.sh push "msg" # push with a custom commit message
#   bash scripts/sync/sync.sh help
#
# `apply` pulls the latest commits (ff-only), then rebuilds and activates the
# home-manager configuration so this machine reflects the repo. Safe to run
# anytime. `push` publishes local repo changes, since home-manager makes the
# repo the single source of truth — edit home.nix/dotfiles/ and push.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
log(){ printf '\033[1;34m[taminaru]\033[0m %s\n' "$*"; }

usage() {
  cat <<'EOF'
Usage: bash scripts/sync/sync.sh [apply|push [message]|help]

  apply (default)  git pull --ff-only, rebuild + activate home-manager
  push [message]   commit and push any changes (default: "chore: sync dotfiles")
  help             show this help
EOF
}

sync_apply() {
  log "📥 Pulling latest Taminaru..."
  git -C "$REPO_DIR" pull --ff-only

  log "🔧 Rebuilding home-manager configuration..."
  # The flake keys homeConfigurations by the managed user (read via
  # TAMINARU_USER), so --impure lets the env var reach flake eval.
  HM_USER="${TAMINARU_USER:-$(id -un)}"
  nix build "$REPO_DIR#homeConfigurations.${HM_USER}.activationPackage" \
    --extra-experimental-features "nix-command flakes" \
    --impure \
    --out-link "$REPO_DIR/result"

  log "🔄 Activating home-manager profile..."
  "$REPO_DIR/result/activate"
  log "✅ Done."
}

sync_push() {
  MSG="${1:-chore: sync dotfiles}"
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
}

ACTION="${1:-apply}"
case "$ACTION" in
  apply) sync_apply ;;
  push) sync_push "${2:-}" ;;
  help|-h|--help) usage ;;
  *) log "Unknown command: $ACTION"; usage; exit 1 ;;
esac
