#!/bin/sh
# Rens Office on macOS and Linux: starts the newest version. Run ./rens-office.sh, or double-click
# "Rens Office.command" on a Mac. Extra options go to the office, e.g. --port 8080.
cd "$(dirname "$0")" || exit 1
PATH="$HOME/.local/bin:$PATH"  # where uv and Claude Code install themselves

if command -v git >/dev/null 2>&1; then
  echo "Getting the newest version..."
  git pull --ff-only || echo "Could not update (no internet, or local changes). Starting the version that is here."
else
  echo "Git was not found, so the office starts as it is, without updating."
fi

# uv brings its own Python, so nothing else needs installing; without it, the system's Python 3.11+ does.
if command -v uv >/dev/null 2>&1; then
  if [ ! -x .venv/bin/python ]; then
    echo "First start: setting up, this takes a minute..."
    uv venv --quiet --python 3.12 .venv || { echo "Could not set up Python with uv."; exit 1; }
  fi
  uv pip install --quiet --python .venv/bin/python -e . || { echo "Could not install the office."; exit 1; }
else
  if [ ! -x .venv/bin/python ]; then
    PY=python3
    command -v python3 >/dev/null 2>&1 || PY=python
    echo "First start: setting up, this takes a minute..."
    "$PY" -m venv .venv || { echo "Could not set up. Install Python 3.11 or newer, or run install.sh."; exit 1; }
  fi
  .venv/bin/python -m pip install --quiet --disable-pip-version-check -e . \
    || { echo "Could not install. Check that Python is 3.11 or newer: .venv/bin/python --version"; exit 1; }
fi

# The agents work through Claude Code, signed in with this person's own Claude account.
if ! command -v claude >/dev/null 2>&1; then
  echo "Claude Code was not found. Install it from https://code.claude.com (or run install.sh), then start again."
elif claude auth status --json 2>/dev/null | grep -q '"loggedIn": *false'; then
  echo "Sign in to Claude with your own account. A browser window opens for it."
  claude auth login || echo "Not signed in yet. The office starts anyway; run: claude auth login"
fi

echo "Starting the office. Press Ctrl+C to stop it."
exec .venv/bin/python -m office.server --open "$@"
