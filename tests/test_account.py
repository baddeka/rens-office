"""The office says when Claude Code is missing or nobody is signed in, and never reads the sign-in."""

import json

from office import account
from reviewer import claude_code

from .test_office import fake_claude, request, server  # noqa: F401 (fixtures)


def test_a_signed_in_claude_code(fake_claude):  # noqa: F811
    assert account.claude_status() == {"installed": True, "signed_in": True}
    assert fake_claude() == []  # asking costs no agent run


def test_nobody_signed_in(fake_claude, monkeypatch):  # noqa: F811
    monkeypatch.setenv("FAKE_CLAUDE_AUTH", json.dumps({"loggedIn": False}))
    assert account.claude_status() == {"installed": True, "signed_in": False}


def test_claude_code_that_cannot_tell(fake_claude, monkeypatch):  # noqa: F811
    for answer in ("error: unknown command 'auth'", "[]", '{"loggedIn": "yes"}'):
        monkeypatch.setenv("FAKE_CLAUDE_AUTH", answer)
        assert account.claude_status() == {"installed": True, "signed_in": None}


def test_no_claude_code(monkeypatch):
    monkeypatch.setattr(claude_code, "CLAUDE_BIN", "definitely-not-installed-claude")
    assert account.claude_status() == {"installed": False, "signed_in": None}


def test_the_page_can_ask(server, fake_claude, monkeypatch):  # noqa: F811
    base, _ = server
    monkeypatch.setenv("FAKE_CLAUDE_AUTH", json.dumps({"loggedIn": False, "email": "someone@example.com"}))

    status, body = request(base + "/api/claude")

    assert status == 200 and json.loads(body) == {"installed": True, "signed_in": False}  # no account details
