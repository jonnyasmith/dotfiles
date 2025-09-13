# Arch Linux Installation

- locale
  - keyboard layout: UK
  - Locale language: en_GB.UTF-8
  - Locale Encoding: UTF-8
- Mirrors and Repositories: United Kingdom
- Partitioning:
  - Use a best-effort default partition layout
  - btrfs
  - Compression
- Swap: zram enabled
- Bootloader: Grub
- hostname: dell-xps
- users:
  - set root password
  - create user with password and set sudo
- Audio: Pipewire
- kernels:
  - remove linux
  - add linux-lts
- Network Configuration: Use Network Manager
- Additional packages:
  - gnome
- Timezone: Europe/London
- Automatic Time Sync (NTP): Enable

Reboot system

# Services

```bash
sudo systemctl enable gdm.service
sudo systemctl start gdm.service
```

## Update system

```bash
sudo pacman -Syu
```

## Install AUR Helper (yay)

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

## Install basic utilities

```bash
yay -S \
    auto-cpufreq \
    base-devel \
    curl \
    dnsutils \
    envycontrol \
    extension-manager \
    fzf \
    git \
    gnome-tweaks \
    less \
    nano \
    neofetch \
    net-tools \
    nvidia-lts \
    nvidia-settings \
    nvidia-utils \
    powertop \
    rsync \
    stow \
    tlp \
    tlp-rdw \
    tmux \
    tree \
    unzip \
    vi \
    wget \
    xz-utils \
    zip \
    zoxide \
    zsh \
    --noconfirm
```

## Install software

```bash
yay -S \
    1password \
    azure-cli \
    ghostty \
    neovim \
    nodejs-lts-jod \
    terraform \
    visual-studio-code-bin \
    vlc \
    zig \
    --noconfirm
```

## Terminal setup

```bash
# Install Starship prompt
curl -sS https://starship.rs/install.sh | sh

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Clone the zsh-autosuggestions plugin into the Oh My Zsh custom plugins directory
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Clone the zsh-syntax-highlighting plugin into the Oh My Zsh custom plugins directory
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Clone the fast-syntax-highlighting plugin into the Oh My Zsh custom plugins directory
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting

# Clone the zsh-autocomplete plugin into the Oh My Zsh custom plugins directory with a shallow clone
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete

# Clone the tmux plugin manager (tpm) into the .tmux/plugins directory
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## Enable pacman colors

```bash
sudo vi /etc/pacman.conf
```

To enable color in Pacman’s output, find the “#Color” line in the “Misc options” section. It will be commented out by default. Simply remove the “#” to enable it

## 1. Power Management

First, install and configure **TLP** for general power saving and **auto-cpufreq** for intelligent CPU scaling.

### a) Install TLP

```bash
# Update system and install TLP
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm tlp tlp-rdw
```

### b) Enable TLP Services

```bash
# Enable TLP services and mask conflicting ones
sudo systemctl enable --now tlp.service
sudo systemctl enable --now NetworkManager-dispatcher.service
sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
```

### d) Install and Enable auto-cpufreq

```bash
# Install auto-cpufreq from the AUR
yay -S --noconfirm auto-cpufreq

# Install the auto-cpufreq daemon
sudo auto-cpufreq --install
```

A **reboot** is recommended after this section to ensure all services start correctly.

### b) Switch to Integrated Graphics

```bash
# Switch to integrated-only graphics mode for maximum battery life
sudo envycontrol -s integrated
```

You must **reboot** for this change to take effect. To switch back to using the NVIDIA card, run `sudo envycontrol -s hybrid` and reboot.

## 3. System Tweaks

Optimise SSD health and system memory usage.

### a) Enable SSD TRIM

```bash
# Enable the systemd timer to run TRIM weekly
sudo systemctl enable --now fstrim.timer
```

### b) Reduce Swappiness

```bash
# Reduce swappiness to 10 to prioritize using RAM
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf
```

A **reboot** is required for this to apply, but you can wait and do it with the graphics step above.

## 4. High-DPI Display Setup (GNOME)

Configure a sharp UI by disabling fractional scaling and using 200% integer scaling with adjusted font sizes.

### a) Install GNOME Tweaks

```bash
# Install GNOME Tweaks for fine-grained control
sudo pacman -S --noconfirm gnome-tweaks
```

### b) Apply Scaling Settings

```bash
# Disable fractional scaling
gsettings set org.gnome.mutter experimental-features "[]"

# Set interface scaling to 200% (integer scale)
gsettings set org.gnome.desktop.interface scaling-factor 2

# Set text scaling factor to 0.80 to achieve a comfortable size
gsettings set org.gnome.desktop.interface text-scaling-factor 0.80
```

You must **log out and log back in** for these display settings to apply correctly.

## 5. Verification

After rebooting into integrated graphics mode, check your idle power draw when running on battery.

```bash
# An optimised system should idle in the 5-8W range
upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep "energy-rate"
```
