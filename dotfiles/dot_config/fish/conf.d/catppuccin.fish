# Catppuccin theme for fish shell
# Requires: https://github.com/catppuccin/fish (install via: fisher install catppuccin/fish)
#
# This sets the catppuccin flavor for fish syntax highlighting.
# To change flavor: edit the line below, or set CATPPUCCIN_FLAVOR in config.fish.
# After changing, run: catppuccin_mocha (or _frappe, _latte, _macchiato)

if set -q CATPPUCCIN_FLAVOR
    set -l flavor $CATPPUCCIN_FLAVOR
else
    set -l flavor frappe
end

# Apply catppuccin if the plugin is installed
if functions -q catppuccin_$flavor
    eval catppuccin_$flavor
end
