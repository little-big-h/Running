# Running Coaching Context — Holger Pirk
*Last updated: 5 May 2026. Migrated from claude.ai chat to Claude Code.*

---

## Athlete Profile

- **Name:** Holger Pirk
- **Age:** 43 (V40 category)
- **Height:** 199cm
- **Weight:** ~79.7kg (Apr 2026), target ~400g/week gain
- **Body fat:** 6%, muscle mass 89% (Withings scale)
- **Location:** Teddington, London (moving to Singapore ~August 2026)
- **Training volume:** ~90km/week

---

## Physiology & Health

### Heart Rate
- Resting HR: ~39 bpm
- Max observed in training: 155 bpm (W8 Q2 threshold session, 22 Apr 2026)
- Max observed in racing: 152 bpm (MK Marathon, 4 May 2026)
- Easy run avg HR: 121–125 bpm
- HR suppression: combination of cardiac adaptation + mild RED-S (confirmed by dietitian)
- Upper-arm optical HR monitor (not wrist-based)

### RED-S (Relative Energy Deficiency in Sport)
- Mild RED-S diagnosed by Jenaed (Nutrition and Co), confirmed Apr 2026
- Primary intervention: carbohydrate availability
- Goal: transition from catabolic to anabolic state
- Target weight gain: ~400g/week
- Vitamin D: critically deficient (22 nmol/L, Apr 2026). 50,000 IU weekly × 6–8 weeks, then 2,000 IU/day maintenance
- Free T3 low (2.7, ref 3.1–6.8) — RED-S driven suppression confirmed
- B12 very high (nutritional yeast). Urea high (high protein). Hb mildly low (dilutional)

### Nutrition
- Ovo-lacto vegetarian, whole-food approach
- Daily intake: ~3,300 kcal, ~3,680 kcal expenditure
- Protein target: 120g/day (typically hits 177g)
- Carb target: 395–475g/day on training days
- Does NOT eat after 8pm
- Tracks in FoodNoms (±30% uncertainty mode — midpoint = working number)
- Post-run fuelling rule: within 60 min of quality sessions, ≥60g carbs + ≥25g protein
- Post-Workout Cream: silken tofu 300g, peach 210g, Medjool dates 25g, cacao nibs 15g (~463 kcal, 57g carbs, 23g protein)
- Recurring ingredients: nutritional yeast, liquid aminos, white miso, shiitake powder, peanut flour (defatted), amaranth

### Standard Breakfasts (~700 kcal each)
1. **Shakshuka:** 2 eggs, 400g passata, 100g spinach, madras masala, smoked paprika, cumin, garlic, liquid aminos, nutritional yeast
2. **Sauerkraut hash:** 2 eggs, 240g sauerkraut, same spice profile

---

## Equipment & Tools

- **Shoes (race):** Saucony Endorphin 4, 8mm drop. ~6–7 sec/km faster at same HR vs Wave Rider.
- **Shoes (training):** Mizuno Wave Rider 29, 12mm drop (new pair from ~Mar 2026)
- **Watch:** Apple Watch + upper-arm optical HR monitor
- **App:** HealthFit — exports CSVs to `/Users/hlgr/Library/Mobile Documents/iCloud~com~altifondo~HealthFit/Sanitized`
- **Nutrition tracking:** FoodNoms
- **Cooking:** Ninja ML750 pressure cooker/air fryer, wok, bamboo steamers
- **Computation:** Wolfram Language Evaluator (mandatory — never use Python for computation)
- **Dietitian:** Jenaed, Nutrition and Co

---

## Race History

| Race | Date | Time | Notes |
|------|------|------|-------|
| Battersea Park Marathon | 18 Oct 2025 | 3:03:55 | Significant aerobic decoupling in second half |
| Stuttgart Marathon | 1 Mar 2026 | 3:05:43 | Positive split |
| Boston Lincolnshire Half | 12 Apr 2026 | 1:28:50 (PB) | Wind-adjusted ~1:21–1:23. Decoupling -3.2% (wind). Max HR 147. |
| **MK Marathon** | **4 May 2026** | **2:58:16 (PB)** | **Boston qualifier. Sub-3:00 A goal achieved.** |

---

## MK Marathon Analysis (4 May 2026)

- **File:** `2026-05-04-090001-Outdoor Running-Holger's Apple Watch.csv`
- **Result:** 2:58:16, avg HR 142.5, max HR 152, avg power ~315W
- **Execution:** Ran 2–3 bpm above target HR band in km 1–15 (adrenaline). Well executed km 16–30. Backed off km 30–38 (HR 142–144 vs target 144–147). Final push km 39–42.
- **Estimated time loss from conservative km 30+:** ~66 seconds → potential 2:57:10 with perfect execution
- **Boston 2027:** 2:58:16 gives ~2:10 buffer below likely cutoff (M40-44 standard 3:05:00, 2026 effective cutoff was 4:34 faster = 3:00:26)

