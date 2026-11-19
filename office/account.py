"""Whether Claude Code is installed and someone is signed in to it on this computer.

Each person uses the office with their own Claude account. Claude Code keeps that sign-in on their
computer; the office never reads or stores it, it only asks Claude Code whether someone is signed in.
"""

from __future__ import annotations

import json
import shutil
import subprocess

from reviewer import claude_code

STATUS_SECONDS = 30


def claude_status() -> dict:
    """{"installed": bool, "signed_in": True, False, or None when Claude Code could not tell}."""
    binary = shutil.which(claude_code.CLAUDE_BIN)
    if binary is None:
        return {"installed": False, "signed_in": None}
    try:
        done = subprocess.run(
            [binary, "auth", "status", "--json"],
            stdin=subprocess.DEVNULL,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=STATUS_SECONDS,
        )
        signed_in = json.loads(done.stdout).get("loggedIn")
    except (OSError, subprocess.SubprocessError, ValueError, AttributeError):
        signed_in = None  # an older Claude Code without `auth status`, or one that answered oddly
    return {"installed": True, "signed_in": signed_in if isinstance(signed_in, bool) else None}
