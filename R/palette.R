#' Build a luminance-matched pair of sequential palettes
#'
#' The two fish of a taichi symbol are compared *against each other*, so the
#' two fill ramps have to be matched: if one ramp spans a wider luminance
#' range than the other, equal values do not produce equal visual weight and
#' one fish systematically appears to dominate. That makes palette pairing a
#' correctness problem rather than a matter of taste --- see
#' [taichi_check_palette()] for the measurement and `vignette("ggtaichi")`
#' for the discussion.
#'
#' `taichi_palette_pair()` constructs two sequential ramps in the perceptual
#' HCL space that differ **only** in hue: they share one luminance trajectory
#' and one chroma trajectory, so step `i` of the yin ramp and step `i` of the
#' yang ramp carry the same visual weight.
#'
#' @param n Number of colours per ramp. The default, 5, matches the length of
#'   the built-in `yin_colors` / `yang_colors` vectors.
#' @param hues Two hues in degrees, `c(yin, yang)`, on the HCL colour wheel
#'   (0 red, 120 green, 250 blue). Pick hues far apart; opposite hues
#'   (a difference near 180) are the most distinguishable.
#' @param luminance The two ends of the shared luminance trajectory as
#'   `c(dark, light)`, on the CIE L\* scale from 0 (black) to 100 (white).
#'   Both ramps run from the light end to the dark end, so the first colour
#'   belongs to the lowest value --- the same convention as `yin_colors` /
#'   `yang_colors`.
#' @param chroma Chroma (colourfulness) at the dark end of each ramp. Chroma
#'   tapers towards the light end, because a very light colour cannot also be
#'   saturated; both ramps taper identically. Values above about 80 will be
#'   clipped to the sRGB gamut, and clipping is hue-dependent, which is
#'   exactly what breaks the match --- keep it moderate and verify with
#'   [taichi_check_palette()].
#'
#' @return A list of two character vectors of hex colours, `yin` and `yang`,
#'   each of length `n`. Pass them straight to [geom_taichi()] as
#'   `yin_colors` / `yang_colors`, or hand the whole list to its `palette`
#'   argument.
#' @seealso [taichi_check_palette()] to measure any pair,
#'   [taichi_palette()] for the ready-made presets.
#' @export
#' @examples
#' pair <- taichi_palette_pair()
#' pair
#'
#' # the pair is matched by construction; the package defaults are not
#' taichi_check_palette(pair$yin, pair$yang)
#'
#' library(ggplot2)
#' d <- data.frame(x = rep(1:3, 3), y = rep(1:3, each = 3),
#'                 yin = 1:9, yang = 9:1)
#' ggplot(d, aes(x, y)) +
#'   geom_taichi(yin = yin, yang = yang, palette = pair, shared_limits = TRUE)
taichi_palette_pair <- function(n = 5, hues = c(250, 20),
                                luminance = c(30, 90), chroma = 60) {
  if (!is.numeric(n) || length(n) != 1 || is.na(n) || n < 2) {
    rlang::abort("`n` must be a single number of 2 or more.")
  }
  n <- as.integer(n)
  if (!is.numeric(hues) || length(hues) != 2 || anyNA(hues)) {
    rlang::abort("`hues` must be two numbers, `c(yin, yang)`.")
  }
  if (!is.numeric(luminance) || length(luminance) != 2 || anyNA(luminance)) {
    rlang::abort("`luminance` must be two numbers, `c(dark, light)`.")
  }
  if (!is.numeric(chroma) || length(chroma) != 1 || is.na(chroma) ||
      chroma < 0) {
    rlang::abort("`chroma` must be a single non-negative number.")
  }

  dark <- min(luminance)
  light <- max(luminance)
  # Light to dark, matching the yin_colors / yang_colors convention.
  l <- seq(light, dark, length.out = n)
  # A single shared chroma trajectory: full chroma at the dark end, tapering
  # to a token amount at the light end, where high chroma is out of gamut.
  frac <- if (light == dark) rep(0, n) else (l - dark) / (light - dark)
  cvec <- chroma * (0.15 + 0.85 * (1 - frac))

  list(
    yin  = grDevices::hcl(h = hues[1], c = cvec, l = l, fixup = TRUE),
    yang = grDevices::hcl(h = hues[2], c = cvec, l = l, fixup = TRUE)
  )
}


