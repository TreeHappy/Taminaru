![./images/terminal.png](./images/kiddy.png)

## Usage

Everything is driven from PowerShell. All tools are provisioned with
[Nix flakes](https://nixos.wiki/wiki/Flakes) and managed by
[home-manager](https://github.com/nix-community/home-manager) in *standalone*
mode (no NixOS — there is no system-level config to touch). Themes are applied
from this repo.

### How home-manager works here

The repo *is* the config — a single source of truth. The pieces:

| Path | Role |
| --- | --- |
| `flake.nix` | entry point: wires up nixpkgs + home-manager and exposes the config |
| `home.nix` | your home-manager module: packages, programs, dotfiles, env vars |
| `dotfiles/` | raw config files (nvim, powershell, atuin, ghostty, ...) referenced by `home.nix` |
| `flake.lock` | exact pinned versions of nixpkgs / home-manager (auto-generated — don't edit) |

Standalone home-manager isn't switched with a `home-manager` binary. The
flake's default package *is* the activation script, so applying a generation is
just `nix build` + `./result/activate` (or `nix run`, which is the same thing
in one command).

### Working with this setup

```bash
# Apply all configs + tools to your system (the one command that matters):
nix run

# Rebuild after editing home.nix or flake.nix, then apply — same as `nix run`,
# but step-by-step:
nix build && ./result/activate

# Update all inputs (nixpkgs, home-manager) to latest:
nix flake update

# See what generations exist:
nix profile history --profile ~/.nix-profile

# Roll back to the previous generation:
nix profile rollback --profile ~/.nix-profile

# Garbage collect old generations (reclaim disk space):
nix-collect-garbage --delete-older-than 5d
```

Common tasks:

- **Add a tool:** append it to `home.packages` in `home.nix`, then rebuild.
- **Change a tool's config:** edit `dotfiles/config/<tool>/` or the
  `programs.<tool>` block in `home.nix`, then rebuild.
- **Update everything:** `nix flake update`, then rebuild.

**Key concept:** `home.nix` (plus `dotfiles/`) = what you want. `flake.lock` =
exact versions pinned. Edit `home.nix` or `dotfiles/`, run
`nix build && ./result/activate` (or `nix run`), commit everything.

## Testing

After implementation, verify:

1. `nix build` succeeds (flake evaluates without errors)
2. `nix run` or home-manager activation applies all configs to $HOME
3. All tools are on PATH after activation
4. pwsh starts and loads profile correctly
5. fish starts and loads all conf.d scripts
6. starship prompt renders with Catppuccin Frappe colors
7. nvim starts with AstroNvim
8. All tools have consistent Catppuccin Frappe theming

### Dependencies

The full dependency stack — apt packages, Nix packages, and the conda
packages (lua, luarocks) — is documented in
[`documentation/dependencies.md`](documentation/dependencies.md).

### Prerequisites

* `curl`, `git`, `sudo` - must be installed before bootstrapping (the one-liner
  below is fetched with curl, and the bootstrap uses git + sudo throughout)
* [Nix](https://nixos.org/download/) - the bootstrap installs it automatically
  via the Determinate Systems installer

### Bootstrap

Installs Nix (via the Determinate Systems installer), then applies the
home-manager configuration which provisions every tool and dotfile from this
repo. The bootstrap also switches the login shell to pwsh.

`curl`, `git` and `sudo` can't be installed by the bootstrap, so install them
first. From a root shell (a fresh Ubuntu install drops you into root):

```bash
apt-get update
apt-get install -y curl git sudo
```

Then provision everything with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/TreeHappy/Taminaru/main/scripts/install.sh | bash
```

Or, if you already have the repo cloned, run the bootstrap directly:

```bash
bash scripts/bootstrap.sh
```

Inside unprivileged containers (plain `docker run`, rootless podman) the script
detects that the Nix sandbox can't run and disables it automatically — see
[`documentation/containers-and-sandbox.md`](documentation/containers-and-sandbox.md).

### Dotfiles sync (home-manager)

The repo's `home.nix` and `dotfiles/` are the single source of truth. Config is
applied to `$HOME` via home-manager (real files, no symlinks).

```bash
bash scripts/sync.sh        # git pull + nix build + activate (repo → $HOME)
bash scripts/sync-push.sh   # commit + push any repo changes
```

Running as root (e.g. right after a fresh Ubuntu install) first creates a
non-root user — default name `taminaru`, passwordless with NOPASSWD sudo,
overridable via `TAMINARU_USER=bob bash scripts/bootstrap.sh` — copies this
repo into that user's home, and re-runs the rest of the bootstrap as them, so
you never have to use root. See
[`documentation/passwordless-sudo.md`](documentation/passwordless-sudo.md) for
how passwordless sudo is set up and verified.

It is idempotent and safe to re-run.

Re-running the bootstrap also **purges the nvim data dirs**
(`~/.local/share/nvim`, `~/.local/state/nvim`, `~/.cache/nvim`, plus any stale
`<dir>.bak` leftovers) so plugins and treesitter parsers are always reinstalled
from the current config, e.g. after an AstroNvim major upgrade. Set
`NVIM_WIPE=0` to keep existing nvim state instead.

### Your pwsh profile

pwsh on Linux reads `~/.config/powershell/profile.ps1`
(`$PROFILE.CurrentUserAllHosts`) at startup. The bootstrap applies the repo's
`dotfiles/config/powershell/profile.ps1` to `~/.config/powershell/profile.ps1`
via home-manager (a real copy, not a symlink) — the repo stays the single source
of truth.

Edit `dotfiles/config/powershell/profile.ps1` in the repo, then
`bash scripts/sync.sh` to re-apply it. Don't edit the bare `$PROFILE` — that
points to `~/.config/powershell/Microsoft.PowerShell_profile.ps1`, which
Taminaru neither creates nor loads.

### Updating

Pull the latest changes and re-apply:

```bash
git -C ~/Taminaru pull && bash ~/Taminaru/scripts/sync.sh
```
