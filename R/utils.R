# Small internal helpers shared across the package.

# Mix two colours in sRGB, the same construction ggplot2 4.0 uses for the
# theme-aware geom defaults it builds out of `ink` and `paper`. Defined here
# rather than borrowed so that the theme-aware default_aes expressions in
# zzz.R resolve inside this namespace, and so that the package keeps working
# on ggplot2 3.4 where no such helper exists.
#
# mix_ink("black", "white", 0.2) is "#333333", i.e. grey20 -- which is exactly
# the fallback fill ggtaichi has always used. That is the point: following the
# theme costs nothing on a light theme and makes the geoms visible on a dark
# one.
mix_ink <- function(a, b, amount = 0.5) {
  if (length(a) == 0 || length(b) == 0) return(a)
  if (all(is.na(a))) return(a)
  if (all(is.na(b))) return(a)
  m <- (1 - amount) * grDevices::col2rgb(a, alpha = TRUE) +
    amount * grDevices::col2rgb(b, alpha = TRUE)
  grDevices::rgb(m[1, ], m[2, ], m[3, ], m[4, ], maxColorValue = 255)
}

# TRUE when the installed ggplot2 understands from_theme() and
# theme(geom = element_geom(...)), i.e. 4.0.0 or later. ggtaichi keeps its
# ggplot2 floor at 3.4.0 and degrades instead of forcing the upgrade, so this
# is checked rather than assumed.
has_themed_aes <- function() {
  isTRUE(utils::packageVersion("ggplot2") >= "4.0.0") &&
    "from_theme" %in% getNamespaceExports("ggplot2")
}
