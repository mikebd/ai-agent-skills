# RTK - Rust Token Killer

**Usage**: Token-optimized CLI proxy (60-90% savings on dev operations)

## Meta Commands (always use rtk directly)

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk proxy <cmd>       # Execute raw command without filtering (debug/edge cases)
```

## Installation Verification

```bash
rtk --version         # Should show: rtk X.Y.Z
rtk gain              # Should work (not "command not found")
which rtk             # Verify correct binary
```

## Session Command Selection Guidance

- Discover available `rtk` commands at the beginning of each session by running `rtk`.
- When unsure about usage/options for a native command, run `rtk help <command>`.
- Ignore: `rtk gain`.
- Ignore Claude-specific commands: `cc-economics`, `discover`, `learn`, `hook-audit`.
- Some `rtk` commands are repository-language-specific; prioritize generic commands or ones aligned to languages in use (`go`, `javascript`/`typescript`/`node`, `rust`, `python`).

### Command Selection Rules (strict)

- Prefer native `rtk` subcommands first for routine operations.
- For text search, default to `rtk grep` (not `rtk proxy rg`) unless `rtk grep` cannot express the needed search behavior.
- For git operations, prefer `rtk git ...` where supported.
- If native `rtk` is not suitable or not beneficial, run the raw command directly.
- Avoid `rtk proxy` in normal workflow; reserve it for debugging or rare edge cases.

Examples:

```bash
# Preferred
rtk grep -n "int32\\(" ai-analytics/analysis_services/batching -- --glob "*test.go"

# Also acceptable when rtk adds no value
rg -n "int32\\(" ai-analytics/analysis_services/batching --glob "*test.go"

# Debug/edge-case fallback only
rtk proxy rg -n "complex-regex-or-feature" .
```

## Go Test Guidance (Codex Sessions)

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
