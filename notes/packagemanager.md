# Packagemanager

There are three possible options for package managers under windows.

## Winget

### Pros

* Installed on every machine
* Has all packages i wanted so far

### Cons

* Updating is pretty slow
* M$
* Clunky to add own repositories

## Scoop

### Pros

### Cons

## Chocolatey

### Pros

### Cons

## mise-en-place

Used for **all CLI / dev tools**. This repo's
`mise.toml` declares the toolchain (opencode, neovim, starship, powershell, bat, eza,
fzf, yazi, vivid, ...), and `mise.lock` pins exact versions for reproducibility.

* https://mise.jdx.dev/core-tools.html
* Tools install per-user into `~/.local/share/mise`, no sudo needed.
* Windows support is partial - that is why winget stays for Windows-only tooling.
