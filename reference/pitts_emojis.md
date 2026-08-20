# Popular Emojis

The most popular emoji of a given week in a given category from the
Meltwater Tweet sample, as HTML `<img>` tags. The vector is aligned
row-for-row with
[`pitts_tg`](https://pursuitofdatascience.github.io/ggtaichi/reference/pitts_tg.md),
so `pitts_emojis[i]` is the emoji for the `week` / `category`
combination in row `i` of that data set. The tags are meant to be drawn
as rich text, e.g. with `ggtext::geom_richtext()` or
`annotate("richtext", ...)`.

## Usage

``` r
pitts_emojis
```

## Format

A character vector of 270 HTML `<img>` tags (90 distinct emoji), one per
row of
[`pitts_tg`](https://pursuitofdatascience.github.io/ggtaichi/reference/pitts_tg.md).

## Source

The most frequent emoji per week and category in the Meltwater Twitter
sample described in
[`pitts_tg`](https://pursuitofdatascience.github.io/ggtaichi/reference/pitts_tg.md),
processed by the package author.

## Note on the image URLs

Each tag points at a remotely hosted PNG on the Emojipedia asset host
used when the data was collected in 2020. Those objects are no longer
served publicly, so the tags no longer render as pictures on their own.
The emoji each tag refers to is still readable from its file name, which
ends in the Unicode code point (for example `thinking-face_1f914.png` is
U+1F914); substitute your own image paths or the literal emoji
characters to draw them.
