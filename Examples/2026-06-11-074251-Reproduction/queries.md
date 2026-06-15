# Query log

Every BOSS expression and Wolfram script that contributed to `report.md`, in execution order. Paste-runnable as long as the FIT path retains its U+2019 apostrophe and U+00A0 NBSP between `Apple` and `Watch`.

`<FIT>` below is shorthand for:
`/Users/hlgr/Library/Mobile Documents/iCloud~com~altifondo~HealthFit/Documents/2026-06-11-074251-Outdoor Running-Holger's Apple Watch.fit`

## A. BOSS — file discovery

```lisp
(Slice (OrderBy (Load "/Users/hlgr/Library/Mobile Documents/iCloud~com~altifondo~HealthFit/Documents") (List (Desc time_created))) 0 5)
```

## B. BOSS — session message (headline numbers)

```lisp
(Load "<FIT>" session)
```

→ `avg_heart_rate=138`, `max_heart_rate=162`, `min_heart_rate=81`, `avg_power=307`, `max_power=437`, `avg_speed=3.797 m/s`, `max_speed=5.288 m/s`, `total_distance=15759.72 m`, `total_elapsed_time=4383.393 s`, `total_timer_time=4150.614 s`, `total_calories=1120`, `training_load_peak=120.4`, `avg_step_length=1355.2 mm`, `avg_running_cadence=84`, `max_running_cadence=94`, `avg_vertical_oscillation=98.0 mm`, `avg_stance_time=244.0 ms`, `nec_lat/long`, `swc_lat/long`, etc.

## C. BOSS — lap message (rep splits)

```lisp
(Project (Load "<FIT>" lap)
  message_index total_distance total_elapsed_time avg_speed
  avg_step_length avg_power max_power total_ascent)
```

→ 18 laps (lap 0 = W/U 3.89 km, laps 1/3/5/7/9/11/13/15 = 800 m reps, even laps = recoveries, lap 17 = C/D 1.33 km). Per-rep pace = `total_distance / avg_speed`. Lap message lacks `avg_heart_rate`.

## D. BOSS — cache `record` series

```lisp
(Name (Project (Load "<FIT>" record)
         timestamp heart_rate enhanced_speed power distance
         cadence step_length vertical_oscillation vertical_ratio
         stance_time enhanced_altitude position_lat position_long)
      thu)
```

Returns 4383 rows (1 Hz). Result exceeds token cap → spills to a file, but `Name` binding still succeeds. Use `(ByName thu)` thereafter.

## E. BOSS — record range sanity

```lisp
(GroupBy (ByName thu)
  (Min timestamp) (Max timestamp) (Max distance)
  (Min heart_rate) (Max heart_rate) (Mean heart_rate))
```

→ `min_ts=1781160171`, `max_ts=1781164554`, `max_dist=15761.73 m`, `min_HR=81`, `max_HR=162`, `mean_HR=139.18`.

## F. BOSS — HR-zone seconds

```lisp
(GroupBy (Filter (ByName thu) (GreaterEqual heart_rate 164.0)) (CountAll))
(GroupBy (Filter (ByName thu) (And (GreaterEqual heart_rate 150.0) (LessEqual heart_rate 163.0))) (CountAll))
(GroupBy (Filter (ByName thu) (And (GreaterEqual heart_rate 136.0) (LessEqual heart_rate 149.0))) (CountAll))
(GroupBy (Filter (ByName thu) (And (GreaterEqual heart_rate 122.0) (LessEqual heart_rate 135.0))) (CountAll))
(GroupBy (Filter (ByName thu) (And (GreaterEqual heart_rate 60.0) (LessEqual heart_rate 121.0))) (CountAll))
```

→ Z5=0, Z4=1239s, Z3=1143s, Z2=1551s, Z1=215s. Total HR-bearing = 4148s ≈ 1:09:08 (matches HealthFit Total Time 1:09:10).

## G. BOSS — aerobic decoupling (per CLAUDE.md rule)

