# PR description format

The reviewer's reading order is: problem → approach → how to verify. Serve that order.

**Problem** (1 sentence, 2 at most): what was broken, missing, or wrong, from the user's or system's point of view. If stating it takes a paragraph, the PR is probably too big.

**Approach** (2-4 sentences): the shape of the solution and *why this way* when alternatives were plausible. Never a file list; the diff already shows files. Mention anything surprising in the diff here so the reviewer is not left guessing.

**How to verify** (concrete steps): commands to run, screens to open, states to check. "Run `/verify`" plus the feature-specific check. A reviewer should be able to follow this section mechanically.

**Checklist**: tick honestly; an unticked box with a reason beats a falsely ticked one.

Anti-patterns: narrating the diff file by file; "various fixes"; verification sections that say "tested locally" with no steps; unexplained drive-by changes.
