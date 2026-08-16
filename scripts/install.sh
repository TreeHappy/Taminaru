#!/usr/bin/env bash
#
# Taminaru bootstrap launcher (curl-friendly).
#
# Clones the Taminaru repo (or pulls the latest) and runs scripts/bootstrap.sh
# inside it, so a fresh machine can be provisioned with a single command:
#
#   curl -fsSL https://raw.githubusercontent.com/TreeHappy/Taminaru/main/scripts/install.sh | bash
#
# Requires curl, git and sudo to already be installed (see README.md).
#
# Env overrides: REPO_URL, REPO_DIR, BRANCH, FLAVOR, TAMINARU_USER
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/TreeHappy/Taminaru.git}"
REPO_DIR="${REPO_DIR:-$HOME/Taminaru}"
BRANCH="${BRANCH:-main}"

log()  { printf '\033[1;34m[taminaru]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[taminaru]\033[0m %s\n' "$*"; }

log "✨ Taminaru bootstrap launcher"

for var in FLAVOR TAMINARU_USER; do
  if [ -n "${!var:-}" ]; then
    export "$var"
  fi
done

if [ ! -d "$REPO_DIR/.git" ]; then
  if [ -e "$REPO_DIR" ]; then
    warn "$REPO_DIR exists but is not a git repo; leaving it alone"
    exit 1
  fi
  log "📂 Cloning Taminaru into $REPO_DIR..."
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$REPO_DIR"
else
  log "📂 Taminaru already present at $REPO_DIR"
  git -C "$REPO_DIR" pull --ff-only >/dev/null 2>&1 \
    || warn "could not pull latest; continuing with local copy"
fi

exec bash "$REPO_DIR/scripts/bootstrap.sh" "$@"
