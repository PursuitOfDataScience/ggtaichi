# Animating taichi diagrams

## Why animate?

A taichi (yin-yang) symbol is *cyclical*, so motion is unusually
on-brand for this geom. Instead of forcing a third variable
(e.g. `week`) onto the x-axis and shrinking every glyph, we can turn it
into an **animation frame**. Each frame is then a clean `category` x
`state` grid of large, readable taichi.

This vignette shows how to combine
[`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)
with [gganimate](https://gganimate.org). `gganimate` is a *Suggested*
dependency; install it with `install.packages("gganimate")` if you have
not already.

``` r

library(ggplot2)
library(ggtaichi)
library(gganimate)
```

## How `geom_taichi()` composes with gganimate

[`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)
returns a pair of layers separated by
[`ggnewscale::new_scale_fill()`](https://eliocamp.github.io/ggnewscale/reference/new_scale.html),
so each fish keeps its own fill scale and legend. gganimate works at the
*layer* level — it splits every layer’s data by the transition variable
and builds one frame per state. Because the two fish layers are ordinary
`ggplot2` layers, gganimate treats them independently and the two fill
scales continue to apply frame-by-frame. In short: **the ggnewscale
layer stack composes cleanly with gganimate**, so no special wrapper is
needed. (This is not just theory: every recipe below has been rendered
frame-by-frame against gganimate 1.0.11, with both legends and the
per-fish fills intact in every frame.)

## Animating over a third variable

Use
[`transition_states()`](https://gganimate.com/reference/transition_states.html)
when the frame variable is discrete (e.g. week number), or
[`transition_time()`](https://gganimate.com/reference/transition_time.html)
when it is a continuous time. Both drive the underlying fish layers. The
bundled `states_tg` data is a perfect showcase: instead of squeezing its
30 weeks onto the x-axis, keep a `category` x `state` grid of large
glyphs and let the weeks play out as frames. Because the fills are
continuous, `tweenr` interpolates the values smoothly between
consecutive weeks.

``` r

p <- ggplot(states_tg, aes(x = category, y = state)) +
  geom_taichi(yin = Twitter, yang = Google) +
  theme_taichi() +
  labs(title = "Week {closest_state}") +
  transition_states(week, transition_length = 1, state_length = 1)

# Render to a GIF (requires the gifski package)
# animate(p, renderer = gifski_renderer())
# anim_save("taichi.gif", p)
```

## Keeping glyphs round

Taichi symbols are always drawn round (they are sized in square units,
like [`grid::circleGrob()`](https://rdrr.io/r/grid/grid.circle.html)),
but
[`coord_fixed()`](https://ggplot2.tidyverse.org/reference/coord_fixed.html)
keeps the *cells* square too, so the glyphs fill them evenly. Match the
animation dimensions to the grid:

``` r

p_fixed <- ggplot(states_tg, aes(x = category, y = state)) +
  geom_taichi(yin = Twitter, yang = Google) +
  coord_fixed() +
  theme_taichi() +
  transition_states(week, transition_length = 1, state_length = 1)

# animate(p_fixed, width = 800, height = 600, fps = 10)
```

## Spin animation

With the `angle` argument (see
[`?geom_taichi`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md))
you can rotate each glyph. Mapping `angle` to an expression of the frame
variable and animating produces the iconic “turning taichi” — with
`eyes = TRUE` each eye rides around in its own fish’s head:

``` r

spin <- data.frame(
  x = 1, y = 1, yin = 5, yang = 5,
  frame = 1:36
)

p_spin <- ggplot(spin, aes(x, y)) +
  geom_taichi(yin = yin, yang = yang, angle = frame * 10,
              eyes = TRUE) +
  coord_fixed() +
  theme_taichi() +
  transition_states(frame, transition_length = 0, state_length = 1)

# animate(p_spin, width = 300, height = 300, fps = 12)
```

Note the `state_length = 1` with `transition_length = 0`: each frame
*is* a state, so the rotation advances in crisp steps (at least one of
the two lengths must be positive, or gganimate cannot allocate frames).
For a grow-in reveal instead, keep a positive `transition_length` and
add [`enter_grow()`](https://gganimate.com/reference/enter_exit.html) to
the plot.

## Export helpers

[`gganimate::anim_save()`](https://gganimate.com/reference/anim_save.html)
writes the animation to a file. For MP4 output use
[`ffmpeg_renderer()`](https://gganimate.com/reference/renderers.html)
(requires a system `ffmpeg`); for GIF use
[`gifski_renderer()`](https://gganimate.com/reference/renderers.html)
(requires the `gifski` package). Aim for 10–15 fps and enough frames
that the motion is smooth;
[`coord_fixed()`](https://ggplot2.tidyverse.org/reference/coord_fixed.html)
keeps every glyph round in the rendered video.
