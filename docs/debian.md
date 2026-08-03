# Debian Desktop

Everything here needs a human: install media, a GUI sign-in, a sudo password, or
a re-login. Packages, repos, git checkouts, dotfile symlinks and GNOME settings
are `mise bootstrap`'s job — do not do them by hand.

## 1. Install Debian

1. Write the Debian ISO to a USB stick and boot it.
2. At the partitioning step enable **full-disk encryption** — it cannot be added
   later without a reinstall.
3. **Leave the root password blank.** That is what makes the installer put your
   user in `sudo`; set one and nothing below can elevate.
4. Create the `jonny` user, finish, reboot.

Already installed with a root password? Fix it once, then log out and back in —
group membership is only read at login:

```shell
su -c '/usr/sbin/usermod -aG sudo jonny'
```

## 2. First boot

```shell
sudo apt update && sudo apt upgrade -y && sudo apt install -y git
```

Reboot if that pulled a new kernel.

## 3. Bootstrap

Clone over **HTTPS** — SSH to GitHub cannot work until the dotfiles are applied,
because the `IdentityAgent` line pointing ssh at 1Password's socket is in this
repo. The path must be `~/.dotfiles`.

```shell
git clone https://github.com/jonnyasmith/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./bootstrap.sh
exec zsh
```

Switching the remote to SSH waits until 1Password is signed in — step 4.

```shell
git remote set-url origin git@github.com:jonnyasmith/dotfiles.git
```

That run adds the 1Password, Docker, VS Code and Chrome apt repos, enables
`contrib` and `non-free` (the Microsoft fonts and `unrar` live there), installs
every `apt:` package, the `[tools]`, the dotfiles and the GNOME dconf, sets zsh
as the login shell, and puts you in the `docker` group.

`./bootstrap.sh --dry-run` first if you want to see it before it runs;
`--status` shows what is out of sync. It is idempotent — re-run it any time.

## 4. 1Password — sign-in, SSH agent, and your keys

1. Launch **1Password** and sign in. If the browser hand-off does not fire,
   choose **Set up another device** on 1password.com → **Add your account
   directly**.
2. Settings → **Developer** → enable **Use the SSH agent**.
3. Settings → **Browser** → enable **Connect with 1Password in the browser**,
   then install the browser extension and approve the pairing dialog.

There is no key to generate. The private keys stay in 1Password; the agent
serves them, `~/.ssh/config` (from this repo) points `IdentityAgent` at
`~/.1password/agent.sock`, and the public-key stubs each `Match` block pins are
committed under `home/.ssh/1password/`. Check all three accounts:

```shell
ssh -T git@github.com        # personal
ssh -T git@github-work       # work alias, rewritten by ~/.config/git/config.local
ssh -T git@ssh.dev.azure.com # azure
```

`Permission denied` with the agent running usually means the key set changed:
`~/.ssh/1password/refresh` rewrites the stubs from whatever the agent now
returns, and the result is a git diff to commit.

## 5. GNOME extensions

```shell
sudo apt install -y gnome-shell-extension-appindicator gnome-browser-connector
```

Then browse <https://extensions.gnome.org> and enable what you want. **Log out
and back in** — GNOME Shell on Wayland will not load a newly installed extension
into a running session.

`gnome-tweaks` is installed by `setup:gnome`, and the settings it exposes are
already written from `desktop/gnome.dconf`.

## 6. Terminal

The terminal is kitty, from Debian's own repositories (`apt:kitty`), same as on
every other platform in this repo. It is deliberately not ghostty: ghostty pins
an exact Zig version and Zig breaks compatibility most releases, so Debian will
not package it and the only Linux builds are distro or community ones. Trixie's
kitty lags upstream by a few minor versions — that is the trade for having the
distro own the updates.

## 7. Things that need a logout or reboot

| Change | Why |
| --- | --- |
| GNOME extensions | Shell loads them only at session start |
| `docker` group | Group membership is read at login |
| Login shell → zsh | `chsh` is read by PAM at login |
| Kernel upgrade | Reboot |

## 8. tmux plugins

Once, inside tmux: `prefix + I`. `mise bootstrap` clones tpm but cannot press
the key for you.
