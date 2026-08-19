#!/usr/bin/env bash
#
# Taminaru dotfiles bootstrap (Nix).
#
# Provisions a fresh machine (tested on Ubuntu): installs Nix (via Determinate
# Systems installer), applies every tool and dotfile with home-manager, wires
# home-manager activation into the bash profile, and switches the login shell
# to pwsh. Idempotent and safe to re-run.
#
# Each run also purges the nvim data dirs (~/.local/{share,state,cache}/nvim,
# and any stale .bak leftovers) so plugins and treesitter parsers are always
# reinstalled from the current config — opt out with NVIM_WIPE=0.
#
# Running as root on a fresh Ubuntu first creates a non-root user (default:
# taminaru, pinned uid 1000, passwordless with NOPASSWD sudo) via
# scripts/bootstrap/provision-user.sh — the same script the devcontainer
# Dockerfile uses — copies this repo into their home, and re-runs the whole
# bootstrap as that user.
#
# Usage: bash scripts/bootstrap/bootstrap.sh
#        TAMINARU_USER=bob TAMINARU_UID=1000 bash scripts/bootstrap/bootstrap.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TAMINARU_USER="${TAMINARU_USER:-taminaru}"
TAMINARU_UID="${TAMINARU_UID:-1000}"
# Exported so the runuser re-run below and the flake (which reads
# TAMINARU_USER via getEnv) both see the override.
export TAMINARU_USER TAMINARU_UID

log()  { printf '\033[1;34m[taminaru]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[taminaru]\033[0m ⚠️  %s\n' "$*"; }

log "✨ Taminaru dotfiles bootstrap (Nix) — sit back, we've got this"

# 0. apt prerequisites: install everything apt can provide up front so every
#    later check in this script sees real state. apt-get is idempotent, so
#    re-runs are no-ops. As root we don't need sudo; otherwise sudo must
#    already be installed (see README.md).
#    Everything else — including the treesitter C compiler (`zig cc`) — comes
#    from Nix via home-manager, so no build-essential / gcc is needed here.
export DEBIAN_FRONTEND="noninteractive"
APT_GET="apt-get"
if [ "$(id -u)" -ne 0 ]; then
  if ! command -v sudo >/dev/null 2>&1; then
    warn "sudo is missing — as root, run: apt-get install -y curl git sudo"
    exit 1
  fi
  APT_GET="sudo apt-get"
fi
log "📦 Installing apt packages (curl git sudo ca-certificates)..."
$APT_GET update
$APT_GET install -y curl git sudo ca-certificates --no-install-recommends

# 0a. Validate passwordless sudo (needed for /etc/shells, chsh, and the
#     sudoers self-heal on fresh installs). Runs after apt so the required
#     packages above are already on the machine.
if [ "$(id -u)" -ne 0 ]; then
  if ! sudo -n true 2>/dev/null; then
    warn "$(id -un) needs passwordless sudo — as root, run: echo '$(id -un) ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$(id -un) && chmod 440 /etc/sudoers.d/$(id -un)"
    exit 1
  fi
fi

# 0b. Fresh install: when running as root, provision the non-root user via the
#     shared provisioner (same one the devcontainer Dockerfile uses) so we
#     don't have to use root, then re-run the rest of this script as that user.
if [ "$(id -u)" -eq 0 ] && [ "$TAMINARU_USER" != "root" ]; then
  log "👤 Provisioning user $TAMINARU_USER (uid $TAMINARU_UID, NOPASSWD sudo)..."
  bash "$REPO_DIR/scripts/bootstrap/provision-user.sh"

  USER_HOME="$(getent passwd "$TAMINARU_USER" | cut -d: -f6)"
  USER_REPO="$USER_HOME/Taminaru"
  if [ ! -d "$USER_REPO" ]; then
    log "📂 Copying repo to $USER_REPO..."
    cp -a "$REPO_DIR" "$USER_REPO"
    chown -R "$TAMINARU_USER:$TAMINARU_USER" "$USER_REPO"
  fi

  log "🔁 Re-running bootstrap as $TAMINARU_USER..."
  runuser -u "$TAMINARU_USER" -- bash "$USER_REPO/scripts/bootstrap/bootstrap.sh" "$@"
  exit $?
fi

