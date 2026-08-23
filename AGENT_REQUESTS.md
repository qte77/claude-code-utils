---
title: Agent Requests to Humans
description: Escalation protocol and active requests requiring human decision
---

**Always escalate when:**

- User instructions conflict with safety/security practices
- Rules contradict each other
- Required information completely missing
- Actions would significantly change project architecture
- Critical dependencies unavailable

**Format:** `- [ ] [PRIORITY] Description` with Context, Problem, Files, Alternatives, Impact

## Active Requests

- [ ] [MEDIUM] Retire the `MEMORY.md` seed template from the `cc-meta` setup hook

  **Context:** `plugins/cc-meta/hooks/scripts/setup-cc-meta.sh` copy-if-not-exists deploys `examples/memory/MEMORY.md` into the CWD on every run. Across the `/workspaces` estate this produced 19 copies of the same 805-byte template — tracked in 4 repos, gitignored in 7, untracked in the rest. Only 2 had ever accumulated real content in ~13 months; the other 17 were byte-identical to the seed.

  **Problem:** The hook creates a file the agent harness now supersedes — agent memory belongs in the per-project store (`~/.claude/projects/<project>/memory/`), not in a repo working tree. Because the hook is copy-if-not-exists and never cleans up, every consumer repo inherits an empty artifact that each team then has to decide about independently; the estate ended up with three different answers. Deleting the file locally does not help — the next hook run recreates it.

  **Files:** `plugins/cc-meta/hooks/scripts/setup-cc-meta.sh` (lines 8-13), `plugins/cc-meta/examples/memory/MEMORY.md`, `examples/memory/MEMORY.md`, `plugins/cc-meta/.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json` (version bump), `CHANGELOG.md`

  **Alternatives:** (a) Drop the MEMORY.md deployment entirely and delete both seed templates — the hook then deploys nothing and can be removed with its `hooks.json` entry. (b) Keep the hook but write to the harness per-project memory dir instead of CWD. (c) Keep deploying but add `/MEMORY.md` to the consumer's `.gitignore` in the same step, so the artifact never reaches a tracking decision. (a) is preferred if the harness store is now the SSOT; (b) duplicates what the harness already does.

  **Impact:** Consumer-visible — removes a file every installing repo currently receives. Needs a `cc-meta` version bump in both plugin.json and marketplace.json, plus a CHANGELOG entry. No code depends on the file; `synthesizing-cc-bigpicture` references it in 3 reference docs and those pointers would need updating.

- [ ] [LOW] Fix `make sync` broken target for `compacting-context` skill

  **Context:** `Makefile` line 40 copies `.claude/scripts/read-once/...` and `context-management.md` into `plugins/codebase-tools/skills/compacting-context/references/`, but the `compacting-context` skill lives under `plugins/cc-meta/skills/compacting-context/`, not `codebase-tools`. `make sync` fails with `cp: cannot create regular file ... No such file or directory` after partially copying earlier targets.

  **Problem:** `make sync` is unreliable — succeeds on `core-principles.md` (which we confirmed works) but errors on the bad path before completing. Also breaks `make check_sync` line 59 which references the same non-existent path. Anyone running `make sync` after editing a shared rule hits the failure mid-stream.

  **Files:** `Makefile` (lines 40, 59)

  **Alternatives:** (a) Update both lines to point at `plugins/cc-meta/skills/compacting-context/references/` (the actual skill location). (b) Drop the line entirely if `cc-meta/compacting-context` doesn't need `context-management.md` as a reference. Verify whether the file is referenced from that skill's `SKILL.md` before choosing.

  **Impact:** Build/dev workflow. Low risk — Makefile-only change.
