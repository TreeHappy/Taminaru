# TODO

## In Repo

- [ ] strip unnecessary ubuntu package
  - [ ] build-essential specifically
- [ ] sshd
- [ ] key handing
- [ ] **Explore [stylix](https://github.com/nix-community/stylix)** — Nix-native dynamic theming that could replace manual color hardcoding. Generates consistent themes across all tools (starship, fzf, bat, ghostty, neovim, etc.) from a single base16/catppuccin palette declaration. Evaluate as a replacement for the static Catppuccin Frappe hardcoding in task 15.
- [ ] ngrok or alternative

## On Dev
- [ ] **jetbrains gateway**
- [ ] **vscode remote**

## Problems build

* warning: Using 'builtins.derivation' to create a derivation named 'options.json' that references the store path '/nix/store/7z46yh4hiqq1rw4hrf3hsscx3i9dpnka-source' without a proper context. The resulting derivation will not have a correct store reference, so this is unreliable and may stop working in the future.

## .bashrc problem

You have two reasonable ways to tell Home Manager “I don’t care about the existing file, just replace it”.

### 1. Per‑file *force* flag (the most explicit)

Home Manager lets you manage a dotfile with the `home.file` attribute set. If you add the **`force`** option, Home Manager will overwrite the file unconditionally (no backup, no prompt).

```nix
# home.nix
{ config, pkgs, ... }:

{
  home.username   = "taminaru";
  home.homeDirectory = "/home/taminaru";

  # Example for .profile
  home.file.".profile".source = ./dotfiles/profile;   # path to the file you want installed
  home.file.".profile".force  = true;                # <-- overwrite without backup

  # Same for .bashrc (repeat for any other file you manage)
  home.file.".bashrc".source = ./dotfiles/bashrc;
  home.file.".bashrc".force  = true;
}
```

When you run `home-manager switch` (or `home-manager switch -b backup`), Home Manager will simply copy the new file over the old one, deleting the previous contents. No “clobber” error, no backup files.

*Tip*: If you have many files you want to force‑replace, you can write a small helper function in your `home.nix` to avoid repetition:

```nix
let
  forceFile = name: src: {
    home.file = { "${name}" = {
      source = src;
      force  = true;
    }; };
  };
in
{
  # …
  home.file = {
    ".profile".source = ./dotfiles/profile;
    ".profile".force  = true;
    ".bashrc".source = ./dotfiles/bashrc;
    ".bashrc".force  = true;
  };
}
```

### 2. Global “always force” via `home.file.*.force = true` (less common)

If you want **every** file that Home Manager manages to be forced, you can set the option globally:

```nix
{
  # …
  home.file = {
    # default attributes for all managed files
    enable = true;          # (implicit)
    force  = true;          # applies to every file under home.file.*
  };
}
```

However, this is usually overkill because you often want the safety net for some files (e.g. configuration files you may edit by hand). The per‑file `force` flag gives you selective control.

### 3. Why not just delete the files before Home Manager runs?

You *could* delete the files in `postCreateCommand` (e.g. `rm -f ~/.profile ~/.bashrc && home-manager switch`), but that mixes container‑setup logic with Home Manager’s declarative configuration. The preferred Nix‑ish way is to let Home Manager express the intent **inside** its own config – that’s what the `force` option is for.

### Which approach fits a Ubuntu‑based devcontainer?

- **If you only have a handful of dotfiles** (typical case): add `force = true` to each `home.file` entry as shown in the first example.
- **If you want to replace *all* Ubuntu‑provided defaults** (e.g. you ship your own complete set of dotfiles): add the global `home.file.force = true` line.

Either way, you avoid the “Existing file … would be clobbered” error without creating backup files. After updating `home.nix`, rebuild the container or simply run:

```sh
home-manager switch
```

and the new files will be written over the old ones.
