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
  Custom scales (objects or constructors) can be supplied via `yin_scale` /
  `yang_scale` (#4a, BUG-4).
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
  `linewidth` aesthetic. The deprecated `size` spelling still works via
  ggplot2's built-in renaming path (with a deprecation message). ggtaichi now
  requires ggplot2 >= 3.4.0.
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
