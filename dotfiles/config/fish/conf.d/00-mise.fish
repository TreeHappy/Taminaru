# mise activation (mirrors ~/.config/powershell/mise.ps1)
# Point mise at the repo's mise.toml (no symlink); tools stay in ~/.local/share/mise.
set -gx MISE_CONFIG_FILE "$HOME/Taminaru/mise.toml"
if command -vq mise
    mise activate fish | source
else if test -x "$HOME/.local/bin/mise"
    fish_add_path "$HOME/.local/bin"
    "$HOME/.local/bin/mise" activate fish | source
end
