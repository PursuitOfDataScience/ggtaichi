#' Summarise the two sources cell by cell
#'
#' A taichi grid is a *superposition* comparison: the two sources share one
#' position, which makes "are these similar?" and "which is bigger here?" easy
#' to see and "by how much?" impossible. `taichi_summary()` is the tidy answer
#' to the last question --- the numbers behind the glyph, one row per input
#' row, for the reader who needs a table rather than a picture.
#'
#' @section The statistics:
#' \describe{
#'   \item{`difference`}{`yin - yang`. Positive means the yin fish (the top
#'     bulb) carries the larger value.}
#'   \item{`ratio`}{`yin / yang`, and `NA` wherever either value is not
#'     strictly positive --- a ratio of a negative or zero quantity is not a
#'     ratio, and `Inf` is never returned.}
#'   \item{`log_ratio`}{`log2(yin / yang)`, so a value of 1 means yin is twice
#'     yang and -1 means half. Symmetric around zero, which `ratio` is not,
#'     and the right choice when the two sources span orders of magnitude.}
#'   \item{`z`}{The difference of the two standardised sources: each column is
#'     centred and scaled across the whole grid, then subtracted. This is the
#'     statistic to use when the two sources are *not* in the same units,
#'     because it asks "which source is unusually high here, relative to its
#'     own spread?" rather than "which number is bigger?".}
#'   \item{`dominant`}{Which source is larger in that cell, named after the
#'     columns supplied, or `"tie"`.}
#'   \item{`rank`}{The cell's rank by size of `abs(difference)`, 1 being the
#'     widest gap. Cells with a missing difference get `NA`.}
#' }
#'
#' @section A caveat on `rank`:
#' A grid of 96 cells is 96 implicit comparisons, and the most extreme cell in
#' a grid that size is frequently the most extreme *noise* rather than the
#' largest real effect. Treat `rank` as a list of places to look, not as a
#' list of findings: taking the top-ranked cell and reporting it is the
#' multiple-comparisons problem in miniature. With one observation per cell
#' there is no per-cell test to correct with, so the honest check is on the
#' field as a whole.
#'
#' @param data A data frame, the same one passed to [ggplot2::ggplot()].
#' @param yin,yang Unquoted column names (or strings naming columns) for the
#'   two sources, exactly as in [geom_taichi()].
#' @param x,y Optional unquoted column names identifying each cell. When
#'   given they are carried through to the output as the first columns, which
#'   makes the result joinable back onto the plotting data.
#'
#' @return A data frame with one row per row of `data`: the optional `x` and
#'   `y` cell identifiers, `yin`, `yang`, `difference`, `ratio`, `log_ratio`,
#'   `z`, `dominant` and `rank`.
#' @seealso [geom_taichi()]'s `explicit` argument, which shows one of these
#'   statistics inside the glyph, and [geom_taichi_diff()], which draws it as
#'   a diverging heatmap.
#' @export
#' @examples
#' summ <- taichi_summary(cafes_tg, yin = matcha, yang = espresso,
#'                        x = week, y = neighbourhood)
#' head(summ)
#'
#' # the five widest gaps -- places to look, not findings; see the caveat above
#' head(summ[order(summ$rank), ], 5)
taichi_summary <- function(data, yin, yang, x = NULL, y = NULL) {
  if (!is.data.frame(data)) {
    rlang::abort("`data` must be a data frame.")
  }
  yin_quo <- as_column_quo(rlang::enquo(yin))
  yang_quo <- as_column_quo(rlang::enquo(yang))
  if (rlang::quo_is_missing(yin_quo) || rlang::quo_is_null(yin_quo)) {
    rlang::abort("`yin` is required and must be a column of `data`.")
  }
  if (rlang::quo_is_missing(yang_quo) || rlang::quo_is_null(yang_quo)) {
    rlang::abort("`yang` is required and must be a column of `data`.")
  }
  x_quo <- as_column_quo(rlang::enquo(x))
  y_quo <- as_column_quo(rlang::enquo(y))

  pull <- function(quo, arg) {
    vals <- tryCatch(rlang::eval_tidy(quo, data), error = function(e) e)
    if (inherits(vals, "error")) {
      rlang::abort(paste0(
        "Column `", rlang::as_label(quo), "` (supplied to `", arg,
        "`) was not found in `data`."
      ))
    }
    vals
  }

  yin_vals <- pull(yin_quo, "yin")
  yang_vals <- pull(yang_quo, "yang")
  if (!is.numeric(yin_vals) || !is.numeric(yang_vals)) {
    rlang::abort(paste0(
      "`taichi_summary()` needs numeric `yin` and `yang` columns; ",
      "`", rlang::as_label(yin_quo), "` and `", rlang::as_label(yang_quo),
      "` are not both numeric."
    ))
  }

  diff <- yin_vals - yang_vals
  out <- data.frame(
    yin = yin_vals,
    yang = yang_vals,
    difference = diff,
    ratio = safe_ratio(yin_vals, yang_vals, warn = FALSE),
    log_ratio = log2(safe_ratio(yin_vals, yang_vals, warn = FALSE)),
    z = zscore(yin_vals) - zscore(yang_vals),
    dominant = factor(
      ifelse(is.na(diff), NA_character_,
             ifelse(diff > 0, rlang::as_label(yin_quo),
                    ifelse(diff < 0, rlang::as_label(yang_quo), "tie"))),
      levels = c(rlang::as_label(yin_quo), rlang::as_label(yang_quo), "tie")
    ),
    rank = rank_by_gap(diff),
    stringsAsFactors = FALSE
  )

  if (!rlang::quo_is_null(y_quo)) {
    out <- cbind(y = pull(y_quo, "y"), out, stringsAsFactors = FALSE)
  }
  if (!rlang::quo_is_null(x_quo)) {
    out <- cbind(x = pull(x_quo, "x"), out, stringsAsFactors = FALSE)
  }
  out
}


