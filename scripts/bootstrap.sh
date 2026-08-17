#!/usr/bin/env bash
#
# Taminaru dotfiles bootstrap (bash).
#
# Provisions a fresh machine (tested on Ubuntu): installs mise (if missing),
# provisions every tool from mise.toml/mise.lock (including pwsh and chezmoi),
# points mise at this repo's mise.toml via MISE_CONFIG_FILE, applies the
# dotfiles with chezmoi (no symlinks) from dotfiles/, wires mise activation
# into the bash + pwsh profiles, applies catppuccin themes to the AI coding
# harnesses (pi/opencode/mammouth), and applies the default catppuccin theme.
# Idempotent and safe to re-run.
#
# Each run also purges the nvim data dirs (~/.local/{share,state,cache}/nvim,
# and any stale .bak leftovers) so plugins and treesitter parsers are always
# reinstalled from the current config — opt out with NVIM_WIPE=0.
#
# Running as root on a fresh Ubuntu first creates a non-root user (default:
# taminaru, passwordless with NOPASSWD sudo), copies this repo into their home,
# and re-runs the whole bootstrap as that user.
#
# Usage: bash scripts/bootstrap.sh
#        FLAVOR=macchiato bash scripts/bootstrap.sh
#        TAMINARU_USER=bob bash scripts/bootstrap.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$REPO_DIR/dotfiles/dot_config"
FLAVOR="${FLAVOR:-frappe}"
TAMINARU_USER="${TAMINARU_USER:-taminaru}"

log()  { printf '\033[1;34m[taminaru]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[taminaru]\033[0m ⚠️  %s\n' "$*"; }

log "✨ Taminaru dotfiles bootstrap — sit back, we've got this"

# 0. apt prerequisites: install everything apt can provide up front so every
#    later check in this script sees real state. apt-get is idempotent, so
#    re-runs are no-ops. As root we don't need sudo; otherwise sudo must
#    already be installed (see README.md).
#    build-essential (cc/gcc) is required for nvim's treesitter parsers, so it
#    is installed here BEFORE the passwordless-sudo check below.
export DEBIAN_FRONTEND="noninteractive"
APT_GET="apt-get"
if [ "$(id -u)" -ne 0 ]; then
  if ! command -v sudo >/dev/null 2>&1; then
    warn "sudo is missing — as root, run: apt-get install -y curl git sudo"
    exit 1
  fi
  APT_GET="sudo apt-get"
fi
log "📦 Installing apt packages (curl git sudo unzip xz-utils build-essential libreadline-dev libicu-dev ...)..."
$APT_GET update
$APT_GET install -y curl git sudo unzip xz-utils ca-certificates libicu-dev \
  libssl3 libgssapi-krb5-2 zlib1g build-essential \
  libreadline-dev # readline headers for lazy.nvim's hererocks to build the sandboxed Lua 5.1 needed by image.nvim/magick luarocks

# 0a. Validate passwordless sudo (needed for /etc/shells, chsh, and the
#     sudoers self-heal on fresh installs). Runs after apt so the required
#     packages above are already on the machine.
if [ "$(id -u)" -ne 0 ]; then
  if ! sudo -n true 2>/dev/null; then
    warn "$(id -un) needs passwordless sudo — as root, run: echo '$(id -un) ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$(id -un) && chmod 440 /etc/sudoers.d/$(id -un)"
    exit 1
  fi
fi

# 0b. Fresh install: when running as root, create a non-root user so we don't
#     have to use root, then re-run the rest of this script as that user.
if [ "$(id -u)" -eq 0 ] && [ "$TAMINARU_USER" != "root" ]; then
  if ! id "$TAMINARU_USER" >/dev/null 2>&1; then
    log "👤 Creating user $TAMINARU_USER (passwordless, NOPASSWD sudo)..."
    useradd -m -s /bin/bash "$TAMINARU_USER"
  else
    log "👤 user $TAMINARU_USER already exists"
  fi

  SUDOERS="/etc/sudoers.d/$TAMINARU_USER"
  log "🔒 Ensuring $TAMINARU_USER has passwordless sudo..."
  printf '%s ALL=(ALL) NOPASSWD:ALL\n' "$TAMINARU_USER" > "$SUDOERS"
  chmod 440 "$SUDOERS"
  visudo -cf "$SUDOERS"

  if ! grep -qE '^[#@]includedir[[:space:]]+/etc/sudoers\.d' /etc/sudoers 2>/dev/null; then
    SUDOERS_TMP="$(mktemp /etc/sudoers.XXXXXX)"
    cat /etc/sudoers > "$SUDOERS_TMP"
    printf '\n@includedir /etc/sudoers.d\n' >> "$SUDOERS_TMP"
    if visudo -cf "$SUDOERS_TMP" >/dev/null 2>&1; then
      install -m 0440 "$SUDOERS_TMP" /etc/sudoers
      log "🔧 added @includedir /etc/sudoers.d to /etc/sudoers"
    else
      warn "could not add @includedir /etc/sudoers.d to /etc/sudoers"
    fi
    rm -f "$SUDOERS_TMP"
  fi

  if ! runuser -u "$TAMINARU_USER" -- sudo -n true 2>/dev/null; then
    warn "passwordless sudo for $TAMINARU_USER is not effective after writing $SUDOERS"
    warn "check that /etc/sudoers includes '@includedir /etc/sudoers.d' and that sudo-rs >= 0.2.14 is installed (0.2.13 has an /etc/group long-line bug)"
    exit 1
  fi
  log "🔑 passwordless sudo verified for $TAMINARU_USER"

  USER_HOME="$(getent passwd "$TAMINARU_USER" | cut -d: -f6)"
  USER_REPO="$USER_HOME/Taminaru"
  if [ ! -d "$USER_REPO" ]; then
    log "📂 Copying repo to $USER_REPO..."
    cp -a "$REPO_DIR" "$USER_REPO"
    chown -R "$TAMINARU_USER:$TAMINARU_USER" "$USER_REPO"
  fi

  log "🔁 Re-running bootstrap as $TAMINARU_USER..."
  runuser -u "$TAMINARU_USER" -- env FLAVOR="$FLAVOR" bash "$USER_REPO/scripts/bootstrap.sh" "$@"
  exit $?
