<#
.SYNOPSIS
  Taminaru theme switching via tinty (Tinted Theming).

.DESCRIPTION
  Exposes Set-TaminaruTheme to switch every tool the dotfiles configure to a
  supported base16/base24 scheme, and Get-TaminaruTheme to report the current.

  Loaded from $PROFILE (see config/powershell/profile.ps1).
#>

$Script:RepoDir = $null

function Get-TaminaruRepoDir {
    if ($Script:RepoDir) { return $Script:RepoDir }
    $repoDir = $null
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        $top = git -C $PSScriptRoot rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0 -and $top) { $repoDir = $top }
    }
    if (-not $repoDir) {
        $dir = $PSScriptRoot
        while ($dir) {
            if (Test-Path (Join-Path $dir "mise.toml")) { $repoDir = $dir; break }
            $parent = Split-Path -Parent $dir
            if ($parent -eq $dir) { break }
            $dir = $parent
        }
    }
    if (-not $repoDir -and (Test-Path (Join-Path $HOME "Taminaru/mise.toml"))) {
        $repoDir = Join-Path $HOME "Taminaru"
    }
    $Script:RepoDir = $repoDir
    return $repoDir
}

function Get-ValidFlavors {
    $themesMd = Join-Path $PSScriptRoot "themes.md"
    $flavors = @()

    # Try mdq first
    $mdq = Get-Command mdq -ErrorAction SilentlyContinue
    if ($mdq -and (Test-Path $themesMd)) {
            $result = & mdq --output plain '-' $themesMd 2>$null
        if ($LASTEXITCODE -eq 0) {
            $flavors = $result | ForEach-Object {
                ($_ -replace '^\s*-\s+', '').Trim()
            } | Where-Object { $_ -ne '' }
        }
    }

    # Fallback: fetch from GitHub
    if ($flavors.Count -eq 0) {
        try {
            $url = "https://raw.githubusercontent.com/TreeHappy/Taminaru/chezmoi/dotfiles/dot_config/powershell/Modules/Taminaru.Theme/themes.md"
            $response = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop
            $lines = $response.Content -split "`n"
            $flavors = $lines | ForEach-Object {
                if ($_ -match '^\s*-\s+(.+)') { $Matches[1].Trim() }
            } | Where-Object { $_ -ne '' }
        } catch {}
    }

    # Fallback: static list
    if ($flavors.Count -eq 0) {
        $flavors = @(
            'catppuccin-frappe', 'catppuccin-latte', 'catppuccin-macchiato', 'catppuccin-mocha',
            'everforest', 'everforest-dark-hard'
        )
    }

    return $flavors
}

function Get-TaminaruTheme {
    $currentSchemeFile = Join-Path $HOME ".local/share/tinted-theming/tinty/artifacts/current_scheme"
    if (Test-Path $currentSchemeFile) {
        return (Get-Content -Raw $currentSchemeFile).Trim()
    }
    # Fallback: read from ghostty
    $ghostty = Join-Path $HOME ".config/ghostty/config"
    if (Test-Path $ghostty) {
        $line = Get-Content $ghostty | Where-Object { $_ -match '^theme = "([^"]+)"' } | Select-Object -First 1
        if ($line -and $line -match '^theme = "([^"]+)"') {
            return $Matches[1]
        }
    }
    return "catppuccin-frappe"
}

function Set-TaminaruTheme {
    <#
    .SYNOPSIS
      Switches every tool to the given base16/base24 scheme via tinty.

    .PARAMETER Flavor
      Scheme name (e.g. catppuccin-frappe, everforest-dark-hard).
    #>
    param(
        [string]
        [ArgumentCompleter({
            param($cmd, $param, $wordToComplete, $commandAst, $fakeBoundParameters)
            $flavors = Get-ValidFlavors
            $flavors | Where-Object { $_ -like "$wordToComplete*" } |
                ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }
        })]
        $Flavor = "catppuccin-frappe"
    )

    $ErrorActionPreference = "Stop"

    # Ensure tinty is available
    $tinty = Get-Command tinty -ErrorAction SilentlyContinue
    if (-not $tinty) {
        throw "tinty not found — run: mise install github:tinted-theming/tinty"
    }

    Write-Host "[theme] Applying scheme: $Flavor" -ForegroundColor Blue

    # Map short names to tinty scheme names if needed
    $schemeName = $Flavor
    if ($Flavor -match '^(frappe|latte|macchiato|mocha)$') {
        $schemeName = "catppuccin-$Flavor"
    }

    tinty apply "base16-$schemeName"
    if ($LASTEXITCODE -ne 0) {
        # Try without base16 prefix
        tinty apply "$schemeName"
        if ($LASTEXITCODE -ne 0) {
            throw "tinty apply failed for scheme '$schemeName'"
        }
    }

    Write-Host "[theme] Scheme applied: $schemeName" -ForegroundColor Blue
}

function Update-Taminaru {
    <#
    .SYNOPSIS
      Updates Taminaru: pulls latest repo changes and re-applies dotfiles via chezmoi.
    #>
    $ErrorActionPreference = "Stop"

    $RepoDir = Join-Path $HOME "Taminaru"
    if (-not (Test-Path $RepoDir)) {
        throw "Taminaru repo not found at '$RepoDir'"
    }

    Write-Host "[taminaru] Pulling latest changes..." -ForegroundColor Blue
    git -C $RepoDir pull --ff-only
    if ($LASTEXITCODE -ne 0) { throw "git pull failed (exit $LASTEXITCODE)" }

    $ChezmoiSource = Join-Path $RepoDir "dotfiles"
    Write-Host "[taminaru] Re-applying dotfiles with chezmoi..." -ForegroundColor Blue
    if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
        chezmoi --source "$ChezmoiSource" apply
    } elseif (Get-Command mise -ErrorAction SilentlyContinue) {
        mise x chezmoi -- chezmoi --source "$ChezmoiSource" apply
    } else {
        throw "chezmoi not found — install via: mise install github:twpayne/chezmoi"
    }
    if ($LASTEXITCODE -ne 0) { throw "chezmoi apply failed (exit $LASTEXITCODE)" }

    Write-Host "[taminaru] Re-applying theme..." -ForegroundColor Blue
    Set-TaminaruTheme (Get-TaminaruTheme)

    Write-Host "[taminaru] Done. Taminaru is up to date." -ForegroundColor Blue
}

Export-ModuleMember -Function Set-TaminaruTheme, Get-TaminaruTheme, Get-TaminaruRepoDir, Update-Taminaru, Get-ValidFlavors
