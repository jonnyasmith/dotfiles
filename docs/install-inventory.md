# Install inventory

> Generated for an audit pass on **2026-08-01**; reflects `~/.dotfiles` config as committed on that date. Every row is traceable to a source file listed under [Sources](#sources); descriptions come from package metadata, not from prose written here. Anything unverifiable is marked `?`.

## Sources

| File | What it declares |
| --- | --- |
| `mise.toml` | `[tools]` (29), `[bootstrap.packages]` apt/dnf/pacman (56), `[bootstrap.repos]` (6), `[tasks."setup:vscode"]` |
| `mise.lock` | resolved version + backend for every `[tools]` entry |
| `mise.macos.toml` | `brew:` (26), `brew-cask:` (24), `[tasks."setup:macos"]` |
| `mise.linux.toml` | `[bootstrap.hooks.pre-packages]` third-party repos, `[tasks."setup:arch"]` AUR list, `setup:gnome` |
| `mise.windows.toml` | `[dotfiles]` + `[tasks."setup:windows"]` PowerShell modules. **No `[tools]`, no `[bootstrap.packages]`** |
| `packages/winget.txt` | 10 winget IDs |
| `packages/vscode.txt` | 104 VS Code extension IDs |
| `bootstrap.sh` | mise itself, via `https://mise.run` |
| `bootstrap.ps1` | winget IDs from `packages/winget.txt` + `jdx.mise` |

---

## Cross-platform tools (mise `[tools]`)

Applies to **every** OS including Windows — `mise.windows.toml` has no `[tools]` table, so its header comment ("anything mise's registry can install is a `[tools]` entry in `mise.windows.toml` instead") points at a section that does not exist; Windows takes the shared table below.

### `[tools]` entries (29)

| Tool | Backend (from `mise.lock`) | Declared range | Locked version | `os` filter | What it is |
| --- | --- | --- | --- | --- | --- |
| `dotnet` | `core:dotnet` | `10, 8` | 10.0.302, 8.0.423 | — | .NET SDKs (`core:dotnet`); both install side-by-side into one DOTNET_ROOT |
| `bun` | `core:bun` | `1` | 1.3.14 | — | Incredibly fast JavaScript runtime, bundler, test runner, and package manager |
| `node` | `core:node` | `24, 22` | 24.18.1, 22.23.2 | — | Open-source, cross-platform JavaScript runtime environment |
| `pnpm` | `aqua:pnpm/pnpm` | `11, 10` | 11.18.0, 10.34.5 | — | Fast, disk space efficient package manager |
| `python` | `core:python` | `3.13, 3.12` | 3.13.14, 3.12.13 | — | Interpreted, interactive, object-oriented programming language |
| `btop` | `aqua:aristocratos/btop` | `latest` | 1.4.7 | linux | Resource monitor. C++ version and continuation of bashtop and bpytop |
| `fzf` | `aqua:junegunn/fzf` | `latest` | 0.74.1 | — | Command-line fuzzy finder written in Go |
| `gh` | `aqua:cli/cli` | `latest` | 2.96.0 | — | GitHub command-line tool |
| `jq` | `aqua:jqlang/jq` | `latest` | 1.8.2 | — | Lightweight and flexible command-line JSON processor |
| `just` | `aqua:casey/just` | `latest` | 1.57.0 | — | Handy way to save and run project-specific commands |
| `lazygit` | `aqua:jesseduffield/lazygit` | `latest` | 0.63.1 | — | Simple terminal UI for git commands |
| `neovim` | `vfox:mise-plugins/vfox-neovim` | `latest` | 0.12.4 | — | Ambitious Vim-fork focused on extensibility and agility |
| `ripgrep` | `aqua:BurntSushi/ripgrep` | `latest` | 15.2.0 | — | Search tool like grep and The Silver Searcher |
| `starship` | `aqua:starship/starship` | `latest` | 1.26.0 | — | Cross-shell prompt for astronauts |
| `terraform` | `aqua:hashicorp/terraform` | `latest` | 1.15.8 | — | Tool to build, change, and version infrastructure |
| `usage` | `aqua:jdx/usage` | `latest` | 4.1.0 | — | Tool for working with usage-spec CLIs (backs `mise` shell completions) |
| `uv` | `aqua:astral-sh/uv` | `latest` | 0.12.0 | — | Extremely fast Python package installer and resolver, written in Rust |
| `zoxide` | `aqua:ajeetdsouza/zoxide` | `latest` | 0.10.0 | — | Shell extension to navigate your filesystem faster |
| `zig` | `core:zig` | `latest` | 0.16.0 | — | Programming language designed for robustness, optimality, and clarity |
| `npm:@github/copilot` | `npm:@github/copilot` | `latest` | 1.0.76 | — | GitHub Copilot CLI — Copilot coding agent in the terminal |
| `npm:@google/gemini-cli` | `npm:@google/gemini-cli` | `latest` | 0.53.0 | — | Gemini CLI |
| `npm:@earendil-works/pi-coding-agent` | `npm:@earendil-works/pi-coding-agent` | `latest` | 0.83.0 | — | Coding agent CLI with read, bash, edit, write tools and session management |
| `npm:@ollama/pi-web-search` | `npm:@ollama/pi-web-search` | `latest` | 0.0.5 | — | Web search and fetch tools for Pi agent — uses Ollama's web search and fetch APIs |
| `npm:@dustinbyrne/kb` | `npm:@dustinbyrne/kb` | `latest` | 0.4.1 | — | Automated Kanban board for `pi`; agents execute queued ideas using worktrees *(low-download opt-in)* |
| `npm:azure-functions-core-tools` | `npm:azure-functions-core-tools` | `latest` | 4.12.1 | — | Azure Functions Core Tools |
| `npm:ccstatusline` | `npm:ccstatusline` | `latest` | 2.2.27 | — | Customizable status line formatter for Claude Code CLI |
| `npm:cline` | `npm:cline` | `latest` | 3.0.47 | — | Autonomous coding agent CLI — creates/edits files, runs commands, uses the browser |
| `npm:firebase-tools` | `npm:firebase-tools` | `latest` | 15.25.0 | — | Command-Line Interface for Firebase |
| `npm:kanban` | `npm:kanban` | `latest` | 0.1.70 | — | A kanban foundation for coding agents |

### Additional installs implied by this section (3)

| Thing | Mechanism | What it is |
| --- | --- | --- |
| `yarn`, `yarnpkg` shims | `[settings.node] corepack = true` — installed with **every** node version | Corepack package-manager shims |
| `ilspycmd` | `dotnet tool install --global` in `[tasks."setup:macos"]` (guarded on `dotnet` on PATH, so mac-only in practice) | Command-line decompiler using the ILSpy decompilation engine |
| `~/.dotnet/tools` on PATH | `[env] _.path` in `mise.toml` | Where `dotnet tool install --global` puts binaries (`DOTNET_CLI_HOME`, not `DOTNET_ROOT`) |

---

## macOS

### `brew:` formulae (26)

Installed by mise's built-in Homebrew support; real Homebrew is not required for these.

| Formula | Description (`brew info`) | Note |
| --- | --- | --- |
| `avrdude` | Atmel AVR MCU programmer | — |
| `azure-cli` | Microsoft Azure CLI 2.0 | **pulls `python@3.14`** |
| `btop` | Resource monitor. C++ version and continuation of bashtop and bpytop | macOS only — `[tools] btop` is `os = ["linux"]` because its aqua backend has no darwin build |
| `caddy` | Powerful, enterprise-ready, open source web server with automatic HTTPS | — |
| `clang-format` | Formatting tools for C, C++, Obj-C, Java, JavaScript, TypeScript | — |
| `cmake` | Cross-platform make | — |
| `curl` | Get a file from an HTTP, HTTPS or FTP server | brew `git` depends on it (`dependencies: curl, expat`) |
| `expat` | XML 1.0 parser | brew `git` depends on it |
| `git` | Distributed revision control system | — |
| `git-filter-repo` | Quickly rewrite git repository history | — |
| `herdr` | Agent multiplexer that lives in your terminal | — |
| `htop` | Improved top (interactive process viewer) | — |
| `lcov` | Graphical front-end for GCC's coverage testing tool (gcov) | — |
| `mosquitto` | Message broker implementing the MQTT protocol | — |
| `ninja` | Small build system for use with gyp or CMake | — |
| `pandoc` | Swiss-army knife of markup format conversion | — |
| `pipx` | Execute binaries from Python packages in isolated environments | **pulls `python@3.14`** |
| `platformio` | Your Gateway to Embedded Software Development Excellence | **pulls `python@3.14`** |
| `poppler` | PDF rendering library (based on the xpdf-3.0 code base) | — |
| `pytest` | Simple powerful testing with Python | **pulls `python@3.14`** |
| `ruff` | Extremely fast Python linter, written in Rust | — |
| `rustup` | Rust toolchain installer | — |
| `tmux` | Terminal multiplexer | — |
| `tree` | Display directories as trees (with optional color/HTML output) | — |
| `wget` | Internet file retriever | — |
| `zsh` | UNIX shell (command interpreter) | — |

### `brew-cask:` casks (24)

| Cask | Kind | Description (`brew info --cask`) |
| --- | --- | --- |
| `1password` | GUI app | Password manager that keeps all passwords secure behind one password |
| `alfred` | GUI app | Application launcher and productivity software |
| `brave-browser` | GUI app | Web browser focusing on privacy |
| `chatgpt` | GUI app | OpenAI's official ChatGPT desktop app |
| `claude` | GUI app | Anthropic's official Claude AI desktop app |
| `codex` | CLI | OpenAI's coding agent that runs in your terminal |
| `fluidvoice` | GUI app | Offline voice-to-text dictation app with AI enhancement |
| `font-fira-mono-nerd-font` | Font | FiraMono Nerd Font (Fira) — Nerd-Fonts patched Fira Mono |
| `ghostty` | GUI app | Terminal emulator that uses platform-native UI and GPU acceleration |
| `google-chrome` | GUI app | Web browser |
| `inkscape` | GUI app | Vector graphics editor |
| `karabiner-elements` | GUI app (pkg installer) + CLI | Keyboard customiser |
| `microsoft-azure-storage-explorer` | GUI app | Explorer for Azure Storage |
| `miro` | GUI app | Online collaborative whiteboard platform |
| `obsidian` | GUI app + CLI | Knowledge base that works on top of a local folder of plain text Markdown files |
| `openttd` | GUI app | Open-source transport simulation game |
| `orbstack` | GUI app + CLI | Replacement for Docker Desktop |
| `parallels` | GUI app | Desktop virtualization software |
| `rectangle` | GUI app | Move and resize windows using keyboard shortcuts or snap areas |
| `repo-prompt` | GUI app | Prompt generation tool |
| `slack` | GUI app | Team communication and collaboration software |
| `todoist-app` | GUI app | To-do list |
| `visual-studio-code` | GUI app + CLI | Open-source code editor |
| `visual-studio-code@insiders` | GUI app + CLI | Open-source code editor |

Deliberately **absent** from the cask list, per comments in `mise.macos.toml`: `microsoft-teams` (pkg cask with installer `choices`, which mise rejects and which fails the whole packages phase) and `microsoft-auto-update` (bare `.pkg`, needs a sudo TTY; the Microsoft apps install it themselves).

### `[tasks."setup:macos"]` (2)

| Item | Mechanism | What it is |
| --- | --- | --- |
| `microsoft-teams` | `brew install --cask` via **real Homebrew** (skipped with a warning if `brew` is absent) | GUI app (pkg installer) — Meet, chat, call, and collaborate in just one place |
| `ilspycmd` | `dotnet tool install --global` | Command-line decompiler using the ILSpy decompilation engine |

---

## Debian / Ubuntu / WSL / Raspberry Pi

### `apt:` entries (19)

From `mise.toml` `[bootstrap.packages]`. "Third-party repo" is what `[bootstrap.hooks.pre-packages]` in `mise.linux.toml` adds for that package.

| Package | Description | Source / repo added by `pre-packages` |
| --- | --- | --- |
| `1password` | Password manager; here for its SSH agent — the snap build cannot use it (mise.toml comment) | **1Password Debian repo** (`downloads.1password.com/linux/debian`, keyring + debsig policy) |
| `ca-certificates` | Common CA certificates | distro archive — but the hook installs it as a Docker-repo/HTTPS-apt prerequisite |
| `code` | Visual Studio Code — code editor for building and debugging modern web and cloud apps | **Microsoft repo** (`packages.microsoft.com/repos/code`, deb822 `.sources`) |
| `curl` | command line tool for transferring data with URL syntax | distro archive |
| `dbus-x11` | simple interprocess messaging system (X11 deps) — provides `dbus-launch` for gnome-tweaks over SSH/X | distro archive |
| `ghostty` | Fast, native, feature-rich terminal emulator pushing modern features | **PPA `ppa:mkasberg/ghostty-ubuntu`** — added only when `ID`/`ID_LIKE` matches `*ubuntu*`, so unresolvable on Debian / Raspberry Pi OS |
| `git` | fast, scalable, distributed revision control system | distro archive |
| `htop` | interactive processes viewer | distro archive |
| `nala` | Commandline frontend for the APT package manager | distro archive |
| `python3-neovim` | pynvim — the `:checkhealth` python3 provider. **Transitional dummy package, last shipped in Ubuntu 22.04 jammy / Debian bookworm**; the live name is `python3-pynvim` | distro archive (absent from noble/questing/resolute) |
| `socat` | multipurpose relay for bidirectional data transfer — 1Password SSH-agent relay under WSL | distro archive |
| `tmux` | terminal multiplexer | distro archive |
| `tree` | displays an indented directory tree, in color | distro archive |
| `ubuntu-restricted-extras` | Commonly used media codecs and fonts for Ubuntu | distro archive; hook preseeds the `msttcorefonts` EULA via `debconf-set-selections` or the install hangs |
| `unzip` | De-archiver for .zip files | distro archive |
| `vlc` | multimedia player and streamer | distro archive |
| `wget` | retrieves files from the web | distro archive — **also installed imperatively by the hook** (`apt-get install -y wget gpg`) before the VS Code repo is added |
| `xz-utils` | XZ-format compression utilities | distro archive |
| `zsh` | shell with lots of features — pairs with `[bootstrap.user].login_shell = /usr/bin/zsh` | distro archive |

### `pre-packages` hook, apt branch (3)

Installed imperatively, not declared in `[bootstrap.packages]`:

| Package | Description | Why |
| --- | --- | --- |
| `wget` | retrieves files from the web | fetch the Microsoft signing key (also declared as `apt:wget` — installed twice) |
| `gpg` | GNU Privacy Guard -- minimalist public key operations | dearmor the Microsoft + 1Password keys |
| `software-properties-common` | manage the repositories that you install software from (common) | provides `add-apt-repository` for the Ghostty PPA (Ubuntu family only) |

Hook-order note: the 1Password repo step pipes `curl -sS …` **before** `apt:curl` is installed, so a minimal Debian/WSL image without `curl` preinstalled fails that step. `wget`/`gpg` are installed explicitly for the VS Code step; `curl` is not.

---

## Fedora

### `dnf:` entries (10)

From `mise.toml` `[bootstrap.packages]`.

| Package | Description | Source / repo added by `pre-packages` |
| --- | --- | --- |
| `1password` | Password manager; here for its SSH agent | **1Password RPM repo** (`/etc/yum.repos.d/1password.repo`, GPG key imported) |
| `azure-cli` | Microsoft Azure Command-Line Tools | Fedora repos (`updates`) |
| `code` | Visual Studio Code — code editor for building and debugging modern web and cloud apps | **Microsoft yum repo** (`/etc/yum.repos.d/vscode.repo`) |
| `curl` | A utility for getting files from remote servers (FTP, HTTP, and others) | Fedora repos |
| `ghostty` | Fast, native, feature-rich terminal emulator pushing modern features | **COPR `scottames/ghostty`** — hook installs `dnf5-plugins` first if `copr` is missing |
| `htop` | Interactive process viewer | Fedora repos |
| `python3-neovim` | Python client to Neovim — the `:checkhealth` python3 provider | Fedora repos (`updates-testing` at time of writing) |
| `tree` | File system tree viewer | Fedora repos |
| `vlc` | The cross-platform open-source multimedia framework, player and server | hook adds **RPM Fusion free**; but `vlc` is now in Fedora's own `updates` (3.0.23-1.fc43), so RPM Fusion is no longer needed to *resolve* it |
| `zsh` | Powerful interactive shell — pairs with `[bootstrap.user].login_shell` | Fedora repos |

### `pre-packages` hook, dnf branch (2)

Installed imperatively, not declared in `[bootstrap.packages]`:

| Package | Description | Why |
| --- | --- | --- |
| `rpmfusion-free-release` | RPM Fusion "free" repository definition, installed from `mirrors.rpmfusion.org/free/fedora/…noarch.rpm` | declared prerequisite for `dnf:vlc` (see the table above — no longer required for resolution) |
| `dnf5-plugins` | Plugins for dnf5 | provides `dnf copr`, needed for the Ghostty COPR; absent on a minimal install |

The hook also writes `max_parallel_downloads=10` and `fastestmirror=true` into `/etc/dnf/dnf.conf` (test-before-append, so idempotent). Not an install.

---

## Arch

### `pacman:` (27)

Descriptions and repo from the Arch package API (`archlinux.org/packages/search/json`).

| Package | Repo | Description |
| --- | --- | --- |
| `azure-cli` | `extra` | Command-line tools for Microsoft Azure |
| `base-devel` | `core` | Basic tools to build Arch Linux packages |
| `bind` | `extra` | A complete, highly portable implementation of the DNS protocol |
| `curl` | `core` | command line tool and library for transferring data with URLs |
| `extension-manager` | `extra` | A native tool for browsing, installing, and managing GNOME Shell Extensions |
| `ghostty` | `extra` | Fast, native, feature-rich terminal emulator pushing modern features |
| `git` | `extra` | the fast distributed version control system |
| `less` | `core` | A terminal based program for viewing text files |
| `linux-firmware-qcom` | `core` | Firmware files for Linux - Firmware for Qualcomm SoCs |
| `nano` | `core` | Pico editor clone with enhancements |
| `net-tools` | `core` | Configuration tools for Linux networking |
| `nvidia-open-lts` | `extra` | NVIDIA open kernel modules |
| `nvidia-settings` | `extra` | Tool for configuring the NVIDIA graphics driver |
| `nvidia-utils` | `extra` | NVIDIA drivers utilities |
| `powertop` | `extra` | A tool to diagnose issues with power consumption and power management |
| `rsync` | `extra` | A fast and versatile file copying tool for remote and local files |
| `stress` | `extra` | A tool that stress tests your system (CPU, memory, I/O, disks) |
| `tlp` | `extra` | Linux Advanced Power Management |
| `tlp-rdw` | `extra` | Linux Advanced Power Management - Radio Device Wizard |
| `tmux` | `extra` | Terminal multiplexer |
| `tree` | `extra` | A directory listing program displaying a depth indented list of files |
| `unzip` | `extra` | For extracting and viewing files in .zip archives |
| `vlc` | `extra` | Free and open source cross-platform multimedia player and framework |
| `wget` | `extra` | Network utility to retrieve files from the web |
| `xz` | `core` | Library and command line tools for XZ and LZMA compressed files |
| `zip` | `extra` | Compressor/archiver for creating and modifying zipfiles |
| `zsh` | `extra` | A very advanced and programmable command interpreter (shell) for UNIX |

### AUR via `yay` in `[tasks."setup:arch"]` (5)

`yay` itself is a **manual prerequisite** — nothing in this repo installs it; the task prints a warning and skips.

| Package | Description (AUR RPC) | Note |
| --- | --- | --- |
| `auto-cpufreq` | Automatic CPU speed & power optimizer | `--install` run only when the systemd unit is absent |
| `envycontrol` | CLI tool for Nvidia Optimus graphics mode switching on Linux | pairs with the `nvidia-*` pacman entries |
| `neofetch` | A CLI system information tool written in BASH that supports displaying images | **upstream `dylanaraps/neofetch` archived 2024-07-19** |
| `1password` | Password manager and secure wallet | the only Arch route — not in `extra` |
| `visual-studio-code-bin` | Visual Studio Code (vscode): Editor for building and debugging modern web and cloud applications (official binary version) | Arch route to `code` |

`setup:arch` also enables `tlp.service`, `NetworkManager-dispatcher.service`, `fstrim.timer`, masks `systemd-rfkill.service`/`.socket`, uncomments `Color` in `pacman.conf`, and writes `vm.swappiness=10`. No installs.

---

## Windows

### `packages/winget.txt` (10) — installed by `bootstrap.ps1`

Descriptions from the package's own `*.locale.en-US.yaml` manifest in `microsoft/winget-pkgs`.

| winget ID | Name | Description |
| --- | --- | --- |
| `AgileBits.1Password` | 1Password | Top-Rated Password Manager for Personal & Business Use |
| `Git.Git` | Git | A free and open source distributed version control system |
| `Google.Chrome` | Google Chrome | The Fast & Secure Web Browser Built to be Yours |
| `JetBrains.Toolbox` | JetBrains Toolbox | Manage your IDEs the easy way |
| `Microsoft.AzureCLI` | Microsoft Azure CLI | Set of commands used to create and manage Azure resources |
| `Microsoft.PowerShell` | PowerShell | Cross-platform task automation shell, scripting language and configuration framework |
| `Microsoft.PowerToys` | PowerToys | Set of utilities for power users to tune and streamline their Windows experience |
| `Microsoft.VisualStudioCode` | Microsoft Visual Studio Code | Code editor optimized for building and debugging modern web and cloud applications |
| `RedHat.Podman-Desktop` | Podman Desktop | Manage different container engines from a single UI and tray icon |
| `RandyRants.SharpKeys` | SharpKeys | Registry hack (HKLM Scancode Map) that makes certain keys act like other keys |

Docker Desktop is deliberately dropped in favour of Podman Desktop (comment in `winget.txt`).

### `bootstrap.ps1` (not in `winget.txt`)

| Item | Mechanism | What it is |
| --- | --- | --- |
| `jdx.mise` | `winget install --id jdx.mise` in the `mise` step, only when `mise` is not already resolvable | mise-en-place — "Your dev env, already prepped." |

### `[tasks."setup:windows"]` — PowerShell Gallery modules (3)

Installed `-Scope CurrentUser` from PSGallery, skipped when already available.

| Module | Pin | Description (PSGallery) |
| --- | --- | --- |
| `PSFzf` | `RequiredVersion = 2.5.16` | Thin wrapper around fzf; registers Ctrl+t with PSReadLine |
| `Terminal-Icons` | latest | PowerShell module to add file icons to terminal based on file extension |
| `z` | latest | Navigate the filesystem from `cd` history; a port of the `z` bash script |

`mise.windows.toml` installs **nothing else** — it contributes two `[dotfiles]` entries (PowerShell profile, Windows Terminal `settings.json`) and this task.

---

## Git repos cloned

`[bootstrap.repos]` in `mise.toml` (6) — cloned before `[dotfiles]` is applied, on every OS.

| Target path | Upstream | Ref | What it is |
| --- | --- | --- | --- |
| `~/.oh-my-zsh` | `github.com/ohmyzsh/ohmyzsh.git` | `master` | oh-my-zsh framework; cloned directly instead of running its installer (which would also `chsh` and write its own `.zshrc`) |
| `~/.oh-my-zsh/custom/plugins/zsh-autosuggestions` | `github.com/zsh-users/zsh-autosuggestions.git` | `master` | Fish-like autosuggestions for zsh |
| `~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting` | `github.com/zsh-users/zsh-syntax-highlighting.git` | `master` | Syntax highlighting for the zsh command line |
| `~/.oh-my-zsh/custom/plugins/fast-syntax-highlighting` | `github.com/zdharma-continuum/fast-syntax-highlighting.git` | `master` | Faster alternative syntax highlighter — **overlaps `zsh-syntax-highlighting`; both are cloned** |
| `~/.oh-my-zsh/custom/plugins/zsh-autocomplete` | `github.com/marlonrichert/zsh-autocomplete.git` | `main` | Real-time type-ahead completion for zsh |
| `~/.config/tmux/plugins/tpm` | `github.com/tmux-plugins/tpm.git` | `master` | tmux plugin manager; its plugins still need `prefix + I` once, by hand |

---

## Overlap analysis

### (a) Same software declared in `[tools]` *and* a system package manager

Literal name collisions across `[tools]` × {`brew`, `brew-cask`, `apt`, `dnf`, `pacman`, `winget`}: exactly **one** (`btop`). The rest of the risk is by *provided binary* and by *transitive dependency*, not by name.

| Software | `[tools]` | System manager | Shadowing risk |
| --- | --- | --- | --- |
| `btop` | `aqua:aristocratos/btop`, `os = ["linux"]` | `brew:btop` (macOS) | **None — partitioned by design.** The aqua backend has no darwin build; the two never coexist. Windows gets neither (see parity table). |
| `python` | `core:python` 3.13 + 3.12 | `brew:python@3.14`, pulled in as a dependency of `brew:azure-cli`, `brew:pipx`, `brew:platformio`, `brew:pytest` (verified via `brew info --json=v2`) | **Real, and actively mitigated.** `/opt/homebrew/bin/python3` is 3.14; `.zshenv`/`.zprofile` re-assert mise shims ahead of it after `brew shellenv`. Any shell that never runs `mise activate` and does run `brew shellenv` gets brew's 3.14. |
| `neovim` | `vfox:mise-plugins/vfox-neovim` | `apt:python3-neovim`, `dnf:python3-neovim` | **None** — those are the pynvim *provider*, not a second neovim. No distro `neovim` package is declared anywhere. |
| `uv` | `aqua:astral-sh/uv` | `brew:pipx` | Not a PATH shadow, but two Python-app installers on the same machine (see (c)). |
| `node` | `core:node` 24 + 22 | — | No distro/brew/winget node declared. Clean. |
| `git` | *(not in `[tools]`)* | `brew:git`, `apt:git`, `pacman:git`, `winget Git.Git` | Not a `[tools]` conflict; it is a **parity** problem — `dnf:git` is missing (see (b)). |
| `curl`, `htop`, `tmux`, `tree`, `wget`, `zsh`, `unzip` | *(not in `[tools]`)* | brew / apt / dnf / pacman, inconsistently | No shadowing; the exposure is per-OS drift (see (b)). These are the obvious candidates for promotion into `[tools]`, which is what `mise.toml`'s own rule ("if it is a CLI you invoke and mise's registry has it, it goes here") would imply. |

### (b) Parity gaps — declared for some OSes, conspicuously absent on others

`—` = not declared. `n/a` = platform genuinely does not apply. **Bold** = the gap worth a decision.

| Software | macOS | Debian/Ubuntu | Fedora | Arch | Windows | Gap |
| --- | --- | --- | --- | --- | --- | --- |
| `git` | `brew:git` | `apt:git` | **—** | `pacman:git` | `Git.Git` | **Fedora** — every other OS declares git |
| `wget` | `brew:wget` | `apt:wget` | **—** | `pacman:wget` | — | **Fedora** |
| `tmux` | `brew:tmux` | `apt:tmux` | **—** | `pacman:tmux` | n/a | **Fedora** — yet `~/.config/tmux` and the `tpm` clone are applied on every OS |
| `htop` | `brew:htop` | `apt:htop` | `dnf:htop` | **—** | n/a | **Arch** — yet `~/.config/htop/htoprc` is applied on every OS |
| `btop` | `brew:btop` | `[tools]` | `[tools]` | `[tools]` | **—** | **Windows** — `os = ["linux"]` excludes it, no winget entry, yet `~/.config/btop/btop.conf` is applied on every OS |
| `unzip` | n/a (system) | `apt:unzip` | **—** | `pacman:unzip` | — | **Fedora** |
| `zip` | n/a (system) | **—** | **—** | `pacman:zip` | — | **Debian, Fedora** |
| xz | — | `apt:xz-utils` | **—** | `pacman:xz` | — | **Fedora** — mise's own tarballs are `.xz` |
| pynvim | **—** | `apt:python3-neovim` | `dnf:python3-neovim` | **—** (`python-pynvim`) | — | **macOS, Arch** — `neovim` is in `[tools]` on all five, so `:checkhealth` python3 provider is missing on two of them. Debian's name is also **stale** (transitional, gone after 22.04) |
| `azure-cli` | `brew:azure-cli` | **—** | `dnf:azure-cli` | `pacman:azure-cli` | `Microsoft.AzureCLI` | **Debian/Ubuntu/WSL** — the only OS without it |
| build toolchain | `brew:cmake`, `ninja`, `clang-format`, `lcov` | **—** | **—** | `pacman:base-devel` | n/a | **Debian, Fedora** — no `build-essential` / `@development-tools` |
| Nerd font | `brew-cask:font-fira-mono-nerd-font` | **—** | **—** | **—** | **—** | **Windows + all Linux** — `home/AppData/.../settings.json` sets face `FiraMono Nerd Font Mono`, and nothing installs it there. (Ghostty's config sets no font, so Linux is cosmetic only.) |
| container runtime | `brew-cask:orbstack` | **—** | **—** | **—** | `RedHat.Podman-Desktop` | **All Linux** — and `setup:wsl` checks `/etc/wsl.conf` for `command="service docker start"`, i.e. it expects a docker nothing installs |
| Chrome | `brew-cask:google-chrome` | **—** | **—** | **—** | `Google.Chrome` | **All Linux** |
| VLC | **—** | `apt:vlc` | `dnf:vlc` | `pacman:vlc` | **—** | macOS, Windows (plausibly deliberate) |
| Ghostty | `brew-cask:ghostty` | `apt:ghostty` (Ubuntu only) | `dnf:ghostty` | `pacman:ghostty` | n/a | **Debian / Raspberry Pi OS** — the PPA guard is `*ubuntu*`, so `apt:ghostty` cannot resolve there. Windows has no upstream build (Windows Terminal is configured instead) |
| `herdr` | `brew:herdr` | **—** | **—** | **—** | **—** | **Everywhere but macOS** — `~/.config/herdr` is applied on every OS |
| JetBrains IDE | **—** | **—** | **—** | **—** | `JetBrains.Toolbox` | **macOS + Linux** — `~/.ideavimrc` is applied on every OS |
| GNOME extension GUI | n/a | **—** | **—** | `pacman:extension-manager` | n/a | Debian, Fedora (`gnome-tweaks` *is* installed imperatively on all three by `setup:gnome`) |
| `dbus-x11` | n/a | `apt:dbus-x11` | **—** | **—** | n/a | Fedora, Arch — needed for `gnome-tweaks` over SSH/X |
| `less`, `nano`, `net-tools`, `rsync`, `bind` | — | — | — | `pacman:*` | — | Arch-only; usually preinstalled elsewhere |
| `powertop`, `stress`, `tlp`, `tlp-rdw`, AUR `auto-cpufreq`/`envycontrol` | — | — | — | `pacman:*` / AUR | — | Arch-only, laptop-specific (Dell XPS) — genuinely machine-scoped, not a gap |
| `nvidia-open-lts`, `nvidia-settings`, `nvidia-utils`, `linux-firmware-qcom` | — | — | — | `pacman:*` | — | Arch-only, hardware-specific — genuinely machine-scoped |
| `nala`, `socat`, `ca-certificates`, `ubuntu-restricted-extras` | — | `apt:*` | — | — | — | Debian-family-specific by nature |
| mac-only GUI: `alfred`, `brave-browser`, `chatgpt`, `claude`, `codex`, `fluidvoice`, `inkscape`, `karabiner-elements`, `microsoft-azure-storage-explorer`, `miro`, `obsidian`, `openttd`, `orbstack`, `parallels`, `rectangle`, `repo-prompt`, `slack`, `todoist-app`, `microsoft-teams` | `brew-cask` | — | — | — | — | 19 GUI apps with no Linux or Windows counterpart declared. Windows counterparts declared instead: `PowerToys`, `SharpKeys`, `JetBrains.Toolbox`, `Podman-Desktop` |
| mac-only CLI: `avrdude`, `caddy`, `clang-format`, `cmake`, `expat`, `git-filter-repo`, `lcov`, `mosquitto`, `ninja`, `pandoc`, `pipx`, `platformio`, `poppler`, `pytest`, `ruff`, `rustup` | `brew:*` | — | — | — | — | 16 CLIs/libs with no non-macOS route. Several are in mise's registry (`ruff`, `cmake`, `pandoc`) and could move to `[tools]` |
| `1Password` | `brew-cask` | `apt` | `dnf` | AUR | `winget` | ✅ full parity |
| VS Code | `brew-cask:visual-studio-code` | `apt:code` | `dnf:code` | AUR `visual-studio-code-bin` | `Microsoft.VisualStudioCode` | ✅ full parity |
| `curl` | `brew:curl` | `apt:curl` | `dnf:curl` | `pacman:curl` | — (ships in Windows 10+) | ✅ |
| `tree` | `brew:tree` | `apt:tree` | `dnf:tree` | `pacman:tree` | — | ✅ (Unix) |
| `zsh` | `brew:zsh` | `apt:zsh` | `dnf:zsh` | `pacman:zsh` | n/a | ✅ |
| everything in `[tools]` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ one declaration, one locked version |

### (c) Installed by two mechanisms at once

| Software | Mechanism 1 | Mechanism 2 | Assessment |
| --- | --- | --- | --- |
| `wget` (Debian) | `apt:wget` in `[bootstrap.packages]` | `sudo apt-get install -y wget gpg` in `[bootstrap.hooks.pre-packages]` | **Genuine duplicate.** The hook runs first (it needs wget before the package phase), so `apt:wget` is always a no-op on Debian. Same manager, so harmless — but the declaration is doing nothing there. |
| `ca-certificates` (Debian) | `apt:ca-certificates` | implicit prerequisite of the HTTPS apt sources the hook writes | Ordering, not duplication: the hook writes HTTPS sources before the package that makes them work is guaranteed installed. |
| VS Code | `brew-cask:visual-studio-code` | `brew-cask:visual-studio-code@insiders` | Deliberate — Stable and Insiders side by side. Both get the same 104 extensions only if the `code` CLI on PATH points at the one you mean; `setup:vscode` uses whichever `code` resolves first. |
| Python app installer | `brew:pipx` | `[tools] uv` (and `uv tool install`) | Two tools for the same job on macOS; `pipx` additionally drags in `brew:python@3.14`. Candidate for deletion. |
| `pytest`, `ruff` | `brew:pytest`, `brew:ruff` | per-project `uv` venvs (`[settings.python] uv_venv_auto = true`) | `brew:pytest` installs a machine-global pytest bound to brew's `python@3.14`, next to per-project venv pytests. `ruff` is a static binary, so it is only a version-drift question. |
| `python` 3.14 | `brew:azure-cli` / `pipx` / `platformio` / `pytest` dependency | `[tools] python` 3.13 + 3.12 | Three interpreters on a mac. This is the exact case `mise.toml`'s python comment and `.zprofile`'s shim re-assert exist for. |
| `mise` | `curl https://mise.run \| sh` in `bootstrap.sh` | `winget install --id jdx.mise` in `bootstrap.ps1` | Partitioned by OS. Note the winget manifest pin available is `2026.7.15`, while `mise.toml` sets `min_version = "2026.7.17"` — a fresh Windows box may install a mise **below the hard floor** and then be refused by the config. |
| `zsh-syntax-highlighting` + `fast-syntax-highlighting` | `[bootstrap.repos]` clone | `[bootstrap.repos]` clone | Two syntax highlighters cloned; only one can be last in `plugins=()`. Both are also listed as needing to stay in sync with `home/.zshrc`. |
| `neovim` config providers | `[tools] neovim` | `apt`/`dnf` `python3-neovim` | Complementary, not duplicated — but see the pynvim parity gap. |
| Homebrew itself | **nothing installs it** | — | `setup:macos` needs real `brew` for `microsoft-teams`, and `.zprofile` claims "bootstrap.sh installs it" — `bootstrap.sh` installs only mise. Homebrew is an undeclared manual prerequisite on macOS. |
| `yay` | **nothing installs it** | — | Documented manual prerequisite (`docs/arch.md`); `setup:arch` warns and skips the 5 AUR packages without it. |

---

## Cross-platform tasks

| Task | Installs | Count |
| --- | --- | --- |
| `[tasks."setup:vscode"]` (`mise.toml`) | VS Code extensions from `packages/vscode.txt`, via `code --install-extension --force`. No-ops with a warning when the `code` CLI is not on PATH. | 104 |
| `[tasks."setup:gnome"]` (`mise.linux.toml`) | `gnome-tweaks` via whichever of `dnf`/`apt-get`/`pacman` exists, only when `gnome-shell` is installed and `gnome-tweaks` is not. Descriptions: Fedora "Customize advanced GNOME 3 options", Ubuntu "tool to adjust advanced configuration settings for GNOME", Arch "Graphical interface for advanced GNOME 3 settings (Tweak Tool)". | 1 |
| `bootstrap.sh` | `mise`, from `https://mise.run` into `~/.local/bin`, only when not already on PATH. | 1 |

Tasks that install **nothing**: `setup:fedora`, `setup:debian`, `setup:wsl` (creates `~/.1password`, reports on `/etc/wsl.conf`), `setup:gtk`, `setup:cosmic`, and every `check:*`.

## Manual prerequisites (installed by nothing in this repo)

| Item | Needed by | Evidence |
| --- | --- | --- |
| Homebrew | `[tasks."setup:macos"]` (`brew install --cask microsoft-teams`), `.zprofile` `brew shellenv` | `bootstrap.sh` installs only mise |
| `yay` | `[tasks."setup:arch"]` AUR packages | `docs/arch.md`, referenced by the task's warning |
| tmux plugins | `~/.config/tmux/plugins/tpm` is cloned, plugins are not fetched | `prefix + I`, noted in `mise.toml` and `bootstrap.sh` |
| 1Password sign-in + SSH agent toggle | every `git` remote | `bootstrap.sh` header |
| VS Code "Shell Command: Install 'code' command in PATH" | `[tasks."setup:vscode"]` | task prints the instruction and exits 0 |
| `shellcheck` | `[tasks."check:shell"]` (optional; skipped when absent) | comment: "not in `[tools]` — a nice-to-have" |
| `~/.config/git/config.local` + `config.work` | work git identity | `bootstrap.sh` warns every run |
