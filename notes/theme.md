# Theme

All tools are themed with [Catppuccin](https://catppuccin.com/) and the default
flavor is **frappe**. The theme switcher is a pwsh module, **Taminaru.Theme**
(`config/powershell/Modules/Taminaru.Theme/`), loaded from `$PROFILE`, which
switches every tool between the four flavors: `latte`, `frappe`, `macchiato`,
`mocha`.

## Running it

From any pwsh session (the module is imported by `$PROFILE`):

```powershell
Set-TaminaruTheme            # default: frappe
Set-TaminaruTheme macchiato  # any flavor
Get-TaminaruTheme            # prints the active flavor
```

There is also a CLI wrapper for bash/bootstrap:

```powershell
pwsh ./scripts/theme.ps1            # default: frappe
pwsh ./scripts/theme.ps1 macchiato  # any flavor
```

The bootstrap (`scripts/bootstrap.sh` / `scripts/bootstrap.ps1`) runs the theme
installer automatically, so a fresh machine only needs the bootstrap.

## How it works

`config/` is the single source of truth and the canonical files in the repo are
**frappe**. The script:

1. Detects the currently active flavor from `config/ghostty/config`
   (`theme = "Catppuccin <Flavor>"`).
2. Replaces every CURRENT flavor hex with the target flavor hex in the in-place
   config files (`CURRENT -> TARGET`), so switching always round-trips cleanly.
3. Regenerates flavor-named files (waybar/rofi/hypr) from the canonical frappe
   version so the result is deterministic regardless of the previous flavor.
4. Deletes stale flavor-named files (only `frappe.<ext>` + `<target>.<ext>`
   remain), keeping the repo clean.
5. Copies the matching vendored syntax theme
   (`config/themes/Catppuccin <Flavor>.tmTheme`) for yazi and bat.

## What gets themed

| Tool | File | Mechanism |
| ---- | ---- | --------- |
| pwsh | `config/powershell/theme.ps1` | generated: PSReadLine colors, `FZF_DEFAULT_OPTS`, `BAT_THEME`, `LS_COLORS` (vivid) |
| eza | `config/eza/theme.yml` | hex swap |
| yazi | `config/yazi/theme.toml` + `Catppuccin-<flavor>.tmTheme` | hex swap + theme file |
| bat | `config/bat/themes/Catppuccin <Flavor>.tmTheme` | theme file |
| starship | `config/starship/starship.toml` | hex swap |
| neovim | `config/nvim/lua/plugins/catppuccin.lua` | `flavour = "<flavor>"` |
| ghostty | `config/ghostty/config` | `theme = "Catppuccin <Flavor>"` |
| wezterm | `config/wezterm/wezterm.lua` | `color_scheme` |
| waybar | `config/waybar/themes/<flavor>.css` + import | regenerated from `frappe.css` |
| rofi | `config/rofi/catppuccin-<flavor>.rasi` + import | regenerated from `catppuccin-frappe.rasi` |
| wofi | `config/wofi/style.css` | hex + rgb swap |
| hyprland | `config/hypr/themes/<flavor>.conf` + source | regenerated from `frappe.conf` |

`LS_COLORS` for vivid is generated on the fly (`vivid generate catppuccin-<flavor>`);
vivid ships all four catppuccin themes built in.

## Palette

The palette lives in `scripts/theme.ps1` as nested hashtables
(`flavor -> color -> hex`), sourced from https://catppuccin.com/palette.
A small note on collisions: across the four flavors every hex is unique except
latte's `base`/`surface0` (both `eff1f5`), which is harmless since the current
and target palettes never use that pair simultaneously.
