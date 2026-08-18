![./images/terminal.png](./images/terminal.png)
![./images/currentscreen.png](./images/currentscreen.png)
## Usage

Everything is driven from PowerShell. All tools are provisioned with [mise](https://mise.jdx.dev)
(see `mise.toml` / `mise.lock`), and themes are applied from this repo.

### Dependencies

The full dependency stack — apt packages, all 27 mise tools, and the conda
packages (imagemagick, lua, luarocks) — is documented in
[`documentation/dependencies.md`](documentation/dependencies.md).

### Prerequisites

* `curl`, `git`, `sudo` - must be installed before bootstrapping (the one-liner
  below is fetched with curl, and the bootstrap uses git + sudo throughout)
* [mise](https://mise.jdx.dev/getting-started) - the bootstrap installs it automatically if missing
* PowerShell 7+ (`pwsh`) to run the scripts - only needed for the first bootstrap; after that pwsh itself is provisioned and pinned via mise (see `mise.toml`)

### Bootstrap

Installs all tools with mise (including the `pi` and `mammouth` coding
harnesses), applies the dotfiles with [chezmoi](https://www.chezmoi.io/) (no
symlinks — the repo's `dotfiles/` is the chezmoi source, applied as real files
into `$HOME`), wires mise into the pwsh profile, themes the AI coding harnesses
(`pi`, `opencode`, `mammouth`) with catppuccin, and applies the default theme
(frappe).

`curl`, `git` and `sudo` can't be installed by the bootstrap, so install them
first. From a root shell (a fresh Ubuntu install drops you into root):

```bash
apt-get update
apt-get install -y curl git sudo
```

Then provision everything with a single command (mise-style):

```bash
curl -fsSL https://raw.githubusercontent.com/TreeHappy/Taminaru/main/scripts/install.sh | bash
```

The one-liner forwards `FLAVOR` and `TAMINARU_USER`:

```bash
curl -fsSL https://raw.githubusercontent.com/TreeHappy/Taminaru/main/scripts/install.sh | FLAVOR=mocha TAMINARU_USER=bob bash
```

Or, if you already have the repo cloned, run the bootstrap directly:

```bash
bash scripts/bootstrap.sh
```

### Dotfiles sync (chezmoi)

The repo's `dotfiles/` is the chezmoi source; config is applied to `$HOME` as
real files (no symlinks), so the machine stands alone and the repo stays the
single source of truth.

```bash
bash scripts/sync.sh        # git pull + chezmoi apply (repo → $HOME)
bash scripts/sync-push.sh   # capture home edits back + commit + push
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

Running the tools from a container? `podman exec ... pwsh` won't find pwsh
because exec skips shell startup (so mise is never activated). `podman exec -u
taminaru -it <container> bash` opens an interactive shell that activates mise
and starts pwsh — see
[`documentation/podman-exec.md`](documentation/podman-exec.md).

### SSH access (tunnel in/out)

The bootstrap configures `sshd` with **passwordless key auth** and enables TCP
forwarding, so you can SSH into this machine and tunnel out of it. It listens on
port `2222` by default (override with `TAMINARU_SSH_PORT=22 bash scripts/bootstrap.sh`).

* A fresh ed25519 client keypair is generated at `~/.ssh/id_ed25519` and its
  **private key is printed at the end of the bootstrap** — save it, then connect
  from anywhere:

  ```bash
  ssh -i ~/.ssh/id_ed25519 -p 2222 taminaru@<host>
  ```

* Passwords are disabled (`PasswordAuthentication no`); only key auth is allowed.
* Ports can be tunneled both ways (`AllowTcpForwarding yes`). Reverse forwards
  bind to loopback by default; use `ssh -R *:8080:localhost:80 ...` to expose a
  port on all interfaces (`GatewayPorts clientspecified`).

For a container, map the port (`podman run -p 2222:2222 ...`). Note the
devcontainer already ships its own sshd on 2222 via the sshd feature, so its
listener will win over the bootstrap's in that image.

For `-L`/`-R`/`-D`/jump-host tunneling recipes (getting the key out, exposing
container services on the host, and reaching the container's network from
outside), see [`documentation/ssh-tunneling.md`](documentation/ssh-tunneling.md).

### Sharing your terminal (tty-share)

[tty-share](https://tty-share.com) shares your live terminal over the internet
with a single HTTPS browser link — the person on the other side needs no tool
and no account.

```bash
tty-share --public
```

This prints a secret URL like `https://go.tty-share.com/s/<token>`; send it to
your guest, they open it in any browser and join your session. Useful flags:

| Flag | Meaning |
| --- | --- |
| `--public` | make the session reachable over the internet (default is LAN-only) |
| `--readonly` | let guests view but not type |
| `--headless` | run without an interactive terminal (e.g. from a script/CI) |
| `--no-wait` | start the session without waiting for `Enter` |

The connection is fully encrypted. Because it is a live PTY, size rendering is
cleanest when your terminal is multiplexed — e.g. wrap it with `tmux` or run it
from your usual `pwsh` session.

### Your pwsh profile

pwsh on Linux reads `~/.config/powershell/profile.ps1`
(`$PROFILE.CurrentUserAllHosts`) at startup. The bootstrap applies the repo's
`dotfiles/dot_config/powershell/profile.ps1` to `~/.config/powershell/profile.ps1`
via chezmoi (a real copy, not a symlink) — the repo stays the single source of
truth.

Edit `dotfiles/dot_config/powershell/profile.ps1` in the repo, then
`bash scripts/sync.sh` to re-apply it (or edit `~/.config/powershell/profile.ps1`
and run `bash scripts/sync-push.sh` to capture the change back). Don't edit the
bare `$PROFILE` — that points to
`~/.config/powershell/Microsoft.PowerShell_profile.ps1`, which Taminaru neither
creates nor loads.

Keep the `# --- Taminaru managed ---` block intact: it dot-sources
`theme.ps1` and `mise.ps1` and imports the `Taminaru.Theme` module (which
provides `Set-TaminaruTheme` and `Update-Taminaru`).

Verify with:

```powershell
pwsh -NoProfile -Command '$PROFILE.CurrentUserAllHosts'
# => /home/<user>/.config/powershell/profile.ps1
```

### Updating

The pwsh module (loaded from `$PROFILE`) also updates Taminaru. From any
pwsh session:

```powershell
Update-Taminaru
```

It runs three steps, all in `~/Taminaru`:
1. Restores every tracked file to HEAD (`git checkout -- .`)
2. Pulls the latest commit from origin (`git pull`)
3. Re-runs `bash scripts/bootstrap.sh` to regenerate config, themes, and tools

Notes:
- **Uncommitted changes are discarded** — commit anything you want to keep
  first: `git -C ~/Taminaru add -A && git -C ~/Taminaru commit`.
- Theme switches are uncommitted repo edits, so an update resets the flavor to
  the default (frappe); re-apply afterwards with
  `Set-TaminaruTheme macchiato`.
- The bootstrap step wipes the nvim data dirs unless `NVIM_WIPE=0` is set.
- Manual equivalent:
  `git -C ~/Taminaru pull && bash ~/Taminaru/scripts/bootstrap.sh`.

### Theme switcher

The theme switcher is a pwsh module (`Taminaru.Theme`) that is loaded from your
pwsh profile (see [Your pwsh profile](#your-pwsh-profile)), so you can switch
flavors from any pwsh session:

```powershell
Set-TaminaruTheme macchiato    # latte | frappe | macchiato | mocha
Get-TaminaruTheme              # prints the active flavor
```

There is also a CLI wrapper for bash/bootstrap:

```powershell
pwsh ./scripts/theme.ps1            # default: frappe
pwsh ./scripts/theme.ps1 mocha
```
