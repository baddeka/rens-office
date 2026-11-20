#!/bin/sh
# Installs Rens Office on macOS or Linux and starts it. Paste into a terminal:
#
#   curl -fsSL https://raw.githubusercontent.com/baddeka/rens-office/HEAD/install.sh | sh
#
# It gets what's missing (uv, which brings its own Python, and Claude Code), puts the office in
# ~/rens-office, adds a "Rens Office" shortcut, asks you to sign in to your Claude account once,
# and opens the office. Run it again any time: it only updates what is there.
set -e

REPO="${RENS_OFFICE_REPO:-https://github.com/baddeka/rens-office}"
DIR="${RENS_OFFICE_DIR:-$HOME/rens-office}"
PATH="$HOME/.local/bin:$PATH"

step() { printf '\n\033[1m==> %s\033[0m\n' "$1"; }

if ! command -v git >/dev/null 2>&1; then
  if [ "$(uname)" = Darwin ]; then
    step "Git is needed. A window opens to install Apple's command line tools: click Install, then run this again."
    xcode-select --install || true
  else
    step "Git is needed. Install it (for example: sudo apt install git), then run this again."
  fi
  exit 1
fi

if ! command -v uv >/dev/null 2>&1; then
  step "Installing uv, which brings its own Python"
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

if ! command -v claude >/dev/null 2>&1; then
  step "Installing Claude Code"
  curl -fsSL https://claude.ai/install.sh | bash
fi

if [ -d "$DIR/.git" ]; then
  step "Updating Rens Office in $DIR"
  git -C "$DIR" pull --ff-only || echo "Could not update; keeping the version that is there."
elif [ -e "$DIR" ]; then
  step "$DIR already exists and is not Rens Office. Move it away, or set RENS_OFFICE_DIR, and run this again."
  exit 1
else
  step "Downloading Rens Office into $DIR"
  git clone --quiet "$REPO" "$DIR"
fi
chmod +x "$DIR/rens-office.sh" "$DIR/Rens Office.command"

step "Adding a Rens Office shortcut"
if [ "$(uname)" = Darwin ]; then
  mkdir -p "$HOME/Desktop"
  printf '#!/bin/sh\nexec "%s/rens-office.sh"\n' "$DIR" > "$HOME/Desktop/Rens Office.command"
  chmod +x "$HOME/Desktop/Rens Office.command"
  echo "On your desktop: Rens Office.command. Double-click it to start the office."
else
  apps="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  mkdir -p "$apps"
  cat > "$apps/rens-office.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Rens Office
Comment=Claude Code agents in a pixel-art office
Exec="$DIR/rens-office.sh"
Terminal=true
Categories=Development;
EOF
  echo "Rens Office is in your applications menu. You can also run: $DIR/rens-office.sh"
fi

step "Starting Rens Office"
# The launcher sets up Python, asks you to sign in to Claude if nobody is, and opens the office.
# It reads from the terminal, since this script itself came in through a pipe.
if (: < /dev/tty) 2>/dev/null; then
  exec "$DIR/rens-office.sh" < /dev/tty
fi
exec "$DIR/rens-office.sh"
