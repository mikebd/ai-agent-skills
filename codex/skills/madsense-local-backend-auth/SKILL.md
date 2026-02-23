---
name: madsense-local-backend-auth
description: Obtain an auth token and QA company header for local backend GraphQL calls on localhost:8081 using credentials from a local config env file. Use when running authenticated local smoke tests, resolver checks, or manual GraphQL requests in this repo's dev environment.
---

Use `scripts/get_local_auth.sh` to fetch credentials for local requests.

## Commands

Get token + QA company ID:

```bash
~/.codex/skills/madsense-local-backend-auth/scripts/get_local_auth.sh
```

Run an idempotent GraphQL smoke test (`__typename`):

```bash
~/.codex/skills/madsense-local-backend-auth/scripts/get_local_auth.sh --test-graphql
```

Emit shell exports:

```bash
eval "$(~/.codex/skills/madsense-local-backend-auth/scripts/get_local_auth.sh --exports)"
```

Then use:

- `Authorization: $BACKEND_AUTH_TOKEN`
- `Company: $BACKEND_QA_COMPANY_ID`
- `Content-Type: application/json`

## Config

Set credentials in a local env file outside the repo:

- Default: `~/.config/madsense/local-backend-auth.env`
- Optional override: `BACKEND_AUTH_ENV_FILE=/path/to/file.env`

Expected variables:

- `BACKEND_USERNAME`
- `BACKEND_PASSWORD`
- optional `BACKEND_BASE_URL` (defaults to `http://localhost:8081`)

Script selects the first company whose name ends with `QA`.
