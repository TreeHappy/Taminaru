# mise activation (managed by chezmoi from dotfiles/)
# Point mise at the repo's mise.toml (no symlink); tools stay in ~/.local/share/mise.
export MISE_CONFIG_FILE="$HOME/Taminaru/mise.toml"
eval "$(mise activate bash)"