# WSL (Debian and Ubuntu)

Harvested from the deleted `wsl` branch, tag `archive/debian` (`debian.md`,
`ubuntu.md`, `README.md`, `.zshrc`).

The Debian and Ubuntu runbooks were byte-identical apart from three lines: the
document title and the two Docker apt URLs (`download.docker.com/linux/debian`
vs `.../linux/ubuntu`). They are one document now, and that substitution no
longer appears here at all — the pre-packages hook derives it from `$ID` in
`/etc/os-release`.

Everything in this file needs a human: a reboot, a GUI sign-in, a sudo password,
a Windows-side action, or a group membership that only takes effect after
re-login. Package installs, git clones and dotfile symlinks are **not** here —
`mise bootstrap` owns those, and as of the Docker work it owns installing and
enabling Docker too. See `mise.toml`.

---

## 1. Install WSL (Windows side)

From an elevated PowerShell:

```powershell
wsl --install --distribution Debian
```

For Ubuntu, `wsl --install --distribution Ubuntu`. `wsl --list --online` shows
the available distribution names.

This enables the Virtual Machine Platform and WSL features and **requires a
reboot** on a machine that has never had WSL enabled. Reference:
<https://learn.microsoft.com/en-us/windows/wsl/install>.

## 2. First run: create the UNIX user

The first launch of the distribution prompts for a UNIX username and password
interactively. There is no unattended path that also produces a sudo-capable
user, so do it by hand. The username does not have to match the Windows
account; nothing in this repo hardcodes it any more (the old `.zshrc` had
`/home/jonny` baked into `PATH` and `PNPM_HOME` — that is gone).

Then, once only:

```bash
sudo apt update && sudo apt install -y git nala
sudo nala upgrade -y
```

`nala` is also declared in `[bootstrap.packages]`, but it has to exist before
the first bootstrap can use it, hence the manual `apt install`.

## 3. Bootstrap

```bash
git clone git@github.com:jonnyasmith/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

The clone needs a working SSH agent — see section 6. Clone over HTTPS first and
switch the remote later if you are setting up the agent after the fact.

## 4. Docker

`mise bootstrap` installs and configures Docker. The repository and GPG key
are added by `[bootstrap.hooks.pre-packages]` in `mise.linux.toml`, the Docker
CE packages are declared in `[bootstrap.packages]`, and `setup:docker` adds you
to the `docker` group and enables the service where systemd is running. Nothing
below needs doing by hand except the two things convergence deliberately will
not do.

The Debian/Ubuntu split the old runbook carried is gone: the distribution
segment of the `download.docker.com` URLs was the only difference, and the hook
now takes it from `$ID` in `/etc/os-release`.

### /etc/wsl.conf

WSL has no systemd unless you turn it on, so `setup:docker` cannot enable the
service there. `setup:wsl` **reports** the missing stanza rather than writing
it — `mise bootstrap` should not need sudo to edit a file outside `$HOME`, and
the archived runbook's `tee` truncated the whole file, destroying any existing
`[automount]`, `[network]` or `[user]` stanzas. Add it yourself:

```ini
[boot]
command="service docker start"
```

That is the SysV route and it works on any WSL build. On builds that support
systemd you can instead set `systemd=true`, which lets `setup:docker` enable
`docker.service` on the next bootstrap. Pick one: with `systemd=true`,
`command=` still runs but `service docker start` is redundant. Either way the
change only takes effect after `wsl --terminate <distro>`.

### The group membership needs a re-login

`setup:docker` prints this too. `usermod -aG docker` does not affect the shell
that ran it, and in WSL a plain `exec zsh` is not enough either — the login
session keeps the old supplementary groups. Terminate the distribution from
Windows and start it again:

```powershell
wsl --terminate Debian
```

Then verify without sudo:

```bash
docker run --rm hello-world
```

## 5. Portainer

Optional. Verbatim from the archived runbook:

```bash
# Create a directory for Portainer
sudo mkdir /opt/portainer

# Create a Docker Compose file for Portainer
sudo tee /opt/portainer/docker-compose.yml > /dev/null <<EOF
services:
  portainer:
    image: portainer/portainer-ce
    container_name: portainer
    restart: always
    ports:
      - "9000:9000"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
      - "/opt/portainer/data:/data"
EOF

# Navigate to the Portainer directory
cd /opt/portainer

# Use Docker Compose to start Portainer in detached mode
sudo docker compose up -d

