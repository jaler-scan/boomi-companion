#!/usr/bin/env bash
set -euo pipefail

# Boomi Companion is a static Claude Code plugin marketplace defined by
# .claude-plugin/marketplace.json. The Claude Code CLI is the tool that consumes
# and validates that manifest, so it is the core dependency of this environment.
PREFIX="$HOME/.npm-global"

npm install -g --prefix "$PREFIX" @anthropic-ai/claude-code

# Expose the CLI on PATH for future interactive shells. Guarded so repeated
# install runs do not duplicate the line.
PATH_LINE="export PATH=\"$PREFIX/bin:\$PATH\""
if ! grep -qxF "$PATH_LINE" "$HOME/.bashrc" 2>/dev/null; then
  echo "$PATH_LINE" >>"$HOME/.bashrc"
fi

export PATH="$PREFIX/bin:$PATH"
claude --version

# When Boomi credentials are injected as secrets (just-in-time / local runs),
# materialize the project .env for the boomi-integration skill. No-op otherwise.
bash "$(dirname "$0")/generate-env.sh" || true
