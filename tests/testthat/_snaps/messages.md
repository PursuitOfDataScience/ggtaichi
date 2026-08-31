# geom_taichi() prints a readable summary of what it will draw

    Code
      print(geom_taichi(yin = Twitter, yang = Google))
    Output
      <ggtaichi> taichi layers for a ggplot
        yin  : Twitter
        yang : Google
        eyes : off
      Add it to a plot: ggplot(data, aes(x, y)) + geom_taichi(...)

---

    Code
      print(geom_taichi(yin = Twitter, yang = Google, eyes = TRUE, shared_legend = TRUE))
    Output
      <ggtaichi> taichi layers for a ggplot
        yin  : Twitter / Google
        yang : Google
        eyes : on
        scale: shared limits, single legend
      Add it to a plot: ggplot(data, aes(x, y)) + geom_taichi(...)

---

    Code
      print(geom_taichi(yin = Twitter, yang = Google, explicit = "log_ratio",
        explicit_channel = "angle", interactive = TRUE, data_id_by = "source"))
    Output
      <ggtaichi> taichi layers for a ggplot
        yin  : Twitter
        yang : Google
        eyes : off
        gap  : log_ratio -> angle
        hover: interactive, highlighting by source
      Add it to a plot: ggplot(data, aes(x, y)) + geom_taichi(...)

# geom_taichi_diff() prints a summary too

    Code
      print(geom_taichi_diff(yin = matcha, yang = espresso))
    Output
      <ggtaichi> difference tiles for a ggplot
        statistic: matcha - espresso
        midpoint : 0
      Add it to a plot: ggplot(data, aes(x, y)) + geom_taichi_diff(...)

---

    Code
      print(geom_taichi_diff(yin = matcha, yang = espresso, method = "ratio"))
    Output
      <ggtaichi> difference tiles for a ggplot
        statistic: matcha / espresso
        midpoint : 1
      Add it to a plot: ggplot(data, aes(x, y)) + geom_taichi_diff(...)

# the palette check prints its measurements

    Code
      print(taichi_check_palette())
    Output
      <ggtaichi palette check>
      
        step yin            L      C   yang           L      C       dL
        1    #FFFFFF    100.0    0.0   #FED7D8     89.2   14.5     10.8
        2    #EBEBEB     93.0    0.0   #FFB2B3     79.8   30.2     13.2
        3    #D8D8D8     86.3    0.0   #FE8C91     70.8   46.6     15.6
        4    #AAAAAA     69.6    0.0   #F9787D     65.8   53.9      3.8
        5    #7F7F7F     53.2    0.0   #F4636B     61.0   61.4     -7.8
        6    #6B6B6B     45.2    0.0   #EE4B54     55.9   70.0    -10.7
        7    #595959     37.8    0.0   #E62C3F     50.7   78.1    -12.8
        8    #2D2D2D     18.5    0.0   #D41D31     45.8   77.1    -27.3
        9    #000000      0.0    0.0   #C10724     40.6   75.7    -40.6
      
        largest luminance mismatch : 40.6 L* (tolerance 5.0)
        largest chroma mismatch    : 78.1
        how far apart the ramps stay (median distance, step for step)
            normal       27.2  
            deutan       20.9  
            protan       12.7  (much worse than normal vision)
            tritan       28.4  
      
        Verdict: FAIL
        the two ramps do not share a luminance trajectory, so equal
        values do NOT read as equal ink and one fish will appear to
        dominate. Consider `palette = "balanced"` or `taichi_palette_pair()`.

---

    Code
      print(taichi_check_palette(palette = "balanced"))
    Output
      <ggtaichi palette check>
      
        step yin            L      C   yang           L      C       dL
        1    #DEE3EC     90.1    5.0   #EDDFDE     89.9    5.1      0.2
        2    #C5CDDE     82.3    9.4   #E0C7C5     82.2    9.4      0.0
        3    #ADB8D1     74.7   13.9   #D2B1AC     74.9   13.1     -0.2
        4    #95A4C3     67.2   17.7   #C49A95     67.3   17.2     -0.1
        5    #7D91B6     59.9   21.7   #B6857E     60.1   21.0     -0.2
        6    #647EA9     52.4   25.9   #A76F66     52.4   25.4     -0.1
        7    #4A6C9D     45.1   30.4   #98594E     44.8   30.3      0.3
        8    #2F5A93     37.9   36.1   #894433     37.3   36.5      0.6
        9    #004888     30.4   41.6   #792E19     29.6   43.2      0.8
      
        largest luminance mismatch : 0.8 L* (tolerance 5.0)
        largest chroma mismatch    : 1.5
        how far apart the ramps stay (median distance, step for step)
            normal       26.4  
            deutan       27.7  
            protan       22.9  
            tritan       40.3  
      
        Verdict: PASS
        the two ramps share a luminance trajectory, so equal values
        read as equal ink.

# the argument errors say which argument and what to do

    Code
      geom_taichi(yang = Google)
    Condition
      Error in `geom_taichi()`:
      ! `yin` is required. Please specify the column for the yin fish.

