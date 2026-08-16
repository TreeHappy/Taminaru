# Decisions

* Package manager: **mise** for every CLI/dev tool (`mise.toml` + `mise.lock` pin versions). winget stays for Windows-only GUI/OS tooling.
* Dotfile manager: none (plain symlinks) - `scripts/bootstrap.sh` (fresh Ubuntu) / `scripts/bootstrap.ps1` (Windows) symlink `config/*` into `~/.config/*`; the repo stays the single source of truth. Chezmoi was considered and dropped (no per-machine templating needed yet).
* Shell / console: **PowerShell (pwsh)** everywhere, and pwsh itself is provisioned via mise (pinned like every other tool). The bootstrap wires `mise activate pwsh` into the profile.
* Scripting: bootstrap is bash (`scripts/bootstrap.sh`) so a fresh Ubuntu box can be provisioned; the theme switcher lives in a pwsh module (`Taminaru.Theme`) loaded from `$PROFILE`, with a thin `scripts/theme.ps1` CLI wrapper.
* Theme: **Catppuccin frappe by default**, switchable via `Set-TaminaruTheme` (latte/frappe/macchiato/mocha). Canonical files in the repo are frappe; the module rewrites them in place (current -> target flavor).
* Codespaces: `.devcontainer` on **ubuntu:26.04** with the toolchain baked in via mise, pwsh default shell, sshd feature enabled, and `postCreateCommand` running `scripts/bootstrap.sh` on container start.