<#
.SYNOPSIS
  Taminaru catppuccin theme switcher (CLI wrapper around the Taminaru.Theme module).

.DESCRIPTION
  Thin entry point so the theme switcher can be called from bash/bootstrap or
  the terminal. Real logic lives in config/powershell/Modules/Taminaru.Theme/
  (Set-TaminaruTheme), which is also available directly from any pwsh session.

.EXAMPLE
  pwsh ./scripts/theme.ps1 frappe          # default
  pwsh ./scripts/theme.ps1 mocha
#>
param(
    [string]$Flavor = "frappe"
)

$ErrorActionPreference = "Stop"

Write-Host "✨ Taminaru theme switcher" -ForegroundColor Magenta

$Module = Join-Path $PSScriptRoot "../config/powershell/Modules/Taminaru.Theme/Taminaru.Theme.psm1"
Import-Module $Module -Force

Set-TaminaruTheme $Flavor