# Taichi

The taichi geom turns each cell of a heatmap-like grid into a taichi
(yin-yang) diagram. The two interlocking "fish" of the diagram use
luminance to show the values from two data sources on the same plot, so
four dimensions of data can be expressed at once: the `x` and `y`
position of every taichi symbol plus the `yin` and `yang` values that
fill its two halves. With the optional eyes enabled and mapped to data
(see `eyes`, `yin_eye_size`, `yang_eye_size`), a single glyph can carry
up to six dimensions.

## Usage

``` r
geom_taichi(
  yin,
  yang,
  yin_name = NULL,
  yang_name = NULL,
  yin_colors = c("gray100", "gray85", "gray50", "gray35", "gray0"),
  yang_colors = c("#FED7D8", "#FE8C91", "#F5636B", "#E72D3F", "#C20824"),
  yin_scale = NULL,
  yang_scale = NULL,
  angle = NULL,
  eyes = FALSE,
  yin_eye_size = 0.15,
  yang_eye_size = 0.15,
  yin_eye_colour = "white",
  yang_eye_colour = "black",
  shared_limits = FALSE,
  shared_legend = FALSE,
  width = NULL,
  height = NULL,
  alpha = NA,
  na.rm = FALSE,
  colour = NA,
  linewidth = 0.1,
  linetype = 1,
  show.legend = NA,
  ...
)
```

## Arguments