```lisp
(GroupBy (Filter (ByName thu) (And (IsValid power) (IsValid heart_rate))) (CountAll))
; → 4135 rows
(Slice (OrderBy (Filter (ByName thu) (And (IsValid power) (IsValid heart_rate))) (List timestamp)) 2067 1)
; → row at midpoint, timestamp=1781162483.0
(GroupBy (Filter (ByName thu) (And (IsValid power) (IsValid heart_rate) (Less timestamp 1781162483.0))) (Mean power) (Mean heart_rate))
; → P1=298.85, HR1=133.58, EF1=2.237
(GroupBy (Filter (ByName thu) (And (IsValid power) (IsValid heart_rate) (GreaterEqual timestamp 1781162483.0))) (Mean power) (Mean heart_rate))
; → P2=315.82, HR2=145.04, EF2=2.178
```

→ Decoupling = (2.237 − 2.178) / 2.237 × 100 = **2.67 %**.

## H. BOSS — MMP-20-min (best 20-minute power window)

```lisp
(OrderBy
  (GroupBy
    (Project (Filter (ByName thu) (IsValid power))
             (As (floor (Divide (Subtract timestamp 1781160171.0) 60.0)) minbin) power)
    (Mean power) minbin)
  (List minbin))
```

→ 73 per-minute power bins. Sliding 20-bin mean computed client-side; max at bins 28-47 = **331 W** (HealthFit reports 332 W).

## I. BOSS — distance-binned multi-metric (100m bins, for plots)

```lisp
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

→ 158 rows (one per 100m bin). Drop the leading `bin=NULL` row, embed each metric column as a Wolfram `List`.

## J. BOSS — per-km splits

```lisp
(GroupBy
  (Project (ByName thu) (As (floor (Divide distance 1000.0)) km_bin)
           timestamp distance heart_rate enhanced_speed)
  (Min timestamp) (Max timestamp) (Min distance) (Max distance)
  km_bin)
```

→ Per km: pace = `(max_ts − min_ts)/(max_dist − min_dist) × 1000 / 60`. Best 1km = km 9-10 at **3:54/km**. Median (15 full km) = **4:15/km**.

## K. BOSS — 30-day Effort Profile baseline

```lisp
(GroupBy (Filter (Load "/Users/hlgr/Library/Mobile Documents/iCloud~com~altifondo~HealthFit/Documents" session)
                 (And (Equal sport "Running")
                      (GreaterEqual start_time 1147503600.0)
                      (Less start_time 1150094571.0)))
         (Mean avg_speed) (Mean avg_power) (Mean avg_heart_rate)
         (Mean total_distance) (Mean total_elapsed_time)
         (Mean total_calories) (CountAll))
```

→ n=20 sessions. Baselines: speed=3.493, power=289.8, HR=126.9, distance=11.71 km, duration=58.2 min, kcal=843.95.

Target/baseline %s: speed 109%, power 106%, HR 109%, distance 135%, duration 126%.

METs = `kcal_per_min / (77.8 × 0.0175)`. Target METs = 11.25, baseline METs = 10.65 → **106%**.

## L. Wolfram — HR plot

```mathematica
hrData = {<158 means from query I>};
distHR = Range[Length[hrData]] * 0.1 - 0.05;
ListLinePlot[Transpose[{distHR, hrData}],
  Frame -> True,
  FrameLabel -> {Style["Distance (km)", 24], Style["Heart Rate (bpm)", 24]},
  PlotLabel -> Style["Heart Rate \[Bullet] avg 138 \[Bullet] max 162 bpm", 24, Bold],
  PlotStyle -> Directive[Red, Thickness[0.004]],
  ImageSize -> 1040, AspectRatio -> 0.55,
  GridLines -> Automatic, GridLinesStyle -> Directive[LightGray, Dashed],
  PlotRange -> {{0, 16}, {80, 165}},
  FrameTicksStyle -> Directive[Black, 24],
  Epilog -> {Dashed, Gray, Line[{{0, 138}, {16, 138}}]}]
