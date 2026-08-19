# Nix sandbox inside containers

## Symptom

Bootstrapping Taminaru in a fresh container (e.g. `docker run ubuntu:devel`,
without `--privileged`) fails at the home-manager build step with:

```
error: while setting up the build environment
error: cannot set host name: Operation not permitted
```

## Cause

`nix build` isolates every derivation inside a Linux namespace sandbox. As part
of that it creates new namespaces and calls `sethostname("nixbld")` to give the
sandbox its own hostname (see `local-derivation-goal.cc` in the Nix source).

Unprivileged containers block this:

- Docker's default seccomp profile blocks the `sethostname` syscall outright.
- Without `CAP_SYS_ADMIN` (dropped unless you pass `--cap-add SYS_ADMIN` or
  `--privileged`) the namespaces themselves can't be created.
- Rootless Podman runs the container in a user namespace with no `CAP_SYS_ADMIN`
  at all, so every sandboxed build fails the same way.

Either way the sandbox setup fails with `Operation not permitted`. This is a
well-known Nix issue (NixOS/nix#11810) and is not specific to Taminaru.

## Fix

`scripts/bootstrap.sh` detects this at bootstrap time and builds unsandboxed:

- When installing Nix it passes `--extra-conf "sandbox = false"` to the
  Determinate installer (the officially recommended approach for Podman), which
  writes it into `/etc/nix/nix.custom.conf` — a file the installer's `nix.conf`
  includes at the bottom, so it wins over the installer's `sandbox = true`.
- It also rewrites `sandbox = false` into `/etc/nix/nix.custom.conf` on every
  run, and passes `--option sandbox false` to the home-manager build itself.

So all builds — including later `scripts/sync.sh` runs and the `nix-daemon` —
run unsandboxed.

Detection is automatic when:

- `/.dockerenv` or `/run/.containerenv` exists (docker / podman), or
- `CAP_SYS_ADMIN` is absent from `CapEff` in `/proc/self/status`.

## Alternatives

If you'd rather keep the sandbox, run the container privileged:

```bash
docker run --privileged -it ubuntu:devel
```

Or force sandboxing back on regardless of detection:

```bash
TAMINARU_SANDBOX=1 bash scripts/bootstrap.sh
```
