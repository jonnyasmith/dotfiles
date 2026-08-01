# macOS software audit — keep/drop checklist

Generated 2026-08-01 on `Apple M1 Max / darwin 25.1.0`, Homebrew at `/opt/homebrew`.
Scope: everything declared in [`mise.macos.toml`](../mise.macos.toml), plus `microsoft-teams`
(installed by `[tasks."setup:macos"]`, not declared as a cask) and anything Homebrew reports
that the repo does not declare.

**This file records signals only. It contains no keep/drop recommendation — that is your call.**
Tick a box to mark an entry for removal.

## How to read the signals

| Column | Source | What it actually means |
| --- | --- | --- |
| Installed | `brew list --cask` / `brew list --formula`, plus the resolved artifact path from `brew info --json=v2` | Present on disk right now. |
| Last opened (count) | `mdls -name kMDItemLastUsedDate -name kMDItemUseCount` | **Mostly useless on this machine — see the caveat below.** |
| Focus ≤30d | `~/Library/Application Support/Knowledge/knowledgeC.db`, stream `/app/usage`, joined on the bundle's real `CFBundleIdentifier` | Foreground sessions. Authoritative, but the store only retains **2026-07-03 → 2026-07-31**. |
| Last wrote state | newest mtime across the app's own `~/Library/Preferences/<bundleid>.plist`, `Containers/`, `HTTPStorages/`, `Saved Application State/`, `Caches/` and app-specific dirs | An **mtime**, not a launch record — but only the app itself writes there, so it is the best evidence that survives beyond 30 days. |
| Last invoked / Invocations | `~/.zsh_history` with `EXTENDED_HISTORY` timestamps — **10,020 entries spanning 2025-10-30 → 2026-08-01** | Real invocation records, matched at command position across every binary each formula ships. |
| Leaf/dep | `brew leaves`, `brew uses --installed <name>`, and the cask's `INSTALL_RECEIPT.json` | A pure dependency can have its declaration dropped for free. |

### Caveat: `mdls` last-used is unreliable here — do not read `?` as "never opened"

Two measured problems, which is why the richer columns exist:

1. **Apps.** Every non-`(null)` `kMDItemLastUsedDate` on this machine falls inside a two-day
   window (2026-07-30 → 2026-08-01), including for apps demonstrably used earlier. Spotlight is
   not stale (`/System/Volumes/Data/.Spotlight-V100` dates to 2025-09-23) — the attribute simply
   is not retained. `?` therefore means *"Spotlight has no value"*, nothing more.
2. **CLI binaries.** `mdls` *does* return a date for `/opt/homebrew/bin/*`, but it is the
   install/upgrade time, not an invocation. Proof: `git` has 1,589 recorded invocations,
   the most recent today, yet `mdls /opt/homebrew/bin/git` reports `2026-07-07` — its brew
   upgrade date. Every formula's "Last opened" is reported as `?` for this reason.

## GUI applications

Sorted coldest first, by the most recent evidence of use from *any* column.

