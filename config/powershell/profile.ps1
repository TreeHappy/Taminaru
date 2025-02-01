$env:HOME = $env:USERPROFILE
$env:EDITOR = "nvim"
$env:YAZI_FILE_ONE = "C:\Program Files\Git\usr\bin\file.exe"
$env:YAZI_CONFIG_HOME = Join-Path $env:HOME ".config/yazi/"
$env:XDG_CONFIG_HOME = Join-Path $env:HOME ".config"

Invoke-Expression (& { (zoxide init powershell | Out-String) })
Invoke-Expression (&starship init powershell)

$env:CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
Set-PSReadLineOption -Colors @{ "Selection" = "`e[7m" }
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
carapace _carapace | Out-String | Invoke-Expression

$env:LS_COLORS="$(vivid generate catppuccin-frappe)"

Set-Alias ls eza
Set-Alias cat bat

