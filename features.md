# ggtaichi — Future Features

*A research-grounded feature catalogue for the releases after 0.2.0. This is a
**design and literature document**, not a changelog and not a commitment. §2
surveys the glyph-visualization and graphical-perception literature and locates
the taichi glyph inside it; §3–§13 turn that into concrete, API-level proposals;
§14 prioritises. CRAN availability of every suggested dependency was verified
against the live CRAN index (July 2026). No package code is changed by this
document.*

**Relationship to `next_release.md`.** That file is the 0.2.0 planning ledger:
the original brainstorm, the four confirmed 0.1.0 bugs, the two implemented
waves, and a short "deferred to 0.3+" list (ggiraph interactivity, `coord_sf`
maps, the eye-size legend, the lifecycle badge). This file is the idea space
behind and beyond it. Items already named there are marked **[ledger]**, and for
those the new content is the *evidence* for why they matter and a sharper design.

> **The framing that organises everything below.** ggtaichi's core encoding is
> **two colour ramps compared within one mark**. The perception literature is
> unambiguous that colour/shading is the *least* accurate channel for reading
> values (Cleveland & McGill 1984 rank it last of six), and equally clear that
> glyph grids are excellent for *pattern and similarity* judgements and poor for
> *value extraction* (Fuchs et al. 2017, over 64 user studies). That is not a
> flaw to hide — it is a **specification**. The taichi is a gestalt mark. So the
> highest-value features are the ones that (a) make the pattern channel as good
> as it can be (palette pairing §7, seriation §5, placement §6), and (b) supply
> a *second, accurate* route to the values when a reader needs them
> (interactivity §4, explicit difference encoding §3, labels and binned scales
> §5). Adding more colour channels without addressing this would make the
> package worse, not better.

---

## Contents

