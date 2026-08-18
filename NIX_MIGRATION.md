# Taminaru: mise + chezmoi → Nix flakes + home-manager Migration

> Branch: `nix`
> Created: 2026-08-18

## Goal

Replace **mise** (tool provisioning) and **chezmoi** (dotfile management) with
**Nix flakes** + **home-manager**. One `nix build` provisions every tool and
applies every dotfile, fully reproducible via `flake.lock`.

## Architecture

| Component | Before | After |
|---|---|---|
| Tool provisioning | `mise.toml` / `mise.lock` | `flake.nix` + `flake.lock` |
| Dotfile management | `chezmoi` (`dotfiles/`) | `home-manager` (`home.nix`) |
| Bootstrap | `curl mise.run` + `mise install` | Determinate Systems Nix installer + `nix run` |
| Shell activation | `mise activate` | `home-manager` profile in shell rc |
| Version pinning | `mise.lock` | `flake.lock` (auto-generated) |
| Sync to machine | `bash scripts/sync.sh` | `home-manager switch` |
| Sync back to repo | `bash scripts/sync-push.sh` | Edit `home.nix` + `git commit` |

## New File Layout

```
Taminaru/
├── flake.nix              # Entry point: inputs (nixpkgs, home-manager), outputs
├── flake.lock             # Auto-generated pin file (replaces mise.lock)
├── home.nix               # home-manager config: packages, dotfiles, shell hooks
├── dotfiles/              # Raw source for configs referenced by home.nix
│   ├── config/            # (was dot_config — renamed to drop chezmoi convention)
│   │   ├── nvim/          # AstroNvim (too complex for home-manager modules)
│   │   ├── powershell/    # pwsh profile
│   │   ├── yazi/          # yazi config
│   │   ├── carapace/      # carapace completions
│   │   ├── atuin/         # atuin config + themes
│   │   ├── ghostty/       # ghostty config
│   │   ├── wezterm/       # wezterm config
│   │   ├── opencode/      # opencode config
│   │   ├── mammouth/      # mammouth config
│   │   ├── themes/        # TextMate themes
│   │   └── eza/           # eza theme
│   └── pi/                # (was dot_pi — renamed to drop chezmoi convention)
│       └── agent/         # pi agent settings + MCP config
├── scripts/
│   ├── bootstrap.sh       # Rewritten: install Nix + apply home-manager
│   ├── sync.sh            # Rewritten: home-manager switch
│   └── sync-push.sh       # Simplified: git add/commit/push
└── .gitignore             # Updated
```

## Tool Mapping (mise → nixpkgs)

| Tool | nixpkgs attribute |
|---|---|
| atuin | `atuin` |
| bat | `bat` |
| bottom | `bottom` |
| carapace | `carapace` |
| difftastic | `difftastic` |
| eza | `eza` |
| fastfetch | `fastfetch` |
| fd | `fd` |
| fzf | `fzf` |
| gdu | `gdu` |
| gh | `gh` |
| gum | `gum` |
| imagemagick | `imagemagick` |
| jj | `jj` |
| lazygit | `lazygit` |
| mammouth | REMOVED (not in nixpkgs, upstream lockfile broken) |
| neovim | `neovim` |
| opencode | `opencode` |
| pi | `pi-coding-agent` |
| powershell | `powershell` |
| ripgrep | `ripgrep` |
| starship | `starship` |
| uv | `uv` |
| vivid | `vivid` |
| yazi | `yazi` |
| zoxide | `zoxide` |
| fish | `fish` |

## Tasks

### Phase 1: Core Nix Files ✅

- [x] 1. Create `flake.nix` with nixpkgs + home-manager inputs
- [x] 2. Create `home.nix` with packages, programs, sessionVariables, xdg.configFile

### Phase 2: Scripts ✅

- [x] 3. Rewrite `scripts/bootstrap.sh` — install Nix via Determinate Systems, then `nix build`
- [x] 4. Rewrite `scripts/sync.sh` — `nix build` + activate
- [x] 5. Rewrite `scripts/sync-push.sh` — just git add/commit/push

### Phase 3: Cleanup ✅

- [x] 6. Remove `mise.toml` and `mise.lock`
- [x] 7. Remove chezmoi-specific files (`.chezmoiignore`, `dot_bashrc`, `dot_gitconfig`, `mise.ps1`)
- [x] 8. Update `.gitignore` (add result symlink, remove mise references)
- [x] 9. Update `README.md` for Nix workflow
- [x] 10. Update `.devcontainer/Dockerfile` for Nix (no .devcontainer found — skipped)
- [x] 11. Update `documentation/dependencies.md`

### Phase 4: Theme System (Deferred)

- [x] 12. Update `scripts/theme.ps1` paths (no longer chezmoi-based)
- [x] 13. Update `Taminaru.Theme.psm1` — remove chezmoi references
- [x] 14. **Remove theme switching system** — tinty, Taminaru.Theme module, theme.ps1, generated configs
- [x] 15. **Static Catppuccin Frappe theming** — hardcode frappe colors into all tools via home.nix and config files

