<#
.SYNOPSIS
  Taminaru catppuccin theme switching (module).

.DESCRIPTION
  Exposes Set-TaminaruTheme to switch every tool the dotfiles configure to a
  catppuccin flavor (latte/frappe/macchiato/mocha), and Get-TaminaruTheme to
  report the currently active flavor.

  Loaded from $PROFILE (see config/powershell/profile.ps1), so the functions
  are available in every pwsh session. In-place config files may be in any
  flavor; conversions always go CURRENT -> TARGET, where CURRENT is detected
  from the ghostty theme line.
#>

$Script:RepoDir = $null

function Get-TaminaruRepoDir {
    # The module lives at <repo>/dotfiles/dot_config/powershell/Modules/Taminaru.Theme/
    # in the source tree. In a deployed setup chezmoi copies it to
    # ~/.config/powershell/Modules/... (a real dir, not a symlink), so
    # git --show-toplevel / a walk-up can't always find the repo; fall back to
    # the fixed install path $HOME/Taminaru.
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

function Get-TaminaruTheme {
    <#
    .SYNOPSIS
      Prints the currently active catppuccin flavor.
    .DESCRIPTION
      Reads from the live chezmoi-managed file at ~/.config/ghostty/config
      (the actual config the terminal uses), NOT the source file in the repo.
    #>
    $ghostty = Join-Path $HOME ".config/ghostty/config"
    $cur = 'frappe'
    if (Test-Path $ghostty) {
        $line = Get-Content $ghostty | Where-Object { $_ -match '^theme = "Catppuccin (\w+)"' } | Select-Object -First 1
        if ($line -and $line -match '^theme = "Catppuccin (\w+)"') {
            $cur = $Matches[1].ToLowerInvariant()
        }
    }
    return $cur
}

function Set-TaminaruTheme {
    <#
    .SYNOPSIS
      Switches every tool to the given catppuccin flavor.

    .PARAMETER Flavor
      One of latte, frappe, macchiato, mocha (default: frappe).
    #>
    param(
        [ValidateSet('latte', 'frappe', 'macchiato', 'mocha')]
        [string]$Flavor = "frappe"
    )

    $ErrorActionPreference = "Stop"

    $RepoDir   = Get-TaminaruRepoDir
    $ConfigDir = Join-Path $RepoDir "dotfiles/dot_config"

    $Valid = @("latte", "frappe", "macchiato", "mocha")
    if ($Valid -notcontains $Flavor) {
        throw "unknown flavor '$Flavor' (use latte|frappe|macchiato|mocha)"
    }
    $Title = (Get-Culture).TextInfo.ToTitleCase($Flavor)   # "Frappe"

    Write-Host "[theme] 🎨 Applying catppuccin $Flavor..." -ForegroundColor Blue

    # ------------------------------------------------------------ palette
    # Palette: <color> -> <hex> per flavor (catppuccin.com/palette)
    $Palette = @{
        latte = @{
            rosewater = 'dc8a78'; flamingo = 'dd7878'; pink = 'ea76cb'; mauve = '8839ef'
            red = 'd20f39'; maroon = 'e64553'; peach = 'fe640b'; yellow = 'df8e1d'
            green = '40a02b'; teal = '179299'; sky = '04a5e5'; sapphire = '209fb5'
            blue = '1e66f5'; lavender = '7287fd'
            text = '4c4f69'; subtext1 = '5c5f77'; subtext0 = '6c6f85'
            overlay2 = '7c7f93'; overlay1 = '8c8fa1'; overlay0 = '9ca0b0'
            surface2 = 'acb0be'; surface1 = 'ccd0da'; surface0 = 'eff1f5'
            base = 'eff1f5'; mantle = 'e6e9ef'; crust = 'dce0e8'
        }
        frappe = @{
            rosewater = 'f2d5cf'; flamingo = 'eebebe'; pink = 'f4b8e4'; mauve = 'ca9ee6'
            red = 'e78284'; maroon = 'ea999c'; peach = 'ef9f76'; yellow = 'e5c890'
            green = 'a6d189'; teal = '81c8be'; sky = '99d1db'; sapphire = '85c1dc'
            blue = '8caaee'; lavender = 'babbf1'
            text = 'c6d0f5'; subtext1 = 'b5bfe2'; subtext0 = 'a5adce'
            overlay2 = '949cbb'; overlay1 = '838ba7'; overlay0 = '737994'
            surface2 = '626880'; surface1 = '51576d'; surface0 = '414559'
            base = '303446'; mantle = '292c3c'; crust = '232634'
        }
        macchiato = @{
            rosewater = 'f4dbd6'; flamingo = 'f0c6c6'; pink = 'f5bde6'; mauve = 'c6a0f6'
            red = 'ed8796'; maroon = 'ee99a0'; peach = 'f5a97f'; yellow = 'eed49f'
            green = 'a6da95'; teal = '8bd5ca'; sky = '91d7e3'; sapphire = '7dc4e4'
            blue = '8aadf4'; lavender = 'b7bdf8'
            text = 'cad3f5'; subtext1 = 'b8c0e0'; subtext0 = 'a5adcb'
            overlay2 = '939ab7'; overlay1 = '8087a2'; overlay0 = '6e738d'
            surface2 = '5b6078'; surface1 = '494d64'; surface0 = '363a4f'
            base = '24273a'; mantle = '1e2030'; crust = '181926'
        }
        mocha = @{
            rosewater = 'f5e0dc'; flamingo = 'f2cdcd'; pink = 'f5c2e7'; mauve = 'cba6f7'
            red = 'f38ba8'; maroon = 'eba0ac'; peach = 'fab387'; yellow = 'f9e2af'
            green = 'a6e3a1'; teal = '94e2d5'; sky = '89dceb'; sapphire = '74c7ec'
            blue = '89b4fa'; lavender = 'b4befe'
            text = 'cdd6f4'; subtext1 = 'bac2de'; subtext0 = 'a6adc8'
            overlay2 = '9399b2'; overlay1 = '7f849c'; overlay0 = '6c7086'
            surface2 = '585b70'; surface1 = '45475a'; surface0 = '313244'
            base = '1e1e2e'; mantle = '181825'; crust = '11111b'
        }
    }

    $Colors = @('rosewater', 'flamingo', 'pink', 'mauve', 'red', 'maroon',
        'peach', 'yellow', 'green', 'teal', 'sky', 'sapphire', 'blue', 'lavender',
        'text', 'subtext1', 'subtext0', 'overlay2', 'overlay1', 'overlay0',
        'surface2', 'surface1', 'surface0', 'base', 'mantle', 'crust')

    $Target = $Palette[$Flavor]

    # Current active flavor (from ghostty); conversions go CURRENT -> TARGET.
    $Cur = Get-TaminaruTheme
    $Src = $Palette[$Cur]

    # ----------------------------------------------------- replacements
    function ConvertTo-Rgb {
        param([string]$Hex)
        $r = [Convert]::ToInt32($Hex.Substring(0, 2), 16)
        $g = [Convert]::ToInt32($Hex.Substring(2, 2), 16)
        $b = [Convert]::ToInt32($Hex.Substring(4, 2), 16)
        return "rgb($r, $g, $b)"
    }

    # Replace every CURRENT flavor hex with the target flavor's hex in a file.
    function Invoke-SubHex {
        param([string]$Path)
        $content = Get-Content -Raw -Path $Path
        foreach ($c in $Colors) {
            $srcHex = $Src[$c]
            $dstHex = $Target[$c]
            $content = $content -ireplace "#$srcHex", "#$dstHex"
            $content = $content -ireplace $srcHex, $dstHex
        }
        Set-Content -Path $Path -Value $content -NoNewline -Encoding utf8NoBOM
    }

    function Write-Log {
        param([string]$Message)
        Write-Host "[theme] $Message" -ForegroundColor Blue
    }

    # ----------------------------------------------------- CLI tools

    # eza
    $Eza = Join-Path $ConfigDir "eza/theme.yml"
    if (Test-Path $Eza) { Invoke-SubHex $Eza; Write-Log "🌳 eza: theme.yml -> $Flavor" }

    # yazi (colors + syntax theme)
    $YaziTheme = Join-Path $ConfigDir "yazi/theme.toml"
    if (Test-Path $YaziTheme) {
        Invoke-SubHex $YaziTheme
        $content = Get-Content -Raw $YaziTheme
        $content = $content -replace 'Catppuccin-[a-z]*\.tmTheme', "Catppuccin-$Flavor.tmTheme"
        Set-Content -Path $YaziTheme -Value $content -NoNewline -Encoding utf8NoBOM
        Write-Log "🗂️  yazi: theme.toml -> $Flavor"
    }
    $YaziTm = Join-Path $ConfigDir "yazi/Catppuccin-$Flavor.tmTheme"
    $YaziSrc = Join-Path $ConfigDir "themes/Catppuccin $Title.tmTheme"
    if ((Test-Path $YaziSrc) -and -not (Test-Path $YaziTm)) {
        Copy-Item $YaziSrc $YaziTm
        Write-Log "🗂️  yazi: copied syntect theme"
    }
    Get-ChildItem -Path (Join-Path $ConfigDir "yazi") -Filter "Catppuccin-*.tmTheme" |
        Where-Object { $_.FullName -ne $YaziTm } |
        Remove-Item -Force

    # bat (syntax theme + BAT_THEME lives in the pwsh theme.ps1)
    $BatDir = Join-Path $ConfigDir "bat/themes"
    New-Item -ItemType Directory -Path $BatDir -Force | Out-Null
    $BatTm = Join-Path $BatDir "Catppuccin $Title.tmTheme"
    if ((Test-Path $YaziSrc) -and -not (Test-Path $BatTm)) {
        Copy-Item $YaziSrc $BatTm
        Write-Log "🦇 bat: copied $Title tmTheme"
    }
    Get-ChildItem -Path $BatDir -Filter "Catppuccin *.tmTheme" |
        Where-Object { $_.FullName -ne $BatTm } |
        Remove-Item -Force

    # starship (canonical file uses frappe hexes already)
    # Note: chezmoi maps dot_config/starship.toml → ~/.config/starship.toml (flat, not a subdir)
    $Starship = Join-Path $ConfigDir "starship.toml"
    if (Test-Path $Starship) { Invoke-SubHex $Starship; Write-Log "🪐 starship: starship.toml -> $Flavor" }

    # pwsh (PSReadLine colors, fzf opts, bat/vivid env)
    function ConvertTo-Ansi {
        param([string]$Hex, [string]$Kind)
        $r = [Convert]::ToInt32($Hex.Substring(0, 2), 16)
        $g = [Convert]::ToInt32($Hex.Substring(2, 2), 16)
        $b = [Convert]::ToInt32($Hex.Substring(4, 2), 16)
        $code = if ($Kind -eq 'bg') { 48 } else { 38 }
        return "`e[${code};2;${r};${g};${b}m"
    }

    $t = $Target
    $s0 = $t['surface0']; $s1 = $t['surface1']; $base = $t['base']
    $fzfOpts = "--color=bg+:#${s0},bg:#${base},spinner:#$($t['rosewater']),hl:#$($t['red']) " +
        "--color=fg:#$($t['text']),header:#$($t['red']),info:#$($t['mauve']),pointer:#$($t['rosewater']) " +
        "--color=marker:#$($t['lavender']),fg+:#$($t['text']),prompt:#$($t['mauve']),hl+:#$($t['red']) " +
        "--color=selected-bg:#${s1} --color=border:#$($t['overlay0']),label:#$($t['text'])"

    $pwshTheme = @"
# Generated by Set-TaminaruTheme - active catppuccin flavor: $Flavor
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
`$env:BAT_THEME = "Catppuccin $Title"

# vivid ships catppuccin-latte/frappe/macchiato/mocha themes out of the box
if (Get-Command vivid -ErrorAction SilentlyContinue) {
    `$env:LS_COLORS = (vivid generate catppuccin-$Flavor 2>`$null)
}
"@
    $PwshDir = Join-Path $ConfigDir "powershell"
    New-Item -ItemType Directory -Path $PwshDir -Force | Out-Null
    $ThemeFile = Join-Path $PwshDir "theme.ps1"
    Set-Content -Path $ThemeFile -Value $pwshTheme -Encoding utf8NoBOM
    Write-Log "⚡ pwsh: powershell/theme.ps1 -> $Flavor"

    # Apply to the current session so the switch takes effect immediately.
    . $ThemeFile

    # neovim
    $NvimCp = Join-Path $ConfigDir "nvim/lua/plugins/catppuccin.lua"
    if (Test-Path $NvimCp) {
        $content = Get-Content -Raw $NvimCp
        $content = $content -replace 'flavour = "[a-z]*"', "flavour = `"$Flavor`""
        Set-Content -Path $NvimCp -Value $content -NoNewline -Encoding utf8NoBOM
        Write-Log "✍️  nvim: catppuccin.lua -> $Flavor"
    }

    # AstroUI colorscheme (nvim/lua/plugins/astroui.lua)
    $NvimAstroui = Join-Path $ConfigDir "nvim/lua/plugins/astroui.lua"
    if (Test-Path $NvimAstroui) {
        $content = Get-Content -Raw $NvimAstroui
        $content = $content -replace 'colorscheme = "catppuccin-[a-z]*"', "colorscheme = `"catppuccin-$Flavor`""
        Set-Content -Path $NvimAstroui -Value $content -NoNewline -Encoding utf8NoBOM
        Write-Log "✍️  nvim: astroui.lua -> catppuccin-$Flavor"
    }

    # AI coding harnesses (pi, opencode, mammouth). opencode/mammouth ship no
    # built-in latte, so latte falls back to the default catppuccin theme.
    $HarnessThemeMap = @{
        latte     = 'catppuccin'
        frappe    = 'catppuccin-frappe'
        macchiato = 'catppuccin-macchiato'
        mocha     = 'catppuccin'
    }
    $SetHarnessTheme = {
        param($Path, $Theme)
        $content = Get-Content -Raw $Path
        $content = $content -replace '"theme"\s*:\s*"[^"]*"', "`"theme`": `"$Theme`""
        Set-Content -Path $Path -Value $content -NoNewline -Encoding utf8NoBOM
    }

    # pi loads catppuccin from the @firstpick/pi-themes-bundle plugin, which
    # ships only latte + mocha. frappe/macchiato have no plugin theme, so they
    # fall back to mocha (dark) to match the other dark flavors. No local pi
    # theme files are generated by the script.
    $PiThemeMap = @{
        latte     = 'catppuccin-latte'
        frappe    = 'catppuccin-mocha'
        macchiato = 'catppuccin-mocha'
        mocha     = 'catppuccin-mocha'
    }
    $PiSettings = Join-Path (Get-TaminaruRepoDir) "dotfiles/dot_pi/agent/settings.json"
    if (Test-Path $PiSettings) {
        & $SetHarnessTheme $PiSettings $PiThemeMap[$Flavor]
        Write-Log "🤖 pi: settings.json -> $($PiThemeMap[$Flavor])"
    }
    foreach ($tool in @('opencode', 'mammouth')) {
        $Tui = Join-Path $ConfigDir "$tool/tui.json"
        if (Test-Path $Tui) {
            & $SetHarnessTheme $Tui $HarnessThemeMap[$Flavor]
            $toolEmoji = if ($tool -eq 'mammouth') { '🦣' } else { '🤖' }
            Write-Log "$toolEmoji ${tool}: tui.json -> $($HarnessThemeMap[$Flavor])"
        }
    }

    # ------------------------------------------------- desktop tools

    # ghostty
    $Ghostty = Join-Path $ConfigDir "ghostty/config"
    if (Test-Path $Ghostty) {
        $content = Get-Content -Raw $Ghostty
        $content = $content -replace '(?m)^theme = "Catppuccin .*"', "theme = `"Catppuccin $Title`""
        Set-Content -Path $Ghostty -Value $content -NoNewline -Encoding utf8NoBOM
        Write-Log "👻 ghostty: -> Catppuccin $Title"
    }

    # wezterm
    $Wezterm = Join-Path $ConfigDir "wezterm/wezterm.lua"
    if (Test-Path $Wezterm) {
        $content = Get-Content -Raw $Wezterm
        $content = $content -replace 'config\.color_scheme = "Catppuccin .*(Gogh)"', "config.color_scheme = `"Catppuccin $Title (Gogh)`""
        Set-Content -Path $Wezterm -Value $content -NoNewline -Encoding utf8NoBOM
        Write-Log "🖥️  wezterm: -> Catppuccin $Title"
    }

    Write-Host "[theme] 🎉 All tools now use catppuccin $Title ($Flavor)." -ForegroundColor Blue
}

function Update-Taminaru {
    <#
    .SYNOPSIS
      Updates Taminaru: pulls latest repo changes and re-applies dotfiles via chezmoi.

    .DESCRIPTION
      Pulls the latest commits from origin (fast-forward only), re-applies the
      chezmoi-managed dotfiles to $HOME, and re-applies the current catppuccin
      theme. No more git checkout -- . — chezmoi handles the apply.
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

Export-ModuleMember -Function Set-TaminaruTheme, Get-TaminaruTheme, Get-TaminaruRepoDir, Update-Taminaru