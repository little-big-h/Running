(* ::Package:: *)

(* runChartsAPI.wl — Wolfram Cloud APIFunction endpoints that render
   running-report visualizations as live SVG over GET.

   Design notes (per Examples/wolframcloudapifunctiondesign.md):

   - Three endpoints by chart SHAPE, not by metric: /lineplot, /donut, /bars.
     One URL per chart, all data baked into the query string as typed
     decomposed sequences. No JSON blobs, no file interpreters.

   - Each list-valued field is a separate DelimitedSequence param.
     Parallel arrays (e.g. xs/ys, labels/vals/colors) are aligned by
     position and length-guarded into a clean 400.

   - Returns image/svg+xml directly (no envelope) so an <img src="..."> tag,
     a browser, or curl -o saves/renders it as-is.

   - Optional params declared as Association <|"Interpreter"->..., "Default"->...|>.
     Use Missing[] when you need to distinguish absent from a legitimate value.

   - All chart-style choices (Frame, FrameTicksStyle 24pt, GridLines, etc.)
     match CLAUDE.md "Visualisations — Wolfram only" rules.

   - To redeploy after edits, re-evaluate this whole file in a kernel
     authenticated to the target Cloud account. CloudDeploy with
     Permissions -> "Public" so the endpoints are open-GET callable
     (artifacts here aren't sensitive — they're chart pixels of a public
     training log). Tighten if that ever changes.
*)

(* ===================================================================== *)
(* Shared helpers                                                         *)
(* ===================================================================== *)

(* parseColor[s]: turn a query-string color token into an RGBColor.
   Accepts:
     - named: "red", "blue", "orange", "green", "purple", "brown", "gray", ...
     - hex:   "#RRGGBB" or "RRGGBB"
   Falls back to GrayLevel[0.4] on anything unparseable so the endpoint
   never throws on a malformed color. *)
