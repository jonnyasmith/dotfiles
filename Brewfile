# Every macOS package, formula and cask alike. Applied by the pre-packages hook
# in mise.macos.toml; see docs/adr/0011-homebrew-owns-macos-packages.md.
#
# The hook passes no `--cleanup`. It uninstalls anything absent from this file,
# which turns a forgotten line into data loss on a daily driver.
#
# mise is absent deliberately: bootstrap.sh installs it from mise.run before
# this file is ever read, and `brew install mise` would be a second owner of the
# same binary (docs/adr/0004-one-updater-per-binary.md).

# --------------------------------------------------------------- formulae --
#
# Anything mise's registry can supply belongs in [tools] instead; these are the
# ones it cannot.

brew "avrdude"
# Not the registry `btop`: its aqua backend publishes Linux binaries only.
brew "btop"
brew "git"
brew "htop"
brew "mosquitto"
brew "platformio"
# Not the registry `rustup`: that is rustup-init, which manages its own
# toolchain directory outside mise.
brew "rustup", link: true
# Not the registry `tree`: that is a Rust reimplementation with different flags.
brew "tree"
brew "wget"
brew "zsh"

# ------------------------------------------------------------------ casks --
#
# microsoft-auto-update is absent: the Microsoft apps pull it in themselves, so
# nothing here has to ask for it.

cask "1password"
cask "alfred"
cask "brave-browser"
cask "chatgpt"
cask "claude"
cask "codex"
cask "fluidvoice"
cask "font-fira-mono-nerd-font"
cask "ghostty"
cask "google-chrome"
cask "inkscape"
cask "karabiner-elements"
cask "kitty"
cask "microsoft-azure-storage-explorer"
cask "microsoft-teams"
cask "miro"
cask "obsidian"
cask "openttd"
cask "orbstack"
cask "parallels"
cask "rectangle"
cask "repo-prompt"
cask "slack"
cask "todoist-app"
cask "visual-studio-code"
# The `code` alias in home/.config/zsh/aliases.zsh points at this one on macOS.
cask "visual-studio-code@insiders"
