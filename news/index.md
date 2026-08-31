# Changelog

## ggtaichi 0.3.0

This release closes the structural gap in the design and brings the
package up to date with ggplot2 4.x. A taichi grid is a *superposition*
comparison: it shows two sources in one position, which is what makes
spatial patterns directly comparable, and which is also why it can say
“which is bigger here?” but not “by how much?”. 0.3.0 answers the second
question three ways — as a third channel of the glyph, as a companion
heatmap, and as a table — and adds the two things a colour-encoded chart
needs to be trustworthy: an interactive route to the exact values, and a
way to check that its two colour ramps are a fair pair.

Nothing about the default appearance changes.

### Explicit encoding: the relationship, not just the two levels

- **`explicit =` computes a third channel** from the two sources —
  `"difference"`, `"ratio"`, `"log_ratio"` or `"z"` — and
  **`explicit_channel =`** decides where it goes:
  - `"eye_size"` (the default) puts the gap in the eyes, which already
    exist and are visually subordinate to the fills. Cells where the two
    sources agree exactly get no eye, so a plain glyph *means*
    agreement.
  - `"angle"` puts it in the glyph’s tilt. Direction is read far more
    accurately than shading, so this is the most precise of the four:
    upright means the sources agree, and the lean shows which way and
    how far.
  - `"border"` puts it in the outline width, and `"radius"` in the
    glyph’s size, scaled by area (radius proportional to the square root
    of the statistic) rather than by diameter. `explicit_range =` sets
    the output range. The statistic is rescaled across the whole layer,
    so facets stay comparable, and driving the same channel by hand as
    well is an error rather than a silent override.
- **[`geom_taichi_diff()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi_diff.md)**
  draws the same statistic as a diverging heatmap, with limits symmetric
  about “the two sources agree”. Sometimes the right chart for “how much
  bigger?” is not a glyph, and the package would rather say so than
  insist.
- **[`taichi_summary()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_summary.md)**
  returns the numbers per cell — both values, the difference, the ratio,
  the log ratio, the standardised difference, which source dominates,
  and the cell’s rank by the size of the gap.
- A ratio of a zero or negative value is `NA` with a warning, never
  `Inf`, in all three.

### Interactivity

