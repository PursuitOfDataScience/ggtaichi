# ggtaichi: Taichi diagrams for two data sources

ggtaichi, which is a ggplot2 extension, visualizes data from two
different sources on a single grid of taichi (yin-yang) diagrams.
Instead of faceting a heatmap by data source, the two sources are
combined into one plot, where every cell becomes a taichi symbol whose
two fish are filled by the two sources via luminance. Prior to using the
package, users should load ggplot2.

## ggtaichi functions

The main workhorse is
[`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md),
which turns every `(x, y)` cell into a taichi diagram, much like
[`geom_tile()`](https://ggplot2.tidyverse.org/reference/geom_tile.html)
draws a regular heatmap. It is supported by
[`theme_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/theme_taichi.md)
and
[`remove_padding()`](https://pursuitofdatascience.github.io/ggtaichi/reference/remove_padding.md)
for styling. Users should reference the documentation and run the
examples in the help files when trying to understand what each argument
means visually.

Around it are the pieces that make a grid of glyphs readable:
[`taichi_summary()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_summary.md)
and
[`geom_taichi_diff()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi_diff.md)
put the relationship between the two sources into numbers and into a
diverging heatmap;
[`taichi_palette_pair()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_palette_pair.md),
[`taichi_palette()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_palette.md)
and
[`taichi_check_palette()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_check_palette.md)
build and audit the pair of colour ramps the comparison depends on; the
`scale_taichi_*()` family supplies ready fill scales, including the
binned ones worth reaching for on a dense grid; and
`geom_taichi(interactive = TRUE)` hands the plot to ggiraph so a reader
can hover for the exact values.

## See also

Useful links:

- <https://pursuitofdatascience.github.io/ggtaichi/>

- <https://github.com/PursuitOfDataScience/ggtaichi>

- Report bugs at
  <https://github.com/PursuitOfDataScience/ggtaichi/issues>

## Author

**Maintainer**: Youzhi Yu <yuyouzhi666@icloud.com>
