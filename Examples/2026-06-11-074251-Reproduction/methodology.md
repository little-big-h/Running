# How to reproduce this report

Hand-off doc for another Claude (or human) who wants to recreate this report from scratch against any other run in `/Users/hlgr/Library/Mobile Documents/iCloud~com~altifondo~HealthFit/Documents`.

## What this report reproduces

The `report.md` is a near-replica of HealthFit's auto-generated session report (see `../2026-06-11-074251-Outdoor Running-Holgers Apple Watch/2026-06-11-074251-outdoor-running-holger-s-apple-watch.md`). All metrics are derived **only from the FIT file** plus prior FIT history in the Documents dir. Sections that need Apple-Health-only data are omitted (see "Omitted sections" below).

## Toolchain

| Step | Tool | What for |
|---|---|---|
| Load FIT | BOSS `Load` op | session, lap, record message types |
| Aggregate | BOSS `Filter`, `Project`, `GroupBy`, `OrderBy`, `Cumulate` | HR zones, decoupling, splits, baselines |
| Visualize | Wolfram `ListLinePlot`, `BarChart`, `PieChart` | All 12 PNGs |
| Save plots | Wolfram returns cloud URLs → `curl` to local PNG | Local file output |

**Note: the BOSS engine renamed `LoadFIT` → `Load` on 2026-06-12.** If `(Load ...)` returns the expression unevaluated, the engine description was cached pre-rename — fetch live via `(GetEngineDescription)`. If it returns `cannot open file`, the filename's invisible Unicode degraded (see below).

## FIT filename gotcha

Apple Watch FIT exports contain TWO invisible non-ASCII characters in the filename:
- U+2019 (right single quote) in `Holger's`
- U+00A0 (NBSP) between `Apple` and `Watch`

These render identically to ASCII apostrophe + space, but BOSS' `Load` is byte-exact and returns `cannot open file` on the wrong path.

**Workaround:** copy a known-good path verbatim from a `(Slice (OrderBy (Load "/dir") (List (Desc time_created))) 0 5)` listing, then change only the date/time digits. If retyping, use the JSON ` ` escape between Apple and Watch.

## Step-by-step

### 1. Discover the file

```
(Slice (OrderBy (Load "/Users/hlgr/Library/Mobile Documents/iCloud~com~altifondo~HealthFit/Documents") (List (Desc time_created))) 0 5)
```

Returns one row per `.fit` file with `file`, `time_created`, `start_time`, `sport`, `total_elapsed_time`, `total_distance`, `total_calories`. Pick target by `start_time` (Unix seconds).

### 2. Load session summary

```
(Load "/path/to/run.fit" session)
```

Returns one row with all session aggregates: `avg/max_heart_rate`, `avg/max_power`, `avg_speed`, `total_distance`, `total_elapsed_time`, `total_timer_time`, `training_load_peak`, `workout_rpe`, `total_calories`, etc. Most headline numbers come from here.

### 3. Load lap summary

```
(Project (Load "/path/to/run.fit" lap) message_index total_distance total_elapsed_time avg_speed avg_step_length avg_power max_power total_ascent)
```

**Lap message has NO `avg_heart_rate` / `max_heart_rate` field.** Per-rep HR must come from the `record` message bucketed by lap-boundary timestamps.

### 4. Cache record-level time series

```
(Name (Project (Load "/path/to/run.fit" record) timestamp heart_rate enhanced_speed power distance cadence step_length vertical_oscillation vertical_ratio stance_time enhanced_altitude position_lat position_long) thu)
```

This will exceed the BOSS result-token cap (~440 KB) — it dumps to a file but **the `Name` binding still takes effect**. Subsequent `(ByName thu)` queries work without re-loading.

**Caveat:** named bindings can vanish between calls (engine GC). Re-bind if `(ByName thu)` returns `unordered_map::at: key not found`.

### 5. Derive HR zones

For each zone:

```
(GroupBy (Filter (ByName thu) (And (GreaterEqual heart_rate <low>) (LessEqual heart_rate <high>))) (CountAll))
```

Returns row count = seconds in that zone (record is 1 Hz). Sum across all zones gives the denominator for %.

### 6. Aerobic decoupling (per `CLAUDE.md`)

1. Count rows with both power and HR non-null: `(GroupBy (Filter (ByName thu) (And (IsValid power) (IsValid heart_rate))) (CountAll))`
2. Find the median timestamp: `(Slice (OrderBy (Filter ...) (List timestamp)) <N/2> 1)` — read the `timestamp` from the returned row.
3. Compute EF1 and EF2:
   ```
   (GroupBy (Filter (ByName thu) (And (IsValid power) (IsValid heart_rate) (Less timestamp <T_mid>))) (Mean power) (Mean heart_rate))
   (GroupBy (Filter (ByName thu) (And (IsValid power) (IsValid heart_rate) (GreaterEqual timestamp <T_mid>))) (Mean power) (Mean heart_rate))
   ```
4. `Decoupling % = (EF1 − EF2) / EF1 × 100` where `EF = mean_power / mean_HR`.

### 7. Distance-binned time-series (for plots)

100m bins keep ~158 points across a 15.7 km run — enough for chart fidelity, small enough to embed in Wolfram code:

