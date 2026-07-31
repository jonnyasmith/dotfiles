# Raspberry Pi (Raspberry Pi OS / Debian)

Headless ARM box. No GNOME, so the `gnome-settings` mise task guards on
`command -v gsettings` and no-ops here. Packages, oh-my-zsh, its plugins and tpm
come from `mise bootstrap`; everything below needs a human.

Harvested from `archive/main:raspberry-pi/README.md`, `raspberry-pi/install.sh`,
`raspberry-pi/scripts/linux.sh`, `raspberry-pi/scripts/packages.sh`,
`raspberry-pi/scripts/zsh.sh`.

## 1. Image the SD card

1. Raspberry Pi Imager → choose the 64-bit Raspberry Pi OS image.
2. In the Imager's advanced options (gear icon), set the hostname, create the
   `jonny` user, and **enable SSH with public-key authentication** — pasting the
   public key here is the only thing that keeps the first boot headless.
3. Write the card, insert it, power on.

## 2. First boot

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install git -y
```

Reboot if the upgrade replaced the kernel or firmware. `rpi-eeprom-update`
changes and any `raspi-config` change to boot order, overclock or GPU memory
also require a reboot.

## 3. SSH key and GitHub

```shell
# run without elevated privileges
ssh-keygen -t ed25519 -C "jonny.asmith@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard
```

`xclip` needs an X display. Headless over SSH, just `cat` the file and copy from
the terminal. Paste it into GitHub → Settings → SSH and GPG keys.

```shell
git clone git@github.com:jonnyasmith/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./bootstrap.sh
```

Run bootstrap **without** `sudo`. The old `sudo bash ./install.sh` wrote
root-owned files into `/home/jonny` and is the reason several dotfiles ended up
unwritable.

## 4. Docker Engine

Left as prose deliberately: sudo, an added apt repo, a GPG key, and a group
change that only lands after a re-login.

```shell
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

Install the engine:

```shell
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Drop the need for `sudo` on docker commands:

```shell
sudo usermod -aG docker $USER
```

**Log out and log back in** to apply the group change. `newgrp docker` affects
only the current shell; systemd user services and anything already running keep
the old group set until the next login.

## 5. Grant permissions to `/opt`

Containers and hand-installed tooling on this box live under `/opt`. Chown it to
the user once:

```shell
sudo chown -R jonny /opt
```

Not automated: it needs root, it is destructive if `/opt` already holds
packaged software with deliberate ownership, and it hardcodes a username.

## 6. Login shell

```shell
chsh -s "$(command -v zsh)"
```

Prompts for the account password, and PAM only reads the new shell at the next
login. Log out and back in.

## 7. Things that need a logout or reboot

| Change | Why |
| --- | --- |
| `docker` group | Group membership is read at login |
| Login shell → zsh | PAM reads `chsh` at login |
| Kernel / firmware / `raspi-config` | Reboot |

## 8. Dropped from the old runbook

- `raspberry-pi/scripts/links.sh` — the three
  `ln -sf /home/jonny/.dotfiles/raspberry-pi/dotfiles/...` symlinks. Superseded
  by mise `[dotfiles]`, which mirrors `home/` into `$HOME` with no hardcoded
  username and no per-platform dotfile copies.
- `raspberry-pi/scripts/zsh.sh` — the oh-my-zsh `curl | sh` installer and the
  three `git clone` guards. oh-my-zsh and its plugins are git repos;
  `[bootstrap.repos]` converges them idempotently.
- `curl -sS https://starship.rs/install.sh | sh` (run twice in the original,
  once unconditionally) — superseded by mise `[tools] starship`.
- `raspberry-pi/scripts/linux.sh` — nothing left but `apt update && apt upgrade`,
  which is step 2 above, and a commented-out `packer.nvim` clone.
