# mise activation (managed by scripts/bootstrap.ps1)
if (Get-Command mise -ErrorAction SilentlyContinue) {
    mise activate pwsh | Out-String | Invoke-Expression
}
