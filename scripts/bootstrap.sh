#!/usr/bin/env bash
#
# Taminaru dotfiles bootstrap (bash).
#
# Provisions a fresh machine (tested on Ubuntu): installs mise (if missing),
# provisions every tool from mise.toml/mise.lock (including pwsh itself), sets
# mise.toml as the global mise config so tools work from anywhere, symlinks
# config/<tool>/ into ~/.config/<tool>/ so the repo stays the single source of
# truth, wires mise activation into the pwsh profile, applies catppuccin themes
# to the AI coding harnesses (pi/opencode/mammouth), and applies the default
# catppuccin theme. Idempotent and safe to re-run.
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
CONFIG_DIR="$REPO_DIR/config"
FLAVOR="${FLAVOR:-frappe}"
TAMINARU_USER="${TAMINARU_USER:-taminaru}"

log()  { printf '\033[1;34m[taminaru]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[taminaru]\033[0m ⚠️  %s\n' "$*"; }

log "✨ Taminaru dotfiles bootstrap — sit back, we've got this"

# 0. apt prerequisites: install everything apt can provide up front so every
#    later check in this script sees real state. apt-get is idempotent, so
#    re-runs are no-ops. As root we don't need sudo; otherwise sudo must
#    already be installed (see README.md).
export DEBIAN_FRONTEND="noninteractive"
APT_GET="apt-get"
if [ "$(id -u)" -ne 0 ]; then
  if ! command -v sudo >/dev/null 2>&1; then
    warn "sudo is missing — as root, run: apt-get install -y curl git sudo"
    exit 1
  fi
  APT_GET="sudo apt-get"
fi
log "📦 Installing apt packages (curl git sudo unzip build-essential libicu-dev ...)..."
$APT_GET update
$APT_GET install -y curl git sudo unzip ca-certificates libicu-dev \
  libssl3 libgssapi-krb5-2 zlib1g build-essential

# 0a. Fresh install: when running as root, create a non-root user so we don't
#     have to use root, then re-run the rest of this script as that user.
if [ "$(id -u)" -eq 0 ] && [ "$TAMINARU_USER" != "root" ]; then
  if ! id "$TAMINARU_USER" >/dev/null 2>&1; then
    log "👤 Creating user $TAMINARU_USER (passwordless, NOPASSWD sudo)..."
    useradd -m -s /bin/bash "$TAMINARU_USER"
    SUDOERS="/etc/sudoers.d/$TAMINARU_USER"
    printf '%s ALL=(ALL) NOPASSWD:ALL\n' "$TAMINARU_USER" > "$SUDOERS"
    chmod 440 "$SUDOERS"
    visudo -cf "$SUDOERS"
  else
    log "👤 user $TAMINARU_USER already exists"
  fi

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
export MISE_TRUSTED_CONFIG_PATHS="/"
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
log "🔧 Installing tools from mise.toml..."
(cd "$REPO_DIR" && "$MISE_BIN" install)

# 2b. Set this repo's mise.toml as the GLOBAL mise config so every tool is
#     available from anywhere (symlink keeps the repo the single source of truth).
MISE_GLOBAL_DIR="$HOME/.config/mise"
MISE_GLOBAL="$MISE_GLOBAL_DIR/config.toml"
mkdir -p "$MISE_GLOBAL_DIR"
if [ -e "$MISE_GLOBAL" ] && [ ! -L "$MISE_GLOBAL" ]; then
  warn "$MISE_GLOBAL exists and is not a symlink; moving to ${MISE_GLOBAL}.bak"
  mv "$MISE_GLOBAL" "${MISE_GLOBAL}.bak"
fi
ln -sf "$REPO_DIR/mise.toml" "$MISE_GLOBAL"
log "🌍 global mise config: $MISE_GLOBAL -> $REPO_DIR/mise.toml"

# 2c. Mammouth Code is provisioned via mise from github:mammouth-ai/code
#     (see [tool_alias] in mise.toml)

