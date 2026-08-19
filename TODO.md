# TODO

## In Repo

- [ ] sshd
- [ ] key handing
- [x] **Explore [stylix](https://github.com/nix-community/stylix)** — Nix-native dynamic theming that could replace manual color hardcoding. Generates consistent themes across all tools (starship, fzf, bat, ghostty, neovim, etc.) from a single base16/catppuccin palette declaration. Evaluate as a replacement for the static Catppuccin Frappe hardcoding in task 15.
- [ ] **Implement custom Stylix themes for unsupported tools** — Tools without Stylix modules (eza, atuin) still have hardcoded Catppuccin Frappe colors. Implement dynamic theming using `config.lib.stylix.colors` or Mustache templates (`config.lib.stylix.colors { template = ./file.mustache; extension = ".ext"; }`). See [Stylix docs on extending](https://nix-community.github.io/stylix/configuration.html#extending). PR [#2400](https://github.com/nix-community/stylix/pull/2400) for eza support is in progress.
- [ ] ngrok or alternative

## On Dev
- [ ] **jetbrains gateway**
- [ ] **vscode remote**

## Problems build

* warning: Using 'builtins.derivation' to create a derivation named 'options.json' that references the store path '/nix/store/7z46yh4hiqq1rw4hrf3hsscx3i9dpnka-source' without a proper context. The resulting derivation will not have a correct store reference, so this is unreliable and may stop working in the future.
