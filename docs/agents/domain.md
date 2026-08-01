# Dotfiles

The vocabulary for a repository whose runbook *is* its config: one declarative
description of a machine, applied by mise to macOS, Fedora, Debian, Arch and
Windows alike.

## Language

### Applying a machine

**Converge**:
Bring this machine into the state the config declares. Idempotent by
definition — converging an already-correct machine changes nothing.
_Avoid_: provision, set up, install (for the whole-machine sense), run the dotfiles

**Bootstrap**:
Reserved for mise's own names — the `mise bootstrap` command, the
`[bootstrap.*]` config namespace, and `[tasks.bootstrap]`. Not a synonym for
converge, and not what `bootstrap.sh` does.
_Avoid_: using it for the act of converging

**Installer**:
`bootstrap.sh` / `bootstrap.ps1`. Their only job is to put mise on the machine
so it can converge. They are not part of convergence.
_Avoid_: calling these "the bootstrap"

### What gets installed

**Tool**:
A versioned CLI that mise's registry can install, declared once and pinned by
the lockfile, so every OS gets the identical version.
_Avoid_: package, binary, dependency

**System package**:
Software installed by the OS's own package manager because mise's registry
cannot supply it, it is machine-global, or it must exist before mise does.
_Avoid_: package (unqualified), distro package, native package

**Parity**:
The property that a system package declared for one Linux package manager is
declared for all of them, or carries a written reason why it is not.
_Avoid_: consistency, coverage

### What does *not* get installed

**Sync-owned**:
Deliberately unmanaged because an upstream mechanism converges it unattended,
so declaring it here would be a second, weaker copy.
_Avoid_: external, synced, not our problem

**Manual step**:
Deliberately unmanaged because nothing converges it — a human runs one command
once per machine. Distinguished from sync-owned by the fact that a fresh
machine never reaches steady state on its own.
_Avoid_: prerequisite, TODO, manual install

### Linking

**Owned file**:
A file whose *content* this repo is the source of truth for. Editing it in the
home directory and editing it in the repo are the same act.
_Avoid_: managed file, our file, tracked file

**Foreign writer**:
A process that creates *new* files inside a directory that holds owned files —
plugin payloads, caches, logs, sockets, sessions. The reason a directory can be
fully owned file-by-file and still not be ours to claim wholesale.
_Avoid_: the tool writes to it, side effects, machine-local state

**Relocatable**:
Said of a foreign writer that can be pointed at a different directory by
configuration, removing the conflict rather than working around it.
_Avoid_: configurable, movable
