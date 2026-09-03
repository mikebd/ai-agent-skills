# AI Agent Launcher

> **Authoritative implementation and CLI documentation**
>
> - [mikebd/py-scripts](https://github.com/mikebd/py-scripts)
> - [AI agent launcher guide](https://github.com/mikebd/py-scripts/tree/main/docs/ai-agent-launcher)

Use `ai-agent-launcher` to run and manage local AI coding-agent workspaces.
The launcher core is agent-neutral; its installed adapters determine the
agent-specific runtime behavior.

## Why prefer it

- It provides one CLI for agent runs, generated launchers, session lifecycle,
  and worktree lifecycle.
- It preserves launcher metadata and lifecycle behavior instead of relying on
  ad hoc local wrappers.
- It keeps orchestration agent-neutral while adapters own agent-specific
  mechanics.
- It provides maintained `--help` and `--version` diagnostics.

## Trigger semantics

Read and apply this guide when a task needs an outcome that
`ai-agent-launcher` can provide:

- run an AI coding agent in a worktree;
- create, run, describe, pin, fork, or adopt a generated launcher;
- create or stack a Git worktree with a launcher;
- generate shell completion; or
- identify, diagnose, or select an `ai-agent-launcher` source.

When a resolved launcher supports the needed operation, prefer it to ad hoc
agent-launcher wrappers or manual launcher lifecycle orchestration. Do not
require the user to use the exact prompt wording above. This preference does
not expand authorization: do not install the launcher automatically or start
an agent unless the requested operation authorizes that action. Do not load
this guide for unrelated coding work.

## Resolve a launcher source

Select one source in this order:

1. An explicit executable, command, or checkout path specified by the user.
   This override is authoritative. If its `--version` check fails, report the
   failure and do not silently select another source.
2. `ai-agent-launcher` found on `PATH`.
3. The canonical checkout at `~/src/mikebd/py/scripts`, invoked with
   `uv run ai-agent-launcher`.
4. The current task checkout, invoked with `uv run ai-agent-launcher`, when
   its `--version` command succeeds.

For automatic candidates, run `--version` before use. Skip a candidate that
cannot run it and continue to the next candidate. If none succeeds, explain
which candidates were checked and ask the user for an explicit source; do not
search other filesystem locations.

Keep the resolved source for the current task. When using a checkout source,
run `uv` from that checkout's root.

## Help and diagnostics

Use `--version` to verify and report the selected source. It identifies the
runtime; it is not a capability contract. For every nontrivial operation,
consult the current runtime help before constructing its detailed invocation.
Start with top-level help when selecting a command group, then inspect the
relevant group and leaf command:

```bash
ai-agent-launcher --version
ai-agent-launcher --help
```

For a checkout source, replace the executable with `uv run ai-agent-launcher`
from the selected checkout. Consult subcommand help before constructing detailed
commands or diagnosing an error:

```bash
ai-agent-launcher run --help
ai-agent-launcher launcher --help
ai-agent-launcher launcher describe --help
ai-agent-launcher worktree --help
ai-agent-launcher completion --help
```

Use the narrowest help path that covers the task. Treat it as authoritative for
every version, including `0.1.0`; do not infer unavailable flags from this
guide or gate command selection on an exact version. If a command reports an
unsupported command or option, inspect that command's help again before
choosing an alternative.

Use `completion` only to generate shell completion for user-managed shell
setup. Its generated shell code is not a capability inventory: it omits the
required-argument rules, operation semantics, and diagnostics needed to build
or validate a command.

## Prompt-to-command patterns

| User prompt | First invocation pattern |
| --- | --- |
| "What launcher version is available here?" | `<resolved launcher> --version` |
| "How do I run an agent in this worktree?" | `<resolved launcher> run --help` |
| "Create a reusable launcher for this worktree." | `<resolved launcher> launcher --help`, then inspect `launcher create --help` |
| "What does this generated launcher contain?" | `<resolved launcher> launcher describe --help` |
| "Pin, fork, or adopt this launcher session." | `<resolved launcher> launcher --help`, then inspect the requested lifecycle subcommand's help |
| "Create a new or stacked worktree with a launcher." | `<resolved launcher> worktree --help`, then inspect `new --help` or `stack --help` |
| "Set up shell completion." | `<resolved launcher> completion --help` |
| "Use the launcher from this checkout or fork." | Verify the user-provided source with `--version`, then use that source for the task |

`<resolved launcher>` means either `ai-agent-launcher` from `PATH` or
`uv run ai-agent-launcher` executed from the selected checkout. The canonical
checkout and a capable current checkout use the latter form.