#' Ready-made palette pairs
#'
#' The named palette pairs that [geom_taichi()]'s `palette` argument accepts,
#' available on their own so they can be inspected, checked with
#' [taichi_check_palette()], or used with the individual fish geoms.
#'
#' @section The presets:
#' \describe{
#'   \item{`"default"`}{The package's own grey yin / seal-red yang ramps ---
#'     the look of every ggtaichi release so far. It is *not* luminance
#'     matched (the grey ramp spans the full range, the red one does not);
#'     run `taichi_check_palette()` to see by how much. Kept as the default
#'     for continuity, not because it is the most defensible choice.}
#'   \item{`"balanced"`}{Two HCL ramps from [taichi_palette_pair()], matched
#'     in luminance and chroma and separated only by hue (blue yin, brick-red
#'     yang). The recommended choice when the two sources are directly
#'     comparable.}
#'   \item{`"diverging"`}{As `"balanced"`, but both ramps reach a shared
#'     near-white light end, so the two fish read as the two arms of one
#'     diverging scale. Use it with `shared_limits = TRUE`.}
#'   \item{`"viridis_pair"`}{The Mako and Rocket ramps, reversed to run light
#'     to dark. They come from the same generator and are close to luminance
#'     matched, and each ramp on its own stays ordered under colour-vision
#'     deficiency. The two are harder to tell apart from *each other* under
#'     red-green deficiency than `"balanced"` is, though --- run
#'     `taichi_check_palette(palette = "viridis_pair")` and look at the
#'     protan row before choosing it.}
#'   \item{`"brewer_pair"`}{ColorBrewer's sequential Blues and Oranges.
#'     Familiar and print-friendly; less exactly matched than
#'     `"balanced"`.}
#'   \item{`"greyscale_safe"`}{A grey yin ramp and a hued yang ramp on the
#'     *same* luminance trajectory. In colour the two fish are told apart by
#'     hue; in greyscale they collapse to the same ink, so equal values still
#'     read as equal --- the two sources are then distinguished by their
#'     position in the glyph (yin is the top bulb, yang the bottom). The right
#'     choice for a journal figure that may be printed in black and white.
#'     Note the promise precisely: it is about **greyscale**, not about the
#'     CMYK gamut. A hued ramp can still shift when converted for offset
#'     printing; if that matters, soft-proof the figure.}
#' }
#'
#' @param name Name of the preset: one of `"default"`, `"balanced"`,
#'   `"diverging"`, `"viridis_pair"`, `"brewer_pair"`, `"greyscale_safe"`.
#' @param n Number of colours per ramp; ramps of a fixed length are
#'   interpolated (in Lab space) when `n` differs from their natural length.
#'
#' @return A list of two character vectors of hex colours, `yin` and `yang`.
#' @seealso [taichi_palette_pair()], [taichi_check_palette()]
#' @export
#' @examples
#' taichi_palette("balanced")
#' taichi_palette("greyscale_safe", n = 3)
#'
#' # every preset, measured
#' for (p in c("default", "balanced", "diverging", "viridis_pair",
#'             "brewer_pair", "greyscale_safe")) {
#'   cat(p, ": max |dL| = ",
#'       round(taichi_check_palette(palette = p)$max_luminance_diff, 1),
#'       "\n", sep = "")
#' }
taichi_palette <- function(name = "balanced", n = 5) {
  name <- rlang::arg_match0(name, taichi_palette_names, arg_nm = "name")
  if (!is.numeric(n) || length(n) != 1 || is.na(n) || n < 2) {
    rlang::abort("`n` must be a single number of 2 or more.")
  }
  n <- as.integer(n)

  out <- switch(name,
    default = list(yin = taichi_default_yin_colors,
                   yang = taichi_default_yang_colors),
    balanced = taichi_palette_pair(n, hues = c(250, 20),
                                   luminance = c(30, 90), chroma = 60),
    diverging = taichi_palette_pair(n, hues = c(255, 15),
                                    luminance = c(30, 97), chroma = 70),
    viridis_pair = list(yin = rev(grDevices::hcl.colors(n, "Mako")),
                        yang = rev(grDevices::hcl.colors(n, "Rocket"))),
    brewer_pair = list(
      yin  = c("#EFF3FF", "#BDD7E7", "#6BAED6", "#3182BD", "#08519C"),
      yang = c("#FEEDDE", "#FDBE85", "#FD8D3C", "#E6550D", "#A63603")
    ),
    greyscale_safe = {
      l <- seq(95, 25, length.out = n)
      cvec <- 65 * (0.15 + 0.85 * (1 - (l - 25) / 70))
      list(yin  = grDevices::hcl(h = 0, c = 0, l = l),
           yang = grDevices::hcl(h = 20, c = cvec, l = l, fixup = TRUE))
    }
  )

  lapply(out, function(cols) {
    if (length(cols) == n) cols else interpolate_ramp(cols, n)
  })
}

