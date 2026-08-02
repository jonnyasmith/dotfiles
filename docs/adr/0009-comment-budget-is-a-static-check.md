# The comment budget is a static check

`check:comments` fails `mise run check` — the same task CI runs — when a
git-tracked config or script file contains a run of consecutive whole-line
comments longer than the budget. The budget is set from the measured longest
block in the stripped tree, not from a number chosen in advance.

`docs/agents/code-comments.md` has always said what a comment may contain, and
`AGENTS.md` routes to it. Routing is on demand, and nothing about editing
`mise.toml` triggers the read. The policy had the same shape the registry and
parity rules had before ADR 0003: it existed as prose, and it was not applied.
1,198 of 1,607 comment lines in this repo were in breach of it.

Waivers are `# comment-budget-skip: <reason>` on the block's first line, the
same convention `check:packages` uses — the reason lives where the decision is
visible, never in a separate manifest.

## Consequences

- **Block length catches an essay and catches nothing else.** A three-line
  restatement of the declaration passes. Six one-line labels on six consecutive
  aliases pass. The check exists because essays are what actually accumulated,
  not because it is a complete test of the policy. The census was the judgement,
  and it happened once.
- Scope is files with a recognised line-comment syntax, minus a vendored list
  held in the task body: the AstroNvim template under `home/.config/nvim/`,
  `desktop/cosmic/` (ADR 0008 requires it stay byte-comparable to upstream),
  herdr, btop, gh and htop's tool-written configs, and
  `home/.config/1Password/ssh/agent.toml`, whose first thirty lines are
  1Password's own generated header. Markdown is out of scope: `#` is a heading
  there, and prose is what `docs/` is for.
- PowerShell's `<# ... #>` comment-based help is invisible to the check, because
  neither delimiter line starts with `#`. That is deliberate: `bootstrap.ps1`'s
  help block is an interface `Get-Help` reads, not prose.
- Raising the budget is a decision, not a fix. A block that needs the length
  takes a waiver so the reason sits beside it; the budget itself moves only if
  the tree's honest maximum moves.
- The check needs `git` to enumerate tracked files, which is the third runtime
  dependency in the gate after `mise search` and `shellcheck`. `git` is declared
  for every package manager in `[bootstrap.packages]`.
