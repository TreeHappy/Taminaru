# Pi theme bundle — context & decision record

> **Purpose:** Self-contained notes for the agent (and future me) on how Pi
> themes are wired into this dotfiles repo, what the
> `@firstpick/pi-themes-bundle` package provides, and how/why the bootstrap was
> (or was not) changed. Read this before touching `scripts/bootstrap.sh`,
> `config/pi/settings.json`, or `config/pi/themes/`.

## 1. Task

Use the `@firstpick/pi-themes-bundle` package for Pi's Catppuccin theme,
updating `scripts/bootstrap.sh` **only if** that bundle is not already the one
in use.

## 2. Current state (before any change)

The repo manages Pi config under `config/pi/` and the bootstrap symlinks it into
`~/.pi/agent/`:

- `config/pi/settings.json` — Pi settings. Currently pins:
  - `"theme": "catppuccin-frappe"`
  - `"packages": ["npm:pi-mcp-adapter", "npm:@maxpaulus/pi-cline"]`
- `config/pi/themes/*.json` — **local** Pi themes for all four Catppuccin
  flavors: `catppuccin-frappe`, `catppuccin-latte`, `catppuccin-macchiato`,
  `catppuccin-mocha`. These are written in Pi's JSON theme format (full
  official Catppuccin palette in `vars`, standard color mapping, `export` block).
- `scripts/bootstrap.sh`:
  - §3c symlinks `config/pi/themes/*.json` → `~/.pi/agent/themes/`, and links
    `settings.json` + `mcp.json` → `~/.pi/agent/`.
  - §3d reads `"npm:..."` entries out of the symlinked `settings.json` and runs
    `pi install <pkg>` for each (idempotent). **This is the install hook for Pi
    packages.**
- `scripts/theme.ps1` + `config/powershell/Modules/Taminaru.Theme/` — separate
  from Pi; this is a PowerShell/terminal Catppuccin switcher (not Pi UI
  theming). Don't confuse the two.
- `config/themes/*.tmTheme` (top-level `themes/`) — TextMate theme files for a
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

## 5. Decision & recommended approach

**The bundle is not currently used, so the task technically says to adopt it.**
However, because the bundle (a) omits `frappe`/`macchiato`, (b) drops the current
`frappe` default, and (c) is visually different + has the missing-asset issue,
adopting it as a full replacement would **regress** the current setup.

Recommended path (non-destructive, additive):

1. Add `"npm:@firstpick/pi-themes-bundle"` to the `packages` array in
   `config/pi/settings.json`. §3d of `bootstrap.sh` already installs every entry
   in that array, so **no change to `bootstrap.sh` is strictly required** for the
   extra themes to appear.
2. **Keep** the local `config/pi/themes/*.json` so `catppuccin-frappe` /
   `catppuccin-macchiato` (and the faithful look) keep working. Local files and
   bundle themes coexist; Pi names themes by their `name` field, no collision.
3. **Leave `"theme": "catppuccin-frappe"`** untouched (it resolves via the local
   files). Only if the user wants the bundle's rendering should the theme name be
   changed to `catppuccin-mocha`, and then only with the caveat about the
   missing PNG background.

If instead a full switch is desired, the follow-up edits are:
- `config/pi/settings.json`: `"theme": "catppuccin-mocha"` + add bundle to
  `packages`.
- Optionally stop symlinking `config/pi/themes/*.json` in `bootstrap.sh` §3c and
  delete the local JSON files. (Not recommended — loses `frappe`/`macchiato`.)

## 6. Verification steps (after any change)

- `pi list` shows the bundle installed.
- `~/.pi/agent/settings.json` still reflects the repo's `config/pi/settings.json`
  (it's a symlink created by §3c).
- Re-run `bash scripts/bootstrap.sh` and confirm:
  - §3d logs `🧩 pi package ready: npm:@firstpick/pi-themes-bundle`.
  - §3c logs the theme symlinks.
- In Pi, `/settings` lists both the local Catppuccin themes and the bundle's.
- `catppuccin-frappe` still renders (resolves from local files).

## 7. Key files

| Path                          | Role                                        |
|-------------------------------|---------------------------------------------|
| `scripts/bootstrap.sh`        | §3c themes/settings symlinks; §3d pkg install |
| `config/pi/settings.json`     | `theme`, `packages` (drives §3d installs)   |
| `config/pi/themes/*.json`     | local Pi Catppuccin themes (keep)           |
| `scripts/theme.ps1`           | PowerShell terminal theme switcher (unrelated to Pi UI) |
| `config/themes/*.tmTheme`     | TextMate themes for another tool (not Pi)   |
| `~/.pi/agent/settings.json`   | live settings (symlinked to the repo)       |