taichi_palette_names <- c("default", "balanced", "diverging", "viridis_pair",
                          "brewer_pair", "greyscale_safe")

taichi_default_yin_colors <-
  c("gray100", "gray85", "gray50", "gray35", "gray0")
taichi_default_yang_colors <-
  c("#FED7D8", "#FE8C91", "#F5636B", "#E72D3F", "#C20824")

# Resample a ramp to n colours the same way the fill scales will: ggplot2's
# gradient scales interpolate control points in Lab, so measure and resample
# there too.
interpolate_ramp <- function(cols, n) {
  if (length(cols) == 1) return(rep(cols, n))
  grDevices::colorRampPalette(cols, space = "Lab")(n)
}


#' Measure whether two fill ramps are a fair pair
#'
#' The taichi's whole purpose is to compare two sources inside one mark, and
#' the fills are what carries the comparison. If the two ramps do not span the
#' same luminance range then equal values do not produce equal visual weight,
#' and one fish appears to dominate wherever the data says the two sources are
#' level. `taichi_check_palette()` measures that, so the question can be
#' settled with numbers instead of taste.
#'
#' Called with no arguments it measures the package's own defaults, which is
#' worth doing once: the default grey yin ramp spans the full luminance range
#' (100 down to 0) while the default red yang ramp spans roughly 89 to 41, a
#' mismatch of about 41 L\* units at the dark end. The defaults are kept for
#' continuity, but `palette = "balanced"` (or any pair from
#' [taichi_palette_pair()]) is the more defensible choice for a published
#' comparison.
#'
#' @section How the verdict is decided:
#' Both ramps are resampled to `n` steps in Lab space --- the space ggplot2's
#' gradient scales interpolate in --- and each step's CIE L\* (luminance) and
#' chroma are recorded. The reported mismatch is the largest absolute
#' luminance difference between corresponding steps. The verdict is
#' `"pass"` below `tolerance` L\* units (default 5, around the point where a
#' difference between two large patches becomes noticeable), `"warning"` up to
#' three times that, and `"fail"` above it. A ramp whose luminance is not
#' monotone is reported separately: a sequential fill that lightens and then
#' darkens has no readable order, whatever its match.
#'
#' When \pkg{colorspace} is installed, the two ramps are also simulated under
#' deuteranopia, protanopia and tritanopia, and the median CIE2000 distance
#' between corresponding steps is reported for each, alongside the same figure
#' for normal vision. Read it as a comparison: a simulation much below the
#' normal-vision row means the deficiency is costing those readers the
#' distinction, and anything below about 10 means the two fish are not
#' tellable apart at all. The median rather than the minimum is deliberate ---
#' two luminance-matched ramps necessarily converge at their pale end, where
#' both are near white, and a minimum would report that as a fault of every
#' well-matched pair.
#'
#' @param yin_colors,yang_colors The two colour vectors to compare. Defaults
#'   to the package's built-in ramps (or, if `palette` is given, to that
#'   preset's ramps).
#' @param n Number of steps at which to sample each ramp. Nine gives a
#'   readable table and catches mid-ramp problems that the control points
#'   alone would hide.
#' @param palette Optionally the name of a preset (see [taichi_palette()]) or
#'   a list with `yin` and `yang` elements, checked instead of
#'   `yin_colors` / `yang_colors`.
#' @param tolerance Largest luminance difference, in L\* units, still counted
#'   as a pass.
#'
#' @return An object of class `taichi_palette_check`, with a `print()` method
#'   that lays the measurements out as a table. It is a list with elements
#'   `steps` (a data frame of per-step colours, luminance and chroma),
#'   `max_luminance_diff`, `max_chroma_diff`, `monotone` (a logical pair),
#'   `verdict` (`"pass"`, `"warning"` or `"fail"`), `cvd` (a data frame of
#'   median step-wise colour distances for normal vision and each simulation,
#'   or `NULL` when \pkg{colorspace} is not installed), `tolerance`, and
#'   `space`, naming the colour space every number was measured in --- they
#'   are not comparable with figures computed in another space.
#' @seealso [taichi_palette_pair()] to build a matched pair,
#'   [taichi_palette()] for the presets.
#' @export
#' @examples
#' # the package defaults, measured honestly
#' taichi_check_palette()
#'
#' # a matched pair
#' taichi_check_palette(palette = "balanced")
taichi_check_palette <- function(yin_colors = NULL, yang_colors = NULL,
                                 n = 9, palette = NULL, tolerance = 5) {
  if (!is.null(palette)) {
    if (!is.null(yin_colors) || !is.null(yang_colors)) {
      rlang::abort(paste0(
        "Supply either `palette` or `yin_colors` / `yang_colors`, not both."
      ))
    }
    pair <- as_palette_pair(palette, "palette")
    yin_colors <- pair$yin
    yang_colors <- pair$yang
  }
  yin_colors <- yin_colors %||% taichi_default_yin_colors
  yang_colors <- yang_colors %||% taichi_default_yang_colors
  check_colours(yin_colors, "yin_colors")
  check_colours(yang_colors, "yang_colors")
  if (!is.numeric(n) || length(n) != 1 || is.na(n) || n < 2) {
    rlang::abort("`n` must be a single number of 2 or more.")
  }
  n <- as.integer(n)

  yin <- interpolate_ramp(yin_colors, n)
  yang <- interpolate_ramp(yang_colors, n)

  yin_lc <- luminance_chroma(yin)
  yang_lc <- luminance_chroma(yang)

  steps <- data.frame(
    step = seq_len(n),
    yin = yin,
    yin_luminance = yin_lc$l,
    yin_chroma = yin_lc$c,
    yang = yang,
    yang_luminance = yang_lc$l,
    yang_chroma = yang_lc$c,
    luminance_diff = yin_lc$l - yang_lc$l,
    stringsAsFactors = FALSE
  )

  max_l <- max(abs(steps$luminance_diff))
  max_c <- max(abs(steps$yin_chroma - steps$yang_chroma))
  verdict <- if (max_l <= tolerance) {
    "pass"
  } else if (max_l <= 3 * tolerance) {
    "warning"
  } else {
    "fail"
  }

  out <- list(
    space = "CIE Lab (L*, C*ab), CIE2000 distances",
    steps = steps,
    max_luminance_diff = max_l,
    max_chroma_diff = max_c,
    monotone = c(yin = is_monotone(yin_lc$l), yang = is_monotone(yang_lc$l)),
    verdict = verdict,
    cvd = cvd_distances(yin, yang),
    tolerance = tolerance
  )
  class(out) <- c("taichi_palette_check", "list")
  out
}


