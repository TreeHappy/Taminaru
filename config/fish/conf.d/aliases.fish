# Aliases (mirrors profile.ps1: Set-Alias ls eza; Set-Alias cat bat)
if command -vq eza
    alias ls eza
end
if command -vq bat
    alias cat bat
end
