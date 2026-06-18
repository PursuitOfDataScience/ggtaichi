# ggtaichi: Taichi diagrams for two data sources

ggtaichi, which is a ggplot2 extension, visualizes data from two
different sources on a single grid of taichi (yin-yang) diagrams.
Instead of facetting a heatmap by data source, the two sources are
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

## See also

Useful links:

- <https://github.com/PursuitOfDataScience/ggtaichi>

- Report bugs at
  <https://github.com/PursuitOfDataScience/ggtaichi/issues>

## Author

**Maintainer**: Youzhi Yu <yuyouzhi666@icloud.com>