### MK Race HR Strategy (for future reference)
| Segment | km | Target HR |
|---|---|---|
| Settle | 0–5 | 135–138 |
| Build | 5–15 | 138–141 |
| Race | 15–30 | 141–144 |
| Hold | 30–38 | 144–147 |
| Empty | 38–42 | 147+ |

**Key lesson for Boston:** resist adrenaline in km 5–15. Running 2–3 bpm hot there caused the km 30 fatigue.

---

## Current Training Plan: Battersea Park Half Marathon

- **Race:** Battersea Park Half Marathon, Saturday 18 July 2026, 10:30 gun
- **Venue:** Carriage Dr E, London SW11 4NJ
- **Target:** Sub-1:20 (3:47/km)
- **Approach:** Polarised training model
- **Plan file:** `Plans/battersea_half_polarised_plan.xlsx`
- **iCal file:** `Plans/battersea_half_plan.ics`

### Polarised Model Rules
- **Easy runs:** HR ceiling 128 bpm. If terrain/heat pushes above 128, slow down. No exceptions.
- **Hard sessions:** Full recovery between reps (2:30–3:00 jog). HR should reach 148–152 on the final rep.
- **NEVER:** Sustained efforts at 4:00–4:10/km. No tempo. No threshold. Nothing comfortably uncomfortable.
- Nothing in the middle zone.

### Weekly Structure (Build & Taper phases)
| Day | Session |
|-----|---------|
| Mon | Easy 10km, HR < 128 |
| Tue | Easy 10km, HR < 128 |
| Wed | Quality session |
| Thu | Easy 10km, HR < 128 |
| **Fri** | **REST** |
| Sat | Easy 10–12km + 6×100m strides |
| Sun | Long run, HR < 128 throughout |

### Plan Summary
| Wk | Dates | Phase | Vol | Wed Quality | Sun Long Run |
|----|-------|-------|-----|-------------|--------------|
| W1 | 5–11 May | Recovery | 45km | Easy only | 14km |
| W2 | 11–17 May | Recovery | 50km | Easy only | 14km |
| W3 | 18–24 May | Recovery | 55km | Strides OK Sat | 16km |
| W4 | 25–31 May | Base | 68km | 8×200m @3:20/km, 90s jog | 18km |
| W5 | 1–7 Jun | Build 1 | 75km | 6×800m @3:38/km, 2:30 jog | 18km |
| W6 | 8–14 Jun | Build 1 | 82km | 8×800m @3:33/km, 2:30 jog | 20km |
| W7 | 15–21 Jun | Build 2 | 82km | 5×1200m @3:44/km, 3:00 jog + **5km TT Sat** | 20km |
| W8 | 22–28 Jun | Build 2 | 78km | 4×1600m @3:44/km, 3:00 jog | 18km |
| W9 | 29 Jun–5 Jul | Taper | 62km | 4×800m @3:44/km, 2:00 jog | 14km |
| W10 | 6–12 Jul | Taper | 42km | 3×800m @3:44/km, 2:00 jog | 10km |
| W11 | 13–18 Jul | Race week | 25km | Tue: 2×800m, Wed: 20min easy | RACE Sat |

**5km TT benchmark:** Sub-17:30 in W7 = sub-1:20 within reach.

### Race Day Strategy (Battersea Half)
Run by HR throughout. Target bands:
- km 0–3: HR 135–138 (settle)
- km 3–8: HR 138–141 (build)
- km 8–18: HR 141–145 (race)
- km 18–21: HR 145–150 (hold)
- Final km: empty the tank

---

## Future Planning

- **Singapore move:** August 2026
- **Boston Marathon 2027:** qualifying window Sep 2025 – Sep 2026. 2:58:16 likely sufficient but not bulletproof.
- **Post-Singapore:** Track running likely. Consider developing top-end speed (5k/10k).
- **Tokyo Marathon 2027** (March): potential Boston qualifier attempt. Fast, flat, cool.
- **Predicted 10km from sub-1:20 half (Riegel):** ~36:15 @ 3:38/km

---

## Hydration & Race Nutrition

### Sweat Rate
- Measured: 2.3kg loss over 80 min/17km = **~1,725ml/hour**
- Race-day conditions will be higher than training measurement

### Vest Setup
- 500ml electrolytes (1 Nuun tablet — max 4 tablets/day)
- 500ml water
- Drink at every aid station regardless of how you feel

