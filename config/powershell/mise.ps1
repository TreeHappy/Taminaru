# mise activation (managed by scripts/bootstrap.sh)
$mise = Join-Path $HOME ".local/bin/mise"
if (Get-Command mise -ErrorAction SilentlyContinue) {
    mise activate pwsh | Out-String | Invoke-Expression
} elseif (Test-Path $mise) {
    $env:PATH = (Join-Path $HOME ".local/bin") + ";" + $env:PATH
    & $mise activate pwsh | Out-String | Invoke-Expression
}
