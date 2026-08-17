# Unattended E2E Execution (arc template)

**Goal: long-running, e2e hands-off unattended sessions with minimal supervision and
intervention.** These constraints generalize across projects and repos; apply each section per the
use case (e.g. the UI-e2e section applies when the project ships a UI).

## Plan + handoff artifacts (per arc `NNNN`)

- Save the plan to `docs/plans/NNNN-slug.md` and a **concise, actionable handoff** to
  `docs/handoffs/NNNN-slug.md` (same 4-digit `NNNN` pair, kebab slug).
- **The plan MUST contain a code/file/source map** (exact files, functions, line refs, external
  refs, reference blueprints) so the next session does **not** have to map or gather context again.
- **The handoff MUST onboard the next session to the plan and how to handle it**: what shipped,
  what's next (in order), the loop, owner-gates, commands, watch-outs.
- Keep plan + handoff + memory in sync at every milestone. Close an arc by marking shipped items
  and migrating the entire remainder to the next `NNNN` — never leave work stranded in a closed arc.

## Non-blocked phase shape (structure every arc this way)

- **Phase A — agent-only:** front-load EVERY agent-runnable slice; never interleave owner-gated
  items mid-sequence.
- **Pre-stage every gate during Phase A:** migration SQL (PR'd, unapplied), remediation scripts,
  dry-run reports — so gates become approvals, not work sessions.
- **Phase B — ONE owner sitting:** batch all gates (migrations, DB mutations, spend) into a single
  pre-staged checkpoint.
- **Phase C — activation:** agent resumes (verify, activate gated features, e2e, deploy).
- **Decide-by-default:** every open decision in the plan carries a recommended default; proceed
  with the default unattended; the owner overrides at the checkpoint.
- **Done-when per item:** each backlog item states its verification so the agent self-verifies and
  moves on.
- **Build-behind-gate:** ship data-dependent features dormant behind their gate; they activate when
  the data lands — code never waits on data.
- **Arc-start access checklist:** list the credentials/grants the arc needs in the plan; the owner
  provisions once up front (no mid-run credential stalls).
- **Bounded write budgets:** pre-approve capped, backup-first data writes (dry-run shown) instead
  of gating every small write.

## Per-milestone discipline (after every major milestone / merged PR)

- **Git:** new branch per topic; commits by topic (`feat`/`fix`/`test`/`docs`/`chore`); push +
  squash-merge ONLY if all CI + test items pass; delete stale remote AND local branches.
- **Docs & issues audit:** CHANGELOG · root README · architecture/ADRs · roadmap · userstory ·
  registries — updates needed? New **URLs / env vars / CLI switches** documented (README tables +
  CHANGELOG)? Issues to **open/update/close** (close shipped features; advance — never auto-close —
  multi-item trackers)?
- **Progress report (concise):** what **shipped** · what's **next** · **overall % of the plan** ·
  **blocked/deferred** (+ what's pre-staged for each).

## Quality gates (always)

- **Strict TDD: first model the expected and desired behavior** (RED first). Only non-trivial
  tests, only where necessary — for modules, never for simple scripts/config;
  rendering/wiring = e2e is the test.
- Run the EXACT CI gate locally before pushing (the repo's make/npm validate target incl. format
  checks) — never à la carte. Run the audit (dependency/security) target too.
- Assume strict lint + typing + security always.

## UI e2e verification (when the project ships a UI)

- Use **polyfetch + its patchright chromium** for e2e UI tests, **locally AND against the remote
  deploy**.
- Vary the **viewport + device emulation**; **click buttons, dropdowns, and other interactive
  elements** to verify functionality *and* appearance — not just render presence.
- Take **screenshots and (opt-in) videos in horizontal and vertical orientation**.
- Use the patchright/chromium **devtools**: capture **console errors** (fail the run on app console
  errors) and failed network requests.

## Context economy (see context-management.md)

- Delegate discovery/search/audits/long-running ops to **subagents**; the main thread keeps
  conclusions, not dumps.
- **Compact at phase/milestone boundaries**; durable facts belong in plan/handoff/memory, not only
  in-conversation.
- Redirect verbose command output to files; read back only the relevant slice.
