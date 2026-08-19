# Dotfile clobbering (`.bashrc` and friends)

## The problem

`programs.bash.enable` in `home.nix` makes Home Manager write three dotfiles
in your home directory:

- `~/.bashrc`
- `~/.profile`
- `~/.bash_profile`

They are managed through the `home.file` option, whose default for `force` is
`false`. When Home Manager activates, it checks each managed target against the
file that currently lives there. If the target exists and Home Manager didn't
create it, activation **aborts** with:

```
Existing file '/home/taminaru/.bashrc' would be clobbered by
'/home/taminaru/.bashrc'
```

On the Ubuntu devcontainer this is guaranteed to happen on a fresh build: the
Dockerfile's `useradd -m` copies `/etc/skel` into `/home/taminaru`, which ships
a stock `.bashrc` and `.profile`.

## The fix

Tell Home Manager to overwrite those files unconditionally. In `home.nix`:

```nix
home.file = {
  ".bashrc".force = true;
  ".profile".force = true;
  ".bash_profile".force = true;
};
```

The `programs.bash` module only sets the `source` of these entries, never
`force`, so these flags merge cleanly with no option conflict. With `force =
true` Home Manager overwrites the existing file with no backup and no prompt —
the "clobbered" error goes away.

### Why `.bash_profile` too

Ubuntu's `/etc/skel` doesn't include a `.bash_profile`, so a fresh image only
conflicts on `.bashrc` and `.profile`. But `.bash_profile` is still listed:
if you ever create it manually (or another tool does), forcing avoids a
surprise later.

## Alternatives (and why they're worse)

| Approach | Verdict |
| --- | --- |
| `rm -f ~/.profile ~/.bashrc` in `postCreateCommand` before bootstrap | Works, but is container-setup logic outside the Nix config. Doesn't cover `.bash_profile`. It's still in `.devcontainer/devcontainer.json` as belt-and-suspenders. |
| Delete the files before running `home-manager switch` by hand | One-off; breaks the moment the file reappears. |
| Global `home.file.force = true` | Forces *every* managed dotfile, removing the safety net for files you may edit by hand. Overkill. |

The `force = true` flags express the intent declaratively, inside Home Manager's
own config, and only for the files that need it.

## Applying

```sh
home-manager switch
```

or, on a fresh devcontainer, just rebuild the container — the
`postCreateCommand` runs `scripts/bootstrap.sh`, whose `nix build` + activation
picks up the new `home.nix`.

## Verifying

```sh
ls -l ~/.bashrc ~/.profile ~/.bash_profile
```

Each should be a symlink into `/nix/store/...-home-manager-files/` (or a real
managed file), and `home-manager switch` should complete without the clobber
error.