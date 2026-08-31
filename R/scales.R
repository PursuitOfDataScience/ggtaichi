#' Fill scales for the taichi fish
#'
#' Ready-made `fill` scales carrying ggtaichi's palette conventions, for the
#' places where [geom_taichi()]'s automatic scale choice is not what you want:
#' pass one to its `yin_scale` / `yang_scale` argument, or use it directly with
#' [geom_yin_fish()] / [geom_yang_fish()] when you are stacking scales by hand.
#'
#' Each function comes in a yin and a yang form, which differ only in which
#' half of the palette pair they take.
#'
#' \describe{
#'   \item{`scale_taichi_yin_c()`, `scale_taichi_yang_c()`}{Continuous
#'     gradients, the same construction [geom_taichi()] builds automatically
#'     for numeric sources.}
#'   \item{`scale_taichi_yin_d()`, `scale_taichi_yang_d()`}{Discrete scales
#'     that sample the ramp for however many levels the data has, skipping its
#'     palest end so no category is invisible on a white panel --- matching
#'     what [geom_taichi()] does for factor, character and logical sources.}
#'   \item{`scale_taichi_yin_binned()`, `scale_taichi_yang_binned()`}{Binned
#'     scales: the fill is matched to one of a handful of discrete steps
#'     instead of to a position on a continuous luminance ramp.}
#'   \item{`scale_taichi_yin_viridis_c()` and friends}{The Mako and Rocket
#'     viridis-family ramps, which are close to luminance matched and stay
#'     ordered under colour-vision deficiency.}
#' }
#'
#' @section Why binned scales are the cheapest accuracy win:
#' Reading a value off a continuous luminance ramp is the least accurate
#' perceptual task there is, and it gets worse as a grid grows. Matching a
#' patch to one of five labelled bins is much closer to a categorical lookup,
#' and the legend then tells the reader exactly which values share a colour.
#' On any grid too dense to compare cell by cell --- roughly, once the glyphs
#' are smaller than a few millimetres --- binning both fish is the single
#' cheapest thing you can do for readability:
#'
#' \preformatted{  geom_taichi(yin = matcha, yang = espresso,
#'               yin_scale = scale_taichi_yin_binned(n.breaks = 5),
#'               yang_scale = scale_taichi_yang_binned(n.breaks = 5),
#'               shared_limits = TRUE)}
#'
#' `shared_limits` and `shared_legend` compose with all of these: the limits
#' ggtaichi computes are pushed into the scale you supply, so the two fish end
#' up with the same breaks and equal values land in the same bin.
#'
#' @param name Legend title. Defaults to the aesthetic's label, as elsewhere
#'   in ggplot2.
#' @param palette The palette pair the ramp is taken from: the name of a
#'   [taichi_palette()] preset, or a list with `yin` and `yang` colour
#'   vectors, for example the output of [taichi_palette_pair()].
#' @param colors,colours An explicit colour vector, used instead of `palette`.
#' @param n For the discrete scales, how many colours to draw from the ramp
#'   before interpolating; defaults to the ramp's own length.
#' @param ... Passed on to the underlying ggplot2 scale
#'   ([ggplot2::scale_fill_gradientn()], [ggplot2::discrete_scale()],
#'   [ggplot2::scale_fill_stepsn()] or [ggplot2::scale_fill_viridis_c()]), so
#'   `limits`, `breaks`, `labels`, `guide`, `na.value`, `n.breaks` and the
#'   rest all work as usual.
#'
#' @return A ggplot2 fill scale.
#' @seealso [taichi_palette()] and [taichi_palette_pair()] for the palettes
#'   themselves, [taichi_check_palette()] to check a pair is fair.
#' @name scale_taichi
#' @examples
#' library(ggplot2)
#' d <- data.frame(x = rep(1:4, 4), y = rep(1:4, each = 4),
#'                 yin = 1:16, yang = 16:1)
#'
#' # binned fills, matched limits: the cheapest readability win there is
#' ggplot(d, aes(x, y)) +
#'   geom_taichi(yin = yin, yang = yang,
#'               yin_scale = scale_taichi_yin_binned(n.breaks = 4),
#'               yang_scale = scale_taichi_yang_binned(n.breaks = 4),
#'               shared_limits = TRUE)
#'
#' # a viridis-family pair
#' ggplot(d, aes(x, y)) +
#'   geom_taichi(yin = yin, yang = yang,
#'               yin_scale = scale_taichi_yin_viridis_c,
#'               yang_scale = scale_taichi_yang_viridis_c)
NULL

