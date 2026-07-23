# Exam product decision: CCE vs permanent-residence A2

**Created:** 23 July 2026
**Decision owner needed:** Product + Czech exam specialist
**Blocks:** Phase 0C exam rebuild and all of Phase 3B (official exam simulation)
**Status:** DRAFT for decision — recommendation below, but the choice is the owner's

## Why this decision exists

The audit and implementation plan require **one** supported official exam product, versioned to a single blueprint, with no mixed timings/points/eligibility. Today the app mixes concepts: `assets/curriculum/exam_bank_a2.json` is tagged `"exam_type": "CCE"` while its own description says "matching the real CCE A2 format (permanent residence, new format since April 2026)." Those name two different exams. Until one is chosen and the content is made faithful to it, the app cannot honestly present an exam simulation.

## The two candidates are genuinely different exams

| | **CCE A2** (Certifikovaná zkouška z češtiny pro cizince) | **Permanent-residence A2** (Zkouška z češtiny pro trvalý pobyt) |
|---|---|---|
| Owner / administrator | ÚJOP, Charles University (and partner centres) | State exam via NPI / MŠMT network of authorised schools |
| Primary purpose | General certified proficiency; university admission; international recognition; **also** accepted as the language proof for permanent residence | Sole purpose: the language proof required for permanent residence |
| Levels offered | A1–C1 (full ladder) | A1 and A2 only |
| Current format valid from | **1 January 2026** | **11 April 2026** |
| Written parts & timing | Reading 40 min · Listening 25–30 min · Writing 40 min | Reading 40 min · Writing 25 min · Listening ~40 min |
| Speaking | 12–15 min, **individual, online video** | Oral part: answer questions, ask for information, short picture-based monologue, react to situations |
| Scoring | **Transformed to percentages** (not a raw point sum) | Raw points: Written **70** (Reading 25 / Listening 25 / Writing 20) + Oral **40** = **110** |
| Pass rule | **≥60% overall and in each part** | **≥60%** (min written 42/70, oral 24/40 in the app's current numbers) |
| Fee to candidate | 3 500 Kč (−500 Kč for ÚJOP students) | One free attempt for residence applicants (state-funded) |

Sources listed at the end. Exact per-item point maps, the CCE percentage-transformation, and the April-2026 writing/oral task inventory must be re-verified against the official model-test PDFs before any scoring rebuild — that is the first task of whichever option is chosen, and a specialist sign-off gate.

## Decisive finding: the app already implements the permanent-residence A2 exam

The numbers hard-coded in `exam_bank_a2.json` — `total_points: 110`, `written_points: 70`, `speaking_points: 40`, `reading 25`, `listening 25`, `writing 20`, `pass_threshold_written: 42`, `pass_threshold_speaking: 24` — are the **permanent-residence A2 (April 2026)** structure exactly (42 = 60% of 70; 24 = 60% of 40). They are **not** the CCE A2 structure (which uses different timings and a percentage transformation, not a raw 110-point sum). The content is the permanent-residence exam wearing a `"CCE"` label.

**Implication:** choosing permanent-residence A2 means the existing content is structurally close to correct and needs relabeling + primary-source verification. Choosing CCE means rebuilding the scoring model (percentage transformation), retiming sections, and simulating an individual online-video speaking test — materially more work, against content that is currently the wrong shape.

## Recommendation: supported product = **permanent-residence A2**, CCE deferred as a later premium track

Reasoning:

1. **Audience fit.** "Čeština Pro" serves foreigners living in Czechia; the permanent-residence A2 exam is the single highest-intent, mass-market goal for that audience. It is the reason most of them study at all.
2. **Lowest build risk / leverages existing work.** The app's A2 bank is already this exam's structure. The path is: relabel, verify against the official model test, fix discrepancies, get specialist sign-off — not a from-scratch rebuild.
3. **Faithfully simulatable.** Raw-point scoring (110, 60% thresholds) can be reproduced exactly. CCE's percentage-transformed scoring cannot be simulated faithfully without ÚJOP's transformation tables, and its individual online-video speaking test is hard to represent honestly in-app.
4. **Single level, single blueprint.** One level (A2), one pass rule, one published model test → satisfies the plan's "one versioned blueprint, no mixed timings/points/eligibility" gate cleanly. CCE would pressure us toward B1+ to be a meaningful product across its A1–C1 ladder.
5. **Honest positioning.** The state exam is free; the app is unambiguously *practice/preparation*, never a substitute for or reseller of a paid certificate — consistent with the plan's "practice, not an official result" rule.

Note the overlap: a CCE A2 certificate **also** satisfies the permanent-residence requirement, so choosing the permanent-residence exam does not strand CCE-bound learners for that specific purpose. CCE remains a sensible **later** premium track (A1–C1, certification-oriented) once the core product is validated.

## What follows once the decision is made (Phase 0C / 3B work)

If permanent-residence A2 is chosen (recommended):
1. Relabel `exam_bank_a2.json` and all UI copy from "CCE" to the permanent-residence exam; remove the conflated description.
2. Verify every subtest's timing, task inventory, and point map against the official April-2026 model test PDF (cited below); fix discrepancies. Treat the PDF as the versioned blueprint with its effective date recorded.
3. Reconcile the A1 bank the same way (permanent-residence A1 exists).
4. Keep speaking/writing scoring as *unscored practice with transparent criteria* until Phase 3A human validation — do not fabricate an official result.
5. Obtain a Czech exam-specialist review of the rebuilt simulation; record reviewer, checklist, and version/date.

If CCE is chosen instead:
- Expect a larger rebuild: percentage-transformation scoring, retimed sections, individual online-video speaking simulation, and a decision on how far up the A1–C1 ladder to build. The existing A2 content would be re-shaped, not reused.

## Open questions for the owner

- Confirm the target purpose: is the product's north star **permanent residence** (recommended) or **general certification / academic** (CCE)?
- Is a paid premium CCE track on the roadmap, or out of scope?
- Who is the Czech exam specialist for the Phase 3B sign-off, and can we obtain the official model-test PDFs as the blueprint of record?

## Sources

- [CCE — ÚJOP UK official exam page](https://ujop.cuni.cz/zkouska/certifikovana-zkouska-z-cestiny-pro-cizince-cce)
- [CCE-A2 model variant 2026 (official PDF)](https://arche.is.cuni.cz/images/zkousky/dokumenty/CCE-A2_MODELOV%C3%81_VARIANTA_2026.pdf)
- [Permanent-residence A2 model test, valid from 11 April 2026 (official PDF)](https://cestina-pro-cizince.cz/trvaly-pobyt/a2/wp-content/uploads/sites/3/2025/10/Modelovy-test-A2-novy-format-od-11.-dubna-2026.pdf)
- [Permanent-residence exam — information (cestina-pro-cizince.cz)](https://cestina-pro-cizince.cz/trvaly-pobyt/a2/en/)
- [Change to the A2 permanent-residence exam — Praha / Metropole všech](https://metropolevsech.eu/en/news/zmena-zkousky-z-cestiny-pro-trvaly-pobyt-a2/)

*All exam facts above are as published on the cited pages as of 23 July 2026. Exact per-item scoring and task inventories must be re-verified against the official model-test PDFs before the scoring rebuild; that verification plus a specialist sign-off is the Phase 3B gate.*
