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

## 3. SSH key and GitHub

```shell
ssh-keygen -t ed25519 -C "your@email"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```

Paste the key into GitHub → Settings → SSH and GPG keys.

## 4. Bootstrap

Clone over **HTTPS** — SSH to GitHub cannot work until the dotfiles are applied,
because the `IdentityAgent` line pointing ssh at 1Password's socket is in this
repo. The path must be `~/.dotfiles`.

```shell
git clone https://github.com/jonnyasmith/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./bootstrap.sh
exec zsh
git remote set-url origin git@github.com:jonnyasmith/dotfiles.git
```

That run adds the 1Password, Docker, VS Code and Chrome apt repos, enables
`contrib` and `non-free` (the Microsoft fonts and `unrar` live there), installs
every `apt:` package, the `[tools]`, the dotfiles and the GNOME dconf, sets zsh
as the login shell, and puts you in the `docker` group.

`./bootstrap.sh --dry-run` first if you want to see it before it runs;
`--status` shows what is out of sync. It is idempotent — re-run it any time.

## 5. 1Password — GUI sign-in and SSH agent

1. Launch **1Password** and sign in. If the browser hand-off does not fire,
   choose **Set up another device** on 1password.com → **Add your account
   directly**.
2. Settings → **Developer** → enable **Use the SSH agent**.
3. Settings → **Browser** → enable **Connect with 1Password in the browser**,
   then install the browser extension and approve the pairing dialog.

`~/.ssh/config` already points `IdentityAgent` at `~/.1password/agent.sock`;
that file comes from this repo.

## 6. GNOME extensions

```shell
sudo apt install -y gnome-shell-extension-appindicator gnome-browser-connector
```

Then browse <https://extensions.gnome.org> and enable what you want. **Log out
and back in** — GNOME Shell on Wayland will not load a newly installed extension
into a running session.

`gnome-tweaks` is installed by `setup:gnome`, and the settings it exposes are
already written from `desktop/gnome.dconf`.

## 7. No ghostty

Debian has no ghostty package and the project ships official binaries for macOS
only, so on this machine the terminal is GNOME Console (`kgx`). The ghostty
config in this repo is still linked, harmlessly, for the machines that have it.
Do not use the project's `curl … | bash` installer — see the note in
`docs/fedora.md` on third-party install scripts.

## 8. Things that need a logout or reboot

| Change | Why |
| --- | --- |
| GNOME extensions | Shell loads them only at session start |
| `docker` group | Group membership is read at login |
| Login shell → zsh | `chsh` is read by PAM at login |
| Kernel upgrade | Reboot |

## 9. tmux plugins

Once, inside tmux: `prefix + I`. `mise bootstrap` clones tpm but cannot press
the key for you.
