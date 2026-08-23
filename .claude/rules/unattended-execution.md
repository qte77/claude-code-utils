# Unattended E2E Execution (arc template)

**Goal: long-running, e2e hands-off unattended sessions with minimal
supervision and intervention.** These constraints generalize across projects
and repos; apply each section per the use case (e.g. the UI-e2e section
applies when the project ships a UI).

## Eligibility (what may run unattended at all)

Offload a task only if ALL hold:

- Single named target stated in the brief
- A failing check exists that will pass when the task is done
- Success is machine-readable — an exit code or a named artifact
- Write surface is disjoint from every task running alongside it
- No credential or consent provisioning (see the arc-start access checklist)
- No merge required

If any fails, the item is owner-gated — batch it into Phase B rather than
attempting it unattended. Bounding is the cheapest lever available: the same
bug took ≤2 min as a bounded brief and 15.7 h unbounded.

**Never offload:** merges (rulesets carry zero bypass actors; `--admin` does
not bypass them) · credential/consent provisioning · UI/e2e *judgement*
(output from a run with a failed step is unusable) · browser-tier
verification (subagents cannot invoke it, so it never parallelises) · scope
and ROI triage.

## Plan + handoff artifacts (per arc `NNNN`)

- Save the plan to `docs/plans/NNNN-slug.md` and a **concise, actionable
  handoff** to `docs/handoffs/NNNN-slug.md` (same 4-digit `NNNN` pair, kebab
  slug).
- **The plan MUST contain a code/file/source map** (exact files, functions,
  line refs, external refs, reference blueprints) so the next session does
  **not** have to map or gather context again.
- **The handoff MUST onboard the next session to the plan and how to handle
  it**: what shipped, what's next (in order), the loop, owner-gates,
  commands, watch-outs.
- Keep plan + handoff + memory in sync at every milestone. Close an arc by
  marking shipped items and migrating the entire remainder to the next
  `NNNN` — never leave work stranded in a closed arc.

## Non-blocked phase shape (structure every arc this way)

- **Phase A — agent-only:** front-load EVERY agent-runnable slice; never
  interleave owner-gated items mid-sequence.
- **Pre-stage every gate during Phase A:** migration SQL (PR'd, unapplied),
  remediation scripts, dry-run reports — so gates become approvals, not work
  sessions.
- **Phase B — ONE owner sitting:** batch all gates (migrations, DB
  mutations, spend) into a single pre-staged checkpoint.
- **Phase C — activation:** agent resumes (verify, activate gated features,
  e2e, deploy).
- **Decide-by-default:** every open decision in the plan carries a
  recommended default; proceed with the default unattended; the owner
  overrides at the checkpoint.
- **Done-when per item:** each backlog item states its verification so the
  agent self-verifies and moves on.
- **Build-behind-gate:** ship data-dependent features dormant behind their
  gate; they activate when the data lands — code never waits on data.
- **Arc-start access checklist:** list the credentials/grants the arc needs
  in the plan; the owner provisions once up front (no mid-run credential
  stalls).
- **Bounded write budgets:** pre-approve capped, backup-first data writes
  (dry-run shown) instead of gating every small write.

## Bounds (declare before starting; stop when any is reached)

- Wall-clock ceiling
- Cost ceiling
- Iteration ceiling
- No-progress — the KPI unchanged for N consecutive iterations

## Escalation

- On ambiguity, open an issue labelled `human-required` and pause. Never
  guess and continue.
- Record the question, what was already tried, and what would unblock it.
- Resume only on explicit human resolution.

## Per-milestone discipline (after every major milestone / merged PR)

- **Git:** new branch per topic; commits by topic
  (`feat`/`fix`/`test`/`docs`/`chore`); push + squash-merge ONLY if all CI +
  test items pass; delete stale remote AND local branches.
- **Docs & issues audit:** CHANGELOG · root README · architecture/ADRs ·
  roadmap · userstory · registries — updates needed? New **URLs / env vars /
  CLI switches** documented (README tables + CHANGELOG)? Issues to
  **open/update/close** (close shipped features; advance — never
  auto-close — multi-item trackers)?
- **Progress report (concise):** what **shipped** · what's **next** ·
  **overall % of the plan** · **blocked/deferred** (+ what's pre-staged for
  each).

## Quality gates (always)

- **Strict TDD: first model the expected and desired behavior** (RED first).
  Only non-trivial tests, only where necessary — for modules, never for
  simple scripts/config; rendering/wiring = e2e is the test.
- Run the EXACT CI gate locally before pushing (the repo's make/npm validate
  target incl. format checks) — never à la carte. Run the audit
  (dependency/security) target too.
- Assume strict lint + typing + security always.

## Signal integrity (an unearned green is the costliest failure)

- **A check that did not run is FAIL, not PASS.** Never infer success from
  the absence of a failure — this is what "ONLY if all CI + test items pass"
  above means.
- Assert the expected magnitude before accepting a result — a green suite
  that ran zero tests, or a validate target that skipped untracked files, is
  a failure.
- Report **"could not check"** and **"checked and clean"** as distinct
  outcomes; a repo with no CI configured is the former only until its
  documented gate has actually been run.
- Never push agent commits with the default `GITHUB_TOKEN` — GitHub
  suppresses workflow triggers on them, so CI silently never runs and "no
  failing check" reads as success.
- **"Completed" is not "delivered."** Verify the artifact exists and is
  well-formed; a run can exit 0 having produced nothing.

## UI e2e verification (when the project ships a UI)

- Use **polyfetch + its patchright chromium** for e2e UI tests, **locally
  AND against the remote deploy**.
- Vary the **viewport + device emulation**; **click buttons, dropdowns, and
  other interactive elements** to verify functionality *and* appearance —
  not just render presence.
- Take **screenshots and (opt-in) videos in horizontal and vertical
  orientation**.
- Use the patchright/chromium **devtools**: capture **console errors** (fail
  the run on app console errors) and failed network requests.

## Context economy (see context-management.md)

- Delegate discovery/search/audits/long-running ops to **subagents**; the
  main thread keeps conclusions, not dumps.
- **Compact at phase/milestone boundaries**; durable facts belong in
  plan/handoff/memory, not only in-conversation.
- Redirect verbose command output to files; read back only the relevant
  slice.
- **Fan out only over disjoint conclusions.** Parallel agents whose outputs
  feed one decision produce silent integration conflicts; after fan-in,
  re-run each conclusion against every later finding before publishing.

## Agent identity

Set agent identity through `GIT_AUTHOR_NAME` / `GIT_AUTHOR_EMAIL` and
`GIT_COMMITTER_NAME` / `GIT_COMMITTER_EMAIL`. **Never `git config`** —
worktrees and parallel agents share one `.git/config`, and concurrent writes
race: measured 0/5 correct attributions via `git config`, 5/5 via
environment variables.
