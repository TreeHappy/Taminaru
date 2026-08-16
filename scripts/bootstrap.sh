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
# Usage: bash scripts/bootstrap.sh
#        FLAVOR=macchiato bash scripts/bootstrap.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$REPO_DIR/config"
FLAVOR="${FLAVOR:-frappe}"

log()  { printf '\033[1;34m[taminaru]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[taminaru]\033[0m %s\n' "$*"; }

# 0. apt prerequisites (curl + git) - only when missing
if ! command -v curl >/dev/null 2>&1 || ! command -v git >/dev/null 2>&1; then
  log "Installing curl + git via apt..."
  sudo apt-get update
  sudo apt-get install -y curl git
fi

# Set environment variables for non-interactive installation
export DEBIAN_FRONTEND="noninteractive"
export MISE_TRUSTED_CONFIG_PATHS="/"
export MISE_SYSTEM_DEPS="auto"

# 1. Install mise if missing
if command -v mise >/dev/null 2>&1; then
  MISE_BIN="$(command -v mise)"
  log "mise already installed: $(mise --version)"
else
  log "Installing mise..."
  curl -fsSL https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
  MISE_BIN="$HOME/.local/bin/mise"
fi

# 2. Provision tools (no-op when already installed; lockfile pins versions)
log "Installing tools from mise.toml..."
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
log "global mise config: $MISE_GLOBAL -> $REPO_DIR/mise.toml"

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
  log "linked ~/.config/$name -> $dir"
done

# 3a. Remove stale symlinks for tools that were dropped from the repo
#     (rofi/wofi/waybar/hypr). Only symlinks are removed; real dirs are kept.
for name in rofi wofi waybar hypr; do
  target="$HOME/.config/$name"
  if [ -L "$target" ]; then
    rm -f "$target"
    log "removed stale ~/.config/$name symlink"
  fi
done

# 3b. AI coding harness themes (managed files, idempotent). opencode/mammouth
#     manage their own config dirs, so only tui.json is linked; pi themes and
#     settings live under ~/.pi/agent.
mkdir -p "$HOME/.config/opencode"
ln -sf "$CONFIG_DIR/opencode/tui.json" "$HOME/.config/opencode/tui.json"
log "linked ~/.config/opencode/tui.json -> $CONFIG_DIR/opencode/tui.json"

mkdir -p "$HOME/.config/mammouth"
ln -sf "$CONFIG_DIR/mammouth/tui.json" "$HOME/.config/mammouth/tui.json"
log "linked ~/.config/mammouth/tui.json -> $CONFIG_DIR/mammouth/tui.json"

mkdir -p "$HOME/.pi/agent/themes"
for theme in "$CONFIG_DIR/pi/themes/"*.json; do
  ln -sf "$theme" "$HOME/.pi/agent/themes/$(basename "$theme")"
done
ln -sf "$CONFIG_DIR/pi/settings.json" "$HOME/.pi/agent/settings.json"
log "linked ~/.pi/agent/{themes,settings.json} -> $CONFIG_DIR/pi"

# 4. starship lives at ~/.config/starship.toml (not a subdirectory)
STARSHIP_TARGET="$HOME/.config/starship.toml"
if [ ! -e "$STARSHIP_TARGET" ] && [ -f "$CONFIG_DIR/starship/starship.toml" ]; then
  ln -s "$CONFIG_DIR/starship/starship.toml" "$STARSHIP_TARGET"
  log "linked ~/.config/starship.toml -> $CONFIG_DIR/starship/starship.toml"
fi

# 4b. atuin: force the local sqlite backend (managed file, idempotent)
ATUIN_DIR="$CONFIG_DIR/atuin"
mkdir -p "$ATUIN_DIR"
cat > "$ATUIN_DIR/config.toml" <<'EOF'
# atuin config (managed by scripts/bootstrap.sh)
db_path = "~/.local/share/atuin/history.db"
EOF
log "wrote $ATUIN_DIR/config.toml (sqlite backend)"

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
log "wrote $PW_DIR/mise.ps1 + ensured managed block in $PROFILE"

# 6. Apply the default catppuccin theme via the mise-installed pwsh
log "Applying catppuccin $FLAVOR theme..."
"$MISE_BIN" x powershell -- pwsh -NoProfile -File "$REPO_DIR/scripts/theme.ps1" "$FLAVOR"

log "Done. Open a new shell, then run: pwsh"
