# Pi theme bundle — context & decision record

> **Purpose:** Self-contained notes for the agent (and future me) on how Pi
> themes are wired into this dotfiles repo, what the
> `@firstpick/pi-themes-bundle` package provides, and how/why the bootstrap was
> (or was not) changed. Read this before touching `scripts/bootstrap.sh`,
> `dotfiles/pi/agent/settings.json`, or `dotfiles/pi/agent/themes/`.

## 1. Task

Use the `@firstpick/pi-themes-bundle` package for Pi's Catppuccin theme,
updating `scripts/bootstrap.sh` **only if** that bundle is not already the one
in use.

## 2. Current state (before any change)

The repo manages Pi config under `dotfiles/pi/agent/`; home-manager applies
it to `~/.pi/agent/` as real files via `xdg.configFile`:

- `dotfiles/pi/agent/settings.json` — Pi settings. Currently pins:
  - `"theme": "catppuccin-frappe"`
  - `"packages": ["npm:pi-mcp-adapter", "npm:@maxpaulus/pi-cline"]`
- `dotfiles/pi/agent/themes/*.json` — **local** Pi themes for all four
  Catppuccin flavors: `catppuccin-frappe`, `catppuccin-latte`,
  `catppuccin-macchiato`, `catppuccin-mocha`. These are written in Pi's JSON
  theme format (full official Catppuccin palette in `vars`, standard color
  mapping, `export` block).
- `scripts/bootstrap.sh`:
   - home-manager activation applies all dotfiles (incl. `pi/agent/{settings,mcp}.json`).
  - §3 reads `"npm:..."` entries out of the applied `~/.pi/agent/settings.json`
    and runs `pi install <pkg>` for each (idempotent). **This is the install
    hook for Pi packages.**
- `dotfiles/config/themes/*.tmTheme` — TextMate theme files for a
  different consumer (nvim/other), unrelated to Pi's JSON themes.

**Conclusion: the bundle is NOT currently used.** Pi's Catppuccin comes from
local JSON files, and the bundle package is absent from `settings.json`.

## 3. How Pi theme discovery & packages work

Sources of Pi themes (from `docs/themes.md`):

- Built-in: `dark`, `light`
- Global: `~/.pi/agent/themes/*.json`
- Project: `.pi/themes/*.json` (only after project is trusted)
- **Packages:** a `themes/` directory or a `pi.themes` entry in the package's
  `package.json`
- Settings: a `themes` array of files/dirs
- CLI: `--theme <path>`

A package declares its themes under `package.json` → `"pi": { "themes":
["./themes"] }` (or a conventional `themes/` dir). `pi install npm:<pkg>` pulls
it into `~/.pi/agent/npm/` and Pi auto-loads those themes for discovery. Select
via `settings.json` `"theme": "<name>"` or `/settings`.

Package install/update commands: `pi install`, `pi remove`, `pi list`,
`pi update --all` / `pi update --extensions`. The `"theme"` value must match a
theme's `name` field exactly.

## 4. The bundle: `@firstpick/pi-themes-bundle`

- Source: <https://pi.dev/packages/@firstpick/pi-themes-bundle?name=catppuccin>
- npm: `npm:@firstpick/pi-themes-bundle`, version **0.1.6** (published 2026-08-07),
  MIT, 0 deps, ~39 KB.
- Install: `pi install npm:@firstpick/pi-themes-bundle`
- Manifest: `{ "pi": { "themes": ["./themes"] } }`
- 16 themes: `catppuccin-latte`, `catppuccin-mocha`, `crimson-noir`, `dracula`,
  `everforest-dark`, `gruvbox-dark`, `gruvbox-light`, `matrix`, `nord`,
  `one-dark`, `rose-pine`, `rose-pine-dawn`, `solarized-dark`, `solarized-light`,
  `tokyo-night`, `tokyo-night-storm`.

### 4a. Critical caveats discovered by unpacking the tarball