#' The difference between the two sources, as a heatmap
#'
#' Sometimes the right chart for "how much bigger?" is not a glyph at all but
#' a diverging heatmap, and a package that offers one next to its signature
#' mark is more useful than one that insists on the mark. `geom_taichi_diff()`
#' computes one of [taichi_summary()]'s statistics per cell and draws it with
#' [ggplot2::geom_tile()] on a diverging scale centred on "the two sources
#' agree".
#'
#' It is the explicit-encoding companion to [geom_taichi()]: same data, same
#' grid, same statistics, but the relationship itself is on the page instead
#' of being left to the reader's eye. Use it beside a taichi grid, not instead
#' of one --- the glyph shows the levels, this shows the gap.
#'
#' @param yin,yang Unquoted column names (or strings naming columns) for the
#'   two sources, as in [geom_taichi()].
#' @param method Which statistic to draw: `"difference"` (`yin - yang`, the
#'   default), `"ratio"`, `"log_ratio"` or `"z"`. See [taichi_summary()] for
#'   the definitions; `"log_ratio"` is the better choice than `"ratio"`
#'   whenever the two sources span orders of magnitude, because it is
#'   symmetric around agreement.
#' @param palette The diverging colours: the name of a [taichi_palette()]
#'   preset (the yang ramp's dark end becomes the low colour, the yin ramp's
#'   dark end the high colour, so the tile agrees with the glyph), a list with
#'   `yin` and `yang` elements, or a character vector of exactly three
#'   colours giving `low`, `mid` and `high` directly.
#' @param name Legend title. Defaults to a label naming the statistic and the
#'   two columns, e.g. `"matcha - espresso"`.
#' @param midpoint The value that counts as "the sources agree" and is painted
#'   in the mid colour. Defaults to 1 for `"ratio"` and 0 for every other
#'   method.
#' @param symmetric If `TRUE` (the default) the fill limits are made
#'   symmetric about `midpoint`, so the mid colour really does sit at the
#'   centre of the legend and the two directions are coloured comparably.
#'   Set it to `FALSE` to use the plain data range.
#' @param na.value Colour for cells whose statistic is missing --- which
#'   includes every non-positive cell under `"ratio"` and `"log_ratio"`.
#' @param ... Further arguments passed to [ggplot2::geom_tile()], for example
#'   `width`, `height`, `colour` or `linewidth`.
#'
#' @return An object that, added to a [ggplot2::ggplot()] with `+`, draws the
#'   difference tiles and their diverging fill scale. It is not a plot on its
#'   own.
#' @seealso [taichi_summary()] for the same numbers as a table, and
#'   [geom_taichi()]'s `explicit` argument for the in-glyph version.
#' @export
#' @examples
#' library(ggplot2)
#'
#' ggplot(cafes_tg, aes(week, neighbourhood)) +
#'   geom_taichi_diff(yin = matcha, yang = espresso) +
#'   theme_taichi()
#'
#' # log ratio, symmetric about "the two agree"
#' ggplot(cafes_tg, aes(week, neighbourhood)) +
#'   geom_taichi_diff(yin = matcha, yang = espresso, method = "log_ratio") +
#'   theme_taichi()
geom_taichi_diff <- function(yin, yang,
                             method = c("difference", "ratio", "log_ratio",
                                        "z"),
                             palette = "diverging",
                             name = NULL,
                             midpoint = NULL,
                             symmetric = TRUE,
                             na.value = "grey90",
                             ...) {
  if (rlang::quo_is_missing(rlang::enquo(yin))) {
    rlang::abort("`yin` is required. Please specify the column for the yin source.")
  }
  if (rlang::quo_is_missing(rlang::enquo(yang))) {
    rlang::abort("`yang` is required. Please specify the column for the yang source.")
  }
  method <- rlang::arg_match0(
    method, c("difference", "ratio", "log_ratio", "z"), arg_nm = "method"
  )
  if (!rlang::is_bool(symmetric)) {
    rlang::abort("`symmetric` must be TRUE or FALSE.")
  }

  yin_quo <- as_column_quo(rlang::enquo(yin))
  yang_quo <- as_column_quo(rlang::enquo(yang))

  cols <- diverging_colours(palette)
  if (is.null(midpoint)) {
    midpoint <- if (method == "ratio") 1 else 0
  }
  if (!is.numeric(midpoint) || length(midpoint) != 1 || is.na(midpoint)) {
    rlang::abort("`midpoint` must be a single number.")
  }
  if (is.null(name)) {
    name <- explicit_label(method, rlang::as_label(yin_quo),
                           rlang::as_label(yang_quo))
  }

  stat_quo <- rlang::quo(
    taichi_explicit_stat(!!yin_quo, !!yang_quo, !!method)
  )

  result <- list(
    layer = ggplot2::geom_tile(
      mapping = ggplot2::aes(fill = !!stat_quo), ...
    ),
    stat_quo = stat_quo,
    name = name,
    colours = cols,
    midpoint = midpoint,
    symmetric = symmetric,
    na.value = na.value
  )
  class(result) <- c("ggtaichi_diff", "list")
  result
}


