#' Remove ggplot2 default padding
#'
#' ggplot2 pads both continuous and discrete axes with a little expansion,
#' which can make a taichi grid look like it is floating. `remove_padding()`
#' trims that space. Called with no arguments it inspects the plot it is
#' added to and figures out for itself whether each axis is continuous or
#' discrete; pass `"c"` (continuous) or `"d"` (discrete) explicitly to
#' override the detection, e.g. when the axis mapping is a computed
#' expression the plot data cannot answer for.
#'
#' @param x,y `NULL` (the default) to auto-detect the scale type of that axis
#'   from the plot's data and mapping, `"c"` for a continuous axis, or `"d"`
#'   for a discrete one.
#' @param ... Additional arguments passed on to the underlying
#'   [ggplot2::scale_x_continuous()] / [ggplot2::scale_x_discrete()] (and y)
#'   calls.
#'
#' @return An object that, added to a ggplot, replaces both position scales
#'   with padding-free ones.
#' @export
#' @import ggplot2
#' @import rlang
#' @examples
#' library(ggplot2)
#' d <- data.frame(x = 1:3, y = c("a", "b", "c"), yin = 1:3, yang = 3:1)
#'
#' # auto-detects x as continuous and y as discrete
#' ggplot(d, aes(x, y)) +
#'   geom_taichi(yin = yin, yang = yang) +
#'   remove_padding()
#'
#' # explicit override, identical result here
#' ggplot(d, aes(x, y)) +
#'   geom_taichi(yin = yin, yang = yang) +
#'   remove_padding(x = "c", y = "d")
remove_padding <- function(x = NULL, y = NULL, ...) {

  check_axis <- function(value, arg) {
    if (!is.null(value) && !(identical(value, "c") || identical(value, "d"))) {
      rlang::abort(paste0("Arguments `", arg, "` only takes `c` or `d`"))
    }
  }
  check_axis(x, "x")
  check_axis(y, "y")

  if (is.null(x) || is.null(y)) {
    out <- list(x = x, y = y, dots = list(...))
    class(out) <- c("taichi_padding", "list")
    return(out)
  }

  padding_scales(x, y, list(...))
}


padding_scales <- function(x, y, dots) {
  scale_x <- if (x == "c") ggplot2::scale_x_continuous else ggplot2::scale_x_discrete
  scale_y <- if (y == "c") ggplot2::scale_y_continuous else ggplot2::scale_y_discrete
  list(
    do.call(scale_x, c(list(expand = c(0, 0)), dots)),
    do.call(scale_y, c(list(expand = c(0, 0)), dots))
  )
}


#' @export
#' @method ggplot_add taichi_padding
ggplot_add.taichi_padding <- function(object, plot, ...) {
  data <- plot$data
  if (!is.data.frame(data)) data <- NULL

  detect_axis <- function(axis, given) {
    if (!is.null(given)) return(given)
    vals <- tryCatch(rlang::eval_tidy(plot$mapping[[axis]], data),
                     error = function(e) NULL)
    if (is.factor(vals) || is.character(vals) || is.logical(vals)) "d" else "c"
  }

  plot + padding_scales(detect_axis("x", object$x),
                        detect_axis("y", object$y),
                        object$dots)
}
