# Opening a shell via podman exec

`podman exec` runs a command directly in a container — it does **not** go through
login or interactive shell startup files. So `~/.bashrc`, `~/.profile` and the
mise activation wired in by `scripts/bootstrap.sh` are never sourced, and the
command runs with the container's default `PATH` (per `/etc/environment`), which
does not include mise's `~/.local/bin` or shims.

That's why this fails even though pwsh works in an interactive bash:

```bash
podman exec -u taminaru -it mycontainer pwsh
# pwsh: command not found
```

(`bash -lc pwsh` fails for the same reason: non-interactive bash returns early
from `.bashrc` before mise is activated.)

## Just open an interactive shell

The default shell (`bash`) is on the default exec `PATH`, and an interactive
bash *does* source `~/.bashrc` — which activates mise and then hands off to
pwsh, landing in `$HOME`:

```bash
podman exec -u taminaru -it mycontainer bash
```

You end up in pwsh directly. Exit it to return to bash, or run any other tool
(`gh`, `pi`, ...) from either shell.

## Making `pwsh` directly runnable

If you want `podman exec ... pwsh` to work without opening bash first, the exec
`PATH` must include mise's dirs. Since the bootstrap runs inside the container
it can't change podman's exec environment — the `PATH` has to come from the
container's config:

1. **Container image** (recommended, persistent) — mirror what
   `.devcontainer/Dockerfile` already does for vscode:

   ```dockerfile
   ENV PATH="/home/taminaru/.local/bin:/home/taminaru/.local/share/mise/shims:$PATH"
   ```

2. **Per invocation, no rebuild:**

   ```bash
   podman exec -u taminaru \
     -e PATH=/home/taminaru/.local/bin:/home/taminaru/.local/share/mise/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
     -it mycontainer pwsh
   ```

3. **Symlink a shim into a standard PATH dir** (inside the container, as root;
   works for exec but per-tool):

   ```bash
   ln -s /home/taminaru/.local/share/mise/shims/pwsh /usr/local/bin/pwsh
   ```

4. **Full path, zero config:**

   ```bash
   podman exec -u taminaru -it mycontainer /home/taminaru/.local/share/mise/installs/powershell/latest/pwsh
   ```