- yin:

  The unquoted column name (or a literal string naming a column) for the
  yin (dark) fish of the taichi symbol. To pass a name held in a
  variable, use `.data[[nm]]` or `!!rlang::sym(nm)` — a bare variable
  would be mapped as a constant fill, exactly as it would be inside
  [`aes()`](https://ggplot2.tidyverse.org/reference/aes.html).

- yang:

  The unquoted column name (or a literal string naming a column) for the
  yang (light) fish of the taichi symbol, as `yin`.

- yin_name:

  The label name (in quotes) for the legend of the yin rendering.
  Default is `NULL` (uses the column name).

- yang_name:

  The label name (in quotes) for the legend of the yang rendering.
  Default is `NULL` (uses the column name).

- yin_colors:

  A color vector, usually as hex codes, for the yin fish fill. Used as a
  gradient for continuous data and as a discrete palette for
  factor/character data. Ignored if `yin_scale` is provided.

- yang_colors:

  A color vector, usually as hex codes, for the yang fish fill. Used as
  a gradient for continuous data and as a discrete palette for
  factor/character data. Ignored if `yang_scale` is provided.

- yin_scale:

  An optional fill scale for the yin fish: either a ready scale object
  or a scale constructor function (e.g.
  [`ggplot2::scale_fill_viridis_d`](https://ggplot2.tidyverse.org/reference/scale_viridis.html)).
  Overrides auto-detection. It must govern a *fill* aesthetic; a scale
  for another aesthetic (say `scale_colour_viridis_c`) is rejected with
  an error rather than quietly leaving the fish on the default gradient.

- yang_scale:

  An optional fill scale for the yang fish, as `yin_scale`.

- angle:

  Rotation of each glyph in degrees, counter-clockwise: either a single
  number or an unquoted column name (one angle per cell). A mapped
  column must be numeric.

- eyes:

  Logical. If `TRUE`, draws the classic taichi eyes (dots), each centred
  in its fish's head. Default `FALSE`, preserving the plain v0.1.0 look.

- yin_eye_size, yang_eye_size:

  Size of each eye as a proportion of the glyph radius: a constant
  (default 0.15) or an unquoted data column to encode a variable (see
  the Eyes section for the rescaling rule).

- yin_eye_colour, yang_eye_colour:

  Colour of each eye dot: a constant (defaults "white" and "black") or
  an unquoted data column containing colour strings.

- shared_limits:

  If `TRUE` and both sources are of the same type (both continuous, or
  both discrete), the two auto-built fill scales share common limits —
  the union range (or union of levels) of `yin` and `yang` — so equal
  values read as equal ink. Explicit `limits` passed through `...` take
  precedence. Default `FALSE`.

- shared_legend:

  If `TRUE`, treats the two sources as directly comparable: implies
  `shared_limits = TRUE`, paints both fish with `yin_colors`, and shows
  a single legend (the yang guide is dropped). Unless `yin_name` is
  supplied, the legend is titled "`yin` / `yang`". Ignored when custom
  `yin_scale` / `yang_scale` are given. Default `FALSE`.

- width, height:

  Width and height of each cell. Typically omitted.

- alpha:

  Alpha transparency for the fish fills. A single value for the whole
  layer (see the Styling section).

- na.rm:

  If `TRUE`, silently removes rows with missing values.

- colour:

  Outline colour of the fish. A single value for the whole layer (see
  the Styling section).

- linewidth:

  Outline width of the fish (in mm). Replaces the deprecated `size`
  aesthetic of ggtaichi 0.1.0. A single value for the whole layer (see
  the Styling section).

- linetype:

  Outline linetype of the fish. A single value for the whole layer (see
  the Styling section).

- show.legend:

  Logical. Should the layer be included in the legend?

- ...:

  Additional arguments passed to *both* auto-built fill scales (e.g.,
  shared `limits` or `na.value`). Because they go to both, an argument
  that suits only one kind of scale will be rejected by the other when
  `yin` and `yang` are of different types — for instance a numeric
  `limits` draws ggplot2's "Continuous limits supplied to discrete
  scale" warning from the discrete fish. For per-fish scale options,
  supply `yin_scale` / `yang_scale` instead. The scale arguments
  `geom_taichi()` fills in itself — `name`, `values` and `colors` /
  `colours` — are not accepted here; use `yin_name` / `yang_name` and
  `yin_colors` / `yang_colors`.

## Value

A `ggtaichi_plot` object: the two fish layers plus the fill scales they
need, ready to be added to a
[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html) with
`+`. It is not a plot on its own.

## Discrete and continuous fills

`geom_taichi()` inspects the plot data at `+` time. A numeric `yin` /
`yang` column gets a continuous
[`scale_fill_gradientn`](https://ggplot2.tidyverse.org/reference/scale_gradient.html)
built from `yin_colors` / `yang_colors`; a factor, character, or logical
column (including computed expressions such as `factor(week)`) gets a
discrete
[`scale_fill_manual`](https://ggplot2.tidyverse.org/reference/scale_manual.html)
whose palette is interpolated from the same color vectors. With the
default vectors the discrete palette skips the palest end of the ramp so
that no category is invisible on a white panel; an explicitly supplied
color vector is used as-is. Supply `yin_scale` / `yang_scale` to
override the automatic choice entirely.

Because the choice is made when the layer is added, replacing the plot's
data afterwards keeps the scales picked for the original data. Swapping
in data of the same types is fine; if the new `yin` / `yang` columns are
of the *other* kind, ggplot2 reports a "Discrete value supplied to a
continuous scale" (or the reverse) at draw time — rebuild the plot
rather than substituting its data.

## Eyes

`eyes = TRUE` draws the classic taichi dots, each sitting in its own
fish's head: the yin eye in the top bulb, the yang eye in the bottom
bulb. The size and colour arguments accept either a constant or an
(unquoted) data column, so the eyes can encode up to two further
variables. A mapped eye-size column is rescaled to radii between 0.05
and 0.3 of the glyph radius, unless all its non-zero values already lie
in `(0, 0.5]`, in which case they are used directly as radius
proportions. Cells whose eye size is `NA` or `0` are drawn without an
eye, so a column may mix proportions with zeros to suppress individual
eyes. A column whose values are all equal gets the midpoint radius,
0.175.

## Styling

`alpha`, `colour`, `linewidth` and `linetype` are layer-wide constants
here. Each has a concrete default, so `geom_taichi()` always passes it
to both fish layers as a parameter, and a parameter takes precedence
over an inherited mapping: a plot-level `aes(linewidth = ...)` (or
`alpha`, `colour`, `linetype`) has no effect on the glyphs. To drive one
of those from a column, build the layers yourself with
[`geom_yin_fish()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_yin_fish.md)
/
[`geom_yang_fish()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_yin_fish.md),
which take all four as ordinary aesthetics.

`width` and `height` behave differently, because they default to `NULL`
and are forwarded only when you actually supply them: a plot-level
`aes(width = ...)` *does* size the cells per row. So the data-driven
channels of `geom_taichi()` are `yin`, `yang`, `angle`, the two eyes,
and `width` / `height` via
[`aes()`](https://ggplot2.tidyverse.org/reference/aes.html).

## Missing values

A fish whose fill value is `NA` is painted in the scale's `na.value`
colour (pass e.g. `na.value = "transparent"` through `...` to change
it), while `na.rm = TRUE` silently drops rows with missing positions.

## Examples

``` r

library(ggplot2)

# taichi with numeric fills

data <- data.frame(x = rep(c(1, 2, 3), 3),
                   y = rep(c(1, 2, 3), each = 3),
                   yin_values = 1:9,
                   yang_values = 9:1)

ggplot(data, aes(x, y)) +
  geom_taichi(yin = yin_values,
              yang = yang_values)


# categorical (discrete) fills are detected automatically

data$yin_class <- rep(c("low", "mid", "high"), 3)

ggplot(data, aes(x, y)) +
  geom_taichi(yin = yin_class,
              yang = yang_values)


# classic eyes, rotation, and data-driven eye sizes

ggplot(data, aes(x, y)) +
  geom_taichi(yin = yin_values,
              yang = yang_values,
              eyes = TRUE,
              yin_eye_size = yang_values,
              angle = 45)

```
