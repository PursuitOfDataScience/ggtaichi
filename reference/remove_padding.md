# Remove ggplot2 default padding

ggplot2 pads both continuous and discrete axes with a little expansion,
which can make a taichi grid look like it is floating.
\`remove_padding()\` trims that space. Called with no arguments it
inspects the plot it is added to and figures out for itself whether each
axis is continuous or discrete; pass \`"c"\` (continuous) or \`"d"\`
(discrete) explicitly to override the detection, e.g. when the axis
mapping is a computed expression the plot data cannot answer for.

## Usage

``` r
remove_padding(x = NULL, y = NULL, ...)
```

## Arguments

- x, y:

  \`NULL\` (the default) to auto-detect the scale type of that axis from
  the plot's data and mapping, \`"c"\` for a continuous axis, or \`"d"\`
  for a discrete one.

- ...:

  Additional arguments passed on to the underlying
  \[ggplot2::scale_x_continuous()\] / \[ggplot2::scale_x_discrete()\]
  (and y) calls.

## Value

An object that, added to a ggplot, replaces both position scales with
padding-free ones.

## Examples

``` r
library(ggplot2)
d <- data.frame(x = 1:3, y = c("a", "b", "c"), yin = 1:3, yang = 3:1)

# auto-detects x as continuous and y as discrete
ggplot(d, aes(x, y)) +
  geom_taichi(yin = yin, yang = yang) +
  remove_padding()


# explicit override, identical result here
ggplot(d, aes(x, y)) +
  geom_taichi(yin = yin, yang = yang) +
  remove_padding(x = "c", y = "d")
```
