# Research — reconciling self-updating tools with a pinned, quarantined toolchain

`mise.lock` + `minimum_release_age = "7d"` vs. AI CLIs and VS Code that update themselves · 2 Aug 2026

## Question

This repo declares ~42 tools in `mise`, commits `mise.lock`, and quarantines every
fuzzy resolution for seven days. Several of those tools — Claude Code, Codex,
Gemini CLI, Copilot CLI — ship their own updater, and so does VS Code. Is
reconciling the two a solved problem, and if so what is the established design?

Scope: what shipped, in first-party sources, as of 2 Aug 2026. Not opinion pieces.

## Answer

**Yes, twice over, and the two answers are separate.**

**Ownership** is the answer to self-updaters, and this repo already wrote it down:
ADR 0002 retired `packages/vscode.txt` because Settings Sync and a package list
were "two owners of the same state". A vendor updater beside `mise.lock` is the
same defect. Every vendor here except one documents an off switch — Claude Code
`DISABLE_UPDATES`, Codex `check_for_update_on_startup`, Gemini
`general.enableAutoUpdate`, Copilot `autoUpdate`, VS Code `update.mode` — so the
rule "whoever installs it, owns updating it" is enforceable rather than advisory.
[^s2][^s7][^s9][^s11][^s13]

**Cooldown** is the answer to supply chain, and it is now standard: all four JS
package managers, both update bots, both Python installers and Homebrew ship one,
several on by default. [^e7][^e9][^e15][^e18][^e19][^e21][^e23] Every one of them
uses the same exemption design — a global floor plus a named allowlist — so the
7d floor here is conventional, not exotic. [^e1][^e12][^e16]

Two findings change what this repo should do. First, the ecosystem has already hit
the `lock --bump` rollback and rejected it: Renovate's `internalChecksFilter`
defaults to `strict` specifically to stop version "flapping", and the documented
answer is **skip, don't downgrade**. [^e2] mise has no `strict` — `--bump` is
permanently `flexible` [^m31][^m32] — so the mitigation has to be procedural.
Second, **vendors ship better cooldowns than a blind age gate**: Claude Code's
`autoUpdatesChannel: "stable"` is ~1 week old *and skips releases with known major
regressions* [^s20]; VS Code delays extension updates 2 hours by default, with
supply-chain quarantine as the stated rationale [^s37]. An age gate has no quality
signal, which is exactly why `--bump` offered uv 0.12.1 → 0.11.32.

> **Uncertainty:** no source compares "age gate + lockfile" against "vendor stable
> channel". Both are defensible; the sources do not rank them.

## Tools that update themselves

Five of the tools in this repo ship their own updater. Four of the five have a documented off switch; one class (Homebrew) has no auto-upgrade to switch off in the first place, and no release-age control of any kind. The two AI CLIs the user is most likely to install through mise — Codex and Gemini CLI — are the ones whose updaters are *conditional on install method*, which is where the mise interaction bites.

### Summary table

| Tool | Auto-updates by default? | Documented disable switch | Verifies its own updates? |
| --- | --- | --- | --- |
| **Claude Code** — native installer (`install.sh`) | **Yes.** Checks on startup and periodically; installs in the background; takes effect next launch[^s1] | `DISABLE_AUTOUPDATER=1` (background only) or `DISABLE_UPDATES=1` (blocks `claude update`/`claude install` too)[^s2] | **Yes.** Per-release `manifest.json` of SHA-256 checksums, detached GPG signature, key fingerprint `31DD DE24 DDFA B679 F42D 7BD2 BAA9 29FF 1A7E CACE`; macOS notarized, Windows Authenticode; Linux binaries not individually code-signed[^s3] |
| **Claude Code** — Homebrew / WinGet / apt / dnf / apk / npm | **No** (opt-in for brew+winget via `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE=1`)[^s4] | n/a (already off) | apt/dnf/apk repos signed with the same release key[^s5] |
| **OpenAI Codex CLI** | **No silent install.** Checks on startup (`check_for_update_on_startup`, default `true`) and shows a notice / update prompt; the update itself is user-confirmed[^s6] | `check_for_update_on_startup = false` in `config.toml` — **present in source, absent from the shipped `docs/`**[^s7] | Sources silent — no first-party integrity documentation found for the CLI's own update path |
| **Gemini CLI** | **Conditional.** `general.enableAutoUpdate` defaults `true`, but the updater returns early for `BINARY`, `npx`, `pnpx`, `bunx` installs, and Homebrew/git-clone installs get a message rather than a command[^s8] | `general.enableAutoUpdate: false` (stops the install); `general.enableAutoUpdateNotification: false` (stops the check entirely)[^s9] | No. The "update" is `spawn("npm install -g @google/gemini-cli@<version>", {shell:true, detached:true})` — integrity is whatever npm gives you[^s10] |
| **GitHub Copilot CLI** | **Yes.** `autoUpdate` defaults `true` ("Automatically download CLI updates")[^s11] | `"autoUpdate": false` in `~/.copilot/settings.json`[^s11] | Not documented. GitHub's CLI reference and config-dir reference describe an "auto-update packages" cache directory but state no signature or checksum check[^s12] |
| **VS Code** (application) | **Yes.** `update.mode` defaults to `"default"` = "check for updates automatically and periodically"[^s13] | `update.mode`: `"none"` \| `"manual"` \| `"start"` \| `"default"`; also a Group Policy named `UpdateMode` since 1.67[^s13] | **Yes on Windows** — the downloaded package is checksum-verified against `update.sha256hash` before it is moved into place[^s14] |
| **VS Code** (extensions) | **Yes.** `extensions.autoUpdate` defaults `"on"`; `extensions.autoCheckUpdates` defaults `true`[^s15] | `extensions.autoUpdate: "off"` and/or `extensions.autoCheckUpdates: false`[^s15] | **Yes.** `extensions.verifySignature` defaults `true`: "extensions are verified to be signed before getting installed"[^s16] |
| **Homebrew** | **No** — brew never upgrades installed packages by itself. What is automatic is a metadata refresh (`brew update`) before `install`/`upgrade`/`tap`[^s17] | `HOMEBREW_NO_AUTO_UPDATE` (kills it) or `HOMEBREW_AUTO_UPDATE_SECS` (raise the interval; default `86400`)[^s17] | Per-package SHA-256 in the formula/cask, plus optional build-provenance attestations (`HOMEBREW_VERIFY_ATTESTATIONS`, `brew verify`)[^s18] |

**Tools with no documented pin-or-disable path:** none of the five is fully undocumented, but two are close:
- **Codex CLI** — the only knob (`check_for_update_on_startup`) is real in the source tree and in the MDM `managed_config.toml` layer, but it does not appear anywhere in the repository's `docs/config.md`. Treat it as an undocumented-but-real setting.[^s7]
- **GitHub Copilot CLI** — `autoUpdate: false` is documented, but there is **no documented enterprise-managed key for updates**. GitHub's enterprise-managed settings reference covers permissions, model, plugin marketplaces, and telemetry — not update behaviour. A fleet cannot centrally forbid Copilot CLI from self-updating.[^s19]

### 1. Claude Code

Auto-update is on by default for the native installer only, and Anthropic says so explicitly: "Native installations automatically update in the background to keep you on the latest version."[^s1] Updates land under `~/.local/share/claude/versions/` with `~/.local/bin/claude` as a symlink into it — which is exactly the path that mise cannot see.[^s1]

The control surface is unusually rich for a CLI, and is worth using rather than fighting:

- `DISABLE_AUTOUPDATER=1` — "disable automatic background updates. Manual `claude update` still works."[^s2]
- `DISABLE_UPDATES=1` — "block all updates including manual `claude update` and `claude install`. Stricter than `DISABLE_AUTOUPDATER`. Use when distributing Claude Code through your own channels and users should not self-update."[^s2] This is the setting written for exactly this repo's situation.
- `FORCE_AUTOUPDATE_PLUGINS=1` — plugin auto-updates continue even when `DISABLE_AUTOUPDATER` is set; note that disabling the binary updater does **not** by itself freeze plugins.[^s2]
- `autoUpdatesChannel` — `"latest"` (default) or `"stable"`, where stable "is typically about one week old and skips versions with major regressions."[^s20] **This is a vendor-supplied cooldown of roughly the same magnitude as the repo's `minimum_release_age = "7d"`.**
- `minimumVersion` — a floor that background updates and `claude update` refuse to go below; `requiredMinimumVersion` / `requiredMaximumVersion` in managed settings make Claude Code refuse to *start* outside a range.[^s20]

Officially supported managed/fleet install paths: `managed-settings.json` in `/etc/claude-code/` on Linux (plus a `managed-settings.d/` drop-in directory merged systemd-style), macOS `com.anthropic.claudecode` plist, Windows `HKLM\SOFTWARE\Policies\ClaudeCode`, and server-managed settings from the admin console.[^s21] Managed settings cannot be overridden by user or project settings.[^s21]

Anthropic also ships signed apt/dnf/apk repositories and a two-channel split (`stable`, `latest`) at the repository level, plus per-release signed manifests. Manifest signatures exist from `2.1.89` onward; earlier releases publish checksums without a detached signature.[^s3]

### 2. OpenAI Codex CLI

Codex does not silently replace itself. On startup it optionally fetches the latest version and, if newer, renders an update notice and an update prompt; the actual update runs a command chosen from the detected install method.[^s6] The commands are fixed per method: `npm install -g @openai/codex`, `bun install -g …`, `pnpm add -g …`, `brew upgrade --cask codex`, or re-running the `chatgpt.com/codex/install.sh` installer with `CODEX_NON_INTERACTIVE=1`.[^s22]

The install-method detection matters for mise. `InstallMethod::Other` is returned for "`cargo run`, app-bundled Codex binaries, custom internal launchers, and tests that execute Codex from an arbitrary path"; standalone detection requires the binary to live under `$CODEX_HOME/packages/standalone/releases/`, and Brew detection requires macOS + `/opt/homebrew` or `/usr/local`.[^s23] A mise-installed Codex at `~/.local/share/mise/installs/...` matches none of these, so `get_update_action()` returns `None` and no update command is offered — only the version notice.[^s24] *[INFERENCE from the detection source; not stated in Codex docs.]*