fi

# Set environment variables for non-interactive installation
export MISE_SYSTEM_DEPS="auto"

# 1. Install mise if missing
if command -v mise >/dev/null 2>&1; then
  MISE_BIN="$(command -v mise)"
  log "🚀 mise already installed: $(mise --version)"
else
  log "🚀 Installing mise..."
  curl -fsSL https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
  MISE_BIN="$HOME/.local/bin/mise"
fi

# 2. Provision tools (no-op when already installed; lockfile pins versions)
# Trust the repo config explicitly (persisted) rather than trusting "/":
# newer mise ignores trusted_config_paths from a project config, and trusting
# "/" is a security hole. This makes mise install and every shell that loads
# the config via MISE_CONFIG_FILE accept it without prompting.
log "🔐 Trusting $REPO_DIR/mise.toml..."
"$MISE_BIN" trust "$REPO_DIR/mise.toml"

log "🔧 Installing tools from mise.toml..."
(cd "$REPO_DIR" && "$MISE_BIN" install)

# 2b. Global mise config: tools are provisioned from this repo's mise.toml,
#     which is trusted (see [settings] trusted_config_paths). The managed shell
#     files under dotfiles/ point mise at it via MISE_CONFIG_FILE, so no symlink
#     is created here.
log "🌍 global mise config: \$HOME/Taminaru/mise.toml (via MISE_CONFIG_FILE in dotfiles)"

# 2c. Mammouth Code is provisioned via mise from github:mammouth-ai/code
#     (see [tool_alias] in mise.toml)

# 3. Apply dotfiles with chezmoi (no symlinks). The source dir is
#     $REPO_DIR/dotfiles, which holds config in chezmoi's dot_* layout; chezmoi
#     materializes REAL files into $HOME so the machine stands alone while the
#     repo stays the single source of truth.
log "🎯 Applying dotfiles with chezmoi (source: \$REPO_DIR/dotfiles)..."
CHEZMOI_SOURCE="$REPO_DIR/dotfiles"
"$MISE_BIN" x chezmoi -- chezmoi --source "$CHEZMOI_SOURCE" apply --force

# 3a. Reset stale nvim data dirs (plugins, LSP servers, treesitter parsers,
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

# 3b. Install pi packages (coding-agent plugins/extensions) declared in the
#     "packages" array of ~/.pi/agent/settings.json (applied by chezmoi above).
#     `pi install` is idempotent: it ensures each package is present and runs
#     npm install for its dependencies. pi itself is provisioned by mise.
PI_PACKAGES="$(grep -oE '"npm:[^"]+"' "$HOME/.pi/agent/settings.json" 2>/dev/null | tr -d '"' || true)"
for pkg in $PI_PACKAGES; do
  if "$MISE_BIN" x pi -- pi install "$pkg" >/dev/null 2>&1; then
    log "🧩 pi package ready: $pkg"
  else
    warn "could not install pi package: $pkg"
  fi
done

# 4. starship, atuin, pwsh/bash profiles and mise activation are all
#    chezmoi-managed (applied in step 3) — nothing to symlink or write here.

# 5b. Switch the login shell to pwsh (needs pwsh listed in /etc/shells first)
MISE_DATA_DIR="${MISE_DATA_DIR:-$HOME/.local/share/mise}"
PW_SHELL="$MISE_DATA_DIR/installs/powershell/latest/pwsh"
if [ ! -x "$PW_SHELL" ]; then
  PW_SHELL="$("$MISE_BIN" which powershell)"
fi
if [ -x "$PW_SHELL" ]; then
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

# 6. Apply the default catppuccin theme via the mise-installed pwsh
log "🎨 Applying catppuccin $FLAVOR theme..."
(cd "$REPO_DIR" && "$MISE_BIN" x -- pwsh -NoProfile -File "$REPO_DIR/scripts/theme.ps1" "$FLAVOR")

# 6b. The theme switch edits files in the chezmoi source dir; re-apply so the
#     updated theme reaches $HOME.
"$MISE_BIN" x chezmoi -- chezmoi --source "$CHEZMOI_SOURCE" apply

log "✅ Done. Log out and back in (or open a new shell), then run: pwsh"
