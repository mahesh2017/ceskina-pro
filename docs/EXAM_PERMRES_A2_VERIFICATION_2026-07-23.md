# Permanent-residence A2 bank — structural verification vs official model test

**Created:** 23 July 2026
**Scope:** structural/factual check only (timings, task counts, point maps, formats). **Not** a linguistic review and **not** the specialist sign-off required by Phase 3B.
**Bank checked:** `assets/curriculum/exam_bank_permres_a2.json`
**Source of record:** official *Modelový test — Zkouška z češtiny pro trvalý pobyt v ČR, úroveň A2, platný od dubna 2026* (48-page PDF), text-extracted. See sources.

## Method

Extracted the official per-part task inventory and point map from the model-test PDF and compared it to the shipped bank's per-task structure. Headline numbers (110 total, 70 written / 40 speaking, 60% gates, 40/25/40 written timings) were already correct; this pass goes to task-level fidelity.

## Official structure (from the model test)

| Part | Time | Tasks | Points per task | Items |
|---|---|---|---|---|
| Reading (Čtení) | 40 min | 5 (Úloha 1–5) | **5, 5, 4, 6, 5** = 25 | multiple items per task |
| Writing (Psaní) | 25 min | 2 | **Formulář 8, E-mail 12** = 20 | e-mail: **min 35 words or 0 points** |
| Listening (Poslech) | ~40 min | 5 (Úloha 1–5) | **5, 5, 5, 5, 5** = 25 | **25 items** (1–25), ~1 pt each |
| Speaking (Mluvení) | 15 min | **4** | **8, 12, 10, 7** = 37 **+ 3 for pronunciation** = 40 | — |

Speaking tasks: 1 Odpovědi na otázky (8), 2 Dialogy (12), 3 Vyprávění podle obrázků / past tense (10), 4 Řešení situace (7), plus **3 points for výslovnost (pronunciation)**.

## Discrepancies found (ranked)

| # | Sev | Part | Bank now | Official | Impact |
|---|---|---|---|---|---|
| 1 | **HIGH** | Speaking | **3 tasks**, points [15, 15, 10] | **4 tasks** [8,12,10,7] **+3 pronunciation** | Wrong task set and point map. Missing task 4 *Řešení situace* (7 pts) and the separate 3-pt pronunciation allocation. Scores are not comparable to the real exam. |
| 2 | **HIGH** | Reading | points **[5,5,5,5,5]**, 1 item/task | **[5,5,4,6,5]**, multi-item tasks | Same 25 total but tasks 3 & 4 mis-weighted (should be 4 and 6); single-item tasks under-sample vs the real multi-item exercises. Partial scoring diverges. |
| 3 | **HIGH** | Listening | **5 items** (5 pts each) | **25 items** (1 pt each) across 5 tasks | Drastic under-sampling; a single wrong answer costs 5× the real weight. |
| 4 | **MED** | Writing | per-task split **[12, 8]** | Formulář **8**, E-mail **12** | Total 20 is correct but the split is reversed/mis-weighted, and the **"<35 words ⇒ 0 points"** e-mail rule is not represented in the bank. |
| 5 | LOW | Whole exam | `total_time_minutes: 120` | Written 105 (40+25+40) + speaking 15 = 120 | Defensible as a full-exam total, but the real exam times the written and oral parts separately (with a break); confirm the timer represents written-only (105) vs full-day. |
| 6 | note | — | — | — | Reading/listening tasks each carry an instruction + a shared stimulus with several sub-items; the bank models them as flat single questions. Faithful tasks need multi-item exercises. |

## What can be fixed by engineering vs what is specialist-gated

**Engineering can align now (pure numbers/structure, no new Czech content):**
- Re-weight the existing reading tasks to [5,5,4,6,5] and writing to Formulář 8 / E-mail 12 *once the tasks are restructured* (#2, #4 point maps). Note: the grader already honours whatever per-task `points` the bank declares, so this is a data/content edit, not an engine change.
- ~~Add the e-mail "<35 words ⇒ 0" rule to the writing scorer (#4).~~ **DONE (24 Jul):** `WritingWordGate` enforces each writing task's declared `min_words` deterministically — a below-minimum response scores 0 and never reaches the AI evaluator. The specific threshold value remains task/content data.
- Add the speaking pronunciation 3-point allocation and a 4th speaking task slot in the schema (#1 structure).

**Specialist-gated (needs authored, reviewed Czech content — the Phase 3B gate):**
- The actual multi-item reading/listening exercises (25 listening items, multi-item reading tasks) with correct Czech texts, distractors, and keys (#2, #3, #6).
- The 4th speaking task *Řešení situace* content and the pronunciation rubric (#1).
- Linguistic correctness and A2-appropriateness of every existing passage, prompt, and answer key — explicitly **not** assessed here.

## Recommendation

1. Do **not** present this bank as a faithful A2 simulation yet — the current in-app scoring can pass/fail differently from the real exam (especially speaking and single-item reading/listening).
2. Treat the discrepancies above as the specification for the content rebuild; author the multi-item exercises + 4th speaking task under qualified Czech review, then apply the point maps.
3. Re-run this structural check after the rebuild, and record the specialist reviewer + version/date as the Phase 3B sign-off.
4. The A1 bank (`exam_bank_permres_a1.json`) needs the same pass against the official A1 model test — not done here.

Until then the app must keep labeling exams as *practice, not an official result* (already enforced).

## Sources

- [Official A2 permanent-residence model test PDF (valid from 11 April 2026)](https://cestina-pro-cizince.cz/trvaly-pobyt/a2/wp-content/uploads/sites/3/2025/10/Modelovy-test-A2-novy-format-od-11.-dubna-2026.pdf) — source of record for the structure above.
- [NPI model test (ISBN 978-80-7578-169-7)](https://www.npi.cz/images/isbn/978-80-7578-169-7.pdf)
- [Permanent-residence exam info (cestina-pro-cizince.cz)](https://cestina-pro-cizince.cz/trvaly-pobyt/a2/en/)
