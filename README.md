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

Installs all tools with mise (including the `pi` coding harness), installs
Mammouth Code from code.mammouth.ai, symlinks every `config/*` directory into
`~/.config/*`, wires mise into the pwsh profile, themes the AI coding harnesses
(`pi`, `opencode`, `mammouth`) with catppuccin, and applies the default theme
(frappe).

On a fresh Ubuntu machine (bash):

```bash
bash scripts/bootstrap.sh
```

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

### GitHub Codespaces

The repo ships a `.devcontainer` (Ubuntu 26, all tools baked in via mise, pwsh
as the default shell, sshd enabled). Open it in Codespaces and the bootstrap
runs automatically on startup:

* Click **Code > Codespaces > Create codespace on main**.
* Wait for it to build; `postCreateCommand` runs `scripts/bootstrap.sh` once the
  container starts (installs + themes, no-op for the baked toolchain).
* The terminal opens in pwsh with the tools on `PATH`. Connect over SSH with the
  sshd feature if you prefer.

