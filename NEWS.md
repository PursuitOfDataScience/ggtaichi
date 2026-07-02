# ggtaichi 0.3.0

## New features

- **Shared scales** for directly comparable sources (§4b of the roadmap):
  - `shared_limits = TRUE` gives both auto-built fill scales common limits —
    the union range of the two sources (or the union of levels when both are
    discrete) — so equal values read as equal ink. Explicit `limits` passed
    through `...` still win, and mixing a discrete with a continuous source
    warns and ignores the flag.
  - `shared_legend = TRUE` treats the sources as one measure: it implies
    shared limits, paints both fish with `yin_colors`, drops the duplicate
    yang guide, and titles the single legend "`yin` / `yang`" unless
    `yin_name` is supplied.
- **The fish geoms are exported** (§4d): `geom_yin_fish()` and
  `geom_yang_fish()` are now documented exports (with the `GeomYinFish` /
  `GeomYangFish` ggproto objects available for extension packages), for
  users who want a single fish or full manual control over scale stacking.
- **`remove_padding()` auto mode**: called with no arguments it now detects
  each axis's scale type from the plot it is added to; the explicit
  `"c"` / `"d"` arguments remain as overrides.
- **New dataset `cafes_tg`**: a small, clearly synthetic (seeded) espresso
  vs. matcha dataset whose two columns share units — an evergreen demo for
  the shared-scale features and a break from the COVID-era examples. The
  generating script ships in `data-raw/`.
- `geom_taichi()` now returns an object with a friendly `print()` method
  instead of dumping raw list internals at the console.

## Performance

- **Vectorized rendering**: each layer now draws all of its cells as one
  id-batched polygon (plus one batched circle grob for the eyes), resolved
  against the physical panel size at draw time via `makeContent()`. Glyphs
  stay perfectly round under resize, and large grids render an order of
  magnitude faster: a 1200-cell grid with eyes takes 0.24 s to build and
  draw versus 3.5 s in 0.2.0 (~15x, same machine). The drawn output is
  pixel-identical to 0.2.0 (verified on rotated, eyed, outlined, and
  faceted-discrete test plots).

## Documentation

- New pkgdown-only **gallery** article showing palettes, data-driven eyes,
  rotation, categorical fills, shared scales, and dense-grid texture.
- New **"When (not) to use taichi"** section in the intro vignette: honest
  guidance on dense grids, luminance precision, colorblind-safe palettes
  (viridis via `yin_scale` / `yang_scale`), and NA visibility.

# ggtaichi 0.2.0

## New features

- **Data-driven eyes** (`eyes = TRUE`): draw the classic taichi dots, each
  centred in its own fish's head (yin in the top bulb, yang in the bottom
  bulb). `yin_eye_size` / `yang_eye_size` and `yin_eye_colour` /
  `yang_eye_colour` accept either a constant or an unquoted data column, so a
  single glyph can now encode up to **six** dimensions (x, y, two fills, two
  eyes) (#3b).
- **Rotation** (`angle`): rotate each glyph by a constant number of degrees or
  by a data column, encoding a directional or temporal variable as
  orientation, and unlocking spin animations (#3a).
- **Categorical fill support**: `geom_taichi()` inspects the plot data at `+`
  time and auto-selects `scale_fill_manual()` for discrete (factor /
  character / logical) `yin` / `yang` values — including computed expressions
  such as `factor(week)` — and `scale_fill_gradientn()` for continuous ones.
  With the default color vectors, discrete categories sample the ramp evenly
  while skipping its palest end, so no category is invisible on a white
  panel. Custom scales (objects or constructors) can be supplied via
  `yin_scale` / `yang_scale` (#4a, BUG-4).
- `yin` and `yang` also accept strings naming a column (`yin = "Twitter"`),
  which previously produced a meaningless constant fill.
- **Animation vignette**: `vignette("animations")` documents how
  `geom_taichi()` composes with gganimate (`transition_states()`, spin
  animations via `angle`, export recipes). gganimate is a Suggests-only
  dependency.

## Bug fixes

- **`...` routing (BUG-1)**: geom parameters (`alpha`, `colour`, `linewidth`,
  `linetype`, `width`, `height`, `na.rm`, `show.legend`) are now real,
  documented arguments of `geom_taichi()` and are forwarded to the underlying
  fish layers. `...` is reserved for options applied to both fill scales
  (e.g. shared `limits`); per-fish scale control goes through `yin_scale` /
  `yang_scale`.
- **`linewidth` aesthetic (BUG-2)**: the outline width now uses the modern
  `linewidth` aesthetic. Passing `size` to `geom_taichi()` still works but
  warns and is routed to `linewidth`, and an inherited `aes(size = ...)`
  mapping is renamed through ggplot2's built-in deprecation path. ggtaichi
  now requires ggplot2 >= 3.4.0.
- **Missing-argument validation (BUG-3)**: omitting `yin` or `yang` errors
  immediately with a clear message instead of silently producing a degenerate
  grey plot, and a `yin` / `yang` column that does not exist in the plot data
  errors at `+` time with the offending name.
- **Categorical fills (BUG-4)**: factor / character columns no longer trigger
  the cryptic "Discrete value supplied to continuous scale" error (see the
  categorical fill support above).

## Internal

- Added a **testthat** suite (argument validation, `taichi_fish()` geometry
  down to a Monte-Carlo tiling check, parameter routing, rotation, eyes,
  discrete-scale selection, grob-level rendering checks) plus **vdiffr**
  visual-regression snapshots.
- `geom_taichi()` now returns a `ggtaichi_plot` object added to the plot via
  a `ggplot_add()` method, which is what makes data-aware scale selection
  possible.

# ggtaichi 0.1.0

- Initial version.
- `geom_taichi()` turns each cell of a grid into a taichi (yin-yang) diagram,
  filling the two fish with values from two data sources.
- Added `theme_taichi()` and `remove_padding()` helpers.
- Bundled the `pitts_tg`, `states_tg`, and `pitts_emojis` data sets.
