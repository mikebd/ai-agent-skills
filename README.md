# ai-agent-skills

Agentic workflow utilities and skills.

## Companion repositories

These optional repositories complement this guidance; `ai-agent-skills` does
not require either checkout.

- [`mikebd/bash-scripts`](https://github.com/mikebd/bash-scripts): shell-first
  utilities for direct local workflows.
- [`mikebd/py-scripts`](https://github.com/mikebd/py-scripts): maintained
  Python CLIs, including [`ai-agent-launcher`](https://github.com/mikebd/py-scripts/blob/main/docs/ai-agent-launcher.md).

## Layout

- `codex/skills`: Source-of-truth Codex skills (folders with SKILL.md)
- `codex/packages`: Optional packaged .skill bundles for sharing
- `codex/EXECUTION_MODEL.md`: Codex mapping for the agent-neutral runtime contract
- `claude/skills`: Claude-specific skill/prompt formats
- `claude/EXECUTION_MODEL.md`: Claude Code mapping for the agent-neutral runtime contract
- `claude/CLAUDE.md.example`: Copyable `~/.claude/CLAUDE.md` bootstrap
- `claude/settings.json.example`: Optional permission allowlist matching the runtime contract, minus package installs. Lists each rule in raw and `rtk`-prefixed form, since the RTK hook rewrites commands before permission matching
- `claude/scripts/rtk-install.sh`: Installs the RTK hook for Claude Code, pinned to rtk's absolute path
- `claude/scripts/rtk-guard.sh`: Checks that the RTK hook is registered and pinned, and reports duplicate RTK.md guidance
- `claude/scripts/rtk-hook-probe.py`: Helper for `rtk-guard.sh`; reports whether `settings.json` registers the hook, and whether it is pinned
- `claude/scripts/rtk-hook-probe-test.py`: Regression tests for the probe, including Claude Code's matcher rules. Run it directly; no dependencies
- `shared/scripts`: Cross-agent utilities
- `shared/references`: Cross-agent docs and references
- `shared/references/agent-runtime`: Shared runtime guidance/docs reusable across agents
- `shared/references/branch-context`: Optional Branch Context guidance, enabled only when its canonical reference is explicitly sourced

## Branch Context

Branch Context is an optional, agent-neutral practice for keeping useful
working memory with a branch. It can make work easier to resume, explain, hand
off, and review by preserving the reasoning around a change alongside its
current state.

Depending on the work, a BC may contain durable framing and decisions, current
findings and evidence, optional work decomposition and plans, reusable methods
or artifacts, and lifecycle history. These materials complement a pull
request; they do not replace the product code, tests, or independent review.

- Read the [Branch Context adoption guide](shared/references/branch-context/README.md).
- See the [canonical behavior reference](shared/references/branch-context/BRANCH_CONTEXT.md).
- Browse the [public BC catalog](https://github.com/mikebd/public-branch-context/blob/main/README.md).

## Supported agents

Runtime guidance and Branch Context are agent-neutral. Each agent is wired up
through its own bootstrap mechanism and an execution model overlay that maps
the neutral execution terms onto that agent's real permission mechanics.

| Agent | Bootstrap | Overlay |
| --- | --- | --- |
| Codex | `developer_instructions` in `~/.codex/config.toml` | [`codex/EXECUTION_MODEL.md`](codex/EXECUTION_MODEL.md) |
| Claude Code | `~/.claude/CLAUDE.md` | [`claude/EXECUTION_MODEL.md`](claude/EXECUTION_MODEL.md) |

See the [agent runtime README](shared/references/agent-runtime/README.md) for
step-by-step setup for each.

**RTK is optional.** It is a CLI proxy that trims tokens from command output;
the runtime contract, the execution-model overlays and Branch Context all work
without it, and nothing here requires you to adopt it. Skip this paragraph if
you are not using it — `rtk-guard.sh` passes on a machine with no rtk and no
hook, rather than telling you to install something.

If you do want it, integration is asymmetric and each overlay documents its
side: `rtk init` installs a command-rewriting hook for Claude Code, while
`rtk init --codex` writes documentation only. Claude Code users run
[`claude/scripts/rtk-install.sh`](claude/scripts/rtk-install.sh) once (rtk itself
comes from `brew install rtk`, or see <https://www.rtk-ai.app/>). It installs
the hook without RTK's upstream RTK.md, which would otherwise duplicate
[`RTK.md`](shared/references/agent-runtime/RTK.md) in every session, and pins the
hook to rtk's absolute path so it keeps working on GUI-launched surfaces, where a
bare `rtk` fails silently. [`claude/scripts/rtk-guard.sh`](claude/scripts/rtk-guard.sh)
verifies both. Codex users rely on the selection rules in that same document.

One consequence to know before writing permission rules: the hook rewrites
commands *before* Claude Code evaluates `permissions.allow`, so rules must match
the rewritten command. See
[Under the RTK hook, rules match the rewritten command](claude/EXECUTION_MODEL.md#under-the-rtk-hook-rules-match-the-rewritten-command).

## Claude Code install

1. Clone this repo locally.
2. Copy [`claude/CLAUDE.md.example`](claude/CLAUDE.md.example) to
   `~/.claude/CLAUDE.md` (or merge it into an existing one) and replace
   `/ABS/PATH/TO/ai-agent-skills` with your clone path.
3. Optionally merge [`claude/settings.json.example`](claude/settings.json.example)
   into `~/.claude/settings.json`. It deliberately omits package-install
   commands; see [Package operations are a separate, deliberate opt-in](claude/EXECUTION_MODEL.md#package-operations-are-a-separate-deliberate-opt-in).
4. Optionally adopt RTK: install it with `brew install rtk` or from
   <https://www.rtk-ai.app/>, then run `./claude/scripts/rtk-install.sh`. Verify
   with `./claude/scripts/rtk-guard.sh`. Skipping this is a supported
   configuration, not a half-finished setup.

Keep only the reference lines you want: runtime guidance, the permission
allowlist, RTK and Branch Context are independent opt-ins.

## Codex install

Run:

  `./codex/sync-to-codex.sh`

This copies `codex/skills` into `~/.codex/skills`.

## Codex sync back

Run:

  `./codex/sync-from-codex.sh <skill-name>`

The `<skill-name>` parameter is required and must be a simple directory name.

This copies the specified skill: `~/.codex/skills/<skill-name>` into `codex/skills/<skill-name>`.

## Agent Runtime Staging

`shared/references/agent-runtime` is where reusable non-secret runtime material is staged so local agent-home files can later be replaced by lightweight pointers/references.

The rule governs *reusable non-secret material* only: once a doc is staged here, the agent home should hold a pointer to it rather than a second copy. Everything else in the agent home stays put. In particular, do not remove:

- **Bootstrap files** that load the contract at session start: `~/.claude/CLAUDE.md`, `developer_instructions` in `~/.codex/config.toml`. These are what make the staged material reachable; deleting them deactivates runtime guidance entirely.
- **Configuration**, including `~/.claude/settings.json` and the rest of `~/.codex/config.toml`.
- **Synchronized skills** under `~/.codex/skills`, which `codex/sync-to-codex.sh` writes and expects to find.
- **Machine-local/private state**: tokens, local overrides, history, sqlite/session state, and `<agent-home>/LOCAL-MACHINE.md`.

For docs that need local defaults (for example env file paths or default DB schema), keep placeholders in repo docs and provide local wrappers in the agent home (see `POSTGRES_AUDIT.local-wrapper.example.md`).
