# Running Coaching — Claude Code Instructions

This directory contains everything needed to continue Holger's running coaching in Claude Code.

## Key Files

| File | Purpose |
|------|---------|
| `CONTEXT.md` | **Start here.** Full athlete profile, race history, current plan, analysis rules |
| `Plans/battersea_half_polarised_plan.xlsx` | Current training plan (Battersea Half 18 Jul 2026) |
| `Plans/battersea_half_plan.ics` | iCal file — all 62 training sessions through race day |
| `Medical/` | Dietitian notes and blood test results (see below) |

## Medical Files — Manual Copy Required

These PDFs are in the claude.ai project and need to be downloaded and placed here manually:
- `Medical/dietitian_notes_mar2026.pdf` — original nutrition report Mar 2026
- `Medical/dietitian_followup_apr2026.pdf` — follow-up notes Apr 2026
- `Medical/blood_tests_meddbase.pdf` — blood test results Apr 2026

## HealthFit Data

All run data is at:
```
/Users/hlgr/Library/Mobile Documents/iCloud~com~altifondo~HealthFit/Sanitized
```

## Critical Rules

1. **All computation via Wolfram Language Evaluator** — never Python for numbers
2. **Run by HR, never by pace** — pace is an output
3. **Wolfram plots:** ImageSize 1040, all fonts at 24pt
4. **Aerobic decoupling:** Power/HR EF formula (see CONTEXT.md)
5. **Pace:** total distance / total elapsed time only

## Current Status (5 May 2026)

- MK Marathon completed yesterday: **2:58:16 PB, Boston qualifier**
- Recovery week (W1) starts today
- Next race: Battersea Park Half Marathon, Sat 18 Jul 2026, 10:30
- Target: Sub-1:20
- Moving to Singapore ~August 2026