### Phase 5: Repo Cleanup

- [x] 16. **Rename `dot_*` folders** — drop chezmoi naming convention:
  - `dotfiles/dot_config/` → `dotfiles/config/`
  - `dotfiles/dot_pi/` → `dotfiles/pi/`
  - `dotfiles/config/nvim/dot_luarc.json` → `.luarc.json`
  - `dotfiles/config/nvim/dot_neoconf.json` → `.neoconf.json`
  - `dotfiles/config/nvim/dot_stylua.toml` → `.stylua.toml`
- [x] 17. **Update all path references** — home.nix, scripts, docs after rename
- [x] 18. **Remove chezmoi from packages** — once migration is verified
- [x] 19. **Remove icons folder** - icons folder is not required any longer

### Phase 6: Dynamic Theming (Future)

- [ ] 20. **Explore [stylix](https://github.com/nix-community/stylix)** — Nix-native dynamic theming that could replace manual color hardcoding. Generates consistent themes across all tools (starship, fzf, bat, ghostty, neovim, etc.) from a single base16/catppuccin palette declaration. Evaluate as a replacement for the static Catppuccin Frappe hardcoding in task 15.

## Key Decisions

1. **AstroNvim stays as raw files** — `xdg.configFile` copies the nvim/ dir.
   home-manager's neovim module is too opinionated for AstroNvim.

2. **PowerShell profile stays as raw file** — `xdg.configFile` copies the
   powershell/ dir. The pwsh profile is too complex for home-manager modules.

3. **mammouth removed** — not in nixpkgs, third-party flake had stale
   `bun.lock` causing build failures. Can be re-added later if upstream fixes.

4. **Default shell** is still pwsh. home-manager doesn't manage system-level
   shell changes — bootstrap.sh still runs `chsh`.

5. **dotfiles/ naming convention changes.** `dot_config/` and `dot_pi/` are
   renamed to `config/` and `pi/` since chezmoi naming is no longer needed.

6. **stylix is the candidate for dynamic theming.** If theme switching is wanted
   again, [stylix](https://github.com/nix-community/stylix) is the Nix-native
   approach — it generates consistent color configs for all tools from a single
   palette declaration, replacing the manual per-tool color hardcoding.

## TL;DR: Working with this setup

```bash
# Apply all configs + tools to your system (the one command that matters):
nix run

# Rebuild after editing home.nix or flake.nix:
nix build
./result/activate

# One-liner for the above:
nix build && ./result/activate

# Update all inputs (nixpkgs, home-manager) to latest:
nix flake update

# Garbage collect old generations (reclaim disk space):
nix-collect-garbage --delete-older-than 5d

# See what generations exist:
nix profile history --profile ~/.nix-profile

# Roll back to previous generation:
nix profile rollback
```

**Key concept:** `home.nix` = what you want. `flake.lock` = exact versions pinned.
Edit `home.nix`, run `nix build && ./result/activate`, commit everything.

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

## Testing Log

### 2026-08-18: First full test run (testuser account)

Created a fresh `testuser` account to test the bootstrap from scratch.

**Issues found and fixed:**

1. **`flake.nix` — `self` undefined** (line 36): The `outputs` function
   referenced `self.homeConfigurations` but didn't receive `self` in its
   arguments. Fixed by adding `self` to the outputs function signature.

2. **`home.nix` — `starship-prompt` undefined** (line 32): The nixpkgs
   attribute is `starship`, not `starship-prompt`. Renamed the package.

3. **`bootstrap.sh` — `--no-confirm` flag rejected by nix-installer v3**:
   The Determinate Systems nix-installer v3 (3.21.9) no longer accepts
   `--no-confirm` as a CLI flag. Fixed by using the `NIX_INSTALLER_NO_CONFIRM`
   environment variable and passing `install linux` subcommand explicitly.

4. **`bootstrap.sh` — no systemd in containers/WSL**: The installer defaults
   to using systemd for the nix-daemon service. Without systemd, it fails.
   Fixed by detecting systemd via `pidof systemd` and passing `--init none`
   when absent.

5. **`bootstrap.sh` — nix-daemon not running**: With `--init none`, the
   nix-daemon isn't started automatically. The script tried to start it as
   the regular user, which fails because the socket must be owned by root.
   Fixed by using `sudo nix-daemon &` when systemd is not available.

**Remaining upstream issue:**

- `opencode` build fails because the flake input's `bun.lock` is stale
  (`lockfile had changes, but lockfile is frozen`). This is an issue in the
  `mammouth-code-nix` flake input, not in our config.

### 2026-08-18: taminaru2 account — migration complete

Switched from testuser to the real `taminaru2` account. Everything works:

- `flake.nix` config renamed to `homeConfigurations.taminaru2`
- `home.nix` username/homeDirectory set to `taminaru2`
- All tools on PATH after activation
- pwsh, fish, starship, nvim all functional
- Catppuccin Frappe theme applied across all tools
- `mise.toml` deleted (replaced entirely by Nix)
- Lean nix config: `auto-optimise-store`, `max-jobs auto`
