# Package index

## Drawing the glyph

The main layer, and the two fish it is assembled from.

- [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)
  : Taichi
- [`geom_yin_fish()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_yin_fish.md)
  [`geom_yang_fish()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_yin_fish.md)
  : The individual taichi fish layers
- [`ggtaichi-ggproto`](https://pursuitofdatascience.github.io/ggtaichi/reference/ggtaichi-ggproto.md)
  [`GeomYinFish`](https://pursuitofdatascience.github.io/ggtaichi/reference/ggtaichi-ggproto.md)
  [`GeomYangFish`](https://pursuitofdatascience.github.io/ggtaichi/reference/ggtaichi-ggproto.md)
  : ggtaichi's ggproto classes

## The relationship between the two sources

A taichi grid shows two sources in one position, which answers “which is
bigger here?” and not “by how much?”. These compute the second
question’s answer – inside the glyph, as a table, or as a heatmap of its
own.

- [`taichi_summary()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_summary.md)
  : Summarise the two sources cell by cell
- [`geom_taichi_diff()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi_diff.md)
  : The difference between the two sources, as a heatmap

## Palettes

The two fill ramps are compared against each other, so pairing them is a
correctness question rather than a matter of taste. These build a
matched pair and measure any pair.

- [`taichi_palette_pair()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_palette_pair.md)
  : Build a luminance-matched pair of sequential palettes
- [`taichi_palette()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_palette.md)
  : Ready-made palette pairs
- [`taichi_check_palette()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_check_palette.md)
  : Measure whether two fill ramps are a fair pair

## Scales

Ready fill scales in the package’s conventions, including the binned
ones worth reaching for on a dense grid.

- [`scale_taichi_yin_c()`](https://pursuitofdatascience.github.io/ggtaichi/reference/scale_taichi.md)
  [`scale_taichi_yang_c()`](https://pursuitofdatascience.github.io/ggtaichi/reference/scale_taichi.md)
  [`scale_taichi_yin_d()`](https://pursuitofdatascience.github.io/ggtaichi/reference/scale_taichi.md)
  [`scale_taichi_yang_d()`](https://pursuitofdatascience.github.io/ggtaichi/reference/scale_taichi.md)
  [`scale_taichi_yin_binned()`](https://pursuitofdatascience.github.io/ggtaichi/reference/scale_taichi.md)
  [`scale_taichi_yang_binned()`](https://pursuitofdatascience.github.io/ggtaichi/reference/scale_taichi.md)
  [`scale_taichi_yin_viridis_c()`](https://pursuitofdatascience.github.io/ggtaichi/reference/scale_taichi.md)
  [`scale_taichi_yang_viridis_c()`](https://pursuitofdatascience.github.io/ggtaichi/reference/scale_taichi.md)
  [`scale_taichi_yin_viridis_d()`](https://pursuitofdatascience.github.io/ggtaichi/reference/scale_taichi.md)
  [`scale_taichi_yang_viridis_d()`](https://pursuitofdatascience.github.io/ggtaichi/reference/scale_taichi.md)
  : Fill scales for the taichi fish

## Styling

- [`theme_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/theme_taichi.md)
  : Plot Themes
- [`remove_padding()`](https://pursuitofdatascience.github.io/ggtaichi/reference/remove_padding.md)
  : Remove ggplot2 default padding
- [`draw_key_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/draw_key_taichi.md)
  : A taichi-shaped legend key

## Data

- [`cafes_tg`](https://pursuitofdatascience.github.io/ggtaichi/reference/cafes_tg.md)
  : Synthetic café orders: espresso vs. matcha
- [`pitts_tg`](https://pursuitofdatascience.github.io/ggtaichi/reference/pitts_tg.md)
  : Pittsburgh COVID-related Google & Twitter incidence rates
- [`states_tg`](https://pursuitofdatascience.github.io/ggtaichi/reference/states_tg.md)
  : States' COVID-related Google & Twitter incidence rates
- [`pitts_emojis`](https://pursuitofdatascience.github.io/ggtaichi/reference/pitts_emojis.md)
  : Popular Emojis

## Package

- [`ggtaichi`](https://pursuitofdatascience.github.io/ggtaichi/reference/ggtaichi-package.md)
  [`ggtaichi-package`](https://pursuitofdatascience.github.io/ggtaichi/reference/ggtaichi-package.md)
  : ggtaichi: Taichi diagrams for two data sources