### MK Marathon Fuel Strategy (reference for future races)
- Pre-race: 3 bagels + mashed banana/date/peanut flour spread (~164g carbs)
- 08:40 top-up: half bagel + half banana (~20g carbs)
- In-race: Veloforte Amaro chews + OTE Strawberry thirds every 5km (~22g/stop, ~60g/hr)
- Beetroot juice: protocol for future race weeks (2 weeks daily, 400–500ml 2–3h pre-race)

---

## Strength & Cross-Training

### Daily Routine (~20 min, evening)
3 circuits of:
- 10 Pushups
- 10 Bulgarian Split Squat
- 30 Ab Twists
- 100 Crunches
- 15 Calf Raises
- 10 Standing Dumbbell Shoulder Press
- 15 Dumbbell Curls
- 30 Dumbbell Shrugs
- Plank 1 min
- 10 Sideway Lunges (frontal plane — valuable for hip stability)
- **NEW: 3×8 Elevated Single-Leg Long-Lever Bridges (per side)** — added per article recommendation for hamstring strength

### Hamstring Development (to add progressively)
1. ✅ **Elevated single-leg long-lever bridges** — added W1 recovery
2. Hamstring walkouts (Nordic curls) — add W3
3. Single-leg Romanian deadlifts — add W5

---

## Run Data Analysis Instructions

### Tools
- **Always use Wolfram Language Evaluator** for all computation. Never Python.
- Read CSVs: `Import[path, "CSV"]`
- Filter numerics: `Select[..., NumericQ]`
- HealthFit CSV path: `/Users/hlgr/Library/Mobile Documents/iCloud~com~altifondo~HealthFit/Sanitized`

### Column Name Variants
- Pre-Apr 2026 files: `"Since start"` (no unit)
- Apr 2026+ files: `"Since start (second)"` and new `"Intensity"` column
- Always check headers first and handle both variants

### Aerobic Decoupling (matches HealthFit)
- Metric: **Power/HR efficiency factor**
- Split all rows with valid HR and Power into two equal halves by row count (no warm-up exclusion)
- EF1 = mean(Power H1) / mean(HR H1)
- EF2 = mean(Power H2) / mean(HR H2)
- **Decoupling = (EF1 − EF2) / EF1 × 100**
- Threshold: <5% = clean aerobic run

### Pace
- **Pace (min/km) = max("Since start") / max("Distance (meter)") × 1000 / 60**
- Watch is paused during stops — elapsed time excludes them
- Never use mean of instantaneous speed values (overstates by ~6–7 sec/km)

### Standard Run Report Template
For any HealthFit CSV, report:
distance (km), duration (min), pace (min/km), avg HR (bpm), max HR (bpm), avg power (W), avg cadence (spm), aerobic decoupling (%)

### Wolfram Plot Standard
- `ImageSize -> 1040` (double resolution)
- `LabelStyle -> Directive[24]`
- Axis labels and title at 24pt
- `FrameTicksStyle -> Directive[Black, 24]`

---

## Key Learnings & Principles

### Pacing
- Always use **total distance / total time** (matches HealthFit). Never mean of instantaneous speed.
- Endorphin 4 gives ~6–7 sec/km faster at same HR vs Wave Rider.
- Run by HR, not pace. Pace is an output.

### Recovery from Marathons
- Acute HR normalisation: ~3 days (post-Stuttgart data)
- Structural/tissue recovery: ~3 weeks regardless of how you feel
- 1 day/mile rule is conservative for experienced runners who execute well

### Aerobic Decoupling History
| Session | Date | Decoupling |
|---------|------|------------|
| W3 Q1 long run | 22 Mar 2026 | Clean |
| Boston Half (wind) | 12 Apr 2026 | -3.2% (wind absorbed pace) |
| W7 long run (headwind km 12–16) | 19 Apr 2026 | ~4% adjusted |
| B2B1 | 25 Apr 2026 | 4.9% |
| B2B2 | 26 Apr 2026 | 4.7% |
| MK Marathon | 4 May 2026 | N/A (power dropout in underpasses) |

### HR Notes
- HR dropout in underpasses is **NOT real** — upper-arm optical HR is not GPS-dependent
- Pace volatility in underpasses IS real (GPS signal loss)
- These are independent phenomena

---

## Medical Files (project documents)
- Dietitian notes Mar 2026: `Medical/dietitian_notes_mar2026.pdf`
- Dietitian follow-up Apr 2026: `Medical/dietitian_followup_apr2026.pdf`
- Blood tests Apr 2026: `Medical/blood_tests_meddbase.pdf`

---

## Communication Style
- Direct and concise
- Challenge ideas when not 100% certain
- Spice calibration: always calibrate suggestions **high** — Holger typically doubles conservative quantities
- Uses 🐙 ("the okaytopus") to signal approval
- Week begins on Monday
- Measurements in metric units
- All computation via Wolfram (mandatory)