1. [Where the package stands today](#1-where-the-package-stands-today)
2. [The survey: where the taichi glyph sits in the literature](#2-the-survey)
3. [Theme A — Explicit encoding: the missing third comparison mode](#3-theme-a--explicit-encoding)
4. [Theme B — Interactivity as the value-reading channel](#4-theme-b--interactivity-as-the-value-reading-channel)
5. [Theme C — Making the grid readable: labels, bins, seriation](#5-theme-c--making-the-grid-readable)
6. [Theme D — Placement beyond the regular grid](#6-theme-d--placement-beyond-the-regular-grid)
7. [Theme E — Palette pairing is a correctness problem](#7-theme-e--palette-pairing-is-a-correctness-problem)
8. [Theme F — More glyph channels, ranked by how well they work](#8-theme-f--more-glyph-channels)
9. [Theme G — A statistical layer](#9-theme-g--a-statistical-layer)
10. [Theme H — Uncertainty and missingness](#10-theme-h--uncertainty-and-missingness)
11. [Theme I — Animation, export and rendering](#11-theme-i--animation-export-and-rendering)
12. [Theme J — ggplot2 4.x currency and extension hygiene](#12-theme-j--ggplot2-4x-currency-and-extension-hygiene)
13. [Theme K — Documentation, positioning, datasets](#13-theme-k--documentation-positioning-datasets)
14. [Prioritisation](#14-prioritisation)
15. [Open questions and decisions needed](#15-open-questions-and-decisions-needed)
16. [References](#16-references)

---

## 1. Where the package stands today

0.2.0 (built, not yet released; CRAN has 0.1.0) exports seven objects:
`geom_taichi()`, `geom_yin_fish()`, `geom_yang_fish()`, the `GeomYinFish` /
`GeomYangFish` ggproto objects, `theme_taichi()` and `remove_padding()`. Four
bundled datasets: `pitts_tg`, `states_tg`, `pitts_emojis`, `cafes_tg`.

The glyph currently encodes up to **six** dimensions — x, y, yin fill, yang
fill, yin eye, yang eye — plus `angle` as a seventh (constant or mapped).
0.2.0 added data-driven eyes, rotation, discrete-fill auto-detection,
`yin_scale`/`yang_scale` overrides, `shared_limits`/`shared_legend`, exported
fish geoms, `remove_padding()` auto mode, a `print()` method, a vectorised
`makeContent()` renderer (~15× faster on a 1200-cell grid, pixel-identical), a
testthat + vdiffr suite, and an animation vignette verified against
gganimate 1.0.11.

**Verified properties worth protecting.** The fish geometry is provably exact
(Monte-Carlo tiling: 100% of points in exactly one fish, ~0.50 area each, no
overlap, no gap). Rendering is stable across macOS/Windows/Linux, and works
under `coord_fixed`, `coord_flip`, `coord_polar`, facets, NA values and
duplicated cells. Any new channel must keep the tiling exact and the vdiffr
suite green.

**Deferred by the ledger:** ggiraph interactivity, `coord_sf`/map placement, the
eye-size legend question, and promoting the lifecycle badge off `experimental`.

---

## 2. The survey

### 2.1 What kind of design is a taichi grid?

**Gleicher et al. (2011), *Visual comparison for information visualization*,
gives the vocabulary.** Every comparison design is assembled from three
building blocks: **juxtaposition** (side by side), **superposition** (on top of
each other), and **explicit encoding** (compute the relationship and show
*that*). A taichi grid is a **superposition** design — the two sources occupy
one mark in one position, which is what makes spatial patterns co-registered and
directly comparable.

The taxonomy also names superposition's weakness precisely: it supports "are
these similar?" and "which is larger here?" but not "how much larger?" —
that requires explicit encoding. **The package currently offers no explicit
encoding at all**, and that is the single clearest structural gap (→ §3).

### 2.2 What does the glyph literature say a glyph should do?

**Borgo et al. (2013), *Glyph-based Visualization* (Eurographics STAR)** is the
canonical reference: it links glyph design to semiotics, collects design
guidelines, and surveys applications. Its central claim is directly relevant —
glyph-based designs are strong precisely because multivariate patterns become
perceptible *in a spatial context*, which is exactly the taichi grid's premise.

**Fuchs et al. (2017), *A Systematic Review of Experimental Studies on Data
Glyphs* (IEEE TVCG)**, synthesises 64 user studies, and four of its findings
bear directly on this package:

1. **The simple star glyph without contours performs best** across several
   criteria — simplicity wins. This is an argument *against* piling on channels
   and *for* making the existing ones excellent.
2. **Contours help shape-similarity judgements but distract from
   data-similarity judgements.** ggtaichi draws an outline (`colour`,
   `linewidth`); the default `colour = NA` is therefore the *right* default for
   value comparison, and the classic black taichi border should stay opt-in and
   be documented as a stylistic, not analytic, choice.
3. **Colour comparisons need no common axis; position/length comparisons require
   mental rotation** across a grid. This is a genuinely *favourable* result for
   a colour-filled glyph grid: unlike star or polyline glyphs, the taichi's two
   fills can be compared cell to cell without realigning axes.
4. **Performance drops significantly as the number of glyphs increases** — every
   scalability study found this. So dense-grid guidance is not a nicety; and
   reordering the grid so structure is visible at a glance (→ §5) is a
   first-class feature, not polish.

**Ward (2002), *A Taxonomy of Glyph Placement Strategies*** splits placement
into **data-driven** (positions come from the data) and **structure-driven**
(positions come from relationships/structure), plus post-processing distortions
to resolve overlap. ggtaichi supports exactly one strategy — a regular
categorical grid. The taxonomy is a ready-made roadmap (→ §6).

**Wickham, Hofmann, Wickham & Cook (2012), *Glyph-maps*** is the closest
methodological ancestor for the map case: one glyph per spatial location, with a
transformation that embeds each glyph's own coordinate system into map space.
That paper (and the `cubble` package's glyph-map workflow) is the model to follow
for a `coord_sf` taichi map, rather than inventing placement rules.

### 2.3 What does perception research say about the fill channel?

**Cleveland & McGill (1984)** ordered elementary perceptual tasks by accuracy:

| Rank | Task | ggtaichi channel |
|---|---|---|
| 1 | Position along a common scale | x, y (the grid) |
| 2 | Position along non-aligned scales | — |
| 3 | Length, direction, angle | `angle` (rotation) |
| 4 | **Area** | **split ratio (§8) — not yet implemented** |
| 5 | Volume, curvature | — |
| 6 | **Shading, colour saturation** | **yin fill, yang fill — the core encoding** |

Two consequences, and they are the backbone of this document:

- **The package's primary channel is the least accurate one.** Everything that
  gives a reader a second, more accurate route to the numbers is high value:
  tooltips (§4), labels and *binned* scales (§5), and an explicit difference
  channel (§3).
- **The deferred "shift the split to encode a ratio" idea (ledger §3d) is
  better-founded than it looked.** Area ranks *above* colour. Encoding a
  proportion by moving the S-curve would be **more** accurate than encoding it
  by fill — at the cost of the iconic 50/50 silhouette. That is a real
  trade-off with evidence on both sides, not a gimmick (→ §8).

### 2.4 Where ggtaichi sits among CRAN packages

Closest neighbours, all live on CRAN: **`gggibbous` 0.1.1** (moon charts —
a two-part glyph for proportions), **`scatterpie` 0.2.6** (pie glyphs at
coordinates), `ggstar` 1.0.6, `ggforce` 0.5.0, `ggpattern` 1.3.1,
`biscale`-style bivariate approaches, `GGally` 2.4.0 (glyph/matrix displays),
`treemapify`, `ggalluvial`.

**The honest differentiation is worth stating in the docs.** Moon charts and pie
glyphs encode **part-to-whole**: one number, split. The taichi encodes **two
independent measurements that need not sum to anything** — that is a genuinely
different job, and it is why `shared_limits`/`shared_legend` exist. Nothing else
on CRAN does it. Conversely, when the two numbers *are* parts of a whole,
`gggibbous` is the better tool and the docs should say so.

Infrastructure available: `ggiraph` 0.9.6, `gganimate` 1.0.11 + `gifski` +
`av` 0.9.6 (MP4), `vdiffr` 1.0.9, `colorspace` 2.1-3 and `farver` 2.1.2 (for
§7's palette work), `sf` 1.1-2 + `ggspatial` (for §6), `S7` 0.2.2,
`marquee` 1.2.1. **ggplot2 on CRAN is 4.0.3** — see §12.

---

## 3. Theme A — Explicit encoding

**Problem.** Superposition answers "which is bigger?" and not "by how much?"
(§2.1). A reader looking at a 12 × 8 taichi grid can see *where* yang dominates
but cannot quantify it, and there is currently no way to ask.

**Features.**

```r
# a third, computed channel alongside the two sources
geom_taichi(yin = espresso, yang = matcha,
            explicit = c("none", "difference", "ratio", "log_ratio", "z"),
            explicit_channel = c("eye_size", "angle", "border", "radius"))

# or the standalone companion mark: one fish per cell, signed
geom_taichi_diff(yin, yang, method = "difference", palette = "diverging")

# the numbers, tidily, for the reader who needs a table
taichi_summary(data, yin, yang)
#> per cell: yin, yang, difference, ratio, dominant source, rank
```

**Design notes.**

- **`explicit_channel = "eye_size"` is the elegant option** because the eyes
  already exist as a data channel and are visually subordinate: the fills carry
  the two sources, the eye size carries the gap. A big eye means a big
  difference, which reads as "look here" — semantically apt.
- **`explicit_channel = "angle"` is the most *accurate* option** (direction/angle
  is rank 3 vs colour's rank 6), and rotation already exists. Encoding
  yin − yang as tilt would make the difference readable to a precision the fills
  can never reach. It costs the glyph's upright orientation, so it belongs behind
  an explicit choice — but it is the highest-accuracy option available.
- **`geom_taichi_diff()` is the honest escape hatch**: sometimes the right chart
  for "how much bigger" is a diverging heatmap, and a package that offers one
  next to its signature glyph is more trustworthy than one that insists on the
  glyph. Cheap to build (it is a `geom_tile()` with the package's palette
  conventions) and it makes the `explicit` argument's semantics concrete.
- `ratio`/`log_ratio` need zero/negative handling defined up front — return `NA`
  with a warning, never `Inf`.

**Deps** none. **Effort** M. **Risk** low. **Value** high — this is the
structural gap in the design, named by the comparison taxonomy.

---

## 4. Theme B — Interactivity as the value-reading channel  **[ledger, deferred to 0.3]**

**Problem.** The ledger correctly identifies ggiraph as "the single
most-requested kind of feature for glyph-heavy plots". §2.3 explains *why* it is
more than a convenience: interactivity is how a colour-encoded chart supplies
accurate values without abandoning its encoding.

**Features.**

```r
geom_taichi(..., interactive = TRUE,
            tooltip = NULL,        # default: both values + difference + cell id
            data_id = NULL,        # per-cell by default; per-fish available
            onclick = NULL)

girafe(ggobj = p, options = list(
  opts_hover(css = "stroke:black;"),
  opts_hover_key(...)              # hover one SOURCE, highlight all its fish
))
```

**Design notes.**

- **The vectorised `makeContent()` renderer built in 0.2.0 is what makes this
  natural** — as the ledger anticipated. The id-batched `polygonGrob` maps
  directly onto `ggiraph::interactive_polygon_grob()` with vectors of `tooltip`
  and `data_id`, so this is a substitution inside one function rather than a
  second rendering path.
- **Per-fish `data_id` enables the feature that matters most**: hovering the
  *yin* fish in any cell highlights the yin fish in **every** cell, turning a
  superposition display temporarily into a single-source display. That directly
  addresses superposition's weakness (§2.1) — the reader can decompose the
  comparison interactively instead of mentally.
- **Default tooltip content should include the difference**, not just the two
  values — the quantity §3 exists to expose.
- Testing: girafe output is an htmlwidget, so test the *grob* level (that
  interactive grobs are emitted with the right ids and tooltip vectors) rather
  than snapshotting HTML, which is brittle. Keep the static path byte-identical
  and guarded by the existing vdiffr snapshots.
- `plotly` remains not worth it (custom grobs; `ggplotly()` cannot translate
  them) — the ledger's judgement stands. Say so in the docs so users stop asking.

**Deps** `Suggests: ggiraph`. **Effort** M. **Risk** low.

---

## 5. Theme C — Making the grid readable

**Problem.** Every scalability study in Fuchs et al. found performance degrades
as glyph count rises (§2.2), and the package's own docs now admit dense grids
are hard. Three interventions are available, and one of them is unusually
powerful.

**Features.**

```r
# 1. seriation — reorder rows/columns so structure becomes visible
taichi_seriate(data, x, y, yin, yang,
               method = c("hclust", "pca", "mean", "difference", "none"))
geom_taichi(..., seriate = "hclust")     # or reorder the factors yourself

# 2. binned fills — match to legend bins instead of interpolating luminance
geom_taichi(..., yin_scale = scale_fill_fermenter(n.breaks = 5), ...)
scale_taichi_yin_binned(...); scale_taichi_yang_binned(...)

# 3. on-glyph values, for small grids
geom_taichi(..., label = c("none", "both", "yin", "yang", "difference"),
            label_size = 2.5, label_colour = "auto")
```

**Design notes.**

- **Seriation is the highest-value idea in this document after §3 and §4.** A
  taichi grid on alphabetically-ordered categories hides its own structure;
  reordering rows and columns by hierarchical clustering on the two value
  vectors makes blocks of similar cells adjacent, which is precisely the
  pattern-detection task the glyph is *good* at (§2.3). The matrix-reordering
  literature has established this for heatmaps for decades, and it transfers
  directly. It is also cheap: `stats::hclust` + factor releveling, no new
  dependency. Offer it both as a standalone data verb (composable, testable) and
  as a convenience argument.
- **Binned fills are the cheapest accuracy win available.** Reading a continuous
  luminance ramp is a rank-6 task; matching a swatch to one of five discrete
  bins is far closer to a categorical lookup. ggplot2 already ships binned
  scales; the package needs to (a) make sure they compose with the discrete/
  continuous auto-detection added in 0.2.0, (b) provide the `scale_taichi_*`
  constructors the ledger listed as §4c, and (c) *recommend* binning for large
  grids in the docs.
- **`label_colour = "auto"` needs real contrast logic**, not a fixed colour:
  compute the fill's relative luminance and choose black or white per cell
  (`farver` makes this trivial). A hard-coded label colour will be invisible on
  half a diverging palette.
- Labels should be honest about space: refuse (with a warning) above a cell count
  where text cannot fit, rather than drawing overlapping mush. `ggfittext` is on
  CRAN if automatic shrink-to-fit is wanted.

**Deps** none required (`Suggests: ggfittext` optional). **Effort** M
(seriation), S (binned scale constructors), M (labels). **Risk** low.

---

## 6. Theme D — Placement beyond the regular grid  **[ledger §6, deferred]**

**Problem.** Ward's taxonomy (§2.2) describes a space of placement strategies;
ggtaichi implements one point in it. The map case in particular is, as the
ledger says, "a very compelling demo".

**Features.**

```r
# map placement — one taichi per region, at its centroid
geom_taichi(..., placement = "map")          # inside coord_sf()
taichi_map(sf_data, yin, yang, size = 0.6)   # convenience wrapper

# continuous (data-driven) placement with overlap resolution
geom_taichi(..., placement = "scatter", collision = c("none", "jitter",
                                                      "repel", "grid_snap"))

# structure-driven placement
taichi_layout(data, method = c("pca", "mds", "umap"), yin, yang)
#> returns x/y positions from the data's own structure, for geom_taichi()
```

**Design notes.**

- **Follow the glyph-maps method rather than improvising.** Wickham et al. (2012)
  solve exactly this: embed each glyph's local coordinate system into map space
  with an explicit width/height, so glyph shape stays constant while position
  comes from geography. The 0.2.0 renderer already resolves radius at draw time
  against the physical panel, which is the same idea and means the hard part is
  done.
- **The map demo has an obvious cross-package partner.** `countryatlas` produces
  ISO-reconciled country geometry and centroids; a two-source country comparison
  (e.g. two data providers' estimates of the same indicator) as a taichi map is
  a compelling joint vignette, and neither package needs to depend on the other —
  just documented recipes.
- **Overlap is the real problem in continuous placement**, and Ward's
  post-processing distortions are the framework: jitter, repulsion, or snapping
  to a coarse grid (the last preserves readability best and is closest to what
  the package already does well). Default to `"grid_snap"` with a message saying
  what happened, and never silently overplot.
- `coord_sf` needs system dependencies on CI, so gate it (`Suggests: sf`), keep
  the vignette `eval`-guarded, and add a tiny synthetic sf fixture for tests.

**Deps** `Suggests: sf`, optionally `ggrepel`. **Effort** M (map), M (scatter +
collision), S (`taichi_layout`). **Risk** medium — CI system deps and the
overlap semantics.

---

## 7. Theme E — Palette pairing is a correctness problem

**Problem, and it is a real one.** The default palettes are a grey ramp
(`gray100` → `gray0`) for yin and a red ramp (`#FED7D8` → `#C20824`) for yang.
Those two ramps do not span the same luminance range, so **equal values do not
produce equal visual weight** — one fish will systematically appear to dominate.
For a design whose entire purpose is comparing two sources fairly, palette
pairing is not aesthetics; it is the chart's validity. `shared_limits` fixed the
*numeric* half of this problem in 0.2.0; the *perceptual* half is untouched.

**Features.**

```r
taichi_palette_pair(n = 5, hues = c(250, 20), luminance = c(30, 90),
                    chroma = 60)
#> two ramps, distinct in hue, matched in luminance and chroma trajectory

taichi_check_palette(yin_colors, yang_colors)
#> per-step luminance and chroma of each ramp, the max luminance mismatch,
#> CVD simulations (deutan/protan/tritan), and a pass/fail verdict

geom_taichi(..., palette = c("balanced", "viridis_pair", "brewer_pair",
                             "diverging", "print_safe"))
scale_taichi_yin_viridis_c(); scale_taichi_yang_viridis_c(); ...   # §4c
```

**Design notes.**

- **`colorspace` is the right tool and it is on CRAN.** Sequential HCL ramps with
  a shared luminance trajectory and different hues are exactly the construction
  needed, and `colorspace` also provides CVD simulation for the check function.
  `farver` handles the per-colour luminance arithmetic.
- **`taichi_check_palette()` should be runnable on the *current defaults* and
  the result documented honestly.** If grey-vs-red is unbalanced, say so in the
  help page, offer `palette = "balanced"`, and consider changing the default at
  the next major version with a loud NEWS note. Do not silently change it —
  0.2.0 already made "the default look must not change" a commitment.
- **`shared_legend = TRUE` deserves a re-read in this light.** It paints both
  fish with `yin_colors` so identical values read as identical ink — which is the
  *perceptually correct* answer for directly comparable sources, and arguably
  should be recommended more strongly than it currently is. The cost is that the
  two sources are then distinguished only by position within the glyph (top bulb
  vs bottom bulb), which is worth stating explicitly.
- A **`print_safe`** pair (works in greyscale) matters for journal figures, where
  a two-hue design collapses. Pair with `ggpattern` texture fills (§8) as the
  belt-and-braces option.
- This theme is also the answer to the ledger's "audit the current red/grey
  defaults for accessibility" note — with a function instead of a manual check.

**Deps** `Suggests: colorspace`; `farver` (already a ggplot2 dependency).
**Effort** M. **Risk** low technically; the only sensitive part is whether to
change defaults.

---

## 8. Theme F — More glyph channels

Ordered by the perceptual evidence (§2.3), not by novelty.

```r
# 1. split ratio -> area (rank 4: BETTER than fill)          [ledger §3d]
geom_taichi(..., split = proportion, split_range = c(0.25, 0.75))

# 2. radius -> size (rank 4-ish, familiar from bubble charts) [ledger §3c]
geom_taichi(..., radius = total, radius_range = c(0.3, 1))

# 3. eye-size legend — resolve the open question              [ledger, open]
guide_taichi_eye(...)      # or: document eyes as annotation-only

# 4. texture/pattern fill for print and CVD safety
geom_taichi(..., yin_pattern = "stripe", yang_pattern = "crosshatch")

# 5. decorative, not data: the classic border and bagua trim
geom_taichi(..., colour = "black", linewidth = 0.3)   # already possible
annotate_bagua(...)                                    # decorative only
```

**Design notes.**

- **The split-ratio channel is more defensible than the ledger assumed.** Area
  outranks colour in Cleveland & McGill, so moving the S-curve to encode a
  proportion gives a *more accurate* reading than a third fill would. Ship it
  behind an explicit `split =` argument, default off, with `split_range`
  clamped away from degenerate slivers, and document the trade-off plainly: you
  gain accuracy and lose the iconic 50/50 silhouette. **Non-negotiable
  constraint:** the two fish must still tile the circle exactly — extend the
  Monte-Carlo tiling test to a grid of split values before this ships.
- **`radius` is the easy one** but needs care about neighbour collision (§6's
  problem in miniature) and about the classic area-vs-diameter scaling error —
  scale by area, i.e. radius ∝ √value, and say so.
- **The eye legend should probably be resolved by *not* building a custom
  guide.** Mapped eye size is a low-precision channel by construction; the
  honest resolution is to document eyes as an *annotation/attention* channel
  rather than a measured one, and point users who need a legend at `radius`
  or `split` instead. A custom guide grob is real work for a channel we should
  not encourage precise reading from. (Decision, not a foregone conclusion —
  see §15.)
- **Patterns are the accessibility backstop.** `ggpattern` composes with
  polygon grobs; a striped yin and crosshatched yang survive greyscale printing
  and total colour-blindness. Cost: pattern rendering is slow and device-
  dependent, so gate it and warn on large grids.
- **Resist adding a seventh and eighth colour channel.** Fuchs et al.'s
  "simple star glyph without contours performs best" is the warning: past a
  point, more channels reduce the glyph's legibility rather than its
  information. The package's channel budget should be spent on *accurate*
  channels (area, angle, position) and on §3–§5's readability work.

**Deps** `Suggests: ggpattern`. **Effort** M (`split`, with geometry tests),
S (`radius`), S (patterns). **Risk** medium for `split` — it touches the one
piece of the package with a proof behind it.

---

## 9. Theme G — A statistical layer

**Problem.** `geom_taichi()` needs one row per cell. Real data arrives long and
unaggregated, so every user's first step is a `group_by()` + `summarise()` they
have to get right, and duplicate cells are currently handled by the geom rather
than by an explicit statistical choice.

**Features.**

```r
stat_taichi(mapping, data, fun = mean, na.rm = FALSE)
#> aggregates yin and yang per (x, y) cell before drawing, like stat_summary_2d

geom_taichi(..., stat = "taichi", fun = sum)
taichi_check(data, x, y, yin, yang)
#> pre-flight diagnostics: duplicate cells, missing combinations, extreme
#> skew, cell count vs readability, NA counts per fish
```

**Design notes.**

- A `stat_taichi()` makes the aggregation *visible in the plot spec*, which is
  both more tidyverse-idiomatic and less error-prone than silent handling. It
  also gives a natural home for `fun.min`/`fun.max` if uncertainty (§10) is
  later encoded.
- **`taichi_check()` is a small function with outsized value** for a geom this
  particular about its input: it turns four separate confusing failure modes
  (duplicate cells, missing combinations, one-sided NAs, too many cells) into one
  readable report. It is also the natural place to warn "142 cells with labels
  will not be legible" (§5) and "your two ramps are luminance-mismatched" (§7).
- Continue the 0.2.0 practice of erroring at `+` time with the offending column
  name — that was the fix for BUG-3 and it is the right ergonomic.

**Deps** none. **Effort** M. **Risk** low.

---

## 10. Theme H — Uncertainty and missingness

**Problem.** 0.2.0 defined NA semantics (a mapped eye size of `NA` suppresses
the eye; NA fills use `na.value`) and documented "NA visibility" in the
vignette. What is missing is a way to say "this value is uncertain" as opposed
to "this value is missing", and the two-source design makes that pointed: a cell
where yin is well-measured and yang is a rough estimate should not look like a
cell where both are solid.

**Features.**

```r
geom_taichi(..., yin_uncertainty = se_a, yang_uncertainty = se_b,
            uncertainty_channel = c("alpha", "pattern", "eye_size", "vsup"))

geom_taichi(..., na_style = c("na_value", "hatched", "hollow", "omit"))
#> "hollow"  = outline only, unmistakably "no data"
#> "omit"    = draw the other fish alone, so a half-glyph reads as half-known
```

**Design notes.**

- **`na_style = "omit"` is the semantically perfect option for this glyph** and
  no other package can do it: drawing only the fish whose source has data makes
  a half-present glyph *mean* "one source missing here". That is a rare case
  where the mark's structure carries the metadata for free.
- **`"vsup"` is the ambitious option**: Value-Suppressing Uncertainty Palettes
  (Correll, Moritz & Heer, CHI 2018) narrow the colour range as uncertainty
  rises, and a crowdsourced study found readers weight uncertainty more heavily
  with them than with ordinary bivariate encodings. Applying a VSUP *per fish*
  would be a genuinely novel visualization contribution. It is also the hardest
  item here (a 2-D palette plus a trapezoidal legend, twice), so it belongs late.
- Start with `alpha` and `pattern`, which are cheap and already plumbed, and
  document the caveat that alpha interacts with the luminance comparison §7 is
  trying to protect — an uncertain-but-high value can end up looking like a
  certain-but-low one. That interaction is a reason to prefer `pattern` or
  `eye_size` as the default uncertainty channel.

**Deps** `Suggests: ggpattern`. **Effort** M (`na_style`, alpha/pattern),
L (VSUP). **Risk** medium for VSUP.

---

## 11. Theme I — Animation, export and rendering

The ledger's gganimate spike succeeded and the animation vignette shipped, so
this theme is mostly small additions:

- **MP4 export** alongside GIF. `av` 0.9.6 is on CRAN and gives H.264 without
  gifski's palette limits — better for talks and journal supplements. Document
  the `coord_fixed()` + fps + frame-count recipe so glyphs stay round.
- **Spin animation as a documented recipe**, now that `angle` exists (ledger
  §1b): rotate as pure decoration for a title/hero animation, and separately as
  a data channel over frames.
- **`transition_reveal()` / grow-in** recipes (ledger §1c) — docs only.
- **Frame-count guidance**: the vectorised renderer makes frames cheap
  (0.24 s for 1200 cells with eyes), so animations that were impractical in
  0.1.0 now are not; the vignette should say so with numbers.
- **Rendering**: `ragg` for raster output and `svglite` for vector are the
  right recommendations for a glyph-dense plot; add a one-paragraph note. Also
  keep the known trap documented: **vdiffr snapshots are coupled to the ggplot2
  minor version on CRAN**, so regenerate them when CRAN's ggplot2 bumps.
- Keep the animations vignette's discipline: chunks attach their own packages,
  `animate()` calls stay commented (no gifski on CI), and
  `transition_states()` needs at least one positive length.

**Deps** `Suggests: av`. **Effort** S. **Risk** low.

---

## 12. Theme J — ggplot2 4.x currency and extension hygiene

**This is the most time-sensitive section.** ggplot2 4.0.0 (Sept 2025; CRAN is
now at **4.0.3**) was a large extension-facing release, and the package should
be deliberate about it rather than merely passing checks.

1. **S3 → S7.** ggplot2 4.0.0 replaced many S3 classes with **S7**. ggtaichi
   defines `ggplot_add.ggtaichi_plot()`, `ggplot_add.taichi_padding()`,
   `makeContent.taichi_cells()` and `print.ggtaichi_plot()` — S3 methods on
   generics whose objects may now be S7. These currently work (the package's
   tests pass on 4.0.3), but the right move is an explicit test asserting that
   `ggplot_add()` dispatch and the `+` chain behave on the current ggplot2, so a
   future S7 tightening is caught by us rather than by CRAN. Watch the extension
   guidance for a recommended S7-native pattern.
2. **`theme(geom = element_geom(ink, paper, accent))`.** ggplot2 4.0 lets themes
   set geom defaults, with `ink` (foreground), `paper` (background) and `accent`
   propagating automatically — and `from_theme()` lets a geom's `default_aes`
   read them. `GeomYinFish`/`GeomYangFish` hard-code `fill = "grey20"`,
   `colour = NA`. **Consequence: ggtaichi does not currently follow a dark
   theme** — on a dark `paper`, a `grey20` fallback fish and NA outlines are
   close to invisible. Migrating the fallbacks to `from_theme(ink)` /
   `from_theme(paper)` is a small change that makes the package a good citizen
   of modern themes, and it interacts well with §7's palette work.
3. **`draw_key`.** Both fish geoms use `draw_key_rect`. A **`draw_key_taichi()`**
   that draws a tiny yin-yang in the legend would be a small, delightful,
   on-brand touch — and it is exactly the kind of thing an extension package
   should do. (Consider a half-fish key for the individual fish geoms.)
4. **Guides.** The guide system was rewritten in 3.5/4.0; if the eye legend
   (§8) is ever built, build it against the new guide API, not the old one.
5. **`linewidth`.** 0.2.0 completed the `size` → `linewidth` migration with a
   soft-deprecation path. Schedule the removal of the `size` fallback for a
   later major version and note it in NEWS now, so the deprecation actually ends.
6. **Version floor.** `Imports: ggplot2 (>= 3.4.0)` was right for `linewidth`.
   If `from_theme()` is adopted (item 2), the floor must rise to 4.0.0 — a real
   cost/benefit decision, since it drops users on older ggplot2. Alternative:
   detect at build time and degrade. Prefer raising the floor once, cleanly,
   at a major version.
7. **Testing infrastructure.** The suite is good; add (a) a vdiffr case per new
   channel, (b) the extended Monte-Carlo tiling test parameterised over `split`
   and `angle` (§8), (c) `expect_snapshot()` for `print.ggtaichi_plot()` and for
   error messages, (d) a `covr` badge, (e) `spelling` + `urlchecker` as
   scheduled CI jobs.
8. **`inst/CITATION`** — worth adding now that the design has an evidence base
   to cite alongside it.

**Effort** S–M. **Risk** low, and it retires a growing compatibility debt.

---

## 13. Theme K — Documentation, positioning, datasets

- **A `vignette("design")` grounded in the literature.** The ledger's
  "when (not) to use taichi" section shipped as prose; this would give it
  citations and turn it into the package's intellectual centre: what a
  superposition glyph is for (Gleicher), what glyph grids are good and bad at
  (Fuchs, Borgo), why the fill channel is imprecise and what to do about it
  (Cleveland & McGill → §3, §4, §5), and how to place glyphs (Ward, Wickham).
  Very few ggplot2 extension packages document *why* their mark works; doing so
  is cheap and differentiating.
- **An honest comparison table** — taichi vs `gggibbous` moon charts vs
  `scatterpie` vs bivariate choropleth vs small multiples vs a diverging heatmap
  — with a one-line "use this instead when…" for each. Specifically: when the
  two numbers are parts of one whole, `gggibbous`; when precision matters more
  than pattern, a heatmap or dot plot; when there are more than two sources,
  small multiples.
- **Gallery growth**: the pkgdown gallery exists; add seriated vs unseriated
  side by side (§5), the palette-pair check output (§7), a map (§6), and an
  interactive example (§4). Each new feature ships with a gallery entry.
- **Datasets**: `cafes_tg` covers the shared-units case. Two gaps worth filling:
  (a) an **sf-shaped** dataset for the map demo (a handful of regions with two
  measures), and (b) a **larger grid** (~40 × 30) so the seriation and
  performance stories have something to show. Both clearly synthetic and seeded,
  with builders in `data-raw/`, per the `cafes_tg` precedent.
- **Lifecycle badge** (ledger, open): the API grew again in 0.2.0. Keep
  `experimental` through 0.3.0; the honest gate for `stable` is one release
  cycle with **no new arguments** to `geom_taichi()` — which, given §3–§8, is
  not the next one. Say that in the docs rather than leaving the badge
  unexplained.
- **Argument-count pressure.** `geom_taichi()` already takes ~20 arguments, and
  this document proposes a dozen more. That is a real design smell. Consider a
  grouping mechanism before the next wave: `taichi_eyes(...)`,
  `taichi_scales(...)`, `taichi_uncertainty(...)` option-objects passed as single
  arguments (the pattern `theme()`/`element_*()` uses), keeping the flat
  arguments as a deprecated-but-working path. Decide this **before** §8, not
  after.

**Effort** M. **Risk** low.

---

## 14. Prioritisation

**Wave 1 — close the structural gap and modernise (0.3.0).**
1. **§4 ggiraph interactivity** — the deferred headline; the value-reading
   channel the encoding needs; the renderer is already shaped for it.
2. **§3 explicit encoding** (`explicit =` + `geom_taichi_diff()` +
   `taichi_summary()`) — the missing third comparison mode.
3. **§12 ggplot2 4.x work** — `from_theme(ink/paper)` so dark themes work,
   `draw_key_taichi()`, S7-dispatch tests, `inst/CITATION`, covr.
4. **§7 `taichi_check_palette()` + `taichi_palette_pair()` + the
   `scale_taichi_*` constructors** — palette pairing is chart validity, and the
   check function can be run on the current defaults immediately.
5. **§5 binned-scale support and recommendation** — the cheapest accuracy win.

**Wave 2 — readability and placement (0.4.0).**
`taichi_seriate()` and labels with contrast-aware colour (§5); `stat_taichi()`
and `taichi_check()` (§9); `na_style` incl. `"omit"` (§10); the map placement
path + `countryatlas` recipe (§6); the `vignette("design")` and the comparison
table (§13); MP4 export (§11).

**Wave 3 — new channels, carefully (0.5.0).**
Settle the argument-grouping question (§13) **first**, then `split` (with the
extended tiling proof) and `radius` (§8); pattern fills; scatter placement with
collision resolution (§6); resolve the eye-legend question (§8/§15).

**Wave 4 — ambitious and optional.**
Per-fish VSUP uncertainty palettes (§10); `taichi_layout()` structure-driven
placement (§6); the stability cycle that earns a `stable` badge (§13).

**Explicitly not planned.** `plotly` support (custom grobs make it impractical;
ggiraph covers the need); a third or fourth *fill* channel (Fuchs et al.'s
simplicity result argues against it); reimplementing animation (gganimate
composes already); a rendering engine of our own; more than two data sources in
one glyph (that is what small multiples are for, and the docs should say so).

---

## 15. Open questions and decisions needed

1. **Argument grouping, and when.** ~20 arguments now, ~32 if §3–§8 all ship
   flat. Option-objects (`taichi_eyes()`, `taichi_scales()`, …) are the
   tidyverse-idiomatic fix, but they are a breaking-ish change and should land
   *before* the next channel wave, not after. **This is the most consequential
   API decision in the document.**
2. **Do the default palettes change?** If `taichi_check_palette()` shows
   grey-vs-red is luminance-mismatched (§7), the defaults are producing subtly
   unfair comparisons. Changing them breaks every existing figure. Proposal:
   measure, document honestly, ship `palette = "balanced"`, and flip the default
   only at 1.0.0 with a prominent NEWS entry.
3. **Raise the ggplot2 floor to 4.0.0?** Required for `from_theme()` (§12).
   Cleaner than runtime detection, but excludes older installs. Leaning: yes, at
   the same major version as the palette change.
4. **Eye-size legend: build a guide, or reframe the channel?** (§8.) Leaning
   towards documenting eyes as an annotation/attention channel and pointing
   precision-seekers at `radius`/`split` — but this is the ledger's open
   question and deserves a real decision.
5. **Does `split` compromise the brand?** The 50/50 silhouette is the design's
   identity; area is a more accurate channel than colour. Leaning: ship it
   off-by-default with the trade-off documented, and require the extended tiling
   proof before merge.
6. **Should `shared_legend = TRUE` be recommended more strongly?** It is the
   perceptually correct choice for comparable sources (§7) but makes the two
   sources distinguishable only by position within the glyph. Worth a decision
   and a docs sentence either way.
7. **Is a taichi map its own package/vignette, or a `countryatlas` recipe?**
   (§6.) Leaning: a vignette here plus a documented recipe, no dependency in
   either direction.
8. **What earns `stable`?** Proposal: one full release with no new arguments to
   `geom_taichi()`, the argument-grouping question settled, and the palette
   defaults final.

---

## 16. References

**Comparison and glyph design**

- Gleicher M, Albers D, Walker R, Jusufi I, Hansen CD, Roberts JC (2011).
  Visual comparison for information visualization. *Information Visualization*
  10(4): 289–309. <https://doi.org/10.1177/1473871611416549> ·
  <https://graphics.cs.wisc.edu/Papers/2011/GAWJHR11/paper.pdf>
- Gleicher M (2018). Considerations for Visualizing Comparison.
  *IEEE TVCG*. <https://graphics.cs.wisc.edu/Papers/2018/Gle18/viscomp.pdf>
- Borgo R, Kehrer J, Chung DHS, Maguire E, Laramee RS, Hauser H, Ward M,
  Chen M (2013). Glyph-based Visualization: Foundations, Design Guidelines,
  Techniques and Applications. *Eurographics State of the Art Reports*: 39–63.
  <https://www.cg.tuwien.ac.at/research/publications/2013/borgo-2013-gly/borgo-2013-gly-report.pdf>
- Fuchs J, Isenberg P, Bezerianos A, Keim D (2017). A Systematic Review of
  Experimental Studies on Data Glyphs. *IEEE TVCG* 23(7): 1863–1879.
  <https://doi.org/10.1109/TVCG.2016.2549018> ·
  <https://inria.hal.science/hal-01378429/document>
- Ward MO (2002). A taxonomy of glyph placement strategies for
  multidimensional data visualization. *Information Visualization* 1(3–4):
  194–210. <https://davis.wpi.edu/xmdv/docs/jinfovis02_glyphpos.pdf>
- Chernoff H (1973). The Use of Faces to Represent Points in k-Dimensional
  Space Graphically. *JASA* 68(342): 361–368.

**Graphical perception**

- Cleveland WS, McGill R (1984). Graphical Perception: Theory, Experimentation,
  and Application to the Development of Graphical Methods. *JASA* 79(387):
  531–554. <http://euclid.psych.yorku.ca/www/psy6135/papers/ClevelandMcGill1984.pdf>
- Correll M, Moritz D, Heer J (2018). Value-Suppressing Uncertainty Palettes.
  *CHI 2018*. <https://doi.org/10.1145/3173574.3174216> ·
  <https://idl.uw.edu/papers/uncertainty-palettes>
- Harrower M, Brewer CA (2003). ColorBrewer.org: An Online Tool for Selecting
  Colour Schemes for Maps. *The Cartographic Journal* 40(1): 27–37.

**Glyphs in space**

- Wickham H, Hofmann H, Wickham C, Cook D (2012). Glyph-maps for visually
  exploring temporal patterns in climate data and models. *Environmetrics*
  23(5): 382–393. <https://doi.org/10.1002/env.2152> ·
  <https://vita.had.co.nz/papers/glyph-maps.html>
- McNabb L, Laramee RS (2019). Multivariate Maps — A Glyph-Placement Algorithm
  to Support Multivariate Geospatial Visualization. *Information* 10(10): 302.
  <https://www.mdpi.com/2078-2489/10/10/302>
- Beecham R et al. (2021). On the Use of 'Glyphmaps' for Analysing the Scale
  and Temporal Spread of COVID-19 Reported Cases. *IJGI* 10(4): 213.
  <https://www.mdpi.com/2220-9964/10/4/213>
- `cubble`'s glyph-map workflow (R implementation of the glyph-map idea):
  <https://huizezhang-sherry.github.io/cubble/articles/cb4glyph.html>

**R ecosystem and tooling**

- ggplot2 4.0.0 release notes (S7 migration; `theme(geom = element_geom())`
  with `ink`/`paper`/`accent`; `from_theme()`):
  <https://tidyverse.org/blog/2025/09/ggplot2-4-0-0/> ·
  <https://ggplot2.tidyverse.org/news/index.html>
- `gggibbous` (moon charts — the part-to-whole neighbour):
  <https://cran.r-project.org/package=gggibbous>
- `scatterpie`: <https://cran.r-project.org/package=scatterpie>
- `ggiraph`: <https://cran.r-project.org/package=ggiraph>
- `gganimate`: <https://cran.r-project.org/package=gganimate> · `av` (MP4):
  <https://cran.r-project.org/package=av>
- `colorspace` (HCL palette construction + CVD simulation):
  <https://cran.r-project.org/package=colorspace>
- `ggpattern`: <https://cran.r-project.org/package=ggpattern>
- `ggfittext`: <https://cran.r-project.org/package=ggfittext>
- `vdiffr`: <https://cran.r-project.org/package=vdiffr>
