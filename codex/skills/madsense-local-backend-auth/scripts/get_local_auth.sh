#!/usr/bin/env bash
set -euo pipefail

MODE="print"
if [[ "${1:-}" == "--exports" ]]; then
  MODE="exports"
elif [[ "${1:-}" == "--test-graphql" ]]; then
  MODE="test"
elif [[ "${1:-}" != "" ]]; then
  echo "usage: $0 [--exports|--test-graphql]" >&2
  exit 1
fi

ENV_FILE="${BACKEND_AUTH_ENV_FILE:-$HOME/.config/madsense/local-backend-auth.env}"
if [[ -f "${ENV_FILE}" ]]; then
  set -a
  source "${ENV_FILE}"
  set +a
fi

BASE_URL="${BACKEND_BASE_URL:-http://localhost:8081}"
USERNAME="${BACKEND_USERNAME:-}"
PASSWORD="${BACKEND_PASSWORD:-}"

if [[ -z "${USERNAME}" || -z "${PASSWORD}" ]]; then
  echo "error: missing BACKEND_USERNAME/BACKEND_PASSWORD; set env vars or create ${ENV_FILE}" >&2
  exit 1
fi

login_resp="$(curl -sS -m 10 \
  -H 'Content-Type: application/json' \
  -d "{\"username\":\"${USERNAME}\",\"password\":\"${PASSWORD}\"}" \
  "${BASE_URL}/auth/login")"

auth_token="$(printf '%s' "${login_resp}" | jq -r '.accessToken // empty')"
qa_company_id="$(printf '%s' "${login_resp}" | jq -r '.companies[]? | select((.name // "") | endswith("QA")) | .id' | head -n1)"

if [[ -z "${auth_token}" ]]; then
  echo "error: accessToken missing in login response" >&2
  exit 1
fi
if [[ -z "${qa_company_id}" ]]; then
  echo "error: no QA company id found in login response" >&2
  exit 1
fi

if [[ "${MODE}" == "exports" ]]; then
  printf 'export BACKEND_BASE_URL=%q\n' "${BASE_URL}"
  printf 'export BACKEND_AUTH_TOKEN=%q\n' "${auth_token}"
  printf 'export BACKEND_QA_COMPANY_ID=%q\n' "${qa_company_id}"
  exit 0
fi

if [[ "${MODE}" == "test" ]]; then
  curl -sS -m 10 -i \
    -H 'Content-Type: application/json' \
    -H "Authorization: ${auth_token}" \
    -H "Company: ${qa_company_id}" \
    -d '{"query":"query { __typename }"}' \
    "${BASE_URL}/graphql"
  exit 0
fi

echo "BASE_URL=${BASE_URL}"
echo "AUTH_TOKEN=${auth_token}"
echo "QA_COMPANY_ID=${qa_company_id}"