The disable switch is `check_for_update_on_startup`, default `true`, read from `config.toml`, and overridable through the MDM/legacy `managed_config.toml` requirements layer (the source's own test fixture sets it to `false` with source `LegacyManagedConfigTomlFromMdm`).[^s25] It is not in the repository's `docs/`.[^s7] There is a `codex doctor` view that reports "check for update on startup", "update action", "latest version", and "cached latest version"/"last checked at".[^s26]

No first-party statement was found about signature or checksum verification of Codex's own update. The repository does publish a **DotSlash** file per GitHub Release, which OpenAI describes as making it "possible to make a lightweight commit to source control to ensure all contributors use the same version of an executable, regardless of what platform they use for development."[^s27] That is the closest thing Codex has to an officially supported pinned/fleet install path — and it is a pinning mechanism, not an update mechanism.

### 3. Gemini CLI and GitHub Copilot CLI

**Gemini CLI.** Two independent settings gate the behaviour: `general.enableAutoUpdateNotification` (default `true`) gates the *check*, and `general.enableAutoUpdate` (default `true`) gates the *install*.[^s9] Turning off the notification setting short-circuits both the update check and the auto-update handler.[^s28] Both keys were renamed: `general.disableAutoUpdate` → `general.enableAutoUpdate` (value inverted) and `general.disableUpdateNag` → `general.enableAutoUpdateNotification`, with in-place migration.[^s29]

The install-method logic is the part that matters here. `handleAutoUpdate` returns early — no update, no message — for `NPX`, `PNPX`, `BUNX`, and `BINARY`.[^s8] `BINARY` is detected from `process.env.IS_BINARY === 'true'`, which the single-executable launcher sets on itself (`sea-launch.cjs`: `process.env.IS_BINARY = 'true'`).[^s30] So an official standalone build self-identifies and declines to update. **But the fallback branch is "assume global npm"** — any binary whose realpath matches none of the npx/pnpm/yarn/bun/volta/homebrew patterns is treated as a global npm install with update command `npm install -g @google/gemini-cli@latest`.[^s31] If a non-SEA `gemini` binary ends up on PATH via a tool manager, the auto-updater's remedy is to shell out to `npm install -g`, which installs a second copy that the tool manager does not own. Auto-update is also suppressed in sandbox mode, and the CLI refuses to move from a more-stable to a less-stable release channel.[^s32]

Fleet path: system-wide settings at `/etc/gemini-cli/settings.json` (Linux) act as **overrides taking precedence over all other settings**, and `/etc/gemini-cli/system-defaults.json` is the lowest-precedence base layer.[^s33] Setting `general.enableAutoUpdate: false` in the system settings file is the documented way to enforce this for all users on a machine.

**GitHub Copilot CLI.** `autoUpdate` (boolean, default `true`, "Automatically download CLI updates") and `autoUpdatesChannel` (`"stable"` | `"prerelease"`, default `"stable"`) live in `~/.copilot/settings.json`, relocatable with `COPILOT_HOME`.[^s11] Manual paths are `copilot update` ("Download and install the latest version") and `copilot version` ("Display version information and check for updates").[^s34] The install script accepts a `VERSION` environment variable for pinning (`VERSION="v0.0.369" PREFIX="$HOME/custom" bash`), which is the only documented pinned-install path.[^s35] Note the update cache lives outside `COPILOT_HOME`, at `$XDG_CACHE_HOME/copilot` or `~/.cache/copilot` on Linux.[^s36] Nothing in GitHub's first-party reference states that Copilot CLI verifies signatures or checksums on its self-update, and update behaviour is absent from the enterprise-managed settings reference.[^s19]

### 4. VS Code

`update.mode` is registered with `enum: ['none', 'manual', 'start', 'default']`, `default: 'default'`, at `ConfigurationScope.APPLICATION`, and carries a Group Policy binding named `UpdateMode` (minimum version 1.67).[^s13] The enum descriptions are:

- `none` — "Disable updates."
- `manual` — "Disable automatic background update checks. Updates will be available if you manually check for updates."
- `start` — "Check for updates only on startup. Disable automatic background update checks."
- `default` — "Enable automatic update checks. Code will check for updates automatically and periodically."[^s13]

`update.channel` still exists but is deprecated in favour of `update.mode`.[^s13] On Windows there is a separate `update.enableWindowsBackgroundUpdates` (default `true`).[^s13]

**Extensions are governed separately, and this is where VS Code already implements a cooldown.** `extensions.autoUpdate` is `'on' | 'off'`, default `'on'`, and `extensions.autoCheckUpdates` is boolean, default `true` (marks extensions outdated in the UI without installing).[^s15] Crucially, `extensions.autoUpdateDelay` defaults to **2 hours**: "Controls the delay in hours after an extension update is published before it is automatically installed. Only applies when `extensions.autoUpdate` is set to `on`. This delay helps avoid installing potentially problematic updates immediately after release."[^s37] It has its own Group Policy, `ExtensionsAutoUpdateDelay`.[^s37] This is Microsoft shipping a supply-chain quarantine window by default — two hours, not seven days, but the same mechanism the repo just adopted.

**Settings Sync does own extensions, and the repo's ADR is correct.** Microsoft: "All built-in and installed extensions are synchronized along with their global enablement state."[^s38] Opt-outs are per-extension via `settingsSync.ignoredExtensions`, or by deselecting Extensions in **Settings Sync: Configure**.[^s38] Two caveats worth carrying into the ADR: sync explicitly does *not* cover remote windows ("VS Code does not synchronize your extensions to or from a remote window, such as when you're connected to SSH, a development container (devcontainer), or WSL"),[^s38] and Settings Sync syncs the *set* of extensions, not pinned versions — version selection stays with `extensions.autoUpdate` / `autoUpdateDelay` on each machine.

Note also that `extensions.autoUpdate` underwent a **breaking value change**: it previously accepted `true` (All Extensions) and `'onlyEnabledExtensions'`, and those values are now retired and migrated to `'on' | 'off'`.[^s39] A dotfiles repo carrying an old `"extensions.autoUpdate": true` is relying on a migration, not a supported value.

### 5. Homebrew

Homebrew has no auto-upgrade to disable and **no release-age control at all**. `HOMEBREW_NO_AUTO_UPDATE` does not stop packages from upgrading; it stops the *metadata refresh*: "If set, do not automatically update before running some commands, e.g. `brew install`, `brew upgrade` or `brew tap`. Preferably, run this less often by setting `$HOMEBREW_AUTO_UPDATE_SECS` to a value higher than the default."[^s17] The default interval is `86400` seconds (24 h), dropping to `3600` after a developer command and `300` if `HOMEBREW_NO_INSTALL_FROM_API` is set.[^s17] A parallel `HOMEBREW_API_AUTO_UPDATE_SECS` (default `450`) governs API formula/cask data, and `HOMEBREW_FORCE_API_AUTO_UPDATE` overrides `HOMEBREW_NO_AUTO_UPDATE` for that data.[^s40]

Searching the full `brew(1)` manpage turns up no minimum-age, cooldown, or quarantine setting — the only time-based knobs are the auto-update intervals above and `HOMEBREW_CLEANUP_MAX_AGE_DAYS`. What Homebrew does offer is integrity, not delay: every formula/cask download carries a SHA-256, `--require-sha` (settable globally via `HOMEBREW_CASK_OPTS`) "Require all casks to have a checksum", `brew verify` checks "the build provenance of bottles using GitHub's attestation tools", and `HOMEBREW_VERIFY_ATTESTATIONS` / `HOMEBREW_NO_VERIFY_ATTESTATIONS` toggle that for homebrew-core bottles.[^s18]

Relevant to Claude Code specifically: Anthropic uses Homebrew's *cask naming* as the channel selector — `claude-code` tracks stable ("typically about a week behind and skips releases with major regressions") and `claude-code@latest` tracks latest.[^s41]

### Synthesis: is there a documented consensus?

**No. There are two well-documented first-party positions and they genuinely conflict.** Neither side is a strawman; both are written by vendors with real incident data.

**Position A — fast auto-update is itself a security control.** Google's *Chrome Updates technical document* is the most explicit first-party statement available. It ranks four strategies against Security / IT effort / Stability and scores auto-update "Best / Best / Standard", version-pinning-by-full-version "Worst / Medium / Better", and full manual updates "Worst / Worst / Better".[^s42] Its reasoning is the CVE-window argument stated directly: "Updates frequently contain security fixes and should be applied quickly (within days or weeks). Although many enterprises concentrate on applying fixes to known in-the-wild exploits, other security fixes are just as important. Once a fix is released, bad actors may reverse engineer it, turning into an in-the-wild exploit after the release."[^s42] It warns that milestone pinning delays some security improvements and that "If you set Target version prefix, remember to regularly update it. If you don't allow the next milestone to roll out, you won't receive any more security updates."[^s43] Google also advises against disabling the Variations framework and component updates because they are the emergency channel: disabling Variations "stops Chrome from making any changes in any situations (even, for example, as a response to an active exploit)."[^s44]

NIST is on the same side for the general case. SP 800-40r4 frames patching as "a standard cost of doing business", names the trade-off outright — "Deploying patches more quickly reduces the window of opportunity for attackers but increases the risk of operational disruption because of the lack of testing" — and argues that "Disruptions from patching are largely controllable, while disruptions from incidents are largely uncontrollable."[^s45] It also says flatly: "There is no way that an organization can keep up with patching without automation."[^s46]

**Position B — artifacts should be verified and quarantined before they run.** The same NIST document, in the same life cycle, requires two steps that a background auto-updater performs on your behalf and a cooldown performs for you: "Validate the patch. A patch's authenticity and integrity should be confirmed, preferably by automated means, before the patch is tested or installed. The patch could have been acquired from a rogue source or tampered with in transit or after acquisition."[^s47] And: "Organizations should consider adopting phased deployments for routine patching in which a small subset of the assets to be patched receive the patch first. These assets act as canaries … In effect, this is how the patching gets tested."[^s48]

OpenSSF's *npm Best Practices Guide* argues the supply-chain case for hash pinning and lockfiles specifically as protection against a compromised *newly published* version: reproducible installation mitigates "certain threats such as malicious dependencies. Otherwise, you might install and run a newly published (compromised) version of the dependency on a CI/CD system or developer machine, giving an attacker immediate code execution."[^s49] It also cites a cooldown mechanism by name — Renovate's `stabilityDays` — as a way to "let maintainers test updates before accepting them in the default branch."[^s49]

**Where the two positions actually diverge — and where they don't.** They agree completely on integrity: nobody argues against signature/checksum verification. They diverge on *latency*, and the divergence is driven by which threat model dominates for a given artifact class:

- Chrome's model assumes the *vendor* is trusted and the *attacker is outside*. The window that matters is between public patch and installed patch. Delay is pure loss.
- The supply-chain model assumes the *publishing pipeline itself* can be compromised. The window that matters is between malicious publish and community detection. Delay is pure gain.

Neither vendor claims their position generalises. Google's own guide concedes pinning "may be appropriate for particularly complex environments with little tolerance for disruptions" and ranks *milestone* pinning — which still takes minor security releases automatically — as the sensible middle.[^s50] NIST's answer to the same tension is not a global rule but **maintenance groups**: "Organizations should use the software inventories, technical and business/mission characteristics, and risk response scenarios to assign each asset to a maintenance group," with different plans per group, and explicitly suggests grouping by "personnel roles (e.g., software developer workstations, system administrator workstations)."[^s51]

**Two observations that the sources make for us, without our having to arbitrate:**

1. **Three of the five vendors here have already shipped a cooldown themselves.** Microsoft's `extensions.autoUpdateDelay` defaults to 2 hours and its stated rationale is verbatim supply-chain quarantine: "This delay helps avoid installing potentially problematic updates immediately after release."[^s37] Anthropic's `autoUpdatesChannel: "stable"` is "typically about one week old and skips versions with major regressions"[^s20] — a ~7-day quarantine, chosen independently, matching this repo's `minimum_release_age = "7d"`. GitHub ships `autoUpdatesChannel` with a `stable`/`prerelease` split.[^s11] The vendors do not treat delay and security as opposites; they treat channel choice as the axis.
2. **Where a vendor's own stable channel exists, it dominates an external quarantine.** A vendor stable channel skips known-bad releases; a blind age gate does not — it merely arrives at the same bad release seven days later. The repo's `mise lock --bump` rolling uv 0.12.1 backwards to 0.11.32 is the visible symptom of an age gate having no quality signal. Nothing in the sources resolves whether an age gate plus a lockfile beats a vendor stable channel; the sources are silent on comparing the two, and this is a genuine gap rather than a settled question.

## The cooldown pattern across the ecosystem

"Quarantine a new release for N days" is now a shipped, first-party feature in every major JavaScript package manager, in both major dependency-update bots, in the Python installer and resolver, and — in narrower form — in Homebrew. It is on by default in several of them. The exception mechanism is, without exception, a **named allowlist evaluated against the global floor**: a list of package names, glob patterns, or name+version locators that bypass the gate. No tool surveyed offers anything structurally different. The only real variation is in the *granularity* of the exemption (name / pattern / exact version) and in whether the exemption is binary (skip the gate) or parametric (a different, shorter gate for that package).

### The reference design: Renovate

Renovate's `minimumReleaseAge` is the oldest and most elaborated implementation, and it is the only one of the shipped implementations that **defaults to off**. The option table lists `type: string`, `cli: --minimum-release-age`, `env: RENOVATE_MINIMUM_RELEASE_AGE` and **no `default` row**, i.e. unset/null unless configured.[^e1] It takes a duration string such as `3 days`. As of Renovate 42.19.5, `minimumReleaseAge=0 days` is treated identically to `null`.[^e1]

Semantics worth copying:

- The wait is **per version, not per package**. Renovate "will wait for the set duration to pass for each *separate* version"; it does not wait until a package has been quiet for the duration.[^e1] This matters for high-churn tools: a package that ships daily still becomes installable, just always N days behind head.
- While the wait is running, Renovate attaches a *pending* status check (`renovate/stability-days` by default, configurable via `statusCheckNames.minimumReleaseAge`) to the update branch, flipping it to passing when the time elapses.[^e1][^e2]
- The docs explicitly say **do not use `minimumReleaseAge` as a rate limiter**: "Do *not* use `minimumReleaseAge` to slow down fast releasing project updates. Instead setup a custom `schedule` for that package."[^e1] Cooldown and noise-reduction are separate concerns with separate knobs.
- The gate requires a release timestamp from the datasource. `minimumReleaseAgeBehaviour` controls what happens when there isn't one: `timestamp-required` treats a timestamp-less release as never stable; `timestamp-optional` treats it as stable.[^e3]

`internalChecksFilter` is the piece most often missed. It is `type: string`, `allowedValues: ["strict", "flexible", "none"]`, **`default: "strict"`**, and "Currently this applies to the `minimumReleaseAge` check only."[^e2]

- `none` — no filtering; the highest release is used regardless of pending status.
- `strict` — all pending releases are filtered; the update is skipped unless a non-pending version exists.
- `flexible` — like strict, but if *every* candidate version is pending, a PR is created with the highest pending version.[^e2]

The docs warn that `flexible` "can result in 'flapping' of Pull Requests, for example: a pending PR with version `1.0.3` is first released but then downgraded to `1.0.2` once it passes `minimumReleaseAge`", and recommend `strict` plus `dependencyDashboard=true` so suppressed updates stay visible.[^e2] **This flapping is the same failure mode as a lockfile bump proposing a version rollback**: it is a known, documented consequence of applying an age filter to a moving target, and the upstream answer is to filter strictly and surface the suppression in a dashboard rather than to let the resolver walk backwards.

Exceptions are expressed through `packageRules`, the same mechanism as every other Renovate override — match on datasource, package name, depType, etc., and set a different `minimumReleaseAge` in the matching rule. The canonical documented example scopes the gate rather than exempting from it:[^e1]

```json
{
  "packageRules": [
    { "matchDatasources": ["npm"], "minimumReleaseAge": "3 days" }
  ]
}
```

To exempt, you write a narrower rule setting `minimumReleaseAge` back to `null` (or to a shorter duration) for the matched packages. Renovate does this itself: the built-in `vulnerabilityAlerts` config has default `{"minimumReleaseAge": null, ..., "prCreation": "immediate"}` — **security updates are exempted from cooldown by default**.[^e4]

Two related defaults: `internalChecksAsSuccess` is `false`, so a passing `renovate/stability-days` check does not on its own make a branch green (this exists to stop automerge when the only check is Renovate's own).[^e5] And `prNotPendingHours` is disabled entirely whenever `minimumReleaseAge` is non-zero.[^e6]

### Dependabot: the only implementation that made cooldown a default

Dependabot ships a `cooldown` block, and since 2026 applies it **whether or not you configure it**:

> "Apply a **default cooldown period of 3 days** to version updates, even when `cooldown` is not configured. A new version is not considered for a version update until 3 days after its release. **This default cooldown does not apply to security updates.**"[^e7]

`cooldown` is version-updates-only; security updates are never delayed.[^e7] Parameters:[^e7]

| Parameter | Meaning |
| --- | --- |
| `default-days` | Cooldown for dependencies without specific rules. Defaults to 3 days if unspecified. |
| `semver-major-days` / `semver-minor-days` / `semver-patch-days` | Per-bump-type cooldown; only for ecosystems that support SemVer. |
| `include` | Dependencies to apply cooldown to — up to **150 items**, wildcards (`*`) supported. |
| `exclude` | Dependencies **excluded** from cooldown — up to **150 items**, wildcards (`*`) supported. |

`default-days` is supported for every listed ecosystem; the SemVer-tiered options are supported only for some (Bundler, Bun, Cargo, Composer, Conda, Deno, Dotnet SDK, Elm, Gomod, Gradle, Helm-no, Hex, Julia, Maven … yes; Bazel, Devcontainers, Docker, Docker Compose, GitHub Actions, Gitsubmodule, Helm … no).[^e7]

So Dependabot's exception model is exactly "global floor plus named exception list", with two refinements: the list is capped at 150 entries, and the *tiering* by SemVer bump type lets you express "patches after 1 day, majors after 14" without naming packages at all.

### Why three days — the quantified justification

GitHub published the reasoning for the 3-day default, and it is the most concrete public number-setting exercise available:[^e8]

- September 2025 `chalk` / `debug` compromise: an attacker phished one maintainer and published booby-trapped versions of packages "downloaded more than 2 billion times a week"; the poisoned versions were "live for roughly two hours before the community caught them and npm pulled them."[^e8]
- Compromised builds of Solana web3.js, Axios and ua-parser-js were "each caught within a few hours of publication."[^e8]
- Volume: "In the year ending May 2026, the [GitHub Advisory Database] published more than 6,500 npm malware advisories, up from roughly 6,200 the year before, which adds up to approximately 18 newly cataloged malicious npm packages every day."[^e8]
- The stated trade-off: "Three days as the default balances two goals: it pushes you past the window where most of these attacks live, and it doesn't hold your dependencies back longer than necessary."[^e8]
- Explicit scope limit: "It does little against attacks that play a longer game, including backdoors planted in releases and left dormant, maintainer sabotage, or a compromised build system."[^e8]

pnpm's docs make a stronger claim about the detection window: "In most cases, malicious releases are discovered and removed from the registry within an hour."[^e9] pnpm nonetheless ships a 1440-minute (24 h) default, ~24× that window.

The Shai-Hulud worm (notified to GitHub 14 September 2025) is the incident that moved the whole ecosystem: a self-replicating worm spreading via compromised maintainer accounts and malicious post-install scripts; GitHub removed "500+ compromised packages" and blocked uploads matching the malware's IoCs.[^e10]

The xz-utils backdoor is the counter-example that bounds the claim. Malicious code was present in xz 5.6.0 and 5.6.1, assigned CVE-2024-3094, disclosed 29 March 2024.[^e11] xz 5.6.0 was released in late February 2024 — roughly a month before disclosure. **A 7-day quarantine would not have caught it**, which is precisely GitHub's "long game" caveat.[^e8][^e11]

### Package managers with native support — what actually shipped

All four JavaScript package managers have shipped it. This is not a proposal in any of them.

**pnpm** — `minimumReleaseAge`, added in **v10.16.0**, type *number of minutes*. "Default: **1440** (since v11), **0** (before v11)". Applies to **all dependencies, including transitive ones**.[^e9] Companion settings:
- `minimumReleaseAgeExclude` (v10.16.0), `string[]`, default undefined. Exclusion is **by package name** and applies to all versions of that package. Glob patterns added in **v10.17.0** (`'@myorg/*'`). Version-specific exemptions added in **v10.19.0**: `nx@21.6.5`, `webpack@4.47.0 || 5.102.1` — "This allows pinning exceptions to mature-time rules."[^e12]
- `minimumReleaseAgeStrict` (v11.0.0): default **true if `minimumReleaseAge` is explicitly configured, false otherwise**. When false, pnpm falls back to a version that violates the constraint so the install still succeeds; when true, resolution fails. The built-in 1440-minute default is deliberately non-strict for backward compatibility.[^e13]
- `minimumReleaseAgeIgnoreMissingTime` (v11.0.0): default **true** — skip the check when registry metadata lacks a `time` field (private registries and mirrors often omit it).[^e13]

pnpm also ships an orthogonal, non-time-based gate worth noting: `trustPolicy: no-downgrade` (v10.21.0) fails the install if a package's *trust evidence* (trusted publisher → provenance → nothing) decreased versus earlier releases, with `trustPolicyExclude` for named exceptions and `trustPolicyIgnoreAfter` (v10.27.0) to auto-exempt anything published more than N minutes ago.[^e14]

**npm** — `min-release-age`, "Default: null, Type: null or Number", expressed in **days**: "npm will build the npm tree such that only versions that were available more than the given number of days ago will be installed."[^e15] Exemptions: `min-release-age-exclude`, "String (can be set multiple times)", "A list of package names or `minimatch` glob patterns that are exempt from the `min-release-age` (and `before`) filter."[^e16] Two sharp edges documented:
- The exemption is **not transitive**: "Only the named package is exempt; its own dependencies still follow the release-age policy unless they also match a pattern."[^e16]
- When the window blocks a security fix, "npm keeps the package at its vulnerable version, warns that the fix was blocked, and exits with a non-zero code."[^e15] npm chose *fail loudly* where Dependabot and Renovate chose *exempt security updates*.
- The older `--before <date>` absolute cutoff still exists and wins over `min-release-age` within a single config source.[^e17]

**Bun** — `minimumReleaseAge` in `[install]` of `bunfig.toml`, in **seconds**, plus CLI `--minimum-release-age <seconds>`; exclusions via `minimumReleaseAgeExcludes = ["@types/node", "typescript"]`.[^e18] Bun adds a heuristic nobody else has: when versions are blocked by the age gate, "a stability check detects rapid bugfix patterns … If multiple versions were published close together just outside your age gate, Bun extends the filter to skip those potentially unstable versions and selects an older, more mature version. The check searches up to **7 days** past the age gate." Exact version requests (`package@1.1.1`) "still respect the age gate but bypass the stability check." The filter "only affects new package resolution; existing packages in `bun.lock` remain unchanged", and versions with no `time` field pass the check.[^e18] Bun's docs state no default value for `minimumReleaseAge`, and show it only as an opt-in — treat the default as unset/0 unless verified.

**Yarn (Berry)** — `npmMinimalAgeGate`, "Minimum age of a package version according to the publish date on the npm registry to be considered for installation", plus `npmPreapprovedPackages`, "Array of package descriptors or package name glob patterns to exclude from all of the package gates."[^e19] The setting is **scopable**: `npmScopes.<scope>.npmMinimalAgeGate` overrides the global value per registry scope.[^e20] `npmPreapprovedPackages` is global-only and defaults to `[]`.[^e20]

**Sources contradict on Yarn's default.** The published `.yarnrc.yml` reference renders `npmMinimalAgeGate: "1w"`.[^e19] The setting definition in `yarnpkg/berry` master declares `type: SettingsType.DURATION, unit: DurationUnit.MINUTES, default: '1d'`.[^e20] I could not reconcile these from primary sources; treat the shipped default as 1 day per the source and verify against your installed Yarn with `yarn config get npmMinimalAgeGate` before relying on it.

**Python — also shipped, in both tools.** `pip install --uploaded-prior-to <datetime_or_duration>`: "Only consider packages uploaded prior to the given value. Accepts an ISO 8601 datetime … or a duration in days (e.g., 'P3D' for packages uploaded at least 3 days ago). Only effective when using indexes that provide upload-time metadata."[^e21] Added in pip **26.0** (2026-01-30); the relative-duration form (`P3D`) was added in pip **26.1** (2026-04-26); pip **26.2** (2026-07-29) extended it to `pip list --outdated`/`--uptodate` and to `pylock.toml`.[^e22] **pip provides no per-package exemption** — it is a global floor with no allowlist, the only surveyed tool in that position.

uv is the opposite extreme and has the most expressive exemption model found: `exclude-newer` (default `None`) accepts "RFC 3339 timestamps …, a 'friendly' duration (e.g., `24 hours`, `1 week`, `30 days`), or an ISO 8601 duration (e.g., `PT24H`, `P7D`, `P30D`)", and `exclude-newer-package` takes "a dictionary format of `PACKAGE = "DATE"` pairs" where **"Set a package to `false` to exempt it from the global `exclude-newer` constraint entirely"**:[^e23]

```toml
[tool.uv]
exclude-newer = "P7D"
exclude-newer-package = { tqdm = "2022-04-04T00:00:00Z", markupsafe = false }
```

That is the design the question is reaching for: one map that expresses both *"this package gets a different (shorter) floor"* and *"this package gets no floor at all"*, instead of a boolean exclusion list.

### Other ecosystems with a genuine first-party mechanism

**Homebrew — yes, but narrow.** `Homebrew::RELEASE_COOLDOWN_DAYS = 1` is a real constant in `brew` master.[^e24] It is applied when resolving Python resource blocks, by passing pip's own flag: `"--uploaded-prior-to=P#{Homebrew::RELEASE_COOLDOWN_DAYS}D"`, with the in-source rationale "Delay packages published in the last day so resource resolution is less likely to pick a freshly compromised PyPI release."[^e25] The exemption is `brew update-python-resources --ignore-main-package-cooldown`: "Bypass the release cooldown for *formula*'s own package when resolving resources. Its dependencies still respect the cooldown. **This option is ignored for official taps.**"[^e26] I found no evidence of a time-based cooldown on `brew install` / bottle consumption itself — the mechanism is scoped to formula-authoring resource resolution.

**Debian testing — the oldest instance of the pattern, and it is urgency-tiered.** A package version migrates from unstable to testing only when "It must have been in unstable for **10, 5 or 2 days**, depending on the urgency of the upload", along with four other conditions (built on all architectures, no new release-critical bugs, dependencies satisfiable, installing it must not break testing).[^e27] The exception mechanism is not a config list but a human: "The release manager can override the rules."[^e27] Note the shape — the age gate is one of five conjunctive conditions, and the *duration* is chosen by the uploader via the urgency field, which is exactly per-package granularity expressed at publish time rather than at consume time.

**Nixpkgs channels — a lag, but not a time-based one.** "Hydra regularly evaluates and builds Nixpkgs, updating the official channels when their jobs succeed."[^e28] The `nixos-YY.MM` branch "points to the latest *tested* release channel commit."[^e28] Mass-rebuild changes are batched through `staging` → `staging-next` → `master`, with the `staging-next` merge done manually.[^e28] The resulting delay between an upstream release and channel availability is real and often multi-day, but it is **test-gated and queue-gated, not clock-gated** — there is no configurable N, and no per-package exemption. Do not cite nixpkgs as a cooldown implementation; it is a different mechanism that produces a similar delay.

**Go modules — no cooldown.** The module system's controls are `GOPROXY`, `GOPRIVATE`, `GONOPROXY`, the checksum database, and `go.sum` verification; the `go` command "requests the latest version of each module path" from the proxy with no age filter documented in the Go Modules Reference.[^e29] Go's mitigation is a different one: proxy immutability plus cryptographic checksums, so a published version cannot be silently changed or (from a warm proxy) fully disappear. There is no `minimumReleaseAge` equivalent and no exemption list, because there is no gate.

**crates.io / Cargo — no cooldown.** Cargo's registry web API defines publish, **yank** and unyank (`yank` sets the `yank` field in the index; unyank clears it),[^e30] and the Cargo configuration reference contains no minimum-age, cooldown or quarantine setting.[^e31] Rust's story is yank-after-the-fact, not delay-before-the-fact.

### Comparison table: default cooldown and exemption mechanism

| Tool | Setting | Shipped? | Default | Unit / form | Exempting specific packages |
| --- | --- | --- | --- | --- | --- |
| **Renovate** | `minimumReleaseAge` | Yes | **none (null)** [^e1] | duration string (`"3 days"`) | `packageRules` matching (`matchDatasources`, `matchPackageNames`, …) setting a different value or `null`; security updates already exempt via `vulnerabilityAlerts` default `minimumReleaseAge: null` [^e1][^e4] |
| **Dependabot** | `cooldown` | Yes | **3 days**, applied even when unconfigured; never applies to security updates [^e7] | days | `cooldown.exclude` list, ≤150 entries, `*` wildcards; also `include` to scope in, and `semver-*-days` to tier by bump type [^e7] |
| **pnpm** | `minimumReleaseAge` | Yes (v10.16.0) | **1440 min (24 h)** since v11; 0 before v11 [^e9] | minutes | `minimumReleaseAgeExclude`: names (v10.16.0), globs (v10.17.0), name@version / `\|\|` disjunctions (v10.19.0) [^e12] |
| **npm** | `min-release-age` | Yes | **null** [^e15] | days | `min-release-age-exclude`: names or `minimatch` globs, repeatable; **not transitive** [^e16] |
| **Bun** | `minimumReleaseAge` (`bunfig.toml` `[install]`) | Yes | none documented (opt-in) [^e18] | seconds | `minimumReleaseAgeExcludes` array of package names [^e18] |
| **Yarn Berry** | `npmMinimalAgeGate` | Yes | **contested: `1w` in docs vs `1d` in source** [^e19][^e20] | minutes (duration string accepted) | `npmPreapprovedPackages`: package descriptors or name globs; also per-scope override via `npmScopes.<scope>.npmMinimalAgeGate` [^e19][^e20] |
| **uv** | `exclude-newer` | Yes | **None** [^e23] | RFC 3339 timestamp *or* duration (`24 hours`, `P7D`) | `exclude-newer-package = { pkg = "DATE", pkg2 = false }` — per-package *date* or `false` to exempt entirely [^e23] |
| **pip** | `--uploaded-prior-to` | Yes (26.0; durations 26.1) [^e21][^e22] | none (opt-in flag) | ISO 8601 datetime or `P<n>D` | **none** — no per-package exemption exists |
| **Homebrew** | `RELEASE_COOLDOWN_DAYS` | Yes, but only for PyPI resource resolution [^e24][^e25] | **1 day** [^e24] | days | `--ignore-main-package-cooldown` exempts the formula's own package only, deps still cooled; ignored for official taps [^e26] |
| **Debian testing** | urgency-based migration delay | Yes (long-standing) | **10 / 5 / 2 days** by upload urgency [^e27] | days | Release manager override; urgency field set per upload [^e27] |
| **Nixpkgs channels** | — | No time-based gate; Hydra test-gated channel advance [^e28] | n/a | n/a | n/a |
| **Go modules** | — | **No such mechanism** [^e29] | n/a | n/a | n/a (mitigation is proxy immutability + checksum DB) |
| **Cargo / crates.io** | — | **No such mechanism**; yank/unyank only [^e30][^e31] | n/a | n/a | n/a |

### Is "global floor plus named exception list" the accepted design?

Yes — every shipped implementation is that shape. But the surveyed primary sources show four refinements over a plain boolean allowlist, and three of them are directly applicable to a fast-moving-tool problem:

1. **Parametric rather than binary exemptions.** uv's `exclude-newer-package` lets an entry be either a *different date* or `false`; Dependabot's `semver-*-days` lets you tier by bump size; Renovate's `packageRules` lets a rule set any duration. "This package gets 1 day instead of 7" is strictly more useful than "this package gets nothing", because it keeps a floor under the tools you most want current.[^e23][^e7][^e1]
2. **Version-pinned exemptions.** pnpm v10.19.0 allows `nx@21.6.5` and `webpack@4.47.0 || 5.102.1`, described as "pinning exceptions to mature-time rules".[^e12] Yarn's `npmPreapprovedPackages` accepts package *descriptors*, not just names.[^e19] This converts the exemption from a standing hole into a one-shot, auditable, reviewed decision — you say "I have looked at this specific version and I want it now", not "this package is forever trusted".
3. **A separate carve-out for security fixes, and an explicit choice about what happens when the gate blocks one.** Renovate and Dependabot exempt security updates by default.[^e4][^e7] npm instead keeps the vulnerable version, warns, and exits non-zero.[^e15] Both are defensible; silently staying vulnerable is not.
4. **A strictness policy for "no candidate satisfies the floor".** This is the setting that governs whether the tool *rolls backwards*. pnpm's `minimumReleaseAgeStrict` chooses between failing resolution (true) and falling back to a version that violates the constraint (false).[^e13] Renovate's `internalChecksFilter: "strict"` (the default) skips the update entirely rather than proposing a lower pending version, precisely because `flexible` causes version flapping.[^e2] The documented ecosystem consensus is **skip, don't downgrade** — hold at the currently-installed version and surface the suppression, rather than let an age filter select an older release.

Nothing better than the allowlist exists in any primary source surveyed. The closest thing to an alternative is Debian's model, where the delay is chosen by the *publisher* per upload (the urgency field) rather than by the consumer per package — but that requires publisher cooperation and has no analogue in any language registry.[^e27] pnpm's `trustPolicy` is a genuinely different axis (publisher trust evidence rather than elapsed time) and can be combined with a cooldown, but it does not replace one.[^e14]

## What mise itself provides

Investigated against mise `2026.8.0` (`Cargo.toml`), source tree at commit `832623e202ff7be9e3a735c4ba1437d578d3066c` (2026-08-02), plus the live docs at mise.jdx.dev.

### 1. `minimum_release_age`: exact semantics

**Conclusion: it is a filter on *remote version selection for fuzzy requests only*, it fails open on any version lacking a publish timestamp, and its 24h "default" is not a setting default but a runtime fallback that applies to only 12 of mise's 20 backend types.**

**Default.** The setting itself is `optional` with no `default` in the schema; only `default_docs = "24h"` is declared.[^m1] The actual floor is a Rust constant, `const DEFAULT_MINIMUM_RELEASE_AGE: &str = "24h"` at `src/install_before.rs:12`.[^m2] Type `String`, env var `MISE_MINIMUM_RELEASE_AGE`.[^m1]

**Accepted formats.** Relative durations `7d`, `90d`, `6mo`, `1y`; absolute dates `2024-06-01` or `2024-06-01T12:00:00Z`.[^m3] A zero duration (`0s`) disables the cutoff.[^m3] Relative durations are resolved once per process against `crate::duration::process_now`, so every resolution inside one `mise` invocation uses an identical absolute timestamp — this is what keeps the version mise picks and the flag it forwards to npm/uv from drifting apart.[^m4]

**Precedence** (highest first), as documented and as implemented in `resolve_before_date_with_excludes`:[^m5][^m6]

1. A pre-resolved cutoff from the caller — the `--minimum-release-age` CLI flag (alias `--before`), available on `install`, `use`, `latest`, `ls-remote`, `upgrade`, and `lock`.[^m7]
2. A per-tool `minimum_release_age` tool option.
3. The global `minimum_release_age` setting.
4. The built-in `24h` default, only for eligible backends.

There is an asymmetry in how `0s` behaves. As a *setting* or *tool option*, `0s` returns "no cutoff" and therefore falls through to nothing — it is a true opt-out.[^m6] As a *CLI flag*, `--minimum-release-age 0s` is translated to the sentinel cutoff `2099-01-01` (`DISABLED_MINIMUM_RELEASE_AGE_CUTOFF`, `src/install_before.rs:13`) precisely so that it takes precedence over and neutralises a lower-precedence per-tool or global value.[^m8] This is the mechanism for a one-shot "ignore the quarantine for this command".

**Which backends enforce it.** The built-in 24h default applies only where `default_minimum_release_age_applies` returns true: `Aqua`, `Cargo`, `Core`, `Forgejo`, `Gem`, `Github`, `Gitlab`, `Go`, `Npm`, `Pipx`, `Spm`, `Ubi`.[^m9] The eight backend types *not* in that list — `Asdf`, `Conda`, `Dotnet`, `Http`, `Pkgx`, `S3`, `Vfox`, `VfoxBackend` — never get the implicit floor.[^m10]

An **explicitly set** global `minimum_release_age`, however, is *not* gated on backend type: the branch that reads `Settings::get().minimum_release_age` has no backend check.[^m6] It is applied to every backend and then quietly does nothing wherever versions carry no timestamps.

**What happens with no timestamps: it fails open, silently.** `VersionInfo::filter_by_date` keeps any version whose `created_at` is `None` (`is_none_or`).[^m11] If *every* remaining version lacks a timestamp, mise emits a `debug!` line — not a warning — saying the backend "does not provide release dates; release-date filter may not work as expected".[^m12] At default log level you will see nothing. A quarantine that cannot be enforced is indistinguishable from one that is being enforced.

This matters concretely here: `registry/claude.toml` declares `aqua:anthropics/claude-code` for linux/macos with an `http:claude` fallback.[^m13] `src/backend/http.rs` contains no `created_at` at all,[^m14] and `Http` is not in the default-eligible list,[^m9] so on the http path `minimum_release_age` is inert. On the aqua path it works, because aqua pulls `created_at` from GitHub releases.[^m15]

**Fuzzy only.** For most backends the filter applies only to fuzzy requests (`latest`, `lts`, `20`); exactly pinned versions like `node@22.5.0` bypass it entirely.[^m3][^m16]

**Installed versions stay eligible.** During ordinary toolset resolution the *built-in default* cutoff gates only which versions remote resolution may pick; it does not deactivate an already-installed fuzzy match.[^m16] This was a deliberate fix (#10315) after the 24h default turned every `mise which`/`hook-env` into a remote fetch and took shell startup from ~2.5s to ~65s (discussion #10308).[^m17] An **explicit** cutoff (flag, tool option, or setting) *does* keep date-aware resolution of installed versions — `should_filter_installed_versions` requires `!opts.before_date_from_default`.[^m18] So setting `minimum_release_age = "7d"` globally, as this repo has done, is materially stricter than leaving the default: it re-enables installed-version date filtering everywhere.

**Transitive dependencies: `npm:` and `pipx:` only.**[^m3] Everything else constrains only the top-level tool version.

- `npm:` — the embedded aube installer honours it natively. When shelling out, mise builds package-manager flags in `build_transitive_release_age_args`: bun gets `--minimum-release-age <seconds>`; pnpm gets `--config.minimumReleaseAge=<minutes>` (seconds rounded up); npm gets `--min-release-age=<days>` only when npm supports it *and* the window is ≥ 86400s, otherwise `--before <timestamp>`, because `--min-release-age` is day-granular.[^m19] Documented minimums: `pnpm >= 10.16.0`, `bun >= 1.3.0`, `npm >= 11.10.0` (`--min-release-age`), `npm 6.9.0–11.9.x` (`--before`).[^m20] A 60-second tolerance (`BEFORE_DATE_TOLERANCE_SECS`) prevents `3d` being rounded up to `4d`.[^m21] mise warns if it cannot determine the package-manager version or finds it too old.[^m22]
- `pipx:` — uv path uses `--exclude-newer`, requires `uv >= 0.2.22`; the pipx fallback passes pip's `--uploaded-prior-to`.[^m23]

### 2. `minimum_release_age_excludes`: exact match, not glob

**Conclusion: all three forms in the docs work, but only as exact string equality against three precomputed candidates. It is not a glob engine — `npm:*` is a literal, and `aqua:jdx/*` will not match anything.**

Type `string[]`, env `MISE_MINIMUM_RELEASE_AGE_EXCLUDES` (comma-separated), default `[]`.[^m24] `is_minimum_release_age_excluded` (`src/install_before.rs:180-203`) trims each entry, skips empties, and returns true if the entry equals any of:[^m25]

1. `backend_arg.short` — the registry shorthand, e.g. `trivy`, `claude`, `node`.
2. the full backend ID with bracketed options stripped — e.g. `aqua:aquasecurity/trivy`, `npm:prettier`. (When `short` already contains `:`, mise strips options off `short`; otherwise it uses `full_without_opts()`.)
3. the literal string `format!("{}:*", backend_arg.backend_type())` — i.e. `aqua:*`, `npm:*`, `github:*`.

So: **bare tool name — yes. `npm:*` — yes. Fully-qualified `aqua:owner/repo` — yes.** Confirmed from source, and each form is exercised by the docs and e2e tests.[^m26] No wildcard other than the exact `<backend>:*` form is supported; there is no glob matcher in that function.

**Interaction with the per-tool option.** Being excluded sets `excluded = true`, which short-circuits *only* the global-setting branch and the built-in-default branch — both are guarded by `!excluded`.[^m6] The caller-provided cutoff (CLI flag) and the per-tool `minimum_release_age` branches are not guarded, so they still apply to an excluded tool.[^m6] This matches the documented sentence verbatim.[^m24]

**The per-tool option exists and is the sharper instrument.** `minimum_release_age` is a recognised core tool-option key (`src/toolset/tool_version_options.rs:14-15`, accessor at `:269-282`, parser at `:362-368`), usable as `[tools.trivy] minimum_release_age = "1d"` or inline `"npm:prettier" = { version = "latest", minimum_release_age = "0s" }`.[^m27][^m28] Because a per-tool `0s` returns "no cutoff" outright,[^m6] a per-tool `minimum_release_age = "0s"` is a complete, declarative, per-tool opt-out that beats the global floor — functionally equivalent to listing the tool in `minimum_release_age_excludes` but expressed next to the tool. The e2e suite proves per-tool wins over global in **both** directions: a per-tool value *newer* than global wins, and a per-tool value *older* than global also wins.[^m29] It is an override, not a `max()`.

`install_before` is the deprecated alias for both the setting and the tool option: `deprecated_warn_at = "2026.10.0"`, `deprecated_remove_at = "2027.10.0"`.[^m30]

### 3. `mise lock --bump` does re-resolve downwards, and nothing stops it

**Conclusion: yes, genuinely. `--bump` discards the locked version and re-picks the newest *eligible* version with no comparison against what was locked. There is no flag, setting, or code path making it monotonic, and no open issue requesting one.**

The code path is three lines in `src/cli/lock.rs:124-128`:[^m31]

```rust
let lock_resolve_options = ResolveOptions {
    before_date,
    filter_installed_versions_by_release_date: true,
    latest_versions: self.bump,
    use_locked_version: !self.bump,
    ..Default::default()
};
```

`--bump` sets `use_locked_version = false` and `latest_versions = true`. In `ToolVersion::resolve`, `latest_versions = true` disables every branch that would return an installed or locked version, so resolution goes to the date-filtered remote list and takes the newest survivor.[^m32] The previously locked version is never read, so it cannot be used as a floor. `filter_installed_versions_by_release_date: true` additionally makes the lock path re-check installed fuzzy matches against release metadata — the one place mise documents that installed versions *are* subject to the cutoff.[^m16]

Grepping the whole tree for downgrade guards turns up only unrelated supply-chain provenance logic. The single "downgrade" check in `src/lockfile.rs` is a provenance-regression detector for `github:` tools, and its comment is explicit that version downgrades are permitted: `// Only flag upgrades — intentional downgrades are allowed` (`src/lockfile.rs:1976`).[^m33]

**The contrast that explains the observed behaviour.** `mise upgrade` *is* monotonic for semver-parseable versions: `is_outdated_version(current, latest)` returns `c.lt(&l)`, and its unit test asserts `is_outdated_version("1.12.0", "1.10.0") == false`.[^m34] So a global floor makes `mise upgrade` hold a tool back and warn — `newer <tool> release <v> ... ignored by minimum_release_age (<age>); latest eligible release is <v2>`[^m35] — while `mise lock --bump` rewrites the pin downwards. Same floor, opposite outcomes, by design of the two code paths.

**Documented non-downgrade guarantee is narrower than it looks.** `mise lock --minimum-release-age` carries the doc line "Existing matching lockfile entries are preserved and are not downgraded solely by this flag."[^m36] That guarantee is scoped to that flag on a non-bump run (where `use_locked_version` is still `true`); it does not survive `--bump`.

**Issue tracker.** Searches of the GitHub Issues/PR search API on 2 Aug 2026 for `repo:jdx/mise minimum_release_age in:title`, `repo:jdx/mise is:issue minimum_release_age`, `repo:jdx/mise is:issue is:open bump lockfile older`, and `repo:jdx/mise cooldown` returned **no open issue and no feature request** for a monotonic `--bump`; every `minimum_release_age` hit was a merged PR.[^m37] Stated plainly: **no such flag or setting exists, and as of this date nobody has filed for one.** Absence of a matching search result is weaker evidence than reading the source, so treat the "nobody has asked" half as a survey, not a proof.

The workable mitigation is per-invocation scoping, which the CLI does support: `mise lock --bump <tool> --minimum-release-age 0s` bumps one tool with the quarantine neutralised (the `0s` flag becomes the 2099 sentinel and outranks both the per-tool option and the global setting),[^m8] and `mise lock --bump --dry-run --json` reports what would change without writing.[^m38]

### 4. Tools that self-update out from under mise

**Conclusion: mise has no facility for this and the documentation is silent on it. The adjacent features — `disable_tools`, tool stubs, `mise self-update` — solve different problems. This is the largest documentation gap found.**

- **`disable_tools`** (`string[]`, `MISE_DISABLE_TOOLS`, default `[]`) means only "tools defined in mise.toml that should be ignored".[^m39] It suppresses mise's management of an entry; it does not detect, block, or reconcile a binary another installer wrote. Its counterpart `enable_tools`, when set, becomes the complete allowlist and disables `disable_tools` entirely; `enable_tools = []` disables all tools.[^m40] `auto_install_disable_tools` narrowly skips auto-install for named tools during `mise x`/`mise run`.[^m41]
- **Tool stubs** are executables with a `#!/usr/bin/env -S mise tool-stub` shebang and embedded TOML; the tool installs on first execution rather than at `mise install` time.[^m42] The stub's TOML "is essentially a subset of what can be done in `mise.toml` [tools] sections",[^m43] so a per-tool `minimum_release_age` is expressible in a stub. Stubs are a lazy-install mechanism, not a defence against a self-updater.
- **`mise self-update`** updates *mise itself*, not managed tools.[^m44] Its interesting content for this question is the packaging contract: mise accepts that a tool it does not own should not update itself in place, and gives packagers four ways to turn self-update off — building without the `self_update` cargo feature, an empty `.disable-self-update` marker at `lib/`, `lib/mise/`, or `lib64/mise/`, a `mise-self-update-instructions.toml`, or `MISE_SELF_UPDATE_AVAILABLE=false`. Any of these makes `mise doctor` report `self_update_available: no`.[^m45] `mise self-update --force` bypasses every runtime mechanism; only a build without the feature is a hard block, and the docs say to treat the rest as "do not update by default" rather than a block.[^m46] mise applies the "the package manager owns the binary, so disable the self-updater" pattern to itself, but ships no mechanism to impose that pattern on the tools it manages.
- **PATH shadowing** is the mechanism by which an installer writing to `~/.local/bin` wins. `mise doctor` performs a shim-shadowing check and verifies that mise tool paths appear before system paths in the current `PATH` (`src/cli/doctor/mod.rs:168`, `:899`).[^m47] `activate_aggressive` (`false` by default) pushes mise's bin paths to the front of `PATH` instead of letting later modifications take precedence.[^m48] These are the only two levers, and both are about ordering, not ownership.

**Explicitly unspecified:** searching `docs/` for `self-updat`, `not managed by mise`, `outside of mise`, and `.local/bin` produced no guidance whatsoever about tools whose own installer writes outside mise's control.[^m49] mise's docs do not acknowledge the failure mode. Whatever policy this repo adopts for `claude`'s installer or `bun upgrade`, it is not one mise documents.

### 5. First-party record on the quarantine and the 24h default

**Conclusion: the concept is explicitly borrowed from Renovate and the name from pnpm. There is no first-party blog post or design doc explaining why *24 hours* specifically — that number appears in code and release notes without a stated rationale.**

The security docs frame the feature by direct analogy: "This is similar to Renovate's minimum release age concept: newly published versions are ignored until they have been available for a configurable amount of time."[^m3] The settings reference adds the motive — "giving the community time to discover compromised releases" — and the naming provenance: "This name matches pnpm's `minimumReleaseAge` setting, though mise accepts both relative durations and absolute cutoff dates."[^m50] The lockfile docs position the two as complementary: "use `minimum_release_age` to avoid picking up brand-new releases, and lockfiles to pin the exact versions you've vetted."[^m51]

Timeline from first-party PRs and the changelog:

- #8842 `feat(install): add per-tool install_before option`; #8851 `feat(npm): apply install_before to transitive dependencies` — the original opt-in feature under its old name.[^m52]
- #9384 (2026-04-25) `refactor(config): rename install_before setting` — renamed to `minimum_release_age` "matching pnpm's terminology", `install_before` kept as a hidden deprecated alias.[^m53]
- **#10279 (2026-06-09) `feat(config): default release age and warn on hidden versions`** — the PR that made the quarantine on-by-default. Its own summary: "default `minimum_release_age` to `24h` at runtime for backends that can use release timestamps", "avoid applying the built-in default to asdf/vfox/plugin-style tools without release timestamps", "warn when newer releases are hidden by the release-age cutoff". **The PR gives no justification for the value 24h.**[^m54]
- #10310, #10344 — `0s` must actually disable the cutoff; stale-metadata false positives.[^m55]
- #10315 — the perf regression fix that split `BeforeDateSource::Default` from `Explicit` after the default cutoff took shell startup from ~2.5s to ~65s (discussion #10308).[^m17]
- #10366 `docs(settings): document 24h default`; #10466, #10705, #10962 — `mise upgrade` tool removal, release-date/eligibility detail in the warning, and stopping `mise prune` from deleting the version `minimum_release_age` selected.[^m56]

Read together, the first-party record supports one inference and refutes another. Supported: mise treats 24h as a low-cost floor that mainly stops you installing a release published minutes ago, not as a considered quarantine window — it is deliberately weak enough that the project shipped it as a silent default. Refuted: there is no evidence mise considers 24h a security-meaningful window; the docs' own framing (Renovate, pnpm) points at configurations measured in days. Nothing in the docs, changelog, or PR bodies addresses the specific tension of high-churn tools under a long floor, and nothing addresses reconciling a floor with tools that update themselves.

## Sources

Footnote prefixes: `m` = mise, `e` = ecosystem, `s` = self-updaters.

[^m1]: settings.toml — `[minimum_release_age]` block, `default_docs = "24h"`, `env = "MISE_MINIMUM_RELEASE_AGE"`, `optional = true`, `type = "String"` — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/settings.toml#L1498-L1550. Primary. Accessed 2 Aug 2026; mise 2026.8.0.
[^m2]: `src/install_before.rs:12` — `const DEFAULT_MINIMUM_RELEASE_AGE: &str = "24h";` — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/install_before.rs#L12. Primary. Accessed 2 Aug 2026; mise 2026.8.0.
[^m3]: mise docs, Security → Minimum release age — https://mise.jdx.dev/security.html#minimum-release-age (source: `docs/security.md`). Primary. Accessed 2 Aug 2026; mise 2026.8.0.
[^m4]: `src/duration.rs:25-30` — relative durations resolved against `process_now` so version choice and forwarded package-manager flags cannot drift — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/duration.rs#L25-L30. Primary. Accessed 2 Aug 2026.
[^m5]: `src/install_before.rs:32-45` — doc comment stating the precedence order — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/install_before.rs#L32-L45. Primary. Accessed 2 Aug 2026.
[^m6]: `src/install_before.rs:123-159` — `resolve_before_date_with_excludes`; the caller-cutoff and per-tool branches are ungated, the global-setting and built-in-default branches are both guarded by `!excluded`; a zero duration returns `Ok(None)` — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/install_before.rs#L123-L159. Primary. Accessed 2 Aug 2026.
[^m7]: `--minimum-release-age` (alias `--before`) declared in `src/cli/install.rs:66-67`, `src/cli/use.rs:101-102`, `src/cli/latest.rs:34-40`, `src/cli/ls_remote.rs:55-56`, `src/cli/upgrade.rs:98-99`, `src/cli/lock.rs:96-102` — https://github.com/jdx/mise/tree/832623e202ff7be9e3a735c4ba1437d578d3066c/src/cli. Primary. Accessed 2 Aug 2026.
[^m8]: `src/install_before.rs:13` and `:58-72` — `DISABLED_MINIMUM_RELEASE_AGE_CUTOFF = "2099-01-01"`; `resolve_cli_minimum_release_age` maps a zero-duration flag to that sentinel so it outranks lower-precedence values — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/install_before.rs#L58-L72. Primary. Accessed 2 Aug 2026.
[^m9]: `src/install_before.rs:162-178` — `default_minimum_release_age_applies`: Aqua, Cargo, Core, Forgejo, Gem, Github, Gitlab, Go, Npm, Pipx, Spm, Ubi — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/install_before.rs#L162-L178. Primary. Accessed 2 Aug 2026.
[^m10]: `src/backend/backend_type.rs:16-37` — full `BackendType` enum, for the complement of the eligible list — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/backend/backend_type.rs#L16-L37. Primary. Accessed 2 Aug 2026.
[^m11]: `src/backend/mod.rs:308-321` — `VersionInfo::filter_by_date`, "Versions without a created_at timestamp are included by default", implemented with `is_none_or` — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/backend/mod.rs#L308-L321. Primary. Accessed 2 Aug 2026.
[^m12]: `src/backend/mod.rs:2238-2244` — `debug!` (not `warn!`) when no filtered version carries a timestamp — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/backend/mod.rs#L2238-L2244. Primary. Accessed 2 Aug 2026.
[^m13]: `registry/claude.toml` — `aqua:anthropics/claude-code` for linux/macos plus an `http:claude` backend with `version_list_url` pointing at the Google Storage releases bucket — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/registry/claude.toml. Primary. Accessed 2 Aug 2026.
[^m14]: `src/backend/http.rs` — contains no `created_at` field or assignment (verified by grep across the file) — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/backend/http.rs. Primary. Accessed 2 Aug 2026.
[^m15]: `src/backend/aqua.rs:4492-4512` — `get_tags_with_created_at` populates `created_at` from GitHub releases and returns `None` when falling back to bare tags — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/backend/aqua.rs#L4492-L4512. Primary. Accessed 2 Aug 2026.
[^m16]: `docs/security.md` — "already-installed fuzzy matches remain eligible: `minimum_release_age` limits remote version selection and does not make an installed version inactive. Lockfile generation may re-check fuzzy installed matches against release metadata." — https://mise.jdx.dev/security.html#minimum-release-age. Primary. Accessed 2 Aug 2026.
[^m17]: jdx/mise PR #10315, `fix(config): default release age cutoff should not disable installed-version resolution` (2026-06-11), referencing discussion #10308 — https://github.com/jdx/mise/pull/10315. Primary. Accessed 2 Aug 2026.
[^m18]: `src/toolset/tool_version.rs:414-418` and `:641-646` — `should_filter_installed_versions` requires `opts.before_date.is_some() && !opts.before_date_from_default` — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/toolset/tool_version.rs#L414-L418. Primary. Accessed 2 Aug 2026.
[^m19]: `src/backend/npm.rs:630-680` — `build_transitive_release_age_args`, `build_npm_release_age_args` (`--min-release-age` only when supported and `seconds >= 86400`, else `--before`), `build_bun_release_age_args` (`--minimum-release-age <seconds>`), `build_pnpm_release_age_args` (`--config.minimumReleaseAge=<minutes>`) — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/backend/npm.rs#L630-L680. Primary. Accessed 2 Aug 2026.
[^m20]: mise docs, npm backend — package-manager version requirements for release-age forwarding (`pnpm >= 10.16.0`, `bun >= 1.3.0`, `npm >= 11.10.0` / `npm 6.9.0–11.9.x`) — https://mise.jdx.dev/dev-tools/backends/npm.html (source `docs/dev-tools/backends/npm.md` lines 33-45). Primary. Accessed 2 Aug 2026.
[^m21]: `src/backend/npm.rs:33-37` — `BEFORE_DATE_TOLERANCE_SECS: u64 = 60`, so `3d` is never rounded up to `4d` — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/backend/npm.rs#L33-L37. Primary. Accessed 2 Aug 2026.
[^m22]: `src/backend/npm.rs:682-745` — warnings when the package-manager version is undeterminable or below the documented minimum — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/backend/npm.rs#L682-L745. Primary. Accessed 2 Aug 2026.
[^m23]: mise docs, pipx backend — uv `--exclude-newer` requires `uv >= 0.2.22`; pipx fallback uses pip `--uploaded-prior-to` — https://mise.jdx.dev/dev-tools/backends/pipx.html (source `docs/dev-tools/backends/pipx.md` lines 29-33); warnings at `src/backend/pipx.rs:664-676`. Primary. Accessed 2 Aug 2026.
[^m24]: mise docs, Settings → `minimum_release_age_excludes` — type `string[]`, env `MISE_MINIMUM_RELEASE_AGE_EXCLUDES` (comma separated), default `[]`; "A per-tool `minimum_release_age` option or the `--minimum-release-age` CLI flag still applies to matching tools." — https://mise.jdx.dev/configuration/settings.html#minimum_release_age_excludes. Primary. Accessed 2 Aug 2026; mise 2026.8.0.
[^m25]: `src/install_before.rs:180-203` — `is_minimum_release_age_excluded`: exact equality against `backend_arg.short`, the options-stripped full backend ID, and the literal `"{backend_type}:*"` — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/install_before.rs#L180-L203. Primary. Accessed 2 Aug 2026.
[^m26]: `e2e/cli/test_install_before` lines 111-124 — `minimum_release_age_excludes = ["jq"]` skips the global setting for a bare shorthand — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/e2e/cli/test_install_before. Primary. Accessed 2 Aug 2026.
[^m27]: `src/toolset/tool_version_options.rs:14-15`, `:269-282`, `:362-368` — `minimum_release_age` as a recognised core tool-option key, with `install_before` as a deprecated alias — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/toolset/tool_version_options.rs#L269-L282. Primary. Accessed 2 Aug 2026.
[^m28]: `e2e/backend/test_npm_install_before` lines 38-51 — inline table form `"npm:prettier" = { version = "latest", minimum_release_age = "2023-06-01" }`, and the CLI flag overriding it — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/e2e/backend/test_npm_install_before. Primary. Accessed 2 Aug 2026.
[^m29]: `e2e/cli/test_install_before` lines 81-109 — per-tool wins whether it is newer or older than the global value (jq 1.7.1 vs 1.6 in both directions) — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/e2e/cli/test_install_before. Primary. Accessed 2 Aug 2026.
[^m30]: `settings.toml:1315-1319` — `[install_before]` `deprecated = "Use minimum_release_age instead."`, `deprecated_remove_at = "2027.10.0"`, `deprecated_warn_at = "2026.10.0"` — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/settings.toml#L1315-L1319. Primary. Accessed 2 Aug 2026.
[^m31]: `src/cli/lock.rs:124-128` — `latest_versions: self.bump`, `use_locked_version: !self.bump`, `filter_installed_versions_by_release_date: true` — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/cli/lock.rs#L124-L128. Primary. Accessed 2 Aug 2026.
[^m32]: `src/toolset/tool_version.rs:420-505` — every installed/locked fast path in `resolve_version` is gated on `!opts.latest_versions` — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/toolset/tool_version.rs#L420-L505. Primary. Accessed 2 Aug 2026.
[^m33]: `src/lockfile.rs:1976-1979` — `// Only flag upgrades — intentional downgrades are allowed`, inside the github provenance-regression detector; the only downgrade-related guard in the lockfile writer — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/lockfile.rs#L1976-L1979. Primary. Accessed 2 Aug 2026.
[^m34]: `src/toolset/outdated_info.rs:420-426` and test at `:440-442` — `is_outdated_version` returns `c.lt(&l)`; `is_outdated_version("1.12.0", "1.10.0") == false` — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/toolset/outdated_info.rs#L420-L426. Primary. Accessed 2 Aug 2026.
[^m35]: `src/cli/upgrade.rs:773-785` — warning text `newer {tool} release {version}{released} ignored by minimum_release_age{age}; {suffix}`, with `suffix` = `latest eligible release is {eligible}` — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/cli/upgrade.rs#L773-L785. Primary. Accessed 2 Aug 2026.
[^m36]: `src/cli/lock.rs:94-95` and mise docs `mise lock` — "Existing matching lockfile entries are preserved and are not downgraded solely by this flag." — https://mise.jdx.dev/cli/lock.html. Primary. Accessed 2 Aug 2026.
[^m37]: GitHub Issues search API, `https://api.github.com/search/issues?q=repo:jdx/mise+...` for the queries `minimum_release_age in:title`, `is:issue minimum_release_age`, `is:issue is:open bump lockfile older`, `cooldown`, `install_before in:title` — every `minimum_release_age` result was a closed/merged PR; the `is:issue` queries returned zero items. Primary (GitHub API). Accessed 2 Aug 2026.
[^m38]: mise docs, `mise lock` → bumping versions: `mise lock --bump`, `mise lock --bump node`, `mise lock --bump --dry-run`, `mise lock --bump --dry-run --json` — https://mise.jdx.dev/dev-tools/mise-lock.html. Primary. Accessed 2 Aug 2026.
[^m39]: mise docs, Settings → `disable_tools`: "Tools defined in mise.toml that should be ignored", `string[]`, `MISE_DISABLE_TOOLS`, default `[]` — https://mise.jdx.dev/configuration/settings.html#disable_tools. Primary. Accessed 2 Aug 2026; mise 2026.8.0.
[^m40]: mise docs, Settings → `enable_tools`: when set it is the complete allowlist and `disable_tools` is not applied; `[]` disables all tools — https://mise.jdx.dev/configuration/settings.html#enable_tools. Primary. Accessed 2 Aug 2026.
[^m41]: mise docs, Settings → `auto_install_disable_tools` — https://mise.jdx.dev/configuration/settings.html#auto_install_disable_tools. Primary. Accessed 2 Aug 2026.
[^m42]: mise docs, Tool stubs — `#!/usr/bin/env -S mise tool-stub`; tools install on first execution rather than at `mise install` time — https://mise.jdx.dev/dev-tools/tool-stubs.html (source `docs/dev-tools/tool-stubs.md` lines 3-29). Primary. Accessed 2 Aug 2026.
[^m43]: `docs/dev-tools/tool-stubs.md:34` — "Tool stub configuration is essentially a subset of what can be done in `mise.toml` [tools] sections, with the addition of a `tool` field" — https://mise.jdx.dev/dev-tools/tool-stubs.html. Primary. Accessed 2 Aug 2026.
[^m44]: mise docs, `mise self-update` — "Updates mise itself." — https://mise.jdx.dev/cli/self-update.html. Primary. Accessed 2 Aug 2026.
[^m45]: mise docs, Contributing → Packaging and self-update instructions — build feature, `.disable-self-update` marker paths, `mise-self-update-instructions.toml`, `MISE_SELF_UPDATE_AVAILABLE` — https://mise.jdx.dev/contributing.html#packaging-and-self-update-instructions (source `docs/contributing.md` lines 53-101). Primary. Accessed 2 Aug 2026.
[^m46]: `docs/contributing.md:101` — "`mise self-update --force` also bypasses the availability check ... Treat the runtime mechanisms as 'do not update by default' rather than a hard block." — https://mise.jdx.dev/contributing.html. Primary. Accessed 2 Aug 2026.
[^m47]: `src/cli/doctor/mod.rs:168`, `:459`, `:899` — `check_shim_shadowing`, and "Check that mise tool paths appear before system paths in the current PATH" — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/src/cli/doctor/mod.rs#L899. Primary. Accessed 2 Aug 2026.
[^m48]: mise docs, Settings → `activate_aggressive`, default `false` — pushes tools' bin-paths to the front of PATH — https://mise.jdx.dev/configuration/settings.html#activate_aggressive. Primary. Accessed 2 Aug 2026.
[^m49]: Negative result: grep of the mise `docs/` tree at commit `832623e` for `self-updat`, `not managed by mise`, `outside of mise`, and `.local/bin` returned only `mise self-update` packaging material and one shims-directory symlink example; no guidance on managed tools that self-update. Primary (source tree). Accessed 2 Aug 2026.
[^m50]: mise docs, Settings → `minimum_release_age` — "giving the community time to discover compromised releases. This name matches pnpm's `minimumReleaseAge` setting, though mise accepts both relative durations and absolute cutoff dates." — https://mise.jdx.dev/configuration/settings.html#minimum_release_age. Primary. Accessed 2 Aug 2026; mise 2026.8.0.
[^m51]: mise docs, `mise.lock` → "This pairs well with lockfiles — use `minimum_release_age` to avoid picking up brand-new releases, and lockfiles to pin the exact versions you've vetted." — https://mise.jdx.dev/dev-tools/mise-lock.html. Primary. Accessed 2 Aug 2026.
[^m52]: jdx/mise PRs #8842 `feat(install): add per-tool install_before option` and #8851 `feat(npm): apply install_before to transitive dependencies` — https://github.com/jdx/mise/pull/8842, https://github.com/jdx/mise/pull/8851. Primary. Accessed 2 Aug 2026.
[^m53]: jdx/mise PR #9384 `refactor(config): rename install_before setting` (2026-04-25) — https://github.com/jdx/mise/pull/9384. Primary. Accessed 2 Aug 2026.
[^m54]: jdx/mise PR #10279 `feat(config): default release age and warn on hidden versions` (2026-06-09) — introduces the runtime 24h default; the PR body states the change but gives no rationale for the 24h value — https://github.com/jdx/mise/pull/10279. Primary. Accessed 2 Aug 2026.
[^m55]: jdx/mise PRs #10310 `fix(backend): respect permissive minimum release age` and #10344 `fix(backend): honor zero minimum release age flag` — https://github.com/jdx/mise/pull/10310, https://github.com/jdx/mise/pull/10344. Primary. Accessed 2 Aug 2026.
[^m56]: jdx/mise CHANGELOG.md — #10366 (docs: 24h default), #10466 (`fix(upgrade): fix tool removal when minimum_release_age is set`), #10705 (`feat(upgrade): show release date and eligibility in minimum_release_age warning`), #10962 (`fix(prune): don't delete the active version selected by minimum_release_age`) — https://github.com/jdx/mise/blob/832623e202ff7be9e3a735c4ba1437d578d3066c/CHANGELOG.md. Primary. Accessed 2 Aug 2026.
[^e1]: Configuration Options — `minimumReleaseAge` — https://docs.renovatebot.com/configuration-options/#minimumreleaseage. Primary. Accessed 2 Aug 2026; behaviour note references Renovate 42.19.5.
[^e2]: Configuration Options — `internalChecksFilter` — https://docs.renovatebot.com/configuration-options/#internalchecksfilter. Primary. Accessed 2 Aug 2026.
[^e3]: Configuration Options — `minimumReleaseAgeBehaviour` — https://docs.renovatebot.com/configuration-options/#minimumreleaseagebehaviour. Primary. Accessed 2 Aug 2026.
[^e4]: Configuration Options — `vulnerabilityAlerts` (default object includes `"minimumReleaseAge": null`, `"prCreation": "immediate"`) — https://docs.renovatebot.com/configuration-options/#vulnerabilityalerts. Primary. Accessed 2 Aug 2026.
[^e5]: Configuration Options — `internalChecksAsSuccess` (default `false`) — https://docs.renovatebot.com/configuration-options/#internalchecksassuccess. Primary. Accessed 2 Aug 2026.
[^e6]: Configuration Options — `prNotPendingHours` ("If the option `minimumReleaseAge` is non-zero then Renovate disables the `prNotPendingHours` functionality") — https://docs.renovatebot.com/configuration-options/#prnotpendinghours. Primary. Accessed 2 Aug 2026.
[^e7]: Dependabot options reference — `cooldown` — https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference#cooldown. Primary. Accessed 2 Aug 2026; `dependabot.yml` version 2 schema.
[^e8]: Carlin Cherry, "The case for a cooldown: Why Dependabot now waits before issuing version updates", The GitHub Blog, 23 July 2026 — https://github.blog/security/supply-chain-security/the-case-for-a-cooldown-why-dependabot-now-waits-before-issuing-version-updates/. Primary (vendor announcement). Accessed 2 Aug 2026.
[^e9]: pnpm Dependency Resolution Settings — `minimumReleaseAge` — https://pnpm.io/settings/dependency-resolution#minimumreleaseage. Primary. Accessed 2 Aug 2026; docs versioned "11 & 12"; setting added v10.16.0, default changed in v11.
[^e10]: Xavier René-Corail, "Our plan for a more secure npm supply chain", The GitHub Blog, 22 September 2025 — https://github.blog/security/supply-chain-security/our-plan-for-a-more-secure-npm-supply-chain/. Primary (registry operator post-incident statement). Accessed 2 Aug 2026. Note: dated Sept 2025.
[^e11]: "Urgent security alert for Fedora Linux 40 and Fedora Rawhide users", Red Hat, 29 March 2024 (updated 30 March 2024) — https://www.redhat.com/en/blog/urgent-security-alert-fedora-40-and-rawhide-users. Primary (vendor advisory). Accessed 2 Aug 2026; affects xz 5.6.0 and 5.6.1, CVE-2024-3094. Note: dated 2024.
[^e12]: pnpm Dependency Resolution Settings — `minimumReleaseAgeExclude` — https://pnpm.io/settings/dependency-resolution#minimumreleaseageexclude. Primary. Accessed 2 Aug 2026; names v10.16.0, patterns v10.17.0, version selectors v10.19.0.
[^e13]: pnpm Dependency Resolution Settings — `minimumReleaseAgeStrict` and `minimumReleaseAgeIgnoreMissingTime` — https://pnpm.io/settings/dependency-resolution#minimumreleaseagestrict. Primary. Accessed 2 Aug 2026; both added v11.0.0.
[^e14]: pnpm Dependency Resolution Settings — `trustPolicy`, `trustPolicyExclude`, `trustPolicyIgnoreAfter` — https://pnpm.io/settings/dependency-resolution#trustpolicy. Primary. Accessed 2 Aug 2026; v10.21.0 / v10.22.0 / v10.27.0.
[^e15]: npm Config — `min-release-age` — https://docs.npmjs.com/cli/v11/using-npm/config#min-release-age. Primary. Accessed 2 Aug 2026; npm CLI v11.19.0 docs.
[^e16]: npm Config — `min-release-age-exclude` — https://docs.npmjs.com/cli/v11/using-npm/config#min-release-age-exclude. Primary. Accessed 2 Aug 2026; npm CLI v11.19.0 docs.
[^e17]: npm Config — `before` — https://docs.npmjs.com/cli/v11/using-npm/config#before. Primary. Accessed 2 Aug 2026; npm CLI v11.19.0 docs.
[^e18]: Bun docs — `bun install`, "Minimum release age" — https://bun.com/docs/pm/cli/install. Primary. Accessed 2 Aug 2026.
[^e19]: Yarn Settings (`.yarnrc.yml`) — `npmMinimalAgeGate`, `npmPreapprovedPackages` — https://yarnpkg.com/configuration/yarnrc. Primary. Accessed 2 Aug 2026; docs render `npmMinimalAgeGate: "1w"`.
[^e20]: yarnpkg/berry, `packages/plugin-npm/sources/index.ts` (setting definitions: `type: SettingsType.DURATION, unit: DurationUnit.MINUTES, default: '1d'`; `npmPreapprovedPackages` default `[]`) and `packages/plugin-npm/sources/npmConfigUtils.ts` (per-scope `npmMinimalAgeGate` lookup, `isPreapproved`) — https://github.com/yarnpkg/berry/blob/master/packages/plugin-npm/sources/index.ts. Primary (first-party source). Accessed 2 Aug 2026; `master` branch.
[^e21]: pip documentation — `pip install --uploaded-prior-to` — https://pip.pypa.io/en/stable/cli/pip_install/#cmdoption-uploaded-prior-to. Primary. Accessed 2 Aug 2026.
[^e22]: pip Changelog — 26.0 (2026-01-30) adds `--uploaded-prior-to`; 26.1 (2026-04-26) allows a duration in days (`P3D`); 26.2 (2026-07-29) extends it to `pip list --outdated`/`--uptodate` and `pylock.toml` — https://pip.pypa.io/en/stable/news/. Primary. Accessed 2 Aug 2026.
[^e23]: uv Settings reference — `exclude-newer`, `exclude-newer-package` (and their `[tool.uv.pip]` equivalents) — https://docs.astral.sh/uv/reference/settings/#exclude-newer. Primary. Accessed 2 Aug 2026.
[^e24]: Homebrew/brew, `Library/Homebrew/release_cooldown.rb` (`RELEASE_COOLDOWN_DAYS = 1`) — https://github.com/Homebrew/brew/blob/master/Library/Homebrew/release_cooldown.rb. Primary (first-party source). Accessed 2 Aug 2026; `master` branch.
[^e25]: Homebrew/brew, `Library/Homebrew/utils/pypi.rb` (`"--uploaded-prior-to=P#{Homebrew::RELEASE_COOLDOWN_DAYS}D"`, `ignore_cooldown_package` handling) — https://github.com/Homebrew/brew/blob/master/Library/Homebrew/utils/pypi.rb. Primary (first-party source). Accessed 2 Aug 2026; `master` branch.
[^e26]: brew(1) manpage — `update-python-resources --ignore-main-package-cooldown` — https://docs.brew.sh/Manpage. Primary. Accessed 2 Aug 2026.
[^e27]: Debian "testing" distribution — migration criteria ("in unstable for 10, 5 or 2 days, depending on the urgency of the upload"; release manager override) — https://www.debian.org/devel/testing. Primary. Accessed 2 Aug 2026; page modified 2026-07-11.
[^e28]: NixOS/nixpkgs `CONTRIBUTING.md` — branch/channel model, Hydra-gated channel advance, staging workflow — https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md. Primary (first-party source). Accessed 2 Aug 2026; `master` branch.
[^e29]: Go Modules Reference — `GOPROXY` resolution, module proxy protocol, checksum verification; no minimum-age mechanism documented — https://go.dev/ref/mod. Primary. Accessed 2 Aug 2026.
[^e30]: The Cargo Book — Registry Web API, Yank / Unyank endpoints — https://doc.rust-lang.org/cargo/reference/registry-web-api.html. Primary. Accessed 2 Aug 2026.
[^e31]: The Cargo Book — Configuration reference; searched for "minimum age", "cooldown", "quarantine" with no matches — https://doc.rust-lang.org/cargo/reference/config.html. Primary (negative result). Accessed 2 Aug 2026.
[^s1]: Advanced setup — Claude Code docs — https://code.claude.com/docs/en/setup. Primary. Accessed 2 Aug 2026; docs describe v2.1.211 as current.
[^s2]: Environment variables — Claude Code docs — https://code.claude.com/docs/en/env-vars. Primary. Accessed 2 Aug 2026.
[^s3]: Advanced setup § Binary integrity and code signing — https://code.claude.com/docs/en/setup. Primary. Accessed 2 Aug 2026; manifest signatures from v2.1.89 onward.
[^s4]: Advanced setup § Update Claude Code / Auto-updates — https://code.claude.com/docs/en/setup. Primary. Accessed 2 Aug 2026.
[^s5]: Advanced setup § Install with Linux package managers — https://code.claude.com/docs/en/setup. Primary. Accessed 2 Aug 2026.
[^s6]: openai/codex — `codex-rs/tui/src/updates.rs` (`get_upgrade_version`, `get_upgrade_version_for_popup`) and `codex-rs/tui/src/update_prompt.rs`. Primary (first-party source). Accessed 2 Aug 2026; `main` @ commit dated 2026-08-02.
[^s7]: openai/codex — `docs/config.md` contains no reference to `check_for_update_on_startup`; the setting appears only in `codex-rs/core/src/config/mod.rs`. Primary. Accessed 2 Aug 2026.
[^s8]: google-gemini/gemini-cli — `packages/cli/src/utils/handleAutoUpdate.ts`. Primary. Accessed 2 Aug 2026; version 0.55.0-nightly.20260729.
[^s9]: Gemini CLI configuration reference — `docs/reference/configuration.md` and `docs/cli/settings.md`. Primary. Accessed 2 Aug 2026; version 0.55.0-nightly.20260729.
[^s10]: google-gemini/gemini-cli — `packages/cli/src/utils/handleAutoUpdate.ts`, `spawnFn(updateCommand, {stdio:'ignore', shell:true, detached:true})`. Primary. Accessed 2 Aug 2026.
[^s11]: GitHub Copilot CLI configuration directory § Configuration file settings — https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-config-dir-reference. Primary. Accessed 2 Aug 2026.
[^s12]: GitHub Copilot CLI configuration directory — https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-config-dir-reference. Primary. Accessed 2 Aug 2026. Absence of a documented verification claim, not a claim of absence of verification.
[^s13]: microsoft/vscode — `src/vs/platform/update/common/update.config.contribution.ts`. Primary. Accessed 2 Aug 2026; `main`.
[^s14]: microsoft/vscode — `src/vs/platform/update/electron-main/updateService.win32.ts` (`update.sha256hash ? () => checksum(downloadPath, update.sha256hash) : …`). Primary. Accessed 2 Aug 2026.
[^s15]: microsoft/vscode — `src/vs/workbench/contrib/extensions/browser/extensions.contribution.ts`. Primary. Accessed 2 Aug 2026.
[^s16]: microsoft/vscode — `extensions.verifySignature`, default `true`, `included: isNative`, same file. Primary. Accessed 2 Aug 2026.
[^s17]: brew(1) manpage § ENVIRONMENT — https://docs.brew.sh/Manpage. Primary. Accessed 2 Aug 2026.
[^s18]: brew(1) manpage — `--require-sha`, `HOMEBREW_CASK_OPTS`, `brew verify`, `HOMEBREW_VERIFY_ATTESTATIONS`, `HOMEBREW_NO_VERIFY_ATTESTATIONS` — https://docs.brew.sh/Manpage. Primary. Accessed 2 Aug 2026.
[^s19]: Enterprise managed settings reference — https://docs.github.com/en/copilot/reference/enterprise-managed-settings-reference; Configuring enterprise-managed settings — https://docs.github.com/en/copilot/how-tos/administer-copilot/manage-for-enterprise/manage-agents/configure-enterprise-managed-settings. Primary. Accessed 2 Aug 2026. Documented keys cover permissions, model, plugin marketplaces, telemetry; no update key.
[^s20]: Advanced setup § Configure release channel / Pin a minimum version — https://code.claude.com/docs/en/setup; Claude Code settings § `autoUpdatesChannel` — https://code.claude.com/docs/en/settings. Primary. Accessed 2 Aug 2026.
[^s21]: Claude Code settings § Settings files / Managed settings — https://code.claude.com/docs/en/settings. Primary. Accessed 2 Aug 2026; legacy Windows path unsupported as of v2.1.75.
[^s22]: openai/codex — `codex-rs/tui/src/update_action.rs`, `UpdateAction::command_args`. Primary. Accessed 2 Aug 2026.
[^s23]: openai/codex — `codex-rs/install-context/src/lib.rs`, `InstallMethod` docs and `install_method_from_exe` / `standalone_install_method`. Primary. Accessed 2 Aug 2026.
[^s24]: openai/codex — `codex-rs/tui/src/update_action.rs`, `UpdateAction::from_install_context` returns `None` for `InstallMethod::Other`. Primary. Accessed 2 Aug 2026. The mise-specific consequence is inference from this code path.
[^s25]: openai/codex — `codex-rs/core/src/config/mod.rs` (`cfg.check_for_update_on_startup.unwrap_or(true)`), `codex-rs/core/src/config/requirements.rs`, and the `LegacyManagedConfigTomlFromMdm` fixture in `codex-rs/tui/src/debug_config.rs`. Primary. Accessed 2 Aug 2026.
[^s26]: openai/codex — `codex-rs/cli/src/doctor/updates.rs`. Primary. Accessed 2 Aug 2026.
[^s27]: openai/codex — `docs/install.md` § DotSlash. Primary. Accessed 2 Aug 2026.
[^s28]: google-gemini/gemini-cli — `packages/cli/src/ui/utils/updateCheck.ts` (`if (!settings.merged.general.enableAutoUpdateNotification) return null;`). Primary. Accessed 2 Aug 2026.
[^s29]: google-gemini/gemini-cli — `packages/cli/src/config/settings.ts` migration of `disableAutoUpdate` → `enableAutoUpdate` and `disableUpdateNag` → `enableAutoUpdateNotification`. Primary. Accessed 2 Aug 2026.
[^s30]: google-gemini/gemini-cli — `sea/sea-launch.cjs` (`process.env.IS_BINARY = 'true'`) and `packages/cli/src/utils/installationInfo.ts`. Primary. Accessed 2 Aug 2026.
[^s31]: google-gemini/gemini-cli — `packages/cli/src/utils/installationInfo.ts`, final fallback "Assume global npm". Primary. Accessed 2 Aug 2026.
[^s32]: google-gemini/gemini-cli — `packages/cli/src/utils/handleAutoUpdate.ts` (`isSandboxEnabled` early return; `RELEASE_CHANNEL_STABILITY` comparison). Primary. Accessed 2 Aug 2026.
[^s33]: Gemini CLI — `docs/reference/configuration.md` § settings file locations. Primary. Accessed 2 Aug 2026.
[^s34]: GitHub Copilot CLI command reference — https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference. Primary. Accessed 2 Aug 2026.
[^s35]: Installing GitHub Copilot CLI — https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/install-copilot-cli. Primary. Accessed 2 Aug 2026.
[^s36]: GitHub Copilot CLI configuration directory § cache directory — https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-config-dir-reference. Primary. Accessed 2 Aug 2026.
[^s37]: microsoft/vscode — `extensions.autoUpdateDelay`, `default: 2`, policy `ExtensionsAutoUpdateDelay`, in `src/vs/workbench/contrib/extensions/browser/extensions.contribution.ts`. Primary. Accessed 2 Aug 2026.
[^s38]: Settings Sync — https://code.visualstudio.com/docs/configure/settings-sync. Primary. Accessed 2 Aug 2026; page dated 02/04/2026.
[^s39]: microsoft/vscode — migration comment in `extensions.contribution.ts`: "Migrates the `extensions.autoUpdate` setting to its new `'on' | 'off'` values … `true` (All Extensions) and `'onlyEnabledExtensions'` … are now retired." Primary. Accessed 2 Aug 2026.
[^s40]: brew(1) manpage — `HOMEBREW_API_AUTO_UPDATE_SECS` (default 450), `HOMEBREW_FORCE_API_AUTO_UPDATE` — https://docs.brew.sh/Manpage. Primary. Accessed 2 Aug 2026.
[^s41]: Advanced setup § Homebrew tab — https://code.claude.com/docs/en/setup. Primary. Accessed 2 Aug 2026.
[^s42]: Google, *Chrome Updates technical document* (PDF), §"Common update management strategies" and §"Strategy 1: Auto-update" — https://storage.googleapis.com/support-kms-prod/IIlkdLHYfuZQkfqwPPEYCZvQbHOzJSCsnXQh, linked from https://support.google.com/chrome/a/answer/9982578. Primary. Accessed 2 Aug 2026; undated PDF, references 4-week Stable / 8-week Extended Stable cadence.
[^s43]: Google, *Chrome Updates technical document*, §"Strategy 2: Version pinning by milestone" and §"Strategy 3: Version pinning by full version". Primary. Accessed 2 Aug 2026.
[^s44]: Google, *Chrome Updates technical document*, §"Chrome Variations Framework" and §"Component Updates". Primary. Accessed 2 Aug 2026.
[^s45]: NIST SP 800-40r4, *Guide to Enterprise Patch Management Planning*, Executive Summary and §3 — https://doi.org/10.6028/NIST.SP.800-40r4. Primary. Accessed 2 Aug 2026; published April 2022.
[^s46]: NIST SP 800-40r4 §3 "Rely on automation." Primary. Accessed 2 Aug 2026.
[^s47]: NIST SP 800-40r4 §2.3.1 "Prepare to Deploy the Patch". Primary. Accessed 2 Aug 2026.
[^s48]: NIST SP 800-40r4 §3.5.1 "Maintenance Plans for Scenario 1, Routine Patching". Primary. Accessed 2 Aug 2026.
[^s49]: OpenSSF, *npm Best Practices Guide* v1.1, §"Reproducible installation" — https://github.com/ossf/package-manager-best-practices/blob/main/published/npm.md. Primary (OpenSSF working-group publication). Accessed 2 Aug 2026.
[^s50]: Google, *Chrome Updates technical document*, §"Strategy 2" pros/cons and §"Strategy 4" ("Consider Strategy 2 instead"). Primary. Accessed 2 Aug 2026.
[^s51]: NIST SP 800-40r4 §3.4 "Assign Each Asset to a Maintenance Group". Primary. Accessed 2 Aug 2026.
