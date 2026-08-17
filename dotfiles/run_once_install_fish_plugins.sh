#!/usr/bin/env bash
# run_once_install_fish_plugins.sh — Install fish plugins (catppuccin theme).
# Runs once on first chezmoi apply. Safe to re-run (idempotent).
set -euo pipefail

# Install fisher (fish plugin manager) if not present
if ! command -v fish &>/dev/null; then
    exit 0  # fish not installed, skip
fi

FISHER_PATH="$(fish -c 'echo $__fish_config_dir/functions/fisher.fish' 2>/dev/null || true)"
if [ ! -f "$FISHER_PATH" ]; then
    echo "[taminaru] Installing fisher..."
    fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
fi

# Install catppuccin theme for fish
echo "[taminaru] Installing catppuccin fish theme..."
fish -c 'fisher install catppuccin/fish'
