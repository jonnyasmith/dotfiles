# Fedora Workstation

Manual steps only. Everything that `mise bootstrap` can converge on its own —
packages, git checkouts, GNOME gsettings, dnf tuning, third-party repos — lives
in `~/.dotfiles/mise.toml`. This file is the list of things that need a human:
physical media, a GUI sign-in, a password prompt outside the terminal, or a
reboot.

Harvested from `archive/main:fedora/README.md`, `fedora/install.sh`,
`fedora/install/linux.sh`, `fedora/install/packages.sh`.

## 1. Install Fedora Workstation

1. Write the Fedora Workstation ISO to a USB stick (Fedora Media Writer, or
   `dd`).
2. Boot the installer. Enable **full-disk encryption** at the partitioning
   step — it cannot be turned on later without a reinstall.
3. Create the `jonny` user and make it an administrator.
4. Reboot into the installed system.

## 2. First boot

```shell
sudo dnf upgrade --refresh -y
```

Reboot if the upgrade pulled a new kernel or `systemd`. Nothing below should be
attempted on a half-upgraded system.

Install git so the repo can be cloned:

```shell
sudo dnf install -y git
```

## 3. SSH key and GitHub

`ssh-keygen` is scriptable; uploading the public key is not.

```shell
ssh-keygen -t ed25519 -C "$(git config user.email)"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```

Paste the key into GitHub → Settings → SSH and GPG keys. Then:

```shell
git clone git@github.com:jonnyasmith/dotfiles.git ~/.dotfiles
```

## 4. Bootstrap

```shell
cd ~/.dotfiles
./bootstrap.sh
```

That installs mise and runs `mise bootstrap`, which handles:

- dnf tuning (`max_parallel_downloads`, `fastestmirror`)
- the RPM Fusion, 1Password and VS Code repos
- every `dnf:` package
- oh-my-zsh and its plugins, tpm
- the 18 GNOME `gsettings` writes plus the two workspace-keybinding loops
- `[tools]` — terraform, zig, starship, dotnet, node, python

## 5. 1Password — GUI sign-in and SSH agent

The package installs unattended; the account does not. After bootstrap:

1. Launch **1Password** and sign in. If the browser hand-off does not fire,
   choose **Set up another device** on 1password.com → **Add your account
   directly**, or **Enter account details manually** in the app.
2. Settings → **Developer** → enable **Use the SSH agent**. Accept the prompt to
   write `~/.config/1Password/ssh/agent.toml`.
3. Settings → **Browser** → enable **Connect with 1Password in the browser**,
   then install the 1Password browser extension and approve the pairing dialog.
4. Point SSH at the agent (`~/.ssh/config`):

   ```
   Host *
     IdentityAgent ~/.1password/agent.sock
   ```

   Once this works, the `~/.ssh/id_ed25519` from step 3 can be retired in favour
   of a key stored in 1Password.

Note: the Snap and Flatpak builds of 1Password **cannot** run the SSH agent or
system authentication. The dnf package from `downloads.1password.com` is the
only build that does — that is why `mise.toml` installs it via `dnf:` behind a
repo hook.

## 6. Desktop settings

This laptop has **both** GNOME and COSMIC installed and switches between them
at the login screen, so bootstrap configures both — see *Distribution and
desktop are two axes* in the README. Nothing is keyed on which session happens
to be running.

| Task | Runs when | Payload |
| --- | --- | --- |
| `setup:gtk` | `dconf` on PATH | `desktop/gtk.dconf` — dark theme, font hinting/antialiasing, animations off, GTK3+GTK4 file-chooser |
| `setup:gnome` | `gnome-shell` installed | `desktop/gnome.dconf` — touchpad, `caps:swapescape`, workspace keybindings, idle/night-light, titlebar buttons, plus `gnome-tweaks` |
| `setup:cosmic` | `cosmic-comp` installed | `desktop/cosmic/` copied into `~/.config/cosmic/` — keyboard, shortcuts, panel/dock, idle, dark mode |

The two desktops share nothing: GNOME's state is dconf, COSMIC's is RON files
under `~/.config/cosmic/<component>/v1/`. `caps:swapescape` is
`/org/gnome/desktop/input-sources/xkb-options` on one and
`com.system76.CosmicComp/v1/xkb_config` on the other, so it is declared twice —
once per payload. Neither is read by the other desktop.

To pick up a change made in COSMIC **Settings**, copy the file back into
`desktop/cosmic/` and commit it; `setup:cosmic` copies rather than symlinks
because `cosmic-config` rewrites these files itself at runtime.

```shell
mise run check:dconf   # after editing desktop/*.dconf
```

### GNOME extensions

GNOME sessions only. Extensions are not automated — they come from
extensions.gnome.org through a browser connector.

```shell
sudo dnf install -y gnome-shell-extension-appindicator gnome-browser-connector
```

Then, in a browser, visit https://extensions.gnome.org and enable:

- **AppIndicator and KStatusNotifierItem Support** — required or the 1Password
  tray icon never appears.
- Anything else per taste.

**Log out and back in** after installing extensions. GNOME Shell will not load a
newly installed extension into a running session on Wayland.

On COSMIC there is no extension mechanism and none of this applies; the panel's
own applets cover the tray.

## 7. Things that need a logout or reboot

| Change | Why |
| --- | --- |
| GNOME extensions | Shell only loads them at session start (Wayland) |
| `caps:swapescape` | Set by `gsettings` on GNOME, by `com.system76.CosmicComp/v1/xkb_config` on COSMIC; either way a running app may hold the old map |
| Login shell → zsh | `[bootstrap.user].login_shell` calls `chsh`; PAM only reads it at login |
| Kernel / `systemd` upgrade | Reboot |

`chsh` prompts for the account password. If `mise bootstrap` cannot get it,
run it by hand and log out:

```shell
chsh -s "$(command -v zsh)"
```

## 8. Nerd fonts

The old runbook piped a third-party installer into bash
(`nerd-fonts-installer/main/install.sh`). Do not. Either take the fonts from the
repo, or download the release archive directly:

```shell
mkdir -p ~/.local/share/fonts
# unzip FiraCode.zip into ~/.local/share/fonts, then:
fc-cache -fv
```

Set the terminal font to **FiraCode Nerd Font Mono** afterwards — a GUI step in
GNOME Terminal / Ptyxis preferences.

## 9. Dropped from the old runbook

- `fedora/install/links.sh` — the whole `ln -sf /home/jonny/.dotfiles/...`
  symlink script. Superseded by mise `[dotfiles]`, which mirrors `home/` into
  `$HOME` without hardcoding a username.
- `nvm` (`creationix/nvm`, `nvm-sh/nvm` v0.39.7) — superseded by mise
  `[tools] node`.
- `dotnet-sdk-6.0` / `7.0` / `8.0` dnf packages — superseded by mise
  `[tools] dotnet`.
- `packer.nvim` clone into
  `/home/jonny/.local/share/nvim/site/pack/packer/start` — packer.nvim is
  unmaintained and the path was hardcoded to one user.
- `curl -sS https://starship.rs/install.sh | sh` — superseded by mise
  `[tools] starship`.
- `sudo dnf install zig` — superseded by mise `[tools] zig`.
- The HashiCorp rpm repo (`rpm.releases.hashicorp.com/fedora/hashicorp.repo`)
  and `dnf install terraform` — superseded by mise `[tools] terraform`
  (aqua backend), so no root-owned repo file is needed at all.
- The oh-my-zsh `curl | sh` installer — it is a git clone; `[bootstrap.repos]`
  does it idempotently.
