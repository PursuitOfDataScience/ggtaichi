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
#' A continuous axis holding dates, date-times or `hms` times gets the
#' matching scale ([ggplot2::scale_x_date()], [ggplot2::scale_x_datetime()],
#' [ggplot2::scale_x_time()]) rather than [ggplot2::scale_x_continuous()], so
#' its labels stay dates instead of turning into day or second counts.
#'
#' @param x,y `NULL` (the default) to auto-detect the scale type of that axis
#'   from the plot's data and mapping, `"c"` for a continuous axis, or `"d"`
#'   for a discrete one. Auto-detection reads the *plot's* mapping, so name the
#'   type explicitly when `x` / `y` are mapped in a layer rather than in
#'   `ggplot()`, or when the mapping is a computed expression the plot data
#'   cannot answer for.
#' @param ... Additional arguments passed on to the underlying
#'   [ggplot2::scale_x_continuous()] / [ggplot2::scale_x_discrete()] (and y)
#'   calls. They go to *both* scales, so when the two axes are of different
#'   types only arguments that continuous and discrete scales share (`name`,
#'   `breaks`, `labels`, `guide`, ...) can be used here: a continuous-only
#'   argument such as `n.breaks` would be rejected by the discrete scale with
#'   an "unused argument" error. For per-axis options, add your own
#'   `scale_x_*(expand = c(0, 0))` call instead.
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

  check_axis <- function(value, arg, call = rlang::caller_env()) {
    if (!is.null(value) && !(identical(value, "c") || identical(value, "d"))) {
      rlang::abort(paste0("Argument `", arg, "` only takes `c` or `d`."),
                   call = call)
    }
  }
  check_axis(x, "x")
  check_axis(y, "y")

  # Always resolved at `+` time, even when both types are given: a "c" axis
  # still has to see its data to pick the date or time scale for it.
  out <- list(x = x, y = y, dots = list(...))
  class(out) <- c("taichi_padding", "list")
  out
}


padding_scales <- function(x, y, dots, x_vals = NULL, y_vals = NULL) {
  args <- c(list(expand = c(0, 0)), dots)
  list(
    do_call_quoted(padding_scale("x", x, x_vals), args),
    do_call_quoted(padding_scale("y", y, y_vals), args)
  )
}


# The scale constructor for one padding-free axis. "d" is the discrete scale.
# "c" is continuous, and a date, date-time or hms axis is continuous too, but
# scale_x_continuous() on one would print the raw day or second counts instead
# of dates, so those get the scale ggplot2 itself would have picked.
padding_scale <- function(axis, type, vals = NULL) {
  kind <- if (identical(type, "d")) {
    "discrete"
  } else if (inherits(vals, "Date")) {
    "date"
  } else if (inherits(vals, "POSIXt")) {
    "datetime"
  } else if (inherits(vals, "hms")) {
    "time"
  } else {
    "continuous"
  }
  get(paste0("scale_", axis, "_", kind), envir = asNamespace("ggplot2"),
      mode = "function")
}


#' @export
#' @method ggplot_add taichi_padding
ggplot_add.taichi_padding <- function(object, plot, ...) {
  data <- plot$data
  if (!is.data.frame(data)) data <- NULL

  axis_values <- function(axis) {
    tryCatch(rlang::eval_tidy(plot$mapping[[axis]], data),
             error = function(e) NULL)
  }
  detect_axis <- function(vals, given) {
    if (!is.null(given)) return(given)
    if (is.factor(vals) || is.character(vals) || is.logical(vals)) "d" else "c"
  }

  x_vals <- axis_values("x")
  y_vals <- axis_values("y")
  plot + padding_scales(detect_axis(x_vals, object$x),
                        detect_axis(y_vals, object$y),
                        object$dots, x_vals, y_vals)
}