#' @export
print.ggtaichi_diff <- function(x, ...) {
  cat("<ggtaichi> difference tiles for a ggplot\n")
  cat("  statistic: ", x$name, "\n", sep = "")
  cat("  midpoint : ", x$midpoint, "\n", sep = "")
  cat("Add it to a plot: ggplot(data, aes(x, y)) + geom_taichi_diff(...)\n")
  invisible(x)
}


#' @export
#' @method ggplot_add ggtaichi_diff
ggplot_add.ggtaichi_diff <- function(object, plot, ...) {
  data <- plot$data
  if (!is.data.frame(data)) data <- NULL

  limits <- NULL
  if (isTRUE(object$symmetric)) {
    vals <- tryCatch(
      suppressWarnings(rlang::eval_tidy(object$stat_quo, data)),
      error = function(e) NULL
    )
    vals <- vals[is.finite(vals)]
    if (length(vals) > 0) {
      span <- max(abs(vals - object$midpoint))
      # An all-agreeing grid has no span to be symmetric about; leave the
      # limits to ggplot2 rather than asking for a zero-width scale.
      if (span > 0) {
        limits <- object$midpoint + c(-span, span)
      }
    }
  }

  scale <- ggplot2::scale_fill_gradient2(
    name = object$name,
    low = object$colours[1], mid = object$colours[2],
    high = object$colours[3],
    midpoint = object$midpoint,
    limits = limits,
    na.value = object$na.value
  )

  plot + object$layer + scale
}


# ---------------------------------------------------------------------------
# The statistics themselves
# ---------------------------------------------------------------------------

explicit_methods <- c("none", "difference", "ratio", "log_ratio", "z")

explicit_channels <- c("eye_size", "angle", "border", "radius")

# The raw explicit statistic for one pair of source columns. Called from
# inside an aes() quosure, so it runs on whatever data the layer is given --
# including replaced data and each facet's rows.
taichi_explicit_stat <- function(yin, yang, method = "difference") {
  if (!is.numeric(yin) || !is.numeric(yang)) {
    rlang::abort(paste0(
      "`explicit` needs numeric `yin` and `yang` columns; a computed ",
      "difference between non-numeric sources is not defined."
    ))
  }
  switch(method,
    difference = yin - yang,
    ratio = safe_ratio(yin, yang),
    log_ratio = log2(safe_ratio(yin, yang)),
    z = zscore(yin) - zscore(yang),
    rlang::abort(paste0("Unknown `explicit` method \"", method, "\"."))
  )
}

# yin / yang, with NA -- never Inf -- wherever the quotient is not a ratio of
# two positive quantities. A silent Inf would sail through the rescaling and
# paint one cell at the extreme of whatever channel it feeds.
safe_ratio <- function(yin, yang, warn = TRUE) {
  bad <- !is.na(yin) & !is.na(yang) & (yin <= 0 | yang <= 0)
  out <- yin / yang
  if (any(bad)) {
    out[bad] <- NA_real_
    if (warn) {
      rlang::warn(paste0(
        "A ratio needs two positive values: ", sum(bad),
        if (sum(bad) == 1) " cell has " else " cells have ",
        "a zero or negative `yin` / `yang` and became NA. Consider ",
        "`\"difference\"` or `\"z\"` instead."
      ))
    }
  }
  out[!is.finite(out) & !is.na(out)] <- NA_real_
  out
}

