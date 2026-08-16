# Dependencies

Everything Taminaru needs, in three layers. Each layer is installed by a
different mechanism and recorded in a different file:

| Layer | Mechanism | Installed by | Recorded in |
| --- | --- | --- | --- |
| System packages | `apt-get` | `scripts/bootstrap.sh` | this doc |
| Tools | mise | `mise install` (via bootstrap) | `mise.toml` / `mise.lock` |
| Conda packages | micromamba | manual / bootstrap | `mise.lock` (imagemagick), this doc |

## Layer 0 — system prerequisites (apt)

`scripts/bootstrap.sh` installs everything apt can provide up front. Two of
these (`curl`, `git`, `sudo`) are *prerequisites*: the bootstrap can't install
them itself, because it's fetched with curl and uses git + sudo throughout. A
fresh Ubuntu install provides none of them, so install them first (see
`README.md`):

```bash
apt-get update
apt-get install -y curl git sudo
```

The full apt list (`scripts/bootstrap.sh`):

```bash
curl git sudo unzip ca-certificates libicu-dev \
  libssl3 libgssapi-krb5-2 zlib1g build-essential libreadline-dev
```

What each is for:

| Package | Why |
| --- | --- |
| `curl` | fetches the mise installer (`https://mise.run`) and the bootstrap one-liner |
| `git` | clones/copies the repo; used by the whole toolchain |
| `sudo` | the few system-wide steps (apt, `/etc/shells`, `chsh`) |
| `unzip` | used by several installers and mise backends |
| `ca-certificates` | TLS trust store so curl/git can reach mise.run, GitHub, conda-forge |
| `libicu-dev` | ICU is required by PowerShell/.NET globalization — mise installs pwsh from a tarball with no apt deps, so the system must provide libicu |
| `libssl3` | TLS runtime lib for gh, curl, node, etc. |
| `libgssapi-krb5-2` | Kerberos/GSSAPI runtime for git/gh network auth |
| `zlib1g` | compression runtime lib |
| `build-essential` | `cc`/`gcc` required to compile nvim's treesitter parsers |
| `libreadline-dev` | readline dev headers (pulls in `libncurses-dev`) so lazy.nvim's hererocks can build the sandboxed Lua 5.1 needed by the `image.nvim`/`magick` luarocks |

The devcontainer image additionally bakes in `libicu-dev` and the rest of the
base image's tooling via `mcr.microsoft.com/devcontainers/base:ubuntu` (see
`.devcontainer/Dockerfile`).

## Layer 1 — tools (mise)

[mise](https://mise.jdx.dev) is itself installed by the bootstrap if missing
(`curl -fsSL https://mise.run | sh`), then every tool in `mise.toml` is
provisioned with `mise install`. Versions are pinned in `mise.lock`; see
[`mise-lock.md`](mise-lock.md).

| Tool | Version | Purpose | Backend |
| --- | --- | --- | --- |
| atuin | 18.19.0 | shell history | `aqua:atuinsh/atuin` |
| bat | 0.26.1 | `cat` clone with syntax highlighting | `aqua:sharkdp/bat` |
| bottom | 0.14.8 | system monitor | `aqua:ClementTsang/bottom` |
| carapace | 1.7.3 | shell completion engine | `aqua:carapace-sh/carapace-bin` |
| difftastic | 0.70.0 | structural `diff` | `aqua:Wilfred/difftastic` |
| dotnet | 10.0.400 | .NET SDK (required by the nvim `cs` pack) | `core` |
| eza | 0.23.5 | `ls` replacement | `aqua:eza-community/eza` |
| fastfetch | 2.67.1 | system info | `aqua:fastfetch-cli/fastfetch` |
| fd | 10.4.2 | `find` replacement | `aqua:sharkdp/fd` |
| fzf | 0.74.2 | fuzzy finder | `aqua:junegunn/fzf` |
| gdu | 5.36.1 | disk usage analyzer | `aqua:dundee/gdu` |
| gh | 2.97.0 | GitHub CLI | `aqua:cli/cli` |
| gum | 0.17.0 | styled output for shell scripts | `aqua:charmbracelet/gum` |
| imagemagick | 7.1.2_27 | image manipulation (conda build) | `conda:imagemagick` |
| jj | 0.44.0 | Jujutsu VCS | `aqua:jj-vcs/jj` |
| lazygit | 0.64.1 | git TUI | `aqua:jesseduffield/lazygit` |
| mammouth | 1.17.11.2 | AI coding harness (via `[tool_alias]`) | `github:mammouth-ai/code` |
| micromamba | 2.9.0-0 | conda package manager (Layer 2) | `github:mamba-org/micromamba-releases` |
| neovim | 0.12.4 | editor | `vfox:mise-plugins/vfox-neovim` |
| node | 24.19.0 (lts) | JS runtime | `core:node` |
| opencode | 1.18.18 | AI coding harness | `aqua:anomalyco/opencode` |
| pi | 0.84.2 | AI coding harness | `aqua:earendil-works/pi` |
| powershell | 7.6.5 | shell (default login shell) | `aqua:PowerShell/PowerShell` |
| ripgrep | 15.2.0 | `grep` replacement | `aqua:BurntSushi/ripgrep` |
| starship | 1.26.0 | prompt | `aqua:starship/starship` |
| vivid | 0.11.1 | `LS_COLORS` generator | `aqua:sharkdp/vivid` |
| yazi | 26.8.15 | terminal file manager | `aqua:sxyazi/yazi` |
| zoxide | 0.10.0 | smarter `cd` | `aqua:ajeetdsouza/zoxide` |

Each tool's config lives in `dotfiles/dot_config/<tool>/` (the chezmoi source)
and is applied to `~/.config/<tool>/` as real files by the bootstrap via
`chezmoi apply`, so the repo stays the single source of truth without symlinks.

## Layer 2 — conda packages (micromamba)

micromamba (Layer 1) is the conda package manager. Two things come from
conda-forge:

### imagemagick

mise manages imagemagick itself via the `conda:` backend
(`imagemagick = "latest"` in `mise.toml`). It resolves to a conda-forge build
whose transitive dependency tree (libjpeg-turbo, libpng, libtiff, openjpeg,
librsvg, graphviz, xorg libs, fonts, ...) is recorded as `conda_deps` in
`mise.lock`. Because these are pinned + checksummed there, imagemagick and all
its shared libraries are installed reproducibly.

### lua + luarocks (documented manual step)

Not in `mise.toml`, installed manually into the micromamba base env:

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
apt-cache policy libicu-dev libssl3 build-essential libreadline-dev

# Layer 1
mise ls                     # every tool + installed version
grep '^\[\[tools\.' mise.lock

# Layer 2
micromamba list | grep -E '^lua|luarocks'
lua -v                      # Lua 5.5.0
luarocks --version          # 3.13.0
```

## Notes

- `mise.lock` is auto-generated; don't edit by hand (see `mise-lock.md`).
- The apt list and all managed files are written by `scripts/bootstrap.sh` —
  keep that script and this doc in sync when dependencies change.
- Tools dropped from `mise.toml` are simply uninstalled; config without a
  managing source file is left untouched (chezmoi only ever writes managed
  paths), so nothing stale is left behind.
