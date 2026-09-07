# Interview guide

The interview is the only source for what the repo cannot tell you: the domain, the users, and the process the human wants. Everything else comes from detection. A good interview feels like onboarding a sharp new teammate: a few pointed questions, smart defaults for the rest.

## Mechanics

- **Closed choices** (ticketing system, depth, conventions): use AskUserQuestion, up to 4 questions per call, `multiSelect` where options are not mutually exclusive. Put the recommended option first with "(Recommended)".
- **Open narrative** (pitch, stories, glossary): ask as one compact chat message with numbered questions the user answers in a single reply. Option lists are useless for free-form domain knowledge.
- **Two rounds maximum.** Round 1: domain narrative + closed process questions (can go out in the same turn). Round 2: only follow-ups where an answer was too thin to generate from. Beyond that, proceed with what you have and list gaps in the report.
- Skip any question answered by detection, pre-supplied input, or earlier conversation. Repeating a known question is the fastest way to make the user abandon the interview.

## Question bank

### Domain (feeds llm/ docs almost verbatim)

| Ask | Feeds | Why it matters |
|---|---|---|
| Elevator pitch: what is this product and for whom? What makes it different? | `llm/PRODUCT.md` | The one paragraph every future session reads first. |
| User types / roles, and what each cares about | `llm/CONTEXT.md` | Tickets say "the user"; the docs must say which one. |
| The 3-7 major user stories (plain sentences are fine) | `llm/USER_FLOWS.md` | These become the skeleton future tickets hang from. |
| Domain terms a newcomer would misread (glossary) | `llm/CONTEXT.md` | AI sessions guess wrong on ambiguous domain words; a glossary kills whole classes of bugs. |
| Hard constraints: compliance (HIPAA/GDPR/PCI), required integrations, platforms, offline, multi-tenant | `llm/CONTEXT.md`, `llm/ARCHITECTURE.md`, `rules/security.md` | Constraints silently invalidate otherwise-good implementations. |

Follow-up rule: if the pitch answer would not let a stranger explain the product in one sentence, ask the single follow-up that fixes that ("who pays for it?" or "what's the core action a user takes?"). One follow-up, not an interrogation.

### Process (feeds workflow wiring)

| Ask | Default (offer as Recommended) |
|---|---|
| Ticketing system + project key or repo | Detected from session (Linear/Atlassian MCP present, `gh` authed). No detection: GitHub Issues if repo is on GitHub. |
| Status names for "started" and "ready for review" | Linear: In Progress / In Review. Jira: ask (workflows vary wildly). GitHub: labels `in-progress` / `in-review`. |
| Branch naming | `<type>/<ticket-ref>-<short-kebab-slug>`, types: `feature` `fix` `chore` `docs` `refactor` |
| Commit style | Imperative subject ≤72 chars, why-not-what body, ticket trailer (`Refs ABC-123` / `Closes #12`) |
| Review setup | Detected `.coderabbit.yaml` → CodeRabbit. Solo dev → self-review via `/review` + `/verify` gates before PR. |
| PR target | Detected default branch |

### Calibration

**Harness depth.** Ask explicitly; do not guess silently.

| | Lean | Full |
|---|---|---|
| Fits | Solo, < ~3 months, one deliverable | Team, long-lived, or compliance-heavy |
| Rules | `workflow`, `git-workflow`, `engineering` (style+testing+security merged), `llm-docs` | The complete blueprint set, separate files |
| Skills | `ticket`, `verify`, `create-pr` | + `review`, `plan` |
| llm/ docs | All five, but concise (PRODUCT+CONTEXT may merge) | All five, fuller |
| Budget | ≤ 20 KB always-loaded | ≤ 45 KB always-loaded |

Recommend lean for the classic case (solo project, couple of months). Upgrading later is easy: re-run `/bootstrap-llm` and pick full.

## Non-interactive defaults

When no user is available and an answer is missing: GitHub Issues (if GitHub remote) else leave ticketing as a TODO in the report; house branch/commit defaults; depth lean; review = self-review gates. Every applied default goes in the report's Assumptions section, phrased so the user can correct it in one line.
