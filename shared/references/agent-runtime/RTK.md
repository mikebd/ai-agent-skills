# RTK - Rust Token Killer (https://github.com/rtk-ai/rtk)

**Usage**: Token-optimized CLI proxy (60-90% savings on dev operations)

Use this guide at session start and before selecting shell commands.

## Trigger semantics

Read and apply this document when:
- the task is likely to use local shell commands
- the task is likely to use text search, git commands, or Go test/build/vet commands
- or `command -v rtk` succeeds

## Enforcement mode

RTK ships a pre-execution hook for some agents and instructions-only support for
others. Which mode is active decides how much of this document the agent must
apply by hand.

- Hook-enforced: the agent runs a PreToolUse-style hook that rewrites shell
  commands to their RTK equivalents before execution (`rtk rewrite` is the
  shared engine). Command selection is mechanical; this document is background
  and exception handling, not a per-command checklist.
- Instruction-enforced: no hook exists for the agent. The command selection
  rules below are the only thing that keeps RTK in use, so apply them
  deliberately for every command.

The execution model overlay for the active agent states which mode applies and
how to install it. As of RTK 0.45, `rtk init` installs a hook for Claude Code
(and Cursor, Gemini, Copilot, and others) but `rtk init --codex` writes docs
only, so Codex is instruction-enforced.

## Session preflight

When RTK.md applies:
- verify RTK availability with `command -v rtk`
- if RTK is present, run `rtk --version` or `rtk help` once to confirm the binary is usable
- treat RTK as active for the remainder of the session unless a command-specific exception applies
- when unsure about a subcommand, run `rtk help <command>` before falling back to a raw command

Under instruction-enforced mode, additionally:
- treat RTK-native command selection as the default for supported operations
- do not silently bypass RTK when a suitable RTK-native command exists
- if a raw command is chosen instead of RTK, state the reason briefly in commentary or in the final response when no commentary is sent

Under hook-enforced mode, do not hand-translate commands to keep the hook busy.
Writing a plain `git status` or `go test ./...` is correct; the hook rewrites
it. Already-RTK commands pass through unchanged rather than being wrapped
twice, so an explicit `rtk ...` command is harmless when it is genuinely the
clearest way to express the intent.

## Meta commands

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk proxy <cmd>       # Execute raw command without filtering (debug/edge cases)
```

## Installation verification

```bash
rtk --version         # Should show: rtk X.Y.Z
rtk gain              # Should work (not "command not found")
which rtk             # Verify correct binary
```

## Session command selection guidance

- When unsure about usage/options for a native command, run `rtk help <command>`.
- Ignore: `rtk gain`.
- Under instruction-enforced mode, ignore the hook/Claude-oriented commands:
  `cc-economics`, `discover`, `learn`, `session`, `hook-audit`. Under
  hook-enforced mode they are the tools for auditing whether the hook is
  actually firing; use them when asked, not routinely.
- Some `rtk` commands are repository-language-specific; prioritize generic commands or ones aligned to languages in use (`go`, `javascript`/`typescript`/`node`, `rust`, `python`).

### Command selection rules (strict)

These rules are mandatory under instruction-enforced mode. Under hook-enforced
mode they describe what the hook already does; read them to predict its
behavior and to recognize the exceptions below.

- Prefer native `rtk` subcommands first for routine operations.
- For text search, default to `rtk grep` unless it cannot express the needed search behavior.
- Do not pass ripgrep-only `--glob` filters to `rtk grep`. In the supported
  RTK environment, they are delegated to GNU grep and fail whether or not
  they follow `--`. When a search needs `--glob`, use `rtk rg`, which runs
  ripgrep natively under the same output filter; do not first try the failing
  `rtk grep` form. If `rtk rg` is unavailable on an older RTK build, fall back
  to a narrow raw `rg` command and treat it as a raw-command exception.
- For git operations, prefer `rtk git ...` where supported.
- For Go test/build/vet operations, prefer `rtk go test`, `rtk go build`, and `rtk go vet` where supported.
- If native `rtk` is not suitable or not beneficial, run the raw command directly only after checking whether RTK has a suitable native subcommand.
- Use `rtk proxy` only when native `rtk` cannot express the required command or output behavior.

### Raw-command exceptions

Raw commands are allowed when:
- RTK lacks the needed feature or flags
- exact raw output is required for correctness, parsing, or review
- true streaming or TTY behavior is required
- RTK output compaction would hide diagnostics that matter for the task
- execution-mode, approval, or environment behavior requires a direct command and RTK changes that behavior materially

When using a raw command under one of these exceptions:
- prefer the narrowest raw command that preserves correctness
- state the exception briefly so RTK bypasses stay auditable

### Verbose non-native fallback

- For verbose commands without a suitable native `rtk` subcommand, use `shared/scripts/rtk_proxy.sh`.
- `rtk_proxy.sh` preserves the wrapped command exit code and compacts captured output via `rtk read`.
- Do not use this wrapper when true streaming/TTY output is required, or when output compaction could compromise correctness. In those cases use direct command execution or `rtk proxy`.

Examples:

```bash
# Preferred ordinary text search
rtk grep -n "int32\\(" ./path/to/package

# Glob filtering: rtk rg runs ripgrep natively
rtk rg -n "int32\\(" ./path/to/package --glob "*test.go"

# Debug/edge-case fallback only
rtk proxy rg -n "complex-regex-or-feature" .
```

## Go test guidance

- Prefer `rtk go test` for both unit and integration tests.
- `rtk go test` may run under constrained execution by default.
- Integration tests that use Docker/Testcontainers need access to `/var/run/docker.sock`, which constrained execution may withhold.
- When that access is required, use elevated execution for `rtk go test` commands; see the execution model overlay for the active agent.

Recommended patterns:

```bash
# Unit tests
rtk go test ./path/to/pkg -run 'TestA|TestB' -count=1

# Integration tests
rtk go test -tags=integration ./path/to/integration/pkg -run 'TestA|TestB' -count=1
```

Optional cache isolation (useful in constrained environments). Under
hook-enforced mode an `env ...` prefix is preserved and only the inner command
is rewritten, so this form stays correct:

```bash
env GOCACHE=/tmp/go-build-cache GOMODCACHE=/tmp/go-mod-cache rtk go test ...
```
