# ggtaichi 0.2.0

## New features

- **Rotation aesthetic** (`angle`): rotate each glyph in degrees to encode a
  directional or temporal variable as orientation (#3a).
- **Data-driven eyes** (`eyes = TRUE`): draw the classic taichi dots with
  customisable colour and size per fish (#3b).
- **Categorical fill support**: `geom_taichi()` auto-detects discrete
  (factor / character) `yin` / `yang` values and picks the appropriate scale
  type.  Custom scales can be supplied via `yin_scale` / `yang_scale` (#4a,
  BUG-4).
- **Linewidth aesthetic**: replaced the deprecated `size` aesthetic with
  `linewidth`, matching modern ggplot2 conventions (BUG-2).

## Bug fixes

- **`...` routing (BUG-1)**: geom parameters (`alpha`, `colour`, `linewidth`,
  `linetype`, `width`, `height`, `na.rm`, `show.legend`) are now properly
  accepted by `geom_taichi()` and forwarded to the underlying fish geoms.
  The `...` is reserved for fill-scale arguments.
- **Missing-argument validation (BUG-3)**: `geom_taichi()` now errors clearly
  when `yin` or `yang` is omitted.
- **Categorical fills (BUG-4)**: factor / character columns no longer trigger
  a cryptic "Discrete value supplied to continuous scale"; the package now
  auto-selects `scale_fill_manual()` when discrete data is detected.

## Internal / testing

- Added a **testthat** suite covering argument validation, geometry
  correctness, rotation, eyes, categorical fill support, and *rendering*
  verification (checking that circle grobs actually appear when `eyes = TRUE`).
- Added **vdiffr** visual-regression snapshots so glyph rendering cannot
  silently regress.
- Exported `ggplot_add.ggtaichi_plot` S3 method to enable smart scale
  auto-detection at `+` time.
- Added an **animation vignette** (`vignette("animations")`) with recipes for
  `gganimate`, guarded so it builds even when `gganimate` is not installed.

## Bug fixes (post-scope)

- **Eyes not rendering**: the `eyes` / eye-size / eye-colour parameters were
  declared in `extra_params` but never reached `draw_panel()` because
  `draw_panel` used `...`, causing `ggplot2::Geom$parameters()` to return an
  empty set and `draw_layer()` to strip every geom parameter before calling
  `draw_panel`.  Switched `draw_panel` to explicit named parameters (the
  standard ggplot2 pattern) so the eye parameters are discovered and forwarded
  correctly.

# ggtaichi 0.1.0

- Initial version.
- `geom_taichi()` turns each cell of a grid into a taichi (yin-yang) diagram,
  filling the two fish with values from two data sources.
- Added `theme_taichi()` and `remove_padding()` helpers.
- Bundled the `pitts_tg`, `states_tg`, and `pitts_emojis` data sets.