#' @export
print.taichi_palette_check <- function(x, ...) {
  cat("<ggtaichi palette check>\n\n")
  s <- x$steps
  fmt <- function(v) formatC(v, format = "f", digits = 1, width = 6)
  cat(sprintf("  %-4s %-9s %6s %6s   %-9s %6s %6s   %6s\n",
              "step", "yin", "L", "C", "yang", "L", "C", "dL"))
  for (i in seq_len(nrow(s))) {
    cat(sprintf("  %-4d %-9s %s %s   %-9s %s %s   %s\n",
                s$step[i], s$yin[i], fmt(s$yin_luminance[i]),
                fmt(s$yin_chroma[i]), s$yang[i], fmt(s$yang_luminance[i]),
                fmt(s$yang_chroma[i]), fmt(s$luminance_diff[i])))
  }
  cat("\n")
  cat(sprintf("  largest luminance mismatch : %.1f L* (tolerance %.1f)\n",
              x$max_luminance_diff, x$tolerance))
  cat(sprintf("  largest chroma mismatch    : %.1f\n", x$max_chroma_diff))
  # Every number above is colour-space dependent and none of them is
  # comparable with a figure computed in another space, so say which one.
  cat(sprintf("  measured in                : %s\n", x$space))
  if (!all(x$monotone)) {
    bad <- names(x$monotone)[!x$monotone]
    cat(sprintf("  NOT monotone in luminance  : %s\n",
                paste(bad, collapse = ", ")))
  }
  if (!is.null(x$cvd)) {
    cat("  how far apart the ramps stay (median distance, step for step)\n")
    normal <- x$cvd$distance[x$cvd$simulation == "normal"]
    for (i in seq_len(nrow(x$cvd))) {
      d <- x$cvd$distance[i]
      note <- if (x$cvd$simulation[i] == "normal") {
        ""
      } else if (d < 10) {
        "(too close to tell apart)"
      } else if (d < 0.5 * normal) {
        "(much worse than normal vision)"
      } else {
        ""
      }
      cat(sprintf("      %-10s %6.1f  %s\n", x$cvd$simulation[i], d, note))
    }
  } else {
    cat("  colour-vision deficiency   : install 'colorspace' to simulate\n")
  }
  cat("\n")
  cat("  Verdict: ", toupper(x$verdict), "\n", sep = "")
  cat("  ", switch(x$verdict,
    pass = paste0("the two ramps share a luminance trajectory, so equal ",
                  "values\n  read as equal ink."),
    warning = paste0("the two ramps are close but not matched; one fish ",
                     "will read\n  slightly heavier than the other at the ",
                     "same value."),
    fail = paste0("the two ramps do not share a luminance trajectory, so ",
                  "equal\n  values do NOT read as equal ink and one fish ",
                  "will appear to\n  dominate. Consider `palette = ",
                  "\"balanced\"` or `taichi_palette_pair()`.")
  ), "\n", sep = "")
  invisible(x)
}