```

## M. Wolfram — Pace plot

```mathematica
paceData = 1000./speedData/60.;
ListLinePlot[Transpose[{dist, paceData}],
  Frame -> True,
  FrameLabel -> {Style["Distance (km)", 24], Style["Pace (min/km)", 24]},
  PlotLabel -> Style["Pace \[Bullet] avg 4'23\" \[Bullet] best 3'09\" /km", 24, Bold],
  PlotStyle -> Directive[Blue, Thickness[0.004]],
  ImageSize -> 1040, AspectRatio -> 0.55,
  GridLines -> Automatic, GridLinesStyle -> Directive[LightGray, Dashed],
  PlotRange -> {{0, 16}, {2.8, 6.5}},
  ScalingFunctions -> "Reverse",
  FrameTicksStyle -> Directive[Black, 24]]
```

## N. Wolfram — Power plot

```mathematica
ListLinePlot[Transpose[{dist, powerData}],
  Frame -> True,
  FrameLabel -> {Style["Distance (km)", 24], Style["Power (W)", 24]},
  PlotLabel -> Style["Running Power \[Bullet] avg 307 \[Bullet] max 437 W", 24, Bold],
  PlotStyle -> Directive[RGBColor[0.8, 0.4, 0], Thickness[0.004]],
  ImageSize -> 1040, AspectRatio -> 0.55,
  GridLines -> Automatic, GridLinesStyle -> Directive[LightGray, Dashed],
  PlotRange -> {{0, 16}, {150, 450}},
  Epilog -> {Dashed, Gray, Line[{{0, 307}, {16, 307}}]},
  FrameTicksStyle -> Directive[Black, 24]]
```

## O. Wolfram — Cadence plot

```mathematica
ListLinePlot[Transpose[{dist, 2 cadenceData}],
  Frame -> True,
  FrameLabel -> {Style["Distance (km)", 24], Style["Cadence (spm)", 24]},
  PlotLabel -> Style["Cadence \[Bullet] avg 169 \[Bullet] max 188 spm", 24, Bold],
  PlotStyle -> Directive[Purple, Thickness[0.004]],
  ImageSize -> 1040, AspectRatio -> 0.55,
  GridLines -> Automatic, GridLinesStyle -> Directive[LightGray, Dashed],
  PlotRange -> {{0, 16}, {130, 195}},
  Epilog -> {Dashed, Gray, Line[{{0, 169}, {16, 169}}]},
  FrameTicksStyle -> Directive[Black, 24]]
```

## P. Wolfram — Stride plot

```mathematica
ListLinePlot[Transpose[{dist, strideData/10.}],
  Frame -> True,
  FrameLabel -> {Style["Distance (km)", 24], Style["Stride length (cm)", 24]},
  PlotLabel -> Style["Stride Length \[Bullet] avg 136 \[Bullet] max 171 cm", 24, Bold],
  PlotStyle -> Directive[Darker[Green], Thickness[0.004]],
  ImageSize -> 1040, AspectRatio -> 0.55,
  GridLines -> Automatic, GridLinesStyle -> Directive[LightGray, Dashed],
  PlotRange -> {{0, 16}, {95, 175}},
  Epilog -> {Dashed, Gray, Line[{{0, 136}, {16, 136}}]},
  FrameTicksStyle -> Directive[Black, 24]]
```

## Q. Wolfram — Vertical Oscillation, GCT, Elevation

```mathematica
voPlot = ListLinePlot[Transpose[{dist, voData/10.}],
  Frame -> True,
  FrameLabel -> {Style["Distance (km)", 24], Style["Vertical osc. (cm)", 24]},
  PlotLabel -> Style["Vertical Oscillation \[Bullet] avg 9.8 \[Bullet] max 11.4 cm", 24, Bold],
  PlotStyle -> Directive[RGBColor[0.5, 0.2, 0.7], Thickness[0.004]],
  ImageSize -> 1040, AspectRatio -> 0.55,
  GridLines -> Automatic, GridLinesStyle -> Directive[LightGray, Dashed],
  PlotRange -> {{0, 16}, {8, 12}},
  FrameTicksStyle -> Directive[Black, 24]];

