# Arch Linux — manual runbook

Harvested from the deleted `arch-linux` branch (`git show archive/arch-linux:README.md`).

Everything that `mise bootstrap` can do — package installs, git clones, service
enablement, `vm.swappiness`, pacman colour — has been moved into `~/.dotfiles/mise.toml`
and `mise.linux.toml`, and is **not** repeated here. What remains are the steps a human
has to perform: OS installation, GUI sign-ins, firmware/bootloader edits, and anything
gated on a reboot.

Target machine: Dell XPS (Intel iGPU + NVIDIA dGPU), GNOME, LTS kernel.

---

## 1. Install the OS (`archinstall`)

Boot the Arch ISO. The installer needs a network first.

### Connect to wifi

```bash
# open wifi utility
iwctl

# list wifi devices
device list # e.g. wlan0

# scan wifi networks
station <device> scan

# connect to wifi router
station <device> connect <SSID>

# exit wifi utility
exit
```

### `archinstall` answers

Run `archinstall` and set:

- Locale
  - Keyboard layout: UK
  - Locale language: en_GB.UTF-8
  - Locale encoding: UTF-8
- Mirrors and repositories: United Kingdom
- Partitioning:
  - Use a best-effort default partition layout
  - btrfs
  - Compression: on
- Swap: zram enabled
- Bootloader: GRUB
- Hostname: `dell-xps`
- Users:
  - Set root password
  - Create a user with a password and grant sudo
- Audio: PipeWire
- Kernels:
  - Remove `linux`
  - Add `linux-lts`
- Network configuration: use NetworkManager
- Additional packages: `gnome`
- Timezone: Europe/London
- Automatic time sync (NTP): enable

Then reboot into the installed system.

### First boot — start the display manager

`archinstall` does not always leave GDM enabled. This runs before the dotfiles repo
exists, so it cannot be a bootstrap hook:

```bash
sudo systemctl enable gdm.service
sudo systemctl start gdm.service
```

---

## 2. AUR: install `yay` before bootstrapping

**mise's `pacman` package manager only installs from the official Arch repositories. It
cannot install from the AUR.** Several packages this machine needs are AUR-only:

| Package | Why it is AUR-only |
| --- | --- |
| `auto-cpufreq` | never packaged in `extra` |
| `envycontrol` | never packaged in `extra` |
| `1password` | proprietary; upstream ships AUR + a signed repo |
| `visual-studio-code-bin` | proprietary MS build of the OSS `code` package |

`mise.toml` covers these with an `arch-aur` task that shells out to `yay`, but that task
needs `yay` to already exist. Bootstrapping `yay` needs `base-devel` and a `makepkg` run
that prompts for your sudo password, so do this once by hand before the first
`mise bootstrap` — it is a prerequisite of the automation, not a duplicate of it:

```bash
# Install yay if you don't already have it
if ! command -v yay &> /dev/null; then
    cd ~
    sudo pacman -S --noconfirm --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi
```

Once `yay` is on `PATH`, run `mise bootstrap` and the rest of the package set installs
itself.

---

## 3. Sign in to 1Password

Open 1Password, sign in, and link the account. Enable the SSH agent — the dotfiles point
`~/.ssh/config` and git at it, so the terminal will not authenticate to GitHub until this
is done. There is no headless path for this.

---

## 4. Install a Nerd Font

The font installer is an interactive menu (it asks which font to install), so it is not
automated:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/officialrajdeepsingh/nerd-fonts-installer/main/install.sh)"
```

Alternatively pick one from the official repos by hand, e.g.
`sudo pacman -S ttf-jetbrains-mono-nerd`, and skip the installer.

Ghostty and starship both expect a Nerd Font; glyphs render as boxes until one is present.

---

## 5. Verify power management

TLP, `NetworkManager-dispatcher`, the `systemd-rfkill` masks, `auto-cpufreq --install` and
`fstrim.timer` are all enabled by the bootstrap. A **reboot** is recommended after the
first bootstrap so every service starts cleanly.

Confirm the CPU governor is actually being driven — open the stats in one pane and load
the CPU in another:

```bash
auto-cpufreq --stats
```

```bash
stress -c 4
```

`auto-cpufreq` should switch the governor to `performance` under load and back to
`powersave` when `stress` exits.

Check idle draw. An optimised system should idle in the 5–8 W range:

```bash
# An optimised system should idle in the 5-8W range
upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep "energy-rate"
```

If the figure is well above 8 W, the NVIDIA card is probably still powered — see the next
section.

---

## 6. Switch to integrated graphics

Requires a reboot, so it stays manual:

```bash
# Switch to integrated-only graphics mode for maximum battery life
sudo envycontrol -s integrated
```

You must **reboot** for this change to take effect. To switch back to using the NVIDIA
card, run `sudo envycontrol -s hybrid` and reboot.

After the reboot, confirm the NVIDIA card is gone from the PCI listing — if it is not
listed, it is genuinely powered off:

```bash
lspci -k | grep -A 2 -E "(VGA|3D)"
```

> The source runbook wrote this as `spci`; the command is `lspci`.

The `vm.swappiness=10` sysctl written by the bootstrap also needs a reboot (or
`sudo sysctl --system`) — fold it into this one.

---

## 7. High-DPI display setup (GNOME)

Configure a sharp UI: disable fractional scaling, use 200% integer scaling, and adjust
font sizes to compensate. GNOME Tweaks is installed by the bootstrap; the settings
themselves are per-user GUI state.

- Settings → Displays → Scale: **200%**, fractional scaling **off**
- GNOME Tweaks → Fonts → reduce the scaling factor until text size looks right at 200%

Re-check idle draw with the `upower` command in section 5 afterwards — a mis-set scale can
keep the GPU busy.

---

## 8. GNOME extensions

Extension Manager is installed by the bootstrap. Its catalogue is a GUI with no scriptable
install path:

- Open **Extension Manager**
- Install **Space Bar**

---

## 9. Enable boot logging (GRUB)

Kernel and systemd messages are hidden by default. Open the GRUB defaults (or the
equivalent bootloader config if you chose systemd-boot):

```bash
sudo vi /etc/default/grub
```

Find the line starting with:

```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
```

`quiet` suppresses most kernel and systemd messages. `splash`, if present, drives a
graphical splash screen such as Plymouth. Remove `quiet` (and `splash` if you do not want
a splash screen), so it becomes:

```bash
GRUB_CMDLINE_LINUX_DEFAULT=""
```

Then regenerate the GRUB config:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Reboot to see the boot log.

---

## Reboot checklist

Three separate steps here ask for a reboot. Do them together, then reboot once:

1. First `mise bootstrap` completed (TLP / auto-cpufreq services started)
2. `sudo envycontrol -s integrated`
3. `vm.swappiness` sysctl and the GRUB `GRUB_CMDLINE_LINUX_DEFAULT` edit

After rebooting, run the section 5 and section 6 verification commands.