```
(OrderBy
  (GroupBy
    (Project (ByName thu)
      (As (floor (Divide distance 100.0)) bin)
      heart_rate enhanced_speed power cadence step_length
      vertical_oscillation stance_time enhanced_altitude)
    (Mean heart_rate) (Mean enhanced_speed) (Mean power)
    (Mean cadence) (Mean step_length) (Mean vertical_oscillation)
    (Mean stance_time) (Mean enhanced_altitude) bin)
  (List bin))
```

Drop the first `bin=NULL` row. Copy each column as a Wolfram `List` literal.

### 8. Per-km splits

```
(GroupBy (Project (ByName thu) (As (floor (Divide distance 1000.0)) km_bin) timestamp distance)
         (Min timestamp) (Max timestamp) (Min distance) (Max distance) km_bin)
```

Pace per km = `(max_ts − min_ts) / (max_dist − min_dist) × 1000 / 60` (minutes / km).

**Known imprecision:** these are elapsed-time-per-km splits using all records, including paused seconds. HealthFit's reported per-km splits use *moving* time only. For the warm-up km where the athlete jogs to start with traffic stops, this can differ by up to ~30 s/km. The rep-section splits agree to within ~2 s.

### 9. MMP-20 min (best 20-minute power)

BOSS' `Pairwise` / `Cumulate` mixed-arg handling is touchy. The reliable shortcut: bin power into per-minute means, then take a sliding-window of 20 consecutive minute-bins:

```
(OrderBy
  (GroupBy
    (Project (Filter (ByName thu) (IsValid power))
             (As (floor (Divide (Subtract timestamp <start_ts>) 60.0)) minbin) power)
    (Mean power) minbin)
  (List minbin))
```

Compute the 20-bin sliding mean client-side and pick the max. For this run the max landed on minute-bins 28-47 ≈ **331 W**.

### 10. 30-day effort baseline

```
(GroupBy (Filter (Load "/dir" session)
                 (And (Equal sport "Running")
                      (GreaterEqual start_time <T_30d_ago>)
                      (Less start_time <T_target>)))
         (Mean avg_speed) (Mean avg_power) (Mean avg_heart_rate)
         (Mean total_distance) (Mean total_elapsed_time)
         (Mean total_calories) (CountAll))
```

Then `target_metric / baseline_metric × 100` for each effort component. **METs** = `kcal_per_min / (weight_kg × 0.0175)`.

HealthFit's exact baseline window is unknown — our 30-day window will not match their numbers. Document the choice in the report.

## Visualization style

CLAUDE.md mandates:

- `ImageSize -> 1040`
- Labels / titles at 24 pt
- `FrameTicksStyle -> Directive[Black, 24]`
- `Frame -> True`
- `GridLines -> Automatic, GridLinesStyle -> Directive[LightGray, Dashed]`

Per-plot tweaks:
- Time-series plots: `ListLinePlot` with `AspectRatio -> 0.55`, distance on x.
- Pace plot: invert y with `ScalingFunctions -> "Reverse"` so fast pace is up.
- Elevation: `Filling -> Bottom` for a filled profile.
- Effort Profile: `BarChart` with reference line at 100% via `InfiniteLine`.
- HR Zones / Training Load Focus: `PieChart` with `ChartLabels -> Placed[..., "RadialOutside"]`.

## Wolfram-cloud → local PNG

The MCP Wolfram tool returns markdown links to `wolframcloud.com/obj/<uuid>`. Curl them down:

```
curl -sSL -o "<localpath>.png" "https://www.wolframcloud.com/obj/<uuid>"
```

Cloud objects appear durable on the order of days; if they expire, re-render.

## Omitted sections (require Apple Health, not FIT)

| Section | Why omitted |
|---|---|
| Map | Need GPS overlay against base map — solvable via Wolfram `GeoGraphics` but slow and stylistically off vs HealthFit. |
| Cardio Fitness (VO₂ max) | Apple Health computes from RHR/HR-response history. Not derivable from one FIT. |
| Post-Workout HRR | Apple Health continues HR sampling after workout end. The FIT `record` stream stops at workout end. |
| CTL/ATL transitions | Need ≥6 weeks of training load history with Banister-style smoothing. Possible to add — load all sessions, sum daily TRIMP, compute 42-day / 7-day EWMAs — but out of scope here. |
| Power Curve / MMP across durations | Single-session MMP-20 is included; full curve needs comparison context. |
| Effort Profile exact % | HealthFit's baseline window unknown; mine is 30 days of all `Sport = Running` sessions. |
| Heart Rate Profile (density / peak) | Computable from `record` HR histogram. Skipped for brevity; add via `Histogram[hrSamples, ...]` if needed. |
| GPS Accuracy | Available as `gps_accuracy` in `record` but stylistically tied to HealthFit's hardware overlay. |

## Files in this output

| File | Contents |
|---|---|
| `report.md` | The reproduced report |
| `methodology.md` | This document |
| `queries.md` | Every BOSS expression and Wolfram script that fed the report |
| `*.png` | 12 visualizations |

## To re-run for another date

1. Pick the file from a `(OrderBy (Load "/dir") (List (Desc time_created)))` listing.
2. Replace the path everywhere in `queries.md` (keep the NBSP intact — see filename gotcha above).
3. Re-bind `thu` with the new record table.
4. Re-execute the queries in `queries.md` in order.
5. Re-render each Wolfram cell, curl the new URLs into the output dir.
6. Update `report.md` headline numbers + the methodology's "30-day baseline" window.
