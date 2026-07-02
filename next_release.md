# ggtaichi — Next Release Brainstorm

Status: planning. No package code changed. This enumerates *everything*
worth considering for v0.2.0 and beyond (features + confirmed bugs),
then triages it. The bugs in §5b were **reproduced** against the
installed v0.1.0 — see the test environment note at the bottom to re-run
them while fixing.

Contents:

1.  Animation · 2. Interactivity · 3. Richer glyph · 4. Scales & color ·
2.  Robustness/testing · **5b. Confirmed bugs** · 6. Coordinates ·
3.  Docs/data/community · Proposed v0.2.0 scope · Open questions · Test
    env.

Current state (v0.1.0, on CRAN):

- `geom_taichi(yin, yang, ...)` — draws one yin/yang glyph per grid
  cell, each fish filled by its own continuous gradient
  (`scale_fill_gradientn`, hardcoded).
- [`theme_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/theme_taichi.md)
  — companion theme.
- `remove_padding(x, y)` — trims panel expansion.
- Datasets: `pitts_tg`, `states_tg`, `pitts_emojis`.
- Encodes exactly **4 dimensions**: x, y, yin value, yang value.
- Fixed vertical S-curve split, 50/50 fish, no eyes/dots, no rotation.
- **No tests.** No interactivity. No animation. Continuous fills only.

Each idea below is tagged with a rough tier:

- **\[P0\]** headline features / things that unblock everything else
- **\[P1\]** strong, in-scope-for-0.2.0 candidates
- **\[P2\]** exploratory / later / “if there’s appetite”

------------------------------------------------------------------------

## 1. Animation (the headline ask)

The taichi is a *cyclical* symbol, so motion is unusually on-brand.
Several distinct flavors, in rough order of effort:

### 1a. Animate over a third variable with `gganimate` \[P1\]

- Today, time (`week`) is forced onto the x-axis, shrinking glyphs.
  Instead let `week` (or any variable) become an **animation frame**, so
  every frame is a clean `category` × `state` grid of large, readable
  taichi.
- Mechanism:
  [`gganimate::transition_states()`](https://gganimate.com/reference/transition_states.html)
  / `transition_time()` driving the underlying `GeomYinFish` /
  `GeomYangFish` layers. Continuous fills mean tweenr can interpolate
  values smoothly between frames.
- **Risk / spike needed:**
  [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)
  returns a *list* of layers including
  [`ggnewscale::new_scale_fill()`](https://eliocamp.github.io/ggnewscale/reference/new_scale.html).
  gganimate’s frame-splitting + ggnewscale’s scale-stacking may not
  compose cleanly. Needs a focused proof-of-concept before promising it.
  If it “just works,” we only need docs; if not, we may need a
  `taichi_animate()` wrapper or a single-scale code path for animation.
- Deliverable: an **animation vignette** + a recipe in the README,
  gganimate in `Suggests`.

### 1b. Spin / rotation animation \[P2\]

- Rotate each glyph about its center over frames — the iconic “turning
  taichi.”
- Hard dependency on the **rotation aesthetic** (see §3a). Build that
  first.
- Could encode a variable as rotation *and* animate the rotation, or
  just use rotation as pure decoration for a title/hero animation.

### 1c. Reveal / grow-in animation \[P2\]

- Fish fill or radius grows from 0 → full as a frame advances
  (`enter_grow()`, `transition_reveal()`). Mostly a docs/recipe item
  once 1a works.

### 1d. Export helpers \[P2\]

- Thin wrappers / documented recipes for `anim_save()` to GIF and MP4,
  plus guidance on frame count, fps, and `coord_fixed()` so glyphs stay
  round in the rendered video.

------------------------------------------------------------------------

## 2. Interactivity

### 2a. `ggiraph` tooltips & hover \[P1\]

- Hovering a glyph shows the exact yin and yang values (and x/y/facet);
  the whole taichi or each fish becomes individually addressable.
- Mechanism: a `geom_taichi_interactive()` (or an `interactive = TRUE`
  switch) that emits ggiraph’s interactive polygon grobs carrying
  `tooltip`, `data_id`, and `onclick`. Per-fish `data_id` lets a hover
  highlight one source.
- ggiraph in `Suggests`. This is the single most-requested kind of
  feature for glyph-heavy plots and pairs perfectly with a dense taichi
  grid where reading exact values by eye is hard.

### 2b. `plotly` support \[P2\]

- Lower priority: `ggplotly()` does not understand custom grobs, so this
  would need a hand-written translation layer. Likely not worth it given
  ggiraph covers the need.

------------------------------------------------------------------------

## 3. Richer glyph — more dimensions, more expression

The taichi has iconic parts we currently throw away. Turning them into
data channels is the most *distinctive* thing this package can do.

### 3a. Rotation aesthetic \[P1\]

- An `angle` / `rotation` argument (constant or mapped) that orients the
  S-curve. Prerequisite for spin animation (§1b) and for encoding a
  directional or temporal variable as orientation.
- Implementation is contained: rotate the unit-fish coordinates in
  `taichi_fish()` before building the grob.

### 3b. Data-driven eyes/dots — a 5th & 6th dimension \[P1, signature feature\]

- v0.1.0 deliberately dropped the dots (“every drop of ink is data”).
  Reframe them: **optional eyes whose size and/or color encode two more
  variables.**
- That turns the glyph into a genuine **6-dimensional** mark (x, y, yin
  fill, yang fill, yin-eye, yang-eye) while staying visually true to a
  real taichi. This is the most “taichi-native” extension we can ship
  and a great headline.
- API sketch: `eyes = TRUE`, `yin_eye = <col>`, `yang_eye = <col>`, with
  size and/or color mappings; off by default to preserve current look.

### 3c. Size aesthetic (radius per cell) \[P2\]

- Let glyph radius shrink/grow with a variable (like a bubble chart),
  encoding magnitude on top of the two fills. Needs care so neighbors
  don’t overlap.

### 3d. Shifting the split to encode a ratio \[P2, experimental\]

- Move the S-curve off-center so the *area* of each fish encodes a
  proportion (a 5th channel). Visually striking but breaks the iconic
  50/50 silhouette — ship behind an explicit flag and document the
  readability trade-off.

### 3e. Border / stroke styling \[P2\]

- Expose `colour`, `linewidth`, `linetype` cleanly per fish (partly
  works via `default_aes` today) so users can outline glyphs or draw the
  classic black taichi border.

------------------------------------------------------------------------

## 4. Scales & color (biggest *correctness* gap)

### 4a. Categorical / discrete fills \[P0-ish for completeness\]

- Right now `scale_fill_gradientn()` is hardwired, so **a categorical
  yin/yang source cannot be drawn at all.** Many natural two-source
  comparisons are discrete (e.g., winning method per cell).
- Options:
  - auto-detect numeric vs. factor and pick `gradientn`
    vs. `manual`/`viridis_d`;
  - a `yin_scale` / `yang_scale` argument accepting a scale object;
  - decouple the geom from the scale entirely (most flexible, see §4d).

### 4b. Diverging & shared scales \[P1\]

- First-class support for diverging palettes (values centered at 0) and
  a **single shared legend** when the two sources are directly
  comparable (same units). Today you can fake shared `limits` via `...`,
  but it’s clumsy and there are still two legends.

### 4c. Convenience scale constructors \[P2\]

- `scale_taichi_yin_*()` / `scale_taichi_yang_*()` helpers (viridis,
  brewer, diverging) for a tidy, discoverable API instead of raw color
  vectors.

### 4d. Decouple geom from scales \[P2, design decision\]

- A lower-level
  [`geom_yin_fish()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_yin_fish.md)
  /
  [`geom_yang_fish()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_yin_fish.md)
  exported pair (they exist internally) would let power users bring any
  scale, faceting, or new_scale arrangement. Keep
  [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)
  as the friendly all-in-one wrapper.
- Trade-off: more surface area to document and support.

### 4e. Better legend control \[P2\]

- Arguments / guidance for legend order, orientation, and merging; the
  current theme rotates legend text 90° which not everyone wants.

------------------------------------------------------------------------

## 5. Robustness, testing, API hygiene \[P0\]

This is unglamorous but should gate the release — there are currently
**zero tests**.

- **testthat** suite: argument validation, the `taichi_fish()` geometry
  math, setup-data behavior, duplicate-cell handling, NA in one/both
  fish.
- **vdiffr** visual-regression snapshots so glyph rendering can’t
  silently regress (especially important once we add rotation/eyes).
- Input validation with clear
  [`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html)
  messages (e.g., missing `yin`/`yang`, non-existent columns, multiple
  values per cell).
