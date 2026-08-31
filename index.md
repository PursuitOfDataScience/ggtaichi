# ggtaichi

**Two data sources. One grid of yin-yang glyphs. Both halves at a
glance.**

A
[`geom_tile()`](https://ggplot2.tidyverse.org/reference/geom_tile.html)
heatmap gives you one number per cell.
[`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)
gives you two.

## Install

``` r

install.packages("ggtaichi")

# development version
devtools::install_github("PursuitOfDataScience/ggtaichi")
```

## One glyph, two numbers

Yin takes one source, yang the other. No decoration – every drop of ink
is data.

``` r

library(ggtaichi)
library(ggplot2)

one <- data.frame(x = 1, y = 1, google = 7, twitter = 3)

ggplot(one, aes(x, y)) +
  geom_taichi(yin = twitter, yang = google) +
  coord_fixed() +
  theme_taichi()
```

![A single large taichi diagram whose red (yang) half encodes one data
source and grey (yin) half the
other.](reference/figures/README-anatomy-1.png)

## Now a grid of them

``` r

pitts_small <- subset(pitts_tg, week <= 6)

ggplot(pitts_small, aes(week, category)) +
  geom_taichi(yin = Twitter, yang = Google) +
  theme_taichi()
```

![A six-week grid of taichi diagrams for nine Pittsburgh COVID
categories, the yang fish shaded red by Google and the yin fish grey by
Twitter.](reference/figures/README-pitts-1.png)

`Covid` and `Masks` lean dark – lots of Twitter – while staying pink, so
only moderate Google.

## The eyes are data too

Six dimensions in one mark: `x`, `y`, two fills, two eyes.

``` r

quad <- data.frame(x = c(1, 2, 1, 2), y = c(2, 2, 1, 1),
                   yin = c(3, 5, 7, 9), yang = c(9, 7, 5, 3),
                   reach = c(10, 40, 25, 5), quality = c(2, 1, 4, 8))

ggplot(quad, aes(x, y)) +
  geom_taichi(yin = yin, yang = yang, eyes = TRUE,
              yin_eye_size = reach, yang_eye_size = quality,
              limits = c(0, 10)) +
  coord_fixed() +
  theme_taichi()
```

![A two-by-two grid of taichi diagrams with classic eyes whose sizes
vary from cell to cell, encoding two extra
variables.](reference/figures/README-eyes-1.png)

## Spin it

`angle` takes a constant or a column – a seventh channel.

``` r

rot <- data.frame(x = 1:4, y = 1, yin = 1:4, yang = 4:1,
                  turn = c(0, 45, 90, 135))

ggplot(rot, aes(x, y)) +
  geom_taichi(yin = yin, yang = yang, angle = turn, eyes = TRUE,
              limits = c(0, 5)) +
  coord_fixed() +
  theme_taichi()
```

![Four taichi diagrams rotated by 0, 45, 90, and 135 degrees read from a
data column.](reference/figures/README-rotation-1.png)

Hand `angle` to [gganimate](https://gganimate.com) and it actually
spins.

``` r

library(gganimate)

spin <- expand.grid(x = 1:4, f = 1:48)
spin$y <- 1
spin$turn <- (spin$f - 1) * 7.5 + (spin$x - 1) * 45   # each one out of phase

ggplot(spin, aes(x, y)) +
  geom_taichi(yin = 1, yang = 2, angle = turn, eyes = TRUE,
              yin_colors = "grey15", yang_colors = "#C20824",
              show.legend = FALSE) +
  coord_fixed() +
  theme_void() +
  transition_states(f, transition_length = 1, state_length = 0)
```

![Four taichi glyphs rotating steadily, each a quarter turn out of phase
with the last.](reference/figures/README-spin-1.gif)

## Watch a season go by

`cafes_tg` follows espresso and matcha across twelve weeks. Espresso
cools off, matcha warms up.

``` r

ggplot(cafes_tg, aes(neighbourhood, "")) +
  geom_taichi(yin = matcha, yang = espresso, shared_legend = TRUE,
              yin_name = "orders / 100 customers") +
  theme_taichi() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1, size = 9)) +
  labs(title = "Week {closest_state}", x = NULL) +
  transition_states(week, transition_length = 2, state_length = 1)
```

![Eight taichi glyphs, one per neighbourhood, animating week by week as
the espresso half lightens and the matcha half
darkens.](reference/figures/README-season-1.gif)

## Categories work too

``` r

disc <- data.frame(x = c(1, 2, 1, 2), y = c(2, 2, 1, 1),
                   method = factor(c("A", "B", "C", "A")),
                   outcome = factor(c("win", "loss", "win", "loss")))

ggplot(disc, aes(x, y)) +
  geom_taichi(yin = method, yang = outcome) +
  coord_fixed() +
  theme_taichi()
```

![A two-by-two grid of taichi diagrams whose fish are filled by discrete
categories: methods A to C for yin and win or loss for
yang.](reference/figures/README-categorical-1.png)

The legend keys are little taichi as well.

## Same units? One legend.

``` r

