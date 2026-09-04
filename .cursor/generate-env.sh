#!/usr/bin/env bash
set -euo pipefail

# Generate a project .env for the boomi-integration skill from Cloud Agent
# secrets that are injected as environment variables.
#
# This is intentionally per-boot work: secrets are injected into each new VM at
# start time, so environment.json runs this from "start" (and install.sh calls it
# too, which covers just-in-time / local runs). It is safe to run repeatedly.
#
# Behavior:
#   - Only acts when all REQUIRED Boomi credentials are present, so it never
#     clobbers a hand-edited .env with blanks and is a no-op during builds where
#     secrets are absent.
#   - Writes only the keys whose values are actually set.
#   - Never prints secret values.

TARGET="${1:-$PWD/.env}"

REQUIRED=(BOOMI_API_URL BOOMI_USERNAME BOOMI_API_TOKEN BOOMI_ACCOUNT_ID)
for v in "${REQUIRED[@]}"; do
  if [ -z "${!v:-}" ]; then
    echo "generate-env: required Boomi credentials not in environment; leaving $TARGET untouched."
    exit 0
  fi
done

KEYS=(
  BOOMI_API_URL BOOMI_USERNAME BOOMI_API_TOKEN BOOMI_ACCOUNT_ID BOOMI_VERIFY_SSL
  BOOMI_TARGET_FOLDER BOOMI_ENVIRONMENT_ID BOOMI_TEST_ATOM_ID
  SERVER_AUTH_TYPE SERVER_BASE_URL SERVER_USERNAME SERVER_TOKEN SERVER_BEARER_TOKEN SERVER_VERIFY_SSL
)

tmp="$(mktemp)"
{
  echo "# Auto-generated from Cloud Agent secrets. Do not commit (gitignored)."
  for v in "${KEYS[@]}"; do
    [ -n "${!v:-}" ] && printf '%s=%s\n' "$v" "${!v}"
  done
} >"$tmp"

mv "$tmp" "$TARGET"
chmod 600 "$TARGET"
echo "generate-env: wrote $TARGET ($(grep -c '=' "$TARGET") variables; values hidden)."
