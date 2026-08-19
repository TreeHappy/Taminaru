# Dependencies

Everything Taminaru needs, in three layers. Each layer is installed by a
different mechanism and recorded in a different file:

| Layer | Mechanism | Installed by | Recorded in |
| --- | --- | --- | --- |
| System packages | `apt-get` | `scripts/bootstrap/bootstrap.sh` | this doc |
| Tools | Nix flakes + home-manager | `nix run` (or `nix build` + `./result/activate`) | `flake.nix` / `flake.lock` / `home.nix` |
| Conda packages | micromamba | manual / bootstrap | this doc |

## Layer 0 — system prerequisites (apt)

`scripts/bootstrap/bootstrap.sh` installs everything apt can provide up front. Two of
these (`curl`, `git`, `sudo`) are *prerequisites*: the bootstrap can't install
them itself, because it's fetched with curl and uses git + sudo throughout. A
fresh Ubuntu install provides none of them, so install them first (see
`README.md`):

```bash
apt-get update
apt-get install -y curl git sudo
```

The full apt list (`scripts/bootstrap/bootstrap.sh`):

```bash
curl git sudo ca-certificates
```

What each is for:

| Package | Why |
| --- | --- |
| `curl` | fetches the Nix installer and the bootstrap one-liner |
| `git` | clones/copies the repo; used by the whole toolchain |
| `sudo` | the few system-wide steps (apt, `/etc/shells`, `chsh`) |
| `ca-certificates` | TLS trust store so curl/git can reach GitHub |

Everything else — including the C compiler for nvim's treesitter parsers —
comes from Nix via home-manager (see Layer 1): `zig` is installed through
`home.nix`, and `cc`/`c++`/`cxx` are shimmed to `zig cc`/`zig c++` so parser
compilation needs no system `build-essential`/gcc. ICU for pwsh is bundled by
the Nix PowerShell package.

## Layer 1 — tools (Nix flakes + home-manager)

[Nix](https://nixos.org/download/) is installed by the bootstrap via the
Determinate Systems installer. All tools are declared in `home.nix` and
provisioned via the flake's activation package — `nix run`, or `nix build` +
`./result/activate` (standalone home-manager, no `home-manager switch`).
Versions are pinned in `flake.lock` (auto-generated, don't edit by hand).

| Tool | nixpkgs attribute | Purpose |
| --- | --- | --- |
| atuin | `atuin` | shell history |
| bat | `bat` | `cat` clone with syntax highlighting |
| bottom | `bottom` | system monitor |
| carapace | `carapace` | shell completion engine |
| difftastic | `difftastic` | structural `diff` |
| eza | `eza` | `ls` replacement |
| fastfetch | `fastfetch` | system info |
| fd | `fd` | `find` replacement |
| fzf | `fzf` | fuzzy finder |
| gdu | `gdu` | disk usage analyzer |
| gh | `gh` | GitHub CLI |
| gum | `gum` | styled output for shell scripts |
| imagemagick | `imagemagick` | image manipulation |
| jj | `jj` | Jujutsu VCS |
| lazygit | `lazygit` | git TUI |
| neovim | `neovim` | editor |
| opencode | `opencode` | AI coding harness |
| pi | `pi-coding-agent` | AI coding harness |
| powershell | `powershell` | shell (default login shell) |
| ripgrep | `ripgrep` | `grep` replacement |
| starship | `starship-prompt` | prompt |
| uv | `uv` | Python package manager |
| vivid | `vivid` | `LS_COLORS` generator |
| yazi | `yazi` | terminal file manager |
| zoxide | `zoxide` | smarter `cd` |
| fish | `fish` | interactive shell |
| zig | `zig` | C/C++ compiler (`cc`/`c++`/`cxx` shims) for nvim's treesitter parser builds |


Each tool's config lives in `dotfiles/config/<tool>/` and is applied to
`~/.config/<tool>/` as real files by home-manager via `xdg.configFile`, so the
repo stays the single source of truth without symlinks.

## Layer 2 — conda packages (micromamba)

micromamba (manual install) is the conda package manager. Two things come from
conda-forge:

### lua + luarocks (documented manual step)

Not in `home.nix`, installed manually:

```bash
micromamba install -c conda-forge lua luarocks
```

Resolves to **lua 5.5.0** + **luarocks 3.13.0** (the current versions; luarocks
3.13.0 is built for Lua 5.5). Add `-n <env>` to keep it out of base.

Why this over the alternatives:

- **apt** (`sudo apt install luarocks`) installs luarocks **3.8.0**, which only
  targets Lua 5.1/5.3 — no 5.4/5.5, and it's years behind.
- **Building from source** (luarocks.org's quick start:
  `wget ... && tar zxpf ... && ./configure && make && sudo make install`)
  needs the build toolchain and `sudo`, and hands you a system-wide install.
  micromamba needs no `sudo`, is version-pinned and reproducible, and is
  trivially removable (`micromamba remove lua luarocks`).

The trade-off: `lua`/`luarocks` live in the micromamba env rather than
`/usr/bin`, so make sure that env is on `PATH` (micromamba's base is activated
by default).

## Verifying

```bash
# Layer 0
apt-cache policy ca-certificates

# Layer 1
nix profile list                     # every Nix package
nix eval .#homeConfigurations.taminaru.config.home.packages --json | jq length
zig version                          # treesitter compiler via nix
cc --version                         # -> zig cc shim

# Layer 2
micromamba list | grep -E '^lua|luarocks'
lua -v                      # Lua 5.5.0
luarocks --version          # 3.13.0
```

## Notes

- `flake.lock` is auto-generated by Nix; don't edit by hand.
- The apt list and all managed files are written by `scripts/bootstrap/bootstrap.sh` —
  keep that script and this doc in sync when dependencies change.
