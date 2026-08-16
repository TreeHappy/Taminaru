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
    # The module lives at <repo>/config/powershell/Modules/Taminaru.Theme/, but
    # in a deployed setup that path is reached through the ~/.config symlink, so
    # Resolve-Path/Split-Path can't walk back to the repo. git --show-toplevel
    # follows the symlink to the real repo root; the walk-up is the fallback for
    # repos not under git.
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
    $Script:RepoDir = $repoDir
    return $repoDir
}

function Get-TaminaruTheme {
    <#
    .SYNOPSIS
      Prints the currently active catppuccin flavor.
    #>
    $ghostty = Join-Path (Get-TaminaruRepoDir) "config/ghostty/config"
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
        [string]$Flavor = "frappe"
    )

    $ErrorActionPreference = "Stop"

    $RepoDir   = Get-TaminaruRepoDir
    $ConfigDir = Join-Path $RepoDir "config"

    $Valid = @("latte", "frappe", "macchiato", "mocha")
    if ($Valid -notcontains $Flavor) {
        throw "unknown flavor '$Flavor' (use latte|frappe|macchiato|mocha)"
    }
    $Title = (Get-Culture).TextInfo.ToTitleCase($Flavor)   # "Frappe"

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

    function Invoke-SubRgb {
        param([string]$Path)
        $content = Get-Content -Raw -Path $Path
        foreach ($c in $Colors) {
            $srcRgb = ConvertTo-Rgb $Src[$c]
            $dstRgb = ConvertTo-Rgb $Target[$c]
            $content = $content -ireplace [regex]::Escape($srcRgb), $dstRgb
        }
        Set-Content -Path $Path -Value $content -NoNewline -Encoding utf8NoBOM
    }

    # Ensure a flavor-named file exists, regenerated from the canonical frappe
    # version so the result is deterministic regardless of the current flavor.
    function Set-FlavorFile {
        param([string]$Source, [string]$Dest)
        if (Test-Path $Dest) { return }
        Copy-Item $Source $Dest
        Invoke-SubHex $Dest
        Invoke-SubRgb $Dest
    }

    function Write-Log {
        param([string]$Message)
        Write-Host "[theme] $Message" -ForegroundColor Blue
    }

    # ----------------------------------------------------- CLI tools

    # eza
    $Eza = Join-Path $ConfigDir "eza/theme.yml"
    if (Test-Path $Eza) { Invoke-SubHex $Eza; Write-Log "eza: theme.yml -> $Flavor" }

    # yazi (colors + syntax theme)
    $YaziTheme = Join-Path $ConfigDir "yazi/theme.toml"
    if (Test-Path $YaziTheme) {
        Invoke-SubHex $YaziTheme
        $content = Get-Content -Raw $YaziTheme
        $content = $content -replace 'Catppuccin-[a-z]*\.tmTheme', "Catppuccin-$Flavor.tmTheme"
        Set-Content -Path $YaziTheme -Value $content -NoNewline -Encoding utf8NoBOM
        Write-Log "yazi: theme.toml -> $Flavor"
    }
    $YaziTm = Join-Path $ConfigDir "yazi/Catppuccin-$Flavor.tmTheme"
    $YaziSrc = Join-Path $ConfigDir "themes/Catppuccin $Title.tmTheme"
    if ((Test-Path $YaziSrc) -and -not (Test-Path $YaziTm)) {
        Copy-Item $YaziSrc $YaziTm
        Write-Log "yazi: copied syntect theme"
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
        Write-Log "bat: copied $Title tmTheme"
    }
    Get-ChildItem -Path $BatDir -Filter "Catppuccin *.tmTheme" |
        Where-Object { $_.FullName -ne $BatTm } |
        Remove-Item -Force

    # starship (canonical file uses frappe hexes already)
    $Starship = Join-Path $ConfigDir "starship/starship.toml"
    if (Test-Path $Starship) { Invoke-SubHex $Starship; Write-Log "starship: starship.toml -> $Flavor" }

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
    $fzfOpts = "--color=bg+:${s0},bg:${base},spinner:$($t['rosewater']),hl:$($t['red']) " +
        "--color=fg:$($t['text']),header:$($t['red']),info:$($t['mauve']),pointer:$($t['rosewater']) " +
        "--color=marker:$($t['lavender']),fg+:$($t['text']),prompt:$($t['mauve']),hl+:$($t['red']) " +
        "--color=selected-bg:${s1} --color=border:$($t['overlay0']),label:$($t['text'])"

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
    Write-Log "pwsh: powershell/theme.ps1 -> $Flavor"

    # Apply to the current session so the switch takes effect immediately.
    . $ThemeFile

    # neovim
    $NvimCp = Join-Path $ConfigDir "nvim/lua/plugins/catppuccin.lua"
    if (Test-Path $NvimCp) {
        $content = Get-Content -Raw $NvimCp
        $content = $content -replace 'flavour = "[a-z]*"', "flavour = `"$Flavor`""
        Set-Content -Path $NvimCp -Value $content -NoNewline -Encoding utf8NoBOM
        Write-Log "nvim: catppuccin.lua -> $Flavor"
    }

    # ------------------------------------------------- desktop tools

    # ghostty
    $Ghostty = Join-Path $ConfigDir "ghostty/config"
    if (Test-Path $Ghostty) {
        $content = Get-Content -Raw $Ghostty
        $content = $content -replace '(?m)^theme = "Catppuccin .*"', "theme = `"Catppuccin $Title`""
        Set-Content -Path $Ghostty -Value $content -NoNewline -Encoding utf8NoBOM
        Write-Log "ghostty: -> Catppuccin $Title"
    }

    # wezterm
    $Wezterm = Join-Path $ConfigDir "wezterm/wezterm.lua"
    if (Test-Path $Wezterm) {
        $content = Get-Content -Raw $Wezterm
        $content = $content -replace 'config\.color_scheme = "Catppuccin .*(Gogh)"', "config.color_scheme = `"Catppuccin $Title (Gogh)`""
        Set-Content -Path $Wezterm -Value $content -NoNewline -Encoding utf8NoBOM
        Write-Log "wezterm: -> Catppuccin $Title"
    }

    # waybar (regenerate target css from canonical frappe.css, drop stale flavors)
    $WaybarThemes = Join-Path $ConfigDir "waybar/themes"
    $FrappeCss = Join-Path $WaybarThemes "frappe.css"
    if (Test-Path $FrappeCss) {
        Set-FlavorFile -Source $FrappeCss -Dest (Join-Path $WaybarThemes "$Flavor.css")
        Get-ChildItem -Path $WaybarThemes -Filter "*.css" |
            Where-Object { $_.BaseName -ne 'frappe' -and $_.BaseName -ne $Flavor } |
            Remove-Item -Force
        $style = Join-Path $ConfigDir "waybar/style.css"
        $content = Get-Content -Raw $style
        $content = $content -replace '@import "themes/[a-z]*\.css";', "@import `"themes/$Flavor.css`";"
        Set-Content -Path $style -Value $content -NoNewline -Encoding utf8NoBOM
        Write-Log "waybar: -> $Flavor.css"
    }

    # rofi
    $RofiDir = Join-Path $ConfigDir "rofi"
    $FrappeRasi = Join-Path $RofiDir "catppuccin-frappe.rasi"
    if (Test-Path $FrappeRasi) {
        Set-FlavorFile -Source $FrappeRasi -Dest (Join-Path $RofiDir "catppuccin-$Flavor.rasi")
        Get-ChildItem -Path $RofiDir -Filter "catppuccin-*.rasi" |
            Where-Object { $_.BaseName -ne 'catppuccin-frappe' -and $_.BaseName -ne "catppuccin-$Flavor" } |
            Remove-Item -Force
        $rasi = Join-Path $RofiDir "config.rasi"
        $content = Get-Content -Raw $rasi
        $content = $content -replace '@import "catppuccin-[a-z]*"', "@import `"catppuccin-$Flavor`""
        Set-Content -Path $rasi -Value $content -NoNewline -Encoding utf8NoBOM
        Write-Log "rofi: -> catppuccin-$Flavor"
    }

    # wofi
    $Wofi = Join-Path $ConfigDir "wofi/style.css"
    if (Test-Path $Wofi) {
        Invoke-SubHex $Wofi
        Invoke-SubRgb $Wofi
        Write-Log "wofi: style.css -> $Flavor"
    }

    # hyprland
    $HyprThemes = Join-Path $ConfigDir "hypr/themes"
    $FrappeConf = Join-Path $HyprThemes "frappe.conf"
    if (Test-Path $FrappeConf) {
        Set-FlavorFile -Source $FrappeConf -Dest (Join-Path $HyprThemes "$Flavor.conf")
        Get-ChildItem -Path $HyprThemes -Filter "*.conf" |
            Where-Object { $_.BaseName -ne 'frappe' -and $_.BaseName -ne $Flavor } |
            Remove-Item -Force
        $hypr = Join-Path $ConfigDir "hypr/hyprland.conf"
        $content = Get-Content -Raw $hypr
        $content = $content -replace 'source = ~/\.config/hypr/themes/[a-z]*\.conf', "source = ~/.config/hypr/themes/$Flavor.conf"
        Set-Content -Path $hypr -Value $content -NoNewline -Encoding utf8NoBOM
        Write-Log "hypr: -> $Flavor.conf"
    }

    Write-Host "[theme] All tools now use catppuccin $Title ($Flavor)." -ForegroundColor Blue
}

Export-ModuleMember -Function Set-TaminaruTheme, Get-TaminaruTheme, Get-TaminaruRepoDir