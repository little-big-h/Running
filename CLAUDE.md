# Running Coaching — Claude Code Project
*This file is the CLAUDE.md for the Running Claude Code project.*

## Purpose
Ongoing running coaching for Holger Pirk. See `CONTEXT.md` for full athlete profile.

## Current Goal
**Battersea Park Half Marathon, 18 July 2026** — polarised training model.
- **Primary: sub-1:21** (3:50/km) — re-aimed 2026-06-20 after W7 5k TT (18:47.7).
- **Stretch: sub-1:20** (3:47/km).

## Critical Rules

### Data Analysis — BOSS
- **ALL run data analysis via BOSS**, starting with:
  `(LoadFIT "/Users/hlgr/Library/Mobile Documents/iCloud~com~altifondo~HealthFit")`
- Use `session` message type for per-workout summaries
- Use `record` message type for time-series data (single file only)
- Use `lap` message type for lap/interval breakdowns
- Never use Python for computation

### Visualisations — Wolfram only
- **ALL plots via `Wolfram:WolframLanguageEvaluator`**
- `ImageSize -> 1040`, all labels/titles at 24pt, `FrameTicksStyle -> Directive[Black, 24]`

### Aerobic Decoupling
- Metric: Power/HR efficiency factor (matches HealthFit)
- Split rows into two equal halves by row count
- EF1 = mean(Power H1) / mean(HR H1); EF2 = mean(Power H2) / mean(HR H2)
- Decoupling = (EF1 − EF2) / EF1 × 100
- Threshold: <5% = clean aerobic run

### Pace
- Pace (min/km) = total_elapsed_time / total_distance × 1000 / 60
- Watch pauses during stops — elapsed time excludes them
- Never use mean of instantaneous speed values

### Coaching
- Run by HR, never by pace — pace is an output
- Easy runs: HR ceiling **128 bpm**
- Quality sessions: HR should reach 148–152 on final rep
- Rest day: **Friday**
- Week starts: **Monday**

## Data Location
```
/Users/hlgr/Library/Mobile Documents/iCloud~com~altifondo~HealthFit
```

## Key Files in This Directory
- `CONTEXT.md` — full context, start here
- `README.md` — setup instructions
- `Plans/battersea_half_polarised_plan.xlsx` — current training plan (Excel)
- `Plans/battersea_half_plan.md` — current training plan (Markdown)
- `Plans/battersea_half_plan.ics` — iCal (62 events)
- `Medical/` — dietitian notes and blood tests

## Communication
- Direct and concise
- Metric units only
- 🐙 = approval ("the okaytopus")
- Challenge ideas that aren't 100% certain
- Week begins Monday
