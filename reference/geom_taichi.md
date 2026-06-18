# Taichi

The taichi geom turns each cell of a heatmap-like grid into a taichi
(yin-yang) diagram. The two interlocking "fish" of the diagram use
luminance to show the values from two data sources on the same plot, so
four dimensions of data can be expressed at once: the `x` and `y`
position of every taichi symbol plus the `yin` and `yang` values that
fill its two halves.

## Usage

``` r
geom_taichi(
  yin,
  yin_name = NULL,
  yin_colors = c("gray100", "gray85", "gray50", "gray35", "gray0"),
  yang,
  yang_name = NULL,
  yang_colors = c("#FED7D8", "#FE8C91", "#F5636B", "#E72D3F", "#C20824"),
  ...
)
```

## Arguments

- yin:

  The column name for the yin (dark) fish of the taichi symbol.

- yin_name:

  The label name (in quotes) for the legend of the yin rendering.
  Default is `NULL`.

- yin_colors:

  A color vector, usually as hex codes.

- yang:

  The column name for the yang (light) fish of the taichi symbol.

- yang_name:

  The label name (in quotes) for the legend of the yang rendering.
  Default is `NULL`.

- yang_colors:

  A color vector, usually as hex codes.

- ...:

  `...` accepts any arguments
  [`scale_fill_gradientn()`](https://ggplot2.tidyverse.org/reference/scale_gradient.html)
  has .

## Value

A taichi diagram comparing two data sources.

## Examples

``` r

# taichi with categorical variables only

library(ggplot2)

data <- data.frame(x = rep(c("a", "b", "c"), 3),
                   y = rep(c("d", "e", "f"), 3),
                   yin_values = rep(c(1,5,7),3),
                   yang_values = rep(c(2,3,4),3))

ggplot(data, aes(x,y)) +
geom_taichi(yin = yin_values,
            yang = yang_values)



# taichi with numeric variables only

data <- data.frame(x = rep(c(1, 2, 3), 3),
                   y = rep(c(1, 2, 3), 3),
                   yin_values = rep(c(1,5,7),3),
                   yang_values = rep(c(2,3,4),3))

ggplot(data, aes(x,y)) +
geom_taichi(yin = yin_values,
            yang = yang_values)



# taichi with a mixture of numeric and categorical variables

data <- data.frame(x = rep(c("a", "b", "c"), 3),
                   y = rep(c(1, 2, 3), 3),
                   yin_values = rep(c(1,5,7),3),
                   yang_values = rep(c(2,3,4),3))

ggplot(data, aes(x,y)) +
geom_taichi(yin = yin_values,
            yang = yang_values)

```
