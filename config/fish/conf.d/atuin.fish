# atuin shell history (mirrors profile.ps1: `atuin init powershell`)
# fish keeps its own atuin history DB (separate from pwsh)
set -gx ATUIN_DB_PATH "$HOME/.local/share/atuin/fish/history.db"

if command -vq atuin
    atuin init fish | source
end