ggplot(cafes_tg, aes(week, neighbourhood)) +
  geom_taichi(yin = matcha, yang = espresso, shared_legend = TRUE,
              yin_name = "orders / 100 customers") +
  remove_padding() +
  theme_taichi()
```

![A 12-week by 8-neighbourhood grid of taichi diagrams comparing
espresso and matcha orders on one shared grey scale with a single
legend.](reference/figures/README-shared-1.png)

## Bigger, sure – but by how much?

Two fish in one spot tell you *which*. `explicit` computes the gap and
shows you *how much*. Cells where the two agree get no eye at all.

``` r

ggplot(cafes_tg, aes(week, neighbourhood)) +
  geom_taichi(yin = matcha, yang = espresso, shared_legend = TRUE,
              yin_name = "orders / 100 customers",
              explicit = "difference") +
  remove_padding() +
  theme_taichi()
```

![The espresso versus matcha grid where each glyph's eyes grow with the
gap between the two sources, and cells where they agree have no
eyes.](reference/figures/README-explicit-eye-1.png)

Or as tilt, which the eye reads far more precisely. Upright means they
agree.

``` r

tilt <- data.frame(x = 1:5, y = 1, yin = c(1, 3, 5, 7, 9), yang = 9:5)

ggplot(tilt, aes(x, y)) +
  geom_taichi(yin = yin, yang = yang, shared_limits = TRUE,
              explicit = "difference", explicit_channel = "angle") +
  coord_fixed() +
  theme_taichi()
```

![Five taichi diagrams tilting from left-leaning to right-leaning as the
difference between the two sources goes from negative to
positive.](reference/figures/README-explicit-angle-1.png)

Animate it and the eyes blink shut exactly where the two sources cross.

``` r

ggplot(cafes_tg, aes(neighbourhood, "")) +
  geom_taichi(yin = matcha, yang = espresso, shared_legend = TRUE,
              yin_name = "orders / 100 customers",
              explicit = "difference") +
  theme_taichi() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1, size = 9)) +
  labs(title = "Week {closest_state}", x = NULL) +
  transition_states(week, transition_length = 2, state_length = 1)
```

![Eight taichi glyphs animating across a season; their eyes shrink to
nothing as espresso and matcha cross over, then swell
again.](reference/figures/README-crossover-1.gif)

## Is your palette fair?

If the two ramps don’t span the same luminance, equal values don’t
*look* equal and one fish quietly wins. Ask:

``` r

taichi_check_palette()
#>   largest luminance mismatch : 40.6 L* (tolerance 5.0)
#>   Verdict: FAIL
```

Yes – the defaults fail their own check, and are kept only so old
figures don’t move. `palette = "balanced"` passes.

``` r

ggplot(cafes_tg, aes(week, neighbourhood)) +
  geom_taichi(yin = matcha, yang = espresso,
              palette = "balanced", shared_limits = TRUE) +
  remove_padding() +
  theme_taichi()
```

![The espresso versus matcha grid drawn with a luminance-matched blue
and brick-red palette pair, so equal values carry equal visual
weight.](reference/figures/README-balanced-1.png)

## Too many cells? Bin it.

``` r

ggplot(cafes_tg, aes(week, neighbourhood)) +
  geom_taichi(yin = matcha, yang = espresso,
              yin_scale  = scale_taichi_yin_binned(n.breaks = 4),
              yang_scale = scale_taichi_yang_binned(n.breaks = 4),
              shared_limits = TRUE) +
  remove_padding() +
  theme_taichi()
```

![The espresso versus matcha grid with both fish filled from four
discrete colour steps rather than a continuous
ramp.](reference/figures/README-binned-1.png)

## Hover for the exact numbers

``` r

p <- ggplot(cafes_tg, aes(week, neighbourhood)) +
  geom_taichi(yin = matcha, yang = espresso,
              interactive = TRUE, data_id_by = "source")

ggiraph::girafe(ggobj = p)
```

Hover one yin fish and *every* yin fish lights up. Live version in the
[gallery](https://pursuitofdatascience.github.io/ggtaichi/articles/gallery.html).

## More

[`vignette("ggtaichi")`](https://pursuitofdatascience.github.io/ggtaichi/articles/ggtaichi.md)
for the full tour,
[`vignette("animations")`](https://pursuitofdatascience.github.io/ggtaichi/articles/animations.md)
for motion, and the
[gallery](https://pursuitofdatascience.github.io/ggtaichi/articles/gallery.html)
for the rest.

## Acknowledgement

`ggtaichi` is a spinoff of the
[`ggDoubleHeat`](https://CRAN.R-project.org/package=ggDoubleHeat)
package, which introduced the idea of folding two data sources into a
single reformed heat map. `ggtaichi` takes that two-scale design and
re-imagines the per-cell glyph as a taichi diagram.
