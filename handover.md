# Handover — BOSS tool knowledge (for next session)

*Written 2026-06-01. Reason: the `mcp__boss__evaluate` tool description is hard-truncated
at "Discover… [truncated]" in this session (identical via `select:` and keyword ToolSearch —
not a cache I could bust). Starting a fresh session to get an un-truncated description.
This file records what was learned the hard way so the next session starts ahead.*

## FIRST THING TO DO NEXT SESSION
Re-read the full `mcp__boss__evaluate` description. **Capture the text after "Discover…"** —
that tail is the operator reference (filter / order / limit / aggregate syntax) that was
missing all session and caused most of the pain. Append the real verbs to this file (or
CLAUDE.md) once known.

## Confirmed working (verified by evaluation)
- `LoadFIT` forms:
  - `(LoadFIT "/dir")` → summary, one row per file: `file`, `time_created`, `start_time`,
    `sport`, `total_elapsed_time` (s), `total_distance` (m), `total_calories`.
  - `(LoadFIT "/file.fit" <msgtype>)` → `session` | `record` | `lap` | `activity`.
  - `(LoadFIT "/dir" <msgtype>)` → all files, that msgtype.
- `Project` — selects/computes columns. **`As` arg order is `(As SOURCE NEWNAME)`** (source
  first). An expression in the NAME slot errors `expected Symbol`.
- Arithmetic inside `Project`: **`Multiply`, `Divide`** — element-wise on columns; scalar
  literals allowed in the value slot, e.g. `(As (Multiply avg_running_cadence 2) cad_spm)`.
- Worked example (per-lap derived table, runs cleanly):
  `(Project (LoadFIT "…lap.fit" lap) (As message_index lap) (As (Multiply (Divide total_elapsed_time total_distance) 1000) pace_spkm) (As (Divide avg_power avg_heart_rate) ef))`
- `Slice` IS a reducer **but demands "arrow-engine" input** — it rejected both raw `LoadFIT`
  output and `Project(LoadFIT)` output with `input was not produced by the arrow engine`.
  Correct composition unknown (probably documented in the truncated tail).

## Did NOT reduce this session (likely wrong verb/syntax — see truncated docs)
- `Times` → use **`Multiply`** (`Times` errors `No function registered with name: times`).
- Bare scalar arithmetic (`(Plus 1 2)`) echoes unevaluated — arithmetic only inside a table
  pipeline.
- `Group`, `Select`, `Greater`, `Sort`, `Order` — all echoed unevaluated / "not produced by
  arrow engine". Unknown verbs echo the expression back unchanged. The correct
  filter/order/aggregate operators are in the missing description tail.

## Filename transmission — THE big time-sink (read this)
- Apple Watch export filenames contain **U+2019** (’) in `Holger’s` and a **U+00A0 NBSP**
  between `Apple` and `Watch`. Both render identically to ASCII and are invisible.
- **BOSS is deterministic.** `cannot open file` = wrong path bytes, NOT flakiness. Do not
  retry-spam identical-looking paths.
- **The agent CANNOT reproduce the NBSP by typing.** Verified with Wolfram `ToCharacterCode`:
  a re-typed path has a regular space (code 32) at the `Apple Watch` gap; the real file has
  code 160. The agent's output layer also decodes `\u` escapes, so ` ` does not reliably
  survive either. The tool description itself says invisible chars "cannot be reproduced by
  re-typing."
- **What worked:** copy a path whose bytes are already correct (e.g. from a prior successful
  call or the directory `file` column) and change ONLY the ASCII date/time digits.
- **Best fix (once operators are known):** filter by `start_time`/date SERVER-SIDE so the
  filename is never typed at all. That sidesteps the NBSP entirely.
- Also beware U+200B (zero-width space), U+00AD (soft hyphen), dash variants ‐ – —.

## Scale note
- Directory holds ~**2834** runs. `(LoadFIT "/dir")` summary is ~**550k chars** → exceeds the
  tool-result token limit and gets spilled to a file. **Never dump the whole directory** —
  reduce server-side (filter + slice) or pick the file first.

## Unfinished task this session
- Question on the table: **"what do you think of this morning's run?"** (2026-06-01).
- This morning's run located: `2026-06-01-081130-Outdoor Running` — **10.33 km, 54:15,
  5:15/km pace, 730 kcal**, started 08:11. (Extracted from the saved directory dump, which
  only carries distance/time/calories.)
- Preliminary read: looks like a correct EASY/recovery run the day after the 2026-05-31
  18 km steady effort (4:44/km, +6.9% decoupling). **Not yet confirmed** because the summary
  has no HR/power.
- TODO: load this morning's `session` (and `lap`) to confirm intensity by HR. Path to load
  (build via date-filter server-side, or change ASCII digits on a known-good path):
  file = `2026-06-01-081130-Outdoor Running-Holger<U+2019>s Apple<U+00A0>Watch.fit`
  in `/Users/hlgr/Library/Mobile Documents/iCloud~com~altifondo~HealthFit/Documents`.

## Coaching context already established
- Easy HR ceiling 128; quality reps 148–152; rest day Friday; week starts Monday.
- 2026-05-31 run fully analysed (18 km, stride peaked 1361 mm km8–9, faded to 1194 mm km17,
  cadence locked 166 spm, EF 2.50→2.00, decoupling +6.9% = steady, not easy).
