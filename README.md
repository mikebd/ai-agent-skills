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
- `claude/settings.json.example`: Optional permission allowlist matching the runtime contract
- `claude/scripts/rtk-install.sh`: Installs the RTK hook for Claude Code, pinned to rtk's absolute path
- `claude/scripts/rtk-guard.sh`: Checks the RTK hook for PATH fragility and duplicate RTK.md guidance
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

RTK integration is asymmetric and each overlay documents its side: `rtk init`
installs a command-rewriting hook for Claude Code, while `rtk init --codex`
writes documentation only. Claude Code users should run
[`claude/scripts/rtk-install.sh`](claude/scripts/rtk-install.sh) once. It installs
the hook without RTK's upstream RTK.md, which would otherwise duplicate
[`RTK.md`](shared/references/agent-runtime/RTK.md) in every session, and pins the
hook to rtk's absolute path so it keeps working on GUI-launched surfaces, where a
bare `rtk` fails silently. [`claude/scripts/rtk-guard.sh`](claude/scripts/rtk-guard.sh)
verifies both. Codex users rely on
the selection rules in that same document.

## Claude Code install

1. Clone this repo locally.
2. Copy [`claude/CLAUDE.md.example`](claude/CLAUDE.md.example) to
   `~/.claude/CLAUDE.md` (or merge it into an existing one) and replace
   `/ABS/PATH/TO/ai-agent-skills` with your clone path.
3. Optionally merge [`claude/settings.json.example`](claude/settings.json.example)
   into `~/.claude/settings.json`.

Keep only the reference lines you want: runtime guidance and Branch Context are
independent opt-ins.

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

Keep in the agent home (`~/.codex`, `~/.claude`) only machine-local/private state (tokens, local overrides, history, sqlite/session state).
For docs that need local defaults (for example env file paths or default DB schema), keep placeholders in repo docs and provide local wrappers in the agent home (see `POSTGRES_AUDIT.local-wrapper.example.md`).
