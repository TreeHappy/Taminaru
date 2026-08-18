# SSH tunneling into and out of the container

`scripts/bootstrap.sh` configures `sshd` with **passwordless key auth** and
enables TCP forwarding, so you can SSH into the machine/container and tunnel
ports out of it (and back). This doc covers the practical recipes; the
bootstrap's exact sshd setup lives in the "SSH access" section of the README.

## What the bootstrap sets up

- **Port** `2222` by default (`TAMINARU_SSH_PORT` to override, e.g.
  `TAMINARU_SSH_PORT=22 bash scripts/bootstrap.sh`).
- **Key auth only** — `PasswordAuthentication no`. No passwords, ever.
- A fresh **ed25519 client keypair** at `~/.ssh/id_ed25519`; its private key is
  printed at the end of the bootstrap so you can save it anywhere.
- **Forwarding allowed** both ways: `AllowTcpForwarding yes`, `PermitOpen any`.
- `GatewayPorts clientspecified` — reverse-forwards bind to loopback unless you
  explicitly ask for all interfaces with `*`.

## Step 1 — get a key out of the container

The key is generated on first run and reused afterwards. If you can read the
container filesystem, just copy it:

```bash
podman cp <container>:/home/taminaru/.ssh/id_ed25519 ~/.ssh/taminaru
chmod 600 ~/.ssh/taminaru
```

Or scroll back through the bootstrap output and save the printed `PRIVATE KEY`
block. Either way, the **public** key must end up in
`~/.ssh/authorized_keys` *inside* the container (the bootstrap does this
automatically).

## Step 2 — make sshd reachable

In a container, map the port when you start it (Docker is the same with `-p`):

```bash
podman run -it -p 2222:2222 taminaru-clean:latest
```

A VM or bare-metal Ubuntu already listens on `2222` (or `TAMINARU_SSH_PORT`) on
its own address — nothing to map.

## Tunneling IN (host → container)

Connect and land in your pwsh session:

```bash
ssh -i ~/.ssh/taminaru -p 2222 taminaru@localhost
```

`localhost` only works because the port is forwarded; for a remote machine use
its IP/hostname. Confirm with `whoami` (should print `taminaru`) — no password
prompt appears.

## Tunneling OUT (container → elsewhere)

### Local forward (`-L`): reach a container service from the host

Expose the container's service on your own machine:

```bash
ssh -i ~/.ssh/taminaru -p 2222 -L 8080:localhost:80 taminaru@localhost
```

Now `http://localhost:8080` on the host reaches port `80` inside the container.
A single SSH session can carry many `-L`/`-R` flags.

### Reverse forward (`-R`): expose a host service from the container

Make something on your host reachable *from inside* the container:

```bash
ssh -i ~/.ssh/taminaru -p 2222 -R 3000:localhost:3000 taminaru@localhost
```

`localhost:3000` inside the container now points at `localhost:3000` on your
host. By default sshd binds this to loopback *inside the container*. To expose
it on **all** interfaces of the container (e.g. for other containers on the
same bridge), opt in explicitly:

```bash
ssh -i ~/.ssh/taminaru -p 2222 -R *:3000:localhost:3000 taminaru@localhost
```

(`GatewayPorts clientspecified` is what makes the `*:` form work.)

### SOCKS proxy (`-D`): browse through the container

Route any host traffic through the container as a dynamic proxy:

```bash
ssh -i ~/.ssh/taminaru -p 2222 -D 1080 taminaru@localhost
# then point your browser/app at socks5://localhost:1080
```

### Jump host (`-J`): tunnel through the container to somewhere else

Use the container as a bastion to reach hosts on its network:

```bash
ssh -i ~/.ssh/taminaru -J taminaru@localhost:2222 user@10.0.0.5
```

or combine the jump with a forward, all in one session:

```bash
ssh -i ~/.ssh/taminaru -p 2222 -J taminaru@localhost:2222 \
  -L 5432:10.0.0.5:5432 taminaru@localhost
```

## Keeping the session alive

For long-lived tunnels, hold them open with a keepalive and server-side
forwarding enabled:

```bash
ssh -i ~/.ssh/taminaru -p 2222 -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes \
  -N -L 8080:localhost:80 taminaru@localhost
```

## Troubleshooting

| Symptom | Likely cause / fix |
| --- | --- |
| `Connection refused` on 2222 | Port not mapped (`-p 2222:2222`) or `sshd` not running — check `ss -tlnp` inside the container. |
| `Permission denied (publickey)` | Wrong `-i` key, or your pubkey isn't in the container's `~/.ssh/authorized_keys`. |
| Reverse forward binds only on loopback | Add `*:` to the `-R` spec: `-R *:8080:...` (requires `GatewayPorts clientspecified`). |
| Nothing listening on 2222 after bootstrap | A pre-existing sshd already owns the port (e.g. the devcontainer's sshd feature) — use that listener instead. |

## Notes

- The devcontainer ships its own sshd on `2222` (the devcontainer sshd feature);
  its listener wins over the bootstrap's in that image.
- The agent-stack sanitizer strips `~/.ssh` from exported images, so the key
  never leaks into `taminaru-clean` — spawn agent containers and bootstrap them
  separately if they need SSH.