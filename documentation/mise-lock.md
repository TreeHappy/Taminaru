# mise lockfile

[mise](https://mise.jdx.dev) manages tool installation. `mise.toml` declares
*what* to install (usually `"latest"`), and `mise.lock` records *exactly what
was resolved and installed* so every machine gets bit-identical binaries.

## Why a lockfile

`mise.toml` pins most tools to `latest`, so a fresh install would resolve
whatever the newest release is at that moment. The lockfile freezes those
resolutions: the exact version, the download URL, and the SHA-256 checksum for
every supported platform. As long as the lockfile is committed, a fresh
bootstrap installs the same bits everywhere.

## How it works

- `mise.toml` has `experimental = true` and `lockfile = true` (see
  `[settings]`).
- `mise install` (run by `scripts/bootstrap.sh`) reads the lock. If a tool in
  `mise.toml` isn't in the lock yet, mise resolves it to the current `latest`
  and **writes the new resolution into `mise.lock` automatically**.
- Tools pinned to a concrete version in `mise.toml` (e.g. `neovim = "0.12.4"`)
  are locked to that version.
- The lock is per-platform: each tool has a `[tools.<name>."platforms.<os>-<arch>"]`
  entry with `checksum`, `url`, and `url_api` (and `provenance` for
  attestation-backed releases). On any machine, mise picks the entry matching
  the host platform.

## When the lock changes

- A tool set to `latest` in `mise.toml` gets a new release → the next
  `mise install` re-resolves it and bumps that tool's entry in `mise.lock`.
- A tool is added to or removed from `mise.toml` → entries are added/removed.
- Example: `yazi = "latest"` previously resolved to `26.5.6`; after `26.8.15`
  shipped, `mise install` bumped the lock from `26.5.6` to `26.8.15`.

## Updating the lock

Run from the repo root:

```bash
mise install
```

This installs anything missing and rewrites `mise.lock` with any new
resolutions. Then commit the updated lock:

```bash
git add mise.lock && git commit -m "chore(mise): update lockfile"
```

Note: a bare `mise lock` may report `No tools configured to lock` because the
lock is managed incrementally by `mise install` under the `experimental`
setting. The `mise lock` command's job is to (re)generate the full lock from
`mise.toml`; `mise install` is what applies and updates it in this repo.

## Verifying

```bash
mise ls                     # installed versions
mise ls --outdated          # tools with newer releases available
grep '^\[\[tools\.' mise.lock   # every locked tool
```

The number of `[[tools.<name>]]` sections in `mise.lock` should match the
number of tools in `[tools]` in `mise.toml`.

## Notes

- `mise.lock` is auto-generated (see its `@generated` header). Don't edit it by
  hand; edit `mise.toml` and re-run `mise install`.
- Backends are recorded per tool (e.g. `aqua:` for most, `github:` for
  `mammouth` via `[tool_alias]`). See `mise.toml` for the aliases.
- Keep the lock committed; bootstrap depends on it for reproducible installs.