# Theme Switching

This config uses [stylix](https://github.com/nix-community/stylix) for unified
theming across all tools. A single base16 color scheme is applied automatically
to: fish, starship, fzf, bat, ghostty, neovim, yazi, lazygit, and bottom.

## Quick Switch

1. Edit `home.nix` and change the `activeTheme` variable near the top:

```nix
activeTheme = "everforest-dark-hard";  # was "catppuccin-frappe"
```

2. Rebuild:

```bash
home-manager switch --flake .#taminaru
```

## Available Themes

| Theme | Description |
|-------|-------------|
| `catppuccin-frappe` | Soft pastel palette (default) |
| `everforest-dark-hard` | Green-toned, high contrast |

Both are included in `pkgs.base16-schemes` and work out of the box.

## Adding a New Theme

1. Browse available schemes at https://tinted-theming.github.io/tinted-gallery/
2. Find the scheme name (the filename without `.yaml`, e.g. `gruvbox-dark-hard`)
3. Set it in `home.nix`:

```nix
activeTheme = "gruvbox-dark-hard";
```

4. Rebuild with `home-manager switch --flake .#taminaru`

## Tools Managed by Stylix

These tools get their colors automatically from the active theme:

- **fish** — shell syntax highlighting and prompt colors
- **starship** — prompt segment colors
- **fzf** — fuzzy finder UI colors
- **bat** — syntax highlighting theme
- **ghostty** — terminal background/foreground colors
- **neovim** — editor colorscheme (via catppuccin plugin)
- **yazi** — file manager colors
- **lazygit** — git UI colors
- **bottom** — system monitor colors

## Tools With Standalone Configs

These tools have their own theme files that are not managed by stylix.
To update them for a new theme, replace the relevant config file:

- **eza** — `dotfiles/config/eza/theme.yml`
- **atuin** — `dotfiles/config/atuin/themes/`

## How It Works

Stylix reads a base16 YAML scheme (16 named colors) and maps them to each
tool's color options. The mapping follows the
[base16 style guide](https://github.com/chriskempson/base16/blob/main/styling.md):

| Slot | Role | Example Use |
|------|------|-------------|
| base00 | Default background | Terminal bg |
| base01 | Alternate background | Selection bg |
| base02 | Selection background | Highlight bg |
| base03 | Comments, invisibles | Dimmed text |
| base04 | Dark text (foreground) | Alt foreground |
| base05 | Default text | Primary foreground |
| base06 | Light foreground | Rarely used |
| base07 | Highest highlight | Bold white |
| base08 | Red | Errors, deleted |
| base09 | Orange | Integers, constants |
| base0A | Yellow | Classes, warnings |
| base0B | Green | Strings, success |
| base0C | Cyan | Regular expressions |
| base0D | Blue | Functions, keywords |
| base0E | Magenta | Errors (light) |
| base0F | Brown | Deprecated, embedded |

## Troubleshooting

**Theme not applying?** Check that `stylix.enable = true` is set and the
scheme file exists:

```bash
ls /nix/store/*/share/themes/${activeTheme}.yaml
```

**Specific tool not themed?** Each tool has a target that can be disabled.
Check `home.nix` for any `stylix.targets.<name>.enable = false` lines.

**Want to preview a theme without rebuilding?** View the generated palette:

```bash
cat ~/.config/stylix/palette.html | xdg-open
```
