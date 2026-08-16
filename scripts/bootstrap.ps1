<#
.SYNOPSIS
  Taminaru dotfiles bootstrap (PowerShell).

.DESCRIPTION
  Installs mise (if missing), provisions all dev tools from mise.toml/mise.lock,
  symlinks every config/<tool>/ directory into ~/.config/<tool>/ so the repo
  remains the single source of truth, wires mise activation into pwsh, and
  applies the default catppuccin theme (frappe). Idempotent and safe to re-run.

.EXAMPLE
  .\scripts\bootstrap.ps1
  FLAVOR=macchiato .\scripts\bootstrap.ps1
#>
param(
    [string]$Flavor = "frappe"
)

$ErrorActionPreference = "Stop"

$RepoDir   = Split-Path -Parent $PSScriptRoot
$ConfigDir = Join-Path $RepoDir "config"
$HomeConfig = Join-Path $HOME ".config"

# Directories that must NOT be symlinked into ~/.config
$SkipDirs = @("winget", "git")

function Write-Log {
    param([string]$Message)
    Write-Host "[taminaru] $Message" -ForegroundColor Blue
}
function Write-Warn {
    param([string]$Message)
    Write-Host "[taminaru] $Message" -ForegroundColor Yellow
}

# 1. Install mise if missing
if (Get-Command mise -ErrorAction SilentlyContinue) {
    Write-Log "mise already installed: $(mise --version)"
} else {
    Write-Log "Installing mise..."
    Invoke-RestMethod https://mise.run/install.ps1 | Invoke-Expression
}

# 2. Provision tools (no-op when already installed; lockfile pins versions)
Write-Log "Installing tools from mise.toml..."
Push-Location $RepoDir
try {
    mise install
} finally {
    Pop-Location
}

# 3. Symlink configs into ~/.config
New-Item -ItemType Directory -Path $HomeConfig -Force | Out-Null
$subdirs = Get-ChildItem -Path $ConfigDir -Directory
foreach ($dir in $subdirs) {
    if ($SkipDirs -contains $dir.Name) { continue }
    $target = Join-Path $HomeConfig $dir.Name
    if (Test-Path $target) {
        $item = Get-Item $target -ErrorAction SilentlyContinue
        if ($item.LinkType -and (Resolve-Path $item.Target -ErrorAction SilentlyContinue).Path -eq $dir.FullName) {
            continue
        }
        Write-Warn "~/.config/$($dir.Name) exists and differs from the repo; moving to $target.bak"
        Move-Item $target "$target.bak" -Force
    }
    try {
        New-Item -ItemType SymbolicLink -Path $target -Target $dir.FullName | Out-Null
        Write-Log "linked ~/.config/$($dir.Name) -> $($dir.FullName)"
    } catch {
        Write-Warn "could not create symlink for $($dir.Name) (need admin/developer mode on Windows): $_"
    }
}

# 4. starship lives at ~/.config/starship.toml (not a subdirectory)
$StarshipTarget = Join-Path $HomeConfig "starship.toml"
$StarshipSrc = Join-Path $ConfigDir "starship/starship.toml"
if (-not (Test-Path $StarshipTarget) -and (Test-Path $StarshipSrc)) {
    New-Item -ItemType SymbolicLink -Path $StarshipTarget -Target $StarshipSrc | Out-Null
    Write-Log "linked ~/.config/starship.toml -> $StarshipSrc"
}

# 4b. atuin: force the local sqlite backend (managed file, idempotent)
$AtuinDir = Join-Path $ConfigDir "atuin"
New-Item -ItemType Directory -Path $AtuinDir -Force | Out-Null
$AtuinConfig = Join-Path $AtuinDir "config.toml"
$AtuinBlock = @'
# atuin config (managed by scripts/bootstrap.sh)
db_path = "~/.local/share/atuin/history.db"
'@
Set-Content -Path $AtuinConfig -Value $AtuinBlock -Encoding utf8NoBOM
Write-Log "wrote $AtuinConfig (sqlite backend)"

# 5. Wire mise activation into pwsh (managed files, idempotent)
$PwshDir = Join-Path $ConfigDir "powershell"
New-Item -ItemType Directory -Path $PwshDir -Force | Out-Null
$MiseFile = Join-Path $PwshDir "mise.ps1"
$MiseBlock = @'
# mise activation (managed by scripts/bootstrap.ps1)
if (Get-Command mise -ErrorAction SilentlyContinue) {
    mise activate pwsh | Out-String | Invoke-Expression
}
'@
Set-Content -Path $MiseFile -Value $MiseBlock -Encoding utf8NoBOM
Write-Log "wrote $MiseFile"

# Ensure profile.ps1 dot-sources the managed theme.ps1 + mise.ps1
$Profile = Join-Path $PwshDir "profile.ps1"
$ManagedBlock = @'
# --- Taminaru managed ---
if (Test-Path (Join-Path $PSScriptRoot "theme.ps1")) { . (Join-Path $PSScriptRoot "theme.ps1") }
if (Test-Path (Join-Path $PSScriptRoot "mise.ps1"))  { . (Join-Path $PSScriptRoot "mise.ps1") }
# --- /Taminaru managed ---
'@
if (-not (Test-Path $Profile)) {
    Set-Content -Path $Profile -Value $ManagedBlock -Encoding utf8NoBOM
    Write-Log "created $Profile"
} else {
    $content = Get-Content -Raw $Profile
    $pattern = '(?s)# --- Taminaru managed ---.*?# --- /Taminaru managed ---'
    if ($content -match $pattern) {
        $content = $content -replace $pattern, $ManagedBlock
    } else {
        $content = $content.TrimEnd("`r", "`n") + "`n`n" + $ManagedBlock + "`n"
    }
    Set-Content -Path $Profile -Value $content -NoNewline -Encoding utf8NoBOM
    Write-Log "updated $Profile"
}

# 6. Apply the default catppuccin theme
& (Join-Path $PSScriptRoot "theme.ps1") $Flavor

Write-Log "Done. Open a new pwsh to pick up mise + the configured tools."
