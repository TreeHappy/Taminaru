# Opening a shell via podman exec

`podman exec` runs a command directly in a container — it does **not** go through
login or interactive shell startup files. So `~/.bashrc`, `~/.profile` and the
home-manager activation profile are never sourced, and the command runs with the
container's default `PATH` (per `/etc/environment`), which does not include
Nix's paths.

That's why this fails even though pwsh works in an interactive bash:

```bash
podman exec -u taminaru -it mycontainer pwsh
# pwsh: command not found
```

## Just open an interactive shell

The default shell (`bash`) is on the default exec `PATH`, and an interactive
bash *does* source `~/.bashrc` — which activates home-manager and then hands off
to pwsh, landing in `$HOME`:

```bash
podman exec -u taminaru -it mycontainer bash
```

You end up in pwsh directly. Exit it to return to bash, or run any other tool
(`gh`, `pi`, ...) from either shell.

## Making `pwsh` directly runnable

If you want `podman exec ... pwsh` to work without opening bash first, the exec
`PATH` must include Nix's bin paths. Since the bootstrap runs inside the
container it can't change podman's exec environment — the `PATH` has to come
from the container's config:

1. **Container image** (recommended, persistent):

   ```dockerfile
   ENV PATH="/home/taminaru/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
   ```

2. **Per invocation, no rebuild:**

   ```bash
   podman exec -u taminaru \
     -e PATH=/home/taminaru/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
     -it mycontainer pwsh
   ```

3. **Full path, zero config:**

   ```bash
   podman exec -u taminaru -it mycontainer /home/taminaru/.nix-profile/bin/pwsh
   ```
