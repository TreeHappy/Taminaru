![./images/terminal.png](./images/terminal.png)
![./images/currentscreen.png](./images/currentscreen.png)
## Usage

Everything is driven from PowerShell. All tools are provisioned with
[Nix flakes](https://nixos.wiki/wiki/Flakes) and managed by
[home-manager](https://github.com/nix-community/home-manager). Themes are
applied from this repo.

### Dependencies

The full dependency stack — apt packages, Nix packages, and the conda
packages (imagemagick, lua, luarocks) — is documented in
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

Re-running the bootstrap also **resets the nvim data dirs**
(`~/.local/share/nvim`, `~/.local/state/nvim`, `~/.cache/nvim` — each moved to
`<dir>.bak`) so plugins and treesitter parsers are always reinstalled from the
current config, e.g. after an AstroNvim major upgrade. Set `NVIM_WIPE=0` to keep
existing nvim state instead.

### Your pwsh profile

pwsh on Linux reads `~/.config/powershell/profile.ps1`
(`$PROFILE.CurrentUserAllHosts`) at startup. The bootstrap applies the repo's
`dotfiles/dot_config/powershell/profile.ps1` to `~/.config/powershell/profile.ps1`
via home-manager (a real copy, not a symlink) — the repo stays the single source
of truth.

Edit `dotfiles/dot_config/powershell/profile.ps1` in the repo, then
`bash scripts/sync.sh` to re-apply it. Don't edit the bare `$PROFILE` — that
points to `~/.config/powershell/Microsoft.PowerShell_profile.ps1`, which
Taminaru neither creates nor loads.

### Updating

Pull the latest changes and re-apply:

```bash
git -C ~/Taminaru pull && bash ~/Taminaru/scripts/sync.sh
```

Notes:
- The bootstrap step wipes the nvim data dirs unless `NVIM_WIPE=0` is set.
