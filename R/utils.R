# Small internal helpers shared across the package.

# Mix two colours in sRGB, the same construction ggplot2 4.0 uses for the
# theme-aware geom defaults it builds out of `ink` and `paper`. Defined here
# rather than borrowed so that the theme-aware default_aes expressions in
# zzz.R resolve inside this namespace, and so that the package keeps working
# on ggplot2 3.4 where no such helper exists.
#
# mix_ink("black", "white", 0.2) is "#333333", i.e. grey20, which is exactly
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

# A legend title as plain text. ggplot2 takes an expression or a call
# (plotmath, e.g. `bquote(mu * g)`) as a title, and cat(), paste() and a
# tooltip take neither: cat() refuses an expression outright, and a call
# injected into a tooltip quosure would be evaluated rather than shown.
label_text <- function(x) {
  if (is.expression(x) || is.language(x)) {
    parts <- if (is.expression(x)) as.list(x) else list(x)
    return(paste(vapply(parts, function(e) paste(deparse(e), collapse = " "),
                        character(1)), collapse = "; "))
  }
  paste(as.character(x), collapse = " ")
}

# do.call() evaluates any symbol or call among its arguments, so a plotmath
# title such as `yin_name = bquote(mu * g)` would be run instead of passed on.
# Quote just those; every other argument goes through as the value it already
# is. (quote = TRUE would do the same, but then every argument reads
# `base::quote(...)` in any error message the callee raises.)
do_call_quoted <- function(what, args) {
  args <- lapply(args, function(a) if (is.language(a)) call("quote", a) else a)
  do.call(what, args)
}

# TRUE or FALSE and nothing else. isTRUE() reads anything else as FALSE, which
# is how a mistyped flag (`eyes = "yes"`) switches a feature off without a
# word.
check_flag <- function(value, arg, call = rlang::caller_env()) {
  if (!rlang::is_bool(value)) {
    rlang::abort(paste0("`", arg, "` must be TRUE or FALSE."), call = call)
  }
  invisible(value)
}

# A theme need not have a background. theme_void() and any theme built with
# `rect = element_blank()` leave `paper` fully transparent, and both of the
# places ggtaichi reads it then misbehave: a transparent yin eye is an
# invisible eye, and mixing a fill towards a transparent paper darkens it
# instead of lightening it. Treat an alpha-zero colour as absent and fall back
# to the concrete colour the output will almost always be viewed against.
solid_colour <- function(col, fallback) {
  if (length(col) != 1 || is.na(col)) return(fallback)
  alpha <- tryCatch(grDevices::col2rgb(col, alpha = TRUE)[4, 1],
                    error = function(e) 255)
  if (alpha == 0) fallback else col
}
