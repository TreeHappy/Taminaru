# mise activation (managed by chezmoi from dotfiles/)
# Point mise at the repo's mise.toml (no symlink); tools stay in ~/.local/share/mise.
$env:MISE_CONFIG_FILE = Join-Path $env:HOME "Taminaru/mise.toml"
if (Get-Command mise -ErrorAction SilentlyContinue) {
    mise activate pwsh | Out-String | Invoke-Expression
} elseif (Test-Path (Join-Path $env:HOME ".local/bin/mise")) {
    $env:PATH = (Join-Path $env:HOME ".local/bin") + ";" + $env:PATH
    & mise activate pwsh | Out-String | Invoke-Expression
}