# Measure whether two fill ramps are a fair pair

The taichi's whole purpose is to compare two sources inside one mark,
and the fills are what carries the comparison. If the two ramps do not
span the same luminance range then equal values do not produce equal
visual weight, and one fish appears to dominate wherever the data says
the two sources are level. `taichi_check_palette()` measures that, so
the question can be settled with numbers instead of taste.

## Usage

``` r
taichi_check_palette(
  yin_colors = NULL,
  yang_colors = NULL,
  n = 9,
  palette = NULL,
  tolerance = 5
)
```

## Arguments

- yin_colors, yang_colors:

  The two colour vectors to compare. Defaults to the package's built-in
  ramps (or, if `palette` is given, to that preset's ramps).

- n:

  Number of steps at which to sample each ramp. Nine gives a readable
  table and catches mid-ramp problems that the control points alone
  would hide.

- palette:

  Optionally the name of a preset (see
  [`taichi_palette()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_palette.md))
  or a list with `yin` and `yang` elements, checked instead of
  `yin_colors` / `yang_colors`.

- tolerance:

  Largest luminance difference, in L\\ units, still counted as a pass.

## Value

An object of class `taichi_palette_check`, with a
[`print()`](https://rdrr.io/r/base/print.html) method that lays the
measurements out as a table. It is a list with elements `steps` (a data
frame of per-step colours, luminance and chroma), `max_luminance_diff`,
`max_chroma_diff`, `monotone` (a logical pair), `verdict` (`"pass"`,
`"warning"` or `"fail"`), `cvd` (a data frame of median step-wise colour
distances for normal vision and each simulation, or `NULL` when
colorspace is not installed) and `tolerance`.

## Details

Called with no arguments it measures the package's own defaults, which
is worth doing once: the default grey yin ramp spans the full luminance
range (100 down to 0) while the default red yang ramp spans roughly 89
to 41, a mismatch of about 41 L\\ units at the dark end. The defaults
are kept for continuity, but `palette = "balanced"` (or any pair from
[`taichi_palette_pair()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_palette_pair.md))
is the more defensible choice for a published comparison.

## How the verdict is decided

Both ramps are resampled to `n` steps in Lab space — the space ggplot2's
gradient scales interpolate in — and each step's CIE L\\ (luminance) and
chroma are recorded. The reported mismatch is the largest absolute
luminance difference between corresponding steps. The verdict is
`"pass"` below `tolerance` L\\ units (default 5, around the point where
a difference between two large patches becomes noticeable), `"warning"`
up to three times that, and `"fail"` above it. A ramp whose luminance is
not monotone is reported separately: a sequential fill that lightens and
then darkens has no readable order, whatever its match.

When colorspace is installed, the two ramps are also simulated under
deuteranopia, protanopia and tritanopia, and the median CIE2000 distance
between corresponding steps is reported for each, alongside the same
figure for normal vision. Read it as a comparison: a simulation much
below the normal-vision row means the deficiency is costing those
readers the distinction, and anything below about 10 means the two fish
are not tellable apart at all. The median rather than the minimum is
deliberate — two luminance-matched ramps necessarily converge at their
pale end, where both are near white, and a minimum would report that as
a fault of every well-matched pair.

## See also

[`taichi_palette_pair()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_palette_pair.md)
to build a matched pair,
[`taichi_palette()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_palette.md)
for the presets.

## Examples

``` r
# the package defaults, measured honestly
taichi_check_palette()
#> <ggtaichi palette check>
#> 
#>   step yin            L      C   yang           L      C       dL
#>   1    #FFFFFF    100.0    0.0   #FED7D8     89.2   14.5     10.8
#>   2    #EBEBEB     93.0    0.0   #FFB2B3     79.8   30.2     13.2
#>   3    #D8D8D8     86.3    0.0   #FE8C91     70.8   46.6     15.6
#>   4    #AAAAAA     69.6    0.0   #F9787D     65.8   53.9      3.8
#>   5    #7F7F7F     53.2    0.0   #F4636B     61.0   61.4     -7.8
#>   6    #6B6B6B     45.2    0.0   #EE4B54     55.9   70.0    -10.7
#>   7    #595959     37.8    0.0   #E62C3F     50.7   78.1    -12.8
#>   8    #2D2D2D     18.5    0.0   #D41D31     45.8   77.1    -27.3
#>   9    #000000      0.0    0.0   #C10724     40.6   75.7    -40.6
#> 
#>   largest luminance mismatch : 40.6 L* (tolerance 5.0)
#>   largest chroma mismatch    : 78.1
#>   how far apart the ramps stay (median distance, step for step)
#>       normal       27.2  
#>       deutan       20.9  
#>       protan       12.7  (much worse than normal vision)
#>       tritan       28.4  
#> 
#>   Verdict: FAIL
#>   the two ramps do not share a luminance trajectory, so equal
#>   values do NOT read as equal ink and one fish will appear to
#>   dominate. Consider `palette = "balanced"` or `taichi_palette_pair()`.

# a matched pair
taichi_check_palette(palette = "balanced")
#> <ggtaichi palette check>
#> 
#>   step yin            L      C   yang           L      C       dL
#>   1    #DEE3EC     90.1    5.0   #EDDFDE     89.9    5.1      0.2
#>   2    #C5CDDE     82.3    9.4   #E0C7C5     82.2    9.4      0.0
#>   3    #ADB8D1     74.7   13.9   #D2B1AC     74.9   13.1     -0.2
#>   4    #95A4C3     67.2   17.7   #C49A95     67.3   17.2     -0.1
#>   5    #7D91B6     59.9   21.7   #B6857E     60.1   21.0     -0.2
#>   6    #647EA9     52.4   25.9   #A76F66     52.4   25.4     -0.1
#>   7    #4A6C9D     45.1   30.4   #98594E     44.8   30.3      0.3
#>   8    #2F5A93     37.9   36.1   #894433     37.3   36.5      0.6
#>   9    #004888     30.4   41.6   #792E19     29.6   43.2      0.8
#> 
#>   largest luminance mismatch : 0.8 L* (tolerance 5.0)
#>   largest chroma mismatch    : 1.5
#>   how far apart the ramps stay (median distance, step for step)
#>       normal       26.4  
#>       deutan       27.7  
#>       protan       22.9  
#>       tritan       40.3  
#> 
#>   Verdict: PASS
#>   the two ramps share a luminance trajectory, so equal values
#>   read as equal ink.
```
