{ config, pkgs, lib, ... }:

let
  # ── Theme selection ──────────────────────────────────────────────────
  # Change this line to switch themes. Rebuild with:
  #   home-manager switch --flake .#taminaru
  #
  # Available themes:
  #   "catppuccin-frappe"   — soft pastel palette (default)
  #   "everforest-dark-hard" — green-toned, high contrast
  activeTheme = "catppuccin-frappe";
in
{
  # home.username / home.homeDirectory are injected by flake.nix (single
  # source of truth for the managed user, overridable via TAMINARU_USER).
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  # ── Stylix: unified theming ─────────────────────────────────────────
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${activeTheme}.yaml";
  };

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
    # C compiler for nvim's treesitter parsers. nvim-treesitter compiles
    # parsers via `tree-sitter build` (the `cc` crate). tree-sitter-cli treats
    # zig as clang and passes `--target=<host-triple>` (e.g.
    # x86_64-unknown-linux-gnu), which zig's clang driver rejects, so the
    # shims strip that flag before invoking `zig cc`/`zig c++`.
    zig
    (pkgs.writeShellScriptBin "cc" ''
      args=()
      for a in "$@"; do
        case "$a" in
          --target=*) continue ;;
          *) args+=("$a") ;;
        esac
      done
      exec ${pkgs.zig}/bin/zig cc "''${args[@]}"
    '')
    (pkgs.writeShellScriptBin "c++" ''
      args=()
      for a in "$@"; do
        case "$a" in
          --target=*) continue ;;
          *) args+=("$a") ;;
        esac
      done
      exec ${pkgs.zig}/bin/zig c++ "''${args[@]}"
    '')
    (pkgs.writeShellScriptBin "cxx" ''
      args=()
      for a in "$@"; do
        case "$a" in
          --target=*) continue ;;
          *) args+=("$a") ;;
        esac
      done
      exec ${pkgs.zig}/bin/zig c++ "''${args[@]}"
    '')
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
    '';
    shellAbbrs = {};
    functions = {};
  };

  # ── Bash dotfiles: overwrite Ubuntu-provided files ──────────────────
  # programs.bash writes ~/.bashrc, ~/.profile and ~/.bash_profile through
  # home.file with force = false. On the devcontainer image those files
  # already exist (copied from /etc/skel), so without force = true
  # home-manager aborts with "Existing file ... would be clobbered".
  # The bash module only sets `.source`, so these force flags merge cleanly.
  home.file = {
    ".bashrc".force = true;
    ".profile".force = true;
    ".bash_profile".force = true;
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
        success_symbol = "[ 🎏](bold)";
        error_symbol = "[ 👹](bold)";
      };
      git_branch = {
        symbol = "🌿 ";
      };
      time = {
        format = "$H:$M:$S";
      };
      username = {
        format = "[$user]($style)";
        disabled = false;
      };
      hostname = {
        ssh_only = true;
        format = "[@$hostname](bold)";
      };
      directory = {
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
      };
      docker_context = {
        symbol = " 🐳 ";
        format = "[$symbol$context]($style)";
      };
    };
  };

  # ── Bat ──────────────────────────────────────────────────────────────
  programs.bat = {
    enable = true;
  };

  # ── FZF ──────────────────────────────────────────────────────────────
  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
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
  };
}