gctPlot = ListLinePlot[Transpose[{dist, gctData}],
  Frame -> True,
  FrameLabel -> {Style["Distance (km)", 24], Style["GCT (ms)", 24]},
  PlotLabel -> Style["Ground Contact Time \[Bullet] avg 244 \[Bullet] max 302 ms", 24, Bold],
  PlotStyle -> Directive[RGBColor[0.7, 0.3, 0.2], Thickness[0.004]],
  ImageSize -> 1040, AspectRatio -> 0.55,
  GridLines -> Automatic, GridLinesStyle -> Directive[LightGray, Dashed],
  PlotRange -> {{0, 16}, {200, 280}},
  FrameTicksStyle -> Directive[Black, 24]];

elePlot = ListLinePlot[Transpose[{dist, altData}],
  Frame -> True,
  FrameLabel -> {Style["Distance (km)", 24], Style["Elevation (m)", 24]},
  PlotLabel -> Style["Elevation \[Bullet] min 6 \[Bullet] max 16 m", 24, Bold],
  PlotStyle -> Directive[Brown, Thickness[0.004]],
  Filling -> Bottom, FillingStyle -> Directive[Brown, Opacity[0.2]],
  ImageSize -> 1040, AspectRatio -> 0.4,
  GridLines -> Automatic, GridLinesStyle -> Directive[LightGray, Dashed],
  PlotRange -> {{0, 16}, {5, 17}},
  FrameTicksStyle -> Directive[Black, 24]];
```

## R. Wolfram — HR Zones Pie

```mathematica
zones = {{"Z5 \[GreaterEqual]164", 0, RGBColor[0.3, 0.3, 1]},
         {"Z4 150-163", 30, RGBColor[1, 0.5, 0]},
         {"Z3 136-149", 27, RGBColor[1, 0.85, 0.2]},
         {"Z2 122-135", 37, RGBColor[0.3, 0.8, 0.3]},
         {"Z1 60-121", 5, RGBColor[0.0, 0.6, 0.9]}};
