# Research guide

Phase 2 exists because stacks move faster than any bundled template. A Next.js or FastAPI project bootstrapped today deserves today's idioms, and your training data is by definition behind. Research is what makes the generated `rules/coding-style.md` (or `engineering.md`), `llm/PATTERNS.md`, and `llm/ARCHITECTURE.md` worth their context cost.

## What to research (budget: 4-8 searches, ~10 minutes)

Anchor every query to the **exact detected version** (e.g., "Next.js 16", "FastAPI 0.115"). Version-less best practices are how stale idioms sneak in.

1. **Official docs for the detected version**: recommended project structure, the current "right way" for routing/data/state (or DI/serialization for backend frameworks). Official docs outrank everything else.
2. **Release notes / upgrade guide** for the detected major version: what changed, what is deprecated. Prevents generating rules around removed APIs.
3. **Testing**: what the framework community currently uses (runner, component/e2e split) and the recommended setup for this version.
4. **Production/security checklist** for the stack: the framework's own deployment and security pages first.
5. **Known AI-codegen pitfalls for this stack** (one search): patterns models habitually get wrong (outdated APIs, deprecated config formats). These become explicit "do not" rules, which is exactly where written rules beat model priors.

Skip: SEO listicles ("Top 10 tips"), anything undated or older than the detected major version, and opinion pieces contradicting official docs.

## Distilling

Sort every finding into one of three buckets; discard what fits none:

- **Hard rule** (violation mechanically recognizable) → `rules/coding-style.md` / `engineering.md`. "Server components by default; `'use client'` only for interactivity" is a rule. "Prefer good architecture" is not.
- **Pattern** (how to do a recurring task, with a short code example) → `llm/PATTERNS.md`: add a route/endpoint, a DB access, a test, error handling, config.
- **Structure** (where things live, layer boundaries) → `llm/ARCHITECTURE.md`.

Keep only what plausibly changes behavior across many future tickets. Ten sharp rules beat forty vague ones; every KB here is charged to every future session.

## Provenance footer

End each research-derived doc with:

```
---
Researched: <YYYY-MM-DD> | Stack: <framework@version> | Sources: <2-5 domains/pages>
Stale if: major version bump, or older than ~3 months. Refresh: /bootstrap-llm --refresh
```

Future sessions use this to decide whether to trust the doc; `--refresh` uses it to find what to update.

## No web access

Generate from model knowledge, set the footer to `Researched: no (model knowledge, cutoff <your cutoff>)`, and flag it in the final report as the first recommended follow-up.
