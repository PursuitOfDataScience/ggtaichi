# Ready-made palette pairs

The named palette pairs that
[`geom_taichi()`](https://pursuitofdatascience.github.io/ggtaichi/reference/geom_taichi.md)'s
`palette` argument accepts, available on their own so they can be
inspected, checked with
[`taichi_check_palette()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_check_palette.md),
or used with the individual fish geoms.

## Usage

``` r
taichi_palette(name = "balanced", n = 5)
```

## Arguments

- name:

  Name of the preset: one of `"default"`, `"balanced"`, `"diverging"`,
  `"viridis_pair"`, `"brewer_pair"`, `"print_safe"`.

- n:

  Number of colours per ramp; ramps of a fixed length are interpolated
  (in Lab space) when `n` differs from their natural length.

## Value

A list of two character vectors of hex colours, `yin` and `yang`.

## The presets

- `"default"`:

  The package's own grey yin / seal-red yang ramps — the look of every
  ggtaichi release so far. It is *not* luminance matched (the grey ramp
  spans the full range, the red one does not); run
  [`taichi_check_palette()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_check_palette.md)
  to see by how much. Kept as the default for continuity, not because it
  is the most defensible choice.

- `"balanced"`:

  Two HCL ramps from
  [`taichi_palette_pair()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_palette_pair.md),
  matched in luminance and chroma and separated only by hue (blue yin,
  brick-red yang). The recommended choice when the two sources are
  directly comparable.

- `"diverging"`:

  As `"balanced"`, but both ramps reach a shared near-white light end,
  so the two fish read as the two arms of one diverging scale. Use it
  with `shared_limits = TRUE`.

- `"viridis_pair"`:

  The Mako and Rocket ramps, reversed to run light to dark. They come
  from the same generator and are close to luminance matched, and each
  ramp on its own stays ordered under colour-vision deficiency. The two
  are harder to tell apart from *each other* under red-green deficiency
  than `"balanced"` is, though — run
  `taichi_check_palette(palette = "viridis_pair")` and look at the
  protan row before choosing it.

- `"brewer_pair"`:

  ColorBrewer's sequential Blues and Oranges. Familiar and
  print-friendly; less exactly matched than `"balanced"`.

- `"print_safe"`:

  A grey yin ramp and a hued yang ramp on the *same* luminance
  trajectory. In colour the two fish are told apart by hue; in greyscale
  they collapse to the same ink, so equal values still read as equal —
  the two sources are then distinguished by their position in the glyph
  (yin is the top bulb, yang the bottom). The right choice for a journal
  figure that may be printed in black and white.

## See also

[`taichi_palette_pair()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_palette_pair.md),
[`taichi_check_palette()`](https://pursuitofdatascience.github.io/ggtaichi/reference/taichi_check_palette.md)

## Examples

``` r
taichi_palette("balanced")
#> $yin
#> [1] "#DEE3ED" "#AEB9D1" "#7D91B6" "#4A6C9D" "#004989"
#> 
#> $yang
#> [1] "#EEDFDE" "#D2B1AD" "#B6857E" "#985A4F" "#7A2F19"
#> 
taichi_palette("print_safe", n = 3)
#> $yin
#> [1] "#F1F1F1" "#919191" "#3B3B3B"
#> 
#> $yang
#> [1] "#FDEDEB" "#B8847C" "#701F00"
#> 

# every preset, measured
for (p in c("default", "balanced", "diverging", "viridis_pair",
            "brewer_pair", "print_safe")) {
  cat(p, ": max |dL| = ",
      round(taichi_check_palette(palette = p)$max_luminance_diff, 1),
      "\n", sep = "")
}
#> default: max |dL| = 40.6
#> balanced: max |dL| = 0.8
#> diverging: max |dL| = 0.8
#> viridis_pair: max |dL| = 7.1
#> brewer_pair: max |dL| = 4.2
#> print_safe: max |dL| = 0.6
```
