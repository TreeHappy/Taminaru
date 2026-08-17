<#
.SYNOPSIS
  Taminaru theme switching (module).

.DESCRIPTION
  Exposes Set-TaminaruTheme to switch every tool the dotfiles configure to a
  supported theme (catppuccin flavors + everforest), and Get-TaminaruTheme to
  report the currently active theme.

  Loaded from $PROFILE (see config/powershell/profile.ps1), so the functions
  are available in every pwsh session.
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

# ---------------------------------------------------------------------------
# Theme registry: every supported theme and its properties
# ---------------------------------------------------------------------------
$Script:ThemeRegistry = $null

function Get-ThemeRegistry {
    if ($Script:ThemeRegistry) { return $Script:ThemeRegistry }

    $RepoDir = Get-TaminaruRepoDir
    $ConfigDir = Join-Path $RepoDir "dotfiles/dot_config"

    $Script:ThemeRegistry = @{

        # ========================= Catppuccin =========================
        'latte' = @{
            Family   = 'catppuccin'
            Variant  = 'light'
            Title    = 'Latte'
            Palette  = @{
                rosewater = 'dc8a78'; flamingo = 'dd7878'; pink = 'ea76cb'; mauve = '8839ef'
                red = 'd20f39'; maroon = 'e64553'; peach = 'fe640b'; yellow = 'df8e1d'
                green = '40a02b'; teal = '179299'; sky = '04a5e5'; sapphire = '209fb5'
                blue = '1e66f5'; lavender = '7287fd'
                text = '4c4f69'; subtext1 = '5c5f77'; subtext0 = '6c6f85'
                overlay2 = '7c7f93'; overlay1 = '8c8fa1'; overlay0 = '9ca0b0'
                surface2 = 'acb0be'; surface1 = 'ccd0da'; surface0 = 'eff1f5'
                base = 'eff1f5'; mantle = 'e6e9ef'; crust = 'dce0e8'
            }
            Ghostty     = 'Catppuccin Latte'
            WezTerm     = 'Catppuccin Latte (Gogh)'
            Vivid       = 'catppuccin-latte'
            BatTheme    = 'Catppuccin Latte'
            Pi          = 'catppuccin-latte'
            Opencode    = 'catppuccin'
            Mammouth    = 'catppuccin'
            Fish        = 'catppuccin'
            NvimFamily  = 'catppuccin'
            NvimColorscheme = 'catppuccin-latte'
        }
        'frappe' = @{
            Family   = 'catppuccin'
            Variant  = 'dark'
            Title    = 'Frappe'
            Palette  = @{
                rosewater = 'f2d5cf'; flamingo = 'eebebe'; pink = 'f4b8e4'; mauve = 'ca9ee6'
                red = 'e78284'; maroon = 'ea999c'; peach = 'ef9f76'; yellow = 'e5c890'
                green = 'a6d189'; teal = '81c8be'; sky = '99d1db'; sapphire = '85c1dc'
                blue = '8caaee'; lavender = 'babbf1'
                text = 'c6d0f5'; subtext1 = 'b5bfe2'; subtext0 = 'a5adce'
                overlay2 = '949cbb'; overlay1 = '838ba7'; overlay0 = '737994'
                surface2 = '626880'; surface1 = '51576d'; surface0 = '414559'
                base = '303446'; mantle = '292c3c'; crust = '232634'
            }
            Ghostty     = 'Catppuccin Frappe'
            WezTerm     = 'Catppuccin Frappe (Gogh)'
            Vivid       = 'catppuccin-frappe'
            BatTheme    = 'Catppuccin Frappe'
            Pi          = 'catppuccin-mocha'
            Opencode    = 'catppuccin-frappe'
            Mammouth    = 'catppuccin-frappe'
            Fish        = 'catppuccin'
            NvimFamily  = 'catppuccin'
            NvimColorscheme = 'catppuccin-frappe'
        }
        'macchiato' = @{
            Family   = 'catppuccin'
            Variant  = 'dark'
            Title    = 'Macchiato'
            Palette  = @{
                rosewater = 'f4dbd6'; flamingo = 'f0c6c6'; pink = 'f5bde6'; mauve = 'c6a0f6'
                red = 'ed8796'; maroon = 'ee99a0'; peach = 'f5a97f'; yellow = 'eed49f'
                green = 'a6da95'; teal = '8bd5ca'; sky = '91d7e3'; sapphire = '7dc4e4'
                blue = '8aadf4'; lavender = 'b7bdf8'
                text = 'cad3f5'; subtext1 = 'b8c0e0'; subtext0 = 'a5adcb'
                overlay2 = '939ab7'; overlay1 = '8087a2'; overlay0 = '6e738d'
                surface2 = '5b6078'; surface1 = '494d64'; surface0 = '363a4f'
                base = '24273a'; mantle = '1e2030'; crust = '181926'
            }
            Ghostty     = 'Catppuccin Macchiato'
            WezTerm     = 'Catppuccin Macchiato (Gogh)'
            Vivid       = 'catppuccin-macchiato'
            BatTheme    = 'Catppuccin Macchiato'
            Pi          = 'catppuccin-mocha'
            Opencode    = 'catppuccin-macchiato'
            Mammouth    = 'catppuccin-macchiato'
            Fish        = 'catppuccin'
            NvimFamily  = 'catppuccin'
            NvimColorscheme = 'catppuccin-macchiato'
        }
        'mocha' = @{
            Family   = 'catppuccin'
            Variant  = 'dark'
            Title    = 'Mocha'
            Palette  = @{
                rosewater = 'f5e0dc'; flamingo = 'f2cdcd'; pink = 'f5c2e7'; mauve = 'cba6f7'
                red = 'f38ba8'; maroon = 'eba0ac'; peach = 'fab387'; yellow = 'f9e2af'
                green = 'a6e3a1'; teal = '94e2d5'; sky = '89dceb'; sapphire = '74c7ec'
                blue = '89b4fa'; lavender = 'b4befe'
                text = 'cdd6f4'; subtext1 = 'bac2de'; subtext0 = 'a6adc8'
                overlay2 = '9399b2'; overlay1 = '7f849c'; overlay0 = '6c7086'
                surface2 = '585b70'; surface1 = '45475a'; surface0 = '313244'
                base = '1e1e2e'; mantle = '181825'; crust = '11111b'
            }
            Ghostty     = 'Catppuccin Mocha'
            WezTerm     = 'Catppuccin Mocha (Gogh)'
            Vivid       = 'catppuccin-mocha'
            BatTheme    = 'Catppuccin Mocha'
            Pi          = 'catppuccin-mocha'
            Opencode    = 'catppuccin'
            Mammouth    = 'catppuccin'
            Fish        = 'catppuccin'
            NvimFamily  = 'catppuccin'
            NvimColorscheme = 'catppuccin-mocha'
        }

        # ========================= Everforest =========================
        'everforest-dark' = @{
            Family   = 'everforest'
            Variant  = 'dark'
            Title    = 'Everforest Dark'
            Palette  = @{
                rosewater = 'd3c6aa'; flamingo = 'd3c6aa'; pink = 'd699b6'; mauve = 'd699b6'
                red = 'e67e80'; maroon = 'e67e80'; peach = 'e69875'; yellow = 'dbbc7f'
                green = 'a7c080'; teal = '83c092'; sky = '7fbbb3'; sapphire = '7fbbb3'
                blue = '7fbbb3'; lavender = '83c092'
                text = 'd3c6aa'; subtext1 = 'd3c6aa'; subtext0 = '9da9a0'
                overlay2 = '859289'; overlay1 = '859289'; overlay0 = '7a8478'
                surface2 = '475258'; surface1 = '3d484d'; surface0 = '343f44'
                base = '2d353b'; mantle = '232a2e'; crust = '232a2e'
            }
            Ghostty     = 'Everforest Dark Hard'
            WezTerm     = 'Everforest Dark (Gogh)'
            Vivid       = 'ansi'
            BatTheme    = 'Everforest Dark'
            Pi          = 'everforest-dark'
            Opencode    = 'everforest'
            Mammouth    = 'catppuccin-frappe'
            Fish        = 'everforest-dark'
            NvimFamily  = 'everforest'
            NvimColorscheme = 'everforest'
            # Theme-specific config files (relative to $ConfigDir)
            EzaThemeSrc    = 'eza/everforest-theme.yml'
            YaziThemeSrc   = 'yazi/everforest-theme.toml'
            StarshipSrc    = 'starship-everforest.toml'
        }
    }
    return $Script:ThemeRegistry
}

