# Passwordless sudo

`scripts/bootstrap/bootstrap.sh` needs root only for a few system-wide steps (apt
packages, `/etc/shells`, `chsh`). Everything else runs as the regular
`TAMINARU_USER` (default: `taminaru`). Because the bootstrap is non-interactive
(a `curl | bash` one-liner, or re-run via `runuser`), it can never answer a
sudo password prompt — so that user must have passwordless (NOPASSWD) sudo.

## What the bootstrap sets up

When run **as root**, the bootstrap provisions the user via
[`scripts/bootstrap/provision-user.sh`](../scripts/bootstrap/provision-user.sh) — the same script
the devcontainer Dockerfile uses at image build. It is idempotent and:

1. Creates the non-root user if it doesn't exist
   (`useradd -m -s /bin/bash -u $TAMINARU_UID`, default uid 1000), or reuses it
   if it already does. If it exists with a different uid, it warns and keeps
   the existing uid.
2. Always (re)writes the sudoers drop-in as a managed file:

   ```bash
   printf '%s ALL=(ALL) NOPASSWD:ALL\n' "$TAMINARU_USER" > /etc/sudoers.d/$TAMINARU_USER
   chmod 440 /etc/sudoers.d/$TAMINARU_USER
   visudo -cf /etc/sudoers.d/$TAMINARU_USER
   ```

   The file is overwritten on every run (never "only if missing"), so a stale
   or malformed drop-in can't silently break passwordless sudo.
3. Ensures `/etc/sudoers` includes the `@includedir /etc/sudoers.d` directive.
   If it's missing (some base images/containers ship without it), it's appended
   via a validated temp copy + atomic `install`, so an invalid sudoers can never
   brick sudo.
4. **Verifies before proceeding** — it actually checks the grant works as the
   target user before re-running the rest of the bootstrap as them:

   ```bash
   runuser -u "$TAMINARU_USER" -- sudo -n true
   ```

   If that fails, the bootstrap stops with a diagnosis instead of failing later
   with a confusing "needs passwordless sudo" error.

## When run as a non-root user

The bootstrap is strict about it: it probes `sudo -n true` up front and aborts
immediately with the exact fix if the current user can't use sudo
non-interactively:

```bash
echo 'taminaru ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/taminaru
chmod 440 /etc/sudoers.d/taminaru
```

## Why the drop-in file is required

- `/etc/sudoers.d` is read via the `@includedir` directive (`#includedir` is
  also accepted for compatibility). Files whose names contain `.` or end in `~`
  are skipped.
- Permissions matter: the file must be owned by root and not group/world
  writable (`chmod 440`). sudo ignores otherwise.
- `visudo -c` validates the file before it takes effect.

## sudo-rs note (Ubuntu 26.04)

Ubuntu 26.04 ships `sudo-rs` (the Rust rewrite) as `/usr/bin/sudo`. Its denial
message when a user has no rights is the HAL 9000 quote
`I'm sorry taminaru. I'm afraid I can't do that` — it means the user simply
isn't allowed to run sudo, not that sudo is broken.

sudo-rs 0.2.13 has a bug where a single `/etc/group` line longer than ~519
bytes breaks group resolution and can deny sudo for users even with a valid
grant. If the bootstrap's verification step fails despite a correct drop-in,
upgrade sudo-rs to 0.2.14+ (`sudo apt-get upgrade sudo-rs`).

## Troubleshooting

Verify a grant took effect:

```bash
sudo -n true && echo "passwordless sudo works"
sudo -l          # list what the user may run
grep includedir /etc/sudoers
ls -la /etc/sudoers.d/
```
