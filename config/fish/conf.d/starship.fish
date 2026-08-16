# starship prompt (mirrors profile.ps1: `starship init powershell`)
if command -vq starship
    starship init fish | source
end
