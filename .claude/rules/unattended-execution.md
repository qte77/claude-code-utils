# Unattended Execution

Always-loaded constraints for **long-running, e2e hands-off unattended sessions** with minimal
supervision. Constraints only; the contract, rationale, and mechanism spec live in
[`docs/unattended-execution.md`](https://github.com/qte77/qte77/blob/main/docs/unattended-execution.md). Pairs with
[`context-management.md`](context-management.md) (compaction) and
[`compound-learning.md`](compound-learning.md) (learnings promotion).

## Plan + handoff (per arc `NNN`)

- Every arc is a paired `docs/plans/NNN-slug.md` + `docs/handoffs/NNN-slug.md` (same number, kebab
  slug; match the repo's existing digit width). Findings reuse the number with a `-findings` suffix.
- The **plan MUST carry a `file:line` source map** ("touch without re-mapping") so the next session
  does not re-explore. The **handoff onboards** the next session: state, ordered next steps, the loop,
  owner-gates, commands, gotchas. Read the handoff first, the plan second.
- Keep plan + handoff + `MEMORY.md` in sync at every milestone. **Close an arc by migrating the entire
  remainder to the next `NNN`** — never strand work in a closed arc.
- **Plans, handoffs, findings, memory, and session summaries are EPHEMERAL working state, not permanent
  docs.** Evaluate them on a regular cadence; **mine** the durable learnings out (into code, ADRs,
  `AGENT_LEARNINGS.md`, rules) and then **prune** the artifact. The durable SOT is git history + code +
  ADRs + learnings + rules — not the arc scaffolding. Compression is the anti-graveyard gate.

## Non-blocked phase shape (structure every arc this way)

- **Phase A (agent-only):** front-load EVERY agent-runnable slice; never interleave owner-gated items
  mid-sequence. **Pre-stage every gate during Phase A** (migration SQL PR'd-but-unapplied, remediation
  scripts, dry-run reports) so a gate becomes an approval, not a work session.
- **Phase B (ONE owner sitting):** batch all gates — migrations, DB mutations, secrets, spend, merge —
  into a single pre-staged checkpoint.
- **Phase C (activation):** agent resumes — verify, activate gated features, e2e, deploy, report.
- **Decide-by-default:** every open decision carries a recommended default; proceed unattended; the
  owner overrides at the checkpoint. In hands-off mode this **overrides** core-principles' "when in
  doubt, STOP, ask the user" — proceed under the safe default and **park** the decision for the owner
  rather than blocking. Escalate mid-run ONLY when a decision has **no safe default** or the action is
  **irreversible/destructive** (delete, DB mutation, spend, deploy, force-push). **Done-when per item:**
  each item states its own verification. **Build-behind-gate:** ship data-dependent features dormant;
  they activate when the data lands.

## Quality gates (always)

- Run the **exact CI gate locally, whole, before pushing** (the repo's `make check` / `npm run
  validate` — format + lint + type + test + build). Never à la carte. Run the **audit/security target**
  too (`npm audit` / dependency + secret scan).
- **Strict TDD, RED first** — model the desired behavior and observe the red before implementing.
  Modules only; rendering/wiring/glue/config are covered by build + lint + e2e, never unit tests. Only
  value-add tests; never chase coverage.
- Assume **strict lint + typing + security always**, on every file, whether or not it has unit tests.

## Verification (verdict-is-the-status)

- Verify on the **live target**, not mocks or localhost assumptions — run e2e against **local AND the
  remote deploy**. `curl` can lie where the browser fails (per-encoding cache variants).
- UI e2e uses **patchright/Chromium**: vary viewport + device, rotate portrait AND landscape, click
  every control, capture **screenshots (and read 2-3 of them)** + opt-in video. **App console errors
  fail the run**; capture failed network requests.
- **Never trust a verification started before the edge settles** after a deploy (add a settle wait +
  asset-hash/MIME poll). Commit a **run manifest** (append PASS/FAIL honestly, keep FAILs). Prefer a
  **scheduled remote monitor** that auto-opens/updates an alert issue on FAIL.

## Durability + the unattended tax (hard rules)

- **git is the only durable SOT** — a session/container death loses anything uncommitted. For long runs
  use **resume-from-run-id** (replays cached agent calls, re-runs only the tail); commit-as-you-go.
- Prefix EVERY `git`/`gh` with `env -u GH_TOKEN -u GITHUB_TOKEN` (both vars shadow the real credential
  -> 403 on writes). Commit with `--no-gpg-sign` and `-F <file>` (never `-m` — backticks/`$()` in `-m`
  get shell-substituted). For rebase, disable signing (`-c commit.gpgsign=false`).
- **Merge is an owner gate.** Open the PR, drive the gate to green, then **park for owner approval** —
  never agent auto-merge. `--admin` bypasses ONLY the signature gate, never a failing/absent check;
  **never relax branch protection**. Clear a stuck required check by updating the branch to `main`, not
  by nudge-commits.
- **Scraper / untrusted-input repos: keep the Bash allowlist narrow** — broad read-only Bash widens
  prompt-injection blast radius and can read secrets. Prefer `Read`/`Grep`/`Glob` (never gated) +
  `uv run python` one-liners over `cat`/`grep`.
- **Compact at phase/milestone boundaries.** The model cannot self-trigger `/compact`; set
  `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`, a `PreCompact` archive hook (flush the live arc state before the
  summary lands), and a `SessionStart:compact` re-onboard hook (see the settings template). **Subagent
  discovery** to keep dumps out of the window — the biggest lever. Durable facts belong in
  plan/handoff/memory, not only in-conversation.