# 3. Symlink configs into ~/.config
# (opencode/mammouth keep their full dirs self-managed; only tui.json is linked below)
SKIP_DIRS="winget git opencode mammouth"
mkdir -p "$HOME/.config"
for dir in "$CONFIG_DIR"/*/; do
  name="$(basename "$dir")"
  case " $SKIP_DIRS " in
    *" $name "*) continue ;;
  esac
  target="$HOME/.config/$name"
  if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$(readlink -f "$dir")" ]; then
    continue
  fi
  if [ -e "$target" ] || [ -L "$target" ]; then
    warn "~/.config/$name exists and differs from the repo; moving to ${target}.bak"
    mv "$target" "${target}.bak"
  fi
  ln -s "$dir" "$target"
  log "🔗 linked ~/.config/$name -> $dir"
done

# 3a. Remove stale symlinks for tools that were dropped from the repo
#     (rofi/wofi/waybar/hypr). Only symlinks are removed; real dirs are kept.
for name in rofi wofi waybar hypr; do
  target="$HOME/.config/$name"
  if [ -L "$target" ]; then
    rm -f "$target"
    log "🧹 removed stale ~/.config/$name symlink"
  fi
done

# 3b. AI coding harness themes (managed files, idempotent). opencode/mammouth
#     manage their own config dirs, so only tui.json is linked; pi themes and
#     settings live under ~/.pi/agent.
mkdir -p "$HOME/.config/opencode"
ln -sf "$CONFIG_DIR/opencode/tui.json" "$HOME/.config/opencode/tui.json"
log "🔗 linked ~/.config/opencode/tui.json -> $CONFIG_DIR/opencode/tui.json"

mkdir -p "$HOME/.config/mammouth"
ln -sf "$CONFIG_DIR/mammouth/tui.json" "$HOME/.config/mammouth/tui.json"
log "🔗 linked ~/.config/mammouth/tui.json -> $CONFIG_DIR/mammouth/tui.json"

mkdir -p "$HOME/.pi/agent/themes"
for theme in "$CONFIG_DIR/pi/themes/"*.json; do
  ln -sf "$theme" "$HOME/.pi/agent/themes/$(basename "$theme")"
done
ln -sf "$CONFIG_DIR/pi/settings.json" "$HOME/.pi/agent/settings.json"
log "🔗 linked ~/.pi/agent/{themes,settings.json} -> $CONFIG_DIR/pi"

# 4. starship lives at ~/.config/starship.toml (not a subdirectory)
STARSHIP_TARGET="$HOME/.config/starship.toml"
if [ ! -e "$STARSHIP_TARGET" ] && [ -f "$CONFIG_DIR/starship/starship.toml" ]; then
  ln -s "$CONFIG_DIR/starship/starship.toml" "$STARSHIP_TARGET"
  log "🪐 linked ~/.config/starship.toml -> $CONFIG_DIR/starship/starship.toml"
fi

# 4b. atuin: force the local sqlite backend (managed file, idempotent)
ATUIN_DIR="$CONFIG_DIR/atuin"
mkdir -p "$ATUIN_DIR"
cat > "$ATUIN_DIR/config.toml" <<'EOF'
# atuin config (managed by scripts/bootstrap.sh)
db_path = "~/.local/share/atuin/history.db"
EOF
log "🗄️  wrote $ATUIN_DIR/config.toml (sqlite backend)"

# 5. pwsh: mise activation + profile wiring (managed files, idempotent)
PW_DIR="$CONFIG_DIR/powershell"
mkdir -p "$PW_DIR"
cat > "$PW_DIR/mise.ps1" <<'EOF'
# mise activation (managed by scripts/bootstrap.sh)
$mise = Join-Path $HOME ".local/bin/mise"
if (Get-Command mise -ErrorAction SilentlyContinue) {
    mise activate pwsh | Out-String | Invoke-Expression
} elseif (Test-Path $mise) {
    $env:PATH = (Join-Path $HOME ".local/bin") + ";" + $env:PATH
    & $mise activate pwsh | Out-String | Invoke-Expression
}
EOF

PROFILE="$PW_DIR/profile.ps1"
write_managed_block() {
  printf '%s\n' \
    '# --- Taminaru managed ---' \
    'if (Test-Path (Join-Path $PSScriptRoot "theme.ps1")) { . (Join-Path $PSScriptRoot "theme.ps1") }' \
    'if (Test-Path (Join-Path $PSScriptRoot "mise.ps1"))  { . (Join-Path $PSScriptRoot "mise.ps1") }' \
    '$taminaruTheme = Join-Path $PSScriptRoot "Modules/Taminaru.Theme/Taminaru.Theme.psm1"' \
    'if (Test-Path $taminaruTheme) { Import-Module $taminaruTheme -Force }' \
    '# --- /Taminaru managed ---'
}
if [ ! -f "$PROFILE" ]; then
  write_managed_block > "$PROFILE"
else
  if ! grep -q "# --- Taminaru managed ---" "$PROFILE"; then
    write_managed_block >> "$PROFILE"
  fi
fi
log "⚡ wrote $PW_DIR/mise.ps1 + ensured managed block in $PROFILE"

# 5b. Switch the login shell to pwsh (needs pwsh listed in /etc/shells first)
MISE_DATA_DIR="${MISE_DATA_DIR:-$HOME/.local/share/mise}"
PW_SHELL="$MISE_DATA_DIR/installs/powershell/latest/pwsh"
if [ ! -x "$PW_SHELL" ]; then
  PW_SHELL="$("$MISE_BIN" which powershell)"
fi
if [ -x "$PW_SHELL" ]; then
  if ! grep -qxF "$PW_SHELL" /etc/shells 2>/dev/null; then
    log "🔒 Adding $PW_SHELL to /etc/shells..."
    echo "$PW_SHELL" | sudo tee -a /etc/shells >/dev/null
  fi
  CURRENT_SHELL="$(getent passwd "${USER:-$(id -un)}" | cut -d: -f7)"
  if [ "$CURRENT_SHELL" != "$PW_SHELL" ]; then
    log "🔁 Changing login shell to $PW_SHELL (log out/in to take effect)..."
    sudo chsh -s "$PW_SHELL" "${USER:-$(id -un)}"
  else
    log "✅ login shell is already $PW_SHELL"
  fi
else
  warn "pwsh not found; skipping login shell change"
fi

# 6. Apply the default catppuccin theme via the mise-installed pwsh
log "🎨 Applying catppuccin $FLAVOR theme..."
"$MISE_BIN" x powershell -- pwsh -NoProfile -File "$REPO_DIR/scripts/theme.ps1" "$FLAVOR"

log "✅ Done. Log out and back in (or open a new shell), then run: pwsh"
