# Summarise the two sources cell by cell

A taichi grid is a *superposition* comparison: the two sources share one
position, which makes "are these similar?" and "which is bigger here?"
easy to see and "by how much?" impossible. `taichi_summary()` is the
tidy answer to the last question — the numbers behind the glyph, one row
per input row, for the reader who needs a table rather than a picture.

## Usage

``` r
taichi_summary(data, yin, yang, x = NULL, y = NULL)
```

## Arguments

- data:

  A data frame, the same one passed to
  [`ggplot2::ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html).

- yin, yang:

  Unquoted column names (or strings naming columns) for the two sources,
  exactly as in
  [`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md).

- x, y:

  Optional unquoted column names identifying each cell. When given they
  are carried through to the output as the first columns, which makes
  the result joinable back onto the plotting data.

## Value

A data frame with one row per row of `data`: the optional `x` and `y`
cell identifiers, `yin`, `yang`, `difference`, `ratio`, `log_ratio`,
`z`, `dominant` and `rank`.

## The statistics

- `difference`:

  `yin - yang`. Positive means the yin fish (the top bulb) carries the
  larger value.

- `ratio`:

  `yin / yang`, and `NA` wherever either value is not strictly positive
  — a ratio of a negative or zero quantity is not a ratio, and `Inf` is
  never returned.

- `log_ratio`:

  `log2(yin / yang)`, so a value of 1 means yin is twice yang and -1
  means half. Symmetric around zero, which `ratio` is not, and the right
  choice when the two sources span orders of magnitude.

- `z`:

  The difference of the two standardised sources: each column is centred
  and scaled across the whole grid, then subtracted. This is the
  statistic to use when the two sources are *not* in the same units,
  because it asks "which source is unusually high here, relative to its
  own spread?" rather than "which number is bigger?".

- `dominant`:

  Which source is larger in that cell, named after the columns supplied,
  or `"tie"`.

- `rank`:

  The cell's rank by size of `abs(difference)`, 1 being the widest gap.
  Cells with a missing difference get `NA`.

## See also

[`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)'s
`explicit` argument, which shows one of these statistics inside the
glyph, and
[`geom_taichi_diff()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi_diff.md),
which draws it as a diverging heatmap.

## Examples

``` r
summ <- taichi_summary(cafes_tg, yin = matcha, yang = espresso,
                       x = week, y = neighbourhood)
head(summ)
#>   x        y  yin yang difference     ratio  log_ratio          z dominant rank
#> 1 1 Old Town 32.8 48.5      -15.7 0.6762887 -0.5642889 -1.3891789 espresso   55
#> 2 2 Old Town 40.5 52.9      -12.4 0.7655955 -0.3853458 -1.1336049 espresso   66
#> 3 3 Old Town 38.4 50.9      -12.5 0.7544204 -0.4065593 -1.1321353 espresso   63
#> 4 4 Old Town 36.6 45.2       -8.6 0.8097345 -0.3044791 -0.7762886 espresso   72
#> 5 5 Old Town 38.3 56.2      -17.9 0.6814947 -0.5532257 -1.6120500 espresso   48
#> 6 6 Old Town 41.1 60.0      -18.9 0.6850000 -0.5458241 -1.7148359 espresso   45

# the five cells where the two sources disagree most
head(summ[order(summ$rank), ], 5)
#>     x               y  yin yang difference    ratio log_ratio        z dominant
#> 35 11      University 74.1 24.0       50.1 3.087500  1.626439 4.260819   matcha
#> 82 10 Garden District 70.9 22.2       48.7 3.193694  1.675226 4.152065   matcha
#> 33  9      University 76.1 28.4       47.7 2.679577  1.422006 4.037432   matcha
#> 84 12 Garden District 72.2 24.7       47.5 2.923077  1.547488 4.038890   matcha
#> 36 12      University 76.1 32.9       43.2 2.313070  1.209809 3.637092   matcha
#>    rank
#> 35    1
#> 82    2
#> 33    3
#> 84    4
#> 36    5
```
