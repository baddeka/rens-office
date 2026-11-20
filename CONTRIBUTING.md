# Contributing

Thanks for taking a look. Issues and pull requests are welcome, small ones especially.

## Setting up

```bash
git clone https://github.com/baddeka/rens-office
cd rens-office
python -m venv .venv
.venv/bin/pip install -e ".[dev]"     # on Windows: .venv\Scripts\pip install -e ".[dev]"
python -m pytest -q
```

The tests use a stand-in for the `claude` command (`tests/fake_claude.py`), so they run offline and
cost nothing. Tests that look at pages in a browser run when Chrome, Edge or Chromium is installed
and are skipped otherwise.

## Where things are

- `office/agents.py` is the office itself: the agents, their prompts, the review loop and the project's memory.
- `office/server.py` serves the page; `office/static/` is the page and the pixel office.
- `office/skills/` holds each agent's skills, as Claude Code plugins.
- `reviewer/` is the review engine, also usable alone as `ai-review`.

## A few habits

- Keep the page dependency-free: plain HTML, CSS and JavaScript.
- Every text the page or an agent shows exists in English and Russian (`office/i18n.py`, `office/static/app.js`).
- A change in behaviour comes with a test.
