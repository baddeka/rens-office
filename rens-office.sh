#!/bin/sh
# Rens Office on macOS and Linux: starts the newest version. Run ./rens-office.sh,
# or double-click "Rens Office.command" on a Mac. Extra options go to the office, e.g. --port 8080.
cd "$(dirname "$0")" || exit 1

if command -v git >/dev/null 2>&1; then
  echo "Getting the newest version..."
  git pull --ff-only || echo "Could not update (no internet, or local changes). Starting the version that is here."
else
  echo "Git was not found, so the office starts as it is, without updating."
fi

if [ ! -x .venv/bin/python ]; then
  PY=python3
  command -v python3 >/dev/null 2>&1 || PY=python
  echo "First start: setting up, this takes a minute..."
  "$PY" -m venv .venv || { echo "Could not set up. Install Python 3.11 or newer and try again."; exit 1; }
fi
.venv/bin/python -m pip install --quiet --disable-pip-version-check -e . \
  || { echo "Could not install. Check that Python is 3.11 or newer: .venv/bin/python --version"; exit 1; }

command -v claude >/dev/null 2>&1 || echo "Claude Code was not found. Install it from https://code.claude.com and sign in with: claude"

echo "Starting the office. Press Ctrl+C to stop it."
exec .venv/bin/python -m office.server --open "$@"
