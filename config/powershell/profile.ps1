$env:HOME = $env:USERPROFILE
$env:EDITOR = "nvim"
$env:YAZI_FILE_ONE = "C:\Program Files\Git\usr\bin\file.exe"
$env:YAZI_CONFIG_HOME = Join-Path $env:HOME ".config/yazi/"
$env:XDG_CONFIG_HOME = Join-Path $env:HOME ".config"
$env:CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
$env:LS_COLORS = "$(vivid generate catppuccin-frappe)"
$env:GIT_EXTERNAL_DIFF = "difft"
$env:STARSHIP_CONFIG = "${env:USERPROFILE}\.config\starship\starship.toml"

Invoke-Expression (& { (zoxide init powershell | Out-String) })

Set-PSReadLineOption -Colors @{ "Selection" = "`e[7m" }
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
carapace _carapace | Out-String | Invoke-Expression

Invoke-Expression (&starship init powershell)

function rep
{
  . $PROFILE
  Clear-Host
}

Set-Alias ls eza
Set-Alias cat bat
Set-Alias zoxide zoxide.exe
Set-Alias git git.exe
Set-Alias docker docker.exe
Set-Alias chezmoi chezmoi.exe
Set-Alias y yazi.exe