# Return to the previous directory
cd
```

Portainer's first-run admin account is created in the browser at
<http://localhost:9000> and times out if you wait too long after the container
starts; if you miss the window, `docker restart portainer`.

## 6. Reaching the Windows 1Password SSH agent from WSL

The 1Password app runs on the Windows side. Its SSH agent listens on the
Windows named pipe `\\.\pipe\openssh-ssh-agent`, which a Linux process inside
WSL cannot open directly. Enable it first: 1Password → Settings → Developer →
**Use the SSH agent**.

There are two ways across the boundary.

### Option A — `core.sshCommand ssh.exe` (what the old branch did)

```bash
git config --global core.sshCommand ssh.exe
```

Git shells out to the Windows OpenSSH client, which talks to the named pipe
natively. One line, no dependencies.

Limitations, all of them real:

- Only git benefits. `ssh`, `scp`, `rsync -e ssh` and anything else inside WSL
  still have no agent.
- `ssh.exe` is a Windows binary, so every path it is handed is interpreted as a
  Windows path. `~/.ssh/config`, `IdentityFile`, `UserKnownHostsFile` and
  `-o` overrides written for the Linux side do not resolve.
- A Win32 process launch per git operation is noticeably slower than a native
  one.

### Option B — relay the pipe to a UNIX socket (recommended)

Bridge the named pipe to a real UNIX socket with
[npiperelay](https://github.com/jstarks/npiperelay) plus `socat`, and point
`SSH_AUTH_SOCK` at it. Every SSH client in the distribution then works, and the
shell config ends up the same shape as macOS — which already does
`export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock`
— differing only in the path.

Windows side, once (PowerShell, with [scoop](https://scoop.sh)):

```powershell
scoop install npiperelay
```

Note the resulting path; the examples below assume
`/mnt/c/Users/<you>/scoop/shims/npiperelay.exe`.

WSL side:

```bash
sudo nala install -y socat
mkdir -p ~/.1password
```

Then start the relay. If the distribution runs systemd (`[boot] systemd=true`),
a user unit is the tidy option — `~/.config/systemd/user/1password-agent.service`:

```ini
[Unit]
Description=1Password SSH agent relay to the Windows named pipe

[Service]
ExecStart=/usr/bin/socat UNIX-LISTEN:%h/.1password/agent.sock,fork EXEC:"/mnt/c/Users/<you>/scoop/shims/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork
Restart=on-failure

[Install]
WantedBy=default.target
```

```bash
systemctl --user daemon-reload
systemctl --user enable --now 1password-agent
```

Without systemd, start it lazily from the shell instead — this is the snippet
the WSL branch of `.zshrc` should carry:

```bash
export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
if ! pgrep -u "$USER" -f 'npiperelay.exe .*openssh-ssh-agent' >/dev/null 2>&1; then
  rm -f "$SSH_AUTH_SOCK"
  setsid socat "UNIX-LISTEN:$SSH_AUTH_SOCK,fork" \
    EXEC:'/mnt/c/Users/<you>/scoop/shims/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent',nofork \
    >/dev/null 2>&1 &
fi
```

Verify with `ssh-add -l`; the first use raises a Windows Hello prompt that must
be authorised in the GUI.

**Recommendation: Option B.** Option A is a git-only patch that breaks as soon
as anything else in WSL needs a key, and its path semantics are a standing
trap. Option B costs one Windows install and one relay, and afterwards WSL
behaves like every other machine in this repo — one `SSH_AUTH_SOCK` export,
same as macOS.

If you keep Option A anyway, `core.sshCommand` is a `git config --global`
write, i.e. it lands in `~/.gitconfig`, which is a stowed dotfile. Do not run
the command; put the value in the WSL-conditional include instead, or it will
be written into the repo copy and follow you to macOS.

## 7. Environment differences from macOS

- `PNPM_HOME` is `$HOME/.local/share/pnpm` on Linux, not macOS's
  `$HOME/Library/pnpm`. This is pnpm's own global-bin directory (`pnpm add -g`
  shims: `wt`, `pn`, `pnpx`), unrelated to the pnpm binary, which mise owns.
- `SSH_AUTH_SOCK` is `$HOME/.1password/agent.sock` (section 6), not the macOS
  group-container path.
- Both come from `[env]` in `mise.linux.toml`, not from a shell file, so a
  shell that never runs `mise activate` does not see them — same as before,
  when they were exported from `~/.config/zsh/os.zsh`, which only `.zshrc`
  sourced.
- The archived `.zshrc` also set `export TERM='xterm-256color'` and put
  `/opt/nvim/bin`, `/opt/zig` and `/home/jonny/.local/bin` on `PATH`. The two
  `/opt` entries are dead — mise installs neovim and zig now — and the third
  was a hardcoded home directory; use `$HOME/.local/bin`.

## 8. Dropped from the archived runbook

Recorded here so nobody re-adds them:

| Dropped | Why |
| --- | --- |
| `curl \| bash` nvm installer, `NVM_DIR` sourcing | mise `[tools]` owns node |
| `curl -sS https://starship.rs/install.sh \| sh` | package/tool manager owns starship |
| Neovim tarball into `/opt/nvim` | superseded by a managed install |
| Zig 0.12.0 tarball into `/opt/zig` | pinned to a dead version; superseded |
| `stow .`, and the `.zshrc.orig` / `.gitconfig.orig` renames | mise `[dotfiles]` links dotfiles and handles pre-existing files |
| `git checkout wsl` | one branch now |
| `mkdir ~/.config` | created implicitly |
| `/home/jonny` in `PATH` and `PNPM_HOME` | hardcoded home directory |