- **`interactive = TRUE`** makes the fish and their eyes
  [ggiraph](https://davidgohel.github.io/ggiraph/) grobs, so
  [`ggiraph::girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.html)
  turns the plot into a widget. This matters more than convenience: fill
  is the least accurate channel there is, and hovering is how a
  colour-encoded chart supplies exact values without abandoning its
  encoding. The default tooltip carries both values, their difference
  and the cell’s coordinates.
- **`data_id_by =`** decides what a hover highlights: `"cell"` (both
  fish of one glyph, the default), `"fish"`, or `"source"` — which
  lights up every fish of one source at once, temporarily turning the
  superposition display into a single-source one. That is the one thing
  a static superposition cannot do.
- `tooltip`, `data_id` and `onclick` take a data column to override any
  of it.
- The static path is untouched: with `interactive = FALSE` the package
  does not load ggiraph at all, and the interactive geometry is
  identical to the static geometry. ggiraph is a Suggests-only
  dependency.
- plotly remains unsupported and will stay that way: `ggplotly()` cannot
  translate the custom grobs this package draws. The help page now says
  so.

### Palettes are a correctness problem, and now they are measurable

- **[`taichi_check_palette()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_check_palette.md)**
  measures a pair of ramps: per-step luminance and chroma, the largest
  luminance mismatch, whether each ramp is monotone, and — with
  **colorspace** installed — how far apart the two stay under
  deuteranopia, protanopia and tritanopia, against a normal-vision
  baseline. Run on the package’s own defaults it returns **FAIL**: the
  grey yin ramp spans the full luminance range while the red yang ramp
  stops around L\* 41, a mismatch of about 41 units, so equal values
  have never read as equal ink. That is documented rather than quietly
  fixed — see below.
- **[`taichi_palette_pair()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_palette_pair.md)**
  builds a pair that differs only in hue, sharing one luminance and one
  chroma trajectory, so step for step the two fish carry the same visual
  weight.
- **`palette =`** on
  [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)
  selects a ready-made pair: `"balanced"` (the recommended one),
  `"diverging"`, `"viridis_pair"`, `"brewer_pair"`, `"print_safe"` (a
  grey ramp and a hued ramp on the same luminance trajectory, so the
  figure survives greyscale printing), or `"default"`.
  **[`taichi_palette()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_palette.md)**
  returns any of them for inspection.
- **The defaults do not change.** Every existing figure is unaffected.
  The honest fix is a different default, and that is a 1.0.0 decision
  with a prominent note, not something to slip into a minor release.

### Fill scales, including binned ones

- A family of ready fill scales:
  [`scale_taichi_yin_c()`](https://pursuitofdatascience.github.io/ggtaichi/reference/scale_taichi.md)
  /
  [`scale_taichi_yang_c()`](https://pursuitofdatascience.github.io/ggtaichi/reference/scale_taichi.md),
  [`scale_taichi_yin_d()`](https://pursuitofdatascience.github.io/ggtaichi/reference/scale_taichi.md)
  /
  [`scale_taichi_yang_d()`](https://pursuitofdatascience.github.io/ggtaichi/reference/scale_taichi.md),
  [`scale_taichi_yin_binned()`](https://pursuitofdatascience.github.io/ggtaichi/reference/scale_taichi.md)
  /
  [`scale_taichi_yang_binned()`](https://pursuitofdatascience.github.io/ggtaichi/reference/scale_taichi.md),
  and
  [`scale_taichi_yin_viridis_c()`](https://pursuitofdatascience.github.io/ggtaichi/reference/scale_taichi.md)
  / `_d()` with their yang counterparts. Pass them to `yin_scale` /
  `yang_scale`, or use them directly with the fish geoms.
- **Binning is the cheapest accuracy win available on a dense grid**,
  and the documentation now says so: matching a patch to one of five
  labelled bins is much closer to a categorical lookup than reading a
  position on a continuous luminance ramp.
- **`shared_limits` now composes with a supplied scale.** Previously the
  limits ggtaichi computed were dropped as soon as anyone brought their
  own scale, so `shared_limits = TRUE` silently did nothing next to a
  binned or viridis scale. They are now pushed into it (a scale that
  sets its own limits still wins), which is what makes binning both fish
  against one set of breaks work. `shared_legend` likewise drops the
  duplicate yang guide from a supplied scale.

### ggplot2 4.x currency

- **The geoms follow the theme.** ggplot2 4.0 lets a theme set geom
  defaults through `theme(geom = element_geom(ink, paper, accent))`;
  ggtaichi’s fallbacks were hard-coded, so on a dark theme the fallback
  fish was nearly invisible and the two eyes were the wrong way round.
  Fill, outline colour, linewidth, linetype and both eye colours now
  read from the theme, resolving to exactly the previous values on any
  light theme. The eye-colour arguments default to `NULL`, meaning “ask
  the theme”. The ggplot2 floor stays at 3.4.0: the theme-aware defaults
  are installed at load time when the installed ggplot2 supports them,
  and the literal fallbacks are used otherwise. Raising the floor to
  4.0.0 is a 1.0.0 decision.
- **[`draw_key_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/draw_key_taichi.md)**:
  legend keys are now small taichi symbols with the layer’s own fish
  filled, rather than plain rectangles — and they grow eyes when the
  layer has them. `key_glyph = "rect"` restores the old keys, and
  `key_glyph` is a new argument of
  [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md),
  [`geom_yin_fish()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_yin_fish.md)
  and
  [`geom_yang_fish()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_yin_fish.md).
  Keys only appear for discrete fills; a continuous fill still gets a
  colourbar.
- **`inst/CITATION`**, so `citation("ggtaichi")` gives a proper entry.
- New tests pin the things ggplot2’s S7 migration could quietly break:
  [`ggplot_add()`](https://ggplot2.tidyverse.org/reference/update_ggplot.html)
  dispatch, the `+` chain, and the theme-aware defaults resolving to the
  historical appearance. The suite moves to testthat edition 3, adds
  `expect_snapshot()` coverage of every print method and error message,
  and adds a vdiffr case per new channel.
- CI gains a coverage job and a weekly, non-blocking spelling and URL
  check.

### New aesthetics on the fish geoms

[`geom_yin_fish()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_yin_fish.md)
and
[`geom_yang_fish()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_yin_fish.md)
additionally understand `radius` (a proportion of the cell’s own radius,
so `0.5` draws a half-size glyph in the same cell), `border` (a per-cell
outline width in mm, overriding `linewidth`), and `tooltip` / `data_id`
/ `onclick`. Both gain `interactive` and `key_glyph` arguments.

### Bug fixes

- **gganimate transitions collapsed to a single frame.** Every animation
  this package has ever been able to produce was static. gganimate
  tracks which rows belong to which frame by encoding the frame into the
  `group` column, as a `"<id>"` suffix; the geom’s `setup_data()` reset
  `group` to `seq_len(nrow(data))` and threw that away, so
  [`transition_states()`](https://gganimate.com/reference/transition_states.html),
  [`transition_manual()`](https://gganimate.com/reference/transition_manual.html)
  and the rest all rendered one frame. The rewrite was dead code from
  the package’s first commit — nothing in the draw path reads `group`,
  since each panel is batched into one polygon that numbers its own
  vertices — and removing it changes no static output (every vdiffr
  snapshot is unchanged). It went unnoticed because
  [`vignette("animations")`](https://pursuitofdatascience.github.io/ggtaichi/articles/animations.md)
  builds the `gganim` object but leaves every
  [`animate()`](https://gganimate.com/reference/animate.html) call
  commented out for CI, so the frames were never rendered. There is now
  a test that renders frames with
  [`gganimate::file_renderer()`](https://gganimate.com/reference/renderers.html),
  which needs no gifski and no system libraries, and asserts the count.
- **The yin eye vanished on a theme with no background.**
  [`theme_void()`](https://ggplot2.tidyverse.org/reference/ggtheme.html),
  and any theme built with `rect = element_blank()`, leaves the theme’s
  `paper` fully transparent, so the new theme-aware default painted the
  yin eye `#00000000`. A fully transparent `paper` now falls back to
  white (and a transparent `ink` to black), which also stops the
  fallback fill being mixed towards transparency instead of towards the
  page.

### Deprecations and notes

- The `size` argument of
  [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md),
  soft-deprecated in favour of `linewidth` since 0.2.0, will be
  **removed in 1.0.0**. It still works, and still warns.
- [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)
  now takes around thirty arguments, which is a design smell the roadmap
  has flagged. Grouping them into option objects (`taichi_eyes()`,
  `taichi_scales()`, …) is intended to land *before* the next wave of
  glyph channels, not after.
- The lifecycle badge stays `experimental`. The gate for `stable` is one
  release cycle with no new arguments to
  [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md),
  which this is emphatically not.

## ggtaichi 0.2.0

CRAN release: 2026-08-24

### New features

- **Data-driven eyes** (`eyes = TRUE`): draw the classic taichi dots,
  each centred in its own fish’s head (yin in the top bulb, yang in the
  bottom bulb). `yin_eye_size` / `yang_eye_size` and `yin_eye_colour` /
  `yang_eye_colour` accept either a constant or an unquoted data column,
  so a single glyph can now encode up to **six** dimensions (x, y, two
  fills, two eyes)
  ([\#3](https://github.com/PursuitOfDataScience/ggtaichi/issues/3)b).
- **Rotation** (`angle`): rotate each glyph by a constant number of
  degrees or by a data column, encoding a directional or temporal
  variable as orientation, and unlocking spin animations
  ([\#3](https://github.com/PursuitOfDataScience/ggtaichi/issues/3)a).
- **Categorical fill support**:
  [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)
  inspects the plot data at `+` time and auto-selects
  [`scale_fill_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html)
  for discrete (factor / character / logical) `yin` / `yang` values —
  including computed expressions such as `factor(week)` — and
  [`scale_fill_gradientn()`](https://ggplot2.tidyverse.org/reference/scale_gradient.html)
  for continuous ones. With the default color vectors, discrete
  categories sample the ramp evenly while skipping its palest end, so no
  category is invisible on a white panel. Custom scales (objects or
  constructors) can be supplied via `yin_scale` / `yang_scale`
  ([\#4](https://github.com/PursuitOfDataScience/ggtaichi/issues/4)a,
  BUG-4).
- **Shared scales** for directly comparable sources
  ([\#4](https://github.com/PursuitOfDataScience/ggtaichi/issues/4)b):
  - `shared_limits = TRUE` gives both auto-built fill scales common
    limits — the union range of the two sources (or the union of levels
    when both are discrete) — so equal values read as equal ink.
    Explicit `limits` passed through `...` still win, and mixing a
    discrete with a continuous source warns and ignores the flag.
  - `shared_legend = TRUE` treats the sources as one measure: it implies
    shared limits, paints both fish with `yin_colors`, drops the
    duplicate yang guide, and titles the single legend “`yin` / `yang`”
    unless `yin_name` is supplied.
- **The fish geoms are exported**
  ([\#4](https://github.com/PursuitOfDataScience/ggtaichi/issues/4)d):
  [`geom_yin_fish()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_yin_fish.md)
  and
  [`geom_yang_fish()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_yin_fish.md)
  are now documented exports (with the `GeomYinFish` / `GeomYangFish`
  ggproto objects available for extension packages), for users who want
  a single fish or full manual control over scale stacking.
- **[`remove_padding()`](https://pursuitofdatascience.github.io/ggtaichi/reference/remove_padding.md)
  auto mode**: called with no arguments it now detects each axis’s scale
  type from the plot it is added to; the explicit `"c"` / `"d"`
  arguments remain as overrides.
- **New dataset `cafes_tg`**: a small, clearly synthetic (seeded)
  espresso vs. matcha dataset whose two columns share units — an
  evergreen demo for the shared-scale features and a break from the
  COVID-era examples. The generating script ships in `data-raw/`.
- `yin` and `yang` also accept strings naming a column
  (`yin = "Twitter"`), which previously produced a meaningless constant
  fill.
- [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)
  now returns an object with a friendly
  [`print()`](https://rdrr.io/r/base/print.html) method instead of
  dumping raw list internals at the console.
- **Animation vignette**:
  [`vignette("animations")`](https://pursuitofdatascience.github.io/ggtaichi/articles/animations.md)
  documents how
  [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)
  composes with gganimate
  ([`transition_states()`](https://gganimate.com/reference/transition_states.html),
  spin animations via `angle`, export recipes) — verified frame-by-frame
  against gganimate 1.0.11. gganimate is a Suggests-only dependency.

### Performance

- **Vectorized rendering**: each layer now draws all of its cells as one
  id-batched polygon (plus one batched circle grob for the eyes),
  resolved against the physical panel size at draw time via
  `makeContent()`. Glyphs stay perfectly round under resize, and large
  grids render an order of magnitude faster than the per-cell grob
  building used in 0.1.0: a 1200-cell grid with eyes takes 0.24 s to
  build and draw versus ~3.5 s with the per-cell approach (~15x, same
  machine), with pixel-identical output.

### Bug fixes

- **Mapped `eye_size = 0` drew an eye
  ([\#1](https://github.com/PursuitOfDataScience/ggtaichi/issues/1))**:
  a mapped eye-size of `0` was rescaled to a positive radius, so an eye
  was drawn despite the documented “0 → no eye” rule. Zeros are now
  preserved and drawn without an eye.
- **A zero disabled the eye-size pass-through for the whole column**:
  because `0` is excluded from the documented `(0, 0.5]` pass-through
  range, a single “no eye here” zero made every other value in an
  otherwise-proportional column go through the `[0.05, 0.3]` rescale
  instead — `c(0, 0.2, 0.4)` drew eyes of `0, 0.175, 0.3`. Zeros are
  markers rather than measurements, so they no longer take part in that
  decision; the column now draws `0, 0.2, 0.4`, and the two documented
  rules compose as intended.
- **`shared_legend` palette mismatch
  ([\#2](https://github.com/PursuitOfDataScience/ggtaichi/issues/2))**:
  with `shared_legend = TRUE` and discrete fills, the yang fish was
  painted with a differently-interpolated palette than the yin fish when
  only one of `yin_colors` / `yang_colors` was supplied. Both fish now
  use `yin_colors`, so identical categories read as identical ink.
- **`states_tg` documentation
  ([\#3](https://github.com/PursuitOfDataScience/ggtaichi/issues/3))**:
  the dataset spans 31 weeks (the bundled data has 31); the
  documentation said 30. Corrected to 31 (the data is unchanged).
- **`...` routing (BUG-1)**: geom parameters (`alpha`, `colour`,
  `linewidth`, `linetype`, `width`, `height`, `na.rm`, `show.legend`)
  are now real, documented arguments of
  [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)
  and are forwarded to the underlying fish layers. `...` is reserved for
  options applied to both fill scales (e.g. shared `limits`); per-fish
  scale control goes through `yin_scale` / `yang_scale`.
- **`linewidth` aesthetic (BUG-2)**: the outline width now uses the
  modern `linewidth` aesthetic. Passing `size` to
  [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)
  still works but warns and is routed to `linewidth`, and an inherited
  `aes(size = ...)` mapping is renamed through ggplot2’s built-in
  deprecation path. ggtaichi now requires ggplot2 \>= 3.4.0.
- **Missing-argument validation (BUG-3)**: omitting `yin` or `yang`
  errors immediately with a clear message instead of silently producing
  a degenerate grey plot, and a `yin` / `yang` column that does not
  exist in the plot data errors at `+` time with the offending name.
- **Categorical fills (BUG-4)**: factor / character columns no longer
  trigger the cryptic “Discrete value supplied to a continuous scale”
  error (see the categorical fill support above).
- **Non-finite `angle` and `eye_size` values**: the guards tested
  [`is.na()`](https://rdrr.io/r/base/NA.html), which is `TRUE` for `NA`
  and `NaN` but not for `Inf` / `-Inf`. An infinite angle therefore
  reached [`cos()`](https://rdrr.io/r/base/Trig.html) /
  [`sin()`](https://rdrr.io/r/base/Trig.html), turned every vertex of
  that glyph into `NaN` and drew nothing while warning “NaNs produced”;
  an infinite mapped eye size asked grid for a circle of infinite
  radius. Both now test
  [`is.finite()`](https://rdrr.io/r/base/is.finite.html), so a
  non-finite angle falls back to no rotation and a non-finite eye size
  means no eye, exactly as `NA` already did.
- **Non-numeric `angle` columns**: mapping `angle` to a character column
  failed at draw time with the base error “non-numeric argument to
  binary operator”, and mapping it to a *factor* silently drew unrotated
  glyphs alongside `'*' not meaningful for factors` warnings. Both now
  error at build time with a clear message, matching how a non-numeric
  `eye_size` column is already handled.
- **Explicit discrete `limits`**: passing `limits` through `...` for a
  factor / character fish aborted with “Insufficient values in manual
  scale” whenever the limits held more entries than the data had levels.
  The auto-built palette is now sized against the limits.
- **A custom scale for the wrong aesthetic drew the wrong plot
  silently**: passing e.g. `yin_scale = scale_colour_viridis_c` attached
  the scale to `colour`, which the fish never map, so the fish fell back
  to ggplot2’s default blue fill gradient with no error at all.
  `yin_scale` / `yang_scale` are now checked to govern a fill aesthetic,
  and a value that is neither a scale object nor a constructor function
  reports that instead of the base error “‘what’ must be a function or
  character string”.
- **Non-numeric cell `width` / `height`** failed inside `setup_data()`
  with “non-numeric argument to binary operator”; now reported directly.
- **`...` colliding with the scale options
  [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)
  sets itself**: `guide` together with `shared_legend = TRUE` aborted
  with the base error “formal argument `guide` matched by multiple
  actual arguments”. The internally computed options now take
  precedence, so the yang guide is still dropped while a user-supplied
  `guide` styles the shared legend. Passing `name`, `values`, `colors`,
  or `colours` through `...` now reports which per-fish argument to use
  instead of raising the same base error.
- **[`theme_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/theme_taichi.md)
  no longer clips text at the plot edges**: the title is now aligned
  with the whole plot area (`plot.title.position = "plot"`) and slightly
  smaller (15 instead of 18), so realistic titles fit at typical figure
  sizes, and the right plot margin is a touch wider so an axis label
  sitting on the panel boundary (common with
  [`remove_padding()`](https://pursuitofdatascience.github.io/ggtaichi/reference/remove_padding.md))
  is not cut off.
- **[`theme_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/theme_taichi.md)
  element inheritance**: because the theme is composed with
  `%+replace%`, three properties
  [`theme_bw()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
  had set were silently dropped and fell back to the generic `text` /
  `rect` parents. The rice-paper canvas picked up a near-black 1px
  border around the whole plot, the y-axis tick labels lost their right
  alignment and their gap from the panel, and the legend title lost its
  left alignment. All three are restored.

### Documentation

- New pkgdown-only **gallery** article showing palettes, data-driven
  eyes, rotation, categorical fills, shared scales, and dense-grid
  texture.
- New **“When (not) to use taichi”** section in the intro vignette:
  honest guidance on dense grids, luminance precision, colorblind-safe
  palettes (viridis via `yin_scale` / `yang_scale`), and NA visibility.
- New **Styling** section in
  [`?geom_taichi`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md):
  `alpha`, `colour`, `linewidth` and `linetype` are layer-wide constants
  there (each has a concrete default, so it is always forwarded as a
  layer parameter and outranks an inherited mapping) — map those through
  [`geom_yin_fish()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_yin_fish.md)
  /
  [`geom_yang_fish()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_yin_fish.md)
  instead. `width` and `height` default to `NULL` and are forwarded only
  when supplied, so a plot-level `aes(width = ...)` does size the cells
  per row.
- [`?theme_taichi`](https://pursuitofdatascience.github.io/ggtaichi/reference/theme_taichi.md)
  now spells out its two surprising choices — the blanked y axis title
  (so `labs(y = )` has no effect) and the 90-degree legend text —
  together with the
  [`theme()`](https://ggplot2.tidyverse.org/reference/theme.html) calls
  that put either back.
- [`?remove_padding`](https://pursuitofdatascience.github.io/ggtaichi/reference/remove_padding.md)
  now states that `...` reaches *both* position scales, so with axes of
  different types only arguments common to continuous and discrete
  scales work there, and that auto-detection reads the plot’s mapping
  (name the type explicitly when `x` / `y` are mapped in a layer
  instead).
- [`?pitts_emojis`](https://pursuitofdatascience.github.io/ggtaichi/reference/pitts_emojis.md)
  now documents the actual format (HTML `<img>` tags aligned row-for-row
  with `pitts_tg`) and notes that the remote images it points at are no
  longer served.

### Internal

- Added a **testthat** suite (argument validation, `taichi_fish()`
  geometry down to a Monte-Carlo tiling check, parameter routing,
  rotation, eyes, discrete-scale selection, grob-level rendering checks)
  plus **vdiffr** visual-regression snapshots.
- Two gaps in that suite are closed. It now covers **non-square cells**
  — the per-cell box following `width` on x and `height` on y, and the
  glyph radius coming from the shorter cell side — which every
  [`coord_fixed()`](https://ggplot2.tidyverse.org/reference/coord_fixed.html)
  snapshot is blind to. It also pins the **direction** of all three
  places rotation is applied (`taichi_fish()`, the vectorised body
  rotation in `makeContent()`, and the eye placement), so a sign error
  in any one of them fails a test.
- `tests/testthat/setup.R` holds a null device open for the run, so the
  suite no longer leaves a stray `Rplots.pdf` in `tests/testthat/`.
- [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)
  now returns a `ggtaichi_plot` object added to the plot via a
  [`ggplot_add()`](https://ggplot2.tidyverse.org/reference/update_ggplot.html)
  method, which is what makes data-aware scale selection and shared
  limits possible.

## ggtaichi 0.1.0

CRAN release: 2026-06-24

- Initial version.
- [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)
  turns each cell of a grid into a taichi (yin-yang) diagram, filling
  the two fish with values from two data sources.
- Added
  [`theme_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/theme_taichi.md)
  and
  [`remove_padding()`](https://pursuitofdatascience.github.io/ggtaichi/reference/remove_padding.md)
  helpers.
- Bundled the `pitts_tg`, `states_tg`, and `pitts_emojis` data sets.