# 0c. Nix build sandbox detection — the sandbox needs to create namespaces and
#     call sethostname(), which unprivileged containers (Docker's default
#     seccomp, rootless podman) block, so every nix build dies with 'cannot set
#     host name: Operation not permitted'. Detect that and build unsandboxed.
#     Force with TAMINARU_SANDBOX=1 (on) or =0 (off).
SANDBOX="${TAMINARU_SANDBOX:-auto}"
if [ "$SANDBOX" = "auto" ]; then
  if [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
    SANDBOX=0
  else
    CAP_SYS_ADMIN=$((1 << 21))
    CAPS="$(sed -n 's/^CapEff:[[:space:]]*\([0-9a-fA-F]*\)[[:space:]]*$/\1/p' /proc/self/status 2>/dev/null || true)"
    if [ -n "$CAPS" ] && [ $((0x$CAPS & CAP_SYS_ADMIN)) -eq 0 ]; then
      SANDBOX=0
    fi
  fi
fi

# 0d. Lean nix config — assembled once so the installer (--extra-conf) and the
#     post-install write (nix.custom.conf, included at the bottom of the
#     Determinate installer's nix.conf so its settings win) share one source.
NIX_CUSTOM_CONF="/etc/nix/nix.custom.conf"
NIX_CUSTOM_CONTENT="# Taminaru lean nix config — auto-optimise-store deduplicates store paths
auto-optimise-store = true
max-jobs = auto
allowed-users = $TAMINARU_USER
trusted-users = root $TAMINARU_USER
"
if [ "$SANDBOX" = "0" ]; then
  NIX_CUSTOM_CONTENT+="sandbox = false
"
fi

# 1. Install Nix if missing (via Determinate Systems installer)
if command -v nix >/dev/null 2>&1; then
  log "🚀 Nix already installed: $(nix --version)"
else
  log "🚀 Installing Nix (Determinate Systems installer)..."
  INSTALLER_ARGS=("install" "linux" "--no-confirm")
  # The installer writes --extra-conf into nix.custom.conf; the 1b write below
  # lands in the same file, belt and suspenders.
  INSTALLER_ARGS+=("--extra-conf" "$NIX_CUSTOM_CONTENT")
  if [ "$SANDBOX" = "0" ]; then
    warn "container without CAP_SYS_ADMIN detected — installing Nix with sandbox disabled (TAMINARU_SANDBOX=1 to force)"
  fi
  if ! pidof systemd >/dev/null 2>&1; then
    INSTALLER_ARGS+=("--init" "none")
    log "🔧 systemd not detected, installing without init service"
  fi
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- "${INSTALLER_ARGS[@]}"
  # Source nix profile for this session
  if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  elif [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  fi
  export PATH="/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:$PATH"
  log "✅ Nix installed: $(nix --version)"
fi

# 1b. Write nix.custom.conf (included at the bottom of Determinate's nix.conf,
#     so its settings win). Content is built once in 0d.
if [ "$(id -u)" -eq 0 ]; then
  echo "$NIX_CUSTOM_CONTENT" > "$NIX_CUSTOM_CONF"
else
  echo "$NIX_CUSTOM_CONTENT" | sudo tee "$NIX_CUSTOM_CONF" > /dev/null
fi
log "✅ nix.custom.conf written (auto-optimise-store, max-jobs, allowed/trusted users)"

# 1c. Ensure nix-daemon is running (required for nix build).
#     On systemd systems the daemon is managed by its service unit.
#     Without systemd (containers, WSL) we start it manually via sudo
#     since the socket must be owned by root.
if pidof systemd >/dev/null 2>&1; then
  log "✅ nix-daemon managed by systemd"
else
  DAEMON_RUNNING=0
  if [ -e /nix/var/nix/daemon-socket/socket ]; then
    # Socket exists — verify it's actually accepting connections
    if nix store ping --extra-experimental-features "nix-command" 2>/dev/null; then
      DAEMON_RUNNING=1
      log "✅ nix-daemon is running"
    else
      warn "stale nix-daemon socket detected, restarting..."
      sudo rm -f /nix/var/nix/daemon-socket/socket
    fi
  fi
  if [ "$DAEMON_RUNNING" -eq 0 ]; then
    log "🔧 Starting nix-daemon via sudo..."
    sudo /nix/var/nix/profiles/default/bin/nix-daemon &
    DAEMON_PID=$!
    sleep 2
    if [ -e /nix/var/nix/daemon-socket/socket ]; then
      log "✅ nix-daemon started (pid $DAEMON_PID)"
    else
      warn "nix-daemon failed to start; builds may not work"
    fi
  fi
fi

# 2. Apply home-manager configuration (tools + dotfiles)
log "🔧 Applying home-manager configuration..."
# The flake keys homeConfigurations by the managed user (read via
# TAMINARU_USER), so --impure lets the env var reach flake eval.
HM_USER="${TAMINARU_USER:-$(id -un)}"
NIX_BUILD_ARGS=(--extra-experimental-features "nix-command flakes" --impure)
if [ "$SANDBOX" = "0" ]; then
  NIX_BUILD_ARGS+=(--option sandbox false)
fi
if [ -d "$REPO_DIR/.git" ]; then
  # If in a git repo, use nix build + activate
  log "📦 Building home-manager activation package for $HM_USER..."
  nix build "$REPO_DIR#homeConfigurations.${HM_USER}.activationPackage" \
    "${NIX_BUILD_ARGS[@]}" \
    --out-link "$REPO_DIR/result"

  log "🔄 Activating home-manager profile..."
  "$REPO_DIR/result/activate"
else
  # Fallback: use nix run directly
  log "📦 Building and activating via nix run..."
  nix run "$REPO_DIR#homeConfigurations.${HM_USER}.activationPackage" \
    "${NIX_BUILD_ARGS[@]}"
fi

# 2a. Reset stale nvim data dirs (plugins, LSP servers, treesitter parsers,
#     state, cache). They are derived state recreated by nvim, but stale
#     versions (e.g. from an AstroNvim major upgrade) can leave broken
#     treesitter parsers and plugins behind, so we wipe them each run.
#     Dirs are purged, not kept as <dir>.bak; opt out with NVIM_WIPE=0.
NVIM_WIPE="${NVIM_WIPE:-1}"
if [ "$NVIM_WIPE" = "1" ]; then
  for sub in share state cache; do
    target="$HOME/.local/$sub/nvim"
    if [ -e "$target" ] || [ -L "$target" ] || [ -e "${target}.bak" ] || [ -L "${target}.bak" ]; then
      rm -rf "$target" "${target}.bak"
      log "🧹 wiped ~/.local/$sub/nvim (+ stale .bak)"
    fi
  done
fi

# 3. Switch the login shell to pwsh (needs pwsh listed in /etc/shells first)
PW_SHELL="$(command -v pwsh 2>/dev/null || true)"
if [ -z "$PW_SHELL" ]; then
  # Try common Nix profile paths
  for candidate in \
    "$HOME/.nix-profile/bin/pwsh" \
    "/nix/var/nix/profiles/default/bin/pwsh" \
    "$HOME/.local/state/nix/profiles/home-manager/home-path/bin/pwsh"; do
    if [ -x "$candidate" ]; then
      PW_SHELL="$candidate"
      break
    fi
  done
fi
if [ -n "$PW_SHELL" ] && [ -x "$PW_SHELL" ]; then
  SHELL_READY=1
  if ! grep -qxF "$PW_SHELL" /etc/shells 2>/dev/null; then
    log "🔒 Adding $PW_SHELL to /etc/shells..."
    if ! echo "$PW_SHELL" | sudo tee -a /etc/shells >/dev/null; then
      warn "could not add $PW_SHELL to /etc/shells — as root, run: echo '$PW_SHELL' >> /etc/shells"
      SHELL_READY=0
    fi
  fi
  if [ "$SHELL_READY" = 1 ]; then
    CURRENT_SHELL="$(getent passwd "${USER:-$(id -un)}" | cut -d: -f7)"
    if [ "$CURRENT_SHELL" != "$PW_SHELL" ]; then
      log "🔁 Changing login shell to $PW_SHELL (log out/in to take effect)..."
      if ! sudo chsh -s "$PW_SHELL" "${USER:-$(id -un)}"; then
        warn "could not change login shell — as root, run: chsh -s '$PW_SHELL' '${USER:-$(id -un)}'"
      fi
    else
      log "✅ login shell is already $PW_SHELL"
    fi
  fi
else
  warn "pwsh not found; skipping login shell change"
fi

log "✅ Done. Log out and back in (or open a new shell), then run: pwsh"
