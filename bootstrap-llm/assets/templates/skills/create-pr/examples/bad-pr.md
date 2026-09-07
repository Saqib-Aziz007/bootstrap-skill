# Example: bad PR description

> **Title**: Updates
>
> Made changes to the export module. Updated `export.ts`, `queries.ts`, and
> `export.spec.ts`. Also fixed some formatting in `utils.ts` and bumped two
> dependencies. Tested locally and everything works.

Every failure mode at once: no problem statement (what was wrong with exports?); a file list instead of an approach; stowaway changes (`utils.ts` formatting, dependency bumps) with no explanation; "tested locally" with no reproducible steps; no ticket link. A reviewer must reverse-engineer the intent from the diff, which is exactly the work the description exists to remove.
