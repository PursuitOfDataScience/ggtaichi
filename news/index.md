# Changelog

## ggtaichi 0.2.0

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
