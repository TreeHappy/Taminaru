{ config, pkgs, ... }:

{
  home.username = "taminaru";
  home.homeDirectory = "/home/taminaru";
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  # ── Packages ──────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Core tools
    atuin
    bat
    bottom
    carapace
    difftastic
    eza
    fastfetch
    fd
    fzf
    gdu
    gh
    gum
    imagemagick
    jj
    lazygit
    neovim
    opencode
    pi-coding-agent
    powershell
    ripgrep
    starship
    uv
    vivid
    yazi
    zoxide
    fish
  ];

  # ── Shell: Bash (minimal — hands off to pwsh) ────────────────────────
  programs.bash = {
    enable = true;
    initExtra = ''
      # Launch pwsh from interactive bash
      if command -v pwsh >/dev/null 2>&1 && [[ $- == *i* ]]; then
          cd "$HOME"
          exec pwsh
      fi
    '';
    shellOptions = [];
    bashrcExtra = "";
    profileExtra = "";
  };

  # ── Shell: Fish ──────────────────────────────────────────────────────
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Aliases
      alias ls eza
      alias cat bat

      # Atuin
      set -gx ATUIN_DB_PATH "$HOME/.local/share/atuin/fish/history.db"
      atuin init fish | source

      # Carapace completions
      carapace _carapace fish | source

      # Starship prompt
      starship init fish | source

      # Zoxide
      zoxide init fish | source

      # Catppuccin Frappe (hardcoded — no fisher plugin needed)
      set -g fish_color_normal c6d0f5
      set -g fish_color_command 8caaee
      set -g fish_color_param eebebe
      set -g fish_color_keyword ca9ee6
      set -g fish_color_quote a6d189
      set -g fish_color_redirection f4b8e4
      set -g fish_color_end ef9f76
      set -g fish_color_comment 838ba7
      set -g fish_color_error e78284
      set -g fish_color_gray 737994
      set -g fish_color_selection --background=414559
      set -g fish_color_search_match --background=414559
      set -g fish_color_option a6d189
      set -g fish_color_operator f4b8e4
      set -g fish_color_escape ea999c
      set -g fish_color_autosuggestion 737994
      set -g fish_color_cancel e78284
      set -g fish_color_cwd e5c890
      set -g fish_color_user 81c8be
      set -g fish_color_host 8caaee
      set -g fish_color_host_remote a6d189
      set -g fish_color_status e78284
      set -g fish_pager_color_progress 737994
      set -g fish_pager_color_prefix f4b8e4
      set -g fish_pager_color_completion c6d0f5
      set -g fish_pager_color_description 737994
    '';
    shellAbbrs = {};
    functions = {};
  };

  # ── Git ──────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings = {
      user.name = "TreeHappy";
      user.email = "97783479+TreeHappy@users.noreply.github.com";
      credential."https://github.com".helper = "!gh auth git-credential";
      credential."https://gist.github.com".helper = "!gh auth git-credential";
    };
  };

  # ── Starship prompt ──────────────────────────────────────────────────
  programs.starship = {
    enable = true;
    settings = {
      character = {
        success_symbol = "[ 🎏](bold #a6d189)";
        error_symbol = "[ 👹](bold #e78284)";
      };
      git_branch = {
        symbol = "🌿 ";
        style = "bold #e5c890";
      };
      time = {
        format = "$H:$M:$S";
        style = "bold #8caaee";
      };
      username = {
        style_user = "bold #a6d189";
        style_root = "bold #e78284";
        format = "[$user]($style)";
        disabled = false;
      };
      hostname = {
        ssh_only = true;
        format = "[@$hostname](bold #a6d189)";
      };
      directory = {
        style = "bold #a6d189";
        format = "[$path]($style) ";
        truncation_length = 3;
        truncation_symbol = "…/";
      };
      git_status = {
        conflicted = "💣";
        ahead = "📤";
        behind = "📥";
        diverged = "😵";
        untracked = "★";
        stashed = "📦";
        modified = "";
        staged = "✓";
        renamed = "🗘";
        deleted = "";
        style = "bold #e78284";
      };
      docker_context = {
        symbol = " 🐳 ";
        style = "bold #8caaee";
        format = "[$symbol$context]($style)";
      };
    };
  };

  # ── Bat ──────────────────────────────────────────────────────────────
  programs.bat = {
    enable = true;
    config.theme = "Catppuccin Frappe";
  };

  # ── FZF ──────────────────────────────────────────────────────────────
  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    colors = {
      "bg+" = "#414559";
      bg = "#303446";
      spinner = "#f2d5cf";
      hl = "#e78284";
      fg = "#c6d0f5";
      header = "#e78284";
      info = "#ca9ee6";
      pointer = "#f2d5cf";
      marker = "#babbf1";
      "fg+" = "#c6d0f5";
      prompt = "#ca9ee6";
      "hl+" = "#e78284";
      "selected-bg" = "#51576d";
      border = "#737994";
      label = "#c6d0f5";
    };
  };

  # ── Eza ──────────────────────────────────────────────────────────────
  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  # ── Zoxide ───────────────────────────────────────────────────────────
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  # ── Ripgrep ──────────────────────────────────────────────────────────
  programs.ripgrep = {
    enable = true;
  };

  # ── Environment Variables ────────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = "nvim";
    YAZI_CONFIG_HOME = "${config.home.homeDirectory}/.config/yazi/";
    XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
    CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";
    GIT_EXTERNAL_DIFF = "difft";
  };

  # ── Raw config files (tools without home-manager modules) ────────────
  xdg.configFile = {
    # ── Neovim (AstroNvim) ──
    "nvim/init.lua".source = ./dotfiles/config/nvim/init.lua;
    "nvim/neovim.yml".source = ./dotfiles/config/nvim/neovim.yml;
    "nvim/selene.toml".source = ./dotfiles/config/nvim/selene.toml;
    "nvim/README.md".source = ./dotfiles/config/nvim/README.md;
    "nvim/.luarc.json".source = ./dotfiles/config/nvim/.luarc.json;
    "nvim/.neoconf.json".source = ./dotfiles/config/nvim/.neoconf.json;
    "nvim/.stylua.toml".source = ./dotfiles/config/nvim/.stylua.toml;
    "nvim/lua" = {
      source = ./dotfiles/config/nvim/lua;
      recursive = true;
    };

    # ── PowerShell ──
    "powershell/profile.ps1".source = ./dotfiles/config/powershell/profile.ps1;
    "powershell/tools.psm1".source = ./dotfiles/config/powershell/tools.psm1;

    # ── Atuin ──
    "atuin/config.toml".source = ./dotfiles/config/atuin/config.toml;
    "atuin/themes" = {
      source = ./dotfiles/config/atuin/themes;
      recursive = true;
    };

    # ── Bat themes ──
    "bat/themes" = {
      source = ./dotfiles/config/bat/themes;
      recursive = true;
    };

    # ── Carapace ──
    "carapace/specs" = {
      source = ./dotfiles/config/carapace/specs;
      recursive = true;
    };
    "carapace/bin" = {
      source = ./dotfiles/config/carapace/bin;
      recursive = true;
    };

    # ── Eza theme ──
    "eza/theme.yml".source = ./dotfiles/config/eza/theme.yml;

    # ── Ghostty ──
    "ghostty/config".source = ./dotfiles/config/ghostty/config;

    # ── WezTerm ──
    "wezterm/wezterm.lua".source = ./dotfiles/config/wezterm/wezterm.lua;

    # ── Yazi ──
    "yazi" = {
      source = ./dotfiles/config/yazi;
      recursive = true;
    };

    # ── OpenCode ──
    "opencode/tui.json".source = ./dotfiles/config/opencode/tui.json;

    # ── Lazygit ──
    "lazygit/config.yml".source = ./dotfiles/config/lazygit/config.yml;

    # ── Bottom ──
    "bottom/bottom.toml".source = ./dotfiles/config/bottom/bottom.toml;

    # ── TextMate themes ──
    "themes" = {
      source = ./dotfiles/config/themes;
      recursive = true;
    };

    # ── Pi (coding agent) ──
    "pi/agent/settings.json".source = ./dotfiles/pi/agent/settings.json;
    "pi/agent/mcp.json".source = ./dotfiles/pi/agent/mcp.json;

    # ── Git hooks ──
    "git/hooks/pre-commit/pre-commit".source = ./dotfiles/config/git/hooks/pre-commit/pre-commit;

    # ── Fish: install catppuccin plugin via fisher ──
    # (handled in programs.fish interactiveShellInit above or via a one-shot script)
  };
}