labels = #[[1]] <> "  " <> ToString[#[[2]]] <> "%" & /@ zones;
PieChart[zones[[All, 2]],
  ChartLabels -> Placed[(Style[#, 18, Bold, Black] & /@ labels), "RadialOutside"],
  ChartStyle -> zones[[All, 3]],
  SectorOrigin -> {Pi/2, "Clockwise"},
  PlotLabel -> Style["Heart Rate Zones", 28, Bold],
  ImageSize -> 1040,
  SectorSpacing -> {0.005, 0.55}]
```

## S. Wolfram — Training Load Focus + Effort Profile

```mathematica
tlf = {{"High Aerobic 70% (82)", 70, RGBColor[1, 0.5, 0]},
       {"Low Aerobic 30% (35)",  30, RGBColor[0.3, 0.8, 0.3]}};
PieChart[tlf[[All, 2]],
  ChartLabels -> Placed[(Style[#, 20, Bold, Black] & /@ tlf[[All, 1]]), "RadialOutside"],
  ChartStyle -> tlf[[All, 3]],
  SectorOrigin -> {Pi/2, "Clockwise"},
  PlotLabel -> Style["Training Load Focus \[Bullet] 117 TSS", 28, Bold],
  ImageSize -> 1040, SectorSpacing -> {0.005, 0.55}]

effort = {{"Avg Speed", 109, RGBColor[0.2, 0.4, 1]},
          {"Avg Power", 106, RGBColor[0.8, 0.4, 0]},
          {"Avg HR",    109, RGBColor[1, 0.2, 0.2]},
          {"METs",      106, RGBColor[0.5, 0.7, 0.2]},
          {"Distance",  135, RGBColor[0.4, 0.4, 0.4]},
          {"Duration",  126, RGBColor[0.6, 0.3, 0.7]}};
BarChart[effort[[All, 2]],
  ChartLabels -> (Style[#, 18, Bold] & /@ effort[[All, 1]]),
  ChartStyle -> effort[[All, 3]],
  LabelingFunction -> (Placed[Style[ToString[#] <> "%", 22, Bold, Black], Above] &),
  PlotLabel -> Style["Effort Profile \[Bullet] vs prior 30 days", 28, Bold],
  ImageSize -> 1040, AspectRatio -> 0.5,
  Frame -> True, FrameTicksStyle -> Directive[Black, 20],
  PlotRange -> {Automatic, {0, 160}},
  GridLines -> {None, Range[0, 160, 20]},
  GridLinesStyle -> Directive[LightGray, Dashed],
  Epilog -> {Dashed, Gray, InfiniteLine[{0, 100}, {1, 0}]}]
```

## T. Wolfram — 1 km splits

```mathematica
splits = {{0, 7+32/60.}, {1, 4+47/60.}, {2, 4+53/60.}, {3, 6+20/60.},
          {4, 3+59/60.}, {5, 3+57/60.}, {6, 4+7/60.},  {7, 4+15/60.},
          {8, 4+1/60.},  {9, 3+54/60.}, {10, 4+24/60.},{11, 4+14/60.},
          {12, 4+15/60.},{13, 4+2/60.}, {14, 4+43/60.},{15, 4+47/60.}};
labels = ToString[#[[1]]] <> "-" <> ToString[#[[1]]+1] & /@ splits;
paces = splits[[All, 2]];
formatPace[m_] := With[{mm = IntegerPart[m], ss = Round[(m - IntegerPart[m]) 60]},
  ToString[mm] <> "'" <> If[ss < 10, "0", ""] <> ToString[ss] <> "\""];
colors = If[# < 4.0, RGBColor[0.2, 0.7, 0.2],
            If[# < 4.5, RGBColor[1, 0.8, 0.2], RGBColor[0.9, 0.4, 0.2]]] & /@ paces;
BarChart[paces,
  ChartLabels -> (Style[#, 16, Bold] & /@ labels),
  ChartStyle -> colors,
  LabelingFunction -> (Placed[Style[formatPace[#], 18, Bold, Black], Above] &),
  PlotLabel -> Style["1 km Splits \[Bullet] median 4'15\" \[Bullet] best 3'54\"", 28, Bold],
  ImageSize -> 1040, AspectRatio -> 0.5,
  Frame -> True, FrameTicksStyle -> Directive[Black, 20],
  FrameLabel -> {Style["Km", 22], Style["Pace (min/km)", 22]},
  PlotRange -> {Automatic, {3, 8.5}},
  GridLines -> {None, Range[3, 8.5, 0.5]},
  GridLinesStyle -> Directive[LightGray, Dashed]]
```

## U. Wolfram cloud → local

Each Wolfram cell above returns a markdown link `![Image](https://www.wolframcloud.com/obj/<uuid>)`. Curl to local:

```bash
curl -sSL -o "<localpath>.png" "https://www.wolframcloud.com/obj/<uuid>"
```

## Numeric sanity check (this run vs HealthFit example)

| Metric | Reproduced | HealthFit | Δ |
|---|---|---|---|
| avg HR | 138 | 138 | 0 |
| max HR | 162 | 162 | 0 |
| min HR | 81 | 81 | 0 |
| HR Z4 (s) | 1239 (20:39) | 20:38 | +1 |
| HR Z3 (s) | 1143 (19:03) | 19:02 | +1 |
| HR Z2 (s) | 1551 (25:51) | 25:54 | −3 |
| HR Z1 (s) | 215 (3:35) | 3:39 | −4 |
| avg power | 307 | 307 | 0 |
| max power | 437 | 437 | 0 |
| avg pace | 4'23" | 4'23" | 0 |
| best 1km | 3'54" | 3'55" | −1s |
| median 1km | 4'15" | 4'15" | 0 |
| MMP-20 min | 331 W | 332 W | −1 |
| total work | 1,274 kJ | 1,275 kJ | −1 |
| decoupling | 2.7% | 3% | −0.3 |
| TRIMP exp | 120 | 120 | 0 |

All within rounding. Effort Profile % differs because baseline window assumption differs from HealthFit's internal one.
