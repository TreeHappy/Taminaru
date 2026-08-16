# mise activation (mirrors ~/.config/powershell/mise.ps1)
if command -vq mise
    mise activate fish | source
else if test -x "$HOME/.local/bin/mise"
    fish_add_path "$HOME/.local/bin"
    "$HOME/.local/bin/mise" activate fish | source
end