# CIE L* and chroma of each colour. farver measures in CIE Lab, whose L* is
# the same luminance axis grDevices::hcl() works in, and whose chroma is
# sqrt(a^2 + b^2).
luminance_chroma <- function(cols) {
  rgb <- t(grDevices::col2rgb(cols))
  lab <- farver::convert_colour(rgb, from = "rgb", to = "lab")
  list(l = as.numeric(lab[, "l"]),
       c = as.numeric(sqrt(lab[, "a"]^2 + lab[, "b"]^2)))
}

is_monotone <- function(v) {
  d <- diff(v)
  d <- d[d != 0]
  length(d) == 0 || all(d > 0) || all(d < 0)
}

# How far apart the two ramps stay, step for step, for readers with
# colour-vision deficiency -- reported against a normal-vision baseline,
# because the interesting question is what the deficiency costs rather than
# the raw number.
#
# The statistic is the MEDIAN step-wise CIE2000 distance, not the minimum.
# Any two luminance-matched sequential ramps must converge at their pale end,
# where both are nearly white and nearly achromatic; a minimum would report
# that unavoidable convergence as a fault of every well-matched pair, and say
# nothing about the rest of the ramp.
#
# NULL rather than an error when colorspace is absent: the rest of the report
# is still worth having.
cvd_distances <- function(yin, yang) {
  if (!requireNamespace("colorspace", quietly = TRUE)) return(NULL)

  step_distance <- function(a_cols, b_cols) {
    a <- t(grDevices::col2rgb(a_cols))
    b <- t(grDevices::col2rgb(b_cols))
    stats::median(vapply(seq_len(nrow(a)), function(i) {
      farver::compare_colour(a[i, , drop = FALSE], b[i, , drop = FALSE],
                             from_space = "rgb", method = "cie2000")[1, 1]
    }, numeric(1)))
  }

  normal <- step_distance(yin, yang)
  sims <- c("deutan", "protan", "tritan")
  res <- vapply(sims, function(fn) {
    sim <- getExportedValue("colorspace", fn)
    step_distance(sim(yin), sim(yang))
  }, numeric(1))

  data.frame(
    simulation = c("normal", sims),
    distance = c(normal, as.numeric(res)),
    stringsAsFactors = FALSE
  )
}


# Accept a preset name, or a two-element list, wherever a palette pair is
# expected. Anything else is a mistake worth naming.
as_palette_pair <- function(palette, arg, n = 5) {
  if (is.character(palette) && length(palette) == 1) {
    return(taichi_palette(palette, n = n))
  }
  if (is.list(palette) && all(c("yin", "yang") %in% names(palette))) {
    check_colours(palette$yin, paste0(arg, "$yin"))
    check_colours(palette$yang, paste0(arg, "$yang"))
    return(list(yin = palette$yin, yang = palette$yang))
  }
  rlang::abort(paste0(
    "`", arg, "` must be one of ",
    paste0("\"", taichi_palette_names, "\"", collapse = ", "),
    ", or a list with `yin` and `yang` colour vectors (see ",
    "`taichi_palette_pair()`)."
  ))
}

check_colours <- function(cols, arg) {
  if (!is.character(cols) || length(cols) == 0 || anyNA(cols)) {
    rlang::abort(paste0(
      "`", arg, "` must be a non-empty character vector of colours."
    ))
  }
  bad <- tryCatch({
    grDevices::col2rgb(cols)
    NULL
  }, error = function(e) conditionMessage(e))
  if (!is.null(bad)) {
    rlang::abort(paste0("`", arg, "` is not a valid colour vector: ", bad))
  }
  invisible(cols)
}
