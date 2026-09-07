# bootstrap-llm

A [Claude Code skill](https://docs.claude.com/en/docs/claude-code/skills) that turns a fresh repository into an AI-first development environment in one run.

Run `/bootstrap-llm` once at the start of a project. It interviews you about the domain, researches current best practices for your stack, and generates a complete per-project harness: LLM docs, always-loaded rules, quality-gate hooks, a PR template, and a project-local `/ticket` skill. From then on, any AI session in that repo can take a ticket ID and carry it all the way to a pull request with near-zero human involvement, and multiple tickets can run in parallel via git worktrees.

## Why

Ticket-driven AI development works only when the project carries its own context: what the product is, who the users are, how the code is structured, what "done" means, and how work lands. Setting that up by hand for every new project is tedious, so it gets skipped, and then every AI session starts from zero. This skill makes the setup a 10-minute guided step instead.

## What it generates

```
your-project/
├── CLAUDE.md                        # Project constitution (single source of truth)
├── AGENTS.md -> CLAUDE.md           # Symlink, so Codex/Cursor/Copilot read the same file
├── llm/                             # Domain docs seeded from your interview answers
│   ├── PRODUCT.md                   # What the product is, business concepts
│   ├── CONTEXT.md                   # Domain glossary, user types, constraints
│   ├── USER_FLOWS.md                # Major user stories and flows
│   ├── ARCHITECTURE.md              # System design (researched + detected)
│   └── PATTERNS.md                  # Stack best practices with code examples
├── .claude/
│   ├── rules/                       # Always-loaded cross-cutting rules
│   │   ├── workflow.md              # Ticket lifecycle: read → discover → plan → implement → verify → PR
│   │   ├── git-workflow.md          # Branching, commits, worktree parallelism
│   │   ├── coding-style.md          # Stack-specific hard rules (from live research)
│   │   ├── testing.md, security.md, pr-quality.md, review-judgment.md
│   │   └── llm-docs.md              # Keep docs current in the same change; context budget
│   ├── refs/                        # On-demand module reference docs (grow over time)
│   ├── skills/
│   │   ├── ticket/                  # /ticket <id>: full ticket-to-PR lifecycle
│   │   ├── create-pr/               # Intent-driven PR creation
│   │   ├── verify/                  # Quality gates: types, lint, tests, build
│   │   ├── review/                  # Pre-commit semantic review
│   │   └── plan/                    # Structured feature planning
│   ├── hooks/                       # Guardrail scripts wired into settings.json
│   └── settings.json
└── .github/pull_request_template.md
```

Ticketing integration is chosen per project: **Linear** (MCP), **GitHub Issues** (`gh` CLI), or **Jira** (Atlassian MCP/REST). The generated `/ticket` skill fetches the ticket, moves its status, branches (or creates a worktree), implements, verifies, updates the LLM docs if reality drifted, and opens a PR.

## Install

Clone and symlink into your Claude Code skills directory:

```bash
git clone https://github.com/Saqib-Aziz007/bootstrap-skill.git
ln -s "$(pwd)/bootstrap-skill/bootstrap-llm" ~/.claude/skills/bootstrap-llm
```

Then register the trigger in `~/.claude/CLAUDE.md` (optional but recommended):

```markdown
# bootstrap-llm
- **bootstrap-llm** (`~/.claude/skills/bootstrap-llm/SKILL.md`) - one-time project setup: interview → LLM docs + AI dev harness. Trigger: `/bootstrap-llm`
When the user types `/bootstrap-llm`, invoke the Skill tool with `skill: "bootstrap-llm"` before doing anything else.
```

## Usage

In the root of a new (or existing) project:

```
/bootstrap-llm
```

The skill detects everything it can (stack, package manager, git remote, existing scripts and docs) and only asks what it cannot detect: the product domain, user types, major user stories, ticketing system, and how heavy a harness you want (lean for small projects, full for serious ones).

You can also pre-supply answers to skip the interview entirely:

```
/bootstrap-llm domain: invoice OCR for freelancers; users: freelancer, accountant;
stories: upload invoice, auto-extract fields, export to CSV; ticketing: linear (project INV);
depth: lean
```

After it finishes, start your first ticket:

```
/ticket INV-1
```

## Design notes

- **Detect first, ask second.** The interview never asks anything derivable from the repo.
- **Live research, not stale templates.** Stack best practices are researched at bootstrap time and stamped with date + sources, so a Next.js project bootstrapped today gets today's idioms.
- **Single source of truth.** `AGENTS.md` is a symlink to `CLAUDE.md`; rules link to refs; nothing is duplicated.
- **Context budget.** Always-loaded docs are kept under a size cap, enforced by a hook, so sessions stay lean as the project grows.
- **Parallelism by construction.** The git workflow documents worktrees as the standard way to run N tickets in N parallel AI sessions.

## License

[MIT](LICENSE)
