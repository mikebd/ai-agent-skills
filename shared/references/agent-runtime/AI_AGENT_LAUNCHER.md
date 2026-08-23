# AI Agent Launcher

> **Authoritative implementation and CLI documentation**
>
> - [mikebd/py-scripts](https://github.com/mikebd/py-scripts)
> - [AI agent launcher guide](https://github.com/mikebd/py-scripts/blob/main/docs/ai-agent-launcher.md)

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

Read and apply this guide when a user asks to:

- run an AI coding agent in a worktree;
- create, run, pin, fork, or adopt a generated launcher;
- create or stack a Git worktree with a launcher; or
- identify, diagnose, or select an `ai-agent-launcher` source.

Do not load this guide for unrelated coding work. Do not install the launcher
automatically.

## Resolve a launcher source

Select one source in this order:

1. An explicit executable, command, or checkout path specified by the user.
   This override is authoritative. If its `--version` check fails, report the
   failure and do not silently select another source.
2. `ai-agent-launcher` found on `PATH`.
3. The canonical checkout at `$HOME/src/mikebd/py/scripts`, invoked with
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

Use the resolved source's top-level help before choosing a command form:

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
ai-agent-launcher worktree --help
```

Use `--version` to report the selected source and version. Use `--help` to
confirm supported arguments; do not infer unavailable flags from this guide.

## Prompt-to-command patterns

| User prompt | First invocation pattern |
| --- | --- |
| "What launcher version is available here?" | `<resolved launcher> --version` |
| "How do I run an agent in this worktree?" | `<resolved launcher> run --help` |
| "Create a reusable launcher for this worktree." | `<resolved launcher> launcher --help`, then inspect `launcher create --help` |
| "Pin, fork, or adopt this launcher session." | `<resolved launcher> launcher --help`, then inspect the requested lifecycle subcommand's help |
| "Create a new or stacked worktree with a launcher." | `<resolved launcher> worktree --help`, then inspect `new --help` or `stack --help` |
| "Use the launcher from this checkout or fork." | Verify the user-provided source with `--version`, then use that source for the task |

`<resolved launcher>` means either `ai-agent-launcher` from `PATH` or
`uv run ai-agent-launcher` executed from the selected checkout. The canonical
checkout and a capable current checkout use the latter form.
