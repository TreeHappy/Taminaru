# mise activation (managed by chezmoi from dotfiles/)
# Point mise at the repo's mise.toml (no symlink); tools stay in ~/.local/share/mise.
export MISE_CONFIG_FILE="$HOME/Taminaru/mise.toml"
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate bash)"
elif [ -x "$HOME/.local/bin/mise" ]; then
    export PATH="$HOME/.local/bin:$PATH"
    eval "$("$HOME/.local/bin/mise" activate bash)"
fi