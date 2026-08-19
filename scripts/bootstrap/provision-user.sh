#!/usr/bin/env bash
#
# provision-user.sh — the single, idempotent implementation of Taminaru's
# non-root user. Used by both .devcontainer/Dockerfile (image build) and
# scripts/bootstrap/bootstrap.sh (bare-Ubuntu / root-shell path), so the user
# definition can't drift between the two.
#
# Creates the user if missing (pinned UID), grants passwordless sudo via a
# managed /etc/sudoers.d drop-in, ensures the @includedir directive, and
# verifies the grant actually works before returning.
#
# Usage (as root):
#   TAMINARU_USER=taminaru TAMINARU_UID=1000 bash scripts/bootstrap/provision-user.sh
set -euo pipefail

TAMINARU_USER="${TAMINARU_USER:-taminaru}"
TAMINARU_UID="${TAMINARU_UID:-1000}"

if [ "$(id -u)" -ne 0 ]; then
  printf '\033[1;31m[taminaru]\033[0m provision-user.sh must run as root (useradd, sudoers)\n' >&2
  exit 1
fi

# 1. Create the user if missing; otherwise sanity-check the UID.
if ! id "$TAMINARU_USER" >/dev/null 2>&1; then
  printf '\033[1;34m[taminaru]\033[0m creating user %s (uid %s, passwordless NOPASSWD sudo)...\n' \
    "$TAMINARU_USER" "$TAMINARU_UID"
  useradd -m -s /bin/bash -u "$TAMINARU_UID" "$TAMINARU_USER"
else
  ACTUAL_UID="$(id -u "$TAMINARU_USER")"
  if [ "$ACTUAL_UID" -ne "$TAMINARU_UID" ]; then
    printf '\033[1;33m[taminaru]\033[0m ⚠️  user %s exists with uid %s (wanted %s) — keeping existing\n' \
      "$TAMINARU_USER" "$ACTUAL_UID" "$TAMINARU_UID"
  fi
  printf '\033[1;34m[taminaru]\033[0m user %s already exists\n' "$TAMINARU_USER"
fi

# 2. Managed sudoers drop-in. Overwritten every run so a stale or malformed
#    grant can't silently break passwordless sudo.
SUDOERS="/etc/sudoers.d/$TAMINARU_USER"
printf '\033[1;34m[taminaru]\033[0m ensuring %s has passwordless sudo...\n' "$TAMINARU_USER"
printf '%s ALL=(ALL) NOPASSWD:ALL\n' "$TAMINARU_USER" > "$SUDOERS"
chmod 440 "$SUDOERS"
visudo -cf "$SUDOERS"

# 3. Ensure /etc/sudoers pulls in /etc/sudoers.d (some base images/containers
#    ship without the directive). Appended via a validated temp copy + atomic
#    install so an invalid sudoers can never brick sudo.
if ! grep -qE '^[#@]includedir[[:space:]]+/etc/sudoers\.d' /etc/sudoers 2>/dev/null; then
  SUDOERS_TMP="$(mktemp /etc/sudoers.XXXXXX)"
  cat /etc/sudoers > "$SUDOERS_TMP"
  printf '\n@includedir /etc/sudoers.d\n' >> "$SUDOERS_TMP"
  if visudo -cf "$SUDOERS_TMP" >/dev/null 2>&1; then
    install -m 0440 "$SUDOERS_TMP" /etc/sudoers
    printf '\033[1;34m[taminaru]\033[0m added @includedir /etc/sudoers.d to /etc/sudoers\n'
  else
    printf '\033[1;33m[taminaru]\033[0m ⚠️  could not add @includedir /etc/sudoers.d to /etc/sudoers\n' >&2
  fi
  rm -f "$SUDOERS_TMP"
fi

# 4. Verify the grant actually works as the target user before returning.
if ! runuser -u "$TAMINARU_USER" -- sudo -n true 2>/dev/null; then
  printf '\033[1;31m[taminaru]\033[0m passwordless sudo for %s is not effective after writing %s\n' \
    "$TAMINARU_USER" "$SUDOERS" >&2
  printf '\033[1;31m[taminaru]\033[0m check that /etc/sudoers includes "@includedir /etc/sudoers.d" and that sudo-rs >= 0.2.14 is installed (0.2.13 has an /etc/group long-line bug)\n' >&2
  exit 1
fi
printf '\033[1;34m[taminaru]\033[0m passwordless sudo verified for %s\n' "$TAMINARU_USER"
