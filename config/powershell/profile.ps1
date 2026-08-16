# --- Taminaru managed: activate mise before any tool init ---
if (Test-Path (Join-Path $PSScriptRoot "mise.ps1")) { . (Join-Path $PSScriptRoot "mise.ps1") }

if (Get-Command atuin -ErrorAction SilentlyContinue) { atuin init powershell | Out-String | Invoke-Expression }

# --- Atuin AI: '?' on an empty prompt (managed by Taminaru) ---
if ((Get-Command atuin -ErrorAction SilentlyContinue) -and (Get-Command sh -ErrorAction SilentlyContinue)) {
    function Invoke-AtuinAiQuestionMark {
        $line = ""
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$null)
        if ($line -eq "" -or $line -eq "?") {
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, "")
            $output = (sh -c 'atuin ai inline --hook 3>&1 1>&2 2>&3' 2>&1 | Out-String).Trim()
            switch -Regex ($output) {
                '^__atuin_ai_execute__:(.*)$' {
                    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, 0, $Matches[1])
                    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
                }
                '^__atuin_ai_insert__:(.*)$' {
                    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, 0, $Matches[1])
                }
                '^__atuin_ai_print__:(.*)$' {
                    Write-Host $Matches[1]
                }
                default {
                    if ($output -and $output -notmatch '^__atuin_ai_cancel__$') {
                        [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, 0, $output)
                    }
                }
            }
        } else {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("?")
        }
    }
    Set-PSReadLineKeyHandler -Key "?" -BriefDescription "Atuin AI" -ScriptBlock { Invoke-AtuinAiQuestionMark }
}

$env:EDITOR = "nvim"
$env:YAZI_CONFIG_HOME = Join-Path $env:HOME ".config/yazi/"
$env:XDG_CONFIG_HOME = Join-Path $env:HOME ".config"
$env:CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
$env:LS_COLORS = "$(vivid generate catppuccin-frappe)"
$env:GIT_EXTERNAL_DIFF = "difft"

if ($IsWindows) {
    $env:HOME = $env:USERPROFILE
    $env:YAZI_FILE_ONE = "C:\Program Files\Git\usr\bin\file.exe"
    $env:STARSHIP_CONFIG = "${env:USERPROFILE}\.config\starship\starship.toml"
}

Set-PSReadLineOption -Colors @{ "Selection" = "`e[7m" }
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
carapace _carapace | Out-String | Invoke-Expression

Invoke-Expression (&starship init powershell)

Invoke-Expression (& { (zoxide init powershell | Out-String) })

Set-Alias ls eza
Set-Alias cat bat
if ($IsWindows) {
    Set-Alias zoxide zoxide.exe
    Set-Alias git git.exe
    Set-Alias docker docker.exe
    Set-Alias chezmoi chezmoi.exe
    Set-Alias y yazi.exe
}

# --- Taminaru managed ---
if (Test-Path (Join-Path $PSScriptRoot "theme.ps1")) { . (Join-Path $PSScriptRoot "theme.ps1") }
$taminaruTheme = Join-Path $PSScriptRoot "Modules/Taminaru.Theme/Taminaru.Theme.psm1"
if (Test-Path $taminaruTheme) { Import-Module $taminaruTheme -Force }
# --- /Taminaru managed ---

