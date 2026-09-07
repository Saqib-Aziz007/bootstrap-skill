# Example: good PR description

> **Title**: Fix duplicate export rows when invoices share a number
>
> ## Problem
> Exporting a date range produced duplicate CSV rows whenever two invoices shared a
> number across clients; the join in the export query matched on number alone.
>
> Closes #38
>
> ## Solution
> Join on `(client_id, number)` and add a uniqueness constraint via migration so the
> ambiguity cannot recur. Chose a constraint over dedup-at-read because duplicates
> were invalid data, not a display concern.
>
> ## How to verify
> 1. `/verify` (migration + regression test `export.spec.ts` included)
> 2. Seed two clients with invoice #1001 each, export the current month: one row per invoice.
>
> ## Checklist
> - [x] Scoped to one ticket
> - [x] Gates pass
> - [x] Docs updated (llm/PATTERNS.md: migration example now shows constraints)

Why it works: problem is one sentence and user-visible; approach explains the *why this way*; verification is mechanical; the checklist is honest.