| Item | Installed | Last opened (count) | Focus ≤30d | Last wrote state | Leaf/dep | Signal verdict |
| --- | --- | --- | --- | --- | --- | --- |
| - [ ] `codex` | binary cask (bin/codex) | ? | — | — | leaf | n/a (CLI cask) — **56 shell invocations**, last 2026-07-22 |
| - [ ] `font-fira-mono-nerd-font` | font cask (9 .otf) | ? | — | — | leaf | n/a (font cask) — set as *primary* `editor.fontFamily` + `terminal.integrated.fontFamily` in both VS Code and Insiders `settings.json` |
| - [ ] `microsoft-azure-storage-explorer` | `Microsoft Azure Storage Explorer.app` | ? | — | 2025-11-09 | leaf | cold — 9mo; brew *updated* it 2026-07-31 but it has not run since 2025-11-09 |
| - [ ] `openttd` | `OpenTTD.app` | ? | — | 2026-01-31 | leaf | cold — 6mo (played once, ~2026-01-31, just after install) |
| - [ ] `brave-browser` | `Brave Browser.app` | ? | — | 2026-01-31 | leaf | cold — 6mo; bundle itself not updated since 2026-01-31 (not even auto-updating) |
| - [ ] `slack` | `Slack.app` | ? | — | 2026-02-26 | leaf | cold — 5mo |
| - [ ] `inkscape` | `Inkscape.app` | ? | — | 2026-04-10 | leaf | cold — 4mo |
| - [ ] `microsoft-teams` | `Microsoft Teams.app` | ? | — | 2026-04-24 | leaf | cold — 3mo |
| - [ ] `repo-prompt` | `Repo Prompt.app` | ? | — | 2026-04-25 | leaf | cold — 3mo |
| - [ ] `parallels` | `Parallels Desktop.app` | ? | — | 2026-04-28 | leaf | cold — 3mo; app bundle is 423 MB but `~/Parallels` holds **51 GB** of VM images (`du -sm`) |
| - [ ] `todoist-app` | `Todoist.app` | ? | — | 2026-05-25 | leaf | cool — 2mo |
| - [ ] `miro` | `Miro.app` | ? | — | 2026-06-02 | leaf | cool — 2mo |
| - [ ] `obsidian` | `Obsidian.app` | ? | 2026-07-16 (4) | 2026-07-16 | leaf | warm — 16d, 4 focus sessions in the 30d window |
| - [ ] `google-chrome` | `Google Chrome.app` | ? | 2026-07-21 (498) | 2026-07-21 | leaf | warm — 11d, 498 focus sessions (incl. 1 installed PWA) |
| - [ ] `visual-studio-code` | `Visual Studio Code.app` | ? | 2026-07-21 (51) | 2026-07-21 | leaf | warm — 11d, 51 focus sessions (Insiders is the daily driver) |
| - [ ] `claude` | `Claude.app` | 2026-07-30 (7) | 2026-07-30 (427) | 2026-07-30 | leaf | hot — 427 focus sessions |
| - [ ] `orbstack` | `OrbStack.app` | 2026-07-30 (2) | 2026-07-30 (87) | 2026-07-30 | leaf | hot — 87 focus sessions |
| - [ ] `chatgpt` | `ChatGPT.app` | 2026-07-31 (7) | 2026-07-31 (920) | 2026-07-31 | leaf | hot — 920 focus sessions (app now ships bundle id `com.openai.codex`; 3 older sessions under `com.openai.chat`) |
| - [ ] `fluidvoice` | `FluidVoice.app` | 2026-07-31 (2) | 2026-07-31 (32) | 2026-07-31 | leaf | hot — 32 focus sessions |
| - [ ] `visual-studio-code@insiders` | `Visual Studio Code - Insiders.app` | ? | 2026-07-31 (1,206) | 2026-07-31 | leaf | hot — 1,206 focus sessions |
| - [ ] `1password` | `1Password.app` | 2026-08-01 (18) | 2026-07-31 (68) | 2026-04-29 | leaf | hot — 68 focus sessions |
| - [ ] `rectangle` | `Rectangle.app` | 2026-08-01 (8) | — | 2026-07-17 | leaf | hot — background app: 8 launches today, no focus sessions by design |
| - [ ] `karabiner-elements` | `Karabiner-Elements.app` | ? | 2026-07-30 (8) | 2026-08-01 | leaf | hot — `~/.config/karabiner` written today; Settings UI has no focus sessions (driver runs headless), Karabiner-Updater ran 2026-07-30 |
| - [ ] `alfred` | `Alfred 5.app` | 2026-08-01 (7) | — | 2026-08-01 | leaf | hot — background app: 7 launches today, no focus sessions by design |
| - [ ] `microsoft-auto-update` | `Microsoft AutoUpdate.app` | ? | — | 2026-08-01 | **dep** | background agent — ran today; **installed as a dependency**, never requested |
| - [ ] `ghostty` | `Ghostty.app` | 2026-08-01 (97) | 2026-07-31 (1,414) | 2026-08-01 | leaf | hot — 1,414 focus sessions (this terminal) |

## CLI formulae

Sorted coldest first, by last shell invocation. All 26 are `brew leaves` with **zero installed
dependents**, so none of them is being retained on another formula's behalf.

