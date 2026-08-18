#!/usr/bin/env bash
#
# setup-agent-stack.sh — RUN ON THE HOST, not inside the container.
#
# Given a running, fully-bootstrapped Taminaru container, this builds a lean
# reusable agent image and provisions two named volumes:
#
#   taminaru-repo   : the Taminaru git checkout  (mounted at ~/Taminaru)
#   taminaru-tools  : the mise toolchain         (~/.local/share/mise)
#
# The resulting image contains only immutable config (applied by home-manager, no
# repo, no symlinks), so agent containers spawned from it have no Taminaru
# source, no credentials, and no tool binaries baked in.
#
# Usage (from the host):
#   bash setup-agent-stack.sh <container> [image-name]
#   RESEED=1 bash setup-agent-stack.sh <container> [image-name]   # re-seed tools + re-pull repo
set -euo pipefail

CONTAINER="${1:?usage: setup-agent-stack.sh <container> [image-name]}"
IMAGE_NAME="${2:-taminaru-clean:latest}"
RESEED="${RESEED:-0}"

VOL_REPO="taminaru-repo"
VOL_TOOLS="taminaru-tools"
REPO_URL="${REPO_URL:-https://github.com/TreeHappy/Taminaru.git}"
BRANCH="${BRANCH:-main}"
STAGE="$(mktemp -d)"; trap 'rm -rf "$STAGE"' EXIT

log(){ printf '\033[1;34m[taminaru]\033[0m %s\n' "$*"; }

# 0. Sanity — this script must run where podman lives (the host).
command -v podman >/dev/null 2>&1 || { echo "podman required — run this on the HOST, not in the container"; exit 1; }
podman inspect "$CONTAINER" >/dev/null 2>&1 || { echo "container not found: $CONTAINER"; exit 1; }
BASE_IMG="$(podman inspect --format '{{.Image}}' "$CONTAINER")"
USER_HOME="$(podman inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "$CONTAINER" | grep '^HOME=' | cut -d= -f2- | tail -n1)"
USER_HOME="${USER_HOME:-/home/taminaru}"

# 1. Build the sanitized image: export -> scrub -> import
log "exporting $CONTAINER ..."
podman export "$CONTAINER" | tar -x -C "$STAGE"

# home-manager apply materializes real files into $HOME during bootstrap, so there
# are no symlinks into the repo to inline — the image already stands alone.
log "config is already materialized by home-manager (no symlinks to inline)"

log "scrubbing secrets, temp, and the repo from the image ..."
for p in \
  'home/*/.gitconfig' 'home/*/.git-credentials' 'home/*/.netrc' \
  'home/*/.ssh' 'home/*/.config/gh' \
  'home/*/.local/share/atuin' 'home/*/.config/atuin' \
  'home/*/.bash_history' 'home/*/.pi/agent/auth.json' 'home/*/.pi/agent/sessions' \
  'tmp/*' 'var/cache/apt/*' 'home/*/Taminaru'; do
  rm -rf "$STAGE/$p" 2>/dev/null || true
done

log "excluding toolchain/cache dirs (provided via volumes) ..."
for p in \
  'home/*/.local/share/mise' 'home/*/.local/state/mise' 'home/*/.cache/mise' \
  'home/*/.dotnet' 'home/*/.nuget' 'home/*/.templateengine' \
  'home/*/.bun' 'home/*/.npm' 'home/*/.cache'; do
  rm -rf "$STAGE/$p" 2>/dev/null || true
done

log "importing $IMAGE_NAME ..."
tar -C "$STAGE" -cf - . | \
  podman import --change "WORKDIR $USER_HOME" --message 'sanitized Taminaru agent image' - "$IMAGE_NAME"

# 2. Repo volume: fresh checkout of Taminaru (kept out of the image)
log "provisioning $VOL_REPO (git checkout) ..."
podman volume create "$VOL_REPO" >/dev/null
podman run --rm -v "$VOL_REPO":/repo "$BASE_IMG" \
  bash -c 'if [ -d /repo/.git ]; then cd /repo && git fetch --depth 1 origin "'"$BRANCH"'" && git reset --hard "origin/'"$BRANCH"'"; else git clone --depth 1 --branch "'"$BRANCH"'" "'"$REPO_URL"'" /repo; fi'

# 3. Tools volume: seed the mise toolchain from the LIVE container's filesystem
#    (the image intentionally has no toolchain). Re-seed on demand.
if [ "$RESEED" = "1" ] || [ ! "$(podman volume inspect "$VOL_TOOLS" >/dev/null 2>&1 && echo yes)" = "yes" ]; then
  podman volume create "$VOL_TOOLS" >/dev/null
  log "seeding $VOL_TOOLS (mise toolchain) from $CONTAINER ..."
  podman cp "$CONTAINER:/home/taminaru/.local/share/mise" "$STAGE/mise" 2>/dev/null \
    || podman cp "$CONTAINER:$USER_HOME/.local/share/mise" "$STAGE/mise"
  podman run --rm -v "$VOL_TOOLS":/dest -v "$STAGE/mise":/src:ro "$BASE_IMG" \
    bash -c 'cp -a /src/. /dest/'
fi

log "done."
cat <<'EOF'
spawn an agent container with:

  podman run -it --rm \
    -v taminaru-repo:/home/taminaru/Taminaru \
    -v taminaru-tools:/home/taminaru/.local/share/mise \
    taminaru-clean:latest
EOF
