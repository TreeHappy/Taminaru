# --- Nix environment bootstrap ---
# pwsh is the login shell but does not source /etc/profile.d/nix.sh (that is
# bash/sh-only), so a fresh login shell misses the Nix profile PATH and TLS
# cert vars. Mirror the essential exports from nix-daemon.sh here.
$nixDefault = "/nix/var/nix/profiles/default"
$nixProfile = Join-Path $env:HOME ".nix-profile"

$env:NIX_PROFILES = "$nixDefault $nixProfile"
if (-not $env:NIX_SSL_CERT_FILE) {
  $env:NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"
}

foreach ($dir in @((Join-Path $nixProfile "bin"), (Join-Path $nixDefault "bin"))) {
  if ((Test-Path $dir) -and ($env:PATH -notmatch [regex]::Escape($dir))) {
    $env:PATH = "$dir$([IO.Path]::PathSeparator)$env:PATH"
  }
}

# pwsh keeps its own atuin history DB (separate from fish)
$env:ATUIN_DB_PATH = Join-Path $env:HOME ".local/share/atuin/pwsh/history.db"
Import-Module PSReadLine
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
$env:GIT_EXTERNAL_DIFF = "difft"

if ($IsWindows) {
    $env:HOME = $env:USERPROFILE
    $env:YAZI_FILE_ONE = "C:\Program Files\Git\usr\bin\file.exe"
    $env:STARSHIP_CONFIG = Join-Path $env:HOME ".config/starship.toml"
}
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
carapace _carapace powershell | Out-String | Invoke-Expression

Invoke-Expression (&starship init powershell)

Invoke-Expression (& { (zoxide init powershell | Out-String) })

Set-Alias ls eza
Set-Alias cat bat
if ($IsWindows) {
    Set-Alias zoxide zoxide.exe
    Set-Alias git git.exe
    Set-Alias docker docker.exe
    Set-Alias y yazi.exe
}



