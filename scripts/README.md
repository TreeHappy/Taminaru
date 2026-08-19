# Taminaru scripts

Internal tooling for provisioning and maintaining Taminaru. User
configuration lives in `home.nix` and `dotfiles/` — **not** here.

## Layout

| Path | Purpose |
|---|---|
| `bootstrap/bootstrap.sh` | Fresh provisioning: apt prereqs, user, Nix, home-manager, pwsh shell. Idempotent; safe to re-run. |
| `bootstrap/install.sh` | curl-friendly launcher: clones the repo (or pulls latest) then runs `bootstrap.sh`. |
| `bootstrap/provision-user.sh` | Single, idempotent implementation of the non-root user. Used by both the devcontainer Dockerfile and bootstrap — edit it once, not in two places. |
| `sync/sync.sh` | `apply` / `push` workflow (below). |
| `host/setup-agent-stack.sh` | Builds the agent containers. Runs on the **host**, not in a container. |

## Workflow

```bash
# Apply the latest config to this machine (pull + rebuild + activate):
bash scripts/sync/sync.sh

# Publish local config changes (commit + push):
bash scripts/sync/sync.sh push "feat: tweak nvim keymaps"

# Fresh provisioning:
bash scripts/bootstrap/bootstrap.sh
```

## Environment variables

| Var | Default | Used by |
|---|---|---|
| `TAMINARU_USER` | `taminaru` | User to provision; also the flake username (via `--impure`). |
| `TAMINARU_UID` | `1000` | Pinned UID for the managed user. |
| `TAMINARU_SANDBOX` | `auto` | Force Nix sandbox on (`1`) or off (`0`); auto-detects unprivileged containers. |
| `NVIM_WIPE` | `1` | Purge nvim data dirs on bootstrap (set `0` to keep). |
| `REPO_URL` / `REPO_DIR` / `BRANCH` | GitHub `main` → `$HOME/Taminaru` | `install.sh` clone overrides. |

## Notes

- Everything here is plumbing; user-visible config lives in `home.nix` and
  `dotfiles/`.
- `provision-user.sh` runs as root only (creates the user and sudoers
  drop-in). The devcontainer Dockerfile and bootstrap's root path both call it.
- The flake reads `TAMINARU_USER` via `getEnv`, so every nix invocation needs
  `--impure` (already handled by these scripts).