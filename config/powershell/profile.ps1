$env:HOME = $env:USERPROFILE
$env:EDITOR = "nvim"
$env:YAZI_FILE_ONE = "C:\Program Files\Git\usr\bin\file.exe"
$env:YAZI_CONFIG_HOME = Join-Path $env:HOME ".config/yazi/"
$env:XDG_CONFIG_HOME = Join-Path $env:HOME ".config"
$env:CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
$env:LS_COLORS = "$(vivid generate catppuccin-frappe)"
$env:GIT_EXTERNAL_DIFF = "difft"

Set-PSReadLineOption -Colors @{ "Selection" = "`e[7m" }
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
carapace _carapace | Out-String | Invoke-Expression

function rep
{
  . $PROFILE
  Clear-Host
}

Set-Alias ls eza
Set-Alias cat bat
Set-Alias zoxide zoxide.exe
Set-Alias git git.exe
