# Designing Wolfram Cloud `APIFunction` Endpoints — A Strategy Note

*For a future Claude building HTTP endpoints with `CloudDeploy[APIFunction[…]]`. These
patterns matter whenever an endpoint takes **structured or sizable input** (lists,
records, many fields) and/or returns a **non-trivial artifact** (a binary file or a large
text/JSON body). They are domain-agnostic.*

## TL;DR

1. **Don't hand-parse structured input.** Let the framework's interpreters parse it,
   declared in the parameter spec.
2. **Decompose structured/large input into typed scalar/sequence query params** (one
   "column" per attribute) rather than shipping a serialized document (JSON) as a string.
   Think DSM (decomposition storage model), not a serialized blob.
3. **Design for GET.** A link, a browser, an `<img>`, `curl -o` all issue GETs with query
   strings. If the endpoint works over a GET query string, it works everywhere — and the
   *same* decomposed params carry over POST form-encoding unchanged when the payload is
   large (§8).
4. **Verify against the deployed object**, in a single self-contained kernel cell. Local
   simulation lies.

---

## 1. The format-interpreter parameter-type trap

The instinct is `APIFunction[{"payload" -> "RawJSON"}, …]` and let the caller POST JSON.
**This breaks for query strings.** As an `APIFunction` *parameter type*, a format name like
`"RawJSON"`/`"JSON"` resolves to a **file interpreter** — it expects an uploaded `.json`
file. A GET query value is a string, not a file, so you get:

```
"The supplied object cannot be interpreted as a file of type RawJSON."
(AllowedExtensions: ["json"])
```

Clickable/browser/`<img>` GETs therefore 400. Don't discover this in production.

## 2. Don't manually parse — but know what "manual" means

The rule is **no hand-rolled string surgery** (regex, `StringSplit`, brace-counting,
`ToExpression` on fields). It is **not** a ban on the framework's parsers. The distinction
that matters:

- ✅ **Declarative** — the parameter's `Interpreter` does the work: `DelimitedSequence`,
  `"Integer"`, `"Number"`, `"Date"`, etc.
- ⚠️ **Framework parse in the body** — `ImportString[s, "RawJSON"]` /
  `Interpreter["RawJSON"][s]`. This *is* the framework, not string surgery; acceptable when
  no declarative param interpreter fits — but prefer (✅).
- ❌ **Manual** — you split/scan the string yourself. Never.

If a project rule says "never call `ImportString`," read it as "never hand-parse," and
reconcile with the owner before contorting the design around the literal wording.

## 3. Typed decomposed sequences over a serialized blob (the core pattern)

Instead of one param carrying a serialized object, give **each field its own typed query
parameter**, and store list-valued data as **parallel typed arrays aligned by position**:

```wolfram
opt[interp_, def_] := <|"Interpreter" -> interp, "Default" -> def|>;  (* see §5 *)

api = APIFunction[
  {"title" -> opt["String", "Untitled"],
   "count" -> opt["Integer", 1],
   (* a list of ints and a parallel list of numbers — DSM "columns" *)
   "ids"     -> opt[DelimitedSequence["Integer", ","], {}],
   "weights" -> opt[DelimitedSequence["Number",  ","], {}],
   (* nested lists: ';' between records, ',' within — two-level DelimitedSequence *)
   "attrNames"  -> opt[DelimitedSequence[DelimitedSequence["String", ","], ";"], {}],
   "attrValues" -> opt[DelimitedSequence[DelimitedSequence["Number", ","], ";"], {}]},
  buildFrom[#] &];
```

A "row-shaped" record `{id, weight}` is reconstructed by `MapThread`/`Transpose` over the
columns — **list ops, not parsing**. Everything arrives already typed (`"101,202"` →
`{101, 202}`).

**Why columns, not an object:** it's the only shape that keeps the whole input
*declaratively typed* in a flat query string. It also reads cleanly in a URL, scales to
large lists, and dodges every encoding pitfall of embedding a serialized document.

## 4. `CompoundElement` will not save you here

It's tempting to want typed *tuples* — `items=101,2.5;102,3.0` parsed into
`{<|"id"->_,"weight"->_|>, …}`. **Wolfram forbids it:**

- `CompoundElement` consumes a **pre-split list of inputs** (designed for multi-field form
  inputs like `x[id]`, `x[weight]`); it raises `Interpreter::shape` on a delimited *string*.
- `DelimitedSequence[CompoundElement[…]]` errors explicitly:
  **`DelimitedSequence::nvldnesting: DelimitedSequence cannot take CompoundElement,
  RepeatingElement and related functions as first argument.`**

