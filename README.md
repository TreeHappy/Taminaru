<div>
  <img src="images/terminal.png" width="200" height="300"/>



  <img src="images/currentscreen.png" width="500"/>
</div>

## Usage

Everything is driven from PowerShell. All tools are provisioned with [mise](https://mise.jdx.dev)
(see `mise.toml` / `mise.lock`), and themes are applied from this repo.

### Prerequisites

* [mise](https://mise.jdx.dev/getting-started) - the bootstrap installs it automatically if missing
* PowerShell 7+ (`pwsh`) to run the scripts - only needed for the first bootstrap; after that pwsh itself is provisioned and pinned via mise (see `mise.toml`)

### Bootstrap

Installs all tools with mise (including the `pi` and `mammouth` coding
harnesses), symlinks every `config/*` directory into
`~/.config/*`, wires mise into the pwsh profile, themes the AI coding harnesses
(`pi`, `opencode`, `mammouth`) with catppuccin, and applies the default theme
(frappe).

On a fresh Ubuntu machine (bash):

```bash
bash scripts/bootstrap.sh
```

Running as root (e.g. right after a fresh Ubuntu install) first creates a
non-root user — default name `taminaru`, passwordless with NOPASSWD sudo,
overridable via `TAMINARU_USER=bob bash scripts/bootstrap.sh` — copies this
repo into that user's home, and re-runs the rest of the bootstrap as them, so
you never have to use root.

It is idempotent and safe to re-run.

### Theme switcher

The theme switcher is a pwsh module (`Taminaru.Theme`) that is loaded from your
`$PROFILE`, so you can switch flavors from any pwsh session:

```powershell
Set-TaminaruTheme macchiato    # latte | frappe | macchiato | mocha
Get-TaminaruTheme              # prints the active flavor
```

There is also a CLI wrapper for bash/bootstrap:

```powershell
pwsh ./scripts/theme.ps1            # default: frappe
pwsh ./scripts/theme.ps1 mocha
```