# All supported flavor names
function Get-ValidFlavors {
    return (Get-ThemeRegistry).Keys | Sort-Object
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function Write-Log {
    param([string]$Message)
    Write-Host "[theme] $Message" -ForegroundColor Blue
}

function ConvertTo-Rgb {
    param([string]$Hex)
    $r = [Convert]::ToInt32($Hex.Substring(0, 2), 16)
    $g = [Convert]::ToInt32($Hex.Substring(2, 2), 16)
    $b = [Convert]::ToInt32($Hex.Substring(4, 2), 16)
    return "rgb($r, $g, $b)"
}

function ConvertTo-Ansi {
    param([string]$Hex, [string]$Kind)
    $r = [Convert]::ToInt32($Hex.Substring(0, 2), 16)
    $g = [Convert]::ToInt32($Hex.Substring(2, 2), 16)
    $b = [Convert]::ToInt32($Hex.Substring(4, 2), 16)
    $code = if ($Kind -eq 'bg') { 48 } else { 38 }
    return "`e[${code};2;${r};${g};${b}m"
}

# Replace every CURRENT flavor hex with the target flavor's hex in a file.
function Invoke-SubHex {
    param(
        [string]$Path,
        [hashtable]$SrcPalette,
        [hashtable]$DstPalette,
        [string[]]$ColorNames
    )
    $content = Get-Content -Raw -Path $Path
    foreach ($c in $ColorNames) {
        $srcHex = $SrcPalette[$c]
        $dstHex = $DstPalette[$c]
        if ($srcHex -and $dstHex) {
            $content = $content -ireplace "#$srcHex", "#$dstHex"
            $content = $content -ireplace $srcHex, $dstHex
        }
    }
    Set-Content -Path $Path -Value $content -NoNewline -Encoding utf8NoBOM
}

# Set a JSON key in a file.
function Set-JsonTheme {
    param(
        [string]$Path,
        [string]$Theme
    )
    $content = Get-Content -Raw $Path
    $content = $content -replace '"theme"\s*:\s*"[^"]*"', "`"theme`": `"$Theme`""
    Set-Content -Path $Path -Value $content -NoNewline -Encoding utf8NoBOM
}

# Copy a source file to the active config path (for non-Catppuccin themes).
function Copy-ThemeFile {
    param(
        [string]$Source,
        [string]$Dest
    )
    if (Test-Path $Source) {
        Copy-Item $Source $Dest -Force
    }
}

# ---------------------------------------------------------------------------
# Get-TaminaruTheme
# ---------------------------------------------------------------------------
function Get-TaminaruTheme {
    <#
    .SYNOPSIS
      Reports the currently active theme flavor.
    .DESCRIPTION
      Reads from the live chezmoi-managed file at ~/.config/ghostty/config.
    #>
    $ghostty = Join-Path $HOME ".config/ghostty/config"
    $cur = 'frappe'
    if (Test-Path $ghostty) {
        $line = Get-Content $ghostty | Where-Object { $_ -match '^theme = "([^"]+)"' } | Select-Object -First 1
        if ($line -and $line -match '^theme = "([^"]+)"') {
            $themeName = $Matches[1]
            # Map ghostty theme name back to flavor
            $registry = Get-ThemeRegistry
            foreach ($key in $registry.Keys) {
                if ($registry[$key].Ghostty -eq $themeName) {
                    return $key
                }
            }
            # Fallback: try catppuccin detection
            if ($themeName -match 'Catppuccin (\w+)') {
                return $Matches[1].ToLowerInvariant()
            }
        }
    }
    return $cur
}

# ---------------------------------------------------------------------------
# Set-TaminaruTheme
# ---------------------------------------------------------------------------
function Set-TaminaruTheme {
    <#
    .SYNOPSIS
      Switches every tool to the given theme.

    .PARAMETER Flavor
      Theme flavor name (e.g. frappe, latte, everforest-dark).
    #>
    param(
        [string]$Flavor = "frappe"
    )

    $ErrorActionPreference = "Stop"

    $RepoDir   = Get-TaminaruRepoDir
    $ConfigDir = Join-Path $RepoDir "dotfiles/dot_config"
    $registry  = Get-ThemeRegistry

    if (-not $registry.ContainsKey($Flavor)) {
        $valid = ($registry.Keys | Sort-Object) -join ', '
        throw "unknown flavor '$Flavor' (valid: $valid)"
    }

    $theme = $registry[$Flavor]
    $family = $theme.Family
    $Title = $theme.Title
    $Palette = $theme.Palette

    Write-Host "[theme] 🎨 Applying $family theme: $Flavor..." -ForegroundColor Blue

    $CatppuccinColors = @('rosewater', 'flamingo', 'pink', 'mauve', 'red', 'maroon',
        'peach', 'yellow', 'green', 'teal', 'sky', 'sapphire', 'blue', 'lavender',
        'text', 'subtext1', 'subtext0', 'overlay2', 'overlay1', 'overlay0',
        'surface2', 'surface1', 'surface0', 'base', 'mantle', 'crust')

    # Current active flavor (from ghostty)
    $CurFlavor = Get-TaminaruTheme
    $CurTheme = $registry[$CurFlavor]
    $CurFamily = $CurTheme.Family
    $CurPalette = $CurTheme.Palette

    # ==================================================== eza
    $Eza = Join-Path $ConfigDir "eza/theme.yml"
    if ($family -eq 'catppuccin') {
        if (Test-Path $Eza) {
            Invoke-SubHex $Eza $CurPalette $Palette $CatppuccinColors
            Write-Log "🌳 eza: theme.yml -> $Flavor"
        }
    } else {
        $EzaSrc = Join-Path $ConfigDir $theme.EzaThemeSrc
        if ((Test-Path $EzaSrc) -and (Test-Path (Split-Path $Eza))) {
            Copy-ThemeFile $EzaSrc $Eza
            Write-Log "🌳 eza: theme.yml -> $Flavor (copied)"
        }
    }

    # ==================================================== yazi
    $YaziTheme = Join-Path $ConfigDir "yazi/theme.toml"
    if ($family -eq 'catppuccin') {
        if (Test-Path $YaziTheme) {
            Invoke-SubHex $YaziTheme $CurPalette $Palette $CatppuccinColors
            $content = Get-Content -Raw $YaziTheme
            $content = $content -replace 'Catppuccin-[a-z]*\.tmTheme', "Catppuccin-$Flavor.tmTheme"
            Set-Content -Path $YaziTheme -Value $content -NoNewline -Encoding utf8NoBOM
            Write-Log "🗂️  yazi: theme.toml -> $Flavor"
        }
    } else {
        $YaziSrc = Join-Path $ConfigDir $theme.YaziThemeSrc
        if ((Test-Path $YaziSrc) -and (Test-Path (Split-Path $YaziTheme))) {
            Copy-ThemeFile $YaziSrc $YaziTheme
            Write-Log "🗂️  yazi: theme.toml -> $Flavor (copied)"
        }
    }

    # yazi syntect theme
    if ($family -eq 'catppuccin') {
        $YaziTm = Join-Path $ConfigDir "yazi/Catppuccin-$Flavor.tmTheme"
        $YaziSrc = Join-Path $ConfigDir "themes/Catppuccin $Title.tmTheme"
        if ((Test-Path $YaziSrc) -and -not (Test-Path $YaziTm)) {
            Copy-Item $YaziSrc $YaziTm
            Write-Log "🗂️  yazi: copied syntect theme"
        }
        Get-ChildItem -Path (Join-Path $ConfigDir "yazi") -Filter "Catppuccin-*.tmTheme" |
            Where-Object { $_.FullName -ne $YaziTm } |
            Remove-Item -Force
        Get-ChildItem -Path (Join-Path $ConfigDir "yazi") -Filter "Everforest*.tmTheme" |
            Remove-Item -Force -ErrorAction SilentlyContinue
    } else {
        $YaziTmDst = Join-Path $ConfigDir "yazi/Everforest.tmTheme"
        $YaziTmSrc = Join-Path $ConfigDir "themes/$Title.tmTheme"
        if (-not (Test-Path $YaziTmSrc)) {
            $YaziTmSrc = Join-Path $ConfigDir "themes/Everforest Dark.tmTheme"
        }
        if ((Test-Path $YaziTmSrc) -and -not (Test-Path $YaziTmDst)) {
            Copy-Item $YaziTmSrc $YaziTmDst
        }
        Get-ChildItem -Path (Join-Path $ConfigDir "yazi") -Filter "Catppuccin-*.tmTheme" |
            Remove-Item -Force -ErrorAction SilentlyContinue
    }

    # ==================================================== bat
    $BatDir = Join-Path $ConfigDir "bat/themes"
    New-Item -ItemType Directory -Path $BatDir -Force | Out-Null
    if ($family -eq 'catppuccin') {
        $BatTm = Join-Path $BatDir "Catppuccin $Title.tmTheme"
        $YaziSrc = Join-Path $ConfigDir "themes/Catppuccin $Title.tmTheme"
        if ((Test-Path $YaziSrc) -and -not (Test-Path $BatTm)) {
            Copy-Item $YaziSrc $BatTm
            Write-Log "🦇 bat: copied $Title tmTheme"
        }
        Get-ChildItem -Path $BatDir -Filter "Catppuccin *.tmTheme" |
            Where-Object { $_.FullName -ne $BatTm } |
            Remove-Item -Force
        Get-ChildItem -Path $BatDir -Filter "Everforest*.tmTheme" |
            Remove-Item -Force -ErrorAction SilentlyContinue
    } else {
        $BatTmSrc = Join-Path $ConfigDir "themes/$Title.tmTheme"
        if (-not (Test-Path $BatTmSrc)) {
            $BatTmSrc = Join-Path $ConfigDir "themes/Everforest Dark.tmTheme"
        }
        $BatTmDst = Join-Path $BatDir "$Title.tmTheme"
        if ((Test-Path $BatTmSrc) -and -not (Test-Path $BatTmDst)) {
            Copy-Item $BatTmSrc $BatTmDst
        }
        Get-ChildItem -Path $BatDir -Filter "Catppuccin *.tmTheme" |
            Remove-Item -Force -ErrorAction SilentlyContinue
    }

    # ==================================================== starship
    $Starship = Join-Path $ConfigDir "starship.toml"
    if ($family -eq 'catppuccin') {
        if (Test-Path $Starship) {
            Invoke-SubHex $Starship $CurPalette $Palette $CatppuccinColors
            Write-Log "🪐 starship: starship.toml -> $Flavor"
        }
    } else {
        $StarshipSrc = Join-Path $ConfigDir $theme.StarshipSrc
        if ((Test-Path $StarshipSrc) -and (Test-Path (Split-Path $Starship))) {
            Copy-ThemeFile $StarshipSrc $Starship
            Write-Log "🪐 starship: starship.toml -> $Flavor (copied)"
        }
    }

    # ==================================================== pwsh (PSReadLine + FZF + vivid)
    $t = $Palette
    $s0 = $t['surface0']; $s1 = $t['surface1']; $base = $t['base']
    $fzfOpts = "--color=bg+:#${s0},bg:#${base},spinner:#$($t['rosewater']),hl:#$($t['red']) " +
        "--color=fg:#$($t['text']),header:#$($t['red']),info:#$($t['mauve']),pointer:#$($t['rosewater']) " +
        "--color=marker:#$($t['lavender']),fg+:#$($t['text']),prompt:#$($t['mauve']),hl+:#$($t['red']) " +
        "--color=selected-bg:#${s1} --color=border:#$($t['overlay0']),label:#$($t['text'])"

    $batThemeStr = if ($family -eq 'catppuccin') { "Catppuccin $Title" } else { $Title }
    $vividTheme  = $theme.Vivid

    $pwshTheme = @"
# Generated by Set-TaminaruTheme - active theme: $Flavor ($family)
Set-PSReadLineOption -Colors @{
    "Default"            = '$(ConvertTo-Ansi $t['text'] fg)'
    "Selection"          = '$(ConvertTo-Ansi $t['surface0'] bg)'
    "Command"            = '$(ConvertTo-Ansi $t['blue'] fg)'
    "Parameter"          = '$(ConvertTo-Ansi $t['flamingo'] fg)'
    "Variable"           = '$(ConvertTo-Ansi $t['flamingo'] fg)'
    "String"             = '$(ConvertTo-Ansi $t['green'] fg)'
    "Operator"           = '$(ConvertTo-Ansi $t['pink'] fg)'
    "Comment"            = '$(ConvertTo-Ansi $t['overlay1'] fg)'
    "Keyword"            = '$(ConvertTo-Ansi $t['red'] fg)'
    "Number"             = '$(ConvertTo-Ansi $t['peach'] fg)'
    "Type"               = '$(ConvertTo-Ansi $t['lavender'] fg)'
    "Member"             = '$(ConvertTo-Ansi $t['teal'] fg)'
    "Error"              = '$(ConvertTo-Ansi $t['red'] fg)'
    "Emphasis"           = '$(ConvertTo-Ansi $t['yellow'] fg)'
    "ContinuationPrompt" = '$(ConvertTo-Ansi $t['sky'] fg)'
    "InlinePrediction"   = '$(ConvertTo-Ansi $t['overlay0'] fg)'
}

`$env:FZF_DEFAULT_OPTS = "$fzfOpts"
`$env:BAT_THEME = "$batThemeStr"

# vivid theme
if (Get-Command vivid -ErrorAction SilentlyContinue) {
    `$env:LS_COLORS = (vivid generate $vividTheme 2>`$null)
}
"@
    $PwshDir = Join-Path $ConfigDir "powershell"
    New-Item -ItemType Directory -Path $PwshDir -Force | Out-Null
    $ThemeFile = Join-Path $PwshDir "theme.ps1"
    Set-Content -Path $ThemeFile -Value $pwshTheme -Encoding utf8NoBOM
    Write-Log "⚡ pwsh: powershell/theme.ps1 -> $Flavor"
    . $ThemeFile

    # ==================================================== neovim
    # catppuccin.lua: always set flavour (only active when catppuccin family)
    $NvimCp = Join-Path $ConfigDir "nvim/lua/plugins/catppuccin.lua"
    if (Test-Path $NvimCp) {
        if ($family -eq 'catppuccin') {
            $content = Get-Content -Raw $NvimCp
            $content = $content -replace 'flavour = "[a-z]*"', "flavour = `"$Flavor`""
            Set-Content -Path $NvimCp -Value $content -NoNewline -Encoding utf8NoBOM
        }
        Write-Log "✍️  nvim: catppuccin.lua"
    }

    # astroui.lua: set colorscheme to match active theme
    $NvimAstroui = Join-Path $ConfigDir "nvim/lua/plugins/astroui.lua"
    if (Test-Path $NvimAstroui) {
        $content = Get-Content -Raw $NvimAstroui
        # Replace any colorscheme value
        $content = $content -replace 'colorscheme = "[^"]*"', "colorscheme = `"$($theme.NvimColorscheme)`""
        Set-Content -Path $NvimAstroui -Value $content -NoNewline -Encoding utf8NoBOM
        Write-Log "✍️  nvim: astroui.lua -> $($theme.NvimColorscheme)"
    }

    # ==================================================== AI coding harnesses
    $SetHarnessTheme = {
        param($Path, $ThemeName)
        $content = Get-Content -Raw $Path
        $content = $content -replace '"theme"\s*:\s*"[^"]*"', "`"theme`": `"$ThemeName`""
        Set-Content -Path $Path -Value $content -NoNewline -Encoding utf8NoBOM
    }

    $PiSettings = Join-Path $RepoDir "dotfiles/dot_pi/agent/settings.json"
    if (Test-Path $PiSettings) {
        & $SetHarnessTheme $PiSettings $theme.Pi
        Write-Log "🤖 pi: settings.json -> $($theme.Pi)"
    }
    foreach ($tool in @('opencode', 'mammouth')) {
        $Tui = Join-Path $ConfigDir "$tool/tui.json"
        if (Test-Path $Tui) {
            $toolTheme = if ($tool -eq 'mammouth') { $theme.Mammouth } else { $theme.Opencode }
            & $SetHarnessTheme $Tui $toolTheme
            $toolEmoji = if ($tool -eq 'mammouth') { '🦣' } else { '🤖' }
            Write-Log "$toolEmoji ${tool}: tui.json -> $toolTheme"
        }
    }

    # ==================================================== ghostty
    $Ghostty = Join-Path $ConfigDir "ghostty/config"
    if (Test-Path $Ghostty) {
        $content = Get-Content -Raw $Ghostty
        # Match both Catppuccin and non-Catppuccin theme lines
        $content = $content -replace '(?m)^theme = "[^"]*"', "theme = `"$($theme.Ghostty)`""
        Set-Content -Path $Ghostty -Value $content -NoNewline -Encoding utf8NoBOM
        Write-Log "👻 ghostty: -> $($theme.Ghostty)"
    }

    # ==================================================== wezterm
    $Wezterm = Join-Path $ConfigDir "wezterm/wezterm.lua"
    if (Test-Path $Wezterm) {
        $content = Get-Content -Raw $Wezterm
        $content = $content -replace 'config\.color_scheme = "[^"]*"', "config.color_scheme = `"$($theme.WezTerm)`""
        Set-Content -Path $Wezterm -Value $content -NoNewline -Encoding utf8NoBOM
        Write-Log "🖥️  wezterm: -> $($theme.WezTerm)"
    }

    # ==================================================== fish
    $FishConf = Join-Path $ConfigDir "fish/conf.d/catppuccin.fish"
    if (Test-Path $FishConf) {
        if ($family -eq 'catppuccin') {
            $content = Get-Content -Raw $FishConf
            # Keep the catppuccin fish script as-is for catppuccin themes
            Write-Log "🐟 fish: catppuccin.fish (unchanged)"
        } else {
            # For non-catppuccin themes, write a generic theme activation script
            $fishTheme = $theme.Fish
            $fishScript = @"
# Auto-generated by Set-TaminaruTheme for $Flavor
# Apply fish theme via builtin fish_config
if status is-interactive
    fish_config theme choose "$fishTheme" 2>/dev/null
end
"@
            Set-Content -Path $FishConf -Value $fishScript -Encoding utf8NoBOM
            Write-Log "🐟 fish: catppuccin.fish -> $fishTheme"
        }
    }

    Write-Host "[theme] 🎉 All tools now use $family $Title ($Flavor)." -ForegroundColor Blue
}

# ---------------------------------------------------------------------------
# Update-Taminaru
# ---------------------------------------------------------------------------
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
        throw "chezmoi not found — install via: mise use aqua:twpayne/chezmoi"
    }
    if ($LASTEXITCODE -ne 0) { throw "chezmoi apply failed (exit $LASTEXITCODE)" }

    Write-Host "[taminaru] Re-applying theme..." -ForegroundColor Blue
    Set-TaminaruTheme (Get-TaminaruTheme)

    Write-Host "[taminaru] Done. Taminaru is up to date." -ForegroundColor Blue
}

Export-ModuleMember -Function Set-TaminaruTheme, Get-TaminaruTheme, Get-TaminaruRepoDir, Update-Taminaru, Get-ValidFlavors
