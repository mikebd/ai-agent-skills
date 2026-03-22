# RTK - Rust Token Killer (https://github.com/rtk-ai/rtk)

**Usage**: Token-optimized CLI proxy (60-90% savings on dev operations)

Use this guide at session start and before selecting shell commands.

## Trigger semantics

Read and apply this document when:
- the task is likely to use local shell commands
- the task is likely to use text search, git commands, or Go test/build/vet commands
- or `command -v rtk` succeeds

When this document applies:
- run `command -v rtk` once near session start if RTK availability is not already known
- if `rtk` is available, treat RTK-native command selection as the default for supported operations
- do not silently bypass RTK when a suitable RTK-native command exists
- if a raw command is chosen instead of RTK, state the reason briefly in commentary or in the final response when no commentary is sent

## Session preflight

When RTK.md applies:
- verify RTK availability with `command -v rtk`
- if RTK is present, run `rtk --version` or `rtk help` once to confirm the binary is usable
- treat RTK as active for the remainder of the session unless a command-specific exception applies
- when unsure about a subcommand, run `rtk help <command>` before falling back to a raw command

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
- Ignore Claude-specific commands: `cc-economics`, `discover`, `learn`, `hook-audit`.
- Some `rtk` commands are repository-language-specific; prioritize generic commands or ones aligned to languages in use (`go`, `javascript`/`typescript`/`node`, `rust`, `python`).

### Command selection rules (strict)

- Prefer native `rtk` subcommands first for routine operations.
- For text search, default to `rtk grep` (not `rtk proxy rg`) unless `rtk grep` cannot express the needed search behavior.
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
- sandbox, escalation, or environment behavior requires a direct command and RTK changes that behavior materially

When using a raw command under one of these exceptions:
- prefer the narrowest raw command that preserves correctness
- state the exception briefly so RTK bypasses stay auditable

### Verbose non-native fallback

- For verbose commands without a suitable native `rtk` subcommand, use `shared/scripts/rtk_proxy.sh`.
- `rtk_proxy.sh` preserves the wrapped command exit code and compacts captured output via `rtk read`.
- Do not use this wrapper when true streaming/TTY output is required, or when output compaction could compromise correctness. In those cases use direct command execution or `rtk proxy`.

Examples:

```bash
# Preferred
rtk grep -n "int32\\(" ./path/to/package -- --glob "*test.go"

# Also acceptable when rtk adds no value
rg -n "int32\\(" ./path/to/package --glob "*test.go"

# Debug/edge-case fallback only
rtk proxy rg -n "complex-regex-or-feature" .
```

## Go test guidance

- Prefer `rtk go test` for both unit and integration tests.
- In Codex tool sessions, `rtk go test` may run sandboxed by default.
- Integration tests that use Docker/Testcontainers require unsandboxed execution to access `/var/run/docker.sock`.
- When unsandboxed execution is required, use escalated execution for `rtk go test` commands.

Recommended patterns:

```bash
# Unit tests
rtk go test ./path/to/pkg -run 'TestA|TestB' -count=1

# Integration tests
rtk go test -tags=integration ./path/to/integration/pkg -run 'TestA|TestB' -count=1
```

Optional cache isolation (useful in constrained environments):

```bash
env GOCACHE=/tmp/go-build-cache GOMODCACHE=/tmp/go-mod-cache rtk go test ...
```
