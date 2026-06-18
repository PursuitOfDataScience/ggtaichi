#' ggtaichi: Taichi diagrams for two data sources
#'
#' ggtaichi, which is a ggplot2 extension, visualizes data from two different
#' sources on a single grid of taichi (yin-yang) diagrams. Instead of facetting
#' a heatmap by data source, the two sources are combined into one plot, where
#' every cell becomes a taichi symbol whose two fish are filled by the two
#' sources via luminance. Prior to using the package, users should load
#' ggplot2.
#'
#' @section ggtaichi functions:
#' The main workhorse is \code{geom_taichi()}, which turns every \code{(x, y)}
#' cell into a taichi diagram, much like \code{geom_tile()} draws a regular
#' heatmap. It is supported by \code{theme_taichi()} and \code{remove_padding()}
#' for styling. Users should reference the documentation and run the examples in
#' the help files when trying to understand what each argument means visually.
#'
#'
#' @keywords internal
"_PACKAGE"

# Quiet R CMD check about the columns referenced inside transform() when
# setting up the per-cell bounding boxes.
utils::globalVariables(c("x", "y", "width", "height"))
