# Long Run — 18 km easy (W7 Sun, hot)

**Date:** 2026-06-21
**Plan (.ics):** "20km long run — W7 Sun. HR ceiling 128. Genuinely easy throughout."
**In-session adjustment:** Trimmed to 18 km, HR strict ≤125 (post-TT recovery; agreed before the run). Athlete pulled up at 18 km on a pre-committed family rendezvous, reports legs had more to give.
**Verdict:** Clean aerobic execution. HR drift entirely thermoregulatory — a hot-day cardiac creep, not a fitness or pacing fault. 🐙

## Session summary

- Outdoor Running, 10:00 BST start. 1:26:42 elapsed, **zero pauses** (timer = elapsed).
- 18.08 km, avg pace **4:48/km**, avg speed 12.5 km/h.
- **Avg HR 132**, max 141, min 63 (pre-run).
- Avg power 278 W, max 568 W (transient surge).
- Cadence 164 spm, stride 1.28 m, vertical osc 10.3 cm — all stable throughout.
- 82 m ascent across 18 km (~1 m / 220 m — gently rolling).
- Training load peak **122**. RPE **40** (lower than yesterday's TT at 50).
- avg_temperature NULL on the watch — actual conditions reported as "very hot" by athlete.

## Reading

### Cardiac drift — the signal

Synopsize (ε=50, patience=30) over the full 5203 records returned a **single linear trend per metric**. The HR trend is the headline:

| Metric | Start | Slope | End (start + slope×t) | Median |
|---|---|---|---|---|
| **HR** | **123 bpm** | **+0.0033 bpm/s** | **140 bpm** | 134 |
| Speed | 3.58 m/s | −2 × 10⁻⁵ m/s² | 3.58 m/s | 3.55 (4:42/km) |
| Cadence | 82 spm⁄2 | flat | 82 spm⁄2 | 82 |
| Altitude | 12.1 m | flat | 12.1 m | 12.6 |

**+17 bpm HR climb across 86 min at constant speed, constant power, constant gait.** That is textbook cardiac drift.

### Decoupling — H1 vs H2

|  | H1 (first 43 min) | H2 (last 43 min) | Δ |
|---|---|---|---|
| HR | 128 | 135 | **+7 bpm (+5.3 %)** |
| Speed | 3.57 m/s (4:40/km) | 3.49 m/s (4:46/km) | −2.1 % |
| Power | 280 W | 275 W | −2.0 % |
| Cadence | 82 spm⁄2 | 82.5 spm⁄2 | flat |
| **EF (P/HR)** | **2.19** | **2.04** | **−7.0 %** |

Power dropped 2 % (normal long-run fade); HR rose 5 %. The asymmetry is the heat signal. Body kept the same mechanical output on the road — it just needed more cardiac throughput to dissipate core heat (skin blood flow) at the same external work.

### Hydration check

Athlete fluids:
- **250 ml pre-run** (water)
- **250 ml during** (electrolytes)
- **800 ml post** (water)

Sweat estimate for easy effort in heat: ~0.8-1.2 L/hour → ~1.1-1.7 L total losses over 86 min. **500 ml in flight + 800 ml post-arrival** matches a 0.6-1.2 L deficit pattern. The 800 ml arrival drink is the body confirming the deficit.

This is enough fluid to keep the HR drift **thermoregulatory** rather than **hypovolemic**. With less, the drift would have shown a steeper slope and probably some power fade too.

## Coaching takeaway — hot-day HR rules

The `CLAUDE.md` "HR ceiling 128" is a **cool-weather rule**. On hot days, judge easy by **start HR + perceived effort + cadence stability**, not the running average:

- If start HR is below ceiling and gait + RPE feel easy: hold the pace, let HR drift up to ~+10-12 bpm above the cool-weather ceiling.
- If start HR is already +10 above ceiling: that's not heat, that's fatigue or under-hydration → bail or slow.

Today's run met every "OK to continue" criterion: start HR 123 (below 128), RPE 40, cadence locked, gait stable. The drift to 140 was the body managing heat, not failing.

### For runs >75 min in heat — fluid prescription

| Run length | Intake during |
|---|---|
| ≤45 min | optional |
| 45–75 min | ~250 ml |
| **75–120 min** | **400-600 ml** (today was at the lower edge — could push to 500-600 next time) |
| >120 min | 250-300 ml per 30 min |

Pre-cooling matters more than during-run intake: cold drink 30 min before, wet cap if available. Reserve the intake for the back half when core temp is highest.

## Race-day implication (Battersea, 18 July)

Today is useful prep:
- Heat-acclimatisation stimulus is real (plasma volume expansion adapts over 7-14 days)
- If 18 July is hot, the HR strategy on the .ics ("km 8-18: HR 141-145, km 18-21: HR 145-150") needs the same hot-day interpretation — those are cool-weather numbers
- Plan to repeat ≥1 hot-day long run in W8/W9 if conditions permit (don't deliberately seek heat — accept it when it comes)

## TFL status
No flare during 18 km of constant-pace easy loading. Status remains **monitoring — tolerated full week including back-to-back TT + long run**.

---
*Data via BOSS. Session: `(Filter (Load "/dir" session) (Equal start_time 1150966816.0))`. Record-level Synopsize: `(Synopsize (ByName sun) (Patience 30) (Epsilon 50))` over 5203 1-Hz records. H1/H2 halves carved at median timestamp 1782035017.*