- Define and document **NA handling** — what a fish looks like when its
  source is missing (`na.value`, or skip the fish).
- [`remove_padding()`](https://pursuitofdatascience.github.io/ggtaichi/reference/remove_padding.md)
  polish: it accepts only `"c"`/`"d"`; consider `TRUE`/ `FALSE` or
  auto-detecting scale type from the built plot.
- Performance: `draw_taichi()` builds grobs in an `lapply`; for large
  grids a vectorized `polygonGrob` (one grob, `id`-separated polygons)
  would cut object churn and speed up rendering/animation frames.

------------------------------------------------------------------------

## 5b. Confirmed bugs & defects (found by testing v0.1.0)

These were reproduced by installing v0.1.0 and exercising it (R 4.3.2
with ggplot2 4.0.3, plus geometry/unit checks). The geom **does** render
correctly on ggplot2 4.0.x and the fish geometry is provably exact (see
note at the end), but the items below are real and should be fixed.

### BUG-1 — `...` never reaches the layers; only the fill scales \[P0\]

- [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)’s
  `...` is forwarded **only** to the two `scale_fill_gradientn()` calls.
  Passing any layer/geom parameter throws:
  - `geom_taichi(..., width = 0.8)` →
    `Error: unused argument (width = 0.8)`
  - `geom_taichi(..., na.rm = TRUE)` → `unused argument`
  - `geom_taichi(..., alpha = 0.5)` → `unused argument`
- Consequences: users **cannot** set cell `width`/`height`, `alpha`,
  `na.rm`, or `show.legend`, and cannot suppress one of the two legends.
- Worse, the *same* `...` is applied to **both** fish scales, so you
  cannot give the yin and yang scales different options (e.g. different
  `limits`/`na.value`) — `limits=` is forced to be shared whether you
  want it or not.
- Fix direction: separate geom params from scale params (e.g. dedicated
  `yin_args`/`yang_args` lists, or explicit `width`/`height`/`alpha`/
  `show.legend` arguments), and document precisely what `...` targets.

### BUG-2 — uses the deprecated `size` aesthetic instead of `linewidth` \[P0\]

- The geom’s outline width is driven by `size` (`default_aes` has
  `size = 0.1`; `draw_taichi()` computes `lwd = coords$size * .pt`).
  Since ggplot2 3.4.0 the outline-width aesthetic for non-point geoms is
  **`linewidth`**.
- Verified on ggplot2 4.0.3: `... linewidth = 2` →
  `Warning: Ignoring unknown parameters: linewidth`, and
  `aes(linewidth = ...)` → `Ignoring unknown aesthetics: linewidth`.
  Only the legacy `size` is honored, contrary to every modern ggplot2
  geom.
- Fix: rename to `linewidth` in `default_aes` and `draw_taichi()` (keep
  a `size` fallback/deprecation path for back-compat). Tie into §3e.

### BUG-3 — missing `yin`/`yang` silently produces a degenerate plot \[P0\]

- `geom_taichi(yang = google)` (no `yin`) **does not error**. It builds
  a plot whose yin fish falls back to the default `grey20`, with an
  **empty legend title** (`""`). Confirmed via `ggplot_build()`: layer-1
  fill is `grey20`, yin scale `name` is the empty string.
- This is a silent-wrong-output trap. Fix: validate that `yin` and
  `yang` are supplied (and refer to existing columns) and
  [`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html) with
  a clear message. Folds into the validation work in §5.

### BUG-4 — categorical / character fill sources hard-error \[P0\]

- (Cross-ref §4a; recording the exact failure here.) A factor or
  character `yin`/`yang` raises
  `Error: Discrete value supplied to a continuous scale` because
  `scale_fill_gradientn()` is hardwired. No graceful message, no
  fallback. Fix is the discrete-scale support in §4a.

### Non-bugs confirmed OK (so we don’t “fix” them by mistake)

- **Fish geometry is exact.** A 20k-point Monte-Carlo test inside the
  unit circle found **100%** of points in exactly one fish — 0% overlap,
  0% gap — with each fish covering ~0.50 of the area, and both polygons
  close cleanly (first vertex = last vertex). The S-curve construction
  is correct.
- **Both legends render** (4 scales: two `fill`, plus x/y) — the
  two-source legend works as intended.
- Renders cleanly under `coord_fixed`, `coord_flip`, `coord_polar`,
  facets,
  [`remove_padding()`](https://pursuitofdatascience.github.io/ggtaichi/reference/remove_padding.md),
  NA values, duplicated cells, and single-value axes on ggplot2 4.0.3 —
  i.e. it is forward-compatible with the current ggplot2.

### Minor / housekeeping

- [`geom_yin_fish()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_yin_fish.md)
  /
  [`geom_yang_fish()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_yin_fish.md)
  are **not exported** (confirmed via `getNamespaceExports`), so the §4d
  decoupling genuinely needs new exports.
- Running examples leaves a stray `Rplots.pdf` in the working dir when a
  device isn’t open — worth a note in dev docs / `.Rbuildignore`
  hygiene.

------------------------------------------------------------------------

## 6. Coordinates & layout \[P2\]

- **Maps:** a taichi per region (`coord_sf` / centroid placement) to
  compare two sources geographically — a very compelling demo, possibly
  its own vignette.
- **Polar / radial** layouts for cyclical data.
- Verify/define behavior under `coord_flip()` and free-scale facets.

------------------------------------------------------------------------

## 7. Documentation, data, community \[P1\]

- **Animation vignette** and **interactivity vignette** (tie to §1, §2).
- A **gallery** page on the pkgdown site showcasing palettes, eyes,
  facets, maps.
- **Fresh, non-COVID example dataset.** The bundled data is COVID-era
  and dating; a fun, evergreen two-source comparison (sports, elections,
  A/B test, before/after) would broaden appeal and make demos timeless.
- A “when *not* to use taichi” / readability guidance section (dense
  grids, colorblind safety) — sets honest expectations.
- Colorblind-safe default palettes (or a documented viridis default);
  audit the current red/grey defaults for accessibility.
- Promote lifecycle badge from `experimental` toward `stable` once the
  API settles and tests land.

------------------------------------------------------------------------

## Proposed v0.2.0 scope (a coherent, shippable cut)

A focused release that is both *useful* and *distinctive*:

0.  **\[P0\] Fix the confirmed bugs (§5b)** — `...` routing (BUG-1),
    `linewidth` aesthetic (BUG-2), missing-arg validation (BUG-3),
    graceful handling of categorical fills (BUG-4). These are
    correctness issues in the shipped version and should lead the
    release.
1.  **\[P0\] Test + validation foundation** (testthat + vdiffr, input
    checks, NA semantics). Non-negotiable groundwork — and would have
    caught §5b.
2.  **\[P0/P1\] Categorical fill support** — close the “can’t plot a
    factor” gap.
3.  **\[P1\] Data-driven eyes** (§3b) — the signature, on-brand new
    capability.
4.  **\[P1\] Rotation aesthetic** (§3a) — small, and unlocks spin
    animation.
5.  **\[P1\] gganimate recipe + animation vignette** (§1a) — the
    headline ask, *contingent on the ggnewscale/gganimate spike
    succeeding.*

Strong stretch / fast-follow (v0.3.0):

- ggiraph interactivity (§2a)
- diverging + shared scales (§4b)
- map demo / `coord_sf` (§6)
- fresh dataset + gallery (§7)

## Things to settle before coding

- **Spike first:** does `gganimate` survive the `ggnewscale` layer
  stack? This decides whether animation is “write docs” or “build a
  wrapper.”
- **API direction:** keep
  [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)
  as a closed all-in-one, or expose the lower-level fish geoms + scale
  decoupling (§4d)? This shapes how 4a/4b/eyes are surfaced.
- **CRAN deps:** gganimate, ggiraph, vdiffr all belong in `Suggests`
  (guarded with `requireNamespace`), keeping the hard dependency
  footprint small.
- **Back-compat:** default look must not change — eyes/rotation off by
  default.

------------------------------------------------------------------------

## Test environment (for reproducing §5b)

The shipped package has no test suite, so the bugs above were verified
by installing v0.1.0 into a scratch library and exercising it. To
reproduce:

- R 4.3.2; ggplot2 4.0.3, ggnewscale 0.5.2, rlang, scales (installed to
  a temp [`.libPaths()`](https://rdrr.io/r/base/libPaths.html) entry,
  since `ggnewscale` was absent on the host).
- `R CMD INSTALL ggtaichi` into that lib, then drive plots with
  [`ggplot2::ggplot_build()`](https://ggplot2.tidyverse.org/reference/ggplot_build.html)
  / `ggplotGrob()` and
  [`withCallingHandlers()`](https://rdrr.io/r/base/conditions.html) to
  capture warnings, rather than rendering to a device.
- Geometry check: sample ~20k points inside the unit circle and ray-cast
  them against `ggtaichi:::taichi_fish(..., "yin")` and `"yang"` to
  confirm exact, gap-free, overlap-free 50/50 tiling.

First task of v0.2.0 (per scope item 1) is to fold these probes into a
real `testthat` + `vdiffr` suite so they run in CI instead of by hand.

------------------------------------------------------------------------

# Addendum — post-v0.2.0 status & v0.3.0 planning (added 2026-07-01)

Everything above is kept verbatim as the historical plan. This addendum
records what v0.2.0 actually shipped and lays out the v0.3.0 scope.

## What v0.2.0 shipped (all four bugs + scope items 0–5)

- BUG-1..4 fixed as planned; `...` now targets both fill scales, geom
  params are explicit arguments, and `size` is soft-deprecated into
  `linewidth` (both as a parameter and, via `rename_size`, as an
  inherited aesthetic).
- Rotation (`angle`, constant or column) and **data-driven eyes** (size
  and colour per fish, constant or column; mapped sizes rescaled to
  \[0.05, 0.3\], values in (0, 0.5\] taken as literal proportions, `NA`
  suppresses the eye).
- Discrete fill detection via tidy evaluation (handles `factor(week)`
  and friends), `yin_scale` / `yang_scale` overrides, string column
  names, and clear `+`-time errors for missing columns.
- Discovered & fixed along the way (not in the original list):
  - the taichi **eyes were swapped** into the opposite fish’s head, and
    the yang polygon over-painted the yin eye — each eye now sits in its
    own fish’s bulb (yin top, yang bottom);
  - the default discrete palette sampled `gray100` first, drawing
    invisible white fish — default discrete palettes now skip the palest
    ramp end;
  - vdiffr snapshots must be generated against the same ggplot2 minor
    version CI installs (a 3.5.2-era snapshot failed under 4.0.3) — see
    CI notes below.
- testthat + vdiffr suite (geometry Monte-Carlo, routing, eyes,
  rotation, scale selection, rendering-level grob checks) runs green on
  all 5 CI platforms, macOS/Windows included.
- The gganimate spike **succeeded**: recipes verified frame-by-frame
  against gganimate 1.0.11 / ggplot2 4.0.3 — no wrapper needed;
  animation vignette shipped.

## Proposed v0.3.0 scope

1.  **\[P1\] Shared & diverging scales (§4b).**
    - `shared_limits = TRUE`: compute the union range of `yin` and
      `yang` at `+` time (both continuous) and apply it to both fill
      scales, so equal values read as equal ink.
    - `shared_legend = TRUE`: for directly comparable sources — implies
      shared limits, paints both fish with the *yin* palette, and shows
      a single legend (the yang guide is dropped). Legend title falls
      back to “yin / yang” names unless `yin_name` is given.
    - Diverging data: document the symmetric-limits recipe
      (`limits = c(-m, m)` with a diverging `yin_colors`/`yang_colors`).
2.  **\[P1\] Export the fish geoms (§4d).**
    [`geom_yin_fish()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_yin_fish.md)
    /
    [`geom_yang_fish()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_yin_fish.md)
    become documented exports for power users who want their own scale /
    ggnewscale arrangements;
    [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)
    remains the friendly wrapper.
3.  **\[P1\] Vectorized rendering (§5 performance).** Replace the
    per-cell `lapply` + per-cell viewport with a draw-time
    `makeContent()` gTree that emits one id-batched `polygonGrob` (and
    one `circleGrob` for eyes) per layer. Keeps glyphs round under
    resize (radius resolved at draw time), cuts grob count from O(cells)
    to O(1) per layer — matters for large grids and animation frames.
    Rendering must stay visually identical (guarded by the vdiffr
    suite + a pixel-level before/after comparison).
4.  **\[P1\] Fresh evergreen dataset (§7).** `cafes_tg`: a small,
    clearly synthetic (seeded) two-source dataset — weekly espresso
    vs. matcha orders across city neighbourhoods — so demos stop leaning
    on COVID-era data.
5.  **\[P1\] Gallery (§7).** A pkgdown-only article
    (vignettes/articles/) showing palettes, eyes, rotation, categorical
    fills, shared scales, and the new dataset side by side.
6.  **\[P2\]
    [`remove_padding()`](https://pursuitofdatascience.github.io/ggtaichi/reference/remove_padding.md)
    auto mode (§5 polish).** Calling it with no arguments now
    auto-detects each axis’s scale type from the plot data at `+` time;
    the explicit `"c"` / `"d"` API stays for overrides.
7.  **\[P2\] Console [`print()`](https://rdrr.io/r/base/print.html)
    method** for the object
    [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)
    returns, so typing it bare no longer dumps raw list internals.
8.  **\[P1 docs\] “When (not) to use taichi” + accessibility.** Honest
    readability guidance (dense grids, luminance-vs-luminance
    comparisons, colorblind-safe palettes via
    `yin_scale = scale_fill_viridis_*`) in the intro vignette.

## Deferred to v0.4+ (sharpened, not dropped)

- **ggiraph interactivity (§2a).** Implementation sketch after the 0.3
  rendering rework: the vectorized `makeContent()` path makes it natural
  to emit `ggiraph::interactive_polygon_grob()` with per-cell `tooltip`
  / `data_id` when an `interactive` flag is set; test via girafe
  htmlwidget snapshots. Deferred so 0.3 stays dependency-light and
  CI-green.
- **Maps / `coord_sf` demo (§6).** Works in principle (bbox-based
  cells); needs an sf-heavy vignette and system deps on CI — pair it
  with the ggiraph release.
- **Eye-size legend (open question).** Mapped eye sizes currently have
  no guide; decide between a custom legend grob or documenting them as a
  annotation channel only.
- **Lifecycle badge.** Keep `experimental` through 0.3.0 (API grew
  again); revisit `stable` for 0.4.0 once the exported-geom API has
  survived a cycle.

## CI / testing notes (learned the hard way, keep in mind)

- vdiffr snapshots are coupled to the **ggplot2 minor version** on CRAN
  (CI installs current CRAN). Regenerate snapshots whenever CRAN’s
  ggplot2 minor bumps; generate them on a stack matching CI (ggplot2
  4.0.x as of now). They *are* stable across OSes (macOS/Windows/Linux
  all pass).
- The animations vignette evaluates its chunks whenever gganimate is
  installed (as on CI) — any chunk must attach its own packages in setup
  and keep `animate()` calls commented (no gifski on CI).
- `transition_states()` needs at least one positive length; `(0, 0)`
  errors.