So there is **no declarative path to per-position-typed tuples inside one delimited
string.** Use parallel typed arrays (§3). The cost is positional alignment — pay it down
with a guard (§6). (A single `DelimitedSequence[DelimitedSequence["String",","], ";"]`
gives you nested *string* lists, but then per-field typing means `ToExpression` — that's
manual; don't.)

## 5. Optional parameters & defaults

The default syntax is an **Association**, not a list:

```wolfram
"x" -> <|"Interpreter" -> "Integer", "Default" -> 7|>   (* ✅ optional, default 7 *)
"x" -> {"Integer", 7}                                   (* ❌ parsed as an ENUM: "Integer" or "7" *)
```

Use `"Default" -> Missing[]` when you must distinguish *absent* from a legitimate value
(e.g. a real `0`), then gate on `NumberQ`/`MissingQ` in the body. Add a key to the
downstream spec **only when supplied**, so a builder's own `Lookup[…, default]` fallback
still wins:

```wolfram
Join[<|baseSpec|>, If[NumberQ[a["x"]], <|"x" -> a["x"]|>, <||>]]
```

## 6. Guard the positional alignment

Parallel arrays can desync. Validate lengths and fail with a **clean HTTP 400**, not a
`MapThread` stack trace:

```wolfram
If[Length[a["ids"]] =!= Length[a["weights"]], Return[Failure["badLengths", <|"err" -> "…"|>]]];
…
Module[{spec = specFromParams[#]},
  If[FailureQ[spec],
     HTTPResponse[spec["err"], <|"StatusCode" -> 400, "Headers" -> {"Content-Type" -> "text/plain"}|>],
     HTTPResponse[buildBody[spec], <|"StatusCode" -> 200, "Headers" -> {…}|>]]] &
```

## 7. When the response is an artifact, return it directly

Don't wrap a binary file (or a large text/JSON body) in an envelope (`{b64: …}` /
`{result: …}`) that the caller must unwrap. Return the body directly so `curl -o`, a
browser, or a link saves/consumes it as-is:

```wolfram
HTTPResponse[byteArray, <|"StatusCode" -> 200, "Headers" -> {
   "Content-Type" -> "application/octet-stream",
   "Content-Disposition" -> "attachment; filename*=UTF-8''" <> URLEncode[filename]}|>]
```

- An `APIFunction` body that returns an `HTTPResponse` is served verbatim — your route to
  custom status/headers/binary. (For a large *text* body, set the matching `Content-Type`,
  e.g. `text/plain` or `application/json`, and skip the envelope likewise.)
- `filename*=UTF-8''…` (RFC 5987) carries non-ASCII filenames.
- **Sidecar metadata** (warnings, derived summaries, a manifest of related artifacts): put
  it *in the artifact* (a notes/description field; values recomputable from the artifact
  itself) rather than inventing an envelope. Self-describing > wrapped.

## 8. GET, POST, URLs, and encoding

- `APIFunction` reads named params from the **query string** as readily as from a POST
  form — so the endpoint *is* its own link. No POST body needed for a download/render link.
- **The same decomposed params scale to large inputs over POST.** When a payload would
  exceed the query-string ceiling (≈ **8 KB** in practice), send the identical parameters
  as `application/x-www-form-urlencoded` POST fields — the interpreters parse form fields
  exactly the same way. Only the transport changes; no redesign.
- **Build URLs with `URLBuild`**, which percent-encodes values (UTF-8). Non-ASCII (glyphs,
  emoji, accents) then rides as `%XX` — no shell-mangling, and no `\uXXXX` escaping.
  Wolfram Cloud round-trips UTF-8 query params correctly (verify it for your case).
- Mojibake almost always traces to a *different* layer (e.g. a string routed through a file
  interpreter), not the query transport. Isolate before blaming the encoder.
- Choose your sequence delimiters deliberately (`,` and `;` are conventional) and test them
  end-to-end — some characters are special in query-string contexts.

## 9. Separate resolution from construction

Two different operations deserve two endpoints:

- **Resolution** — fuzzy, ranked, *to be judged* (e.g. a free-text query → candidate
  records). Return options + the data needed to choose; never auto-commit.
- **Construction** — deterministic, *resolved inputs → artifact*. Takes only
  already-resolved keys.

Folding a fuzzy lookup into the builder hides a non-deterministic, arbitrary pick inside a
pure function. Keep them apart.

## 10. Verification discipline (this bit up front saves hours)

- **Each `WolframLanguageEvaluator` call is a fresh kernel.** Definitions do **not**
  persist between calls. Put all defs *and* the test in **one cell**, or it silently fails
  with symbols left unevaluated.
- **Local `GenerateHTTPResponse[af, request]` simulation is unreliable** for parameter
  routing (it can drop query params). **Test against the live deployed object** with
  `URLRead`/`URLExecute` — that's the only faithful check. (Network egress works
  server-side, which is where the object runs.)
- Verify the **round trip**: status, headers (e.g. `Content-Disposition`), body magic
  bytes, *and* decode the artifact to confirm structure + that any derived values are what
  you expect.
- You typically can't `CloudDeploy` without auth — implement, ask the owner to redeploy,
  then live-verify. State plainly which checks are "verified live" vs "verified in-kernel,
  awaiting deploy."

## 11. Deterministic IDs for linked artifacts

If the endpoint emits multiple artifacts that reference each other (and you emit one per
call), derive their IDs **deterministically** (e.g. `hash(name + role)` formatted as a
UUID) rather than `CreateUUID[]`. Then an artifact produced in a *later* call still carries
the exact ID the first one references — they link without being generated together.

---

### The one-paragraph version

Take input as **typed, decomposed query parameters** (parallel `DelimitedSequence`
columns, not a serialized blob), because that's the only shape Wolfram parses
**declaratively from a GET query string** — and GET is what links, browsers, and
`curl -o` speak (the same params POST as form fields when the payload is large). Avoid
format-name param types (`"RawJSON"` = file interpreter, 400s on queries) and
`CompoundElement` (can't split strings; can't nest in `DelimitedSequence`). Default
optionals with `<|"Interpreter"->…,"Default"->…|>`, guard positional alignment into clean
400s, return artifacts (binary or large text) as a raw `HTTPResponse` body with the right
`Content-Type`/`Content-Disposition`, keep metadata inside the artifact, split
fuzzy-resolution from deterministic-construction, and **verify against the deployed object
in a single kernel cell** — never the local simulator.