parseColor[s_String] := Module[{lower = ToLowerCase[s], hex},
  Switch[lower,
    "red",     RGBColor[0.85, 0.15, 0.15],
    "blue",    RGBColor[0.20, 0.40, 1.00],
    "orange",  RGBColor[0.85, 0.45, 0.05],
    "green",   RGBColor[0.20, 0.65, 0.30],
    "purple",  RGBColor[0.50, 0.20, 0.70],
    "brown",   RGBColor[0.55, 0.35, 0.20],
    "gray",    RGBColor[0.45, 0.45, 0.45],
    "darkgreen", RGBColor[0.10, 0.50, 0.20],
    "powerorange", RGBColor[0.80, 0.40, 0.00],
    "yellow",  RGBColor[1.00, 0.80, 0.20],
    "skyblue", RGBColor[0.00, 0.60, 0.90],
    _,
      hex = StringReplace[lower, "#" -> ""];
      If[StringLength[hex] === 6 && StringMatchQ[hex, RegularExpression["[0-9a-f]{6}"]],
        RGBColor @@ (FromDigits[#, 16] / 255. & /@ StringPartition[hex, 2]),
        GrayLevel[0.4]]
  ]];
parseColor[_] := GrayLevel[0.4];

(* svgResponse[graphic]: serialize a Graphics to SVG bytes and wrap
   in an HTTPResponse with image/svg+xml so it renders inline. *)
svgResponse[g_] := HTTPResponse[
  ExportByteArray[g, "SVG"],
  <|"StatusCode" -> 200,
    "Headers" -> {
      "Content-Type" -> "image/svg+xml; charset=utf-8",
      "Cache-Control" -> "public, max-age=3600"}|>];

(* bad[msg]: clean 400 with a human-readable body. *)
bad[msg_String] := HTTPResponse[msg,
  <|"StatusCode" -> 400,
    "Headers" -> {"Content-Type" -> "text/plain; charset=utf-8"}|>];

(* mkRefLineEpilog[v, xMax]: dashed horizontal reference line at y=v. *)
mkRefLineEpilog[v_?NumberQ, xMin_, xMax_] := {Dashed, Gray, Line[{{xMin, v}, {xMax, v}}]};
mkRefLineEpilog[_, _, _] := {};

(* ===================================================================== *)
(* Endpoint 1: /lineplot                                                  *)
(* Distance-x metric-y line plot. Used for HR, pace, power, cadence,      *)
(* stride, VO, GCT, elevation.                                            *)
(* ===================================================================== *)

(* Required:
     xs        — numeric x values (km), comma-separated
     ys        — numeric y values, comma-separated, same length as xs

   Optional:
     title     — chart title (string)
     xlabel    — x-axis label (default "Distance (km)")
     ylabel    — y-axis label (default "")
     color     — line color, named or #RRGGBB (default "red")
     yMin/yMax — y-axis bounds (default: auto from data)
     xMin/xMax — x-axis bounds (default: auto from data)
     refLine   — dashed gray horizontal reference at this y (e.g. session avg)
     reversed  — "true"/"false", flip y axis (set true for pace plots so
                 fast pace points up). Default false.
     filled    — "true"/"false", fill area below the line (set true for
                 elevation profile). Default false.
     aspect    — height/width ratio (default 0.55)
     thickness — line thickness (default 0.004)
*)

lineplotAPI = APIFunction[
  {
    "xs"        -> DelimitedSequence["Number", ","],
    "ys"        -> DelimitedSequence["Number", ","],
    "title"     -> <|"Interpreter" -> "String", "Default" -> ""|>,
    "xlabel"    -> <|"Interpreter" -> "String", "Default" -> "Distance (km)"|>,
    "ylabel"    -> <|"Interpreter" -> "String", "Default" -> ""|>,
    "color"     -> <|"Interpreter" -> "String", "Default" -> "red"|>,
    "yMin"      -> <|"Interpreter" -> "Number", "Default" -> Missing[]|>,
    "yMax"      -> <|"Interpreter" -> "Number", "Default" -> Missing[]|>,
    "xMin"      -> <|"Interpreter" -> "Number", "Default" -> Missing[]|>,
    "xMax"      -> <|"Interpreter" -> "Number", "Default" -> Missing[]|>,
    "refLine"   -> <|"Interpreter" -> "Number", "Default" -> Missing[]|>,
    "reversed"  -> <|"Interpreter" -> "String", "Default" -> "false"|>,
    "filled"    -> <|"Interpreter" -> "String", "Default" -> "false"|>,
    "aspect"    -> <|"Interpreter" -> "Number", "Default" -> 0.55|>,
    "thickness" -> <|"Interpreter" -> "Number", "Default" -> 0.004|>
  },
  Module[{a = #, xs, ys, n, xMin, xMax, yMin, yMax, color, data, refY, epilog,
          revQ, fillQ, plot},
    xs = a["xs"]; ys = a["ys"];
    If[Length[xs] === 0, Return[bad["xs required (comma-separated numbers)"]]];
    If[Length[xs] =!= Length[ys],
       Return[bad["xs and ys must be the same length (got " <>
                  ToString[Length[xs]] <> " vs " <> ToString[Length[ys]] <> ")"]]];
    n = Length[xs];

    color = parseColor[a["color"]];
    revQ  = ToLowerCase[a["reversed"]] === "true";
    fillQ = ToLowerCase[a["filled"]] === "true";

    xMin = If[NumberQ[a["xMin"]], a["xMin"], Min[xs]];
    xMax = If[NumberQ[a["xMax"]], a["xMax"], Max[xs]];
    yMin = If[NumberQ[a["yMin"]], a["yMin"], Min[ys]];
    yMax = If[NumberQ[a["yMax"]], a["yMax"], Max[ys]];

    data = Transpose[{xs, ys}];

    refY = a["refLine"];
    epilog = If[NumberQ[refY], mkRefLineEpilog[refY, xMin, xMax], {}];

    plot = ListLinePlot[data,
      Frame -> True,
      FrameLabel -> {
        Style[a["xlabel"], 24],
        Style[a["ylabel"], 24]},
      PlotLabel -> If[a["title"] =!= "", Style[a["title"], 24, Bold], None],
      PlotStyle -> Directive[color, Thickness[a["thickness"]]],
      ImageSize -> 1040,
      AspectRatio -> a["aspect"],
      GridLines -> Automatic,
      GridLinesStyle -> Directive[LightGray, Dashed],
      PlotRange -> {{xMin, xMax}, {yMin, yMax}},
      FrameTicksStyle -> Directive[Black, 24],
      ScalingFunctions -> If[revQ, {Automatic, "Reverse"}, Automatic],
      Filling -> If[fillQ, Bottom, None],
      FillingStyle -> If[fillQ, Directive[color, Opacity[0.2]], Automatic],
      Epilog -> epilog];

    svgResponse[plot]
  ] &];

(* ===================================================================== *)
(* Endpoint 2: /donut                                                     *)
(* Pie chart with outside labels. Used for HR Zones, Training Load Focus. *)
(* ===================================================================== *)

(* Required:
     labels — segment labels, ";"-separated (commas appear inside labels)
     vals   — segment values, ","-separated, same length as labels
     colors — per-segment colors, ","-separated, same length as labels

   Optional:
     title   — chart title (default "")
     spacing — radial inner cutout (0 = pie, 0.55 = donut). Default 0.55.
*)

donutAPI = APIFunction[
  {
    "labels"  -> DelimitedSequence["String", ";"],
    "vals"    -> DelimitedSequence["Number", ","],
    "colors"  -> DelimitedSequence["String", ","],
    "title"   -> <|"Interpreter" -> "String", "Default" -> ""|>,
    "spacing" -> <|"Interpreter" -> "Number", "Default" -> 0.55|>
  },
  Module[{a = #, labels, vals, colors, parsedColors, plot},
    labels = a["labels"]; vals = a["vals"]; colors = a["colors"];
    If[Length[labels] === 0, Return[bad["labels required (semicolon-separated)"]]];
    If[!(Length[labels] === Length[vals] === Length[colors]),
       Return[bad["labels, vals, colors must all be the same length"]]];

    parsedColors = parseColor /@ colors;

    plot = PieChart[vals,
      ChartLabels -> Placed[(Style[#, 18, Bold, Black] & /@ labels), "RadialOutside"],
      ChartStyle -> parsedColors,
      SectorOrigin -> {Pi/2, "Clockwise"},
      PlotLabel -> If[a["title"] =!= "", Style[a["title"], 28, Bold], None],
      ImageSize -> 1040,
      SectorSpacing -> {0.005, a["spacing"]}];

    svgResponse[plot]
  ] &];

(* ===================================================================== *)
(* Endpoint 3: /bars                                                      *)
(* Vertical bar chart with per-bar labels above. Used for Effort Profile  *)
(* and 1 km Splits.                                                       *)
(* ===================================================================== *)

(* Required:
     labels  — bar x labels, ","-separated
     vals    — bar heights, ","-separated, same length as labels

   Optional:
     colors  — per-bar colors, ","-separated (default: gray for all)
     title   — chart title
     xlabel  — x-axis label
     ylabel  — y-axis label
     yMin/yMax — y bounds (default: auto from data)
     refLine — dashed horizontal reference (e.g. 100% for effort profile)
     unit    — suffix for value labels: ""|"%"|"pace" (default "")
               "pace" interprets vals as minutes and formats as M'SS"
     aspect  — height/width ratio (default 0.5)
*)

formatPace[m_?NumberQ] := Module[{mm = IntegerPart[m], ss = Round[(m - IntegerPart[m]) 60]},
  If[ss === 60, mm += 1; ss = 0];
  ToString[mm] <> "'" <> If[ss < 10, "0", ""] <> ToString[ss] <> "\""];

barsAPI = APIFunction[
  {
    "labels"  -> DelimitedSequence["String", ","],
    "vals"    -> DelimitedSequence["Number", ","],
    "colors"  -> <|"Interpreter" -> DelimitedSequence["String", ","], "Default" -> {}|>,
    "title"   -> <|"Interpreter" -> "String", "Default" -> ""|>,
    "xlabel"  -> <|"Interpreter" -> "String", "Default" -> ""|>,
    "ylabel"  -> <|"Interpreter" -> "String", "Default" -> ""|>,
    "yMin"    -> <|"Interpreter" -> "Number", "Default" -> Missing[]|>,
    "yMax"    -> <|"Interpreter" -> "Number", "Default" -> Missing[]|>,
    "refLine" -> <|"Interpreter" -> "Number", "Default" -> Missing[]|>,
    "unit"    -> <|"Interpreter" -> "String", "Default" -> ""|>,
    "aspect"  -> <|"Interpreter" -> "Number", "Default" -> 0.5|>
  },
  Module[{a = #, labels, vals, colorTokens, parsedColors, n, yMin, yMax, refY,
          unit, labelFn, epilog, plot},
    labels = a["labels"]; vals = a["vals"];
    If[Length[labels] === 0, Return[bad["labels required (comma-separated)"]]];
    If[Length[labels] =!= Length[vals],
       Return[bad["labels and vals must be the same length"]]];
    n = Length[labels];

    colorTokens = a["colors"];
    parsedColors = Which[
      Length[colorTokens] === 0, ConstantArray[GrayLevel[0.45], n],
      Length[colorTokens] === n, parseColor /@ colorTokens,
      True, Return[bad["colors must be empty or same length as labels"]]];

    yMin = If[NumberQ[a["yMin"]], a["yMin"], Min[Append[vals, 0]]];
    yMax = If[NumberQ[a["yMax"]], a["yMax"], 1.15 Max[vals]];

    refY = a["refLine"];
    unit = a["unit"];
    labelFn = Switch[unit,
      "pace",    (Placed[Style[formatPace[#], 18, Bold, Black], Above] &),
      "%",       (Placed[Style[ToString[#] <> "%", 22, Bold, Black], Above] &),
      _,         (Placed[Style[ToString[#] <> unit, 20, Bold, Black], Above] &)];

    epilog = If[NumberQ[refY],
                {Dashed, Gray, InfiniteLine[{0, refY}, {1, 0}]},
                {}];

    plot = BarChart[vals,
      ChartLabels -> (Style[#, 16, Bold] & /@ labels),
      ChartStyle -> parsedColors,
      LabelingFunction -> labelFn,
      PlotLabel -> If[a["title"] =!= "", Style[a["title"], 28, Bold], None],
      ImageSize -> 1040,
      AspectRatio -> a["aspect"],
      Frame -> True,
      FrameTicksStyle -> Directive[Black, 20],
      FrameLabel -> {Style[a["xlabel"], 22], Style[a["ylabel"], 22]},
      PlotRange -> {Automatic, {yMin, yMax}},
      GridLines -> {None, Automatic},
      GridLinesStyle -> Directive[LightGray, Dashed],
      Epilog -> epilog];

    svgResponse[plot]
  ] &];

(* ===================================================================== *)
(* Deploy                                                                 *)
(* ===================================================================== *)

(* Re-evaluate this block to (re-)deploy. The three CloudObjects are
   returned so the deployer can copy the URLs into the report.

   Permissions -> "Public" makes the endpoints GET-callable without auth.
   That's appropriate here because the rendered outputs contain only
   data baked into the URL — there is no server-side state, no user
   data, and no privilege boundary to protect. If that ever changes,
   tighten to Permissions -> Automatic and pre-sign URLs from a trusted
   builder. *)

deployments = <|
  "lineplot" -> CloudDeploy[lineplotAPI, "runCharts/lineplot",
                  Permissions -> "Public"],
  "donut"    -> CloudDeploy[donutAPI,    "runCharts/donut",
                  Permissions -> "Public"],
  "bars"     -> CloudDeploy[barsAPI,     "runCharts/bars",
                  Permissions -> "Public"]
|>;

Print["Deployed endpoints:"];
KeyValueMap[Print["  /", #1, " -> ", #2] &, deployments];

(* ===================================================================== *)
(* Smoke tests (uncomment to run locally before deploying)                *)
(* ===================================================================== *)

(*
GenerateHTTPResponse[lineplotAPI,
  HTTPRequest["https://example.invalid/?xs=1,2,3&ys=10,20,15&title=Test&color=blue"]]

(* Note: per the design doc, local GenerateHTTPResponse can drop query
   params. The authoritative check is URLRead against the deployed object,
   e.g.:

   URLRead[HTTPRequest[deployments["lineplot"],
     <|"Query" -> {"xs" -> "1,2,3", "ys" -> "10,20,15",
                   "title" -> "Test", "color" -> "blue"}|>]]
*)
*)