# The colour vector a scale constructor should use: an explicit one wins,
# otherwise the requested half of a palette pair.
scale_colours <- function(fish, palette, colors, colours, n = 5) {
  cols <- colors %||% colours
  if (!is.null(cols)) {
    check_colours(cols, "colors")
    return(cols)
  }
  as_palette_pair(palette, "palette", n = n)[[fish]]
}

#' @rdname scale_taichi
#' @export
scale_taichi_yin_c <- function(name = ggplot2::waiver(), palette = "default",
                               colors = NULL, colours = NULL, ...) {
  ggplot2::scale_fill_gradientn(
    name = name,
    colors = scale_colours("yin", palette, colors, colours), ...
  )
}

#' @rdname scale_taichi
#' @export
scale_taichi_yang_c <- function(name = ggplot2::waiver(), palette = "default",
                                colors = NULL, colours = NULL, ...) {
  ggplot2::scale_fill_gradientn(
    name = name,
    colors = scale_colours("yang", palette, colors, colours), ...
  )
}

#' @rdname scale_taichi
#' @export
scale_taichi_yin_d <- function(name = ggplot2::waiver(), palette = "default",
                               colors = NULL, colours = NULL, n = NULL, ...) {
  taichi_discrete_scale("yin", name, palette, colors, colours, n, ...)
}

#' @rdname scale_taichi
#' @export
scale_taichi_yang_d <- function(name = ggplot2::waiver(), palette = "default",
                                colors = NULL, colours = NULL, n = NULL, ...) {
  taichi_discrete_scale("yang", name, palette, colors, colours, n, ...)
}

# A discrete scale rather than scale_fill_manual(), because the number of
# levels is not known until the plot is built. The ramp is sampled for k + 1
# steps and the palest dropped, which is the rule geom_taichi() applies to its
# own automatic discrete palette: the light end of a sequential ramp is
# invisible on a white panel.
taichi_discrete_scale <- function(fish, name, palette, colors, colours, n,
                                  ...) {
  cols <- scale_colours(fish, palette, colors, colours, n = n %||% 5)
  ggplot2::discrete_scale(
    aesthetics = "fill",
    name = name,
    palette = function(k) {
      if (k <= 0) return(character(0))
      grDevices::colorRampPalette(cols, space = "Lab")(k + 1)[-1]
    },
    ...
  )
}

#' @rdname scale_taichi
#' @export
scale_taichi_yin_binned <- function(name = ggplot2::waiver(),
                                    palette = "default", colors = NULL,
                                    colours = NULL, ...) {
  ggplot2::scale_fill_stepsn(
    name = name,
    colours = scale_colours("yin", palette, colors, colours), ...
  )
}

#' @rdname scale_taichi
#' @export
scale_taichi_yang_binned <- function(name = ggplot2::waiver(),
                                     palette = "default", colors = NULL,
                                     colours = NULL, ...) {
  ggplot2::scale_fill_stepsn(
    name = name,
    colours = scale_colours("yang", palette, colors, colours), ...
  )
}

#' @rdname scale_taichi
#' @export
scale_taichi_yin_viridis_c <- function(name = ggplot2::waiver(), ...) {
  ggplot2::scale_fill_viridis_c(name = name, option = "mako",
                                direction = -1, ...)
}

#' @rdname scale_taichi
#' @export
scale_taichi_yang_viridis_c <- function(name = ggplot2::waiver(), ...) {
  ggplot2::scale_fill_viridis_c(name = name, option = "rocket",
                                direction = -1, ...)
}

#' @rdname scale_taichi
#' @export
scale_taichi_yin_viridis_d <- function(name = ggplot2::waiver(), ...) {
  ggplot2::scale_fill_viridis_d(name = name, option = "mako",
                                direction = -1, ...)
}

#' @rdname scale_taichi
#' @export
scale_taichi_yang_viridis_d <- function(name = ggplot2::waiver(), ...) {
  ggplot2::scale_fill_viridis_d(name = name, option = "rocket",
                                direction = -1, ...)
}