| Item | Installed | Last opened (count) | Last invoked | Invocations | Leaf/dep | Signal verdict |
| --- | --- | --- | --- | --- | --- | --- |
| - [ ] `clang-format` | yes — `22.1.8` | ? | **never** | 0 | leaf (0 dependents) | **never invoked** — only mention in 9mo is `which prettier clang-format` (2025-12-21). `ms-vscode.cpptools` is installed and can drive it in-editor. |
| - [ ] `expat` | yes — `2.8.2`, **not on PATH** (`xmlwf` → `n/a`) | ? | **never** | 0 | leaf (0 dependents) | **never invoked** — 0 mentions ever. keg-only (`:provided_by_macos`, never on PATH) and **0 installed dependents**. `docs/install-inventory.md` says brew `git` needs it — that is wrong: `brew deps git` = gettext, json-c, libunistring, pcre2. |
| - [ ] `git-filter-repo` | yes — `2.47.0` | ? | **never** | 0 | leaf (0 dependents) | **never invoked** — 0 mentions of `git-filter-repo` *or* `git filter-repo` in 9mo. |
| - [ ] `lcov` | yes — `2.5` | ? | **never** | 0 | leaf (0 dependents) | **never invoked** — only mention is `brew install lcov` (2026-07-04). |
| - [ ] `ninja` | yes — `1.13.2` | ? | **never** | 0 | leaf (0 dependents) | **never invoked directly** — but consumed as a CMake generator: `cmake -B build -G Ninja` (2026-05-18). |
| - [ ] `pandoc` | yes — `3.10.1` | ? | **never** | 0 | leaf (0 dependents) | **never invoked** — only mentions are `brew search/install pandoc` (2026-06-02). |
| - [ ] `poppler` | yes — `26.07.0` | ? | **never** | 0 | leaf (0 dependents) | **never invoked** — 0 mentions of `poppler` or any of its 13 `pdf*` tools ever. |
| - [ ] `pytest` | yes — `9.1.1` | ? | **never** | 0 | leaf (0 dependents) | **brew build never invoked** — the one real run was `.venv/bin/python -m pytest` (2026-02-21). `mise.toml` sets `settings.python.uv_venv_auto`, so project venvs supply pytest. |
| - [ ] `ruff` | yes — `0.16.1` | ? | **never** | 0 | leaf (0 dependents) | **never invoked** — 0 mentions ever, and no ruff extension among the 107 in `packages/vscode.txt`. |
| - [ ] `wget` | yes — `1.25.0` | ? | **never** | 0 | leaf (0 dependents) | **never invoked** — 0 mentions ever on macOS (it is used in the *Linux* VS Code hook only). |
| - [ ] `caddy` | yes — `2.11.4` | ? | 2025-11-06 | 9 | leaf (0 dependents) | cold — 9 invocations, none since 2025-11-06. |
| - [ ] `pipx` | yes — `1.16.5` | ? | 2025-12-30 | 4 | leaf (0 dependents) | cold — 4 invocations, none since 2025-12-30. Pulls `python@3.14`. |
| - [ ] `platformio` | yes — `6.1.19_2` | ? | 2025-12-31 | 169 | leaf (0 dependents) | cold — 169 invocations (`pio`×163) but none since 2025-12-31. `platformio.platformio-ide` is in `packages/vscode.txt`. Pulls `python@3.14`. |
| - [ ] `mosquitto` | yes — `2.1.2_1` | ? | 2026-03-04 | 9 | leaf (0 dependents) | cold — 9 invocations (`mosquitto_sub`×5, `mosquitto_pub`×4), none since 2026-03-04. |
| - [ ] `rustup` | yes — `1.29.0_2` | ? | 2026-03-22 | 2 | leaf (0 dependents) | cold — 2 invocations (`cargo`×1, `rustc`×1), none since 2026-03-22. |
| - [ ] `cmake` | yes — `4.4.2` | ? | 2026-05-18 | 3 | leaf (0 dependents) | cool — 3 invocations, last 2026-05-18. |
| - [ ] `btop` | yes — `1.4.7` | ? | 2026-05-23 | 1 | leaf (0 dependents) | cool — 1 invocation, last 2026-05-23. |
| - [ ] `avrdude` | yes — `8.2` | ? | 2026-06-13 | 1 | leaf (0 dependents) | cool — 1 invocation, last 2026-06-13. |
| - [ ] `curl` | yes — `8.21.0`, **not on PATH** (`curl` → `/usr/bin/curl`) | ? | 2026-06-30 *(system curl)* | 117 *(all system)* | leaf (0 dependents) | **brew build never used** — keg-only, so `curl` resolves to `/usr/bin/curl`. All 117 invocations hit Apple's. |
| - [ ] `htop` | yes — `3.5.2` | ? | 2026-07-12 | 1 | leaf (0 dependents) | warm — 1 invocation, last 2026-07-12. |
| - [ ] `tree` | yes — `2.3.2` | ? | 2026-07-26 | 13 | leaf (0 dependents) | warm — 13 invocations, last 2026-07-26. |
| - [ ] `azure-cli` | yes — `2.88.0` | ? | 2026-07-27 | 347 | leaf (0 dependents) | hot — 347 `az` invocations. Pulls `python@3.14`. |
| - [ ] `tmux` | yes — `3.7b` | ? | 2026-07-27 | 41 | leaf (0 dependents) | hot — 41 invocations. |
| - [ ] `zsh` | yes — `5.9.2` | ? | 2026-07-31 | 2 | leaf (0 dependents) | brew build barely used — 2 direct invocations. Login shell is **`/bin/zsh`** (Apple's) per `[bootstrap.user].login_shell`, though `zsh` on PATH resolves to brew's. |
| - [ ] `herdr` | yes — `0.7.5` | ? | 2026-08-01 | 16 | leaf (0 dependents) | hot — 16 invocations, last today. |
| - [ ] `git` | yes — `2.55.0` | ? | 2026-08-01 | 1,589 | leaf (0 dependents) | hot — 1,589 invocations, last today. |

## Not installed but declared

**None.** All 24 casks declared in `[bootstrap.packages]`, all 26 declared formulae, and
`microsoft-teams` from `[tasks."setup:macos"]` are present on disk. There is no drift in this
direction.

## Installed but not declared

### Casks (1)

| Item | Installed | Why it is here |
| --- | --- | --- |
| - [ ] `microsoft-auto-update` | 2025-09-29, `Microsoft AutoUpdate.app` | `INSTALL_RECEIPT.json` says `installed_as_dependency: true`, `installed_on_request: false`. Matches the comment in `mise.macos.toml` — the Microsoft apps pull it in themselves. Note no cask in the tap actually declares `depends_on.cask`, so if every Microsoft app goes, `brew autoremove` will not take this with them. |

### Formulae (12 undeclared leaves, of 114 installed)

`brew list --formula` reports 114 formulae; 76 are pure dependencies and
38 are leaves. 26 of those leaves are declared here, leaving 12 that
arrived by hand:

| Item | Also declared as | `command -v` resolves to | Signal verdict |
| --- | --- | --- | --- |
| - [ ] `fzf` | `[tools]` in `mise.toml` | `/opt/homebrew/bin/fzf` | **duplicate install** — mise declares it cross-platform, but the Homebrew copy wins on PATH |
| - [ ] `jq` | `[tools]` in `mise.toml` | `/opt/homebrew/bin/jq` | **duplicate install** — mise declares it cross-platform, but the Homebrew copy wins on PATH |
| - [ ] `just` | `[tools]` in `mise.toml` | `/opt/homebrew/bin/just` | **duplicate install** — mise declares it cross-platform, but the Homebrew copy wins on PATH |
| - [ ] `lazygit` | `[tools]` in `mise.toml` | `/opt/homebrew/bin/lazygit` | **duplicate install** — mise declares it cross-platform, but the Homebrew copy wins on PATH |
| - [ ] `neovim` | `[tools]` in `mise.toml` (as `nvim`) | `/opt/homebrew/bin/nvim` | **duplicate install** — mise declares it cross-platform, but the Homebrew copy wins on PATH |
| - [ ] `starship` | `[tools]` in `mise.toml` | `/opt/homebrew/bin/starship` | **duplicate install** — mise declares it cross-platform, but the Homebrew copy wins on PATH |
| - [ ] `terraform` | `[tools]` in `mise.toml` | `/opt/homebrew/bin/terraform` | **duplicate install** — mise declares it cross-platform, but the Homebrew copy wins on PATH |
| - [ ] `uv` | `[tools]` in `mise.toml` | `/opt/homebrew/bin/uv` | **duplicate install** — mise declares it cross-platform, but the Homebrew copy wins on PATH |
| - [ ] `zoxide` | `[tools]` in `mise.toml` | `/opt/homebrew/bin/zoxide` | **duplicate install** — mise declares it cross-platform, but the Homebrew copy wins on PATH |
| - [ ] `gh` | `[tools]` in `mise.toml` | `/Users/jonny/.local/share/mise/installs/gh/2.97.0/gh_2.97.0_macOS_arm64/bin/gh` | duplicate install — here the **mise shim wins**, so the brew copy is dead weight |
| - [ ] `stow` | not declared anywhere | `/opt/homebrew/bin/stow` | leftover from the pre-mise GNU Stow bootstrap; `README.md`/`mise.toml` reference it only as history |
| - [ ] `mise` | n/a — bootstraps the repo | shell function from `.zshrc` → `/opt/homebrew/bin/mise` | intentional: mise installs everything else, so it cannot declare itself |

## Appendix — install / update dates

Bundle mtime and cask receipt date. **Install/update time, not use time** — an app that
auto-updates is being maintained by its updater, which says nothing about whether you open it.

| Cask | Cask installed | Bundle mtime |
| --- | --- | --- |
| `codex` | 2026-07-29 | 2026-07-29 |
| `font-fira-mono-nerd-font` | 2025-09-23 | 2025-09-23 |
| `microsoft-azure-storage-explorer` | 2026-07-31 | 2026-07-31 |
| `openttd` | 2026-01-29 | 2026-04-05 |
| `brave-browser` | 2025-09-23 | 2026-01-31 |
| `slack` | 2026-07-21 | 2026-07-21 |
| `inkscape` | 2025-11-29 | 2026-05-07 |
| `microsoft-teams` | 2025-09-29 | 2026-07-29 |
| `repo-prompt` | 2025-10-03 | 2026-06-20 |
| `parallels` | 2026-04-28 | 2026-06-23 |
| `todoist-app` | 2026-02-14 | 2026-07-07 |
| `miro` | 2026-07-25 | 2026-07-25 |
| `obsidian` | 2025-10-04 | 2026-06-12 |
| `google-chrome` | 2026-07-30 | 2026-07-30 |
| `visual-studio-code` | 2026-07-29 | 2026-07-29 |
| `claude` | 2026-07-25 | 2026-07-25 |
| `orbstack` | 2025-12-26 | 2026-06-12 |
| `chatgpt` | 2026-08-01 | 2026-08-01 |
| `fluidvoice` | 2026-07-22 | 2026-07-05 |
| `visual-studio-code@insiders` | 2026-07-29 | 2026-07-24 |
| `1password` | 2025-09-23 | 2026-07-29 |
| `rectangle` | 2026-07-17 | 2026-07-17 |
| `karabiner-elements` | 2025-09-23 | 2026-07-05 |
| `alfred` | 2025-09-23 | 2026-04-01 |
| `microsoft-auto-update` | 2025-09-29 | 2026-07-15 |
| `ghostty` | 2025-09-23 | 2026-03-14 |

| Formula | Version | Installed |
| --- | --- | --- |
| `clang-format` | `22.1.8` | 2026-07-02 |
| `expat` | `2.8.2` | 2026-06-27 |
| `git-filter-repo` | `2.47.0` | 2025-10-29 |
| `lcov` | `2.5` | 2026-07-08 |
| `ninja` | `1.13.2` | 2026-05-18 |
| `pandoc` | `3.10.1` | 2026-07-25 |
| `poppler` | `26.07.0` | 2026-07-07 |
| `pytest` | `9.1.1` | 2026-06-24 |
| `ruff` | `0.16.1` | 2026-07-31 |
| `wget` | `1.25.0` | 2025-09-23 |
| `caddy` | `2.11.4` | 2026-06-04 |
| `pipx` | `1.16.5` | 2026-07-31 |
| `platformio` | `6.1.19_2` | 2026-05-15 |
| `mosquitto` | `2.1.2_1` | 2026-07-28 |
| `rustup` | `1.29.0_2` | 2026-06-07 |
| `cmake` | `4.4.2` | 2026-08-01 |
| `btop` | `1.4.7` | 2026-05-22 |
| `avrdude` | `8.2` | 2026-07-13 |
| `curl` | `8.21.0` | 2026-06-27 |
| `htop` | `3.5.2` | 2026-07-19 |
| `tree` | `2.3.2` | 2026-03-23 |
| `azure-cli` | `2.88.0` | 2026-07-08 |
| `tmux` | `3.7b` | 2026-07-07 |
| `zsh` | `5.9.2` | 2026-07-13 |
| `herdr` | `0.7.5` | 2026-07-22 |
| `git` | `2.55.0` | 2026-07-07 |
