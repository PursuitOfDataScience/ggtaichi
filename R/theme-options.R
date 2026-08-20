#' Plot Themes
#'
#' A light theme tuned for the taichi grid: it bottoms the legends, drops the
#' panel grid and axis ticks, and gives the canvas a soft off-white background
#' reminiscent of rice paper.
#'
#' @section Opinionated choices:
#' Two of the theme's settings surprise people often enough to be worth
#' spelling out. The y axis \emph{title} is blanked, on the assumption that the
#' y axis of a taichi grid is a list of category names that already reads as a
#' label --- so \code{labs(y = "...")} has no visible effect under this theme.
#' Legend text is rotated 90 degrees, which keeps a wide continuous legend from
#' running off the bottom of the plot. Both are ordinary theme elements, so add
#' a \code{\link[ggplot2]{theme}()} call afterwards to put them back:
#' \preformatted{  + theme_taichi() + theme(axis.title.y = element_text(),
#'                           legend.text = element_text(angle = 0))}
#'
#' @param base_size base font size
#' @param base_family base font family
#' @param base_line_size base size for line elements
#' @param base_rect_size base size for rect elements
#' @import ggplot2
#' @export
#' @return A \code{\link[ggplot2]{theme}} object that can be added to any
#'   ggplot, in the same way as \code{\link[ggplot2]{theme_bw}()}.
#' @examples
#' library(ggplot2)
#' d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 3:1)
#'
#' ggplot(d, aes(x, y)) +
#'   geom_taichi(yin = yin, yang = yang) +
#'   theme_taichi()

theme_taichi <- function(base_size = 11, base_family = "",
                         base_line_size = base_size / 22,
                         base_rect_size = base_size / 22) {

  ggplot2::theme_bw(base_size = base_size, base_family = base_family,
           base_line_size = base_line_size, base_rect_size = base_rect_size) %+replace%


    # `%+replace%` swaps each element wholesale rather than merging it, so any
    # property of a replaced element that theme_bw() had set has to be restated
    # here or it falls back to the generic `text` / `rect` parent.
    ggplot2::theme(legend.position = "bottom",
          axis.ticks = element_blank(),
          axis.title = element_text(size = 13, color = "#222222", face = "bold"),
          axis.text = element_text(size = 11, color = "#222222"),
          # hjust and the right margin keep the y tick labels flush-right with a
          # gap from the panel, as in theme_bw().
          axis.text.y = element_text(face = "bold", hjust = 1,
                                     margin = margin(r = 0.2 * base_size)),
          legend.text = element_text(angle = 90, vjust = 0, hjust = 0, color = "#222222"),
          legend.title = element_text(vjust = 1, hjust = 0, color = "#222222"),
          axis.title.y = element_blank(),
          panel.grid = element_blank(),
          # colour = NA, or the rect inherits a near-black border and frames the
          # whole canvas.
          plot.background = element_rect(fill = "#f3efe6", colour = NA),
          # Leave room at the right edge so a tick label landing on the panel
          # boundary (common with remove_padding()) is not cut off.
          plot.margin = margin(6, 14, 6, 6),
          # Align the title with the whole plot (not the panel) and keep it a
          # size that long titles survive without running off the right edge.
          plot.title.position = "plot",
          plot.title = element_text(size = 15, vjust = 1, hjust = 0, color = "#222222", face = "bold",
                                    margin = margin(10, 0, 10, 0)))

}
