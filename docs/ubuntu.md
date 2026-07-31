# Ubuntu Desktop

Manual steps only. Packages, git checkouts, GNOME `gsettings` and repo setup are
handled by `mise bootstrap` from `~/.dotfiles/mise.toml`. What follows needs a
human: install media, a GUI sign-in, an interactive EULA, a sudo prompt that
adds a system repo, or a re-login.

Harvested from `archive/main:ubuntu/README.md`, `ubuntu/install.sh`,
`ubuntu/install/packages.sh`, `ubuntu/install/linux.sh`.

## 1. Install Ubuntu

1. Write the Ubuntu Desktop ISO to a USB stick.
2. Boot the installer. Enable **full-disk encryption** at the partitioning
   step — it cannot be added later without a reinstall.
3. Create the `jonny` user.
4. Reboot into the installed system.

## 2. First boot

```shell
sudo apt update && sudo apt upgrade -y && sudo apt install git -y
```

Reboot if a new kernel was installed.

## 3. SSH key and GitHub

```shell
ssh-keygen -t ed25519 -C "$(git config user.email)"
eval "$(ssh-agent -s)"
touch ~/.ssh/config
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```

Paste the key into GitHub → Settings → SSH and GPG keys, then:

```shell
git clone git@github.com:jonnyasmith/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./bootstrap.sh
```

## 4. `ubuntu-restricted-extras` blocks on a EULA

`ubuntu-restricted-extras` pulls in `ttf-mscorefonts-installer`, which raises a
full-screen debconf dialog for the Microsoft EULA. A non-interactive
`mise bootstrap` run will hang there.

Accept it once, up front, before bootstrapping:

```shell
sudo apt install -y ubuntu-restricted-extras
```

Or pre-seed the answer so it never prompts:

```shell
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" \
  | sudo debconf-set-selections
```

## 5. Snap packages replaced by apt

The old runbook installed `code`, `nvim` and `1password` from Snap. mise's
`[bootstrap.packages]` has no snap manager, and for these three Snap is the
worse choice anyway, so all three moved to `apt:`:

| Snap | Replacement | Reason |
| --- | --- | --- |
| `code` (classic) | `apt:code` from `packages.microsoft.com/repos/code` | The official Debian repo; auto-updates through apt. Same `code` binary. |
| `nvim` (classic) | `apt:neovim` | Real Ubuntu package; also matches the `neovim` + `python3-neovim` pair already used on Fedora. |
| `1password` | `apt:1password` from `downloads.1password.com/linux/debian` | The Snap build **cannot** use the SSH agent or system authentication. The deb can. |

Both repos are added by a guarded `[bootstrap.hooks.pre-packages]`, so this is
automated — it is documented here only because it is a behaviour change from the
old runbook.

If Ubuntu's `apt:neovim` is too old for the config, drop it and let mise own the
binary with `[tools] neovim = "latest"` instead.

## 6. 1Password — GUI sign-in and SSH agent

1. Launch **1Password** and sign in. If the browser hand-off does not fire,
   choose **Set up another device** on 1password.com → **Add your account
   directly**.
2. Settings → **Developer** → enable **Use the SSH agent**.
3. Settings → **Browser** → enable **Connect with 1Password in the browser**,
   then install the browser extension and approve the pairing dialog.
4. Add to `~/.ssh/config`:

   ```
   Host *
     IdentityAgent ~/.1password/agent.sock
   ```

## 7. GNOME extensions

```shell
sudo apt install -y gnome-shell-extension-appindicator chrome-gnome-shell
```

Then browse https://extensions.gnome.org and enable what you want. **Log out and
back in** — GNOME Shell on Wayland will not load a newly installed extension
into a running session.

`gnome-tweaks` is installed by `apt:gnome-tweaks`; the settings it exposes are
already written by the `gnome-settings` mise task.

## 8. Docker Engine

Left as prose deliberately: it needs sudo, adds an apt repo and a GPG key, and
the group change only takes effect after a re-login. None of that belongs in
`[bootstrap.packages]`.

```shell
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

```shell
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

To drop the `sudo` prefix on docker commands:

```shell
sudo usermod -aG docker $USER
```

**Log out and log back in** to pick up the new group. `newgrp docker` works for
the current shell only.

This is the sequence from `archive/main:raspberry-pi/README.md` with the Debian
paths swapped for `ubuntu` — the rest is byte-identical.

## 9. Zig and other runtimes

`sudo snap install zig --beta --classic` is gone. mise owns zig
(`[tools] zig`), node (`[tools] node`), .NET (`[tools] dotnet`), python and
starship.

## 10. Things that need a logout or reboot

| Change | Why |
| --- | --- |
| GNOME extensions | Shell loads them only at session start |
| `docker` group | Group membership is read at login |
| Login shell → zsh | `chsh` is read by PAM at login |
| Kernel upgrade | Reboot |

## 11. Dropped from the old runbook

- `ubuntu/install/links.sh` — the `ln -sf /home/jonny/.dotfiles/...` symlink
  script. Superseded by mise `[dotfiles]`. Note it was also broken: it linked
  `~/.dotfiles/linux/git/gitconfig.symlink`, and no `linux/` directory ever
  existed on this branch.
- `dotnet-install.sh` and its `--channel 8.0 / 7.0 / 6.0` invocations —
  superseded by mise `[tools] dotnet`, which installs SDKs side-by-side into one
  `DOTNET_ROOT`.
- `nvm` (`creationix/nvm` and `nvm-sh/nvm` v0.39.7) — superseded by mise
  `[tools] node`.
- `curl -sS https://starship.rs/install.sh | sh` — superseded by mise
  `[tools] starship`.
- The `nerd-fonts-installer` `curl | bash` — see the Fedora runbook; take the
  fonts from a release archive and run `fc-cache -fv`.
- `packer.nvim` clone into a hardcoded `/home/jonny/...` path — packer.nvim is
  unmaintained.
- `ubuntu/install/linux.sh` in its entirety — it guarded on `which dnf` and then
  ran `dnf update`, on Ubuntu. It could never have executed.