# Centre and scale across the whole grid. A constant column has no spread to
# standardise by, so it contributes nothing rather than NaN.
zscore <- function(v) {
  s <- stats::sd(v, na.rm = TRUE)
  if (!is.finite(s) || s == 0) return(rep(0, length(v)))
  (v - mean(v, na.rm = TRUE)) / s
}

# Rank cells by how far apart the two sources are, widest gap first.
rank_by_gap <- function(diff) {
  out <- rep(NA_integer_, length(diff))
  ok <- is.finite(diff)
  if (any(ok)) {
    out[ok] <- as.integer(rank(-abs(diff[ok]), ties.method = "min"))
  }
  out
}

explicit_label <- function(method, yin_lab, yang_lab) {
  switch(method,
    difference = paste(yin_lab, "-", yang_lab),
    ratio = paste(yin_lab, "/", yang_lab),
    log_ratio = paste0("log2(", yin_lab, " / ", yang_lab, ")"),
    z = paste("z(", yin_lab, ") - z(", yang_lab, ")"),
    method
  )
}

# Default output range of each explicit channel. eye_size is a proportion of
# the glyph radius; border is a linewidth in mm; radius is a proportion of the
# cell's own radius; angle is degrees, symmetric so that "the two sources
# agree" stays upright.
explicit_default_range <- function(channel) {
  switch(channel,
    eye_size = c(0, 0.3),
    angle = c(-45, 45),
    border = c(0, 1),
    radius = c(0.4, 1)
  )
}

# Turn the raw statistic into channel units.
#
# The signed channel (angle) maps zero to the middle of the range so that an
# upright glyph means agreement; the magnitude channels use the absolute
# statistic, because the sign is already legible from which fish is darker.
# `radius` is the one channel where the eye reads area rather than extent, so
# it is scaled by the square root -- the standard fix for the area-versus-
# diameter error of bubble charts.
rescale_explicit <- function(x, channel, range = NULL, exponent = NULL) {
  range <- range %||% explicit_default_range(channel)
  exponent <- exponent %||% 0.57
  if (!is.numeric(range) || length(range) != 2 || anyNA(range)) {
    rlang::abort("`explicit_range` must be two numbers, or NULL.")
  }
  if (!is.numeric(x)) {
    rlang::abort("The computed `explicit` statistic must be numeric.")
  }

  finite <- x[is.finite(x)]
  signed <- channel == "angle"
  m <- if (length(finite) == 0) 0 else max(abs(finite))

  if (m == 0) {
    # Nothing to show: every cell agrees (or nothing is finite). Return the
    # channel's neutral value rather than dividing by zero -- no tilt, no eye,
    # the thinnest border, the full radius.
    neutral <- switch(channel,
      eye_size = 0, angle = 0, border = min(range), radius = max(range)
    )
    out <- rep(neutral, length(x))
    out[!is.finite(x)] <- if (channel == "eye_size") NA_real_ else neutral
    return(out)
  }

  if (signed) {
    frac <- (x + m) / (2 * m)
    out <- range[1] + frac * (range[2] - range[1])
    out[!is.finite(x)] <- mean(range)
  } else {
    frac <- abs(x) / m
    # Area, not diameter -- but not the naive square root either. Readers
    # systematically underestimate the area ratio between large and small
    # circles, and cartography compensates with an exponent near 0.57
    # (Flannery) rather than 0.5. `radius_exponent` exposes the choice;
    # 0.5 gives strict area scaling.
    if (channel == "radius") frac <- frac^exponent
    out <- range[1] + frac * (range[2] - range[1])
    # A missing statistic is not a zero one: leave the eye off and the rest
    # of the glyph at its neutral value.
    out[!is.finite(x)] <- if (channel == "eye_size") NA_real_ else range[1]
  }
  out
}

# low / mid / high for geom_taichi_diff(): a length-3 colour vector is used
# verbatim, anything else comes from a palette pair, with yang low and yin
# high so the tile's colours agree with the glyph's fish.
diverging_colours <- function(palette) {
  if (is.character(palette) && length(palette) == 3) {
    check_colours(palette, "palette")
    return(palette)
  }
  pair <- as_palette_pair(palette, "palette")
  c(pair$yang[length(pair$yang)],
    mix_ink(pair$yin[1], pair$yang[1], 0.5),
    pair$yin[length(pair$yin)])
}
