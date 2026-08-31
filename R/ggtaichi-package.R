#' ggtaichi: Taichi diagrams for two data sources
#'
#' ggtaichi, which is a ggplot2 extension, visualizes data from two different
#' sources on a single grid of taichi (yin-yang) diagrams. Instead of faceting
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
#' Around it are the pieces that make a grid of glyphs readable:
#' \code{taichi_summary()} and \code{geom_taichi_diff()} put the relationship
#' between the two sources into numbers and into a diverging heatmap;
#' \code{taichi_palette_pair()}, \code{taichi_palette()} and
#' \code{taichi_check_palette()} build and audit the pair of colour ramps the
#' comparison depends on; the \code{scale_taichi_*()} family supplies ready
#' fill scales, including the binned ones worth reaching for on a dense grid;
#' and \code{geom_taichi(interactive = TRUE)} hands the plot to
#' \pkg{ggiraph} so a reader can hover for the exact values.
#'
#'
#' @keywords internal
#' @importFrom stats sd
#' @importFrom utils packageVersion
"_PACKAGE"