1. **Only `catppuccin-latte` and `catppuccin-mocha` are included.** The bundle
   does **not** ship `catppuccin-frappe` or `catppuccin-macchiato`. Our current
   default is `catppuccin-frappe`, so a naive switch to the bundle would leave
   `"theme": "catppuccin-frappe"` unresolvable → Pi would fall back to its
   default and silently drop our Catppuccin look. The two flavors the bundle
   does provide also differ in default style (see 4c).
2. **Missing background asset.** The bundle's `catppuccin-mocha.json` (and
   presumably latte) includes an `export.backgroundImage` =
   `"/catppuccin-mocha-background.png"`, but the published tarball contains **no
   PNG assets** (only `.json`, `package.json`, `README.md`, `LICENSE`). Selecting
   that theme may render a broken/missing background image.
3. The bundle themes use a **different, non-standard Catppuccin mapping**: a
   reduced `vars` set (e.g. `accent`, `accent2`, `textSoft`, `bgSelect`,
   `bgUser`, ...) rather than the full official palette
   (`rosewater...crust`), and set `colors.text` to `""`. Its `accent` is `#89b4fa`
   (Catppuccin *Blue*), whereas our local themes use `accent: mauve`. So the
   bundle's Catppuccin will look noticeably different from ours even on the same
   flavor.

### 4b. Same-flavor comparison (mocha): bundle vs local

| Aspect            | Bundle `catppuccin-mocha`          | Local `catppuccin-mocha`          |
|-------------------|------------------------------------|-----------------------------------|
| palette           | reduced custom vars                | full official Catppuccin palette  |
| accent            | `#89b4fa` (Blue)                   | `mauve` (`#cba6f7`)               |
| `colors.text`     | `""`                               | `text` (`#cdd6f4`)                |
| background        | PNG URL (asset not shipped)        | solid `#11111b` (pageBg)          |
| palette fidelity  | loose/approximate                  | faithful to official Catppuccin   |

## 5. Decision — plugin-only (adopted)

**Pi is now themed entirely by the bundle.** The local
`dotfiles/pi/agent/themes/*.json` files were deleted, and pi's default is
`catppuccin-mocha`, which the bundle ships. The setting is written directly in
`dotfiles/pi/agent/settings.json` and falls back to `catppuccin-mocha`
for `frappe`/`macchiato`, since the bundle provides only `catppuccin-latte` and
`catppuccin-mocha`.

Trade-off: the terminal dotfiles (ghostty, starship, etc.) can stay on any
flavor, but **pi supports only latte and mocha** now. If a really dark pi theme
is wanted, `mocha` is the option. (Known bundle quirk: the `catppuccin-mocha`
theme references a background PNG that is not shipped — see §4a.3.)

## 6. Verification steps (after any change)

- `pi list` shows `npm:@firstpick/pi-themes-bundle` installed.
- `~/.pi/agent/settings.json` is a real file applied by home-manager from the
  repo's `dotfiles/pi/agent/settings.json` and reads
  `"theme": "catppuccin-mocha"`.
- `dotfiles/pi/agent/themes/` no longer exists; `~/.pi/agent/themes/` is not
  created by the bootstrap.
- Re-run `bash scripts/bootstrap.sh` and confirm pi package install logs
  `🧩 pi package ready: npm:@firstpick/pi-themes-bundle`, and home-manager
  applies `settings.json`/`mcp.json`.
- Restart pi. In `/settings`, `catppuccin-mocha` is the active theme and renders.

## 7. Key files

| Path                          | Role                                        |
|-------------------------------|---------------------------------------------|
| `scripts/bootstrap.sh`        | home-manager activation; pi pkg install |
| `dotfiles/pi/agent/settings.json` | `theme` (mocha default), `packages` (drives pi install) |
| ~~`dotfiles/pi/agent/themes/*.json`~~ | removed — pi is plugin-only now |
| `dotfiles/config/themes/*.tmTheme` | TextMate themes for another tool (not Pi) |
| `~/.pi/agent/settings.json`   | live settings (applied by home-manager) |
