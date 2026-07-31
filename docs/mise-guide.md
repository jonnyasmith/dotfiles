# mise-en-place — Comprehensive Feature Research

`Research notes on the mise CLI (https://mise.jdx.dev), compiled from the official documentation` · 31 Jul 2026

## Question

What features does `mise` (mise-en-place) provide, and how does each one work? Scope: the complete
official documentation set at <https://mise.jdx.dev> — Getting Started, Configuration, Dev Tools,
Backends, Bootstrap, Environments, Tasks, Plugins, Language runtimes, and the CLI reference.

## Answer

`mise` is a single Rust CLI that replaces asdf/nvm/pyenv (dev tools), direnv (env vars), and
make/npm-scripts (tasks), driven by one `mise.toml` per project ([about](https://mise.jdx.dev/about.html)).
It resolves tools from ~18 pluggable *backends* (aqua, ubi, github, cargo, npm, pipx, go, http, …) via a
curated registry of 1000+ short names, injects them either through a shell hook (`mise activate`) or
through shims, and layers project/global/system config files with a documented precedence order
([dev-tools](https://mise.jdx.dev/dev-tools/), [configuration](https://mise.jdx.dev/configuration.html)).
Beyond tools it ships env-var loading with sops/age secrets, a dependency-graph task runner with
usage-spec argument parsing and source/output fingerprinting, machine provisioning (`mise bootstrap`
for dotfiles, packages, repos, launchd/systemd, macOS defaults), a lockfile with per-platform
checksums, OCI distribution, an MCP server, and four kinds of plugin API
([environments](https://mise.jdx.dev/environments/), [tasks](https://mise.jdx.dev/tasks/),
[bootstrap](https://mise.jdx.dev/bootstrap.html), [plugins](https://mise.jdx.dev/plugins.html)).

**How to read this document.** Each numbered section below is a self-contained reference for one
feature area. Every non-obvious claim carries an inline link to the exact documentation page it came
from. Facts that are version-sensitive, experimental, or deprecated are marked as such; places where
the docs are silent or self-contradictory are called out in `> **Uncertainty:**` blockquotes rather
than guessed at.

**Version.** All content reflects the docs as published for mise **2026.7.x**, accessed **31 Jul 2026**.
mise ships a new release most weeks, so re-check version-sensitive claims against
<https://mise.jdx.dev> before relying on them.

## Contents

- [1. Overview, Installation & Core Concepts](#1-overview-installation--core-concepts)
  - [1.1 What mise is](#11-what-mise-is)
  - [1.2 What mise replaces](#12-what-mise-replaces)
  - [1.3 Installation](#13-installation)
  - [1.4 Shell activation](#14-shell-activation)
  - [1.5 Activation vs. shims](#15-activation-vs-shims)
  - [1.6 Directory layout](#16-directory-layout)
  - [1.7 Cache behavior](#17-cache-behavior)
  - [1.8 Glossary of mise terminology](#18-glossary-of-mise-terminology)
  - [1.9 Quickstart walkthrough](#19-quickstart-walkthrough)
  - [1.10 `mise doctor`](#110-mise-doctor)
  - [1.11 Debugging switches](#111-debugging-switches)
  - [1.12 Common errors](#112-common-errors)
  - [1.13 Troubleshooting by symptom](#113-troubleshooting-by-symptom)
  - [1.14 Semantics worth internalizing](#114-semantics-worth-internalizing)
- [2. Configuration](#2-configuration)
  - [2.1 Config file discovery and precedence](#21-config-file-discovery-and-precedence)
  - [2.2 Config environments (`MISE_ENV`)](#22-config-environments-mise_env)
  - [2.3 Top-level tables in `mise.toml`](#23-top-level-tables-in-misetoml)
  - [2.4 `.tool-versions` and idiomatic version files](#24-tool-versions-and-idiomatic-version-files)
  - [2.5 Setting settings: CLI, env, and config](#25-setting-settings-cli-env-and-config)
  - [2.6 Settings reference](#26-settings-reference)
  - [2.7 Trust model](#27-trust-model)
  - [2.8 Paranoid mode](#28-paranoid-mode)
  - [2.9 Safe mode](#29-safe-mode)
  - [2.10 Sandboxing](#210-sandboxing)
  - [2.11 URL replacements and corporate mirrors](#211-url-replacements-and-corporate-mirrors)
  - [2.12 Creating, formatting, and inspecting config](#212-creating-formatting-and-inspecting-config)
- [3. Dev Tools](#3-dev-tools)
  - [3.1 How tool resolution works](#31-how-tool-resolution-works)
  - [3.2 The `[tools]` table](#32-the-tools-table)
  - [3.3 Version specifiers, scopes, and fuzzy matching](#33-version-specifiers-scopes-and-fuzzy-matching)
  - [3.4 Requesting, installing, and upgrading](#34-requesting-installing-and-upgrading)
  - [3.5 Lockfile: `mise.lock`](#35-lockfile-miselock)
  - [3.6 Tool stubs](#36-tool-stubs)
  - [3.7 OCI distribution — `mise oci` **(experimental)**](#37-oci-distribution--mise-oci-experimental)
  - [3.8 Tool aliases](#38-tool-aliases)
  - [3.9 Project dependencies — `mise deps` **(experimental)**](#39-project-dependencies--mise-deps-experimental)
  - [3.10 Core tools](#310-core-tools)
  - [3.11 Backend selection (summary)](#311-backend-selection-summary)
  - [3.12 GitHub tokens and rate limits](#312-github-tokens-and-rate-limits)
  - [3.13 Shims vs PATH activation](#313-shims-vs-path-activation)
  - [3.14 Comparison to asdf](#314-comparison-to-asdf)
  - [3.15 Tool-related settings reference](#315-tool-related-settings-reference)
  - [3.16 CLI quick reference](#316-cli-quick-reference)
- [4. Backends & the Registry](#4-backends--the-registry)
  - [4.1 What a backend is](#41-what-a-backend-is)
  - [4.2 Backend priority & default resolution order](#42-backend-priority--default-resolution-order)
  - [4.3 The registry: short names → backend URLs](#43-the-registry-short-names--backend-urls)
  - [4.4 Backend comparison table](#44-backend-comparison-table)
  - [4.5 `aqua`](#45-aqua)
  - [4.6 `asdf`](#46-asdf)
  - [4.7 `cargo`](#47-cargo)
  - [4.8 `conda`](#48-conda)
  - [4.9 `dotnet`](#49-dotnet)
  - [4.10 `forgejo`](#410-forgejo)
  - [4.11 `gem`](#411-gem)
  - [4.12 `github`](#412-github)
  - [4.13 `gitlab`](#413-gitlab)
  - [4.14 `go`](#414-go)
  - [4.15 `http`](#415-http)
  - [4.16 `npm`](#416-npm)
  - [4.17 `pipx`](#417-pipx)
  - [4.18 `pkgx` (experimental)](#418-pkgx-experimental)
  - [4.19 `s3`](#419-s3)
  - [4.20 `spm`](#420-spm)
  - [4.21 `ubi` (deprecated)](#421-ubi-deprecated)
  - [4.22 `vfox`](#422-vfox)
  - [4.23 Custom backends (backend plugins)](#423-custom-backends-backend-plugins)
  - [4.24 Options that work across every backend](#424-options-that-work-across-every-backend)
- [5. Bootstrap (machine & dotfiles provisioning)](#5-bootstrap-machine--dotfiles-provisioning)
  - [5.1 Is it experimental?](#51-is-it-experimental)
  - [5.2 Config surface](#52-config-surface)
  - [5.3 The bootstrap lifecycle](#53-the-bootstrap-lifecycle)
  - [5.4 User config (`[bootstrap.user]`)](#54-user-config-bootstrapuser)
  - [5.5 Dotfiles (`[dotfiles]`)](#55-dotfiles-dotfiles)
  - [5.6 Packages (`[bootstrap.packages]`)](#56-packages-bootstrappackages)
  - [5.7 Git repos (`[bootstrap.repos]`)](#57-git-repos-bootstraprepos)
  - [5.8 Shell activation (`[bootstrap.mise_shell_activate]`)](#58-shell-activation-bootstrapmise_shell_activate)
  - [5.9 macOS defaults (`[bootstrap.macos.*]`)](#59-macos-defaults-bootstrapmacos)
  - [5.10 launchd agents (`[bootstrap.macos.launchd.agents]`)](#510-launchd-agents-bootstrapmacoslaunchdagents)
  - [5.11 systemd user units (`[bootstrap.linux.systemd.units]`)](#511-systemd-user-units-bootstraplinuxsystemdunits)
  - [5.12 Common workflows](#512-common-workflows)
  - [5.13 `mise generate bootstrap` (unrelated to `mise bootstrap`)](#513-mise-generate-bootstrap-unrelated-to-mise-bootstrap)
  - [5.14 CLI reference table](#514-cli-reference-table)
- [6. Environments, Env Vars, Secrets & Hooks](#6-environments-env-vars-secrets--hooks)
  - [6.1 The `[env]` table](#61-the-env-table)
  - [6.2 `env._` directives](#62-env_-directives)
  - [6.3 Templating and shell-style expansion in env values](#63-templating-and-shell-style-expansion-in-env-values)
  - [6.4 `config_root` and relative paths](#64-config_root-and-relative-paths)
  - [6.5 Precedence and ordering](#65-precedence-and-ordering)
  - [6.6 Config environments (`MISE_ENV`)](#66-config-environments-mise_env)
  - [6.7 Where the environment shows up](#67-where-the-environment-shows-up)
  - [6.8 CLI: `mise env`, `mise set`, `mise unset`, `mise en`](#68-cli-mise-env-mise-set-mise-unset-mise-en)
  - [6.9 Redactions](#69-redactions)
  - [6.10 Secrets](#610-secrets)
  - [6.11 direnv interop](#611-direnv-interop)
  - [6.12 Hooks](#612-hooks)
  - [6.13 Shell aliases](#613-shell-aliases)
  - [6.14 File watching](#614-file-watching)
  - [6.15 Quick gotcha index](#615-quick-gotcha-index)
- [7. Tasks](#7-tasks)
  - [7.1 Environment variables mise passes into every task](#71-environment-variables-mise-passes-into-every-task)
  - [7.2 TOML tasks — complete key reference](#72-toml-tasks--complete-key-reference)
  - [7.3 Sources, outputs, and freshness checking](#73-sources-outputs-and-freshness-checking)
  - [7.4 File tasks](#74-file-tasks)
  - [7.5 Task arguments (usage spec)](#75-task-arguments-usage-spec)
  - [7.6 Tera templates available inside tasks](#76-tera-templates-available-inside-tasks)
  - [7.7 Running tasks](#77-running-tasks)
  - [7.8 `[task_config]` — config-scope task options](#78-task_config--config-scope-task-options)
  - [7.9 Task templates (`[task_templates]` + `extends`)](#79-task-templates-task_templates--extends)
  - [7.10 Monorepo tasks](#710-monorepo-tasks)
  - [7.11 Architecture and internals](#711-architecture-and-internals)
  - [7.12 Task CLI reference](#712-task-cli-reference)
  - [7.13 Generating task docs and stubs](#713-generating-task-docs-and-stubs)
  - [7.14 Watching — `mise watch` / `mise w`](#714-watching--mise-watch--mise-w)
  - [7.15 Quick precedence summary](#715-quick-precedence-summary)
- [8. Plugins](#8-plugins)
  - [8.1 Do you actually need a plugin?](#81-do-you-actually-need-a-plugin)
  - [8.2 The five plugin kinds](#82-the-five-plugin-kinds)
  - [8.3 Installing, linking, updating, removing](#83-installing-linking-updating-removing)
  - [8.4 The `[plugins]` config table and shorthand registry](#84-the-plugins-config-table-and-shorthand-registry)
  - [8.5 Tool options passed to plugins](#85-tool-options-passed-to-plugins)
  - [8.6 Security implications and `paranoid`](#86-security-implications-and-paranoid)
  - [8.7 Tool Plugin Development](#87-tool-plugin-development)
  - [8.8 Backend Plugin Development](#88-backend-plugin-development)
  - [8.9 Environment Plugin Development](#89-environment-plugin-development)
  - [8.10 Package Plugin Development](#810-package-plugin-development)
  - [8.11 asdf (Legacy) Shell Plugins](#811-asdf-legacy-shell-plugins)
  - [8.12 Lua modules (plugin stdlib)](#812-lua-modules-plugin-stdlib)
  - [8.13 Testing plugins locally](#813-testing-plugins-locally)
  - [8.14 Publishing a plugin](#814-publishing-a-plugin)
  - [8.15 Templates and starting points](#815-templates-and-starting-points)
- [9. Integration: CI, IDEs, Containers & Tooling](#9-integration-ci-ides-containers--tooling)
  - [9.1 The core problem: non-interactive environments](#91-the-core-problem-non-interactive-environments)
  - [9.2 Continuous integration](#92-continuous-integration)
  - [9.3 Docker & devcontainers](#93-docker--devcontainers)
  - [9.4 IDE integration](#94-ide-integration)
  - [9.5 MCP server (`mise mcp`)](#95-mcp-server-mise-mcp)
  - [9.6 Shell completions](#96-shell-completions)
  - [9.7 Generators (`mise generate …`)](#97-generators-mise-generate)
  - [9.8 Housekeeping commands](#98-housekeeping-commands)
  - [9.9 Tips & tricks worth knowing](#99-tips--tricks-worth-knowing)
  - [9.10 External resources](#910-external-resources)
  - [9.11 Global flags (apply to every command)](#911-global-flags-apply-to-every-command)
  - [Full CLI index](#full-cli-index)
- [10. Language Runtimes & Cookbook](#10-language-runtimes--cookbook)
  - [10.0 Cross-cutting concepts](#100-cross-cutting-concepts)
  - [10.1 Node.js](#101-nodejs)
  - [10.2 Python](#102-python)
  - [10.3 Ruby](#103-ruby)
  - [10.4 Go](#104-go)
  - [10.5 Rust](#105-rust)
  - [10.6 Java](#106-java)
  - [10.7 Deno](#107-deno)
  - [10.8 Bun](#108-bun)
  - [10.9 Erlang & Elixir (paired)](#109-erlang--elixir-paired)
  - [10.10 Swift](#1010-swift)
  - [10.11 Zig](#1011-zig)
  - [10.12 .NET](#1012-net)
  - [10.13 Cookbook — C++](#1013-cookbook--c)
  - [10.14 Cookbook — Node.js](#1014-cookbook--nodejs)
  - [10.15 Cookbook — Python](#1015-cookbook--python)
  - [10.16 Cookbook — Ruby](#1016-cookbook--ruby)
  - [10.17 Cookbook — Terraform / OpenTofu](#1017-cookbook--terraform--opentofu)
  - [10.18 Cookbook — Docker](#1018-cookbook--docker)
  - [10.19 Cookbook — Neovim](#1019-cookbook--neovim)
  - [10.20 Cookbook — Presets (project scaffolding)](#1020-cookbook--presets-project-scaffolding)
  - [10.21 Cookbook — Shell tricks](#1021-cookbook--shell-tricks)
  - [10.22 Cookbook index & contributing](#1022-cookbook-index--contributing)

---

## Findings

## 1. Overview, Installation & Core Concepts

### 1.1 What mise is

`mise` (pronounced "meez", short for *mise-en-place*) is a Rust-based development environment setup tool. The name is a French culinary phrase meaning roughly "setup" / "put in place": before you cook, every utensil and ingredient is already in its place ([about](https://mise.jdx.dev/about.html), [glossary](https://mise.jdx.dev/glossary.html)).

Its functionality is grouped into exactly three categories ([about](https://mise.jdx.dev/about.html), [architecture](https://mise.jdx.dev/architecture.html)):

| Pillar | What it does | Entry point |
| --- | --- | --- |
| **Dev tools** | Installs and manages versions of runtimes/CLIs (node, python, terraform, jq, …), switching automatically per directory | `mise use`, `mise install`, `[tools]` ([dev-tools](https://mise.jdx.dev/dev-tools/index.html)) |
| **Environments** | Per-project environment variables, `.env` files, PATH additions, Python virtualenv auto-activation | `mise set`, `[env]` ([about](https://mise.jdx.dev/about.html)) |
| **Tasks** | Project task runner with a parallel DAG, file-watching, and script or TOML task definitions | `mise run`, `[tasks]` ([tasks](https://mise.jdx.dev/tasks/index.html)) |

All three live in a single `mise.toml` checked into the repo, so every machine gets the same setup ([home](https://mise.jdx.dev/)):

```toml
# mise.toml
[tools]
node = "24"
python = "3.13"

[env]
_.file = ".env.local"

[tasks.test]
run = "pytest"
```

Architecturally, mise is a modular Rust program: a clap-based CLI layer (`src/cli/`), a trait-based **backend** system (`src/backend/`), a hierarchical **config** system (`src/config/`), **toolset** resolution (`src/toolset/`), a `petgraph`-backed **task** DAG (`src/task/`), a **plugin** layer (`src/plugins/`), **shell** code generation (`src/shell/`), and a msgpack+zstd file **cache** (`src/cache.rs`) ([architecture](https://mise.jdx.dev/architecture.html)).

The tool-resolution pipeline on every directory entry / command is: configuration discovery (walk up the tree, merge hierarchically) → version resolution (`latest`, `prefix:1.2`, `sub-1:latest` → concrete) → backend selection → dependency analysis (e.g. npm requires node) → installation coordination → environment/PATH configuration ([architecture](https://mise.jdx.dev/architecture.html), [dev-tools](https://mise.jdx.dev/dev-tools/index.html)).

Versioning is [Calver](https://calver.org/) (`YYYY.MM.RELEASE`, e.g. `2026.7.0`). There are no SemVer-major releases; new/behaviour-changing functionality is opted into with settings such as `experimental = true` rather than gated behind a major bump ([faq](https://mise.jdx.dev/faq.html#how-does-mise-versioning-work)).

### 1.2 What mise replaces

| Replaces | How | Caveats |
| --- | --- | --- |
| **asdf** | Drop-in replacement: reads the same `.tool-versions` files and can use asdf plugins via the `asdf` backend. `mise use node@20` replaces the three-step `asdf plugin add` / `asdf install` / `asdf local`. Fuzzy versions work *everywhere*, not just on the CLI. | Does **not** reuse existing `~/.asdf` directories — reinstall or move them. 100% compatibility is explicitly not a design goal, and asdf-go (≥0.16) compatibility is worse than asdf-bash (≤0.15) since `asdf set` collides with the pre-existing, unrelated `mise set`. ([comparison-to-asdf](https://mise.jdx.dev/dev-tools/comparison-to-asdf.html), [faq](https://mise.jdx.dev/faq.html#how-compatible-is-mise-with-asdf)) |
| **nvm / rbenv / pyenv** and other single-language version managers | One tool for all languages; core tools (node, python, ruby, go, java, …) are native Rust implementations shipped in the binary ([glossary](https://mise.jdx.dev/glossary.html)). `mise activate` puts real install paths on `PATH`, so `which node` returns `~/.local/share/mise/installs/node/lts/bin/node`, not a shim ([demo](https://mise.jdx.dev/demo.html)). | — |
| **direnv** | mise manages env vars and Python virtualenv activation from `mise.toml`, which covers most direnv use-cases. | **The official stance is: do not use direnv with mise.** Incompatibilities are not treated as bugs and direnv-compat PRs are not accepted. They can coexist for unrelated env vars; anything touching `PATH` conflicts. `use mise` in `.envrc` is **deprecated and no longer supported**. ([direnv](https://mise.jdx.dev/direnv.html)) |
| **make** (as a task runner) | `[tasks]` in `mise.toml` or executable scripts in `mise-tasks/`, with parallel dependency building by default, last-modified change detection (`sources`/`outputs`), `mise watch`, and real bash files instead of strings inside YAML/JSON/TOML ([tasks](https://mise.jdx.dev/tasks/index.html)). | — |
| **Nix**, informally | The project's own framing: "Nix for people who have actual work to do now" — no flakes required, laptop and CI interoperable ([mise-en-place: The Song](https://mise.jdx.dev/mise-en-place.html)). | Not a real Nix replacement; see the explicit non-goals below. |

**Explicit non-goals.** mise manages *development tool versions* and CLI utilities. It is **not** a replacement for `apt`/`brew`/`pacman`. It does not install system libraries (libssl, zlib), manage desktop applications, or handle system-level compile dependencies — install those with your OS package manager first ([faq](https://mise.jdx.dev/faq.html#mise-is-for-dev-tools-not-applications-or-system-packages)).

**Performance vs. asdf.** asdf's shim design adds ~120 ms to every runtime call. `mise activate` adds no per-call overhead because it edits `PATH` directly; the cost is `mise hook-env` on prompt display — ~10 ms typical, ~4 ms when nothing changed, ~14 ms on a full reload. Against asdf-go the gap is much smaller, and the docs argue security/DX/no-shims matter more than raw speed ([comparison-to-asdf](https://mise.jdx.dev/dev-tools/comparison-to-asdf.html)).

**Supply-chain posture.** asdf plugins are arbitrary shell code usually not written by the tool vendor. mise reduces reliance on them by preferring `aqua` and `github` backends, and implements native Cosign / SLSA / Minisign / GitHub-attestation verification for aqua tools, plus gpg verification on node installs ([comparison-to-asdf](https://mise.jdx.dev/dev-tools/comparison-to-asdf.html)).

---

### 1.3 Installation

#### 1.3.1 Recommended method per platform

| Platform | Recommended | Alternative |
| --- | --- | --- |
| macOS | Homebrew | mise.run |
| Linux (Debian/Ubuntu) | apt | mise.run |
| Linux (Fedora/RHEL) | dnf | mise.run |
| Linux (Arch) | pacman | mise.run |
| Linux (Alpine) | apk | mise.run |
| Windows | Scoop | winget |
| Any (Rust users) | `cargo binstall` | `cargo install` |
| CI/Docker | mise.run | GitHub Releases |

([installing-mise](https://mise.jdx.dev/installing-mise.html))

Package managers (apt, dnf, brew, pacman, …) update mise with the rest of your system packages; every other method updates via `mise self-update` ([installing-mise](https://mise.jdx.dev/installing-mise.html)).

> **Version policy:** mise talks to many external registries (aqua, GitHub releases, language registries, system package managers) that change over time, so it works best on a recent version. Projects that need a newer feature should set [`min_version`](https://mise.jdx.dev/configuration.html#minimum-mise-version) rather than pinning every user to one mise executable. Pinning mise back is "like preventing `apt update` from refreshing package metadata": it hides deprecations and causes bit rot with upstream integrations like aqua-registry ([installing-mise](https://mise.jdx.dev/installing-mise.html)).

#### 1.3.2 `https://mise.run` (the curl installer)

```sh
curl https://mise.run | sh
```

```sh
# with options
curl https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh
```

Default install path is `~/.local/bin/mise`. It is **not** necessary for `mise` to be on `PATH` — if you run the activate script in your shell rc file, mise adds itself to `PATH` ([installing-mise](https://mise.jdx.dev/installing-mise.html), [getting-started](https://mise.jdx.dev/getting-started.html)).

**Installer environment variables:**

| Variable | Meaning |
| --- | --- |
| `MISE_DEBUG=1` | Enable debug logging |
| `MISE_QUIET=1` | Disable non-error output |
| `MISE_INSTALL_PATH=/some/path` | Change the binary path (default `~/.local/bin/mise`) |
| `MISE_VERSION=v2025.12.0` | Install a specific version |
| `MISE_INSTALL_SKIP_IF_EXISTS=1` | Skip download/install if the binary at the install path already matches the requested version |

([installing-mise](https://mise.jdx.dev/installing-mise.html))

**Shell-specific install + activation endpoints** install mise *and* append the activation line to the right rc file, detecting the shell config, skipping if activation is already present (safe to re-run) ([installing-mise](https://mise.jdx.dev/installing-mise.html)):

```sh
curl https://mise.run/zsh | sh   # installs mise and adds activation to ~/.zshrc
curl https://mise.run/bash | sh  # installs mise and adds activation to ~/.bashrc
curl https://mise.run/fish | sh  # installs mise and adds activation to ~/.config/fish/config.fish
```

**Verifying the installer signature:**

```sh
gpg --keyserver hkps://keys.openpgp.org --recv-keys 24853EC9F655CE80B48E6C3A8B81C9D17413A06D
curl https://mise.jdx.dev/install.sh.sig | gpg --decrypt > install.sh
# ensure the above is signed with the mise release key
sh ./install.sh
```

> **Tip from the docs:** as long as you don't override `MISE_VERSION`, the install script is pinned to whatever the latest version was when it was downloaded, with checksums baked into the file. Vendoring `install.sh` into a project is therefore a good way to guarantee everyone fetches the exact same mise binary ([installing-mise](https://mise.jdx.dev/installing-mise.html)).

**Supported os/arch for the installer:** `macos-x64`, `macos-arm64`, `linux-x64`, `linux-x64-musl`, `linux-arm64`, `linux-arm64-musl`, `linux-armv6`, `linux-armv6-musl`, `linux-armv7`, `linux-armv7-musl`. Anything else must be compiled with `cargo install mise` ([installing-mise](https://mise.jdx.dev/installing-mise.html)).

#### 1.3.3 Every documented package-manager method

| Method | Command(s) | Notes |
| --- | --- | --- |
| Homebrew | `brew install mise` | [formula](https://formulae.brew.sh/formula/mise). Homebrew (and possibly other installs) auto-activate fish — see `MISE_FISH_AUTO_ACTIVATE=1` |
| apk (Alpine) | `apk add mise` | lives in the Alpine *community* repository |
| apt — Ubuntu 26.04+ | `sudo add-apt-repository -y ppa:jdxcode/mise`<br>`sudo apt update`<br>`sudo apt install -y mise` | PPA |
| apt — Debian 11+ / Ubuntu 22.04+ | `sudo apt install -y extrepo`<br>`sudo extrepo enable mise`<br>`sudo apt update`<br>`sudo apt install -y mise` | via extrepo |
| pacman (Arch) | `sudo pacman -S mise` | [extra/mise](https://archlinux.org/packages/extra/x86_64/mise/) |
| dnf — Fedora 41+, CentOS Stream 9+, RHEL 10+ | `dnf copr enable jdxcode/mise`<br>`dnf install mise` | [COPR](https://copr.fedorainfracloud.org/coprs/jdxcode/mise/) |
| dnf — RHEL 9 / AlmaLinux 9 / Rocky 9 | `dnf copr enable jdxcode/mise centos-stream+epel-next-9`<br>`dnf install mise` | RHEL 9 AppStream is frozen at Rust 1.88, older than mise's MSRV; the CentOS Stream 9 build works on RHEL 9 derivatives |
| yum — RHEL 8, CentOS Stream 8, Amazon Linux 2 | `yum install -y yum-utils`<br>`yum-config-manager --add-repo https://mise.jdx.dev/rpm/mise.repo`<br>`yum install -y mise` | |
| zypper | `sudo wget https://mise.jdx.dev/rpm/mise.repo -O /etc/zypp/repos.d/mise.repo`<br>`sudo zypper refresh`<br>`sudo zypper install mise` | |
| Snap | `sudo snap install mise --classic` | [snapcraft.io/mise](https://snapcraft.io/mise) |
| MacPorts | `sudo port install mise` | [port](https://ports.macports.org/port/mise/) |
| nix | `nix-env -iA mise` | nixpkgs 24.05+. Also importable as `mise-flake.packages.${system}.mise`. NixOS compiles from source by default — for precompiled binaries enable [nix-ld](https://github.com/Mic92/nix-ld) and disable [`all_compile`](https://mise.jdx.dev/configuration/settings.html#all_compile) |
| Windows — Scoop | `scoop install mise` | **Recommended on Windows**; automatically adds shims to PATH |
| Windows — winget | `winget install jdx.mise` | |
| Windows — Chocolatey | `choco install mise` | Docs note: "chocolatey version is currently outdated" |
| Windows — manual | Download from [GitHub releases](https://github.com/jdx/mise/releases), add binary to PATH | If your shell doesn't support `mise activate`, add the shims dir to PATH — default `%LOCALAPPDATA%\mise\shims` |

([installing-mise](https://mise.jdx.dev/installing-mise.html))

#### 1.3.4 Cargo

```sh
cargo install --locked mise                                     # build from source
cargo install cargo-binstall && cargo binstall mise             # prebuilt, faster
cargo install mise --git https://github.com/jdx/mise --branch main   # latest commit on main
```

([installing-mise](https://mise.jdx.dev/installing-mise.html))

#### 1.3.5 npm

mise is published on npm as a **precompiled binary** — it is not a Node.js package, just distributed through npm. Useful for JS projects that want to set mise up via `package.json` or `npx` ([installing-mise](https://mise.jdx.dev/installing-mise.html)).

```sh
npm install -g mise
```

```sh
# test it for a single command without installing
npx mise exec python@3.11 -- python some_script.py
```

The legacy [`@jdxcode/mise`](https://www.npmjs.com/package/@jdxcode/mise) package is still published.

#### 1.3.6 GitHub Releases

```sh
curl -L https://github.com/jdx/mise/releases/download/v2025.12.0/mise-v2025.12.0-linux-x64 > /usr/local/bin/mise
chmod +x /usr/local/bin/mise
```

([installing-mise](https://mise.jdx.dev/installing-mise.html))

#### 1.3.7 Docker

The documented example Dockerfile pushes all mise directories to fixed locations and puts the **shims** directory on PATH (containers are non-interactive, so `mise activate` would never fire) ([installing-mise](https://mise.jdx.dev/installing-mise.html); see also the [Docker cookbook](https://mise.jdx.dev/mise-cookbook/docker.html)):

```dockerfile
FROM debian:13-slim

RUN apt-get update \
    && apt-get -y --no-install-recommends install sudo curl git ca-certificates build-essential \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV MISE_DATA_DIR="/mise"
ENV MISE_CONFIG_DIR="/mise"
ENV MISE_CACHE_DIR="/mise/cache"
ENV MISE_INSTALL_PATH="/usr/local/bin/mise"
ENV PATH="/mise/shims:$PATH"
RUN curl https://mise.run | sh
RUN mise trust -a && mise install
```

#### 1.3.8 Updating: `mise self-update`

* **Usage:** `mise self-update [FLAGS] [VERSION]` — *modifies state*
* Uses the GitHub Releases API to find the latest release and binary, and mise's GitHub-token resolution chain for authenticated requests.
* **By default it also updates any installed plugins.**
* Packagers can disable this command so mise is updated through the package manager instead — do not use it if you installed via a package manager.

| Flag / arg | Meaning |
| --- | --- |
| `[VERSION]` | Update to a specific version |
| `-f`, `--force` | Update even if already up to date |
| `-y`, `--yes` | Skip confirmation prompt |
| `--no-plugins` | Disable auto-updating plugins |

([cli/self-update](https://mise.jdx.dev/cli/self-update.html), [walkthrough](https://mise.jdx.dev/walkthrough.html))

#### 1.3.9 `mise install-into` — installing a tool outside of mise

* **Usage:** `mise install-into <TOOL@VERSION> <PATH>` — *modifies state*
* Installs a tool version to a specific path, "for building a tool to a directory for use outside of mise".

```sh
# install node@20.0.0 into ./mynode
$ mise install-into node@20.0.0 ./mynode && ./mynode/bin/node -v
20.0.0
```

([cli/install-into](https://mise.jdx.dev/cli/install-into.html))

#### 1.3.10 Uninstalling

`mise implode` removes the mise CLI and all related data. **Skips the config directory by default.**

| Flag | Meaning |
| --- | --- |
| `-n`, `--dry-run` | List directories that would be removed without removing them |
| `--config` | Also remove the config directory |

Manual cleanup equivalent ([installing-mise](https://mise.jdx.dev/installing-mise.html), [cli/implode](https://mise.jdx.dev/cli/implode.html)):

* `~/.local/share/mise` (or `MISE_DATA_DIR` / `XDG_DATA_HOME/mise`)
* `~/.local/state/mise` (or `MISE_STATE_DIR` / `XDG_STATE_HOME/mise`)
* `~/.config/mise` (or `MISE_CONFIG_DIR` / `XDG_CONFIG_HOME/mise`)
* Linux: `~/.cache/mise` (or `MISE_CACHE_DIR` / `XDG_CACHE_HOME/mise`)
* macOS: `~/Library/Caches/mise` (or `MISE_CACHE_DIR`)

#### 1.3.11 Autocompletion

Completions require the `usage` CLI ([usage.jdx.dev](https://usage.jdx.dev/)), a spec + CLI for defining CLI tools — "OpenAPI (swagger) for CLIs" ([faq](https://mise.jdx.dev/faq.html#what-is-usage)). Some installation methods install completion scripts automatically.

```sh
mise use -g usage
```

```sh
# bash (requires bash-completion)
mkdir -p ~/.local/share/bash-completion/completions/
mise completion bash --include-bash-completion-lib > ~/.local/share/bash-completion/completions/mise
```

```sh
# zsh — with oh-my-zsh, add `mise` to plugins=(...). Otherwise:
echo $fpath | tr ' ' '\n'
mkdir -p /usr/local/share/zsh/site-functions
mise completion zsh  > /usr/local/share/zsh/site-functions/_mise
```

```sh
# fish
mise completion fish > ~/.config/fish/completions/mise.fish
```

([installing-mise](https://mise.jdx.dev/installing-mise.html#autocompletion))

---

### 1.4 Shell activation

#### 1.4.1 What `mise activate` actually does

`mise activate` registers a **shell hook that runs `mise hook-env` every time the shell prompt is displayed**. `hook-env` inspects the current env vars — most importantly `PATH`, but also tool-specific ones like `GOROOT` or `JAVA_HOME` — and adds/removes/updates whatever changed ([faq](https://mise.jdx.dev/faq.html#what-does-mise-activate-do)).

For example, `cd`-ing from a java-17 project to a java-18 project causes the shell to evaluate something like:

```sh
export JAVA_HOME=$HOME/.local/share/installs/java/18
export PATH=$HOME/.local/share/installs/java/18/bin:$PATH
```

(In reality PATH manipulation is more complex because java-17 must also be removed.)

Key behaviours:

* It runs on **prompt display**, not only on `cd`, because config can change without the directory changing (e.g. you just edited `mise.toml` or `.tool-versions` in the current shell) ([faq](https://mise.jdx.dev/faq.html#what-does-mise-activate-do)).
* `hook-env` **exits early** when nothing changed, so it doesn't add latency to every command ([faq](https://mise.jdx.dev/faq.html#what-does-mise-activate-do)).
* `mise activate` also **creates a shell function named `mise`** (in most shells). That trick is what lets `mise shell` and `mise deactivate` work without wrapping them in `eval "$(...)"` ([faq](https://mise.jdx.dev/faq.html#what-does-mise-activate-do)).
* PATH entries point at **real install directories**, not shims — `which node` returns e.g. `/root/.local/share/mise/installs/node/lts/bin/node` ([demo](https://mise.jdx.dev/demo.html)). When a fuzzy version like `python = "3.15"` is active, the PATH entry may be the *requested-version symlink* (`.../installs/python/3.15/bin`) rather than the fully-resolved patch directory ([shims](https://mise.jdx.dev/dev-tools/shims.html)).
* In some shells (`bash`, `zsh`, `fish`, `xonsh`) mise **also hooks `cd`** — via `PROMPT_COMMAND` (bash), `chpwd` (zsh), `fish_prompt` (fish), `on_chdir` (xonsh) ([shims](https://mise.jdx.dev/dev-tools/shims.html#hook-on-cd)).

**`mise activate` CLI reference** ([cli/activate](https://mise.jdx.dev/cli/activate.html)):

* **Usage:** `mise activate [FLAGS] [SHELL_TYPE]` — *read-only*
* **`[SHELL_TYPE]` choices:** `bash`, `elvish`, `fish`, `nu`, `xonsh`, `zsh`, `pwsh`

| Flag | Meaning |
| --- | --- |
| `-q`, `--quiet` | Suppress non-error messages |
| `--no-hook-env` | Do not automatically call `hook-env`. Useful for debugging: `eval "$(mise activate --no-hook-env)"` then call `mise hook-env` manually (e.g. `mise hook-env --trace`) to see the values it would output without modifying the environment |
| `--shims` | Use shims instead of modifying PATH; effectively `PATH="$HOME/.local/share/mise/shims:$PATH"`. Does **not** support all `mise activate` features |

Status output is customised with `status` settings. The activate line belongs in an rc/login file (`~/.zshrc`, `~/.zprofile`, `~/.zshenv`, `~/.bashrc`, `~/.bash_profile`, `~/.profile`, `~/.config/fish/config.fish`, or `$PROFILE` for PowerShell); otherwise it only affects the current session. If `mise` isn't on PATH, use the absolute path in the rc file ([cli/activate](https://mise.jdx.dev/cli/activate.html)).

#### 1.4.2 Per-shell activation snippets

**Bash**

```sh
echo 'eval "$(mise activate bash)"' >> ~/.bashrc
```

**Zsh**

```sh
echo 'eval "$(mise activate zsh)"' >> "${ZDOTDIR-$HOME}/.zshrc"
```

**Fish**

```sh
echo 'mise activate fish | source' >> ~/.config/fish/config.fish
```

> For Homebrew and possibly other installs, mise is automatically activated in fish so this is not necessary — see [`MISE_FISH_AUTO_ACTIVATE=1`](https://mise.jdx.dev/configuration.html#mise-fish-auto-activate-1).

**PowerShell** (see [about_Profiles](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles) for your real profile path; create the parent directory first)

```powershell
echo '(&mise activate pwsh) | Out-String | Invoke-Expression' >> $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

**Nushell** — Nu does [not support `eval`](https://www.nushell.sh/book/how_nushell_code_gets_run.html#eval-function), so the activation script is saved to a file and imported:

```nushell
'
let mise_path = $nu.default-config-dir | path join mise.nu
^mise activate nu | save $mise_path --force
' | save $nu.env-path --append
"\nuse ($nu.default-config-dir | path join mise.nu)" | save $nu.config-path --append
```

To keep dotfiles clean, save elsewhere and extend `$env.NU_LIB_DIRS`:

```nushell
"\n$env.NU_LIB_DIRS ++= ($mise_path | path dirname | to nuon)" | save $nu.env-path --append
```

**Xonsh** — `.xsh` files are [not compiled](https://github.com/xonsh/xonsh/issues/3953), so a pure-Python import shaves startup time. Put this in e.g. `~/.config/xonsh/mise.py` and `import mise` from `~/.config/xonsh/rc.xsh`:

```python
from pathlib import Path
from xonsh.built_ins import XSH

ctx = XSH.ctx
mise_init = subprocess.run([Path('~/bin/mise').expanduser(),'activate','xonsh'],capture_output=True,encoding="UTF-8").stdout
XSH.builtins.execx(mise_init,'exec',ctx,filename='mise')
```

Or plain rc:

```sh
echo 'execx($(~/bin/mise activate xonsh))' >> ~/.config/xonsh/rc.xsh # or ~/.xonshrc
```

> **Xonsh gotcha:** mise replaces both the shell env `$PATH` *and* the OS `environ` `PATH`. Watch out that your configs don't set these differently — you may need `os.environ['PATH'] = xonsh.built_ins.XSH.env.get_detyped('PATH')` at the end of a config to keep them in sync.

**Elvish** — add to `rc.elv`:

```shell
var mise: = (ns [&])
eval (mise activate elvish | slurp) &ns=$mise: &on-end={|ns| set mise: = $ns }
mise:activate
```

Optionally alias `mise` to `mise:mise` so `mise {activate,deactivate,shell}` integrate seamlessly:

```shell
edit:add-var mise~ {|@args| mise:mise $@args }
```

**cmd.exe** — not an `activate` target.

> **Uncertainty:** the documented `SHELL_TYPE` choices for `mise activate` are `bash`, `elvish`, `fish`, `nu`, `xonsh`, `zsh`, `pwsh` only ([cli/activate](https://mise.jdx.dev/cli/activate.html)); no `cmd` shell script is documented. For `cmd.exe` (and any unsupported shell) the documented approach is to add the shims directory to `PATH` manually — default `%LOCALAPPDATA%\mise\shims` on Windows ([installing-mise](https://mise.jdx.dev/installing-mise.html#windows-manual)). The FAQ likewise states native Windows support works "via the use of shims until someone adds [powershell](https://github.com/jdx/mise/discussions/6733) support", which means env vars from `mise.toml` are unavailable there unless you go through `mise x` / `mise run` ([faq](https://mise.jdx.dev/faq.html#windows-support)) — note this sits in tension with `pwsh` being a listed `activate` target.

Adding a new shell is described as easy — very little shell code lives in the project; see [src/shell](https://github.com/jdx/mise/tree/main/src/shell) ([installing-mise](https://mise.jdx.dev/installing-mise.html)).

#### 1.4.3 Shell feature compatibility matrix

| Feature | Bash | Zsh | Fish | Nushell | Elvish | Xonsh | PowerShell |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `mise activate` | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| `mise shell` | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Shell aliases (`[shell_alias]`) | Yes | Yes | Yes | No | No | Yes | No |
| chpwd hook | Yes | Yes | Yes | Yes | Yes | Yes | Yes |

([getting-started](https://mise.jdx.dev/getting-started.html#shell-feature-compatibility))

#### 1.4.4 Related session commands

| Command | Effect | Notes |
| --- | --- | --- |
| `mise deactivate` | read-only | Disables mise for the current shell session (temporary) ([cli/deactivate](https://mise.jdx.dev/cli/deactivate.html)) |
| `mise shell [FLAGS] <TOOL@VERSION>…` (alias `sh`) | read-only | Sets a tool version for the current session by exporting env vars such as `MISE_NODE_VERSION=20`, eval'd through the shell function created by `mise activate`. **Only works where mise is already activated.** Flags: `-j/--jobs <JOBS>` (default 4), `-u/--unset`, `--raw` (connect backend install stdio to the terminal, implies `--jobs=1`) ([cli/shell](https://mise.jdx.dev/cli/shell.html)) |
| `mise en [-s --shell <SHELL>] [DIR]` | — | Starts a **new shell** with the mise environment built from the current config: an explicit alternative to `mise activate`. `DIR` defaults to `.`; `--shell` defaults to `$SHELL`. **Changing directories does not update the environment.** Examples: `mise en .`, `mise en -s "bash --norc"`, `mise en -s "zsh -f"` ([cli/en](https://mise.jdx.dev/cli/en.html)) |

---

### 1.5 Activation vs. shims

#### 1.5.1 The three loading mechanisms

There are three ways to get the mise context (dev tools + env vars) into a process ([shims](https://mise.jdx.dev/dev-tools/shims.html)):

1. **PATH activation** (`mise activate`) — mise rewrites `PATH` and other env vars each time the prompt is displayed.
2. **Shims** (`mise activate --shims`, or manually prepending the shims dir) — small executables that intercept commands and load context per invocation.
3. **Neither** — `mise exec` / `mise run` / `mise en` for ad-hoc commands and tasks.

Shims are symlinks (on Unix) to the mise binary:

```sh
ls -l ~/.local/share/mise/shims/node
# [...] ~/.local/share/mise/shims/node -> ~/.local/bin/mise
```

Installing a tool creates a shim for **every binary that tool provides**:

```sh
mise use -g node@20
npm install -g prettier@3.1.0

~/.local/share/mise/shims/node -v
# v20.0.0
~/.local/share/mise/shims/prettier -v
# 3.1.0
```

`mise activate --shims` is shorthand for `export PATH="$HOME/.local/share/mise/shims:$PATH"` ([shims](https://mise.jdx.dev/dev-tools/shims.html), [cli/activate](https://mise.jdx.dev/cli/activate.html#shims)).

#### 1.5.2 Full comparison

| Dimension | `mise activate` (PATH) | Shims (`--shims`) | `mise exec` / `run` / `en` |
| --- | --- | --- | --- |
| Mechanism | Shell hook runs `mise hook-env` at each prompt; rewrites `PATH`/env | Shims dir added to `PATH` once; each shim invocation loads context | Sets up env, runs one command/task, exits |
| Env vars from `[env]` | Full — exported into the shell | **Only available to mise tools** (loaded when a shim is called) | Full, for the child process |
| Hooks (`cd`, `enter`, `leave`) | Yes | **No** — these need shell integration | No (`preinstall`/`postinstall` still work with shims — they don't need shell integration) |
| `watch_files` hook | Yes (requires `mise activate`) | No | No |
| `which <tool>` | Returns the real path with a version in it, e.g. `~/.mise/installs/node/20/bin/node` | Returns the shim path, obscuring the real executable (workaround: `mise which`) | n/a |
| Non-interactive shells / scripts | **Broken** — the prompt never displays, so `hook-env` never runs | **Works** — shims resolve dynamically from `PWD` on each call | Works |
| IDEs | Not reliable | **Recommended** | Works if the IDE is configured to call it |
| CI/CD | Not recommended | **Recommended** (`export PATH="$HOME/.local/share/mise/shims:$PATH"`; GitHub Actions: `echo "$HOME/.local/share/mise/shims" >> $GITHUB_PATH`) | `mise exec -- npm test` |
| cron / other non-login contexts | No (no prompt) | Yes, if the shims dir is on PATH | Yes |
| Subprocesses | Inherit the rewritten PATH; no extra cost | When a shim runs, mise puts *all* tool paths ahead of the shims dir, so nested subprocesses pay no new penalty | Child inherits full env |
| Inline `cd a && cmd && cd b && cmd` | In shells **without** a cd hook this uses the tools from the *old* directory (mise only runs before the prompt) | **Always correct** | Always correct |
| Performance | A few ms per prompt, regardless of whether you use a mise tool; short-circuits when nothing changed | A few ms per shim invocation — worse in tight loops (`for i in {1..500}; do node script.js; done`), better if you rarely call tools | Per-invocation |
| Interactive use | **Recommended** | Works, with the caveats above | Explicit, "precise over easy" |

([shims](https://mise.jdx.dev/dev-tools/shims.html), [faq](https://mise.jdx.dev/faq.html#how-do-mise-activate-shims-mise-exec-and-mise-env-relate), [troubleshooting](https://mise.jdx.dev/troubleshooting.html))

The FAQ's condensed version ([faq](https://mise.jdx.dev/faq.html#how-do-mise-activate-shims-mise-exec-and-mise-env-relate)):

| Method | How it works | Best for |
| --- | --- | --- |
| `mise activate` | Hooks into your shell prompt, updates PATH dynamically | Interactive terminal use |
| `mise activate --shims` | Adds the shims directory to PATH once | IDEs, simple setups (no hooks/env support) |
| `mise exec` / `mise x` | Sets up env, runs a single command, then exits | Scripts, CI, one-off commands |
| `mise env` | Prints env vars you can eval | Integrating with other tools |
| `mise run` | Sets up env, then runs a task | Task execution |
| Shims (`~/.local/share/mise/shims`) | Wrapper scripts that call mise on each invocation | Non-interactive shells, IDEs |

> **Warning (verbatim from the docs):** `mise activate --shims` does **not** support hooks, env vars from `[env]`, or `watch_files`. It only puts shims on PATH. If you need those features use `mise activate` without `--shims`.

The env-var difference, concretely ([shims](https://mise.jdx.dev/dev-tools/shims.html#env-vars-and-shims)):

```sh
# only works under `mise activate`
$ mise set NODE_ENV=production
$ echo $NODE_ENV
production
```

```sh
# works under either
$ mise set NODE_ENV=production
$ node -p process.env.NODE_ENV
production
```

```sh
# works under either — exec/run always load the environment
$ mise x -- bash -c "echo \$NODE_ENV"
production
$ mise r some_task_that_uses_NODE_ENV
production
```

#### 1.5.3 Using both at once

The recommended combined setup puts `--shims` in the **profile** (non-interactive) file and plain `activate` in the **rc** (interactive) file ([shims](https://mise.jdx.dev/dev-tools/shims.html#how-to-add-mise-shims-to-path)):

```sh
# bash — note bash reads ~/.profile OR ~/.bash_profile if the latter exists;
# check which is defined on your system and append only to the existing one
echo 'eval "$(mise activate bash --shims)"' >> ~/.bash_profile  # non-interactive sessions
echo 'eval "$(mise activate bash)"' >> ~/.bashrc                # interactive sessions
```

```sh
# zsh
echo 'eval "$(mise activate zsh --shims)"' >> ~/.zprofile
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
```

```sh
# fish
echo 'mise activate fish --shims | source' >> ~/.config/fish/config.fish
echo 'mise activate fish | source' >> ~/.config/fish/config.fish
```

What happens to the shims directory when both are used depends on [`not_found_auto_install`](https://mise.jdx.dev/configuration/settings.html#not_found_auto_install) ([shims](https://mise.jdx.dev/dev-tools/shims.html)):

| `not_found_auto_install` | Behaviour of `mise activate` toward the shims dir |
| --- | --- |
| **enabled (default)** | Keeps the shims directory in `PATH`, **behind** the tool paths it manages. Tools resolved by the current toolset still win; shims remain a fallback so a missing version of an already-known tool can trigger auto-install. `mise doctor` does **not** flag this combination |
| disabled | **Removes** the shims directory from `PATH`; the rest of `PATH` is left untouched |

An alternative to `mise activate --shims` is a raw `export PATH="$HOME/.local/share/mise/shims:$PATH"` — helpful when `mise` isn't yet available at that point in shell startup ([shims](https://mise.jdx.dev/dev-tools/shims.html)).

**Using mise inside rc files.** rc files are scripts that run only for interactive sessions, so tools aren't on PATH yet. Two documented options ([shims](https://mise.jdx.dev/dev-tools/shims.html#using-mise-in-rc-files)):

```sh
# hook-env approach
eval "$(mise activate zsh)"
eval "$(mise hook-env -s zsh)"
node some_script.js
```

```sh
# shims approach — the --shims line must come first
eval "$(mise activate zsh --shims)"
eval "$(mise activate zsh)"
node some_script.js
```

#### 1.5.4 `mise reshim`

* **Usage:** `mise reshim [-f --force]` — *modifies state*
* Creates new shims in `~/.local/share/mise/shims` based on bin paths from **all currently installed tools** — not just those active in `mise.toml`.
* mise already reshims automatically whenever a tool is installed/updated/removed, and for commands like `npm i -g`. It is needed for install paths mise doesn't know about (e.g. installing global CLIs via yarn or pnpm).
* `-f`, `--force`: removes all shims before reshimming.
* **`mise reshim` only creates/removes shims.** Users often treat it as a "fix it" button, but it is only necessary when the shims dir is missing something it should have.
* **Do not put extra executables in the mise shims directory** — the next reshim deletes them.

Auto-reshim shell function suggested by the docs (it's fast, so overhead isn't a concern):

```sh
npm() {
  command npm "$@"
  mise reshim
}
```

```sh
$ mise reshim
$ ~/.local/share/mise/shims/node -v
v20.0.0
```

([cli/reshim](https://mise.jdx.dev/cli/reshim.html), [shims](https://mise.jdx.dev/dev-tools/shims.html#mise-reshim), [glossary](https://mise.jdx.dev/glossary.html))

---

### 1.6 Directory layout

| Directory | Override | Default | Purpose | Share across machines? |
| --- | --- | --- | --- | --- |
| `~/.config/mise` | `$MISE_CONFIG_DIR` | `${XDG_CONFIG_HOME:-$HOME/.config}/mise` | Global config file `~/.config/mise/config.toml` | **Yes** — intended for your dotfiles repo |
| `~/.cache/mise` | `$MISE_CACHE_DIR` | `${XDG_CACHE_HOME:-$HOME/.cache}/mise`; **macOS: `~/Library/Caches/mise`** | Internal cache (e.g. the list of available versions per plugin) | **No.** Deletable any time mise isn't installing; use `mise cache clear` |
| `~/.local/state/mise` | `$MISE_STATE_DIR` | `${XDG_STATE_HOME:-$HOME/.local/state}/mise` | Machine-local state, e.g. which config files are trusted | No |
| `~/.local/share/mise` | `$MISE_DATA_DIR` | `${XDG_DATA_HOME:-$HOME/.local/share}/mise` | Main directory: plugins and installed tools | *Could* be, but only for identical OS/arch — "in general I wouldn't advise doing so" |

([directories](https://mise.jdx.dev/directories.html), [glossary](https://mise.jdx.dev/glossary.html))

> **Tip from the docs:** if you use these directories often, set all of them to `~/.mise` for easy access ([directories](https://mise.jdx.dev/directories.html)).

`~/.local/share/mise` is nearly identical to asdf's `~/.asdf` — "so much so that you may be able to get by symlinking these together and using asdf and mise simultaneously (supporting this isn't a project goal, however)" ([directories](https://mise.jdx.dev/directories.html)).

#### 1.6.1 Inside `~/.local/share/mise`

| Subdirectory | Contents |
| --- | --- |
| `downloads/` | Assets (tarballs, etc.) plugins write during installation. mise **removes these after install/uninstall by default**; set `always_keep_download` to retain them for debugging backend/plugin install behaviour. **Not a supported download cache** — some backends may skip a download if the expected file exists, but that is backend-specific and not guaranteed. To avoid reinstalling tools in CI/offline, cache `installs/` instead |
| `plugins/` | Where `mise plugins install` puts plugins. For plugin development, symlink manually: `ln -s ~/src/mise-my-tool ~/.local/share/mise/plugins/my-tool` |
| `installs/` | Where `mise install` puts tools: `mise install node@20.0.0` → `~/.local/share/mise/installs/node/20.0.0`. Also creates symlinks for version prefixes and matching aliases. Overridable with `MISE_INSTALLS_DIR` |
| `shims/` | Where mise places shims — used for IDE integration or when `mise activate` doesn't work. Windows default: `%LOCALAPPDATA%\mise\shims` |

([directories](https://mise.jdx.dev/directories.html), [shims](https://mise.jdx.dev/dev-tools/shims.html))

Example symlink layout inside `installs/`:

```sh
$ tree ~/.local/share/mise/installs/node
20 -> ./20.15.0
20.15 -> ./20.15.0
lts -> ./20.15.0
latest -> ./20.15.0
```

> **`MISE_INSTALLS_DIR` gotcha:** it is read **when mise starts**. Set it in the environment before invoking mise and keep it set for later mise and shim invocations. **Do not set it in `[env]` in `mise.toml`** — `[env]` describes the environment mise *exports*, after mise has already chosen its installation directory. Setting it there can make an install use one directory while later commands and shims look in another ([directories](https://mise.jdx.dev/directories.html)).

Other state paths worth knowing: `~/.local/state/mise/ignored-configs/` holds symlinks for configs whose trust prompt you declined ([faq](https://mise.jdx.dev/faq.html#my-config-file-is-being-ignored-mise-trust-issues)).

---

### 1.7 Cache behavior

#### 1.7.1 Tool cache

Each tool/backend has a cache under `$MISE_CACHE_DIR/<TOOL>` storing ([cache-behavior](https://mise.jdx.dev/cache-behavior.html)):

* the list of available versions (`mise ls-remote <TOOL>`)
* idiomatic filenames
* the list of aliases
* the bin directories inside each tool installation
* the result of running `exec-env` after the tool was installed

**Remote versions are updated daily by default.** The file is zlib messagepack; to inspect it (requires [msgpack-cli](https://github.com/msgpack/msgpack-cli)):

```sh
cat ~/$MISE_CACHE_DIR/node/remote_versions.msgpack.z | perl -e 'use Compress::Raw::Zlib;my $d=new Compress::Raw::Zlib::Inflate();my $o;undef $/;$d->inflate(<>,$o);print $o;' | msgpack-cli decode
```

Caching `exec-env` "massively improved the performance of mise since it requires calling bash every time mise is initialized", but it can be problematic if an `exec-env` script doesn't just export static values — the vast majority do ([cache-behavior](https://mise.jdx.dev/cache-behavior.html)).

> Internally, the generic cache layer is `CacheManager<T>`: msgpack serialization, **zstd** compression, TTL support, automatic invalidation on file timestamps, and per-backend cache isolation ([architecture](https://mise.jdx.dev/architecture.html)). Note the tool-version cache file described on the cache page is documented as *zlib* messagepack ([cache-behavior](https://mise.jdx.dev/cache-behavior.html)).

#### 1.7.2 Environment caching

For advanced needs (including dynamic env providers like secret managers), the [`env_cache`](https://mise.jdx.dev/configuration/settings.html#env_cache) setting caches the computed environment **to disk with encryption** ([cache-behavior](https://mise.jdx.dev/cache-behavior.html)):

```toml
# ~/.config/mise/config.toml
[settings]
env_cache = true
env_cache_ttl = "1h"  # optional, default is 1h
```

Invalidation happens automatically when:

* any config file changes (`mise.toml`, `.tool-versions`, …)
* tool versions change
* settings change
* the mise version changes
* the TTL expires (`env_cache_ttl`)
* any watched file changes (from modules or `_.source` directives)

Env plugins (vfox modules) can declare themselves cacheable by returning `{cacheable = true, watch_files = [...]}` from their `MiseEnv` hook ([env-plugin-development](https://mise.jdx.dev/env-plugin-development.html)). Individual directives can opt out:

```toml
[env]
TIMESTAMP = { value = "{{ now() }}", cacheable = false }
_.source = { file = "dynamic.sh", cacheable = false }
```

#### 1.7.3 Auto-pruning, `cache prune`, `cache clear`

mise automatically deletes old files in the cache directory, governed by [`cache_prune_age`](https://mise.jdx.dev/configuration/settings.html#cache_prune_age). Much of the content is ignored anyway once it is >24 hours old (or a few days), "for this reason it's likely wasteful to store this directory in CI jobs" ([cache-behavior](https://mise.jdx.dev/cache-behavior.html)).

| Command | Aliases | Effect | Notes |
| --- | --- | --- | --- |
| `mise cache prune [-v --verbose…] [--dry-run] [TOOL]…` | `p` | modifies state | Removes stale cache files: by default those **not accessed in 30 days**, changeable via `MISE_CACHE_PRUNE_AGE`. `--dry-run` shows what would be pruned; `-v` shows pruned files; `[TOOL]…` limits to specific tools ([cli/cache/prune](https://mise.jdx.dev/cli/cache/prune.html)) |
| `mise cache clear [TOOL]…` | `c` | modifies state | Deletes **all** cache files (optionally only for the given tools) ([cli/cache/clear](https://mise.jdx.dev/cli/cache/clear.html)) |

> **Uncertainty:** the troubleshooting page also references `mise cache clean` ([troubleshooting](https://mise.jdx.dev/troubleshooting.html#mise-is-failing-or-not-working-right)) while the CLI reference documents `mise cache clear` with alias `c` ([cli/cache/clear](https://mise.jdx.dev/cli/cache/clear.html)); the docs do not state whether `clean` is a separate alias.

**Related caches outside `MISE_CACHE_DIR`:** mise uses <https://mise-versions.jdx.dev> as a centralized version list for most plugins, to speed things up and dodge GitHub rate limits. It is also a shared cache for public GitHub release metadata and GitHub artifact attestations, so normal installs of public `github:` and many `aqua:` tools avoid unauthenticated GitHub API calls even in Docker/CI without a token; mise falls back to the GitHub API when the host lacks the metadata. Disable with `MISE_USE_VERSIONS_HOST=0` ([troubleshooting](https://mise.jdx.dev/troubleshooting.html#new-version-of-a-tool-is-not-available)).

---

### 1.8 Glossary of mise terminology

#### Core concepts

| Term | Definition |
| --- | --- |
| **Activation** | Loading mise's context (tools, env vars, PATH modifications) into your shell session, typically `eval "$(mise activate bash)"` in your rc file |
| **Backend** | A package manager or ecosystem mise uses to fetch/install/manage tools |
| **Core Tools** | Built-in tool implementations written in Rust that ship with mise (node, python, ruby, go, …) — see [core-tools](https://mise.jdx.dev/core-tools.html) |
| **mise.toml** | The primary project configuration file: tool versions, env vars, tasks, hooks |
| **mise.local.toml** | User-local config that overrides `mise.toml`; typically gitignored |
| **Plugin** | An extension adding tools or env-var management to mise |
| **Registry** | The mapping of friendly short names to full backend specs (e.g. `aws-cli` → `aqua:aws/aws-cli`) |
| **Tool** | A dev tool or runtime mise can install (`node`, `python`, `terraform`, `jq`) |
| **Tool Request** | A user's (possibly fuzzy/aliased) version spec: `node@18`, `python@latest`, `go@1.21` |
| **Tool Version** | A concrete resolved version — `node@18` may resolve to `node@18.19.0` |
| **Toolset** | An immutable collection of resolved Tool Versions active for a directory/project |

([glossary](https://mise.jdx.dev/glossary.html), [architecture](https://mise.jdx.dev/architecture.html))

#### Backends

`aqua` (aqua-proj registry; SLSA provenance verification), `asdf` (legacy asdf shell-script plugins; **Linux and macOS only**; slower than native backends), `cargo`, `conda`, `dotnet`, `gem`, `github`, `gitlab`, `go`, `http`, `npm`, `pipx`, `spm`, `ubi` (Universal Binary Installer for single-binary tools), `vfox` (VersionFox plugins) ([glossary](https://mise.jdx.dev/glossary.html)).

#### Shell integration

| Term | Definition |
| --- | --- |
| **hook-env** | `mise hook-env` exports environment changes for shell integration; called automatically by the shell hook installed by `mise activate` |
| **PATH Activation** | The default integration: mise updates `PATH` at each prompt to point at the right tool binaries |
| **Reshim** | Updating the shims directory after tools are installed/removed (`mise reshim`) |
| **Shims** | Small executables intercepting tool commands and delegating to mise, which loads context before execution |

#### Configuration

| Term | Definition |
| --- | --- |
| **config_root** | The canonical project root used to resolve relative paths in config files; set via `MISE_PROJECT_ROOT` or auto-detected |
| **Configuration Environments** | Env-specific config files like `mise.dev.toml` / `mise.prod.toml`, activated with `MISE_ENV` ([configuration/environments](https://mise.jdx.dev/configuration/environments.html)) |
| **Configuration Hierarchy** | System/global/project `mise.toml` files merged, with files closer to the cwd winning |
| **Settings** | Global options in `~/.config/mise/settings.toml` affecting all projects |
| **Templates** | Tera template syntax in config, e.g. `{{env.HOME}}`, `{{arch()}}` ([templates](https://mise.jdx.dev/templates.html)) |

#### Environment variables

| Term | Definition |
| --- | --- |
| **`env._` directives** | `env._.file` (load from a file, e.g. `.env`), `env._.path` (prepend dirs to PATH), `env._.source` (source a shell script) |
| **Lazy Evaluation** | Env vars configured with `tools = true`, evaluated after tools load so they can read tool-provided env vars |
| **Redaction** | `redact = true` hides a sensitive env var's value from mise output and logs |

#### Hooks

**Hooks** are scripts that run automatically during mise activation at specific events — **an experimental feature** ([glossary](https://mise.jdx.dev/glossary.html), [hooks](https://mise.jdx.dev/hooks.html)).

| Hook | Fires |
| --- | --- |
| `cd` | Whenever you change directories while mise is active (requires `mise activate`) |
| `enter` | Entering a directory where a `mise.toml` becomes active (requires `mise activate`) |
| `leave` | Leaving a directory where a `mise.toml` was active (requires `mise activate`) |
| `preinstall` | Before a tool installation begins (**works with shims**) |
| `postinstall` | After a tool is successfully installed (**works with shims**) |
| `watch_files` | When specified files change — **requires `mise activate`** |

([glossary](https://mise.jdx.dev/glossary.html), [shims](https://mise.jdx.dev/dev-tools/shims.html#hooks-and-shims))

#### Tasks

| Term | Definition |
| --- | --- |
| **Task** | A reusable command defined in `mise.toml` or as a standalone script, executed within the mise environment |
| **TOML Tasks** | Tasks in the `[tasks]` section of a config file |
| **File Tasks** | Standalone executable scripts in `mise-tasks/`, `.mise/tasks/`, etc. |
| **Dependency Graph** | The internal DAG resolving task execution order |
| **Task Dependencies** | `depends` (run before), `depends_post` (run after), `wait_for` (wait but don't trigger) |

#### Directories & other terms

| Term | Definition |
| --- | --- |
| **MISE_CACHE_DIR** | Cached downloads/metadata; `~/.cache/mise` on Linux, `~/Library/Caches/mise` on macOS |
| **MISE_DATA_DIR** | Installed tools and persistent data; `~/.local/share/mise` |
| **MISE_PROJECT_ROOT** | Auto-set to the root directory of the current project (where the `mise.toml` lives) |
| **Tool Aliases** | Alternative names via `mise tool-alias` / `[tool_alias]`. *Backend* aliases point a short name like `node` at a custom backend; *version* aliases map symbolic names like `lts-iron` to a concrete version |
| **Shell Aliases** | Shell command aliases (`ll = "ls -la"`) via `mise shell-alias` / `[shell_alias]`, set on entering a directory and unset on leaving, like env vars. Supported in bash, zsh, fish, xonsh |
| **direnv** | External env-management tool mise can work alongside (with strong caveats — see §1.2) |
| **mise-en-place** | The French culinary phrase "everything in its place" — the philosophy behind mise |
| **mise.lock** | Lockfile recording exact resolved versions for reproducibility ([mise-lock](https://mise.jdx.dev/dev-tools/mise-lock.html)) |
| **Tool Options** | Config in `mise.toml` changing tool behaviour, e.g. Python `virtualenv` path or Node `corepack` preferences |

Tasks also receive these env vars: `MISE_ORIGINAL_CWD`, `MISE_CONFIG_ROOT`, `MISE_PROJECT_ROOT`, `MISE_MONOREPO_ROOT` (only inside a monorepo), `MISE_TASK_NAME`, `MISE_TASK_DIR`, `MISE_TASK_FILE` ([tasks](https://mise.jdx.dev/tasks/index.html)).

Adjacent tools in the same ecosystem: **usage** (CLI spec, powers completions and task args), **pitchfork** (process/daemon manager with auto-restart, readiness checks, shell-based auto-start/stop, cron-style scheduling) ([faq](https://mise.jdx.dev/faq.html#what-is-usage), [faq](https://mise.jdx.dev/faq.html#what-is-pitchfork)).

---

### 1.9 Quickstart walkthrough

#### Step 1 — install and verify

```sh
curl https://mise.run | sh
~/.local/bin/mise --version
# mise 2024.x.x
```

([getting-started](https://mise.jdx.dev/getting-started.html))

#### Step 2 — run tools without installing anything permanently

```sh
mise exec python@3 -- python
# this will download and install Python if it is not already installed
# Python 3.15.0
# >>> ...
```

```sh
mise exec node@26 -- node -v
# v26.x.x
```

Outside the mise environment the tool is not on PATH:

```sh
node -v
# bash: node: command not found
```

> **Tip:** alias it — `alias x="mise x --"` ([getting-started](https://mise.jdx.dev/getting-started.html), [demo](https://mise.jdx.dev/demo.html)).

#### Step 3 — activate (optional but recommended for interactive shells)

```sh
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
# zsh:  echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
# fish: echo '~/.local/bin/mise activate fish | source' >> ~/.config/fish/config.fish
```

Restart the shell, then run `mise doctor` to verify ([getting-started](https://mise.jdx.dev/getting-started.html)).

#### Step 4 — install tools globally

```sh
mise use --global node@lts
node -v
# v22.14.0
which node
# /root/.local/share/mise/installs/node/lts/bin/node   ← real path, not a shim
```

```sh
mise use -g terraform jq go
# mise jq@1.7.1 ✓ installed
# mise terraform@1.11.3 ✓ installed
# mise go@1.24.1 ✓ installed
# mise ~/.config/mise/config.toml tools: go@1.24.1, jq@1.7.1, terraform@1.11.3
```

```sh
mise ls
# Tool       Version  Source                      Requested
# go         1.24.1   ~/.config/mise/config.toml  latest
# jq         1.7.1    ~/.config/mise/config.toml  latest
# node       22.14.0  ~/.config/mise/config.toml  lts
# terraform  1.11.3   ~/.config/mise/config.toml  latest
```

([demo](https://mise.jdx.dev/demo.html))

#### Step 5 — pin per-project tools and watch them switch

```bash
mkdir example-project && cd example-project
mise use node@26
node -v
# v26.x.x
```

`mise use` does **two** things — installs the tool *and* adds it to `mise.toml`. **Both are required.** Installing with `mise install` alone will not make the tool available in your shell; it must also be listed in `mise.toml` ([walkthrough](https://mise.jdx.dev/walkthrough.html), [faq](https://mise.jdx.dev/faq.html#what-is-the-difference-between-mise-install-and-mise-use)).

```toml
# mise.toml
[tools]
node = "26"
```

```sh
cd ..
node -v
# v22.14.0   ← reverts to the global LTS
```

([demo](https://mise.jdx.dev/demo.html))

#### Step 6 — pull tools from other backends

```sh
mise use --global npm:@anthropic-ai/claude-code
mise use --global pipx:black
mise use --global github:BurntSushi/ripgrep
mise use cargo:starship
mise use npm:@antfu/ni
```

Resulting global config ([getting-started](https://mise.jdx.dev/getting-started.html#tool-backends), [walkthrough](https://mise.jdx.dev/walkthrough.html)):

```toml
# ~/.config/mise/config.toml
[tools]
"npm:@anthropic-ai/claude-code" = "latest"
"pipx:black" = "latest"
"github:BurntSushi/ripgrep" = "latest"
```

You can also edit `mise.toml` by hand and run `mise install` — the effect is the same.

#### Step 7 — trust the config

```
mise ~/my-project/mise.toml is not trusted. Trust it? [y/n]
```

```sh
mise trust
```

Only needed once per file. To disable trust prompts entirely, trust the root path ([getting-started](https://mise.jdx.dev/getting-started.html#trust)):

```sh
mise settings trusted_config_paths=["/"]
# or: export MISE_TRUSTED_CONFIG_PATHS=/
```

`mise use` auto-trusts the file it creates, so the prompt appears only for configs someone else wrote or files you hand-edited.

#### Step 8 — environment variables

```sh
mise set MY_VAR=123
echo $MY_VAR
# 123
```

```toml
[env]
NODE_ENV = "production"
MY_VAR = "123"
_.path = "./node_modules/.bin"   # "." = the directory containing mise.toml, so subdirs still work
```

```sh
mise exec -- node --eval 'console.log(process.env.NODE_ENV)'
```

Do **not** put secrets in a project's `mise.toml` (it's meant for version control) — use `mise.local.toml` ([walkthrough](https://mise.jdx.dev/walkthrough.html), [getting-started](https://mise.jdx.dev/getting-started.html)).

#### Step 9 — tasks

```toml
# mise.toml
[tasks]
hello = "echo hello from mise"
build = "npm run build"
test = "npm test"
```

```bash
#!/bin/bash
# mise-tasks/build
npm run build
```

```sh
mise run hello
# hello from mise
```

`mise run` sets up the full mise environment (tools + env vars) before running, so it is a complete alternative to activating mise in your shell. mise also **automatically installs all tools from `mise.toml` before running a task** ([walkthrough](https://mise.jdx.dev/walkthrough.html), [getting-started](https://mise.jdx.dev/getting-started.html)).

Tasks integrate with [usage](https://usage.jdx.dev) for docs, args, and completions:

```bash
#!/usr/bin/env bash
# mise-tasks/greet
set -e

#MISE description="Greet a user with a message"
#USAGE flag "-g --greeting <greeting>" help="The greeting word to use" {
#USAGE   choices "hi" "hello" "hey"
#USAGE }
#USAGE flag "-u --user <user>" help="The user to greet"
#USAGE flag "--dir <dir>" help="The directory to greet from" default="."
#USAGE complete "dir" run="find . -maxdepth 1 -type d"
#USAGE arg "<message>" help="Greeting message"

echo "all available options are in the env with the prefix 'usage_'"
env | grep usage_

echo "${usage_greeting?}, ${usage_user?}! Your message is: ${usage_message?}"
```

```shell
mise run greet --user jdx -g "hey" "How are you?"
```

Options arrive as env vars prefixed `usage_`; `mise run greet --help` shows them; completions work, including custom completion commands like `find . -maxdepth 1 -type d` ([walkthrough](https://mise.jdx.dev/walkthrough.html)).

#### Step 10 — config hierarchy and upgrades

Config cascades broad → specific ([walkthrough](https://mise.jdx.dev/walkthrough.html)):

1. `~/.config/mise/config.toml` — global
2. `~/work/mise.toml` — work-specific
3. `~/work/project/mise.toml` — project-specific
4. `~/work/project/mise.local.toml` — project-specific, not shared (gitignore it)

Use `mise config ls` (`mise cfg`) to see which files are in play. Prefer loose versions (`node@26`) so teammates aren't locked to your patch version; pin with `mise use --pin` or the [`lockfile`](https://mise.jdx.dev/configuration/settings.html#lockfile) setting. Omitting the version defaults to `@latest`. `mise edit` opens a TUI with registry fuzzy-search and schema-aware autocompletion.

```sh
mise upgrade node          # latest within the mise.toml prefix; updates mise.lock if present
mise upgrade --bump node   # also rewrites mise.toml at the same specificity (24 → 26)
```

#### Most important commands

| Command | Purpose |
| --- | --- |
| `mise completion` | Set up shell completions |
| `mise cfg` / `mise config` | Work with `mise.toml` files via the CLI |
| `mise x` / `mise exec` | Execute a command in the mise environment without activating |
| `mise g` / `mise generate` | Generate git hooks, task docs, GitHub Actions, etc. |
| `mise i` / `mise install` | Install tools |
| `mise link` | Symlink a tool installed by other means into mise |
| `mise ls-remote` | List all available versions of a tool |
| `mise ls` | List installed/active tools |
| `mise outdated` | Show tools with newer versions available |
| `mise plugin` | Manage plugins (asdf or modern plugins) |
| `mise r` / `mise run` | Run a task |
| `mise self-update` | Update mise (**not** if installed via a package manager) |
| `mise settings` | Get/set configuration settings |
| `mise rm` / `mise uninstall` | Uninstall a tool |
| `mise up` / `mise upgrade` | Upgrade tool versions |
| `mise u` / `mise use` | Install **and** activate tools |
| `mise w` / `mise watch` | Watch for changes and run tasks |

([walkthrough](https://mise.jdx.dev/walkthrough.html))

#### Migrating from asdf

```sh
# 1. install mise and set up `mise activate`
# 2. remove asdf from your shell rc file
# 3. run `mise install` in a directory with a .tool-versions file
```

mise does **not** treat `~/.tool-versions` as a global config the way asdf does — global config is `~/.config/mise/config.toml`. Migration script for a global `.tool-versions` ([faq](https://mise.jdx.dev/faq.html#how-do-i-migrate-from-asdf)):

```shell
mv ~/.tool-versions ~/.tool-versions.bak
cat ~/.tool-versions.bak | tr -s ' ' | tr ' ' '@' | xargs -n2 mise use -g
```

`mise use` may write fuzzy versions that asdf can't read; use `--pin` or `MISE_PIN=1` for asdf-compatible `.tool-versions` output. `mise.toml` and `.tool-versions` may sit side by side — `mise.toml` wins in the same directory ([faq](https://mise.jdx.dev/faq.html#how-compatible-is-mise-with-asdf)).

---

### 1.10 `mise doctor`

* **Usage:** `mise doctor [-J --json] <SUBCOMMAND>` — aliases `dr` — *read-only*
* Checks the mise installation for possible problems.

| Flag / subcommand | Meaning |
| --- | --- |
| `-J`, `--json` | JSON output |
| `mise doctor path [-f --full]` | Print the PATH entries mise is providing; `--full` prints all entries, including those not from mise |

```
$ mise doctor
[WARN] plugin node is not installed
```

```
$ mise doctor path
/home/user/.local/share/mise/installs/node/24.0.0/bin
/home/user/.local/share/mise/installs/rust/1.90.0/bin
/home/user/.local/share/mise/installs/python/3.10.0/bin
```

([cli/doctor](https://mise.jdx.dev/cli/doctor.html), [cli/doctor/path](https://mise.jdx.dev/cli/doctor/path.html))

What `mise doctor` is used for across the docs:

* Verifying activation after editing an rc file ([getting-started](https://mise.jdx.dev/getting-started.html)).
* Diagnosing install problems ([installing-mise](https://mise.jdx.dev/installing-mise.html#troubleshooting)).
* Confirming mise is activated when the wrong tool version is being used — it should not list a "problem" about mise not being activated ([troubleshooting](https://mise.jdx.dev/troubleshooting.html)).
* Listing untrusted config files under "problems" ([faq](https://mise.jdx.dev/faq.html#my-config-file-is-being-ignored-mise-trust-issues)).
* **Always include `mise doctor` output in bug reports** ([troubleshooting](https://mise.jdx.dev/troubleshooting.html)).
* Note: the `--shims` + `activate` combination is *not* reported as a problem when `not_found_auto_install` is enabled ([shims](https://mise.jdx.dev/dev-tools/shims.html)).

---

### 1.11 Debugging switches

| Switch | Effect |
| --- | --- |
| `mise --verbose <cmd>` / `MISE_VERBOSE=1` | Show stacktraces and command output |
| `MISE_DEBUG=1 mise <cmd>` | Debug logging |
| `MISE_TRACE=1 mise <cmd>` | Trace logging (very verbose) |
| `MISE_LOG_FILE_LEVEL=debug MISE_LOG_FILE=/path/to/logfile` | Write logs to a file |
| `MISE_TIMINGS=1` / `=2` | Profile `hook-env` steps (`=2` gives per-step breakdowns with cumulative time; red = slow) |
| `mise install ... --raw` | Install serially with stdin/stdout/stderr connected to the terminal — needed if a plugin tries to interact with you |
| `mise doctor` | Diagnostics and warnings |

Every mise error is followed by a generic footer; the *actual* error is the line(s) above it ([errors](https://mise.jdx.dev/errors.html)):

```text
mise ERROR Version: 2026.7.0
mise ERROR Run with --verbose or MISE_VERBOSE=1 for more information
```

Color output follows the [clicolors spec](https://bixense.com/clicolors/) via [console.rs](https://docs.rs/console/latest/console/fn.colors_enabled.html): `CLICOLOR != 0` → colors when not piped; `CLICOLOR == 0` → no ANSI codes; `CLICOLOR_FORCE != 0` → always color ([faq](https://mise.jdx.dev/faq.html#how-do-i-disable-force-cli-color-output)).

HTTP proxies: set lowercase `http_proxy` and `https_proxy`. This may not work with plugins not configured to read them ([faq](https://mise.jdx.dev/faq.html#how-do-i-use-mise-with-http-proxies)).

---

### 1.12 Common errors

Organized by **message** ([errors](https://mise.jdx.dev/errors.html)); the symptom-organized companion is [troubleshooting](https://mise.jdx.dev/troubleshooting.html).

| Error | Cause | Fix |
| --- | --- | --- |
| `Config files in <dir> are not trusted. Trust them with mise trust.` | Config files can define env vars, templates, and tasks, so mise won't load them from unfamiliar directories | `mise trust` in the directory; for a whole tree use [`trusted_config_paths`](https://mise.jdx.dev/configuration/settings.html#trusted_config_paths); see also [paranoid mode](https://mise.jdx.dev/paranoid.html) |
| `<tool> not found in mise tool registry` | The name has no shorthand in the [registry](https://mise.jdx.dev/registry.html) (check the "Did you mean?" list for typos) | Use explicit backend syntax: `mise use aqua:owner/repo`, `github:owner/repo`, `cargo:some-tool`, `npm:some-tool` |
| `Failed to install <tool>@<version>: <underlying error>` | Wrapper — the text after the colon is the real error (often a 403 or checksum mismatch) | Re-run with `--verbose`, or `mise install <tool>@<version> --raw` to run serially with a live terminal |
| `<tool>@<version> not installed` | Version is known but not on disk | `mise install` (or `mise install <tool>@<version>`); `mise ls <tool>` shows installed vs. merely requested |
| `[<config file>] <tool>@<version>: <error>` | Failed to resolve the version requested by that config file | (a) version doesn't exist → `mise ls-remote <tool>`; (b) stale cache → `mise cache clear`; (c) network/API errors → read the text after the colon |
| `HTTP status client error (401 Unauthorized)` | GitHub rejected the credential — invalid/expired token, wrong GitHub host, or missing scope. Output includes a `github auth:` line naming the source (`GITHUB_TOKEN`, `gh CLI (hosts.yml)`, `github_tokens.toml`); `github auth: yes` when the source is unknown, `github auth: no` when no Authorization header was sent | Replace the token in the named source — see [GitHub Tokens](https://mise.jdx.dev/dev-tools/github-tokens.html) |
| `HTTP status client error (403 Forbidden)` / `GitHub rate limit exceeded` | GitHub API rate limit (very low unauthenticated; common in CI) | Set `GITHUB_TOKEN` or `MISE_GITHUB_TOKEN` (**no scopes required**). Output includes `github auth:` and `github rate limit:` lines. Private repos need appropriate scopes |
| `Checksum mismatch for file <file>` | (1) corrupted/truncated download; (2) stale lockfile checksum after an upstream re-upload; (3) tampering | (1) `mise cache clear` and retry; (2) remove the entry from [`mise.lock`](https://mise.jdx.dev/dev-tools/mise-lock.html) and reinstall to re-lock; (3) **don't override** — verify the upstream release |
| `mise version <X> is required, but you are using <Y>` | The project declares a newer [`min_version`](https://mise.jdx.dev/configuration.html) | `mise self-update`, or update via your package manager |
| `no tasks <name> found` | No such task in the current config hierarchy — tasks load from the cwd and its parents only | `mise tasks ls` |
| `<command> exited with non-zero status: exit code <N>` / `command failed: exit code <N>` | A command mise executed failed (task, plugin script, or the program run via `mise exec`/shims). The problem is in the command; mise propagates its exit code | Re-run with `--verbose` / `MISE_DEBUG=1` |

Checksum mismatch output shape:

```text
Checksum mismatch for file node-v24.0.0.tar.gz:
Expected: sha256:abc123...
Actual:   sha256:def456...
```

---

### 1.13 Troubleshooting by symptom

([troubleshooting](https://mise.jdx.dev/troubleshooting.html))

#### `mise activate` doesn't work in `~/.profile`, `~/.bash_profile`, `~/.zprofile`

`mise activate` belongs only in **rc** files — the interactive ones. The prompt isn't displayed in non-interactive environments, so PATH is never modified. For non-interactive setups use shims (they route calls by looking at `PWD` on each execution), `mise exec`, or `mise env` — though `mise env` in a non-interactive shell only sets up global tools and won't update env vars when entering a different project. See also the [shebang trick](https://mise.jdx.dev/tips-and-tricks.html#shebang).

#### Slow shell prompts

```sh
mise deactivate

# Show timing per major step (color-coded: red = slow)
MISE_TIMINGS=1 mise hook-env -s bash 2>&1 >/dev/null

# Or =2 for detailed per-step breakdowns with cumulative time
MISE_TIMINGS=2 mise hook-env -s bash 2>&1 >/dev/null
```

Common causes: expensive `_.source` scripts in `mise.toml` (they re-run on every prompt), large numbers of tools/plugins, network-dependent env directives. `mise activate --shims` moves the cost from every prompt to every tool invocation — which may or may not be faster for your workflow.

#### The wrong version of a tool is being used

Usually mise isn't first in `PATH`. Diagnose:

```bash
$ mise ls node          # must not say "missing"; check the Requested column
Plugin  Version  Config Source       Requested
node    24.0.0  ~/.mise/config.toml  24.0.0
$ mise doctor           # must not report "mise not activated"
$ which -a node         # is the first hit a mise directory?
```

Whichever `node` runs first has its directory earlier in PATH — typically you must set the mise shims PATH at the **end** of bashrc/zshrc. With `mise activate` you can also set `MISE_ACTIVATE_AGGRESSIVE=1` so mise always prepends its tools; this may still fail if another tool rewrites PATH after mise does. As a fallback, run things with `mise x --`.

#### New version of a tool is not available

Two caches: the local CLI cache (`mise cache clear`) and the centralized <https://mise-versions.jdx.dev> host (disable with `MISE_USE_VERSIONS_HOST=0`). You can help the versions host fetch more frequently by authenticating with its [GitHub app](https://github.com/apps/mise-versions) — it requires no permissions since it only reads public repository information.

#### Tool not found after `mise install`/`mise use` in a script

`mise activate` updates PATH at the next prompt, which never happens in a script.

```bash
# Option 1: Use mise exec (recommended)
mise install
mise exec -- my-tool --version

# Option 2: Re-evaluate the environment after install
mise install
eval "$(mise hook-env)"
my-tool --version

# Option 3: Use shims (they always resolve dynamically)
export PATH="$HOME/.local/share/mise/shims:$PATH"
mise install
my-tool --version
```

#### mise isn't working from tmux or another shell init script

Same root cause. Either add shims to PATH, or call `hook-env` manually:

```bash
export PATH="$HOME/.local/share/mise/shims:$PATH"
python --version
```

```bash
eval "$(mise activate bash)"
eval "$(mise hook-env)"
python --version   # works only after calling hook-env explicitly
```

#### `mise activate` in CI / non-interactive shells

With `chpwd` support it works in more situations now, but the recommendations remain:

```bash
# Option 1: Use shims (recommended for CI)
export PATH="$HOME/.local/share/mise/shims:$PATH"
# In GitHub Actions: echo "$HOME/.local/share/mise/shims" >> $GITHUB_PATH

# Option 2: Use mise exec
mise exec -- npm test

# Option 3: Manually call hook-env after activate
eval "$(mise activate bash)"
eval "$(mise hook-env)"
```

#### Creating `~/.bash_profile` breaks `~/.profile` on Ubuntu/Debian

On many distros `~/.profile` sources `~/.bashrc`, but bash reads `~/.bash_profile` **instead of** `~/.profile` when it exists. Fix by activating in `~/.bashrc`, or:

```bash
# ~/.bash_profile
[[ -f ~/.profile ]] && source ~/.profile
```

#### `not_found_auto_install` doesn't work for brand-new tools

**mise can only auto-install missing *versions* of tools that already have at least one version installed.** mise can't know which binaries a tool provides until some version of it exists on disk, so it can't map an unknown binary name to a tool. Workarounds: install one version manually first, or use `mise x` / `mise r`, which install required versions automatically ([troubleshooting](https://mise.jdx.dev/troubleshooting.html), [settings#not_found_auto_install](https://mise.jdx.dev/configuration/settings.html#not_found_auto_install)).

#### Config file is ignored / trust issues

Safe config files — those containing only `min_version`, `[tools]` entries with plain version strings (or arrays of them), and `[tasks]` with no templates and no tool options — load **without** trust, because nothing in them executes code at load time. Everything else (env vars, hooks, settings, aliases, templates, tool options) requires trust ([faq](https://mise.jdx.dev/faq.html#my-config-file-is-being-ignored-mise-trust-issues)).

| Situation | Resolution |
| --- | --- |
| Accidentally denied trust | The file is added to the ignore list — remove its symlink from `~/.local/state/mise/ignored-configs/` |
| Symlinked configs (e.g. GNU Stow) | mise may track the symlink target; run `mise trust` against the actual file path |
| CI | In detected CI, configs are assumed trusted unless paranoid mode is enabled |
| Non-interactive, non-CI (IDE extensions, scripts without a TTY) | mise cannot prompt. Commands that directly load an untrusted `mise.toml` fail; commands discovering tracked configs may silently skip untrusted entries. Run `mise trust` beforehand or set `trusted_config_paths` |
| Global config not auto-trusted | `mise trust ~/.config/mise/config.toml` |

#### Tasks with `redact` env vars break `raw` output

If any env var has `redact = true`, tasks with `raw = true` appear to produce no output — mise intercepts stdout/stderr to redact, which conflicts with raw mode. **Workaround:** remove `redact` where it isn't needed, or accept no visible output from raw tasks while redactions are active.

#### Windows-specific problems

| Symptom | Explanation & fix |
| --- | --- |
| **PATH too long for `cmd.exe`** | A deep `mise.toml` hierarchy makes `mise x` produce a `Path` too long for `cmd.exe`, breaking mise tools that invoke it (e.g. `npm install`). Options: (1) set `MISE_INSTALLS_DIR` to something short like `C:\.mise-installs`; (2) use `powershell.exe`/`pwsh.exe`; (3) reorganize `mise.toml` files so each specifies only the tools it needs. Test with `mise x -- cmd.exe /d /s /c "where.exe where"` — success prints `C:\Windows\System32\where.exe`, failure prints `'where.exe' is not recognized…` |
| **Shims leaking into WSL** | With `windows_shim_mode = "file"`, mise writes an extension-less bash script next to each `<tool>.cmd` shim (for Git Bash/Cygwin). WSL's Windows-PATH interop exposes the shims dir at `/mnt/c/...` where everything looks executable. mise guards the script: on detecting WSL it drops the shims dir from `PATH` and runs a native Linux tool if installed, otherwise fails with a plain `<tool>: not found` instead of recursing. The **default `exe` mode is unaffected** (only native `.exe` files, which WSL ignores). To keep Windows shims out of WSL entirely, manage the tool with mise inside WSL, or set `appendWindowsPath = false` under `[interop]` in `/etc/wsl.conf` |
| **`shell = "bash -c"` task fails with `command not found` from PowerShell** | mise is resolving `bash` to the WSL launcher `C:\Windows\System32\bash.exe`. mise prefers a real POSIX bash (Git Bash/MSYS2) from standard install locations; otherwise set `MISE_BASH_PATH`. An **explicit** absolute path in a task's `shell` or in `windows_default_inline_shell_args` is honored as-is — the `MISE_BASH_PATH` override and auto-detection apply only when the shell is the bare name `bash`. The same resolution applies to the bash mise spawns for `[env] _.source` scripts |
| **Cygwin** | Detected by a `cygwin`/`cygwin64`/`cygwin32` path segment; mise converts PATH to `/cygdrive/c/...` instead of Git Bash's `/c/...`. Point `MISE_BASH_PATH` at your Cygwin bash |
| **Custom `cygdrive` mount root** | mise does not read `/etc/fstab`; set `MISE_CYGDRIVE_PREFIX` to match (works for Cygwin **and** Git Bash/MSYS2). Must be absolute — a relative value like `mnt` is rejected with a warning and the shell default is used. `MISE_CYGDRIVE_PREFIX=/` collapses to the Git Bash `/c/...` form |
| **VSCode extensions throwing `spawn EINVAL`** | Caused by a [Node.js security fix](https://nodejs.org/en/blog/vulnerability/april-2024-security-releases-2). The default `exe` shim mode resolves it; on older modes set [`windows_shim_mode`](https://mise.jdx.dev/configuration/settings.html#windows_shim_mode) to `exe`, `hardlink`, or `symlink` ([faq](https://mise.jdx.dev/faq.html#vscode-for-windows-extension-with-error-spawn-einval)) |

Windows support is described as "very basic": because Windows can't support asdf plugins, only **core and vfox** backends are usable there, which limits available tools ([troubleshooting](https://mise.jdx.dev/troubleshooting.html#windows-problems)).

Bash-path quoting on Windows — backslashes are literal, forward slashes also work, but a path with spaces must be quoted ([troubleshooting](https://mise.jdx.dev/troubleshooting.html)):

```toml
[tasks.build]
run = "echo hi"
shell = '"C:\Program Files\Git\bin\bash.exe" -c'
```

```toml
# scope the bash override to one project
[env]
MISE_BASH_PATH = "C:/tools/msys64/usr/bin/bash.exe"
```

---

### 1.14 Semantics worth internalizing

| Question | Answer |
| --- | --- |
| Does `node@20` mean the newest available 20.x? | **Usually no.** In config files and most commands it means the latest **installed** 20.x — check with `mise latest --installed node@20` or by reading the `~/.local/share/mise/installs/node/20` symlink. Exceptions that use the newest **available**: `mise install node@20`, `mise latest node@20`, `mise upgrade node@20` ([faq](https://mise.jdx.dev/faq.html#does-node-20-mean-the-newest-available-version-of-node)) |
| Same for `latest`? | Yes — in config files and most commands `latest` = latest **installed**. Newest available for `mise install node@latest`, `mise x node@latest -- node -v`, `mise latest node`. To move forward: `mise upgrade node`, or `mise upgrade --bump node` to also rewrite `mise.toml` ([faq](https://mise.jdx.dev/faq.html#does-latest-mean-the-newest-remote-version)) |
| `mise install` vs `mise use`? | `install` downloads/installs but does **not** touch any config file — the tool won't activate unless already listed. `use` installs **and** writes it to `mise.toml` (or `~/.config/mise/config.toml` with `-g`). `mise install node` with no version installs the latest if node isn't in config; bare `mise install` installs only what config lists ([faq](https://mise.jdx.dev/faq.html#what-is-the-difference-between-mise-install-and-mise-use)) |
| Where does `mise use` write? | The **nearest** `mise.toml` up the directory hierarchy — possibly a parent directory. `mise use -g` → `~/.config/mise/config.toml`; `mise use --path mise.toml node@22` targets a specific file. Check with `mise cfg` ([faq](https://mise.jdx.dev/faq.html#where-does-mise-use-write-to)) |
| `nodejs` vs `node`, `golang` vs `go`? | Aliased; they cannot be different plugins. When mise **writes** to `mise.toml` (`mise use`, `mise unuse`) it writes the canonical name — a `nodejs` entry becomes `node`, keeping its comments. `.tool-versions` files are unaffected and keep the asdf spellings ([faq](https://mise.jdx.dev/faq.html#what-is-the-difference-between-nodejs-and-node-or-golang-and-go)) |
| Are `.python-version` / `.node-version` read? | **Disabled by default.** Opt in per tool with [`idiomatic_version_file_enable_tools`](https://mise.jdx.dev/configuration/settings.html#idiomatic_version_file_enable_tools), e.g. `mise settings add idiomatic_version_file_enable_tools node` ([faq](https://mise.jdx.dev/faq.html#how-do-idiomatic-version-files-python-version-node-version-etc-work)) |
| Git shows `mise.toml` as untracked and I don't want to commit it | Prefer `mise.local.toml` plus a global gitignore. Otherwise: add to `.git/info/exclude` (local, uncommitted), to `.gitignore` (must be committed), or to the global gitignore via `core.excludesFile` (then `git add --force mise.toml` where needed) ([faq](https://mise.jdx.dev/faq.html)) |
| How do shorthand names map to repos? | Via [an index of shorthands](https://github.com/mise-plugins/registry) vendored into the codebase at [`registry/`](https://github.com/jdx/mise/blob/main/registry/), refreshed each mise release ([faq](https://mise.jdx.dev/faq.html#how-do-the-shorthand-plugin-names-map-to-repositories)) |
| Is mise secure? | "Providing a secure supply chain is incredibly important. mise already provides a more secure experience when compared to asdf." Users should vet the plugins they use. Details in [SECURITY.md](https://github.com/jdx/mise/blob/main/SECURITY.md) ([faq](https://mise.jdx.dev/faq.html#is-mise-secure), [troubleshooting](https://mise.jdx.dev/troubleshooting.html#is-mise-secure)) |

---

## 2. Configuration

mise's configuration model has four layers that are frequently confused. Keep them apart:

| Layer | What it is | Where it lives | Precedence rule |
| --- | --- | --- | --- |
| **Config files** | `mise.toml` and friends | project dirs, `~/.config/mise`, `/etc/mise` | nearest directory wins; within a directory, the list in [§2.1](#21-config-file-discovery-and-precedence) |
| **Config environments** | `MISE_ENV`-selected file variants | `mise.<env>.toml`, `mise.<env>.local.toml` | later env in the list wins; `.local` beats non-local |
| **Settings** | mise's own behaviour knobs | `[settings]` in any config file, `MISE_*` env vars, CLI flags | CLI flag > env var > config file |
| **Early-init settings** | settings that decide *which files are read* | `.miserc.toml` or `MISE_*` env var **only** | cannot be set in `mise.toml` |

Run `mise config ls` (alias `mise cfg`) to see the actual resolved load order on your machine — the docs explicitly recommend this over reasoning about the rules ([configuration](https://mise.jdx.dev/configuration.html)).

---

### 2.1 Config file discovery and precedence

#### 2.1.1 Filenames within one directory

Within a single directory, mise looks for these paths. **Top of the list overrides lower entries** ([configuration#mise-toml](https://mise.jdx.dev/configuration.html#mise-toml)):

| Rank | Path | Notes |
| --- | --- | --- |
| 1 (highest) | `mise.local.toml` | local-only; do **not** commit |
| 2 | `mise.toml` | the normal project config |
| 3 | `mise/config.toml` | |
| 4 | `.mise/config.toml` | |
| 5 | `.config/mise.toml` | groups config files under a common directory |
| 6 | `.config/mise/config.toml` | |
| 7 (lowest) | `.config/mise/conf.d/*.toml` | **all** files loaded, in alphabetical order |

Gotchas ([configuration#mise-toml](https://mise.jdx.dev/configuration.html#mise-toml)):

- Any path starting with `mise` may be a dotfile: `.mise.toml`, `.mise/config.toml`, `.mise.local.toml` all work.
- This list excludes [config environments](#22-config-environments-mise-env) (`mise.development.toml` etc.).
- The authoritative source is `LOCAL_CONFIG_FILENAMES` in [`src/config/mod.rs`](https://github.com/jdx/mise/blob/main/src/config/mod.rs); some legacy paths are omitted from the docs for brevity.

#### 2.1.2 Directory walk

Config files **recurse upwards**. mise walks from the current directory to the filesystem root (or to a `ceiling_paths` entry), collects every config file found, and merges them so that files closer to the cwd override files further away ([configuration#configuration-resolution-process](https://mise.jdx.dev/configuration.html#configuration-resolution-process)).

Full hierarchy, lowest precedence at the top ([configuration#visual-configuration-hierarchy](https://mise.jdx.dev/configuration.html#visual-configuration-hierarchy)):

```
/
├── etc/mise/                         # System-wide config (lowest precedence)
│   ├── conf.d/*.toml                 # System fragments, loaded alphabetically
│   ├── config.toml                   # System defaults
│   └── config.<env>.toml             # Env-specific system config (MISE_ENV or -E)
└── home/user/
    ├── .config/mise/
    │   ├── conf.d/*.toml             # User fragments, loaded alphabetically
    │   ├── config.toml               # Global user config
    │   ├── config.<env>.toml         # Env-specific user config
    │   ├── config.local.toml         # User-local overrides
    │   └── config.<env>.local.toml   # Env-specific user-local overrides
    └── work/
        ├── mise.toml                 # Work-wide settings
        └── myproject/
            ├── mise.local.toml       # Local overrides (git-ignored)
            ├── mise.toml             # Project config
            ├── mise.<env>.toml       # Env-specific project config
            ├── mise.<env>.local.toml # Env-specific project local overrides
            └── backend/
                └── mise.toml         # Service-specific config (highest precedence)
```

Worked example ([configuration#mise-toml](https://mise.jdx.dev/configuration.html#mise-toml)): with `~/src/myproj/mise.toml` declaring `node = '20'`, `python = '3.10'` and `~/src/myproj/backend/mise.toml` declaring `node = '18'`, `ruby = '3.1'`, then inside `backend/` you get node 18, python 3.10, ruby 3.1. Verify with `mise ls --current`.

#### 2.1.3 Merge behaviour differs per section

| Section | Merge semantics |
| --- | --- |
| `[tools]` | additive, with per-tool override |
| `[env]` | additive, with per-key override |
| `[tasks]` | **a task is completely replaced**, not merged field-by-field |
| `[settings]` | additive, with per-key override |

```toml
# [tools]  Global: node@18, python@3.11 | Project: node@20, go@1.21
#          Result: node@20, python@3.11, go@1.21

# [env]    Global: NODE_ENV=development | Project: NODE_ENV=production, API_URL=localhost
#          Result: NODE_ENV=production, API_URL=localhost

# [tasks]  Global: [tasks.test] = "npm test" | Project: [tasks.test] = "yarn test"
#          Result: "yarn test"  (completely replaces global)

# [settings] Global: experimental = true | Project: jobs = 4
#            Result: experimental = true, jobs = 4
```

([configuration#merge-behavior-by-section](https://mise.jdx.dev/configuration.html#merge-behavior-by-section))

#### 2.1.4 Which file gets written

`mise use`, `mise set`, and `mise unuse` write to the **lowest precedence file in the highest precedence directory** ([configuration#target-file-for-write-operations](https://mise.jdx.dev/configuration.html#target-file-for-write-operations)):

| Files present | `mise use node@22` writes to |
| --- | --- |
| `mise.toml` + `mise.local.toml` | `mise.toml` |
| `mise.toml` + `mise.production.toml` | `mise.toml` |
| only `mise.local.toml` | `mise.local.toml` |

```bash
# With both mise.toml and mise.local.toml present:
$ mise use node@22              # writes to mise.toml
$ mise use --env local node@20  # writes to mise.local.toml
$ mise set NODE_ENV=production  # writes to mise.toml
```

#### 2.1.5 Global and system config

- **Global:** `~/.config/mise/config.toml` — behaves like a local `mise.toml` but applies to every directory. Override the path with `MISE_GLOBAL_CONFIG_FILE`; override its `{{config_root}}` (default `$HOME`) with `MISE_GLOBAL_CONFIG_ROOT` ([configuration#global-config-config-mise-config-toml](https://mise.jdx.dev/configuration.html#global-config-config-mise-config-toml)).
- **System:** `/etc/mise/config.toml`, for defaults across all users. Directory overridable with `MISE_SYSTEM_CONFIG_DIR` (legacy alias `MISE_SYSTEM_DIR`), file path with `MISE_SYSTEM_CONFIG_FILE` ([configuration#system-config-etc-mise-config-toml](https://mise.jdx.dev/configuration.html#system-config-etc-mise-config-toml)).

Global/system config is **operator-owned**: it is implicitly trusted (see [§2.7](#27-trust-model)) and it is the only config that still applies under [safe mode](#29-safe-mode).

Representative global config ([configuration#global-config-config-mise-config-toml](https://mise.jdx.dev/configuration.html#global-config-config-mise-config-toml)):

```toml
# ~/.config/mise/config.toml
[tools]
# global tool versions go here
# you can set these with `mise use -g`
node = 'lts'
python = ['3.10', '3.11']

[settings]
# read version files used by other version managers, such as .nvmrc
idiomatic_version_file_enable_tools = ['node']

trusted_config_paths = [
    '~/work/my-trusted-projects',
]

env_file = '.env' # load env vars from a dotenv file, see `MISE_ENV_FILE`

[settings.status]
show_env = false
show_tools = false

# "_" is a special key for information you'd like to put into mise.toml that mise will never parse
[_]
foo = "bar"
```

#### 2.1.6 `.miserc.toml` — early-init config

Some settings decide *which config files get loaded*, so they cannot live in `mise.toml`. They go in `.miserc.toml`, which is read very early, before config discovery ([configuration/environments#setting-mise-env-in-miserc-toml](https://mise.jdx.dev/configuration/environments.html#setting-mise-env-in-miserc-toml)).

Search order (highest precedence first):

1. `.miserc.toml` and `.config/miserc.toml` in the current directory and its parents
2. `~/.config/mise/miserc.toml` (global)
3. `/etc/mise/miserc.toml` (system)

```toml
# .miserc.toml
env = ["development"]

# Stop config search at $HOME
ceiling_paths = ["{{ env.HOME }}"]

# Or use the XDG config home variable
ignored_config_paths = ["{{ xdg_config_home }}/mise/shared.toml"]
```

`.miserc.toml` supports [Tera templates](https://mise.jdx.dev/templates.html#miserc-template-support), but **only OS-level context is available** (env vars, `cwd`, `arch()`, `os()`, …) — `mise.toml` settings are not loaded yet.

**Early-init settings** (settable only via `.miserc.toml`, `MISE_*` env var, or CLI flag — setting them in `mise.toml` silently does nothing):

| Setting | Reason | Source |
| --- | --- | --- |
| `env` / `MISE_ENV` | determines which config files to load | ([settings#env](https://mise.jdx.dev/configuration/settings.html#env)) |
| `auto_env` | determines platform config file discovery | ([settings#auto_env](https://mise.jdx.dev/configuration/settings.html#auto_env)) |
| `ceiling_paths` | bounds the upward directory walk | ([settings#ceiling_paths](https://mise.jdx.dev/configuration/settings.html#ceiling_paths)) |
| `ignored_config_paths` | excludes discovered configs | ([settings#ignored_config_paths](https://mise.jdx.dev/configuration/settings.html#ignored_config_paths)) |
| `override_config_filenames` | replaces the filename list entirely | ([settings#override_config_filenames](https://mise.jdx.dev/configuration/settings.html#override_config_filenames)) |
| `override_tool_versions_filenames` | replaces `.tool-versions` discovery | ([settings#override_tool_versions_filenames](https://mise.jdx.dev/configuration/settings.html#override_tool_versions_filenames)) |
| `default_config_filename`, `default_tool_versions_filename`, `global_config_file`, `global_config_root`, `system_config_file` | documented as "must be an env var" | ([settings](https://mise.jdx.dev/configuration/settings.html#default_config_filename)) |

`ceiling_paths` follows Git's `GIT_CEILING_DIRECTORIES` semantics: config files **in** the ceiling directory itself are excluded. With `MISE_CEILING_PATHS="/home/user"`, `/home/user/mise.toml` is *not* loaded but `/home/user/projects/myapp/mise.toml` is ([settings#ceiling_paths](https://mise.jdx.dev/configuration/settings.html#ceiling_paths)).

---

### 2.2 Config environments (`MISE_ENV`)

Separate `mise.toml` variants in the *same* directory, selected by an environment name ([configuration/environments](https://mise.jdx.dev/configuration/environments.html)).

Three ways to set it:

| Method | Example |
| --- | --- |
| CLI flag | `mise -E development ...` / `mise --env development ...` |
| Environment variable | `MISE_ENV=development` |
| `.miserc.toml` | `env = ["development"]` |

mise then looks for `mise.{MISE_ENV}.toml` in the current directory, parent directories, and `MISE_CONFIG_DIR`.

**Precedence within a directory** (top overrides bottom):

```
mise.{MISE_ENV}.local.toml
mise.local.toml
mise.{MISE_ENV}.toml
mise.toml
```

Multiple environments: `MISE_ENV=ci,test` — comma separated, **read in order with the last taking precedence** ([settings#env](https://mise.jdx.dev/configuration/settings.html#env)).

Other rules ([configuration/environments](https://mise.jdx.dev/configuration/environments.html)):

- `MISE_ENV` **cannot** be set in `mise.toml` — it decides which files to load in the first place.
- Paths like `mise/config.{MISE_ENV}.toml` and `.config/mise.{MISE_ENV}.toml` also work, following the [§2.1.1](#211-filenames-within-one-directory) ordering.
- `MISE_OVERRIDE_CONFIG_FILENAMES`, when set, replaces all of this.
- Add `mise.local.toml` and `mise.*.local.toml` to `.gitignore`.
- Write target selection is different — see [`mise use`](https://mise.jdx.dev/cli/use.html) and [§2.1.4](#214-which-file-gets-written).

#### 2.2.1 Platform environments (`auto_env`)

With `auto_env` enabled, mise treats platform identity as implicit config environments ([configuration/environments#platform-environments](https://mise.jdx.dev/configuration/environments.html#platform-environments)):

| Environment | Values |
| --- | --- |
| `{os_family}` | `unix` (not defined on Windows — use `windows`) |
| `{os}` | `linux`, `macos`, `windows` |
| `{os}-{arch}` | e.g. `linux-x64`, `macos-arm64`, `windows-x64` |

Architectures use mise's remapped names: `x86_64` → `x64`, `aarch64` → `arm64`.

This auto-loads `mise.windows.toml`, `mise.macos-arm64.toml`, `mise.unix.toml`, and selects matching lockfiles like `mise.windows.lock`. All the usual config locations and `.local.toml` variants apply.

Full precedence (later overrides earlier):

```
unix  <  {os}  <  {os}-{arch}  <  explicit MISE_ENV entries
```

Platform environments affect **only** config-file discovery and lockfile selection. They are *not* added to `MISE_ENV`: the `mise_env` template variable and the `MISE_ENV` passed to subprocesses/tasks reflect explicit environments only.

**Rollout:** `auto_env` is currently **disabled by default**. From mise `2027.6.0` it defaults to enabled; from `2026.12.0` until then mise warns when it finds a platform-specific config file that would be newly loaded. Silence/opt in explicitly:

```toml
# .miserc.toml
auto_env = true  # adopt the new behavior now
# or
auto_env = false # keep the old behavior and silence the warning
```

`auto_env` is an early-init setting — `.miserc.toml` or `MISE_AUTO_ENV` only.

#### 2.2.2 Environment-specific lockfiles

Each config variant gets its own lockfile ([dev-tools/mise-lock#environment-specific-lockfiles](https://mise.jdx.dev/dev-tools/mise-lock.html#environment-specific-lockfiles)):

| Config file | Lockfile |
| --- | --- |
| `mise.toml` | `mise.lock` |
| `mise.test.toml` | `mise.test.lock` |
| `mise.staging.toml` | `mise.staging.lock` |
| `mise.local.toml` | `mise.local.lock` |
| `mise.test.local.toml` | `mise.test.local.lock` |

Commit `mise.lock` and `mise.<env>.lock`; gitignore `mise.local.lock` and `mise.<env>.local.lock`. Lockfile depth is covered in the lockfile section of this guide; the config-file-relevant facts are: lockfiles are **not** created automatically (`touch mise.lock && mise install`, or run `mise lock`), and the naming rule is "same name as the config file with `.toml` → `.lock`" ([settings#lockfile](https://mise.jdx.dev/configuration/settings.html#lockfile)).

> **Warning (from the docs):** all mise settings are global in scope. Setting `locked = true` in a project `mise.toml` applies to **all** tool resolution, including tools from `~/.config/mise/config.toml`. Run `mise lock -g` to generate a global lockfile if you see warnings about global tools ([dev-tools/mise-lock#strict-lockfile-mode](https://mise.jdx.dev/dev-tools/mise-lock.html#strict-lockfile-mode)).

---

### 2.3 Top-level tables in `mise.toml`

The complete set of top-level keys, taken from the published JSON schema ([schema/mise.json](https://github.com/jdx/mise/blob/main/schema/mise.json), also served at <https://mise.en.dev/schema/mise.json>):

| Key | Kind | Purpose |
| --- | --- | --- |
| `tools` | table | dev tools to use |
| `env` | table | environment variables to set |
| `tasks` | table | task runner tasks |
| `task_config` | table | configuration for task execution and management |
| `task_templates` | table | task templates extendable by tasks via `extends` |
| `settings` | table | mise settings |
| `vars` | table | variables for use in config templates |
| `hooks` | table | hooks to run on events like `cd`, `enter`, `leave` |
| `watch_files` | array of tables | files to watch and scripts to run on change |
| `redactions` | array | env or vars keys to redact from logs |
| `plugins` | table | plugin shortname → repo URL |
| `tool_alias` | table | tool version aliases (formerly `alias`) |
| `alias` | table | **deprecated** name for `tool_alias` |
| `shell_alias` | table | shell aliases set on directory entry |
| `min_version` | string/table | minimum mise version required |
| `monorepo_root` | bool | marks this config as a monorepo root |
| `monorepo` | table | monorepo task-discovery / lockfile configuration |
| `deps` | table | configure deps providers |
| `oci` | table | configuration for `mise oci build` |
| `dotfiles` | table | dotfiles applied with `mise bootstrap`, keyed by target path |
| `bootstrap` | table | machine-global bootstrapping (system packages, repos, macOS defaults, launchd agents, …) |
| `env_file` / `dotenv` | — | **deprecated**, use `env._.file`; removal in mise 2027.4.0 |
| `env_path` | — | **deprecated**, use `env._.path`; removal in mise 2027.4.0 |
| `_` | table | free-form data mise never parses |

A minimal, typical file ([configuration](https://mise.jdx.dev/configuration.html)):

```toml
[tools]
node = '24'
python = '3.12'

[env]
NODE_ENV = 'development'

[tasks.dev]
run = 'npm run dev'

[tasks.test]
run = 'pytest'
```

#### 2.3.1 `[tools]`

Beyond a plain version string, each entry accepts options ([configuration#tools-dev-tools](https://mise.jdx.dev/configuration.html#tools-dev-tools)):

| Option | Meaning |
| --- | --- |
| `os` | restrict installation to certain operating systems |
| `depends` | install order relative to other tools **in this config only**; vfox plugin hook dependencies belong in the plugin's `metadata.lua` |
| `install_env` | environment vars used during install and tool-level `postinstall` |
| `postinstall` | command run after that specific tool finishes installing |
| `minimum_release_age` | per-tool override of the global setting ([security#minimum-release-age](https://mise.jdx.dev/security.html#minimum-release-age)) |
| `prerelease` | opt into pre-release versions (honored by `github:`, `forgejo:`, `aqua:`, `dotnet:`) ([settings#prereleases](https://mise.jdx.dev/configuration/settings.html#prereleases)) |

```toml
[tools]
node = { version = "22", postinstall = "corepack enable" }
```

```toml
[settings]
minimum_release_age = "7d"  # default for all tools

[tools.trivy]
version = "latest"
minimum_release_age = "1d"  # trivy updates are time-sensitive, use a shorter window
```

#### 2.3.2 `[env]`

Environment variables, with directive keys under `_`. Covered in depth in the environments section of this guide; see [environments](https://mise.jdx.dev/environments/). Config-relevant notes:

- `env_shell_expand` (default `true`) enables `$FOO` / `${FOO}` / `${FOO:-default}` expansion **after** Tera rendering; undefined vars stay literal and warn — use `${MISSING:-}` to suppress ([settings#env_shell_expand](https://mise.jdx.dev/configuration/settings.html#env_shell_expand)).
- Values can be marked `redact = true`, and can be made tool-aware with `tools = true` ([environments#redactions](https://mise.jdx.dev/environments/index.html#redactions)).
- Top-level `env_file` / `dotenv` / `env_path` are deprecated in favour of `env._.file` / `env._.path` ([schema/mise.json](https://github.com/jdx/mise/blob/main/schema/mise.json)).

#### 2.3.3 `[tasks]`, `[task_config]`, `[task_templates]`

Tasks themselves are covered in the tasks section of this guide ([tasks](https://mise.jdx.dev/tasks/)). Config-file-level facts:

- A task in a nearer config **completely replaces** the same-named task from a further config — no field merging ([configuration#merge-behavior-by-section](https://mise.jdx.dev/configuration.html#merge-behavior-by-section)).
- `[task_config]` applies to all tasks included by that config file or sharing its root directory. `cascade = true` extends it to descendant config roots; a descendant may set `cascade = false` to stop inheriting ([tasks/task-configuration#task-config-options](https://mise.jdx.dev/tasks/task-configuration.html#task-config-options)).

| `[task_config]` key | Meaning |
| --- | --- |
| `cascade` | inherit this section into descendant config roots |
| `dir` | default working directory for tasks (`dir = "{{cwd}}"`) |
| `shell` | default shell for tasks in this scope; a task's own `shell` wins |
| `includes` | toml files and file-task directories to search; **replaces** the defaults for that scope |
| `cache` *(experimental)* | default artifact-cache config for cache-eligible tasks |
| `global_env` *(experimental)* | ambient var names added to every cache-enabled task's cache key |
| `global_pass_through_env` *(experimental)* | ambient vars preserved without entering cache keys |
| `global_inputs` *(experimental)* | source paths/globs added to every task in scope |
| `input_groups` *(experimental)* | reusable named source groups, referenced as `@group:<name>` |

```toml
[task_config]
cascade = true
shell = "bash -c"
global_inputs = ["mise.toml", ".github/tool-versions", "@group:lockfiles"]

[task_config.input_groups]
lockfiles = ["Cargo.lock", "pnpm-lock.yaml"]

[task_config.cache]
enabled = true
env = ["NODE_ENV", "CI"]
command_inputs = ["node --version"]
```

`includes` gotcha: entries are evaluated in order and **the last entry defining a task name wins**, uniformly across directory, toml-file, and `git::` includes ([tasks/task-configuration#task-config-includes](https://mise.jdx.dev/tasks/task-configuration.html#task-config-includes)):

```toml
[task_config]
includes = [
    "git::https://github.com/myorg/shared-tasks.git//tasks", # remote task…
    ".mise/tasks",                                           # …is overridden by the local one with the same name
]
```

#### 2.3.4 `[settings]`

See [§2.5](#25-setting-settings-cli-env-and-config) and the reference in [§2.6](#26-settings-reference). Sub-tables like `[settings.status]`, `[settings.sandbox]`, `[settings.python]` are the config-file form of dotted names like `status.show_env`.

#### 2.3.5 `[plugins]`

Adds or overrides plugin shortnames. **Only affects new plugin installations** — existing plugins keep whatever URL they were installed with ([configuration#plugins-specify-custom-plugin-repository-urls](https://mise.jdx.dev/configuration.html#plugins-specify-custom-plugin-repository-urls)).

```toml
[plugins]
elixir = "https://github.com/my-org/mise-elixir.git"
node = "https://github.com/my-org/mise-node.git#DEADBEEF" # supports specific gitref
"vfox-backend:myplugin" = "https://github.com/jdx/vfox-npm"
```

- The type prefix (`asdf:`, `vfox:`, `vfox-backend:`) is optional; omitted, mise clones first and detects the type from installed plugin files.
- Local plugin directories work. Absolute paths and `~/`-paths are used directly; explicit relative paths (`./`, `../`) resolve against the **config root of the declaring file**. Local plugins are symlinked like `mise plugins link`, so edits are live. `file://` sources are still cloned as Git repos.
- Run `mise plugins install --force <NAME>` to replace an existing plugin with the configured source.
- For a one-off install prefer `mise plugin install <NAME> <GIT_URL>`; use `[plugins]` when the location/revision should be shared with the team.
- This **replaces the deprecated `settings.shorthands_file` / `MISE_SHORTHANDS_FILE`** mechanism — move the same `shortname = "backend-or-url"` rows into `[plugins]`.

#### 2.3.6 `[tool_alias]` (formerly `[alias]`) and `[shell_alias]`

`[alias]` was renamed to `[tool_alias]` to distinguish it from `[shell_alias]`; the old key still works but is **deprecated** ([configuration#tool-alias-tool-version-aliases](https://mise.jdx.dev/configuration.html#tool-alias-tool-version-aliases)).

```toml
[tool_alias.node.versions]
my_custom_node = '20'
```

This makes `mise install node@my_custom_node` install node 20.x and also creates a symlink:

```sh
~/.local/share/mise/installs/node/20 -> ./20.x.x
```

`[shell_alias]` defines aliases set on directory entry and unset on leave ([configuration#shell-alias-shell-aliases](https://mise.jdx.dev/configuration.html#shell-alias-shell-aliases), [shell-aliases](https://mise.jdx.dev/shell-aliases.html)):

```toml
[shell_alias]
ll = "ls -la"
gs = "git status"
dev = "npm run dev"
```

Managed from the CLI with `mise tool-alias {get,ls,set,unset}` and `mise shell-alias {get,ls,set,unset}` ([cli](https://mise.jdx.dev/cli/)).

#### 2.3.7 `[hooks]`

Hooks require the `mise activate` shell hook — **except** `preinstall` and `postinstall` ([hooks](https://mise.jdx.dev/hooks.html)).

| Hook | Fires |
| --- | --- |
| `cd` | any directory change |
| `enter` | project entered (not re-fired when cd-ing within it) |
| `leave` | project left |
| `preinstall` | before tools are installed; no `mise activate` needed |
| `postinstall` | after tools are installed; no `mise activate` needed |

```toml
[hooks]
cd = "echo 'I changed directories'"
enter = "echo 'I entered the project'"
leave = "echo 'I left the project'"
preinstall = "echo 'I am about to install tools'"
postinstall = { run = "echo 'installed'", shell = "bash -c" }
```

Semantics worth knowing:

- A bare string is shorthand for `{ run = "..." }`. `run` and `run_windows` must be **strings** — `run = ["a", "b"]` is not supported.
- `run_windows` is used on Windows when set; a hook with only `run_windows` is skipped elsewhere.
- One `run` entry = one subprocess. For multiple spawned commands use multiple hook entries; for multiple shell lines in one process use a multiline `run` string.
- `run` hooks use the configured inline shell ([`unix_default_inline_shell_args`](https://mise.jdx.dev/configuration/settings.html#unix_default_inline_shell_args) / [`windows_default_inline_shell_args`](https://mise.jdx.dev/configuration/settings.html#windows_default_inline_shell_args)); override with `shell = "bash -c"`.
- **Current-shell hooks** use `script`/`scripts` with `shell` as a shell *name* (`bash`, `zsh`, `fish`), not an inline command. mise only emits the script when the active `mise activate` shell matches.
- For `preinstall`/`postinstall`, `script`/`scripts` are **deprecated legacy aliases** for `run`; a `shell` set alongside them is ignored (with a warning).
- Hooks may reference tasks: `enter = { task = "setup" }`, executed as a subprocess via `mise run`.
- A no-op `mise install` (nothing to install) **still runs** `postinstall`.

Environment provided to hooks: `MISE_ORIGINAL_CWD`, `MISE_PROJECT_ROOT`, `MISE_PREVIOUS_DIR` (only on a directory change), and `MISE_INSTALLED_TOOLS` (postinstall only; a JSON array, `[]` on a no-op install).

> Docs warning: hooks do **no cleanup on leave** the way `[env]` does. You are literally executing shell code that mise cannot track ([hooks#shell-hooks](https://mise.jdx.dev/hooks.html#shell-hooks)).

#### 2.3.8 `[[watch_files]]`

Requires `mise activate` ([hooks#watch-files-hook](https://mise.jdx.dev/hooks.html#watch-files-hook)).

```toml
[[watch_files]]
patterns = ["src/**/*.rs"]
run = "cargo fmt"

[[watch_files]]
patterns = ["*.js"]
run = "eslint --fix ."
shell = "bash -c"

[[watch_files]]
patterns = ["uv.lock"]
task = "sync-deps"
```

Each entry must have **either** `run` **or** `task`, not both. `shell` applies only to `run`. The hook receives `MISE_WATCH_FILES_MODIFIED`: a colon-separated list of modified files, with colons backslash-escaped.

#### 2.3.9 `[vars]`

Values shared between TOML tasks and other Tera-rendered config (tool versions/options). Unlike `[env]`, vars are **not exported** to task processes. Reference with `{{vars.NAME}}` ([tasks/task-configuration#vars](https://mise.jdx.dev/tasks/task-configuration.html#vars)).

```toml
[vars]
e2e_args = '--headless'

[tasks.test]
run = './scripts/test-e2e.sh {{vars.e2e_args}}'
```

Vars accept the value-producing directive forms from `[env]`:

```toml
[vars]
e2e_args = { default = "--headless" }
api_token = { required = "Set api_token in mise.local.toml" }
secret_arg = { value = "--token=abc123", redact = true }
_.file = ".env"
```

- `default` reads a **process** environment variable of the same name when set and non-empty; values from `[env]` are not consulted.
- `required` must be satisfied by the process environment or a later config file such as `mise.local.toml`.
- `redact = true` hides the value from task output. [Secrets](https://mise.jdx.dev/environments/secrets/) work as vars.
- Vars merge across config files like other config; later files override.
- Tasks may define task-local `vars = { ... }` that override config vars for that task.
- As of this writing vars are **only supported in TOML tasks**, not file tasks.

#### 2.3.10 `redactions`

A top-level array of glob-ish patterns marking env/vars keys as sensitive ([environments#redactions](https://mise.jdx.dev/environments/index.html#redactions)):

```toml
redactions = ["SECRET_*", "*_TOKEN", "PASSWORD"]
[env]
SECRET_KEY = "sensitive_value"
API_TOKEN = "token_123"
PASSWORD = "my_password"
```

Gotchas:

- Redaction works by intercepting task output line-by-line, so it **requires a non-`raw` output mode**. Tasks with `raw = true` bypass interception entirely and cannot be redacted.
- `mise run` defaults to the `replacing` output mode (spinner). In CI prefer `prefix` or `interleave` so full logs are visible *and* redacted.
- `mise env --redacted`, `--values`, and `--redacted --values` inspect redacted variables.
- [mise-action](https://github.com/jdx/mise-action) automatically redacts values marked `redact = true` or matched by `redactions`.

#### 2.3.11 `min_version`

Hard (error) or soft (warn) minimum ([configuration#minimum-mise-version](https://mise.jdx.dev/configuration.html#minimum-mise-version)):

```toml
# (equivalent to hard)
min_version = '2024.11.1'

# new object form
min_version = { hard = '2024.11.1' }

# soft recommendation
min_version = { soft = '2024.11.1' }

# both
min_version = { hard = '2024.11.1', soft = '2024.9.0' }
```

Unmet soft minimum → warning plus self-update instructions when available. Unmet hard minimum → error plus self-update instructions. The docs argue explicitly for `min_version` over pinning users to one mise executable: pinning "is like preventing `apt update` or `brew update` from refreshing package metadata".

#### 2.3.12 `monorepo_root` / `[monorepo]`

```toml
monorepo_root = true
```

Enables namespaced task paths (`//projects/frontend:build`), lets subdirectory tasks use parent-config tools, defers loading until needed, and — importantly for the trust model — **implicitly trusts all descendant config files when the root is trusted** ([configuration#monorepo-root](https://mise.jdx.dev/configuration.html#monorepo-root)).

`[monorepo] lockfile = true` opts into a single root lockfile (`mise.lock`, `mise.ci.lock`, `mise.local.lock`). Monorepos using `mise*.lock` start warning in mise `2026.12.0`; unset defaults to root lockfiles in `2027.6.0`. Pin the old layout with `[monorepo] lockfile = false` ([dev-tools/mise-lock#monorepos](https://mise.jdx.dev/dev-tools/mise-lock.html#monorepos)).

#### 2.3.13 `[_]`

`_` is a special key for arbitrary data that mise will **never** parse ([configuration#global-config-config-mise-config-toml](https://mise.jdx.dev/configuration.html#global-config-config-mise-config-toml)):

```toml
[_]
foo = "bar"
```

#### 2.3.14 JSON schema

- `mise.toml` schema: [schema/mise.json](https://github.com/jdx/mise/blob/main/schema/mise.json) or <https://mise.en.dev/schema/mise.json>; also published to the [JSON Schema Store](https://www.schemastore.org/).
- Included task files use a separate schema: <https://mise.en.dev/schema/mise-task.json>.
- Editors (VSCode, IntelliJ, neovim via SchemaStore.nvim) can load it for completion/validation ([configuration#mise-toml-schema](https://mise.jdx.dev/configuration.html#mise-toml-schema)).

---

### 2.4 `.tool-versions` and idiomatic version files

#### 2.4.1 `.tool-versions`

asdf's config file, fully usable by mise but less flexible — recommended only for existing asdf setups or mixed teams ([configuration#tool-versions](https://mise.jdx.dev/configuration.html#tool-versions)):

```text
node        20.0.0       # comments are allowed
ruby        3            # can be fuzzy version
shellcheck  latest       # also supports "latest"
jq          1.6
erlang      ref:master   # compile from vcs ref
go          prefix:1.19  # uses the latest 1.19.x version—needed in case "1.19" is an exact match
shfmt       path:./shfmt # use a custom runtime
node        lts          # use lts version of node (not supported by all plugins)

node        sub-2:lts      # subtract 2 from the resolved major version (e.g.: 20 becomes 18)
python      sub-0.1:latest # subtract 1 from the resolved minor version (e.g.: 3.11 becomes 3.10)
```

Filename control: `default_tool_versions_filename` (`MISE_DEFAULT_TOOL_VERSIONS_FILENAME`, default `.tool-versions`) changes which name is read but does **not** ignore `.tool-versions`; `override_tool_versions_filenames` replaces the list entirely and accepts `none` to disable `.tool-versions` completely ([settings#override_tool_versions_filenames](https://mise.jdx.dev/configuration/settings.html#override_tool_versions_filenames)).

#### 2.4.2 Version scopes (both `mise.toml` and `.tool-versions`)

| Scope | Meaning |
| --- | --- |
| `ref:<SHA>` | compile from a VCS (usually git) ref |
| `prefix:<PREFIX>` | latest version matching the prefix — needed for Go, where `1.20` matches only `1.20` exactly but `prefix:1.20` matches `1.20.1`, `1.20.2`, … |
| `path:<PATH>` | use a custom compiled version at that path (e.g. re-use Homebrew: `path:/opt/homebrew/opt/node@20`) |
| `sub-<PARTIAL>:<ORIG>` | resolve `ORIG`, subtract the numeric components of `PARTIAL` from the corresponding resolved components, then resolve the result as a prefix |

`sub-` is **numeric version arithmetic, not "the Nth previous release"**: `sub-2:lts` resolves `lts` and subtracts 2 from its major (20 → 18); `sub-0.1:latest` subtracts 1 from the resolved minor (3.11 → 3.10) ([configuration#scopes](https://mise.jdx.dev/configuration.html#scopes)).

#### 2.4.3 Idiomatic version files

Language-specific files like `.node-version` and `.python-version`, ideal for projects that must not force mise/asdf on everyone. They support aliases — an `.nvmrc` containing `lts/hydrogen` works in both mise and nvm ([configuration#idiomatic-version-files](https://mise.jdx.dev/configuration.html#idiomatic-version-files)).

**These are disabled by default in mise** (rationale: [jdx/mise#4345](https://github.com/jdx/mise/discussions/4345)). Enable per tool:

```sh
mise settings add idiomatic_version_file_enable_tools python
mise settings add idiomatic_version_file_enable_tools node
```

Disable an individual file for a tool without disabling the tool or the file for others — `tool:filename` pairs:

```sh
# keep .nvmrc for node, but stop node reading devEngines.runtime from package.json
mise settings add idiomatic_version_file_disable_files node:package.json
```

Supported files ([configuration#idiomatic-version-files](https://mise.jdx.dev/configuration.html#idiomatic-version-files)):

| Plugin | Idiomatic files |
| --- | --- |
| atmos | `.atmos-version` |
| bun | `.bun-version`, `package.json` |
| chezmoi | `.chezmoiversion` |
| cmake | `CMakeLists.txt` |
| crystal | `.crystal-version` |
| dagger | `dagger.json` |
| deno | `.deno-version`, `package.json` |
| dotnet | `global.json` |
| earthly | `Earthfile` |
| elixir | `.exenv-version` |
| go | `.go-version`, `go.mod` |
| golangci-lint | `.golangci.yml`, `.golangci.yaml`, `.golangci.toml`, `.golangci.json` |
| goreleaser | `.config/goreleaser.yml`, `.config/goreleaser.yaml`, `.goreleaser.yml`, `.goreleaser.yaml`, `goreleaser.yml`, `goreleaser.yaml` |
| java | `.java-version`, `.sdkmanrc` |
| lefthook | `lefthook.{yml,yaml,toml,json,jsonc}`, `.lefthook.{yml,yaml,toml,json,jsonc}`, `.config/lefthook.{yml,yaml,toml,json,jsonc}` |
| node | `.nvmrc`, `.node-version`, `package.json` |
| npm | `package.json` |
| opentofu | `.opentofu-version` |
| packer | `.packer-version` |
| perl | `.perl-version` |
| pixi | `pixi.toml`, `pyproject.toml` |
| pnpm | `package.json` |
| pre-commit | `.pre-commit-config.yaml` |
| python | `.python-version`, `.python-versions` |
| ruby | `.ruby-version`, `Gemfile` |
| ruff | `ruff.toml`, `.ruff.toml` |
| rust | `rust-toolchain.toml` |
| swift | `.swift-version` |
| task | `Taskfile.yml`, `Taskfile.yaml`, `taskfile.yml`, `taskfile.yaml` |
| terraform | `.terraform-version` |
| terragrunt | `.terragrunt-version` |
| terramate | `.terramate-version` |
| yarn | `.yvmrc`, `package.json` |
| zig | `.zig-version` |

Additional semantics:

- Registry-backed tools can declare `version_regex`, `version_json_path`, or `version_expr` parsers (same as the [HTTP backend](https://mise.jdx.dev/dev-tools/backends/http.html#version-listing)), so `aqua:`/`github:` tools support JSON manifests without an asdf/vfox plugin.
- Values that declare a *minimum* or a config-format major are treated as normal version requests: CMake `3.25` → latest matching 3.25; GoReleaser config `version: 2` → latest 2.x.
- `go.mod`: `toolchain goX.Y.Z` (an exact pin) is used when present; otherwise `go X.Y` — which declares only a minimum — resolves to the latest matching patch (`go 1.22` → latest `1.22.x`).
- There is a small cost to discovering/parsing these files. Registry parsers run in-process; plugin-provided files may invoke the plugin's parser. Results are [cached](https://mise.jdx.dev/cache-behavior.html).
- Terminology: asdf called these "legacy version files"; mise renamed them "idiomatic" because they are not asdf-specific (`.nvmrc` being the notable tool-specific exception).

> **Uncertainty / version note:** the `legacy_version_file` and `legacy_version_file_disable_tools` settings referenced in older material no longer appear in the published settings reference. They still exist upstream but are marked `hide = true` and deprecated in favour of `idiomatic_version_file*` ([settings.toml](https://github.com/jdx/mise/blob/main/settings.toml)). Use `idiomatic_version_file_enable_tools` / `idiomatic_version_file_disable_files`.

---

### 2.5 Setting settings: CLI, env, and config

Settings can be set three ways ([configuration/settings](https://mise.jdx.dev/configuration/settings.html)):

1. `mise settings key=value` (or `mise settings set key value`)
2. Editing `[settings]` in the global (`~/.config/mise/config.toml`) or a local config file
3. `MISE_*` environment variables

Some also have global CLI flags. **CLI flag > environment variable > config file**, and among config files the normal file precedence from [§2.1](#21-config-file-discovery-and-precedence) applies (settings merge additively with per-key override).

#### 2.5.1 Naming convention

| Config form | Dotted CLI form | Env var |
| --- | --- | --- |
| `[settings] jobs = 4` | `jobs` | `MISE_JOBS=4` |
| `[settings.status] show_env = true` | `status.show_env` | `MISE_STATUS_MESSAGE_SHOW_ENV=1` |
| `[settings.node] mirror_url = "…"` | `node.mirror_url` | `MISE_NODE_MIRROR_URL` |
| `[settings.sandbox] deny_all = true` | `sandbox.deny_all` | `MISE_SANDBOX_DENY_ALL=1` |

Env var names are **not** always a mechanical `MISE_` + uppercase of the dotted key — `status.show_env` → `MISE_STATUS_MESSAGE_SHOW_ENV`, `python.venv_stdlib` → `MISE_VENV_STDLIB`, `ruby.ruby_build_opts` → `MISE_RUBY_BUILD_OPTS`, `node.nvm_dir` → `NVM_DIR`, `rust.cargo_home` → `MISE_CARGO_HOME`. Always check the [reference](https://mise.jdx.dev/configuration/settings.html).

List separators differ per setting: most `string[]` settings are **comma** separated in the env var, path-like ones (`ceiling_paths`, `ignored_config_paths`, `trusted_config_paths`, `shared_install_dirs`, `task.disable_paths`) use the **OS path separator** (`:` on Unix, `;` on Windows), and `override_config_filenames` / `override_tool_versions_filenames` / `python.venv_create_args` / `python.uv_venv_create_args` are **colon** separated.

#### 2.5.2 `mise settings` CLI

`mise settings` shows current settings — the contents of `~/.config/mise/config.toml`. Aliases are stored there too but managed separately with `mise tool-alias` ([cli/settings](https://mise.jdx.dev/cli/settings.html)).

| Command | Effect |
| --- | --- |
| `mise settings` | list settings |
| `mise settings <SETTING>` | show one setting |
| `mise settings <SETTING>=<VALUE>` | set one setting |
| `mise settings set [-l] <SETTING> [VALUE]` | add/update (alias `create`) ([cli/settings/set](https://mise.jdx.dev/cli/settings/set.html)) |
| `mise settings add [-l] <SETTING> [VALUE]` | **append** to an array setting ([cli/settings/add](https://mise.jdx.dev/cli/settings/add.html)) |
| `mise settings get [-l] <SETTING>` | print one value ([cli/settings/get](https://mise.jdx.dev/cli/settings/get.html)) |
| `mise settings ls [FLAGS] [SETTING]` | list (alias `list`) ([cli/settings/ls](https://mise.jdx.dev/cli/settings/ls.html)) |
| `mise settings unset [-l] <KEY>` | clear (aliases `rm`, `remove`, `delete`, `del`) ([cli/settings/unset](https://mise.jdx.dev/cli/settings/unset.html)) |

Flags: `-a/--all` (list all settings), `-J/--json`, `-T/--toml`, `--json-extended` (JSON **with sources** — the way to find out *where* a value came from), `-l/--local` (target the local config file instead of the global one).

```bash
# list all settings
$ mise settings

# get the value of the setting "always_keep_download"
$ mise settings always_keep_download

# set the value of the setting "always_keep_download" to "true"
$ mise settings always_keep_download=true

# set the value of the setting "node.mirror_url" to "https://npmmirror.com/mirrors/node"
$ mise settings node.mirror_url https://npmmirror.com/mirrors/node

# append to an array setting
$ mise settings add disable_hints python_multi

# list one group
$ mise settings ls python
```

#### 2.5.3 `mise config` CLI

`mise config` (alias `mise cfg`) manages config files ([cli/config](https://mise.jdx.dev/cli/config.html)).

| Command | Effect |
| --- | --- |
| `mise config ls [-J] [--no-header] [--tracked-configs]` | list config files in use, **in precedence order** ([cli/config/ls](https://mise.jdx.dev/cli/config/ls.html)) |
| `mise config get [-f FILE] [KEY]` | read a value out of a `mise.toml` ([cli/config/get](https://mise.jdx.dev/cli/config/get.html)) |
| `mise config set [-f FILE] [-t TYPE] <KEY> [VALUE]` | write a value into a `mise.toml` ([cli/config/set](https://mise.jdx.dev/cli/config/set.html)) |

`-f/--file` defaults to the nearest `mise.toml`. `-t/--type` is one of `infer` (default), `string`, `integer`, `float`, `bool`, `list`, `set`.

```bash
$ mise config ls
Path                        Tools
~/.config/mise/config.toml  pitchfork
~/src/mise/mise.toml        actionlint, bun, cargo-binstall, cargo:cargo-insta

$ mise config get tools.python
3.12

$ mise config set tools.python 3.12
$ mise config set settings.always_keep_download true
$ mise config set env.TEST_ENV_VAR ABC
$ mise config set settings.disable_tools node,rust
$ mise config set settings.jobs 4     # type for `settings` is inferred
```

#### 2.5.4 Global CLI flags that map to settings

([cli](https://mise.jdx.dev/cli/))

| Flag | Setting / env equivalent |
| --- | --- |
| `-C --cd <DIR>` | change directory before running (no setting) |
| `-E --env <ENV>` | `env` / `MISE_ENV` |
| `-j --jobs <JOBS>` | `jobs` / `MISE_JOBS` (default 8) |
| `-q --quiet` | `quiet` / `MISE_QUIET` |
| `-v --verbose` (`-vv` for more) | `verbose` / `MISE_VERBOSE`, `MISE_LOG_LEVEL` |
| `-y --yes` | `yes` / `MISE_YES` |
| `--raw` | `raw` / `MISE_RAW` |
| `--locked` | `locked` / `MISE_LOCKED` |
| `--silent` | `silent` / `MISE_SILENT` |
| `--no-config` | `MISE_NO_CONFIG=1` |
| `--no-env` | `no_env` / `MISE_NO_ENV=1` |
| `--no-hooks` | `no_hooks` / `MISE_NO_HOOKS=1` |
| `--offline` | `offline` / `MISE_OFFLINE` ([settings#offline](https://mise.jdx.dev/configuration/settings.html#offline)) |
| `--minimum-release-age` | `minimum_release_age` (highest precedence) ([security#minimum-release-age](https://mise.jdx.dev/security.html#minimum-release-age)) |
| `--prerelease` (on `mise ls-remote`) | `prereleases` ([settings#prereleases](https://mise.jdx.dev/configuration/settings.html#prereleases)) |

#### 2.5.5 Environment variables that are *not* settings

These are documented separately because they have no `[settings]` equivalent ([configuration#environment-variables](https://mise.jdx.dev/configuration.html#environment-variables)):

| Variable | Default | Purpose |
| --- | --- | --- |
| `MISE_DATA_DIR` | Linux/macOS `~/.local/share/mise` or `$XDG_DATA_HOME/mise`; Windows `%LOCALAPPDATA%\mise` | plugins and tool installs; not meant to be shared across machines |
| `MISE_CACHE_DIR` | Linux `~/.cache/mise`; macOS `~/Library/Caches/mise`; Windows `%TEMP%\mise`; or `$XDG_CACHE_HOME/mise` | internal cache; deletable any time mise isn't running |
| `MISE_TMP_DIR` | Rust `std::env::temp_dir()` | temporary storage during installs |
| `MISE_SYSTEM_CONFIG_DIR` | `/etc/mise` | system-wide config dir (legacy alias `MISE_SYSTEM_DIR`) |
| `MISE_GLOBAL_CONFIG_FILE` | `$MISE_CONFIG_DIR/config.toml` (usually `~/.config/mise/config.toml`) | retarget global writes (`mise use`/`mise set` from `$HOME`) |
| `MISE_DEFAULT_CONFIG_FILENAME` | `mise.toml` | default **local** config filename mise creates/looks for |
| `MISE_GLOBAL_CONFIG_ROOT` | `$HOME` | value of `{{config_root}}` for the global config file |
| `MISE_ENV_FILE` | — | filename of a dotenv file to load; searched in cwd and parents; uses [dotenvy](https://crates.io/crates/dotenvy) |
| `MISE_${TOOL}_VERSION` | — | force a tool version, e.g. `MISE_NODE_VERSION=20`, regardless of `mise.toml`/`.tool-versions` |
| `MISE_TRUSTED_CONFIG_PATHS` | — | auto-trusted paths; OS path separator (`:` Unix, `;` Windows) |
| `MISE_CEILING_PATHS` | — | stop config/file-task search here; OS path separator |
| `MISE_LOG_LEVEL` | — | `trace\|debug\|info\|warn\|error`; also `MISE_DEBUG=1`, `MISE_TRACE=1`, `MISE_QUIET=1`, `--log-level=` |
| `MISE_LOG_FILE` | — | write logs to a file, e.g. `~/mise.log` |
| `MISE_LOG_FILE_LEVEL` | — | log level for the **file** sink only |
| `MISE_LOG_HTTP=1` | — | show HTTP requests/responses in logs |
| `MISE_LOG_VERBOSE_DEPS=1` | — | the **only** way to see debug/trace logs from noisy crates (`h2`, `hyper`, `reqwest`, `rustls`); otherwise always dropped, even at `-vv` |
| `MISE_HTTP_TIMEOUT` | `30` (seconds) | HTTP request timeout |
| `MISE_RAW=1` | — | pipe plugin scripts directly to stdin/stdout/stderr; **also forces `MISE_JOBS=1`** |
| `MISE_TERM_WIDTH` | auto-detect, then `COLUMNS` | force table/list width; useful in CI (e.g. CircleCI reports width `0`) |
| `MISE_FISH_AUTO_ACTIVATE` | `1` | fish `vendor_conf.d` auto-activation (used by Homebrew installs); set `0` to disable |
| `MISE_NO_CONFIG=1` | — | load no config files at all ([cli](https://mise.jdx.dev/cli/)) |
| `MISE_OVERRIDE_CONFIG_FILENAMES` | — | replace the entire config filename list ([configuration/environments](https://mise.jdx.dev/configuration/environments.html)) |

---

### 2.6 Settings reference

All rows below come from the [settings reference](https://mise.jdx.dev/configuration/settings.html); each group links its source anchors. Env var names in the "Env" column are exactly as documented. Types: `bool`, `int`, `str`, `str[]`, `obj`; `?` marks an optional/tri-state setting whose unset value is *not* the same as `false`.

#### 2.6.1 Core behaviour and output

([settings](https://mise.jdx.dev/configuration/settings.html))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `experimental` | `MISE_EXPERIMENTAL` | bool / `false` | enables experimental features; behaviour may change or vanish in any release. Also used as a general beta flag. |
| `activate_aggressive` | `MISE_ACTIVATE_AGGRESSIVE` | bool / `false` | push tool bin-paths to the **front** of PATH so later PATH edits can't shadow mise |
| `jobs` | `MISE_JOBS` | int / `8` | concurrent jobs, e.g. tool installs |
| `raw` | `MISE_RAW` | bool / `false` | connect stdin/stdout/stderr directly to child processes (forces `jobs=1` via `MISE_RAW`) |
| `quiet` | `MISE_QUIET` | bool / `false` | suppress all output except errors |
| `silent` | `MISE_SILENT` | bool / `false` | suppress all `mise run`/`watch` output except errors — **including task output** |
| `verbose` | `MISE_VERBOSE` | bool / `false` | more verbose output, e.g. install logs |
| `yes` | `MISE_YES` | bool / `false` | auto-answer prompts; for scripting |
| `color` | `MISE_COLOR` | bool / `true` | color in terminal output |
| `color_theme` | `MISE_COLOR_THEME` | str / `default` | prompt theme: `auto`, `default`, `charm`, `base16`, `catppuccin`, `dracula` |
| `terminal_progress` | `MISE_TERMINAL_PROGRESS` | bool / `true` | OSC 9;4 progress in terminal chrome (Ghostty, iTerm2, VS Code, Windows Terminal, VTE) |
| `disable_hints` | `MISE_DISABLE_HINTS` | str[] / `[]` | turn off specific helpful hints |
| `cache_prune_age` | `MISE_CACHE_PRUNE_AGE` | str / `30d` | age before cache files are stale; `0s` keeps forever |

`color_theme` detail: `default` is an alias for `auto` — mise detects a light terminal background via `COLORFGBG` and switches to `base16`. Set an explicit theme to disable detection. When color is off (`color=false`, `NO_COLOR`, `CLICOLOR=0`) prompts render unstyled ([settings#color_theme](https://mise.jdx.dev/configuration/settings.html#color_theme)).

`activate_aggressive` background: normally, `PATH="/some/other/python:$PATH"` *after* `eval "$(mise activate zsh)"` wins. Put `mise activate` last in your shell config, or set this to `true` ([settings#activate_aggressive](https://mise.jdx.dev/configuration/settings.html#activate_aggressive)).

#### 2.6.2 Config discovery / early-init

([settings](https://mise.jdx.dev/configuration/settings.html))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `env` | `MISE_ENV` (comma) | str[] / `[]` | active config environments; **early-init** |
| `auto_env` | `MISE_AUTO_ENV` | bool? / unset (`false` today, `true` from 2027.6.0) | platform config environments; **early-init** |
| `ceiling_paths` | `MISE_CEILING_PATHS` (path sep) | str[] / `[]` | stop the upward config walk; **early-init**; ceiling dir's own config is excluded |
| `ignored_config_paths` | `MISE_IGNORED_CONFIG_PATHS` (path sep) | str[] / `[]` | config paths to ignore; **early-init** |
| `override_config_filenames` | `MISE_OVERRIDE_CONFIG_FILENAMES` (colon) | str[] / `[]` | replace default config filenames; **early-init** |
| `override_tool_versions_filenames` | `MISE_OVERRIDE_TOOL_VERSIONS_FILENAMES` (colon) | str[] / `[]` | replace `.tool-versions` filenames; `none` disables; **early-init** |
| `default_config_filename` | `MISE_DEFAULT_CONFIG_FILENAME` | str / `mise.toml` | default local config filename; **env var only** |
| `default_tool_versions_filename` | `MISE_DEFAULT_TOOL_VERSIONS_FILENAME` | str / `.tool-versions` | default tool-versions filename; **env var only** |
| `global_config_file` | `MISE_GLOBAL_CONFIG_FILE` | str? / `~/.config/mise/config.toml` | global config path; **env var only** |
| `global_config_root` | `MISE_GLOBAL_CONFIG_ROOT` | str? / `$HOME` | `{{config_root}}` for the global config; **env var only** |
| `system_config_file` | `MISE_SYSTEM_CONFIG_FILE` | str? / `/etc/mise/config.toml` | system config path; **env var only** |
| `idiomatic_version_file_enable_tools` | `MISE_IDIOMATIC_VERSION_FILE_ENABLE_TOOLS` | str[] / `[]` | enable idiomatic version files per tool (disabled by default) |
| `idiomatic_version_file_disable_files` | `MISE_IDIOMATIC_VERSION_FILE_DISABLE_FILES` | str[] / `[]` | `tool:filename` pairs to exclude individual files |

#### 2.6.3 Tools, install behaviour, registry

([settings](https://mise.jdx.dev/configuration/settings.html))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `auto_install` | `MISE_AUTO_INSTALL` | bool / `true` | auto-install missing tools on `mise x`, `mise run`, and the not-found handler |
| `auto_install_disable_tools` | `MISE_AUTO_INSTALL_DISABLE_TOOLS` (comma) | str[]? / unset | tools excluded from auto-install |
| `exec_auto_install` | `MISE_EXEC_AUTO_INSTALL` | bool / `true` | auto-install for `mise x` specifically |
| `not_found_auto_install` | `MISE_NOT_FOUND_AUTO_INSTALL` | bool / `true` | "command not found" handler auto-installs missing versions; also runs in shims when interactive |
| `disable_tools` | `MISE_DISABLE_TOOLS` | str[] / `[]` | tools in `mise.toml` to ignore |
| `enable_tools` | `MISE_ENABLE_TOOLS` | str[]? / unset | **allowlist**; when set, `disable_tools` is not applied. `[]` disables all tools |
| `disable_backends` | `MISE_DISABLE_BACKENDS` (comma) | str[] / `[]` | backends disabled for **new** installs (`asdf`, `pipx`, a vfox-backend name); already-installed tools keep working |
| `disable_default_registry` | `MISE_DISABLE_DEFAULT_REGISTRY` | bool / `false` | disable short-name → plugin mapping; affects only `vfox` and `asdf` backends |
| `registry_floating` | `MISE_REGISTRY_FLOATING` | bool / `false` | fetch the latest released mise registry + current aqua registry instead of the baked-in snapshots |
| `registry_cache_ttl` | `MISE_REGISTRY_CACHE_TTL` | str / `1h` | freshness of the downloaded registry when `registry_floating` is on; `0s` = always check |
| `always_keep_download` | `MISE_ALWAYS_KEEP_DOWNLOAD` | bool / `false` | keep downloaded archives under `~/.local/share/mise/downloads` for debugging — **not** a supported download cache |
| `always_keep_install` | `MISE_ALWAYS_KEEP_INSTALL` | bool / `false` | keep install files even when the install fails |
| `all_compile` | `MISE_ALL_COMPILE` | bool / `false` (true on NixOS/Alpine) | never use precompiled binaries; must be supported per language |
| `arch` | `MISE_ARCH` | str / detected | architecture for precompiled binaries (`x86_64`, `aarch64`, `arm`, `loongarch64`, `riscv64`) |
| `os` | `MISE_OS` | str / detected | OS for precompiled binaries (`linux`, `macos`, `windows`) |
| `libc` | `MISE_LIBC` | str / detected | `glibc` (alias `gnu`) or `musl` for precompiled Linux binaries |
| `pin` | `MISE_PIN` | bool / `false` | make `mise use` write pinned versions by default; override with `--fuzzy` |
| `prereleases` | `MISE_PRERELEASES` | bool / `false` | include GitHub/Forgejo prereleases globally in `ls-remote`, `latest`, fuzzy matching. Drafts always excluded; no effect on backends without an upstream prerelease flag (e.g. `github_tag`) |
| `shared_install_dirs` | `MISE_SHARED_INSTALL_DIRS` (path sep) | str[]? / unset | extra **read-only** install dirs searched after `~/.local/share/mise/installs`. `/usr/local/share/mise/installs` is always checked; populate with `mise install --system node@20` |
| `system_deps` | `MISE_SYSTEM_DEPS` | str / `prompt` | missing plugin system prerequisites: `prompt` (falls back to `warn` non-interactively), `auto`, `warn`, `ignore`. Missing **optional** deps never prompt or fail |
| `plugin_autoupdate_last_check_duration` | `MISE_PLUGIN_AUTOUPDATE_LAST_CHECK_DURATION` | str / `7d` | plugin auto-update interval — **not currently implemented** |
| `use_versions_host` | `MISE_USE_VERSIONS_HOST` | bool / `true` | use [mise-versions](https://mise-versions.jdx.dev) as a shared cache for version lists, public GitHub release metadata, and attestations — avoids anonymous GitHub rate limits |
| `use_versions_host_track` | `MISE_USE_VERSIONS_HOST_TRACK` | bool / `true` | send anonymous install stats (tool+version, OS/arch, hashed IP); auto-disabled when `use_versions_host=false` |

> **Uncertainty:** there is no `plugin_autoinstall_default` setting in the mise 2026.7 settings reference. The nearest documented controls are `auto_install`, `exec_auto_install`, `auto_install_disable_tools`, `task.run_auto_install`, and `plugin_autoupdate_last_check_duration` ([settings](https://mise.jdx.dev/configuration/settings.html)).

#### 2.6.4 Network and HTTP

([settings](https://mise.jdx.dev/configuration/settings.html))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `http_timeout` | `MISE_HTTP_TIMEOUT` | str / `30s` | connection phase **and each individual response read**; the read timer resets on data |
| `http_download_timeout` | `MISE_HTTP_DOWNLOAD_TIMEOUT` | str / `30m` | total wall-clock budget for one artifact including retries/backoff |
| `http_retries` | `MISE_HTTP_RETRIES` | int / `3` | retries on transient errors only |
| `fetch_remote_versions_cache` | `MISE_FETCH_REMOTE_VERSIONS_CACHE` | str / `1h` | remote version cache duration for "fast" commands; slow commands (`ls-remote`, `install`) use it if set, else hourly |
| `fetch_remote_versions_timeout` | `MISE_FETCH_REMOTE_VERSIONS_TIMEOUT` | str / `20s` | capped at **3s** for fast/`prefer_offline` paths so shims and activation don't block |
| `offline` | `MISE_OFFLINE` | bool / `false` | never make HTTP requests at all (air-gapped, VPN issues) |
| `prefer_offline` | `MISE_PREFER_OFFLINE` | bool / `false` | prefer cached data, network only as fallback; auto-enabled for `hook-env`, `activate`, `exec`, `env`, `ls`, `current`, `where`, `which`, and shims |
| `netrc` | `MISE_NETRC` | bool / `true` | read credentials from netrc and apply HTTP Basic auth (Artifactory/Nexus). Unix `~/.netrc`; Windows `%USERPROFILE%\_netrc` then `.netrc` |
| `netrc_file` | `MISE_NETRC_FILE` | str? / unset | custom netrc path |
| `url_replacements` | `MISE_URL_REPLACEMENTS` | obj? / unset | rewrite any URL mise fetches — see [§2.11](#211-url-replacements-and-corporate-mirrors) |

`http_retries` detail: retried on HTTP 5xx, 408, 429, and network-layer failures (connect refused, timeout, mid-stream body drops). Other 4xx (e.g. 404) are permanent. Backoff with jitter: ~200 ms / ~1 s / ~4 s / ~15 s. `0` disables retries. Retries are **automatically disabled** for fast `prefer_offline` commands (shims, activation) — one attempt, then fail or fall back. A retry that rescues a request logs a warning with the original error ([settings#http_retries](https://mise.jdx.dev/configuration/settings.html#http_retries)).

#### 2.6.5 Security, trust, verification

([settings](https://mise.jdx.dev/configuration/settings.html), [security](https://mise.jdx.dev/security.html), [paranoid](https://mise.jdx.dev/paranoid.html))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `trusted_config_paths` | `MISE_TRUSTED_CONFIG_PATHS` (path sep) | str[] / `[]` | configs under these paths are trusted without prompting; `["/"]` effectively disables the trust mechanism |
| `paranoid` | `MISE_PARANOID` | bool / `false` | extra-secure behaviour — see [§2.8](#28-paranoid-mode) |
| `safe` | `MISE_SAFE` | bool / `false` | hard code-execution boundary — see [§2.9](#29-safe-mode). **`global_only`**: settable only via env or global config |
| `minimum_release_age` | `MISE_MINIMUM_RELEASE_AGE` | str / `24h` | ignore versions newer than this; `7d`, `6mo`, `1y`, or `2024-06-01`. `0s` disables |
| `minimum_release_age_excludes` | `MISE_MINIMUM_RELEASE_AGE_EXCLUDES` (comma) | str[] / `[]` | exempt tools/backends: `npm:*`, `trivy`, `aqua:aquasecurity/trivy` |
| `slsa` | `MISE_SLSA` | bool / `true` | SLSA provenance verification globally |
| `github_attestations` | `MISE_GITHUB_ATTESTATIONS` | bool / `true` | GitHub Artifact Attestations verification globally |
| `gpg_verify` | `MISE_GPG_VERIFY` | bool? / unset | built-in OpenPGP verification for all tools (no external `gpg`); `false` disables |
| `provenance_api_failures_fatal` | `MISE_PROVENANCE_API_FAILURES_FATAL` | bool / `true` | unreachable attestation/provenance APIs **fail** the install; `false` warns and continues (does not ignore checksum failures, verification mismatches, or lockfile-required provenance) |
| `locked_verify_provenance` | `MISE_LOCKED_VERIFY_PROVENANCE` | bool / `false` | re-verify provenance at install even when the lockfile has checksum + provenance. Auto-enabled by `paranoid` |

`minimum_release_age` precedence: `--minimum-release-age` CLI flag **>** per-tool `minimum_release_age` **>** global setting. For most backends it only filters **fuzzy** requests (`node@20`, `latest`); explicit pins like `node@22.5.0` bypass it. Already-installed fuzzy matches stay eligible during ordinary resolution. Capability by backend ([security#minimum-release-age](https://mise.jdx.dev/security.html#minimum-release-age)):

| Capability | Backends |
| --- | --- |
| Top-level version filtering | backends providing release timestamps: `aqua:`, `cargo:`, `github:`, `gitlab:`, `go:`, `npm:`, `pipx:`, and many core tools |
| Transitive dependency filtering during install | `npm:` and `pipx:` only |

Versions without timestamps are included by default.

#### 2.6.6 Lockfile

([settings](https://mise.jdx.dev/configuration/settings.html), [dev-tools/mise-lock](https://mise.jdx.dev/dev-tools/mise-lock.html))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `lockfile` | `MISE_LOCKFILE` | bool? / unset | read/update `mise.lock`. `true` = read+write; `false` = explicitly disabled (**errors** if `locked = true`); unset behaves like `true` but without the conflict |
| `locked` | `MISE_LOCKED` | bool / `false` | `mise install` fails unless every tool has a pre-resolved URL for the current platform. Requires `lockfile`. Equivalent to `--locked` |
| `lockfile_platforms` | `MISE_LOCKFILE_PLATFORMS` (comma) | str[]? / unset | restrict auto-lock/`mise lock` platforms. Default targets linux-x64, linux-x64-musl, linux-arm64, linux-arm64-musl, macos-x64, macos-arm64, windows-x64 **plus** the current platform. Does **not** override explicit `mise lock --platform` |

Lockfiles are not created automatically: `touch mise.lock && mise install`, or run `mise lock` ([settings#lockfile](https://mise.jdx.dev/configuration/settings.html#lockfile)). The current platform is always included regardless of `lockfile_platforms`.

#### 2.6.7 Environment computation and `hook-env`

([settings](https://mise.jdx.dev/configuration/settings.html))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `env_file` | `MISE_ENV_FILE` | str? / unset | dotenv file to auto-load |
| `env_shell_expand` | `MISE_ENV_SHELL_EXPAND` | bool / `true` | `$FOO` / `${FOO}` / `${FOO:-default}` expansion in `[env]` values, applied after Tera |
| `env_cache` | `MISE_ENV_CACHE` | bool / `false` | cache the computed env+PATH to disk; encrypted with a session-scoped key `__MISE_ENV_CACHE_KEY` |
| `env_cache_ttl` | `MISE_ENV_CACHE_TTL` | str / `1h` | cache validity window |
| `no_env` | `MISE_NO_ENV` | bool? / unset | do not load env vars from config files (`--no-env`) |
| `no_hooks` | `MISE_NO_HOOKS` | bool? / unset | do not execute hooks from config files (`--no-hooks`) |
| `hook_env.cache_ttl` | `MISE_HOOK_ENV_CACHE_TTL` | str / `0s` | cache directory-traversal results for `hook-env` on slow filesystems (NFS). `0s` = no caching (safest, slowest) |
| `hook_env.chpwd_only` | `MISE_HOOK_ENV_CHPWD_ONLY` | bool / `false` | full config checks only on directory change, not on every prompt |

`env_cache` invalidation: any config file change, tool-version change, settings change, mise version change, TTL expiry, or a watched file change (modules / `_.source`). Modules (vfox plugins) may declare `{cacheable = true, watch_files = [...], env = [...]}` from their `mise_env` hook; those that don't are treated as dynamic. Opt individual directives out with `cacheable = false` ([settings#env_cache](https://mise.jdx.dev/configuration/settings.html#env_cache)):

```toml
[env]
TIMESTAMP = { value = "{{ now() }}", cacheable = false }
_.source = { file = "dynamic.sh", cacheable = false }
```

With `hook_env` caching on, newly created config files may not be detected until the TTL expires — `mise hook-env --force` bypasses the cache ([settings#hook_env-cache_ttl](https://mise.jdx.dev/configuration/settings.html#hook_env.cache_ttl)).

#### 2.6.8 Status line (`status.*`)

([settings#status](https://mise.jdx.dev/configuration/settings.html#status))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `status.missing_tools` | `MISE_STATUS_MESSAGE_MISSING_TOOLS` | str / `if_other_versions_installed` | warn about uninstalled tools on directory entry: `if_other_versions_installed`, `always`, `never` |
| `status.show_tools` | `MISE_STATUS_MESSAGE_SHOW_TOOLS` | bool / `false` | show configured tools on entering a directory with `mise.toml` |
| `status.show_env` | `MISE_STATUS_MESSAGE_SHOW_ENV` | bool / `false` | show configured env vars on entering a directory |
| `status.show_deps_stale` | `MISE_STATUS_SHOW_DEPS_STALE` | bool / `true` | warn when deps providers have stale dependencies |
| `status.truncate` | `MISE_STATUS_MESSAGE_TRUNCATE` | bool / `true` | truncate status messages |

#### 2.6.9 Tasks (`task.*`)

([settings#task](https://mise.jdx.dev/configuration/settings.html#task))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `task.output` | `MISE_TASK_OUTPUT` | str? / unset | output **style**: `prefix` (default when jobs>1), `interleave` (default when jobs==1/sequential), `keep-order`, `replacing`, `timed`, `quiet` (legacy), `silent` (legacy) |
| `task.timeout` | `MISE_TASK_TIMEOUT` | str? / unset | global default task timeout; the **shorter** of global and per-task wins; `--timeout` overrides |
| `task.timings` | `MISE_TASK_TIMINGS` | bool? / unset | elapsed-time completion message; defaults on when output type is `prefix` |
| `task.skip` | `MISE_TASK_SKIP` | str[] / `[]` | tasks to skip during `mise run` |
| `task.skip_depends` | `MISE_TASK_SKIP_DEPENDS` | bool / `false` | run only the named tasks, skipping dependencies |
| `task.run_auto_install` | `MISE_TASK_RUN_AUTO_INSTALL` | bool / `true` | auto-install missing tools when executing tasks |
| `task.disable_paths` | `MISE_TASK_DISABLE_PATHS` (path sep) | str[] / `[]` | paths mise will not look for tasks in |
| `task.show_full_cmd` | `MISE_TASK_SHOW_FULL_CMD` | bool / `false` | don't truncate command lines in task output |
| `task.cache_dir` | `MISE_TASK_CACHE_DIR` | str? / unset | task artifact cache location instead of `MISE_CACHE_DIR/task-artifacts` |
| `task.remote_no_cache` | `MISE_TASK_REMOTE_NO_CACHE` | bool? / unset | always refetch remote tasks instead of using the cache |
| `task.disable_spec_from_run_scripts` | `MISE_TASK_DISABLE_SPEC_FROM_RUN_SCRIPTS` | bool / `false` | `arg()`/`option()`/`flag()` in run scripts stop contributing to the usage spec; early opt-out before Tera template args are removed in **2026.11.0** |
| `task.source_freshness_equal_mtime_is_fresh` | `MISE_TASK_SOURCE_FRESHNESS_EQUAL_MTIME_IS_FRESH` | bool / `false` | treat equal source/output mtime as fresh (`<=` instead of strict `<`) |
| `task.source_freshness_hash_contents` | `MISE_TASK_SOURCE_FRESHNESS_HASH_CONTENTS` | bool / `false` | blake3 content hashing instead of metadata — more accurate, slower |
| `task.monorepo_depth` | `MISE_TASK_MONOREPO_DEPTH` | int / `5` | subdirectory search depth in monorepo mode |
| `task.monorepo_exclude_dirs` | `MISE_TASK_MONOREPO_EXCLUDE_DIRS` (comma) | str[] / `[]` | when empty, defaults to `node_modules`, `target`, `dist`, `build`; **any value replaces the defaults entirely** |
| `task.monorepo_respect_gitignore` | `MISE_TASK_MONOREPO_RESPECT_GITIGNORE` | bool / `true` | skip gitignored directories during monorepo task discovery |
| `use_file_shell_for_executable_tasks` | `MISE_USE_FILE_SHELL_FOR_EXECUTABLE_TASKS` | bool / `false` | run tasks-directory tasks through the file shell rather than directly as programs |

`task.output` is the *style* axis; verbosity is separate (`quiet`/`silent` settings, `--quiet`/`--silent`, or per-task fields). `output = "prefix"` + `quiet = true` keeps prefixes while suppressing mise's own messages. The `quiet`/`silent` **values** are backwards-compatibility bundles ([settings#task-output](https://mise.jdx.dev/configuration/settings.html#task.output)).

#### 2.6.10 Shells and Windows

([settings](https://mise.jdx.dev/configuration/settings.html))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `unix_default_inline_shell_args` | `MISE_UNIX_DEFAULT_INLINE_SHELL_ARGS` | str / `sh -c -o errexit` | inline command shell on Unix |
| `unix_default_file_shell_args` | `MISE_UNIX_DEFAULT_FILE_SHELL_ARGS` | str / `sh` | file command shell on Unix |
| `windows_default_inline_shell_args` | `MISE_WINDOWS_DEFAULT_INLINE_SHELL_ARGS` | str / `cmd /c` | inline command shell on Windows |
| `windows_default_file_shell_args` | `MISE_WINDOWS_DEFAULT_FILE_SHELL_ARGS` | str / `cmd /c` | file command shell on Windows |
| `windows_executable_extensions` | `MISE_WINDOWS_EXECUTABLE_EXTENSIONS` (comma) | str[] / `["exe","bat","cmd","com","ps1","vbs"]` | recognised executable extensions |
| `windows_powershell_no_profile` | `MISE_WINDOWS_POWERSHELL_NO_PROFILE` | bool / `true` | pass `-NoProfile` to pwsh/powershell so a PATH-mutating profile can't shadow task tools |
| `windows_shim_mode` | `MISE_WINDOWS_SHIM_MODE` | str / `exe` | `exe` (recommended, needs `mise-shim.exe`), `file` (`.cmd` + bash script), `hardlink` (needs `mise reshim --force` after upgrades), `symlink` (needs admin or Developer Mode) |

#### 2.6.11 Sandbox defaults (`sandbox.*`)

([settings#sandbox](https://mise.jdx.dev/configuration/settings.html#sandbox), [sandboxing](https://mise.jdx.dev/sandboxing.html))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `sandbox.deny_all` | `MISE_SANDBOX_DENY_ALL` | bool / `false` | deny reads, writes, network, and env inheritance for every `mise run`/`mise exec` |
| `sandbox.deny_read` | `MISE_SANDBOX_DENY_READ` | bool / `false` | deny filesystem reads by default |
| `sandbox.deny_write` | `MISE_SANDBOX_DENY_WRITE` | bool / `false` | deny filesystem writes by default |
| `sandbox.deny_net` | `MISE_SANDBOX_DENY_NET` | bool / `false` | deny network by default |
| `sandbox.deny_env` | `MISE_SANDBOX_DENY_ENV` | bool / `false` | deny env var inheritance by default |

#### 2.6.12 Python (`python.*`)

([settings#python](https://mise.jdx.dev/configuration/settings.html#python))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `python.compile` | `MISE_PYTHON_COMPILE` | bool? / unset | `true` = always python-build; `false` = always precompiled; unset = precompiled if available, else compile |
| `python.precompiled_arch` | `MISE_PYTHON_PRECOMPILED_ARCH` | str / `x86_64_v3` or `aarch64` | set to `x86_64` on older CPUs for maximum compatibility |
| `python.precompiled_os` | `MISE_PYTHON_PRECOMPILED_OS` | str / `apple-darwin`, `unknown-linux-gnu`, `unknown-linux-musl` | precompiled OS triple |
| `python.precompiled_flavor` | `MISE_PYTHON_PRECOMPILED_FLAVOR` | str / `install_only_stripped` | python-build-standalone flavor |
| `python.github_attestations` | `MISE_PYTHON_GITHUB_ATTESTATIONS` | bool? / unset | override the global setting for astral-sh/python-build-standalone binaries |
| `python.patch_url` | `MISE_PYTHON_PATCH_URL` | str? / unset | URL of python patches passed to python-build |
| `python.patches_directory` | `MISE_PYTHON_PATCHES_DIRECTORY` | str? / unset | local directory of python patches |
| `python.pyenv_repo` | `MISE_PYENV_REPO` | str / `https://github.com/pyenv/pyenv.git` | pyenv source for python-build |
| `python.uv_venv_auto` | `MISE_PYTHON_UV_VENV_AUTO` | bool\|str / `false` | uv project venv handling when `uv.lock` exists: `false`, `source`, `create\|source`, `true` (legacy = create\|source **plus** exporting `UV_PYTHON`) |
| `python.uv_venv_create_args` | `MISE_PYTHON_UV_VENV_CREATE_ARGS` (colon) | str[]? / unset | args passed to `uv` when creating a venv |
| `python.venv_create_args` | `MISE_PYTHON_VENV_CREATE_ARGS` (colon) | str[]? / unset | args passed to python when creating a venv (not used for uv) |
| `python.venv_stdlib` | `MISE_VENV_STDLIB` | bool / `false` | prefer the stdlib `venv` module |
| `python.default_packages_file` | `MISE_PYTHON_DEFAULT_PACKAGES_FILE` | str? / unset | **deprecated** — use tool-level `postinstall` or the `pipx:` backend |

#### 2.6.13 Node (`node.*`)

([settings#node](https://mise.jdx.dev/configuration/settings.html#node))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `node.compile` | `MISE_NODE_COMPILE` | bool? / unset | compile node from source |
| `node.mirror_url` | `MISE_NODE_MIRROR_URL` | str? / unset | tarball mirror (e.g. `https://npmmirror.com/mirrors/node`) |
| `node.flavor` | `MISE_NODE_FLAVOR` | str? / unset | e.g. `glibc-217`, `musl` — for unofficial node build repos |
| `node.verify` | `MISE_NODE_VERIFY` | bool / `true` | verify downloaded assets using GPG |
| `node.gpg_verify` | `MISE_NODE_GPG_VERIFY` | bool? / unset | built-in OpenPGP verification for node; `false` disables |
| `node.corepack` | `MISE_NODE_COREPACK` | bool / `false` | install default corepack shims after installing any node version |
| `node.npm_shim` | `MISE_NODE_NPM_SHIM` | bool / `true` | bash wrapper at `bin/npm` triggering `mise reshim` after `npm install -g`; disable to let corepack manage it |
| `node.ninja` | `MISE_NODE_NINJA` | bool / auto (`true` if `ninja` on PATH) | use ninja instead of make for compilation |
| `node.concurrency` | `MISE_NODE_CONCURRENCY` | int / physical CPUs (unset with ninja) | parallel compile jobs |
| `node.make` | `MISE_NODE_MAKE` | str? / unset | make command |
| `node.make_opts` | `MISE_NODE_MAKE_OPTS` | str? / unset | extra make options |
| `node.make_install_opts` | `MISE_NODE_MAKE_INSTALL_OPTS` | str? / unset | extra `make install` options |
| `node.configure_opts` | `MISE_NODE_CONFIGURE_OPTS` | str? / unset | extra `./configure` options |
| `node.cflags` | `MISE_NODE_CFLAGS` | str? / unset | extra CFLAGS (e.g. to override `-O3`) |
| `node.nvm_dir` | `NVM_DIR` | str / `~/.nvm` | nvm directory |
| `node.nodenv_root` | `NODENV_ROOT` | str / `~/.nodenv` | nodenv directory |
| `node.default_packages_file` | `MISE_NODE_DEFAULT_PACKAGES_FILE` | str / `~/.default-npm-packages` | **deprecated**; also reads `~/.default-nodejs-packages`, `~/.default-node-packages` |

#### 2.6.14 Ruby (`ruby.*`)

([settings#ruby](https://mise.jdx.dev/configuration/settings.html#ruby))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `ruby.compile` | `MISE_RUBY_COMPILE` | bool? / unset | `false` = precompiled first, fall back to compile; `true` = always ruby-build; unset = compile today, **changes to precompiled in 2026.8.0**; with `experimental = true`, unset already prefers precompiled |
| `ruby.precompiled_url` | `MISE_RUBY_PRECOMPILED_URL` | str / `jdx/ruby` | GitHub shorthand or URL template with `{version}`, `{platform}`, `{os}`, `{arch}` |
| `ruby.precompiled_os` | `MISE_RUBY_PRECOMPILED_OS` | str? / unset | override OS identifier |
| `ruby.precompiled_arch` | `MISE_RUBY_PRECOMPILED_ARCH` | str? / unset | override arch identifier |
| `ruby.github_attestations` | `MISE_RUBY_GITHUB_ATTESTATIONS` | bool? / unset | override the global setting for jdx/ruby binaries |
| `ruby.ruby_build_repo` | `MISE_RUBY_BUILD_REPO` | str / `https://github.com/rbenv/ruby-build.git` | git repo or ZIP archive |
| `ruby.ruby_build_opts` | `MISE_RUBY_BUILD_OPTS` | str? / unset | options for ruby-build |
| `ruby.ruby_install` | `MISE_RUBY_INSTALL` | bool / `false` | use ruby-install instead of ruby-build |
| `ruby.ruby_install_repo` | `MISE_RUBY_INSTALL_REPO` | str / `https://github.com/postmodern/ruby-install.git` | git repo or ZIP archive |
| `ruby.ruby_install_opts` | `MISE_RUBY_INSTALL_OPTS` | str? / unset | options for ruby-install |
| `ruby.apply_patches` | `MISE_RUBY_APPLY_PATCHES` | str? / unset | patch files or URLs to apply to ruby source |
| `ruby.verbose_install` | `MISE_RUBY_VERBOSE_INSTALL` | bool? / unset | verbose ruby install output |
| `ruby.default_packages_file` | `MISE_RUBY_DEFAULT_PACKAGES_FILE` | str / `~/.default-gems` | **deprecated** — use tool-level `postinstall` or the `gem:` backend |

```toml
[settings.ruby]
# Use a different GitHub repo
precompiled_url = "yourorg/ruby"

# Or use a custom URL template
precompiled_url = "https://my-mirror.example.com/ruby-{version}.{platform}.tar.gz"
```

#### 2.6.15 Go, Java, Rust, Erlang, Swift, Zig, .NET

([settings#go](https://mise.jdx.dev/configuration/settings.html#go), [#java](https://mise.jdx.dev/configuration/settings.html#java), [#rust](https://mise.jdx.dev/configuration/settings.html#rust), [#erlang](https://mise.jdx.dev/configuration/settings.html#erlang), [#swift](https://mise.jdx.dev/configuration/settings.html#swift), [#zig](https://mise.jdx.dev/configuration/settings.html#zig), [#dotnet](https://mise.jdx.dev/configuration/settings.html#dotnet))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `go.download_mirror` | `MISE_GO_DOWNLOAD_MIRROR` | str / `https://dl.google.com/go` | Go SDK tarball mirror |
| `go.repo` | `MISE_GO_REPO` | str / `https://github.com/golang/go` | URL to fetch go from |
| `go.set_goroot` | `MISE_GO_SET_GOROOT` | bool / `true` | set `GOROOT` to the mise install dir |
| `go.set_gobin` | `MISE_GO_SET_GOBIN` | bool? / unset | `true` overrides a previously set `GOBIN`; `false` leaves it at `${GOPATH:-$HOME/go}/bin` |
| `go.set_gopath` | `MISE_GO_SET_GOPATH` | bool / `false` | **deprecated** — use `env._go.set_goroot` |
| `go.skip_checksum` | `MISE_GO_SKIP_CHECKSUM` | bool / `false` | skip Go SDK tarball checksum verification |
| `go.default_packages_file` | `MISE_GO_DEFAULT_PACKAGES_FILE` | str / `~/.default-go-packages` | **deprecated** — use tool-level `postinstall` or the `go:` backend |
| `java.shorthand_vendor` | `MISE_JAVA_SHORTHAND_VENDOR` | str / `openjdk` | vendor used when installing Java without a vendor prefix |
| `rust.cargo_home` | `MISE_CARGO_HOME` | str? / `~/.cargo` | cargo home directory |
| `rust.rustup_home` | `MISE_RUSTUP_HOME` | str? / `~/.rustup` | rustup home directory |
| `rust.default_host` | `MISE_RUST_DEFAULT_HOST` | str? / unset | `--default-host` triple for `rustup init` |
| `erlang.compile` | `MISE_ERLANG_COMPILE` | bool? / unset | `true` compile from source; `false` precompiled; unset = precompiled if available |
| `swift.platform` | `MISE_SWIFT_PLATFORM` | str / detected | override precompiled platform (`osx`, `windows10`, `ubuntu20.04`…`ubuntu24.04`, `amazonlinux2`, `ubi9`, `fedora39`) |
| `swift.gpg_verify` | `MISE_SWIFT_GPG_VERIFY` | bool? / unset | built-in OpenPGP verification for swift |
| `zig.use_community_mirrors` | `MISE_ZIG_USE_COMMUNITY_MIRRORS` | bool / `true` | fetch Zig from community mirrors; tarballs are still verified against the ZSF public key |
| `dotnet.dotnet_root` | `MISE_DOTNET_ROOT` | str? / `~/.local/share/mise/dotnet-root` | shared side-by-side SDK root |
| `dotnet.isolated` | `MISE_DOTNET_ISOLATED` | bool / `false` | one directory per SDK version; `dotnet --list-sdks` then shows only the active one |
| `dotnet.registry_url` | `MISE_DOTNET_REGISTRY_URL` | str / `https://api.nuget.org/v3/index.json` | NuGet feed for dotnet tools |
| `dotnet.cli_telemetry_optout` | `MISE_DOTNET_CLI_TELEMETRY_OPTOUT` | bool? / unset | sets `DOTNET_CLI_TELEMETRY_OPTOUT` to `1`/`0`; unset leaves .NET's own default |
| `dotnet.package_flags` | `MISE_DOTNET_PACKAGE_FLAGS` (comma) | str[] / `[]` | **deprecated** — use the `prerelease` tool option or `prereleases` |

`swift.platform` matters for lockfiles: Swift publishes a different Linux tarball per distro, so lockfile entries record `swift_platform`. Pin `swift.platform` to make every Linux machine resolve the same artifact ([dev-tools/mise-lock#tool-entry-fields](https://mise.jdx.dev/dev-tools/mise-lock.html#tool-entry-fields)).

> **Uncertainty:** the settings reference documents only `java.shorthand_vendor` under `java.*`; there are no other `java.*` settings in mise 2026.7 ([settings#java](https://mise.jdx.dev/configuration/settings.html#java)).

#### 2.6.16 Package-manager backends: cargo, npm, pipx, conda, spm

([settings#cargo](https://mise.jdx.dev/configuration/settings.html#cargo), [#npm](https://mise.jdx.dev/configuration/settings.html#npm), [#pipx](https://mise.jdx.dev/configuration/settings.html#pipx), [#conda](https://mise.jdx.dev/configuration/settings.html#conda), [#spm](https://mise.jdx.dev/configuration/settings.html#spm))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `cargo.binstall` | `MISE_CARGO_BINSTALL` | bool / `true` | use `cargo binstall` when on PATH; set `false` to force `cargo install` when Cargo settings must control the build |
| `cargo.binstall_native` | `MISE_CARGO_BINSTALL_NATIVE` | bool? / unset | mise's own native binary installer. Unset = disabled today; warns from **2027.1.0**; defaults on in **2027.7.0** |
| `cargo.binstall_only` | `MISE_CARGO_BINSTALL_ONLY` | bool / `false` | require cargo-binstall for non-Git-source crates; fail rather than fall back |
| `cargo.binstall_quickinstall` | `MISE_CARGO_BINSTALL_QUICKINSTALL` | bool / `false` | allow external cargo-binstall to use third-party cargo-quickinstall artifacts |
| `cargo.registry_name` | `MISE_CARGO_REGISTRY_NAME` | str? / unset | alternate cargo registry name |
| `npm.package_manager` | `MISE_NPM_PACKAGE_MANAGER` | str / `auto` | `auto` (embedded `aube`), `aube_cli`, `npm`, `bun`, `pnpm` |
| `npm.shell_out` | `MISE_NPM_SHELL_OUT` | bool / `false` | shell out to the npm CLI (`npm view`, `npm install -g`) instead of mise's built-in HTTP+aube path |
| `pipx.uvx` | `MISE_PIPX_UVX` | bool / `true` | use `uvx` instead of `pipx` when `uv` is on PATH |
| `pipx.registry_url` | `MISE_PIPX_REGISTRY_URL` | str / `https://pypi.org/pypi/{}/json` | pypi metadata endpoint; HTML endpoint `https://pypi.org/simple/{}/` also works |
| `conda.channel` | `MISE_CONDA_CHANNEL` | str / `conda-forge` | default channel; per-package override `conda:package[channel=bioconda]` |
| `spm.artifactbundle_only` | `MISE_SPM_ARTIFACTBUNDLE_ONLY` | bool / `false` | only use SwiftPM artifact bundles; fail if none matches |

`cargo.binstall` fallback detail: mise disables cargo-binstall's `compile` strategy. Exit code **94** ("no prebuilt artifact") triggers a `cargo install` fallback; other cargo-binstall errors do not. By default mise passes `--disable-strategies compile,quick-install`; `binstall_quickinstall = true` narrows that to `--disable-strategies compile` ([settings#cargo-binstall](https://mise.jdx.dev/configuration/settings.html#cargo.binstall)).

`npm` default path detail: without shelling out, `mise ls-remote`/`latest` query the npm registry over HTTP and installs use the embedded [aube](https://github.com/jdx/aube). Both honour `~/.npmrc` and `NPM_CONFIG_*` (registry, scoped registries, auth tokens). Enable `npm.shell_out` when you need npm-specific config the built-in path doesn't support (`cafile`, client certs, auth token helpers). Explicitly selecting a package manager always shells out regardless ([settings#npm-shell_out](https://mise.jdx.dev/configuration/settings.html#npm.shell_out)).

> **Uncertainty:** there are **no `ubi.*` settings** in the mise 2026.7 settings reference; the `ubi` backend is configured through tool options rather than global settings ([settings](https://mise.jdx.dev/configuration/settings.html)).

#### 2.6.17 aqua (`aqua.*`)

([settings#aqua](https://mise.jdx.dev/configuration/settings.html#aqua))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `aqua.baked_registry` | `MISE_AQUA_BAKED_REGISTRY` | bool / `true` | use the registry baked into this mise release |
| `aqua.registries` | `MISE_AQUA_REGISTRIES` (comma) | str[]? / unset | extra registry sources checked **in order** before the baked-in one: repo URL, direct `registry.yaml`/`.yml` URL, or absolute `file://` dir/file |
| `aqua.registry_cache_ttl` | `MISE_AQUA_REGISTRY_CACHE_TTL` | str / `1w` | freshness of downloaded registry sources; `0s` re-downloads every time |
| `aqua.registry_url` | `MISE_AQUA_REGISTRY_URL` | str? / unset | **deprecated** — use `aqua.registries` |
| `aqua.cosign` | `MISE_AQUA_COSIGN` | bool / `true` | cosign signature verification |
| `aqua.cosign_extra_args` | `MISE_AQUA_COSIGN_EXTRA_ARGS` | str[]? / unset | extra args passed to cosign |
| `aqua.minisign` | `MISE_AQUA_MINISIGN` | bool / `true` | minisign signature verification |
| `aqua.slsa` | `MISE_AQUA_SLSA` | bool / `true` | SLSA verification for aqua tools |
| `aqua.github_attestations` | `MISE_AQUA_GITHUB_ATTESTATIONS` | bool / `true` | GitHub Artifact Attestations for aqua tools |

Local `file://` sources bypass the download cache, so edits are picked up on the next registry load. If the baked registry is disabled and no registries are configured, mise downloads <https://github.com/aquaproj/aqua-registry> ([settings#aqua-registries](https://mise.jdx.dev/configuration/settings.html#aqua.registries)).

#### 2.6.18 Forge credentials: github, gitlab, forgejo

([settings#github](https://mise.jdx.dev/configuration/settings.html#github), [#gitlab](https://mise.jdx.dev/configuration/settings.html#gitlab), [#forgejo](https://mise.jdx.dev/configuration/settings.html#forgejo))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `github.credential_command` | `MISE_GITHUB_CREDENTIAL_COMMAND` | str / `""` | run via `sh -c`, read token from stdout; host exposed as `MISE_CREDENTIAL_HOST`. e.g. `op read "op://Private/GitHub Token/credential"` |
| `github.gh_cli_tokens` | `MISE_GITHUB_GH_CLI_TOKENS` | bool / `true` | read OAuth tokens from `~/.config/gh/hosts.yml` (or `$GH_CONFIG_DIR`) as fallback |
| `github.use_git_credentials` | `MISE_GITHUB_USE_GIT_CREDENTIALS` | bool / `false` | run `git credential fill`; last resort after env vars, `github_tokens.toml`, gh CLI. Cached per host per session |
| `github.github_attestations` | `MISE_GITHUB_GITHUB_ATTESTATIONS` | bool / `true` | attestations for `github:` backend tools; auto-skipped for custom `api_url` (GHES has no attestations endpoint) |
| `github.slsa` | `MISE_GITHUB_SLSA` | bool / `true` | SLSA verification for `github:` backend tools |
| `github.oauth_client_id` | `MISE_GITHUB_OAUTH_CLIENT_ID` | str / `""` | enables GitHub App user access tokens via the OAuth device flow (`mise token github --oauth`) |
| `github.oauth_api_url` | `MISE_GITHUB_OAUTH_API_URL` | str / `https://api.github.com` | API base used to validate OAuth tokens |
| `github.oauth_auth_url` | `MISE_GITHUB_OAUTH_AUTH_URL` | str / `https://github.com/login` | device-flow OAuth base URL |
| `github.oauth_export_env` | `MISE_GITHUB_OAUTH_EXPORT_ENV` | str / `GITHUB_TOKEN` | env var the token is exported under; `GH_TOKEN` for gh CLI, empty string disables |
| `github.oauth_open_browser` | `MISE_GITHUB_OAUTH_OPEN_BROWSER` | bool / `true` | open the verification URL during device flow |
| `github.oauth_scopes` | `MISE_GITHUB_OAUTH_SCOPES` | str / `""` | optional scope string; usually empty since App permissions govern access |
| `gitlab.credential_command` | `MISE_GITLAB_CREDENTIAL_COMMAND` | str / `""` | same contract as GitHub's |
| `gitlab.glab_cli_tokens` | `MISE_GITLAB_GLAB_CLI_TOKENS` | bool / `true` | read tokens from `~/.config/glab-cli/config.yml` (or `$GLAB_CONFIG_DIR`) |
| `gitlab.use_git_credentials` | `MISE_GITLAB_USE_GIT_CREDENTIALS` | bool / `false` | `git credential fill` fallback |
| `forgejo.credential_command` | `MISE_FORGEJO_CREDENTIAL_COMMAND` | str / `""` | same contract as GitHub's |
| `forgejo.fj_cli_tokens` | `MISE_FORGEJO_FJ_CLI_TOKENS` | bool / `true` | read `~/.local/share/forgejo-cli/keys.json` (Linux) or `~/Library/Application Support/Cyborus.forgejo-cli/keys.json` (macOS) |
| `forgejo.use_git_credentials` | `MISE_FORGEJO_USE_GIT_CREDENTIALS` | bool / `false` | `git credential fill` fallback |

A `credential_command` **replaces** the `git credential fill` fallback and does not require `use_git_credentials`. Output is a single token; trailing whitespace is trimmed.

#### 2.6.19 Secrets: age and sops

([settings#age](https://mise.jdx.dev/configuration/settings.html#age), [#sops](https://mise.jdx.dev/configuration/settings.html#sops))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `age.key_file` *(experimental)* | `MISE_AGE_KEY_FILE` | str / `~/.config/mise/age.txt` | age private key for encryption/decryption |
| `age.identity_files` *(experimental)* | `MISE_AGE_IDENTITY_FILES` | str[]? / unset | age identity files for decryption |
| `age.ssh_identity_files` *(experimental)* | `MISE_AGE_SSH_IDENTITY_FILES` | str[]? / unset | SSH identity files for age decryption |
| `age.strict` *(experimental)* | `MISE_AGE_STRICT` | bool / `true` | fail on decryption failure (missing/invalid key, age unavailable); `false` skips and continues |
| `sops.age_key` | `MISE_SOPS_AGE_KEY` | str? / unset | age private key; takes precedence over `SOPS_AGE_KEY` |
| `sops.age_key_file` | `MISE_SOPS_AGE_KEY_FILE` | str / `~/.config/mise/age.txt` | takes precedence over `SOPS_AGE_KEY_FILE` |
| `sops.age_recipients` | `MISE_SOPS_AGE_RECIPIENTS` | str? / unset | age public keys for sops encryption |
| `sops.rops` | `MISE_SOPS_ROPS` | bool / `true` | use rops instead of shelling out to `sops`. **Required for TOML SOPS files** — the sops CLI doesn't support TOML |
| `sops.strict` | `MISE_SOPS_STRICT` | bool / `true` | fail on sops decryption failure; `false` skips and continues |

All `age.*` settings are marked **[experimental]** in the docs.

#### 2.6.20 System packages, dotfiles, OCI

([settings#system_packages](https://mise.jdx.dev/configuration/settings.html#system_packages), [#dotfiles](https://mise.jdx.dev/configuration/settings.html#dotfiles), [#oci](https://mise.jdx.dev/configuration/settings.html#oci))

| Setting | Env | Type / Default | Purpose |
| --- | --- | --- | --- |
| `system_packages.managers` | `MISE_SYSTEM_PACKAGES_MANAGERS` (comma) | str[]? / unset | restrict which system package managers mise uses from `[bootstrap.packages]` |
| `system_packages.sudo` | `MISE_SYSTEM_PACKAGES_SUDO` | bool / `true` | allow `mise bootstrap packages apply` to elevate. Disabled → errors with the exact manual command. mise logs the full command line and skips sudo when already root |
| `dotfiles.root` | `MISE_DOTFILES_ROOT` | str / `~/.dotfiles` | root for implied dotfile sources |
| `dotfiles.default_mode` | `MISE_DOTFILES_DEFAULT_MODE` | str / `symlink` | `symlink`, `symlink-each`, `copy`, `template` |
| `oci.default_from` | `MISE_OCI_DEFAULT_FROM` | str / `debian:bookworm-slim` | base image for `mise oci build`. **Must be glibc-based**; Alpine breaks glibc-linked prebuilt binaries |
| `oci.default_mount_point` | `MISE_OCI_DEFAULT_MOUNT_POINT` | str / `/mise` | in-image path for tool installs/shims; sets `MISE_DATA_DIR` |
| `oci.insecure_registries` | `MISE_OCI_INSECURE_REGISTRIES` | str[]? / unset | plain-HTTP registries (exact `host` or `host:port`); loopback is always insecure |

```toml
[settings]
system_packages.managers = ["apt"]

[settings.oci]
insecure_registries = ["registry.lan:5000", "10.0.0.8:5000"]
```

#### 2.6.21 Deprecated and hidden settings

Deprecated but still documented ([settings](https://mise.jdx.dev/configuration/settings.html)):

| Setting | Status |
| --- | --- |
| `tera_v1` / `MISE_TERA_V1` | temporary Tera v1 escape hatch; **scheduled for removal in mise 2027.4.0**. For shared configs prefer `MISE_TERA_V1 = true` under `[env]` while migrating so older mise releases don't fail on an unknown setting |
| `aqua.registry_url` | use `aqua.registries` |
| `dotnet.package_flags` | use the `prerelease` tool option or `prereleases` |
| `go.set_gopath` | use `env._go.set_goroot` |
| `go.default_packages_file`, `node.default_packages_file`, `python.default_packages_file`, `ruby.default_packages_file` | use tool-level `postinstall` hooks or the `go:`/`npm:`/`pipx:`/`gem:` backends |

Settings that exist upstream but are **hidden** from the published reference (`hide = true` in [settings.toml](https://github.com/jdx/mise/blob/main/settings.toml)) — documented here only because they appear in older material:

| Setting | Env | Status |
| --- | --- | --- |
| `legacy_version_file` | `MISE_LEGACY_VERSION_FILE` | deprecated → `idiomatic_version_file` |
| `legacy_version_file_disable_tools` | `MISE_LEGACY_VERSION_FILE_DISABLE_TOOLS` | deprecated → `idiomatic_version_file_disable_tools` |
| `idiomatic_version_file`, `idiomatic_version_file_disable_tools` | — | hidden; the supported knobs are `idiomatic_version_file_enable_tools` / `idiomatic_version_file_disable_files` |
| `asdf_compat` | `MISE_ASDF_COMPAT` | "no longer supported"; used to keep `.tool-versions` asdf-compatible |
| `libgit2` | `MISE_LIBGIT2` | hidden, default `true`; use libgit2 for git operations — faster, but may be less compatible if the system libgit2 differs from mise's. Set `false` to shell out to `git` |
| `gix` | — | hidden git-backend switch |
| `shorthands_file` | `MISE_SHORTHANDS_FILE` | deprecated (warn from `2026.6.0`, removal `2026.12.0`) → put the same `shortname = "backend-or-url"` rows in `[plugins]` |
| `npm.bun` | — | hidden; superseded by `npm.package_manager` |
| `task_output`, `task_timeout`, `task_skip`, `task_skip_depends`, `task_disable_paths`, `task_show_full_cmd`, `task_timings`, `task_run_auto_install`, `task_remote_no_cache` | — | hidden flat aliases of the `task.*` group |
| `go_repo`, `go_download_mirror`, `go_set_goroot`, `go_set_gobin`, `go_set_gopath`, `go_skip_checksum`, `go_default_packages_file` | — | hidden flat aliases of the `go.*` group |
| `cd`, `ci`, `debug`, `trace`, `log_level`, `profile`, `install_before` | — | internal/CLI-driven, hidden |

> **Uncertainty:** hidden settings are intentionally absent from <https://mise.jdx.dev/configuration/settings.html>. Their behaviour is only described in the repository's `settings.toml`, so treat them as unsupported and subject to removal.

---

### 2.7 Trust model

mise checks trust **before parsing** `mise.toml` files, because they can contain code-executing or environment-affecting content ([cli/trust](https://mise.jdx.dev/cli/trust.html), [paranoid#config-files](https://mise.jdx.dev/paranoid.html#config-files)).

```sh
$ mise install
mise ~/src/mise/.tool-versions is not trusted. Trust it [y/n]?
```

Behaviour of an untrusted config depends on the code path:

| Situation | What happens |
| --- | --- |
| Interactive command that needs the config | prompts |
| Discovery paths that scan previously tracked configs | may **skip** untrusted files rather than prompt |
| Commands that directly need the config and cannot prompt (e.g. `mise lock`) | **fail** with an untrusted-config error |
| mise detects CI | configs are **assumed trusted** — unless paranoid mode is enabled |

**Safe configs need no trust.** Files containing only `min_version`, `[tools]` entries with plain version strings (or arrays of them), and `[tasks]` **with no templates and no tool options** load without prompting: nothing in them executes at load time; tools install and tasks run only on explicit `mise install` / `mise run` ([cli/trust](https://mise.jdx.dev/cli/trust.html)).

Other exemptions:

- **Global and system configs** (`~/.config/mise/config.toml`, `/etc/mise/config.toml`) are implicitly trusted. This is what lets you enable paranoid mode globally without a trust prompt for that file ([paranoid#config-files](https://mise.jdx.dev/paranoid.html#config-files)).
- **Git worktrees** share trust: a config inside a linked worktree is trusted when the equivalent path in the main checkout has been trusted. Paranoid mode **disables** this sharing, since worktrees can check out branches with different contents ([cli/trust](https://mise.jdx.dev/cli/trust.html)).
- **Monorepo roots**: with `monorepo_root = true`, trusting the root implicitly trusts all descendant configs ([configuration#monorepo-root](https://mise.jdx.dev/configuration.html#monorepo-root)).
- `trusted_config_paths` / `MISE_TRUSTED_CONFIG_PATHS` auto-trusts everything below the listed paths. `["/"]` disables the trust mechanism entirely ([settings#trusted_config_paths](https://mise.jdx.dev/configuration/settings.html#trusted_config_paths)).

#### `mise trust` / `mise untrust`

`mise trust [FLAGS] [CONFIG_FILE]` — modifies state ([cli/trust](https://mise.jdx.dev/cli/trust.html)):

| Flag | Effect |
| --- | --- |
| `-a --all` | trust all config files in the current directory, its parents, **and its subdirectories** |
| `--ignore` | do not trust this config and ignore it in the future |
| `--show` | show trusted status for configs in the current directory and its parents; changes nothing |
| `--untrust` | stop trusting; will prompt again in the future |

```
# trusts ~/some_dir/mise.toml
$ mise trust ~/some_dir/mise.toml

# trusts mise.toml in the current or parent directory
$ mise trust
```

`--all` walks subdirectories respecting `.gitignore`, skipping hidden directories and common build/dependency directories (`node_modules`, `vendor`, `target`, `dist`, `build`).

`mise untrust [CONFIG_FILE]` is the standalone equivalent of `mise trust --untrust` ([cli/untrust](https://mise.jdx.dev/cli/untrust.html)).

---

### 2.8 Paranoid mode

Enable with `MISE_PARANOID=1` or `mise settings paranoid=1` ([paranoid](https://mise.jdx.dev/paranoid.html)). The author notes these are settings he personally finds "too restrictive for the benefits" — this is a deliberate trade.

| Area | Normal | Paranoid |
| --- | --- | --- |
| Which configs need trust | only formats that can execute code / affect env | **all** config files, including formats that normally don't require trust |
| Trust durability | trusted once, forever | file contents are **hashed**; changing the file requires re-trusting |
| Global/system config | implicitly trusted | still implicitly trusted and exempt |
| CI | configs assumed trusted | assumption **removed** |
| Worktree trust sharing | shared with the main checkout | **disabled** |
| Community plugins by short name | `mise plugin install shfmt` works | must give the full git repo unless the plugin is core, mise-team-maintained, or "first-party" |
| HTTP endpoints (version lists, mise update check) | plain HTTP (saves ~10 ms of TLS module load on hot paths) | **all HTTPS** |
| Provenance re-verification when lockfile already has checksum + provenance | skipped to avoid redundant API calls | always re-verified (SLSA, cosign, minisign, GitHub attestations) |

```sh
# under paranoid, community plugins need the full URL
mise plugin install shfmt https://github.com/luizm/asdf-shfmt
```

Provenance re-verification alone can be enabled without full paranoid mode via [`locked_verify_provenance`](https://mise.jdx.dev/configuration/settings.html#locked_verify_provenance).

---

### 2.9 Safe mode

`MISE_SAFE=1` or the [`safe`](https://mise.jdx.dev/configuration/settings.html#safe) setting. Where paranoid tightens *trust* (which configs load, and re-verification), safe mode is a hard boundary on *code execution* — for running mise against configuration you do not control ([security#safe-mode](https://mise.jdx.dev/security.html#safe-mode)).

Canonical use case: a bot refreshing `mise.lock` on PR branches.

```sh
# resolve tool versions from untrusted config without executing any of it
MISE_SAFE=1 mise lock --bump --dry-run --json
```

**Refuses with an error** (never a silent fallback) to:

- run `exec()` or `read_file()` in config templates
- run hooks (suppressed like `--no-hooks`, since hooks fire ambiently from `mise env`/`hook-env`)
- run tasks
- execute asdf plugin scripts
- install plugins

**Ignores from project (non-global) config:** `[env]` values, `_.path`, `_.file`, `[shell_alias]` entries, and `[settings]`. These would otherwise reach your shell environment (via `hook-env`) and the subprocesses mise spawns during resolution (`go list`, vfox plugin hooks) — an indirect code-execution vector through `PATH`, `LD_PRELOAD`, `DYLD_INSERT_LIBRARIES`, `NODE_OPTIONS`, …. Ignoring project `[settings]` stops an untrusted repo disabling verification or redirecting a backend.

`_.source` is treated as **code execution**, so it is ignored regardless of where it is defined — including operator-owned global config.

Global and system config still applies (operator-owned), mirroring the trust model.

**Safe mode does not require trust.** A config loaded in safe mode is inert — it can neither execute code nor inject environment — so mise loads untrusted configs without a prompt or error when `safe` is set. This is exactly what lets automation run `mise lock` against PR config without a preceding `mise trust`.

Still works under safe mode:

- version resolution for every HTTP-based backend: `core`, `aqua`, `github`, `gitlab`, `http`, `cargo`, `pipx`, `gem`, `dotnet`, `npm`
- `go`, run with `GOTOOLCHAIN=local` so a project `go.mod` cannot trigger a toolchain download
- refreshing `mise.lock` and listing installed tools
- already-installed and embedded vfox plugins (operator-chosen code); resolution short-circuits on plugins that are not installed, without executing anything

`MISE_SAFE` is **`global_only`**: settable only via the environment or global config — a project `mise.toml` cannot turn it off for itself.

> The docs are explicit: safe mode limits *what a config can do*; trust limits *which configs are loaded*. They are complementary, not substitutes.

---

### 2.10 Sandboxing

Lightweight process sandboxing for `mise exec` and `mise run`, inspired by [zerobox](https://github.com/afshinm/zerobox). No Docker; minimal overhead. **Any `--deny-*` or `--allow-*` flag implicitly enables sandboxing** ([sandboxing](https://mise.jdx.dev/sandboxing.html)).

```bash
# Full lockdown — no writes, no network, no env vars
mise x --deny-all -- node script.js

# Block network only
mise x --deny-net -- npm run build

# Block writes except to ./dist
mise x --allow-write=./dist -- npm run build

# Block everything, allow specific exceptions
mise x --deny-all --allow-read=. --allow-write=./dist --allow-net=registry.npmjs.org -- npm install
```

| Flag | Description |
| --- | --- |
| `--deny-all` | block reads, writes, network, and env vars |
| `--deny-read` | block filesystem reads (system libs and tool dirs still accessible) |
| `--deny-write` | block all filesystem writes (except `/tmp`) |
| `--deny-net` | block all network access |
| `--deny-env` | block env inheritance (only `PATH`, `HOME`, `USER`, `SHELL`, `TERM`, `LANG` pass through) |
| `--allow-read=<path>` | allow reads from a path (implies `--deny-read` for everything else) |
| `--allow-write=<path>` | allow writes to a path (implies `--deny-write` for everything else) |
| `--allow-net=<host>` | allow network to a host (implies `--deny-net` for everything else) |
| `--allow-env=<var>` | allow an env var through (implies `--deny-env` for everything else); supports wildcards, e.g. `--allow-env='MYAPP_*'` |

Defaults via settings ([sandboxing#default-restrictions](https://mise.jdx.dev/sandboxing.html#default-restrictions)):

```toml
[settings.sandbox]
deny_all = true
```

Tasks can declare their own permissions; **CLI flags on `mise run` override task-level config** ([sandboxing#task-sandboxing](https://mise.jdx.dev/sandboxing.html#task-sandboxing)):

```toml
[tasks.build]
run = "npm run build"
deny_net = true
allow_write = ["./dist"]

[tasks.install]
run = "npm install"
deny_all = true
allow_read = ["."]
allow_write = ["./node_modules"]
allow_net = ["registry.npmjs.org"]

[tasks.test]
run = "npm test"
deny_net = true
deny_write = true
allow_write = ["./coverage", "./node_modules/.cache"]
allow_env = ["NODE_*", "npm_*"]
```

**Implicit access** when filesystem restrictions are active ([sandboxing#implicit-access](https://mise.jdx.dev/sandboxing.html#implicit-access)):

| Category | Paths |
| --- | --- |
| Always readable (Linux) | `/usr`, `/lib`, `/lib64`, `/bin`, `/sbin`, `/etc`, `/dev`, `/proc`, `/sys`, `/tmp`, `/nix`, `/snap`, `/home/linuxbrew` |
| Always readable (macOS) | `/System`, `/Library`, `/usr`, `/bin`, `/sbin`, `/dev`, `/etc`, `/var/run`, `/tmp`, `/private`, `/opt/homebrew`, `/nix` |
| Always readable (both) | mise tool dirs: `~/.local/share/mise/installs/...` |
| Always writable | `/tmp` (and `/private/tmp` on macOS), `/dev` (for `/dev/null`, `/dev/tty`) |

`--allow-write` paths are implicitly readable; `--allow-read` paths include the system essentials above.

Platform support ([sandboxing#platform-support](https://mise.jdx.dev/sandboxing.html#platform-support)):

| Feature | Linux | macOS |
| --- | --- | --- |
| Deny/allow reads | Landlock | Seatbelt |
| Deny/allow writes | Landlock | Seatbelt |
| Deny all network | seccomp | Seatbelt |
| Per-host network (`--allow-net=<host>`) | **Not supported (v1)** | Seatbelt |
| Env filtering | built-in | built-in |
| Docker support | Yes | N/A |

- **Linux:** [Landlock](https://landlock.io/) (Linux 5.13+) for filesystem, [seccomp-bpf](https://www.kernel.org/doc/html/latest/userspace-api/seccomp_filter.html) to block inet socket creation while allowing Unix sockets. If Landlock is unavailable or cannot apply restrictions, **the command fails**. `--allow-net` degrades to allowing *all* network.
- **macOS:** `sandbox-exec` (Seatbelt) with a generated profile; supports everything including per-host filtering.
- **Windows:** not supported — a warning is printed and the command runs **unsandboxed**.

---

### 2.11 URL replacements and corporate mirrors

mise has no built-in artifact registry; it fetches remote registry manifests that name download URLs. In enterprises/DMZs those URLs may be unreachable, so `url_replacements` rewrites **any** URL mise attempts ([url-replacements](https://mise.jdx.dev/url-replacements.html)).

```toml
# single line
[settings]
url_replacements = { "example.com" = "mirror.example.com" }
```

```toml
# multiline
[settings.url_replacements]
"example.com" = "mirror.example.com"
"releases.hashicorp.com" = "hashicorp.example.com"
```

```toml
# regex
[settings.url_replacements]
"regex:^http://(.+)" = "https://$1"
"regex:^https://github\\.com/([^/]+)/([^/]+)/releases/download/(.+)" = "https://hub.example.com/artifactory/github/$1/$2/$3"
```

**Simple replacement** is a plain search-and-replace anywhere in the full URL string (protocol, hostname, path, query):

| Pattern → replacement | Effect |
| --- | --- |
| `github.com` → `mirror.example.com` | replaces GitHub hostnames |
| `https://github.com` → `https://mirror.example.com` | including protocol, so `api.github.com` is excluded |
| `https://github.com` → `https://proxy.example.com/github-mirror` | route through a corporate proxy path |
| `http://example.net` → `https://example.net` | protocol upgrade |

**Regex replacement** when the key starts with `regex:`; the value uses `$1`, `$2`, … capture groups. mise uses the Rust regex engine: `^`/`$` anchors, `(.+)` groups, `[^/]+` classes, `\\.` escaping (double backslash in TOML), `*`/`+`/`?` quantifiers, `|` alternation. Full syntax: <https://docs.rs/regex/latest/regex/#syntax>.

```toml
[settings]
url_replacements = {
  "regex:^https://github\\.com/microsoft/(.+)" =
    "https://internal.example.org/microsoft/$1",
  "regex:^https://github\\.com/(.+)" =
    "https://public.example.org/github/$1",
  "releases.hashicorp.com" = "hashicorp.example.net"
}
```

**Precedence and matching** ([url-replacements#precedence-and-matching](https://mise.jdx.dev/url-replacements.html#precedence-and-matching)):

- processed in configuration order (IndexMap insertion order)
- regex and simple string replacements share that single ordering
- **first match wins**; later patterns are ignored for that URL
- no match → original URL unchanged

> **Security warning (verbatim concern from the docs):** authentication headers generated for the original URL (e.g. `Authorization: Bearer <TOKEN>` for `api.github.com`) are **preserved and sent to the replaced URL**. This is by design so internal proxies can forward to upstream services — but it means redirecting to an untrusted server **leaks your credentials**. Anchor your patterns: `"regex:github\\.com"` also matches `evil-github.com`; `"regex:^https://github\\.com"` does not ([url-replacements#security-considerations](https://mise.jdx.dev/url-replacements.html#security-considerations)).

**netrc interaction:** replacements are applied **before** the netrc lookup, so put the **replaced** hostname in `~/.netrc` (`~/_netrc` on Windows). Credentials from `.netrc` take precedence over and **overwrite** default auth headers such as those derived from `MISE_GITHUB_TOKEN` ([url-replacements#authentication](https://mise.jdx.dev/url-replacements.html#authentication)).

```toml
[settings]
url_replacements = { "regex:^https://github\\.com" = "https://nexus.example.com" }
```

```netrc
machine nexus.example.com
  login myusername
  password mypassword
```

Related corporate-network settings: [`netrc`](https://mise.jdx.dev/configuration/settings.html#netrc), [`netrc_file`](https://mise.jdx.dev/configuration/settings.html#netrc_file), [`aqua.registries`](https://mise.jdx.dev/configuration/settings.html#aqua.registries), [`cargo.registry_name`](https://mise.jdx.dev/configuration/settings.html#cargo.registry_name), [`pipx.registry_url`](https://mise.jdx.dev/configuration/settings.html#pipx.registry_url), [`dotnet.registry_url`](https://mise.jdx.dev/configuration/settings.html#dotnet.registry_url), [`node.mirror_url`](https://mise.jdx.dev/configuration/settings.html#node.mirror_url), [`go.download_mirror`](https://mise.jdx.dev/configuration/settings.html#go.download_mirror), [`ruby.precompiled_url`](https://mise.jdx.dev/configuration/settings.html#ruby.precompiled_url), [`github.oauth_api_url`](https://mise.jdx.dev/configuration/settings.html#github.oauth_api_url), [`oci.insecure_registries`](https://mise.jdx.dev/configuration/settings.html#oci.insecure_registries).

---

### 2.12 Creating, formatting, and inspecting config

#### `mise generate config`

`mise generate config [FLAGS] [PATH]` — creates a `mise.toml` ([cli/generate/config](https://mise.jdx.dev/cli/generate/config.html)).

| Flag | Effect |
| --- | --- |
| `-g --global` | generate the global config file (`~/.config/mise/config.toml`) |
| `-n --dry-run` | show what would be generated, write nothing |
| `-t --tool-versions <PATH>` | import tools from a `.tool-versions` file |

```
mise generate config             # generate mise.toml interactively
mise generate config .mise.toml  # generate a specific file
mise generate config -g          # generate the global config file
mise generate config -y          # skip interactive editor
mise generate config -n          # preview without writing
```

#### `mise fmt`

`mise fmt [FLAGS]` — formats `mise.toml`, sorting keys and cleaning whitespace ([cli/fmt](https://mise.jdx.dev/cli/fmt.html)).

| Flag | Effect |
| --- | --- |
| `-a --all` | format all files from the current directory |
| `-c --check` | check formatting only; format nothing (CI-friendly) |
| `-s --stdin` | read config from stdin, write the formatted version to stdout |

#### Inspecting what mise actually loaded

| Command | Answers |
| --- | --- |
| `mise config ls` | which config files are in use, in precedence order ([cli/config/ls](https://mise.jdx.dev/cli/config/ls.html)) |
| `mise config ls --tracked-configs` | all tracked config files |
| `mise settings --json-extended` | every setting **with its source** ([cli/settings](https://mise.jdx.dev/cli/settings.html)) |
| `mise trust --show` | trusted status of configs in this directory and its parents ([cli/trust](https://mise.jdx.dev/cli/trust.html)) |
| `mise ls --current` | resolved tool versions after all merging ([configuration](https://mise.jdx.dev/configuration.html)) |
| `mise env --redacted --values` | redacted env vars only ([environments#redactions](https://mise.jdx.dev/environments/index.html#redactions)) |
| `mise doctor` | general diagnostics ([cli](https://mise.jdx.dev/cli/)) |
| `mise edit [PATH]` | open a config file in `$EDITOR` ([cli](https://mise.jdx.dev/cli/)) |

The docs' own advice bears repeating: *"Run `mise cfg` to figure out what order mise is loading files on your particular setup. This is often a lot easier than figuring out mise's rules."* ([configuration#mise-toml](https://mise.jdx.dev/configuration.html#mise-toml))

---

## 3. Dev Tools

mise's oldest and largest job is installing and switching between versions of programming-language runtimes and CLI tools — node, python, ruby, terraform, ripgrep, and [hundreds more](https://mise.jdx.dev/registry.html) — driven from a single `mise.toml` per project ([dev-tools](https://mise.jdx.dev/dev-tools/)).

### 3.1 How tool resolution works

When you enter a directory or run a command, mise executes this pipeline ([dev-tools](https://mise.jdx.dev/dev-tools/)):

1. **Configuration discovery** — walk up the directory tree collecting `mise.toml`, `.tool-versions`, etc., and merge them hierarchically.
2. **Tool resolution** — resolve version specs (`node@latest`, `python@3`) to concrete versions using registries and remote version lists.
3. **Backend selection** — pick the [backend](https://mise.jdx.dev/dev-tools/backend_architecture.html) (core, aqua, github, asdf, …) that handles each tool.
4. **Installation check** — verify the resolved versions are installed; auto-install the missing ones.
5. **Environment setup** — prepend tool `bin` dirs to `PATH` and export tool env vars.

`[tools]` merges **additively with overrides** across the config hierarchy: global `node@18, python@3.11` + project `node@20, go@1.21` yields `node@20, python@3.11, go@1.21` ([configuration#merge-behavior-by-section](https://mise.jdx.dev/configuration.html#merge-behavior-by-section)). Check the result with `mise ls --current`.

```bash
# Before mise
echo $PATH
/usr/local/bin:/usr/bin:/bin

# After mise activation in a project with node@20
echo $PATH
/home/user/.local/share/mise/installs/node/20.11.0/bin:/usr/local/bin:/usr/bin:/bin
```

Because mise rewrites `PATH` ahead of time rather than shimming, calling a tool has **zero** overhead and `which node` returns the real versioned path ([dev-tools](https://mise.jdx.dev/dev-tools/)). When a *fuzzy* version like `python = "3.15"` is active, the PATH entry may be the requested-version symlink (`~/.local/share/mise/installs/python/3.15/bin`) rather than the fully-resolved patch directory ([dev-tools/shims](https://mise.jdx.dev/dev-tools/shims.html#path-activation)).

Caching keeps this cheap: version lists are cached daily, downloads are cached, environment resolution is cached, and plugin metadata is cached ([dev-tools#caching-and-performance](https://mise.jdx.dev/dev-tools/#caching-and-performance)). `mise hook-env` exits early when the directory is unchanged and no config file was modified.

---

### 3.2 The `[tools]` table

#### 3.2.1 Value forms

| Form | Example | Meaning |
| --- | --- | --- |
| String version | `node = '24'` | One requested version (fuzzy unless exact) ([dev-tools](https://mise.jdx.dev/dev-tools/)) |
| Array of strings | `python = ['3.10', '3.11']` | Install/activate **multiple** versions of the same tool; the first is first on `PATH` ([configuration](https://mise.jdx.dev/configuration.html)) |
| Inline table | `node = { version = "22", postinstall = "corepack enable" }` | Version plus tool options ([configuration#tools-dev-tools](https://mise.jdx.dev/configuration.html#tools-dev-tools)) |
| Sub-table | `[tools."http:my-tool"]` + `version = "1.0.0"` | Same as inline table, but readable for nested options ([dev-tools#table-format-recommended](https://mise.jdx.dev/dev-tools/#table-format-recommended)) |
| Backend-qualified key | `"cargo:ripgrep" = "14"`, `"core:node" = "20"` | Force a specific backend ([backend_architecture](https://mise.jdx.dev/dev-tools/backend_architecture.html#force-backend-for-tool)) |

```toml
# mise.toml
[tools]
node = '24'
python = '3'
ruby = 'latest'
```

```toml
# ~/.config/mise/config.toml — a list installs several versions at once
[tools]
node = 'lts'
python = ['3.10', '3.11']
```

Tool versions **and** tool options may reference environment variables or [vars](https://mise.jdx.dev/tasks/task-configuration.html#vars) from the config hierarchy — including values produced by `_.source`, `_.file`, or env modules. These are resolved *before* tool version/option templates are rendered ([dev-tools](https://mise.jdx.dev/dev-tools/)).

#### 3.2.2 Universal tool options

These options work on (essentially) any backend; backend-specific options such as `exe`, `matching`, `api_url`, `tags`, `virtualenv` are documented per backend.

| Option | Type | Meaning |
| --- | --- | --- |
| `version` | string | The requested version. Required unless the backend derives it (e.g. `http:` with a `url`) ([dev-tools#tool-options](https://mise.jdx.dev/dev-tools/#tool-options)) |
| `os` | string[] | Restrict install to listed OSes / `os/arch` pairs ([dev-tools#os-specific-tools](https://mise.jdx.dev/dev-tools/#os-specific-tools)) |
| `depends` | string \| string[] | Install-ordering constraint against other tools in the same install set ([dev-tools#tool-dependencies](https://mise.jdx.dev/dev-tools/#tool-dependencies)) |
| `install_env` | table | Env vars set for the backend's install command, and for that tool's `postinstall` ([configuration#tools-dev-tools](https://mise.jdx.dev/configuration.html#tools-dev-tools)) |
| `postinstall` | string | Command run once, immediately after that tool installs successfully ([dev-tools#tool-postinstall-commands](https://mise.jdx.dev/dev-tools/#tool-postinstall-commands)) |
| `prerelease` | bool | Opt this tool into pre-release versions; honored by `github:`, `forgejo:`, `aqua:`, `dotnet:` ([settings#prereleases](https://mise.jdx.dev/configuration/settings.html#prereleases)) |
| `minimum_release_age` | string | Per-tool override of the global release-age cutoff ([cli/latest](https://mise.jdx.dev/cli/latest.html)) |
| `platforms.<os>-<arch>.*` | table | Per-platform `url`/`checksum`/`bin`, mostly for `http:` ([dev-tools#table-format-recommended](https://mise.jdx.dev/dev-tools/#table-format-recommended)) |
| `matching` | string | Pick one asset out of a multi-binary release (github backend) ([dev-tools/aliases](https://mise.jdx.dev/dev-tools/aliases.html#aliased-backends)) |
| `locked` | bool | Backend-specific locking flag, e.g. `cargo:` ([dev-tools#os-specific-tools](https://mise.jdx.dev/dev-tools/#os-specific-tools)) |

#### 3.2.3 Nested options: three equivalent notations

**Table format (recommended)** ([dev-tools#table-format-recommended](https://mise.jdx.dev/dev-tools/#table-format-recommended)):

```toml
[tools."http:my-tool"]
version = "1.0.0"

[tools."http:my-tool".platforms]
macos-x64 = {
  url = "https://example.com/my-tool-macos-x64.tar.gz",
  checksum = "sha256:abc123",
}
linux-x64 = {
  url = "https://example.com/my-tool-linux-x64.tar.gz",
  checksum = "sha256:def456",
}
```

**Dotted notation** ([dev-tools#dotted-notation](https://mise.jdx.dev/dev-tools/#dotted-notation)):

```toml
[tools."http:my-tool"]
version = "1.0.0"
platforms.macos-x64.url = "https://example.com/my-tool-macos-x64.tar.gz"
platforms.linux-x64.url = "https://example.com/my-tool-linux-x64.tar.gz"
simple_option = "value"
```

**Generic nesting** — any backend can organize arbitrary nested options ([dev-tools#generic-nested-support](https://mise.jdx.dev/dev-tools/#generic-nested-support)):

```toml
[tools."custom:my-backend"]
version = "1.0.0"

[tools."custom:my-backend".database]
host = "localhost"
port = 5432

[tools."custom:my-backend".cache.redis]
host = "redis.example.com"
port = 6379
```

Internally, nested options are **flattened to dot notation** (`platforms.macos-x64.url`, `database.host`, `cache.redis.port`) before being handed to the backend ([dev-tools#generic-nested-support](https://mise.jdx.dev/dev-tools/#generic-nested-support)).

#### 3.2.4 `postinstall`

```toml
[tools]
node = { version = "22", postinstall = "corepack enable" }
```

Semantics ([dev-tools#tool-postinstall-commands](https://mise.jdx.dev/dev-tools/#tool-postinstall-commands)):

- Runs once the install completes **successfully** for that tool/version. Failed install → not run.
- The tool's `bin` path is on `PATH` during the command, so you can invoke the freshly-installed tool directly.
- `MISE_TOOL_INSTALL_PATH` is exported, pointing at the tool's install directory, along with any vars from that tool's `install_env`.
- This is **not** the same as `[hooks].postinstall` — it is scoped to one tool.

#### 3.2.5 `os` and `os/arch` restrictions

```toml
[tools]
# Only install on Linux and macOS
ripgrep = { version = "latest", os = ["linux", "macos"] }

# Only install on Windows
"npm:windows-terminal" = { version = "latest", os = ["windows"] }

# Works with other options
"cargo:usage-cli" = {
    version = "latest",
    os = ["linux", "macos"],
    locked = false
}
```

| Identifier | Accepted aliases |
| --- | --- |
| `linux` | — (all Linux distributions) |
| `macos` | `darwin` |
| `windows` | `win` |
| `arm64` | `aarch64` |
| `x64` | `x86_64`, `amd64` |

([dev-tools#os-specific-tools](https://mise.jdx.dev/dev-tools/#os-specific-tools))

```toml
[tools]
# Only install on macOS ARM64 and all Linux (skips macOS x86_64)
hk = { version = "latest", os = ["linux", "macos/arm64"] }

# Only install on Linux x86_64
mytool = { version = "latest", os = ["linux/x64"] }
```

**Rule:** an entry containing `/` requires *both* OS and arch to match; a bare OS name matches any architecture on that OS. If the current OS is not in the list, mise **skips installing and using** the tool entirely ([dev-tools#os-architecture-combinations](https://mise.jdx.dev/dev-tools/#os-architecture-combinations)).

#### 3.2.6 `depends` — install ordering

```toml
[tools]
python = "3.12.11"
"pipx:ruff" = { version = "latest", depends = ["python"] }
```

```toml
[tools]
# Single dependency
"pipx:ruff" = { version = "latest", depends = "python" }

# Multiple dependencies
"pipx:ruff" = { version = "latest", depends = ["python", "pipx"] }
```

`depends` adds **install-graph ordering only**, for tools already in the current install set — use it when parallel installs would otherwise race ([dev-tools#tool-dependencies](https://mise.jdx.dev/dev-tools/#tool-dependencies)).

> **Gotcha:** `depends` does **not** declare hook-time dependencies and does **not** add those tools to the `PATH` used while vfox install hooks run. For vfox plugins, declare hook requirements on the `PLUGIN` table in `metadata.lua` ([dev-tools#vfox-plugin-hook-dependencies](https://mise.jdx.dev/dev-tools/#vfox-plugin-hook-dependencies)):

```lua
PLUGIN = {
    name = "example",
    version = "1.0.0",
    depends = { "go" },
}
```

Backends also carry *implicit* dependencies that mise resolves automatically — node before npm tools, pipx before pipx tools, and so on ([backend_architecture#backend-dependencies](https://mise.jdx.dev/dev-tools/backend_architecture.html#backend-dependencies)).

---

### 3.3 Version specifiers, scopes, and fuzzy matching

#### 3.3.1 Scopes

Both `mise.toml` and `.tool-versions` support "scopes" that modify how a version string is interpreted ([configuration#scopes](https://mise.jdx.dev/configuration.html#scopes)):

| Scope | Example | Meaning |
| --- | --- | --- |
| *(bare exact)* | `node = "20.0.0"` | Exactly that version |
| *(bare fuzzy)* | `node = "20"` | Latest installed/available matching the prefix |
| `latest` | `ruby = "latest"` | Latest stable version |
| `lts` | `node = "lts"` | LTS version — *not supported by all plugins* |
| `ref:<SHA>` | `erlang = "ref:master"` | Compile from a VCS (usually git) ref |
| `prefix:<PREFIX>` | `go = "prefix:1.19"` | Latest version matching the prefix. Needed when the bare string would be an exact match — e.g. Go's `1.20` matches only `1.20`, while `prefix:1.20` matches `1.20.1`, `1.20.2`, … |
| `path:<PATH>` | `shfmt = "path:./shfmt"` | Use a custom compiled build at that path. Handy for reusing Homebrew: `path:/opt/homebrew/opt/node@20` |
| `sub-<PARTIAL>:<ORIG>` | `node = "sub-2:lts"` | Resolve `ORIG`, subtract the numeric components of `PARTIAL` from the corresponding resolved components, then resolve the result as a *prefix* |

**`sub-` is version arithmetic, not "N releases ago"** ([configuration#scopes](https://mise.jdx.dev/configuration.html#scopes)):

- `sub-2:lts` → resolve `lts` (say `20`), subtract 2 from the major → `18`.
- `sub-0.1:latest` → resolve `latest` (say `3.11`), subtract 1 from the minor → `3.10`.

#### 3.3.2 Fuzzy matching everywhere

Unlike asdf — where `latest:20` works on the command line but not in a `.tool-versions` file — mise accepts fuzzy matching in **every** place a version is written ([comparison-to-asdf#ux](https://mise.jdx.dev/dev-tools/comparison-to-asdf.html#ux)).

Whether `mise use` *writes* the fuzzy or exact version is controlled by:

| Control | Effect |
| --- | --- |
| `mise use --fuzzy node@20` | Writes `node = "20"` (**default** behavior) ([cli/use](https://mise.jdx.dev/cli/use.html#fuzzy)) |
| `mise use --pin node@20` | Writes the exact resolved version, e.g. `node = "20.0.0"` ([cli/use](https://mise.jdx.dev/cli/use.html#pin)) |
| `MISE_PIN=1` / `pin = true` | Makes `--pin` the default; override per-invocation with `--fuzzy` ([settings#pin](https://mise.jdx.dev/configuration/settings.html#pin)) |

The docs explicitly recommend `mise.lock` over `--pin` as the better way to get reproducibility while keeping loose ranges in `mise.toml` ([cli/use](https://mise.jdx.dev/cli/use.html#pin)).

#### 3.3.3 Pre-releases

Releases flagged `prerelease: true` are excluded from `mise ls-remote`, `latest` resolution, and fuzzy matching by default. Opt in per-tool with the `prerelease = true` tool option (honored by `github:`, `forgejo:`, `aqua:`, `dotnet:`), globally with `prereleases = true` / `MISE_PRERELEASES=1`, or per-command with `mise ls-remote --prerelease` ([settings#prereleases](https://mise.jdx.dev/configuration/settings.html#prereleases)).

#### 3.3.4 `.tool-versions` compatibility

```text
node        20.0.0       # comments are allowed
ruby        3            # can be fuzzy version
shellcheck  latest       # also supports "latest"
jq          1.6
erlang      ref:master   # compile from vcs ref
go          prefix:1.19  # uses the latest 1.19.x version—needed in case "1.19" is an exact match
shfmt       path:./shfmt # use a custom runtime
node        lts          # use lts version of node (not supported by all plugins)

node        sub-2:lts      # subtract 2 from the resolved major version (e.g.: 20 becomes 18)
python      sub-0.1:latest # subtract 1 from the resolved minor version (e.g.: 3.11 becomes 3.10)
```

([configuration#tool-versions](https://mise.jdx.dev/configuration.html#tool-versions))

#### 3.3.5 Idiomatic version files

mise also reads language-native files (`.node-version`, `.python-version`, `.nvmrc`, `.ruby-version`, …), including nvm aliases such as `lts/hydrogen`. **They are disabled by default**; enable per tool ([configuration#idiomatic-version-files](https://mise.jdx.dev/configuration.html#idiomatic-version-files), [settings#idiomatic_version_file_enable_tools](https://mise.jdx.dev/configuration/settings.html#idiomatic_version_file_enable_tools)):

```bash
mise settings add idiomatic_version_file_enable_tools node
mise settings add idiomatic_version_file_enable_tools python
```

```toml
[settings]
idiomatic_version_file_enable_tools = ['node']
```

---

### 3.4 Requesting, installing, and upgrading

#### 3.4.1 `mise use` — the one command most users need

`mise use` does four things at once ([dev-tools#mise-use](https://mise.jdx.dev/dev-tools/#mise-use)):

1. Installs the tool's plugin if needed
2. Installs the specified version
3. Sets the version active (updates `PATH`)
4. Creates/updates the config file (`mise.toml` or `.tool-versions`)

```shell
> cd my-project
> mise use node@26
# download node, verify signature...
mise node@26.x.x ✓ installed
mise ~/my-project/mise.toml tools: node@26.x.x # mise.toml created/updated

> which node
~/.local/share/mise/installs/node/26/bin/node
```

**Flags** ([cli/use](https://mise.jdx.dev/cli/use.html)):

| Flag | Meaning |
| --- | --- |
| `-e, --env <ENV>` | Write to an environment-specific config, e.g. `mise.<env>.toml` |
| `-f, --force` | Force reinstall even if already installed |
| `-g, --global` | Write to `~/.config/mise/config.toml` |
| `-j, --jobs <JOBS>` | Parallel install jobs (help text says default 4) |
| `-n, --dry-run` | Show what would be installed/modified, change nothing |
| `-p, --path <PATH>` | Target a specific config file, or a directory (then the normal target rules apply within it) |
| `--dry-run-code` | Like `--dry-run` but exits 1 if there are changes to make — for scripts |
| `--fuzzy` | Save the fuzzy version (default unless `MISE_PIN=1`) |
| `--minimum-release-age <AGE>` | Only install versions older than a date (`2024-06-01`) or duration (`90d`, `1y`) |
| `--pin` | Save the exact resolved version |
| `--raw` | Wire backend install stdin/stdout/stderr straight to the terminal; implies `--jobs=1` |
| `--remove… <TOOL>` | Remove the tool(s) from the config file |

```bash
# run with no arguments to use the interactive selector
$ mise use

# set the current version of node to 20.x in mise.toml of current directory
# will write the fuzzy version (e.g.: 20)
$ mise use node@20

# set the current version of node to 20.x in ~/.config/mise/config.toml
# will write the precise version (e.g.: 20.0.0)
$ mise use -g --pin node@20

# sets .mise.local.toml (which is intended not to be committed to a project)
$ mise use --env local node@20

# sets .mise.staging.toml (which is used if MISE_ENV=staging)
$ mise use --env staging node@20
```

Tool options can be passed inline on the CLI with bracket syntax ([cli/use](https://mise.jdx.dev/cli/use.html#tool-version)):

```bash
mise use ubi:BurntSushi/ripgrep[exe=rg]
```

**Which file gets written** — precedence, highest first ([cli/use](https://mise.jdx.dev/cli/use.html)):

1. `--global` → the global config file
2. `--path` → the given path
3. `--env <ENV>` → `mise.<env>.toml`
4. `MISE_DEFAULT_CONFIG_FILENAME`
5. `MISE_OVERRIDE_CONFIG_FILENAMES` (first entry)
6. Otherwise `mise.toml` — or the global config if cwd is the home directory

More precisely, writes go to the **lowest-precedence file in the highest-precedence directory**, so with both `mise.toml` and `mise.local.toml` present, `mise use node@22` writes to `mise.toml` ([configuration#target-file-for-write-operations](https://mise.jdx.dev/configuration.html#target-file-for-write-operations)).

Editing `mise.toml` by hand is equivalent; just run `mise install` afterwards ([dev-tools#mise-use](https://mise.jdx.dev/dev-tools/#mise-use)).

#### 3.4.2 `mise install`

Installs into `~/.local/share/mise/installs/<TOOL>/<VERSION>` but does **not** activate — you still need the version set in a config file, or use `mise exec` ([cli/install](https://mise.jdx.dev/cli/install.html)).

```bash
mise install node@20.0.0  # install specific node version
mise install node@20      # install fuzzy node version
mise install node         # install version specified in mise.toml
mise install              # installs everything specified in mise.toml
```

| Flag | Meaning |
| --- | --- |
| `-f, --force` | Force reinstall |
| `-j, --jobs <JOBS>` | Parallel jobs (help text: default 4). `MISE_JOBS=1` also serializes |
| `-n, --dry-run` | Show what would be installed |
| `-v, --verbose…` | Print backend download/configure/compile output |
| `--dry-run-code` | Exit 1 if tools need installing |
| `--minimum-release-age <AGE>` | Date or duration cutoff |
| `--monorepo` | Install from every `[monorepo].config_roots` root; needs `monorepo_root = true` and explicit roots |
| `--raw` | Direct stdio; implies `--jobs=1` |
| `--shared <SHARED>` | Install into a shared directory instead of the default location (may need elevated permissions) |
| `--system` | Install into `/usr/local/share/mise/installs` (or `MISE_SYSTEM_DATA_DIR/installs`); may need sudo |

> Coming from asdf: there is **no** need to run `mise plugin add` first — the plugin is installed automatically ([dev-tools#mise-install](https://mise.jdx.dev/dev-tools/#mise-install)).

> **Uncertainty:** the [settings#locked](https://mise.jdx.dev/configuration/settings.html#locked) page says `locked = true` is "equivalent to passing `--locked` to `mise install`", but `--locked` is not listed among the flags on [cli/install](https://mise.jdx.dev/cli/install.html). Prefer the `MISE_LOCKED=1` env var or the setting.

#### 3.4.3 `mise upgrade`

Upgrades within the range in `mise.toml` (so `node@20` → latest `20.x.x`), and updates `mise.lock` when lockfiles are enabled ([cli/upgrade](https://mise.jdx.dev/cli/upgrade.html)).

| Flag | Meaning |
| --- | --- |
| `-i, --interactive` | Multiselect menu of tools to upgrade |
| `-j, --jobs <JOBS>` | Parallel jobs (default 4 per help) |
| `-l, --bump` | Upgrade to the newest version available **and rewrite `mise.toml`**, preserving the original precision (`20.0.0`→`22.1.0`; `20`→`22`) |
| `-n, --dry-run` | Print only |
| `-x, --exclude… <TOOL>` | Exclude tools from upgrading |
| `--dry-run-code` | Exit 1 if there are outdated tools |
| `--inactive` | Also upgrade installed-but-inactive tools not in the current config |
| `--local` | Only tools defined in project-local `mise.toml`; skip the global config |
| `--minimum-release-age <AGE>` | Only fuzzy matches are filtered; pinned versions like `22.5.0` are not |
| `--monorepo` | **Placeholder — not implemented yet** |
| `--raw` | Direct stdio; implies `--jobs=1` |

```bash
$ mise upgrade node            # latest matching the range in mise.toml
$ mise upgrade node --bump     # latest, and bump the version in mise.toml
$ mise upgrade                 # all tools
$ mise upgrade --bump          # all tools + bump config
$ mise upgrade --dry-run
$ mise upgrade node python
$ mise upgrade --exclude go
$ mise upgrade --interactive
$ mise upgrade --local
```

#### 3.4.4 `mise outdated`

Read-only view of what `mise upgrade` would do ([cli/outdated](https://mise.jdx.dev/cli/outdated.html)).

| Flag | Meaning |
| --- | --- |
| `-J, --json` | JSON output |
| `-l, --bump` | Compare against the absolute latest, not just what matches the current range |
| `--inactive` | Include installed-but-inactive tools |
| `--local` | Local configs only |
| `--monorepo` | **Placeholder — not implemented yet** |
| `--no-header` | Suppress the table header |

```
$ mise outdated
Plugin  Requested  Current  Latest
python  3.11       3.11.0   3.11.1
node    20         20.0.0   20.1.0

$ mise outdated --json
{"python": {"requested": "3.11", "current": "3.11.0", "latest": "3.11.1"}, ...}
```

#### 3.4.5 Removal: `uninstall`, `unuse`, `prune`

| Command | Touches installs? | Touches `mise.toml`? |
| --- | --- | --- |
| `mise uninstall node@18.0.0` | Yes — deletes the install | **No** ([cli/uninstall](https://mise.jdx.dev/cli/uninstall.html)) |
| `mise unuse node@18.0.0` (`rm`, `remove`) | Yes — also prunes unless `--no-prune` | **Yes** — removes it from config ([cli/unuse](https://mise.jdx.dev/cli/unuse.html)) |
| `mise use --remove node` | No install change | Yes — removes from config ([cli/use](https://mise.jdx.dev/cli/use.html#remove-tool)) |
| `mise prune` | Yes — deletes unused versions | No ([cli/prune](https://mise.jdx.dev/cli/prune.html)) |

`mise uninstall` flags: `-a/--all` (delete all installed versions), `-n/--dry-run`, `--dry-run-code`.

`mise unuse` flags: `-e/--env`, `-g/--global`, `-p/--path`, `--no-prune`. It follows the same target-file rules as `mise use`.

`mise prune` deletes versions that are no longer the latest specified in any config tracked in `~/.local/state/mise/tracked-configs`. Versions installed **only** via `MISE_<TOOL>_VERSION` env vars or **only** referenced on the command line (`mise exec <TOOL>@<VERSION>`) are deleted. Tool versions referenced by an *executed* stub tracked in `~/.local/state/mise/tracked-stubs` are protected ([cli/prune](https://mise.jdx.dev/cli/prune.html)).

| `mise prune` flag | Meaning |
| --- | --- |
| `-n, --dry-run` | Don't delete |
| `--configs` | Prune only tracked/trusted config links pointing at nonexistent configs |
| `--tools` | Prune only unused tool versions |
| `--dry-run-code` | Exit 1 if there is something to prune |
| `--monorepo` | **Placeholder — not implemented yet** |

List candidates first with `mise ls --prunable`.

#### 3.4.6 Ad-hoc execution and session overrides

```bash
mise x python@3.12 -- ./myscript.py       # installs python 3.12 if missing
mise exec node@20 -- node ./app.js
mise exec node@20 python@3.11 --command "node -v && python -V"
mise x -C /path/to/project node@20 -- node ./app.js
alias mx="mise x --"
```

`mise exec` loads local/global config too, so only the tools you name are overridden — a config with `node 20` plus `mise exec python@3.11` still gives you node 20 ([cli/exec](https://mise.jdx.dev/cli/exec.html)).

| `mise exec` flag | Meaning |
| --- | --- |
| `-c, --command <C>` | Command string (alternative to `-- CMD`) |
| `-j, --jobs <JOBS>` | Parallel jobs |
| `--fresh-env` | Bypass the environment cache and recompute |
| `--no-deps` | Skip automatic `mise deps` preparation |
| `--raw` | Direct stdio; implies `--jobs=1` |
| `--deny-all` | Block reads, writes, network, env vars |
| `--deny-env` / `--allow-env… <VAR>` | Block env inheritance (only `PATH`, `HOME`, `USER`, `SHELL`, `TERM`, `LANG` pass) / allow-list with wildcards (`--allow-env='MYAPP_*'`) |
| `--deny-net` / `--allow-net… <HOST>` | Block network / allow specific hosts (**macOS only in v1**; Linux falls back to allowing all network) |
| `--deny-read` / `--allow-read… <PATH>` | Block reads (system libs and tool dirs still accessible) / allow-list |
| `--deny-write` / `--allow-write… <PATH>` | Block writes / allow-list |

`mise shell <TOOL@VERSION>…` (alias `sh`) sets the version for the **current shell session** by exporting `MISE_NODE_VERSION=20`-style vars evaluated by the shell function `mise activate` installed. It only works where mise is already activated. Flags: `-j/--jobs`, `-u/--unset`, `--raw` ([cli/shell](https://mise.jdx.dev/cli/shell.html)).

#### 3.4.7 Auto-install mechanisms

All of these require the global [`auto_install`](https://mise.jdx.dev/configuration/settings.html#auto_install) setting, and **all auto-install settings default to enabled** ([dev-tools#auto-install-mechanisms](https://mise.jdx.dev/dev-tools/#auto-install-mechanisms)).

| Trigger | Setting | Default | Notes |
| --- | --- | --- | --- |
| `mise x` / `mise exec` | `exec_auto_install` | `true` | Installs missing versions needed for the command |
| `mise r` / `mise run` | `task_auto_install` | `true` | Same, for tasks |
| Shell "command not found" handler | `not_found_auto_install` | `true` | **Only works for tools that already have ≥1 version installed** — mise can't map an arbitrary binary name to a tool otherwise. Also runs in shims when the terminal is interactive |

Disable for specific tools with `auto_install_disable_tools = [...]` ([settings#auto_install_disable_tools](https://mise.jdx.dev/configuration/settings.html#auto_install_disable_tools)).

#### 3.4.8 Inspection commands

```bash
$ mise ls                    # everything mise "knows about"
$ mise ls --current          # what's active right now
$ mise ls --json
$ mise ls --all-sources
node    20.0.0  ~/src/myapp/mise.toml  20
                ~/.config/mise/config.toml  latest
```

| `mise ls` flag | Meaning |
| --- | --- |
| `-c, --current` | Only versions specified in a `mise.toml` |
| `-g, --global` | Only versions from the global config |
| `-i, --installed` | Only installed versions (hides configured-but-missing) |
| `-J, --json` | JSON output |
| `-l, --local` | Only versions from the local `mise.toml` |
| `-m, --missing` | Show missing versions |
| `--all-sources` | Show every tracked config source per tool |
| `--monorepo` | List across `[monorepo].config_roots` |
| `--no-header` / `--outdated` / `--prefix <PREFIX>` / `--prunable` | Suppress headers / mark outdated / filter by version prefix / only prunable |

([cli/ls](https://mise.jdx.dev/cli/ls.html))

```bash
$ mise ls-remote node          # available versions
$ mise ls-remote node@20
$ mise ls-remote node 20       # PREFIX as a positional
$ mise ls-remote github:cli/cli --json
[{"version":"2.62.0","created_at":"2024-11-14T15:40:35Z","prerelease":false}, ...]
```

`mise ls-remote` flags: `--all`, `-J/--json` (includes `created_at` metadata where available), `--minimum-release-age <AGE>`, `--no-versions-host` (skip the mise-versions cache host), `--prerelease`, `--strict-metadata` (fail on metadata-fetch errors; **requires `--json` and `--no-versions-host`**). Results may be cached — `mise cache clean` to refresh ([cli/ls-remote](https://mise.jdx.dev/cli/ls-remote.html)).

```bash
$ mise latest node@20      # 20.0.0
$ mise latest node         # latest stable
$ mise latest node -i      # latest *installed*
$ mise where node@20       # /home/jdx/.local/share/mise/installs/node/20.0.0
$ mise which node          # /home/.../installs/node/20.0.0/bin/node
$ mise which node --plugin # node
$ mise which node --version# 20.0.0
$ mise which npm --tool=node@20
```

`mise latest` flags: `-i/--installed`, `--minimum-release-age` (overrides per-tool and global settings) ([cli/latest](https://mise.jdx.dev/cli/latest.html)). `mise where` errors if the tool isn't installed / isn't referenced anywhere ([cli/where](https://mise.jdx.dev/cli/where.html)). `mise which` flags: `-t/--tool <TOOL@VERSION>`, `--plugin`, `--version` ([cli/which](https://mise.jdx.dev/cli/which.html)).

`mise tool <TOOL>` reports the backend and resolution for one tool ([cli/tool](https://mise.jdx.dev/cli/tool.html)):

```
$ mise tool node
Backend:            core
Installed Versions: 20.0.0 22.0.0
Active Version:     20.0.0
Requested Version:  20
Config Source:      ~/.config/mise/mise.toml
Tool Options:       [none]
```

Flags: `-J/--json`, `--active`, `--backend`, `--config-source`, `--description`, `--installed`, `--requested`, `--tool-options` (each restricts output to one field).

#### 3.4.9 Adopting externally-built tools

`mise link <TOOL@VERSION> <PATH>` (alias `ln`) symlinks an existing install into mise; `-f/--force` overwrites ([cli/link](https://mise.jdx.dev/cli/link.html)):

```bash
# build node-20.0.0 with node-build and link it into mise
$ node-build 20.0.0 ~/.nodes/20.0.0
$ mise link node@20.0.0 ~/.nodes/20.0.0

# have mise use the node version provided by Homebrew
$ brew install node
$ mise link node@brew $(brew --prefix node)
$ mise use node@brew
```

`mise sync` bulk-imports from other version managers ([cli/sync](https://mise.jdx.dev/cli/sync.html)). It won't overwrite existing installs, but **will** overwrite existing symlinks.

| Subcommand | Flags | Notes |
| --- | --- | --- |
| `mise sync node` | `--brew`, `--nodenv`, `--nvm` | ([cli/sync/node](https://mise.jdx.dev/cli/sync/node.html)) |
| `mise sync python` | `--pyenv`, `--uv` | `--uv` is a **2-way** sync ([cli/sync/python](https://mise.jdx.dev/cli/sync/python.html)) |
| `mise sync ruby` | `--brew` | ([cli/sync/ruby](https://mise.jdx.dev/cli/sync/ruby.html)) |

```bash
brew install node@18 node@20
mise sync node --brew
mise use -g node@18   # uses Homebrew-provided node

uv python install 3.11.0
mise install python@3.10.0
mise sync python --uv
mise x python@3.11.0 -- python -V   # uses uv-provided python
uv run -p 3.10.0 -- python -V       # uses mise-provided python
```

`mise test-tool [TOOLS]…` verifies a tool installs and executes. Flags: `-a/--all` (every tool in `registry/`), `-j/--jobs` (default 4), `--all-config` (all tools in config files), `--include-non-defined` (guess how to test tools not in the registry), `--raw` ([cli/test-tool](https://mise.jdx.dev/cli/test-tool.html)).

---

### 3.5 Lockfile: `mise.lock`

`mise.lock` pins exact versions and checksums for reproducible environments — the `package-lock.json`/`Cargo.lock` of mise ([dev-tools/mise-lock](https://mise.jdx.dev/dev-tools/mise-lock.html)). It buys you: reproducible builds, checksum-verified integrity, version pinning that keeps `mise.toml` loose, and **avoidance of GitHub/registry API rate limits** because download URLs are stored.

#### 3.5.1 Enabling

**Lockfiles are never created automatically — you must run `mise lock`** (or `touch mise.lock` and install). Once one exists, mise keeps it updated ([dev-tools/mise-lock](https://mise.jdx.dev/dev-tools/mise-lock.html), [settings#lockfile](https://mise.jdx.dev/configuration/settings.html#lockfile)).

```sh
# Enable lockfiles globally
mise settings lockfile=true
```

```toml
[settings]
lockfile = true
```

| `lockfile` value | Behavior |
| --- | --- |
| `true` | Lockfiles read and written |
| `false` | Explicitly disabled — **errors** if `locked = true` is also set |
| unset (default) | Enabled (same as `true`) but no conflict with `locked` mode |

([settings#lockfile](https://mise.jdx.dev/configuration/settings.html#lockfile))

#### 3.5.2 File format

```toml
# Example mise.lock
[[tools.node]]
version = "20.11.0"
backend = "core:node"

[tools.node.platforms.linux-x64]
checksum = "sha256:a6c213b7a2c3b8b9c0aaf8d7f5b3a5c8d4e2f4a5b6c7d8e9f0a1b2c3d4e5f6a7"
size = 23456789
url = "https://nodejs.org/dist/v20.11.0/node-v20.11.0-linux-x64.tar.xz"

[[tools.python]]
version = "3.11.7"
backend = "core:python"

[tools.python.platforms.linux-x64]
checksum = "sha256:def456..."
size = 12345678

# Tool with backend-specific options
[[tools.ripgrep]]
version = "14.1.1"
backend = "aqua:BurntSushi/ripgrep"
options = { exe = "rg" }

[tools.ripgrep.platforms.linux-x64]
checksum = "sha256:4cf9f2741e6c465ffdb7c26f38056a59e2a2544b51f7cc128ef28337eeae4d8e"
size = 1234567
```

| Field | Level | Required | Meaning |
| --- | --- | --- | --- |
| `version` | `[[tools.<name>]]` | **yes** | Exact version |
| `backend` | `[[tools.<name>]]` | no | Backend used, e.g. `core:node`, `aqua:BurntSushi/ripgrep` |
| `options` | `[[tools.<name>]]` | no | Backend options that identify the artifact, e.g. `{exe = "rg", matching = "musl"}` |
| `platforms` | `[[tools.<name>]]` | no | Per-platform metadata table |
| `checksum` | `platforms.<key>` | no | SHA256 or Blake3 hash |
| `size` | `platforms.<key>` | no | File size in bytes |
| `url` | `platforms.<key>` | no | Original download URL |

([dev-tools/mise-lock#file-format](https://mise.jdx.dev/dev-tools/mise-lock.html#file-format))

**Platform keys** are generally `os-arch` (`linux-x64`, `macos-arm64`, `windows-x64`), but backends may customize them — Java uses more specific identifiers, `ubi` may embed tool-specific information ([dev-tools/mise-lock#platform-keys](https://mise.jdx.dev/dev-tools/mise-lock.html#platform-keys)).

**Multiple entries per version.** When a tool's artifact identity depends on more than the platform key, several `[[tools.<name>]]` entries share a version. Swift publishes a distro-specific Linux tarball:

```toml
[[tools.swift]]
version = "6.3.1"
backend = "core:swift"
options = { swift_platform = "ubuntu24.04" }

[[tools.swift]]
version = "6.3.1"
backend = "core:swift"
options = { swift_platform = "fedora39" }
```

Entries are matched on **options exactly**, so a machine only verifies against its own distro's entry. Pin `swift.platform` to make every Linux machine resolve the same artifact. A platform whose artifact the vendor doesn't publish (e.g. `ubi9` arm64) is reported as **skipped**, not locked ([dev-tools/mise-lock#tool-entry-fields](https://mise.jdx.dev/dev-tools/mise-lock.html#tool-entry-fields)).

#### 3.5.3 Environment-specific and local lockfiles

| Config file | Lockfile |
| --- | --- |
| `mise.toml` | `mise.lock` |
| `mise.test.toml` | `mise.test.lock` |
| `mise.staging.toml` | `mise.staging.lock` |
| `mise.local.toml` | `mise.local.lock` |
| `mise.test.local.toml` | `mise.test.local.lock` |

([dev-tools/mise-lock#environment-specific-lockfiles](https://mise.jdx.dev/dev-tools/mise-lock.html#environment-specific-lockfiles))

```sh
MISE_ENV=test mise lock  # creates mise.lock AND mise.test.lock
```

Environment lockfiles are **strictly scoped**: `mise.test.lock` contains only tools defined in `mise.test.toml`. This means CI that doesn't set `MISE_ENV` depends only on `mise.lock`, so dev-tool bumps in `mise.dev.lock` don't invalidate CI caches. Commit `mise.lock` and `mise.<env>.lock`; gitignore `mise.local.lock` and `mise.<env>.local.lock` alongside their configs.

```sh
mise lock --local              # update mise.local.lock
mise lock --local node python  # update specific tools in mise.local.lock
```

**Monorepos:** with `monorepo_root = true`, set `[monorepo] lockfile = true` to opt into a single root lockfile (`mise.lock`, `mise.ci.lock`, `mise.local.lock`). Existing subproject lockfiles migrate into the root lockfile on the next lock-aware command. Version-sensitive: monorepos using `mise*.lock` files **start warning in mise 2026.12.0**, and unset **defaults to root lockfiles in mise 2027.6.0**. Pin the old behavior with `[monorepo] lockfile = false` ([dev-tools/mise-lock#monorepos](https://mise.jdx.dev/dev-tools/mise-lock.html#monorepos)).

#### 3.5.4 Strict mode (`locked`)

```sh
mise settings locked=true
# or
MISE_LOCKED=1 mise install
```

`locked` forces every tool to have a pre-resolved URL in the lockfile for the current platform before install, eliminating GitHub/aqua API calls ([dev-tools/mise-lock#strict-lockfile-mode](https://mise.jdx.dev/dev-tools/mise-lock.html#strict-lockfile-mode)).

> **Gotcha:** all mise settings are **global in scope**. Setting `locked = true` in a project's `mise.toml` applies to **all** tool resolution, including tools from `~/.config/mise/config.toml`. If you see warnings about global tools missing from the lockfile, run `mise lock -g`.

```sh
mise lock                                   # generate URLs for all platforms
mise lock --platform linux-x64,macos-arm64  # or specific platforms
```

#### 3.5.5 `mise lock` flags

| Flag | Meaning |
| --- | --- |
| `-g, --global` | Only global config lockfiles (`~/.config/mise/mise.lock` and system config) |
| `-j, --jobs <JOBS>` | Parallel jobs |
| `-n, --dry-run` | Show what would be updated |
| `-p, --platform… <PLATFORM>` | Comma-separated targets, e.g. `linux-x64,macos-arm64,windows-x64`. Default: all platforms already in the lockfile |
| `--bump` | Re-resolve fuzzy selectors (`latest`, `lts`, `20`) against the latest matching remote versions. Installs nothing; **never modifies config files** |
| `--json` | Emit version changes as JSON and suppress human output |
| `--local` | Update `mise.local.lock` instead of `mise.lock` |
| `--minimum-release-age <AGE>` | Only lock versions older than a date/duration. Affects fuzzy matches only; existing matching entries are preserved and never downgraded by this flag alone |

([cli/lock](https://mise.jdx.dev/cli/lock.html))

```sh
mise lock                       # update lockfile for all common platforms
mise lock node python           # update only node and python
mise lock --platform linux-x64  # update only linux-x64 platform
mise lock --dry-run             # show what would be updated
mise lock --bump                # re-resolve selectors like "latest" or "20"
mise lock --bump --dry-run --json   # list available updates as JSON without writing
mise lock --minimum-release-age 2024-01-01
mise lock --local
mise lock --global
```

`--bump` JSON is designed for scheduled dependency-update jobs:

```json
[
  {
    "name": "node",
    "backend": "core:node",
    "lockfile": "~/src/myproj/mise.lock",
    "old_versions": ["22.14.0"],
    "new_versions": ["22.15.0"]
  }
]
```

Only **version-level** changes are reported — checksum/URL refreshes for unchanged versions produce no entries, so plain `mise lock --json` typically prints `[]` while still updating the file. Version lists keep config/lockfile order (not sorted). Tools removed from config appear with an empty `new_versions` ([cli/lock](https://mise.jdx.dev/cli/lock.html#json), [dev-tools/mise-lock#bumping-locked-versions](https://mise.jdx.dev/dev-tools/mise-lock.html#bumping-locked-versions)).

> **Security note for bots:** when a bump job runs against configuration you don't control (e.g. bumping `mise.lock` on PR branches), set `MISE_SAFE=1`. Safe mode refuses template `exec()`, `_.source` scripts, hooks, tasks, asdf plugin scripts, and plugin installs, while `--bump` resolution over HTTP-based backends keeps working ([dev-tools/mise-lock](https://mise.jdx.dev/dev-tools/mise-lock.html), [security#safe-mode](https://mise.jdx.dev/security.html#safe-mode)):
> ```sh
> MISE_SAFE=1 mise lock --bump --json
> ```

#### 3.5.6 Command behavior matrix

| Command | Installs | Updates `mise.toml` | Updates `mise.lock` |
| --- | --- | --- | --- |
| `mise use node@22` | Yes | Yes (sets `node = "22"`) | Yes |
| `mise install` | Yes | No | Yes |
| `mise install node` | Yes | No | Yes (installs config version for node) |
| `mise install node@22.15.0` | Yes | No | **No** (one-off install, not config-driven) |
| `mise upgrade` | Yes | No | Yes |
| `mise upgrade node` | Yes | No | Yes (upgrades node within its range) |
| `mise upgrade node@22.15.0` | Yes | Only if version doesn't match prefix | Yes |
| `mise upgrade --bump` | Yes | Yes (bumps prefix to match) | Yes |
| `mise lock` | **No** | No | Yes (regenerates for all tools) |
| `mise lock --bump` | **No** | No | Yes (re-resolves selectors to latest) |
| `mise lock node@22.15.0` | **No** | Only if version doesn't match prefix | Yes |

([dev-tools/mise-lock#command-behavior-with-lockfiles](https://mise.jdx.dev/dev-tools/mise-lock.html#command-behavior-with-lockfiles))

Pinning a locked version while keeping a fuzzy `mise.toml` spec:

```sh
# mise.toml has node = "latest" or node = "22"
mise upgrade node@22.15.0   # installs 22.15.0 and updates mise.lock
mise lock node@22.15.0      # updates mise.lock without reinstalling
```

If the version doesn't match the config prefix, the config is bumped automatically at the **same precision level** — `node = "20"` + `mise upgrade node@22.15.0` → `node = "22"` in config, `22.15.0` in the lockfile.

#### 3.5.7 Backend support for lockfile fields

| Level | Backends |
| --- | --- |
| ✅ Full (version + checksum + size + URL) | `aqua`, `http`, `github`, `gitlab` |
| ↳ Provenance support | `aqua`, `github`, `core:python` (precompiled), `core:ruby` (precompiled), `core:zig` (install-time) |
| ⚠️ Partial (version + URL + provenance) | `vfox` (tool plugins only) |
| ⚠️ Partial (version + checksum + size) | `ubi` |
| 📝 Basic (version + checksum) | `core` (some tools) |
| 📝 Version only | `asdf`, `npm`, `cargo`, `pipx` |

([dev-tools/mise-lock#backend-support](https://mise.jdx.dev/dev-tools/mise-lock.html#backend-support))

#### 3.5.8 CI usage and workflow

```sh
# Initial setup
mise lock       # generate the lockfile
mise install    # install tools using locked versions

# Daily
mise install    # exact versions from lockfile
mise upgrade    # update tools and lockfile
```

```yaml
# Example GitHub Actions
- name: Install tools
  run: |
    mise install  # Uses exact versions from mise.lock

- name: Cache lockfile
  uses: actions/cache@v5
  with:
    key: mise-lock-${{ hashFiles('mise.lock') }}
```

([dev-tools/mise-lock#ci-cd](https://mise.jdx.dev/dev-tools/mise-lock.html#ci-cd))

Team workflow: lead updates `mise.toml` ranges → runs `mise install` to refresh `mise.lock` → commits both → members pull and run `mise install`. Always `git add mise.lock`.

**Migration from asdf:**

```sh
mise config generate          # convert .tool-versions to mise.toml
mise settings lockfile=true
mise lock
mise install
```

**From `package.json` engines:** `mise use node@$(jq -r '.engines.node' package.json)`.

**Troubleshooting.** Bad checksums → `mise uninstall --all && mise install`. Merge conflicts → resolve in `mise.lock`, run `mise install` to verify, commit. Disable per project with `[settings] lockfile = false`. Precompiled Ruby build revisions keep `version = "3.3.11"` in the lockfile while the revision lives in the platform `url` (`.../download/3.3.11-1/ruby-3.3.11.x86_64_linux.tar.gz`, where `-1` is build revision 1) ([dev-tools/mise-lock#troubleshooting](https://mise.jdx.dev/dev-tools/mise-lock.html#troubleshooting)).

#### 3.5.9 Provenance and supply chain

`mise lock` records a verified provenance type (`slsa`, `cosign`, `minisign`, `github-attestations`) per tool where available. For the **current platform** it downloads the artifact and performs full cryptographic verification at lock time (aqua and github backends). Cross-platform entries get provenance detected from registry metadata **without** verification ([dev-tools/mise-lock#provenance-and-security](https://mise.jdx.dev/dev-tools/mise-lock.html#provenance-and-security)).

By default `mise install` trusts a lockfile carrying both a checksum and verified provenance and skips re-verification — this avoids redundant GitHub attestation API calls that cause CI rate-limit problems. `github_attestations = "unavailable"` is a **negative cache entry, not provenance**: it only skips the redundant probe; SLSA/Cosign/Minisign/checksum verification still run. Attestations can appear *after* a release asset is uploaded, so a later `mise lock` or `MISE_LOCKED_VERIFY_PROVENANCE=1 mise install` can discover them.

```toml
[settings]
locked_verify_provenance = true   # force re-verification on every install
```

```toml
[settings]
paranoid = true    # implies locked_verify_provenance
```

**Minimum release age** complements lockfiles: `minimum_release_age` defaults to **`24h`** and filters top-level fuzzy resolution for backends that report release timestamps; versions without timestamps are included by default ([settings#minimum_release_age](https://mise.jdx.dev/configuration/settings.html#minimum_release_age), [dev-tools/mise-lock#minimum-release-age](https://mise.jdx.dev/dev-tools/mise-lock.html#minimum-release-age)).

```toml
[settings]
minimum_release_age = "7d"  # override the default 24h delay
```

Accepts relative durations (`7d`, `90d`, `6mo`, `1y`) and absolute dates (`2024-06-01`, `2024-06-01T12:00:00Z`). Only `npm:` and `pipx:` forward the same cutoff into **transitive** dependency resolution; other backends constrain only the top-level tool version.

---

### 3.6 Tool stubs

A tool stub is an executable file whose shebang points at `mise tool-stub` and whose body is TOML describing which tool to run. Running it installs the tool if needed and executes it with your arguments. Inspired by [dotslash](https://github.com/facebook/dotslash) ([dev-tools/tool-stubs](https://mise.jdx.dev/dev-tools/tool-stubs.html)).

The killer property: **lazy installation**. Tools are fetched only when their stub is first executed, not during `mise install` — ideal for specialized/rarely-used binaries.

#### 3.6.1 Format

```bash
#!/usr/bin/env -S mise tool-stub
# Optional comment describing the tool

version = "1.0.0"
tool = "python"
bin = "python"
```

`env -S` splits the shebang on spaces (`env` → `mise` → `tool-stub`), working around the traditional Unix single-argument shebang limit ([dev-tools/tool-stubs](https://mise.jdx.dev/dev-tools/tool-stubs.html#tool-non-http-stubs)).

Stub config is **a subset of `mise.toml` `[tools]` options plus one extra field**:

| Field | Required | Meaning |
| --- | --- | --- |
| `tool` | optional | Tool name or backend spec (`"python"`, `"github:cli/cli"`). **The only field unique to stubs.** If omitted and `url` is present, defaults to the HTTP backend |
| `version` | optional | Version of the tool |
| `bin` | optional | Binary to execute inside the tool; **defaults to the stub filename** |
| *(any `[tools]` option)* | optional | All the same options available in `mise.toml` tool config are supported |

([dev-tools/tool-stubs#configuration-fields](https://mise.jdx.dev/dev-tools/tool-stubs.html#configuration-fields))

#### 3.6.2 HTTP stubs and platforms

```toml
#!/usr/bin/env -S mise tool-stub
url = "https://example.com/releases/1.0.0/tool-linux-x64.tar.gz"
```

```toml
#!/usr/bin/env -S mise tool-stub
[platforms.linux-x64]
url = "https://example.com/releases/1.0.0/tool-linux-x64.tar.gz"

[platforms.darwin-arm64]
url = "https://example.com/releases/1.0.0/tool-macos-arm64.tar.gz"
```

Platform-specific binary paths override a global `bin`:

```toml
#!/usr/bin/env -S mise tool-stub
# Global bin field used when platforms have the same structure
bin = "bin/tool"

[platforms.linux-x64]
url = "https://example.com/tool-linux.tar.gz"
# Uses global bin field: "bin/tool"

[platforms.windows-x64]
url = "https://example.com/tool-windows.zip"
bin = "tool.exe"  # Platform-specific binary for Windows
```

URLs support templating against `version`:

```toml
#!/usr/bin/env -S mise tool-stub
# Custom HTTP tool with platform-specific downloads

version = "1.0.0"

[platforms.linux-x64]
url = "https://releases.example.com/v{{version}}/tool-linux-x64.tar.gz"

[platforms.darwin-arm64]
url = "https://releases.example.com/v{{version}}/tool-macos-arm64.tar.gz"
```

#### 3.6.3 Generating stubs

```bash
mise generate tool-stub ./bin/gh --url "https://github.com/cli/cli/releases/download/v2.336.0/gh_2.336.0_linux_amd64.tar.gz"
```

This downloads the archive to compute checksums, extracts it to auto-detect the binary path, and writes an executable stub ([dev-tools/tool-stubs#basic-generation](https://mise.jdx.dev/dev-tools/tool-stubs.html#basic-generation)):

```bash
#!/usr/bin/env -S mise tool-stub

version = "latest"
bin = "bin/gh"
url = "https://github.com/cli/cli/releases/download/v2.336.0/gh_2.336.0_linux_amd64.tar.gz"
checksum = "blake3:a1b2c3d4e5f6..."
size = 12345678
```

**Incremental building:** with platform-specific URLs the generator **appends** new platforms to an existing stub rather than overwriting it; re-specifying an existing platform updates its URL.

```bash
mise generate tool-stub ./bin/rg \
  --platform-url linux-x64:https://github.com/BurntSushi/ripgrep/releases/download/14.0.3/ripgrep-14.0.3-x86_64-unknown-linux-musl.tar.gz \
  --platform-url darwin-arm64:https://github.com/BurntSushi/ripgrep/releases/download/14.0.3/ripgrep-14.0.3-aarch64-apple-darwin.tar.gz
```

Omit the `platform:` prefix and mise auto-detects the platform from the URL filename:

```bash
# Auto-detect platform from URL (detects as 'macos-arm64')
mise generate tool-stub ./bin/node \
  --platform-url https://nodejs.org/dist/v22.17.1/node-v22.17.1-darwin-arm64.tar.gz
```

**`mise generate tool-stub <OUTPUT>` flags** ([cli/generate/tool-stub](https://mise.jdx.dev/cli/generate/tool-stub.html)):

| Flag | Default | Meaning |
| --- | --- | --- |
| `-u, --url <URL>` | — | Single download URL |
| `--version <VERSION>` | `latest` | Tool version |
| `-b, --bin <BIN>` | auto-detected | Binary path inside the archive |
| `--platform-url… <PLATFORM:URL \| URL>` | — | Per-platform URL; repeatable; platform auto-detected if omitted |
| `--platform-bin… <PLATFORM:PATH>` | — | Per-platform binary path, e.g. `windows-x64:tool.exe` |
| `--http <HTTP>` | `http` | HTTP backend type to use |
| `--skip-download` | off | Skip downloading (fast, but no checksums or binary detection) |
| `--fetch` | off | Read an existing stub and fill in **missing** checksum/size fields by downloading; URLs must already be present |
| `--lock` | off | Resolve and embed lockfile data (pinned version + platform URLs/checksums) into an existing stub |
| `--bootstrap` | off | Wrap the stub in a bash script that checks for mise, installs it via the embedded installer if absent, then executes the stub |
| `--bootstrap-version <VER>` | latest | Pin the mise version used by the bootstrap script, e.g. `2025.1.0` |

Supported archive formats for auto-extraction: `.tar.gz`/`.tgz`, `.tar.xz`/`.txz`, `.tar.bz2`/`.tbz2`, `.tar.zst`/`.tzst`, `.zip`, `.7z` ([dev-tools/tool-stubs#supported-archive-formats](https://mise.jdx.dev/dev-tools/tool-stubs.html#supported-archive-formats)).

#### 3.6.4 Locked stubs

```bash
# Create a stub with a fuzzy version
mise generate tool-stub ./bin/node --version 20

# Lock it to pin the exact version and add platform URLs/checksums
mise generate tool-stub ./bin/node --lock

# Bump to the latest node 22.x and re-lock
mise generate tool-stub ./bin/node --lock --version 22
```

`--lock` resolves the version and fetches URLs for **linux-x64, linux-arm64, macos-x64, macos-arm64, windows-x64**, writing a `[lock]` section ([dev-tools/tool-stubs#locking-a-stub](https://mise.jdx.dev/dev-tools/tool-stubs.html#locking-a-stub)):

```bash
#!/usr/bin/env -S mise tool-stub

tool = "node"
version = "20.18.1"
bin = "node"

[lock.platforms.linux-x64]
url = "https://nodejs.org/dist/v20.18.1/node-v20.18.1-linux-x64.tar.xz"
checksum = "sha256:abc123..."

[lock.platforms.macos-arm64]
url = "https://nodejs.org/dist/v20.18.1/node-v20.18.1-darwin-arm64.tar.gz"
checksum = "sha256:def456..."
```

The `tool`/`version` fields still drive backend resolution; `[lock]` supplies download shortcuts. This is especially useful for **avoiding GitHub API rate limits** when users have no `GITHUB_TOKEN` — locked stubs install with zero runtime API calls.

#### 3.6.5 Running, caching, pruning

```bash
chmod +x ./bin/my-tool
./bin/my-tool --version           # direct execution
mise tool-stub ./bin/my-tool --version   # via mise, useful for debugging
```

`mise tool-stub <FILE> [ARGS]…` forwards everything after the stub path to the tool; use `--` to separate mise args from tool args if needed ([cli/tool-stub](https://mise.jdx.dev/cli/tool-stub.html)).

Caching: binary paths are cached by stub path + mtime, invalidated when the stub changes, and cleaned up when the binary goes missing. **Cached stubs have ~4 ms of overhead** ([dev-tools/tool-stubs#caching](https://mise.jdx.dev/dev-tools/tool-stubs.html#caching)).

Pruning: executing a stub records it in `~/.local/state/mise/tracked-stubs`, and `mise prune` treats tool versions referenced by a tracked stub as needed. **A stub must have been executed at least once on that machine to protect its tool**; deleting the stub file makes its versions prunable again ([dev-tools/tool-stubs#pruning](https://mise.jdx.dev/dev-tools/tool-stubs.html#pruning)).

#### 3.6.6 Poor-man's stubs

For trivial cases, skip the TOML entirely ([dev-tools/tool-stubs#alternative-creating-simple-stubs-with-mise-x](https://mise.jdx.dev/dev-tools/tool-stubs.html#alternative-creating-simple-stubs-with-mise-x)):

```bash
mkdir -p ./bin
cat > ./bin/node << 'EOF'
#!/usr/bin/env bash
exec mise x node@20 -- "$@"
EOF
chmod +x ./bin/node
```

---

### 3.7 OCI distribution — `mise oci` **(experimental)**

> **Experimental:** requires `mise settings experimental=true` or `MISE_EXPERIMENTAL=1`. Flags, output layout, and defaults may change ([dev-tools/mise-oci](https://mise.jdx.dev/dev-tools/mise-oci.html)).

`mise oci build` turns a `mise.toml` into a container image with **one OCI layer per installed tool**. Because every tool lives in an isolated `$MISE_DATA_DIR/installs/<plugin>/<version>/` directory, layer ordering is semantically irrelevant — bumping one tool version swaps exactly one content-addressable blob, unlike a Dockerfile where changing an early `RUN` invalidates everything above it.

| Command | What it does |
| --- | --- |
| `mise oci build` | Produce an OCI image layout on disk |
| `mise oci run` | Build (or reuse) an image and run a command inside it via podman/docker |
| `mise oci push` | Build (or reuse) an image and push it to a registry |

```sh
# Build from the current mise.toml using the default base (debian:bookworm-slim).
# Output goes to ./mise-oci/.
mise oci build

# Run an interactive shell in the image (podman if present, else docker).
mise oci run -it -- bash

# Push with the built-in client (no skopeo/crane needed).
mise oci push ghcr.io/me/devenv:latest

# Standard OCI image layout, so external tools work too:
skopeo inspect oci:./mise-oci
```

#### 3.7.1 Layer composition

Given `node = "20"`, `python = "3.12"`, `jq = "1.8.1"`, `mise oci build` emits ([dev-tools/mise-oci#how-layering-works](https://mise.jdx.dev/dev-tools/mise-oci.html#how-layering-works)):

1. Base image layers (e.g. `debian:bookworm-slim`), copied through unchanged so registry dedup applies.
2. The mise binary at `/usr/local/bin/mise` (skip with `--no-mise`).
3. One layer per tool rooted at `/mise/installs/<plugin>/<version>/`, annotated `dev.mise.tool.short` and `dev.mise.tool.version`.
4. Configured apt `[bootstrap.packages]`, as one package layer.
5. Configured `[dotfiles]`, baked as image files.
6. A synthesized `/etc/mise/config.toml` pointing at `/mise` as the data directory.

#### 3.7.2 `mise oci build`

```sh
mise oci build [-o PATH] [--from REF] [--tag REF] [--mount-point PATH]
               [--copy HOST_PATH:IMAGE_PATH]...
               [--no-mise] [--owner UID[:GID]]
```

| Flag | Default | Meaning |
| --- | --- | --- |
| `-o, --output <PATH>` | `./mise-oci` | Output directory for the OCI image layout |
| `--from <REF>` | `debian:bookworm-slim` | Base image; overrides `[oci].from` and `oci.default_from`. `scratch` builds without a base |
| `-t, --tag <REF>` | — | Written to `index.json` as the `org.opencontainers.image.ref.name` annotation |
| `--mount-point <PATH>` | `/mise` | Where tool installs live in the image. Must be absolute |
| `--copy… <HOST:IMAGE>` | — | Copy a host file/dir/symlink to an absolute image path; repeatable; each becomes an independent content-addressed layer after the tool layers |
| `--include-global` | off | Also package tools from global/system config (default is **project-only**) |
| `--no-mise` | off | Don't embed the running mise binary |
| `--owner <UID[:GID]>` | `[oci].user_id`/`group_id`, then `0:0` | Numeric owner for every tar entry. GID defaults to UID. **File ownership only — not the image `USER` directive** |

([cli/oci/build](https://mise.jdx.dev/cli/oci/build.html), [dev-tools/mise-oci#mise-oci-build](https://mise.jdx.dev/dev-tools/mise-oci.html#mise-oci-build))

#### 3.7.3 `mise oci run`

```sh
mise oci run [--engine ENGINE] [--image-dir DIR]
             [--from REF] [--mount-point PATH] [--no-mise]
             [--owner UID[:GID]]
             [-i] [-t] [-e KEY=VAL]... [--volume HOST:CONTAINER]...
             [-w DIR] [--keep]
             -- <cmd> [args...]
```

| Flag | Meaning |
| --- | --- |
| `--engine <auto\|podman\|docker>` | Default `auto` (prefers podman, which loads OCI layouts natively; docker receives the image via `docker load`) |
| `--image-dir <DIR>` | Skip the build, use an existing layout |
| `-i, --interactive` / `-t, --tty` | Passed through to the engine |
| `-e, --env… <KEY=VAL>` | Set env vars in the container |
| `--volume… <HOST:CONTAINER[:MODE]>` | Bind-mount. **There is no `-v` short flag** — mise reserves `-v` for `--verbose`; use `--volume` or `--mount` |
| `-w, --workdir <DIR>` | Working directory inside the container |
| `--keep` | Keep the loaded image after the run. By default both the container (`--rm`) and the loaded image are removed |
| `--owner <UID[:GID]>` | Cannot be combined with `--image-dir` |

```sh
mise oci run -it -- bash
mise oci run -e DEBUG=1 --volume "$PWD:/work" -w /work -- npm test
mise oci build -o ./img
mise oci run --image-dir ./img -- node --version
```

([cli/oci/run](https://mise.jdx.dev/cli/oci/run.html))

#### 3.7.4 `mise oci push`

Pushes with mise's own registry client — **no skopeo, crane, or docker daemon required**. Only blobs the registry lacks are uploaded; base-image blobs on the destination registry are **cross-repository mounted** (zero bytes transferred). Large layers upload in chunks with progress bars, and transient failures retry with backoff (`http_retries` controls attempts) ([dev-tools/mise-oci#mise-oci-push](https://mise.jdx.dev/dev-tools/mise-oci.html#mise-oci-push)).

**Layer reuse:** tool layers whose cache key (tool, version, in-image prefix, file owner) matches the previously pushed image are reused from the registry instead of rebuilt — those tools **don't even need to be installed locally**, which makes CI pushes fast.

| Flag | Meaning |
| --- | --- |
| `<REF>` (positional) | Fully-qualified destination, e.g. `ghcr.io/me/devenv:latest`. Must include a registry host |
| `--cache-from <REF>` | Reuse layers from another tag in the **same repository** — for per-commit tags |
| `--no-cache` | Disable reuse; rebuild every layer from local installs |
| `--image-dir <DIR>` | Push an already-built layout |
| `--from`, `--mount-point`, `--no-mise` | Build options; ignored with `--image-dir` |
| `--include-global` | Include global/system config tools |
| `--owner <UID[:GID]>` | Conflicts with `--image-dir` |
| `--update-index` | Maintain the tag as a **multi-arch OCI image index**: push this build's manifest by digest and point the tag at an index preserving other platforms' entries |

```sh
mise oci push --cache-from ghcr.io/me/dev:latest ghcr.io/me/dev:$GIT_SHA
```

> **Caveat:** environment derivation (`JAVA_HOME`-style `exec_env` vars) runs against **local** installs. For a reused tool that isn't installed locally most backends still derive paths correctly, but exotic backends may contribute incomplete env — pass `--no-cache` (with the tool installed) if the image config looks wrong ([dev-tools/mise-oci#layer-reuse](https://mise.jdx.dev/dev-tools/mise-oci.html#layer-reuse)).

**Insecure registries.** Loopback registries (`localhost:5000/…`) are contacted over plain HTTP (docker's convention). Non-loopback plain-HTTP registries must be opted in:

```toml
[settings.oci]
insecure_registries = ["registry.lan:5000"]
```

**Auth** resolves exactly like docker/podman, in order ([dev-tools/mise-oci#push-authentication](https://mise.jdx.dev/dev-tools/mise-oci.html#push-authentication)):

1. `$REGISTRY_AUTH_FILE`
2. `$XDG_RUNTIME_DIR/containers/auth.json` (podman)
3. `~/.config/containers/auth.json`
4. `~/.docker/config.json` (or `$DOCKER_CONFIG/config.json`)

Inline `auths` entries and credential helpers (`credsStore`/`credHelpers`, e.g. `docker-credential-osxkeychain`, `docker-credential-ecr-login`) are supported, so `docker login ghcr.io` is enough. With no credentials, mise pushes anonymously and warns. **ghcr.io requires the `write:packages` scope.**

**Multi-arch** via one runner per architecture ([dev-tools/mise-oci#multi-arch-images](https://mise.jdx.dev/dev-tools/mise-oci.html#multi-arch-images)):

```yaml
# CI sketch: one job per arch, same tag
jobs:
  push-amd64: # runs-on: ubuntu-24.04
    run: mise oci push --update-index ghcr.io/me/dev:latest
  push-arm64: # runs-on: ubuntu-24.04-arm
    needs: push-amd64 # sequence to avoid a read-modify-write race
    run: mise oci push --update-index ghcr.io/me/dev:latest
```

The index update is read-modify-write (the Distribution API has no conditional writes), so concurrent pushes to the same tag can race — sequence them.

#### 3.7.5 The `[oci]` section

```toml
[oci]
from        = "debian:bookworm-slim"  # base image ref
tag         = "ghcr.io/me/devenv:v1"  # default tag for the built image
workdir     = "/workspace"             # WORKDIR
entrypoint  = ["bash", "-l"]           # ENTRYPOINT
cmd         = []                        # CMD
user        = "nonroot"                # USER
user_id     = 1000                      # tar layer entry UID (file ownership)
group_id    = 1000                      # tar layer entry GID (defaults to user_id)
mount_point = "/mise"                  # where tools install in the image

[[oci.copy]]
host  = "dist/my-app"
image = "/usr/local/bin/my-app"

[[oci.copy]]
host  = "assets"
image = "/srv/app/assets"

# Extra env baked into the image config (image-only — won't shadow MISE_*).
[oci.env]
NODE_ENV = "production"

# Labels baked into the image config.
[oci.labels]
"org.opencontainers.image.source" = "https://github.com/me/my-app"
```

Precedence: **CLI flags > `[oci]` section > `oci.default_from` / `oci.default_mount_point` settings**. Layered `mise.toml` files merge field-by-field, more specific winning per field ([dev-tools/mise-oci#oci-section-in-mise-toml](https://mise.jdx.dev/dev-tools/mise-oci.html#oci-section-in-mise-toml)).

Copy semantics: sources may be files, directories, or symlinks. Directory **contents** land at `image` (the source directory name is not added). Image paths must be absolute and may not contain `.`/`..`. Parent dirs are created, executable bits preserved, ownership follows `--owner`/`[oci].user_id`/`group_id`. Copy layers are annotated `dev.mise.copy=<image path>`. Relative `host` paths in `[[oci.copy]]` resolve from the config file's directory; relative CLI paths resolve from cwd. When layered configs copy to the same image path, less-specific entries are emitted first (most-specific wins); CLI copies are emitted last.

| Setting | Default | Description |
| --- | --- | --- |
| `oci.default_from` | `debian:bookworm-slim` | Default base image when none is specified |
| `oci.default_mount_point` | `/mise` | Where tools install inside the image |

The default base is **glibc-based on purpose** — Alpine/musl breaks most mise-installed prebuilt binaries (Node, Python wheels, Ruby gems). Opt into `--from alpine:…` only if you know your tools are statically linked.

#### 3.7.6 Image env var order

Later entries win ([dev-tools/mise-oci#environment-variables-in-the-image](https://mise.jdx.dev/dev-tools/mise-oci.html#environment-variables-in-the-image)):

1. Base image env (from the pulled `--from` image's config)
2. Your `[env]` section from `mise.toml`, fully resolved (templates expanded, `.env` files read)
3. Each tool's `exec_env()` — `JAVA_HOME`, `GOROOT`, `GEM_HOME`, with paths rebased onto the in-image path
4. `[oci].env` entries
5. Synthesized `PATH` (each tool's bin paths in the image) plus the inherited `PATH`
6. `MISE_DATA_DIR=/mise` and `MISE_CONFIG_DIR=/etc/mise` — **always last, so they can't be shadowed**

> **Security gotcha:** everything in `[env]` — including values loaded from `.env` files — is written into the image config JSON and visible via `docker inspect` / `skopeo inspect`. **Do not put secrets there.** Use `docker run -e`, secret mounts, or orchestrator secrets. mise warns with a count of baked-in `[env]` vars. Use `[oci].env` only for values safe to live in the image.

#### 3.7.7 `[bootstrap]` / `[dotfiles]` in images, and limits

`mise oci build` applies project-scoped `[bootstrap.packages]` and `[dotfiles]`; `--include-global` also pulls global ones ([dev-tools/mise-oci#bootstrap-and-dotfiles-in-oci-images](https://mise.jdx.dev/dev-tools/mise-oci.html#bootstrap-and-dotfiles-in-oci-images)):

```toml
[bootstrap.packages]
"apt:curl" = "latest"

[dotfiles]
"/etc/profile.d/project.sh" = { source = "profile.sh", mode = "copy" }
"~/.config/app/config.toml" = { source = "config.toml", mode = "template" }
```

Only `apt:` packages with a Debian/Ubuntu base are supported: mise unpacks the base into a temp rootfs, calls the host `apt-get`, then emits the diff as one layer annotated `dev.mise.system.packages=apt`. Other package managers are rejected. `symlink`/`symlink-each` dotfile entries are copied as **file content** (host symlinks would dangle inside the container); `~/`-prefixed targets are written under `/root/`. `[bootstrap.macos.defaults]` and the imperative `bootstrap` task are **not** run.

**Supported backends** (all install entirely under their per-version directory): `core`, `aqua`, `cargo`, `npm`, `go`, `pipx`, `github`, `gitlab`, `forgejo`, `ubi`, `spm`, `http`, `s3`, `gem`, `conda`, `dotnet`. **Not supported in v1:** `asdf` and `vfox` plugins (including third-party vfox plugins) — their install scripts can write outside the per-version directory, breaking the one-layer-per-tool invariant. Using them errors out ([dev-tools/mise-oci#supported-backends](https://mise.jdx.dev/dev-tools/mise-oci.html#supported-backends)).

**Known v1 limitations** ([dev-tools/mise-oci#known-limitations-v1](https://mise.jdx.dev/dev-tools/mise-oci.html#known-limitations-v1)):

- asdf/vfox rejected.
- **Cross-platform builds produce broken images.** OCI images are linux-targeted; building on macOS/Windows yields `os: linux` but host-native binaries that fail with `Exec format error`. Build on a linux host (or `docker run -v $PWD:/src -w /src debian mise oci build`). mise warns on mismatch.
- Alpine/musl bases break most tools.
- `mise oci run` needs podman or docker; **pushing needs no external tools**.

**Reproducibility:** on the same host, re-running with unchanged inputs produces byte-identical tool layer digests. Across machines digests may drift because compiled artifacts (pyc bytecode, node-gyp output) can embed absolute paths. For reproducible image config timestamps: `SOURCE_DATE_EPOCH=$(git log -1 --format=%ct) mise oci build`.

Base images may come from any OCI Distribution v2 registry; anonymous token auth is automatic for public images, and `docker login`/`podman login` credentials cover private ones. Digest references work: `mise oci build --from ubuntu@sha256:e3b0c44298fc...`.

---

### 3.8 Tool aliases

> **Naming:** `[alias]` has been **renamed to `[tool_alias]`** to distinguish it from `[shell_alias]`. The old `[alias]` key still works but is **deprecated** ([dev-tools/aliases](https://mise.jdx.dev/dev-tools/aliases.html)).

#### 3.8.1 Aliased backends

Remap a short name to a different backend:

```toml
# ~/.config/mise/config.toml
[tool_alias]
node = 'github:company/our-custom-node'   # shorthand for https://github.com/company/our-custom-node
erlang = 'aqua:company/our-custom-erlang' # use an aqua registry entry
```

Useful for pulling two binaries out of one GitHub repo, combined with the github backend's `matching` option:

```toml
# ~/.config/mise/config.toml
[tool_alias]
dhall-json = 'github:dhall-lang/dhall-haskell'
dhall-lsp = 'github:dhall-lang/dhall-haskell'

[tools]
dhall-json = { version = "v1.42.2", matching = "dhall-json" }
dhall-lsp = { version = "latest", matching = "dhall-lsp-server" }
```

([dev-tools/aliases#aliased-backends](https://mise.jdx.dev/dev-tools/aliases.html#aliased-backends))

#### 3.8.2 Aliased versions

```toml
[tool_alias.node.versions]
lts-iron = '20'
```

```toml
[tools]
node = "lts-iron"
```

Adding a version alias also creates a symlink, e.g. `~/.local/share/mise/installs/node/20 -> ./20.x.x` ([configuration](https://mise.jdx.dev/configuration.html)).

Plugins can supply aliases via a `bin/list-aliases` script ([dev-tools/aliases#aliased-versions](https://mise.jdx.dev/dev-tools/aliases.html#aliased-versions)):

```bash
#!/usr/bin/env bash

echo "lts-krypton 24"
echo "lts-jod 22"
echo "lts-iron 20"
```

mise's built-in node plugin already ships these LTS aliases.

Alias values may be **templates** ([dev-tools/aliases#templates](https://mise.jdx.dev/dev-tools/aliases.html#templates)):

```toml
[tool_alias.node.versions]
current = "{{exec(command='node --version')}}"
```

#### 3.8.3 `mise tool-alias` CLI

| Command | Aliases | Notes |
| --- | --- | --- |
| `mise tool-alias ls [--no-header] [TOOL]` | `list` | Lists aliases from user config **and** plugin `bin/list-aliases` ([cli/tool-alias/ls](https://mise.jdx.dev/cli/tool-alias/ls.html)) |
| `mise tool-alias get <TOOL> <ALIAS>` | — | Prints the `tool_alias.<TOOL>` entry ([cli/tool-alias/get](https://mise.jdx.dev/cli/tool-alias/get.html)) |
| `mise tool-alias set <TOOL> <ALIAS> [VALUE]` | `add`, `create` | **Modifies `~/.config/mise/config.toml`** ([cli/tool-alias/set](https://mise.jdx.dev/cli/tool-alias/set.html)) |
| `mise tool-alias unset <TOOL> [ALIAS]` | `rm`, `remove`, `delete`, `del` | Modifies `~/.config/mise/config.toml` ([cli/tool-alias/unset](https://mise.jdx.dev/cli/tool-alias/unset.html)) |

Parent-command flags: `-p/--tool <TOOL>` (filter by tool), `--no-header` ([cli/tool-alias](https://mise.jdx.dev/cli/tool-alias.html)).

```bash
mise tool-alias set maven asdf:mise-plugins/mise-maven   # backend alias (2 args)
mise tool-alias set node lts-jod 22.0.0                  # version alias (3 args)
mise tool-alias unset maven
mise tool-alias unset node lts-jod

$ mise tool-alias get node lts-hydrogen
20.0.0
$ mise tool-alias ls
node  lts-jod      22
```

---

### 3.9 Project dependencies — `mise deps` **(experimental)**

Distinct from the `depends` **tool option** (§3.2.6): `mise deps` manages *project* dependencies by hashing source files (`package-lock.json`, …) and running install commands when they change ([dev-tools/deps](https://mise.jdx.dev/dev-tools/deps.html)).

```bash
export MISE_EXPERIMENTAL=1

mise deps                    # install all project dependencies
mise deps add npm:react
mise deps add -D npm:vitest  # dev dependency
mise deps remove npm:lodash
```

#### 3.9.1 Built-in providers

Built-in providers are **only active when explicitly configured in `mise.toml` AND their lockfile exists**.

| Provider | Sources | Outputs | Command |
| --- | --- | --- | --- |
| npm | package.json, package-lock.json | node_modules/ | `npm install` |
| yarn | package.json, yarn.lock | node_modules/ | `yarn install` |
| pnpm | package.json, pnpm-lock.yaml | node_modules/ | `pnpm install` |
| bun | package.json, bun.lock, bun.lockb | node_modules/ | `bun install` |
| deno | deno.json, deno.jsonc, package.json, deno.lock | node_modules/ | `deno install` |
| aube | package.json, aube-lock.yaml | node_modules/ | `aube install` |
| go | go.mod | vendor/ or go.sum | `go mod vendor` or `go mod download` |
| pip | requirements.txt | .venv/ | `pip install -r requirements.txt` |
| poetry | pyproject.toml, poetry.lock | .venv/ | `poetry install` |
| uv | pyproject.toml, uv.lock | .venv/ | `uv sync` |
| bundler | Gemfile, Gemfile.lock | vendor/bundle/ | `bundle install` |
| composer | composer.json, composer.lock | vendor/ | `composer install` |
| dart | pubspec.yaml, pubspec.lock | .dart_tool/ | `dart pub get` |
| flutter | pubspec.yaml, pubspec.lock | .dart_tool/ | `flutter pub get` |

([dev-tools/deps#built-in-providers](https://mise.jdx.dev/dev-tools/deps.html#built-in-providers))

```toml
[deps.npm]
auto = true  # Auto-run before mise x/run

[deps.uv]
[deps.bundler]

[deps]
disable = ["npm"]
```

#### 3.9.2 Custom providers

```toml
[deps.codegen]
sources = ["schema/*.graphql", "codegen.yml"]
outputs = ["src/generated/"]
run = "npm run codegen"
description = "Generate GraphQL types"

[deps.prisma]
sources = ["prisma/schema.prisma"]
outputs = ["node_modules/.prisma/"]
run = "npx prisma generate"
```

| Option | Type | Description |
| --- | --- | --- |
| `auto` | bool | Auto-run before `mise x` and `mise run` (default `false`) |
| `sources` | string[] | Files/patterns to check for changes |
| `outputs` | string[] | Files/dirs that must exist for the provider to count as fresh |
| `run` | string | Command to run when stale |
| `env` | table | Environment variables to set |
| `dir` | string | Base directory for sources, outputs, and the command |
| `description` | string | Description shown in output |
| `depends` | string[] | Other providers that must complete first |
| `timeout` | string | Timeout for the run command, e.g. `"30s"`, `"5m"` (default: no timeout) |

([dev-tools/deps#provider-options](https://mise.jdx.dev/dev-tools/deps.html#provider-options))

#### 3.9.3 Freshness, auto-install, parallelism

mise uses **blake3** content hashing; hashes live in `$MISE_STATE_DIR/deps/<hash>.toml` keyed by project root, so nothing is written inside the project directory ([dev-tools/deps#freshness-checking](https://mise.jdx.dev/dev-tools/deps.html#freshness-checking)).

- Modify `package-lock.json` → `node_modules/` is stale.
- `node_modules/` missing → always stale.
- Sources don't exist → **fresh** (nothing to do).
- First run with no stored state → always stale.

`auto = true` runs the provider before `mise run` and `mise x`. Skip per-invocation with `mise run --no-deps build` / `mise x --no-deps -- npm test`. Under `mise activate`, mise warns `mise WARN deps: npm may need update, run 'mise deps'`; silence with `[settings] status.show_deps_stale = false` ([dev-tools/deps#staleness-warnings](https://mise.jdx.dev/dev-tools/deps.html#staleness-warnings)).

Providers run in parallel bounded by the `jobs` setting. `depends` serializes; failures skip dependents; circular dependencies are detected and the affected providers are skipped with a warning ([dev-tools/deps#dependencies](https://mise.jdx.dev/dev-tools/deps.html#dependencies)).

```toml
[deps.uv]
auto = true

[deps.ansible-galaxy]
auto = true
depends = ["uv"]
run = "ansible-galaxy install -r requirements.yml && touch .galaxy-installed"
sources = ["requirements.yml"]
outputs = [".galaxy-installed"]
```

#### 3.9.4 Monorepos

By default `mise deps` only runs providers from the current config root. `--monorepo` runs providers from every explicitly configured root — this **requires explicit `[monorepo].config_roots`**; mise never searches arbitrary subdirectories for providers ([dev-tools/deps#monorepos](https://mise.jdx.dev/dev-tools/deps.html#monorepos)).

```toml
monorepo_root = true

[monorepo]
config_roots = ["apps/*", "packages/*"]
```

```bash
mise deps --monorepo
mise deps --monorepo --only //apps/api:uv
mise deps install //apps/worker:uv --monorepo
```

Monorepo provider IDs are qualified with their config root (`//apps/api:uv`). Provider `depends` entries without a `//` prefix resolve within the same config root. For a single nested project, `dir` is simpler: `[deps.uv] dir = "apps/api"`.

#### 3.9.5 `mise deps` CLI

`mise deps [FLAGS] [PROVIDER] <SUBCOMMAND>` (alias `dep`) ([cli/deps](https://mise.jdx.dev/cli/deps.html)):

| Flag | Meaning |
| --- | --- |
| `--explain` | Show why a provider is fresh or stale (**requires a provider argument**) |
| `-f, --force` | Run all steps even if outputs are fresh |
| `-n, --dry-run` | Only check whether install is needed |
| `--list` | List available providers |
| `--monorepo` | Run across `[monorepo].config_roots` |
| `--only… <ONLY>` | Run specific rules only |
| `--skip… <SKIP>` | Skip specific rules |

Subcommands: `mise deps install [FLAGS] [PROVIDER]` (same flags as above; bare `mise deps` is equivalent), `mise deps add [-D --dev] <PACKAGES>…`, `mise deps remove <PACKAGES>…` ([cli/deps/install](https://mise.jdx.dev/cli/deps/install.html), [cli/deps/add](https://mise.jdx.dev/cli/deps/add.html), [cli/deps/remove](https://mise.jdx.dev/cli/deps/remove.html)).

Add/remove use `ecosystem:package` specs. **Currently supported for add/remove:** `npm`, `yarn`, `pnpm`, `bun`, `deno`, `aube`, `dart`, `flutter` ([dev-tools/deps#adding-and-removing-packages](https://mise.jdx.dev/dev-tools/deps.html#adding-and-removing-packages)).

```bash
mise deps add npm:react
mise deps add npm:@types/react@19
mise deps add -D npm:vitest
mise deps remove npm:lodash
```

---

### 3.10 Core tools

Core tools are plugins compiled into the mise CLI in Rust. They can be overridden by installing an asdf/vfox plugin with the same name, e.g. `mise plugin install python https://github.com/asdf-community/asdf-python`. List them with `mise registry -b core` ([core-tools](https://mise.jdx.dev/core-tools.html)).

| Core tool | Docs |
| --- | --- |
| Bun | [lang/bun](https://mise.jdx.dev/lang/bun.html) |
| Deno | [lang/deno](https://mise.jdx.dev/lang/deno.html) |
| Elixir | [lang/elixir](https://mise.jdx.dev/lang/elixir.html) |
| Erlang | [lang/erlang](https://mise.jdx.dev/lang/erlang.html) |
| Go | [lang/go](https://mise.jdx.dev/lang/go.html) |
| Java | [lang/java](https://mise.jdx.dev/lang/java.html) |
| NodeJS | [lang/node](https://mise.jdx.dev/lang/node.html) |
| Python | [lang/python](https://mise.jdx.dev/lang/python.html) |
| Ruby | [lang/ruby](https://mise.jdx.dev/lang/ruby.html) |
| Rust | [lang/rust](https://mise.jdx.dev/lang/rust.html) |
| Swift | [lang/swift](https://mise.jdx.dev/lang/swift.html) |
| Zig | [lang/zig](https://mise.jdx.dev/lang/zig.html) |

([core-tools](https://mise.jdx.dev/core-tools.html))

New core-tool contributions "are likely to be rejected unless they're for very popular tools like Node.js, Python, or Go" — core tools require much more maintenance than registry-backed ones ([backend_architecture#core-tools](https://mise.jdx.dev/dev-tools/backend_architecture.html#core-tools)).

---

### 3.11 Backend selection (summary)

Backend resolution priority ([backend_architecture#how-backend-selection-works](https://mise.jdx.dev/dev-tools/backend_architecture.html#how-backend-selection-works)):

1. **Explicit backend** — `mise use aqua:golangci/golangci-lint`
2. **Env-var override** — `MISE_BACKENDS_<TOOL>` (tool name in SHOUTY_SNAKE_CASE, hyphens → underscores)
3. **Registry lookup** — `mise use golangci-lint` consults the registry's preferred order
4. **Core tools** — `mise use node`
5. **Fallback** — suggests available backends

```bash
# Use vfox backend for php
export MISE_BACKENDS_PHP='vfox:mise-plugins/vfox-php'
mise install php@latest
```

```toml
# ~/.config/mise/config.toml
[settings]
disable_backends = ["asdf", "vfox"] # Don't use these backends
```

```toml
# mise.toml
[tools]
"core:node" = "20"     # Explicitly use core backend
"aqua:yarn" = "latest" # Use aqua backend instead of default (vfox)
```

```toml
# mise.toml
[tools]
python = { version = "3.12", virtualenv = ".venv" }  # Core backend options
black = { version = "latest", python = "3.12" }      # pipx backend options
```

> **Deprecation:** the `ubi` backend is deprecated in favor of `github`. Replace `ubi:owner/repo` with `github:owner/repo` ([backend_architecture#ubi-universal-binary-installer-deprecated](https://mise.jdx.dev/dev-tools/backend_architecture.html#ubi-universal-binary-installer-deprecated)).

Debugging backend selection ([backend_architecture#debug-backend-selection](https://mise.jdx.dev/dev-tools/backend_architecture.html#debug-backend-selection)):

```bash
mise doctor                   # Check backend configuration
mise tool python              # See which backend is used for a tool
mise config get tools         # Verify tool configurations
```

---

### 3.12 GitHub tokens and rate limits

For public releases mise uses [mise-versions](https://mise-versions.jdx.dev) by default as a shared cache for version lists, release metadata, and GitHub artifact attestations — which avoids most unauthenticated GitHub API calls during normal installs, CI, and Docker builds. Tokens matter when mise falls back to GitHub's API, when `MISE_USE_VERSIONS_HOST=0`, or for private repos / GitHub Enterprise / custom API hosts. Unauthenticated requests hit low rate limits and surface as `403 Forbidden` ([dev-tools/github-tokens](https://mise.jdx.dev/dev-tools/github-tokens.html)).

#### 3.12.1 Token priority

**github.com** ([dev-tools/github-tokens#token-priority](https://mise.jdx.dev/dev-tools/github-tokens.html#token-priority)):

| # | Source |
| --- | --- |
| 1 | `MISE_GITHUB_TOKEN` env var |
| 2 | `GITHUB_API_TOKEN` env var |
| 3 | `GITHUB_TOKEN` env var |
| 4 | `credential_command` (if set) |
| 5 | native GitHub OAuth (if configured) |
| 6 | `github_tokens.toml` (per-host) |
| 7 | gh CLI token (from `hosts.yml`) |
| 8 | `git credential fill` (if enabled) |

**GitHub Enterprise hosts:**

| # | Source |
| --- | --- |
| 1 | `MISE_GITHUB_ENTERPRISE_TOKEN` env var |
| 2 | `MISE_GITHUB_TOKEN` / `GITHUB_API_TOKEN` / `GITHUB_TOKEN` env vars |
| 3 | `credential_command` (if set) |
| 4 | native GitHub OAuth (if configured) |
| 5 | `github_tokens.toml` (per-host) |
| 6 | gh CLI token (matched by hostname) |
| 7 | `git credential fill` (if enabled) |

#### 3.12.2 Configuration options

**Env var** — a PAT with **no scopes required** works ([dev-tools/github-tokens#setting-a-token-via-environment-variable](https://mise.jdx.dev/dev-tools/github-tokens.html#setting-a-token-via-environment-variable)):

```sh
export MISE_GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
```

**Token file** — auto-discovered at `$MISE_CONFIG_DIR/github_tokens.toml` (defaults `~/.config/mise`); no settings required. Checked after env vars and `credential_command`, before gh's `hosts.yml` ([dev-tools/github-tokens#token-file-github-tokens-toml](https://mise.jdx.dev/dev-tools/github-tokens.html#token-file-github-tokens-toml)):

```toml
# ~/.config/mise/github_tokens.toml
[tokens."github.com"]
token = "ghp_xxxxxxxxxxxx"

[tokens."github.mycompany.com"]
token = "ghp_yyyyyyyyyyyy"
```

**gh CLI** — enabled by default; mise reads `hosts.yml` **directly** (it does not shell out to `gh`), searching in order: `$GH_CONFIG_DIR/hosts.yml`, `$XDG_CONFIG_HOME/gh/hosts.yml`, `~/Library/Application Support/gh/hosts.yml` (macOS), `%APPDATA%\GitHub CLI\hosts.yml` (Windows), `~/.config/gh/hosts.yml`. Disable with `[settings.github] gh_cli_tokens = false` ([dev-tools/github-tokens#gh-cli-integration](https://mise.jdx.dev/dev-tools/github-tokens.html#gh-cli-integration)).

> **Gotcha:** if gh stores the token in a keyring (macOS Keychain, Windows Credential Manager) rather than `hosts.yml`, reading the file cannot help. `mise token github` printing `(none)` while `gh auth status` works is the tell.

**Credential command** ([dev-tools/github-tokens#credential-command](https://mise.jdx.dev/dev-tools/github-tokens.html#credential-command)):

```toml
[settings.github]
credential_command = "op read 'op://Private/GitHub Token/credential'"
```

Runs via the configured default inline shell (`unix_default_inline_shell_args` / `windows_default_inline_shell_args`) and reads the token from stdout. `MISE_CREDENTIAL_HOST` carries the hostname and `MISE_CREDENTIAL_PROVIDER` the provider name (`github`). The command runs with **mise shims removed from `PATH`** to avoid recursive mise invocations.

> **Planned deprecation:** the legacy `$1`/`${1}` hostname argument is deprecated. Use `MISE_CREDENTIAL_HOST`. mise **starts warning in 2026.11.0**; `$1` compatibility is **removed in 2027.11.0**.

```toml
# macOS/Linux
[settings.github]
credential_command = 'gh auth token --hostname "$MISE_CREDENTIAL_HOST"'
```

```toml
# Windows — cmd is the default inline shell and does not expand $VAR
[settings.github]
credential_command = 'gh auth token --hostname %MISE_CREDENTIAL_HOST%'
```

If you install `ghtkn` (or similar) *with mise*, store the real path, not the shim, and never make the credential command call `mise x`/`mise exec` (it can loop while mise is trying to obtain the token):

```sh
mise settings set github.credential_command="$(mise which ghtkn) get -m 1h"
```

**Native GitHub OAuth** — mise can mint short-lived GitHub App user access tokens with the device flow; no PAT, App private key, client secret, `gh`, or `ghtkn` needed ([dev-tools/github-tokens#native-github-oauth](https://mise.jdx.dev/dev-tools/github-tokens.html#native-github-oauth)):

```sh
mise settings set github.oauth_client_id=Iv1.yourgithubappclientid
mise token github --oauth       # authorize once
```

While the cached token is valid mise **exports it to your shell as `GITHUB_TOKEN`** (via `mise activate` / `hook-env` / `env` / `exec`), so `gh`, `git`, and `cargo publish` pick it up automatically.

```toml
[settings.github]
oauth_client_id = "Iv1.yourgithubappclientid"
oauth_scopes = "" # usually empty for GitHub App user access tokens
oauth_open_browser = true
oauth_export_env = "GITHUB_TOKEN" # set to "" to disable automatic export
```

```sh
export MISE_GITHUB_TOKEN="$(mise token github --oauth --raw)"
```

**Git credential helpers** — **opt-in**, last-resort fallback. mise runs `git credential fill` with `GIT_TERMINAL_PROMPT=0` and caches per host for the session ([dev-tools/github-tokens#git-credential-helpers](https://mise.jdx.dev/dev-tools/github-tokens.html#git-credential-helpers)):

```toml
[settings.github]
use_git_credentials = true
```

**GitHub Enterprise** — set `api_url` as a tool option, and prefer `github_tokens.toml` / gh CLI / `credential_command` when you have **multiple** GHE instances (a single `MISE_GITHUB_ENTERPRISE_TOKEN` can't cover them) ([dev-tools/github-tokens#github-enterprise](https://mise.jdx.dev/dev-tools/github-tokens.html#github-enterprise)):

```toml
[tools]
"github:myorg/mytool" = { version = "latest", api_url = "https://github.mycompany.com/api/v3" }
```

**Avoiding tokens entirely** — the recommended CI approach ([dev-tools/github-tokens#avoiding-tokens-entirely-with-lockfiles](https://mise.jdx.dev/dev-tools/github-tokens.html#avoiding-tokens-entirely-with-lockfiles)):

```sh
mise settings lockfile=true
mise lock
```

In GitHub Actions, `GITHUB_TOKEN` is picked up with no configuration:

```yaml
- uses: jdx/mise-action@v2
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

mise also supports `.netrc` for HTTP Basic auth; **`.netrc` credentials take precedence over token-based auth headers** ([dev-tools/github-tokens#netrc](https://mise.jdx.dev/dev-tools/github-tokens.html#netrc)).

#### 3.12.3 `mise token`

`mise token <SUBCOMMAND>` displays the git-provider token mise would use ([cli/token](https://mise.jdx.dev/cli/token.html)):

| Subcommand | Default host | Flags |
| --- | --- | --- |
| `mise token github [HOST]` | `github.com` | `--oauth`, `--raw`, `--refresh`, `--unmask` ([cli/token/github](https://mise.jdx.dev/cli/token/github.html)) |
| `mise token gitlab [HOST]` | `gitlab.com` | `--unmask` ([cli/token/gitlab](https://mise.jdx.dev/cli/token/gitlab.html)) |
| `mise token forgejo [HOST]` | `codeberg.org` | `--unmask` ([cli/token/forgejo](https://mise.jdx.dev/cli/token/forgejo.html)) |

- `--oauth` resolves **only** via the native OAuth source (cache, refresh, or device-code flow), bypassing other sources.
- `--refresh` mints a fresh OAuth token even if the cached one hasn't expired — use after changing the GitHub App's installations or permissions, since cached tokens keep their original access until expiry.
- `--raw` prints only the token value.

```
$ mise token github
github.com: ghp_…xxxx (source: GITHUB_TOKEN)

$ mise token github --unmask
github.com: ghp_xxxxxxxxxxxx (source: GITHUB_TOKEN)

$ mise token github github.mycompany.com
github.mycompany.com: (none)

$ mise token github --oauth --refresh
github.com: gho_…xxxx (source: GitHub OAuth)

$ mise token gitlab
gitlab.com: glpa…xxxx (source: GITLAB_TOKEN)

$ mise token forgejo
codeberg.org: a180…61f6 (source: FORGEJO_TOKEN)
```

---

### 3.13 Shims vs PATH activation

Three ways to load the mise context ([dev-tools/shims](https://mise.jdx.dev/dev-tools/shims.html)):

| Method | How | Best for |
| --- | --- | --- |
| PATH activation | `eval "$(mise activate bash)"` — rewrites env vars each prompt | Interactive shells (**recommended**) |
| Shims | `mise activate --shims` — puts wrapper executables on `PATH` | Non-interactive: IDEs, scripts, `.zprofile` |
| Neither | `mise x`, `mise r`, `mise en` | Explicit, no rc-file changes |

Shims live in `~/.local/share/mise/shims` (Windows: `%LOCALAPPDATA%\mise\shims`) and are effectively symlinks to the mise binary:

```sh
ls -l ~/.local/share/mise/shims/node
# [...] ~/.local/share/mise/shims/node -> ~/.local/bin/mise
```

Recommended combined setup — shims in the profile (non-interactive), PATH activation in the rc file (interactive) ([dev-tools/shims#how-to-add-mise-shims-to-path](https://mise.jdx.dev/dev-tools/shims.html#how-to-add-mise-shims-to-path)):

```sh
echo 'eval "$(mise activate bash --shims)"' >> ~/.bash_profile # non-interactive sessions
echo 'eval "$(mise activate bash)"' >> ~/.bashrc               # interactive sessions
```

```sh
echo 'eval "$(mise activate zsh --shims)"' >> ~/.zprofile
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
```

```sh
echo 'mise activate fish --shims | source' >> ~/.config/fish/config.fish
echo 'mise activate fish | source' >> ~/.config/fish/config.fish
```

What happens when both are used depends on [`not_found_auto_install`](https://mise.jdx.dev/configuration/settings.html#not_found_auto_install) ([dev-tools/shims#how-to-add-mise-shims-to-path](https://mise.jdx.dev/dev-tools/shims.html#how-to-add-mise-shims-to-path)):

- **enabled (default):** `mise activate` keeps the shims directory in `PATH`, *behind* the tool paths it manages. Tools from the current toolset win; shims remain as an auto-install fallback. `mise doctor` does not flag this.
- **disabled:** `mise activate` removes the shims directory from `PATH` entirely.

**Feature loss when using shims instead of PATH activation** ([dev-tools/shims#shims-vs-path](https://mise.jdx.dev/dev-tools/shims.html#shims-vs-path)):

| Feature | With shims |
| --- | --- |
| mise `[env]` vars | Only available **to mise tools** (loaded when a shim is called), not to your shell |
| `cd` / `enter` / `leave` hooks, `watch_files` | Do **not** trigger — they require `mise activate` |
| `preinstall` / `postinstall` hooks | Still work (no shell integration needed) |
| unix `which` | Points at the shim; use `mise which` for the real path |

```sh
# Only works under `mise activate`:
$ mise set NODE_ENV=production
$ echo $NODE_ENV
production

# Works with either:
$ node -p process.env.NODE_ENV
production
$ mise x -- bash -c "echo \$NODE_ENV"
production
```

**`mise reshim`** rebuilds the shims directory. mise already reshims on tool install/update/remove and after most tool operations (like `npm i -g`), so it's rarely needed manually — it is *not* a general "fix it" button, only for when `~/.local/share/mise/shims` is missing something. **Do not put extra executables in the mise directory; the next reshim deletes them.** `mise reshim -f/--force` removes all shims first. Note it creates shims for **all installed tools**, not just active ones ([cli/reshim](https://mise.jdx.dev/cli/reshim.html), [dev-tools/shims#mise-reshim](https://mise.jdx.dev/dev-tools/shims.html#mise-reshim)).

```sh
npm() {
  command npm "$@"
  mise reshim
}
```

**Hook-on-`cd`.** In `bash`, `zsh`, `fish`, and `xonsh`, mise hooks the directory change (`PROMPT_COMMAND`, `chpwd`, `fish_prompt`, `on_chdir`); elsewhere it runs only at prompt display. Consequence ([dev-tools/shims#hook-on-cd](https://mise.jdx.dev/dev-tools/shims.html#hook-on-cd)):

```sh
cd ~
cd ~/src/proj1 && node -v && cd ~/src/proj2 && node -v
```

Under `mise activate` in a shell **without** hook-on-cd, both `node -v` calls use the tools from `~`. **Shims always work correctly for this inline case.**

**In rc files** you need one of ([dev-tools/shims#using-mise-in-rc-files](https://mise.jdx.dev/dev-tools/shims.html#using-mise-in-rc-files)):

```sh
eval "$(mise activate zsh)"
eval "$(mise hook-env -s zsh)"
node some_script.js
```

```sh
eval "$(mise activate zsh --shims)" # should be first
eval "$(mise activate zsh)"
node some_script.js
```

**Performance.** Realistically indistinguishable. `mise activate` costs a few ms per prompt (~10 ms on the author's machine; 4 ms with no changes, 14 ms for a full reload); shims cost the same but per shim invocation. A bash loop calling a shim 500 times pays 500 penalties — but a subprocess *spawned from within* a shim pays nothing extra, because the shim already set up `PATH` for all tools ahead of the shim directory ([dev-tools/shims#performance](https://mise.jdx.dev/dev-tools/shims.html#performance)).

---

### 3.14 Comparison to asdf

mise is a drop-in replacement for asdf: it reads the same `.tool-versions` files and can run asdf plugins via the [asdf backend](https://mise.jdx.dev/dev-tools/backends/asdf.html). It will **not** reuse existing asdf directories (reinstall or move them), and 100% compatibility is not a design goal ([comparison-to-asdf](https://mise.jdx.dev/dev-tools/comparison-to-asdf.html)).

| Dimension | asdf (bash, ≤0.15) | mise |
| --- | --- | --- |
| Runtime dispatch | Shims → `asdf exec` → runtime; **~120 ms per call** | `PATH` rewrite; **zero** per-call overhead; `mise hook-env` ~10 ms on directory change |
| Fuzzy versions | `asdf install node latest:20` works, but `latest:20` is invalid in `.tool-versions` | Fuzzy matching accepted **everywhere** |
| Install a new tool | `asdf plugin add node` → `asdf install node latest:20` → `asdf local node latest:20` | `mise use node@20` (one step) |
| Windows | Not supported at all | Supported for non-asdf backends when the vendor ships Windows binaries |
| Plugin security | Arbitrary shell code, usually written by third parties, not vendors | Prefers aqua/github backends with no plugin; native Cosign/SLSA/Minisign/GitHub-attestation verification for aqua tools; gpg verification on node installs |
| Env vars / tasks | No equivalent | [environments](https://mise.jdx.dev/environments/), [tasks](https://mise.jdx.dev/tasks/) |
| Extra backends | asdf plugins only | cargo, npm, pipx, go, gem, aqua, github, http, … |

([comparison-to-asdf](https://mise.jdx.dev/dev-tools/comparison-to-asdf.html))

**asdf-go (0.16+):** the go rewrite closed most of the performance gap. The docs' own verdict: "I don't think performance is a good enough reason to switch though now that asdf-go is a thing… the improved security in mise, better DX, and lack of reliance on shims are all more important." Also, asdf-go **removed `asdf global|local` in favor of `asdf set`**, which mise cannot mirror (it already has `mise set`), so command compatibility will be worse with 0.16+ ([comparison-to-asdf#asdf-in-go-0-16](https://mise.jdx.dev/dev-tools/comparison-to-asdf.html#asdf-in-go-0-16), [#command-compatibility](https://mise.jdx.dev/dev-tools/comparison-to-asdf.html#command-compatibility)).

asdf-style positional syntax mostly works as a best-effort muscle-memory aid, but is **not recommended**:

```sh
mise install node 20.0.0
mise local node 20.0.0
```

The `@` form is preferred because it allows several tools at once: `mise use|install node@20 node@18`.

```sh
mise install                 # install everything from an existing .tool-versions / mise.toml
mise use -g cargo:ripgrep@14
mise use -g npm:prettier@3
```

---

### 3.15 Tool-related settings reference

| Setting | Env var | Default | Meaning |
| --- | --- | --- | --- |
| `auto_install` | `MISE_AUTO_INSTALL` | `true` | Auto-install missing tools for `mise x`, `mise run`, and the not-found handler |
| `auto_install_disable_tools` | `MISE_AUTO_INSTALL_DISABLE_TOOLS` | none | Tools to exclude from auto-install |
| `exec_auto_install` | `MISE_EXEC_AUTO_INSTALL` | `true` | Auto-install when running `mise x` |
| `not_found_auto_install` | `MISE_NOT_FOUND_AUTO_INSTALL` | `true` | "command not found" handler; only installs missing versions of tools with ≥1 version already installed. Also runs in shims when interactive |
| `lockfile` | `MISE_LOCKFILE` | unset (≈`true`) | Read/update `mise.lock`. `false` errors if `locked = true` |
| `locked` | `MISE_LOCKED` | `false` | Require pre-resolved URLs in the lockfile; **requires `lockfile`** |
| `locked_verify_provenance` | `MISE_LOCKED_VERIFY_PROVENANCE` | `false` | Re-verify SLSA/cosign/minisign/attestations on every install; auto-enabled by `paranoid` |
| `minimum_release_age` | `MISE_MINIMUM_RELEASE_AGE` | `24h` | Ignore versions newer than this; relative (`7d`, `6mo`, `1y`) or absolute (`2024-06-01`) |
| `pin` | `MISE_PIN` | `false` | Make `mise use` default to `--pin`; override with `--fuzzy` |
| `prereleases` | `MISE_PRERELEASES` | `false` | Globally include pre-release versions |
| `disable_tools` | `MISE_DISABLE_TOOLS` | `[]` | Tools defined in `mise.toml` that should be ignored |
| `disable_backends` | `MISE_DISABLE_BACKENDS` | `[]` | Backends to disable **for new installs**; does not uninstall or disable already-installed tools |
| `idiomatic_version_file_enable_tools` | `MISE_IDIOMATIC_VERSION_FILE_ENABLE_TOOLS` | `[]` | Enable `.node-version`-style files per tool |
| `jobs` | `MISE_JOBS` | `8` | Concurrent jobs such as tool installs |
| `always_keep_download` | `MISE_ALWAYS_KEEP_DOWNLOAD` | `false` | Keep downloaded archives under `~/.local/share/mise/downloads`. **Not a supported download cache** — cache `~/.local/share/mise/installs` instead |
| `always_keep_install` | `MISE_ALWAYS_KEEP_INSTALL` | `false` | Keep install files even when installation fails |

([configuration/settings](https://mise.jdx.dev/configuration/settings.html))

> **Uncertainty:** the `jobs` setting documents a default of `8` ([settings#jobs](https://mise.jdx.dev/configuration/settings.html#jobs)), while the `-j/--jobs` flag help on `mise use`, `mise install`, `mise upgrade`, `mise exec`, and `mise shell` all say `[default: 4]`. The docs do not reconcile these; pass `-j` explicitly if the value matters.

---

### 3.16 CLI quick reference

| Command | Aliases | Effect | Key flags |
| --- | --- | --- | --- |
| [`mise use [TOOL@VERSION]…`](https://mise.jdx.dev/cli/use.html) | `u` | modifies state | `-e/--env`, `-f/--force`, `-g/--global`, `-j/--jobs`, `-n/--dry-run`, `-p/--path`, `--dry-run-code`, `--fuzzy`, `--pin`, `--minimum-release-age`, `--raw`, `--remove… <TOOL>` |
| [`mise install [TOOL@VERSION]…`](https://mise.jdx.dev/cli/install.html) | `i` | modifies state | `-f/--force`, `-j/--jobs`, `-n/--dry-run`, `-v/--verbose`, `--dry-run-code`, `--minimum-release-age`, `--monorepo`, `--raw`, `--shared <DIR>`, `--system` |
| [`mise uninstall [TOOL@VERSION]…`](https://mise.jdx.dev/cli/uninstall.html) | — | **destructive** | `-a/--all`, `-n/--dry-run`, `--dry-run-code` |
| [`mise upgrade [TOOL@VERSION]…`](https://mise.jdx.dev/cli/upgrade.html) | `up` | modifies state | `-i/--interactive`, `-j/--jobs`, `-l/--bump`, `-n/--dry-run`, `-x/--exclude`, `--dry-run-code`, `--inactive`, `--local`, `--minimum-release-age`, `--raw`, `--monorepo` *(not implemented)* |
| [`mise outdated [TOOL@VERSION]…`](https://mise.jdx.dev/cli/outdated.html) | — | read-only | `-J/--json`, `-l/--bump`, `--inactive`, `--local`, `--no-header`, `--monorepo` *(not implemented)* |
| [`mise ls [TOOL]…`](https://mise.jdx.dev/cli/ls.html) | `list` | read-only | `-c/--current`, `-g/--global`, `-i/--installed`, `-J/--json`, `-l/--local`, `-m/--missing`, `--all-sources`, `--monorepo`, `--no-header`, `--outdated`, `--prefix`, `--prunable` |
| [`mise ls-remote [TOOL@VERSION] [PREFIX]`](https://mise.jdx.dev/cli/ls-remote.html) | — | read-only | `--all`, `-J/--json`, `--minimum-release-age`, `--no-versions-host`, `--prerelease`, `--strict-metadata` |
| [`mise latest <TOOL@VERSION>`](https://mise.jdx.dev/cli/latest.html) | — | read-only | `-i/--installed`, `--minimum-release-age` |
| [`mise where <TOOL@VERSION>`](https://mise.jdx.dev/cli/where.html) | — | read-only | *(none)* |
| [`mise which [BIN_NAME]`](https://mise.jdx.dev/cli/which.html) | — | read-only | `-t/--tool <TOOL@VERSION>`, `--plugin`, `--version` |
| [`mise prune [TOOL]…`](https://mise.jdx.dev/cli/prune.html) | — | **destructive** | `-n/--dry-run`, `--configs`, `--tools`, `--dry-run-code`, `--monorepo` *(not implemented)* |
| [`mise reshim`](https://mise.jdx.dev/cli/reshim.html) | — | modifies state | `-f/--force` |
| [`mise link <TOOL@VERSION> <PATH>`](https://mise.jdx.dev/cli/link.html) | `ln` | modifies state | `-f/--force` |
| [`mise lock [TOOL]…`](https://mise.jdx.dev/cli/lock.html) | — | modifies state | `-g/--global`, `-j/--jobs`, `-n/--dry-run`, `-p/--platform`, `--bump`, `--json`, `--local`, `--minimum-release-age` |
| [`mise unuse <TOOL@VERSION>…`](https://mise.jdx.dev/cli/unuse.html) | `rm`, `remove` | **destructive** | `-e/--env`, `-g/--global`, `-p/--path`, `--no-prune` |
| [`mise exec [TOOL@VERSION]… [-- CMD]`](https://mise.jdx.dev/cli/exec.html) | `x` | — | `-c/--command`, `-j/--jobs`, `--fresh-env`, `--no-deps`, `--raw`, `--deny-all`, `--deny-env`/`--allow-env`, `--deny-net`/`--allow-net`, `--deny-read`/`--allow-read`, `--deny-write`/`--allow-write` |
| [`mise shell <TOOL@VERSION>…`](https://mise.jdx.dev/cli/shell.html) | `sh` | read-only | `-j/--jobs`, `-u/--unset`, `--raw` |
| [`mise tool <TOOL>`](https://mise.jdx.dev/cli/tool.html) | — | read-only | `-J/--json`, `--active`, `--backend`, `--config-source`, `--description`, `--installed`, `--requested`, `--tool-options` |
| [`mise tool-alias <SUBCOMMAND>`](https://mise.jdx.dev/cli/tool-alias.html) | — | read-only | `-p/--tool`, `--no-header`; subcommands `get`, `ls`, `set`, `unset` |
| [`mise sync node`](https://mise.jdx.dev/cli/sync/node.html) | — | modifies state | `--brew`, `--nodenv`, `--nvm` |
| [`mise sync python`](https://mise.jdx.dev/cli/sync/python.html) | — | modifies state | `--pyenv`, `--uv` |
| [`mise sync ruby`](https://mise.jdx.dev/cli/sync/ruby.html) | — | modifies state | `--brew` |
| [`mise deps [PROVIDER]`](https://mise.jdx.dev/cli/deps.html) **exp.** | `dep` | modifies state | `--explain`, `-f/--force`, `-n/--dry-run`, `--list`, `--monorepo`, `--only`, `--skip` |
| [`mise deps install [PROVIDER]`](https://mise.jdx.dev/cli/deps/install.html) **exp.** | — | modifies state | same as `mise deps` |
| [`mise deps add <PACKAGES>…`](https://mise.jdx.dev/cli/deps/add.html) **exp.** | — | modifies state | `-D/--dev` |
| [`mise deps remove <PACKAGES>…`](https://mise.jdx.dev/cli/deps/remove.html) **exp.** | — | **destructive** | *(none)* |
| [`mise tool-stub <FILE> [ARGS]…`](https://mise.jdx.dev/cli/tool-stub.html) | — | — | *(none; args forwarded to the tool)* |
| [`mise generate tool-stub <OUTPUT>`](https://mise.jdx.dev/cli/generate/tool-stub.html) | — | modifies state | `-b/--bin`, `-u/--url`, `--version`, `--platform-url…`, `--platform-bin…`, `--http`, `--skip-download`, `--fetch`, `--lock`, `--bootstrap`, `--bootstrap-version` |
| [`mise oci build`](https://mise.jdx.dev/cli/oci/build.html) **exp.** | — | modifies state | `-o/--output`, `--from`, `-t/--tag`, `--mount-point`, `--copy…`, `--include-global`, `--no-mise`, `--owner` |
| [`mise oci push <REF>`](https://mise.jdx.dev/cli/oci/push.html) **exp.** | — | modifies state | `--cache-from`, `--no-cache`, `--image-dir`, `--from`, `--mount-point`, `--include-global`, `--no-mise`, `--owner`, `--update-index` |
| [`mise oci run [-- CMD]…`](https://mise.jdx.dev/cli/oci/run.html) **exp.** | — | — | `--engine <auto\|podman\|docker>`, `--image-dir`, `--from`, `--mount-point`, `--include-global`, `--no-mise`, `--owner`, `-i/--interactive`, `-t/--tty`, `-e/--env…`, `--volume…`, `-w/--workdir`, `--keep` |
| [`mise test-tool [TOOLS]…`](https://mise.jdx.dev/cli/test-tool.html) | — | — | `-a/--all`, `-j/--jobs`, `--all-config`, `--include-non-defined`, `--raw` |
| [`mise token github [HOST]`](https://mise.jdx.dev/cli/token/github.html) | — | read-only | `--oauth`, `--raw`, `--refresh`, `--unmask` |
| [`mise token gitlab [HOST]`](https://mise.jdx.dev/cli/token/gitlab.html) | — | read-only | `--unmask` |
| [`mise token forgejo [HOST]`](https://mise.jdx.dev/cli/token/forgejo.html) | — | read-only | `--unmask` |

> **Uncertainty:** `mise exec` documents `-C /path/to/project` in its examples but does not list it under Flags — it is presumably a global mise flag rather than an `exec`-specific one ([cli/exec](https://mise.jdx.dev/cli/exec.html)).

---

## 4. Backends & the Registry

### 4.1 What a backend is

A **backend** is an adapter between mise and a package manager, release host, or plugin ecosystem. Each backend knows how to list remote versions, install/uninstall a specific version, and set up the environment for the installed tool; mise drives them all through one common Rust trait ([dev-tools/backend_architecture](https://mise.jdx.dev/dev-tools/backend_architecture.html)).

```rust
pub trait Backend {
    async fn list_remote_versions(&self) -> Result<Vec<String>>;
    async fn install_version(&self, ctx: &InstallContext, tv: &ToolVersion) -> Result<()>;
    async fn uninstall_version(&self, tv: &ToolVersion) -> Result<()>;
    // ... other methods
}
```

One backend serves many tools: `npm:` installs any npm package, `pipx:` any PyPI CLI, `aqua:` anything in the aqua registry ([dev-tools/backends](https://mise.jdx.dev/dev-tools/backends/)). The universal spelling is:

```
<backend>:<tool-identifier>[<opt>=<val>,<opt>=<val>]@<version>
```

The bracketed `[key=value]` form passes tool options inline on the command line; the same options are written as a TOML table in `[tools]` ([dev-tools/backends/github#matching](https://mise.jdx.dev/dev-tools/backends/github.html#matching)).

```sh
mise use "github:oxc-project/oxc[matching=oxlint,rename_exe=oxlint]@apps_v1.69.0"
```

```toml
[tools]
"github:oxc-project/oxc" = { version = "apps_v1.69.0", matching = "oxlint", rename_exe = "oxlint" }
```

mise groups backends into four families ([dev-tools/backend_architecture#backend-types](https://mise.jdx.dev/dev-tools/backend_architecture.html#backend-types)):

| Family | Members | Notes |
| --- | --- | --- |
| **Core tools** | node, python, ruby, go, java, … (`core:node`) | Native Rust, fastest, no external deps. New core-tool contributions are likely rejected unless the tool is very popular. |
| **Language package managers** | `npm`, `pipx`, `cargo`, `gem`, `go`, `dotnet`, `conda` | Leverage an existing ecosystem; most bind to a runtime on PATH. |
| **Universal installers** | `aqua`, `github`, `gitlab`, `forgejo`, `http`, `s3`, `ubi` (deprecated), `pkgx` (experimental), `spm` | Download prebuilt artifacts; no plugin needed. |
| **Plugin systems** | `vfox` (tool + backend plugins), `asdf` (legacy) | Arbitrary install logic; only these can export env vars other than `PATH`. |

Capability matrix as published by mise ([dev-tools/backend_architecture#backend-capabilities-comparison](https://mise.jdx.dev/dev-tools/backend_architecture.html#backend-capabilities-comparison)):

| Feature | Core | npm/pipx/cargo | aqua | ubi | Backend Plugins | Tool Plugins (vfox) | asdf Plugins (legacy) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Speed | ✅ | ⚠️ | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ |
| Security | ✅ | ⚠️ | ✅ | ⚠️ | ⚠️ | ⚠️ | ⚠️ |
| Windows Support | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Env Var Support | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ |
| Custom Scripts | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ |
| Built-in Modules | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| Security Attestations | ❌ | ❌ | ✅ | ❌ | ✅ | ✅ | ❌ |
| Multi-tool Plugins | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Progress/Logging | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |

A key structural limit: **aqua (and the other download-only backends) can only download binaries — they cannot set environment variables.** Tools that need `JAVA_HOME`/`GOROOT`-style setup or a complex build will always need an asdf/vfox plugin or a core implementation ([dev-tools/backends/aqua](https://mise.jdx.dev/dev-tools/backends/aqua.html)).

---

### 4.2 Backend priority & default resolution order

When you name a tool, mise resolves the backend in this order ([dev-tools/backend_architecture#how-backend-selection-works](https://mise.jdx.dev/dev-tools/backend_architecture.html#how-backend-selection-works)):

| # | Step | Example |
| --- | --- | --- |
| 1 | **Explicit backend prefix** in the tool string | `mise use aqua:golangci/golangci-lint` |
| 2 | **Env var override** `MISE_BACKENDS_<TOOL>` | `export MISE_BACKENDS_PHP='vfox:mise-plugins/vfox-php'` |
| 3 | **Registry lookup** — short name → the registry's ordered backend list | `mise use golangci-lint` |
| 4 | **Core tools** | `mise use node` → `core:node` |
| 5 | **Fallback** — not found; mise suggests available backends | — |

The env-var name is the tool name in `SHOUTY_SNAKE_CASE` (hyphens → underscores): `my-tool` → `MISE_BACKENDS_MY_TOOL`. It "takes the highest priority and overrides any registry or alias configuration" — i.e. it beats `[tool_alias]`, but an explicit `backend:tool` string in your config is itself already unambiguous ([registry#environment-variable-overrides](https://mise.jdx.dev/registry.html#environment-variable-overrides)).

Within step 3, **each registry entry defines its own ordered list of backends** and mise takes the first non-disabled one. `mise registry` prints the whole list per tool, first = preferred ([registry#backends-priority](https://mise.jdx.dev/registry.html#backends-priority)):

```
$ mise registry | grep vfox:
etcd        aqua:etcd-io/etcd vfox:mise-plugins/vfox-etcd
gradle      aqua:gradle/gradle vfox:mise-plugins/vfox-gradle
terraform   aqua:hashicorp/terraform vfox:mise-plugins/vfox-terraform
```

Registry **acceptance tiers** — which also explains why the default for most tools is `aqua` ([registry#backends](https://mise.jdx.dev/registry.html#backends)):

| Tier | Backends | Rule |
| --- | --- | --- |
| **1 — preferred, routinely accepted** | `aqua`, `github`, `gitlab` | aqua first (most features + security, no plugins); github/gitlab when the tool isn't in the aqua registry. |
| **2 — high bar** | `conda` | Lower bar than tier 3 because mise's conda backend needs no separately-installed `conda`/`mamba`/`micromamba`. |
| **3 — very high bar, rarely accepted** | `pipx`, `npm`, `gem`, `go`, `cargo`, `dotnet` | All depend on a separately-installed runtime on PATH, which is fragile — `npm`/`pipx`/`gem` "silently bind tools to whichever `node`/`python`/`ruby` happened to be on PATH at install time." |
| **Not accepted** | new `vfox` / `asdf` entries (supply-chain security), `ubi` (deprecated) | Users may still install via these backends with explicit syntax; they just get no registry shorthand. |

#### `disable_backends`

```toml
# ~/.config/mise/config.toml
[settings]
disable_backends = ["asdf", "vfox"]
```

| Setting | Type / Default | Meaning |
| --- | --- | --- |
| `disable_backends` | `string[]`, `[]`, env `MISE_DISABLE_BACKENDS` (comma-separated) | Backends to disable **for new installs**, e.g. `asdf`, `pipx`, or a vfox-backend plugin name. Does **not** uninstall or disable tools already installed with those backends. |
| `disable_default_registry` | `boolean`, `false`, env `MISE_DISABLE_DEFAULT_REGISTRY` | Disables the default short-name mapping (e.g. `php` → `asdf:mise-plugins/asdf-php`) **only for the `vfox` and `asdf` backends**. |
| `disable_tools` | `string[]`, `[]`, env `MISE_DISABLE_TOOLS` | Tools defined in `mise.toml` that should be ignored. |
| `enable_tools` | `string[]` (optional), `None`, env `MISE_ENABLE_TOOLS` | When set, it is the complete allowlist and `disable_tools` is not applied; `[]` disables all tools. |

([configuration/settings#disable_backends](https://mise.jdx.dev/configuration/settings.html#disable_backends), [configuration/settings#disable_default_registry](https://mise.jdx.dev/configuration/settings.html#disable_default_registry))

Notable defaults and idioms:

- **`asdf` is disabled by default on Windows** ([registry#backends-priority](https://mise.jdx.dev/registry.html#backends-priority)); consequently mise uses vfox plugins by default there ([dev-tools/backends/vfox#default-plugin-backend](https://mise.jdx.dev/dev-tools/backends/vfox.html#default-plugin-backend)).
- To prefer vfox over asdf on Linux/macOS: `mise settings add disable_backends asdf` ([dev-tools/backends/vfox#default-plugin-backend](https://mise.jdx.dev/dev-tools/backends/vfox.html#default-plugin-backend)).
- To turn off aqua entirely while debugging a bad registry entry: `MISE_DISABLE_BACKENDS=aqua` ([dev-tools/backends/aqua](https://mise.jdx.dev/dev-tools/backends/aqua.html)).

#### Pinning a backend without env vars

```toml
# ~/.config/mise/config.toml — alias a short name to one backend
[tool_alias]
go = "core:go"
terraform = "aqua:hashicorp/terraform"
```

```toml
# mise.toml — force a backend on a single tool
[tools]
"core:node" = "20"
"aqua:yarn" = "latest"
```

([dev-tools/backend_architecture#registry-system](https://mise.jdx.dev/dev-tools/backend_architecture.html#registry-system), [dev-tools/backend_architecture#force-backend-for-tool](https://mise.jdx.dev/dev-tools/backend_architecture.html#force-backend-for-tool))

Debugging which backend won ([dev-tools/backend_architecture#debug-backend-selection](https://mise.jdx.dev/dev-tools/backend_architecture.html#debug-backend-selection)):

```bash
mise doctor          # check backend configuration
mise tool python     # see which backend is used for a tool
mise config get tools
```

---

### 4.3 The registry: short names → backend URLs

The **registry** is the table of default aliases that lets you write `mise use aws-cli` instead of `mise use aqua:aws/aws-cli` ([registry](https://mise.jdx.dev/registry.html)). Its source lives at [`registry/` in jdx/mise](https://github.com/jdx/mise/blob/main/registry/) and it is compiled into the mise binary at release time.

A registry row maps `short → [backend:spec, backend:spec, …]`, optionally constrained by OS:

| Short | Full | OS |
| --- | --- | --- |
| `aws-cli` | `aqua:aws/aws-cli` `asdf:MetricMike/asdf-awscli` | linux, macos |
| `bat` | `aqua:sharkdp/bat` `cargo:bat` `asdf:https://gitlab.com/wt0f/asdf-bat` | |
| `bun` | `core:bun` | |
| `ansible` | `pipx:ansible` | |
| `bashly` | `gem:bashly` | |
| `actionlint` | `aqua:rhysd/actionlint` `asdf:crazy-matt/asdf-actionlint` `go:github.com/rhysd/actionlint/cmd/actionlint` | |
| `carthage` | `vfox:mise-plugins/vfox-carthage` `asdf:mise-plugins/mise-carthage` | macos |

(rows copied from [registry#tools](https://mise.jdx.dev/registry.html#tools))

If a tool has no registry shorthand, install it by full name — "github and aqua give you for example access to almost all programs available on GitHub" ([registry](https://mise.jdx.dev/registry.html)).

#### Floating registries

By default mise uses the **mise registry snapshot and aqua registry snapshot bundled with that mise release**. Opt into live registry data with ([registry#floating-registries](https://mise.jdx.dev/registry.html#floating-registries)):

```shell
mise settings registry_floating=true
```

| Setting | Type / Default | Meaning |
| --- | --- | --- |
| `registry_floating` | `boolean`, `false`, env `MISE_REGISTRY_FLOATING` | Fetch the latest released official mise registry **and** the current aqua registry; bundled snapshots remain the fallback when a remote registry cannot be loaded. |
| `registry_cache_ttl` | `string`, `1h`, env `MISE_REGISTRY_CACHE_TTL` | Freshness window for the downloaded **mise** registry when `registry_floating` is on. `0s` = check every time. |
| `aqua.registry_cache_ttl` | `string`, `1w`, env `MISE_AQUA_REGISTRY_CACHE_TTL` | Freshness window for downloaded **aqua** registry sources. `0s` = re-download every time. |

([configuration/settings#registry_floating](https://mise.jdx.dev/configuration/settings.html#registry_floating), [configuration/settings#registry_cache_ttl](https://mise.jdx.dev/configuration/settings.html#registry_cache_ttl))

Behavioral details: fast/offline commands never refresh the mise registry — they use an existing cached copy or the bundled snapshot. `mise cache clear` forces both registries to be re-downloaded on their next online use. Floating is opt-in because a floating registry may contain changes made after the installed mise version was tested; **updating mise remains preferable** ([registry#floating-registries](https://mise.jdx.dev/registry.html#floating-registries)).

#### `mise registry`

```
mise registry [FLAGS] [NAME]
```

| Flag | Meaning |
| --- | --- |
| `[NAME]` | Show only that tool's full name |
| `-b, --backend <BACKEND>` | Show only tools for this backend |
| `--hide-aliased` | Hide aliased tools |
| `-J, --json` | JSON output |
| `--security` | Include per-backend security features in JSON output. **Requires `--json`.** De-duplicated across a tool's backends; "can add noticeable time for large listings since each backend's security info is resolved individually." |

```
$ mise registry
node    core:node
poetry  asdf:mise-plugins/mise-poetry
ubi     cargo:ubi-cli

$ mise registry poetry
asdf:mise-plugins/mise-poetry
```

([cli/registry](https://mise.jdx.dev/cli/registry.html))

#### `mise search`

```
mise search [FLAGS] [NAME]
```

| Flag | Default | Meaning |
| --- | --- | --- |
| `-i, --interactive` | — | Interactive fuzzy-search TUI |
| `-m, --match-type <equal\|contains\|fuzzy>` | `fuzzy` | Match strictness |
| `--no-header` | — | Suppress column headers |

```
$ mise search jq
Tool  Description
jq    Command-line JSON processor. https://github.com/jqlang/jq
jqp   A TUI playground to experiment with jq. https://github.com/noahgorstein/jqp
jiq   jid on jq - interactive JSON query tool using jq expressions. https://github.com/fiatjaf/jiq
gojq  Pure Go implementation of jq. https://github.com/itchyny/gojq
```

([cli/search](https://mise.jdx.dev/cli/search.html)). `mise use` with no arguments opens a TUI to pick a tool ([registry#tools](https://mise.jdx.dev/registry.html#tools)).

#### `mise backends ls`

```
$ mise backends ls
aqua
asdf
cargo
core
dotnet
gem
go
npm
pipx
spm
ubi
vfox
```

([cli/backends/ls](https://mise.jdx.dev/cli/backends/ls.html)). The parent command is `mise backends <SUBCOMMAND>`; **the `mise b` alias is deprecated and will be removed in mise 2027.4.0** ([cli/backends](https://mise.jdx.dev/cli/backends.html)).

> **Uncertainty:** the documented `mise backends ls` sample output omits `conda`, `forgejo`, `github`, `gitlab`, `http`, `pkgx`, and `s3`, even though those backends are documented and shipped. The docs do not say whether the sample is merely stale or whether the command lists a narrower set.

---

### 4.4 Backend comparison table

| Backend | Source | Version resolution | Needs a runtime/toolchain? | Lockfile / checksum support |
| --- | --- | --- | --- | --- |
| [`aqua`](#45-aqua) | aqua registry (baked-in snapshot; mostly GitHub releases) | Registry-defined version source (`github_release` / `github_tag`); `prerelease` opt-in | **No** — the aqua CLI is never invoked | ✅ Full: version + checksum + size + URL, **plus provenance** |
| [`asdf`](#46-asdf) | asdf plugin git repos (bash) | Plugin `bin/list-all` / `bin/latest-stable` | Yes — bash + whatever the plugin shells out to; ❌ Windows | 📝 Version only |
| [`cargo`](#47-cargo) | crates.io, or a git repo | crates.io versions; `@tag:`/`@branch:`/`@rev:` for git | `cargo` (rustup or `mise use -g rust`); cargo-binstall can skip compiling | 📝 Version only |
| [`conda`](#48-conda) | anaconda.org channels (`conda-forge` default) | anaconda.org API | **No** — no conda/mamba/micromamba needed | ⚠️ Not listed in the lockfile support matrix |
| [`dotnet`](#49-dotnet) | NuGet (`https://api.nuget.org/v3/index.json`) | NuGet feed; `prerelease` opt-in | .NET runtime (`mise use dotnet`) | ⚠️ Not listed in the lockfile support matrix |
| [`forgejo`](#410-forgejo) | Forgejo/Codeberg releases (default `https://codeberg.org`) | Release tags via Forgejo API; `version_prefix`, `prerelease` | **No** | `checksum`/`size` tool options; ⚠️ not in the lockfile support matrix |
| [`gem`](#411-gem) | RubyGems | `gem` | `ruby`/`gem` | ⚠️ Not listed in the lockfile support matrix |
| [`github`](#412-github) | GitHub releases | Release tags (via mise-versions cache or GitHub API); `version_prefix`, `prerelease` | **No** | ✅ Full: version + checksum + size + URL, **plus provenance** |
| [`gitlab`](#413-gitlab) | GitLab releases | Release tags via GitLab API | **No** | ✅ Full: version + checksum + size + URL |
| [`go`](#414-go) | Go module proxy | Module versions incl. pseudo-versions | `go` toolchain (compiles) | ⚠️ Not listed in the lockfile support matrix |
| [`http`](#415-http) | Any HTTP/HTTPS URL | `version_list_url` + `version_regex`/`version_json_path`/`version_expr`; else pinned | **No** | ✅ Full: version + checksum + size + URL; `checksum_url`/`checksum_expr` enable cross-platform locking without downloading |
| [`npm`](#416-npm) | npm registry | Direct HTTP to the registry (or `npm view` with `npm.shell_out`) | **No** to install (embedded `aube`); `node` needed to *run* the tool | 📝 Version only |
| [`pipx`](#417-pipx) | PyPI, git, GitHub, HTTP zip | `https://pypi.org/pypi/{}/json` | `uv` (preferred) or `pipx`, plus `python` | 📝 Version only |
| [`pkgx`](#418-pkgx-experimental) | pkgx pantry / `dist.pkgx.dev` bottles | Pantry metadata, npm-style semver ranges | **No** — the pkgx CLI is not invoked | ✅ Supports `mise.lock`: bottle URL + checksum, transitive deps in `[pkgx-packages]` |
| [`s3`](#419-s3) | Amazon S3 / S3-compatible (MinIO, Spaces) | `version_list_url` manifest, or S3 object listing (`version_prefix` + `version_regex`) | **No** (needs AWS credentials) | `checksum`/`size` tool options; ⚠️ not in the lockfile support matrix |
| [`spm`](#420-spm) | GitHub/GitLab releases of SwiftPM packages | Release tags | `swift` — unless a matching `*.artifactbundle.zip` is used | ⚠️ Not listed in the lockfile support matrix |
| [`ubi`](#421-ubi-deprecated) *(deprecated)* | GitHub/GitLab releases, or a direct URL | Release tags; `tag_regex` filter | **No** (ubi is compiled into mise) | ⚠️ Partial: version + checksum + size |
| [`vfox`](#422-vfox) | vfox Lua plugins | Plugin `Available` hook | **No** — the Lua interpreter is built into mise | ⚠️ Partial: version + URL + provenance (**tool plugins only**) |

Lockfile column sourced from [dev-tools/mise-lock#backend-support](https://mise.jdx.dev/dev-tools/mise-lock.html#backend-support), which states verbatim: full support for `aqua`, `http`, `github`, `gitlab` (provenance: `aqua`, `github`, `core:python`, `core:ruby`, `core:zig`); partial for `vfox` (tool plugins only) and `ubi`; basic (version + checksum) for `core` (some tools); version-only for `asdf`, `npm`, `cargo`, `pipx`; "more backends will add full asset tracking support over time".

> **Uncertainty:** `conda`, `dotnet`, `forgejo`, `gem`, `go`, `s3`, and `spm` are absent from the mise-lock backend-support list. `forgejo`/`s3` clearly accept explicit `checksum`/`size` tool options, and `mise.lock` is offered as an alternative to inline checksums on those pages, but the docs do not state their lockfile tier.

Two cross-cutting supply-chain notes:

- **`minimum_release_age`** filters top-level fuzzy version resolution for backends that publish release timestamps (default `24h`). Only `npm:` and `pipx:` forward the same cutoff into **transitive dependency** resolution during install ([dev-tools/mise-lock](https://mise.jdx.dev/dev-tools/mise-lock.html)).
- Lockfile entries are matched on `options` exactly, so options that change artifact identity produce separate entries ([dev-tools/mise-lock#file-format](https://mise.jdx.dev/dev-tools/mise-lock.html#file-format)).

---

### 4.5 `aqua`

**Syntax:** `aqua:<owner>/<repo>[@version]` — e.g. `aqua:BurntSushi/ripgrep`, `aqua:hashicorp/terraform`, `aqua:bazelbuild/buildtools/buildifier` (registry paths may be deeper than `owner/repo`).

```sh
$ mise use -g aqua:BurntSushi/ripgrep
$ rg --version
ripgrep 14.1.1
```

```toml
[tools]
"aqua:BurntSushi/ripgrep" = "latest"
```

Aqua is **the ideal backend for new tools**: no plugins, works on Windows, ships security features beyond checksums, and shows richer progress bars. **You do not install aqua** — the aqua CLI is never used; mise compiles the [aqua registry](https://github.com/aquaproj/aqua-registry) into its binary and reimplements aqua's install logic in [`src/backend/aqua.rs`](https://github.com/jdx/mise/blob/main/src/backend/aqua.rs) ([dev-tools/backends/aqua](https://mise.jdx.dev/dev-tools/backends/aqua.html)).

**Tool options**

| Option | Type / Default | Meaning |
| --- | --- | --- |
| `symlink_bins` | `boolean`, unset | Create a filtered `.mise-bins` dir exposing only the binaries mise intends to expose. Uses the registry's `files` field if present (e.g. `aws`, `aws_completer` for aws-cli), else the inferred primary binary. Keeps bundled deps (e.g. aws-cli's Python) off PATH. |
| `vars` / top-level var keys | table or inline keys | Fill aqua registry template vars (e.g. `{{.Vars.channel}}`). Vars with defaults are auto-filled; vars marked required must be set unless the registry supplies a default. |
| `prerelease` | `boolean`, `false` | Include GitHub releases flagged `prerelease: true` in `mise ls-remote`, `latest` resolution, and fuzzy matching. **No effect** when the package uses the `github_tag` version source (git tags carry no prerelease flag). Draft releases are always excluded. |

```toml
[tools]
aws-cli = { version = "latest", symlink_bins = true }
"aqua:flutter/flutter" = { version = "3.32.8", channel = "stable" }
"aqua:scenarigo/scenarigo" = { version = "0.21.0", vars = { go_version = "1.24" } }
"aqua:owner/tool" = { version = "latest", prerelease = true }
```

**Settings**

| Setting | Type / Default | Env | Meaning |
| --- | --- | --- | --- |
| `aqua.baked_registry` | `boolean` / `true` | `MISE_AQUA_BAKED_REGISTRY` | Use the baked-in aqua registry. |
| `aqua.registries` | `string[]` / `None` | `MISE_AQUA_REGISTRIES` (comma-separated) | Registry sources checked **in order, before** the baked registry. |
| `aqua.registry_cache_ttl` | `string` / `1w` | `MISE_AQUA_REGISTRY_CACHE_TTL` | Freshness of downloaded registry sources. `0s` = always re-download. |
| `aqua.registry_url` **(deprecated)** | `string` / `None` | `MISE_AQUA_REGISTRY_URL` | Legacy single registry URL. Still supported, but `aqua.registries` takes precedence when both are set. |
| `aqua.cosign` | `boolean` / `true` | `MISE_AQUA_COSIGN` | Verify cosign signatures. |
| `aqua.cosign_extra_args` | `string[]` / `None` | `MISE_AQUA_COSIGN_EXTRA_ARGS` | Extra args for cosign verification. |
| `aqua.slsa` | `boolean` / `true` | `MISE_AQUA_SLSA` | Verify SLSA provenance. |
| `aqua.minisign` | `boolean` / `true` | `MISE_AQUA_MINISIGN` | Verify minisign signatures. |
| `aqua.github_attestations` | `boolean` / `true` | `MISE_AQUA_GITHUB_ATTESTATIONS` | Verify GitHub Artifact Attestations. |

**Custom registries.** Each source may be a repository URL, a direct URL to `registry.yaml`/`registry.yml`, or an absolute `file://` URL to a local directory or file:

```toml
[settings]
aqua.registries = [
  "https://github.com/my-org/internal-aqua-registry",
  "https://github.com/partner/aqua-registry",
  "file:///absolute/path/to/aqua-registry",
  "file:///absolute/path/to/registry.yaml",
]
```

For repository/directory sources mise loads `registry.yaml` from the source root, falling back to `registry.yml`. Remote sources are cached under `MISE_CACHE_DIR` for `aqua.registry_cache_ttl`; **local `file://` sources bypass the download cache**, so edits are read on the next registry load. After a refreshed source is downloaded, mise hashes it and scopes the compiled registry cache path by that hash, pruning older compiled caches for the same URL once the new one is loaded/written. **Aqua registry aliases are local to the registry that defines them** — use [`[tool_alias]`](https://mise.jdx.dev/dev-tools/aliases.html) to point a mise shorthand at a package from another registry ([dev-tools/backends/aqua#custom-registry](https://mise.jdx.dev/dev-tools/backends/aqua.html#custom-registry)).

**Security verification.** mise provides a **native Rust implementation** for every verification method — no `cosign`, `slsa-verifier`, or `gh` binary required. Checksum verification (SHA256/SHA512/SHA1/MD5) is **always enabled**. During install mise downloads signature/attestation files, verifies natively, shows status, and **aborts the install if any verification fails** ([dev-tools/backends/aqua#security-verification](https://mise.jdx.dev/dev-tools/backends/aqua.html#security-verification)).

```yaml
# aqua registry entry enabling attestations
packages:
  - type: github_release
    repo_owner: cli
    repo_name: cli
    github_artifact_attestations:
      signer_workflow: cli/cli/.github/workflows/deployment.yml
```

```bash
# Disable all verification temporarily
export MISE_AQUA_GITHUB_ATTESTATIONS=false
export MISE_AQUA_COSIGN=false
export MISE_AQUA_SLSA=false
export MISE_AQUA_MINISIGN=false
```

**Known limitations & gotchas** ([dev-tools/backends/aqua#common-aqua-issues](https://mise.jdx.dev/dev-tools/backends/aqua.html#common-aqua-issues)):

- Aqua tools **cannot set environment variables** or do anything beyond downloading binaries; jdx is "not sure this functionality would ever get added", so some tools will always need asdf/vfox plugins.
- **Missing `supported_envs`**: registry entries sometimes omit os/arch combos that actually work. Fix by editing `supported_envs` in the tool's `registry.yaml` upstream.
- **`version_filter` instead of `version_prefix`**: a filter like `Version startsWith "atlascli/"` leaves versions as `atlascli/1.2.3`. Use `version_prefix: atlascli/` instead — mise strips and re-adds a prefix automatically but cannot do that with a filter. Non-triplet versions break `mise up` semver parsing.
- Escape hatch: `MISE_DISABLE_BACKENDS=aqua`.

---

### 4.6 `asdf`

**Syntax:** `asdf:<plugin-shorthand>` or `asdf:<owner>/<plugin-repo>` or `asdf:<git-url>` — e.g. `asdf:mise-plugins/mise-poetry`, `asdf:https://gitlab.com/wt0f/asdf-bat` ([registry#tools](https://mise.jdx.dev/registry.html#tools)).

```toml
[tools]
"asdf:owner/plugin" = { version = "latest", install_env = { MAKEFLAGS = "-j8" } }
```

> **asdf plugins are considered legacy.** New asdf **and vfox** plugins are not accepted into the mise registry for supply-chain security reasons; registry submissions must use `aqua` (preferred) or `github`. For private/custom plugins, prefer **vfox** over asdf ([dev-tools/backends/asdf](https://mise.jdx.dev/dev-tools/backends/asdf.html)).

asdf is mise's original backend. Its plugins are "more risky to use because they're typically written by a single developer unrelated to the tool vendor", and they generally **do not work on Windows** (bash scripts, rarely cross-platform). Registry asdf plugins are all hosted in the `mise-plugins` org to secure the supply chain. Tools are actively being migrated off asdf — but tools with unique install processes or that must export env vars other than `PATH` can't move to github/aqua ([dev-tools/backends/asdf](https://mise.jdx.dev/dev-tools/backends/asdf.html)).

**Tool options**

| Option | Type / Default | Meaning |
| --- | --- | --- |
| `install_env` | table, unset | Environment variables for the asdf plugin's install scripts. |

**Feature comparison: asdf vs vfox** ([dev-tools/backends/asdf#feature-comparison-asdf-vs-vfox](https://mise.jdx.dev/dev-tools/backends/asdf.html#feature-comparison-asdf-vs-vfox))

| Feature | asdf Plugins | vfox Plugins |
| --- | --- | --- |
| Language | Bash scripts | Lua |
| Windows Support | ❌ | ✅ |
| Built-in HTTP module | ❌ (requires curl) | ✅ |
| Built-in JSON module | ❌ (requires jq) | ✅ |
| Built-in HTML parsing | ❌ | ✅ |
| Built-in archive extraction | ❌ | ✅ |
| Built-in semver module | ❌ | ✅ |
| Built-in logging | ❌ | ✅ |
| Post-install hooks | ❌ | ✅ |
| Security attestations | ❌ | ✅ (cosign, SLSA) |
| Multi-tool plugins | ❌ | ✅ (backend plugins) |
| Lock file support | ❌ | ✅ |
| Rolling version checksums | ❌ | ✅ |

**Hook migration map (asdf → vfox)** ([dev-tools/backends/asdf#hook-migration-asdf-to-vfox](https://mise.jdx.dev/dev-tools/backends/asdf.html#hook-migration-asdf-to-vfox))

| asdf Script | vfox Hook | Notes |
| --- | --- | --- |
| `bin/list-all` | `Available` | Return structured version objects instead of plain text |
| `bin/download` | `PreInstall` | Return URL and checksum; mise handles the download |
| `bin/install` | `PostInstall` | Runs after mise downloads and extracts |
| `bin/exec-env` | `EnvKeys` | Return structured key/value pairs instead of `export` statements |
| `bin/list-legacy-filenames` | `PLUGIN.legacyFilenames` | Set in `metadata.lua` instead of a script |
| `bin/parse-legacy-file` | `ParseLegacyFile` | Return structured result instead of plain text |

**Version-listing environment.** `bin/list-all` and `bin/latest-stable` receive env vars and PATH additions resolved from mise configuration **before tools are loaded**, so private plugins can use `[env]` credentials or `_.path` helpers when listing versions. Because those values change the available versions, mise stores version-list caches **separately per resolved config environment**, without writing the original values or paths into the cache ([dev-tools/backends/asdf#writing-asdf-legacy-plugins-for-mise](https://mise.jdx.dev/dev-tools/backends/asdf.html#writing-asdf-legacy-plugins-for-mise)).

---

### 4.7 `cargo`

**Syntax:** `cargo:<crate>[@version]`, or `cargo:<git-url>@tag:<t>` / `@branch:<b>` / `@rev:<sha>`.

```sh
$ mise use -g cargo:eza
$ eza --version
eza - A modern, maintained replacement for ls
v0.17.1 [+git]
```

```sh
mise use cargo:https://github.com/username/demo@tag:<release_tag>
mise use cargo:https://github.com/username/demo@branch:<branch_name>
mise use cargo:https://github.com/username/demo@rev:<commit_hash>
```

**Dependencies:** requires `cargo` — via [rustup](https://rustup.rs/) or `mise use -g rust` ([dev-tools/backends/cargo](https://mise.jdx.dev/dev-tools/backends/cargo.html)).

**Tool options**

| Option | Type / Default | Meaning | binstall interaction |
| --- | --- | --- | --- |
| `features` | string or `string[]` | `cargo install --features` | **Skips cargo-binstall** (needs a source build) |
| `default-features` | `boolean`, `true` | `false` → `cargo install --no-default-features` | **Skips cargo-binstall** when `false` |
| `bin` | string | `cargo install --bin` — pick the CLI when several exist | Passed through; does not skip binstall |
| `crate` | string | `cargo install --git=<repo> <crate>` — pick the crate when several exist | Does not skip binstall when applicable; git installs already use `cargo install` |
| `locked` | `boolean`, **`true`** | `cargo install --locked`; pass `false` to disable | Does not skip binstall; affects the `cargo install` fallback |
| `install_env` | table | Env vars for `cargo install` / `cargo-binstall` | — |

```toml
[tools]
"cargo:cargo-edit" = { version = "latest", features = "add" }
"cargo:sqlx-cli" = { version = "latest", features = ["postgres", "rustls"] }
"cargo:cargo-edit" = { version = "latest", default-features = false }
"cargo:https://github.com/username/demo" = { version = "tag:v1.0.0", bin = "demo", crate = "demo" }
"cargo:https://github.com/username/demo" = { version = "latest", locked = false }
"cargo:eza" = { version = "latest", install_env = { CARGO_NET_GIT_FETCH_WITH_CLI = "true" } }
```

**Reinstall semantics:** mise records the effective `features`, `default-features`, `bin`, `crate`, and `locked` values with each installed version. Changing any of them **reinstalls the same version** rather than reusing a binary built with different options. Feature names are normalized, so reordering them or switching between a string and an array does not trigger a spurious reinstall ([dev-tools/backends/cargo#tool-options](https://mise.jdx.dev/dev-tools/backends/cargo.html#tool-options)).

**Settings**

| Setting | Type / Default | Env | Meaning |
| --- | --- | --- | --- |
| `cargo.binstall` | `boolean` / `true` | `MISE_CARGO_BINSTALL` | Use `cargo binstall` instead of `cargo install` when cargo-binstall is on PATH. Set `false` to force `cargo install` when Cargo settings must control the artifact. |
| `cargo.binstall_native` | `boolean` (optional) / `None` | `MISE_CARGO_BINSTALL_NATIVE` | mise's own binary installer using conventional GitHub release names or `package.metadata.binstall`. `true` = try it first, fall back to `cargo install`. `false` = never. |
| `cargo.binstall_only` | `boolean` / `false` | `MISE_CARGO_BINSTALL_ONLY` | Require cargo-binstall for non-git Cargo tools. Fails if no prebuilt binary exists or if options require `cargo install`. |
| `cargo.binstall_quickinstall` | `boolean` / `false` | `MISE_CARGO_BINSTALL_QUICKINSTALL` | Allow external cargo-binstall to use the third-party [cargo-quickinstall](https://github.com/cargo-bins/cargo-quickinstall) host. |
| `cargo.registry_name` | `string` (optional) / `None` | `MISE_CARGO_REGISTRY_NAME` | Use an [alternate cargo registry](https://doc.rust-lang.org/cargo/reference/registries.html#using-an-alternate-registry) instead of crates.io. |

**Strategy mechanics** ([dev-tools/backends/cargo#settings](https://mise.jdx.dev/dev-tools/backends/cargo.html#settings)):

- mise always disables cargo-binstall's `compile` strategy. Default flag is `--disable-strategies compile,quick-install`; `cargo.binstall_quickinstall = true` changes it to `--disable-strategies compile`.
- If cargo-binstall exits **94** (no prebuilt artifact), mise runs `cargo install` itself. **Other cargo-binstall errors do not trigger this fallback.**
- With `cargo.binstall_only = true`, non-git tools must be installed by cargo-binstall — no `cargo install` fallback, and options that require `cargo install` error out. Explicit git sources are unaffected (they always use `cargo install --git`).
- When cargo-binstall installs a prebuilt binary, **Cargo build settings do not affect that artifact.**
- ⚠️ **Version-sensitive:** with `cargo.binstall_native` unset, native installs are disabled today; **starting in mise `2027.1.0` mise will warn** when a package could have used a native binary artifact, and **in mise `2027.7.0` unset defaults to native binary installs** and the setting becomes a two-way switch.

---

### 4.8 `conda`

**Syntax:** `conda:<package>[@version]`, optionally `conda:<package>[channel=<name>]`.

```sh
$ mise use -g conda:ruff
$ ruff --version
ruff 0.8.0

mise use -g conda:ruff@0.7.0
mise use -g "conda:ruff[channel=bioconda]"
```

```toml
[tools]
"conda:ruff" = "latest"
"conda:bioconductor-deseq2" = { version = "latest", channel = "bioconda" }
```

**Dependencies: none.** Unlike other conda tooling, this backend requires **no conda, mamba, or micromamba** — it fetches pre-built packages from the anaconda.org API and extracts them directly ([dev-tools/backends/conda](https://mise.jdx.dev/dev-tools/backends/conda.html)).

**Tool options**

| Option | Type / Default | Meaning |
| --- | --- | --- |
| `channel` | string, falls back to `conda.channel` | Anaconda channel for this package. |

**Settings**

| Setting | Type / Default | Env | Meaning |
| --- | --- | --- | --- |
| `conda.channel` | `string` / `conda-forge` | `MISE_CONDA_CHANNEL` | Default channel. Override per-package with `conda:pkg[channel=bioconda]`. |

Common channels: `conda-forge` (community, default), `bioconda` (bioinformatics), `nvidia` (CUDA).

**Platform support** — the backend picks the subdir automatically and **falls back to `noarch`** when no platform-specific package exists:

| Platform | Conda Subdir |
| --- | --- |
| Linux x64 | `linux-64` |
| Linux ARM64 | `linux-aarch64` |
| macOS x64 | `osx-64` |
| macOS ARM64 | `osx-arm64` |
| Windows x64 | `win-64` |

**Limitations** ([dev-tools/backends/conda#limitations](https://mise.jdx.dev/dev-tools/backends/conda.html#limitations)): installs **single packages only**, not full conda environments with dependencies; best for standalone CLI tools without complex dependency trees; does not manage Python environments or package dependencies like conda/mamba.

---

### 4.9 `dotnet`

**Syntax:** `dotnet:<NuGetPackageId>[@version]`.

| Description | Usage |
| --- | --- |
| Dotnet shorthand latest version | `dotnet:GitVersion.Tool` |
| Dotnet shorthand for specific version | `dotnet:GitVersion.Tool@5.12.0` |

```sh
$ mise use dotnet:GitVersion.Tool@5.12.0
$ dotnet-gitversion /version
5.12.0+Branch.support-5.x.Sha.3f75764963eb3d7956dcd5a40488c074dd9faf9e
```

```toml
[tools]
"dotnet:GitVersion.Tool" = "5.12.0"
```

**Dependencies:** requires the .NET runtime — `mise use dotnet`, `mise use dotnet@8`, `mise use dotnet@9` ([dev-tools/backends/dotnet](https://mise.jdx.dev/dev-tools/backends/dotnet.html)).

**Tool options**

| Option | Type / Default | Meaning |
| --- | --- | --- |
| `install_env` | table | Env vars for `dotnet tool install`. |
| `prerelease` | `boolean`, `false` | Include NuGet pre-release versions in `mise ls-remote` and `latest` resolution. |

```toml
[tools]
"dotnet:GitVersion.Tool" = { version = "latest", install_env = { DOTNET_CLI_TELEMETRY_OPTOUT = "1" } }
"dotnet:GitVersion.Tool" = { version = "latest", prerelease = true }
```

**Settings**

| Setting | Type / Default | Env | Meaning |
| --- | --- | --- | --- |
| `dotnet.registry_url` | `string` / `https://api.nuget.org/v3/index.json` | `MISE_DOTNET_REGISTRY_URL` | Feed to fetch dotnet tools from; point at a custom feed if needed. |
| `dotnet.dotnet_root` | `string` (optional) / `None` (effectively `~/.local/share/mise/dotnet-root`) | `MISE_DOTNET_ROOT` | Directory holding all side-by-side .NET SDK versions. |
| `dotnet.isolated` | `boolean` / `false` | `MISE_DOTNET_ISOLATED` | `true` → each SDK in its own mise installs dir; `dotnet --list-sdks` shows only the active version. `false` → shared `DOTNET_ROOT`, matching .NET's native side-by-side model. |
| `dotnet.cli_telemetry_optout` | `boolean` (optional) / `None` | `MISE_DOTNET_CLI_TELEMETRY_OPTOUT` | `true` sets `DOTNET_CLI_TELEMETRY_OPTOUT=1`, `false` sets `0`; unset leaves .NET's default. |
| `dotnet.package_flags` **(deprecated)** | `string[]` / `[]` | `MISE_DOTNET_PACKAGE_FLAGS` (comma-separated) | Legacy; only `prerelease` is supported. **Because it is global, remove it before relying on per-tool `prerelease = false` opt-outs.** |

⚠️ **Version-sensitive:** `dotnet.package_flags` is deprecated in favor of the per-tool `prerelease = true` option or the global `prereleases` setting.

---

### 4.10 `forgejo`

**Syntax:** `forgejo:<owner>/<repo>[@version]`, optionally with inline `[api_url=…,bin=…]`. Defaults to the public Codeberg instance at `https://codeberg.org` ([dev-tools/backends/forgejo](https://mise.jdx.dev/dev-tools/backends/forgejo.html)).

```sh
$ mise use -g forgejo:forgejo/runner[api_url=https://code.forgejo.org/api/v1,bin=forgejo-runner]
$ forgejo-runner -v
forgejo-runner version v12.4.0
```

```toml
[tools]
"forgejo:forgejo/runner" = {
  version = "latest",
  api_url = "https://code.forgejo.org/api/v1",
  bin = "forgejo-runner",
}
```

Implementation shares [`src/backend/github.rs`](https://github.com/jdx/mise/blob/main/src/backend/github.rs) and the asset scorer [`src/backend/asset_matcher.rs`](https://github.com/jdx/mise/blob/main/src/backend/asset_matcher.rs) with the GitHub and GitLab backends.

**Tool options**

| Option | Type / Default | Meaning |
| --- | --- | --- |
| `asset_pattern` | string | Glob matched against release asset names. **Replaces autodetection entirely.** |
| `matching` | string | Case-sensitive **substring** filter that narrows candidates while keeping platform autodetection. |
| `matching_regex` | string (regex) | Same, but regex; case-sensitive (use inline `(?i)`). With `matching`, an asset must satisfy **both** (AND). |
| `version_prefix` | string | Custom release-tag prefix (`release-`, `version-`, or `""` for none). mise filters+strips it, re-adds it when searching, and tries both forms during install. |
| `prerelease` | `boolean`, `false` | Include releases flagged `prerelease: true`; `latest` then resolves across stable + pre-releases instead of using `/repos/{owner}/{repo}/releases/latest`. Drafts always excluded. |
| `checksum` | string `algo:hash` | Verify the downloaded file. |
| `size` | string | Verify the downloaded asset size. |
| `strip_components` | integer | Directory components stripped on extract. Auto-detected as `1` when the archive has exactly one root dir and no root files. |
| `bin` | string | Rename a **single downloaded binary** (non-archive). OS/arch suffixes are already stripped automatically. |
| `rename_exe` | string | Rename the executable **extracted from an archive**. |
| `no_app` | `boolean`, `false` | Penalize macOS `.app.` bundle assets during autodetection; prefer standalone CLI archives. Only affects autodetection. |
| `bin_path` | string (Tera template) | Directory inside the archive containing binaries. Supports `{{ version }}`, `{{ os() }}`, `{{ arch() }}` with remap kwargs. |
| `filter_bins` | string or `string[]` | Symlink only these binaries into a `.mise-bins` dir; everything else stays off PATH. |
| `api_url` | string | API base for self-hosted / other Forgejo-compatible instances. Used for release listing, asset lookup, and possibly asset download. |
| `platforms.<key>.*` | table | Per-platform `asset_pattern`, `checksum`, etc. |

```toml
[tools."forgejo:user/repo"]
version = "latest"

[tools."forgejo:user/repo".platforms]
linux-x64 = { asset_pattern = "tool_*_linux_x64.tar.gz", checksum = "sha256:a1b2c3d4e5f6789..." }
macos-arm64 = { asset_pattern = "tool_*_macOS_arm64.tar.gz", checksum = "sha256:b2c3d4e5f6789..." }
```

**Autodetection scoring** (shared with github/gitlab): OS compatibility (linux/macos/windows), architecture (x64/arm64/x86/arm), libc variant (gnu/musl on Linux, msvc on Windows), archive format preference (tar.gz, zip, …), and build type (avoids debug/test builds).

**Binary path lookup order** (shared with github/gitlab): 1) `bin_path` → 2) `bin/` in the install path → 3) install path root if it holds an executable → 4) search subdirectories for `bin/` dirs → 5) search immediate subdirectories for any executable (that whole subdirectory becomes a bin path) → 6) root of the extracted directory.

**Authentication.** Token sources in priority order ([dev-tools/backends/forgejo#token-priority](https://mise.jdx.dev/dev-tools/backends/forgejo.html#token-priority)):

| # | Source |
| --- | --- |
| 1 | `MISE_FORGEJO_ENTERPRISE_TOKEN` (non-`codeberg.org` hosts) |
| 2 | `MISE_FORGEJO_TOKEN` |
| 3 | `FORGEJO_TOKEN` |
| 4 | `credential_command` (if set) |
| 5 | `forgejo_tokens.toml` (per host) |
| 6 | `fj` CLI config (`keys.json`, if enabled) |
| 7 | `git credential fill` (if `forgejo.use_git_credentials=true`) |

```toml
# ~/.config/mise/forgejo_tokens.toml
[tokens."codeberg.org"]
token = "forgejo-public-token"

[tokens."forgejo.mycompany.com"]
token = "forgejo-enterprise-token"
```

```toml
[settings.forgejo]
credential_command = "op read 'op://Private/Forgejo Token/credential'"
fj_cli_tokens = false        # default true
use_git_credentials = true   # default false
```

| Setting | Type / Default | Env |
| --- | --- | --- |
| `forgejo.credential_command` | `string` / `` | `MISE_FORGEJO_CREDENTIAL_COMMAND` |
| `forgejo.fj_cli_tokens` | `boolean` / `true` | `MISE_FORGEJO_FJ_CLI_TOKENS` |
| `forgejo.use_git_credentials` | `boolean` / `false` | `MISE_FORGEJO_USE_GIT_CREDENTIALS` |

`credential_command` runs through the configured default inline shell; the target host is `MISE_CREDENTIAL_HOST` and the provider is `MISE_CREDENTIAL_PROVIDER=forgejo`. ⚠️ **Version-sensitive:** the legacy `$1`/`${1}` hostname argument is deprecated — **mise starts warning in `2026.11.0` and removes `$1` compatibility in `2027.11.0`.**

`fj` CLI fallback locations: `$XDG_DATA_HOME/forgejo-cli/keys.json` (default `~/.local/share/forgejo-cli/keys.json`), then `~/Library/Application Support/Cyborus.forgejo-cli/keys.json` (macOS).

Debug with `mise token forgejo`, `mise token forgejo --unmask`, `mise token forgejo forgejo.mycompany.com`.

**Known limitations.** `asset_pattern` **silently supersedes** `matching`/`matching_regex` — a superseded invalid regex is never consulted and never reported. ⚠️ `matching`/`matching_regex` are **not part of the install path** (keyed by tool name + version), so two entries for the same `forgejo:user/repo` with different `matching` values collide and the second overwrites the first; use a distinct `[tool_alias]` per binary.

---

### 4.11 `gem`

**Syntax:** `gem:<gem-name>[@version]`.

```sh
mise use -g gem:rubocop
rubocop --version
```

```toml
[tools]
"gem:rubocop" = "latest"
```

**Dependencies:** `gem` (ships with ruby) — `mise use -g ruby` ([dev-tools/backends/gem](https://mise.jdx.dev/dev-tools/backends/gem.html)).

**Tool options**

| Option | Type / Default | Meaning |
| --- | --- | --- |
| `install_env` | table | Env vars for the `gem install` command (e.g. `GEM_HOST_API_KEY` for a private gem host). |

```toml
[tools]
"gem:rubocop" = { version = "latest", install_env = { GEM_HOST_API_KEY = "..." } }
```

**Settings:** none ("No settings available").

**Known limitation — Ruby upgrades.** If the ruby used by a gem package changes (mise or system ruby), the gem may need reinstalling:

```sh
mise install -f gem:rubocop
mise install -f "gem:*"     # reinstall all gems
```

---

### 4.12 `github`

**Syntax:**

- **latest release:** `github:cli/cli`
- **specific release:** `github:cli/cli@2.40.1`

```sh
$ mise use -g github:BurntSushi/ripgrep
$ rg --version
ripgrep 14.1.1
```

```toml
[tools]
"github:BurntSushi/ripgrep" = "latest"
```

Source: [`src/backend/github.rs`](https://github.com/jdx/mise/blob/main/src/backend/github.rs). This is the **recommended replacement for `ubi`** and a Tier-1 registry backend ([dev-tools/backends/github](https://mise.jdx.dev/dev-tools/backends/github.html)).

**Tool options**

| Option | Type / Default | Meaning |
| --- | --- | --- |
| `asset_pattern` | string (templated) | Glob matched against asset names; **replaces autodetection**. Supports `{{ version }}`, `{{ os() }}`, `{{ arch() }}` with remap kwargs. |
| `additional_asset_patterns` | `string[]` (templated) | Download extra archives from the **same release** and overlay them into the primary install dir, in order. |
| `matching` | string | Case-sensitive substring pre-filter; **keeps** platform autodetection. |
| `matching_regex` | string (regex) | Regex pre-filter; ANDed with `matching`. Case-sensitive; use `(?i)`. |
| `version_prefix` | string | Custom tag prefix; `""` for none. |
| `prerelease` | `boolean`, `false` | Include `prerelease: true` releases in `ls-remote`, `latest`, fuzzy matching. Drafts always excluded. **No effect on GitLab.** |
| `checksum` | string `algo:hash` | Verify the downloaded file. |
| `size` | string | Verify asset size. |
| `strip_components` | integer | Components stripped on extract; auto-`1` for single-root-dir archives. |
| `bin` | string | Rename a single downloaded **binary** (non-archive). |
| `rename_exe` | string **or table** | Rename the executable(s) extracted from an archive. Table form: `{ "<src-glob>" = "<newname>" }`. |
| `no_app` | `boolean`, `false` | Penalize macOS `.app.` bundle assets during autodetection. |
| `bin_path` | string (Tera template) | Directory in the archive holding binaries. |
| `filter_bins` | string or `string[]` | Expose only these binaries via a `.mise-bins` symlink dir. |
| `api_url` | string | GitHub Enterprise / self-hosted API base (e.g. `https://github.mycompany.com/api/v3`). |
| `github_attestations` | `boolean`, `true` | Per-tool escape hatch to skip GitHub Artifact Attestations while keeping them on globally. |
| `platforms.<key>.*` | table | Per-platform `asset_pattern`, `checksum`, `additional_asset_patterns`, … |

```toml
# additional_asset_patterns: one install split across a base + supplemental archive
[tools."github:ollama/ollama"]
version = "latest"

[tools."github:ollama/ollama".platforms]
linux-x64 = { additional_asset_patterns = ["ollama-linux-amd64-rocm.tar.zst"] }
```

```toml
# rename_exe table form — expose two binaries from one archive under clean names
[tools."github:DanielGavin/ols"]
version = "latest"
# archive contains ols-x86_64-unknown-linux-gnu and odinfmt-x86_64-unknown-linux-gnu
rename_exe = { "ols-*" = "ols", "odinfmt-*" = "odinfmt" }
```

```toml
# bin_path templating with arch remapping — note the single-quoted TOML string
[tools."github:pizlonator/fil-c"]
version = "latest"
# expands to filc-0.681-linux-x86_64/build/bin
bin_path = 'filc-{{ version }}-{{ os() }}-{{ arch(x64="x86_64", arm64="aarch64") }}/build/bin'
```

```toml
# Two independent binaries from one release → one alias each (separate install dirs)
[tool_alias]
oxlint = "github:oxc-project/oxc"
oxfmt = "github:oxc-project/oxc"

[tools.oxlint]
version = "apps_v1.69.0"
matching = "oxlint"
rename_exe = "oxlint"

[tools.oxfmt]
version = "apps_v1.69.0"
matching = "oxfmt"
rename_exe = "oxfmt"
```

**Precedence & gotchas**

- `asset_pattern` **wins** over `matching`/`matching_regex`, silently — a superseded invalid `matching_regex` is never consulted or reported.
- `matching` also **scopes verification**: checksums and SLSA provenance discovery are narrowed to the selected asset, so a multi-binary release can't verify one binary against another's provenance. A single shared provenance file attesting every artifact (e.g. `multiple.intoto.jsonl`) is still a fallback.
- **Aliases are not an overlay mechanism** — each alias creates a separate install directory. Use `additional_asset_patterns` when two archives must compose one runnable tool.
- `additional_asset_patterns`: each pattern must select **exactly one** archive; supplemental assets **must be archives** (bare binaries unsupported); they are extracted **without** the primary asset's `strip_components`, `bin`, or `rename_exe`; later archives win on path collisions.
- There are **no bare `{{ os }}` / `{{ arch }}` variables** and no `{{ x86_64_arch }}`-style aliases — `{{ arch(x64="x86_64", arm64="aarch64") }}` is the way.
- Single-binary downloads already have OS/arch suffixes stripped automatically (`docker-compose-linux-x86_64` → `docker-compose`); use `bin` only for a custom name.
- If `mise.lock` records `github-attestations` provenance and you then set `github_attestations = false`, **re-run `mise lock`** so the lockfile no longer requires a disabled verifier.

**Lockfile:** with lockfiles enabled, mise records URL + checksum for each supplemental artifact plus available provenance metadata. Provenance is cryptographically verified for the current platform; cross-platform entries record detected provenance. `--locked` installs use only the recorded artifact list and **fail if it is incomplete**.

**Authentication.** mise uses [mise-versions](https://mise-versions.jdx.dev) as a shared cache for version lists, release metadata, and attestations, which avoids most unauthenticated GitHub API calls — including in CI and Docker. Tokens matter for API fallback, `MISE_USE_VERSIONS_HOST=0`, private repos, GHE, and custom API hosts ([dev-tools/github-tokens](https://mise.jdx.dev/dev-tools/github-tokens.html)).

| # | github.com source | GitHub Enterprise source |
| --- | --- | --- |
| 1 | `MISE_GITHUB_TOKEN` | `MISE_GITHUB_ENTERPRISE_TOKEN` |
| 2 | `GITHUB_API_TOKEN` | `MISE_GITHUB_TOKEN` / `GITHUB_API_TOKEN` / `GITHUB_TOKEN` |
| 3 | `GITHUB_TOKEN` | `credential_command` |
| 4 | `credential_command` | native GitHub OAuth |
| 5 | native GitHub OAuth | `github_tokens.toml` (per host) |
| 6 | `github_tokens.toml` (per host) | gh CLI token (matched by hostname) |
| 7 | gh CLI token (`hosts.yml`) | `git credential fill` (if enabled) |
| 8 | `git credential fill` (if enabled) | — |

`hosts.yml` lookup order: `$GH_CONFIG_DIR/hosts.yml` → `$XDG_CONFIG_HOME/gh/hosts.yml` → `~/Library/Application Support/gh/hosts.yml` (macOS) → `%APPDATA%\GitHub CLI\hosts.yml` (Windows) → `~/.config/gh/hosts.yml`. mise **reads the file directly and never shells out to `gh`**, so keychain-backed gh tokens require `credential_command` or `use_git_credentials`.

**Settings**

| Setting | Type / Default | Env | Meaning |
| --- | --- | --- | --- |
| `github.credential_command` | `string` / `` | `MISE_GITHUB_CREDENTIAL_COMMAND` | Command whose stdout is the token (trailing whitespace trimmed). Host in `MISE_CREDENTIAL_HOST`. Replaces the `git credential fill` fallback; doesn't need `use_git_credentials`. |
| `github.gh_cli_tokens` | `boolean` / `true` | `MISE_GITHUB_GH_CLI_TOKENS` | Read OAuth tokens from gh's `hosts.yml`. |
| `github.github_attestations` | `boolean` / `true` | `MISE_GITHUB_GITHUB_ATTESTATIONS` | Verify GitHub Artifact Attestations. **Only when the tool resolves to `https://api.github.com`** — a custom `api_url` (GHE Server) skips attestation verification automatically, since GHE Server has no attestations endpoint. |
| `github.slsa` | `boolean` / `true` | `MISE_GITHUB_SLSA` | Verify SLSA provenance. |
| `github.use_git_credentials` | `boolean` / `false` | `MISE_GITHUB_USE_GIT_CREDENTIALS` | Run `git credential fill` (with `GIT_TERMINAL_PROMPT=0`) as a last resort; cached per host for the session. |
| `github.oauth_client_id` | `string` / `` | `MISE_GITHUB_OAUTH_CLIENT_ID` | Enables GitHub App user access tokens via OAuth device flow. `mise token github --oauth` authorizes once. |
| `github.oauth_api_url` | `string` / `https://api.github.com` | `MISE_GITHUB_OAUTH_API_URL` | API base used to validate native OAuth tokens. |
| `github.oauth_auth_url` | `string` / `https://github.com/login` | `MISE_GITHUB_OAUTH_AUTH_URL` | OAuth endpoint base for the device flow. |
| `github.oauth_export_env` | `string` / `GITHUB_TOKEN` | `MISE_GITHUB_OAUTH_EXPORT_ENV` | Env var under which mise exports the cached OAuth token. `GH_TOKEN` for gh; empty string disables auto-export. |
| `github.oauth_open_browser` | `boolean` / `true` | `MISE_GITHUB_OAUTH_OPEN_BROWSER` | Open GitHub's verification URL during device flow. |
| `github.oauth_scopes` | `string` / `` | `MISE_GITHUB_OAUTH_SCOPES` | Optional scope string; usually empty for GitHub App user access tokens. |

```toml
[settings.github]
credential_command = 'gh auth token --hostname "$MISE_CREDENTIAL_HOST"'   # macOS/Linux
# credential_command = 'gh auth token --hostname %MISE_CREDENTIAL_HOST%'  # Windows (cmd)
```

Debug with `mise token github`, `--unmask`, or `mise token github github.mycompany.com`. If it prints `(none)` while `gh auth status` works, the token is in a keyring — enable `use_git_credentials` or a `credential_command`.

---

### 4.13 `gitlab`

**Syntax:**

- **latest release:** `gitlab:gitlab-org/gitlab-runner`
- **specific release:** `gitlab:gitlab-org/gitlab-runner@16.8.0`

```sh
$ mise use -g gitlab:gitlab-org/gitlab-runner
$ gitlab-runner --version
gitlab-runner 16.8.0
```

```toml
[tools]
"gitlab:gitlab-org/gitlab-runner" = { version = "latest", asset_pattern = "gitlab-runner-linux-x64" }
```

Also implemented in [`src/backend/github.rs`](https://github.com/jdx/mise/blob/main/src/backend/github.rs) ([dev-tools/backends/gitlab](https://mise.jdx.dev/dev-tools/backends/gitlab.html)).

**Tool options**

| Option | Type / Default | Meaning |
| --- | --- | --- |
| `asset_pattern` | string | Glob matched against asset names; replaces autodetection. |
| `matching` | string | Case-sensitive substring pre-filter; keeps autodetection. |
| `matching_regex` | string (regex) | Regex pre-filter; ANDed with `matching`. |
| `version_prefix` | string | Custom tag prefix; `""` for none. |
| `checksum` | string `algo:hash` | Verify the downloaded file (also per-platform). |
| `size` | string | Verify asset size (also per-platform). |
| `strip_components` | integer | Components stripped on extract; auto-`1` for single-root-dir archives. |
| `bin` | string | Rename a single downloaded binary. |
| `rename_exe` | string | Rename the executable extracted from an archive. |
| `no_app` | `boolean`, `false` | Penalize macOS `.app.` assets during autodetection. |
| `bin_path` | string (Tera template) | Directory in the archive holding binaries. |
| `filter_bins` | string or `string[]` | `.mise-bins` allowlist. |
| `api_url` | string | Self-hosted GitLab API base, e.g. `https://gitlab.mycompany.com/api/v4`. |
| `platforms.<key>.*` | table | Per-platform patterns/checksums/sizes. |

```toml
[tools."gitlab:gitlab-org/gitlab-runner"]
version = "latest"

[tools."gitlab:gitlab-org/gitlab-runner".platforms]
linux-x64 = { asset_pattern = "gitlab-runner-linux-x64", checksum = "sha256:a1b2c3d4e5f6789...", size = "12345678" }
macos-arm64 = { asset_pattern = "gitlab-runner-macos-arm64", checksum = "sha256:b2c3d4e5f6789...", size = "9876543" }
```

**Authentication** ([dev-tools/backends/gitlab#token-priority](https://mise.jdx.dev/dev-tools/backends/gitlab.html#token-priority)):

| # | Source |
| --- | --- |
| 1 | `MISE_GITLAB_ENTERPRISE_TOKEN` (non-`gitlab.com` hosts) |
| 2 | `MISE_GITLAB_TOKEN` |
| 3 | `GITLAB_TOKEN` |
| 4 | `credential_command` (if set) |
| 5 | `gitlab_tokens.toml` (per host) |
| 6 | glab CLI config (`config.yml`, if enabled) |
| 7 | `git credential fill` (if `gitlab.use_git_credentials=true`) |

```toml
# ~/.config/mise/gitlab_tokens.toml
[tokens."gitlab.com"]
token = "glpat-xxxxxxxx"

[tokens."gitlab.mycompany.com"]
token = "glpat-yyyyyyyy"
```

glab config lookup order: `$GLAB_CONFIG_DIR/config.yml` → `~/.config/glab-cli/config.yml` (glab's legacy location on every platform, still preferred when present) → `$XDG_CONFIG_HOME/glab-cli/config.yml` → `~/Library/Application Support/glab-cli/config.yml` (macOS) → `%LOCALAPPDATA%\glab-cli\config.yml` (**Windows — glab resolves `XDG_CONFIG_HOME` to `%LOCALAPPDATA%`, unlike `gh`, which uses `%APPDATA%`**).

| Setting | Type / Default | Env |
| --- | --- | --- |
| `gitlab.credential_command` | `string` / `` | `MISE_GITLAB_CREDENTIAL_COMMAND` |
| `gitlab.glab_cli_tokens` | `boolean` / `true` | `MISE_GITLAB_GLAB_CLI_TOKENS` |
| `gitlab.use_git_credentials` | `boolean` / `false` | `MISE_GITLAB_USE_GIT_CREDENTIALS` |

Debug with `mise token gitlab [--unmask] [host]`.

**Known limitations.** `prerelease` **has no effect on GitLab** ([dev-tools/backends/github#prerelease](https://mise.jdx.dev/dev-tools/backends/github.html#prerelease)). The GitLab page documents no `additional_asset_patterns`, `github_attestations`, or `prerelease`. Same install-path collision caveat as github/forgejo for `matching`.

---

### 4.14 `go`

**Syntax:** `go:<module-path>[@version]` — the module path of the command package.

```sh
$ mise use -g go:github.com/DarthSim/hivemind
$ hivemind --help
Hivemind version 1.1.0
```

```toml
[tools]
# pin a module version, including an unreleased pseudo-version
"go:github.com/grafana/oats" = "v0.7.1-0.20260703092802-96201f1b8136"
```

**Dependencies:** `go` must be installed — `mise use -g go`, or any other method; mise uses whatever `go` is on PATH ([dev-tools/backends/go](https://mise.jdx.dev/dev-tools/backends/go.html)).

**Tool options**

| Option | Type / Default | Meaning |
| --- | --- | --- |
| `install_env` | table | Env vars for `go install`. **mise still sets `GOBIN` to the tool install directory after applying `install_env`.** |
| `tags` | string or `string[]` | Go build tags, passed as `go install -tags`. |

```toml
[tools]
"go:github.com/golang-migrate/migrate/v4/cmd/migrate" = { version = "latest", tags = "postgres" }
# equivalent array form:
# "go:github.com/golang-migrate/migrate/v4/cmd/migrate" = { version = "latest", tags = ["postgres", "mysql"] }

# resolve an unreleased revision from VCS instead of the module proxy
"go:github.com/grafana/oats" = {
  version = "v0.7.1-0.20260703092802-96201f1b8136",
  install_env = { GOPROXY = "direct", GONOSUMDB = "github.com/grafana/oats" },
}

"go:github.com/DarthSim/hivemind" = { version = "latest", install_env = { GOPRIVATE = "github.com/acme/*" } }
```

**Settings:** none documented on the page.

**Known limitation.** Compiles from source, so a Go toolchain is required; the registry notes aqua/github are "definitely preferred" for Go tools since they ship single binaries ([registry#backends](https://mise.jdx.dev/registry.html#backends)).

---

### 4.15 `http`

**Syntax:** `http:<name>[url=<URL>]@<version>` — `url` is **required**.

```sh
mise use -g http:my-tool[url=https://example.com/releases/my-tool-v1.0.0.tar.gz]@1.0.0
```

```toml
[tools]
"http:my-tool" = { version = "1.0.0", url = "https://example.com/releases/my-tool-v{{version}}.tar.gz" }
```

Source: [`src/backend/http.rs`](https://github.com/jdx/mise/blob/main/src/backend/http.rs) ([dev-tools/backends/http](https://mise.jdx.dev/dev-tools/backends/http.html)).

**Tool options**

| Option | Type / Default | Meaning |
| --- | --- | --- |
| `url` **(required)** | string (templated) | Download URL. Templating: `{{version}}`, `{{os()}}`, `{{arch()}}`, `{{os_family()}}`. |
| `checksum` | string `algo:hash` | Verify the downloaded file. |
| `checksum_url` | string (templated) | URL of a published checksum source; lets `mise lock` resolve checksums for **every** target platform **without downloading artifacts**. |
| `checksum_expr` | string (expr-lang) | Extract a checksum from a manifest body; must evaluate to a qualified `algo:hash` **string**. |
| `size` | string | Verify the downloaded file size. |
| `strip_components` | integer | Components stripped on extract; auto-`1` for single-root-dir archives. |
| `bin` | string | Rename a single downloaded binary (non-archive). |
| `rename_exe` | string **or table** | Rename the executable(s) inside an extracted archive. String form renames the first executable found in the extracted dir (or `bin_path`); table maps `"<src-glob>" = "<newname>"`. |
| `format` | string | Explicit archive format when the URL has no/incorrect extension (e.g. `tar.xz`, `tar.gz`, `zip`). Auto-detected from the URL otherwise. |
| `bin_path` | string (templated) | Directory in the archive containing binaries. |
| `version_list_url` | string | Remote source of available versions — enables `mise ls-remote`. |
| `version_regex` | string (regex) | Extract versions from the version-list body; first capture group wins (whole match if none). |
| `version_json_path` | string (jq-like) | Extract versions from JSON. |
| `version_expr` | string (expr-lang) | Extract versions with an expression over `body`; returns an array of strings. **Takes precedence over `version_regex` and `version_json_path`.** |
| `platforms.<key>.*` | table | Per-platform `url`, `checksum`, `checksum_url`, `size`, `format`. |

**Template variables:** `version`, `os()` → `macos`/`linux`/`windows`, `arch()` → `x64`/`arm64`, `os_family()` → `unix`/`windows`. `os()`/`arch()` accept remap kwargs:

```toml
[tools]
# HashiCorp tools use "darwin" instead of "macos" and "amd64" instead of "x64"
"http:sentinel" = {
  version = "latest",
  url = 'https://releases.hashicorp.com/sentinel/{{version}}/sentinel_{{version}}_{{os(macos="darwin")}}_{{arch(x64="amd64")}}.zip',
}
```

Platform keys accept `macos` or `darwin`, `x64` or `amd64` — `macos`/`x64` are preferred in docs. "If you mess up and use something like `darwin-aarch64` mise will try to figure out what you meant and do the right thing anyhow."

```toml
[tools."http:my-tool"]
version = "1.0.0"

[tools."http:my-tool".platforms]
macos-x64   = { url = "…-macos-x64.tar.gz",   checksum = "sha256:a1b2…", size = "12345678" }
macos-arm64 = { url = "…-macos-arm64.tar.gz", checksum = "sha256:b2c3…", size = "9876543" }
linux-x64   = { url = "…-linux-x64.tar.gz",   checksum = "sha256:c3d4…", size = "11111111" }
```

**Checksum sources.** `checksum_url` may point at an individual checksum file (`<artifact>.sha256`, containing just the hash or `<hash> <filename>`), a **SHASUMS-style** file listing many platforms (matched by artifact filename), or a manifest used with `checksum_expr`. For the first two, the algorithm is detected from the file name (`*.sha512`, `SHA512SUMS`, `*.md5`, `*.b3`; default sha256).

```toml
# Individual checksum file (one per artifact)
[tools."http:my-tool"]
version = "1.0.0"
url = "https://example.com/releases/my-tool-{{ version }}-{{ os() }}-{{ arch() }}.tar.gz"
checksum_url = "https://example.com/releases/my-tool-{{ version }}-{{ os() }}-{{ arch() }}.tar.gz.sha256"

# SHASUMS (one file lists every platform)
[tools."http:other-tool"]
version = "1.0.0"
url = 'https://example.com/{{ version }}/other_{{ version }}_{{ os(macos="darwin") }}_{{ arch(x64="amd64") }}.zip'
checksum_url = 'https://example.com/{{ version }}/other_{{ version }}_SHASUMS'
```

```toml
# Manifest + checksum_expr
[tools."http:my-tool"]
version = "1.10.0"
checksum_url = "https://example.com/versions.json"
checksum_expr = '"sha256:" + filter(fromJSON(body)[version + ""].files, { #.url == url })[0].sha256'

[tools."http:my-tool".platforms]
linux-x64 = { url = "https://example.com/my-tool-{{ version }}-linux-x86_64.tar.gz" }
macos-arm64 = { url = "https://example.com/my-tool-{{ version }}-macos-arm64.tar.gz" }
```

`checksum_expr` variables: `body`, `version`, `os`, `arch`, `url` (resolved artifact URL), `filename`. **expr-lang gotchas:** write the predicate placeholder as `{ #... }` **with a space** after `{`, because `{#` is the Tera comment delimiter; index a map by a runtime value with `[version + ""]` — a bare `[version]` is treated as the literal key `"version"`.

**Version discovery.** `version_list_url` accepts plain text (single version), line-separated, a JSON array of strings, a JSON array of objects (`version`/`tag_name`), or `{"versions": [...]}`. A leading `v` is stripped automatically. `version_json_path` supports `.`, `.[]`, `.[].field`, `.field`, `.field[]`, `.field.subfield`, `.data.versions[]`, and the filter form `.[?field=value]`:

```toml
version_json_path = ".[].tag_name"
version_json_path = ".data.versions[]"
version_json_path = ".releases[].info.version"
version_json_path = ".releases[?channel=stable].version"   # Flutter-style channel filter
```

```toml
version_expr = 'split(body, "\n")'
version_expr = 'filter(split(body, "\n"), # != "")'
version_expr = 'keys(fromJSON(body).versions)'   # HashiCorp-style {"versions": {"1.0.0": {}}}
```

expr-lang builtins available: `fromJSON`, `toJSON`, `keys`, `values`, `len`.

**Caching behavior.** Downloads and extractions live in `$MISE_CACHE_DIR/http-tarballs/` (Linux `~/.cache/mise/http-tarballs/`, macOS `~/Library/Caches/mise/http-tarballs/`), keyed by a **Blake3 hash of file content** (when no checksum is given) plus `strip_components`. Installs are **symlinks** into that cache:

```bash
~/.local/share/mise/installs/http-my-tool/1.0.0 → ~/.cache/mise/http-tarballs/71f774.../extracted
```

Each entry carries a `metadata.json` (`url`, `checksum`, `size`, `extracted_at`, `platform`). Clear with `mise cache clear`; an autopruner removes entries unused for 30 days.

**Known limitation.** The http `bin_path` lookup order documented on this page is shorter than the github/gitlab one: 1) `bin_path` → 2) `bin/` in the install path → 3) search subdirectories for `bin/` dirs → 4) root of the extracted directory.

---

### 4.16 `npm`

**Syntax:** `npm:<package>[@version]`, including scoped packages (`npm:@biomejs/biome`).

```sh
$ mise use -g npm:prettier
$ prettier --version
3.1.0
```

```toml
[tools]
"npm:prettier" = "latest"
```

**Dependencies: none by default.** Version resolution queries the npm registry directly over HTTP and installs run through mise's **embedded [aube](https://github.com/jdx/aube) package manager**. `~/.npmrc` (or `NPM_CONFIG_USERCONFIG`), scoped registries (`@scope:registry`), auth tokens, and `NPM_CONFIG_*` env vars are honored by both. **`node` is only needed to *run* installed tools (and lifecycle scripts), not to install them** ([dev-tools/backends/npm](https://mise.jdx.dev/dev-tools/backends/npm.html)).

`node` is installed automatically as a dependency. To use a specific package manager CLI instead of the embedded installer, install it first (`mise use -g pnpm` / `mise use -g bun`) and set `npm.package_manager` ([dev-tools/backends/npm](https://mise.jdx.dev/dev-tools/backends/npm.html)).

**Settings**

| Setting | Type / Default | Env | Meaning |
| --- | --- | --- | --- |
| `npm.package_manager` | `string` / `auto` (`auto`, `npm`, `aube`, `aube_cli`, `bun`, `pnpm`) | `MISE_NPM_PACKAGE_MANAGER` | `auto`/`aube` = embedded aube. `aube_cli` invokes a standalone `aube add --global`. `npm`/`bun`/`pnpm` shell out to that tool, which must be installed. |
| `npm.shell_out` | `boolean` / `false` | `MISE_NPM_SHELL_OUT` | Shell out to the npm CLI (`npm view` + `npm install -g`). Applies to the default/`auto` manager only — an explicit `npm.package_manager` always shells out to that tool regardless. Use for npm-only config the built-in path lacks: `cafile`, client certs, auth token helpers. |

**Tool options**

| Option | Type / Default | Applies to | Meaning |
| --- | --- | --- | --- |
| `allow_builds` | `string[]` or `true` | aube, aube_cli, pnpm, npm ≥ 11.16.0 | Approve dependency lifecycle build scripts. `true` = allow all. **No effect on `bun`.** |
| `trust_policy_excludes` | `string[]` | aube, aube_cli | Exempt packages/version ranges from aube's `trustPolicy=no-downgrade` check. Written to the install `.npmrc` as `trustPolicyExclude`. |
| `allow_low_downloads` | `boolean` | aube | Allow a package below aube's `lowDownloadThreshold` (1000 weekly downloads). Scoped to the requested package only, written as `allowedUnpopularPackages=<package>`. |
| `aube_args` | string | aube_cli | Raw args for `aube add --global`. (**Ignored** in the embedded/in-process aube path.) |
| `pnpm_args` | string | pnpm | Raw args for `pnpm`. |
| `bun_args` | string | bun | Raw args for `bun`. mise never adds `--trust` automatically. |
| `npm_args` | string | npm | Raw args for `npm`. |

```toml
[tools]
"npm:some-tool" = { version = "latest", allow_builds = ["esbuild", "sharp"] }
"npm:some-tool" = { version = "latest", allow_builds = true }
"npm:some-tool" = { version = "latest", trust_policy_excludes = ["undici@^5 || >=6 <7"] }
"npm:some-tool" = { version = "latest", allow_low_downloads = true }
"npm:some-tool" = { version = "latest", bun_args = "--trust" }
"npm:some-tool" = { version = "latest", npm_args = "--ignore-scripts=false" }
"npm:npm"       = { version = "latest", aube_args = "--reporter append-only" }
```

**Lifecycle-script policy per installer** ([dev-tools/backends/npm#lifecycle-scripts](https://mise.jdx.dev/dev-tools/backends/npm.html#lifecycle-scripts)):

| Installer | Default script behavior | `allow_builds` translation |
| --- | --- | --- |
| `aube` (embedded, default) | pnpm-v11 model: dependency lifecycle scripts **denied** unless allowlisted | written to `aube.allowBuilds` manifest field |
| `aube_cli` | same, via `aube add --global` | forwarded, plus `aube_args` |
| `pnpm` | build approval required | one `--allow-build=<pkg>` per package (pnpm ≥ v10.4.0); `true` → `--dangerously-allow-all-builds` |
| `bun` | does not execute arbitrary dependency lifecycle scripts by default | **not supported** — mise's Bun path is a global install and writes no per-transitive `trustedDependencies` |
| `npm` | mise passes `--ignore-scripts=true` by default | npm ≥ 11.16.0: `--allow-scripts=<pkg>` (and mise then drops `--ignore-scripts=true`, since `ignore-scripts` takes precedence); `true` → `--dangerously-allow-all-scripts` |

`pnpm approve-builds -g` worked for global packages in pnpm v10.4.0–v10.x and **was removed in v11.0.0** — use `allow_builds` instead.

**`minimum_release_age` forwarding** into transitive resolution requires ([dev-tools/backends/npm](https://mise.jdx.dev/dev-tools/backends/npm.html)):

| Package manager | Requirement | Flag |
| --- | --- | --- |
| embedded aube | — | honored natively |
| pnpm | ≥ 10.16.0 | `--config.minimumReleaseAge=<minutes>` |
| bun | ≥ 1.3.0 | `--minimum-release-age <seconds>` |
| npm | ≥ 11.10.0 | `--min-release-age=<days>` |
| npm | 6.9.0–11.9.x | `--before <timestamp>` (also used for sub-day windows, since `--min-release-age` is day-granular) |

Older versions **may fail** while processing the forwarded argument.

**Socket security.** Two integrations ([dev-tools/backends/npm#socket-security](https://mise.jdx.dev/dev-tools/backends/npm.html#socket-security)):

```sh
# 1. Bun-compatible security scanner (aube implements Bun's Security Scanner API)
MISE_NPM_PACKAGE_MANAGER=aube \
AUBE_SECURITY_SCANNER=/absolute/path/to/scanner.mjs \
  mise install npm:prettier@latest
```

```js
// scanner.mjs — mise installs each npm: tool in a synthetic project, so a bare
// scanner package name is not resolvable; point the setting at an absolute module.
export { scanner } from "@socketsecurity/bun-security-scanner";
```

The scanner runs after dependency resolution and before tarballs are downloaded; a fatal finding blocks the install, and a configured scanner **fails closed** if it cannot start or complete. Requires **Node.js 22.6+**. It inherits Socket vars such as `SOCKET_SECURITY_API_KEY`, while aube strips common npm and GitHub credentials from the scanner subprocess.

```sh
# 2. Socket Firewall wraps mise itself (network layer)
sfw mise install npm:prettier@latest
sfw mise use -g npm:prettier
```

Both mise's npm metadata client and embedded aube use aube-registry, honoring `HTTP_PROXY`/`HTTPS_PROXY`/`NO_PROXY` and explicitly loading `NODE_EXTRA_CA_CERTS` into their Rust TLS clients. **Socket documents npm/yarn/pnpm, not mise or aube — this interoperability is not an upstream compatibility guarantee.**

**Known limitations / gotchas.** A `trustPolicy=no-downgrade` failure is a **supply-chain signal**, not a version-resolution problem: an earlier release had stronger trusted-publisher, staged-publish, or provenance evidence than the selected one. Investigate before excepting, and prefer a version-scoped `"<package>@<version>"` exception — a bare name exempts every future version. Switching to `npm.shell_out=true` bypasses the aube check entirely and should be a **last resort**. Download count is a popularity signal, not a safety one. Tools resolved from `mise.lock` are auto-trusted for the download-count check.

---

### 4.17 `pipx`

**Syntax** ([dev-tools/backends/pipx#supported-pipx-syntax](https://mise.jdx.dev/dev-tools/backends/pipx.html#supported-pipx-syntax)):

| Description | Usage |
| --- | --- |
| PyPI shorthand latest version | `pipx:black` |
| PyPI shorthand for specific version | `pipx:black@24.3.0` |
| GitHub shorthand for latest version | `pipx:psf/black` |
| GitHub shorthand for specific version | `pipx:psf/black@24.3.0` |
| Git syntax for latest version | `pipx:git+https://github.com/psf/black.git` |
| Git syntax for a branch | `pipx:git+https://github.com/psf/black.git@main` |
| Https with zipfile | `pipx:https://github.com/psf/black/archive/18.9b0.zip` |

"Other syntax may work but is unsupported and untested."

```sh
$ mise use -g pipx:psf/black
$ black --version
black, 24.3.0
```

**Dependencies:** `uv` (recommended) or `pipx`. **If `uv` is installed, mise uses `uv tool install` and you don't need pipx at all** — confusing, but much faster. `minimum_release_age` is forwarded to transitive Python dependency resolution: the uv path uses `--exclude-newer` and requires **`uv >= 0.2.22`**; the pipx fallback passes pip's `--uploaded-prior-to` ([dev-tools/backends/pipx](https://mise.jdx.dev/dev-tools/backends/pipx.html)).

**Tool options**

| Option | Type / Default | Meaning |
| --- | --- | --- |
| `install_env` | table | Env vars for `uv tool install` / `pipx install`. **mise still sets the tool dir, bin dir, and configured Python package index variables after applying `install_env`.** |
| `extras` | string or `string[]` | Install additional components (extras). |
| `uvx` | `boolean` (as `"false"` string in the doc example) | Set to `false` to always disable uv for this tool. |
| `pipx_args` | string | Extra args for `pipx`. |
| `uvx_args` | string | Extra args for `uvx`. |

```toml
[tools]
"pipx:harlequin" = { version = "latest", extras = "postgres,s3" }
# equivalent array form:
# "pipx:harlequin" = { version = "latest", extras = ["postgres", "s3"] }
"pipx:ansible" = { version = "latest", uvx = "false", pipx_args = "--include-deps" }
"pipx:ansible-core" = { version = "latest", uvx_args = "--with ansible" }
"pipx:black" = { version = "latest", install_env = { PIP_TRUSTED_HOST = "pypi.org" } }
```

**Settings**

| Setting | Type / Default | Env | Meaning |
| --- | --- | --- | --- |
| `pipx.registry_url` | `string` / `https://pypi.org/pypi/{}/json` | `MISE_PIPX_REGISTRY_URL` | Endpoint for fetching the latest version. The HTML endpoint `https://pypi.org/simple/{}/` also works. |
| `pipx.uvx` | `boolean` / `true` | `MISE_PIPX_UVX` | Use `uvx` instead of `pipx` when uv is on PATH. |

**Scope & known limitations.** pipx is for **CLIs, not libraries** — use it for `black`, not `NumPy`/`requests`; mise is a tool manager, not a dependency manager. Occasionally tools don't work under uvx — disable per-tool with `uvx = false`. **Python upgrades** can break installed packages:

```sh
mise install -f pipx:psf/black
mise install -f "pipx:*"     # reinstall all pipx packages
```

mise *should* do this automatically when running `mise up python`.

---

### 4.18 `pkgx` (experimental)

> ⚠️ **Experimental — requires `experimental = true`.** Enable with `mise settings experimental=true`, or `MISE_EXPERIMENTAL=1` for a single shell/session ([dev-tools/backends/pkgx](https://mise.jdx.dev/dev-tools/backends/pkgx.html)).

**Syntax:** `pkgx:<pantry-project-name>[@version]`.

```sh
mise use pkgx:stedolan.github.io/jq@1.7.1
jq --version
```

```toml
[tools]
"pkgx:stedolan.github.io/jq" = "1.7.1"
```

The backend installs from the [pkgx pantry](https://github.com/pkgxdev/pantry) **without shelling out to the `pkgx` CLI**: mise resolves pantry metadata, downloads bottles from `dist.pkgx.dev`, verifies bottle checksums when available, and writes wrapper scripts that set the package runtime environment.

**Tool options**

| Option | Type / Default | Meaning |
| --- | --- | --- |
| — | — | No pkgx-specific tool options are documented. |

> **Uncertainty:** the pkgx page documents no tool options and no `pkgx.*` settings beyond the global `experimental` gate.

**Lockfiles.** Supported. `mise lock` records the main bottle URL and checksum on the tool entry, and records **transitive pkgx dependencies in a shared `[pkgx-packages]` lockfile section**.

```sh
mise lock
mise install --locked
```

With `--locked`, mise requires a lockfile URL for the current platform and **fails rather than doing a live pantry resolution** if the lockfile is missing or incomplete.

**Known limitations.** Supports only platforms for which pkgx publishes bottles. Version requirements resolve from pantry metadata using **npm-style semver ranges**. Runtime environment from pantry manifests is applied through generated wrappers.

---

### 4.19 `s3`

**Syntax:** `s3:<name>[url=s3://bucket/key]@<version>` — `url` is **required**.

```sh
mise use -g "s3:my-tool[url=s3://my-bucket/tools/my-tool-v1.0.0.tar.gz]@1.0.0"
```

```toml
[tools]
"s3:my-tool" = { version = "1.0.0", url = "s3://my-bucket/tools/my-tool-v{{ version }}.tar.gz" }
```

Source: [`src/backend/s3.rs`](https://github.com/jdx/mise/blob/main/src/backend/s3.rs). Targets enterprise teams hosting proprietary tools in private buckets; also works with S3-compatible storage such as MinIO and DigitalOcean Spaces ([dev-tools/backends/s3](https://mise.jdx.dev/dev-tools/backends/s3.html)).

**Tool options**

| Option | Type / Default | Meaning |
| --- | --- | --- |
| `url` **(required)** | string (templated) | `s3://…` object URL; supports `{{ version }}`. |
| `endpoint` | string | Custom S3-compatible endpoint (MinIO, Spaces, self-hosted). |
| `region` | string | AWS region for the bucket. |
| `checksum` | string `algo:hash` | Verify the downloaded object. |
| `size` | string | Verify the downloaded object size (also per-platform). |
| `strip_components` | integer | Components stripped on extract; auto-`1` for single-root-dir archives. |
| `bin` | string | Rename a single downloaded binary object. |
| `rename_exe` | string | Rename the executable extracted from an archive. |
| `bin_path` | string (templated) | Directory in the archive containing binaries. |
| `format` | string | Explicit archive format when the URL lacks an extension. |
| `version_list_url` | string (`s3://…`) | JSON manifest of available versions. |
| `version_json_path` | string (jq-like) | Extract versions from that JSON. |
| `version_expr` | string (expr-lang) | Extract versions with an expression over `body`. |
| `version_prefix` | string | **S3-listing mode:** the S3 key prefix to list objects from. |
| `version_regex` | string (regex) | **S3-listing mode:** extract versions from object keys (first capture group). |
| `platforms.<key>.*` | table | Per-platform `url`, `size`, … |

> **Note:** in the s3 backend `version_prefix` means an **S3 key prefix**, not a release-tag prefix as in github/gitlab/forgejo ([dev-tools/backends/s3#s3-object-listing](https://mise.jdx.dev/dev-tools/backends/s3.html#s3-object-listing)).

**Authentication** — the AWS SDK default credential chain, in order: 1) `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` env vars → 2) `~/.aws/credentials` → 3) IAM roles when running on AWS infrastructure.

```sh
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
mise install
```

**Complete MinIO example**

```toml
[tools."s3:my-internal-tool"]
version = "latest"
url = "s3://tools-bucket/releases/my-tool-{{ version }}.tar.gz"
endpoint = "http://minio.internal:9000"
region = "us-east-1"
version_list_url = "s3://tools-bucket/releases/versions.json"
bin_path = "bin"
```

**S3 vs HTTP** ([dev-tools/backends/s3#comparison-with-http-backend](https://mise.jdx.dev/dev-tools/backends/s3.html#comparison-with-http-backend)):

| Feature | S3 Backend | HTTP Backend |
| --- | --- | --- |
| Authentication | AWS credentials (env vars, `~/.aws/credentials`, IAM) | HTTP auth headers |
| Version discovery | S3 listing or manifest file | HTTP endpoint |
| Custom endpoints | Yes (MinIO, etc.) | N/A |
| Use case | Private/enterprise tools | Public downloads |

**Known limitation.** No `version_list_url` format flexibility comparable to http's (only a JSON array of strings, or a JSON array of objects with `version_json_path`, plus `version_expr` / object listing are documented).

---

### 4.20 `spm`

**Syntax** ([dev-tools/backends/spm#supported-syntax](https://mise.jdx.dev/dev-tools/backends/spm.html#supported-syntax)):

| Description | Usage |
| --- | --- |
| GitHub shorthand for latest release version | `spm:tuist/tuist` |
| GitHub shorthand for specific release version | `spm:tuist/tuist@4.15.0` |
| GitHub url for latest release version | `spm:https://github.com/tuist/tuist.git` |
| GitHub url for specific release version | `spm:https://github.com/tuist/tuist.git@4.15.0` |

```sh
$ mise use -g spm:tuist/tuist
$ tuist --help
OVERVIEW: Generate, build and test your Xcode projects.

# artifact-bundle-only release
$ mise use -g spm:giginet/swift-testing-revolutionary@0.4.0
```

**Dependencies:** `swift` — installed [manually](https://www.swift.org/install) or [with mise](https://mise.jdx.dev/lang/swift.html). If Xcode is installed and selected via `xcode-select`, Swift is already available. Note that a **matching artifact bundle avoids the source build** ([dev-tools/backends/spm](https://mise.jdx.dev/dev-tools/backends/spm.html)).

**Resolution behavior:** when a release publishes a SwiftPM artifact bundle (`*.artifactbundle.zip`), mise uses the prebuilt executable **if it matches the current Swift target triple**; otherwise it falls back to building from source unless bundles are explicitly required.

**Tool options**

| Option | Type / Default | Meaning |
| --- | --- | --- |
| `provider` | `github` \| `gitlab`, default `github` | Which API to use for assets and release info. **Set it explicitly with shorthand notation + `api_url`, since the type usually can't be derived from the URL.** |
| `api_url` | string | Provider API base for self-hosted instances. |
| `artifactbundle` | `boolean`, unset | Unset = try bundle, fall back to source. `true` = **require** a bundle (fail if none matches the target triple). `false` = always build from source. |
| `artifactbundle_asset` | string | Select a specific `*.artifactbundle.zip`. **Required when a release contains multiple bundles.** |
| `filter_bins` | `string[]` or comma-separated string | Restrict which executable products are installed. For source builds, filtering happens **before `swift build`**, so unwanted products are never built. **Installation fails if a listed name matches no executable product.** |
| `install_command` | string | Run an explicit command from the checked-out package dir instead of discovering products and running `swift build --product`. |
| `install_env` | table | Env vars for `swift package dump-package`, `swift -print-target-info`, `swift build`. **For artifact-bundle installs this only applies to `swift -print-target-info`** — download/extract/symlink are handled by mise. |

```toml
[tools]
"spm:patricklorran/ios-settings" = { version = "latest", provider = "gitlab" }
"spm:acme/my-tool" = { version = "latest", provider = "gitlab", api_url = "https://gitlab.acme.com/api/v4" }
"spm:giginet/swift-testing-revolutionary" = { version = "0.4.0", artifactbundle = true }
"spm:giginet/swift-testing-revolutionary" = { version = "0.4.0", artifactbundle_asset = "swift-testing-revolutionary.artifactbundle.zip" }
"spm:tuist/tuist" = { version = "latest", artifactbundle = false }
"spm:swiftlang/swiftly" = { version = "latest", filter_bins = ["swiftly"] }
"spm:tuist/tuist" = { version = "latest", install_env = { SWIFTPM_ENABLE_PLUGINS = "1" } }
"spm:owner/repo" = { version = "1.2.3", artifactbundle = false, install_command = "make install PREFIX=\"$MISE_TOOL_INSTALL_PATH\"" }
```

`install_command` details: uses mise's default inline shell, inherits `install_env` plus the Swift dependency's `PATH`, and both `PREFIX` and `MISE_TOOL_INSTALL_PATH` are set to the tool's install directory. **Source installs only; cannot be combined with `filter_bins`.** mise never runs a package's Makefile automatically. Because some install scripts exit 0 even when `swift build` failed, **mise verifies at least one executable landed in `bin/` and fails otherwise.**

**Settings**

| Setting | Type / Default | Env | Meaning |
| --- | --- | --- | --- |
| `spm.artifactbundle_only` | `boolean` / (unset) | `MISE_SPM_ARTIFACTBUNDLE_ONLY=1` | Require artifact bundles for **all** `spm:` installs; mirrors `cargo.binstall_only` — mise fails instead of compiling from source. |

```toml
[settings]
spm.artifactbundle_only = true
```

**Default behavior when `filter_bins` is unset:** every executable product declared in `Package.swift` is built and symlinked into `bin/`, or every matching executable artifact from an artifact bundle is symlinked into `bin/`.

---

### 4.21 `ubi` (deprecated)

> ⚠️ **The ubi backend is deprecated. Use the [github backend](#412-github) instead** — it offers provenance verification, download progress reports, and fewer dependencies. Migrate by replacing `ubi:owner/repo` with `github:owner/repo`; `matching` and `matching_regex` carry over. `ubi` is also **not accepted for new registry entries** ([dev-tools/backends/ubi](https://mise.jdx.dev/dev-tools/backends/ubi.html), [registry#backends](https://mise.jdx.dev/registry.html#backends)).

**Syntax** ([dev-tools/backends/ubi#supported-ubi-syntax](https://mise.jdx.dev/dev-tools/backends/ubi.html#supported-ubi-syntax)):

- **latest release:** `ubi:goreleaser/goreleaser`
- **specific release:** `ubi:goreleaser/goreleaser@1.25.1`
- **URL syntax:** `ubi:https://github.com/goreleaser/goreleaser/releases/download/v1.16.2/goreleaser_Darwin_arm64.tar.gz`

```sh
$ mise use -g ubi:goreleaser/goreleaser
$ goreleaser --version
1.25.1
```

[ubi](https://github.com/houseabsolute/ubi) is compiled into mise, so it needs no separate install. It deduces the right binary/tarball from GitHub releases with no per-tool configuration, as long as the vendor uses a somewhat standard labeling scheme.

**Tool options**

| Option | Type / Default | Meaning |
| --- | --- | --- |
| `exe` | string | Name of the executable **inside** the archive. Fixes `could not find any files named cli in the downloaded zip file`. |
| `rename_exe` | string | Name for the executable **after** extraction. |
| `matching` | string | Match against the release filename (e.g. `gnu`, `musl`, `msvc`). **Only used when more than one release filename matches your OS/arch — ignored when a single asset matches.** |
| `matching_regex` | string (regex) | Matched against release filenames **before** OS/arch matching. A single match is selected; **no matches is an error.** |
| `provider` | `github` \| `gitlab`, default `github` | Which API to use. Set explicitly when using `api_url`. |
| `api_url` | string | Provider API base for self-hosted instances. |
| `extract_all` | `boolean`, `false` | Extract **all** files in the tarball, not just the bin. **Not compatible with `exe` nor `rename_exe`.** |
| `bin_path` | string | Directory in the tarball holding the binary(s). **Only meaningful with `extract_all = true`.** |
| `tag_regex` | string (regex) | Filter out release tags that don't match — for repos publishing releases for unrelated CLIs. |

```toml
[tools]
"ubi:cli/cli" = { version = "latest", exe = "gh", rename_exe = "github" }
"ubi:BurntSushi/ripgrep" = { version = "latest", matching = "musl" }
"ubi:shader-slang/slang" = { version = "latest", matching_regex = "\\d+\\.tar" }
"ubi:gitlab-org/cli" = { version = "latest", exe = "glab", provider = "gitlab" }
"ubi:acme/my-tool" = { version = "latest", provider = "gitlab", api_url = "https://gitlab.acme.com/api/v4" }
"ubi:helix-editor/helix" = { version = "latest", extract_all = true }
"ubi:BurntSushi/ripgrep" = { version = "latest", extract_all = true, bin_path = "target/release" }
"ubi:cargo-bins/cargo-binstall" = { version = "latest", tag_regex = '^\d+\.' }
```

**Binary path lookup order (ubi-specific):** 1) `bin_path` → 2) if `extract_all = true`, the install path root → 3) `bin/` in the install path → 4) root of the extracted directory.

**Auth:** for self-hosted GitHub/GitLab set `provider` + `api_url` and `MISE_GITHUB_ENTERPRISE_TOKEN` or `MISE_GITLAB_ENTERPRISE_TOKEN`.

**Migration semantics vs `github`** ([dev-tools/backends/ubi](https://mise.jdx.dev/dev-tools/backends/ubi.html)):

| Behavior | ubi | github |
| --- | --- | --- |
| `matching` semantics | Tiebreaker **among** assets already matching your OS/arch; **skipped** when one asset matches the platform | **Pre-filter before** autodetection — you get the named binary, or a clear error naming the filter if it isn't published for your platform |
| Install path key | Includes `matching` → several binaries from one repo via different `matching` values on the same `ubi:owner/repo` | Tool name + version only → two entries with different `matching` collide; **the second overwrites the first**. Give each binary its own `[tool_alias]` |

**Troubleshooting** ([dev-tools/backends/ubi#troubleshooting-ubi](https://mise.jdx.dev/dev-tools/backends/ubi.html#troubleshooting-ubi)):

| Symptom | Cause | Fix |
| --- | --- | --- |
| resolver can't find os/arch | Vendor uses a nonstandard tag (e.g. `mac` instead of `macos`/`darwin`) | Test with `ubi -p owner/repo` directly to isolate mise vs ubi |
| picks the wrong tarball | Release has many tarballs | `mise use ubi:tamasfe/taplo[matching=full]` |
| can't find the binary in the tarball | ubi assumes repo name == binary name (`ripgrep` vs `rg`) | `mise use ubi:BurntSushi/ripgrep[exe=rg]` |
| weird versions | Repo has releases for unrelated CLIs | `mise use 'ubi:cargo-bins/cargo-binstall[tag_regex=^\d+\.]'` — then `mise cache clear`, since `ls-remote` is cached |

---

### 4.22 `vfox`

> **Vfox is the recommended plugin system for mise** — cross-platform, built-in modules, modern hook-based architecture ([dev-tools/backends/vfox](https://mise.jdx.dev/dev-tools/backends/vfox.html)). Note the registry caveat: **new vfox plugins are not accepted into the mise registry** for supply-chain reasons ([registry#backends](https://mise.jdx.dev/registry.html#backends)).

**Syntax:** `vfox:<owner>/<plugin-repo>[@version]`, or `<plugin>:<tool>@<version>` for **backend plugins** that manage multiple tools.

```sh
$ mise use -g vfox:version-fox/vfox-cmake
$ cmake --version
cmake version 3.21.3
```

```toml
[tools]
"vfox:version-fox/vfox-cmake" = "latest"
```

```bash
# Backend plugins: plugin:tool format
mise plugin install my-plugin https://github.com/username/my-plugin
mise install my-plugin:some-tool@1.0.0
mise use my-plugin:some-tool@latest

# Install a plugin from a zip over HTTPS
mise plugin install vfox-cmake https://github.com/mise-plugins/vfox-cmake/archive/refs/heads/main.zip
```

**Dependencies: none.** "Vfox Lua code is executed by the interpreter built into mise." Source: [`src/backend/vfox.rs`](https://github.com/jdx/mise/blob/main/src/backend/vfox.rs).

**Tool options**

| Option | Type / Default | Meaning |
| --- | --- | --- |
| `install_env` | table | Env vars for commands a vfox plugin starts with `cmd.exec` during install hooks. **vfox's built-in Lua HTTP, archive, and JSON helpers do not use these variables directly.** |

```toml
[tools]
"vfox:version-fox/vfox-cmake" = { version = "latest", install_env = { HTTPS_PROXY = "http://proxy.example" } }
```

**Why vfox** ([dev-tools/backends/vfox#why-vfox](https://mise.jdx.dev/dev-tools/backends/vfox.html#why-vfox)): cross-platform (Windows included); built-in HTTP/JSON/HTML-parsing/archive/semver/logging modules; **security** — [tool plugins](https://mise.jdx.dev/tool-plugin-development.html) support attestation verification (GitHub artifact attestations, cosign, SLSA): when a tool plugin's `PreInstall` hook returns an `attestation` table, mise verifies it during install and **records the result in `mise.lock`, protecting against downgrade attacks on subsequent installs**; structured hooks with typed contexts, backend plugins, rolling version checksums, and lock file support.

**Default plugin backend.** On **Windows, mise uses vfox plugins by default**. To prefer plugins on Linux/macOS too:

```sh
mise settings add disable_backends asdf
```

Then registry shorthands resolve to vfox and `mise use -g cmake` works without the `vfox:` prefix ([dev-tools/backends/vfox#default-plugin-backend](https://mise.jdx.dev/dev-tools/backends/vfox.html#default-plugin-backend)).

**Known limitations.** **Backend plugins do not currently support attestation** — only tool plugins do. Lockfile support is partial: version + URL + provenance, **tool plugins only** ([dev-tools/mise-lock#backend-support](https://mise.jdx.dev/dev-tools/mise-lock.html#backend-support)).

---

### 4.23 Custom backends (backend plugins)

Beyond the built-ins, you can **build your own backend with a plugin that itself provides many tools**, using the `plugin:tool` format ([dev-tools/backends](https://mise.jdx.dev/dev-tools/backends/) → [backend-plugin-development](https://mise.jdx.dev/backend-plugin-development.html)). Use them for private repositories, custom package managers, or tool families ([dev-tools/backends/vfox#plugins](https://mise.jdx.dev/dev-tools/backends/vfox.html#plugins)).

**Tool options**

| Option | Type / Default | Meaning |
| --- | --- | --- |
| arbitrary nested tables | any | Any backend can use nested options; internally flattened to dot notation (`platforms.macos-x64.url`, `database.host`, `cache.redis.port`) for backend access. |

```toml
[tools."custom:my-backend"]
version = "1.0.0"

[tools."custom:my-backend".database]
host = "localhost"
port = 5432

[tools."custom:my-backend".cache.redis]
host = "redis.example.com"
port = 6379
```

([dev-tools/#tool-options](https://mise.jdx.dev/dev-tools/index.html#tool-options))

`disable_backends` accepts a vfox-backend plugin name, so custom backends can be disabled the same way as built-ins ([configuration/settings#disable_backends](https://mise.jdx.dev/configuration/settings.html#disable_backends)).

---

### 4.24 Options that work across every backend

These are declared in `[tools]` alongside backend-specific options ([dev-tools/#tool-options](https://mise.jdx.dev/dev-tools/index.html#tool-options)):

| Option | Type | Meaning |
| --- | --- | --- |
| `postinstall` | string | Command run once the install completes successfully for that tool/version. The tool's bin path is on PATH; `MISE_TOOL_INSTALL_PATH` and the tool's `install_env` variables are exported. **Not run if the install fails.** Distinct from `[hooks].postinstall`. |
| `os` | `string[]` | Restrict installation to `"linux"`, `"macos"` (alias `"darwin"`), `"windows"` (alias `"win"`), or `os/arch` pairs (`"macos/arm64"`, `"linux/x64"`). Arch identifiers: `"arm64"`/`"aarch64"`, `"x64"`/`"x86_64"`/`"amd64"`. An entry with `/` requires both to match; a bare OS matches any arch. Non-matching OS → the tool is skipped. |
| `depends` | `string[]` | Declare explicit install-order dependencies between tools. |

```toml
[tools]
node = { version = "22", postinstall = "corepack enable" }
ripgrep = { version = "latest", os = ["linux", "macos"] }
"npm:windows-terminal" = { version = "latest", os = ["windows"] }
hk = { version = "latest", os = ["linux", "macos/arm64"] }
"cargo:usage-cli" = { version = "latest", os = ["linux", "macos"], locked = false }
```

mise also **automatically handles backend dependencies** — installing Node.js before npm tools, pipx before pipx tools, and so on ([dev-tools/backend_architecture#backend-dependencies](https://mise.jdx.dev/dev-tools/backend_architecture.html#backend-dependencies)).

---

## 5. Bootstrap (machine & dotfiles provisioning)

`mise bootstrap` sets up a machine for the current config in one command: OS packages, git repos, dotfiles, mise shell activation, macOS defaults, macOS LaunchAgents, Linux systemd user services, the user's login shell, tools, and a final project-specific task ([bootstrap](https://mise.jdx.dev/bootstrap.html)).

The design intent is explicit: use bootstrap for things needed *before* a project or workstation is ready but which do **not** belong in `[tools]` — native libraries, Homebrew formulae, dotfile repositories, shell rc files, editor config, macOS preferences, user services, and one-time machine setup ([bootstrap](https://mise.jdx.dev/bootstrap.html)). It occupies the niche otherwise filled by Homebrew Bundle (`Brewfile`), chezmoi/stow, and small ansible playbooks: `mise bootstrap packages import`/`prune` are explicitly described as the analogues of [`brew bundle dump`](https://docs.brew.sh/Brew-Bundle-and-Brewfile) and [`brew bundle cleanup`](https://docs.brew.sh/Manpage) ([packages/brew](https://mise.jdx.dev/bootstrap/packages/brew.html)), and `[dotfiles]` provides symlink/copy/template management with a marker-based edit mechanism ([dotfiles](https://mise.jdx.dev/dotfiles.html)).

### 5.1 Is it experimental?

**No.** None of the bootstrap documentation pages (`/bootstrap.html`, `/bootstrap/*`, `/dotfiles.html`, `/cli/bootstrap*`) mark the feature as experimental or require `experimental = true`. By contrast, mise documents `experimental` as a setting whose features "may change or even disappear in any release" and consistently labels such features in their own docs ([settings#experimental](https://mise.jdx.dev/configuration/settings.html)).

Two forward-looking caveats *are* documented:

| Caveat | Detail | Source |
| --- | --- | --- |
| `mise dotfiles` (top-level) is deprecated | Hidden from help; begins warning in **mise 2027.2.0**, removed in **mise 2028.2.0**. Use `mise bootstrap dotfiles`. | ([dotfiles](https://mise.jdx.dev/dotfiles.html)) |
| Bootstrap-part aliases | Older short part names `shell`, `defaults`, `launchd`, `systemd` still accepted as aliases for `mise-shell-activate`, `macos-defaults`, `macos-launchd-agents`, `linux-systemd-units`. | ([bootstrap](https://mise.jdx.dev/bootstrap.html), [cli/bootstrap](https://mise.jdx.dev/cli/bootstrap.html)) |
| Package-plugin removal/pruning | "Not supported in the first version of this API." Removing a config entry does not uninstall host-managed state. | ([packages/plugins](https://mise.jdx.dev/bootstrap/packages/plugins.html)) |
| Cask import/prune | Not implemented; `import`/`prune` are formulae-only. | ([packages/brew](https://mise.jdx.dev/bootstrap/packages/brew.html)) |

> **Uncertainty:** the docs do not state a "stable since" version for bootstrap. Treat this section as describing the docs as published for the 2026.7.x line.

### 5.2 Config surface

All bootstrap state lives in ordinary mise config files (`mise.toml`, `~/.config/mise/config.toml`, platform variants such as `mise.macos.toml` / `mise.linux.toml`) — there is no separate bootstrap file ([bootstrap](https://mise.jdx.dev/bootstrap.html), [packages](https://mise.jdx.dev/bootstrap/packages/)).

| Table | Purpose | Page |
| --- | --- | --- |
| `[bootstrap.plugins]` | Package-manager plugin sources (`name = "<git url>"`) | ([packages/plugins](https://mise.jdx.dev/bootstrap/packages/plugins.html)) |
| `[bootstrap.packages]` | OS packages, keyed `"manager:package" = "version"` | ([packages](https://mise.jdx.dev/bootstrap/packages/)) |
| `[bootstrap.brew.taps]` | Third-party Homebrew tap URLs (`"owner/repo" = "<github git url>"`) | ([packages/brew](https://mise.jdx.dev/bootstrap/packages/brew.html)) |
| `[bootstrap.repos]` | Git repos cloned before dotfiles are applied | ([repos](https://mise.jdx.dev/bootstrap/repos.html)) |
| `[dotfiles]` | Whole-file dotfiles and small managed edits (note: **top-level table**, not under `bootstrap`) | ([dotfiles](https://mise.jdx.dev/dotfiles.html)) |
| `[bootstrap.mise_shell_activate]` | mise activation snippets in shell startup files | ([shell](https://mise.jdx.dev/bootstrap/shell.html)) |
| `[bootstrap.macos.dock]` / `.finder` / `.keyboard` / `.trackpad` | Curated macOS preferences | ([macos-defaults](https://mise.jdx.dev/bootstrap/macos-defaults.html)) |
| `[bootstrap.macos.defaults]` | Raw macOS preferences via `defaults write` | ([macos-defaults](https://mise.jdx.dev/bootstrap/macos-defaults.html)) |
| `[bootstrap.macos.launchd.agents.<name>]` | macOS user LaunchAgents | ([launchd](https://mise.jdx.dev/bootstrap/launchd.html)) |
| `[bootstrap.linux.systemd.units.<name>]` | Linux systemd **user** services and timers | ([systemd](https://mise.jdx.dev/bootstrap/systemd.html)) |
| `[bootstrap.user]` | Current-user settings, currently `login_shell` | ([user](https://mise.jdx.dev/bootstrap/user.html)) |
| `[bootstrap.hooks.<phase>]` | Commands run at named bootstrap phases | ([bootstrap#hooks](https://mise.jdx.dev/bootstrap.html)) |
| `[tools]` | Versioned dev tools managed by mise (installed by bootstrap step 10) | ([bootstrap](https://mise.jdx.dev/bootstrap.html)) |
| `[tasks.bootstrap]` | Imperative setup run after tools are installed | ([bootstrap](https://mise.jdx.dev/bootstrap.html)) |

Relevant `[settings]`:

| Setting | Type / default | Env | Meaning |
| --- | --- | --- | --- |
| `dotfiles.root` | `string`, `~/.dotfiles` | `MISE_DOTFILES_ROOT` | Root directory used for implied dotfile sources |
| `dotfiles.default_mode` | `string`, `symlink` | `MISE_DOTFILES_DEFAULT_MODE` | Mode when omitted: `symlink`, `symlink-each`, `copy`, `template` |
| `system_packages.managers` | `string[]`, `None` | `MISE_SYSTEM_PACKAGES_MANAGERS` (comma-sep) | Restrict which package managers mise acts on |
| `system_packages.sudo` | `boolean`, `true` | `MISE_SYSTEM_PACKAGES_SUDO` | Allow `mise bootstrap packages apply` to elevate with sudo |

([settings](https://mise.jdx.dev/configuration/settings.html))

#### Full example config

```toml
[bootstrap.packages]
"apk:build-base" = "latest"
"apt:build-essential" = "latest"
"brew:postgresql@17" = "latest"

[bootstrap.repos]
"~/src/dotfiles" = { url = "git@github.com:jdx/dotfiles.git", ref = "main" }

[dotfiles]
"~/.gitconfig" = { mode = "symlink" }
"~/.config/nvim" = { mode = "symlink" }

[bootstrap.mise_shell_activate]
zprofile = "shims"
zshrc = "activate"
fish = "activate"

[bootstrap.macos.dock]
autohide = true
orientation = "left"
tilesize = 48

[bootstrap.macos.finder]
show_pathbar = true

[bootstrap.macos.keyboard]
key_repeat = 2
initial_key_repeat = 15

[bootstrap.macos.trackpad]
tap_to_click = true

[bootstrap.macos.defaults]
"com.apple.finder" = { AppleShowAllFiles = true }

[bootstrap.macos.launchd.agents.my-sync]
program = "~/.local/bin/my-sync"
args = ["--watch"]
run_at_load = true

[bootstrap.linux.systemd.units.my-sync]
description = "sync files"
exec_start = "~/.local/bin/my-sync --watch"
restart = "on-failure"

[bootstrap.user]
login_shell = "/bin/zsh"

[bootstrap.hooks.pre-packages]
run = "softwareupdate --install-rosetta --agree-to-license"

[bootstrap.hooks.post-defaults]
run = "killall Dock || true"

[tools]
node = "lts"
python = "3.12"

[tasks.bootstrap]
run = "gh auth status || gh auth login"
```

([bootstrap](https://mise.jdx.dev/bootstrap.html))

### 5.3 The bootstrap lifecycle

`mise bootstrap` runs these steps **in order** ([bootstrap](https://mise.jdx.dev/bootstrap.html)):

| # | Step | Part name (`--skip`/`--only`) |
| --- | --- | --- |
| 1 | `mise bootstrap plugins apply` — install `[bootstrap.plugins]` | `plugins` |
| 2 | Built-in managers install missing `[bootstrap.packages]` | `packages` |
| 3 | `mise bootstrap repos apply` — clone/converge `[bootstrap.repos]` | `repos` |
| 4 | `mise bootstrap dotfiles apply` — apply `[dotfiles]` | `dotfiles` |
| 5 | `mise bootstrap mise-shell-activate apply` | `mise-shell-activate` (alias `shell`) |
| 6 | `mise bootstrap macos defaults apply` | `macos-defaults` (alias `defaults`) |
| 7 | `mise bootstrap macos launchd-agents apply` | `macos-launchd-agents` (alias `launchd`) |
| 8 | `mise bootstrap linux systemd-units apply` | `linux-systemd-units` (alias `systemd`) |
| 9 | `mise bootstrap user apply` | `user` |
| 10 | `mise install` — install missing `[tools]` | `tools` |
| 11 | Plugin package managers apply, after their host tools exist | (part of `packages`) |
| 12 | `mise run bootstrap` — the task named `bootstrap`, if defined | `task` |
| 13 | `[bootstrap.hooks.final]` | `final-hook` |

Step 11 is the reason plugins are split from built-in managers: "This lets a plugin declare a host command such as `code`, `helm`, `kubectl`, or `gh` that is provided by the same config's global `[tools]` entries." ([packages/plugins](https://mise.jdx.dev/bootstrap/packages/plugins.html))

```mermaid
graph TD
  A[plugins apply] --> B[built-in packages]
  B --> C[repos apply]
  C --> D[dotfiles apply]
  D --> E[mise-shell-activate apply]
  E --> F[macos defaults apply]
  F --> G[macos launchd-agents apply]
  G --> H[linux systemd-units apply]
  H --> I[user apply]
  I --> J[mise install tools]
  J --> K[plugin package managers]
  K --> L[mise run bootstrap]
  L --> M[hooks.final]
```

#### Hook phases

Hooks run **only** during explicit `mise bootstrap` invocations ([bootstrap#hooks](https://mise.jdx.dev/bootstrap.html)).

| Phase | Fires |
| --- | --- |
| `pre-packages` / `post-packages` | around package installation (`post-packages` runs after plugin-manager entries) |
| `pre-repos` / `post-repos` | around `repos apply` |
| `pre-dotfiles` / `post-dotfiles` | around `dotfiles apply` — **also wrap the standalone `mise bootstrap dotfiles apply`** |
| `pre-defaults` / `post-defaults` | around macOS defaults |
| `pre-user` / `post-user` | around `user apply` |
| `pre-tools` / `post-tools` | around `mise install` |
| `final` | after the `bootstrap` task |

([bootstrap](https://mise.jdx.dev/bootstrap.html), [cli/bootstrap](https://mise.jdx.dev/cli/bootstrap.html), [dotfiles](https://mise.jdx.dev/dotfiles.html))

Hook semantics ([bootstrap#hooks](https://mise.jdx.dev/bootstrap.html)):

- A hook may be a command string, an array of command strings, or a table with a `run` field.
- They use the same default inline shell setting as tasks.
- A failing hook **stops the bootstrap**.
- Under `--dry-run` the command is printed, not run.
- Hooks run in the *current process environment* — they do **not** get `[tools]` on `PATH`. Use `mise exec -- ...` inside a hook, or use `[tasks.bootstrap]`.
- Hooks merge across the config hierarchy from global to local.

```toml
[bootstrap.hooks.pre-packages]
run = "softwareupdate --install-rosetta --agree-to-license"

[bootstrap.hooks.post-tools]
run = [
  "mise exec -- corepack enable",
  "mise exec -- rustup component add rustfmt clippy",
]

[bootstrap.hooks.final]
run = "gh auth status || gh auth login"
```

Shorthand form:

```toml
[bootstrap.hooks]
post-defaults = "killall Dock || true"
```

#### Idempotency contract

> "The declarative steps converge: if a package is already installed, a repo is already at the requested ref, a dotfile already matches, or a default is already set, mise skips it. The `bootstrap` task runs every time, so keep it idempotent." ([bootstrap](https://mise.jdx.dev/bootstrap.html))

Cross-cutting rules that hold for every declarative section:

| Rule | Meaning |
| --- | --- |
| **Manual application only** | mise never applies packages, dotfiles, rc-file edits, macOS defaults, LaunchAgents, systemd units, or the login shell implicitly. Only the matching `apply` command or top-level `mise bootstrap` does. `mise install` prints a one-time hint when packages are missing but installs nothing. ([packages](https://mise.jdx.dev/bootstrap/packages/), [macos-defaults](https://mise.jdx.dev/bootstrap/macos-defaults.html), [launchd](https://mise.jdx.dev/bootstrap/launchd.html), [systemd](https://mise.jdx.dev/bootstrap/systemd.html), [user](https://mise.jdx.dev/bootstrap/user.html), [shell](https://mise.jdx.dev/bootstrap/shell.html)) |
| **Declarative and additive** | Entries merge global → project as a *union of keys*; a more local config can override a value but cannot remove an entry. Exception: `[bootstrap.user].login_shell` is a single value, so most-local wins. ([packages](https://mise.jdx.dev/bootstrap/packages/), [user](https://mise.jdx.dev/bootstrap/user.html)) |
| **OS-filtered, never invisible** | Entries for an unavailable manager/platform are not acted on, but `status` and `mise doctor` still *list* them as skipped, "so nothing is silently invisible". ([packages](https://mise.jdx.dev/bootstrap/packages/), [macos-defaults](https://mise.jdx.dev/bootstrap/macos-defaults.html)) |
| **Forward compatible** | Unknown managers, unknown dotfile modes/operations, unknown friendly macOS keys, and unsupported plist shapes warn and are ignored rather than failing the parse — configs written for newer mise versions still load. ([packages](https://mise.jdx.dev/bootstrap/packages/), [dotfiles](https://mise.jdx.dev/dotfiles.html), [macos-defaults](https://mise.jdx.dev/bootstrap/macos-defaults.html)) |
| **No state database** | mise has no apply manifest. Removing an entry from config leaves its file/block/line in place; `unapply` before removing the entry. ([dotfiles](https://mise.jdx.dev/dotfiles.html)) |
| **mise never deletes a default** | macOS defaults are only ever written, never removed. ([macos-defaults](https://mise.jdx.dev/bootstrap/macos-defaults.html)) |

#### Follow-up reporting

When bootstrap applies (or would apply) something needing user follow-up it prints a final `bootstrap: follow-up` section after a successful run; dry runs use `bootstrap: follow-up if applied`. If a later phase fails after earlier phases produced follow-up items, mise prints those items *before* returning the error. The section is omitted when there is nothing actionable ([bootstrap](https://mise.jdx.dev/bootstrap.html)). Documented follow-up producers: changing the login shell ("start a new login session", [user](https://mise.jdx.dev/bootstrap/user.html)) and macOS defaults that need app relaunches ([macos-defaults](https://mise.jdx.dev/bootstrap/macos-defaults.html)).

#### Aggregate status

`mise bootstrap status` reports every declarative part — packages, repos, dotfiles, shell activation, macOS defaults, LaunchAgents, systemd units, and login shell — plus `[tools]` and any system dependencies that installed tools require ([bootstrap](https://mise.jdx.dev/bootstrap.html)).

```sh
mise bootstrap status
mise bootstrap status --json
mise bootstrap status --missing
mise bootstrap packages status
mise bootstrap repos status
mise bootstrap dotfiles status
mise bootstrap dotfiles apply --dry-run
mise bootstrap dotfiles apply --dry-run --verbose
mise bootstrap mise-shell-activate status
mise bootstrap macos defaults status
mise bootstrap macos launchd-agents status
mise bootstrap linux systemd-units status
mise bootstrap user status
```

`--missing` exits 1 when anything is out of its desired state, which makes any `status` command a CI drift check that installs nothing ([bootstrap](https://mise.jdx.dev/bootstrap.html), [cli/bootstrap/status](https://mise.jdx.dev/cli/bootstrap/status.html)).

#### Top-level `mise bootstrap` flags

| Flag | Meaning |
| --- | --- |
| `-n`, `--dry-run` | Print what would happen without installing anything |
| `-y`, `--yes` | Skip confirmation prompts |
| `--force-dotfiles` | Overwrite existing files that conflict with whole-file dotfile entries |
| `--only <PART>…` | Run only named parts; repeatable or comma-separated; **mutually exclusive with `--skip`** |
| `--skip <PART>…` | Skip named parts; repeatable or comma-separated |
| `--update` | Refresh package manager metadata and update configured repos (apk `--update-cache`, apt `apt-get update`) |

Part choices for both `--only` and `--skip`: `plugins`, `packages`, `repos`, `dotfiles`, `mise-shell-activate`, `shell`, `macos-defaults`, `defaults`, `macos-launchd-agents`, `launchd`, `linux-systemd-units`, `systemd`, `user`, `tools`, `task`, `final-hook`. Alias: `mise bs` ([cli/bootstrap](https://mise.jdx.dev/cli/bootstrap.html)).

```sh
mise bootstrap                    # packages + repos + dotfiles + tools + bootstrap task
mise bootstrap --force-dotfiles   # replace conflicting dotfile targets
mise bootstrap --skip tools,task  # skip tool installation and the bootstrap task
mise bootstrap --only tools       # run just tool installation
mise bootstrap --yes              # non-interactive full converge
mise bootstrap --dry-run          # preview
```

([cli/bootstrap](https://mise.jdx.dev/cli/bootstrap.html), [bootstrap](https://mise.jdx.dev/bootstrap.html))

### 5.4 User config (`[bootstrap.user]`)

```toml
[bootstrap.user]
login_shell = "/bin/zsh"
```

When the configured shell is not listed in `/etc/shells`, mise appends it first. When the configured shell differs from the user's account entry, mise runs `chsh -s /bin/zsh` ([user](https://mise.jdx.dev/bootstrap/user.html)).

| Semantic | Detail |
| --- | --- |
| Precedence | **Most local wins** — unlike list-shaped sections there is only one desired value |
| Application | Manual only: `mise bootstrap user apply` or `mise bootstrap` |
| `/etc/shells` | Shell must be listed before `chsh` accepts it on many platforms; mise adds it when missing |
| Platform | Unix-only. On other platforms, or when `chsh` is unavailable, `status` reports the entry as **skipped** and bootstrap ignores it |
| Path form | **Absolute path required.** Relative shell names are skipped with a warning (`/bin/zsh`, `/opt/homebrew/bin/fish`) |
| sudo | `/etc/shells` is usually root-owned; mise reuses the system-package sudo behavior (prompt when interactive, passwordless sudo when non-interactive, honors `system_packages.sudo = false`) |
| Under `sudo mise` | Login-shell status and `chsh` target `SUDO_USER`, not root. Plain root sessions (containers) still target root |
| Follow-up | Top-level bootstrap reminds you to start a new login session when it changes (or would change) the login shell |

([user](https://mise.jdx.dev/bootstrap/user.html))

```sh
mise bootstrap user status            # shows login shell state
mise bootstrap user status --missing  # exit 1 if the shell differs or is not listed
mise bootstrap user status --json

mise bootstrap user apply           # updates /etc/shells and runs chsh -s
mise bootstrap user apply --dry-run # print the commands instead
mise bootstrap user apply --yes     # skip the confirmation prompt
```

([user](https://mise.jdx.dev/bootstrap/user.html), [cli/bootstrap/user/status](https://mise.jdx.dev/cli/bootstrap/user/status.html), [cli/bootstrap/user/apply](https://mise.jdx.dev/cli/bootstrap/user/apply.html))

### 5.5 Dotfiles (`[dotfiles]`)

Entries either **own a whole file or directory**, or **manage one small piece** of a file something else owns ([dotfiles](https://mise.jdx.dev/dotfiles.html)).

```toml
[settings]
dotfiles.root = "~/.dotfiles"
dotfiles.default_mode = "symlink"

[dotfiles]
"~/.zshrc" = {}                                                      # ~/.dotfiles/.zshrc
"~/.gitconfig" = "dotfiles/gitconfig"                                # explicit source
"~/.config/alacritty.toml" = { mode = "copy" }                       # ~/.dotfiles/.config/alacritty.toml
"~/.config/starship.toml" = { source = "dotfiles/starship.toml", mode = "copy" }
"~/.ssh/config" = { source = "dotfiles/ssh_config.tmpl", mode = "template" }
"~/.config/nvim" = "dotfiles/nvim"                                   # symlink the directory itself
"~/.local/bin" = { source = "dotfiles/bin", mode = "symlink-each" }  # symlink each file within
"~/hosts/dev" = { line = "127.0.0.1 dev.local" }                     # edit one line in ~/hosts
```

Application is **never implicit**: entries are applied by `mise bootstrap dotfiles add` (unless `--no-apply`), by `mise bootstrap dotfiles apply`, or by `mise bootstrap`. They are never applied by `mise install` or `mise bootstrap packages`. The nested apply command runs the configured `pre-dotfiles`/`post-dotfiles` hooks ([dotfiles](https://mise.jdx.dev/dotfiles.html)).

#### Source layout resolution

| Situation | Source used |
| --- | --- |
| `source` omitted, target under `$HOME` | Home-relative target path mirrored under `dotfiles.root`: `~/.zshrc` → `~/.dotfiles/.zshrc`; `~/.config/foo.toml` → `~/.dotfiles/.config/foo.toml` |
| Target **outside** `$HOME` | `source` **must** be specified |
| String entry (`"~/.gitconfig" = "dotfiles/gitconfig"`) | Shorthand for an explicit source with `dotfiles.default_mode` |
| Relative explicit source | Resolved against the **directory of the config file that declares the entry** — so a global `~/.config/mise/config.toml` can manage dotfiles kept beside it, and a project config can ship machine setup from the repo |

([dotfiles](https://mise.jdx.dev/dotfiles.html))

`mise bootstrap dotfiles add` omits an implied source and the built-in `symlink` mode when writing config, while preserving a mode explicitly selected with `--mode`:

```toml
[dotfiles]
"~/.zshrc" = {}
"~/.ssh/config" = { source = "ssh/config", mode = "copy" }
```

#### Globs

Source paths may contain `*`, `**`, `?`, or `[ab]`. When a wildcard source matches multiple paths, **the target path must contain matching wildcards** so each source expands to a unique target ([dotfiles](https://mise.jdx.dev/dotfiles.html)):

```toml
[dotfiles]
"~/.config/*.toml" = "dotfiles/config/*.toml"
"~/.local/share/app/**/*.json" = { source = "dotfiles/app/**/*.json", mode = "copy" }
"~/.config/app?.toml" = "dotfiles/config/app?.toml"
"~/.config/theme-[ab].toml" = "dotfiles/config/theme-[ab].toml"
```

#### Excluding files

Modes that walk a source directory — `symlink-each`, and `copy` with a directory source — take an `exclude` list of glob patterns. This is the documented way to point an entry at a directory you don't fully own, such as the one holding `mise.toml` ([dotfiles](https://mise.jdx.dev/dotfiles.html)):

```toml
[dotfiles]
"~" = { source = ".", mode = "symlink-each", exclude = ["mise.toml", "*.md", ".git"] }
```

| Pattern shape | Match semantics |
| --- | --- |
| No `/` (`"mise.toml"`, `"*.md"`) | Matches any single path component — skips that file *wherever* it appears in the tree |
| Contains `/` (`"nvim/spell"`) | Anchored to the source root; skips only that path |
| Either kind matching a directory | Skips everything under it |

Excluding a file mise already applied removes what it left behind on the next apply, the same as deleting the source would ([dotfiles](https://mise.jdx.dev/dotfiles.html)).

#### Modes

| Mode | Behavior |
| --- | --- |
| `symlink` (**default**) | Symlink the target to the source. Works for files and directories — a directory source gets **one link for the whole directory** |
| `symlink-each` | Source must be a directory: recreate its directory structure under the target and symlink each file individually, so the target directory (say `~/.config`) can also hold files mise doesn't manage. Deleting a source file removes the link it left behind on the next apply; files and links mise didn't create are never touched |
| `copy` | Copy the source file (or directory, recursively). Use when the target must be a real file — e.g. tools that rewrite their config in place. Directory copies are **additive**: matching files are overwritten, files mise doesn't manage are left in place. **Copies are never pruned**, so removing a source file leaves the copy behind |
| `template` | Render the source through the [mise template engine](https://mise.jdx.dev/templates.html) and write the result. Permissions are taken from the source file (and repaired if they drift) |

([dotfiles](https://mise.jdx.dev/dotfiles.html))

#### Templating

Templates get the same context as other mise templates (`env`, `vars`, `exec()`, etc.) — "one source file, per-machine output" ([dotfiles](https://mise.jdx.dev/dotfiles.html)).

> **Gotcha:** detecting whether a template's output has drifted requires rendering it, so `mise bootstrap dotfiles status` and a real apply **evaluate templates — including any `exec()` calls** — from your trusted config, just like `[env]` templates. `--dry-run` is the exception: it promises to execute nothing, so it skips template rendering and lists those entries as `(if changed)` ([dotfiles](https://mise.jdx.dev/dotfiles.html)).

#### Edit entries

Edit entries manage *one piece* of a file: the `mise activate` block in your shell rc, an entry in `/etc/hosts`, a snippet in a config file. They are keyed by **target path plus an id** naming each edit within the file ([dotfiles](https://mise.jdx.dev/dotfiles.html)):

```toml
[dotfiles]
"~/.zshrc/activate" = { block = 'eval "$(mise activate zsh)"' }
"~/.zshrc/aliases" = { block = '''
alias ll='ls -l'
alias la='ls -la'
''' }
"/etc/hosts/dev" = { line = "127.0.0.1 dev.local" }
"~/.gitconfig/identity" = { source = "snippets/git-identity.tmpl", template = "tera" }
```

| Key | Behavior |
| --- | --- |
| `block` | Delimited by marker comments named by the entry's id. Applying replaces only what's between the markers, or appends the block if absent; everything else in the file is untouched |
| `line` | Ensures an exact line exists somewhere in the file, appending at the end if absent. Never modifies or removes other lines — that is what makes it safely idempotent. Must be a **single** line; use a block for multi-line content |
| `source` + `template = "tera"` | Renders a template as an edit. The `template = "tera"` pairing is what makes the entry unambiguously an edit — **a table with only `source` is a whole-file entry** using `dotfiles.default_mode` |
| `comment` | Overrides the inferred marker comment prefix |

Marker format ([dotfiles](https://mise.jdx.dev/dotfiles.html)):

```sh
# >>> mise:activate >>> managed by mise - do not edit between markers
eval "$(mise activate zsh)"
# <<< mise:activate <<<
```

"The markers are the ownership record, stored in the file itself, so the design stays stateless."

- Ids may contain letters, digits, `_`, `-`, and `.`.
- Comment prefix is inferred from file extension: `#` for shell/config files, `--` for Lua, `//` for C-like languages, `;` for INI, `"` for vim; override with `comment = "..."`.
- Files that can't hold line comments at all (strict JSON, XML) aren't a fit for blocks — use a whole-file entry.

([dotfiles](https://mise.jdx.dev/dotfiles.html))

#### Merge semantics

- Whole-file entries merge by **target path**; edit entries merge by **(path, id)**, global → project ([dotfiles](https://mise.jdx.dev/dotfiles.html)).
- Idempotent: entries already in their desired state are skipped; re-running is always safe.
- Unknown modes and operations are ignored with a warning.

#### Conflicts

mise refuses to **replace** existing files it doesn't manage. A real file or directory where a symlink should go, or a directory where a file should go, is an error listing the conflicting paths; pass `--force` (or top-level `mise bootstrap --force-dotfiles`) to replace them ([dotfiles](https://mise.jdx.dev/dotfiles.html), [cli/bootstrap](https://mise.jdx.dev/cli/bootstrap.html)).

| Case | Needs `--force`? | Why |
| --- | --- | --- |
| Real file/dir where a symlink belongs | **Yes**, always — even when visible content and permissions match | Portable filesystem APIs cannot compare ownership, ACLs, extended attributes, flags, and security labels |
| Re-pointing an existing symlink | No | "a symlink is never data" |
| `copy` / `template` overwriting target content | No | That is the declared intent of those modes |
| Block edit | No | A block owns only what's between its markers |
| Line edit | No | A line only ever appends |
| Corrupted markers | **Refused with an error** — not guessed at | — |
| Edit target that is a symlink | **Refused with an error** | The edit would modify whatever the link points at, often a `[dotfiles]` source. Point the edit at the real file |

`mise bootstrap dotfiles add` sidesteps the destructive comparison entirely: it **moves** each captured real path to its source before creating the symlink; cross-filesystem moves fall back to a symlink- and permission-preserving copy ([dotfiles](https://mise.jdx.dev/dotfiles.html)).

#### Unapplying

`mise bootstrap dotfiles unapply` removes configured targets **without** removing their `[dotfiles]` entries or source files. It uses the current config and filesystem to decide what an entry owns ([dotfiles](https://mise.jdx.dev/dotfiles.html)):

| Entry kind | Removal rule |
| --- | --- |
| `symlink` | Removed only while it still points to the configured source |
| `symlink-each` | Removes exact source-to-target links, **including dangling links** for deleted source files. Other links and files under the target survive |
| file `copy` / rendered `template` | Removed only while content still matches. Modified targets require `--force` |
| directory `copy` | Removed file by file. Unmanaged neighbors always survive; directories removed only when empty |
| marker-delimited `block` | Removed with its markers |
| plain `line` edit | No ownership marker → requires `--force` |

> **Gotcha:** unapply is deliberately conservative because dotfiles have no apply manifest. "A copied file whose source was deleted can no longer be identified inside an additive directory copy. Remove such leftovers by hand." Use `--dry-run` to inspect identifiable removals first; template dry-runs do not render or execute template functions ([dotfiles](https://mise.jdx.dev/dotfiles.html)).

#### Status states

`mise bootstrap dotfiles status` reports each entry as `applied`, `missing`, `differs` (with a reason), or `source missing` ([dotfiles](https://mise.jdx.dev/dotfiles.html)).

#### Root-owned files and Windows

- Dotfiles write as the current user — **there is no sudo here.** Managing `/etc/hosts` works when running as root (containers, CI); otherwise mise fails with an ordinary permission error ([dotfiles](https://mise.jdx.dev/dotfiles.html)).
- **Windows:** file symlinks require elevation, so `symlink` and `symlink-each` fall back to **copying** for files; directory symlinks use **junctions** ([dotfiles](https://mise.jdx.dev/dotfiles.html)).

#### Dotfiles commands

```sh
mise bootstrap dotfiles status            # applied / missing / differs / source missing
mise bootstrap dotfiles status --missing  # exit 1 if anything is out of sync

mise bootstrap dotfiles apply                     # apply files and edits
mise bootstrap dotfiles apply --dry-run           # print what would be done
mise bootstrap dotfiles apply --dry-run --verbose # include diff-like details
mise bootstrap dotfiles apply --yes               # skip the confirmation prompt
mise bootstrap dotfiles apply --force             # also replace conflicting files

mise bootstrap dotfiles unapply             # remove identifiable managed targets
mise bootstrap dotfiles unapply --dry-run   # preview removals
mise bootstrap dotfiles unapply --force     # also remove modified/ambiguous targets

mise bootstrap dotfiles add ~/.zshrc       # capture a live file into dotfiles.root
mise bootstrap dotfiles edit ~/.zshrc      # edit the managed source or owning config
mise bootstrap dotfiles edit --apply ~/.zshrc
```

([dotfiles](https://mise.jdx.dev/dotfiles.html))

**`mise bootstrap dotfiles add [FLAGS] <TARGET>…`** — "If the target is already managed, this updates its source from the live target. Otherwise it creates a `[dotfiles]` entry and seeds the source under `dotfiles.root` unless `--source` is provided."

| Flag | Meaning |
| --- | --- |
| `-f`, `--force` | Overwrite existing sources without prompting |
| `-g`, `--global` | Write to the global config |
| `-l`, `--local` | Write to the local config instead of the global config |
| `-m`, `--mode <MODE>` | Dotfile mode to write |
| `-n`, `--dry-run` | Print the config/source updates without writing anything |
| `--no-apply` | Add the entry without applying it |
| `-p`, `--path <PATH>` | Write to this config file or directory |
| `-s`, `--source <PATH>` | Source path to use for a single target |
| `-y`, `--yes` | Skip the confirmation prompt |

```sh
mise bootstrap dotfiles add ~/.zshrc
mise bootstrap dotfiles add --mode copy ~/.config/starship.toml
mise bootstrap dotfiles add --source dotfiles/gitconfig ~/.gitconfig
```

([cli/bootstrap/dotfiles/add](https://mise.jdx.dev/cli/bootstrap/dotfiles/add.html))

**`mise bootstrap dotfiles apply [FLAGS] [TARGET]…`** — flags `-f/--force`, `-n/--dry-run`, `-y/--yes`; positional `[TARGET]…` limits the run to those targets.

```sh
mise bootstrap dotfiles apply
mise bootstrap dotfiles apply --dry-run
mise bootstrap dotfiles apply --force --yes
```

([cli/bootstrap/dotfiles/apply](https://mise.jdx.dev/cli/bootstrap/dotfiles/apply.html))

**`mise bootstrap dotfiles edit [FLAGS] <TARGET>`** — flags `--apply` (apply this target after the editor exits), `-m/--mode <MODE>` and `-s/--source <PATH>` (used if the target is not yet managed), `-y/--yes` (skip the confirmation prompt when adding an unmanaged target). For symlinked dotfiles, `edit` opens the **managed source**, so it works with the default `symlink` mode ([bootstrap](https://mise.jdx.dev/bootstrap.html)).

```sh
mise bootstrap dotfiles edit ~/.zshrc
mise bootstrap dotfiles edit --apply ~/.config/starship.toml
```

([cli/bootstrap/dotfiles/edit](https://mise.jdx.dev/cli/bootstrap/dotfiles/edit.html))

**`mise bootstrap dotfiles status [-J --json] [--missing] [TARGET]…`** — alias `ls`, read-only.

```sh
mise bootstrap dotfiles status
mise bootstrap dotfiles status ~/.zshrc
mise bootstrap dotfiles status --json
mise bootstrap dotfiles status --missing # exit 1 if anything is out of sync
```

([cli/bootstrap/dotfiles/status](https://mise.jdx.dev/cli/bootstrap/dotfiles/status.html))

**`mise bootstrap dotfiles unapply [FLAGS] [TARGET]…`** — marked **destructive — may delete or irreversibly overwrite**. Flags `-f/--force`, `-n/--dry-run`, `-y/--yes`.

```sh
mise bootstrap dotfiles unapply
mise bootstrap dotfiles unapply ~/.zshrc
mise bootstrap dotfiles unapply --dry-run
mise bootstrap dotfiles unapply --force --yes
```

([cli/bootstrap/dotfiles/unapply](https://mise.jdx.dev/cli/bootstrap/dotfiles/unapply.html))

#### Capturing changes back

```sh
$EDITOR ~/.config/starship.toml
mise bootstrap dotfiles add ~/.config/starship.toml
```

For an unmanaged target, `add` creates a `[dotfiles]` entry and seeds the source under `dotfiles.root`. For an already-managed target, it updates the existing source from the live target ([dotfiles](https://mise.jdx.dev/dotfiles.html)).

#### Self-managing config

```toml
[settings]
dotfiles.root = "~/.dotfiles"

[dotfiles]
"~/.dotfiles" = "~/src/dotfiles"
"~/.config/mise/config.toml" = "~/src/dotfiles/mise/config.toml"
```

Clone the real repo (e.g. `~/src/dotfiles`) *before* the first apply. Use the real repo path for sources needed during the first run — `~/.dotfiles` does not exist until mise creates that symlink. Replacing the active global config affects future mise invocations, so make sure the source contains a valid config ([dotfiles](https://mise.jdx.dev/dotfiles.html), [bootstrap](https://mise.jdx.dev/bootstrap.html)).

### 5.6 Packages (`[bootstrap.packages]`)

```toml
[bootstrap.packages]
"apk:build-base" = "latest"
"apt:libssl-dev" = "latest"
"apt:build-essential" = "latest"
"brew:postgresql@17" = "latest"
"brew:ffmpeg" = "latest"
"brew-cask:firefox" = "latest"
"flatpak:org.mozilla.firefox" = "latest"
"mas:497799835" = "latest"
```

Each entry is keyed `"manager:package"` — **the manager prefix is required** — and the value is a version: `"latest"`, or a pin in the manager's native format where supported ([packages](https://mise.jdx.dev/bootstrap/packages/)).

System packages are intentionally separate from `[tools]`: they are not version-pinned per-project, do not get shims, and are installed machine-globally. Use them for shared libraries, build dependencies, and machine-global GUI apps (`libssl-dev`, `postgresql`, `ffmpeg`, `firefox`), **not** for project dev tools ([packages](https://mise.jdx.dev/bootstrap/packages/)).

| Manager | Platform | Pins? |
| --- | --- | --- |
| `apk` | Alpine Linux | Yes, native `name=version` |
| `apt` | Debian, Ubuntu, Mint | Yes, native `name=version`; `name:arch` qualifiers pass through |
| `dnf` | Fedora, RHEL, CentOS Stream, Rocky, Alma | Yes, `name-version` / `name-version-release` |
| `pacman` | Arch, Manjaro, EndeavourOS | **No** — pinned entries skipped with a warning |
| `brew` | macOS (arm64), Linux (x86_64/arm64) — **no Homebrew required** | Via formula name (`postgresql@17`), not a mise pin |
| `brew-cask` | macOS — **no Homebrew required** | Via cask token |
| `flatpak` | Linux with the `flatpak` CLI on PATH | **No** |
| `mas` | macOS with the `mas` CLI on PATH | **No** |
| `<plugin>` | Declared by the plugin | Declared by the plugin |

([packages](https://mise.jdx.dev/bootstrap/packages/), [pacman](https://mise.jdx.dev/bootstrap/packages/pacman.html), [flatpak](https://mise.jdx.dev/bootstrap/packages/flatpak.html), [mas](https://mise.jdx.dev/bootstrap/packages/mas.html), [cli/bootstrap/packages/use](https://mise.jdx.dev/cli/bootstrap/packages/use.html))

#### Choosing which managers run

By default mise acts on every configured manager available on the current machine. When more than one could apply, restrict with the `system_packages.managers` setting ([packages](https://mise.jdx.dev/bootstrap/packages/)):

```toml
[settings]
system_packages.managers = ["apt"]
```

This composes with platform-specific config files (`mise.macos.toml`, `mise.linux.toml`). The setting is **name-based** and can include or exclude plugin managers just like built-ins ([packages/plugins](https://mise.jdx.dev/bootstrap/packages/plugins.html)).

#### sudo behavior

Linux package managers require root. When not running as root mise elevates with `sudo`. The same sudo path is used when `[bootstrap.user].login_shell` needs to add a shell to `/etc/shells`, and it only happens during an explicit `mise bootstrap` ([packages#sudo](https://mise.jdx.dev/bootstrap/packages/)):

| Context | Behavior |
| --- | --- |
| Already root (containers, CI) | No sudo; commands run directly |
| Interactive terminal | e.g. `sudo apt-get install ...` with a normal sudo prompt |
| Non-interactive without passwordless sudo | mise **errors and prints the exact command to run manually** — it never hangs waiting for a password |
| Always | The full command line is logged before it runs |
| `system_packages.sudo = false` | Elevation forbidden entirely; mise prints the command for you to run |
| `brew` | Never needs sudo **except once** to create `/opt/homebrew` |
| Package plugins | Never use mise's sudo path and must never elevate themselves |

#### 5.6.1 apk (Alpine)

```toml
[bootstrap.packages]
"apk:build-base" = "latest"
"apk:zlib-dev" = "1.3.1-r2" # version pin
```

| Operation | Command |
| --- | --- |
| State check | `apk info -e -v` (read-only, never elevates) |
| Install | `apk add`, elevated with sudo when necessary |
| Pin syntax | native `name=version` |
| `apply --update` | adds `--update-cache` |
| `upgrade` | `apk upgrade --available --update-cache` for configured packages already installed |

A pinned entry shows as `version mismatch` in `packages status` when a different version is installed; `apply` passes the pin to apk to correct it. `"latest"` entries are satisfied by **any** installed version — use `upgrade` to move them forward ([apk](https://mise.jdx.dev/bootstrap/packages/apk.html)).

#### 5.6.2 apt (Debian family)

```toml
[bootstrap.packages]
"apt:libssl-dev" = "latest"
"apt:curl" = "8.5.0-2ubuntu10" # version pin
"apt:gcc:arm64" = "latest"     # architecture qualifier
```

| Operation | Command |
| --- | --- |
| State check | `dpkg-query` (read-only, never elevates) |
| Install | `apt-get install -y`, sudo when necessary, with `DEBIAN_FRONTEND=noninteractive` so installs never block on configuration prompts |
| Pin syntax | native `name=version`; `name:arch` qualifiers pass through in the package name |
| `upgrade` | `apt-get update` then `apt-get install --only-upgrade` for configured packages, so nothing new is pulled in |

**Metadata refresh gotcha:** if `/var/lib/apt/lists` contains no package lists (fresh containers), mise runs `apt-get update` automatically before installing. Otherwise it does **not** touch apt metadata — if an install fails with "Unable to locate package", run `mise bootstrap packages apply --update` ([apt](https://mise.jdx.dev/bootstrap/packages/apt.html)).

#### 5.6.3 dnf (RedHat family)

```toml
[bootstrap.packages]
"dnf:openssl-devel" = "latest"
"dnf:postgresql-server" = "latest"
"dnf:bash" = "5.2.26-3.fc40" # version or version-release pin
```

| Operation | Command |
| --- | --- |
| State check | `rpm -q` (read-only, never elevates) |
| Install | `dnf install -y`, sudo when necessary |
| Pin syntax | native `name-version` / `name-version-release`; a version-only pin is satisfied by any release of that version |
| `apply --update` | adds `--refresh`; otherwise dnf manages its own metadata expiry |
| `upgrade` | `dnf upgrade -y --refresh` for configured packages — only already-installed packages are touched |

Only `dnf` is supported — **not legacy `yum`-only systems**. On RHEL/CentOS 8+ and all current Fedora releases `dnf` is the default ([dnf](https://mise.jdx.dev/bootstrap/packages/dnf.html)).

#### 5.6.4 pacman (Arch family)

```toml
[bootstrap.packages]
"pacman:openssl" = "latest"
"pacman:base-devel" = "latest"
```

| Operation | Command |
| --- | --- |
| State check | `pacman -Q` (read-only, never elevates) |
| Install | `pacman -S --noconfirm --needed`, sudo when necessary. `--needed` makes installs idempotent |
| Metadata | If `/var/lib/pacman/sync` has no databases (fresh containers), mise runs `pacman -Sy` automatically. Force with `apply --update` |
| `upgrade` | `pacman -Sy` then upgrades only the configured packages |

> **Warning (from the docs):** Arch repositories only carry the latest version of each package, so pacman entries **cannot** be installed at a pinned version — `apply` skips pinned entries with a warning, though `status` still reports a `version mismatch` for them. **AUR packages are not supported** (they require an AUR helper and building from source). Also: Arch officially supports only full-system upgrades (`pacman -Syu`); upgrading individual packages is a [partial upgrade](https://wiki.archlinux.org/title/System_maintenance#Partial_upgrades_are_unsupported), so prefer running `pacman -Syu` yourself on a rolling-release system ([pacman](https://mise.jdx.dev/bootstrap/packages/pacman.html)).

#### 5.6.5 brew and brew-cask (no Homebrew required)

```toml
[bootstrap.packages]
"brew:postgresql@17" = "latest"
"brew:ffmpeg" = "latest"
"brew:imagemagick" = "latest"
"brew-cask:firefox" = "latest"
```

mise installs [homebrew/core](https://formulae.brew.sh) formulae **directly into the canonical Homebrew prefix**, fetching metadata from the formulae.brew.sh API, resolving the runtime dependency closure, downloading prebuilt bottles from ghcr.io (verifying sha256), and performing the same relocation, code-signing, and linking work `brew` does when pouring a bottle. **mise never shells out to `brew` for homebrew/core formulae** ([packages/brew](https://mise.jdx.dev/bootstrap/packages/brew.html)).

| Platform | Prefix |
| --- | --- |
| macOS arm64 (Apple Silicon) | `/opt/homebrew` |
| Linux x86_64 | `/home/linuxbrew/.linuxbrew` |
| Linux arm64 | `/home/linuxbrew/.linuxbrew` |

**Intel Macs are not supported** — the `brew` manager reports itself unavailable there. On Linux, formulae without a bottle for your architecture are built from source ([packages/brew](https://mise.jdx.dev/bootstrap/packages/brew.html)).

Rationale for existing at all: "shared-library packages — postgres, ffmpeg, imagemagick, php — fundamentally can't be served by mise's per-project backends like `aqua:` or `github:`: their bottles are built against fixed install paths and a shared dependency tree." ([packages/brew](https://mise.jdx.dev/bootstrap/packages/brew.html))

##### Taps

Third-party taps work directly when the tap publishes Homebrew API metadata (`api/formula/<name>.json` or `api/cask/<token>.json`). Use the fully-qualified name:

```toml
[bootstrap.packages]
"brew:railwaycat/emacsmacport/emacs-mac" = "latest"
"brew-cask:owner/tap/app" = "latest"
```

For taps whose GitHub URL cannot be inferred, add a tap source — this mirrors `[plugins]`: key is the tap name, value is the GitHub git URL:

```toml
[bootstrap.brew.taps]
"acme/tools" = "https://github.com/acme/homebrew-tools.git"

[bootstrap.packages]
"brew:acme/tools/widget" = "latest"
"brew-cask:acme/tools/widget-app" = "latest"
```

```sh
mise bootstrap packages brew tap railwaycat/emacsmacport
mise bootstrap packages brew tap acme/tools https://github.com/acme/homebrew-tools.git
mise bootstrap packages brew untap acme/tools
```

`tap`/`untap` manage `[bootstrap.brew.taps]` in `mise.toml`; **they do not mutate a Homebrew installation**. Non-GitHub taps are not currently supported because mise needs direct raw access to the generated API metadata ([packages/brew](https://mise.jdx.dev/bootstrap/packages/brew.html)).

##### Casks

Casks use the `brew-cask:` manager. mise fetches cask metadata from the Homebrew cask API (or tap API metadata), downloads the artifact, verifies its sha256 when provided, extracts the archive, installs app bundles into `/Applications`, and records the version under `<prefix>/Caskroom` ([packages/brew](https://mise.jdx.dev/bootstrap/packages/brew.html)).

```toml
[bootstrap.packages]
"brew-cask:firefox" = "latest"
"brew-cask:homebrew/cask/visual-studio-code" = "latest"
```

| Cask capability | Support |
| --- | --- |
| `app` artifacts (app bundles) | Supported |
| `binary`, `command_wrapper` artifacts | Supported — staged in the Caskroom and linked into the Homebrew prefix, usually under `<prefix>/bin` |
| `pkg` artifacts (simple macOS installers) | Supported. Run through mise's normal system-package sudo path so non-interactive runs never hang. **Must include `pkgutil` receipt IDs in `uninstall` metadata** so mise can verify installed state; `zap` `pkgutil` IDs are treated as cleanup metadata, not install receipts |
| Completions (`bash_completion`, `fish_completion`, `zsh_completion`, `generate_completions_from_executable`) | Supported from dmg and common archive formats |
| `preflight`/`postflight` hooks | mise fetches the sha256-verified cask Ruby source pinned by API metadata and runs supported hooks through its own Cask DSL shim, without delegating to Homebrew |
| Structured `preflight_steps`/`postflight_steps` | Supported for `move`/`remove` against `staged_path` and `run` using Homebrew's serialized command bases, arguments, environment, guards, and sudo setting |
| Custom installer choices, services, unsupported hook DSL, other artifact types | **Fail with a clear unsupported-artifact error** instead of delegating to Homebrew |

##### Coexistence with a real Homebrew

- mise pours bottles into the Cellar exactly the way brew does and writes brew-compatible `INSTALL_RECEIPT.json` files into every keg. `brew list`, `brew upgrade`, and `brew uninstall` all work on mise-poured kegs.
- Conversely, mise's status checks read the Cellar directly, so formulae installed by brew count as installed.
- For non-keg-only formulae, mise maintains Homebrew's `<prefix>/var/homebrew/linked/<name>` record alongside the `opt` record. For a configured formula, if either record is missing, `apply` restores it **without repouring the keg or replacing its public links**. Older mise installs are recognised as linked only when their existing public links match the keg's layout. Dependency-closure migration is not performed.
- mise **never overwrites files in the prefix that it didn't create** — link conflicts fail with a list of the offending files rather than clobbering them.

([packages/brew](https://mise.jdx.dev/bootstrap/packages/brew.html))

##### How pouring works

1. **Fetch** the bottle for your platform from ghcr.io and verify its sha256 against the API metadata.
2. **Extract** into a temporary directory inside the Cellar (incomplete pours are never visible as installed packages).
3. **Relocate** — bottles embed placeholders like `@@HOMEBREW_PREFIX@@`; mise rewrites them: plain replacement in text files, in-place and load-command rewriting in Mach-O binaries (growing load commands into header padding, as brew's ruby-macho does). On Linux the ELF interpreter and rpath are patched the way brew's PatchELF gem does: over-long strings move into a new appended segment, and the interpreter points at `<prefix>/lib/ld.so` (a symlink mise maintains to the system loader, or to a brewed glibc).
4. **Re-sign** (macOS) — modified binaries are ad-hoc re-signed with `codesign`, required on arm64.
5. **Receipt** — a brew-compatible `INSTALL_RECEIPT.json` is written.
6. **Link** — `<prefix>/opt/<name>` is created and `bin`, `lib`, `include`, `share`, etc. are symlinked into the prefix; the linked-keg record is created for non-keg-only formulae. [keg-only](https://docs.brew.sh/FAQ#what-does-keg-only-mean) formulae get the `opt` link but are not linked into the prefix, same as brew.

([packages/brew](https://mise.jdx.dev/bootstrap/packages/brew.html))

##### Source formulae

Formulae with no usable bottle are built from source, still without Homebrew: mise provisions a mise-managed **ruby**; downloads the formula `.rb` from homebrew/core **pinned to the exact commit the API metadata was generated from** and verified against the API's sha256; downloads and verifies the stable source archive; adds build dependencies (cmake, pkgconf, …) to the install closure and pours them as bottles first; then evaluates the formula with mise's own Formula-DSL shim and runs `def install` against the canonical prefix with `PATH`, `PKG_CONFIG_PATH`, and compiler flags pointing at the dependency kegs. The keg gets the same brew-compatible receipt with `poured_from_bottle: false` ([packages/brew](https://mise.jdx.dev/bootstrap/packages/brew.html)).

The shim implements the commonly-used subset of the formula DSL (configure/cmake/meson-style builds, resources, patches, standard path and environment helpers). Formulae using language-specific helpers like `virtualenv_install_with_resources`, VCS downloads, and similar **fail with a clear `formula uses ...` error** rather than miscompiling silently. Source builds need a working toolchain (Xcode CLT on macOS, gcc/make on Linux).

##### brew limitations

| Limitation | Detail |
| --- | --- |
| Cask artifact coverage is intentionally narrow | Other artifact types, pkg installers without `pkgutil` IDs, and pkg installers with custom choices fail explicitly |
| `brew services` | **Not implemented** |
| Cask import/prune | **Not implemented** — formulae-only until cask uninstall semantics can be made safe |
| Source builds | Cover common formula shapes only |
| Canonical names required | `postgresql@17` is a **formula name, not a mise version pin** — the API's current stable version decides what gets installed. Aliases (`postgres`) install correctly but `status` can't track them; mise warns and tells you the canonical name |
| `PATH` | `<prefix>/bin` must be on `PATH` to use linked binaries, just like with Homebrew itself |

([packages/brew](https://mise.jdx.dev/bootstrap/packages/brew.html))

#### 5.6.6 flatpak

```toml
[bootstrap.packages]
"flatpak:org.mozilla.firefox" = "latest"
"flatpak:org.gnome.Builder" = "latest"
```

The package name is an application or runtime ID accepted by `flatpak install` and `flatpak update`. **mise does not install Flatpak or configure remotes implicitly** — install the CLI and add the remote first ([flatpak](https://mise.jdx.dev/bootstrap/packages/flatpak.html)):

```sh
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
mise bootstrap packages use flatpak:org.mozilla.firefox
```

```sh
mise bootstrap packages status --manager flatpak
mise bootstrap packages apply --manager flatpak
mise bootstrap packages upgrade --manager flatpak
```

| Operation | Command |
| --- | --- |
| `apply` | `flatpak install --system --noninteractive <id>` for missing packages |
| `upgrade` | `flatpak update --system --noninteractive <id>` for installed packages |

mise manages the **system-wide** Flatpak installation. Version pins are **not supported** — use `"latest"`. Linux-only, requires `flatpak` on `PATH`; elsewhere shared configs list Flatpak entries as skipped ([flatpak](https://mise.jdx.dev/bootstrap/packages/flatpak.html)).

> **Uncertainty:** the flatpak page shows `mise bootstrap packages status --manager flatpak`, but the documented flags for `mise bootstrap packages status` are only `-J/--json` and `--missing` ([cli/bootstrap/packages/status](https://mise.jdx.dev/cli/bootstrap/packages/status.html)). Whether `status` accepts `--manager` is not settled by the CLI reference.

#### 5.6.7 mas (Mac App Store)

```toml
[bootstrap.packages]
"brew:mas" = "latest"
"mas:497799835" = "latest"       # Xcode
```

The package name is the App Store app ID: a **numeric ADAM ID** accepted by `mas install` and `mas upgrade`. Bundle identifiers such as `com.apple.dt.Xcode` are **not valid** package names ([mas](https://mise.jdx.dev/bootstrap/packages/mas.html)).

mise does not install `mas` implicitly. Install it via the built-in brew manager (`"brew:mas" = "latest"`) or as a normal mise tool:

```sh
mise use -g mas
```

```sh
mise bootstrap packages use mas:497799835
mise bootstrap packages status
mise bootstrap packages apply --manager mas
mise bootstrap packages upgrade --manager mas
```

| Operation | Command |
| --- | --- |
| `apply` | `mas install <id>` for missing apps |
| `upgrade` | `mas upgrade <id>` for installed apps |

**Caveats:** macOS-only and must be on `PATH`. On other platforms, or when `mas` is missing, shared configs list the entries as **skipped** instead of failing — but explicit commands such as `mise bootstrap packages apply --manager mas` still **fail** when `mas` is unavailable, matching other managers. Mac App Store operations may require an Apple Account signed in to the App Store, macOS authentication, prior purchase/claiming for paid apps, and valid Spotlight indexing; mise surfaces `mas` errors rather than trying to purchase or claim apps itself ([mas](https://mise.jdx.dev/bootstrap/packages/mas.html)).

Finding IDs: `mas search xcode`, or take the numeric part of the App Store URL (`id497799835` → `"mas:497799835"`).

#### 5.6.8 Package manager plugins (`[bootstrap.plugins]`)

Plugins extend `[bootstrap.packages]` without adding a manager to mise core — useful for machine-global state owned by another tool: VS Code extensions, Helm plugins, krew plugins, GitHub CLI extensions ([packages/plugins](https://mise.jdx.dev/bootstrap/packages/plugins.html)).

```toml
[bootstrap.plugins]
vscode = "https://github.com/mise-plugins/mise-vscode-extensions"
krew = "https://github.com/mise-plugins/mise-krew"

[bootstrap.packages]
"vscode:ms-python.python" = "latest"
"krew:ctx" = "latest"
```

```sh
mise bootstrap plugins status
mise bootstrap plugins status --missing
mise bootstrap plugins apply
mise bootstrap plugins apply --dry-run
mise bootstrap packages status
mise bootstrap packages apply
```

Install a plugin without declaring it:

```sh
mise plugin install package:vscode https://github.com/mise-plugins/mise-vscode-extensions
```

| Plugin semantic | Detail |
| --- | --- |
| Ordering | `mise bootstrap` installs declared plugins **first**, applies built-in managers, installs `[tools]`, **then** applies plugin managers — so a plugin can depend on a host command (`code`, `helm`, `kubectl`, `gh`) provided by `[tools]` |
| Install location | The host application's own state directory. No mise installs, no shims |
| sudo | Never elevate; not affected by `system_packages.sudo` |
| `system_packages.managers` | Name-based; can include/exclude plugin managers just like built-ins |
| Removal/pruning | **Not supported in the first version of this API.** Removing a config entry does not uninstall host-managed state |

CLI flags: `mise bootstrap plugins apply [-n --dry-run]`; `mise bootstrap plugins status [--missing]` ([cli/bootstrap/plugins/apply](https://mise.jdx.dev/cli/bootstrap/plugins/apply.html), [cli/bootstrap/plugins/status](https://mise.jdx.dev/cli/bootstrap/plugins/status.html)). See [Package Plugin Development](https://mise.jdx.dev/package-plugin-development.html) to create one.

#### 5.6.9 Package commands

```sh
mise bootstrap packages status            # table of requested vs installed packages
mise bootstrap packages status --json     # machine-readable
mise bootstrap packages status --missing  # exit 1 if anything is out of sync (CI check)

mise bootstrap packages apply           # install whatever is missing (prompts first)
mise bootstrap packages apply apt:curl  # install specific packages (configured or not)
mise bootstrap packages apply --dry-run # print the commands without running them
mise bootstrap packages apply --yes     # skip the confirmation prompt
mise bootstrap packages apply --manager apt
mise bootstrap packages apply --update  # refresh package manager metadata first

mise bootstrap packages use apk:zlib-dev apt:curl brew:jq brew-cask:firefox flatpak:org.mozilla.firefox mas:497799835
mise bootstrap packages use -g brew:ffmpeg     # write globally
mise bootstrap packages use apt:curl@8.5.0-2   # pin a version

mise bootstrap packages import --manager brew   # add installed requested brew formulae
mise bootstrap packages import --manager brew --all
mise bootstrap packages import --manager brew --dry-run

mise bootstrap packages prune --manager brew    # remove unneeded linked brew formulae
mise bootstrap packages prune --manager brew --dry-run
mise bootstrap packages prune --manager brew --yes

mise bootstrap packages upgrade           # upgrade installed packages to current versions
mise bootstrap packages upgrade --manager brew
mise bootstrap packages upgrade --manager brew-cask
mise bootstrap packages upgrade --manager flatpak
mise bootstrap packages upgrade --manager mas
```

([packages](https://mise.jdx.dev/bootstrap/packages/))

**`mise bootstrap packages apply [FLAGS] [PACKAGE]…`** — aliases `i`, and `install` is accepted as an alias for the command. Packages may be given explicitly in `manager:package` form and are installed **whether or not they appear in the config**. Explicit packages and `--manager` scope the run to packages only.

| Flag | Meaning |
| --- | --- |
| `-m`, `--manager <MANAGER>` | Only install packages for this built-in or plugin manager |
| `-n`, `--dry-run` | Print the commands that would run without running them |
| `-y`, `--yes` | Skip the confirmation prompt |
| `--update` | Refresh package manager metadata first (apk `--update-cache`, apt `apt-get update`) |

```sh
mise bootstrap packages apply
mise bootstrap packages apply apk:zlib-dev apt:curl brew:jq brew-cask:firefox flatpak:org.mozilla.firefox mas:497799835
mise bootstrap packages apply --dry-run
mise bootstrap packages apply --manager apt --yes
```

([cli/bootstrap/packages/apply](https://mise.jdx.dev/cli/bootstrap/packages/apply.html))

**`mise bootstrap packages status [-J --json] [--missing]`** — alias `ls`, read-only.

```sh
mise bootstrap packages status
mise bootstrap packages status --json
mise bootstrap packages status --missing # exit 1 if anything is out of sync
```

([cli/bootstrap/packages/status](https://mise.jdx.dev/cli/bootstrap/packages/status.html))

**`mise bootstrap packages use [FLAGS] <PACKAGE>…`** — alias `u`. "Like `mise use` for tools": writes `"manager:package" = "version"` entries to mise.toml (local by default, global with `-g`) and installs whatever is missing. Entries for managers that aren't available on the current machine are **written without installing** — that's how a shared config picks up `apt:` lines authored on a Mac.

| Flag | Meaning |
| --- | --- |
| `-e`, `--env <ENV>` | Write to the config file for this environment (`mise.<ENV>.toml`) |
| `-g`, `--global` | Write to `~/.config/mise/config.toml` instead of the local config |
| `-n`, `--dry-run` | Print the commands that would run without writing config or installing |
| `-p`, `--path <PATH>` | Write to this config file or directory |
| `-y`, `--yes` | Skip the confirmation prompt |

Pin syntax: versions are pinned with `@` (`apt:curl@8.5.0-2`). Without `@` (or with `@latest`) no pin is written. **brew formulae and casks version through their names instead** (`brew:postgresql@17`, `brew-cask:temurin@17`), where `@` is part of the Homebrew name rather than a mise version selector. mas uses numeric ADAM IDs and does not support pins.

```sh
mise bootstrap packages use apk:zlib-dev apt:curl brew:jq brew-cask:firefox flatpak:org.mozilla.firefox mas:497799835
mise bootstrap packages use -g brew:postgresql@17
mise bootstrap packages use apt:curl@8.5.0-2
```

([cli/bootstrap/packages/use](https://mise.jdx.dev/cli/bootstrap/packages/use.html))

**`mise bootstrap packages import [FLAGS]`** — currently **Homebrew formulae only**. Reads the active `opt` links in the Homebrew prefix and writes `"brew:<formula>" = "latest"` entries. By default imports only formulae whose active keg receipt says they were installed **on request**; `--all` includes dependency formulae. Tapped formulae are written with fully-qualified names, and mise adds inferred `[bootstrap.brew.taps]` entries when it can derive the conventional GitHub tap URL. Imported formulae are kept by future prune runs because they are now declared in config.

| Flag | Meaning |
| --- | --- |
| `-e`, `--env <ENV>` | Write to `mise.<ENV>.toml` |
| `-g`, `--global` | Write to the global config |
| `-m`, `--manager <MANAGER>` | Only import for this manager. Choices: `brew`. **Default:** `brew` |
| `--all` | Import every linked formula, including dependencies |
| `-n`, `--dry-run` | Print the config change without writing config |
| `-p`, `--path <PATH>` | Write to this config file or directory |

```sh
mise bootstrap packages import --manager brew
mise bootstrap packages import --manager brew --all
mise bootstrap packages import --manager brew --global
mise bootstrap packages import --manager brew --dry-run
```

([cli/bootstrap/packages/import](https://mise.jdx.dev/cli/bootstrap/packages/import.html), [packages/brew](https://mise.jdx.dev/bootstrap/packages/brew.html))

**`mise bootstrap packages prune [FLAGS]`** — marked **destructive — may delete or irreversibly overwrite**. Currently Homebrew formulae only. Treats the current config **and trusted, loadable tracked configs** as the source of truth, and removes linked formulae that are not in the resolved dependency closure of those configured `brew:` entries — *including formulae installed by a real Homebrew*. Prune removes the active keg, its `opt` and linked-keg records, and prefix symlinks pointing into that keg.

| Flag | Meaning |
| --- | --- |
| `-m`, `--manager <MANAGER>` | Only prune for this manager. Choices: `brew`. **Default:** `brew` |
| `-n`, `--dry-run` | Print what would be removed without deleting anything |
| `-y`, `--yes` | Skip the confirmation prompt |

```sh
mise bootstrap packages prune --manager brew
mise bootstrap packages prune --manager brew --dry-run
mise bootstrap packages prune --manager brew --yes
```

This is mise's declarative cleanup, similar in spirit to [`brew bundle cleanup`](https://docs.brew.sh/Manpage) — **not** the old upstream `brew prune`, which Homebrew removed ([cli/bootstrap/packages/prune](https://mise.jdx.dev/cli/bootstrap/packages/prune.html), [packages/brew](https://mise.jdx.dev/bootstrap/packages/brew.html)).

**`mise bootstrap packages upgrade [FLAGS] [PACKAGE]…`** — alias `up`. Refreshes package manager metadata and upgrades configured packages **that are already installed**; not-yet-installed packages are skipped (that's `apply`'s job).

| Manager | Upgrade behavior |
| --- | --- |
| apk / apt / dnf | Upgrade to newest available; **honor a version pinned in config** |
| pacman, brew, brew-cask, flatpak, mas | Can't install pins → pinned entries are skipped with a warning |
| brew | Pours the formula's current bottle and replaces the old keg (re-resolved against the formulae.brew.sh API); links repointed, the same dance `brew upgrade` does |
| brew-cask | Installs the current cask artifact |
| flatpak | Updates the configured applications and runtimes |
| mas | Runs `mas upgrade` |

| Flag | Meaning |
| --- | --- |
| `-m`, `--manager <MANAGER>` | Only upgrade packages for this built-in or plugin manager |
| `-n`, `--dry-run` | Print the commands that would run without running them |
| `-y`, `--yes` | Skip the confirmation prompt |

```sh
mise bootstrap packages upgrade
mise bootstrap packages upgrade brew:postgresql@17
mise bootstrap packages upgrade --manager brew-cask
mise bootstrap packages upgrade --manager mas
mise bootstrap packages upgrade --manager apt --yes
mise bootstrap packages upgrade --dry-run
```

([cli/bootstrap/packages/upgrade](https://mise.jdx.dev/cli/bootstrap/packages/upgrade.html), [packages](https://mise.jdx.dev/bootstrap/packages/))

**`mise bootstrap packages brew <SUBCOMMAND>`** — "Manage Homebrew taps used by bootstrap packages. These commands edit `[bootstrap.brew.taps]` so tapped formulae and casks can be fetched directly by mise without a Homebrew installation." ([cli/bootstrap/packages/brew](https://mise.jdx.dev/cli/bootstrap/packages/brew.html))

**`mise bootstrap packages brew tap [FLAGS] <TAP> [URL]`** — `<TAP>` is `owner/repo`; `[URL]` defaults to `https://github.com/<owner>/homebrew-<repo>.git`.

| Flag | Meaning |
| --- | --- |
| `-l`, `--local` | Write to the local config instead of the global config |
| `-n`, `--dry-run` | Print the config change without writing it |
| `-p`, `--path <PATH>` | Write to this config file or directory |

```sh
mise bootstrap packages brew tap railwaycat/emacsmacport
mise bootstrap packages brew tap acme/tools https://github.com/acme/homebrew-tools.git
```

([cli/bootstrap/packages/brew/tap](https://mise.jdx.dev/cli/bootstrap/packages/brew/tap.html))

**`mise bootstrap packages brew untap [FLAGS] <TAPS>…`** — aliases `remove`, `rm`. Same flags (`-l/--local`, `-n/--dry-run`, `-p/--path <PATH>`).

```sh
mise bootstrap packages brew untap railwaycat/emacsmacport
```

([cli/bootstrap/packages/brew/untap](https://mise.jdx.dev/cli/bootstrap/packages/brew/untap.html))

#### CI usage

In containers you're typically already root, so no prompts occur ([packages#ci-usage](https://mise.jdx.dev/bootstrap/packages/)):

```sh
mise bootstrap packages apply --yes
mise install
```

`mise bootstrap --yes` combines both (and runs a `bootstrap` task afterwards, if defined). `mise bootstrap packages status --missing` exits 1 when packages are missing — a convenient CI check that installs nothing. `mise doctor` also reports configured system packages and warns when any are missing.

### 5.7 Git repos (`[bootstrap.repos]`)

```toml
[bootstrap.repos]
"~/src/dotfiles" = { url = "git@github.com:jdx/dotfiles.git", ref = "main" }
"~/src/mise" = { url = "https://github.com/jdx/mise.git" }
```

| Field | Required | Meaning |
| --- | --- | --- |
| key (target path) | yes | Absolute, `~/`-prefixed, or relative |
| `url` | **yes** | Clone URL |
| `ref` | no | Branch, tag, or full commit SHA |

**Relative target paths** are resolved against the *project root of the config file that declares them* and must name a directory inside it — they cannot be empty or `.`, and cannot escape the root with `..` or absolute segments. Consequently **relative paths are only valid in a project config, not in a global config** such as `~/.config/mise/config.toml` ([repos](https://mise.jdx.dev/bootstrap/repos.html)).

Ordering matters: repos run **after** `[bootstrap.packages]` and **before** `[dotfiles]`, so a bootstrap config can install `git`, clone a dotfiles repository, and then apply dotfiles from that checkout ([repos](https://mise.jdx.dev/bootstrap/repos.html)).

#### Semantics

| Rule | Detail |
| --- | --- |
| Declarative and path-keyed | Entries merge across the hierarchy by **expanded target path**; a more local config replaces the **full** repo entry for that path |
| Safe updates only | mise clones missing repos or **empty** target directories, and updates existing repos only when the worktree is clean **and** the configured `origin` URL matches |
| URL comparison | Exactly three network URL forms are compared transport-agnostically: `git@host:path`, `ssh://git@host/path`, and `https://host/path` identify the same repo. Different hosts, ssh aliases, explicit ports, paths, or non-`git` ssh users still conflict. Everything else requires an **exact** match: `http://` and `git://` origins (an insecure transport is never silently treated as the https config), ssh origins without a user (git resolves those to the login user, not `git`), URLs carrying a query string, local paths, and `file://` URLs |
| No implicit writes | Repos change only via explicit `apply`, `update`, `exec`, or top-level `mise bootstrap`. **Applying never pulls an existing repo without a configured `ref`** — use `repos update` for that imperative behavior |
| No forced resets | Dirty repos, non-empty non-git target paths, and mismatched origins **fail** instead of overwriting local work |
| Omitted `ref` | An existing repo with the expected origin is considered **current**; mise does not fetch or update it |

([repos](https://mise.jdx.dev/bootstrap/repos.html))

#### States

| State | Meaning |
| --- | --- |
| `current` | repo exists, origin matches, and ref matches |
| `missing` | target path does not exist or is empty |
| `differs` | repo is clean but not at the configured ref |
| `dirty` | repo has local changes or untracked files |
| `conflict` | target path is not the expected git repo |

([repos](https://mise.jdx.dev/bootstrap/repos.html))

#### Repos commands

```sh
mise bootstrap repos status            # shows repo checkout state
mise bootstrap repos status --json     # machine-readable
mise bootstrap repos status --missing  # exit 1 if any repo is not current

mise bootstrap repos apply           # clone or update missing/changed repos
mise bootstrap repos apply --dry-run # print the commands without running them
mise bootstrap repos apply --yes     # skip the confirmation prompt

mise bootstrap repos update             # clone missing and pull existing repos
mise bootstrap repos update ~/src/mise  # update only a matching path
mise bootstrap repos update --dry-run   # print the commands without running them
mise bootstrap repos update --yes       # skip the confirmation prompt

mise bootstrap repos exec -- git status        # run argv in every usable repo
mise bootstrap repos exec ~/src/mise -- git pull
mise bootstrap repos exec --continue-on-error -- command
mise bootstrap repos exec --dry-run -- command
```

| Command | Usage / flags |
| --- | --- |
| `mise bootstrap repos apply` | `[-n --dry-run] [-y --yes]` |
| `mise bootstrap repos status` | `[-J --json] [--missing]` (read-only) |
| `mise bootstrap repos update` | `[-n --dry-run] [-y --yes] [PATH]…` |
| `mise bootstrap repos exec` | `[-c --continue-on-error] [-n --dry-run] [PATH]… <-- COMMAND>…` |

([cli/bootstrap/repos/apply](https://mise.jdx.dev/cli/bootstrap/repos/apply.html), [status](https://mise.jdx.dev/cli/bootstrap/repos/status.html), [update](https://mise.jdx.dev/cli/bootstrap/repos/update.html), [exec](https://mise.jdx.dev/cli/bootstrap/repos/exec.html))

- **`update`** fetches and fast-forward pulls the current branch of repos **without a configured `ref`**. It warns and skips an unpinned repo with a **detached HEAD**. Dirty repos, conflicting origins, and non-git targets fail *before any repo is changed*. Passing one or more paths limits the update to exact configured paths or their expanded forms ([repos](https://mise.jdx.dev/bootstrap/repos.html)).
- **`exec`** runs the command **directly, without shell interpolation**, with each repo as the working directory. Missing and conflicting repos are skipped with a warning. It stops on the first command failure unless `--continue-on-error` is set; in that mode it visits every usable repo and reports all failures at the end ([repos](https://mise.jdx.dev/bootstrap/repos.html)).

### 5.8 Shell activation (`[bootstrap.mise_shell_activate]`)

```toml
[bootstrap.mise_shell_activate]
zprofile = "shims"
zshrc = "activate"
bash_profile = "shims"
bashrc = "activate"
fish = "activate"
```

Compact table form, for a shape that can accept future options:

```toml
[bootstrap.mise_shell_activate]
zprofile = {enabled = true, mode = "shims"}
zshrc = {enabled = true, mode = "activate"}
```

**Shell keys are shortcuts:** `zsh = true` expands to `zprofile = "shims"` and `zshrc = "activate"`. Any target can use either `"activate"` or `"shims"`; boolean `true` enables the target with its default mode and `false` disables it ([shell](https://mise.jdx.dev/bootstrap/shell.html)).

| Target | Shell | Default mode | Target file | Block written |
| --- | --- | --- | --- | --- |
| `bash_profile` | bash | shims | `~/.bash_profile` | `eval "$(mise activate bash --shims)"` |
| `bashrc` | bash | activate | `~/.bashrc` | `eval "$(mise activate bash)"` |
| `zprofile` | zsh | shims | `~/.zprofile` | `eval "$(mise activate zsh --shims)"` |
| `zshrc` | zsh | activate | `~/.zshrc` | `eval "$(mise activate zsh)"` |
| `zshenv` | zsh | shims | `~/.zshenv` | `eval "$(mise activate zsh --shims)"` |
| `fish` | fish | activate | `~/.config/fish/config.fish` | `mise activate fish \| source` |

([shell](https://mise.jdx.dev/bootstrap/shell.html))

The markers are the same edit markers used by `[dotfiles]`:

```sh
# >>> mise:activate >>> managed by mise - do not edit between markers
eval "$(mise activate zsh)"
# <<< mise:activate <<<
```

#### Semantics

| Rule | Detail |
| --- | --- |
| Per-target override | A project config can override a global setting for one startup file with `zshrc = false` without changing `zprofile` |
| Manual application only | mise never edits shell rc files implicitly; only `mise bootstrap mise-shell-activate apply` and `mise bootstrap` |
| Marker-owned edits | mise owns only the block between its markers; other content is untouched |
| `zshenv` opt-in | Shims stay out of `zshenv` by default — it is supported when configured explicitly, but shell shortcuts do not write it because zsh reads it for **every** invocation, including scripts |
| Explicit dotfiles win | If `[dotfiles]` already manages the same rc file as a whole file, or defines an edit for the same target/id such as `"~/.zshrc/activate"`, mise **skips** the generated shell activation entry for that shell |

For fully managed rc files or custom activation blocks, use `[dotfiles]` directly instead ([shell](https://mise.jdx.dev/bootstrap/shell.html)).

#### Commands

```sh
mise bootstrap mise-shell-activate status            # shows activation block state
mise bootstrap mise-shell-activate status --json     # machine-readable
mise bootstrap mise-shell-activate status --missing  # exit 1 if anything is out of sync

mise bootstrap mise-shell-activate apply           # writes missing/different blocks
mise bootstrap mise-shell-activate apply --dry-run # print the edits instead
mise bootstrap mise-shell-activate apply --yes     # skip the confirmation prompt
```

`apply` takes `[-n --dry-run] [-y --yes]`; `status` takes `[-J --json] [--missing]` ([cli/bootstrap/mise-shell-activate/apply](https://mise.jdx.dev/cli/bootstrap/mise-shell-activate/apply.html), [status](https://mise.jdx.dev/cli/bootstrap/mise-shell-activate/status.html)).

**JSON schema:** status entries include `target`, `shell`, `path`, `mode`, and `state`, where `state` is `"missing" | "applied" | "differs" | "source_missing"`. Entries with `state = "differs"` also include a `reason` field ([shell](https://mise.jdx.dev/bootstrap/shell.html)).

### 5.9 macOS defaults (`[bootstrap.macos.*]`)

```toml
[bootstrap.macos.dock]
autohide = true
orientation = "left"
tilesize = 48
show_recents = false

[bootstrap.macos.finder]
show_all_files = true
show_pathbar = true
preferred_view_style = "list"

[bootstrap.macos.keyboard]
key_repeat = 2
initial_key_repeat = 15
press_and_hold = false

[bootstrap.macos.trackpad]
tap_to_click = true

[bootstrap.macos.defaults]
"com.apple.finder" = { AppleShowAllFiles = true }
```

The curated sections **compile to raw defaults entries**. Precedence: *within the same config file*, raw defaults override the raw `(domain, key)` generated by a friendly setting. *Across* config files, normal global → local precedence applies, so a local friendly setting can override a global raw default for the same pair ([macos-defaults](https://mise.jdx.dev/bootstrap/macos-defaults.html)).

#### Friendly sections

`[bootstrap.macos.dock]`:

| Key | Raw default |
| --- | --- |
| `autohide` | `com.apple.dock.autohide` |
| `orientation` | `com.apple.dock.orientation` (must be `bottom`, `left`, or `right`) |
| `tilesize` | `com.apple.dock.tilesize` |
| `magnification` | `com.apple.dock.magnification` |
| `largesize` | `com.apple.dock.largesize` |
| `show_recents` | `com.apple.dock.show-recents` |
| `mru_spaces` | `com.apple.dock.mru-spaces` |

`[bootstrap.macos.finder]`:

| Key | Raw default |
| --- | --- |
| `show_all_files` | `com.apple.finder.AppleShowAllFiles` |
| `show_pathbar` | `com.apple.finder.ShowPathbar` |
| `show_status_bar` | `com.apple.finder.ShowStatusBar` |
| `show_extensions_warning` | `com.apple.finder.FXEnableExtensionChangeWarning` |
| `preferred_view_style` | `com.apple.finder.FXPreferredViewStyle` (must be `icon`, `list`, `column`, or `gallery`) |

`[bootstrap.macos.keyboard]`:

| Key | Raw default |
| --- | --- |
| `key_repeat` | `NSGlobalDomain.KeyRepeat` |
| `initial_key_repeat` | `NSGlobalDomain.InitialKeyRepeat` |
| `press_and_hold` | `NSGlobalDomain.ApplePressAndHoldEnabled` |
| `fn_state` | `NSGlobalDomain.com.apple.keyboard.fnState` |

`[bootstrap.macos.trackpad]`:

| Key | Raw defaults (both written) |
| --- | --- |
| `tap_to_click` | `com.apple.AppleMultitouchTrackpad.Clicking`, `com.apple.driver.AppleBluetoothMultitouch.trackpad.Clicking` |
| `three_finger_drag` | `com.apple.AppleMultitouchTrackpad.TrackpadThreeFingerDrag`, `com.apple.driver.AppleBluetoothMultitouch.trackpad.TrackpadThreeFingerDrag` |

Unknown friendly keys, invalid enum values, and unsupported value types **warn and are ignored** ([macos-defaults](https://mise.jdx.dev/bootstrap/macos-defaults.html)).

#### Raw defaults typing

Each key under `[bootstrap.macos.defaults]` is a preferences domain (quote domains containing dots). Values map to the matching `defaults write` type:

| TOML value | Written as | Example |
| --- | --- | --- |
| boolean | `-bool true/false` | `autohide = true` |
| integer | `-int <n>` | `tilesize = 48` |
| float | `-float <n>` | `scale = 1.5` |
| string | `-string <s>` | `orientation = "left"` |

Other plist shapes (arrays, dicts, dates, data) are **not supported**; entries using them parse fine but are skipped with a warning, so configs written for newer mise versions still work ([macos-defaults](https://mise.jdx.dev/bootstrap/macos-defaults.html)).

#### Semantics

| Rule | Detail |
| --- | --- |
| Declarative and additive | `(domain, key)` pairs merge global → project as a **union**; a local config can override a pair's value but **cannot remove it. mise never deletes a default** |
| OS-filtered | On non-macOS the section is inert: `macos defaults status` and `mise doctor` list entries as **skipped**; `apply` ignores them |
| Manual application only | Only `mise bootstrap macos defaults apply` writes defaults, after the usual confirmation prompt |
| **Strictly typed** | An existing value counts as in sync only when **both value and plist type match** — an integer `1` does not satisfy a configured `true`. `apply` converges it to the typed value |
| No sudo, ever | User defaults are per-user. Host-scoped preferences (`defaults -currentHost`) and `sudo defaults` system domains are **not supported** |

([macos-defaults](https://mise.jdx.dev/bootstrap/macos-defaults.html))

#### Status states and app restarts

`status` reports each entry as `set` (matches), `differs` (a value exists but doesn't match — the current value is shown), or `unset`. `mise doctor` summarizes the same drift ([macos-defaults](https://mise.jdx.dev/bootstrap/macos-defaults.html)).

Some applications only pick up changed defaults after a relaunch — mise prints a reminder after writing, and top-level `mise bootstrap` includes the same reminder in its final follow-up summary. **mise deliberately does not kill applications itself.** The usual suspects:

```sh
killall Dock
killall Finder
killall SystemUIServer
```

A `post-defaults` hook is the documented way to automate it:

```toml
[bootstrap.hooks]
post-defaults = "killall Dock || true"
```

([macos-defaults](https://mise.jdx.dev/bootstrap/macos-defaults.html), [bootstrap](https://mise.jdx.dev/bootstrap.html))

#### Finding keys

```sh
defaults read com.apple.dock
defaults read-type com.apple.dock tilesize
```

Change a setting in System Settings and diff `defaults read` before and after ([macos-defaults](https://mise.jdx.dev/bootstrap/macos-defaults.html)).

#### Commands

```sh
mise bootstrap macos defaults status            # shows defaults drift
mise bootstrap macos defaults status --missing  # exit 1 if anything is unset or differs
mise bootstrap macos defaults status --json

mise bootstrap macos defaults apply           # writes unset/differing defaults
mise bootstrap macos defaults apply --dry-run # print the `defaults write` commands
mise bootstrap macos defaults apply --yes     # skip the confirmation prompt
```

`apply` takes `[-n --dry-run] [-y --yes]`; `status` takes `[-J --json] [--missing]` ([cli/bootstrap/macos/defaults/apply](https://mise.jdx.dev/cli/bootstrap/macos/defaults/apply.html), [status](https://mise.jdx.dev/cli/bootstrap/macos/defaults/status.html)).

### 5.10 launchd agents (`[bootstrap.macos.launchd.agents]`)

```toml
[bootstrap.macos.launchd.agents.my-sync]
program = "~/.local/bin/my-sync"
args = ["--watch"]
run_at_load = true
start_calendar_interval = { hour = 2, minute = 0 }
environment = { PATH = "/opt/homebrew/bin:/usr/bin:/bin" }
working_directory = "~"
stdout_path = "~/Library/Logs/my-sync.log"
stderr_path = "~/Library/Logs/my-sync.err.log"
```

Each agent is written to `~/Library/LaunchAgents/dev.mise.<name>.plist` and loaded with:

```sh
launchctl bootstrap gui/$UID ~/Library/LaunchAgents/dev.mise.<name>.plist
```

Agent names may contain letters, numbers, `.`, `_`, and `-`. **mise owns only the plist files it creates with the `dev.mise.` label prefix** ([launchd](https://mise.jdx.dev/bootstrap/launchd.html)).

#### Supported keys

| TOML key | launchd key |
| --- | --- |
| `program` | `ProgramArguments[0]` |
| `args` | `ProgramArguments[1..]` |
| `run_at_load` | `RunAtLoad` |
| `keep_alive` | `KeepAlive` |
| `start_interval` | `StartInterval` |
| `start_calendar_interval` | `StartCalendarInterval` |
| `environment` | `EnvironmentVariables` |
| `working_directory` | `WorkingDirectory` |
| `stdout_path` | `StandardOutPath` |
| `stderr_path` | `StandardErrorPath` |
| `kickstart` | run `launchctl kickstart` |

- `program`, `working_directory`, `stdout_path`, and `stderr_path` expand bare `~` and `~/` to the current user's home before writing the plist. **`args` are passed through exactly as written** (no `~` expansion).
- `start_calendar_interval` accepts `minute` (0–59), `hour` (0–23), `day` (1–31), `weekday` (0–7), and `month` (1–12).
- For multiple independent calendar schedules, use an array of inline tables:

```toml
start_calendar_interval = [{ hour = 3 }, { hour = 12, weekday = 1 }]
```

- `start_interval` and `start_calendar_interval` are **independent** launchd triggers; if both are set, launchd can start the agent from either schedule.

([launchd](https://mise.jdx.dev/bootstrap/launchd.html))

#### Semantics

| Rule | Detail |
| --- | --- |
| Declarative and additive | Agent names merge global → project; a more local config replaces the **full** declaration for the same name |
| macOS-only | Elsewhere the section is inert: `status` lists entries as skipped, `apply` ignores them |
| Manual application only | Only `mise bootstrap macos launchd-agents apply` and `mise bootstrap` write/load agents |
| **User agents only** | mise writes to `~/Library/LaunchAgents`. System daemons in `/Library/LaunchDaemons` are **not supported** |

#### States and apply behavior

`status` reports each agent as `loaded`, `unloaded`, `differs`, or `missing`. `apply` rewrites changed plists, **unloads the old job if present, loads the new job, enables it, and runs `kickstart` only when `kickstart = true`** ([launchd](https://mise.jdx.dev/bootstrap/launchd.html)).

```sh
mise bootstrap macos launchd-agents status            # shows LaunchAgent state
mise bootstrap macos launchd-agents status --json     # machine-readable
mise bootstrap macos launchd-agents status --missing  # exit 1 if any agent is missing, changed, or unloaded

mise bootstrap macos launchd-agents apply           # write and load missing/changed agents
mise bootstrap macos launchd-agents apply --dry-run # print the commands without running them
mise bootstrap macos launchd-agents apply --yes     # skip the confirmation prompt
```

`apply` takes `[-n --dry-run] [-y --yes]`; `status` takes `[-J --json] [--missing]` ([cli/bootstrap/macos/launchd-agents/apply](https://mise.jdx.dev/cli/bootstrap/macos/launchd-agents/apply.html), [status](https://mise.jdx.dev/cli/bootstrap/macos/launchd-agents/status.html)).

### 5.11 systemd user units (`[bootstrap.linux.systemd.units]`)

```toml
[bootstrap.linux.systemd.units.my-sync]
description = "sync files"
exec_start = "~/.local/bin/my-sync --watch"
after = ["network-online.target"]
wants = ["network-online.target"]
environment = { PATH = "/usr/local/bin:/usr/bin:/bin" }
working_directory = "~"
restart = "on-failure"
restart_sec = "5s"
standard_output = "append:%h/.local/state/my-sync.log"
standard_error = "journal"
```

Oneshot and hardened services:

```toml
[bootstrap.linux.systemd.units.daemon-lifecycle]
type = "oneshot"
remain_after_exit = true
exec_start = "~/.local/bin/daemon start"
exec_stop = "~/.local/bin/daemon stop"
timeout_start_sec = "120"
timeout_stop_sec = "30"
no_new_privileges = true
private_tmp = true
```

Timers — **an entry containing a timer key is rendered as a `.timer` instead of a `.service`**:

```toml
[bootstrap.linux.systemd.units.healthcheck-timer]
description = "periodically check daemon health"
on_boot_sec = "2min"
on_unit_inactive_sec = "5min"
randomized_delay_sec = "30s"
persistent = true
unit = "healthcheck"
```

| Timer rule | Detail |
| --- | --- |
| Bare `unit` value (no unit-type suffix) | Resolved to the mise-owned service `dev.mise.<unit>.service` — `unit = "healthcheck"` targets the `healthcheck` service entry |
| Fully-qualified `unit` | Written verbatim, e.g. `unit = "nginx.service"` for an unmanaged unit |
| Minimum trigger | A timer **must** set at least one of `on_boot_sec`, `on_unit_active_sec`, `on_unit_inactive_sec`, or `on_calendar` |
| Service-only keys on a timer | `exec_start`, `environment`, `restart`, etc. are **rejected** on timer entries; use a separate service entry for the triggered unit |

Units are written to `~/.config/systemd/user/dev.mise.<name>.service` or `…dev.mise.<name>.timer` and managed with `systemctl --user`. Unit names may contain letters, numbers, `.`, `_`, `-`, and `@`. mise owns only the unit files it creates with the `dev.mise.` prefix ([systemd](https://mise.jdx.dev/bootstrap/systemd.html)).

#### Supported keys

| TOML key | systemd key |
| --- | --- |
| `description` | `Description` |
| `after` | `After` |
| `wants` | `Wants` |
| `exec_start` | `ExecStart` |
| `type` | `Type` |
| `remain_after_exit` | `RemainAfterExit` |
| `exec_stop` | `ExecStop` |
| `timeout_start_sec` | `TimeoutStartSec` |
| `timeout_stop_sec` | `TimeoutStopSec` |
| `no_new_privileges` | `NoNewPrivileges` |
| `private_tmp` | `PrivateTmp` |
| `environment` | `Environment` |
| `working_directory` | `WorkingDirectory` |
| `restart` | `Restart` |
| `restart_sec` | `RestartSec` |
| `standard_output` | `StandardOutput` |
| `standard_error` | `StandardError` |
| `on_boot_sec` | `OnBootSec` |
| `on_unit_active_sec` | `OnUnitActiveSec` |
| `on_unit_inactive_sec` | `OnUnitInactiveSec` |
| `on_calendar` | `OnCalendar` |
| `randomized_delay_sec` | `RandomizedDelaySec` |
| `accuracy_sec` | `AccuracySec` |
| `persistent` | `Persistent` |
| `unit` | `Unit` |
| `wanted_by` | `WantedBy` |
| `start` | run `systemctl --user restart` |

Defaults and expansion ([systemd](https://mise.jdx.dev/bootstrap/systemd.html)):

| Key | Default / behavior |
| --- | --- |
| `wanted_by` | `["default.target"]` for services, `["timers.target"]` for timers. Set `wanted_by = []` to write the unit and **disable any previous enablement** |
| `start` | `true`. Set `start = false` to write and enable without keeping the unit running |
| `exec_start`, `working_directory` | Bare `~` and `~/` expand to the current user's home before writing |

#### Semantics

| Rule | Detail |
| --- | --- |
| Declarative and additive | Unit names merge global → project; a more local config replaces the **full** declaration for the same name. **When an entry changes between a service and a timer, mise stops, disables, and removes the stale sibling unit** |
| Linux-only | Elsewhere inert: `status` lists entries as skipped, `apply` ignores them |
| **User units only** | mise writes to `~/.config/systemd/user` and uses `systemctl --user`. System services in `/etc/systemd/system` are not supported |
| Target user only | Run mise as the user who owns the services, with a reachable systemd user manager. **`sudo mise` is skipped** because `systemctl --user` would target the wrong user manager |
| Manual application only | Only `mise bootstrap linux systemd-units apply` and `mise bootstrap` write or start units |

#### States and apply behavior

`status` reports each unit as `active`, `inactive`, `differs`, or `missing`. `apply` rewrites changed unit files, runs `systemctl --user daemon-reload`, enables units with `wanted_by`, disables units with `wanted_by = []`, and restarts them when `start = true` or stops them when `start = false` ([systemd](https://mise.jdx.dev/bootstrap/systemd.html)).

```sh
mise bootstrap linux systemd-units status            # shows systemd user service state
mise bootstrap linux systemd-units status --json     # machine-readable
mise bootstrap linux systemd-units status --missing  # exit 1 if any unit is missing, changed, or inactive

mise bootstrap linux systemd-units apply           # write and start missing/changed units
mise bootstrap linux systemd-units apply --dry-run # print the commands without running them
mise bootstrap linux systemd-units apply --yes     # skip the confirmation prompt
```

`apply` takes `[-n --dry-run] [-y --yes]`; `status` takes `[-J --json] [--missing]` ([cli/bootstrap/linux/systemd-units/apply](https://mise.jdx.dev/cli/bootstrap/linux/systemd-units/apply.html), [status](https://mise.jdx.dev/cli/bootstrap/linux/systemd-units/status.html)).

### 5.12 Common workflows

**New machine** ([bootstrap](https://mise.jdx.dev/bootstrap.html)):

```sh
mise trust
mise bootstrap --yes
```

**Add a package** — writes `[bootstrap.packages]` and installs what is missing:

```sh
mise bootstrap packages use apk:zlib-dev apt:libssl-dev
```

**Capture an edited dotfile** — `add` stores the live file under `dotfiles.root` and writes an explicit `[dotfiles]` entry with `mode`:

```sh
$EDITOR ~/.zshrc
mise bootstrap dotfiles add ~/.zshrc
```

**Edit a managed dotfile** — for symlinked dotfiles `edit` opens the managed source, so it works with the default `symlink` mode:

```sh
mise bootstrap dotfiles edit ~/.zshrc
mise bootstrap dotfiles apply ~/.zshrc
```

**Migrate off a Brewfile:**

```sh
mise bootstrap packages import --manager brew --global   # snapshot requested formulae
mise bootstrap packages import --manager brew --all      # ...including dependencies
mise bootstrap packages prune --manager brew --dry-run   # preview the cleanup
```

([bootstrap](https://mise.jdx.dev/bootstrap.html), [packages/brew](https://mise.jdx.dev/bootstrap/packages/brew.html))

### 5.13 `mise generate bootstrap` (unrelated to `mise bootstrap`)

Despite the name, `mise generate bootstrap` is a **different feature**: it generates a script to download+execute mise, "designed to be used in a project where contributors may not have mise installed" ([cli/generate/bootstrap](https://mise.jdx.dev/cli/generate/bootstrap.html)).

* **Usage**: `mise generate bootstrap [FLAGS]`

| Flag | Meaning |
| --- | --- |
| `-l`, `--localize` | Sandbox mise internal directories like `MISE_DATA_DIR` and `MISE_CACHE_DIR` into a `.mise` directory in the project. Necessary if users may use a different version of mise outside the project |
| `-V`, `--version <VERSION>` | Specify mise version to fetch |
| `-w`, `--write <WRITE>` | Instead of outputting the script to stdout, write to a file and make it executable |
| `--localized-dir <LOCALIZED_DIR>` | Directory to put localized data into. **Default:** `.mise` |

```sh
mise generate bootstrap >./bin/mise
chmod +x ./bin/mise
./bin/mise install # automatically downloads mise to .mise if not already installed
```

([cli/generate/bootstrap](https://mise.jdx.dev/cli/generate/bootstrap.html))

### 5.14 CLI reference table

| Command | Aliases | Effect | Flags | Cited |
| --- | --- | --- | --- | --- |
| `mise bootstrap [FLAGS] [SUBCOMMAND]` | `bs` | modifies state | `-n/--dry-run`, `-y/--yes`, `--force-dotfiles`, `--only…`, `--skip…`, `--update` | ([cli/bootstrap](https://mise.jdx.dev/cli/bootstrap.html)) |
| `mise bootstrap status` | `ls` | read-only | `-J/--json`, `--missing` | ([cli/bootstrap/status](https://mise.jdx.dev/cli/bootstrap/status.html)) |
| `mise bootstrap plugins <SUBCOMMAND>` | — | read-only | — | ([cli/bootstrap/plugins](https://mise.jdx.dev/cli/bootstrap/plugins.html)) |
| `mise bootstrap plugins apply` | — | modifies state | `-n/--dry-run` | ([cli/bootstrap/plugins/apply](https://mise.jdx.dev/cli/bootstrap/plugins/apply.html)) |
| `mise bootstrap plugins status` | — | read-only | `--missing` | ([cli/bootstrap/plugins/status](https://mise.jdx.dev/cli/bootstrap/plugins/status.html)) |
| `mise bootstrap packages <SUBCOMMAND>` | — | read-only | — | ([cli/bootstrap/packages](https://mise.jdx.dev/cli/bootstrap/packages.html)) |
| `mise bootstrap packages apply [PACKAGE]…` | `i`, `install` | modifies state | `-m/--manager`, `-n/--dry-run`, `-y/--yes`, `--update` | ([apply](https://mise.jdx.dev/cli/bootstrap/packages/apply.html)) |
| `mise bootstrap packages status` | `ls` | read-only | `-J/--json`, `--missing` | ([status](https://mise.jdx.dev/cli/bootstrap/packages/status.html)) |
| `mise bootstrap packages use <PACKAGE>…` | `u` | modifies state | `-e/--env`, `-g/--global`, `-n/--dry-run`, `-p/--path`, `-y/--yes` | ([use](https://mise.jdx.dev/cli/bootstrap/packages/use.html)) |
| `mise bootstrap packages import` | — | modifies state | `-e/--env`, `-g/--global`, `-m/--manager` (`brew`, default `brew`), `--all`, `-n/--dry-run`, `-p/--path` | ([import](https://mise.jdx.dev/cli/bootstrap/packages/import.html)) |
| `mise bootstrap packages prune` | — | **destructive** | `-m/--manager` (`brew`, default `brew`), `-n/--dry-run`, `-y/--yes` | ([prune](https://mise.jdx.dev/cli/bootstrap/packages/prune.html)) |
| `mise bootstrap packages upgrade [PACKAGE]…` | `up` | modifies state | `-m/--manager`, `-n/--dry-run`, `-y/--yes` | ([upgrade](https://mise.jdx.dev/cli/bootstrap/packages/upgrade.html)) |
| `mise bootstrap packages brew <SUBCOMMAND>` | — | read-only | — | ([brew](https://mise.jdx.dev/cli/bootstrap/packages/brew.html)) |
| `mise bootstrap packages brew tap <TAP> [URL]` | — | modifies state | `-l/--local`, `-n/--dry-run`, `-p/--path` | ([tap](https://mise.jdx.dev/cli/bootstrap/packages/brew/tap.html)) |
| `mise bootstrap packages brew untap <TAPS>…` | `remove`, `rm` | modifies state | `-l/--local`, `-n/--dry-run`, `-p/--path` | ([untap](https://mise.jdx.dev/cli/bootstrap/packages/brew/untap.html)) |
| `mise bootstrap repos <SUBCOMMAND>` | — | read-only | — | ([repos](https://mise.jdx.dev/cli/bootstrap/repos.html)) |
| `mise bootstrap repos apply` | — | modifies state | `-n/--dry-run`, `-y/--yes` | ([apply](https://mise.jdx.dev/cli/bootstrap/repos/apply.html)) |
| `mise bootstrap repos status` | — | read-only | `-J/--json`, `--missing` | ([status](https://mise.jdx.dev/cli/bootstrap/repos/status.html)) |
| `mise bootstrap repos update [PATH]…` | — | modifies state | `-n/--dry-run`, `-y/--yes` | ([update](https://mise.jdx.dev/cli/bootstrap/repos/update.html)) |
| `mise bootstrap repos exec [PATH]… -- <COMMAND>…` | — | — | `-c/--continue-on-error`, `-n/--dry-run` | ([exec](https://mise.jdx.dev/cli/bootstrap/repos/exec.html)) |
| `mise bootstrap dotfiles <SUBCOMMAND>` | — | read-only | — | ([dotfiles](https://mise.jdx.dev/cli/bootstrap/dotfiles.html)) |
| `mise bootstrap dotfiles add <TARGET>…` | — | modifies state | `-f/--force`, `-g/--global`, `-l/--local`, `-m/--mode`, `-n/--dry-run`, `--no-apply`, `-p/--path`, `-s/--source`, `-y/--yes` | ([add](https://mise.jdx.dev/cli/bootstrap/dotfiles/add.html)) |
| `mise bootstrap dotfiles apply [TARGET]…` | — | modifies state | `-f/--force`, `-n/--dry-run`, `-y/--yes` | ([apply](https://mise.jdx.dev/cli/bootstrap/dotfiles/apply.html)) |
| `mise bootstrap dotfiles edit <TARGET>` | — | modifies state | `--apply`, `-m/--mode`, `-s/--source`, `-y/--yes` | ([edit](https://mise.jdx.dev/cli/bootstrap/dotfiles/edit.html)) |
| `mise bootstrap dotfiles status [TARGET]…` | `ls` | read-only | `-J/--json`, `--missing` | ([status](https://mise.jdx.dev/cli/bootstrap/dotfiles/status.html)) |
| `mise bootstrap dotfiles unapply [TARGET]…` | — | **destructive** | `-f/--force`, `-n/--dry-run`, `-y/--yes` | ([unapply](https://mise.jdx.dev/cli/bootstrap/dotfiles/unapply.html)) |
| `mise bootstrap mise-shell-activate apply` | — | modifies state | `-n/--dry-run`, `-y/--yes` | ([apply](https://mise.jdx.dev/cli/bootstrap/mise-shell-activate/apply.html)) |
| `mise bootstrap mise-shell-activate status` | — | read-only | `-J/--json`, `--missing` | ([status](https://mise.jdx.dev/cli/bootstrap/mise-shell-activate/status.html)) |
| `mise bootstrap macos <SUBCOMMAND>` | — | read-only | — | ([macos](https://mise.jdx.dev/cli/bootstrap/macos.html)) |
| `mise bootstrap macos defaults apply` | — | modifies state | `-n/--dry-run`, `-y/--yes` | ([apply](https://mise.jdx.dev/cli/bootstrap/macos/defaults/apply.html)) |
| `mise bootstrap macos defaults status` | — | read-only | `-J/--json`, `--missing` | ([status](https://mise.jdx.dev/cli/bootstrap/macos/defaults/status.html)) |
| `mise bootstrap macos launchd-agents apply` | — | modifies state | `-n/--dry-run`, `-y/--yes` | ([apply](https://mise.jdx.dev/cli/bootstrap/macos/launchd-agents/apply.html)) |
| `mise bootstrap macos launchd-agents status` | — | read-only | `-J/--json`, `--missing` | ([status](https://mise.jdx.dev/cli/bootstrap/macos/launchd-agents/status.html)) |
| `mise bootstrap linux <SUBCOMMAND>` | — | read-only | — | ([linux](https://mise.jdx.dev/cli/bootstrap/linux.html)) |
| `mise bootstrap linux systemd-units apply` | — | modifies state | `-n/--dry-run`, `-y/--yes` | ([apply](https://mise.jdx.dev/cli/bootstrap/linux/systemd-units/apply.html)) |
| `mise bootstrap linux systemd-units status` | — | read-only | `-J/--json`, `--missing` | ([status](https://mise.jdx.dev/cli/bootstrap/linux/systemd-units/status.html)) |
| `mise bootstrap user <SUBCOMMAND>` | — | read-only | — | ([user](https://mise.jdx.dev/cli/bootstrap/user.html)) |
| `mise bootstrap user apply` | — | modifies state | `-n/--dry-run`, `-y/--yes` | ([apply](https://mise.jdx.dev/cli/bootstrap/user/apply.html)) |
| `mise bootstrap user status` | — | read-only | `-J/--json`, `--missing` | ([status](https://mise.jdx.dev/cli/bootstrap/user/status.html)) |
| `mise generate bootstrap` | — | modifies state | `-l/--localize`, `-V/--version`, `-w/--write`, `--localized-dir` (default `.mise`) | ([generate/bootstrap](https://mise.jdx.dev/cli/generate/bootstrap.html)) |

> **Uncertainty:** `mise bootstrap repos exec` is the only bootstrap subcommand whose CLI page omits an **Effect** line ([cli/bootstrap/repos/exec](https://mise.jdx.dev/cli/bootstrap/repos/exec.html)); it obviously modifies state via whatever command you pass, but mise does not classify it.

> **Uncertainty:** the `--verbose` flag used in `mise bootstrap dotfiles apply --dry-run --verbose` ([bootstrap](https://mise.jdx.dev/bootstrap.html), [dotfiles](https://mise.jdx.dev/dotfiles.html)) is not listed on the [apply CLI page](https://mise.jdx.dev/cli/bootstrap/dotfiles/apply.html); it is presumably a global mise flag rather than a subcommand flag.

---

## 6. Environments, Env Vars, Secrets & Hooks

mise is two tools in one: a version manager and a directory-scoped environment manager. This section covers the second half — the `[env]` table, the `env._` directives, secrets, `MISE_ENV` config environments, hooks, shell aliases, and the file-watching commands.

---

### 6.1 The `[env]` table

The minimum viable config is a `mise.toml` at the project root ([environments](https://mise.jdx.dev/environments/)):

```toml
[env]
NODE_ENV = 'production'
```

Values may be **strings**, **integers**, **booleans** (`false` only, see below), or **tables** (the "map form", see the options table).

#### 6.1.1 Unsetting and defaulting

| Form | Meaning |
| --- | --- |
| `VAR = "value"` | Set unconditionally (overrides pre-existing and earlier configs) |
| `VAR = false` | **Unset** a previously set var |
| `VAR = { default = "x" }` | Set only if `VAR` is unset **or empty**; otherwise preserve existing value |

```toml
[env]
NODE_ENV = false # unset a previously set NODE_ENV
```

```toml
[env]
NODE_ENV = { default = "development" }
```

`default` "keeps `NODE_ENV` if it was already set before mise ran or by an earlier config file. If it is unset or empty, mise sets it to `"development"`. Defaults can be strings or integers." ([environments](https://mise.jdx.dev/environments/))

#### 6.1.2 Map-form options

When a value is a TOML table instead of a scalar, these keys are available ([environments](https://mise.jdx.dev/environments/)):

| Key | Type / default | Meaning |
| --- | --- | --- |
| `value` | string | The literal value (may be a template) |
| `default` | string \| integer | Fallback used only when the var is unset or empty |
| `tools` | bool, default `false` | Resolve this entry **after** tools are loaded, so `{{env.PATH}}` / `{{tools.*}}` see tool-provided values |
| `redact` | bool, default `false` | Mark value sensitive; hidden from task output and reported by `mise env --redacted` |
| `required` | bool \| string, default `false` | Fail if the var is not supplied elsewhere; a string value is help text shown in the error |
| `age` | table | [experimental] Age-encrypted ciphertext, see §6.10.2 |

> **Uncertainty:** The docs demonstrate `required` with inline tables spread across multiple lines (`DATABASE_URL = {\n  required = "…",\n}`). Strict TOML 1.0 forbids newlines inside inline tables, so either mise's parser is lenient or the doc snippets are illustrative. Prefer single-line inline tables or `[env.DATABASE_URL]` sub-tables if your editor/linter complains. ([environments](https://mise.jdx.dev/environments/))

#### 6.1.3 `required` variables

Marks a variable that the config **declares** but does not **define** — it must come from the ambient environment or a later (higher-precedence) config file ([environments](https://mise.jdx.dev/environments/)):

```toml
[env]
DATABASE_URL = { required = true }
API_KEY = { required = true }
```

With help text:

```toml
[env]
DATABASE_URL = { required = "Set DATABASE_URL to your PostgreSQL connection string (e.g., postgres://user:pass@localhost/dbname)" }
API_KEY = { required = "Get your API key from https://example.com/api-keys" }
AWS_REGION = { required = "Set to your AWS region (e.g., us-east-1, eu-west-1)" }
```

Accepted satisfaction sources, in the docs' own words: (1) **pre-existing environment** — set before running mise; (2) **later config file** — defined in a config processed after the one declaring it required (e.g. `mise.local.toml`).

Failure behaviour differs by entry point ([environments](https://mise.jdx.dev/environments/)):

| Context | Behaviour |
| --- | --- |
| Regular commands (`mise env`, `mise run`, …) | Hard error: `Error: Required environment variable 'DATABASE_URL' is not defined...` |
| Shell activation (`mise hook-env`) | Warns (`mise WARN Required environment variable ... is not defined...`) and continues, so shell setup is not broken |

```toml
# mise.toml
[env]
DATABASE_URL = { required = true }
```

```toml
# mise.local.toml (processed later)
[env]
DATABASE_URL = "postgres://prod.example.com/db"  # This satisfies the requirement
```

#### 6.1.4 Lazy eval: `tools = true`

> "Environment variables typically are resolved before tools—that way you can configure tool installation subprocesses with environment variables." ([environments](https://mise.jdx.dev/environments/))

To read values *produced by* tools, flip the entry to the map form with `tools = true`:

```toml
[env]
MY_VAR = { value = "tools path: {{env.PATH}}", tools = true }
_.path = { path = ["{{env.GEM_HOME}}/bin"], tools = true } # directives may also set tools = true
NODE_VERSION = { value = "{{ tools.node.version }}", tools = true }
```

**Gotcha — mise's own config vars are not lazily evaluatable at all.** Variables that configure mise itself, such as `MISE_DATA_DIR` or `MISE_INSTALLS_DIR`, "are read when the process starts, so set them in the shell or CI environment before invoking mise rather than in `[env]`." ([environments](https://mise.jdx.dev/environments/)) The same reasoning applies to `MISE_ENV` and `auto_env`, which must be set before config discovery (§6.6).

A practical `tools = true` case from the Python docs — pinning `uv` to mise's exact interpreter ([lang/python](https://mise.jdx.dev/lang/python.html)):

```toml
[tools]
python = "3.15"

[env]
UV_PYTHON = { value = "{{ tools.python.path }}", tools = true }
```

---

### 6.2 `env._` directives

> "`env._.*` define special behavior for setting environment variables … Since nested environment variables do not make sense, we make use of this fact by creating a key named `_` which is a TOML table for the configuration of these directives." ([environments](https://mise.jdx.dev/environments/#env-directives))

**Deprecations to know (version-sensitive):** ([environments](https://mise.jdx.dev/environments/#env-directives))

| Deprecated form | Replacement | Removal |
| --- | --- | --- |
| `value` / `values` keys inside built-in `file`/`path`/`source` directive objects (under `env._` or `vars._`) | `path` (accepts a string or array of strings) | mise **2026.12.0** |
| `env.mise.*` spelling | `env._.*` | mise **2026.12.0** |
| Top-level `env_file`, `dotenv`, `env_path` keys | `env._.file`, `env._.path` | mise **2027.4.0** |
| `[tools] python = { virtualenv = ".venv" }` | `env._.python.venv` | "a future release" ([lang/python](https://mise.jdx.dev/lang/python.html)) |

Note the `value`/`values` deprecation does **not** affect `value` in ordinary env-var objects, nor options for plugin-provided directives.

#### 6.2.1 `env._.file` — dotenv / JSON / YAML / TOML

```toml
[env]
_.file = '.env'
```

Supported ([environments](https://mise.jdx.dev/environments/#env-file)):

* a single file as a string **or** an object
* multiple files as an array of strings and objects
* relative or absolute paths (relative → `config_root`, §6.4)
* `dotenv`, `json`, `yaml`, `toml` formats
* the `redact`, `tools`, and `expand` options

```toml
[env]
_.file = '.env.yaml'
```

```toml
[env]
_.file = '.env.toml'
```

```toml
[env]
# Load env from the dotenv file after tools have defined environment variables
_.file = { path = ".env", tools = true }
```

```toml
[env]
_.file = [
    # Load env from the json file relative to this config file
    '.env.json',
    # Load env from the dotenv file at an absolute path
    '/User/bob/.env',
    # Load env from the yaml file relative to this config file and redact the values
    { path = ".secrets.yaml", redact = true }
]
```

**Parser note:** "Only dotenv-format files use [dotenvy](https://crates.io/crates/dotenvy) under the hood. If you have problems with dotenv parsing, you will likely need to post an issue there, not to mise… JSON, YAML, and TOML files use separate parsers." ([environments](https://mise.jdx.dev/environments/#env-file))

**Expansion rules for `_.file`** ([environments](https://mise.jdx.dev/environments/#env-file)):

| File type | Default expansion | With `expand = true` | Global kill-switch |
| --- | --- | --- | --- |
| JSON / YAML / TOML | **Disabled** — literal `$` preserved | Values may reference vars defined earlier in the same file, an earlier file, or an earlier `[env]` block | `env_shell_expand = false` overrides `expand = true` |
| dotenv | dotenvy's normal same-file expansion, always on | *Additionally* enables references to previously loaded values | same |

```toml
[env]
BASE = "/opt/project"
_.file = { path = ".env.json", expand = true }
```

**`_.file` vs the `env_file` setting.** `MISE_ENV_FILE=.env` (or `env_file = ".env"` under `[settings]` in `~/.config/mise/config.toml`) "automatically load[s] dotenv files from the current directory and parent directories… This is different from `env._.file`, which resolves paths relative to the config file that declares it." ([environments](https://mise.jdx.dev/environments/#env-file)) The setting is `env_file`, type `string` (optional), env `MISE_ENV_FILE`, default `None` ([configuration/settings](https://mise.jdx.dev/configuration/settings.html)).

#### 6.2.2 `env._.path` — PATH prepending

```toml
[env]
_.path = './bin'
```

Supports a single path (string or object), an array, relative/absolute paths, and the `tools` option ([environments](https://mise.jdx.dev/environments/#env-path)).

```toml
[env]
_.path = 'scripts'
```

```toml
[env]
# Define this path directory after tools have defined environment variables
_.path = { path = ["{{env.GEM_HOME}}/bin"], tools = true }
```

```toml
[env]
_.path = [
    # adds an absolute path
    "~/.local/share/bin",
    # adds a path relative to the project root (config_root)
    "{{config_root}}/node_modules/.bin",
    # adds a relative path (equivalent to "{{config_root}}/tools/bin")
    "tools/bin",
]
```

> "Relative paths like `tools/bin` or `./tools/bin` are resolved against `{{config_root}}`. For example, with a config file at `/path/to/project/.config/mise/config.toml`, `tools/bin` resolves to `/path/to/project/tools/bin`." ([environments](https://mise.jdx.dev/environments/#env-path))

`PATH` is described as "treated specially": entries are *added* so their executables become callable without a full path, rather than replacing `PATH` ([environments](https://mise.jdx.dev/environments/#env-path)).

> **Uncertainty:** The docs describe `_.path` as "add extra directories to the `PATH`" and the direnv page warns that "if you have an issue, it's likely to do with the **ordering** of PATH" ([direnv](https://mise.jdx.dev/direnv.html)), but the `_.path` reference does not state in prose whether entries are prepended or appended, nor the relative order of multiple entries vs. tool-provided PATH entries. Empirically-critical detail — verify with `mise env -s bash` for your layout rather than assuming.

#### 6.2.3 `env._.source` — sourcing a shell script

```toml
[env]
_.source = "./script.sh"
```

> "This **must** be a script that runs in bash as if it were executed like this: `source ./script.sh`. The shebang will be **ignored**." ([environments](https://mise.jdx.dev/environments/#env-source)) mise pulls the *exported* variables out of it. Support for binaries or other script languages is tracked in [jdx/mise discussion #6734](https://github.com/jdx/mise/discussions/6734).

Supports a single source (string or object), arrays, relative/absolute paths, and the `redact` and `tools` options ([environments](https://mise.jdx.dev/environments/#env-source)):

```toml
[env]
_.source = 'source.sh'
```

```toml
[env]
# Source this file after tools have defined environment variables
_.source = { path = "my/env.sh", tools = true }
```

```toml
[env]
_.source = [
    # Sources the file relative to the config root
    './scripts/base.sh',
    # Sources a file at an absolute path
    '/User/bob/env.sh',
    # Sources the file relative to the config root and redacts the values
    { path = ".secrets.sh", redact = true }
]
```

Multiple scripts in an array "can be sourced in order with a single `_.source` key" ([environments](https://mise.jdx.dev/environments/#multiple-env-directives)):

```toml
[env]
_.source = ["./script_1.sh", "./script_2.sh"]
```

**Windows:** sourcing "requires a real POSIX bash such as [Git for Windows](https://gitforwindows.org/) or MSYS2. mise auto-detects it the same way it does for bash tasks (common install locations are probed even when bash is not on `PATH`; set `MISE_BASH_PATH` to point at a specific bash; the WSL launcher at `C:\Windows\System32\bash.exe` is never auto-selected since WSL cannot read Windows script paths). `PATH` entries the script prepends (in `/c/...` or `/cygdrive/c/...` form) are converted back to Windows form." ([environments](https://mise.jdx.dev/environments/#env-source))

#### 6.2.4 `env._.python.venv` — automatic virtualenv activation

Lives in `[env]` (contrast with the `python.uv_venv_auto` **setting**, which lives in `[settings]`) ([lang/python](https://mise.jdx.dev/lang/python.html#automatic-virtualenv-activation)):

| Mechanism | Best for | Config location |
| --- | --- | --- |
| `python.uv_venv_auto` | uv projects (with `uv.lock`) | `[settings]` section |
| `_.python.venv` | Projects not using uv | `[env]` section |

`_.python.venv` "creates/activates a venv and adds it to PATH. It works with both `mise activate` and `mise exec`."

The doc's option catalogue (shown as repeated assignments for illustration — **do not** copy verbatim, duplicate keys are invalid TOML; pick one form):

```toml
[tools]
python = "3.15" # [optional] will be used for the venv

[env]
_.python.venv = ".venv" # relative to this file's directory
_.python.venv = "/root/.venv" # can be absolute
_.python.venv = "{{env.HOME}}/.cache/venv/myproj" # can use templates
_.python.venv = { path = ".venv", create = true } # create the venv if it doesn't exist
_.python.venv = { path = ".venv", create = true, python = "3.15" } # use a specific python version
_.python.venv = {
  path = ".venv", create = true,
  python_create_args = ["--without-pip"], # pass args to python -m venv
}
_.python.venv = {
  path = ".venv", create = true,
  uv_create_args = ["--system-site-packages"], # pass args to uv venv
}
# Install seed packages (pip, setuptools, and wheel) into the virtual environment.
_.python.venv = { path = ".venv", create = true, uv_create_args = ['--seed'] }
```

| Option | Type / default | Meaning |
| --- | --- | --- |
| `path` | string | Venv location; relative to this file's directory, or absolute; templates allowed |
| `create` | bool, default `false` | Create the venv if missing. Without it, "the venv will need to be created manually with `python -m venv /path/to/venv`" |
| `python` | string | Use a specific Python version for the venv |
| `python_create_args` | string[] | Args passed to `python -m venv` |
| `uv_create_args` | string[] | Args passed to `uv venv` (e.g. `['--seed']` to get pip) |

([lang/python](https://mise.jdx.dev/lang/python.html#python-venv-configuration))

Creation backend: "If you have installed `uv` … `mise` will use it to create virtual environments via `_.python.venv`. Otherwise, it will use the built-in `python -m venv` command." `uv` omits `pip` by default, hence `uv_create_args = ['--seed']` ([lang/python](https://mise.jdx.dev/lang/python.html#mise-uv)).

**Gotchas:**

* "Virtualenv activation requires `mise activate` or `mise exec`. When using [shims](https://mise.jdx.dev/dev-tools/shims.html) alone, the venv's `bin/` directory is not added to PATH, so `which python` will point to the shim rather than the venv's interpreter." ([lang/python](https://mise.jdx.dev/lang/python.html#python-venv-configuration))
* `_.python.venv` and `python.uv_venv_auto` "are separate mechanisms with different code paths. Options like `uv_create_args` and `python_create_args` in `_.python.venv` are not used by `python.uv_venv_auto`." ([lang/python](https://mise.jdx.dev/lang/python.html#automatic-virtualenv-activation))

Related settings (`[settings]`, not `[env]`) ([lang/python](https://mise.jdx.dev/lang/python.html)):

| Setting | Type / default | Meaning |
| --- | --- | --- |
| `python.uv_venv_auto` | `boolean \| string` — `false` / `"source"` / `"create\|source"` / `true` (legacy) | uv-project venv handling; requires a `uv.lock` (no-op without one). Legacy `true` = `create\|source` **plus** exporting `UV_PYTHON` |
| `python.uv_venv_create_args` | `string[]` (optional), env `MISE_PYTHON_UV_VENV_CREATE_ARGS` (colon separated) | Args passed to uv when creating a venv |
| `python.venv_create_args` | `string[]` (optional), env `MISE_PYTHON_VENV_CREATE_ARGS` (colon separated) | Args passed to python when creating a venv (not used for uv) |
| `python.venv_stdlib` | boolean, env `MISE_VENV_STDLIB` | Prefer venv from Python's standard library |

`UV_PROJECT_ENVIRONMENT` is respected for `uv_venv_auto`: relative paths resolve from the uv project root (dir containing `uv.lock`), absolute paths are used as-is, unset/empty → `.venv` ([lang/python](https://mise.jdx.dev/lang/python.html#python-uv-venv-auto-setting)).

```toml
[env]
UV_PROJECT_ENVIRONMENT = "my.venv"

[settings]
python.uv_venv_auto = "create|source"
```

> **Version note:** the `true` value for `python.uv_venv_auto` "is considered legacy and will be deprecated in a future release (planned for mise 2026.7)". The *setting* stays; only `true` is phased out. ([lang/python](https://mise.jdx.dev/lang/python.html#mise-uv))

#### 6.2.5 Plugin-provided `env._` directives

Plugins can register their own directives, useful for secret managers, dynamic env, and PATH management ([environments](https://mise.jdx.dev/environments/#plugin-provided-env-directives)):

```toml
[env]
_.my-plugin = {}
```

```toml
[env]
_.my-plugin = { option1 = "value1", option2 = "value2" }
```

Resolution sequence when `env._.<plugin-name>` is used:

1. Loads the plugin from your installed plugins
2. Calls the plugin's `MiseEnv` hook to get environment variables
3. Calls the plugin's `MisePath` hook to get PATH entries (if defined)
4. Applies these when running `mise env` or using shell integration

Options in the TOML table are passed to the hooks via `ctx.options`. Authoring guide: [Environment Plugins](https://mise.jdx.dev/plugins.html#environment-plugins); working example: [mise-env-plugin-template](https://github.com/jdx/mise-env-plugin-template).

```toml
[env]
# Fetch secrets from a vault
_.vault-secrets = { vault_url = "https://vault.example.com", secrets_path = "secret/myapp" }
# Set environment based on git branch
_.git-env = { production_branch = "main" }
```

---

### 6.3 Templating and shell-style expansion in env values

Two independent mechanisms, applied in a fixed order.

**1. Tera templates** ([environments](https://mise.jdx.dev/environments/#templates), see also [templates](https://mise.jdx.dev/templates.html)):

```toml
[env]
LD_LIBRARY_PATH = "/some/path:{{env.LD_LIBRARY_PATH}}"
```

Later vars can reference earlier ones — "of course the ordering matters when doing this":

```toml
[env]
MY_PROJ_LIB = "{{config_root}}/lib"
LD_LIBRARY_PATH = "/some/path:{{env.MY_PROJ_LIB}}"
```

**2. Shell-style expansion** — "a simpler alternative to Tera templates for referencing env vars" ([environments](https://mise.jdx.dev/environments/#shell-style-variable-expansion)):

```toml
[env]
MY_PROJ_LIB = "{{config_root}}/lib"
LD_LIBRARY_PATH = "$MY_PROJ_LIB:$LD_LIBRARY_PATH"
```

| Syntax | Description |
| --- | --- |
| `$VAR` | Expands to the value of VAR |
| `${VAR}` | Same, useful when followed by alphanumeric characters (e.g., `${VAR}_suffix`) |
| `${VAR:-default}` | Uses default if VAR is unset or empty |
| `${VAR:-}` | Expands to empty string if VAR is unset (suppresses the undefined variable warning) |

**Ordering:** "Expansion runs after Tera template rendering, so both syntaxes can be mixed. Undefined variables without a default are left unexpanded and produce a warning." ([environments](https://mise.jdx.dev/environments/#shell-style-variable-expansion))

Kill-switch: setting `env_shell_expand` — type `boolean`, env `MISE_ENV_SHELL_EXPAND`, default `true`; `false` disables shell expansion everywhere, including in files that set `expand = true` ([configuration/settings](https://mise.jdx.dev/configuration/settings.html), [environments](https://mise.jdx.dev/environments/#env-file)):

```toml
[env]
FOO = "hello"
BAR = "$FOO-world"        # "hello-world"
BAZ = "${FOO}_suffix"     # "hello_suffix"
QUX = "${UNDEF:-fallback}" # "fallback"
```

---

### 6.4 `config_root` and relative paths

> "`config_root` is the canonical project root directory that mise uses when resolving relative paths inside configuration files. Generally, when you use relative paths in mise you're referring to this directory." ([environments](https://mise.jdx.dev/environments/#config-root))

| Config File | config_root |
| --- | --- |
| `~/src/foo/.config/mise/conf.d/config.toml` | `~/src/foo` |
| `~/src/foo/.config/mise/config.toml` | `~/src/foo` |
| `~/src/foo/.mise/config.toml` | `~/src/foo` |
| `~/src/foo/mise.toml` | `~/src/foo` |

Implementation: [config_root.rs](https://github.com/jdx/mise/blob/main/src/config/config_file/config_root.rs).

```toml
[env]
# These are equivalent and both resolve against the project root
_.path = ["tools/bin", "{{config_root}}/tools/bin"]

# Likewise, a relative source path resolves against the project root
_.source = "scripts/env.sh"          # == "{{config_root}}/scripts/env.sh"
```

---

### 6.5 Precedence and ordering

Three distinct orderings compose. Getting these straight is most of the battle.

#### 6.5.1 Between config files (directory hierarchy)

mise "walks up the directory tree from your current location to the root (or `MISE_CEILING_PATHS`), collects all config files it finds along the way, merges them in order with more specific (closer to your current directory) settings overriding broader ones, [and] applies environment-specific configs like `mise.dev.toml` if `MISE_ENV` is set." ([configuration](https://mise.jdx.dev/configuration.html#configuration-hierarchy))

```
/
├── etc/mise/                         # System-wide config (lowest precedence)
│   ├── conf.d/*.toml                 # System fragments, loaded alphabetically
│   ├── config.toml                   # System defaults
│   └── config.<env>.toml             # Env-specific system config (MISE_ENV or -E)
└── home/user/
    ├── .config/mise/
    │   ├── conf.d/*.toml             # User fragments, loaded alphabetically
    │   ├── config.toml               # Global user config
    │   ├── config.<env>.toml         # Env-specific user config
    │   ├── config.local.toml         # User-local overrides
    │   └── config.<env>.local.toml   # Env-specific user-local overrides
    └── work/
        ├── mise.toml                 # Work-wide settings
        └── myproject/
            ├── mise.local.toml       # Local overrides (git-ignored)
            ├── mise.toml             # Project config
            ├── mise.<env>.toml       # Env-specific project config
            ├── mise.<env>.local.toml # Env-specific project local overrides
            └── backend/
                └── mise.toml         # Service-specific config (highest precedence)
```

([configuration](https://mise.jdx.dev/configuration.html#visual-configuration-hierarchy))

#### 6.5.2 Within one directory (filename precedence)

Top overrides bottom ([configuration](https://mise.jdx.dev/configuration.html#mise-toml)):

1. `mise.local.toml` — local config, should not be committed
2. `mise.toml`
3. `mise/config.toml`
4. `.mise/config.toml`
5. `.config/mise.toml`
6. `.config/mise/config.toml`
7. `.config/mise/conf.d/*.toml` — loaded in alphabetical order

Any of the `mise`-prefixed paths may be dotfiles (`.mise.toml`, `.mise/config.toml`). Ground truth lives in [`LOCAL_CONFIG_FILENAMES` in src/config/mod.rs](https://github.com/jdx/mise/blob/main/src/config/mod.rs).

With `MISE_ENV` set, the four-way order in a directory is (top overrides bottom) ([configuration/environments](https://mise.jdx.dev/configuration/environments.html)):

```
mise.{MISE_ENV}.local.toml
mise.local.toml
mise.{MISE_ENV}.toml
mise.toml
```

Debug it with `mise config` / `mise cfg`: "Run `mise cfg` to figure out what order mise is loading files on your particular setup. This is often a lot easier than figuring out mise's rules." ([configuration](https://mise.jdx.dev/configuration.html#mise-toml))

#### 6.5.3 Merge semantics per section

| Section | Merge behaviour | Example ([configuration](https://mise.jdx.dev/configuration.html#merge-behavior-by-section)) |
| --- | --- | --- |
| `[tools]` | Additive with overrides | Global `node@18, python@3.11` + project `node@20, go@1.21` → `node@20, python@3.11, go@1.21` |
| `[env]` | Additive with overrides | Global `NODE_ENV=development` + project `NODE_ENV=production, API_URL=localhost` → `NODE_ENV=production, API_URL=localhost` |
| `[tasks]` | **Completely replaced per task** | Global `[tasks.test] = "npm test"` + project `[tasks.test] = "yarn test"` → `"yarn test"` |
| `[settings]` | Additive with overrides | Global `experimental = true` + project `jobs = 4` → both |

#### 6.5.4 Within a single `[env]` table (order of appearance)

Entries are resolved in the order written: later entries can reference earlier ones via `{{env.X}}` or `$X` — "of course the ordering matters when doing this" ([environments](https://mise.jdx.dev/environments/#using-env-vars-in-other-env-vars)). Likewise `expand = true` lets a file reference "variables defined earlier in the same file, an earlier file, or an earlier `[env]` block" ([environments](https://mise.jdx.dev/environments/#env-file)), and `_.source` arrays are applied in array order ([environments](https://mise.jdx.dev/environments/#multiple-env-directives)).

#### 6.5.5 Env vs. tools

* Env vars resolve **before** tools by default, so they can configure tool-installation subprocesses.
* Entries with `tools = true` resolve **after** tools, and can read `{{env.*}}` values set by tools plus `{{tools.<name>.version}}` / `{{tools.<name>.path}}`.
* `MISE_*` variables that configure mise itself are read at process start and cannot be set from `[env]` at all.

([environments](https://mise.jdx.dev/environments/#lazy-eval))

#### 6.5.6 Secrets key precedence

sops age key resolution, highest first ([environments/secrets/sops](https://mise.jdx.dev/environments/secrets/sops.html#environment-variables)):

1. `MISE_SOPS_AGE_KEY` (mise setting or env var, checked first)
2. `MISE_SOPS_AGE_KEY_FILE` or `sops.age_key_file` (mise setting or env var)
3. `SOPS_AGE_KEY_FILE` (standard)
4. `SOPS_AGE_KEY` (standard, direct key content)
5. Default: `~/.config/mise/age.txt`

Direct-age identity resolution, in order ([environments/secrets/age](https://mise.jdx.dev/environments/secrets/age.html#decryption-identities)):

1. `MISE_AGE_KEY` env var (one or more raw `AGE-SECRET-KEY-...` lines, or an age identity file payload)
2. `settings.age.identity_files` (list of paths)
3. `settings.age.key_file` (single path)
4. Default `~/.config/mise/age.txt` if it exists
5. SSH identities from `settings.age.ssh_identity_files` and common defaults (`~/.ssh/id_ed25519`, `~/.ssh/id_rsa`)

---

### 6.6 Config environments (`MISE_ENV`)

> "It's possible to have separate `mise.toml` files in the same directory for different environments like `development` and `production`." ([configuration/environments](https://mise.jdx.dev/configuration/environments.html))

Three ways to select an environment:

| Method | Example |
| --- | --- |
| CLI flag | `-E development` / `--env development` |
| Environment variable | `MISE_ENV=development` |
| `.miserc.toml` | `env = ["development"]` |

mise then looks for `mise.{MISE_ENV}.toml` "in the current directory, parent directories and the `MISE_CONFIG_DIR` directory". Multiple environments are allowed: `MISE_ENV=ci,test`, "with the last one taking precedence".

**`MISE_ENV` cannot be set in `mise.toml`** "because it determines which config files to load in the first place."

`.miserc.toml` is loaded very early, before config discovery, and supports [Tera templates](https://mise.jdx.dev/templates.html#miserc-template-support) with OS-level context only (env vars, `cwd`, `arch()`, `os()`) — `mise.toml` settings are not yet loaded:

```toml
# .miserc.toml

# Stop config search at $HOME
ceiling_paths = ["{{ env.HOME }}"]

# Or use the XDG config home variable
ignored_config_paths = ["{{ xdg_config_home }}/mise/shared.toml"]
```

`.miserc.toml` search order (by precedence) ([configuration/environments](https://mise.jdx.dev/configuration/environments.html#setting-mise-env-in-miserc-toml)):

1. `.miserc.toml` and `.config/miserc.toml` in current directory and parent directories
2. `~/.config/mise/miserc.toml` (global)
3. `/etc/mise/miserc.toml` (system)

Other notes: `MISE_OVERRIDE_CONFIG_FILENAMES`, if set, replaces all of the above; nested paths like `mise/config.{MISE_ENV}.toml` and `.config/mise.{MISE_ENV}.toml` follow the [Configuration](https://mise.jdx.dev/configuration.html) ordering rules; `mise use` write-target rules are separate (see [mise use](https://mise.jdx.dev/cli/use.html)).

#### 6.6.1 Platform environments (`auto_env`)

With the [`auto_env` setting](https://mise.jdx.dev/configuration/settings.html#auto_env) enabled, mise treats these as active config environments based on the running platform ([configuration/environments](https://mise.jdx.dev/configuration/environments.html#platform-environments)):

| Environment | Values |
| --- | --- |
| `{os_family}` | `unix` (not defined on Windows — use `windows`) |
| `{os}` | `linux`, `macos`, `windows` |
| `{os}-{arch}` | e.g. `linux-x64`, `macos-arm64`, `windows-x64` |

Architectures use mise's remapped names: `x86_64` → `x64`, `aarch64` → `arm64`. Files like `mise.windows.toml`, `mise.macos-arm64.toml`, `mise.unix.toml` load automatically, matching lockfiles like `mise.windows.lock` get selected, and all the usual locations and `.local.toml` variants work.

**Precedence (later overrides earlier):** `unix` < `{os}` < `{os}-{arch}` < explicit `MISE_ENV` entries.

Platform environments "only affect config file discovery and lockfile selection. They are not added to `MISE_ENV` itself" — the template variable and the `MISE_ENV` passed to subprocesses and tasks reflect only explicit environments.

> **Version-sensitive rollout:** `auto_env` is **disabled by default** today. "Starting with mise `2027.6.0` it will default to enabled; from `2026.12.0` until then, mise warns if it finds a platform-specific config file that would be newly loaded." Opt in/out explicitly — and note it is an early-init setting like `MISE_ENV`, so `mise.toml` is too late: ([configuration/environments](https://mise.jdx.dev/configuration/environments.html#rollout))

```toml
# .miserc.toml
auto_env = true # adopt the new behavior now
# or
auto_env = false # keep the old behavior and silence the warning
```

or `MISE_AUTO_ENV=true` / `MISE_AUTO_ENV=false`.

---

### 6.7 Where the environment shows up

Env vars are available with [`mise x|exec`](https://mise.jdx.dev/cli/exec.html) and [`mise r|run`](https://mise.jdx.dev/cli/run.html) ([environments](https://mise.jdx.dev/environments/#using-environment-variables)):

```shell
mise set MY_VAR=123
mise exec -- bash -c 'echo $MY_VAR'
# 123
```

Combined with tools:

```sh
mise use node@26
mise set MY_VAR=123
cat mise.toml
# [tools]
# node = '24'
# [env]
# MY_VAR = '123'
mise exec -- node --eval 'console.log(process.env.MY_VAR)'
# 123
```

With [mise activated](https://mise.jdx.dev/getting-started.html#activate-mise), vars are applied to the current shell on `cd`:

```shell
cd /path/to/project
mise set NODE_ENV=production
cat mise.toml
# [env]
# NODE_ENV = 'production'

echo $NODE_ENV
# production
```

With [shims](https://mise.jdx.dev/dev-tools/shims.html), the vars are present when the shim runs:

```shell
mise set NODE_ENV=production
mise use node@26
# using the absolute path for the example
~/.local/share/mise/shims/node --eval 'console.log(process.env.NODE_ENV)'
```

Per-task env ([environments](https://mise.jdx.dev/environments/#environment-in-tasks)):

```toml
[tasks.print]
run = "echo $MY_VAR"
env = { _.file = '/path/to/file.env', "MY_VAR" = "my variable" }
```

Status-line visibility: `status.show_env` — boolean, env `MISE_STATUS_MESSAGE_SHOW_ENV`, default `false` — "Show configured env vars when entering a directory with a mise.toml file." ([configuration/settings](https://mise.jdx.dev/configuration/settings.html))

Caching: `env_cache_ttl` — string, env `MISE_ENV_CACHE_TTL`, default `1h` — "How long cached environments remain valid before being regenerated… Even with a valid TTL, caches are still invalidated when config files, tool versions, settings, or watched files change." ([configuration/settings](https://mise.jdx.dev/configuration/settings.html))

---

### 6.8 CLI: `mise env`, `mise set`, `mise unset`, `mise en`

#### 6.8.1 `mise env`

* **Usage:** `mise env [FLAGS] [TOOL@VERSION]…` · **Alias:** `e` · **Effect:** read-only · [src/cli/env.rs](https://github.com/jdx/mise/blob/main/src/cli/env.rs)
* "Exports env vars to activate mise a single time. Use this if you don't want to permanently install mise. It's not necessary to use this if you have `mise activate` in your shell rc file."

| Flag | Meaning |
| --- | --- |
| `-D --dotenv` | Output in dotenv format |
| `-J --json` | Output in JSON format |
| `-s --shell <SHELL>` | Shell type to generate for: `bash`, `elvish`, `fish`, `nu`, `xonsh`, `zsh`, `pwsh` |
| `--json-extended` | JSON with additional information (source, tool) |
| `--redacted` | Only show redacted environment variables |
| `--values` | Only show values of environment variables |

Positional `[TOOL@VERSION]…` selects tool(s) to use. ([cli/env](https://mise.jdx.dev/cli/env.html))

```
eval "$(mise env -s bash)"
eval "$(mise env -s zsh)"
mise env -s fish | source
execx($(mise env -s xonsh))
```

`mise env` also exports "`PATH` and environment variables set by tools or plugins", not just `[env]` entries ([environments](https://mise.jdx.dev/environments/)).

#### 6.8.2 `mise set`

* **Usage:** `mise set [FLAGS] [ENV_VAR]…` · **Effect:** modifies state · [src/cli/set.rs](https://github.com/jdx/mise/blob/main/src/cli/set.rs)
* "Set environment variables in mise.toml. By default, this command modifies `mise.toml` in the current directory. If multiple config files exist (e.g., both `mise.toml` and `mise.local.toml`), the **lowest precedence** file (`mise.toml`) will be used." ([cli/set](https://mise.jdx.dev/cli/set.html))

| Flag | Meaning |
| --- | --- |
| `-E --env <ENV>` | Create/modify an environment-specific config file like `mise.<env>.toml` |
| `-g --global` | Set in the global config file |
| `--file <FILE>` | TOML file (or directory → `mise.toml` inside it) to update; defaults to `MISE_DEFAULT_CONFIG_FILENAME` or `mise.toml`; `MISE_GLOBAL_CONFIG_FILE` chooses a different global path |
| `--prompt` | Prompt for the value (keeps it out of shell history) |
| `--stdin` | Read the value from stdin until EOF (for multiline); pass a single key with no value |
| `--no-redact` | Show raw values instead of redacting secrets |
| `--age-encrypt` | [experimental] Encrypt the value with age before storing |
| `--age-key-file <PATH>` | [experimental] Age identity file for encryption (defaults to `~/.config/mise/age.txt` if it exists) |
| `--age-recipient… <RECIPIENT>` | [experimental] x25519 public key recipient; repeatable; requires `--age-encrypt` |
| `--age-ssh-recipient… <PATH_OR_PUBKEY>` | [experimental] SSH recipient (public key or path); repeatable; requires `--age-encrypt` |

```
$ mise set NODE_ENV=production

$ mise set NODE_ENV
production

$ mise set -E staging NODE_ENV=staging
# creates or modifies mise.staging.toml

$ mise set
key       value       source
NODE_ENV  production  ~/.config/mise/config.toml

$ mise set --prompt PASSWORD
Enter value for PASSWORD: [hidden input]
```

Multiline values:

```
$ cat private.key | mise set --stdin MY_KEY
$ printf "line1\nline2" | mise set --stdin MY_KEY
```

Round-trip from the environments guide ([environments](https://mise.jdx.dev/environments/)):

```sh
mise set NODE_ENV=development
# mise set NODE_ENV
# development

mise set
# key       value        source
# NODE_ENV  development  mise.toml

cat mise.toml
# [env]
# NODE_ENV = 'development'

mise unset NODE_ENV
```

#### 6.8.3 `mise unset`

* **Usage:** `mise unset [-f --file <FILE>] [-g --global] [ENV_KEY]…` · **Effect:** modifies state · [src/cli/unset.rs](https://github.com/jdx/mise/blob/main/src/cli/unset.rs)
* "Remove environment variable(s) from the config file. By default, this command modifies `mise.toml` in the current directory." ([cli/unset](https://mise.jdx.dev/cli/unset.html))

| Flag | Meaning |
| --- | --- |
| `-f --file <FILE>` | Use this file instead of `mise.toml`; defaults to `MISE_DEFAULT_CONFIG_FILENAME` or `mise.toml` |
| `-g --global` | Use the global config file |

```
# Remove NODE_ENV from the current directory's config
$ mise unset NODE_ENV

# Remove NODE_ENV from the global config
$ mise unset NODE_ENV -g
```

**Note the asymmetry:** `mise unset` *deletes the key from the config file*; `VAR = false` in `[env]` *actively unsets* a var that a lower-precedence config or the ambient shell had set.

#### 6.8.4 `mise en`

* **Usage:** `mise en [-s --shell <SHELL>] [DIR]` · [src/cli/en.rs](https://github.com/jdx/mise/blob/main/src/cli/en.rs)
* "Starts a new shell with the mise environment built from the current configuration. This is an alternative to `mise activate` that allows you to explicitly start a mise session. It will have the tools and environment variables in the configs loaded. **Note that changing directories will not update the mise environment.**" ([cli/en](https://mise.jdx.dev/cli/en.html))

| Arg / Flag | Default | Meaning |
| --- | --- | --- |
| `[DIR]` | `.` | Directory to start the shell in |
| `-s --shell <SHELL>` | `$SHELL` | Shell to start |

```
$ mise en .
$ node -v
v20.0.0

Skip loading bashrc:
$ mise en -s "bash --norc"

Skip loading zshrc:
$ mise en -s "zsh -f"
```

```shell
mise set FOO=bar
mise en
> echo $FOO
# bar
```

([environments](https://mise.jdx.dev/environments/))

---

### 6.9 Redactions

Per-entry, via `redact = true` ([environments](https://mise.jdx.dev/environments/#redactions)):

```toml
[env]
SECRET = { value = "my_secret", redact = true }
_.file = { path = ".env.json", redact = true }
```

Pattern-based, via a **top-level** `redactions` array (note: it sits outside `[env]`):

```toml
redactions = ["SECRET_*", "*_TOKEN", "PASSWORD"]
[env]
SECRET_KEY = "sensitive_value"
API_TOKEN = "token_123"
PASSWORD = "my_password"
```

Inspecting:

```bash
# Show only redacted environment variables
mise env --redacted

# Show only values (useful for piping)
mise env --values

# Show only values of redacted variables
mise env --redacted --values
```

**Gotcha — `raw = true` tasks bypass redaction.** "Redactions work by intercepting task output line-by-line, so they require a non-`raw` output mode. Tasks with `raw = true` bypass this interception (stdout/stderr are passed directly to the terminal), so redactions cannot be applied." ([environments](https://mise.jdx.dev/environments/#redactions))

**Gotcha — default `mise run` output mode hides logs.** "By default, `mise run` uses the `replacing` output mode which shows a progress spinner rather than full output. In CI environments, you may want to use `prefix` or `interleave` output instead so you can see full task logs while still having redactions applied":

```bash
MISE_TASK_OUTPUT=prefix mise run mytask
```

```toml
[settings]
task.output = "prefix"
```

**CI masking.** "Because mise may output sensitive values that could show up in CI logs you'll need to configure your CI setup to know which values are sensitive."

```bash
# In a GitHub Actions workflow
for value in $(mise env --redacted --values); do
  echo "::add-mask::$value"
done
```

[mise-action](https://github.com/jdx/mise-action) "will automatically redact values marked with `redact = true` or matching patterns in the `redactions` array." ([environments](https://mise.jdx.dev/environments/#redactions))

Decrypted age values "are always marked as redacted" automatically ([environments/secrets/age](https://mise.jdx.dev/environments/secrets/age.html#decryption-identities)).

---

### 6.10 Secrets

Three documented approaches ([environments/secrets](https://mise.jdx.dev/environments/secrets/)):

| Approach | Status | Shape |
| --- | --- | --- |
| [fnox](https://github.com/jdx/fnox) | **recommended** | "Full-featured secret manager with remote secret storage (e.g.: 1Password, AWS Secrets Manager) and remote encryption (e.g.: AWS KMS). This is a separate project by @jdx that works well alongside mise. **There's no direct integration with mise and fnox**, you set it up separately." |
| [sops](https://mise.jdx.dev/environments/secrets/sops.html) | **experimental** | "Encrypt entire files and load them via `env._.file`" |
| [Direct age encryption](https://mise.jdx.dev/environments/secrets/age.html) | **experimental** | "Encrypt individual env vars inline in `mise.toml`" |

#### 6.10.1 sops (experimental)

"mise reads encrypted secret files and makes values available as environment variables via `env._.file`." Formats: `.env.json`, `.env.yaml`, `.env.toml`. Encryption: [sops](https://getsops.io) backed by [age](https://github.com/FiloSottile/age) — "Currently age is the only sops encryption method supported." ([environments/secrets/sops](https://mise.jdx.dev/environments/secrets/sops.html))

Plaintext source:

```json
{
  "AWS_ACCESS_KEY_ID": "AKIAIOSFODNN7EXAMPLE",
  "AWS_SECRET_ACCESS_KEY": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}
```

Config — nothing special; "mise will automatically decrypt the file if it is sops-encrypted":

```toml
[env]
_.file = ".env.json"
```

End-to-end setup:

```sh
# 1. Install tools
mise use -g sops age

# 2. Generate an age key and note the public key
age-keygen -o ~/.config/mise/age.txt
# Public key: <public key>

# 3. Encrypt the file (-i overwrites in place; the encrypted file is safe to commit)
sops encrypt -i --age "<public key>" .env.json
```

"Set `SOPS_AGE_KEY_FILE=~/.config/mise/age.txt` or `MISE_SOPS_AGE_KEY_FILE=~/.config/mise/age.txt` to decrypt/edit with sops." Then `mise env` exposes the values.

Redaction:

```toml
[env]
_.file = { path = ".env.json", redact = true }
```

```yaml
- name: Mask secrets
  run: |
    for value in $(mise env --redacted --values); do
      echo "::add-mask::$value"
    done
- name: Use secrets safely
  run: |
    mise exec -- ./deploy.sh
```

**sops settings** ([environments/secrets/sops](https://mise.jdx.dev/environments/secrets/sops.html#settings)):

| Setting | Type / Default | Env var | Meaning |
| --- | --- | --- | --- |
| `sops.age_key` | `string` (optional) / `None` | `MISE_SOPS_AGE_KEY` | Age private key for sops decryption. Takes precedence over standard `SOPS_AGE_KEY` |
| `sops.age_key_file` | `string` / `~/.config/mise/age.txt` | `MISE_SOPS_AGE_KEY_FILE` | Path to age private key file. Takes precedence over standard `SOPS_AGE_KEY_FILE` |
| `sops.age_recipients` | `string` (optional) / `None` | `MISE_SOPS_AGE_RECIPIENTS` | Age public keys for sops encryption |
| `sops.rops` | `boolean` / `true` | `MISE_SOPS_ROPS` | Use rops to decrypt sops files. "Disable to shell out to `sops` which will slow down mise but sops may offer features not available in rops. Required for TOML SOPS files because the sops CLI does not support TOML." |
| `sops.strict` | `boolean` / `true` | `MISE_SOPS_STRICT` | "If true, fail when sops decryption fails (including when sops is not available, the key is missing, or the key is invalid). If false, skip decryption and continue" |

**Gotcha — TOML + external CLI.** "The external `sops` CLI does not currently support TOML input/output. mise can decrypt SOPS-encrypted `.env.toml` files only with the default `sops.rops = true` setting. If you set `sops.rops = false`, mise shells out to the `sops` CLI and encrypted TOML env files fail with a configuration error. Use `.env.json` or `.env.yaml` when you need the external CLI path." ([environments/secrets/sops](https://mise.jdx.dev/environments/secrets/sops.html#encrypt-with-sops))

#### 6.10.2 Direct age encryption (experimental)

"Encrypt individual environment variable values directly in `mise.toml` using [age](https://github.com/FiloSottile/age) encryption. **The age tool is not required—mise has support built-in.**" Defaults to your SSH key (`~/.ssh/id_ed25519` or `~/.ssh/id_rsa`) if present. ([environments/secrets/age](https://mise.jdx.dev/environments/secrets/age.html))

Properties: inline storage in `mise.toml`; multiple recipients (x25519 age keys and SSH recipients); automatic decryption at runtime when identities are available.

Quick start:

```bash
# 1. Enable experimental features
mise settings set experimental=true
```

```bash
# 2. [optional] Generate an age key if you don't want to use your ssh key
age-keygen -o ~/.config/mise/age.txt
# Note the public key output for encryption
```

```bash
# 3. Encrypt a value
mise set --age-encrypt --prompt DB_PASSWORD
# Enter value for DB_PASSWORD: [hidden input]
```

```toml
# 4. Stored encrypted in mise.toml as an age directive
[env]
DB_PASSWORD = { age = { value = "<base64>" } }
```

```bash
# 5. Decryption happens automatically
mise env  # Variables are decrypted automatically
```

> **Warning from the docs:** "It's recommended to use `--prompt` to avoid accidentally exposing the value to your shell history. You don't have to though, you can use `mise set --age-encrypt DB_PASSWORD="password123"`."

**CLI flags** ([environments/secrets/age](https://mise.jdx.dev/environments/secrets/age.html#cli-flags)):

| Flag | Meaning |
| --- | --- |
| `--age-encrypt` | Enable age encryption for the value |
| `--age-recipient <KEY>` | x25519 recipient (repeatable) |
| `--age-ssh-recipient <PATH\|KEY>` | SSH public key, or path to a `.pub`/private key (repeatable) |
| `--age-key-file <PATH>` | Use recipients derived from an age identity file |
| `--prompt` | Prompt for the value to keep it out of shell history |

**Storage format:** base64 plus a `format` field — `format = "raw"` (uncompressed, typically small values) or `format = "zstd"` (zstd-compressed, used when ciphertext > 1KB).

**Default recipients when `--age-encrypt` has no explicit recipients:** public keys corresponding to identities in `~/.config/mise/age.txt`, and public keys inferred from SSH private keys where a matching `.pub` exists. "If none are found, the command fails with an error asking you to provide recipients or configure `settings.age.key_file`."

**Strictness:** "Age decryption is strict by default. If no identities are found, no available identity can decrypt the value, or the age payload is invalid, mise fails instead of continuing with a partially resolved environment." Relax it with:

```bash
mise settings set age.strict=false
```

In non-strict mode "mise skips values that cannot be decrypted and continues resolving the rest of the environment."

**age settings** (all `[experimental]`) ([environments/secrets/age](https://mise.jdx.dev/environments/secrets/age.html#settings)):

| Setting | Type / Default | Env var | Meaning |
| --- | --- | --- | --- |
| `age.identity_files` | `string[]` (optional) / `None` | `MISE_AGE_IDENTITY_FILES` | List of age identity files used for decryption |
| `age.key_file` | `string` / `~/.config/mise/age.txt` | `MISE_AGE_KEY_FILE` | Path to the age private key file for encryption/decryption |
| `age.ssh_identity_files` | `string[]` (optional) / `None` | `MISE_AGE_SSH_IDENTITY_FILES` | List of SSH identity files used for age decryption |
| `age.strict` | `boolean` / `true` | `MISE_AGE_STRICT` | Fail when age decryption fails (unavailable/missing/invalid key); `false` skips and continues |

Closing notes from the page: "Feature is experimental; flags and behavior may change" and "`mise set KEY` will print the decrypted value".

---

### 6.11 direnv interop

The `direnv` page is marked **deprecated** and carries a blunt policy statement ([direnv](https://mise.jdx.dev/direnv.html)):

> "The official stance is you should not use direnv with mise. Issues arising from incompatibilities are not considered bugs and PRs to improve direnv compatibility will not be accepted. While that's the official stance, the reality is mise and direnv can coexist for simple cases like setting unrelated environment variables. Anything involving PATH — which is most of what people use both tools for — is where problems arise."

Why they collide: "they both analyze the current environment variables before and after their respective 'hook' commands are run." The failure mode is PATH ordering, and "it would really only be a problem if you were trying to manage the same tool with direnv and mise. For example, you may use `layout python` in an `.envrc` but also be maintaining a `.tool-versions` file with python in it as well." Setting arbitrary env vars, or adding unrelated binaries to PATH, is fine — "mise will not interfere with direnv."

#### Direction 1 — mise inside direnv (`use mise`) — **deprecated and no longer supported**

The docs explicitly state: "`use mise` is deprecated and no longer supported." The historical recipe, retained on the page:

```sh
mise direnv activate > ~/.config/direnv/lib/use_mise.sh
```

```sh
# .envrc
use mise
```

Caveats documented for that mode:

* "direnv will now call mise to export its environment variables. You'll need to make sure to add `use_mise` to all projects that use mise (or use direnv's `source_up` to load it from a subdirectory). You can also add `use mise` to `~/.config/direnv/direnvrc`."
* "direnv typically won't know to refresh `.tool-versions` files unless they're at the same level as a `.envrc` file. You'll likely always want to have a `.envrc` file next to your `.tool-versions` for this reason."
* Suggested workaround: skip `.tool-versions` entirely and set versions via env vars in `.envrc`:

```sh
export MISE_NODE_VERSION=20.0.0
export MISE_PYTHON_VERSION=3.11
```

* It may be *required* "if you want to use direnv's `layout python` with mise. Otherwise there are situations where mise will override direnv's PATH. `use mise` ensures that direnv always has control."

> **Uncertainty:** `mise direnv activate` is referenced by the direnv page, but there is no published CLI reference page for it (`https://mise.jdx.dev/cli/direnv.html` and `/cli/direnv/activate.html` both return HTTP 404, and `direnv` does not appear in the CLI index). Treat the subcommand as undocumented/legacy surface area.

#### Direction 2 — direnv inside mise

Not offered as an integration. The page's counter-proposal is to drop direnv: "mise is capable of replacing direnv for most use-cases. This is why mise includes support for managing env vars and [virtualenv](https://mise.jdx.dev/lang/python.html#automatic-virtualenv-activation) for python using `mise.toml`." If `mise activate` still misbehaves, "you can also try using the [shims method](https://mise.jdx.dev/dev-tools/shims.html)."

---

### 6.12 Hooks

> "You can have mise automatically execute scripts during a `mise activate` session. You cannot use these without the `mise activate` shell hook installed in your shell—except the `preinstall` and `postinstall` hooks. The configuration goes into `mise.toml`." ([hooks](https://mise.jdx.dev/hooks.html))

#### 6.12.1 Hook catalogue

| Hook | Fires | Needs `mise activate`? |
| --- | --- | --- |
| `cd` | "anytime the directory is changed" | Yes |
| `enter` | "when the project is entered. Changing directories while in the project will not trigger this hook again" | Yes |
| `leave` | "when the project is left. Changing directories while in the project will not trigger this hook" | Yes |
| `preinstall` | before tools are installed | **No** |
| `postinstall` | after tools are installed | **No** |

```toml
[hooks]
cd = "echo 'I changed directories'"
enter = "echo 'I entered the project'"
leave = "echo 'I left the project'"
preinstall = "echo 'I am about to install tools'"
postinstall = "echo 'I just installed tools'"
```

#### 6.12.2 Inline `run` hooks (subprocess)

"String hooks are shorthand for `run` hooks", i.e. `enter = "echo hi"` ≡ `{ run = "echo hi" }`. Use a table to pick the inline shell ([hooks](https://mise.jdx.dev/hooks.html)):

```toml
[hooks]
postinstall = { run = "echo 'installed'", shell = "bash -c" }
```

`run` hooks execute in a subprocess using the default inline shell — [`unix_default_inline_shell_args`](https://mise.jdx.dev/configuration/settings.html#unix_default_inline_shell_args) or [`windows_default_inline_shell_args`](https://mise.jdx.dev/configuration/settings.html#windows_default_inline_shell_args). The `shell` value "should include both the program and the argument that evaluates the inline command such as `bash -c`, `zsh -c`, or `pwsh -Command`."

Windows variants, like tasks:

```toml
[hooks]
postinstall = { run = "echo installed", run_windows = "Write-Output installed" }
```

"On Windows, mise uses `run_windows` when it is set; otherwise it uses `run`. On other platforms, a hook with only `run_windows` is skipped."

**`run` must be a string.** "`run = ["echo one", "echo two"]` is not supported." To get multiple subprocesses, use multiple hook entries (one subprocess per `run`):

```toml
[hooks]
enter = [
  { run = "echo one" },
  { run = "echo two" },
]
```

To get one subprocess with multiple lines, use a multiline string:

```toml
[hooks.enter]
run = """
echo one
echo two
"""
```

#### 6.12.3 Shell hooks (current shell)

`enter`, `leave`, and `cd` "can be executed in the current shell, for example if you'd like to add bash completions when entering a directory" ([hooks](https://mise.jdx.dev/hooks.html#shell-hooks)):

```toml
[hooks.enter]
shell = "bash"
script = "source completions.sh"
```

Current-shell hooks may use `script`/`scripts` arrays:

```toml
[hooks.enter]
shell = "bash"
script = [
  "source completions.sh",
  "export PROJECT_READY=1",
]

[hooks.leave]
shell = "bash"
scripts = [
  "unset PROJECT_READY",
]
```

**The key distinction — two different meanings of `shell`:**

| Style | `shell` value | Execution |
| --- | --- | --- |
| `run` (+ optional `shell`) | An *inline shell command*, e.g. `bash -c`, `pwsh -Command` | Subprocess |
| `script`/`scripts` (+ `shell`) | A *shell-name selector*, e.g. `bash`, `zsh`, `fish` | Current shell — "mise only prints the script when the active `mise activate` shell matches" |

"`preinstall` and `postinstall` do not have a current shell, so `script`/`scripts` are only kept there as legacy aliases for `run`; if `shell` is set with `script`/`scripts` on those hooks, it is ignored" (mise warns and runs with the default inline shell). The `script`/`scripts` aliases for install hooks are **deprecated**. ([hooks](https://mise.jdx.dev/hooks.html))

> **Warning from the docs (verbatim intent):** current-shell hooks do no cleanup on leave the way `[env]` does — "You're literally just executing shell code when you enter the directory which mise has no way to track at all."

#### 6.12.4 Task hooks

"Instead of inline scripts, hooks can reference mise tasks. The task is executed as a subprocess via `mise run`, so it reuses the full task system including dependencies, environment variables, and file-based task definitions." ([hooks](https://mise.jdx.dev/hooks.html#task-hooks))

```toml
[tasks.setup]
run = "echo 'setting up project'"
depends = ["install-deps"]

[hooks]
enter = { task = "setup" }
```

Mixing is allowed, and task hooks "work with all hook types (`enter`, `leave`, `cd`, `preinstall`, `postinstall`)":

```toml
[hooks]
enter = ["echo 'entering project'", { task = "setup" }]
```

#### 6.12.5 Install hooks and `MISE_INSTALLED_TOOLS`

"A `mise install` that finds nothing to install (all configured tools are already present) still runs the `postinstall` hook — it is not skipped on a no-op install." The hook receives `MISE_INSTALLED_TOOLS`, "a JSON array of the tools that were just installed, or `[]` when nothing was installed". Guard on it: ([hooks](https://mise.jdx.dev/hooks.html#preinstall-postinstall-hook))

```toml
[hooks]
postinstall = '''
echo "Installed: $MISE_INSTALLED_TOOLS"
# Example output: [{"name":"node","version":"20.10.0"},{"name":"python","version":"3.12.0"}]
'''
```

#### 6.12.6 Tool-level `postinstall`

Distinct from `[hooks]`: individual tools can define their own postinstall, which runs "immediately after each tool is installed (before other tools in the same session are installed)" ([hooks](https://mise.jdx.dev/hooks.html#tool-level-postinstall)):

```toml
[tools]
node = { version = "20", postinstall = "npm install -g pnpm" }
python = { version = "3.12", postinstall = "pip install pipx" }
```

Variables provided to tool-level postinstall scripts:

| Variable | Meaning |
| --- | --- |
| `MISE_TOOL_NAME` | Short name of the tool (e.g. `node`, `python`) |
| `MISE_TOOL_VERSION` | Version installed (e.g. `20.10.0`, `3.12.0`) |
| `MISE_TOOL_INSTALL_PATH` | Path where the tool was installed |
| *(plus)* | Variables from that tool's `install_env` option |

#### 6.12.7 Hook execution environment

All hooks run with ([hooks](https://mise.jdx.dev/hooks.html#hook-execution)):

| Variable | Meaning |
| --- | --- |
| `MISE_ORIGINAL_CWD` | The directory that the user is in |
| `MISE_PROJECT_ROOT` | The root directory of the project |
| `MISE_PREVIOUS_DIR` | The directory the user was in before the change (only if a directory change occurred) |
| `MISE_INSTALLED_TOOLS` | JSON array of installed tools (only for `postinstall`) |

#### 6.12.8 Multiple hooks syntax

```toml
[hooks]
enter = [
  "echo 'I entered the project'",
  { run = "echo 'I am in the project'" }
]

[[hooks.cd]]
run = "echo 'I changed directories'"
[[hooks.cd]]
run = "echo 'I also changed directories'"
```

([hooks](https://mise.jdx.dev/hooks.html#multiple-hooks-syntax))

---

### 6.13 Shell aliases

"mise can manage shell aliases that are set dynamically when you enter a directory and unset when you leave, similar to how environment variables work." Defined under `[shell_alias]` ([shell-aliases](https://mise.jdx.dev/shell-aliases.html)):

```toml
[shell_alias]
ll = "ls -la"
la = "ls -A"
gs = "git status"
gc = "git commit"
```

Lifecycle:

1. **Set on entry** — `cd` into a directory with `[shell_alias]` config
2. **Updated on change** — if the value changes in config
3. **Unset on exit** — when you leave, or the alias is removed from config

```bash
$ cd ~/myproject
# mise sets: alias ll='ls -la'

$ ll
# Runs: ls -la

$ cd ~
# mise runs: unalias ll
```

Shell support: **bash** and **zsh** use `alias`/`unalias`; **fish** uses `alias`/`functions -e`. "Other shells (nushell, elvish, xonsh, powershell) do not currently support shell aliases."

> **Uncertainty:** the same page contradicts itself — the *Supported Shells* section lists bash, zsh, fish and explicitly excludes xonsh, while the *Limitations* section says "Only bash, zsh, fish, and xonsh are supported." Check the [shell feature compatibility matrix](https://mise.jdx.dev/getting-started.html#shell-feature-compatibility) before relying on xonsh. ([shell-aliases](https://mise.jdx.dev/shell-aliases.html))

Hierarchy behaves like other config — parent-directory aliases are available in children, and children override:

```toml
# ~/projects/mise.toml
[shell_alias]
build = "make build"

# ~/projects/myapp/mise.toml
[shell_alias]
build = "npm run build"  # Overrides parent
```

Values support [templates](https://mise.jdx.dev/templates.html):

```toml
[shell_alias]
proj = "cd {{config_root}}"
node_version = "echo {{exec(command='node --version')}}"
src = "cd {{config_root}}/src"
tests = "cd {{config_root}}/tests"
docs = "cd {{config_root}}/docs"
```

Typical uses — project shortcuts and tool wrappers:

```toml
[shell_alias]
dev = "npm run dev"
test = "npm test"
build = "npm run build"
deploy = "./scripts/deploy.sh"
docker-compose = "docker compose -f docker-compose.dev.yml"
terraform = "terraform -chdir=./infrastructure"
```

**Gotcha — not available in tasks.** "Shell aliases are only active in interactive shells where `mise activate` is running. They are **not** available inside TOML task `run` blocks or file tasks, since tasks run in non-interactive subshells. Use the underlying command directly in tasks, or add wrapper scripts to your `PATH` via [env._.path](https://mise.jdx.dev/environments/#path)."

**Do not confuse with tool aliases** ([shell-aliases](https://mise.jdx.dev/shell-aliases.html#comparison-to-tool-aliases)):

| Feature | Purpose | Config Key |
| --- | --- | --- |
| Shell Aliases | Define shell command shortcuts (`alias ll='ls -la'`) | `[shell_alias]` |
| Tool Aliases | Define version aliases for tools (`node@lts` → `20.x`) | `[tool_alias]` |

See [Tool Aliases](https://mise.jdx.dev/dev-tools/aliases.html) for the latter.

#### `mise shell-alias` CLI

* **Usage:** `mise shell-alias [--no-header] <SUBCOMMAND>` · read-only · [src/cli/shell_alias/mod.rs](https://github.com/jdx/mise/blob/main/src/cli/shell_alias/mod.rs) ([cli/shell-alias](https://mise.jdx.dev/cli/shell-alias.html))

| Subcommand | Aliases | Effect | Notes |
| --- | --- | --- | --- |
| `mise shell-alias get <shell_alias>` | — | read-only | "Show the command for a shell alias" ([get](https://mise.jdx.dev/cli/shell-alias/get.html)) |
| `mise shell-alias ls [--no-header]` | `list` | read-only | "Shows the shell aliases that are set in the current directory. These are defined in `mise.toml` under the `[shell_alias]` section." ([ls](https://mise.jdx.dev/cli/shell-alias/ls.html)) |
| `mise shell-alias set <shell_alias> [COMMAND]` | `add`, `create` | modifies state | "Add/update a shell alias. **This modifies the contents of `~/.config/mise/config.toml`**" ([set](https://mise.jdx.dev/cli/shell-alias/set.html)) |
| `mise shell-alias unset <shell_alias>` | `rm`, `remove`, `delete`, `del` | modifies state | "Removes a shell alias. **This modifies the contents of `~/.config/mise/config.toml`**" ([unset](https://mise.jdx.dev/cli/shell-alias/unset.html)) |

```
$ mise shell-alias get ll
ls -la

$ mise shell-alias ls
alias    command
ll       ls -la
gs       git status

mise shell-alias set ll "ls -la"
mise shell-alias set gs "git status"
mise shell-alias unset ll
```

**Asymmetry gotcha:** unlike `mise set`/`mise unset` (which default to `mise.toml` in the *current directory*), `mise shell-alias set`/`unset` write to the **global** `~/.config/mise/config.toml`. `[COMMAND]` is "optional if provided as ALIAS=COMMAND". ([cli/shell-alias/set](https://mise.jdx.dev/cli/shell-alias/set.html))

---

### 6.14 File watching

Two separate mechanisms: a declarative `[[watch_files]]` hook driven by `mise activate`, and the imperative `mise watch` command driven by watchexec.

#### 6.14.1 `[[watch_files]]` (activate-driven)

"While using `mise activate` you can have mise watch files for changes and execute a script or task when a file changes." ([hooks](https://mise.jdx.dev/hooks.html#watch-files-hook))

```toml
[[watch_files]]
patterns = ["src/**/*.rs"]
run = "cargo fmt"
```

```toml
[[watch_files]]
patterns = ["*.js"]
run = "eslint --fix ."
shell = "bash -c"
```

```toml
[[watch_files]]
patterns = ["uv.lock"]
task = "sync-deps"
```

| Key | Meaning |
| --- | --- |
| `patterns` | Glob patterns to watch |
| `run` | Inline command, executed with [`unix_default_inline_shell_args`](https://mise.jdx.dev/configuration/settings.html#unix_default_inline_shell_args) / [`windows_default_inline_shell_args`](https://mise.jdx.dev/configuration/settings.html#windows_default_inline_shell_args) by default |
| `shell` | Inline shell command override, e.g. `bash -c`; "`shell` only applies to `run` hooks" |
| `task` | Reference a mise task instead of an inline script |

"Each `[[watch_files]]` entry should have either `run` or `task`, but not both."

Hook env: `MISE_WATCH_FILES_MODIFIED` — "A colon-separated list of the files that have been modified. Colons are escaped with a backslash."

#### 6.14.2 `mise watch`

* **Usage:** `mise watch [FLAGS] [TASK] [ARGS]…` · **Alias:** `w` · [src/cli/watch.rs](https://github.com/jdx/mise/blob/main/src/cli/watch.rs)
* "Run task(s) and watch for changes to rerun it. This command uses the `watchexec` tool to watch for changes and rerun the specified task(s). **It must be installed for this command to work**, but you can install it with `mise use -g watchexec@latest`." ([cli/watch](https://mise.jdx.dev/cli/watch.html))
* Multiple tasks are separated with `:::` — e.g. `mise run task1 arg1 arg2 ::: task2 arg1 arg2`.
* Pointer for heavier process management (daemons, auto-restart, readiness checks, cron): mise's sister project <https://pitchfork.jdx.dev>.

Most of the flag surface is watchexec's, passed straight through. The mise-owned and highest-value flags:

| Flag | Default | Meaning |
| --- | --- | --- |
| `--skip-deps` | — | Run only the specified tasks, skipping all dependencies |
| `-w --watch… <PATH>` | cwd | Watch a specific file or directory (repeatable). Special value `/dev/null` as the only path disables path watching |
| `-W --watch-non-recursive… <PATH>` | — | Watch a directory without recursing |
| `-F --watch-file <PATH>` | — | Read watched paths from a file, one per line (`-` = stdin, incompatible with `--stdin-quit`) |
| `-c --clear <MODE>` | — | `clear` \| `reset` — clear the screen before running |
| `-o --on-busy-update <MODE>` | `do-nothing` | `queue` \| `do-nothing` \| `restart` \| `signal` — what to do when events arrive mid-run |
| `-r --restart` | — | Shorthand for `--on-busy-update=restart` |
| `-s --signal <SIGNAL>` | — | Signal to send when still running; implies `--on-busy-update=signal` |
| `--stop-signal <SIGNAL>` | `SIGTERM` (unix) | Signal used to stop the command for `restart`/`signal` modes |
| `--stop-timeout <TIMEOUT>` | `10s` | Grace period before force-kill; `0` = immediate force-kill |
| `-d --debounce <TIMEOUT>` | `50ms` | Wait window before acting on events. "Setting to 0 is highly discouraged" |
| `-p --postpone` | — | Wait for the first change before running (default is to run once immediately) |
| `--delay-run <DURATION>` | — | Sleep before running the command after an event |
| `--poll <INTERVAL>` | 30s if bare | Poll instead of native FS watching (aliased `--force-poll`) |
| `-e --exts… <EXTENSIONS>` | — | Filter to filename extensions (`js` or `.js`, comma-separated or repeated) |
| `-f --filter… <PATTERN>` | — | Glob-like include filter (repeatable) |
| `-i --ignore… <PATTERN>` | — | Glob-like exclude filter (repeatable) |
| `--filter-file… <PATH>` / `--ignore-file… <PATH>` | — | Load filters/ignores from files (also `$WATCHEXEC_FILTER_FILES` / `$WATCHEXEC_IGNORE_FILES`) |
| `--fs-events… <EVENTS>` | `create,remove,rename,modify,metadata` | Restrict to event kinds (`access`, `create`, `remove`, `rename`, `modify`, `metadata`) |
| `--no-meta` | — | Shorthand for `--fs-events create,remove,rename,modify`; not allowed together with `--fs-events` |
| `--no-vcs-ignore` / `--no-project-ignore` / `--no-global-ignore` / `--no-default-ignore` | — | Selectively stop loading ignore sources |
| `--no-discover-ignore` | — | Shorthand for the first three, and skips discovery entirely |
| `--ignore-nothing` | — | Shorthand for `--no-discover-ignore` + `--no-default-ignore` |
| `--shell <SHELL>` | `$SHELL` or `sh` (unix); `pwsh`/`powershell`/`cmd` (Windows) | Shell used to run the command; `none` disables shell use |
| `-n` | — | Shorthand for `--shell=none` |
| `--emit-events-to <MODE>` | `none` | `environment` (deprecated) \| `stdio` \| `file` \| `json-stdio` \| `json-file` \| `none` |
| `--only-emit-events` | — | Emit events to stdout and run no commands; requires `--emit-events-to` restricted to `stdio`/`json-stdio` |
| `-E --env… <KEY=VALUE>` | — | Add env vars to the command without setting them on watchexec itself (repeatable) |
| `--wrap-process <MODE>` | session (macOS) / group (other unix) / Job Object (Windows) | `group` \| `session` \| `none` |
| `--project-origin <DIRECTORY>` | discovered | Override project origin (also faster — skips discovery) |
| `--workdir <DIRECTORY>` | watchexec's cwd | Working directory for the command |
| `--stdin-quit` | — | Exit when stdin closes |
| `-N --notify` | — | Desktop notification on command start/end |
| `--color <MODE>` | `auto` | `auto` \| `always` \| `never`; `NO_COLOR` ≡ `--color=never` |
| `--timings` / `-q --quiet` / `--bell` / `--print-events` / `--manual` | — | Timing output / suppress start-stop messages / terminal bell / print triggering events / show the man page |
| `-J --filter-prog… <EXPRESSION>` | — | **[experimental]** jaq (jq-like) filter programs; "may change and/or vanish without notice" |
| `--map-signal… <SIGNAL:SIGNAL>` | — | Translate OS signals to signals sent to the command, e.g. `TERM:INT`, or `TERM:` to discard |

([cli/watch](https://mise.jdx.dev/cli/watch.html))

Documented examples:

```
$ mise watch build
Runs the "build" tasks. Will re-run the tasks when any of its sources change.
Uses "sources" from the tasks definition to determine which files to watch.

$ mise watch build --glob src/**/*.rs
Runs the "build" tasks but specify the files to watch with a glob pattern.
This overrides the "sources" from the tasks definition.

$ mise watch build --clear
Extra arguments are passed to watchexec. See `watchexec --help` for details.

$ mise watch serve --watch src --exts rs --restart
Starts an api server, watching for changes to "*.rs" files in "./src" and kills/restarts the server when they change.
```

The important default: with no `-w`/`-f`, **`mise watch <task>` derives the watch set from the task's `sources`**.

> **Uncertainty:** the examples use `mise watch build --glob src/**/*.rs`, but `--glob` does not appear anywhere in the flag reference on the same page (the documented pattern filters are `-f --filter`, `-e --exts`, `-i --ignore`). Either the flag is undocumented or the example is stale — verify with `mise watch --help` before scripting it. ([cli/watch](https://mise.jdx.dev/cli/watch.html))

Windows caveats carried over from watchexec: "Signals are not supported on Windows at the moment, and will always be overridden to 'kill'"; `--stop-timeout` "has no practical effect on Windows as the command is always forcefully terminated". Unit-less values for `--debounce`, `--stop-timeout`, `--delay-run`, and `--poll` are deprecated and warn.

---

### 6.15 Quick gotcha index

| Symptom | Cause / fix | Source |
| --- | --- | --- |
| `MISE_DATA_DIR` in `[env]` has no effect | mise-configuring vars are read at process start; set them in the shell/CI env | [environments](https://mise.jdx.dev/environments/#lazy-eval) |
| `MISE_ENV` / `auto_env` in `mise.toml` has no effect | Both are early-init; use `.miserc.toml` or the environment variable | [configuration/environments](https://mise.jdx.dev/configuration/environments.html) |
| `{{env.GEM_HOME}}` empty in `_.path` | Env resolves before tools; add `tools = true` | [environments](https://mise.jdx.dev/environments/#lazy-eval) |
| Literal `$` mangled (or *not* expanded) in a JSON/YAML/TOML env file | Structured files disable expansion by default; opt in with `expand = true`, global switch is `env_shell_expand` | [environments](https://mise.jdx.dev/environments/#env-file) |
| Secrets leak in CI logs | Use `redact`/`redactions` + `mise env --redacted --values` and CI masking; not applied for `raw = true` tasks | [environments](https://mise.jdx.dev/environments/#redactions) |
| Encrypted `.env.toml` fails to decrypt | You set `sops.rops = false`; the sops CLI has no TOML support | [sops](https://mise.jdx.dev/environments/secrets/sops.html) |
| `mise env` errors out on an undecryptable age value | Age is strict by default; `mise settings set age.strict=false` to skip and continue | [age](https://mise.jdx.dev/environments/secrets/age.html) |
| Venv's `python` not on PATH | Shims alone don't activate venvs; needs `mise activate` or `mise exec` | [lang/python](https://mise.jdx.dev/lang/python.html#python-venv-configuration) |
| `python.uv_venv_auto` does nothing | No `uv.lock` found; run `uv sync`/`uv lock` first | [lang/python](https://mise.jdx.dev/lang/python.html#python-uv-venv-auto-setting) |
| Alias works interactively, not in a task | Shell aliases require an interactive `mise activate` shell; use `env._.path` wrappers | [shell-aliases](https://mise.jdx.dev/shell-aliases.html) |
| `mise shell-alias set` edited the wrong file | It always writes `~/.config/mise/config.toml`, unlike `mise set` | [cli/shell-alias/set](https://mise.jdx.dev/cli/shell-alias/set.html) |
| Shell hook state survives after leaving the directory | Current-shell `script` hooks do no teardown; add an explicit `leave` hook | [hooks](https://mise.jdx.dev/hooks.html#shell-hooks) |
| `run = ["a", "b"]` rejected in a hook | `run` must be a string; use multiple hook entries or a multiline string | [hooks](https://mise.jdx.dev/hooks.html#hook-execution) |
| `mise watch` fails immediately | `watchexec` not installed: `mise use -g watchexec@latest` | [cli/watch](https://mise.jdx.dev/cli/watch.html) |
| PATH fights between mise and direnv | Officially unsupported combination; drop direnv or use shims | [direnv](https://mise.jdx.dev/direnv.html) |
| `mise en` env doesn't update after `cd` | By design — "changing directories will not update the mise environment" | [cli/en](https://mise.jdx.dev/cli/en.html) |

---

## 7. Tasks

mise doubles as a project task runner. Tasks run with the mise environment already applied — the tools from `[tools]` are on `PATH` and the vars from `[env]` are exported — and they get parallel dependency execution, last-modified staleness checking, and file watching with essentially no configuration ([tasks](https://mise.jdx.dev/tasks/)).

There are exactly two ways to define a task:

| Form | Where | Best for |
| --- | --- | --- |
| **TOML task** | `[tasks.<name>]` in `mise.toml`, or an included `*.toml` task file | short commands, dependency-only aggregator tasks, `tools`/`env` overrides |
| **File task** | an executable file in `mise-tasks/`, `.mise-tasks/`, `mise/tasks/`, `.mise/tasks/`, `.config/mise/tasks/` | real scripts — you get editor syntax highlighting, shellcheck, and the script still works for non-mise users |

([tasks](https://mise.jdx.dev/tasks/), [tasks/file-tasks](https://mise.jdx.dev/tasks/file-tasks.html))

```toml
# mise.toml
[tasks.build]
description = "Build the CLI"
run = "cargo build"
```

```bash
# mise-tasks/build
#!/usr/bin/env bash
#MISE description="Build the CLI"
cargo build
```

Both are invoked identically: `mise run build` (or the shorthand `mise build`).

### 7.1 Environment variables mise passes into every task

| Variable | Meaning |
| --- | --- |
| `MISE_ORIGINAL_CWD` | The directory the user was in when the task was invoked (tasks otherwise run from `config_root`) |
| `MISE_CONFIG_ROOT` | Directory containing the `mise.toml` that defined the task. For `~/src/myproj/.config/mise.toml` this is `~/src/myproj`, not `.config` |
| `MISE_PROJECT_ROOT` | Root of the project that defines the task. For monorepo subproject tasks this is the **subproject's** directory and is stable regardless of the invocation directory |
| `MISE_MONOREPO_ROOT` | Root of the monorepo (the directory with `monorepo_root = true`). Only set inside a monorepo |
| `MISE_TASK_NAME` | Name of the task being run |
| `MISE_TASK_DIR` | Directory containing the task script |
| `MISE_TASK_FILE` | Full path to the task script |

([tasks](https://mise.jdx.dev/tasks/#environment-variables-passed-to-tasks))

---

### 7.2 TOML tasks — complete key reference

Trivial tasks can be one-liners; detailed tasks get a table. All of these are equivalent forms of `run` ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#run)):

```toml
tasks.a = "echo hello"
tasks.b = ["echo hello"]
tasks.c.run = "echo hello"
[tasks.d]
run = "echo hello"
[tasks.e]
run = ["echo hello"]
```

#### 7.2.1 Execution keys

| Key | Type | Default | Meaning |
| --- | --- | --- | --- |
| `run` | `string \| (string \| { task, args?, env? } \| { tasks: string[] })[]` | — (**required**) | Command(s) to run. Array entries run **in series**; a failing entry stops the task. Entries may be shell strings, a single task reference, or `{ tasks = [...] }` for a parallel group |
| `run_windows` | same as `run` | unset | Windows-specific replacement for `run`, supporting the identical structured syntax |
| `file` | `string` | unset | Execute an external script instead of an inline `run`. Accepts a local path, an `http(s)://` URL, or a `git::` URL |
| `shell` | `string` | `unix_default_inline_shell_args` / `windows_default_inline_shell_args` | Shell command used for inline `run` strings, e.g. `"bash -c"`, `"node -e"`, `"pwsh"`. **TOML tasks only** |
| `dir` | `string` | `"{{ config_root }}"` | Working directory. `dir = "{{cwd}}"` runs in the user's invocation directory |
| `env` | `{ [key]: string \| int \| bool }` | `{}` | Env vars for this task only. **Not** propagated to `depends` tasks |
| `vars` | table (same directive forms as `[env]`) | `{}` | Task-local Tera vars that override config `[vars]`; referenced as `{{vars.NAME}}`, never exported to the process |
| `tools` | `{ [key]: string }` | `{}` | Tools installed/activated for this task only (not for its dependencies), e.g. `tools.rust = "1.50.0"` |
| `timeout` | `string` | unset (inherits `task.timeout`) | Per-task timeout, e.g. `"30s"`, `"5m"`. When both global and per-task timeouts exist, the **shorter** wins |
| `extends` | `string` | unset | Name of a `[task_templates.*]` entry to inherit from (see §7.9) |

([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#run), [mise-task.json schema](https://mise.jdx.dev/schema/mise-task.json), [tasks/toml-tasks](https://mise.jdx.dev/tasks/toml-tasks.html#using-a-file-or-remote-script))

```toml
[tasks.grouped]
run = [
  { task = "t1" },          # run t1 (with its dependencies)
  { task = "build", args = ["--release"], env = { RUSTFLAGS = "-C opt-level=3" } },
  { tasks = ["t2", "t3"] }, # run t2 and t3 in parallel (with their dependencies)
  "echo end",               # then run a script
]
```

#### 7.2.2 Metadata & discovery keys

| Key | Type | Default | Meaning |
| --- | --- | --- | --- |
| `description` | `string` | `""` | Shown in `mise tasks`, completions, `--help`, and the interactive `mise run` picker |
| `alias` | `string \| string[]` | `[]` | Alternate name(s): `alias = 'b'` → `mise run b` |
| `hide` | `bool` | `false` | Hide from `mise tasks`, help, and completions. Use for deprecated/internal tasks. Reveal with `mise tasks --hidden` |
| `confirm` | `string \| { message: string, default: "yes"\|"no"\|"y"\|"n"\|"true"\|"false" }` | unset | Prompt before running. Supports Tera and `{{ usage.* }}` |
| `usage` | `string` | `""` | [usage](https://usage.jdx.dev) spec defining args/flags/completions (see §7.5). **TOML tasks only** — file tasks use `#USAGE` comments |

([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#description), [mise-task.json schema](https://mise.jdx.dev/schema/mise-task.json))

> **Gotcha:** `confirm` guards **only** the task's own `run`. `depends` tasks execute **before** the prompt appears. To confirm before dependencies, put `confirm` on the dependency tasks or replace `depends` with `run = [{ task = "..." }]` ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#confirm)).

```toml
[tasks.deploy]
usage = '''
arg "<environment>" help="Environment to deploy to"
flag "--force" help="Force deployment"
'''
confirm = "Deploy to {{ usage.environment }}?{% if usage.force %} (forced){% endif %}"
run = "deploy.sh ${usage_environment}"
```

#### 7.2.3 Dependency keys

| Key | Type | Default | Meaning |
| --- | --- | --- | --- |
| `depends` | `string \| (string \| string[] \| { task, args?, env?, optional? })[]` | `[]` | Hard prerequisites — added to the run and executed first. Shared deps run once; independents run in parallel up to `--jobs` |
| `depends_post` | same | `[]` | Run **after** this task and its dependencies complete (per architecture docs: whether it succeeded or failed) |
| `wait_for` | same | `[]` | Soft ordering: waits for these tasks **only if they are already scheduled**; never adds them to the run |

([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#depends), [tasks/architecture](https://mise.jdx.dev/tasks/architecture.html#dependency-types))

**Four dependency spellings, all valid:**

```toml
[tasks.check]
depends = [
  "lint",                                        # bare name
  "build --release",                             # name + inline args
  "NODE_ENV=test setup",                         # shell-style inline env
  { task = "test", env = { CI = "true" }, args = ["--fast"], optional = true },
]
```

| Sub-field of the structured form | Type | Meaning |
| --- | --- | --- |
| `task` | `string` | Task name or wildcard pattern (**required**) |
| `args` | `string[]` | Arguments passed to that dependency |
| `env` | `{ [k]: string }` | Env vars passed **only** to that dependency — not to the current task or sibling deps |
| `optional` | `bool` | Do not fail when the name/pattern matches nothing. Invalid *patterns* still error |

([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#passing-environment-variables-to-dependencies), [mise-task.json schema](https://mise.jdx.dev/schema/mise-task.json))

**`wait_for` matching precision** ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#wait-for)):

| Written as | Matches |
| --- | --- |
| `wait_for = ["setup"]` | any scheduled `setup`, regardless of args or env overrides (so `depends = ["DEBUG=1 setup"]` elsewhere still matches) |
| `wait_for = ["setup arg1"]` / `["DEBUG=1 setup"]` | only tasks running with that **exact** args/env configuration |

**Forwarding parent args to dependencies** requires a `usage` spec on *both* tasks; `{{usage.*}}` works in `depends`, `depends_post`, and `wait_for` ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#passing-parent-task-arguments-to-dependencies)):

```toml
[tasks.build]
usage = 'arg "<app>"'
run = 'echo "building {{usage.app}}"'

[tasks.deploy]
usage = 'arg "<app>"'
depends = [{ task = "build", args = ["{{usage.app}}"] }]   # or: depends = ["build {{usage.app}}"]
run = 'echo "deploying {{usage.app}}"'
```

Arguments flow transitively: A→B→C each forwards its own resolved arguments.

#### 7.2.4 I/O, verbosity, and terminal keys

| Key | Type | Default | Meaning |
| --- | --- | --- | --- |
| `quiet` | `bool` | `false` | Suppress **mise's own** chatter (`[build] $ cargo build`). A *verbosity* setting — since the split, it no longer forces un-prefixed output, so `output = "prefix"` + `quiet = true` keeps prefixes |
| `silent` | `bool \| "stdout" \| "stderr"` | `false` | Suppress all task output, or just one stream |
| `output` | `"prefix" \| "interleave" \| "keep-order" \| "replacing" \| "timed" \| "quiet" \| "silent"` | unset (inherits global `task.output`) | Per-task output **style**. Orthogonal to `quiet`/`silent`. The `quiet`/`silent` *values* are legacy bundles of style+verbosity |
| `raw` | `bool` | `false` | Connect the task straight to the shell's stdin/stdout/stderr. Forces `jobs = 1` globally and **disables redactions**. Discouraged |
| `raw_args` | `bool` | `false` | Skip mise's argument parsing entirely — every argument, including `--help`/`-h`, is forwarded verbatim. For thin proxies over tools with their own parsers |
| `interactive` | `bool` | `false` | Also connects to the terminal, but takes an **exclusive lock** rather than serializing everything: other tasks block only while it runs; non-interactive tasks still parallelize with each other |

([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#quiet), [mise-task.json schema](https://mise.jdx.dev/schema/mise-task.json))

```toml
[tasks.manage]
raw_args = true
run = 'python manage.py'
```

```sh
mise run manage --help          # forwarded to manage.py, not intercepted by mise
mise run manage migrate --fake  # all flags reach manage.py unchanged
```

Ad-hoc alternative without `raw_args`: `mise run task -- --help` — the `--` separator bypasses mise's usage parser specifically for `--help`/`-h`. Everything after that separator belongs to the task, so `mise run task -- -- --help` forwards `-- --help` ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#raw-args)).

#### 7.2.5 Sandbox keys

These mirror the `mise run` CLI sandbox flags and appear in the task schema ([mise-task.json schema](https://mise.jdx.dev/schema/mise-task.json), [cli/run](https://mise.jdx.dev/cli/run.html#deny-all)).

| Key | Type | Default | Meaning |
| --- | --- | --- | --- |
| `deny_all` | `bool` | `false` | Block reads, writes, network, and env vars |
| `deny_read` | `bool` | `false` | Block filesystem reads (system libs and tool dirs stay accessible) |
| `deny_write` | `bool` | `false` | Block all filesystem writes |
| `deny_net` | `bool` | `false` | Block all network access |
| `deny_env` | `bool` | `false` | Block env inheritance (only `PATH`, `HOME`, `USER`, `SHELL`, `TERM`, `LANG` pass through) |
| `allow_read` | `string[]` | `[]` | Allow reads from specific paths (implies `deny_read` for everything else) |
| `allow_write` | `string[]` | `[]` | Allow writes to specific paths (implies `deny_write` for everything else) |
| `allow_net` | `string[]` | `[]` | Allow network to specific hosts (implies `deny_net` for everything else) |
| `allow_env` | `string[]` | `[]` | Allow specific env vars through (implies `deny_env`); supports wildcards like `MYAPP_*` |
| `pass_through_env` | `string[]` | `[]` | **experimental** — ambient env vars preserved under env denial **without** affecting the task cache key. Use for short-lived credentials |

---

### 7.3 Sources, outputs, and freshness checking

| Key | Type | Default | Meaning |
| --- | --- | --- | --- |
| `sources` | `string \| string[]` | `[]` | Input files/dirs/globs, relative to the config file. Also what `mise watch` watches. The task definition itself is automatically added as a source, so editing the task re-triggers it |
| `outputs` | `string \| string[] \| { auto = true }` | `{ auto = true }` (when `sources` is set) | Files/dirs the task produces |

([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#sources))

**The skip rule:** with both defined, mise skips the task when the **mtime of the oldest output** is newer than the **mtime of the newest source** ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#sources), [tasks/running-tasks](https://mise.jdx.dev/tasks/running-tasks.html#running-on-file-changes)).

```toml
[tasks.build]
description = 'Build the CLI'
run = "cargo build"
sources = ['Cargo.toml', 'src/**/*.rs']
outputs = ['target/debug/mycli']
```

`outputs = { auto = true }` avoids declaring output files: mise touches an internal marker keyed on a hash of the task definition, stored at `~/.local/state/mise/task-outputs/<hash>` ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#outputs)).

**Exclusions.** Entries prefixed `!` are excluded, gitignore/watchexec/rsync style. Order matters and the **latest matching entry wins**, so a later positive entry re-includes. Escape a literal leading bang as `\!` (`"\\!important.txt"` in TOML). Exclusions apply to the freshness check, `task_source_files()`, and `mise watch` ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#excluding-sources)).

```toml
[tasks.build]
sources = ["src/**/*.ts", "!src/**/*.test.ts", "!src/**/*.spec.ts", "tsconfig.json"]
run = "npm run build"

# outputs exclusions too:
# outputs = ["dist", "!dist/**/*.map", "!dist/.vite/**"]
```

**Dependency invalidation.** If a dependency also has `sources` and it re-runs because its sources changed, the dependent re-runs too — even when the dependent's own sources are unchanged. Dependencies **without** `sources` (which always run) do *not* trigger this, otherwise `sources` on dependents would be useless ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#dependency-invalidation)).

**Freshness tuning settings** ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#task-configuration-settings)):

| Setting | Env | Default | Meaning |
| --- | --- | --- | --- |
| `task.source_freshness_equal_mtime_is_fresh` | `MISE_TASK_SOURCE_FRESHNESS_EQUAL_MTIME_IS_FRESH` | `false` | Treat equal mtimes as fresh (`<=` instead of strict `<`) |
| `task.source_freshness_hash_contents` | `MISE_TASK_SOURCE_FRESHNESS_HASH_CONTENTS` | `false` | Use blake3 content hashing instead of metadata — more accurate, slower |

> Performance note from the docs: don't go crazy with huge globs — mise stats every matched file ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#sources)).

#### 7.3.1 Reusable input groups and global inputs — *experimental*

Requires `experimental = true`. Group entries resolve relative to the **config file that defines them**, even when the task uses a different `dir`; ordinary `sources` entries stay relative to the task directory. Undefined group references and cycles are configuration errors ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#reusable-and-global-inputs)).

```toml
[settings]
experimental = true

[task_config.input_groups]
toolchain = ["rust-toolchain.toml", "Cargo.lock"]
rust = ["Cargo.toml", "src/**/*.rs", "@group:toolchain"]

[task_config]
global_inputs = ["mise.toml", ".github/tool-versions", "@group:lockfiles"]

[tasks.build]
run = "cargo build"
sources = ["@group:rust"]
outputs = ["target/debug/mycli"]
```

#### 7.3.2 `cache` — artifact caching — *experimental*

| Key | Type | Default | Meaning |
| --- | --- | --- | --- |
| `cache` | `{ enabled: bool, env: string[], command_inputs: string[] }` | `{ enabled = false, env = [], command_inputs = [] }` | Content-addressed local cache of successful task results; declared outputs are restored after deletion |

Requirements: `experimental` enabled, at least one matching `source`, and **either** explicit output paths **or** `outputs = []`. Not supported: `outputs = { auto = true }`, absolute outputs, and patterns (including the body of an exclusion) that escape the task directory. `outputs = []` asserts the task has no filesystem side effects worth reproducing — ideal for lint/test/typecheck ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#cache)).

```toml
[settings]
experimental = true

[tasks.build]
run = "npm run build"
sources = ["package.json", "src/**"]
outputs = ["dist"]
cache = { enabled = true, env = ["NODE_ENV"] }
```

**Cache key composition:** source contents, task definition and arguments, resolved task environment, values (or absence) of variables named in `cache.env`, command-input output, resolved tool versions, dependency artifact keys, and OS + architecture. Ambient variables are ignored unless named in `cache.env` ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#cache)).

**`cache.command_inputs`** run before cache lookup, using the same inline shell (including a CLI `--shell` override), env, tools, working directory, and sandbox policy as the task. Their command text, stdout, and stderr enter the key. Constraints: must be non-empty and exit successfully; output is hashed, never printed or retained; inherit the task timeout or 30s when the task has none; at most 16 MiB across stdout+stderr; not run during dry runs, or when caching is disabled for raw/interactive execution.

**Per-run access modes** — `mise run --task-cache <mode>` or `MISE_TASK_CACHE`:

| Mode | Behavior |
| --- | --- |
| `read-write` | **default** — use cached results, publish new ones |
| `read-only` | use cached results, don't publish misses (e.g. untrusted PRs) |
| `write-only` | publish results, always execute instead of restoring (cache warming) |
| `off` | disable task output caching; fall back to ordinary source/output freshness |
| `local-only` | local cache only; currently equivalent to `read-write` since remote caching does not exist yet |

These affect only the experimental artifact cache. `--no-cache` is unrelated — it controls fetching **remote task definitions** ([cli/run](https://mise.jdx.dev/cli/run.html#task-cache-task-cache), [tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#per-run-cache-access)).

Other cache behavior: only **successful** runs are cached; cache read/write failures are treated as misses and never fail a passing task; stdout/stderr are stored as ordered, redacted streams and replayed through the selected output mode; raw and interactive tasks conservatively bypass artifact caching; cacheable dependencies contribute their artifact keys to dependents, and a dependency that executes without a stable artifact key forces its dependents to execute. Entries live under `MISE_CACHE_DIR/task-artifacts/v2`, or under `task.cache_dir` / `MISE_TASK_CACHE_DIR` (experimental) with the same `v2` child.

Declare lockfiles as inputs so dependency bumps invalidate the cache; installed dependency directories like `node_modules` generally should not be listed. Secrets belong in `pass_through_env`, not `cache.env` — pass-through values can change behavior without invalidating results, so tasks must not let them affect generated outputs.

> **Uncertainty:** the assignment lists a task key named `check`. No such key exists in the task docs or in `mise-task.json`, and the `Task` struct in `jdx/mise` `src/task/mod.rs` has no `check` field. The closest documented facilities are [`mise tasks validate`](https://mise.jdx.dev/cli/tasks/validate.html) (static checks over the task set) and the `sources`/`outputs` freshness check described above.

---

### 7.4 File tasks

#### 7.4.1 Discovery paths

Default file-task directories, searched relative to the config root ([tasks/file-tasks](https://mise.jdx.dev/tasks/file-tasks.html), [tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#task-config-includes)):

```
mise-tasks/:task_name
.mise-tasks/:task_name
mise/tasks/:task_name
.mise/tasks/:task_name
.config/mise/tasks/:task_name
```

If `task_config.includes` is set for the current config scope, mise searches **only** those paths instead — `includes` *replaces* the defaults, it does not extend them.

**The file must be executable**, or mise will not see it:

```shell
chmod +x mise-tasks/build
```

Tasks can also be run without any config at all by path — the path must start with `/` or `./` (`C:\` or `.\` on Windows) ([tasks/file-tasks](https://mise.jdx.dev/tasks/file-tasks.html#running-tasks-directly)):

```bash
mise run ./path/to/script.sh
```

#### 7.4.2 Grouping via sub-directories

Sub-directories become `:`-separated name prefixes; a file named `_default` inside a directory takes the directory's own name ([tasks/file-tasks](https://mise.jdx.dev/tasks/file-tasks.html#task-grouping)):

```
mise-tasks
├── build
└── test
    ├── _default
    ├── integration
    └── units
```

```shellsession
$ mise tasks
Name              Description Source
build                         ./mise-tasks/build
test                          ./mise-tasks/test/_default
test:integration              ./mise-tasks/test/integration
test:units                    ./mise-tasks/test/units
```

#### 7.4.3 `#MISE` comment directives

Every configuration key from §7.2 is available in a file task as a `#MISE` comment. **Each `#MISE` line is TOML** ([tasks/file-tasks](https://mise.jdx.dev/tasks/file-tasks.html#task-configuration)):

```bash
#MISE description="Build the CLI"
#MISE alias="b"
#MISE sources=["Cargo.toml", "src/**/*.rs"]
#MISE outputs=["target/debug/mycli"]
#MISE env={RUST_BACKTRACE = "1"}
#MISE depends=["lint", "test"]
#MISE tools={rust="1.50.0"}
#MISE dir="{{cwd}}"
```

Arrays and inline tables may span lines as long as every line keeps the prefix:

```bash
#!/usr/bin/env bash
#MISE description="Build the CLI"
#MISE depends=[
#MISE   "lint",
#MISE   "test",
#MISE ]
#MISE sources=[
#MISE   "Cargo.toml",
#MISE   "src/**/*.rs",
#MISE ]
cargo build
```

Dotted keys avoid braces entirely:

```bash
#MISE tools.node="20"
#MISE tools.python="3.11"
```

| Directive form | Accepted? | Note |
| --- | --- | --- |
| `#MISE key=value` | ✅ | canonical |
| `# [MISE] key=value` | ✅ | workaround for formatters that insert a space |
| `# MISE key=value` | ❌ | **intentionally ignored** so a reformatted comment can't silently become configuration |
| `//MISE …` | ✅ | for JS/TS/Deno scripts |
| `#USAGE …` / `//USAGE …` / `# [USAGE] …` | ✅ | usage-spec lines (see §7.5) |

([tasks/file-tasks](https://mise.jdx.dev/tasks/file-tasks.html#task-configuration), [tasks/task-arguments](https://mise.jdx.dev/tasks/task-arguments.html#file-task-headers))

#### 7.4.4 Shebangs

The shebang is optional; when present it selects the interpreter, so a file task can be written in any language ([tasks/file-tasks](https://mise.jdx.dev/tasks/file-tasks.html#shebang)):

```js
#!/usr/bin/env node
//MISE description="Hello, World in Node.js"
console.log("Hello, World!");
```

```python
#!/usr/bin/env python
#MISE description="Hello, World in Python"
print('Hello, World!')
```

```ts
#!/usr/bin/env -S deno run --allow-env
//MISE description="Hello, World in Deno"
console.log(`PATH, ${Deno.env.get("PATH")}`);
```

```powershell
#!/usr/bin/env pwsh
#MISE description="Hello, World in PowerShell"
$current_directory = Get-Location
Write-Host "Hello from PowerShell, current directory is $current_directory"
```

`-S` lets you pass multiple arguments to the interpreter (`#!/usr/bin/env -S python -u`). mise does not actually shell out to `env` but behaves similarly ([tasks/toml-tasks](https://mise.jdx.dev/tasks/toml-tasks.html#shell-shebang)).

#### 7.4.5 CWD and editing

mise `cd`s to the `mise.toml` directory before running; override per-task with `#MISE dir="{{cwd}}"`, or use `cd "$MISE_ORIGINAL_CWD"` inside the script. `mise tasks edit <task>` opens the script in `$EDITOR`, creating it if it doesn't exist ([tasks/file-tasks](https://mise.jdx.dev/tasks/file-tasks.html#cwd), [cli/tasks/edit](https://mise.jdx.dev/cli/tasks/edit.html)).

> **Uncertainty:** vars are documented as TOML-task-only. The docs state the author wants file-task support but doesn't want to turn all file tasks into Tera templates ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#vars)).

---

### 7.5 Task arguments (usage spec)

Three mechanisms exist; only two are current ([tasks/task-arguments](https://mise.jdx.dev/tasks/task-arguments.html)):

| Mechanism | Status | Where |
| --- | --- | --- |
| `usage` field | **preferred** | TOML tasks |
| `#USAGE` / `//USAGE` comment headers | **preferred** | file tasks |
| Tera `arg()` / `option()` / `flag()` in run scripts | **deprecated** | both |

#### 7.5.1 How values reach the task

Parsed values are exposed **two** ways:

1. Environment variables prefixed `usage_`, snake_cased (`--dry-run` → `$usage_dry_run`).
2. A Tera `usage` map inside run-script templates (`{{ usage.dry_run }}`; use bracket access for literal dashes: `{{ usage["dry-run"] }}`). Variadic args/flags become arrays usable with `for` and `| length`.

Do **not** mix the `usage` map with the deprecated `arg()`/`option()`/`flag()` functions in the same task ([tasks/task-arguments](https://mise.jdx.dev/tasks/task-arguments.html#usage-field), [templates](https://mise.jdx.dev/templates.html#variables)).

Inherited `usage_*` values are **cleared** for normal task execution, even for tasks without a usage spec. Only `raw_args = true` tasks retain inherited `usage_*`. To deliberately inherit a value, back the arg with a differently-named variable via `env=` ([tasks/task-arguments](https://mise.jdx.dev/tasks/task-arguments.html#usage-field)).

```toml
[tasks.deploy]
description = "Deploy application"
usage = '''
arg "<environment>" help="Target environment" {
  choices "dev" "staging" "prod"
}
flag "-v --verbose" help="Enable verbose output"
flag "--region <region>" help="AWS region" default="us-east-1" env="AWS_REGION"
'''
run = '''
echo "Deploying to ${usage_environment?} in ${usage_region?}"
[[ "${usage_verbose?}" == "true" ]] && set -x
./deploy.sh "${usage_environment?}" "${usage_region?}"
'''
```

```shellsession
$ mise run deploy --help
Deploy application

Usage: deploy <environment> [OPTIONS]

Arguments:
  <environment>  Target environment [possible values: dev, staging, prod]

Options:
  -v, --verbose          Enable verbose output
      --region <region>  AWS region [env: AWS_REGION] [default: us-east-1]
  -h, --help            Print help
```

#### 7.5.2 `arg` — positional arguments

| Attribute | Type | Meaning |
| --- | --- | --- |
| `"<name>"` | — | required positional |
| `"[name]"` | — | optional positional |
| `help=` | string | short help text |
| `long_help=` | string | extended help shown with `--help` |
| `default=` | string | value when not provided |
| `env=` | string | env var fallback |
| `var=#true` | bool | variadic (0+ if `[…]`, 1+ if `<…>`) |
| `var_min=` / `var_max=` | int | bounds on a variadic arg |
| `hide=#true` | bool | hide from help |
| `double_dash=` | `"required"` \| `"optional"` \| `"automatic"` | require `--` before the value / allow either / behave as if `--` was used after the first arg |
| `choices "a" "b"` | block | enumerated values, validated and completed |

([tasks/task-arguments](https://mise.jdx.dev/tasks/task-arguments.html#positional-arguments-arg))

```kdl
arg "<name>" help="Description"               // Required positional arg
arg "[name]" help="Description"               // Optional positional arg
arg "<file>"                                  // Completed as filename
arg "<dir>"                                   // Completed as directory
arg "<files>" var=#true var_min=1 var_max=3   // Between 1 and 3 files
arg "<token>" env="API_TOKEN"                 // Can be set via $API_TOKEN
arg "<level>" {
  choices "debug" "info" "warn" "error"
}
```

Naming `<file>` / `<dir>` implicitly selects filename / directory completion.

#### 7.5.3 `flag` — named flags and options

| Attribute | Type | Meaning |
| --- | --- | --- |
| `"-f --force"` | — | boolean flag (short and/or long; either alone is fine) |
| `"-o --output <file>"` | — | flag that takes a value |
| `help=` / `long_help=` | string | help text |
| `default=` | string \| `#true` | default value |
| `env=` | string | env var fallback |
| `count=#true` | bool | repeatable; `$usage_verbose` becomes the repeat count (`-vvv` → `3`) |
| `negate="--no-color"` | string | generates a negating flag; value becomes `"false"` |
| `global=#true` | bool | available on all subcommands (with `cmd` structure) |
| `hide=#true` | bool | hide from help |
| `choices "a" "b"` | block | enumerated values |

([tasks/task-arguments](https://mise.jdx.dev/tasks/task-arguments.html#flags-flag))

```kdl
flag "--color" negate="--no-color" default=#true
// Default: $usage_color = "true"; with --no-color: $usage_color = "false"

flag "-v --verbose" count=#true    // -vvv → $usage_verbose = 3

flag "--color <when>" {
  choices "auto" "always" "never"
  default "auto"
}
```

#### 7.5.4 `complete` — dynamic completions

```kdl
arg "<plugin>"
complete "plugin" run="mise plugins ls"
complete "plugin" run="mycli plugins list" descriptions=#true
```

With `descriptions=#true` the command's output is split on `:` into value and description ([tasks/task-arguments](https://mise.jdx.dev/tasks/task-arguments.html#completion-complete)):

```
nodejs:JavaScript runtime
python:Python language
ruby:Ruby language
```

The `usage` CLI is **not** required to *execute* tasks with a usage spec, but it **is** required for completions to work — it must be installed and on `PATH`. Debug bad specs with `mise run build -v`, which surfaces `DEBUG failed to parse task file with usage` ([tasks/file-tasks](https://mise.jdx.dev/tasks/file-tasks.html#arguments)).

#### 7.5.5 `mount` — spec generated by the wrapped CLI

```bash
#!/usr/bin/env bash
#USAGE mount "mise run run-release -- --usage-spec"
exec ./target/release/mycli "$@"
```

The mount command runs when shell completion asks for the task spec, so it must work **outside** the task's final process; calling the task itself lets mise apply task configuration before forwarding `--usage-spec` ([tasks/task-arguments](https://mise.jdx.dev/tasks/task-arguments.html#mounting-generated-specs)).

#### 7.5.6 Precedence and bash expansion

Precedence: **CLI argument > environment variable (`env=`) > `default=`**. An env-backed value satisfies a required (`<angle bracket>`) argument ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#environment-variable-support-for-args-and-flags)).

| Syntax | Behavior | Use case | Example |
| --- | --- | --- | --- |
| `${var?}` | Error if unset | required args, or flags with `default=` in the spec | `${usage_profile?}` |
| `${var:?}` | Error if unset or empty | when you need a non-empty value | `${usage_target:?}` |
| `${var:-default}` | Use default if unset | boolean flags with no `default=` | `${usage_clean:-false}` |
| `${var:=default}` | Set and use default if unset | when you want the variable set for later | `${usage_dir:=.}` |
| `${var:+value}` | Use value if set | conditional flag passing | `${usage_verbose:+--verbose}` |

([tasks/task-arguments](https://mise.jdx.dev/tasks/task-arguments.html#bash-variable-expansion))

Variadic arguments arrive as a single shell-escaped string. Convert to a bash array before using:

```bash
eval "files=($usage_files)"
for f in "${files[@]}"; do
  echo "Processing: $f"
done
```

#### 7.5.7 Argument passing *without* a usage spec

| Task form | Where extra arguments go |
| --- | --- |
| `run` is an array | appended to the **last entry only** |
| plain inline shell command | appended to the command text |
| shebang task | executed as a script file, so `$1`, `$@` work normally |

```toml
[tasks.test]
run = ['cargo test', './scripts/test-e2e.sh']
# `mise run test foo bar` → passes "foo bar" to ./scripts/test-e2e.sh, NOT to cargo test
```

([tasks/running-tasks](https://mise.jdx.dev/tasks/running-tasks.html), [tasks/toml-tasks](https://mise.jdx.dev/tasks/toml-tasks.html#arguments))

> **Gotcha:** everything after the task name belongs to the task, so mise's own flags must precede it — `mise run --silent build`, not `mise run build --silent` (the latter passes `--silent` to the task and fails with `unexpected word: --silent`). The upside: a task is free to define a flag that collides with a mise flag, e.g. its own `--env` ([tasks/running-tasks](https://mise.jdx.dev/tasks/running-tasks.html)).

#### 7.5.8 Deprecated: Tera `arg()` / `option()` / `flag()`

**Removal is scheduled.** The task-arguments page states removal in **mise 2026.11.0**; the toml-tasks page states removal in **2027.5.0** with deprecation warnings from **>= 2026.5.0**.

> **Uncertainty:** the two official pages disagree on the removal version (2026.11.0 vs 2027.5.0). Treat the feature as removed-soon either way ([tasks/task-arguments](https://mise.jdx.dev/tasks/task-arguments.html#tera-templates), [tasks/toml-tasks](https://mise.jdx.dev/tasks/toml-tasks.html#tera-template-functions)).

Reasons given for removal: template functions return **empty strings during spec collection** (two-pass parsing), shell escaping rules are complex and inconsistent between TOML and file tasks, and no `--help` output is generated.

| Deprecated function | Parameters | Produced |
| --- | --- | --- |
| `{{arg(name=, i=, var=, default=)}}` | `i` = explicit index (defaults to definition order), `var` = allow multiple, `default` | positional argument |
| `{{option(name=, var=, default=)}}` | `var`, `default` | `--name value` option |
| `{{flag(name=)}}` | `name` | `"true"` when passed, `"false"` otherwise |

Opt out immediately with `task.disable_spec_from_run_scripts = true` / `MISE_TASK_DISABLE_SPEC_FROM_RUN_SCRIPTS=1`, which skips the extra template pass and uses only the explicit `usage` field ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#task-configuration-settings)).

Migration examples ([tasks/task-arguments](https://mise.jdx.dev/tasks/task-arguments.html#migration-guide)):

```toml
# Old (deprecated)
[tasks.lint]
run = 'eslint {{arg(name="files", var=true)}}'

# New (preferred)
[tasks.lint]
usage = 'arg "<files>" var=#true'
run = 'eslint ${usage_files?}'
```

---

### 7.6 Tera templates available inside tasks

Most `mise.toml` values — including task fields — are rendered as [Tera](https://keats.github.io/tera/) templates. The `mise.toml` file itself is not templated and must be valid TOML. Delimiters: `{{ }}` expressions, `{% %}` statements, `{# #}` comments, `{% raw %}…{% endraw %}` to escape ([templates](https://mise.jdx.dev/templates.html)).

**mise 2026.x uses Tera v2.** Escape hatch `MISE_TERA_V1=1` (or `[settings] tera_v1 = true`) renders with Tera v1; v1 compatibility helpers start warning in **2026.10.0** and are removed in **2027.4.0**. In shared configs prefer the `[env] MISE_TERA_V1 = true` form, because older mise releases treat it as a normal env var rather than failing on an unknown setting ([templates](https://mise.jdx.dev/templates.html#tera-v2-migration)).

| Tera v1 pattern | Tera v2 replacement |
| --- | --- |
| `value \| trim_start_matches(pat="v")` | `value \| trim_start(pat="v")` |
| `value \| trim_end_matches(pat="-beta")` | `value \| trim_end(pat="-beta")` |
| `items \| slice(start=0, end=2)` | `items[0:2]` |
| `[base] \| concat(with="file.txt")` | `[base, "file.txt"]` |
| `[...items] \| concat(with=extra_items)` | `[...items, ...extra_items]` |
| `items \| map(attribute="name")` | `[item.name for item in items]` |
| `items \| filter(attribute="active")` | `[item for item in items if item.active]` |
| `value \| as_str` | `value \| str` |
| `value \| escape` | `value \| escape_html` |
| `value \| linebreaksbr` | `value \| newlines_to_br` |
| `value is divisibleby(divisor=3)` | `value is divisible_by(divisor=3)` |
| `value is object` | `value is map` |
| `value \| indent(prefix=">")` | `value \| indent(width=1)` for spaces only |
| `value \| truncate` | `value \| truncate(length=255)` |

Tera v2 additionally supports slices (`parts[0:2]`, `parts[-1]`, `name[::-1]`), spread (`[first, ...rest]`, `{...base, key: value}`), comprehensions, optional chaining (`env?.NODE_ENV or "development"`), and ternaries (`"prod" if release else "dev"`). Undefined-variable access is stricter, and Tera v1 macros are not supported.

#### 7.6.1 Variables

| Variable | Type | Meaning |
| --- | --- | --- |
| `env` | `HashMap<String,String>` | current environment variables |
| `cwd` | `PathBuf` | current working directory |
| `config_root` | `PathBuf` | directory containing `mise.toml`; for `~/src/myproj/.config/mise.toml` → `~/src/myproj` |
| `mise_bin` | `String` | path to the current mise executable |
| `mise_pid` | `String` | pid of the current mise process |
| `mise_env` | `Vec<String>` | config environment from `MISE_ENV` / `-E` / `--env`; **undefined** when unset |
| `xdg_cache_home`, `xdg_config_home`, `xdg_data_home`, `xdg_state_home` | `PathBuf` | XDG base dirs |
| `vars.*` | — | user-defined `[vars]` (config-level and task-local) |
| `tools` | `HashMap<String, ToolInfo \| ToolInfo[]>` | installed tools; available in task templates and in env directives with `tools = true`. Single version → `tools.<name>.version` / `.path`; multiple → `tools.<name>[0].version` etc. |
| `usage` | `HashMap<String, Value>` | parsed task args/flags in **run scripts**; values are booleans, strings, or arrays and are **not** shell-escaped or quoted |

([templates](https://mise.jdx.dev/templates.html#variables))

#### 7.6.2 Functions

**Tera built-ins** (`[]` = optional arg) ([templates](https://mise.jdx.dev/templates.html#tera-built-in-functions)):

| Function | Meaning |
| --- | --- |
| `range(end, [start], [step_by])` | array of integers; `start` defaults `0`, `step_by` defaults `1` |
| `now([timezone])` | current datetime as a string; timezone defaults UTC, accepts IANA names like `America/New_York`. With `tera_v1 = true` the old `now([timestamp], [utc])` signature applies |
| `throw(message)` | raise an error |
| `get_random(start, end, [seed])` | random integer in a range; `seed` makes it reproducible |

**mise general functions** — same behavior in every task ([templates](https://mise.jdx.dev/templates.html#additional-mise-functions)):

| Function | Returns | Meaning |
| --- | --- | --- |
| `exec(command, [cache_key], [cache_duration])` | `String` | run a shell command, return its output. `cache_duration` accepts `"1d"`-style spans and requires `cache_key` to cache |
| `get_env(name, [default])` | `String` | original process env var; compatibility helper — prefer the `env` variable. Empty vars are returned as-is |
| `arch()` | `String` | e.g. `x64`, `arm64` |
| `os()` | `String` | `linux`, `macos`, `windows` |
| `os_family()` | `String` | `unix`, `windows` |
| `num_cpus()` | `usize` | CPU count |
| `choice(n, alphabet)` | `String` | random sample with replacement, e.g. `choice(n=64, alphabet='0123456789abcdef')` |
| `read_file(path)` | `String` | file contents |

> **Warning from the docs:** `exec()` runs whenever its template is rendered, **including during `--dry-run`**. Dry-run suppresses the planned mise operation; it does not sandbox template-executed commands. Keep `exec()` commands side-effect free ([templates](https://mise.jdx.dev/templates.html#additional-mise-functions)).

**Task-specific functions** — return values depend on the calling task ([templates](https://mise.jdx.dev/templates.html#task-specific-functions)):

| Function | Returns | Meaning |
| --- | --- | --- |
| `task_source_files()` | `Vec<String>` | the task's `sources` expanded to resolved file paths (globs processed, Tera strings rendered, exclusions applied). Non-matching patterns are omitted; returns `[]` when no sources are configured or nothing matches |

```toml
[tasks.example]
sources = ["src/**/*.ts", "package.json"]
run = '''
{% for file in task_source_files() %}
  echo "Processing: {{ file }}"
{% endfor %}
'''
```

#### 7.6.3 Filters

**String / general** ([templates](https://mise.jdx.dev/templates.html#filters)):

| Filter | Meaning |
| --- | --- |
| `lower`, `upper`, `capitalize`, `title` | case transforms |
| `replace(from, to)` | substring replacement |
| `trim`, `trim_start`, `trim_end` | whitespace trimming |
| `truncate` | truncate to length (Tera v2 wants `truncate(length=255)`) |
| `first`, `last` | first/last element of array or string |
| `join(sep)` | join array, e.g. `{{ ["a","b","c"] \| join(sep=", ") }}` → `a, b, c` |
| `length` | length of a string or array |
| `reverse` | reverse characters or elements |
| `urlencode`, `urlencode_strict` | percent-encoding (strict encodes all non-alphanumerics) |
| `map(attribute)` | **deprecated compat** — extract attribute from each object |
| `concat(with)` | **deprecated compat** — append to array; prefer literals + spread |
| `abs` | absolute value |
| `filesize_format` (alias `filesizeformat`) | human-readable file size |
| `date(format, [timezone])` | format a timestamp; see [jiff strtime](https://docs.rs/jiff/latest/jiff/fmt/strtime/index.html) |
| `b64_encode([url_safe], [padded])`, `b64_decode([url_safe])` | base64 |
| `format(spec)` | Rust-style formatting |
| `json_encode([pretty])` | encode as JSON |
| `shuffle([seed])` | randomly shuffle an array |
| `regex_replace(pattern, rep)` | regex replacement |
| `striptags`, `spaceless` | strip HTML tags / whitespace between tags |
| `slug` (alias `slugify`) | URL-friendly slug |
| `split(pat)` | split into array |
| `default(value)` | fallback when undefined or empty |

**Hashing:**

| Filter | Args | Meaning |
| --- | --- | --- |
| `hash([algorithm], [len])` | `algorithm`: `"sha256"` (default) \| `"blake3"`; `len`: truncate | hash of the input string |
| `hash_file([len])` | `len`: truncate | BLAKE3 hash of the file at the path |

**Path manipulation:**

| Filter | Meaning |
| --- | --- |
| `absolute` | make absolute; does **not** require the path to exist |
| `canonicalize` | absolute + resolved; **throws** if the path doesn't exist |
| `dirname` | `/foo/bar/baz.txt` → `/foo/bar` |
| `basename` | `/foo/bar/baz.txt` → `baz.txt` |
| `extname` | `/foo/bar/baz.txt` → `.txt` |
| `file_stem` | `/foo/bar/baz.txt` → `baz` |
| `file_size` | size in bytes |
| `last_modified` | last modified time |
| `join_path` | join an **array** of path segments into one path |

```toml
[env]
PROJECT_CONFIG = "{{ [config_root, 'bar.txt'] | join_path }}"
```

**Case conversion:** `quote` (converts `'` to `\'` then quotes), `kebabcase`, `lowercamelcase`, `uppercamelcase`, `snakecase`, `shoutysnakecase`.

#### 7.6.4 Tests

Tera built-ins include `defined`, `string`, `number`, `starting_with`, `ending_with`, `containing`, `matching`, and the date tests `before` / `after` (which take `other` and optional `inclusive`). mise adds `is dir`, `is file`, `is exists` ([templates](https://mise.jdx.dev/templates.html#tests)).

#### 7.6.5 Vars

`[vars]` are shared between TOML tasks and other Tera-rendered config. Unlike `[env]` they are **not exported to task processes** ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#vars)):

```toml
[vars]
e2e_args = '--headless'
api_token = { required = "Set api_token in mise.local.toml" }
secret_arg = { value = "--token=abc123", redact = true }
_.file = ".env"

[tasks.test]
vars = { e2e_args = "--headed" }   # task-local override
run = './scripts/test-e2e.sh {{vars.e2e_args}}'
```

- The `default` form reads from a **process** environment variable of the same name when set and non-empty; values from `[env]` are not consulted for this lookup.
- The `required` form must be satisfied by the process environment or a later config file such as `mise.local.toml`.
- `redact = true` hides the value from task output; secrets are supported as vars.
- Vars compose across config files, so a global `~/.config/mise/config.toml` var can be overridden in `mise.local.toml` and the override applies inside tasks from any config file.

---

### 7.7 Running tasks

#### 7.7.1 Invocation forms

| Form | Notes |
| --- | --- |
| `mise run <task>` | canonical; **use this in scripts and docs** |
| `mise tasks run <task>` | explicit subcommand |
| `mise r <task>` | alias |
| `mise <task>` | shorthand — works only if the name doesn't collide with a mise command, and a future mise version could shadow it |
| `mise run` | runs the task named `default` (or a task aliased to `default`); with no `default`, shows the interactive picker |
| `mise //path:task` | monorepo syntax; `//`- and `:`-prefixed names are guaranteed never to collide with mise commands |

([tasks/running-tasks](https://mise.jdx.dev/tasks/running-tasks.html), [tasks/monorepo](https://mise.jdx.dev/tasks/monorepo.html#task-path-syntax))

Multiple tasks with their own arguments are separated by `:::`:

```bash
mise run build arg1 arg2 ::: test arg3 arg4
mise run lint ::: test ::: check
```

#### 7.7.2 `mise run` flags

| Flag | Meaning |
| --- | --- |
| `-c --continue-on-error` | keep running tasks even after one fails |
| `-C --cd <CD>` | change to this directory before executing |
| `-f --force` | run even if outputs are up to date |
| `-j --jobs <JOBS>` | parallel task count; **default 4**; also `jobs` setting / `MISE_JOBS` |
| `-n --dry-run` | print tasks in execution order without running them |
| `-o --output <OUTPUT>` | output style (table below) |
| `-q --quiet` | hide mise's extra output |
| `-r --raw` | direct stdin/stdout/stderr; **redactions are not applied**; forces `--jobs=1`; also `raw` setting / `MISE_RAW` |
| `-s --shell <SHELL>` | shell for TOML tasks; defaults to `sh -c -o errexit -o pipefail` on unix and `cmd /c` on Windows |
| `-S --silent` | show nothing but errors |
| `-t --tool… <TOOL@VERSION>` | extra tools beyond `mise.toml`, e.g. `node@20 python@3.10` |
| `--allow-env… <VAR>` | allow specific env var (implies `--deny-env` for the rest); wildcards like `MYAPP_*` |
| `--allow-net… <HOST>` / `--allow-read… <PATH>` / `--allow-write… <PATH>` | targeted allowances, each implying the matching deny |
| `--deny-all` | block reads, writes, network, and env vars |
| `--deny-env` | block env inheritance (only `PATH`, `HOME`, `USER`, `SHELL`, `TERM`, `LANG` pass) |
| `--deny-net` / `--deny-read` / `--deny-write` | block network / reads / writes |
| `--fresh-env` | bypass the environment cache and recompute |
| `--no-cache` | do not use the cache for **remote** task definitions |
| `--no-deps` | skip automatic dependency preparation |
| `--no-timings` | hide elapsed time per task; permanently via `MISE_TASK_TIMINGS=0` |
| `--skip-deps` | run only the named tasks, skipping all dependencies |
| `--skip-tools` | skip installing tools; persistently via `task.run_auto_install` / `MISE_TASK_RUN_AUTO_INSTALL=false` |
| `--task-cache <MODE>` | `read-write` (default) \| `read-only` \| `write-only` \| `off` \| `local-only` |
| `--timeout <TIMEOUT>` | task timeout, e.g. `30s`, `5m`; overrides the global `task.timeout` setting |

([cli/run](https://mise.jdx.dev/cli/run.html), [cli/tasks/run](https://mise.jdx.dev/cli/tasks/run.html))

#### 7.7.3 Output modes

| Mode | Behavior |
| --- | --- |
| `prefix` | print by line, prefixed with the task label — **default when jobs > 1** |
| `interleave` | print straight to stdout/stderr as it comes — **default when jobs == 1 or all tasks run sequentially** |
| `keep-order` | stream one task's output live while buffering others, printing in definition order as tasks complete |
| `replacing` | replace stdout each time a line prints (same logic as `mise install`); stderr printed as-is |
| `timed` | only show stdout lines displayed for more than 1 second |
| `quiet` | *legacy* — `interleave` + suppress mise's own messages |
| `silent` | print nothing from tasks or mise (nulls stdout and stderr) except errors |

Set with `--output`/`-o`, the `task.output` setting, `MISE_TASK_OUTPUT`, or the per-task `output` key ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#task.output), [cli/run](https://mise.jdx.dev/cli/run.html#o-output-output)).

> **Style vs. verbosity are separate axes** (a behavior change worth knowing): `MISE_TASK_OUTPUT=prefix` combined with `--quiet` keeps the task-name prefixes while suppressing mise's own messages. `--quiet` **no longer** forces un-prefixed output — use `--output quiet` or `-o interleave` for the old behavior ([tasks/running-tasks](https://mise.jdx.dev/tasks/running-tasks.html)).

Stdin is not read by default; set `raw = true` on the task that needs it. That takes a RWMutex write lock, preventing parallel execution, and disables redactions ([tasks/running-tasks](https://mise.jdx.dev/tasks/running-tasks.html)).

#### 7.7.4 Timings

`task.timings` / `MISE_TASK_TIMINGS` shows a completion message with elapsed time per task. Default: shown when the output type is `prefix`. `--no-timings` hides it for one run ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#task.timings), [cli/run](https://mise.jdx.dev/cli/run.html#no-timings)).

#### 7.7.5 Task grouping and wildcards

Names are grouped with `:` separators (`test:unit`, `test:integration:local`). TOML keys containing `:` must be quoted:

```toml
[tasks."test:unit"]
run = 'cargo test --lib'
```

| Pattern | Matches |
| --- | --- |
| `?` | any single character |
| `*` | 0 or more characters |
| `**` | 0 or more groups |
| `{glob1,glob2,…}` | any of the comma-separated globs |
| `[ab,…]` | any of the characters or ranges `[a-z]` |
| `[!ab,…]` | any character **not** in the set |

```bash
mise run 'test:*'
mise run test:**:local            # matches test:units:local, test:integration:local, test:e2e:happy:local
mise run generate:{completions,docs:*}
```

Wildcards work in dependencies too ([tasks/running-tasks](https://mise.jdx.dev/tasks/running-tasks.html#wildcards)):

```toml
[tasks."lint:eslint"]
run = "eslint ."
[tasks."lint:prettier"]
run = "prettier --check ."
[tasks.lint]
depends = ["lint:*"]
wait_for = ["render"]
```

#### 7.7.6 `set -e` semantics

Tasks execute with `set -e` (`set -o errexit`) when the shell is `sh`, `bash`, or `zsh` — any failing command aborts the script. Disable per-script with `set +e` ([tasks/toml-tasks](https://mise.jdx.dev/tasks/toml-tasks.html#shell-shebang)):

```toml
[tasks.echo]
run = '''
set +e
cd /nonexistent
echo "This will not fail the task"
'''
```

When the shell is PowerShell (`pwsh`/`powershell`), mise passes `-NoProfile` so your profile can't shadow a task's installed tools via `PATH` mutation — matching the non-interactive behavior of `sh -c`. Set `windows_powershell_no_profile = false` if your tasks depend on profile side effects ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#shell)).

#### 7.7.7 Ordering primitives

```toml
[tasks.one_by_one]
run = [
    { task = "example1" },                # waits for example1 before the next step
    { tasks = ["example2", "example3"] }, # these 2 run in parallel
]
```

([tasks/running-tasks](https://mise.jdx.dev/tasks/running-tasks.html#execution-order))

---

### 7.8 `[task_config]` — config-scope task options

`[task_config]` applies to all tasks included by that config file or sharing its root directory — e.g. `~/src/myproject/mise.toml`'s `[task_config]` governs file tasks at `~/src/myproject/mise-tasks/mytask` ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#task-config-options)).

| Key | Type | Default | Meaning |
| --- | --- | --- | --- |
| `task_config.cascade` | `bool` | `false` | Also apply this section to tasks owned by **descendant** config roots. Descendants override individual inherited fields; a descendant may set `cascade = false` to stop inheriting. Applies to `dir`, `shell`, `cache`, and `includes` |
| `task_config.dir` | `string` (Tera) | `{{ config_root }}` | Default working directory for tasks in scope |
| `task_config.shell` | `string` | platform inline-shell default | Default shell for tasks in this scope. A task's explicit `shell` wins, including one inherited from a task template. Unlike the global `*_default_inline_shell_args`, it cannot change the interpreter used by hooks, tool installation, or tasks from another config root |
| `task_config.includes` | `string[]` (Tera-rendered) | the five default dirs | Toml files and file-task directories to search — **replaces** the defaults |
| `task_config.cache` | `{ enabled, env, command_inputs }` | unset | **experimental** — default artifact-cache config, inherited only by cache-eligible tasks. Task-local and template cache config wins, including `cache = { enabled = false }` |
| `task_config.global_env` | `string[]` | `[]` | **experimental** — ambient env var names added to every cache-enabled task's key. **Composes** with task-local `cache.env` rather than acting as a default |
| `task_config.global_pass_through_env` | `string[]` | `[]` | **experimental** — ambient vars preserved under env denial without entering cache keys |
| `task_config.global_inputs` | `string[]` | `[]` | **experimental** — config-root-relative source paths/globs added to every task in scope; may use `@group:<name>` |
| `task_config.input_groups` | `{ [name]: string[] }` | `{}` | **experimental** — reusable, config-root-relative source groups; may reference other groups |
| `redactions` | `string[]` | `[]` | **experimental** — env var names (glob patterns allowed, e.g. `SECRETS_*`) to redact from task output |

#### 7.8.1 `includes` semantics

```toml
[task_config]
includes = [
    "tasks.toml", # a task toml file
    "mytasks"     # a directory containing file tasks
]
```

Rules ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#task-config-includes)):

- Setting `includes` **replaces** the defaults (`mise-tasks`, `.mise-tasks`, `.mise/tasks`, `.config/mise/tasks`, `mise/tasks`); re-list them explicitly to keep them.
- Entries are rendered as Tera templates, so they can reference `config_root`, `env`, and resolved `vars`.
- For local and monorepo discovery, mise uses the **nearest** config that defines `includes`. With `cascade = true` a parent's includes are inherited until a child defines its own; a child's `includes` replaces both the defaults and any inherited includes for that directory. Global config files are loaded independently and each uses its own `includes` (or the defaults).
- Entries are evaluated in order and **the last entry wins** on duplicate task names — uniformly across directory, toml-file, and `git::` includes.

```toml
[task_config]
includes = [
    "git::https://github.com/myorg/shared-tasks.git//tasks", # remote task…
    ".mise/tasks",                                           # …overridden by the local one with the same name
]
```

Included task TOML files use a **different format** from `mise.toml`: the keys *are* the task names, with no `[tasks.…]` prefix ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#task-config-includes)):

```toml
# tasks.toml
task1 = "echo task1"
task2 = "echo task2"

[task4]
run = "echo task4"
vars = { target = "linux" }
```

JSON schema for editor validation of those files: `https://mise.en.dev/schema/mise-task.json`.

#### 7.8.2 Remote task sources

| Source | Syntax | Notes |
| --- | --- | --- |
| HTTP file task | `file = "https://example.com/build.sh"` | downloaded and executed — trust the source |
| Git file task (**experimental**) | `file = "git::<protocol>://<url>//<path>?ref=<ref>"` | `protocol`, `url`, `path` required; `ref` (branch/tag/commit) optional |
| Git includes (**experimental**) | `includes = ["git::ssh://git@github.com/myorg/shared-tasks.git//tasks?ref=v1.0.0"]` | `path` may be a directory (loads executable file tasks **and** `.toml` task files) or a single `.toml` file |

Caching: task files cache into `MISE_CACHE_DIR`; git includes cache into `MISE_CACHE_DIR/remote-git-tasks-cache`. Updated remotes are **not** re-fetched until the cache is cleared. Reset with `mise cache clear`, or disable with `MISE_TASK_REMOTE_NO_CACHE=true` / `--no-cache` / the `task.remote_no_cache` setting ([tasks/toml-tasks](https://mise.jdx.dev/tasks/toml-tasks.html#remote-tasks), [tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#remote-git-includes)).

#### 7.8.3 Task-related settings

| Setting | Env | Type | Default | Meaning |
| --- | --- | --- | --- | --- |
| `task.cache_dir` | `MISE_TASK_CACHE_DIR` | `string?` | `None` | Alternate parent for task-output cache artifacts (mise appends its versioned `v2` child); included in `mise cache clear` and pruning |
| `task.disable_paths` | `MISE_TASK_DISABLE_PATHS` | `string[]` | `[]` | Paths mise will not look for tasks in; OS path separator when set via env (`:` unix, `;` Windows) |
| `task.disable_spec_from_run_scripts` | `MISE_TASK_DISABLE_SPEC_FROM_RUN_SCRIPTS` | `bool` | `false` | Ignore `arg()`/`option()`/`flag()` in run scripts for spec generation; use only the `usage` field |
| `task.monorepo_depth` | `MISE_TASK_MONOREPO_DEPTH` | `int` | `5` | How deep to search for task files in monorepo mode (1 = immediate children) |
| `task.monorepo_exclude_dirs` | `MISE_TASK_MONOREPO_EXCLUDE_DIRS` (comma separated) | `string[]` | `[]` | Empty uses defaults `node_modules, target, dist, build`; **any value replaces the defaults entirely** |
| `task.monorepo_respect_gitignore` | `MISE_TASK_MONOREPO_RESPECT_GITIGNORE` | `bool` | `true` | Skip `.gitignore`d directories during monorepo discovery |
| `task.output` | `MISE_TASK_OUTPUT` | `string?` | `None` | Output style (see §7.7.3) |
| `task.remote_no_cache` | `MISE_TASK_REMOTE_NO_CACHE` | `bool?` | `None` | Always fetch the latest remote tasks |
| `task.run_auto_install` | `MISE_TASK_RUN_AUTO_INSTALL` | `bool` | `true` | Auto-install missing tools when executing tasks |
| `task.show_full_cmd` | `MISE_TASK_SHOW_FULL_CMD` | `bool` | `false` | Disable truncation of command lines in task output |
| `task.skip` | `MISE_TASK_SKIP` | `string[]` | `[]` | Tasks to skip when running `mise run` |
| `task.skip_depends` | `MISE_TASK_SKIP_DEPENDS` | `bool` | `false` | Run only specified tasks, skipping all dependencies |
| `task.source_freshness_equal_mtime_is_fresh` | `MISE_TASK_SOURCE_FRESHNESS_EQUAL_MTIME_IS_FRESH` | `bool` | `false` | Equal mtime counts as fresh (`<=` vs strict `<`) |
| `task.source_freshness_hash_contents` | `MISE_TASK_SOURCE_FRESHNESS_HASH_CONTENTS` | `bool` | `false` | blake3 content hashing instead of metadata |
| `task.timeout` | `MISE_TASK_TIMEOUT` | `string?` | `None` | Global default task timeout; the **shorter** of global and per-task wins; `--timeout` overrides |
| `task.timings` | `MISE_TASK_TIMINGS` | `bool?` | `None` | Show elapsed time per task; default shows when output type is `prefix` |

([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#task-configuration-settings))

---

### 7.9 Task templates (`[task_templates]` + `extends`)

Reusable task definitions, especially for monorepos ([tasks/templates](https://mise.jdx.dev/tasks/templates.html)):

```toml
[task_templates."python:build"]
description = "Build a Python project"
run = "uv build"
tools = { python = "3.12", uv = "latest" }
env = { PYTHONPATH = "src" }

[tasks.build]
extends = "python:build"

[tasks.test]
extends = "python:test"
run = "pytest --cov"  # Override run while keeping tools, depends
```

Templates use `:` for namespacing (`python:build`, `rust:cargo:build`).

| Field | Merge behavior |
| --- | --- |
| `run`, `run_windows` | local overrides completely |
| `tools` | **deep merge** (local added/overriding) |
| `env` | **deep merge** (local added/overriding) |
| `depends`, `depends_post`, `wait_for` | local overrides **completely** (not merged) |
| `dir` | local overrides; defaults to `config_root` if absent from the template |
| `sources`, `outputs`, `cache` | local overrides completely |
| `output` | local overrides template (if set) |
| Sandbox **deny** fields | compose with task-local settings |
| Sandbox **allow** fields | template and task-local values are **combined** |
| `description`, `shell`, `timeout`, etc. | local overrides template (if set) |
| `quiet`, `hide`, `raw`, `interactive`, `raw_args` | **not supported on templates** — set explicitly on each task |

Templates are Tera-rendered with the **using project's** context, so `{{ config_root }}` resolves to the consuming project's directory, not where the template is defined. `env`, `cwd`, and `vars.*` are also available.

Documented as planned but **not yet available**: global templates in `~/.config/mise/config.toml`, template packages from external sources, pattern-matching auto-apply rules, and file-task templates ([tasks/templates](https://mise.jdx.dev/tasks/templates.html#future-enhancements)).

---

### 7.10 Monorepo tasks

Enable with `monorepo_root = true` in the root `mise.toml`. mise then discovers tasks in subdirectories and prefixes them with their path from the monorepo root, creating one unified namespace ([tasks/monorepo](https://mise.jdx.dev/tasks/monorepo.html)).

```toml
# /myproject/mise.toml
monorepo_root = true

[tools]
node = "20"   # applies to all subdirectories

[monorepo]
config_roots = [
    "packages/frontend",
    "packages/backend",
    "services/*",          # single-level glob
]
```

```
myproject/
├── mise.toml (monorepo_root = true)
└── projects/
    ├── frontend/mise.toml   → //projects/frontend:build, //projects/frontend:test
    └── backend/mise.toml    → //projects/backend:build,  //projects/backend:test
```

#### 7.10.1 Path syntax

| Syntax | Meaning |
| --- | --- |
| `//path/to/project:task` | absolute path from the monorepo root |
| `:task` | task in the **current** config_root (recommended, explicit) |
| `task` | bare name in the current config_root — works, but supported mainly for migration compatibility |
| `./relative/...:task` | dependency paths starting with `./` resolve relative to the **declaring** task |
| `//...:task` | `...` = any directory depth |
| `//projects/...:build` | all subdirs under `projects/` |
| `//projects/.../api:build` | wildcards in the middle: matches `projects/*/api` and `projects/*/*/api` |
| `'//projects/frontend:*'` | all task names in one project (quote for the shell) |
| `'//...:test*'` | task-name wildcard across all projects |
| `'//...:*'` | everything, everywhere |

mise will **never** define commands with a `//` or `:` prefix, so the direct `mise //projects/frontend:build` form is safe in scripts — unlike the bare `mise <task>` shorthand. Recursive glob path patterns (`**`) are not yet supported; `...` follows the bazel/buck2 convention ([tasks/monorepo](https://mise.jdx.dev/tasks/monorepo.html#task-path-syntax)).

```toml
[tasks.test]
depends = [{ task = "./...:groups:tests:*", optional = true }]
```

Declared by `//apps/frontend:test`, that resolves to `//apps/frontend/...:groups:tests:*` — the current project and its descendants, without siblings.

#### 7.10.2 Layering

1. **Base**: tools, env, and vars from all global and parent configs in the hierarchy.
2. **Subdirectory override**: the subdirectory's own config merged on top.
3. **Task-specific**: the task's `tools` and `env` properties take highest precedence.

Task templates like `sources = ["{{env.SRC_DIR}}/*"]` are rendered with env from the **task's own** config hierarchy, so a subproject's `[env]` applies no matter where the task is invoked. Child `task_config.includes` templates can reference inherited vars, e.g. `git::https://example.com/tasks.git//go.toml?ref={{vars.central_ref}}`. Trust propagates automatically: trusting the monorepo root trusts all descendant configs ([tasks/monorepo](https://mise.jdx.dev/tasks/monorepo.html#tool-environment-and-vars-layering)).

#### 7.10.3 Discovery, config roots, and nesting

`[monorepo].config_roots` gives fast, explicit discovery with single-level `*` globs (recursive `**` is deliberately unsupported). **Automatic filesystem walking is deprecated** — without `config_roots`, mise still walks but emits a deprecation warning.

When multiple configs in the hierarchy set `monorepo_root = true` (common with git worktrees checked out inside the main checkout), the **nearest** one wins. Tasks from the enclosing monorepo are not loaded — they belong to a different task set, and loading them would place them outside the `//` namespace. The enclosing config still contributes **tools, env, and vars** as an ordinary ancestor; keep worktrees outside the checkout to avoid that too ([tasks/monorepo](https://mise.jdx.dev/tasks/monorepo.html#nested-monorepo-roots)).

Depth and exclusion are tuned by `task.monorepo_depth` (default 5), `task.monorepo_exclude_dirs`, and `task.monorepo_respect_gitignore` (see §7.8.3).

#### 7.10.4 Listing

| Command | Scope |
| --- | --- |
| `mise tasks` | current config_root hierarchy (current root and its parents) |
| `mise tasks --all` | the entire monorepo, including sibling and descendant directories |
| `mise tasks '//projects/frontend:*'` | one project |

([tasks/monorepo](https://mise.jdx.dev/tasks/monorepo.html#listing-tasks))

#### 7.10.5 Monorepo tools and lockfiles

`mise install --monorepo` installs the union of tools from every directory in `[monorepo].config_roots` (useful for CI cache warming); passing a tool name filters the union while preserving multiple configured versions. `mise ls --monorepo` lists the same union. Both require `monorepo_root = true` **and** explicit `config_roots` ([tasks/monorepo](https://mise.jdx.dev/tasks/monorepo.html#tools)).

Lockfiles are a **tri-state rollout** ([tasks/monorepo](https://mise.jdx.dev/tasks/monorepo.html#lockfiles)):

| `[monorepo] lockfile` | Behavior |
| --- | --- |
| unset | today's per-subproject lockfile behavior; starts warning in **2026.12.0**, defaults to root lockfiles in **2027.6.0** |
| `true` | opt in now: tools from `packages/api/mise.toml` write to `<monorepo_root>/mise.lock`; env/local variants write to `mise.ci.lock`, `mise.local.lock`. Old subproject lockfiles are migrated on the next lock-aware command (root entries win on conflict, unique subproject entries preserved, migrated files removed) |
| `false` | pin the old per-subproject behavior — needed for mixed-version teams, since older mise versions don't understand unified monorepo lockfiles |

#### 7.10.6 Workspace project graph — *experimental*

Requires `experimental = true` plus `monorepo_root = true`. mise infers a provider-neutral project graph from ecosystem workspace metadata; a project does **not** need its own `mise.toml` to appear. Inspect with `mise tasks graph` / `mise tasks graph --json` ([tasks/monorepo](https://mise.jdx.dev/tasks/monorepo.html#workspace-project-graph-experimental), [cli/tasks/graph](https://mise.jdx.dev/cli/tasks/graph.html)).

**Node discovery sources:** `pnpm-workspace.yaml`, the `workspaces` array in the root `package.json`, the single-pattern string form, and the Yarn Classic `workspaces.packages` object form. When both files exist, `pnpm-workspace.yaml` defines membership. Positive/negative patterns, recursive `**`, and brace patterns (`packages/{web,api}`) are supported. Discovery skips `.git` and `node_modules` but does **not** apply `.gitignore` or `.ignore`. Each package needs a `name`, which yields a stable ID like `node:@acme/web` that survives directory moves.

**Dependency inference** reads `dependencies`, `devDependencies`, `optionalDependencies`, and `peerDependencies`. A declared name that exactly matches another discovered package creates an edge; external names and self-references are ignored. Version strings are opaque — `workspace:*`, `catalog:`, `*`, or a normal range all produce the same edge. All four kinds participate; a cycle is reported rather than silently dropped.

**Imported package scripts** become tasks named `<project-id>#<script>`, with the monorepo path available as an alias:

```bash
mise run 'node:@acme/web#build'
mise run //apps/web:build
mise //...:test
```

They run in the package directory through the workspace package manager (`npm`, `pnpm`, `yarn`, `bun`) selected from the root `packageManager` declaration or lockfile, falling back to npm; arguments pass through. `mise task info` reports the package's `package.json` as the source. An explicit mise task at the package's monorepo path takes precedence, and both names resolve to it.

**Root task defaults** apply shared config to same-named tasks across every workspace project; task-local config and `extends` templates take precedence. Experimental — ignored unless experimental features are on:

```toml
[monorepo.task_defaults.build]
sources = ["src/**", "package.json"]
outputs = ["dist/**"]
cache = { enabled = true }
depends = ["^build"]

[monorepo.task_defaults.test]
env = { NODE_ENV = "test" }
```

**`^` upstream dependencies** run the named task in upstream workspace projects first, following the complete project dependency graph including through intermediate projects that don't define the task; missing upstream tasks are skipped. `^` is **only** valid in `depends` — it is rejected in `depends_post` and `wait_for` because those don't describe prerequisite work. Uses the ordinary scheduler: cycle detection, dedup, parallelism, cache-key propagation.

**Project overrides** correct provider inference (IDs with `:` or scoped names must be quoted):

```toml
[monorepo.projects."node:@acme/web"]
root = "apps/web"
depends_add = ["custom:docs"]
depends_remove = ["node:@acme/legacy"]

[monorepo.projects."custom:docs"]
root = "docs"
metadata = { kind = "documentation" }
```

| Override field | Effect |
| --- | --- |
| `remove = true` | remove an inferred project and its connected edges |
| `root`, `metadata` | replace inferred values |
| `depends` | replace the complete inferred dependency set |
| `depends_add` / `depends_remove` | adjust individual edges |
| new namespaced ID + `root` | add a provider-independent project |

The final graph must reference existing IDs and be acyclic; diagnostics name the affected projects and the override fields that can repair it.

> Note the docs' own comparison table marks **task caching** as ❌ for mise relative to Nx/Turborepo/Bazel ([tasks/monorepo](https://mise.jdx.dev/tasks/monorepo.html#the-mise-sweet-spot)) — while §7.3.2 documents an experimental artifact cache. Read the ❌ as "not yet a mature/remote caching story."

---

### 7.11 Architecture and internals

mise builds a **directed acyclic graph** of tasks and dependencies on every run, guaranteeing: dependencies precede dependents, independent tasks run in parallel, no cycles exist, and failed dependencies prevent dependents from running ([tasks/architecture](https://mise.jdx.dev/tasks/architecture.html#dependency-graph-resolution)).

**Resolution pipeline** for `mise run build`:

1. Discover all tasks from all configuration sources
2. Resolve the task name (aliases, partial matches)
3. Build the dependency graph, including all dependencies
4. Validate the graph (circular-dependency check)
5. Execute in dependency order with parallelism

**Discovery order:** file tasks (executables in task directories) → TOML tasks in `mise.toml` → parent-directory tasks. Parent tasks are visible in subdirectories and can be overridden by a same-named local task ([tasks/architecture](https://mise.jdx.dev/tasks/architecture.html#task-discovery-and-resolution)).

```mermaid
graph LR
  lint --> test_unit[test-unit]
  lint --> test_int[test-integration]
  test_unit --> build
  test_int --> build
```

With `--jobs 2`, the docs' worked example runs `lint` alone, then `test-unit` and `test-integration` in parallel, then `build` ([tasks/architecture](https://mise.jdx.dev/tasks/architecture.html#example-execution-flow)).

**Cross-project dependencies** reference tasks in other directories:

```toml
[tasks.deploy-all]
depends = [
  "../api:build",
  "../frontend:build",
  "deploy-infrastructure"
]
run = "echo 'All services deployed'"
```

**Dynamic dependencies** — a file task can declare `#MISE depends=[...]` and additionally shell out to `mise run <other>` conditionally at runtime.

**Debugging:**

| Command | Purpose |
| --- | --- |
| `mise tasks deps build` | tree view of a task's dependencies |
| `mise tasks deps --dot > deps.dot` | graphviz DOT output |
| `mise run --verbose build` | task execution details |
| `mise run --dry-run build` | show what would run without executing |

**Common errors** and their documented fixes:

| Error | Fix |
| --- | --- |
| `Circular dependency detected: test → build → test` | remove the cycle, or use `wait_for` instead of `depends` |
| `Task 'build' depends on 'lint' but 'lint' was not found` | define the task or drop the dependency |
| slow parallel execution | remove unnecessary dependencies, inspect with `mise tasks deps`, raise `--jobs` |

([tasks/architecture](https://mise.jdx.dev/tasks/architecture.html#debugging-task-dependencies))

> **Note:** the architecture page says `depends_post` runs "whether successful or failed", while the task-configuration page says it runs "after this task and its dependencies complete". The failure-path behavior is only asserted on the architecture page ([tasks/architecture](https://mise.jdx.dev/tasks/architecture.html#depends-post-cleanup-tasks), [tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#depends-post)).

---

### 7.12 Task CLI reference

#### `mise tasks` — `mise t`

`mise tasks [FLAGS] [TASK] <SUBCOMMAND>` — read-only. `[TASK]` gets info for that task ([cli/tasks](https://mise.jdx.dev/cli/tasks.html)).

| Global flag | Meaning |
| --- | --- |
| `-g --global` | only global tasks |
| `-l --local` | only non-global tasks |
| `-J --json` | JSON output |
| `-x --extended` | show all columns |
| `--all` | load all tasks from the entire monorepo including sibling directories |
| `--hidden` | show tasks with `hide = true` |
| `--name-only` | one task name per line — pipe to fzf |
| `--no-header` | omit the table header |
| `--sort <COLUMN>` | `name` (default) \| `alias` \| `description` \| `source` |
| `--sort-order <ORDER>` | `asc` (default) \| `desc` |

#### `mise tasks ls`

Same flags as above. Merges tasks from all parent directories; project-specific tasks (`~/myproject/.mise/tasks/*`) override global ones (`~/.config/mise/tasks/*`) with the same name ([cli/tasks/ls](https://mise.jdx.dev/cli/tasks/ls.html)).

#### `mise tasks add`

`mise tasks add [FLAGS] <TASK> [-- RUN]…` — modifies state; writes to the local `mise.toml` ([cli/tasks/add](https://mise.jdx.dev/cli/tasks/add.html)).

| Flag | Meaning |
| --- | --- |
| `-a --alias… <ALIAS>` | other names for the task |
| `-d --depends… <DEPENDS>` | dependencies |
| `-D --dir <DIR>` | run the task in a specific directory |
| `-f --file` | create a **file** task instead of a TOML task |
| `-H --hide` | hide from `mise tasks` and completions |
| `-q --quiet` | do not print the command before running |
| `-r --raw` | directly connect stdin/stdout/stderr |
| `-s --sources… <SOURCES>` | input glob patterns |
| `-w --wait-for… <WAIT_FOR>` | soft dependencies |
| `--depends-post… <DEPENDS_POST>` | post dependencies |
| `--description <DESCRIPTION>` | task description |
| `--outputs… <OUTPUTS>` | output glob patterns |
| `--run-windows <RUN_WINDOWS>` | Windows command |
| `--shell <SHELL>` | shell to run in |
| `--silent` | do not print the command or its output |

```shell
mise tasks add pre-commit --depends "test" --depends "render" -- echo pre-commit
```

```toml
[tasks.pre-commit]
depends = ["test", "render"]
run = "echo pre-commit"
```

#### `mise tasks deps`

`mise tasks deps [FLAGS] [TASKS]…` — read-only tree visualization ([cli/tasks/deps](https://mise.jdx.dev/cli/tasks/deps.html)).

| Flag | Meaning |
| --- | --- |
| `--compact` | collapse repeated dependencies after their first occurrence |
| `--dot` | emit DOT format |
| `--hidden` | include hidden tasks |

```bash
mise tasks deps                    # all tasks
mise tasks deps lint test check    # specific tasks
mise tasks deps --dot              # DOT format
mise tasks deps --compact
```

#### `mise tasks graph` — *experimental*

`mise tasks graph [-J --json] [--no-header]` — inspects the **workspace project graph** (§7.10.6), not the task dependency tree. For task dependencies use `mise tasks deps` ([cli/tasks/graph](https://mise.jdx.dev/cli/tasks/graph.html)).

#### `mise tasks info`

`mise tasks info [-J --json] <TASK>` ([cli/tasks/info](https://mise.jdx.dev/cli/tasks/info.html)):

```
$ mise tasks info
Name: test
Aliases: t
Description: Test the application
Source: ~/src/myproj/mise.toml

$ mise tasks info test --json
{
  "name": "test",
  "aliases": "t",
  "description": "Test the application",
  "source": "~/src/myproj/mise.toml",
  "config_sources": ["~/src/myproj/mise.toml"],
  "depends": [], "env": {}, "dir": null, "hide": false, "raw": false,
  "sources": [], "outputs": [],
  "run": ["echo \"testing!\""],
  "file": null, "usage_spec": {}
}
```

#### `mise tasks edit`

`mise tasks edit [-p --path] <TASK>` — opens the task in `$EDITOR`, creating it as a standalone script if it doesn't exist. `-p --path` prints the path instead of editing ([cli/tasks/edit](https://mise.jdx.dev/cli/tasks/edit.html)).

#### `mise tasks validate`

`mise tasks validate [--errors-only] [--json] [TASKS]…` — validates all tasks when none are named ([cli/tasks/validate](https://mise.jdx.dev/cli/tasks/validate.html)).

| Check | Detects |
| --- | --- |
| Circular Dependencies | dependency cycles |
| Missing References | references to nonexistent tasks |
| Usage Spec Parsing | invalid `#USAGE` directives and specs |
| Timeout Format | invalid duration values |
| Alias Conflicts | duplicate aliases across tasks |
| File Existence | missing files for file-based tasks |
| Directory Templates | invalid directory paths and templates |
| Shell Commands | shell executables that don't exist |
| Glob Patterns | invalid `sources` / `outputs` patterns |
| Run Entries | `run` entries referencing invalid dependencies |

---

### 7.13 Generating task docs and stubs

#### `mise generate task-docs`

`mise generate task-docs [FLAGS]` — renders Markdown documentation for a project's tasks ([cli/generate/task-docs](https://mise.jdx.dev/cli/generate/task-docs.html)).

| Flag | Type/Default | Meaning |
| --- | --- | --- |
| `-i --inject` | bool | insert into an existing file between `<!-- mise-tasks -->` and `<!-- /mise-tasks -->`, replacing everything between them (re-runnable). **Both** comments must already exist or mise errors instead of modifying the file |
| `-I --index` | bool | write only an index of tasks; intended for use with `--multi` |
| `-m --multi` | bool | render each task as a separate document; requires `--output` to be a directory |
| `-o --output <OUTPUT>` | path | write generated docs to a file/directory |
| `-r --root <ROOT>` | path | root directory to search for tasks |
| `-s --style <STYLE>` | `simple` (default) \| `detailed` | rendering style |

#### `mise generate task-stubs`

`mise generate task-stubs [-d --dir <DIR>] [-m --mise-bin <MISE_BIN>]` — builds shims like `./bin/<task>` so contributors can run mise tasks without installing mise system-wide. Pairs with `mise generate bootstrap` ([cli/generate/task-stubs](https://mise.jdx.dev/cli/generate/task-stubs.html)).

| Flag | Default | Meaning |
| --- | --- | --- |
| `-d --dir <DIR>` | `bin` | directory to create task stubs in |
| `-m --mise-bin <MISE_BIN>` | `mise` | mise binary the stub invokes; use `--mise-bin=./bin/mise` with a bootstrap-generated binary |

```
$ mise tasks add test -- echo 'running tests'
$ mise generate task-stubs
$ ./bin/test
running tests
```

---

### 7.14 Watching — `mise watch` / `mise w`

`mise watch [FLAGS] [TASK] [ARGS]…` re-runs tasks when files change. It **shells out to `watchexec`**, which must be installed (`mise use -g watchexec@latest`); the docs note this may change in the future. Multiple tasks use the same `:::` separator. For daemon management, auto-restart, readiness checks, and cron, the docs point at the sister project [pitchfork](https://pitchfork.jdx.dev) ([cli/watch](https://mise.jdx.dev/cli/watch.html), [tasks/running-tasks](https://mise.jdx.dev/tasks/running-tasks.html#watching-files)).

By default `mise watch <task>` watches the paths from the task's `sources` ([cli/watch](https://mise.jdx.dev/cli/watch.html) examples):

```bash
$ mise watch build
# Re-runs "build" when any of its `sources` change.

$ mise watch build --glob src/**/*.rs
# Overrides the task's `sources` with an explicit glob.

$ mise watch build --clear
# Extra arguments are passed straight to watchexec.

$ mise watch serve --watch src --exts rs --restart
# Kills/restarts the server when any *.rs under ./src changes.
```

mise-specific flag: `--skip-deps` (run only the specified tasks, skipping dependencies). Everything else is watchexec's own surface, passed through:

| Flag group | Flags |
| --- | --- |
| Paths | `-w --watch <PATH>`, `-W --watch-non-recursive <PATH>`, `-F --watch-file <PATH>` (`-` reads stdin, incompatible with `--stdin-quit`), `--project-origin <DIR>`, `--workdir <DIR>` |
| Busy behavior | `-o --on-busy-update <queue\|do-nothing\|restart\|signal>` (**default `do-nothing`**), `-r --restart` (= `--on-busy-update=restart`), `-s --signal <SIGNAL>`, `--stop-signal <SIGNAL>` (unix default `SIGTERM`), `--stop-timeout <TIMEOUT>` (**default `10s`**, `0` = immediate force-kill), `--map-signal <SIG:SIG>` |
| Timing | `-d --debounce <TIMEOUT>` (**default `50ms`**; `0` strongly discouraged), `--delay-run <DURATION>`, `-p --postpone` (wait for the first change before running), `--poll <INTERVAL>` (default 30s, alias `--force-poll`) |
| Filtering | `-e --exts <EXTENSIONS>`, `-f --filter <PATTERN>`, `--filter-file <PATH>`, `-J --filter-prog <EXPRESSION>` (**experimental** jaq programs), `-i --ignore <PATTERN>`, `--ignore-file <PATH>`, `--fs-events <access\|create\|remove\|rename\|modify\|metadata>` (**default `create,remove,rename,modify,metadata`**), `--no-meta` |
| Ignore discovery | `--no-vcs-ignore`, `--no-project-ignore`, `--no-global-ignore`, `--no-default-ignore`, `--no-discover-ignore`, `--ignore-nothing` |
| Shell | `--shell <SHELL>` (`none` disables shell use), `-n` (= `--shell=none`) |
| Output/UX | `-c --clear <clear\|reset>`, `-N --notify`, `--color <auto\|always\|never>` (`NO_COLOR` ≡ `never`), `--timings`, `-q --quiet`, `--bell`, `--print-events`, `--manual` |
| Events | `--emit-events-to <environment\|stdio\|file\|json-stdio\|json-file\|none>` (**default `none`**; `environment` is deprecated), `--only-emit-events` (requires `--emit-events-to`, restricted to `stdio`/`json-stdio`) |
| Process | `-E --env <KEY=VALUE>`, `--wrap-process <group\|session\|none>`, `--stdin-quit` |

Watchexec's default ignores cover editor swap files, `*.pyc`, `*.pyo`, `.DS_Store`, `.bzr`, `_darcs`, `.fossil-settings`, `.git`, `.hg`, `.pijul`, `.svn`, and watchexec log files. Watching a single file is discouraged — watch the containing directory and filter on the filename, because some editors replace files on save.

> **Uncertainty:** `--glob` appears in the `mise watch` examples on [cli/watch](https://mise.jdx.dev/cli/watch.html) but is not listed among the documented flags on that page.

---

### 7.15 Quick precedence summary

| Question | Answer |
| --- | --- |
| Which shell runs an inline `run`? | task `shell` → task template `shell` → `task_config.shell` (cascaded) → `--shell` CLI → `unix_default_inline_shell_args` / `windows_default_inline_shell_args` ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#task-config-shell)) |
| Where does a task run? | task `dir` → `task_config.dir` → `{{ config_root }}` ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#dir)) |
| Which value wins for a usage arg? | CLI argument > `env=` variable > `default=` ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#environment-variable-support-for-args-and-flags)) |
| Which task wins on a duplicate name? | later `task_config.includes` entry wins; project-local overrides global; explicit mise task beats a provider-inferred one ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#task-config-includes), [cli/tasks/ls](https://mise.jdx.dev/cli/tasks/ls.html), [tasks/monorepo](https://mise.jdx.dev/tasks/monorepo.html#node-package-scripts)) |
| Which timeout applies? | the **shorter** of `task.timeout` and the task's `timeout`; `--timeout` overrides the global setting ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#task.timeout)) |
| Which tool version does a task use? | task `tools` > subproject config `[tools]` > parent/global configs ([tasks/monorepo](https://mise.jdx.dev/tasks/monorepo.html#layering-rules)) |
| Which sources entry decides inclusion? | the **last** matching entry, negated or not ([tasks/task-configuration](https://mise.jdx.dev/tasks/task-configuration.html#excluding-sources)) |
| Which monorepo root applies? | the **nearest** config with `monorepo_root = true` ([tasks/monorepo](https://mise.jdx.dev/tasks/monorepo.html#nested-monorepo-roots)) |

---

## 8. Plugins

Plugins extend mise with new functionality — extra tools, environment variables, or machine-global package managers. Historically a plugin was the *only* way to add a tool, because asdf was the only backend. With [core tools](https://mise.jdx.dev/core-tools.html) and backends like `aqua`/`github`, plugins are no longer necessary to run most tools ([plugins](https://mise.jdx.dev/plugins.html)).

### 8.1 Do you actually need a plugin?

Read this before writing one. The mise docs are explicit that plugins are a last resort:

> Tool plugins should be avoided for security reasons. New tools will not be accepted into mise built with asdf/plugins unless they are very popular and aqua/github is not an option for some reason. ([plugins](https://mise.jdx.dev/plugins.html))

**Preference order for making a tool installable** ([asdf-legacy-plugins](https://mise.jdx.dev/asdf-legacy-plugins.html), [plugins](https://mise.jdx.dev/plugins.html)):

1. [aqua backend](https://mise.jdx.dev/dev-tools/backends/aqua.html) — preferred; better UX, SLSA verification, per-version logic
2. [github backend](https://mise.jdx.dev/dev-tools/backends/github.html) — simple GitHub releases
3. Language package managers — npm, pipx, cargo, gem ([backends](https://mise.jdx.dev/dev-tools/backends/))
4. [Backend plugins](https://mise.jdx.dev/backend-plugin-development.html) — one plugin, many tools
5. [Tool plugins](https://mise.jdx.dev/tool-plugin-development.html) — hook-based, cross-platform
6. asdf (legacy) shell plugins — only for compatibility

**The legitimate reasons to still write a plugin** ([plugins](https://mise.jdx.dev/plugins.html)):

| Reason | Why a registry backend can't do it |
| --- | --- |
| The tool must set env vars beyond `PATH` | aqua/github only place binaries on `PATH` |
| Complex/unique installation process (source compilation, multi-artifact) | aqua/github install a release asset |
| Needs to set env vars **globally**, without a tool being installed | [Plugin-provided `env._` directives](https://mise.jdx.dev/environments/#plugin-provided-env-directives) |
| Needs to provide [aliased versions](https://mise.jdx.dev/dev-tools/aliases.html#aliased-versions) | Registry backends have no alias hook (except registry-declared parsers) |
| Private/internal tool registries | Not in a public registry |
| Machine-global host-owned state (VS Code extensions, krew, helm plugins) | Not a `[tools]` concern at all ([bootstrap/packages/plugins](https://mise.jdx.dev/bootstrap/packages/plugins.html)) |

> **Registry submission is closed to plugins.** "New asdf and vfox plugins are not accepted into the [mise registry](https://github.com/jdx/mise/blob/main/registry/) for supply-chain security reasons — for registry submissions use the [aqua](https://mise.jdx.dev/dev-tools/backends/aqua.html) (preferred) or [github](https://mise.jdx.dev/dev-tools/backends/github.html) backend instead." ([asdf-legacy-plugins](https://mise.jdx.dev/asdf-legacy-plugins.html), [dev-tools/backends/asdf](https://mise.jdx.dev/dev-tools/backends/asdf.html))

Note also that registry-backed tools can now declare idiomatic-version-file parsers (`version_regex`, `version_json_path`, `version_expr`, borrowed from the [http backend](https://mise.jdx.dev/dev-tools/backends/http.html#version-listing)), so JSON manifests and tool-specific version files no longer require an asdf or vfox plugin ([configuration](https://mise.jdx.dev/configuration.html)).

### 8.2 The five plugin kinds

| Plugin kind | Language | Required entrypoints | Use case |
| --- | --- | --- | --- |
| **Tool plugin** (vfox-compatible) | Lua 5.1 | `metadata.lua`; `hooks/available.lua` (`Available`), `hooks/pre_install.lua` (`PreInstall`), `hooks/env_keys.lua` (`EnvKeys`) | One tool with complex install logic, source compilation, non-`PATH` env vars, or legacy version-file parsing ([tool-plugin-development](https://mise.jdx.dev/tool-plugin-development.html)) |
| **Backend plugin** | Lua 5.1 | `metadata.lua`; `hooks/backend_list_versions.lua`, `hooks/backend_install.lua`, `hooks/backend_exec_env.lua` | One plugin managing *many* tools via the `plugin:tool` format — package managers, tool families, private registries ([backend-plugin-development](https://mise.jdx.dev/backend-plugin-development.html)) |
| **Environment plugin** | Lua 5.1 | `metadata.lua`; `hooks/mise_env.lua` (`MiseEnv`). `hooks/mise_path.lua` (`MisePath`) optional | Env vars + PATH with **no** version management — secret managers, dynamic config, team standardization. Activated via `env._.<name>` ([env-plugin-development](https://mise.jdx.dev/env-plugin-development.html)) |
| **Package plugin** | Lua 5.1 | `metadata.lua`, `mise.plugin.toml`; `hooks/package_installed.lua` (`PackageInstalled`) **and** `hooks/package_install.lua` (`PackageInstall`). `hooks/package_upgrade.lua` optional | Machine-global manager for `[bootstrap.packages]` wrapping state owned by a host tool — VS Code extensions, krew, helm plugins, `gh` extensions ([package-plugin-development](https://mise.jdx.dev/package-plugin-development.html)) |
| **asdf (legacy) plugin** | Bash / shell scripts | `bin/list-all`, `bin/download`, `bin/install` | Backward compatibility with the asdf ecosystem. Linux/macOS only, slower, less secure ([asdf-legacy-plugins](https://mise.jdx.dev/asdf-legacy-plugins.html)) |

All four Lua kinds are implemented in **Lua 5.1** ("at the moment"), executed by the interpreter built into mise — no extra system packages are needed to run the vfox backend ([dev-tools/backends/vfox](https://mise.jdx.dev/dev-tools/backends/vfox.html)).

#### 8.2.1 Kind detection

* A repo with **both** `hooks/package_installed.lua` and `hooks/package_install.lua` is a **package plugin**. With only one of the two, it stays a regular vfox plugin. If `hooks/backend_install.lua` is *also* present, mise treats the repo as a tool backend instead — **package and tool-backend plugins must be separate repositories** ([package-plugin-development](https://mise.jdx.dev/package-plugin-development.html)).
* In `[plugins]`, the type prefix (`asdf:`, `vfox:`, `vfox-backend:`) is optional; if omitted mise clones the plugin first and detects the type from the installed files ([configuration](https://mise.jdx.dev/configuration.html#plugins-specify-custom-plugin-repository-urls)).

#### 8.2.2 asdf vs vfox feature comparison

| Feature | asdf Plugins | vfox Plugins |
| --- | --- | --- |
| Language | Bash scripts | Lua |
| Windows Support | ❌ | ✅ |
| Built-in HTTP module | ❌ (requires curl) | ✅ |
| Built-in JSON module | ❌ (requires jq) | ✅ |
| Built-in HTML parsing | ❌ | ✅ |
| Built-in archive extraction | ❌ | ✅ |
| Built-in semver module | ❌ | ✅ |
| Built-in logging | ❌ | ✅ |
| Post-install hooks | ❌ | ✅ |
| Security attestations | ❌ | ✅ (cosign, SLSA) |
| Multi-tool plugins | ❌ | ✅ (backend plugins) |
| Lock file support | ❌ | ✅ |
| Rolling version checksums | ❌ | ✅ |

([dev-tools/backends/asdf](https://mise.jdx.dev/dev-tools/backends/asdf.html#feature-comparison-asdf-vs-vfox))

### 8.3 Installing, linking, updating, removing

```bash
# From a git repository
mise plugin install <plugin-name> <repository-url>
mise plugin install vfox-npm https://github.com/jdx/vfox-npm

# From a zip file over HTTPS
mise plugin install <plugin-name> <zip-url>
mise plugin install vfox-cmake https://github.com/mise-plugins/vfox-cmake/archive/refs/heads/main.zip

# Pin a specific git ref with '#'
mise plugins install poetry https://github.com/mise-plugins/mise-poetry.git#11d0c1e

# Infer the plugin name from the URL
mise plugins install https://github.com/mise-plugins/mise-poetry.git

# Shorthand (registry) install
mise plugins install poetry

# From a local directory (development)
mise plugin link <plugin-name> /path/to/plugin/directory

# Package plugins get a 'package:' prefix when installed ad-hoc
mise plugin install package:vscode https://github.com/mise-plugins/mise-vscode-extensions
```

([plugin-usage](https://mise.jdx.dev/plugin-usage.html), [cli/plugins/install](https://mise.jdx.dev/cli/plugins/install.html), [dev-tools/backends/vfox](https://mise.jdx.dev/dev-tools/backends/vfox.html), [bootstrap/packages/plugins](https://mise.jdx.dev/bootstrap/packages/plugins.html))

Plugins are auto-installed on demand: "mise can automatically install plugins when you install a tool e.g.: `mise install cmake@3.30` will autoinstall the cmake plugin. This behavior can be modified in `~/.config/mise/config.toml`" ([cli/plugins/install](https://mise.jdx.dev/cli/plugins/install.html)).

```bash
# Management
mise plugins ls                  # list installed
mise plugins ls --urls           # with git URLs
mise plugin update vfox-npm      # update one plugin
mise plugin update --all         # update all
mise plugin remove vfox-npm      # also removes tools installed by the plugin
```

([plugin-usage](https://mise.jdx.dev/plugin-usage.html))

Once installed, a **backend plugin** is used with the `plugin:tool` format:

```bash
mise install vfox-npm:prettier@latest
mise use     vfox-npm:prettier@3.0.0
mise exec    vfox-npm:prettier -- --version
mise ls-remote vfox-npm:prettier
```

A **tool plugin** is used with the tool name directly (`mise install my-tool@1.0.0`, `mise use my-tool@latest`) ([plugin-usage](https://mise.jdx.dev/plugin-usage.html)).

The plugin name does **not** have to match the repository name — the backend prefix matches whatever name the plugin was installed as. The docs note this could be used deliberately: "you could install the same plugin with different names to configure different behaviors or access different tool registries" ([backend-plugin-development](https://mise.jdx.dev/backend-plugin-development.html#usage-example)).

#### 8.3.1 `mise plugins` CLI reference

`mise plugins [FLAGS] <SUBCOMMAND>` — alias `p`; effect: read-only ([cli/plugins](https://mise.jdx.dev/cli/plugins.html)).

| Flag | Meaning |
| --- | --- |
| `-c --core` | The built-in plugins only. Normally these are not shown |
| `-u --urls` | Show the git url for each plugin, e.g. `https://github.com/mise-plugins/vfox-cmake.git` |
| `--user` | List installed plugins. Default behavior; usable with `--core` to show core **and** user plugins |

| Subcommand | Aliases | Effect | Notes |
| --- | --- | --- | --- |
| `plugins install [FLAGS] [NEW_PLUGIN] [GIT_URL]` | `i`, `a`, `add` | modifies state | ([cli/plugins/install](https://mise.jdx.dev/cli/plugins/install.html)) |
| `plugins link [-f --force] <NAME> [DIR]` | `ln` | modifies state | ([cli/plugins/link](https://mise.jdx.dev/cli/plugins/link.html)) |
| `plugins ls [-o --outdated] [-u --urls]` | `list` | read-only | ([cli/plugins/ls](https://mise.jdx.dev/cli/plugins/ls.html)) |
| `plugins ls-remote [-u --urls] [--only-names]` | `list-remote`, `list-all` | read-only | ([cli/plugins/ls-remote](https://mise.jdx.dev/cli/plugins/ls-remote.html)) |
| `plugins uninstall [-a --all] [-p --purge] [PLUGIN]…` | `remove`, `rm` | **destructive** | ([cli/plugins/uninstall](https://mise.jdx.dev/cli/plugins/uninstall.html)) |
| `plugins update [-j --jobs <JOBS>] [PLUGIN]…` | `up`, `upgrade` | modifies state | ([cli/plugins/update](https://mise.jdx.dev/cli/plugins/update.html)) |

**`mise plugins install`** arguments and flags:

| Name | Type/Default | Meaning |
| --- | --- | --- |
| `[NEW_PLUGIN]` | positional, repeatable | Plugin name, e.g. `cmake`, `poetry`. Multiple: `mise plugins install cmake poetry` |
| `[GIT_URL]` | positional | The git url of the plugin |
| `-a --all` | flag | Install all missing plugins. Only installs plugins that have matching shorthands (no full git URL needed) |
| `-f --force` | flag | Reinstall even if plugin exists |
| `-j --jobs <JOBS>` | number | Number of jobs to run in parallel |
| `-v --verbose…` | repeatable flag | Show installation output |

**`mise plugins link`** — "Symlinks a plugin into mise. This is used for developing a plugin."

| Name | Meaning |
| --- | --- |
| `<NAME>` | The name of the plugin, e.g. `cmake`, `poetry` |
| `[DIR]` | The local path to the plugin, e.g. `./vfox-cmake` |
| `-f --force` | Overwrite existing plugin |

```bash
# essentially just `ln -s ./vfox-cmake ~/.local/share/mise/plugins/cmake`
$ mise plugins link cmake ./vfox-cmake

# infer plugin name as "cmake"
$ mise plugins link ./vfox-cmake
```

**`mise plugins ls`**

| Flag | Meaning |
| --- | --- |
| `-o --outdated` | Show plugins with available updates; checks the remote for newer versions and only displays outdated plugins |
| `-u --urls` | Show the git url for each plugin |

```
$ mise plugins ls
cmake
poetry

$ mise plugins ls --urls
cmake     https://github.com/mise-plugins/vfox-cmake.git
poetry    https://github.com/mise-plugins/vfox-poetry.git
```

**`mise plugins ls-remote`** — "List all available remote plugins. The full list is here: <https://github.com/jdx/mise/blob/main/registry/>"

| Flag | Meaning |
| --- | --- |
| `-u --urls` | Show the git url for each plugin |
| `--only-names` | Only show the name of each plugin; by default it shows a `*` next to installed plugins |

**`mise plugins uninstall`**

| Flag | Meaning |
| --- | --- |
| `-a --all` | Remove all plugins |
| `-p --purge` | Also remove the plugin's installs, downloads, and cache |

**`mise plugins update`** — "note: this updates the plugin itself, not the runtime versions"

| Flag | Type/Default | Meaning |
| --- | --- | --- |
| `-j --jobs <JOBS>` | number, default `4` | Number of jobs to run in parallel |

```
mise plugins update              # update all plugins
mise plugins update cmake       # update only cmake
mise plugins update cmake#beta  # specify a ref
```

### 8.4 The `[plugins]` config table and shorthand registry

`[plugins]` adds or modifies plugin **shortnames**. It only affects *new* plugin installations; existing plugins can use any URL ([configuration](https://mise.jdx.dev/configuration.html#plugins-specify-custom-plugin-repository-urls)).

```toml
[plugins]
elixir = "https://github.com/my-org/mise-elixir.git"
node = "https://github.com/my-org/mise-node.git#DEADBEEF" # supports specific gitref
"vfox-backend:myplugin" = "https://github.com/jdx/vfox-npm"
```

| Rule | Detail |
| --- | --- |
| Type prefix | `asdf:`, `vfox:` or `vfox-backend:` is **optional**; if omitted mise clones first and detects the type from the installed plugin files |
| Scope | Only affects *new* installations. Use `mise plugins install --force <NAME>` to replace an existing plugin with the configured source |
| One-off installs | "If you simply want to install a plugin from a specific URL once, it's better to use `mise plugin install <NAME> <GIT_URL>`." Use `[plugins]` to share the location/revision with the project's other developers |
| Local directories | Absolute paths and `~/...` are used directly. Explicit relative paths beginning with `./` or `../` resolve relative to the **config root of the file that declares them** |
| Local semantics | Local plugins are **symlinked** into mise's plugin directory, matching `mise plugins link`, so source edits apply immediately |
| `file://` | `file://` sources remain Git repositories and are **cloned** (not symlinked) |
| Deprecation | This replaces the deprecated `settings.shorthands_file` / `MISE_SHORTHANDS_FILE` mechanism — put the same `shortname = "backend-or-url"` entries under `[plugins]` instead of a separate TOML file |

```toml
[plugins]
example = "./plugins/mise-example"
```

Plugin repository values are **templates** ([plugins](https://mise.jdx.dev/plugins.html#templates), [templates](https://mise.jdx.dev/templates.html)):

```toml
[plugins]
"vfox-backend:my-plugin" = "https://{{ get_env(name='GIT_USR', default='empty') }}:{{ get_env(name='GIT_PWD', default='empty') }}@github.com/foo/my-plugin.git"
```

Combined with `[tools]`:

```toml
[plugins]
vfox-npm = "https://github.com/jdx/vfox-npm"

[tools]
"vfox-npm:prettier" = "latest"
"vfox-npm:eslint" = "8.0.0"
```

([plugin-usage](https://mise.jdx.dev/plugin-usage.html#configuration))

#### 8.4.1 Shorthand registry and the default plugin backend

The registry maps short tool names to backends. `mise use postgres@15` is equivalent to `mise use asdf:mise-plugins/mise-postgres@15` ([asdf-legacy-plugins](https://mise.jdx.dev/asdf-legacy-plugins.html)).

| Setting | Type / Default | Meaning |
| --- | --- | --- |
| `disable_default_registry` (`MISE_DISABLE_DEFAULT_REGISTRY`) | boolean, `false` | Disable the default mapping of short tool names like `php` → `asdf:mise-plugins/asdf-php`. **Only** disables it for the `vfox` and `asdf` backends |
| `disable_backends` (`MISE_DISABLE_BACKENDS`, comma separated) | `string[]`, `[]` | Backends to disable **for new installs** — e.g. `asdf`, `pipx`, or *a vfox-backend plugin name*. Does not uninstall or disable already-installed tools |
| `plugin_autoupdate_last_check_duration` (`MISE_PLUGIN_AUTOUPDATE_LAST_CHECK_DURATION`) | string, `7d` | How long to wait before updating plugins automatically — **"note this isn't currently implemented"** |

([configuration/settings](https://mise.jdx.dev/configuration/settings.html))

On **Windows, mise uses vfox plugins by default**. To prefer vfox on Linux/macOS too:

```sh
mise settings add disable_backends asdf
```

Then registry shorthands resolve to vfox plugins and `mise use -g cmake` works without the `vfox:` prefix ([dev-tools/backends/vfox](https://mise.jdx.dev/dev-tools/backends/vfox.html#default-plugin-backend)):

```sh
$ mise registry | grep vfox:
clang                         vfox:mise-plugins/vfox-clang
cmake                         vfox:mise-plugins/vfox-cmake
crystal                       vfox:mise-plugins/vfox-crystal
dart                          vfox:mise-plugins/vfox-dart
dotnet                        vfox:mise-plugins/vfox-dotnet
etcd                          aqua:etcd-io/etcd vfox:mise-plugins/vfox-etcd
flutter                       vfox:mise-plugins/vfox-flutter
gradle                        aqua:gradle/gradle vfox:mise-plugins/vfox-gradle
groovy                        vfox:mise-plugins/vfox-groovy
kotlin                        vfox:mise-plugins/vfox-kotlin
maven                         aqua:apache/maven vfox:mise-plugins/vfox-maven
php                           vfox:mise-plugins/vfox-php
scala                         vfox:mise-plugins/vfox-scala
terraform                     aqua:hashicorp/terraform vfox:mise-plugins/vfox-terraform
vlang                         vfox:mise-plugins/vfox-vlang
```

The direct `vfox:` form works without a `[plugins]` entry:

```sh
$ mise use -g vfox:version-fox/vfox-cmake
$ cmake --version
cmake version 3.21.3
```

```toml
[tools]
"vfox:version-fox/vfox-cmake" = "latest"
```

#### 8.4.2 `[bootstrap.plugins]` — package plugin sources

Package plugins are declared alongside their packages ([bootstrap/packages/plugins](https://mise.jdx.dev/bootstrap/packages/plugins.html)):

```toml
[bootstrap.plugins]
vscode = "https://github.com/mise-plugins/mise-vscode-extensions"
krew = "https://github.com/mise-plugins/mise-krew"

[bootstrap.packages]
"vscode:ms-python.python" = "latest"
"krew:ctx" = "latest"
```

Ordering: "`mise bootstrap` installs declared package plugins first, applies built-in package managers, installs `[tools]`, then applies plugin managers." This lets a plugin declare a host command (`code`, `helm`, `kubectl`, `gh`) that is provided by the same config's global `[tools]` entries.

```sh
mise bootstrap plugins status
mise bootstrap plugins status --missing
mise bootstrap plugins apply
mise bootstrap packages status
mise bootstrap packages apply
```

Package plugins install into the host application's own state directory. They **do not** create mise installs or shims, **never elevate with `sudo`**, and are **not** affected by `system_packages.sudo`. The `system_packages.managers` setting is name-based and can include/exclude plugin managers just like built-ins. Package removal and pruning are **not supported in the first version of this API** — removing a config entry does not uninstall host-managed state ([bootstrap/packages/plugins](https://mise.jdx.dev/bootstrap/packages/plugins.html)). Unknown managers are ignored with a warning plus a package-plugin install hint ([bootstrap/packages](https://mise.jdx.dev/bootstrap/packages/)).

### 8.5 Tool options passed to plugins

"Tool options" are configuration specified in `mise.toml` that changes tool behavior:

```toml
[tools]
python = { version='3.11', virtualenv='.venv' }
```

Each option is passed to all plugin scripts as `MISE_TOOL_OPTS__<OPTION>`, e.g. `MISE_TOOL_OPTS__VIRTUALENV=.venv`. The user can specify any option and it is passed in that format. "Currently, this only supports simple strings, but we can make it compatible with more complex types (arrays, tables) fairly easily if there is a need for it." ([plugins](https://mise.jdx.dev/plugins.html#tool-options))

> **Warning (from the docs):** the python `virtualenv` tool option is deprecated and will be removed in a future release; use [`_.python.venv`](https://mise.jdx.dev/lang/python.html#automatic-virtualenv-activation) in `[env]` instead.

For Lua plugins, option values reach hooks via `ctx.options` and **preserve their TOML types as native Lua equivalents**: strings stay strings, arrays become Lua sequence tables, nested tables become Lua map tables. `channels = ["conda-forge", "robostack"]` becomes a table you iterate with `ipairs(ctx.options.channels)` ([backend-plugin-development](https://mise.jdx.dev/backend-plugin-development.html#context-variables)).

**`install_env`** is available on both plugin backends:

```toml
[tools]
# vfox: env for commands a plugin starts with cmd.exec during install hooks.
# vfox's built-in Lua HTTP, archive, and JSON helpers do NOT use these variables directly.
"vfox:version-fox/vfox-cmake" = { version = "latest", install_env = { HTTPS_PROXY = "http://proxy.example" } }

# asdf: env for plugin install scripts
"asdf:owner/plugin" = { version = "latest", install_env = { MAKEFLAGS = "-j8" } }
```

([dev-tools/backends/vfox](https://mise.jdx.dev/dev-tools/backends/vfox.html#install-env), [dev-tools/backends/asdf](https://mise.jdx.dev/dev-tools/backends/asdf.html#install-env))

`depends` in `[tools]` is **not** the same as `depends` in a plugin's `metadata.lua`: the former is install order relative to other tools in that config only; vfox plugin hook dependencies belong in `metadata.lua` ([configuration](https://mise.jdx.dev/configuration.html)).

### 8.6 Security implications and `paranoid`

> **DANGER (verbatim intent from the docs):** "Plugins execute arbitrary code during installation and use." Only install plugins from trusted sources; review plugin code before installation when possible; use version pinning to avoid unexpected updates, e.g. [mise.lock](https://mise.jdx.dev/dev-tools/mise-lock.html) ([plugin-usage](https://mise.jdx.dev/plugin-usage.html#security-considerations)).

asdf plugins execute arbitrary **shell scripts**, and are described as "less secure than sandboxed modern backends"; the guidance is to avoid plugins with complex installation scripts and to prefer modern backends ([asdf-legacy-plugins](https://mise.jdx.dev/asdf-legacy-plugins.html#security-considerations)). asdf plugins are also "typically written by a single developer unrelated to the tool vendor"; registry asdf plugins are all hosted in the mise-plugins org "to secure the supply chain so you do not need to rely on plugins maintained by anyone except me" ([dev-tools/backends/asdf](https://mise.jdx.dev/dev-tools/backends/asdf.html)).

<https://github.com/mise-plugins> is a GitHub organization for community-developed plugins; see [SECURITY.md](https://github.com/jdx/mise/blob/main/SECURITY.md) "for more details on how plugins here are treated differently" ([plugins](https://mise.jdx.dev/plugins.html#plugin-authors)).

#### 8.6.1 `paranoid`

`paranoid` (`MISE_PARANOID`, boolean, default `false`) "Enables extra-secure behavior" ([configuration/settings](https://mise.jdx.dev/configuration/settings.html#paranoid)). Enable with either:

```sh
mise settings paranoid=1
# or
MISE_PARANOID=1
```

| Area | Normal mode | Paranoid mode |
| --- | --- | --- |
| Config trust | Trust checked before parsing `mise.toml`; some formats don't require trust; in CI configs are assumed trusted | **All** config files must be trusted first, including formats that normally don't require trust; CI is **not** auto-trusted |
| Trust persistence | A config only needs to be trusted once | File contents are **hashed**; changing the file requires re-trusting |
| Global/system configs | Implicitly trusted | Still implicitly trusted and exempt — this lets paranoid be enabled globally without a trust prompt for that file |
| **Community plugins** | `mise plugin install shfmt` (short name) works | Community plugins **cannot be installed by short-name**. Only core, mise-team-maintained, or plugins mise has marked "first-party" (developed by the same team that builds the tool). Otherwise use the full git repo: `mise plugin install shfmt https://github.com/luizm/asdf-shfmt` |
| Transport | Some endpoints (latest-version checks, tool version lists) use HTTP, because loading the TLS module costs ~10ms | **All** endpoints fetched over HTTPS |
| Provenance | With a checksum + provenance entry in the lockfile, `mise install` trusts the lockfile and skips re-verification | `mise install` **always re-verifies** provenance (SLSA, cosign, minisign, GitHub artifact attestations) at install time. Also available independently via [`locked_verify_provenance`](https://mise.jdx.dev/configuration/settings.html#locked%5Fverify%5Fprovenance) |

([paranoid](https://mise.jdx.dev/paranoid.html))

Related but distinct: [Safe mode](https://mise.jdx.dev/security.html#safe-mode) (`MISE_SAFE=1`) — "where paranoid tightens *trust* (which configs are loaded and re-verified), safe mode is a hard boundary on *code execution* for running mise against configuration you do not control" ([paranoid](https://mise.jdx.dev/paranoid.html#see-also)).

#### 8.6.2 Attestation (tool plugins only)

Tool plugins support attestation verification — GitHub artifact attestations, cosign signatures, SLSA provenance — for downloaded artifacts. "When a tool plugin's `PreInstall` hook returns an `attestation` table, mise verifies it during install and records the result in `mise.lock`, protecting against downgrade attacks on subsequent installs. **Backend plugins do not currently support attestation**" ([dev-tools/backends/vfox](https://mise.jdx.dev/dev-tools/backends/vfox.html#why-vfox)).

#### 8.6.3 Other security-relevant settings

| Setting | Type / Default | Relevance to plugins |
| --- | --- | --- |
| `system_deps` (`MISE_SYSTEM_DEPS`) | string, `prompt`; choices `prompt`\|`auto`\|`warn`\|`ignore` | What mise does when `PLUGIN.systemDependencies` declares prerequisites that are missing (see §8.7.3) |
| `env_cache` (`MISE_ENV_CACHE`) | boolean, `false` | Required for env-plugin `cacheable = true` output to be cached. Cache is encrypted with a session-scoped key `__MISE_ENV_CACHE_KEY` |
| `env_cache_ttl` (`MISE_ENV_CACHE_TTL`) | string, `1h` | How long cached environments remain valid |
| `always_keep_download` (`MISE_ALWAYS_KEEP_DOWNLOAD`) | boolean, `false` | Keeps downloaded archive/source files under `~/.local/share/mise/downloads` "so you can inspect them while debugging backend/plugin install behavior". Not a supported download cache |
| `MISE_RAW` / `raw` | boolean | "Set to '1' to directly pipe plugin scripts to stdin/stdout/stderr. By default stdin is disabled because when installing a bunch of plugins in parallel you won't see the prompt." Sets `MISE_JOBS=1` because only 1 plugin script can be executed at a time |
| `MISE_DATA_DIR` | path | "This is the directory where mise stores plugins and tool installs." |

([configuration/settings](https://mise.jdx.dev/configuration/settings.html), [configuration](https://mise.jdx.dev/configuration.html))

### 8.7 Tool Plugin Development

Tool plugins use a hook-based architecture to manage an individual tool, are compatible with the standard vfox ecosystem, and work on Windows/macOS/Linux ([tool-plugin-development](https://mise.jdx.dev/tool-plugin-development.html)). Start from [mise-tool-plugin-template](https://github.com/jdx/mise-tool-plugin-template), which ships LuaCATS type definitions, stylua formatting, and hk linting pre-configured.

#### 8.7.1 File layout

```
my-tool-plugin/
├── metadata.lua          # Plugin metadata and configuration
├── hooks/               # Hook functions directory
│   ├── available.lua    # List available versions [required]
│   ├── pre_install.lua  # Pre-installation hook [required]
│   ├── env_keys.lua     # Environment configuration [required]
│   ├── post_install.lua # Post-installation hook [optional]
│   ├── pre_use.lua      # Pre-use hook [optional]
│   └── parse_legacy_file.lua # Legacy file parser [optional]
├── lib/                 # Shared library code [optional]
│   └── helper.lua       # Helper functions
└── test/               # Test scripts [optional]
    └── test.sh
```

#### 8.7.2 Hook reference

| Hook | Signature | Required | Purpose | `ctx` fields | Returns |
| --- | --- | --- | --- | --- | --- |
| `Available` | `function PLUGIN:Available(ctx)` | ✅ | Lists all available versions of the tool | `ctx.args` (user arguments) | Array of `{version, note?, rolling?, checksum?, addition?}` |
| `PreInstall` | `function PLUGIN:PreInstall(ctx)` | ✅ | Pre-installation logic; returns download information | `ctx.version`, `ctx.runtimeVersion` | `{version, url, sha256?, note?, attestation?, addition?}` |
| `EnvKeys` | `function PLUGIN:EnvKeys(ctx)` | ✅ | Configures environment variables for the installed tool | `ctx.path` (main path), `ctx.runtimeVersion`, `ctx.sdkInfo['<name>']` → `{path, version, name}` | Array of `{key, value}`; multiple `PATH` entries are automatically merged |
| `PostInstall` | `function PLUGIN:PostInstall(ctx)` | optional | Additional setup after installation (compile native modules, set permissions, …) | `ctx.rootPath`, `ctx.runtimeVersion`, `ctx.sdkInfo['<name>']` → `{path, version}` | No return value needed |
| `PreUse` | `function PLUGIN:PreUse(ctx)` | optional | Modifies the version before use (e.g. resolve `latest`) | `ctx.version`, `ctx.previousVersion`, `ctx.installedSdks`, `ctx.cwd`, `ctx.scope` (`global`/`project`/`session`) | `{version = <string>}` |
| `ParseLegacyFile` | `function PLUGIN:ParseLegacyFile(ctx)` | optional | Parses version files from other tools (`.nvmrc`, `.node-version`, …) | `ctx.filename`, `ctx.filepath`, `ctx:getInstalledVersions()` | `{version = <string>}` |

([tool-plugin-development](https://mise.jdx.dev/tool-plugin-development.html#hook-functions))

**`Available`**

```lua
-- hooks/available.lua
function PLUGIN:Available(ctx)
    local args = ctx.args  -- User arguments

    -- Return array of available versions
    return {
        {
            version = "20.0.0",
            note = "Latest"
        },
        {
            version = "18.18.0",
            note = "LTS",
            addition = {
                {
                    name = "npm",
                    version = "9.8.1"
                }
            }
        }
    }
end
```

*Rolling releases* — for tools with rolling releases like "nightly"/"stable" where the version string stays the same but content changes:

```lua
function PLUGIN:Available(ctx)
    return {
        {
            version = "nightly",
            note = "Latest development build",
            rolling = true,  -- Mark as rolling release
            checksum = "abc123..."  -- SHA256 of the release asset
        },
        {
            version = "stable",
            note = "Latest stable release",
            rolling = true,
            checksum = "def456..."
        },
        {
            version = "1.0.0",
            note = "Fixed release"
            -- No rolling or checksum needed for fixed versions
        }
    }
end
```

When `rolling = true`: `mise upgrade` checks whether the checksum changed to detect updates, and `mise upgrade --bump` preserves the version name (e.g. "nightly") instead of converting it to a semver. The checksum should be the SHA256 of the release asset for the user's platform; see the [vfox-neovim plugin](https://github.com/mise-plugins/vfox-neovim) for a complete example.

> **Sorting gotcha:** the analogous warning is documented explicitly for `BackendListVersions` (§8.8). For `Available`, the docs' recommended practice is `semver.sort_by(result, "version")` (ascending, oldest first) — see [plugin-lua-modules](https://mise.jdx.dev/plugin-lua-modules.html#real-world-example-available-hook).

**`PreInstall`**

```lua
-- hooks/pre_install.lua
function PLUGIN:PreInstall(ctx)
    local version = ctx.version
    local runtimeVersion = ctx.runtimeVersion

    -- Determine download URL and checksums
    local url = "https://nodejs.org/dist/v" .. version .. "/node-v" .. version .. "-linux-x64.tar.gz"

    return {
        version = version,
        url = url,
        sha256 = "abc123...",  -- Optional checksum
        note = "Installing Node.js " .. version,
        -- Optional attestation metadata, choose a verification type
        attestation = {
            -- GitHub
            github_owner = "ownername"
            github_repo = "reponame"
            -- Cosign
            cosign_sig_or_bundle_path = "/path/to/sig/or/bundle/file"
            -- SLSA
            slsa_provenance_path = "/path/to/provenance/file"
        },
        -- Additional files can be specified
        addition = {
            {
                name = "npm",
                url = "https://registry.npmjs.org/npm/-/npm-" .. npm_version .. ".tgz"
            }
        }
    }
end
```

> **Uncertainty:** the `attestation` snippet above is copied verbatim from [tool-plugin-development](https://mise.jdx.dev/tool-plugin-development.html#preinstall-hook), but as published it omits the commas/semicolons that Lua table constructors require between fields, and it lists all three verification types at once while the comment says "choose a verification type". Treat the field *names* (`github_owner`, `github_repo`, `cosign_sig_or_bundle_path`, `slsa_provenance_path`) as authoritative and the literal syntax as illustrative.

**`EnvKeys`**

```lua
-- hooks/env_keys.lua
function PLUGIN:EnvKeys(ctx)
    local mainPath = ctx.path
    local runtimeVersion = ctx.runtimeVersion
    local sdkInfo = ctx.sdkInfo['nodejs']
    local path = sdkInfo.path
    local version = sdkInfo.version
    local name = sdkInfo.name

    return {
        {
            key = "NODE_HOME",
            value = mainPath
        },
        {
            key = "PATH",
            value = mainPath .. "/bin"
        },
        -- Multiple PATH entries are automatically merged
        {
            key = "PATH",
            value = mainPath .. "/lib/node_modules/.bin"
        }
    }
end
```

**`PostInstall`**

```lua
-- hooks/post_install.lua
function PLUGIN:PostInstall(ctx)
    local rootPath = ctx.rootPath
    local runtimeVersion = ctx.runtimeVersion
    local sdkInfo = ctx.sdkInfo['nodejs']
    local path = sdkInfo.path
    local version = sdkInfo.version

    -- Compile native modules, set permissions, etc.
    local result = os.execute("chmod +x " .. path .. "/bin/*")
    if result ~= 0 then
        error("Failed to set permissions")
    end

    -- No return value needed
end
```

**`PreUse`**

```lua
-- hooks/pre_use.lua
function PLUGIN:PreUse(ctx)
    local version = ctx.version
    local previousVersion = ctx.previousVersion
    local installedSdks = ctx.installedSdks
    local cwd = ctx.cwd
    local scope = ctx.scope  -- global/project/session

    -- Optionally modify the version
    if version == "latest" then
        version = "20.0.0"  -- Resolve to specific version
    end

    return {
        version = version
    }
end
```

**`ParseLegacyFile`**

```lua
-- hooks/parse_legacy_file.lua
function PLUGIN:ParseLegacyFile(ctx)
    local filename = ctx.filename
    local filepath = ctx.filepath
    local versions = ctx:getInstalledVersions()

    -- Read and parse the file
    local file = require("file")
    local content = file.read(filepath)
    local version = content:match("v?([%d%.]+)")

    return {
        version = version
    }
end
```

A fuller real-world variant branching on filename:

```lua
-- hooks/parse_legacy_file.lua
function PLUGIN:ParseLegacyFile(ctx)
    local filename = ctx.filename
    local filepath = ctx.filepath
    local file = require("file")

    -- Read file content
    local content = file.read(filepath)
    if not content then
        error("Failed to read " .. filepath)
    end

    -- Parse version from different file formats
    local version = nil

    if filename == ".nvmrc" then
        -- .nvmrc can contain version with or without 'v' prefix
        version = content:match("v?([%d%.]+)")
    elseif filename == ".node-version" then
        -- .node-version typically contains just the version number
        version = content:match("([%d%.]+)")
    end

    -- Remove any whitespace
    if version then
        version = version:gsub("%s+", "")
    end

    return {
        version = version
    }
end
```

#### 8.7.3 `metadata.lua`

```lua
-- metadata.lua
PLUGIN = {
    name = "nodejs",
    version = "1.0.0",
    description = "Node.js runtime environment",
    author = "Plugin Author",

    -- Legacy version files this plugin can parse
    legacyFilenames = {
        '.nvmrc',
        '.node-version'
    },

    -- Tools whose bin paths should be available during install hooks
    depends = { "node" },
}
```

| Field | Type | Meaning |
| --- | --- | --- |
| `name` | string | Plugin name |
| `version` | string | Plugin version (SemVer; update for each release) |
| `description` | string | Human description |
| `author` | string | Author |
| `homepage` | string (optional) | Plugin homepage (documented on the env-plugin page) |
| `license` | string (optional) | License (documented on the env-plugin page) |
| `minRuntimeVersion` | string (optional) | Minimum mise/vfox version required, e.g. `"0.3.0"` |
| `legacyFilenames` | string[] | Legacy version files this plugin can parse (replaces asdf's `bin/list-legacy-filenames`) |
| `depends` | string[] | Tools whose bin paths should be available during install hooks. Use tool names as they'd appear in `mise.toml`, e.g. `depends = { "go", "make" }`. Omit if hooks don't shell out |
| `systemDependencies` | table[] | System prerequisites checked before install (see below) |

([tool-plugin-development](https://mise.jdx.dev/tool-plugin-development.html#%5F2-metadata-lua), [env-plugin-development](https://mise.jdx.dev/env-plugin-development.html#metadata-lua))

> `depends` in `metadata.lua` is *plugin metadata*, distinct from `depends` in `[tools]` (which only makes one configured tool wait for another in the install graph). "when matching tools are configured, mise uses it to order current install jobs and to build the hook environment" ([tool-plugin-development](https://mise.jdx.dev/tool-plugin-development.html#%5F2-metadata-lua)).

**System dependencies** — plugins that compile from source can declare prerequisites; mise checks each before install and, per the [`system_deps`](https://mise.jdx.dev/configuration/settings.html#system%5Fdeps) setting, reports / offers to install / auto-installs anything missing:

```lua
PLUGIN = {
    name = "php",
    version = "1.0.0",

    systemDependencies = {
        -- an executable on PATH, with an optional version constraint
        { bin = "bison", version = ">=3.0",
          packages = { brew = "bison", apt = "bison", dnf = "bison" } },
        { bin = "re2c",
          packages = { brew = "re2c", apt = "re2c", dnf = "re2c" } },

        -- a library discoverable via pkg-config
        { pkgconfig = "libxml-2.0",
          packages = { brew = "libxml2", apt = "libxml2-dev", dnf = "libxml2-devel" } },
        { pkgconfig = "openssl",
          packages = { brew = "openssl@3", apt = "libssl-dev", dnf = "openssl-devel" } },

        -- a runtime shared library, by soname (Linux)
        { sharedlib = "libaio.so.1",
          packages = { apt = "libaio1", dnf = "libaio" } },

        -- an escape hatch: any shell command whose exit status 0 means "satisfied"
        { command = "xcode-select -p", optional = "macOS command line tools" },
    },
}
```

Each entry must set **exactly one** check:

| Check | Detection | Use for |
| --- | --- | --- |
| `bin` | executable resolvable on PATH | compilers, build tools, `*-config` scripts |
| `pkgconfig` | `pkg-config --exists <name>` | C libraries that ship a `.pc` file |
| `sharedlib` | dynamic linker can resolve the soname (Linux only) | runtime libraries for prebuilt binaries |
| `command` | the shell command exits 0 | anything the above can't express |

Optional fields:

| Field | Meaning |
| --- | --- |
| `version` | Constraint (`>=3.0`, `>3`, `<=1.2`, `=3.0`, or bare `3.0` meaning `>=3.0`) for `bin` and `pkgconfig`. mise runs `<bin> --version` / `pkg-config --modversion` and compares. **If a version can't be extracted, the dependency is treated as satisfied** (presence is enough) rather than blocking the install |
| `optional` | A short reason string. Missing optional dependencies never prompt or fail; they surface as a single informational line (e.g. Erlang's `wxWidgets` GUI) |
| `packages` | Map of package-manager name (`brew`, `brew-cask`, `apt`, `dnf`, `pacman`, `apk`, `flatpak`, `mas`) → package providing the capability |

"**Detection is the source of truth.** A check that passes is satisfied no matter how the capability was installed — Homebrew, apt, nix, MacPorts, or from source all pass without ceremony… The `packages` map is only consulted to *offer* installing the missing subset; it is a remediation hint." These declarations "are inert on older mise versions and on upstream vfox (both ignore unknown `PLUGIN` fields), so adding them is backward-compatible" ([tool-plugin-development](https://mise.jdx.dev/tool-plugin-development.html#system-dependencies)).

#### 8.7.4 The `RUNTIME` object

Automatically available in all plugin hooks ([tool-plugin-development](https://mise.jdx.dev/tool-plugin-development.html#platform-detection), [backend-plugin-development](https://mise.jdx.dev/backend-plugin-development.html#environment-detection)):

| Field | Values |
| --- | --- |
| `RUNTIME.osType` | `"windows"`, `"linux"`, `"darwin"` |
| `RUNTIME.archType` | `"amd64"`, `"arm64"`, `"x86"`, etc. |
| `RUNTIME.envType` | libc environment type: `"gnu"` on glibc Linux, `"musl"` on musl Linux, `nil` on Windows/macOS and undetected systems |
| `RUNTIME.version` | vfox runtime version |
| `RUNTIME.pluginDirPath` | Plugin directory path |

```lua
-- lib/helper.lua
local M = {}

function M.get_arch()
    -- Use the RUNTIME object provided by vfox/mise
    return (RUNTIME.archType == "amd64") and "x64" or RUNTIME.archType  -- return as-is for other architectures
end

function M.get_os()
    -- Use the RUNTIME object provided by vfox/mise
    return (RUNTIME.osType == "windows") and "win" or RUNTIME.osType
end

function M.get_platform()
    return M.get_os() .. "-" .. M.get_arch()
end

return M
```

#### 8.7.5 Real-world example: vfox-nodejs

```lua
-- hooks/available.lua
function PLUGIN:Available(ctx)
    local http = require("http")
    local json = require("json")

    -- Fetch versions from Node.js API
    local resp, err = http.get({
        url = "https://nodejs.org/dist/index.json"
    })

    if err ~= nil then
        error("Failed to fetch versions: " .. err)
    end

    local versions = json.decode(resp.body)
    local result = {}

    for i, v in ipairs(versions) do
        local version = v.version:gsub("^v", "")  -- Remove 'v' prefix
        local note = nil

        if v.lts then
            note = "LTS"
        end

        table.insert(result, {
            version = version,
            note = note,
            addition = {
                {
                    name = "npm",
                    version = v.npm
                }
            }
        })
    end

    return result
end
```

```lua
-- hooks/pre_install.lua
function PLUGIN:PreInstall(ctx)
    local version = ctx.version

    -- Determine platform using RUNTIME object
    local arch_token = (RUNTIME.archType == "amd64") and "x64" or RUNTIME.archType
    local os_token = (RUNTIME.osType == "windows") and "win" or RUNTIME.osType
    local platform = os_token .. "-" .. arch_token
    local extension = (RUNTIME.osType == "windows") and "zip" or "tar.gz"

    -- Build download URL
    local filename = "node-v" .. version .. "-" .. platform .. "." .. extension
    local url = "https://nodejs.org/dist/v" .. version .. "/" .. filename

    -- Fetch checksum
    local http = require("http")
    local shasums_url = "https://nodejs.org/dist/v" .. version .. "/SHASUMS256.txt"
    local resp, err = http.get({ url = shasums_url })

    local sha256 = nil
    if err == nil then
        -- Extract SHA256 for our file
        for line in resp.body:gmatch("[^\n]+") do
            if line:match(filename) then
                sha256 = line:match("^(%w+)")
                break
            end
        end
    end

    return {
        version = version,
        url = url,
        sha256 = sha256,
        note = "Installing Node.js " .. version .. " (" .. platform .. ")"
    }
end
```

Complex `EnvKeys` (library paths, platform-specific additions):

```lua
function PLUGIN:EnvKeys(ctx)
    local mainPath = ctx.path
    local version = ctx.sdkInfo['tool-name'].version

    local env_vars = {
        -- Standard environment variables
        { key = "TOOL_HOME",    value = mainPath },
        { key = "TOOL_VERSION", value = version },

        -- PATH entries
        { key = "PATH", value = mainPath .. "/bin" },
        { key = "PATH", value = mainPath .. "/scripts" },

        -- Library paths
        { key = "LD_LIBRARY_PATH", value = mainPath .. "/lib" },
        { key = "PKG_CONFIG_PATH", value = mainPath .. "/lib/pkgconfig" }
    }

    -- Platform-specific additions
    if RUNTIME.osType == "darwin" then
        table.insert(env_vars, {
            key = "DYLD_LIBRARY_PATH",
            value = mainPath .. "/lib"
        })
    end

    return env_vars
end
```

Source compilation in `PostInstall`:

```lua
-- hooks/post_install.lua
function PLUGIN:PostInstall(ctx)
    local sdkInfo = ctx.sdkInfo['tool-name']
    local path = sdkInfo.path
    local version = sdkInfo.version

    -- Change to source directory
    local build_dir = path .. "/src"

    -- Configure build
    local configure_result = os.execute("cd " .. build_dir .. " && ./configure --prefix=" .. path)
    if configure_result ~= 0 then
        error("Configure failed")
    end

    -- Compile
    local make_result = os.execute("cd " .. build_dir .. " && make -j$(nproc)")
    if make_result ~= 0 then
        error("Compilation failed")
    end

    -- Install
    local install_result = os.execute("cd " .. build_dir .. " && make install")
    if install_result ~= 0 then
        error("Installation failed")
    end
end
```

Caching an expensive `Available`:

```lua
-- Cache versions for 12 hours
local cache = {}
local cache_ttl = 12 * 60 * 60  -- 12 hours in seconds

function PLUGIN:Available(ctx)
    local now = os.time()

    -- Check cache first
    if cache.versions and cache.timestamp and (now - cache.timestamp) < cache_ttl then
        return cache.versions
    end

    -- Fetch fresh data
    local versions = fetch_versions_from_api()

    -- Update cache
    cache.versions = versions
    cache.timestamp = now

    return versions
end
```

### 8.8 Backend Plugin Development

Backend plugins extend the standard vfox plugin system with enhanced backend methods, managing **multiple** tools via `plugin:tool`. They are "generally a git repository but can also be a directory (via `mise link`)" ([backend-plugin-development](https://mise.jdx.dev/backend-plugin-development.html)). Template: [mise-backend-plugin-template](https://github.com/jdx/mise-backend-plugin-template).

#### 8.8.1 File layout

```
my-backend-plugin/
├── metadata.lua                    # Plugin metadata
├── hooks/
│   ├── backend_list_versions.lua   # BackendListVersions hook
│   ├── backend_install.lua         # BackendInstall hook
│   └── backend_exec_env.lua        # BackendExecEnv hook
└── Injection.lua                   # Runtime injection (auto-generated)
```

```lua
PLUGIN = {
    name = "vfox-npm",
    version = "1.0.0",
    description = "Backend plugin for npm packages",
    author = "Your Name"
}
```

#### 8.8.2 Backend methods

| Method | Signature | Purpose | Returns |
| --- | --- | --- | --- |
| `BackendListVersions` | `function PLUGIN:BackendListVersions(ctx)` | Lists available versions for a tool | `{versions = <array of strings>}` |
| `BackendInstall` | `function PLUGIN:BackendInstall(ctx)` | Installs a specific version of a tool | `{}` |
| `BackendExecEnv` | `function PLUGIN:BackendExecEnv(ctx)` | Sets up environment variables for a tool | `{env_vars = {{key=…, value=…}, …}}` |

**Context variables** ([backend-plugin-development](https://mise.jdx.dev/backend-plugin-development.html#context-variables)):

*`BackendListVersions`*

| Variable | Description | Example |
| --- | --- | --- |
| `ctx.tool` | The tool name | `"prettier"` |
| `ctx.options` | Tool options from mise.toml | `{channels = {"a", "b"}}` |

*`BackendInstall`*

| Variable | Description | Example |
| --- | --- | --- |
| `ctx.tool` | The tool name | `"prettier"` |
| `ctx.version` | The requested version | `"3.0.0"` |
| `ctx.install_path` | Installation directory | `"/home/user/.local/share/mise/installs/vfox-npm-prettier/3.0.0"` |
| `ctx.download_path` | Download directory | `"/home/user/.local/share/mise/downloads/vfox-npm-prettier/3.0.0"` |
| `ctx.options` | Tool options from mise.toml | `{exe = "rg"}` |

*`BackendExecEnv`*

| Variable | Description | Example |
| --- | --- | --- |
| `ctx.tool` | The tool name | `"prettier"` |
| `ctx.version` | The requested version | `"3.0.0"` |
| `ctx.install_path` | Installation directory | `"/home/user/.local/share/mise/installs/vfox-npm-prettier/3.0.0"` |
| `ctx.options` | Tool options from mise.toml | `{exe = "rg"}` |

```lua
function PLUGIN:BackendListVersions(ctx)
    local tool = ctx.tool
    local options = ctx.options
    local versions = {}

    -- Your logic to fetch versions for the tool
    -- Example: query an API, parse a registry, etc.
    -- Access custom options via options["key"] or options.key

    return {versions = versions}
end
```

> **WARNING — Version sorting:** "The versions returned by `BackendListVersions` should be in ascending order (oldest to newest), sorted semantically (version `3.10.0` should not come before `3.2.0`). **Mise does not apply any additional sorting** to the versions returned by this method." ([backend-plugin-development](https://mise.jdx.dev/backend-plugin-development.html#backendlistversions))

```lua
function PLUGIN:BackendInstall(ctx)
    local tool = ctx.tool
    local version = ctx.version
    local install_path = ctx.install_path
    local download_path = ctx.download_path
    local options = ctx.options

    -- Your logic to install the tool
    -- Example: download files, extract archives, etc.
    -- Access custom options via options["key"] or options.key

    return {}
end
```

```lua
function PLUGIN:BackendExecEnv(ctx)
    local install_path = ctx.install_path
    local options = ctx.options

    -- Your logic to set up environment variables
    -- Example: add bin directories to PATH

    return {
        env_vars = {
            {key = "PATH", value = install_path .. "/bin"}
        }
    }
end
```

#### 8.8.3 Complete example: vfox-npm

```lua
-- metadata.lua
PLUGIN = {
    name = "vfox-npm",
    version = "1.0.0",
    description = "Backend plugin for npm packages",
    author = "jdx"
}
```

```lua
-- hooks/backend_list_versions.lua
function PLUGIN:BackendListVersions(ctx)
    local cmd = require("cmd")
    local json = require("json")

    local result = cmd.exec("npm view " .. ctx.tool .. " versions --json")
    local versions = json.decode(result)

    return {versions = versions}
end
```

```lua
-- hooks/backend_install.lua
function PLUGIN:BackendInstall(ctx)
    local tool = ctx.tool
    local version = ctx.version
    local install_path = ctx.install_path

    -- Install the package directly using npm install
    local cmd = require("cmd")
    local npm_cmd = "npm install " .. tool .. "@" .. version .. " --no-package-lock --no-save --silent"
    local result = cmd.exec(npm_cmd, {cwd = install_path})

    -- If we get here, the command succeeded
    return {}
end
```

```lua
-- hooks/backend_exec_env.lua
function PLUGIN:BackendExecEnv(ctx)
    local file = require("file")
    return {
        env_vars = {
            {key = "PATH", value = file.join_path(ctx.install_path, "node_modules", ".bin")}
        }
    }
end
```

```bash
mise plugin install vfox-npm https://github.com/jdx/vfox-npm
mise ls-remote vfox-npm:prettier
mise install vfox-npm:prettier@3.0.0
mise use vfox-npm:prettier@latest
mise exec -- prettier --help
```

> **INFO from the docs:** vfox-npm "is just an example plugin for testing. mise already has built-in npm support that you should use instead: `mise install npm:prettier@latest`" ([plugin-usage](https://mise.jdx.dev/plugin-usage.html#vfox-npm-example-plugin)).

Multiple env vars derived from context:

```lua
function PLUGIN:BackendExecEnv(ctx)
    -- Add node_modules/.bin to PATH for npm-installed binaries
    local bin_path = ctx.install_path .. "/node_modules/.bin"
    return {
        env_vars = {
            {key = "PATH", value = bin_path},
            {key = ctx.tool:upper() .. "_HOME", value = ctx.install_path},
            {key = ctx.tool:upper() .. "_VERSION", value = ctx.version}
        }
    }
end
```

> **Uncertainty:** the docs' "Performance Optimization → Caching" section for backend plugins is a literal `TODO: We need caching support for [Shared Lua modules]` — there is no documented cross-invocation caching mechanism for backend plugins ([backend-plugin-development](https://mise.jdx.dev/backend-plugin-development.html#performance-optimization)).

### 8.9 Environment Plugin Development

Environment plugins provide environment variables and PATH modifications **without** managing tool versions. Unlike tool/backend plugins they ([env-plugin-development](https://mise.jdx.dev/env-plugin-development.html)):

* Don't implement version management (`Available`, `PreInstall`, `PostInstall` hooks)
* Only implement environment hooks (`MiseEnv`, `MisePath`)
* Are configured via `env._.<plugin-name>` syntax
* Can accept configuration options as TOML values
* **Execute on every environment activation**

Template: [mise-env-plugin-template](https://github.com/jdx/mise-env-plugin-template).

#### 8.9.1 File layout

```
my-env-plugin/
├── metadata.lua           # Plugin metadata
└── hooks/
    ├── mise_env.lua      # Returns environment variables (required)
    └── mise_path.lua     # Returns PATH entries (optional)
```

```lua
PLUGIN = {}

--- Plugin name (required)
PLUGIN.name = "my-env-plugin"

--- Plugin version (required)
PLUGIN.version = "1.0.0"

--- Plugin description (required)
PLUGIN.description = "Provides environment variables for my service"

--- Plugin homepage (optional)
PLUGIN.homepage = "https://github.com/username/my-env-plugin"

--- Plugin license (optional)
PLUGIN.license = "MIT"

--- Minimum mise/vfox version required (optional)
PLUGIN.minRuntimeVersion = "0.3.0"
```

#### 8.9.2 Hooks

| Hook | Signature | Required | Purpose | Returns |
| --- | --- | --- | --- | --- |
| `MiseEnv` | `function PLUGIN:MiseEnv(ctx)` | ✅ | Returns environment variables to set | Simple: array of `{key, value}`. Extended: `{env = […], cacheable = <bool>, watch_files = {…}}` |
| `MisePath` | `function PLUGIN:MisePath(ctx)` | optional | Returns directories to **prepend** to PATH | Array of strings (directory paths) |

Both hooks receive `ctx` with a single documented field: **`ctx.options`** — the TOML table of user configuration from `mise.toml`. "For environment plugins, `ctx.options` is the primary way to accept user configuration."

```lua
function PLUGIN:MiseEnv(ctx)
    -- Access configuration from mise.toml via ctx.options
    local api_url = ctx.options.api_url or "https://api.example.com"
    local debug = ctx.options.debug or false

    -- Return array of environment variables
    return {
        {
            key = "API_URL",
            value = api_url
        },
        {
            key = "DEBUG",
            value = tostring(debug)
        },
        {
            key = "SERVICE_TOKEN",
            value = get_token_from_somewhere()  -- Your custom logic
        }
    }
end
```

```lua
function PLUGIN:MisePath(ctx)
    -- Return array of paths to prepend to PATH
    local paths = {
        "/opt/my-service/bin"
    }

    -- Optionally add user-configured path
    if ctx.options.custom_bin_path then
        table.insert(paths, ctx.options.custom_bin_path)
    end

    return paths
end
```

#### 8.9.3 `MiseEnv` return formats

| Field | Type / Default | Meaning |
| --- | --- | --- |
| `key` | string, required | Environment variable name (simple format) |
| `value` | string, required | Environment variable value (simple format) |
| `env` | array, required (extended) | Array of `{key, value}` tables, same as simple format |
| `cacheable` | boolean, optional, default `false` | If `true`, mise can cache this plugin's output |
| `watch_files` | string[], optional | File paths to watch; if any file's mtime changes, the cache is invalidated |

```lua
function PLUGIN:MiseEnv(ctx)
    local config_path = ctx.options.config_file or "config.json"
    local config = load_config(config_path)

    return {
        cacheable = true,
        watch_files = {config_path},
        env = {
            {key = "API_URL", value = config.api_url},
            {key = "API_KEY", value = config.api_key}
        }
    }
end
```

With `cacheable = true`, mise caches the env vars and only re-executes the plugin when: any file in `watch_files` changes; the mise configuration changes; or the cache TTL expires (`env_cache_ttl`). **Users must enable `env_cache`:**

```toml
# ~/.config/mise/config.toml
[settings]
env_cache = true
```

Why prefer the built-in mechanism over manual Lua caching: mise handles cache invalidation automatically, the cache is encrypted with session-scoped keys, it integrates with `mise cache clear` / `mise cache prune`, and it respects `env_cache_ttl` ([env-plugin-development](https://mise.jdx.dev/env-plugin-development.html#%5F4-use-built-in-caching-for-expensive-operations)). Modules that don't declare cacheability "are treated as dynamic and will be re-executed on each cache hit" ([configuration/settings](https://mise.jdx.dev/configuration/settings.html#env%5Fcache)).

#### 8.9.4 Activation in `mise.toml`

```toml
[env]
_.my-env-plugin = {}
```

```toml
[env]
_.my-env-plugin = {
  api_url = "https://prod.api.example.com",
  debug = false,
  custom_bin_path = "/custom/path/bin",
}
```

How it works ([environments](https://mise.jdx.dev/environments/#plugin-provided-env-directives)): when you use `env._.<plugin-name>`, mise (1) loads the plugin from your installed plugins, (2) calls `MiseEnv` to get environment variables, (3) calls `MisePath` to get PATH entries if defined, (4) applies these when running `mise env` or using shell integration. The TOML table after `=` is passed to the hooks via `ctx.options`, so plugins can be configured per-project or per-environment.

**Gotcha** — the value must be a TOML **table**, not a string:

```toml
[env]
# Correct: TOML table
_.my-plugin = { key = "value" }

# Wrong: String value
_.my-plugin = "value"  # This won't work
```

**`tools = true`** — when `cmd.exec()` is called from `MiseEnv`/`MisePath`, it inherits the mise-constructed environment, including `_.path` entries and env vars from preceding directives. With `tools = true`, tool installation bin paths are also included so mise-managed tools are directly callable:

```toml
[env]
_.my-plugin = { tools = true }
```

```lua
function PLUGIN:MiseEnv(ctx)
    -- With tools=true, mise-managed tools are on PATH
    local version = cmd.exec("node --version")
    return {
        {key = "NODE_VERSION", value = version:gsub("%s+", "")}
    }
end
```

Without `tools = true`, only `_.path` directive entries and the original system PATH are available to `cmd.exec()` ([plugin-lua-modules](https://mise.jdx.dev/plugin-lua-modules.html#environment-inheritance-in-env-module-hooks)).

Note: "The `value` and `values` keys in built-in `file`, `path`, and `source` directive objects under `env._` or `vars._` are deprecated… This does **not** affect `value` in ordinary environment variable objects or **options for plugin-provided directives**" ([environments](https://mise.jdx.dev/environments/)).

#### 8.9.5 Complete example: Vault secrets plugin

```lua
-- metadata.lua
PLUGIN = {}
PLUGIN.name = "vault-secrets"
PLUGIN.version = "1.0.0"
PLUGIN.description = "Fetch secrets from HashiCorp Vault"
PLUGIN.minRuntimeVersion = "0.3.0"
```

```lua
-- hooks/mise_env.lua
local http = require("http")
local json = require("json")

function PLUGIN:MiseEnv(ctx)
    local vault_url = ctx.options.vault_url or error("vault_url required")
    local secrets_path = ctx.options.secrets_path or error("secrets_path required")
    local vault_token = os.getenv("VAULT_TOKEN") or error("VAULT_TOKEN not set")

    -- Fetch secrets from Vault
    local url = vault_url .. "/v1/" .. secrets_path
    local response = http.get({
        url = url,
        headers = {
            ["X-Vault-Token"] = vault_token
        }
    })

    if response.status_code ~= 200 then
        error("Failed to fetch secrets: " .. response.status_code)
    end

    local data = json.decode(response.body)
    local env_vars = {}

    -- Convert Vault secrets to environment variables
    for key, value in pairs(data.data.data) do
        table.insert(env_vars, {
            key = key,
            value = value
        })
    end

    return env_vars
end
```

```toml
[env]
_.vault-secrets = {
  vault_url = "https://vault.example.com",
  secrets_path = "secret/data/myapp/production",
}
```

Environment plugins have access to `http`, `json`, `file`, `cmd`, `strings`, and `env` modules ([env-plugin-development](https://mise.jdx.dev/env-plugin-development.html#available-lua-modules)).

#### 8.9.6 Migrating a tool plugin to an env plugin

If an existing tool plugin only sets environment variables, simplify it:

```
# Before (tool plugin with unused hooks)
my-plugin/
├── metadata.lua
└── hooks/
    ├── available.lua        # Returns empty list
    ├── pre_install.lua      # Not used
    ├── post_install.lua     # Not used
    └── env_keys.lua         # Actually sets env vars

# After (environment plugin)
my-plugin/
├── metadata.lua
└── hooks/
    └── mise_env.lua         # Clean and focused
```

### 8.10 Package Plugin Development

"A package plugin is a Lua-based vfox plugin that implements a machine-global manager for [`[bootstrap.packages]`](https://mise.jdx.dev/bootstrap/packages/). It wraps state owned by a host tool rather than installing versioned tools under mise's data directory." ([package-plugin-development](https://mise.jdx.dev/package-plugin-development.html))

#### 8.10.1 File layout

```
mise-vscode-extensions/
├── metadata.lua
├── mise.plugin.toml
└── hooks/
    ├── package_installed.lua
    ├── package_install.lua
    └── package_upgrade.lua
```

```toml
[package-manager]
requires = ["code"]
supports_version_pins = true
os = ["macos", "linux"]
```

| Key | Type / Default | Meaning |
| --- | --- | --- |
| `requires` | string[] | Host binaries the hooks invoke. mise adds its shims and global toolset bin paths to `PATH`, but **does not install these tools automatically** — users declare them in `[tools]` or install manually |
| `supports_version_pins` | boolean, default `false` | Whether the manager can install a pinned version |
| `os` | string[], optional, defaults to every platform | mise platform names such as `macos`, `linux`, `windows` |

> **Uncertainty:** the docs show the `[package-manager]` block immediately after the layout without naming the file. `mise.plugin.toml` is the only TOML file in the layout, so that is where it belongs, but the page does not state it explicitly ([package-plugin-development](https://mise.jdx.dev/package-plugin-development.html#layout)).

#### 8.10.2 Hooks

**All hooks receive the complete package batch. Managers must be batch-oriented.**

| Hook | Signature | Required | Purpose | `ctx` fields | Returns |
| --- | --- | --- | --- | --- | --- |
| `PackageInstalled` | `function PLUGIN:PackageInstalled(ctx)` | ✅ | Report installed/missing state for every requested package | `ctx.packages` = `{{ name = "diff", version = "1.3.4" \| nil }, ...}` | `{packages = {{name, state = "installed"\|"missing", version?}, …}}` |
| `PackageInstall` | `function PLUGIN:PackageInstall(ctx)` | ✅ | Install the requested batch | `ctx.packages`, `ctx.dry_run`, `ctx.update` | `{}` |
| `PackageUpgrade` | `function PLUGIN:PackageUpgrade(ctx)` | optional | Upgrade the requested batch. Same context and response as `PackageInstall`; mise calls `PackageInstall` when the upgrade hook is absent | `ctx.packages`, `ctx.dry_run`, `ctx.update` | `{}` |

```lua
function PLUGIN:PackageInstalled(ctx)
  -- ctx.packages: {{ name = "diff", version = "1.3.4" | nil }, ...}
  return {
    packages = {
      { name = "diff", state = "installed", version = "1.3.4" },
      { name = "s3", state = "missing" },
    },
  }
end
```

`PackageInstalled` "must be side-effect free, fast, non-interactive, and never elevate. It must return one `installed` or `missing` entry for every request. mise computes a version mismatch when a requested pin is not exactly equal to the returned version."

```lua
function PLUGIN:PackageInstall(ctx)
  -- ctx.dry_run: print intended actions and do nothing
  -- ctx.update: refresh manager metadata first when applicable
  for _, package in ipairs(ctx.packages) do
    -- install package.name, optionally at package.version
  end
  return {}
end
```

"The name reserves room for a future `PackageUninstall` hook, but uninstall and prune are not part of v1."

#### 8.10.3 Hard contracts

* Package plugins **must never invoke `sudo`** in any hook. mise never elevates for them.
* **Version strings are opaque.** Compare them with exact equality only; never parse or sort them.
* `PackageInstalled` is side-effect free, non-interactive, never elevates, and should be fast.
* Hooks operate on the **full request batch**.
* Declare **every** required host binary in `requires`.

Worked reference: for VS Code, `PackageInstalled` can parse `code --list-extensions --show-versions`, `PackageInstall` can run `code --install-extension name[@version]`, and `PackageUpgrade` can run `code --update-extensions` or reinstall the requested extensions ([package-plugin-development](https://mise.jdx.dev/package-plugin-development.html)).

### 8.11 asdf (Legacy) Shell Plugins

asdf plugins are shell-script based, following the asdf plugin specification, supported by mise "for backward compatibility" ([asdf-legacy-plugins](https://mise.jdx.dev/asdf-legacy-plugins.html)).

**Limitations:** Linux/macOS only (no Windows); slower than native backends; limited features; harder to maintain and debug; "less secure than sandboxed modern backends."

**Only use asdf plugins when:** the tool isn't available through modern backends; you need compatibility with existing asdf workflows; or the tool requires complex shell-based installation logic that modern backends can't handle.

#### 8.11.1 Installation

```bash
# From the registry shorthand
mise use postgres@15
# equivalent to
mise use asdf:mise-plugins/mise-postgres@15

# From a git repository
mise plugin install postgres https://github.com/mise-plugins/mise-postgres

# Manual
mise plugin add postgres https://github.com/mise-plugins/mise-postgres
mise install postgres@15.0.0
mise use postgres@15.0.0
```

#### 8.11.2 File layout

```
plugin-name/
├── bin/
│   ├── list-all          # List all available versions
│   ├── download          # Download source code/binary
│   ├── install           # Install the tool
│   ├── latest-stable     # Get latest stable version [optional]
│   ├── help.overview     # Plugin description [optional]
│   ├── help.deps         # Plugin dependencies [optional]
│   ├── help.config       # Plugin configuration [optional]
│   ├── help.links        # Plugin links [optional]
│   ├── list-legacy-filenames  # Legacy version files [optional]
│   ├── parse-legacy-file # Parse legacy version files [optional]
│   ├── post-plugin-add   # Post plugin addition hook [optional]
│   ├── post-plugin-update # Post plugin update hook [optional]
│   ├── pre-plugin-remove # Pre plugin removal hook [optional]
│   └── exec-env          # Set execution environment [optional]
├── lib/                  # Shared library code [optional]
└── README.md
```

Additionally, `bin/list-aliases` provides [aliased versions](https://mise.jdx.dev/dev-tools/aliases.html) — one `alias version` pair per line:

```bash
#!/usr/bin/env bash

echo "lts-krypton 24"
echo "lts-jod 22"
echo "lts-iron 20"
```

(mise's built-in node plugin already ships these LTS aliases; the example shows the format other plugins can use.) ([dev-tools/aliases](https://mise.jdx.dev/dev-tools/aliases.html))

#### 8.11.3 Script reference

| Script | Required | Purpose |
| --- | --- | --- |
| `bin/list-all` | ✅ | List all available versions of the tool (stdout, whitespace-separated / newline list) |
| `bin/download` | ✅ | Download the tool source/binary into `$ASDF_DOWNLOAD_PATH` |
| `bin/install` | ✅ | Install the tool into `$ASDF_INSTALL_PATH` |
| `bin/latest-stable` | optional | Print the latest stable version |
| `bin/help.overview` | optional | Plugin description |
| `bin/help.deps` | optional | Plugin dependencies |
| `bin/help.config` | optional | Plugin configuration |
| `bin/help.links` | optional | Plugin links |
| `bin/list-legacy-filenames` | optional | Print legacy version file names, one per line |
| `bin/parse-legacy-file` | optional | Parse a legacy version file (path passed as `$1`) and print the version |
| `bin/post-plugin-add` | optional | Post plugin addition hook |
| `bin/post-plugin-update` | optional | Post plugin update hook |
| `bin/pre-plugin-remove` | optional | Pre plugin removal hook |
| `bin/exec-env` | optional | Set environment variables when executing tools |
| `bin/list-aliases` | optional | Provide version aliases ([dev-tools/aliases](https://mise.jdx.dev/dev-tools/aliases.html)) |

```bash
#!/usr/bin/env bash
# bin/list-all — List all available versions
curl -s https://api.github.com/repos/owner/repo/releases |
  grep '"tag_name":' |
  sed -E 's/.*"([^"]+)".*/\1/' |
  sort -V
```

```bash
#!/usr/bin/env bash
# bin/download
set -e

# Input variables from mise
# ASDF_INSTALL_TYPE (version or ref)
# ASDF_INSTALL_VERSION (version number or git ref)
# ASDF_INSTALL_PATH (where to install)
# ASDF_DOWNLOAD_PATH (where to download)

version="$ASDF_INSTALL_VERSION"
download_path="$ASDF_DOWNLOAD_PATH"

# Download logic here
curl -Lo "$download_path/archive.tar.gz" \
  "https://github.com/owner/repo/archive/v${version}.tar.gz"
```

```bash
#!/usr/bin/env bash
# bin/install
set -e

install_path="$ASDF_INSTALL_PATH"
download_path="$ASDF_DOWNLOAD_PATH"

# Extract and install
cd "$download_path"
tar -xzf archive.tar.gz --strip-components=1
make install PREFIX="$install_path"
```

```bash
#!/usr/bin/env bash
# bin/exec-env — Set environment variables

export TOOL_HOME="$ASDF_INSTALL_PATH"
export PATH="$ASDF_INSTALL_PATH/bin:$PATH"
```

```bash
#!/usr/bin/env bash
# bin/latest-stable
curl -s https://api.github.com/repos/owner/repo/releases/latest |
  grep '"tag_name":' |
  sed -E 's/.*"([^"]+)".*/\1/'
```

```bash
#!/usr/bin/env bash
# bin/list-legacy-filenames
echo ".tool-version"
echo ".tool-versions"
```

```bash
#!/usr/bin/env bash
# bin/parse-legacy-file
cat "$1" | head -n 1
```

#### 8.11.4 Environment variables available to asdf plugins

| Variable | Meaning |
| --- | --- |
| `ASDF_INSTALL_TYPE` | `version` or `ref` |
| `ASDF_INSTALL_VERSION` | Version number or git ref |
| `ASDF_INSTALL_PATH` | Installation directory |
| `ASDF_DOWNLOAD_PATH` | Download directory |
| `ASDF_PLUGIN_PATH` | Plugin directory |
| `ASDF_PLUGIN_PREV_REF` | Previous git ref (for updates) |
| `ASDF_PLUGIN_POST_REF` | New git ref (for updates) |
| `ASDF_CMD_FILE` | Path to executable being run |

Plus `MISE_TOOL_OPTS__<OPTION>` for each tool option (§8.5) ([plugins](https://mise.jdx.dev/plugins.html#tool-options)).

Notably, `bin/list-all` and `bin/latest-stable` "receive environment variables and PATH additions resolved from mise configuration before tools are loaded. This allows private plugins to use credentials, helper executables from `_.path`, or other project-specific values from `[env]` while listing versions. Because these values can change the available versions, mise stores version-list caches separately for each resolved configuration environment without writing the original values or paths to the cache." ([dev-tools/backends/asdf](https://mise.jdx.dev/dev-tools/backends/asdf.html#writing-asdf-legacy-plugins-for-mise))

#### 8.11.5 asdf → vfox hook migration

| asdf Script | vfox Hook | Notes |
| --- | --- | --- |
| `bin/list-all` | `Available` | Return structured version objects instead of plain text |
| `bin/download` | `PreInstall` | Return URL and checksum; mise handles the download |
| `bin/install` | `PostInstall` | Runs after mise downloads and extracts the tool |
| `bin/exec-env` | `EnvKeys` | Return structured key/value pairs instead of export statements |
| `bin/list-legacy-filenames` | `PLUGIN.legacyFilenames` | Set in `metadata.lua` instead of a script |
| `bin/parse-legacy-file` | `ParseLegacyFile` | Return structured result instead of plain text |

([dev-tools/backends/asdf](https://mise.jdx.dev/dev-tools/backends/asdf.html#hook-migration-asdf-to-vfox))

Testing legacy plugins locally:

```bash
mise plugin add my-plugin /path/to/local/plugin
mise list-all my-plugin
mise install my-plugin@1.0.0
mise which my-plugin

export MISE_DEBUG=1        # or:
mise install --verbose my-plugin@1.0.0
```

### 8.12 Lua modules (plugin stdlib)

Available in **both backend plugins and tool plugins** (and, per the env-plugin page, `http`/`json`/`file`/`cmd`/`strings`/`env` in environment plugins) ([plugin-lua-modules](https://mise.jdx.dev/plugin-lua-modules.html)).

| Module | Purpose | Documented API |
| --- | --- | --- |
| `cmd` | Execute shell commands | `cmd.exec(command[, opts])` |
| `json` | Parse and generate JSON | `json.encode(tbl)`, `json.decode(str)` |
| `http` | HTTP requests and downloads | `http.get`, `http.head`, `http.download_file`, `http.try_get`, `http.try_head`, `http.try_download_file` |
| `file` | File system operations | `file.join_path(...)`, `file.read(path)`, `file.symlink(src, dst)`, `file.exists(path)` |
| `env` | Environment variable operations | `env.setenv(key, value)` (read with `os.getenv`) |
| `strings` | String manipulation | `split`, `join`, `trim_space`, `trim`, `has_prefix`, `has_suffix`, `contains`, `trim_prefix` |
| `semver` | Semantic version comparison/sorting | `semver.compare`, `semver.parse`, `semver.sort`, `semver.sort_by` |
| `html` | HTML parsing | `html.parse(str)`, `doc:find(selector)`, `el:text()`, `el:attr(name)` |
| `archiver` | Archive extraction | `archiver.decompress(archive, destdir)` |
| `log` | Structured logging | `log.trace/debug/info/warn/error`, also `require("vfox").log` |

#### 8.12.1 `http`

```lua
local http = require("http")

-- GET request
local resp, err = http.get({
    url = "https://api.github.com/repos/owner/repo/releases",
    headers = {
        ['User-Agent'] = "mise-plugin",
        ['Accept'] = "application/json"
    }
})

if err ~= nil then
    error("Request failed: " .. err)
end

if resp.status_code ~= 200 then
    error("HTTP error: " .. resp.status_code)
end

local body = resp.body
```

```lua
-- HEAD request to check file info
local resp, err = http.head({
    url = "https://example.com/file.tar.gz"
})

local content_length = resp.headers['content-length']
local content_type = resp.headers['content-type']
```

```lua
-- Download file
local err = http.download_file({
    url = "https://github.com/owner/repo/archive/v1.0.0.tar.gz",
    headers = {
        ['User-Agent'] = "mise-plugin"
    }
}, "/path/to/download.tar.gz")

if err ~= nil then
    error("Download failed: " .. err)
end
```

**Non-raising `try_*` variants.** `http.get`, `http.head`, and `http.download_file` **raise a Lua error** on transport failures (timeouts, DNS errors, connection refused). "Since `pcall()` cannot catch errors from async functions in this environment, non-raising variants are provided":

```lua
-- try_get: returns (resp, nil) on success, (nil, err_string) on failure
local resp, err = http.try_get({
    url = "https://primary.example.com/index"
})
if err ~= nil then
    -- fall back to another source
    resp, err = http.try_get({ url = "https://fallback.example.com/index" })
end

-- try_head: same return convention as try_get
local resp, err = http.try_head({ url = "https://example.com/file.tar.gz" })

-- try_download_file: returns (true, nil) on success, (nil, err_string) on failure
local ok, err = http.try_download_file({
    url = "https://example.com/archive.tar.gz"
}, "/path/to/download.tar.gz")
if err ~= nil then
    error("Download failed: " .. err)
end
```

Response object shape:

```lua
{
    status_code = 200,
    headers = {
        ['content-type'] = "application/json",
        ['content-length'] = "1234"
    },
    body = "response content"
}
```

#### 8.12.2 `json`, `strings`, `semver`

```lua
local json = require("json")

local jsonStr = json.encode({name = "mise-plugin", version = "1.0.0", tools = {"prettier", "eslint"}})
-- '{"name":"mise-plugin","version":"1.0.0","tools":["prettier","eslint"]}'
local decoded = json.decode(jsonStr)
print(decoded.name)     -- "mise-plugin"
print(decoded.tools[1]) -- "prettier"

-- Safe parsing
local success, result = pcall(json.decode, response_body)
if not success then
    error("Failed to parse JSON: " .. result)
end
```

```lua
local strings = require("strings")

local parts   = strings.split("hello,world,test", ",")      -- {"hello","world","test"}
local joined  = strings.join({"hello","world","test"}, " - ") -- "hello - world - test"
local trimmed = strings.trim_space("  hello world  ")        -- "hello world"

print(strings.has_prefix("hello world", "hello"))  -- true
print(strings.has_suffix("hello world", "world"))  -- true
print(strings.contains("hello world", "lo wo"))    -- true
print(strings.trim("hello world", "world"))        -- "hello "

-- strings.trim_prefix
local v = strings.trim_prefix("v1.2.3", "v")       -- "1.2.3"
```

```lua
local semver = require("semver")

-- compare: -1 if v1 < v2, 0 if equal, 1 if v1 > v2
semver.compare("1.2.3", "1.2.4")   -- -1
semver.compare("2.0.0", "1.9.9")   --  1
semver.compare("1.0.0", "1.0.0")   --  0
semver.compare("9.6.9", "9.6.24")  -- -1 (not lexicographic!)
semver.compare("10.0.0", "9.6.24") --  1

-- parse into numeric parts (tolerates prefixes/suffixes)
local parts = semver.parse("1.2.3")      -- {1, 2, 3}
local parts = semver.parse("v1.2.3-beta") -- {1, 2, 3}

-- sort an array of version strings, ascending
local sorted = semver.sort({"1.10.0", "1.2.0", "1.9.0", "2.0.0"})
-- {"1.2.0", "1.9.0", "1.10.0", "2.0.0"}

-- sort an array of tables by a version field, ascending
local sorted = semver.sort_by(releases, "version")
```

```lua
-- Sort with custom comparator (descending order - newest first)
table.sort(versions, function(a, b)
    return semver.compare(a.version, b.version) > 0
end)

-- Sort ascending (oldest first) - default for Available()
table.sort(versions, function(a, b)
    return semver.compare(a.version, b.version) < 0
end)
```

#### 8.12.3 `html`

```lua
local html = require("html")

local doc = html.parse([[
    <html>
        <body>
            <div id="version" class="info">1.2.3</div>
            <ul class="downloads">
                <li><a href="/download/v1.2.3.tar.gz">Source</a></li>
                <li><a href="/download/v1.2.3.zip">Windows</a></li>
            </ul>
        </body>
    </html>
]])

-- Extract text content
local version = doc:find("#version"):text()  -- "1.2.3"

-- Extract attributes
local links = doc:find("a")
for _, link in ipairs(links) do
    local href = link:attr("href")
    local text = link:text()
    print(text .. ": " .. href)
end
```

CSS selectors supported: by ID (`#version`), by class (`.download-link`), by tag (`a`), and complex selectors (`ul.downloads a[href$='.tar.gz']`).

#### 8.12.4 `archiver`

Supported formats: **tar.gz**, **tar.xz**, **tar.bz2**, **zip**.

```lua
local archiver = require("archiver")

local err = archiver.decompress("archive.tar.gz", "extracted/")
if err ~= nil then
    error("Extraction failed: " .. err)
end

local err = archiver.decompress("package.zip", "destination/")
if err ~= nil then
    error("ZIP extraction failed: " .. err)
end
```

#### 8.12.5 `file` and `env`

```lua
local file = require("file")

-- Join path segments using the OS-specific separator (recommended for cross-platform plugins)
local full_path = file.join_path("/foo", "bar", "baz.txt")
-- On Unix: /foo/bar/baz.txt, on Windows: \foo\bar\baz.txt

print(file.read("/path/to/file"))
file.symlink("/path/to/source", "/path/to/new-symlink")

if file.exists("important_file.txt") then
    print("File exists")
else
    print("File does not exist")
end
```

```lua
local env = require("env")

env.setenv("MY_VAR", "my_value")
-- To READ variables in Lua, use os.getenv("MY_VAR")

local current_path = os.getenv("PATH")
env.setenv("PATH", "/usr/local/bin:" .. current_path)

-- Platform-specific PATH separator
local separator = package.config:sub(1,1) == '\\' and ";" or ":"
env.setenv("PATH", table.concat({"/usr/local/bin", "/opt/bin", current_path}, separator))
```

#### 8.12.6 `cmd`

```lua
local cmd = require("cmd")

local output = cmd.exec("ls -la")

-- with error handling
local success, output = pcall(cmd.exec, "some-command")
if not success then
    error("Command failed: " .. output)
end

-- with options
local output = cmd.exec("pwd", {cwd = "/tmp"})
local result = cmd.exec("echo $TEST_VAR", {
    cwd = "/path/to/project",
    env = {TEST_VAR = "hello", NODE_ENV = "production"}
})
```

| Option | Type | Meaning |
| --- | --- | --- |
| `cwd` | string | Working directory for the command |
| `env` | table | Environment variables for the command; **merged on top of** the inherited environment |
| `timeout` | number | Timeout for command execution — **"(future feature)"** |

Environment inheritance in env-module hooks is described in §8.9.4.

#### 8.12.7 `log`

Routes through Rust's `log` crate, respecting `MISE_DEBUG` and `MISE_TRACE`.

```lua
local log = require("log")

log.trace("detailed tracing info")   -- only visible with MISE_TRACE=1
log.debug("debugging info")          -- visible with MISE_DEBUG=1
log.info("status message")           -- visible by default
log.warn("warning message")          -- visible by default
log.error("error message")           -- visible by default
```

All log functions accept multiple arguments of any type; arguments are converted via `tostring()` and joined with tab characters, matching Lua's `print()`:

```lua
log.info("version", version, "installed to", path)
-- Output: [plugin-name] version<TAB>1.0.0<TAB>installed to<TAB>/path
```

Messages are automatically prefixed with `[plugin_name]`: `mise [INFO] [my-plugin] Installing version 1.0.0`.

**`print()` is overridden** to route through `info!()` level logging: output goes to **stderr instead of stdout**, is prefixed with `[plugin_name]`, and respects log-level filtering. `print("hello", "world")` ≡ `log.info("hello", "world")`.

Also reachable as `local log = require("vfox").log`.

### 8.13 Testing plugins locally

| Step | Command |
| --- | --- |
| Link a working directory as a plugin | `mise plugin link my-tool /path/to/my-tool-plugin` |
| Declare a local plugin in config instead | `[plugins]` → `my-plugin = "./plugins/my-plugin"` |
| Replace an existing installation with the local source | `mise plugins install --force my-plugin` |
| List versions (tool plugin) | `mise ls-remote my-tool` |
| List versions (backend plugin) | `mise ls-remote my-plugin:some-tool` |
| Install | `mise install my-tool@1.0.0` / `mise use my-plugin:some-tool@1.0.0` |
| Execute | `mise exec -- some-tool --version` |
| Env plugin: inspect env | `mise env \| grep MY_`, `mise exec -- env \| grep MY_` |
| Verify plugin is installed | `mise plugins ls` |
| Debug output | `mise --debug install my-plugin:some-tool@1.0.0`, or `MISE_DEBUG=1 mise env` |
| Registry-driven tool smoke test | `mise test-tool <tool>` |

([tool-plugin-development](https://mise.jdx.dev/tool-plugin-development.html#testing-your-plugin), [backend-plugin-development](https://mise.jdx.dev/backend-plugin-development.html#testing-your-plugin), [env-plugin-development](https://mise.jdx.dev/env-plugin-development.html#testing-your-plugin), [plugin-usage](https://mise.jdx.dev/plugin-usage.html), [configuration](https://mise.jdx.dev/configuration.html#plugins-specify-custom-plugin-repository-urls))

#### 8.13.1 `mise test-tool`

`mise test-tool [FLAGS] [TOOLS]…` — "Test a tool installs and executes" ([cli/test-tool](https://mise.jdx.dev/cli/test-tool.html)).

| Name | Type/Default | Meaning |
| --- | --- | --- |
| `[TOOLS]…` | positional | Tool(s) to test |
| `-a --all` | flag | Test every tool specified in `registry/` |
| `-j --jobs <JOBS>` | number, default `4` | Number of tool tests to run in parallel |
| `--all-config` | flag | Test all tools specified in config files |
| `--include-non-defined` | flag | Also test tools not defined in `registry/`, guessing how to test it |
| `--raw` | flag | Connect backend install command stdin/stdout/stderr directly to the terminal. **Implies `--jobs=1`** |

```
mise test-tool ripgrep
```

#### 8.13.2 Template-provided tasks and a hand-rolled test script

```bash
# If using the template repository
mise run lint
mise run test
```

```bash
#!/bin/bash
# test/test.sh
set -e

echo "Testing nodejs plugin..."

# Install the plugin
mise plugin install nodejs .

# Test basic functionality
mise install nodejs@18.18.0
mise use nodejs@18.18.0

# Verify installation
node --version | grep "18.18.0"
npm --version

# Test legacy file support
echo "20.0.0" > .nvmrc
mise use nodejs
node --version | grep "20.0.0"

# Clean up
rm -f .nvmrc
mise plugin remove nodejs

echo "All tests passed!"
```

Cross-distro smoke test in a container:

```bash
docker run --rm -it ubuntu:latest bash -c "
    curl -fsSL https://mise.jdx.dev/install.sh | sh
    mise plugin install my-plugin https://github.com/username/my-plugin
    mise install my-plugin@latest
"
```

#### 8.13.3 Troubleshooting

| Symptom | Check |
| --- | --- |
| Plugin installation fails | Repository URL correct? `ls ~/.local/share/mise/plugins/` |
| Tool installation fails | `mise install vfox-npm:prettier@latest --verbose`; `mise plugins ls` |
| Environment issues | `mise exec vfox-npm:prettier env \| grep PATH`; `ls ~/.local/share/mise/installs/vfox-npm/prettier/` |
| Env-plugin hook not executing | `MISE_DEBUG=1 mise env` |
| Env-plugin options not passed | Verify `_.my-plugin = { key = "value" }` is a TOML **table**, not a string |
| "Plugin not installing" | `git clone <url>`; `ls -la my-plugin/metadata.lua`; `mise plugin link my-plugin ./my-plugin` |
| Version conflicts | `grep version my-plugin/metadata.lua`; `git tag -l` |
| Permission issues | `git ls-remote <url>`; for private repos `ssh -T git@github.com` |

([plugin-usage](https://mise.jdx.dev/plugin-usage.html#troubleshooting), [env-plugin-development](https://mise.jdx.dev/env-plugin-development.html#common-issues), [plugin-publishing](https://mise.jdx.dev/plugin-publishing.html#troubleshooting))

### 8.14 Publishing a plugin

> There is **no centralized registry for community plugins**. Discovery is via GitHub search for repositories with the "vfox-" prefix, mise community discussions/Discord, or company-internal sources ([plugin-usage](https://mise.jdx.dev/plugin-usage.html#finding-plugins)). And new asdf/vfox plugins are **not accepted into the mise registry** (§8.1).

#### 8.14.1 Checklist

**Essential** ([plugin-publishing](https://mise.jdx.dev/plugin-publishing.html#publishing-checklist)):

* `metadata.lua` — plugin metadata with name, version, description, and author
* Plugin implementation — either backend methods or hook functions
* Test coverage — automated tests to verify functionality

**Optional but recommended:** `README.md`, a `test/` directory, and a git repository with proper versioning.

```
my-plugin/
├── metadata.lua          # Plugin metadata
├── README.md            # Basic documentation
├── test/                # Test scripts
│   └── test.sh
├── .gitignore           # Git ignore rules
└── [implementation files]
```

```gitignore
# Temporary files
*.tmp
*.temp
.DS_Store
Thumbs.db

# Test artifacts
test/tmp/
test/output/

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS files
*.log
```

#### 8.14.2 Versioning and release

Use SemVer: major = breaking changes, minor = new features (backward compatible), patch = bug fixes. Update `version` in `metadata.lua` for each release and tag:

```bash
git tag -a v1.2.3 -m "Release version 1.2.3"
git push origin --tags
```

Then create a GitHub release (Releases → "Create a new release" → choose the tag → write release notes → publish) for better discoverability.

```bash
# Simple backend plugin release
cd my-backend-plugin
mise plugin link my-plugin .
mise ls-remote my-plugin:tool
git add . && git commit -m "v1.0.0: Initial release"
git tag -a v1.0.0 -m "Initial release"
git push origin v1.0.0
```

#### 8.14.3 Distribution methods

| Method | Command users run |
| --- | --- |
| Direct git | `mise plugin install my-plugin https://github.com/username/my-plugin` |
| Specific version | `mise plugin install my-plugin https://github.com/username/my-plugin@v1.2.3` |
| Other git providers | `mise plugin install my-plugin https://gitlab.com/username/my-plugin` |
| Private repo, SSH (recommended) | `mise plugin install my-plugin git@github.com:username/private-plugin.git` |
| Private repo, HTTPS + token | `mise plugin install my-plugin https://username:token@github.com/username/private-plugin.git` |
| Archive | `git archive --format=zip --output=my-plugin-v1.2.3.zip v1.2.3`, then `mise plugin install my-plugin https://…/releases/download/v1.2.3/my-plugin-v1.2.3.zip` |

([plugin-publishing](https://mise.jdx.dev/plugin-publishing.html#distribution-methods))

> **Uncertainty:** the publishing page shows `…/my-plugin@v1.2.3` for "install specific version" while [cli/plugins/install](https://mise.jdx.dev/cli/plugins/install.html) and [cli/plugins/update](https://mise.jdx.dev/cli/plugins/update.html) document the `#<ref>` form (`…mise-poetry.git#11d0c1e`, `mise plugins update cmake#beta`). The two pages disagree on the separator; the `#` form is the one documented in the CLI reference.

#### 8.14.4 Hosting under `mise-plugins`

<https://github.com/mise-plugins> is a GitHub organization for community-developed plugins. "If you'd like your plugin to be hosted here please let me know (GH discussion or discord is fine) and I'd be happy to host it for you." ([plugins](https://mise.jdx.dev/plugins.html#plugin-authors))

For environment plugins specifically: "The [mise-plugins](https://github.com/mise-plugins) organization currently hosts tool plugins only—add your environment plugin there (or share it with the community) so others can learn from more examples" ([env-plugin-development](https://mise.jdx.dev/env-plugin-development.html#examples)).

#### 8.14.5 Publishing-time security guidance

* **Code review** — review all code changes before publishing; check for security vulnerabilities; validate external dependencies; test with untrusted inputs.
* **Dependency management** — pin dependency versions where possible; regularly update; monitor advisories; use trusted sources only.
* **Access control** — limit repository access; use strong authentication; regularly audit permissions; consider signed releases for sensitive plugins.

([plugin-publishing](https://mise.jdx.dev/plugin-publishing.html#security-considerations))

### 8.15 Templates and starting points

| Template | For | Ships with |
| --- | --- | --- |
| [mise-tool-plugin-template](https://github.com/jdx/mise-tool-plugin-template) | Tool plugins | LuaCATS type definitions, stylua formatting, hk linting, all required hooks, example implementations with comments, `.luacheckrc`/`stylua.toml`, testing setup with mise tasks, GitHub Actions CI |
| [mise-backend-plugin-template](https://github.com/jdx/mise-backend-plugin-template) | Backend plugins | Complete backend structure with all required hooks, hk/stylua/luacheck/actionlint, docs and examples, GitHub Actions CI, multiple implementation patterns |
| [mise-env-plugin-template](https://github.com/jdx/mise-env-plugin-template) | Environment plugins | LuaCATS type definitions, stylua formatting, hk linting |

```bash
# Option 1: GitHub's "Use this template" button (recommended for the backend template)
# Option 2: clone and reset history
git clone https://github.com/jdx/mise-tool-plugin-template my-tool-plugin
cd my-tool-plugin
rm -rf .git
git init
# Customize the plugin for your tool: edit metadata.lua, hooks/*.lua files, etc.
```

([tool-plugin-development](https://mise.jdx.dev/tool-plugin-development.html#using-the-template-repository), [backend-plugin-development](https://mise.jdx.dev/backend-plugin-development.html#using-the-template-repository), [env-plugin-development](https://mise.jdx.dev/env-plugin-development.html#quick-start))

Reference implementations named in the docs: [vfox-npm](https://github.com/jdx/vfox-npm) (backend), [vfox-nodejs](https://github.com/version-fox/vfox-nodejs) (tool), [vfox-neovim](https://github.com/mise-plugins/vfox-neovim) (rolling releases). The vfox backend itself lives at [src/backend/vfox.rs](https://github.com/jdx/mise/blob/main/src/backend/vfox.rs) ([dev-tools/backends/vfox](https://mise.jdx.dev/dev-tools/backends/vfox.html)).

---

## 9. Integration: CI, IDEs, Containers & Tooling

This section covers everything about running mise *outside* an interactive shell: continuous integration, editors and IDEs, containers/devcontainers, the MCP server for AI clients, shell completions, the code generators, and the housekeeping commands. It closes with a complete index of every top-level `mise` command.

> Version context: all statements below reflect the mise docs as of **2026-07** (mise `2026.7.x`). Alias columns in the CLI index were confirmed against `mise --help` from `mise 2026.7.17 macos-arm64 (2026-07-30)`.

---

### 9.1 The core problem: non-interactive environments

`mise activate` works by re-computing `PATH` and env vars **every time your shell prompt is displayed**. CI runners, IDEs, build scripts and Xcode script phases never display a prompt, so `mise activate` alone is the wrong tool there ([dev-tools/shims](https://mise.jdx.dev/dev-tools/shims.html)).

There are exactly three supported ways to get the mise environment into a non-interactive context ([dev-tools/shims](https://mise.jdx.dev/dev-tools/shims.html)):

| Mechanism | How | Loads env vars from `[env]`? | Loads hooks? | Best for |
|---|---|---|---|---|
| PATH activation | `eval "$(mise activate <shell>)"` | yes | yes | interactive shells only |
| Shims | `eval "$(mise activate <shell> --shims)"`, or `export PATH="$HOME/.local/share/mise/shims:$PATH"` | **only when a shim is executed** | `preinstall`/`postinstall` only; `cd`/`enter`/`leave`/`watch_files` do **not** fire | IDEs, CI, scripts, login profiles |
| Explicit exec | `mise exec -- cmd`, `mise run <task>`, `mise en` | yes | n/a (explicit) | CI steps, launch configs, precision |

Documented limitations of shims **relative to** PATH activation ([dev-tools/shims#shims-vs-path](https://mise.jdx.dev/dev-tools/shims.html#shims-vs-path)):

- `[env]` variables are only available to mise-managed tools (i.e. when a shim is invoked), not to your shell.
- Most [hooks](https://mise.jdx.dev/hooks.html) won't trigger.
- The unix `which` command resolves to the shim, obscuring the real executable — use `mise which` instead.

Shim location: `~/.local/share/mise/shims` on Unix, `%LOCALAPPDATA%\mise\shims` on Windows. A shim is a small executable that behaves like a symlink to the mise binary ([dev-tools/shims](https://mise.jdx.dev/dev-tools/shims.html)).

```sh
ls -l ~/.local/share/mise/shims/node
# [...] ~/.local/share/mise/shims/node -> ~/.local/bin/mise
```

`mise activate --shims` is documented as *"effectively the same as"* ([cli/activate#shims](https://mise.jdx.dev/cli/activate.html#shims)):

```sh
PATH="$HOME/.local/share/mise/shims:$PATH"
```

#### Combining shims and activate

It is explicitly fine to call `mise activate --shims` in the login/profile file and `mise activate` in the interactive rc file. What happens to the shims dir then depends on [`not_found_auto_install`](https://mise.jdx.dev/configuration/settings.html#not_found_auto_install) ([dev-tools/shims](https://mise.jdx.dev/dev-tools/shims.html)):

| `not_found_auto_install` | Behaviour of `mise activate` w.r.t. the shims dir |
|---|---|
| enabled (default) | shims dir stays in `PATH`, **behind** the tool paths mise manages; acts as an auto-install fallback. `mise doctor` does not flag this. |
| disabled | shims dir is **removed** from `PATH`; the rest of `PATH` is untouched. |

Canonical two-file setup ([dev-tools/shims](https://mise.jdx.dev/dev-tools/shims.html)):

```sh
# bash
echo 'eval "$(mise activate bash --shims)"' >> ~/.bash_profile   # non-interactive sessions
echo 'eval "$(mise activate bash)"'         >> ~/.bashrc         # interactive sessions

# zsh
echo 'eval "$(mise activate zsh --shims)"'  >> ~/.zprofile
echo 'eval "$(mise activate zsh)"'          >> ~/.zshrc

# fish
echo 'mise activate fish --shims | source' >> ~/.config/fish/config.fish
echo 'mise activate fish | source'         >> ~/.config/fish/config.fish
```

`mise reshim` forces regeneration of the shims directory. mise already reshims on install/update/remove (and most tools like `npm` trigger it), so it is only needed when the shims dir is missing something. **Do not put your own executables in the shims dir — mise deletes them on the next reshim** ([dev-tools/shims#mise-reshim](https://mise.jdx.dev/dev-tools/shims.html#mise-reshim)).

---

### 9.2 Continuous integration

#### 9.2.1 Any CI provider (the generic recipe)

The baseline recommendation is: **pin tool versions in the project config** so the environment is reproducible ([continuous-integration](https://mise.jdx.dev/continuous-integration.html)).

```yaml
script: |
  curl https://mise.run | sh
  mise install
```

Then run tools *through* mise so you get the mise-installed versions:

```yaml
script: |
  mise x -- npm test
```

Alternatively add the [shims](https://mise.jdx.dev/dev-tools/shims.html) directory to `PATH` if the provider allows it ([continuous-integration](https://mise.jdx.dev/continuous-integration.html)).

#### 9.2.2 Bootstrapping without a system mise

`mise generate bootstrap` emits a self-contained script that downloads and runs mise, so CI (and contributors) need no pre-installed mise ([continuous-integration#bootstrapping](https://mise.jdx.dev/continuous-integration.html#bootstrapping), [cli/generate/bootstrap](https://mise.jdx.dev/cli/generate/bootstrap.html)).

```sh
mise generate bootstrap -l -w
```

Add `.mise/` to `.gitignore` and **commit the generated `./bin/mise`**. Then:

```yaml
script: |
  ./bin/mise install
  ./bin/mise x -- npm test
```

| Flag | Type/default | Meaning |
|---|---|---|
| `-l --localize` | flag | Sandbox mise internal dirs (`MISE_DATA_DIR`, `MISE_CACHE_DIR`) into a `.mise` directory in the project. Necessary if users may run a different mise outside the project. |
| `--localized-dir <DIR>` | string, default `.mise` | Directory to put localized data into. |
| `-V --version <VERSION>` | string | Specific mise version to fetch. |
| `-w --write <WRITE>` | path | Write the script to a file and make it executable instead of printing to stdout. |

([cli/generate/bootstrap](https://mise.jdx.dev/cli/generate/bootstrap.html))

Version-selection semantics of the generated script ([continuous-integration#bootstrapping](https://mise.jdx.dev/continuous-integration.html#bootstrapping)):

- By default it installs the version it was generated with.
- It honours the same `MISE_VERSION` and `MISE_INSTALL_PATH` variables as [the install script](https://mise.jdx.dev/installing-mise.html).
- An explicit `MISE_INSTALL_PATH` is **always used as-is**.
- Otherwise `MISE_VERSION` also selects the default cache path — so **bumping `MISE_VERSION` in CI installs the requested version instead of silently reusing the first-cached one**.

#### 9.2.3 Safe mode: running against untrusted config

When a job resolves tool versions from configuration it does not control — the canonical case being a bot that refreshes `mise.lock` on pull-request branches — set `MISE_SAFE=1` ([continuous-integration#running-against-untrusted-config-safe-mode](https://mise.jdx.dev/continuous-integration.html#running-against-untrusted-config-safe-mode)).

```yaml
script: |
  MISE_SAFE=1 mise lock --bump --json
```

In safe mode mise **refuses with an error (never a silent fallback)** to ([security#safe-mode](https://mise.jdx.dev/security.html#safe-mode)):

| Refused | Note |
|---|---|
| template `exec()` / `read_file()` | in config templates |
| hooks | suppressed like `--no-hooks`, since hooks fire ambiently from `mise env` / `hook-env` |
| tasks | |
| asdf plugin scripts | |
| plugin installs | already-installed and embedded vfox plugins keep working |

It additionally **ignores** environment/shell configuration from **project (non-global)** config: `[env]` values, `_.path`, `_.file`, and `[shell_alias]` entries — because those are an indirect code-execution vector (`PATH`, `LD_PRELOAD`, `DYLD_INSERT_LIBRARIES`, `NODE_OPTIONS`, …). `_.source` is treated as code execution and is ignored *regardless of where it is defined*, including operator-owned global config. `[settings]` from project config are also ignored. Global/system config still applies ([security#safe-mode](https://mise.jdx.dev/security.html#safe-mode)).

Version resolution still works for `core`, `aqua`, `github`, `gitlab`, `http`, `cargo`, `pipx`, `gem`, `dotnet`, `npm`, and `go` (which runs with `GOTOOLCHAIN=local` so a project `go.mod` cannot trigger a toolchain download) ([security#safe-mode](https://mise.jdx.dev/security.html#safe-mode)).

Two important consequences:

- **Safe mode does not require trust.** A config loaded in safe mode is inert, so mise loads untrusted configs with no trust prompt or error. This is what lets `mise lock` run against PR config with no preceding `mise trust` ([security#safe-mode](https://mise.jdx.dev/security.html#safe-mode)).
- `MISE_SAFE` is `global_only` — it can only be set via the environment or global config, so a project `mise.toml` **cannot turn it off for itself** ([security#safe-mode](https://mise.jdx.dev/security.html#safe-mode)).

Safe mode limits *what a config can do*; trust limits *which configs are loaded* ([security#safe-mode](https://mise.jdx.dev/security.html#safe-mode)).

#### 9.2.4 Trust in CI

`mise trust` marks a config file as trusted — i.e. mise is allowed to parse a file that may execute code or affect the environment. Without trust, mise "may prompt, skip the config in some discovery paths, fail with an untrusted-config error when it cannot prompt, or **assume trust in detected CI unless paranoid mode is enabled**" ([cli/trust](https://mise.jdx.dev/cli/trust.html)).

Configs that are *safe by construction* need no trust at all: files containing only `min_version`, `[tools]` entries with plain version strings (or arrays of them), and `[tasks]` **with no templates and no tool options** load without prompting ([cli/trust](https://mise.jdx.dev/cli/trust.html)).

| Knob | Where | Meaning |
|---|---|---|
| `MISE_TRUSTED_CONFIG_PATHS` / `trusted_config_paths` | `string[]`, default `[]` | Config paths mise automatically marks as trusted; any config under them is trusted without prompting. `["/"]` trusts everything, effectively disabling the trust mechanism. Separated by the OS path separator in the env var (`:` on Unix, `;` on Windows). ([settings#trusted_config_paths](https://mise.jdx.dev/configuration/settings.html#trusted_config_paths)) |
| `MISE_PARANOID` / `paranoid` | `boolean`, default `false` | Extra-secure behavior; see [Paranoid](https://mise.jdx.dev/paranoid.html). Disables the CI trust assumption and disables worktree trust sharing. ([settings#paranoid](https://mise.jdx.dev/configuration/settings.html#paranoid), [cli/trust](https://mise.jdx.dev/cli/trust.html)) |

`mise trust` flags ([cli/trust](https://mise.jdx.dev/cli/trust.html)):

| Flag | Meaning |
|---|---|
| `-a --all` | Trust all config files in the current dir, its parents and its subdirectories. Subdirectory walk respects `.gitignore` and skips hidden dirs plus `node_modules`, `vendor`, `target`, `dist`, `build`. |
| `--ignore` | Do not trust this config and ignore it in the future |
| `--show` | Show trust status of configs from the current dir and parents; changes nothing |
| `--untrust` | Stop trusting; will prompt in the future |

Trust is shared across git worktrees — a config inside a linked worktree is trusted when the equivalent path in the main checkout is trusted. Paranoid mode disables that sharing ([cli/trust](https://mise.jdx.dev/cli/trust.html)).

#### 9.2.5 Non-interactive / `--yes`

| Knob | Type/default | Meaning |
|---|---|---|
| `-y --yes` (global flag) | flag | Answer yes to all confirmation prompts ([cli/](https://mise.jdx.dev/cli/)) |
| `MISE_YES` / `yes` setting | `boolean`, default `false` | Automatically answer yes/no to prompts; "useful for scripting" ([settings#yes](https://mise.jdx.dev/configuration/settings.html#yes)) |
| `-q --quiet` | flag | Suppress non-error messages ([cli/](https://mise.jdx.dev/cli/)) |
| `--silent` | flag | Suppress **all** task output and mise non-error messages ([cli/](https://mise.jdx.dev/cli/)) |
| `--no-config` / `MISE_NO_CONFIG=1` | flag | Do not load any config files ([cli/](https://mise.jdx.dev/cli/)) |
| `--no-env` / `MISE_NO_ENV=1` | flag | Do not load env vars from config files ([cli/](https://mise.jdx.dev/cli/)) |
| `--no-hooks` / `MISE_NO_HOOKS=1` | flag | Do not execute hooks from config files ([cli/](https://mise.jdx.dev/cli/)) |
| `-j --jobs <N>` | default `8` | Parallel jobs ([cli/](https://mise.jdx.dev/cli/)) |

Also relevant for machine setup jobs: `mise bootstrap --yes` ([tips-and-tricks#machine-bootstrapping](https://mise.jdx.dev/tips-and-tricks.html#machine-bootstrapping)).

#### 9.2.6 Lockfile-pinned CI

The `--locked` global flag is the hard guarantee for reproducible, API-free installs ([cli/](https://mise.jdx.dev/cli/)):

> **`--locked`** — Require lockfile URLs to be present during installation. Fails if tools don't have pre-resolved URLs in the lockfile for the current platform. This prevents API calls to GitHub, aqua registry, etc. Can also be enabled via `MISE_LOCKED=1` or `settings.locked=true`.

Why this matters in CI ([tips-and-tricks#lockfile-url-tracking-avoiding-rate-limits](https://mise.jdx.dev/tips-and-tricks.html#lockfile-url-tracking-avoiding-rate-limits)):

- **Avoids GitHub API rate limits** — after the first install, subsequent `mise install` runs use the URLs from the lockfile instead of calling provider APIs.
- **No `GITHUB_TOKEN` needed** for simple installs (see [GitHub Tokens](https://mise.jdx.dev/dev-tools/github-tokens.html)).
- **Faster installs** — API lookups are skipped.

Creating the lockfile is manual — mise does not create it automatically ([tips-and-tricks#mise-lock](https://mise.jdx.dev/tips-and-tricks.html#mise-lock)):

```sh
touch mise.lock
mise i
```

`mise lock` refreshes checksums/URLs for the platforms already in the lockfile, and is the command CI bump-jobs use ([cli/lock](https://mise.jdx.dev/cli/lock.html)):

| Flag | Meaning |
|---|---|
| `-g --global` | Target only global config lockfiles (`~/.config/mise/mise.lock` and system config); by default only the active project config root is locked |
| `-j --jobs <JOBS>` | Parallelism |
| `-n --dry-run` | Show what would be updated without changing anything |
| `-p --platform… <PLATFORM>` | Comma-separated platforms, e.g. `linux-x64,macos-arm64,windows-x64`; default = all platforms already in the lockfile |
| `--bump` | Re-resolve fuzzy selectors (`latest`, `lts`, `20`) against latest matching remote versions. **Config files are never modified** — use `mise upgrade --bump` to rewrite pins in `mise.toml` |
| `--json` | Emit version changes as JSON (`name`, `backend`, `lockfile`, `old_versions`, `new_versions`). Only version-level changes are reported, so plain `mise lock --json` typically prints `[]` while still updating the lockfile. Combine with `--dry-run` to detect updates without writing |
| `--local` | Update `mise.local.lock` instead of `mise.lock` |
| `--minimum-release-age <AGE>` | Only lock versions released before this age/date (`2024-06-01`, `90d`, `1y`). Affects fuzzy matches only; pinned versions are not filtered; existing entries are not downgraded by this flag alone |

Canonical CI bump job, combining safe mode with a dry-run JSON diff ([security#safe-mode](https://mise.jdx.dev/security.html#safe-mode)):

```sh
MISE_SAFE=1 mise lock --bump --dry-run --json
```

> **Gotcha:** mise must actually **install** a tool to compute its tarball checksum (otherwise it would need to download the tarball purely to hash it). So you may need `mise uninstall --all` first to force a reinstall that fills in checksums. Versions are still locked even without a checksum ([tips-and-tricks#mise-lock](https://mise.jdx.dev/tips-and-tricks.html#mise-lock)).

#### 9.2.7 GitHub Actions

Simplest form, no action required ([tips-and-tricks#github-actions](https://mise.jdx.dev/tips-and-tricks.html#github-actions)):

```yaml
jobs:
  build:
    steps:
      - run: |
          curl https://mise.run | sh
          echo "$HOME/.local/bin" >> $GITHUB_PATH
          echo "$HOME/.local/share/mise/shims" >> $GITHUB_PATH
```

Or use the maintained action ([continuous-integration#github-actions](https://mise.jdx.dev/continuous-integration.html#github-actions)):

```yaml
name: test
on:
  pull_request:
    branches:
      - main
  push:
    branches:
      - main
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: jdx/mise-action@v3
        with:
          version: 2024.12.14 # [default: latest] mise version to install
          install: true # [default: true] run `mise install`
          cache: true # [default: true] cache mise using GitHub's cache
          experimental: true # [default: false] enable experimental features
          # automatically write this mise.toml file
          mise_toml: |
            [tools]
            shellcheck = "0.9.0"
          # or, if you prefer .tool-versions:
          tool_versions: |
            shellcheck 0.9.0
      - run: shellcheck scripts/*.sh
```

Minimal version ([tips-and-tricks#github-actions](https://mise.jdx.dev/tips-and-tricks.html#github-actions)):

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: jdx/mise-action@v3
      - run: node -v # will be the node version from `mise.toml`/`.tool-versions`
```

> **Version skew:** the mise docs page pins the example at `jdx/mise-action@v3`, while the action's own repository documents `@v4` with a larger input set ([jdx/mise-action README](https://github.com/jdx/mise-action/blob/main/README.md)). Treat the action repo as authoritative for the input list; the table below is from that README.

**`jdx/mise-action@v4` inputs** ([jdx/mise-action README](https://github.com/jdx/mise-action/blob/main/README.md)):

| Input | Default | Meaning |
|---|---|---|
| `version` | `latest` | mise version to install |
| `install` | `true` | run `mise install` |
| `install_args` | `""` | additional arguments to `mise install` |
| `bootstrap` | `false` | run `mise bootstrap` instead of `mise install` |
| `bootstrap_skip` | `""` | comma-separated parts to skip when bootstrapping (e.g. `tools,task`) |
| `bootstrap_args` | `""` | additional arguments to `mise bootstrap` |
| `cache` | `true` | cache mise using GitHub's cache |
| `experimental` | `false` | enable experimental features |
| `log_level` | `info` | log level |
| `tool_versions` | – | inline `.tool-versions` content to write |
| `mise_toml` | – | inline `mise.toml` content to write |
| `working_directory` | `.` | directory to run mise in |
| `reshim` | `false` | run `mise reshim -f` |
| `env` | `true` | export mise environment variables |
| `export_path` | `true` | add mise PATH entries to subsequent steps |
| `github_token` | `${{ github.token }}` | GitHub token for API authentication |
| `cache_key` | – | override the entire cache key |
| `cache_key_prefix` | `mise-v1` | override just the cache key prefix |

PATH entries are added individually through `GITHUB_PATH`, so the runner's complete PATH is **not** copied into `GITHUB_ENV`. `export_path: false` exports regular env vars without persisting mise's PATH changes ([jdx/mise-action README](https://github.com/jdx/mise-action/blob/main/README.md)).

**Cache-key templates** available in `cache_key` (Handlebars, including `{{#if version}}…{{/if}}`) ([jdx/mise-action README](https://github.com/jdx/mise-action/blob/main/README.md)):

| Variable | Meaning |
|---|---|
| `{{version}}` | mise version from the `version` input |
| `{{cache_key_prefix}}` | cache key prefix |
| `{{platform}}` | target platform incl. runner image, e.g. `linux-x64-ubuntu24`, `macos-arm64-macos15`, `linux-x64-self-hosted`. Trailing segment is `process.env.ImageOS`, falling back to `self-hosted` — prevents collisions across runner providers |
| `{{file_hash}}` | hash of all mise configuration files |
| `{{mise_env}}` | value of `MISE_ENV` |
| `{{install_args_hash}}` | SHA256 of the sorted tools from install args |
| `{{bootstrap_hash}}` | SHA256 of bootstrap mode, skip list and args |
| `{{default}}` | the processed default cache key (useful for extending) |

```yaml
- uses: jdx/mise-action@v4
  with:
    cache_key: "mise-v1-{{platform}}-{{install_args_hash}}-{{file_hash}}"
    install_args: "node@24 python@3.14"
```

Lockfile auto-detection: if `mise.lock` is present in the working directory or a parent, the action automatically runs `mise install --locked` (adding `--locked` to your `install_args` unless you already passed it). Auto-detection is skipped when you supply `mise_toml` or `tool_versions` inputs. With `bootstrap: true` and a lockfile present the action runs `mise --locked bootstrap`; `install_args` cannot be combined with `bootstrap: true` ([jdx/mise-action README](https://github.com/jdx/mise-action/blob/main/README.md)).

> **Known issue:** Rust has a cache interaction because mise installs Rust through `rustup` — see [jdx/mise-action#215](https://github.com/jdx/mise-action/issues/215).

#### 9.2.8 GitLab CI

The recommended shape is a prebuilt image with mise baked in ([continuous-integration#gitlab-ci](https://mise.jdx.dev/continuous-integration.html#gitlab-ci)):

```dockerfile
FROM debian:12-slim

RUN apt-get update  \
    && apt-get -y --no-install-recommends install  \
      # install any tools you need
      sudo curl git ca-certificates build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://mise.run | MISE_VERSION=v... MISE_INSTALL_PATH=/usr/local/bin/mise sh
```

```yaml
build-job:
  stage: build
  image: mise-debian-slim # Use the image you created
  variables:
    MISE_DATA_DIR: $CI_PROJECT_DIR/.mise/mise-data
  cache:
    - key:
        prefix: mise-
        files: ["mise.toml", "mise.lock"] # mise.lock is optional, only if using `lockfile = true`
      paths:
        - $MISE_DATA_DIR
  script:
    - mise install
    - mise exec --command 'npm build'
```

With the bootstrap script instead, the image can be entirely generic ([continuous-integration#example-with-the-bootstrap-script](https://mise.jdx.dev/continuous-integration.html#example-with-the-bootstrap-script)):

```yaml
.mise-cache: &mise-cache
  key:
    prefix: mise-
    files: ["mise.toml", "./bin/mise"]
  paths:
    - .mise/installs
    - .mise/mise-2025.1.3

build-job:
  stage: build
  image: my-debian-slim-image # Use the image you created
  cache:
    - <<: *mise-cache
      policy: pull-push
  script:
    - ./bin/mise install
    - ./bin/mise exec --command 'npm build'
```

> **Caching gotcha:** cache the *install* directories, not the cache directory. mise auto-prunes its cache dir (see [`cache_prune_age`](https://mise.jdx.dev/configuration/settings.html#cache_prune_age)) and much of its content is ignored once >24 hours old, so *"it's likely wasteful to store this directory in CI jobs"* ([cache-behavior#cache-auto-pruning](https://mise.jdx.dev/cache-behavior.html#cache-auto-pruning)).

Which directories exist and what they hold: see [Directory Structure](https://mise.jdx.dev/directories.html) ([continuous-integration#gitlab-ci](https://mise.jdx.dev/continuous-integration.html#gitlab-ci)).

#### 9.2.9 CircleCI and other providers

> **Uncertainty:** the mise documentation has no CircleCI-specific page or example. Use the "Any CI provider" recipe ([continuous-integration#any-ci-provider](https://mise.jdx.dev/continuous-integration.html#any-ci-provider)) — install via `curl https://mise.run | sh` or a committed `./bin/mise` from `mise generate bootstrap`, then `mise install` and `mise x -- <cmd>`, or add the shims dir to `PATH`.

#### 9.2.10 Xcode Cloud

Xcode Cloud runs a custom `ci_post_clone.sh` [build script](https://developer.apple.com/documentation/xcode/writing-custom-build-scripts) ([continuous-integration#xcode-cloud](https://mise.jdx.dev/continuous-integration.html#xcode-cloud)):

```bash
#!/bin/sh
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"

mise install # Installs the tools in mise.toml
eval "$(mise activate bash --shims)" # Adds the activated tools to $PATH

swiftlint {args}
```

---

### 9.3 Docker & devcontainers

#### 9.3.1 Base image

Recommended Dockerfile shape ([mise-cookbook/docker](https://mise.jdx.dev/mise-cookbook/docker.html)):

```dockerfile
FROM debian:13-slim

RUN apt-get update  \
    && apt-get -y --no-install-recommends install  \
        # install any other dependencies you might need
        sudo curl git ca-certificates build-essential \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV MISE_DATA_DIR="/mise"
ENV MISE_CONFIG_DIR="/mise"
ENV MISE_CACHE_DIR="/mise/cache"
ENV MISE_INSTALL_PATH="/usr/local/bin/mise"
ENV PATH="/mise/shims:$PATH"
# ENV MISE_VERSION="..."

RUN curl https://mise.run | sh
```

Note the pattern: shims on `PATH` (non-interactive by definition inside a container) and all mise dirs relocated to a single `/mise` root.

#### 9.3.2 Shared/system installs for multi-user containers

For toolbox containers, bastion hosts and — critically — **devcontainers that mount the user's home directory**, install into the system-wide directory ([mise-cookbook/docker#shared-tools-in-multi-user-containers](https://mise.jdx.dev/mise-cookbook/docker.html#shared-tools-in-multi-user-containers)):

```dockerfile
FROM debian:13-slim
# ... install mise ...
RUN mise install --system node@26 python@3.15
```

| Aspect | Behaviour |
|---|---|
| Install location | `/usr/local/share/mise/installs` |
| Discovery | every user's mise finds these automatically, no configuration needed |
| Priority | a user's own installs in `~/.local/share/mise/installs` take priority over system versions |
| Customize | `MISE_SYSTEM_DATA_DIR` changes the system directory |
| Extra dirs | `MISE_SHARED_INSTALL_DIRS` (`:`-separated on Unix, `;` on Windows) or the `shared_install_dirs` setting |

([mise-cookbook/docker](https://mise.jdx.dev/mise-cookbook/docker.html))

```sh
$ mise ls
node    26.0.0 (system)
python  3.15.0 (system)
```

**Why this matters for devcontainers:** devcontainers often mount the user's home directory, so tools pre-installed at build time into `~/.local/share/mise/installs` are hidden by the mount. `/usr/local/share/mise/installs` sits outside `~` and survives the mount ([mise-cookbook/docker#devcontainers-with-home-directory-mounts](https://mise.jdx.dev/mise-cookbook/docker.html#devcontainers-with-home-directory-mounts)).

Debian/Ubuntu via `extrepo` is also documented, with the caveat that **you cannot specify `MISE_VERSION` or `MISE_INSTALL_PATH`** with that approach ([mise-cookbook/docker](https://mise.jdx.dev/mise-cookbook/docker.html)):

```dockerfile
# syntax=docker/dockerfile:1
FROM debian:13-slim

RUN <<EOF
  set -ex
  apt-get update
  apt-get install -y extrepo
  extrepo enable mise
  apt-get remove -y --auto-remove extrepo # extrepo and its deps are not needed after extrepo enable
  apt-get update
  apt-get install -y mise build-essential
  rm -fr /var/lib/apt/lists/*
EOF

# Pre-install tools to the system-wide shared directory
RUN mise install --system node@26 python@3.15
```

#### 9.3.3 libc detection in minimal images

In `scratch`/`busybox`/distroless images no dynamic linker files exist and mise may fail to detect musl vs glibc ([mise-cookbook/docker#overriding-libc-detection](https://mise.jdx.dev/mise-cookbook/docker.html#overriding-libc-detection)):

```dockerfile
ENV MISE_LIBC=musl
RUN mise install
```

Valid values: `musl`, `glibc`, `gnu` (case-insensitive; `gnu` is treated as glibc). **Invalid values are silently ignored** and mise falls back to runtime detection. A musl-compiled mise binary (the default for Linux releases) also falls back to musl when no linker is detected ([mise-cookbook/docker](https://mise.jdx.dev/mise-cookbook/docker.html)).

#### 9.3.4 `mise generate devcontainer`

```
mise generate devcontainer [FLAGS]
```
Effect: **modifies state** ([cli/generate/devcontainer](https://mise.jdx.dev/cli/generate/devcontainer.html))

| Flag | Type | Meaning |
|---|---|---|
| `-i --image <IMAGE>` | string | Image to use for the devcontainer |
| `-m --mount-mise-data` | flag | Bind the `mise-data-volume` to the devcontainer |
| `-n --name <NAME>` | string | Name of the devcontainer |
| `-w --write` | flag | Write to `.devcontainer/devcontainer.json` |

Default output (verified by running `mise generate devcontainer` on mise 2026.7.17; defaults `name = "mise"` and `image = "mcr.microsoft.com/devcontainers/base:ubuntu"` come from [src/cli/generate/devcontainer.rs](https://github.com/jdx/mise/blob/main/src/cli/generate/devcontainer.rs)):

```json
{
  "name": "mise",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers-extra/features/mise:1": {}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "hverlin.mise-vscode"
      ]
    }
  },
  "mounts": [],
  "containerEnv": {},
  "remoteEnv": {}
}
```

With `--mount-mise-data`, the generator adds a named volume plus the env wiring and an ownership fix-up ([src/cli/generate/devcontainer.rs](https://github.com/jdx/mise/blob/main/src/cli/generate/devcontainer.rs)):

```json
{
  "mounts": [
    { "source": "mise-data-volume", "target": "/mnt/mise-data", "type": "volume" }
  ],
  "containerEnv": { "MISE_DATA_DIR": "/mnt/mise-data" },
  "remoteEnv": { "PATH": "${containerEnv:PATH}:/mnt/mise-data/shims" },
  "postCreateCommand": "sudo chown -R vscode:vscode /mnt/mise-data"
}
```

With `--write`, the file is written to `<git root>/.devcontainer/devcontainer.json`, falling back to `<cwd>/.devcontainer/devcontainer.json` when not in a git repo ([src/cli/generate/devcontainer.rs](https://github.com/jdx/mise/blob/main/src/cli/generate/devcontainer.rs)).

#### 9.3.5 Reproducing mise issues in a clean container

```toml
[tasks.docker]
run = "docker run -it --rm debian-mise"
```

```sh
❯ mise docker
[docker] $ docker run -it --rm debian-mise
root@75f179a190a1:/# eval "$(mise activate bash)"
# overwrite configuration and prune to give us a clean state
root@75f179a190a1:/# echo "" > /mise/config.toml
root@75f179a190a1:/# mise prune --yes
```

([mise-cookbook/docker#task-to-run-mise-in-a-docker-container](https://mise.jdx.dev/mise-cookbook/docker.html#task-to-run-mise-in-a-docker-container))

---

### 9.4 IDE integration

#### 9.4.1 Why IDEs need special handling

Editors either inherit the environment from the shell that launched them (`nvim .`, `code .`) or have [their own way](https://github.com/microsoft/vscode-docs/blob/906acccd6180d8425577f8297ed29e221ad3daca/docs/supporting/faq.md?plain=1#L238) of setting up an environment. Once launched, an IDE **will not reload** the env vars or `PATH` mise provides when you edit your mise config — so `mise activate` cannot be relied on ([ide-integration](https://mise.jdx.dev/ide-integration.html)).

Four documented strategies, in rough order of preference ([ide-integration](https://mise.jdx.dev/ide-integration.html)):

1. Native mise support in the editor/plugin (select the tool/SDK path from IDE settings) — gives you the binaries but **not** the env vars.
2. **Add the mise shims dir to `PATH`** — most editors and language plugins look for tools on `PATH`; this runs the mise-provided tool *and* loads env vars (because a shim was executed).
3. Manually point IDE settings at a path from [`mise which <tool>`](https://mise.jdx.dev/cli/which.html) or [`mise where`](https://mise.jdx.dev/cli/where.html). Prefer supplying the **shim** path (e.g. `~/.local/share/mise/shims/node`) if the plugin accepts it, since that also loads env vars.
4. Use a community plugin (below).

#### 9.4.2 The shims-in-login-profile approach (the general answer)

Find your default shell:

```sh
# macOS
dscl . -read /Users/$USER UserShell
# Linux
getent passwd $USER | cut -d: -f7
```

Change it with `chsh -s /path/to/shell` (you may need to add it to `/etc/shells` first). Then modify the login/profile script ([ide-integration#adding-shims-to-path-default-shell](https://mise.jdx.dev/ide-integration.html#adding-shims-to-path-default-shell)):

```zsh
# ~/.zprofile
eval "$(mise activate zsh --shims)"
```

```bash
# ~/.bash_profile or ~/.bash_login or ~/.profile
eval "$(mise activate bash --shims)"
```

```fish
# ~/.config/fish/config.fish
if status is-interactive
  mise activate fish | source
else
  mise activate fish --shims | source
end
```

> **Warning (verbatim from the docs):** Do not use `/bin/bash` or `/usr/bin/bash` on macOS. bash is complicated, decades old, and mise isn't able to use as many features. Unless you consider yourself an expert on bash and know why I (and Apple for that matter) admonish using bash, just use zsh on macOS. ([ide-integration](https://mise.jdx.dev/ide-integration.html))

Two more caveats ([ide-integration](https://mise.jdx.dev/ide-integration.html)):

- On Linux the login profile is read at machine login, so you must log out and back in.
- The snippets assume `mise` is on `PATH`; if not, use an absolute path — `eval "$($HOME/.local/bin/mise activate zsh --shims)"`.
- Shims don't cover everything: arbitrary env vars in `[env]` are only set when a shim is executed. Tighter integration requires an IDE plugin.

#### 9.4.3 JetBrains (IntelliJ, RustRover, PyCharm, WebStorm, RubyMine, GoLand, …)

| Option | How |
|---|---|
| Plugin | [intellij-mise](https://github.com/134130/intellij-mise) — auto-configures the IDE to use mise tools, plus some support for running mise tasks and loading env vars in run configurations |
| Direct SDK selection | Some JetBrains IDEs / language plugins support mise natively; pick the SDK version from IDE settings |
| asdf-layout workaround | For plugins that only know asdf, symlink the mise dir (same layout as asdf) |
| Fallback | shims on `PATH` via the login profile (§9.4.2) |

```sh
ln -s ~/.local/share/mise ~/.asdf
```

Tools then appear in Project Settings, or for node (and possibly other languages) under "Languages & Frameworks" ([ide-integration#jetbrains-editors-intellij-rustrover-pycharm-webstorm-rubymine-goland-etc](https://mise.jdx.dev/ide-integration.html#jetbrains-editors-intellij-rustrover-pycharm-webstorm-rubymine-goland-etc)).

#### 9.4.4 VS Code

**macOS automation profile.** Unlike Linux, macOS does not read the login shell profile (`~/.profile`, `~/.zprofile`) at machine login, so VS Code needs to be told to use a login shell ([ide-integration#vscode-automation-profile-for-macos](https://mise.jdx.dev/ide-integration.html#vscode-automation-profile-for-macos)):

```json
    "terminal.integrated.automationProfile.osx": {
        "path": "/usr/bin/zsh",
        "args": ["--login"]
    }
```

Tip from the docs: use `["--login", "--interactive"]` if you also want `~/.zshrc`.

**Plugin.** [mise-vscode](https://marketplace.visualstudio.com/items?itemName=hverlin.mise-vscode) ([repo](https://github.com/hverlin/mise-vscode/), [docs](https://hverlin.github.io/mise-vscode/)) avoids the shell-profile edit entirely and adds ([ide-integration#vscode-plugin](https://mise.jdx.dev/ide-integration.html#vscode-plugin)):

- Automatic configuration of other extensions to use mise-provided tools
- Manage mise tasks, tools and env vars from VS Code
- Load env vars from `mise.toml` files
- Autocompletion and snippets for `mise.toml`
- Integration with VS Code tasks

**Per-launch-config approach** using [`mise exec`](https://mise.jdx.dev/cli/exec.html) in `launch.json` ([ide-integration#use-mise-exec-in-launch-configuration](https://mise.jdx.dev/ide-integration.html#use-mise-exec-in-launch-configuration)):

```json
{
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Launch Program",
      "program": "${file}",
      "args": [],
      "osx": {
        "runtimeExecutable": "mise"
      },
      "linux": {
        "runtimeExecutable": "mise"
      },
      "runtimeArgs": ["exec", "--", "node"]
    }
  ]
}
```

#### 9.4.5 Vim & Neovim

```vim
" Prepend mise shims to PATH
let $PATH = $HOME . '/.local/share/mise/shims:' . $PATH
```

```lua
-- Prepend mise shims to PATH
vim.env.PATH = vim.env.HOME .. "/.local/share/mise/shims:" .. vim.env.PATH
```

([ide-integration#vim](https://mise.jdx.dev/ide-integration.html#vim), [ide-integration#neovim](https://mise.jdx.dev/ide-integration.html#neovim))

For Treesitter/LSP integration there is a dedicated [Neovim cookbook](https://mise.jdx.dev/mise-cookbook/neovim.html) covering:

| Feature | Mechanism |
|---|---|
| Syntax highlighting for `run` command bodies in `mise.toml` | Treesitter injection queries in `after/queries/toml/injections.scm`, gated by a custom `is-mise?` predicate that matches filenames like `.*mise.*%.toml$` |
| Highlighting of `#MISE` (TOML) and `#USAGE` (KDL) comments in file tasks | Injection queries in `after/queries/bash/injections.scm`; the same queries work for any `#`-comment language (copy into `after/queries/python/injections.scm`, etc.), with a `//`-comment variant provided |
| LSP + completion for embedded languages in `run` commands | [otter.nvim](https://github.com/jmbuhr/otter.nvim), activated on `FileType toml`; **requires the injection queries above** |

([mise-cookbook/neovim](https://mise.jdx.dev/mise-cookbook/neovim.html))

The `is-mise?` predicate, registered via lazy.nvim ([mise-cookbook/neovim#run-commands](https://mise.jdx.dev/mise-cookbook/neovim.html#run-commands)):

```lua
{
  "nvim-treesitter/nvim-treesitter",
  init = function()
    require("vim.treesitter.query").add_predicate("is-mise?", function(_, _, bufnr, _)
      local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
      local filename = vim.fn.fnamemodify(filepath, ":t")
      return string.match(filename, ".*mise.*%.toml$") ~= nil
    end, { force = true, all = false })
  end,
},
```

> Note for Neovim ≥ 0.12: the docs recommend the multi-node pattern (`((comment)+ @injection.content …)`) instead of `(#set! injection.combined)`, because combined injections have [multiple limitations](https://github.com/neovim/neovim/issues/32635) ([mise-cookbook/neovim](https://mise.jdx.dev/mise-cookbook/neovim.html)).

#### 9.4.6 Emacs

Traditional shims approach ([ide-integration#emacs](https://mise.jdx.dev/ide-integration.html#emacs)):

```lisp
;; CLI tools installed by Mise
;; See: https://www.emacswiki.org/emacs/ExecPath
(setenv "PATH" (concat (getenv "PATH") ":/home/user/.local/share/mise/shims"))
(setq exec-path (append exec-path '("/home/user/.local/share/mise/shims")))
```

Or [mise.el](https://github.com/eki3z/mise.el), which sets per-directory/per-project env vars on a per-buffer basis ([ide-integration#use-with-package-mise-el](https://mise.jdx.dev/ide-integration.html#use-with-package-mise-el)):

```lisp
(require 'mise)
(add-hook 'after-init-hook #'global-mise-mode)
```

> **Note:** the IDE Plugins list links Emacs support as [liuyinz/mise.el](https://github.com/liuyinz/mise.el) while the Emacs section links [eki3z/mise.el](https://github.com/eki3z/mise.el) ([ide-integration](https://mise.jdx.dev/ide-integration.html)). Both appear on the same page.

#### 9.4.7 Xcode

Xcode can run system commands from script build phases and schemes, but it sandboxes script execution via `/usr/bin/sandbox-exec`, so mise and auto-activated tools do **not** work out of the box ([ide-integration#xcode](https://mise.jdx.dev/ide-integration.html#xcode)).

Required steps:

1. Add `$(SRCROOT)/mise.toml` to the build phase's list of **Input files** — necessary for Xcode to permit reads of that file.
2. Activate with shims and an explicit config root:

```bash
# -C ensures that Mise loads the configuration from the Mise configuration
# file in the project's root directory.
eval "$($HOME/.local/bin/mise activate -C $SRCROOT bash --shims)"

swiftlint
```

([ide-integration#xcode](https://mise.jdx.dev/ide-integration.html#xcode))

#### 9.4.8 Zed

> **Uncertainty:** the mise documentation does not mention Zed on the [IDE Integration](https://mise.jdx.dev/ide-integration.html) page (the enumerated editors are Emacs, IntelliJ/JetBrains, VS Code, Vim, Neovim, and Xcode) and no Zed plugin is listed under [IDE Plugins](https://mise.jdx.dev/ide-integration.html#ide-plugins). The documented generic path applies: put the shims directory on `PATH` from your **login/profile** script (§9.4.2), or point Zed's tool/LSP settings at a shim path obtained from [`mise which <tool>`](https://mise.jdx.dev/cli/which.html) / [`mise where`](https://mise.jdx.dev/cli/where.html), so env vars are loaded when the shim runs ([ide-integration](https://mise.jdx.dev/ide-integration.html)).

#### 9.4.9 IDE plugin summary

| Editor | Plugin | Source |
|---|---|---|
| Emacs | `mise.el` | [liuyinz/mise.el](https://github.com/liuyinz/mise.el) / [eki3z/mise.el](https://github.com/eki3z/mise.el) |
| IntelliJ / JetBrains | `intellij-mise` | [134130/intellij-mise](https://github.com/134130/intellij-mise) |
| VS Code | `mise-vscode` | [hverlin/mise-vscode](https://github.com/hverlin/mise-vscode) |

([ide-integration#ide-plugins](https://mise.jdx.dev/ide-integration.html#ide-plugins))

---

### 9.5 MCP server (`mise mcp`)

> **Experimental.** "The MCP feature is experimental and requires enabling experimental features with `MISE_EXPERIMENTAL=1`." ([mcp](https://mise.jdx.dev/mcp.html))

```
mise mcp
```
Runs a Model Context Protocol server that speaks **JSON-RPC 2.0 over stdin/stdout** ([cli/mcp](https://mise.jdx.dev/cli/mcp.html), [mcp](https://mise.jdx.dev/mcp.html)). It is normally launched by the AI client, but can be run manually for testing:

```bash
# Enable experimental features
export MISE_EXPERIMENTAL=1

# Start the MCP server (it will wait for JSON-RPC input on stdin)
mise mcp
```

#### Resources exposed (read-only)

| URI | Contents |
|---|---|
| `mise://tools` | All tools managed by mise in the project: names and versions, installation status, configuration source. Accepts `?include_inactive=true` to include inactive/all installed tools |
| `mise://tasks` | All tasks: names and descriptions, dependencies, command definitions |
| `mise://env` | Environment variables from mise config: names and values, environment-specific overrides |
| `mise://config` | Active configuration files, project root directory, settings and preferences |

([mcp#available-resources](https://mise.jdx.dev/mcp.html#available-resources), [cli/mcp](https://mise.jdx.dev/cli/mcp.html))

#### Tools exposed (callable)

| Tool | Params | Status |
|---|---|---|
| `list_commands` | `{"include_hidden": false}` | Every mise command, with its declared effect on the world |
| `install_tool` | – | Install a tool with an optional version — **not yet implemented** |
| `run_task` | `task` (required, string), `args` (optional, array of strings) | Executes the task; returns stdout, stderr and exit status |

([cli/mcp](https://mise.jdx.dev/cli/mcp.html), [mcp#available-tools](https://mise.jdx.dev/mcp.html#available-tools))

```json
{
  "task": "build",
  "args": ["--verbose"]
}
```

> Note: `list_commands` is documented on the [CLI page](https://mise.jdx.dev/cli/mcp.html) but is not listed in the "Available Tools" section of the [MCP guide](https://mise.jdx.dev/mcp.html) — the CLI page is the more recent/complete of the two.

#### Wiring it into an AI client

Claude Desktop config file locations ([mcp#claude-desktop](https://mise.jdx.dev/mcp.html#claude-desktop)):

| OS | Path |
|---|---|
| macOS | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| Windows | `%APPDATA%\Claude\claude_desktop_config.json` |
| Linux | `~/.config/claude/claude_desktop_config.json` |

```json
{
  "mcpServers": {
    "mise": {
      "command": "mise",
      "args": ["mcp"],
      "env": {
        "MISE_EXPERIMENTAL": "1"
      }
    }
  }
}
```

([mcp#claude-desktop](https://mise.jdx.dev/mcp.html#claude-desktop))

> The [CLI reference](https://mise.jdx.dev/cli/mcp.html) shows the same snippet with `"env": {}`. Since the feature is gated on experimental mode, prefer the `"MISE_EXPERIMENTAL": "1"` form from the guide unless experimental is already enabled globally.

Any MCP-capable client works, since the transport is standard JSON-RPC 2.0 over stdio — the docs name Claude and Cursor explicitly ([cli/mcp](https://mise.jdx.dev/cli/mcp.html), [mcp#other-ai-assistants](https://mise.jdx.dev/mcp.html#other-ai-assistants)).

Manual smoke test ([cli/mcp](https://mise.jdx.dev/cli/mcp.html)):

```sh
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' | mise mcp
```

Implementation: [src/cli/mcp.rs](https://github.com/jdx/mise/blob/main/src/cli/mcp.rs), implementing the `ServerHandler` trait from the `rmcp` crate ([mcp#technical-details](https://mise.jdx.dev/mcp.html#technical-details)).

---

### 9.6 Shell completions

```
mise completion [--include-bash-completion-lib] [SHELL]
```
Effect: **read-only**. Shell choices: `bash`, `fish`, `powershell`, `zsh` ([cli/completion](https://mise.jdx.dev/cli/completion.html)).

| Flag | Meaning |
|---|---|
| `--include-bash-completion-lib` | Include the bash completion library in the bash script. **Required for completions to work in bash**, but not included by default; you may source it separately instead. |

**Prerequisite:** `mise completion` requires [`usage`](https://usage.jdx.dev) to be installed ([installing-mise#autocompletion](https://mise.jdx.dev/installing-mise.html#autocompletion)):

```sh
mise use -g usage
```

Some installation methods install completion scripts automatically ([installing-mise#autocompletion](https://mise.jdx.dev/installing-mise.html#autocompletion)).

| Shell | Install command |
|---|---|
| bash | `mkdir -p ~/.local/share/bash-completion/completions/` then `mise completion bash --include-bash-completion-lib > ~/.local/share/bash-completion/completions/mise` (requires `bash-completion` installed) |
| zsh | `mise completion zsh > /usr/local/share/zsh/site-functions/_mise` — or find a suitable dir with `echo $fpath \| tr ' ' '\n'`; `mkdir -p /usr/local/share/zsh/site-functions` first if needed |
| fish | `mise completion fish > ~/.config/fish/completions/mise.fish` |
| powershell | `mise completion powershell >> $PROFILE` |

([installing-mise#autocompletion](https://mise.jdx.dev/installing-mise.html#autocompletion), [cli/completion](https://mise.jdx.dev/cli/completion.html))

Then source your shell's rc file or restart the shell ([installing-mise#autocompletion](https://mise.jdx.dev/installing-mise.html#autocompletion)).

Zinit users can wire mise + usage + completions in one go ([tips-and-tricks#installation-via-zsh-zinit](https://mise.jdx.dev/tips-and-tricks.html#installation-via-zsh-zinit)):

```sh
zinit as="command" lucid from="gh-r" for \
    id-as="usage" \
    atpull="%atclone" \
    jdx/usage
    #atload='eval "$(mise activate zsh)"' \

zinit as="command" lucid from="gh-r" for \
    id-as="mise" mv="mise* -> mise" \
    atclone="./mise* completion zsh > _mise" \
    atpull="%atclone" \
    atload='eval "$(mise activate zsh)"' \
    jdx/mise
```

---

### 9.7 Generators (`mise generate …`)

`mise generate` — "Generate files for various tools/services" ([cli/generate](https://mise.jdx.dev/cli/generate.html)).

| Subcommand | Purpose |
|---|---|
| `bootstrap` | Generate a script to download+execute mise ([cli/generate/bootstrap](https://mise.jdx.dev/cli/generate/bootstrap.html)) |
| `config` | Generate a `mise.toml` file ([cli/generate/config](https://mise.jdx.dev/cli/generate/config.html)) |
| `devcontainer` | Generate a devcontainer to execute mise ([cli/generate/devcontainer](https://mise.jdx.dev/cli/generate/devcontainer.html)) |
| `git-pre-commit` | Generate a git pre-commit hook ([cli/generate/git-pre-commit](https://mise.jdx.dev/cli/generate/git-pre-commit.html)) |
| `github-action` | Generate a GitHub Action workflow file ([cli/generate/github-action](https://mise.jdx.dev/cli/generate/github-action.html)) |
| `task-docs` | Generate documentation for tasks in a project ([cli/generate/task-docs](https://mise.jdx.dev/cli/generate/task-docs.html)) |
| `task-stubs` | Generate shims to run mise tasks ([cli/generate/task-stubs](https://mise.jdx.dev/cli/generate/task-stubs.html)) |
| `tool-stub` | Generate a tool stub for HTTP-based tools ([cli/generate/tool-stub](https://mise.jdx.dev/cli/generate/tool-stub.html)) |

#### 9.7.1 `mise generate github-action`

Generates a workflow that runs a mise task (e.g. `mise run ci`) on push ([cli/generate/github-action](https://mise.jdx.dev/cli/generate/github-action.html)). Effect: modifies state.

| Flag | Default | Meaning |
|---|---|---|
| `-t --task <TASK>` | `ci` | The task to run when the workflow is triggered |
| `--name <NAME>` | `ci` | The name of the workflow to generate |
| `-w --write` | – | Write to `.github/workflows/$name.yml` |

```
mise generate github-action --write --task=ci
git commit -m "feat: add new feature"
git push # runs `mise run ci` on GitHub
```

#### 9.7.2 `mise generate git-pre-commit`

Alias: `pre-commit`. Effect: modifies state. **Staged files are passed to the task as `STAGED`.** For more advanced pre-commit functionality the docs point at mise's sister project [hk](https://hk.jdx.dev/) ([cli/generate/git-pre-commit](https://mise.jdx.dev/cli/generate/git-pre-commit.html)).

| Flag | Default | Meaning |
|---|---|---|
| `-t --task <TASK>` | `pre-commit` | Task to run when the hook fires |
| `--hook <HOOK>` | `pre-commit` | Which hook to generate (saves to `.git/hooks/$hook`) |
| `-w --write` | – | Write to `.git/hooks/pre-commit` and make it executable |

```
mise generate git-pre-commit --write --task=pre-commit
git commit -m "feat: add new feature" # runs `mise run pre-commit`
```

#### 9.7.3 `mise generate task-stubs`

Builds `./bin/<task>` shims so contributors can run mise tasks without installing mise ([cli/generate/task-stubs](https://mise.jdx.dev/cli/generate/task-stubs.html)). Effect: modifies state.

| Flag | Default | Meaning |
|---|---|---|
| `-d --dir <DIR>` | `bin` | Directory to create task stubs inside of |
| `-m --mise-bin <MISE_BIN>` | `mise` | Path to a mise bin used when running the stub; use `--mise-bin=./bin/mise` to pair with `mise generate bootstrap` |

```
$ mise tasks add test -- echo 'running tests'
$ mise generate task-stubs
$ ./bin/test
running tests
```

Pairing bootstrap + task-stubs gives you a fully self-contained project entrypoint ([tips-and-tricks#project-local-task-entrypoints](https://mise.jdx.dev/tips-and-tricks.html#project-local-task-entrypoints)):

```sh
mkdir -p bin
mise generate bootstrap --localize --write bin/mise
mise generate task-stubs --mise-bin ./bin/mise
./bin/test
```

---

### 9.8 Housekeeping commands

#### 9.8.1 `mise cache`

```
mise cache <SUBCOMMAND>
```
Effect: read-only. Running `mise cache` with no args shows the current cache directory ([cli/cache](https://mise.jdx.dev/cli/cache.html)).

| Subcommand | Aliases | Effect | Notes |
|---|---|---|---|
| `mise cache clear [TOOL]…` | `c` | modifies state | Deletes all cache files in mise; optional tool filter (e.g. `node`, `python`) ([cli/cache/clear](https://mise.jdx.dev/cli/cache/clear.html)) |
| `mise cache path` | `dir` | read-only | Show the cache directory path ([cli/cache/path](https://mise.jdx.dev/cli/cache/path.html)) |
| `mise cache prune [-v --verbose…] [--dry-run] [TOOL]…` | `p` | modifies state | Removes stale cache files — by default those not accessed in **30 days**, configurable via `MISE_CACHE_PRUNE_AGE`. `-v` shows pruned files, `--dry-run` just reports ([cli/cache/prune](https://mise.jdx.dev/cli/cache/prune.html)) |

`mise cache clear` is the "use fresh data" button when mise isn't noticing a new release — it "basically just runs `rm -rf ~/.cache/mise/*`" ([tips-and-tricks#mise-cache-clear](https://mise.jdx.dev/tips-and-tricks.html#mise-cache-clear)).

Related setting: `cache_prune_age` (`MISE_CACHE_PRUNE_AGE`, `string`, default `30d`) — the age before a cache file is considered stale; mise occasionally deletes files not accessed within it. **Set to `0s` to keep cache files indefinitely** ([settings#cache_prune_age](https://mise.jdx.dev/configuration/settings.html#cache_prune_age)).

What's actually in the cache: per-tool/backend caches at `~/$MISE_CACHE_DIR/<TOOL>` holding the remote version list (`mise ls-remote <TOOL>`), idiomatic filenames, aliases, bin directories per installation, and the result of `exec-env`. Remote versions refresh daily by default; the file format is zlib messagepack ([cache-behavior#tool-cache](https://mise.jdx.dev/cache-behavior.html#tool-cache)).

#### 9.8.2 `mise implode`

```
mise implode [-n --dry-run] [--config]
```
Effect: **destructive — may delete or irreversibly overwrite**. Removes the mise CLI and all related data. **Skips the config directory by default** ([cli/implode](https://mise.jdx.dev/cli/implode.html)).

| Flag | Meaning |
|---|---|
| `-n --dry-run` | List directories that would be removed without removing them |
| `--config` | Also remove the config directory |

#### 9.8.3 `mise self-update`

```
mise self-update [FLAGS] [VERSION]
```
Effect: modifies state. Uses the GitHub Releases API to find the latest release and binary. **By default it also updates any installed plugins.** Uses mise's GitHub token resolution chain for authenticated requests ([cli/self-update](https://mise.jdx.dev/cli/self-update.html)).

| Arg/Flag | Meaning |
|---|---|
| `[VERSION]` | Update to a specific version |
| `-f --force` | Update even if already up to date |
| `-y --yes` | Skip confirmation prompt |
| `--no-plugins` | Disable auto-updating plugins |

> **Packaging gotcha:** packagers can *disable* this command so that mise is updated through the package manager instead — see the [packaging and self-update instructions](https://mise.jdx.dev/contributing.html#packaging-and-self-update-instructions) ([cli/self-update](https://mise.jdx.dev/cli/self-update.html)). Relevant if you installed via Homebrew/apt/etc.

#### 9.8.4 `mise deactivate`

```
mise deactivate
```
Effect: read-only. Disables mise for the current shell session — for temporarily turning mise off ([cli/deactivate](https://mise.jdx.dev/cli/deactivate.html)).

#### 9.8.5 `mise bin-paths`

```
mise bin-paths [--bin-names] [-J --json] [TOOL@VERSION]…
```
Effect: read-only. Lists all the active runtime bin paths ([cli/bin-paths](https://mise.jdx.dev/cli/bin-paths.html)).

| Arg/Flag | Meaning |
|---|---|
| `[TOOL@VERSION]…` | Tool(s) to look up, e.g. `ruby@3` |
| `--bin-names` | Output executable **names** instead of bin directories |
| `-J --json` | Output executable entries in JSON format (**implies `--bin-names`**) |

#### 9.8.6 `mise version`

```
mise version [-J --json]
```
Alias: `v`. Effect: read-only. Displays version, os, architecture and build date. **If the version is out of date it prints a warning** ([cli/version](https://mise.jdx.dev/cli/version.html)).

```
mise version
mise --version
mise -v
mise -V
```

| Flag | Meaning |
|---|---|
| `-J --json` | Print version information as JSON |

#### 9.8.7 `mise en`

```
mise en [-s --shell <SHELL>] [DIR]
```
Starts a **new shell** with the mise environment built from the current configuration — an explicit alternative to `mise activate`. Tools and env vars from the configs are loaded. **Changing directories inside that shell will not update the mise environment** ([cli/en](https://mise.jdx.dev/cli/en.html)).

| Arg/Flag | Default | Meaning |
|---|---|---|
| `[DIR]` | `.` | Directory to start the shell in |
| `-s --shell <SHELL>` | `$SHELL` | Shell to start |

```
$ mise en .
$ node -v
v20.0.0

Skip loading bashrc:
$ mise en -s "bash --norc"

Skip loading zshrc:
$ mise en -s "zsh -f"
```

`mise en` is recommended "if you don't want to always be using mise" — it sets up the environment in the current directory once and does not keep running ([tips-and-tricks#mise-en](https://mise.jdx.dev/tips-and-tricks.html#mise-en)).

#### 9.8.8 Cross-reference: settings

`mise settings` and its `add`/`get`/`ls`/`set`/`unset` subcommands are the interface to everything in [Settings](https://mise.jdx.dev/configuration/settings.html); `-l --local` targets the local config ([cli/settings](https://mise.jdx.dev/cli/settings.html), [cli/settings/set](https://mise.jdx.dev/cli/settings/set.html)). Full settings coverage belongs to the configuration section of this guide.

---

### 9.9 Tips & tricks worth knowing

([tips-and-tricks](https://mise.jdx.dev/tips-and-tricks.html) unless otherwise noted)

#### Shebangs — mise without any config file

```typescript
#!/usr/bin/env -S mise x node@20 -- node
// "env -S" allows multiple arguments in a shebang
console.log(`Running node: ${process.version}`);
```

Useful precisely in environments where mise isn't activated, such as non-interactive sessions ([tips-and-tricks#shebang](https://mise.jdx.dev/tips-and-tricks.html#shebang)).

#### Commit the bootstrap script rather than curl-ing dynamically

```sh
curl https://mise.run > setup-mise.sh
chmod +x setup-mise.sh
./setup-mise.sh
```

The file contains checksums, so committing it is more secure than calling `curl https://mise.run` at runtime — at the cost of pinning to the mise version current when the script was created ([tips-and-tricks#bootstrap-script](https://mise.jdx.dev/tips-and-tricks.html#bootstrap-script)).

#### `mise run` shorthand

As long as the task name doesn't collide with a mise command, `mise test` works instead of `mise run test`. **Don't use this inside scripts** — mise may add a conflicting command in a future version ([tips-and-tricks#mise-run-shorthand](https://mise.jdx.dev/tips-and-tricks.html#mise-run-shorthand)).

#### Auto-install on entering a project

```toml
[hooks]
enter = "mise i -q"
```

([tips-and-tricks#auto-install-when-entering-a-project](https://mise.jdx.dev/tips-and-tricks.html#auto-install-when-entering-a-project)) — note this requires `mise activate`, since `enter` hooks don't fire under shims ([dev-tools/shims#hooks-and-shims](https://mise.jdx.dev/dev-tools/shims.html#hooks-and-shims)).

#### `mise watch` for edit loops

```sh
mise use -g watchexec@latest
mise watch test
mise watch --restart dev   # for long-running processes
```

`mise watch` is backed by `watchexec`, which you can install with mise itself ([tips-and-tricks#watch-tasks-while-editing](https://mise.jdx.dev/tips-and-tricks.html#watch-tasks-while-editing)).

#### Redact secrets from task output (CI-critical)

```toml
redactions = ["API_KEY", "PASSWORD"]
```

Glob patterns work too:

```toml
redactions = ["SECRETS_*"]
```

Listed env vars are replaced with `[redacted]` in task output ([tips-and-tricks#redact-secrets-from-task-output](https://mise.jdx.dev/tips-and-tricks.html#redact-secrets-from-task-output)).

#### `mise up --bump`

Upgrades all software to the latest version **and updates `mise.toml` files**, keeping the same semver range shape: `node = "24"` becomes `node = "26"` ([tips-and-tricks#mise-up-bump](https://mise.jdx.dev/tips-and-tricks.html#mise-up-bump)).

#### `cargo-binstall` makes `cargo:` tools much faster

mise uses it automatically for `cargo:` tools when installed ([tips-and-tricks#cargo-binstall](https://mise.jdx.dev/tips-and-tricks.html#cargo-binstall)):

```sh
mise use -g cargo-binstall
```

#### Debugging config precedence with `mise cfg`

```sh
❯ mise cfg
Path                                    Tools
~/.config/mise/config.toml              (none)
~/.mise/config.toml                     (none)
~/src/mise.toml                         (none)
~/src/mise/.config/mise/conf.d/foo.toml (none)
~/src/mise/mise.toml                    actionlint, bun, cargo-binstall, cargo:…
~/src/mise/mise.local.toml              (none)
```

Shows load order, which is how you figure out what is overriding what ([tips-and-tricks#mise-cfg](https://mise.jdx.dev/tips-and-tricks.html#mise-cfg)).

#### `mise tool <TOOL>` for backend introspection

```sh
❯ mise tool ripgrep
Backend:            aqua:BurntSushi/ripgrep
Installed Versions: 14.1.1
Active Version:     14.1.1
Requested Version:  latest
Config Source:      ~/src/mise/mise.toml
Tool Options:       [none]
```

([tips-and-tricks#mise-tool-tool](https://mise.jdx.dev/tips-and-tricks.html#mise-tool-tool))

#### Reading unsupported version files with Tera

```toml
[tools]
hugo = "{{ read_file(path='.hvm') | trim }}"
```

```toml
[tools]
hugo-extended = "{{ read_file(path='.hvm') | trim | replace(from='/extended', to='') }}"
```

Note the second form: HVM supports an `/extended` suffix, but in mise Hugo and Hugo Extended are separate tools ([tips-and-tricks#using-tera-to-read-unsupported-version-files](https://mise.jdx.dev/tips-and-tricks.html#using-tera-to-read-unsupported-version-files)). **These templates call `read_file()`, which safe mode refuses** ([security#safe-mode](https://mise.jdx.dev/security.html#safe-mode)).

#### Share task catalogs across repos

```toml
[task_config]
includes = [
  "mise-tasks",
  "tasks.toml",
  "git::https://github.com/myorg/shared-tasks.git//tasks?ref=v1.0.0",
]
```

Included `tasks.toml` files use the same shape as `[tasks]` without the `[tasks.]` prefix ([tips-and-tricks#share-task-catalogs](https://mise.jdx.dev/tips-and-tricks.html#share-task-catalogs)).

#### Task templates (experimental)

> Requires `experimental = true`.

```toml
[settings]
experimental = true

[task_templates."node:test"]
tools = { node = "24", pnpm = "latest" }
run = "pnpm test"

[tasks.test]
extends = "node:test"
run = "pnpm test -- --watch=false"
```

Especially useful in monorepos where packages need similar build/test/lint tasks with small local overrides ([tips-and-tricks#reuse-task-definitions-with-templates](https://mise.jdx.dev/tips-and-tricks.html#reuse-task-definitions-with-templates), [tasks/templates](https://mise.jdx.dev/tasks/templates.html)).

#### `mise set` instead of hand-editing env vars

```sh
mise set NODE_ENV=production
```

([tips-and-tricks#mise-set](https://mise.jdx.dev/tips-and-tricks.html#mise-set))

#### macOS Rosetta / x86_64 tools on Apple Silicon

To run tools as x86_64 on Apple Silicon (e.g. to compile node ≤ 14) you need an **x86_64 build of mise itself**, either via the [`MISE_ARCH`](https://mise.jdx.dev/configuration/settings.html#arch) setting or a dedicated binary ([tips-and-tricks#macos-rosetta](https://mise.jdx.dev/tips-and-tricks.html#macos-rosetta)):

```sh
$ curl https://mise.run | MISE_INSTALL_PATH=~/.local/bin/mise-x64 MISE_INSTALL_ARCH=x64 sh
$ ~/.local/bin/mise-x64 --version
mise 2024.x.x
$ mise-x64 use -g node@20
```

#### Machine bootstrapping

`mise bootstrap` converges an entire workstation in one command, in a fixed order: **system packages → repos → dotfiles → shell activation → macOS defaults → LaunchAgents → systemd user services → login shell → tools → a `bootstrap` task** ([tips-and-tricks#machine-bootstrapping](https://mise.jdx.dev/tips-and-tricks.html#machine-bootstrapping)).

```toml
[bootstrap.packages]                      # OS packages (apk/apt/dnf/pacman/brew)
"apk:build-base" = "latest"
"apt:build-essential" = "latest"
"brew:postgresql@17" = "latest"

[bootstrap.repos]                         # git repos cloned before dotfiles
"~/src/dotfiles" = { url = "git@github.com:jdx/dotfiles.git", ref = "main" }

[dotfiles]                             # dotfiles: symlink/copy/template
"~/.gitconfig" = { mode = "symlink" }
"~/.config/nvim" = { mode = "symlink" }

[bootstrap.mise_shell_activate]       # mise activation in shell startup files
zprofile = "shims"
zshrc = "activate"
fish = "activate"

[bootstrap.macos.dock]                 # friendly macOS defaults
autohide = true
orientation = "left"

[bootstrap.macos.finder]
show_pathbar = true

[bootstrap.macos.launchd.agents.my-sync]      # macOS user LaunchAgents
program = "~/.local/bin/my-sync"
run_at_load = true

[bootstrap.linux.systemd.units.my-sync]       # Linux systemd user services
exec_start = "~/.local/bin/my-sync --watch"
restart = "on-failure"

[bootstrap.user]                       # current user's login shell
login_shell = "/bin/zsh"

[bootstrap.hooks.post-defaults]        # optional phase hooks
run = "killall Dock || true"

[tasks.bootstrap]                      # anything else, with tools on PATH
run = "gh auth status || gh auth login"
```

```sh
mise bootstrap --yes   # new laptop or container -> ready to work
```

Everything is declarative and idempotent; re-running skips whatever is already in its desired state. `mise bootstrap packages status --missing` and `mise bootstrap dotfiles status --missing` make **CI checks**. The exceptions are `[bootstrap.hooks]` and `[tasks.bootstrap]`, which are imperative and **should be treated as non-idempotent** unless written to converge safely ([tips-and-tricks#machine-bootstrapping](https://mise.jdx.dev/tips-and-tricks.html#machine-bootstrapping)). Note the `[bootstrap.mise_shell_activate]` block encodes exactly the shims-in-profile / activate-in-rc split from §9.4.2 ([bootstrap/shell](https://mise.jdx.dev/bootstrap/shell.html)).

---

### 9.10 External resources

Curated third-party articles, talks and sister projects ([external-resources](https://mise.jdx.dev/external-resources.html)):

| Date | Resource |
|---|---|
| 2025-04-09 | Keeping your Swift apps' sensitive data secret — <https://tuist.dev/blog/2025/04/09/secrets> |
| 2025-02-17 | **hk** — git hook manager that pairs well with mise — <https://hk.jdx.dev> |
| 2025-02-17 | **pitchfork** — process manager for developers that pairs well with mise — <https://pitchfork.jdx.dev> |
| 2025-02-04 | A Mise guide for Swift developers — <https://tuist.dev/blog/2025/02/04/mise> |
| 2025-01-26 | devtools.fm: Jeff Dickey — Mise, Usage, and Pitchfork and the Future of Polyglot Tools — <https://www.devtools.fm/episode/129> |
| 2025-01-12 | [fr] Mise-En-Place: Simplifiez la Gestion de vos Environnements et Tâches — <https://blog.stephane-robert.info/docs/outils/systeme/mise/> |
| 2024-11-20 | Migrating from nvm to mise — <https://dev.to/hverlin/migrating-from-nvm-to-mise-4mfp> |
| 2024-09-06 | Replacing pyenv, nvm, direnv with Mise — <https://arunmozhi.in/2024/09/06/replacing-pyenv-nvm-direnv-with-mise> |
| 2024-06-27 | Managing Development Tool Versions with mise — <https://haril.dev/en/blog/2024/06/27/Easy-devtools-version-management-mise> |
| 2024-04-14 | Shims: How they work in mise-en-place — <https://jdx.dev/posts/2024-04-13-shims-how-they-work-in-mise-en-place/> |
| 2024-04-07 | Lalaluka stream: Grroxy, Cook, and jdx/mise — <https://www.youtube.com/watch?v=zA1hjrLQiPw> |
| 2024-02-20 | Can Mise replace Volta? — <https://ricostacruz.com/posts/mise-vs-volta> |
| 2024-01-14 | Manage all your runtime versions with one tool (asdf, mise) — <https://blog.andreyfadeev.com/p/manage-all-your-runtime-versions> |
| 2023-12-30 | You should be using mise — <https://andrei-calazans.com/posts/you-should-be-using-rtx/> |
| 2023-03-04 | Beginner's Guide to rtx (mise) — <https://dev.to/jdxcode/beginners-guide-to-rtx-ac4> |

---

### 9.11 Global flags (apply to every command)

```
mise [FLAGS] [TASK] <SUBCOMMAND>
```

`[TASK]` is shorthand for `mise tasks run <TASK>` ([cli/](https://mise.jdx.dev/cli/)).

| Flag | Meaning |
|---|---|
| `-C --cd <DIR>` | Change directory before running command |
| `-E --env… <ENV>` | Set the environment for loading `mise.<ENV>.toml` |
| `-j --jobs <JOBS>` | How many jobs to run in parallel [default: 8] |
| `-q --quiet` | Suppress non-error messages |
| `-v --verbose…` | Show extra output (use `-vv` for even more) |
| `-y --yes` | Answer yes to all confirmation prompts |
| `--raw` | Read/write directly to stdin/stdout/stderr instead of by line |
| `--locked` | Require lockfile URLs to be present during installation (also `MISE_LOCKED=1` / `settings.locked=true`) |
| `--silent` | Suppress all task output and mise non-error messages |
| `--no-config` | Do not load any config files (also `MISE_NO_CONFIG=1`) |
| `--no-env` | Do not load environment variables from config files (also `MISE_NO_ENV=1`) |
| `--no-hooks` | Do not execute hooks from config files (also `MISE_NO_HOOKS=1`) |
| `--output <OUTPUT>` | *(undocumented on the CLI index page)* |

([cli/](https://mise.jdx.dev/cli/))

> **Uncertainty:** `--output <OUTPUT>` is listed on the CLI index with no description ([cli/](https://mise.jdx.dev/cli/)).

---

### Full CLI index

Every top-level command listed on the [CLI reference index](https://mise.jdx.dev/cli/) (58 commands). Descriptions are the official one-liners from each command's doc page (also aggregated at <https://mise.jdx.dev/llms.txt>). Aliases were confirmed against `mise --help` on mise `2026.7.17`.

| Command | Alias(es) | Description |
|---|---|---|
| [`mise activate`](https://mise.jdx.dev/cli/activate.html) | – | Initializes mise in the current shell session |
| [`mise backends`](https://mise.jdx.dev/cli/backends.html) | – | Manage backends |
| [`mise bin-paths`](https://mise.jdx.dev/cli/bin-paths.html) | – | List all the active runtime bin paths |
| [`mise bootstrap`](https://mise.jdx.dev/cli/bootstrap.html) | `bs` | Set up a machine for the current config in one command |
| [`mise cache`](https://mise.jdx.dev/cli/cache.html) | – | Manage the mise cache |
| [`mise completion`](https://mise.jdx.dev/cli/completion.html) | – | Generate shell completions |
| [`mise config`](https://mise.jdx.dev/cli/config.html) | `cfg` | Manage config files |
| [`mise deactivate`](https://mise.jdx.dev/cli/deactivate.html) | – | Disable mise for current shell session |
| [`mise deps`](https://mise.jdx.dev/cli/deps.html) | `dep` | **[experimental]** Manage project dependencies |
| [`mise doctor`](https://mise.jdx.dev/cli/doctor.html) | `dr` | Check mise installation for possible problems |
| [`mise edit`](https://mise.jdx.dev/cli/edit.html) | – | Edit mise.toml interactively |
| [`mise en`](https://mise.jdx.dev/cli/en.html) | – | Starts a new shell with the mise environment built from the current configuration |
| [`mise env`](https://mise.jdx.dev/cli/env.html) | `e` | Exports env vars to activate mise a single time |
| [`mise exec`](https://mise.jdx.dev/cli/exec.html) | `x` | Execute a command with tool(s) set |
| [`mise fmt`](https://mise.jdx.dev/cli/fmt.html) | – | Formats mise.toml |
| [`mise generate`](https://mise.jdx.dev/cli/generate.html) | `gen` | Generate files for various tools/services |
| [`mise implode`](https://mise.jdx.dev/cli/implode.html) | – | Removes mise CLI and all related data |
| [`mise install`](https://mise.jdx.dev/cli/install.html) | `i` | Install a tool version |
| [`mise install-into`](https://mise.jdx.dev/cli/install-into.html) | – | Install a tool version to a specific path |
| [`mise latest`](https://mise.jdx.dev/cli/latest.html) | – | Gets the latest available version for a plugin |
| [`mise link`](https://mise.jdx.dev/cli/link.html) | `ln` | Symlinks a tool version into mise |
| [`mise lock`](https://mise.jdx.dev/cli/lock.html) | – | Update lockfile checksums and URLs for all specified platforms |
| [`mise ls`](https://mise.jdx.dev/cli/ls.html) | `list` | List installed and active tool versions |
| [`mise ls-remote`](https://mise.jdx.dev/cli/ls-remote.html) | – | List runtime versions available for install |
| [`mise mcp`](https://mise.jdx.dev/cli/mcp.html) | – | Run Model Context Protocol (MCP) server |
| [`mise oci`](https://mise.jdx.dev/cli/oci.html) | – | **[experimental]** Build OCI container images from a mise.toml |
| [`mise outdated`](https://mise.jdx.dev/cli/outdated.html) | – | Shows outdated tool versions |
| [`mise patrons`](https://mise.jdx.dev/cli/patrons.html) | – | Show the individuals supporting mise as Patron-tier members |
| [`mise plugins`](https://mise.jdx.dev/cli/plugins.html) | `p` | Manage plugins |
| [`mise prune`](https://mise.jdx.dev/cli/prune.html) | – | Delete unused versions of tools |
| [`mise registry`](https://mise.jdx.dev/cli/registry.html) | – | List available tools to install |
| [`mise reshim`](https://mise.jdx.dev/cli/reshim.html) | – | Creates new shims based on bin paths from currently installed tools |
| [`mise run`](https://mise.jdx.dev/cli/run.html) | `r` | Run task(s) |
| [`mise search`](https://mise.jdx.dev/cli/search.html) | – | Search for tools in the registry |
| [`mise self-update`](https://mise.jdx.dev/cli/self-update.html) | – | Updates mise itself |
| [`mise set`](https://mise.jdx.dev/cli/set.html) | – | Set environment variables in mise.toml |
| [`mise settings`](https://mise.jdx.dev/cli/settings.html) | – | Show current settings (`mise --help` renders this as "Manage settings") |
| [`mise shell`](https://mise.jdx.dev/cli/shell.html) | `sh` | Sets a tool version for the current session |
| [`mise shell-alias`](https://mise.jdx.dev/cli/shell-alias.html) | – | Manage shell aliases |
| [`mise sponsors`](https://mise.jdx.dev/cli/sponsors.html) | – | Show the companies sponsoring mise and the jdx.dev open source tools |
| [`mise sync`](https://mise.jdx.dev/cli/sync.html) | – | Synchronize tools from other version managers with mise |
| [`mise tasks`](https://mise.jdx.dev/cli/tasks.html) | `t` | Manage tasks |
| [`mise test-tool`](https://mise.jdx.dev/cli/test-tool.html) | – | Test a tool installs and executes |
| [`mise token`](https://mise.jdx.dev/cli/token.html) | – | Display git provider tokens mise will use |
| [`mise tool`](https://mise.jdx.dev/cli/tool.html) | – | Gets information about a tool |
| [`mise tool-alias`](https://mise.jdx.dev/cli/tool-alias.html) | – | Manage tool version aliases |
| [`mise tool-stub`](https://mise.jdx.dev/cli/tool-stub.html) | – | Execute a tool stub |
| [`mise trust`](https://mise.jdx.dev/cli/trust.html) | – | Marks a config file as trusted |
| [`mise uninstall`](https://mise.jdx.dev/cli/uninstall.html) | – | Removes installed tool versions |
| [`mise unset`](https://mise.jdx.dev/cli/unset.html) | – | Remove environment variable(s) from the config file |
| [`mise untrust`](https://mise.jdx.dev/cli/untrust.html) | – | No longer trust a config, will prompt in the future |
| [`mise unuse`](https://mise.jdx.dev/cli/unuse.html) | `rm`, `remove` | Removes installed tool versions from mise.toml |
| [`mise upgrade`](https://mise.jdx.dev/cli/upgrade.html) | `up` | Upgrades outdated tools |
| [`mise use`](https://mise.jdx.dev/cli/use.html) | `u` | Installs a tool and adds the version to mise.toml |
| [`mise version`](https://mise.jdx.dev/cli/version.html) | `v` | Display the version of mise |
| [`mise watch`](https://mise.jdx.dev/cli/watch.html) | `w` | Run task(s) and watch for changes to rerun it |
| [`mise where`](https://mise.jdx.dev/cli/where.html) | – | Display the installation path for a tool |
| [`mise which`](https://mise.jdx.dev/cli/which.html) | – | Shows the path that a tool's bin points to |

#### Notable nested subcommands (for orientation)

| Parent | Subcommands |
|---|---|
| `backends` | `ls` ([cli/backends/ls](https://mise.jdx.dev/cli/backends/ls.html)) |
| `bootstrap` | `dotfiles` (`add`/`apply`/`edit`/`status`/`unapply`), `linux systemd-units` (`apply`/`status`), `macos defaults` (`apply`/`status`), `macos launchd-agents` (`apply`/`status`), `mise-shell-activate` (`apply`/`status`), `packages` (`apply`/`brew tap`/`brew untap`/`import`/`prune`/`status`/`upgrade`/`use`), `plugins` (`apply`/`status`), `repos` (`apply`/`exec`/`status`/`update`), `status`, `user` (`apply`/`status`) ([cli/](https://mise.jdx.dev/cli/)) |
| `cache` | `clear`, `path`, `prune` |
| `config` | `get`, `ls`, `set` |
| `deps` | `add`, `install`, `remove` |
| `doctor` | `path` |
| `generate` | `bootstrap`, `config`, `devcontainer`, `git-pre-commit`, `github-action`, `task-docs`, `task-stubs`, `tool-stub` |
| `oci` | `build`, `push`, `run` — all **[experimental]** |
| `plugins` | `install`, `link`, `ls`, `ls-remote`, `uninstall`, `update` |
| `settings` | `add`, `get`, `ls`, `set`, `unset` |
| `shell-alias` | `get`, `ls`, `set`, `unset` |
| `sync` | `node`, `python`, `ruby` |
| `tasks` | `add`, `deps`, `edit`, `graph` (**[experimental]**), `info`, `ls`, `run`, `validate` |
| `token` | `forgejo`, `github`, `gitlab` |
| `tool-alias` | `get`, `ls`, `set`, `unset` |

([cli/](https://mise.jdx.dev/cli/))

---

## 10. Language Runtimes & Cookbook

mise ships **core plugins** for the major language runtimes. A core plugin is compiled into the mise binary (source lives under `src/plugins/core/*.rs`) and is used automatically *unless* you manually install a git plugin with the same name — e.g. `mise plugins install node https://github.com/asdf-vm/asdf-nodejs` shadows the core `node` plugin ([lang/node](https://mise.jdx.dev/lang/node.html)).

### 10.0 Cross-cutting concepts

#### Install strategy at a glance

| Runtime | Default acquisition | Compiles from source? | Escape hatch |
| --- | --- | --- | --- |
| node | Precompiled tarballs from nodejs.org | Opt-in via `node.compile=1` | `node.mirror_url` + `node.flavor` for unofficial builds ([lang/node](https://mise.jdx.dev/lang/node.html)) |
| python | Precompiled `python-build-standalone` | Opt-in via `python.compile=true` (uses pyenv's `python-build`) | `python.precompiled_arch` / `_flavor` / `_os` ([lang/python](https://mise.jdx.dev/lang/python.html)) |
| ruby | Compiles with `ruby-build` (precompiled becomes default in **2026.8.0**) | Yes, by default today | `ruby.compile=false` to prefer precompiled `jdx/ruby` binaries ([lang/ruby](https://mise.jdx.dev/lang/ruby.html)) |
| go | Official SDK tarballs from `dl.google.com/go` | No | `go.download_mirror`, `go.repo` ([lang/go](https://mise.jdx.dev/lang/go.html)) |
| rust | Delegates entirely to **rustup** | rustup's business | `rust.rustup_home`, `rust.cargo_home` ([lang/rust](https://mise.jdx.dev/lang/rust.html)) |
| java | Vendor-published JDK archives | No | `java.shorthand_vendor`, `release_type` ([lang/java](https://mise.jdx.dev/lang/java.html)) |
| deno / bun | Official release binaries | No | `install_env` only ([lang/deno](https://mise.jdx.dev/lang/deno.html), [lang/bun](https://mise.jdx.dev/lang/bun.html)) |
| erlang | Precompiled if available, else **kerl** build | Yes (fallback / `erlang.compile=true`) | `erlang.compile` ([lang/erlang](https://mise.jdx.dev/lang/erlang.html)) |
| elixir | Precompiled releases; **requires erlang** | No | `install_env` ([lang/elixir](https://mise.jdx.dev/lang/elixir.html)) |
| swift | Precompiled swift.org toolchains (macOS + Linux) | No | `swift.platform` ([lang/swift](https://mise.jdx.dev/lang/swift.html)) |
| zig | Precompiled, via community mirrors by default | No | `zig.use_community_mirrors` ([lang/zig](https://mise.jdx.dev/lang/zig.html)) |
| dotnet | Microsoft's official install script | No | `dotnet.dotnet_root`, `dotnet.isolated` ([lang/dotnet](https://mise.jdx.dev/lang/dotnet.html)) |

#### `install_env` — the universal tool option

Every core language backend accepts an `install_env` tool option that injects environment variables into the install-time commands (source builds, default-package installation, post-install verification). It goes in `[tools]`, not `[settings]` ([lang/node](https://mise.jdx.dev/lang/node.html)):

```toml
[tools]
node   = { version = "latest", install_env = { CFLAGS = "-O2" } }
python = { version = "latest", install_env = { CONFIGURE_OPTS = "--enable-optimizations" } }
ruby   = { version = "latest", install_env = { RUBY_CONFIGURE_OPTS = "--disable-install-doc" } }
go     = { version = "latest", install_env = { GOPRIVATE = "github.com/acme/*" } }
rust   = { version = "latest", install_env = { RUSTUP_DIST_SERVER = "https://static.rust-lang.org" } }
erlang = { version = "latest", install_env = { KERL_CONFIGURE_OPTIONS = "--without-javac" } }
elixir = { version = "latest", install_env = { MIX_HOME = "~/.mix" } }
java   = { version = "latest", install_env = { JAVA_TOOL_OPTIONS = "-Djava.net.useSystemProxies=true" } }
dotnet = { version = "latest", install_env = { DOTNET_CLI_TELEMETRY_OPTOUT = "1" } }
deno   = { version = "latest", install_env = { HTTPS_PROXY = "http://proxy.example" } }
bun    = { version = "latest", install_env = { HTTPS_PROXY = "http://proxy.example" } }
swift  = { version = "latest", install_env = { HTTPS_PROXY = "http://proxy.example" } }
zig    = { version = "latest", install_env = { HTTPS_PROXY = "http://proxy.example" } }
```

#### Default package files are on a deprecation clock

`~/.default-npm-packages`, `~/.default-gems`, `~/.default-python-packages`, `~/.default-go-packages` and friends **still work**, but mise **starts warning in `2026.11.0` and removes support in `2027.11.0`** ([lang/node](https://mise.jdx.dev/lang/node.html), [lang/python](https://mise.jdx.dev/lang/python.html), [lang/ruby](https://mise.jdx.dev/lang/ruby.html), [lang/go](https://mise.jdx.dev/lang/go.html)).

Two documented replacements:

| Need | Replacement | Example |
| --- | --- | --- |
| A CLI tool | Install it directly with a language backend | `"npm:typescript" = "latest"`, `"pipx:black" = "latest"`, `"gem:rubocop" = "latest"`, `"go:github.com/jesseduffield/lazygit" = "latest"` |
| A package that genuinely must exist inside *every* installed runtime version | Tool-level `postinstall` hook | `node = { version = "22", postinstall = "npm install -g typescript" }` |

```toml
# postinstall hook variants, one per doc page
[tools]
node   = { version = "22",   postinstall = "npm install -g typescript" }
python = { version = "3.13", postinstall = "python -m pip install --upgrade ansible" }
ruby   = { version = "3.4",  postinstall = "gem install rubocop" }
go     = { version = "1.25", postinstall = "go install github.com/daixiang0/gci@latest" }
```

([lang/node](https://mise.jdx.dev/lang/node.html), [lang/python](https://mise.jdx.dev/lang/python.html), [lang/ruby](https://mise.jdx.dev/lang/ruby.html), [lang/go](https://mise.jdx.dev/lang/go.html))

#### Idiomatic version files: **disabled by default**

mise reads `mise.toml` and `.tool-versions` out of the box. Language-native version files (`.nvmrc`, `.python-version`, `.java-version`, …) are **off by default** and must be enabled per tool ([configuration#idiomatic-version-files](https://mise.jdx.dev/configuration.html#idiomatic-version-files)):

```sh
mise settings add idiomatic_version_file_enable_tools node
mise settings add idiomatic_version_file_enable_tools python
```

```toml
# ~/.config/mise/config.toml
[settings]
idiomatic_version_file_enable_tools = ["node", "python", "ruby"]
```

Individual files can be excluded with a `tool:filename` pair — e.g. keep `.nvmrc` but stop node consuming `devEngines.runtime` from `package.json`:

```sh
mise settings add idiomatic_version_file_disable_files node:package.json
```

Supported idiomatic files for the runtimes in this section ([configuration#idiomatic-version-files](https://mise.jdx.dev/configuration.html#idiomatic-version-files)):

| Tool | Idiomatic files |
| --- | --- |
| bun | `.bun-version`, `package.json` |
| deno | `.deno-version`, `package.json` |
| dotnet | `global.json` |
| elixir | `.exenv-version` |
| go | `.go-version`, `go.mod` |
| java | `.java-version`, `.sdkmanrc` |
| node | `.nvmrc`, `.node-version`, `package.json` |
| python | `.python-version`, `.python-versions` |
| ruby | `.ruby-version`, `Gemfile` |
| rust | `rust-toolchain.toml` |
| swift | `.swift-version` |
| zig | `.zig-version` |

> **Uncertainty:** The idiomatic-file table on [configuration.html](https://mise.jdx.dev/configuration.html#idiomatic-version-files) lists no entry for **erlang**; the Erlang page does not mention `.erlang-version` or `.erlang_version` either. Assume no idiomatic file support for erlang unless a plugin provides one.

Idiomatic files **support aliases** — an `.nvmrc` containing `lts/hydrogen` works in both mise and nvm. There is a small performance cost to discovering/parsing them (results are cached). asdf called these "legacy version files"; mise renamed them because they're not deprecated ([configuration#idiomatic-version-files](https://mise.jdx.dev/configuration.html#idiomatic-version-files)).

`go.mod` gets special treatment: the `toolchain goX.Y.Z` directive (an exact pin) wins when present; otherwise the `go X.Y` directive is used, and since that declares only a *minimum*, mise resolves it to the latest matching patch (`go 1.22` → latest `1.22.x`) ([configuration#idiomatic-version-files](https://mise.jdx.dev/configuration.html#idiomatic-version-files)).

#### Version scopes relevant to runtimes

| Scope | Meaning |
| --- | --- |
| `ref:<SHA>` | Compile from a VCS ref |
| `prefix:<PREFIX>` | Latest version matching prefix — **required for Go ≤1.20** (see §10.4) |
| `path:<PATH>` | Use a custom compiled version at a path, e.g. `path:/opt/homebrew/opt/node@20` |
| `sub-<PARTIAL>:<ORIG>` | Numeric arithmetic on a resolved version — `sub-2:lts` resolves `lts` then subtracts 2 from the major (`20`→`18`); `sub-0.1:latest` subtracts 1 from the minor (`3.11`→`3.10`). **Not** "the Nth previous release." |

([configuration#tool-versions](https://mise.jdx.dev/configuration.html#tool-versions))

---

### 10.1 Node.js

Core plugin: [`src/plugins/core/node.rs`](https://github.com/jdx/mise/blob/main/src/plugins/core/node.rs). A drop-in replacement for `nvm`, `volta`, `fnm`, and asdf-nodejs ([lang/node](https://mise.jdx.dev/lang/node.html)).

```sh
mise use -g node@26   # latest node-26.x as the global default
```

#### Install mechanics

Default is a **precompiled tarball from nodejs.org**, GPG-verified. Source compilation is opt-in:

```sh
mise settings node.compile=1
mise use node@latest
```

See [BUILDING.md](https://github.com/nodejs/node/blob/main/BUILDING.md#building-nodejs-on-supported-platforms) for required system dependencies before compiling ([lang/node](https://mise.jdx.dev/lang/node.html)).

#### Unofficial builds (musl, old glibc, exotic arches)

[unofficial-builds.nodejs.org](https://unofficial-builds.nodejs.org/) covers platforms the official binaries don't (e.g. `linux-loong64`, `linux-armv6l`) and offers musl/older-glibc flavors — a good alternative to compiling ([lang/node](https://mise.jdx.dev/lang/node.html)):

```sh
mise settings node.mirror_url=https://unofficial-builds.nodejs.org/download/release/
# for an alternative arch/os that is all you need. For a flavor:
mise settings node.flavor=musl
mise settings node.flavor=glibc-217
```

For the common musl case, the global `mise settings libc=musl` also selects Node's `musl` flavor **when `node.flavor` is unset** ([lang/node](https://mise.jdx.dev/lang/node.html)).

#### Pinning npm independently of Node

Node ships a bundled npm; pinning `npm` as its own tool overrides it, which is how you keep a team on one npm version and avoid `package-lock.json` churn ([lang/node](https://mise.jdx.dev/lang/node.html)):

```toml
# mise.toml
[tools]
node = "26"
npm  = "11"
```

```sh
mise use --pin node@lts npm@latest
```

`--pin` resolves the aliases to exact numbers in the file:

```toml
# mise.toml
[tools]
node = "26.1.0"
npm  = "11.12.1"
```

> The pinned npm takes precedence over the bundled one, so `npm --version` always reports the `mise.toml` value ([lang/node](https://mise.jdx.dev/lang/node.html)).

#### Corepack (pnpm/yarn)

`node.corepack = true` installs the default corepack shims after installing *any* node version ([lang/node](https://mise.jdx.dev/lang/node.html)). The Node.js cookbook instead uses a `postinstall` hook (`npx corepack enable`) — see §10.14.

#### Default npm packages (legacy)

`$HOME/.default-npm-packages`, one package per line, optionally with a version specifier ([lang/node](https://mise.jdx.dev/lang/node.html)):

```text
lodash
typescript@latest
@types/node@^20
```

mise also checks `~/.default-nodejs-packages` and `~/.default-node-packages` for backwards compatibility. Override the location with `MISE_NODE_DEFAULT_PACKAGES_FILE`.

#### Settings

| Setting | Type / Default | Env | Meaning |
| --- | --- | --- | --- |
| `node.cflags` | `string?` / none | `MISE_NODE_CFLAGS` | Additional CFLAGS (e.g. to override `-O3`) |
| `node.compile` | `boolean?` / none | `MISE_NODE_COMPILE` | Compile node from source |
| `node.concurrency` | `integer` / physical CPU count (unset when ninja enabled) | `MISE_NODE_CONCURRENCY` | Parallel jobs for compilation; with ninja, ninja handles concurrency |
| `node.configure_opts` | `string?` / none | `MISE_NODE_CONFIGURE_OPTS` | Additional `./configure` options |
| `node.corepack` | `boolean` / `false` | `MISE_NODE_COREPACK` | Install default corepack shims after installing any node version |
| `node.default_packages_file` **(deprecated)** | `string` / `~/.default-npm-packages` | `MISE_NODE_DEFAULT_PACKAGES_FILE` | npm packages installed post-install; also checks `~/.default-nodejs-packages`, `~/.default-node-packages` |
| `node.flavor` | `string?` / none | `MISE_NODE_FLAVOR` | e.g. `glibc-217`, `musl` — use with the unofficial build repo |
| `node.gpg_verify` | `boolean?` / none | `MISE_NODE_GPG_VERIFY` | Verify OpenPGP signatures (built-in; **no external gpg required**). `false` disables |
| `node.make` | `string?` / none | `MISE_NODE_MAKE` | Make command to use |
| `node.make_install_opts` | `string?` / none | `MISE_NODE_MAKE_INSTALL_OPTS` | Additional `make install` options |
| `node.make_opts` | `string?` / none | `MISE_NODE_MAKE_OPTS` | Additional make options |
| `node.mirror_url` | `string?` / none | `MISE_NODE_MIRROR_URL` | Mirror to download node tarballs from |
| `node.ninja` | `boolean` / auto: `true` if `ninja` on PATH | `MISE_NODE_NINJA` | Use ninja instead of make; generally faster for incremental builds |
| `node.nodenv_root` | `string` / `~/.nodenv` | `NODENV_ROOT` | Directory for nodenv |
| `node.npm_shim` | `boolean` / `true` | `MISE_NODE_NPM_SHIM` | Installs a bash wrapper at `bin/npm` that triggers `mise reshim` after `npm install -g`. Disable to let corepack or a global `npm install -g npm@…` own `bin/npm` |
| `node.nvm_dir` | `string` / `~/.nvm` | `NVM_DIR` | Directory for nvm |
| `node.verify` | `boolean` / `true` | `MISE_NODE_VERIFY` | Verify downloaded assets using GPG |

([lang/node](https://mise.jdx.dev/lang/node.html))

#### Gotchas

- **You cannot install a plugin named `nodejs`.** mise silently renames it to `node` ([lang/node](https://mise.jdx.dev/lang/node.html), [faq](https://mise.jdx.dev/faq.html#what-is-the-difference-between-nodejs-and-node-or-golang-and-go)).
- `.nvmrc` / `.node-version` / `package.json#devEngines` need `idiomatic_version_file_enable_tools` (see §10.0).
- `node.npm_shim` conflicts with corepack owning `bin/npm` — disable the shim in that scenario ([lang/node](https://mise.jdx.dev/lang/node.html)).

---

### 10.2 Python

Core plugin: [`src/plugins/core/python.rs`](https://github.com/jdx/mise/blob/main/src/plugins/core/python.rs). Replaces `pyenv`, plus virtualenv automation and uv integration ([lang/python](https://mise.jdx.dev/lang/python.html)).

```sh
mise use -g python@3.15
```

Multiple concurrent versions produce versioned binaries:

```sh
$ mise use -g python@3.14 python@3.15
$ python -V
3.14.0
$ python3.15 -V
3.15.0
```

Flavour prefixes select alternative distributions — `mise use -g python@anaconda` installs the latest anaconda ([lang/python](https://mise.jdx.dev/lang/python.html)).

#### Precompiled binaries (default) vs python-build

By default mise downloads [python-build-standalone](https://github.com/astral-sh/python-build-standalone) binaries: much faster, and no system build dependencies needed. There are [known quirks](https://github.com/astral-sh/python-build-standalone/blob/main/docs/quirks.rst) ([lang/python](https://mise.jdx.dev/lang/python.html)).

- Disable with `mise settings python.compile=1` (falls back to pyenv's [python-build](https://github.com/pyenv/pyenv/tree/master/plugins/python-build), whose [dependencies](https://github.com/pyenv/pyenv/wiki#suggested-build-environment) you must install first).
- **Old CPUs:** the default arch may not run. Set `MISE_PYTHON_PRECOMPILED_ARCH`; use `x86_64` for the most compatible binaries.

#### `patch_sysconfig` tool option

On Unix, mise patches the installed Python's `sysconfig` data so python-build-standalone's build-time paths point at the final mise install path. Disable only as an install workaround ([lang/python](https://mise.jdx.dev/lang/python.html)):

```toml
[tools]
python = { version = "3.14", patch_sysconfig = false }
```

> Disabling leaves stale build-time paths in `sysconfig`; prefer the default.

#### Two virtualenv mechanisms — pick deliberately

| Mechanism | Best for | Config location |
| --- | --- | --- |
| `python.uv_venv_auto` | uv projects (with `uv.lock`) | `[settings]` |
| `_.python.venv` | Projects not using uv | `[env]` |

([lang/python](https://mise.jdx.dev/lang/python.html))

> **These are separate code paths.** Options like `uv_create_args` and `python_create_args` on `_.python.venv` are **not** used by `python.uv_venv_auto` ([lang/python](https://mise.jdx.dev/lang/python.html)).

##### `_.python.venv`

```toml
[tools]
python = "3.15" # [optional] will be used for the venv

[env]
_.python.venv = ".venv" # relative to this file's directory
_.python.venv = "/root/.venv" # can be absolute
_.python.venv = "{{env.HOME}}/.cache/venv/myproj" # can use templates
_.python.venv = { path = ".venv", create = true } # create the venv if it doesn't exist
_.python.venv = { path = ".venv", create = true, python = "3.15" } # use a specific python version
_.python.venv = {
  path = ".venv", create = true,
  python_create_args = ["--without-pip"], # pass args to python -m venv
}
_.python.venv = {
  path = ".venv", create = true,
  uv_create_args = ["--system-site-packages"], # pass args to uv venv
}
# Install seed packages (pip, setuptools, and wheel) into the virtual environment.
_.python.venv = { path = ".venv", create = true, uv_create_args = ['--seed'] }
```

Without `create = true` the venv must be created manually (`python -m venv /path/to/venv`) ([lang/python](https://mise.jdx.dev/lang/python.html)).

If `uv` is installed (e.g. `mise use -g uv@latest`), mise uses it to create the venv; otherwise it falls back to `python -m venv`. Because `uv` omits `pip` by default (it provides `uv pip`), add `uv_create_args = ['--seed']` if you need real `pip` ([lang/python](https://mise.jdx.dev/lang/python.html)).

##### `python.uv_venv_auto`

```toml
# mise.toml
[settings]
python.uv_venv_auto = "source"        # activate existing .venv
# or
python.uv_venv_auto = "create|source" # create .venv if missing, then activate
```

mise finds the uv project root by **walking up for a `uv.lock`**. No lockfile ⇒ the setting is a no-op; run `uv sync` or `uv lock` first ([lang/python](https://mise.jdx.dev/lang/python.html)).

mise honours uv's `UV_PROJECT_ENVIRONMENT`: a relative path resolves from the uv project root (the `uv.lock` directory), an absolute path is used as-is, and unset/empty means `.venv` ([lang/python](https://mise.jdx.dev/lang/python.html)):

```toml
# mise.toml
[env]
UV_PROJECT_ENVIRONMENT = "my.venv"

[settings]
python.uv_venv_auto = "create|source"
```

> **Version-sensitive:** the `true` value for `python.uv_venv_auto` is legacy and **planned for deprecation in mise 2026.7**. The *setting* is staying; only the `true` value is being phased out. `true` behaves like `create|source` **plus** exporting `UV_PYTHON` (just the version number) ([lang/python](https://mise.jdx.dev/lang/python.html)).

Setting `UV_PYTHON` to a bare version does **not** guarantee uv uses mise's interpreter — uv may fall back to a system or self-managed Python of the same version. To bind it strictly ([lang/python](https://mise.jdx.dev/lang/python.html)):

```toml
[tools]
python = "3.15"

[env]
UV_PYTHON = { value = "{{ tools.python.path }}", tools = true }
```

> The legacy `virtualenv` tool option (`python = { version = "3.15", virtualenv = ".venv" }` in `[tools]`) is **deprecated and will be removed**; use `_.python.venv` ([lang/python](https://mise.jdx.dev/lang/python.html)).

#### Free-threaded Python

```bash
# precompiled freethreaded build
MISE_PYTHON_COMPILE=0 MISE_PYTHON_PRECOMPILED_FLAVOR=freethreaded+pgo-full mise install python

# or compile it with python-build
MISE_PYTHON_COMPILE=1 PYTHON_BUILD_FREE_THREADING=1 mise install python
```

([lang/python](https://mise.jdx.dev/lang/python.html))

#### Windows

mise uses the same python-build-standalone binaries on Windows; **compiling with python-build is not supported there**. mise smooths over two upstream quirks ([lang/python](https://mise.jdx.dev/lang/python.html)):

- Archives ship only `python.exe` → mise creates a `python3.exe` alias beside it.
- Archives ship no `pip.exe` → mise creates `pip.cmd`/`pip3.cmd` wrappers in the install root delegating to `python -m pip` (so they survive pip self-upgrades).

The install's `Scripts` directory is on `PATH`, so console scripts from `pip install` (e.g. `black`) are runnable. **With shims instead of `mise activate`, run `mise reshim` after `pip install`.**

#### Homebrew / OpenSSL troubleshooting

```sh
brew unlink pkg-config
CFLAGS="-I$(brew --prefix openssl)/include" \
  LDFLAGS="-L$(brew --prefix openssl)/lib" \
  mise install python@latest
brew link pkg-config
```

Homebrew's own OpenSSL can collide with the system-expected one; the `pkg-config` unlink works around a [known python-build issue](https://github.com/pyenv/pyenv/issues/2823#issuecomment-1769081965) ([lang/python](https://mise.jdx.dev/lang/python.html)).

#### Settings

| Setting | Type / Default | Env | Meaning |
| --- | --- | --- | --- |
| `python.compile` | `boolean?` / none | `MISE_PYTHON_COMPILE` | `true` = always python-build; `false` = always precompiled; unset = precompiled if available, else compile |
| `python.default_packages_file` **(deprecated)** | `string?` / none | `MISE_PYTHON_DEFAULT_PACKAGES_FILE` | File of default pip packages |
| `python.github_attestations` | `boolean?` / none | `MISE_PYTHON_GITHUB_ATTESTATIONS` | Override global `github_attestations` for `astral-sh/python-build-standalone` binaries |
| `python.patch_url` | `string?` / none | `MISE_PYTHON_PATCH_URL` | URL to fetch python patches to pass to python-build |
| `python.patches_directory` | `string?` / none | `MISE_PYTHON_PATCHES_DIRECTORY` | Directory to fetch python patches from |
| `python.precompiled_arch` | `string` / `"x86_64_v3" \| "aarch64"` | `MISE_PYTHON_PRECOMPILED_ARCH` | Arch for precompiled binaries; use `x86_64` on old CPUs |
| `python.precompiled_flavor` | `string` / `install_only_stripped` | `MISE_PYTHON_PRECOMPILED_FLAVOR` | e.g. `freethreaded+pgo-full` |
| `python.precompiled_os` | `string` / `"apple-darwin" \| "unknown-linux-gnu" \| "unknown-linux-musl"` | `MISE_PYTHON_PRECOMPILED_OS` | OS for precompiled binaries |
| `python.pyenv_repo` | `string` / `https://github.com/pyenv/pyenv.git` | `MISE_PYENV_REPO` | Where to fetch pyenv (for python-build) |
| `python.uv_venv_auto` | `boolean \| string` / `false` | `MISE_PYTHON_UV_VENV_AUTO` | `false` \| `source` \| `create\|source` \| `true` (legacy) |
| `python.uv_venv_create_args` | `string[]?` / none | `MISE_PYTHON_UV_VENV_CREATE_ARGS` (**colon separated**) | Args passed to `uv` when creating a venv |
| `python.venv_create_args` | `string[]?` / none | `MISE_PYTHON_VENV_CREATE_ARGS` (**colon separated**) | Args passed to `python -m venv` (not used for uv venv creation) |
| `python.venv_stdlib` | `boolean` / `false` | `MISE_VENV_STDLIB` | Prefer stdlib `venv` over uv |

([lang/python](https://mise.jdx.dev/lang/python.html))

#### Gotchas

- **Virtualenv activation requires `mise activate` or `mise exec`.** With [shims](https://mise.jdx.dev/dev-tools/shims.html) alone the venv's `bin/` is not added to PATH, so `which python` points at the shim, not the venv interpreter ([lang/python](https://mise.jdx.dev/lang/python.html)).
- `MISE_PYTHON_UV_VENV_CREATE_ARGS` / `MISE_PYTHON_VENV_CREATE_ARGS` are **colon separated**, not comma separated.

---

### 10.3 Ruby

Core plugin: [`src/plugins/core/ruby.rs`](https://github.com/jdx/mise/blob/main/src/plugins/core/ruby.rs). Replaces `rvm`/`rbenv` ([lang/ruby](https://mise.jdx.dev/lang/ruby.html)).

```sh
mise use -g ruby@3.2
mise use -g ruby@truffleruby   # latest of a flavour, via flavour prefix
```

#### Compile (today) vs precompiled (2026.8.0)

Behind the scenes mise currently uses [ruby-build](https://github.com/rbenv/ruby-build) to compile from source, so install its [suggested build environment](https://github.com/rbenv/ruby-build/wiki#suggested-build-environment) first ([lang/ruby](https://mise.jdx.dev/lang/ruby.html)).

> **Version-sensitive:** precompiled binaries become the default in **2026.8.0**. Opt in now:

```sh
mise settings ruby.compile=false
mise use ruby@3.4.1
```

Precompiled binaries come from [jdx/ruby](https://github.com/jdx/ruby) and cover **macOS arm64 (Apple Silicon only)**, **Linux arm64**, **Linux x86_64**. Unavailable platform/version ⇒ automatic fallback to ruby-build source compilation. To always compile: `mise settings ruby.compile=true` ([lang/ruby](https://mise.jdx.dev/lang/ruby.html)).

#### Precompiled build revisions (reproducibility gotcha)

`jdx/ruby` sometimes **rebuilds a binary without changing Ruby's version**, tagging releases `3.3.11-1`, `3.3.11-2`, … Documented rebuild reasons include native gem packaging fixes, CA certificate lookup fixes, RI documentation packaging changes, SLSA/provenance workflow fixes, and mass regeneration (not exhaustive). mise still calls the version `3.3.11` ([lang/ruby](https://mise.jdx.dev/lang/ruby.html)).

**Without a `mise.lock`, mise uses the latest available build revision** — so reinstalling the same Ruby version later may silently pick up a newer rebuild. With a lockfile the URL records the revision:

```toml
[[tools.ruby]]
version = "3.3.11"

[tools.ruby.platforms.linux-x64]
url = "https://github.com/jdx/ruby/releases/download/3.3.11-1/ruby-3.3.11.x86_64_linux.tar.gz"
```

Read the revision from the tag in the platform `url` (`/releases/download/3.3.11-1/` ⇒ revision `1`). To move to the newest rebuild, remove the entire Ruby entry from `mise.lock` (or every Ruby platform `url`), then ([lang/ruby](https://mise.jdx.dev/lang/ruby.html)):

```sh
mise lock ruby
mise install --force ruby
```

Commit the updated `mise.lock` so other machines and CI agree.

#### Default gems (legacy)

`$HOME/.default-gems`, one gem per line ([lang/ruby](https://mise.jdx.dev/lang/ruby.html)):

```text
# supports comments
pry
bcat ~> 0.6.0 # supports version constraints
rubocop --pre # install prerelease version
```

#### Version files

```sh
ruby -v > .ruby-version
mise settings add idiomatic_version_file_enable_tools ruby
```

mise reads `.ruby-version` *and* `Gemfile` (if it specifies a ruby version) once enabled ([lang/ruby](https://mise.jdx.dev/lang/ruby.html)).

#### Refreshing ruby-build

ruby-build updates daily; force it when a version is missing ([lang/ruby](https://mise.jdx.dev/lang/ruby.html)):

```bash
mise cache clean
mise ls-remote ruby
```

#### Settings

ruby-build has its own [custom build configuration](https://github.com/rbenv/ruby-build?tab=readme-ov-file#custom-build-configuration); mise adds:

| Setting | Type / Default | Env | Meaning |
| --- | --- | --- | --- |
| `ruby.apply_patches` | `string?` / none | `MISE_RUBY_APPLY_PATCHES` | List of patch files or URLs to apply to ruby source |
| `ruby.compile` | `boolean?` / none | `MISE_RUBY_COMPILE` | `false` = try precompiled, fall back to compiling; `true` = always ruby-build; unset = compile today (**precompiled from 2026.8.0**). **If `experimental = true`, precompiled is used when unset** |
| `ruby.default_packages_file` **(deprecated)** | `string` / `~/.default-gems` | `MISE_RUBY_DEFAULT_PACKAGES_FILE` | Default gems to install |
| `ruby.github_attestations` | `boolean?` / none | `MISE_RUBY_GITHUB_ATTESTATIONS` | Override global `github_attestations` for jdx/ruby binaries |
| `ruby.precompiled_arch` | `string?` / none | `MISE_RUBY_PRECOMPILED_ARCH` | Override arch identifier for precompiled binaries |
| `ruby.precompiled_os` | `string?` / none | `MISE_RUBY_PRECOMPILED_OS` | Override OS identifier |
| `ruby.precompiled_url` | `string` / `jdx/ruby` | `MISE_RUBY_PRECOMPILED_URL` | GitHub repo shorthand or full URL template with `{version}`, `{platform}`, `{os}`, `{arch}` |
| `ruby.ruby_build_opts` | `string?` / none | `MISE_RUBY_BUILD_OPTS` | Options to pass to ruby-build |
| `ruby.ruby_build_repo` | `string` / `https://github.com/rbenv/ruby-build.git` | `MISE_RUBY_BUILD_REPO` | Git repo **or ZIP archive** URL |
| `ruby.ruby_install` | `boolean` / `false` | `MISE_RUBY_INSTALL` | Use `ruby-install` instead of `ruby-build` |
| `ruby.ruby_install_opts` | `string?` / none | `MISE_RUBY_INSTALL_OPTS` | Options to pass to ruby-install |
| `ruby.ruby_install_repo` | `string` / `https://github.com/postmodern/ruby-install.git` | `MISE_RUBY_INSTALL_REPO` | Git repo or ZIP archive URL |
| `ruby.verbose_install` | `boolean?` / none | `MISE_RUBY_VERBOSE_INSTALL` | Verbose output during installation |

```toml
[settings.ruby]
# Use a different GitHub repo
precompiled_url = "yourorg/ruby"

# Or use a custom URL template
precompiled_url = "https://my-mirror.example.com/ruby-{version}.{platform}.tar.gz"
```

([lang/ruby](https://mise.jdx.dev/lang/ruby.html))

---

### 10.4 Go

Core plugin: [`src/plugins/core/go.rs`](https://github.com/jdx/mise/blob/main/src/plugins/core/go.rs). Downloads official Go SDK tarballs — no compilation ([lang/go](https://mise.jdx.dev/lang/go.html)).

```sh
mise use -g go@1.21
```

#### The `prefix:` gotcha for Go ≤ 1.20

> Minor Go versions **1.20 and below** require `prefix:` before the version number, because the first release of each series shipped without a `.0` suffix — which makes `1.20` an *exact* version match ([lang/go](https://mise.jdx.dev/lang/go.html)):

```sh
mise use -g go@prefix:1.20
```

#### GOROOT / GOPATH / GOBIN

| Variable | Behaviour |
| --- | --- |
| `GOROOT` | Set to `~/.local/share/mise/installs/go/…/` — controlled by `go.set_goroot`, **default `true`** |
| `GOBIN` | Defaults to `~/.local/share/mise/installs/go/.../bin`. `go.set_gobin = true` overrides a previously-set `GOBIN`; `false` means don't set it (leaving Go's own default of `${GOPATH:-$HOME/go}/bin`) |
| `GOPATH` | `go.set_gopath` is **deprecated** (use `env._go.set_goroot` instead); when `true` it set `GOPATH=~/.local/share/mise/installs/go/.../packages` |

([lang/go](https://mise.jdx.dev/lang/go.html))

#### Default packages (legacy)

`$HOME/.default-go-packages`, one package per line ([lang/go](https://mise.jdx.dev/lang/go.html)):

```text
github.com/daixiang0/gci # allows comments
github.com/jesseduffield/lazygit
```

#### Settings

| Setting | Type / Default | Env | Meaning |
| --- | --- | --- | --- |
| `go.default_packages_file` **(deprecated)** | `string` / `~/.default-go-packages` | `MISE_GO_DEFAULT_PACKAGES_FILE` | Default go packages to install |
| `go.download_mirror` | `string` / `https://dl.google.com/go` | `MISE_GO_DOWNLOAD_MIRROR` | Mirror for go SDK tarballs |
| `go.repo` | `string` / `https://github.com/golang/go` | `MISE_GO_REPO` | URL to fetch go from |
| `go.set_gobin` | `boolean?` / none | `MISE_GO_SET_GOBIN` | `true` overrides an existing GOBIN; `false` leaves GOBIN unset |
| `go.set_gopath` **(deprecated)** | `boolean` / `false` | `MISE_GO_SET_GOPATH` | Legacy GOPATH override |
| `go.set_goroot` | `boolean` / `true` | `MISE_GO_SET_GOROOT` | Sets GOROOT to the mise install dir |
| `go.skip_checksum` | `boolean` / `false` | `MISE_GO_SKIP_CHECKSUM` | Skip checksum verification of SDK tarballs |

([lang/go](https://mise.jdx.dev/lang/go.html))

> Like `nodejs`→`node`, `golang` is not a separate tool name — see the [FAQ](https://mise.jdx.dev/faq.html#what-is-the-difference-between-nodejs-and-node-or-golang-and-go) ([lang/node](https://mise.jdx.dev/lang/node.html)).

---

### 10.5 Rust

**Rust is the odd one out: mise drives rustup, it does not install toolchains itself.** mise installs rustup if missing, then installs the requested toolchain, components, and targets ([lang/rust](https://mise.jdx.dev/lang/rust.html)).

```sh
mise use -g rust          # latest stable
mise use -g rust@beta     # latest beta
mise use -g rust@1.82     # specific version
cargo build
```

#### Home directories & install layout

- By default mise **respects `RUSTUP_HOME` and `CARGO_HOME`**, falling back to `~/.rustup` and `~/.cargo`.
- Set `MISE_RUSTUP_HOME` / `MISE_CARGO_HOME` to isolate mise's rustup/cargo from your other installations.
- Toolchains **do not live in `~/.local/share/mise/installs`** because rustup owns them. mise keeps a symlink there for install tracking, sets `RUSTUP_TOOLCHAIN` to the requested version, and asks rustup to install configured components/targets on `mise install` ([lang/rust](https://mise.jdx.dev/lang/rust.html)).

#### Tool options

```toml
[tools]
"rust" = { version = "1.83.0", components = ["rust-src", "llvm-tools"] }
```

```toml
[tools]
"rust" = { version = "1.83.0", profile = "minimal" }
```

```toml
[tools]
"rust" = {
  version = "1.83.0",
  targets = ["wasm32-unknown-unknown", "thumbv2-none-eabi"],
}
```

| Option | Values | Meaning |
| --- | --- | --- |
| `components` | array, or comma-separated string | Components to install. Available set varies by release/toolchain. **If the toolchain is already installed, `mise install` still adds missing components** |
| `profile` | `minimal` \| `default` \| `complete` | `minimal` = `rustc`, `rust-std`, `cargo`. `default` = minimal + `rust-docs`, `rustfmt`, `clippy`. `complete` = everything rustup has — **"should never be used"**, it includes every component ever in the metadata and "will almost always fail." Unset ⇒ rustup's configured profile (`rustup show profile`) |
| `targets` | array, or comma-separated string | Cross-compilation targets. Missing targets are added on `mise install` even for an already-installed toolchain |

([lang/rust](https://mise.jdx.dev/lang/rust.html))

#### Settings

| Setting | Type / Default | Env | Meaning |
| --- | --- | --- | --- |
| `rust.cargo_home` | `string?` / none (→ `~/.cargo` or `%USERPROFILE%\.cargo`) | `MISE_CARGO_HOME` | Cargo home directory |
| `rust.default_host` | `string?` / none | `MISE_RUST_DEFAULT_HOST` | Host triple passed to `rustup init` via `--default-host` |
| `rust.rustup_home` | `string?` / none (→ `~/.rustup` or `%USERPROFILE%\.rustup`) | `MISE_RUSTUP_HOME` | rustup home directory |

([lang/rust](https://mise.jdx.dev/lang/rust.html))

`rust-toolchain.toml` is the registered idiomatic version file ([configuration#idiomatic-version-files](https://mise.jdx.dev/configuration.html#idiomatic-version-files)).

---

### 10.6 Java

Core plugin: [`src/plugins/core/java.rs`](https://github.com/jdx/mise/blob/main/src/plugins/core/java.rs). An sdkman-style multi-vendor JDK manager ([lang/java](https://mise.jdx.dev/lang/java.html)).

#### Vendor syntax

```sh
mise use -g java@openjdk-21
mise use -g java@21         # alternate shorthands for openjdk

mise use -g java@temurin    # latest version from Temurin
mise use -g java@temurin-21
mise use -g java@zulu-21
mise use -g java@corretto-21
```

`mise ls-remote java` enumerates what's available ([lang/java](https://mise.jdx.dev/lang/java.html)).

> **Shorthand versions (e.g. `21`) use [OpenJDK](https://openjdk.org/) as the vendor**, changeable via [`java.shorthand_vendor`](https://mise.jdx.dev/configuration/settings.html#java.shorthand%5Fvendor). **OpenJDK builds are only updated for a 6-month period — no updates or security patches after that, including for LTS versions.** See <https://whichjdk.com> for choosing ([lang/java](https://mise.jdx.dev/lang/java.html)).

#### `JAVA_HOME`

mise sets `JAVA_HOME` to the active installation, but **this requires [`mise activate`](https://mise.jdx.dev/cli/activate.html) — shims alone do not set environment variables** ([lang/java](https://mise.jdx.dev/lang/java.html)).

```sh
cd . # triggers mise hook-env to re-evaluate
echo $JAVA_HOME
```

IDEs that read `JAVA_HOME` at startup need a restart after switching. In CI/scripts use `mise exec` or `mise run`, which always set up the full environment ([lang/java](https://mise.jdx.dev/lang/java.html)).

#### macOS `/usr/libexec/java_home` integration

```sh
sudo mkdir /Library/Java/JavaVirtualMachines/openjdk-21.jdk
sudo ln -s ~/.local/share/mise/installs/java/openjdk-21/Contents /Library/Java/JavaVirtualMachines/openjdk-21.jdk/Contents
```

> Not all JDK distributions support this integration (e.g. **liberica**) ([lang/java](https://mise.jdx.dev/lang/java.html)).

#### `.java-version` / `.sdkmanrc`

For `.sdkmanrc`, mise maps vendor+version to its own version string: `20.0.2-tem` → `temurin-20.0.2`. Due to Azul's Zulu versioning, `11.0.12-zulu` maps only to the **major** version `zulu-11`.

**Unsupported sdkman vendors:** `bsg` (Bisheng), `graal` (GraalVM), `nik` (Liberica NIK) ([lang/java](https://mise.jdx.dev/lang/java.html)).

#### Using an unsupported JDK manually

```sh
# 1. download to e.g. ~/.sdkman/candidates/java/21.0.1-open, then:
ln -s ~/.sdkman/candidates/java/21.0.1-open ~/.local/share/mise/installs/java/21.0.1-open

# 2. macOS only:
mkdir ~/.local/share/mise/installs/java/21.0.1-open/Contents
mkdir ~/.local/share/mise/installs/java/21.0.1-open/Contents/MacOS

ln -s ~/.sdkman/candidates/java/21.0.1-open ~/.local/share/mise/installs/java/21.0.1-open/Contents/Home
cp ~/.local/share/mise/installs/java/21.0.1-open/lib/libjli.dylib ~/.local/share/mise/installs/java/21.0.1-open/Contents/MacOS/libjli.dylib
```

Then make sure an **empty directory exists** for that version in the [mise cache](https://mise.en.dev/directories.html#cache-mise) so the cache is blocked and valid ([lang/java](https://mise.jdx.dev/lang/java.html)):

```sh
$ ls -R $MISE_CACHE_DIR/java
21.0.1-open

mise/java/21.0.1-open:
```

#### Tool options & settings

```toml
[tools]
"java" = { version = "openjdk-21", release_type = "ea" }
```

| Name | Type / Default | Meaning |
| --- | --- | --- |
| `release_type` (tool option) | `ga` (default) \| `ea` | General Availability vs Early Access release |
| `java.shorthand_vendor` (setting, env `MISE_JAVA_SHORTHAND_VENDOR`) | `string` / `openjdk` | Vendor used when installing java without a vendor prefix |

([lang/java](https://mise.jdx.dev/lang/java.html))

#### Gradle toolchain auto-detection

Gradle [cannot auto-detect](https://github.com/gradle/gradle/issues/29508) mise-installed JDKs. Workaround — exploit the fact that mise's install layout matches [asdf's](https://mise.jdx.dev/ide-integration.html#sdk-selection-using-asdf-layout) ([lang/java](https://mise.jdx.dev/lang/java.html)):

```shell
mkdir -p ~/.asdf/installs/ && ln -s ~/.local/share/mise/installs/java ~/.asdf/installs/
```

Alternatively use the [foojay-resolver-convention](https://plugins.gradle.org/plugin/org.gradle.toolchains.foojay-resolver-convention) plugin and let Gradle install JDKs itself.

---

### 10.7 Deno

Core plugin: [`src/plugins/core/deno.rs`](https://github.com/jdx/mise/blob/main/src/plugins/core/deno.rs) ([lang/deno](https://mise.jdx.dev/lang/deno.html)).

```sh
mise use -g deno@1       # install deno 1.x
mise use -g deno@latest  # install latest deno
```

```toml
[tools]
deno = { version = "latest", install_env = { HTTPS_PROXY = "http://proxy.example" } }
```

| Item | Value |
| --- | --- |
| Tool options | `install_env` only |
| Dedicated settings | *(none documented)* |
| Idiomatic files | `.deno-version`, `package.json` ([configuration](https://mise.jdx.dev/configuration.html#idiomatic-version-files)) |
| List versions | `mise ls-remote deno` |

> **Gotcha:** avoid `deno upgrade` — mise will not be aware of the change ([lang/deno](https://mise.jdx.dev/lang/deno.html)).

---

### 10.8 Bun

Core plugin: [`src/plugins/core/bun.rs`](https://github.com/jdx/mise/blob/main/src/plugins/core/bun.rs) ([lang/bun](https://mise.jdx.dev/lang/bun.html)).

```sh
mise use -g bun@0.7     # install bun 0.7.x
mise use -g bun@latest  # install latest bun
```

```toml
[tools]
bun = { version = "latest", install_env = { HTTPS_PROXY = "http://proxy.example" } }
```

| Item | Value |
| --- | --- |
| Tool options | `install_env` only |
| Dedicated settings | *(none documented)* |
| Idiomatic files | `.bun-version`, `package.json` ([configuration](https://mise.jdx.dev/configuration.html#idiomatic-version-files)) |
| List versions | `mise ls-remote bun` |

> **Gotcha:** avoid `bun upgrade` — mise will not be aware of the change ([lang/bun](https://mise.jdx.dev/lang/bun.html)).

---

### 10.9 Erlang & Elixir (paired)

#### Erlang

Core plugin: [`src/plugins/core/erlang.rs`](https://github.com/jdx/mise/blob/main/src/plugins/core/erlang.rs) ([lang/erlang](https://mise.jdx.dev/lang/erlang.html)).

```sh
mise use -g erlang@26
mise ls-remote erlang
```

The plugin uses [**kerl**](https://github.com/kerl/kerl) under the hood to build erlang; see kerl's docs for build configuration ([lang/erlang](https://mise.jdx.dev/lang/erlang.html)).

```toml
[tools]
erlang = { version = "latest", install_env = { KERL_CONFIGURE_OPTIONS = "--without-javac" } }
```

**GitHub Actions Linux runners:** `ImageOS=ubuntu24`, `ImageOS=ubuntu22`, and `ImageOS=ubuntu20` map to the precompiled Erlang build targets `ubuntu-24.04`, `ubuntu-22.04`, `ubuntu-20.04`. In the default `erlang.compile` mode, **unsupported `ImageOS` values record the Erlang/OTP source archive as the platform's locked input**, so installs can reproduce the kerl fallback ([lang/erlang](https://mise.jdx.dev/lang/erlang.html)).

| Setting | Type / Default | Env | Meaning |
| --- | --- | --- | --- |
| `erlang.compile` | `boolean?` / none | `MISE_ERLANG_COMPILE` | `true` = compile from source; `false` = use precompiled; unset = precompiled if available |

#### Elixir

Core plugin: [`src/plugins/core/elixir.rs`](https://github.com/jdx/mise/blob/main/src/plugins/core/elixir.rs) ([lang/elixir](https://mise.jdx.dev/lang/elixir.html)).

> **Erlang is required to install elixir** — install both together ([lang/elixir](https://mise.jdx.dev/lang/elixir.html)):

```sh
mise use -g erlang elixir
```

```toml
[tools]
elixir = { version = "latest", install_env = { MIX_HOME = "~/.mix" } }
```

| Item | Value |
| --- | --- |
| Tool options | `install_env` only |
| Dedicated settings | *(none documented)* |
| Idiomatic file | `.exenv-version` ([configuration](https://mise.jdx.dev/configuration.html#idiomatic-version-files)) |

> **Uncertainty:** the Elixir page documents no OTP-version-pairing syntax (e.g. `1.16-otp-26`) and no setting to tie an Elixir build to a specific OTP major. The only documented coupling is that erlang must be installed. Verify against `mise ls-remote elixir` output on your machine before assuming an `-otp-N` suffix resolves.

---

### 10.10 Swift

Supported on **macOS and Linux** ([lang/swift](https://mise.jdx.dev/lang/swift.html)).

```sh
mise use -g swift
swift --version
```

```toml
[tools]
swift = { version = "latest", install_env = { HTTPS_PROXY = "http://proxy.example" } }
```

| Setting | Type / Default | Env | Meaning |
| --- | --- | --- | --- |
| `swift.gpg_verify` | `boolean?` / none | `MISE_SWIFT_GPG_VERIFY` | Verify OpenPGP signatures (**built-in, no external gpg required**); `false` disables |
| `swift.platform` | `string` / one of `"osx" \| "windows10" \| "ubuntu20.04" \| "ubuntu22.04" \| "ubuntu24.04" \| "amazonlinux2" \| "ubi9" \| "fedora39"` | `MISE_SWIFT_PLATFORM` | Override the platform used to select precompiled binaries |

Idiomatic file: `.swift-version` ([configuration](https://mise.jdx.dev/configuration.html#idiomatic-version-files)). Further reading: [a mise guide for Swift developers](https://tuist.dev/blog/2025/02/04/mise) ([lang/swift](https://mise.jdx.dev/lang/swift.html)).

> **Uncertainty:** the settings list documents `windows10` as a valid `swift.platform` value while the page's prose says "Swift is supported for macos and linux." Treat Windows support as undocumented.

---

### 10.11 Zig

Core plugin: [`src/plugins/core/zig.rs`](https://github.com/jdx/mise/blob/main/src/plugins/core/zig.rs) ([lang/zig](https://mise.jdx.dev/lang/zig.html)).

```sh
mise use -g zig@0.14           # install zig 0.14.x
mise use -g zig@latest         # install latest zig release
mise use -g zig@master         # install latest nightly from master
mise use -g zig@2024.11.0-mach # install Mach nominated zig
mise use -g zig@mach-latest    # install latest Mach nominated zig
```

#### Mach versions are hidden from `ls-remote`

[Mach](https://machengine.org/) versions **won't appear in `mise ls-remote zig`** due to a workaround for a [version ordering bug](https://github.com/jdx/mise/discussions/5232) — they're still installable. Enumerate them with ([lang/zig](https://mise.jdx.dev/lang/zig.html)):

```sh
curl https://machengine.org/zig/index.json | yq 'keys'
```

#### `master` (nightly channel)

`zig@master` tracks a moving nightly. mise resolves it to the concrete dev version it currently points at (e.g. `0.17.0-dev.836+...`) **at install time**, so the install lands in a versioned directory and `mise upgrade zig` / `mise outdated` pick up newer nightlies — rather than the channel staying pinned to the build it was first installed from. Advance with `mise upgrade zig` or `mise install -f zig@master` ([lang/zig](https://mise.jdx.dev/lang/zig.html)).

#### Language server (separate tool)

```sh
mise use -g zls@0.14   # install zls 0.14.x
mise use -g zls@latest # install latest zls release
```

> Use a tagged `zig` release with the **same** tagged `zls` release. **There is currently no Mach version of `zls`** ([lang/zig](https://mise.jdx.dev/lang/zig.html)).

#### Settings

| Setting | Type / Default | Env | Meaning |
| --- | --- | --- | --- |
| `zig.use_community_mirrors` | `boolean` / **`true`** | `MISE_ZIG_USE_COMMUNITY_MIRRORS` | Fetch Zig from community-maintained mirrors. ziglang.org offers no uptime/speed guarantees and recommends mirrors; the mirror list is cached so installs survive main-server outages. **Tarballs are always verified against the Zig Software Foundation's public key**, so there's no third-party-modification risk |

If the mirror list isn't cached locally, place a newline-separated server list inside `mise cache path`, folder `zig`, as `community-mirrors.txt`. More: [ziglang.org community mirrors](https://ziglang.org/download/community-mirrors/) ([lang/zig](https://mise.jdx.dev/lang/zig.html)).

Idiomatic file: `.zig-version` ([configuration](https://mise.jdx.dev/configuration.html#idiomatic-version-files)).

---

### 10.12 .NET

The core `dotnet` plugin installs **.NET SDKs using Microsoft's official install script**. All SDK versions install **side-by-side under a shared `DOTNET_ROOT`**, matching .NET's native multi-version model — so `dotnet --list-sdks` sees every version installed through mise. Like rust, SDKs don't live in `~/.local/share/mise/installs`; mise symlinks the install path to `DOTNET_ROOT` and sets env vars so the right SDK is picked up ([lang/dotnet](https://mise.jdx.dev/lang/dotnet.html)).

> This plugin manages the **.NET SDK**. For .NET global tools (e.g. `dotnet-ef`), use the [dotnet backend](https://mise.jdx.dev/dev-tools/backends/dotnet.html) with `dotnet:ToolName` syntax ([lang/dotnet](https://mise.jdx.dev/lang/dotnet.html)).

```sh
mise use -g dotnet@latest
mise use -g dotnet@8.0.400

# side-by-side multi-targeting
mise use dotnet@8
mise use dotnet@9
dotnet --list-sdks
```

#### `global.json`

```json
{
  "sdk": {
    "version": "8.0.100"
  }
}
```

```sh
mise settings set idiomatic_version_file_enable_tools=dotnet
```

([lang/dotnet](https://mise.jdx.dev/lang/dotnet.html))

#### Shared vs isolated

```sh
mise settings set dotnet.isolated=true
```

|  | Shared (default) | Isolated |
| --- | --- | --- |
| `dotnet --list-sdks` | All installed versions | Active version only |
| Install location | `DOTNET_ROOT` | `installs/dotnet/<version>/` |
| Multi-targeting | Works out of the box | Requires switching versions |

([lang/dotnet](https://mise.jdx.dev/lang/dotnet.html))

#### Runtime-only installs

```sh
mise use dotnet[runtime=dotnet]@8.0.14
dotnet --list-runtimes
```

| Value | Framework | Use case |
| --- | --- | --- |
| `dotnet` | `Microsoft.NETCore.App` | Console apps, libraries |
| `aspnetcore` | `Microsoft.AspNetCore.App` | ASP.NET Core web apps |
| `windowsdesktop` | `Microsoft.WindowsDesktop.App` | WPF / WinForms (Windows) |

```toml
[tools]
dotnet = ["9", { version = "8.0.14", runtime = "dotnet" }]
```

> **Gotchas** ([lang/dotnet](https://mise.jdx.dev/lang/dotnet.html)):
> - **Version numbers are runtime versions, not SDK versions.** `8.0.14` = .NET Runtime 8.0.14, not SDK 8.0.14. Check the [.NET release notes](https://github.com/dotnet/core/tree/main/release-notes).
> - Runtime-only installs exclude SDK build tools — `dotnet build`/`dotnet publish` are unavailable and `dotnet --version` won't report an SDK version.
> - **Only exact runtime versions are supported.** Channel syntax like `@8` is not supported for runtime installs, since it resolves against SDK versions.

#### Environment variables set by the plugin

| Variable | Value |
| --- | --- |
| `DOTNET_ROOT` | Shared SDK install directory (or install path if isolated) |
| `DOTNET_MULTILEVEL_LOOKUP` | `0` |
| `DOTNET_CLI_TELEMETRY_OPTOUT` | Only set when `dotnet.cli_telemetry_optout` is configured |

#### Settings

| Setting | Type / Default | Env | Meaning |
| --- | --- | --- | --- |
| `dotnet.cli_telemetry_optout` | `boolean?` / none | `MISE_DOTNET_CLI_TELEMETRY_OPTOUT` | `true` ⇒ `DOTNET_CLI_TELEMETRY_OPTOUT=1`; `false` ⇒ `0`; unset ⇒ mise doesn't set the variable at all |
| `dotnet.dotnet_root` | `string?` / none (→ `~/.local/share/mise/dotnet-root`) | `MISE_DOTNET_ROOT` | Shared side-by-side install directory |
| `dotnet.isolated` | `boolean` / `false` | `MISE_DOTNET_ISOLATED` | Per-version install dirs under mise's installs path |
| `dotnet.package_flags` **(deprecated)** | `string[]` / `[]` | `MISE_DOTNET_PACKAGE_FLAGS` (comma separated) | Legacy; only supported flag is `prerelease`. **Because it is global, remove it before relying on per-tool `prerelease = false` opt-outs.** Use the `prerelease = true` tool option or the global `prereleases` setting instead |
| `dotnet.registry_url` | `string` / `https://api.nuget.org/v3/index.json` | `MISE_DOTNET_REGISTRY_URL` | Feed used when installing dotnet **tools** |

([lang/dotnet](https://mise.jdx.dev/lang/dotnet.html))

---

### 10.13 Cookbook — C++

A CMake project driven entirely by mise tasks ([mise-cookbook/cpp](https://mise.jdx.dev/mise-cookbook/cpp.html)):

```toml
# mise.toml
min_version = "2024.9.5"

[env]
# Project information
PROJECT_NAME = "{{ config_root | basename }}"

# Build directory
BUILD_DIR = "{{ config_root }}/build"

[tools]
# Install CMake and make
cmake = "latest"
make = "latest"

[tasks.configure]
description = "Configure the project"
run = "mkdir -p $BUILD_DIR && cd $BUILD_DIR && cmake .."

[tasks.build]
description = "Build the project"
alias = "b"
run = "cd $BUILD_DIR && make"

[tasks.clean]
description = "Clean the build directory"
alias = "c"
run = "rm -rf $BUILD_DIR"

[tasks.run]
alias = "r"
description = "Run the application"
run = "$BUILD_DIR/bin/$PROJECT_NAME"

[tasks.info]
description = "Print project information"
run = '''
echo "Project: $PROJECT_NAME"
echo "Build Directory: $BUILD_DIR"
'''
```

Key ideas: `{{ config_root | basename }}` derives the project name from the directory; `$BUILD_DIR` is an `[env]` var consumed by every task; `alias` gives short task names (`mise b`).

---

### 10.14 Cookbook — Node.js

([mise-cookbook/nodejs](https://mise.jdx.dev/mise-cookbook/nodejs.html))

#### Put `node_modules/.bin` on PATH

Locally-installed CLIs normally need `npx`. One `[env]` directive fixes it:

```toml
# mise.toml
[env]
_.path = ['{{config_root}}/node_modules/.bin']
```

```shell
npm install --save eslint
eslint --version # works
```

#### Full example project

```toml
# mise.toml
min_version = "2024.9.5"

[env]
_.path = ['{{config_root}}/node_modules/.bin']

# Use the project name derived from the current directory
PROJECT_NAME = "{{ config_root | basename }}"

# Set up the path for node module binaries
BIN_PATH = "{{ config_root }}/node_modules/.bin"

NODE_ENV = "{{ env.NODE_ENV | default(value='development') }}"

[tools]
# Install Node.js using the specified version
node = "{{ env['NODE_VERSION'] | default(value='lts') }}"

# Install some npm packages globally if needed
"npm:typescript" = "latest"
"npm:eslint" = "latest"
"npm:jest" = "latest"

[tasks.install]
alias = "i"
description = "Install npm dependencies"
run = "npm install"

[tasks.start]
alias = "s"
description = "Start the development server"
run = "npm run start"

[tasks.lint]
alias = "l"
description = "Run ESLint"
run = "eslint src/"

[tasks.test]
description = "Run tests"
alias = "t"
run = "jest"

[tasks.build]
description = "Build the project"
alias = "b"
run = "npm run build"

[tasks.info]
description = "Print project information"
run = '''
echo "Project: $PROJECT_NAME"
echo "NODE_ENV: $NODE_ENV"
'''
```

#### pnpm + corepack + incremental installs

```toml
# mise.toml
[tools]
node = '24'

[hooks]
# Enabling corepack will install the `pnpm` package manager specified in your package.json
# alternatively, you can also install `pnpm` with mise
postinstall = 'npx corepack enable'

[settings]
# This must be enabled to make the hooks work
experimental = true

[env]
_.path = ['{{config_root}}/node_modules/.bin']

[tasks.pnpm-install]
description = 'Installs dependencies with pnpm'
run = 'pnpm install'
sources = ['package.json', 'pnpm-lock.yaml', 'mise.toml']
outputs = ['node_modules/.pnpm/lock.yaml']

[tasks.dev]
description = 'Calls your dev script in `package.json`'
run = 'node --run dev'
depends = ['pnpm-install']
```

> ⚠️ **`[hooks]` requires `experimental = true`** — the recipe states this explicitly ([mise-cookbook/nodejs](https://mise.jdx.dev/mise-cookbook/nodejs.html)).

With this, `mise dev` installs the right Node, enables corepack, runs `pnpm install` (skipped when `sources` are unchanged), then `node --run dev`.

---

### 10.15 Cookbook — Python

([mise-cookbook/python](https://mise.jdx.dev/mise-cookbook/python.html))

#### Project with a plain virtualenv

```toml
# mise.toml
min_version = "2024.9.5"

[env]
# Use the project name derived from the current directory
PROJECT_NAME = "{{ config_root | basename }}"

# Automatic virtualenv activation
_.python.venv = { path = ".venv", create = true }

[tools]
python = "{{ get_env(name='PYTHON_VERSION', default='3.11') }}"
ruff = "latest"

[tasks.install]
description = "Install dependencies"
alias = "i"
run = "uv pip install -r requirements.txt"

[tasks.run]
description = "Run the application"
run = "python app.py"

[tasks.test]
description = "Run tests"
run = "pytest tests/"

[tasks.lint]
description = "Lint the code"
run = "ruff src/"

[tasks.info]
description = "Print project information"
run = '''
echo "Project: $PROJECT_NAME"
echo "Virtual Environment: $VIRTUAL_ENV"
'''
```

#### mise + uv

Given a `uv init .` project (`.python-version`, `pyproject.toml`, `uv.lock`), mise detects the `.python-version` but **does not use uv's venv by default** — `which python` shows the global mise install:

```shell
mise i
which python
# ~/.local/share/mise/installs/python/3.12.4/bin/python
```

Fix it with the setting:

```toml
# mise.toml
[settings]
python.uv_venv_auto = "source"
# or, to create if missing
# python.uv_venv_auto = "create|source"
```

```shell
which python
# ./uv-project/.venv/bin/python
```

> If you prefer `mise deps` to create the venv, keep `python.uv_venv_auto = "source"`, enable `[deps.uv]`, and run `mise deps` ([mise-cookbook/python](https://mise.jdx.dev/mise-cookbook/python.html)).

Alternative, pointing `_.python.venv` at uv's directory:

```toml
# mise.toml
[env]
_.python.venv = { path = ".venv" }
```

Sync mise's and uv's Python versions with [`mise sync python --uv`](https://mise.jdx.dev/cli/sync/python.html#uv) ([mise-cookbook/python](https://mise.jdx.dev/mise-cookbook/python.html)).

#### uv inline-script tasks

`uv run` works as a task [shebang](https://mise.jdx.dev/tasks/toml-tasks.html#shell-shebang). **`--script` is required if the filename doesn't end in `.py`.**

```toml
# mise.toml
[tools]
uv = 'latest'

[tasks.print_peps]
run = '''
#!/usr/bin/env -S uv run --script
# /// script
# dependencies = ["requests<3", "rich"]
# ///

import requests
from rich.pretty import pprint

resp = requests.get("https://peps.python.org/api/peps.json")
data = resp.json()
pprint([(k, v["title"]) for k, v in data.items()][:10])
'''
```

The same content works as a file task at `mise-tasks/print_peps.py`, run with `mise run print_peps` ([mise-cookbook/python](https://mise.jdx.dev/mise-cookbook/python.html)).

---

### 10.16 Cookbook — Ruby

A Rails project ([mise-cookbook/ruby](https://mise.jdx.dev/mise-cookbook/ruby.html)):

```toml
# mise.toml
min_version = "2024.9.5"

[env]
# Project information
PROJECT_NAME = "{{ config_root | basename }}"

[tools]
# Install Ruby with the specified version
ruby = "{{ get_env(name='RUBY_VERSION', default='3.3.3') }}"

[tasks."bundle:install"]
description = "Install gem dependencies"
run = "bundle install"

[tasks.server]
description = "Start the Rails server"
alias = "s"
run = "rails server"

[tasks.test]
description = "Run tests"
alias = "t"
run = "rails test"

[tasks.lint]
description = "Run lint using Rubocop"
alias = "l"
run = "rubocop"
```

Note the `get_env(name=…, default=…)` template function for a CI-overridable Ruby version, and quoted namespaced task names (`[tasks."bundle:install"]`).

---

### 10.17 Cookbook — Terraform / OpenTofu

Terraform config often lives in a `terraform/` subdirectory, forcing `terraform -chdir=terraform …`. Wrap it in tasks ([mise-cookbook/terraform](https://mise.jdx.dev/mise-cookbook/terraform.html)):

```toml
# mise.toml
[tools]
terraform = "1"

[tasks."terraform:init"]
description = "Initializes a Terraform working directory"
run = "terraform -chdir=terraform init"

[tasks."terraform:plan"]
description = "Generates an execution plan for Terraform"
run = "terraform -chdir=terraform plan"

[tasks."terraform:apply"]
description = "Applies the changes required to reach the desired state of the configuration"
run = "terraform -chdir=terraform apply"

[tasks."terraform:destroy"]
description = "Destroy Terraform-managed infrastructure"
run = "terraform -chdir=terraform destroy"

[tasks."terraform:validate"]
description = "Validates the Terraform files"
run = "terraform -chdir=terraform validate"

[tasks."terraform:format"]
description = "Formats the Terraform files"
run = "terraform -chdir=terraform fmt"

[tasks."terraform:check"]
description = "Checks the Terraform files"
depends = ["terraform:format", "terraform:validate"]

[env]
_.file = ".env"
```

`terraform:check` is a **dependency-only task** (no `run`) that fans out to format + validate; `_.file = ".env"` loads a dotenv file for credentials.

---

### 10.18 Cookbook — Docker

([mise-cookbook/docker](https://mise.jdx.dev/mise-cookbook/docker.html))

#### Base image with mise

```dockerfile
FROM debian:13-slim

RUN apt-get update  \
    && apt-get -y --no-install-recommends install  \
        # install any other dependencies you might need
        sudo curl git ca-certificates build-essential \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV MISE_DATA_DIR="/mise"
ENV MISE_CONFIG_DIR="/mise"
ENV MISE_CACHE_DIR="/mise/cache"
ENV MISE_INSTALL_PATH="/usr/local/bin/mise"
ENV PATH="/mise/shims:$PATH"
# ENV MISE_VERSION="..."

RUN curl https://mise.run | sh
```

```shell
docker build -t debian-mise .
docker run -it --rm debian-mise
```

#### Shared, multi-user tool installs

`mise install --system` installs into `/usr/local/share/mise/installs`; every user's mise finds these with **no configuration**:

```dockerfile
# syntax=docker/dockerfile:1
FROM debian:13-slim

RUN <<EOF
  set -ex
  apt-get update
  apt-get install -y extrepo
  extrepo enable mise
  apt-get remove -y --auto-remove extrepo # extrepo and its deps are not needed after extrepo enable
  apt-get update
  apt-get install -y mise build-essential
  rm -fr /var/lib/apt/lists/*
EOF

# Pre-install tools to the system-wide shared directory
RUN mise install --system node@26 python@3.15
```

```shell
$ mise ls
node    26.0.0 (system)
python  3.15.0 (system)
```

| Knob | Meaning |
| --- | --- |
| `MISE_SYSTEM_DATA_DIR` | Customise the system-wide directory |
| `MISE_SHARED_INSTALL_DIRS` / `shared_install_dirs` setting | Additional shared directories; separator is `:` on Unix, `;` on Windows |

**Note:** with the `extrepo` approach you **cannot** specify `MISE_VERSION` or `MISE_INSTALL_PATH`. User-installed versions take priority over system versions ([mise-cookbook/docker](https://mise.jdx.dev/mise-cookbook/docker.html)).

#### Devcontainers with home-directory mounts

Devcontainers often mount `~`, which hides anything baked into `~/.local/share/mise/installs` at build time. `mise install --system` writes to `/usr/local/share/mise/installs`, outside `~`, so it survives the mount. Tools users install later go to the mounted `~/.local/share/mise/installs` and take priority ([mise-cookbook/docker](https://mise.jdx.dev/mise-cookbook/docker.html)).

#### Overriding libc detection in minimal images

In scratch/busybox/distroless images with no dynamic-linker files, mise may fail to detect musl vs glibc:

```dockerfile
ENV MISE_LIBC=musl
RUN mise install
```

Valid values: `musl`, `glibc`, `gnu` (case-insensitive; `gnu` = glibc). **Invalid values are silently ignored** and mise falls back to runtime detection. A musl-compiled mise binary (the default for Linux releases) also falls back to musl when no linker is detected ([mise-cookbook/docker](https://mise.jdx.dev/mise-cookbook/docker.html)). Recall from §10.1 that `libc=musl` also selects Node's musl flavor when `node.flavor` is unset.

#### Reproducing bugs in a clean container

```toml
# mise.toml
[tasks.docker]
run = "docker run -it --rm debian-mise"
```

```shell
❯ mise docker
[docker] $ docker run -it --rm debian-mise
root@75f179a190a1:/# eval "$(mise activate bash)"
# overwrite configuration and prune to give us a clean state
root@75f179a190a1:/# echo "" > /mise/config.toml
root@75f179a190a1:/# mise prune --yes
```

---

### 10.19 Cookbook — Neovim

([mise-cookbook/neovim](https://mise.jdx.dev/mise-cookbook/neovim.html))

Three integrations, all Treesitter-based:

| Goal | Mechanism | File |
| --- | --- | --- |
| Highlight embedded code in `run = '''…'''` | TS injection query keyed on the `run` bare key | `after/queries/toml/injections.scm` |
| Highlight `#MISE` (TOML) and `#USAGE` (KDL) comments in file tasks | TS injection query on comments | `after/queries/<lang>/injections.scm` |
| LSP + completion for embedded code | [otter.nvim](https://github.com/jmbuhr/otter.nvim) activated on `toml` filetype | lazy.nvim spec |

#### Run-command injection

```query
; extends

(pair
  (bare_key) @key (#eq? @key "run")
  (string) @injection.content @injection.language

  (#is-mise?)
  (#match? @injection.language "^['\"]{3}\n*#!(/\\w+)+/env\\s+\\w+") ; multiline shebang using env
  (#gsub! @injection.language "^.*#!/.*/env%s+([^%s]+).*" "%1") ; extract lang
  (#offset! @injection.content 0 3 0 -3) ; rm quotes
)

(pair
  (bare_key) @key (#eq? @key "run")
  (string) @injection.content

  (#is-mise?)
  (#not-match? @injection.content "^['\"]{3}") ; not multiline
  (#offset! @injection.content 0 1 0 -1) ; rm quotes
  (#set! injection.language "bash") ; default to bash
)
```

The `(#is-mise?)` predicate restricts highlighting to mise files; drop those lines to apply to all TOML. Define the predicate yourself, e.g. with lazy.nvim:

```lua
{
  "nvim-treesitter/nvim-treesitter",
  init = function()
    require("vim.treesitter.query").add_predicate("is-mise?", function(_, _, bufnr, _)
      local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
      local filename = vim.fn.fnamemodify(filepath, ":t")
      return string.match(filename, ".*mise.*%.toml$") ~= nil
    end, { force = true, all = false })
  end,
},
```

This treats any TOML file with `mise` in its name as a mise file.

#### `#MISE` / `#USAGE` comment injection

```query
; extends

; #MISE format — offset skips the "#MISE " prefix (6 chars)
((comment) @injection.content
  (#lua-match? @injection.content "^#MISE ")
  (#offset! @injection.content 0 6 0 1)
  (#set! injection.language "toml"))

; #USAGE format — combined so consecutive comments form one KDL block
((comment) @injection.content
  (#lua-match? @injection.content "^#USAGE ")
  (#offset! @injection.content 0 7 0 1)
  (#set! injection.combined)
  (#set! injection.language "kdl"))
```

Recognised prefixes: `#MISE `, `#[MISE] `, `# [MISE] ` (offsets 6/8/9) and `#USAGE `, `#[USAGE] `, `# [USAGE] ` (offsets 7/9/10). For `//`-comment languages the offsets shift by one (7/9/10 and 8/10/11) ([mise-cookbook/neovim](https://mise.jdx.dev/mise-cookbook/neovim.html)).

> **Version-sensitive:** injections are **per language**, so the same queries must be copied into each language's query file (`after/queries/python/injections.scm`, etc.). On **neovim ≥ 0.12** you can use the multi-node pattern `((comment)+ @injection.content …)` instead of `(#set! injection.combined)` — the preferred way, since combined injections have [multiple limitations](https://github.com/neovim/neovim/issues/32635) ([mise-cookbook/neovim](https://mise.jdx.dev/mise-cookbook/neovim.html)).

#### LSP for embedded code

```lua
{
  "jmbuhr/otter.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    vim.api.nvim_create_autocmd({ "FileType" }, {
      pattern = { "toml" },
      group = vim.api.nvim_create_augroup("EmbedToml", {}),
      callback = function()
        require("otter").activate()
      end,
    })
  end,
},
```

> Only works if the TS injection queries above are also set up ([mise-cookbook/neovim](https://mise.jdx.dev/mise-cookbook/neovim.html)).

---

### 10.20 Cookbook — Presets (project scaffolding)

Presets are just [mise tasks](https://mise.jdx.dev/tasks/) that write config, cutting per-project boilerplate ([mise-cookbook/presets](https://mise.jdx.dev/mise-cookbook/presets.html)).

`~/.config/mise/tasks/preset/python`:

```shell
#!/usr/bin/env bash
#MISE dir="{{cwd}}"

mise use pre-commit
mise config set env._.python.venv.path .venv
mise config set env._.python.venv.create true -t bool
mise tasks add lint -- pre-commit run -a
```

`~/.config/mise/tasks/preset/pdm`:

```shell
#!/usr/bin/env bash
#MISE dir="{{cwd}}"
#MISE depends=["preset:python"]
#USAGE arg "<version>"

mise use python@${usage_version?}
mise use pdm@latest
mise config set hooks.postinstall "pdm sync"
```

Then in any directory:

```shell
cd my-project
mise preset:pdm 3.10
```

Generated `mise.toml`:

```toml
[tools]
pdm = "latest"
pre-commit = "latest"
python = "3.10"

[hooks]
postinstall = "pdm sync"

[env]
[env._]
[env._.python]
[env._.python.venv]
path = ".venv"
create = true

[tasks.lint]
run = "pre-commit run -a"
```

Techniques worth stealing: `#MISE dir="{{cwd}}"` makes the task operate on the invoking directory; `#MISE depends=[…]` chains presets; `#USAGE arg "<version>"` exposes the argument as `$usage_version`; `mise config set … -t bool` writes a typed TOML value.

---

### 10.21 Cookbook — Shell tricks

([mise-cookbook/shell-tricks](https://mise.jdx.dev/mise-cookbook/shell-tricks.html))

#### Colour the ZSH prompt when mise changes the environment

```shell
# activate mise like normal
source <(command mise activate zsh)

typeset -i _mise_updated

# replace default mise hook
function _mise_hook {
  local diff=${__MISE_DIFF}
  source <(command mise hook-env -s zsh)
  [[ ${diff} == ${__MISE_DIFF} ]]
  _mise_updated=$?
}

_PROMPT="❱ "  # or _PROMPT=${PROMPT} to keep the default

function _prompt {
  if (( ${_mise_updated} )); then
    PROMPT='%F{blue}${_PROMPT}%f'
  else
    PROMPT='%(?.%F{green}${_PROMPT}%f.%F{red}${_PROMPT}%f)'
  fi
}

add-zsh-hook precmd _prompt
```

The trick is comparing `__MISE_DIFF` before and after `mise hook-env`.

#### `MISE_ENV` in a powerline-go prompt

Include `shell-var` in `-modules` and pass `-shell-var MISE_ENV -shell-var-no-warn-empty`, and make sure `MISE_ENV` is exported so powerline-go can see it.

> **Gotcha (as of February 2025):** the `shell-var` module does not tolerate *unset* (as opposed to empty) variables. Work around it by setting `MISE_ENV` to empty early in shell startup and never `unset`-ing it ([mise-cookbook/shell-tricks](https://mise.jdx.dev/mise-cookbook/shell-tricks.html)):

```bash
export MISE_ENV=
```

#### Decode `__MISE_DIFF` to see what the hook changed

```toml
# ~/.config/mise/config.toml
[tools]
"cargo:record-query" = "latest"
```

```shell
function mise_parse_env {
  rq -m < <(
    zcat -q < <(
      printf '\x1f\x8b\x08\x00\x00\x00\x00\x00'
      base64 -d <<< "$1"
    )
  )
}
```

```shell
$ mise_parse_env "${__MISE_DIFF}"
{
  "new": { ... },
  "old": { ... },
  "path": [ ... ]
}
```

`__MISE_DIFF` is base64-encoded gzip data with the header stripped — hence the manual gzip magic bytes ([mise-cookbook/shell-tricks](https://mise.jdx.dev/mise-cookbook/shell-tricks.html)).

---

### 10.22 Cookbook index & contributing

The [cookbook index](https://mise.jdx.dev/mise-cookbook/) links: [C++](https://mise.jdx.dev/mise-cookbook/cpp.html), [Docker](https://mise.jdx.dev/mise-cookbook/docker.html), [Node.JS](https://mise.jdx.dev/mise-cookbook/nodejs.html), [Python](https://mise.jdx.dev/mise-cookbook/python.html), [Ruby](https://mise.jdx.dev/mise-cookbook/ruby.html), [Terraform](https://mise.jdx.dev/mise-cookbook/terraform.html), [Neovim](https://mise.jdx.dev/mise-cookbook/neovim.html), plus [presets](https://mise.jdx.dev/mise-cookbook/presets.html) and [shell tricks](https://mise.jdx.dev/mise-cookbook/shell-tricks.html). Contributions go to the [cookbook discussion thread](https://github.com/jdx/mise/discussions/3645) ([mise-cookbook](https://mise.jdx.dev/mise-cookbook/)).

---

## Sources

All claims above are cited inline against the page that owns them. The primary source set is the
official mise documentation at <https://mise.jdx.dev>, accessed 31 Jul 2026 (mise 2026.7.x):

| Area | Entry point |
| --- | --- |
| Overview & install | <https://mise.jdx.dev/getting-started.html>, <https://mise.jdx.dev/installing-mise.html>, <https://mise.jdx.dev/walkthrough.html> |
| Configuration | <https://mise.jdx.dev/configuration.html>, <https://mise.jdx.dev/configuration/settings.html>, <https://mise.jdx.dev/configuration/environments.html> |
| Dev tools | <https://mise.jdx.dev/dev-tools/>, <https://mise.jdx.dev/dev-tools/mise-lock.html>, <https://mise.jdx.dev/dev-tools/tool-stubs.html> |
| Backends & registry | <https://mise.jdx.dev/dev-tools/backends/>, <https://mise.jdx.dev/registry.html> |
| Bootstrap | <https://mise.jdx.dev/bootstrap.html>, <https://mise.jdx.dev/bootstrap/packages/>, <https://mise.jdx.dev/dotfiles.html> |
| Environments & secrets | <https://mise.jdx.dev/environments/>, <https://mise.jdx.dev/environments/secrets/>, <https://mise.jdx.dev/hooks.html> |
| Tasks | <https://mise.jdx.dev/tasks/>, <https://mise.jdx.dev/tasks/toml-tasks.html>, <https://mise.jdx.dev/tasks/task-arguments.html> |
| Plugins | <https://mise.jdx.dev/plugins.html>, <https://mise.jdx.dev/tool-plugin-development.html>, <https://mise.jdx.dev/plugin-lua-modules.html> |
| Integration | <https://mise.jdx.dev/continuous-integration.html>, <https://mise.jdx.dev/ide-integration.html>, <https://mise.jdx.dev/mcp.html> |
| Languages & cookbook | <https://mise.jdx.dev/lang/node.html> (and siblings), <https://mise.jdx.dev/mise-cookbook/> |
| CLI reference | <https://mise.jdx.dev/cli/> |

Secondary/first-party sources used where the docs were incomplete, cited inline at the point of use:
the `jdx/mise` source repository (<https://github.com/jdx/mise>) and the `jdx/mise-action` README
(<https://github.com/jdx/mise-action>).
