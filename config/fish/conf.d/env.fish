# Environment variables (mirrors profile.ps1)
set -gx EDITOR nvim
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx YAZI_CONFIG_HOME "$HOME/.config/yazi/"
set -gx CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense'
set -gx GIT_EXTERNAL_DIFF difft
set -gx BAT_THEME 'Catppuccin Frappe'

# LS_COLORS via vivid (mirrors theme.ps1)
if command -vq vivid
    set -gx LS_COLORS (vivid generate catppuccin-frappe 2>/dev/null)
end

# fzf colors (catppuccin frappe, mirrors theme.ps1)
set -gx FZF_DEFAULT_OPTS '--color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 --color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf --color=marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284 --color=selected-bg:#51576d --color=border:#737994,label:#c6d0f5'