---

    Code
      geom_taichi(yin = Twitter)
    Condition
      Error in `geom_taichi()`:
      ! `yang` is required. Please specify the column for the yang fish.

---

    Code
      geom_taichi(yin = NULL, yang = Google)
    Condition
      Error in `geom_taichi()`:
      ! `yin` must be a column, not NULL.

---

    Code
      geom_taichi(yin = a, yang = b, eyes = "yes")
    Condition
      Error in `geom_taichi()`:
      ! `eyes` must be TRUE or FALSE.

---

    Code
      geom_taichi(yin = a, yang = b, palette = "balanced", yin_colors = "red")
    Condition
      Error in `geom_taichi()`:
      ! Supply either `palette` or `yin_colors` / `yang_colors`, not both.

---

    Code
      geom_taichi(yin = a, yang = b, palette = 42)
    Condition
      Error in `as_palette_pair()`:
      ! `palette` must be one of "default", "balanced", "diverging", "viridis_pair", "brewer_pair", "print_safe", or a list with `yin` and `yang` colour vectors (see `taichi_palette_pair()`).

---

    Code
      geom_taichi(yin = a, yang = b, explicit = "difference", explicit_channel = "angle",
        angle = 30)
    Condition
      Error in `geom_taichi()`:
      ! `explicit_channel = "angle"` drives the same channel as `angle`; drop one of them.

---

    Code
      geom_taichi(yin = a, yang = b, explicit = "difference", eyes = FALSE)
    Condition
      Error in `geom_taichi()`:
      ! `explicit_channel = "eye_size"` needs the eyes; drop `eyes = FALSE` or pick another `explicit_channel`.

---

    Code
      geom_taichi(yin = a, yang = b, explicit = "difference", explicit_range = 1)
    Condition
      Error in `geom_taichi()`:
      ! `explicit_range` must be two numbers, or NULL.

---

    Code
      geom_taichi(yin = a, yang = b, tooltip = lab)
    Condition
      Error in `geom_taichi()`:
      ! `tooltip` only has an effect with `interactive = TRUE`.

---

    Code
      geom_taichi(yin = a, yang = b, yin_scale = "viridis")
    Condition
      Error in `check_scale_arg()`:
      ! `yin_scale` must be a fill scale object (e.g. `scale_fill_viridis_c()`) or a scale constructor function (e.g. `scale_fill_viridis_c`), not character.

---

    Code
      geom_taichi(yin = a, yang = b, name = "x")
    Condition
      Error in `geom_taichi()`:
      ! `name` cannot be passed through `...`; use `yin_name` / `yang_name` instead.

# a column that is not there is named at + time

    Code
      ggplot(d, aes(x, y)) + geom_taichi(yin = nope, yang = yang)
    Condition
      Error in `resolve_values()`:
      ! Column `nope` (supplied to `yin`) was not found in the plot data.

# mismatched source types warn rather than pretending to share

    Code
      p <- ggplot(dd, aes(x, y)) + geom_taichi(yin = a, yang = b, shared_limits = TRUE)
    Condition
      Warning:
      `shared_limits` needs `yin` and `yang` to be of the same type (both continuous or both discrete); ignoring it.

# a ratio of a non-positive value warns before it becomes NA

    Code
      ggplot_build(ggplot(dd, aes(x, y)) + geom_taichi(yin = a, yang = b, explicit = "ratio"))$
        data[[1]]$eye_size
    Condition
      Warning:
      A ratio needs two positive values: 1 cell has a zero or negative `yin` / `yang` and became NA. Consider `"difference"` or `"z"` instead.
      Warning:
      A ratio needs two positive values: 1 cell has a zero or negative `yin` / `yang` and became NA. Consider `"difference"` or `"z"` instead.
    Output
      [1] 0.1  NA 0.3

# the deprecated size argument still says what replaced it

    Code
      obj <- geom_taichi(yin = a, yang = b, size = 2)
    Condition
      Warning:
      The `size` argument of `geom_taichi()` is deprecated as of ggtaichi 0.2.0; please use `linewidth` instead.

# taichi_summary() errors point at the column

    Code
      taichi_summary(d, yin = nope, yang = yang)
    Condition
      Error in `pull()`:
      ! Column `nope` (supplied to `yin`) was not found in `data`.

---

    Code
      taichi_summary(1:3, yin = a, yang = b)
    Condition
      Error in `taichi_summary()`:
      ! `data` must be a data frame.

# the palette helpers explain what they will accept

    Code
      taichi_palette_pair(n = 1)
    Condition
      Error in `taichi_palette_pair()`:
      ! `n` must be a single number of 2 or more.

---

    Code
      taichi_palette_pair(hues = 1)
    Condition
      Error in `taichi_palette_pair()`:
      ! `hues` must be two numbers, `c(yin, yang)`.

---

    Code
      taichi_check_palette("notacolour")
    Condition
      Error in `check_colours()`:
      ! `yin_colors` is not a valid colour vector: invalid color name 'notacolour'

---

    Code
      taichi_check_palette("red", palette = "balanced")
    Condition
      Error in `taichi_check_palette()`:
      ! Supply either `palette` or `yin_colors` / `yang_colors`, not both.

