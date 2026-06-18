#' Taichi
#'
#' The taichi geom turns each cell of a heatmap-like grid into a taichi
#' (yin-yang) diagram. The two interlocking "fish" of the diagram use luminance
#' to show the values from two data sources on the same plot, so four
#' dimensions of data can be expressed at once: the \code{x} and \code{y}
#' position of every taichi symbol plus the \code{yin} and \code{yang} values
#' that fill its two halves.
#'
#' @param yin The column name for the yin (dark) fish of the taichi symbol.
#' @param yin_name The label name (in quotes) for the legend of the yin
#' rendering. Default is \code{NULL}.
#' @param yin_colors A color vector, usually as hex codes.
#' @param yang The column name for the yang (light) fish of the taichi symbol.
#' @param yang_name The label name (in quotes) for the legend of the yang
#' rendering. Default is \code{NULL}.
#' @param yang_colors A color vector, usually as hex codes.
#' @param eyes Whether to draw the two contrasting "eye" dots, one in the head
#' of each fish, as in a classic taichi symbol. Default is \code{TRUE}.
#' @param yin_eye The color of the eye sitting in the yin fish. Default is
#' \code{"gray95"}.
#' @param yang_eye The color of the eye sitting in the yang fish. Default is
#' \code{"gray10"}.
#' @param eye_ratio The radius of each eye relative to the radius of the whole
#' taichi symbol. Default is \code{1/6}.
#' @param ... \code{...} accepts any arguments \code{scale_fill_gradientn()} has
#' .
#'
#' @import ggplot2
#' @import grid
#' @import rlang
#' @import ggnewscale
#' @return A taichi diagram comparing two data sources.
#' @export
#'
#' @examples
#'
#' # taichi with categorical variables only
#'
#' library(ggplot2)
#'
#' data <- data.frame(x = rep(c("a", "b", "c"), 3),
#'                    y = rep(c("d", "e", "f"), 3),
#'                    yin_values = rep(c(1,5,7),3),
#'                    yang_values = rep(c(2,3,4),3))
#'
#' ggplot(data, aes(x,y)) +
#' geom_taichi(yin = yin_values,
#'             yang = yang_values)
#'
#'
#' # Hiding the eyes.
#'
#' ggplot(data, aes(x,y)) +
#' geom_taichi(yin = yin_values,
#'             yang = yang_values,
#'             eyes = FALSE)
#'
#'
#' # taichi with numeric variables only
#'
#' data <- data.frame(x = rep(c(1, 2, 3), 3),
#'                    y = rep(c(1, 2, 3), 3),
#'                    yin_values = rep(c(1,5,7),3),
#'                    yang_values = rep(c(2,3,4),3))
#'
#' ggplot(data, aes(x,y)) +
#' geom_taichi(yin = yin_values,
#'             yang = yang_values)
#'
#'
#' # taichi with a mixture of numeric and categorical variables
#'
#' data <- data.frame(x = rep(c("a", "b", "c"), 3),
#'                    y = rep(c(1, 2, 3), 3),
#'                    yin_values = rep(c(1,5,7),3),
#'                    yang_values = rep(c(2,3,4),3))
#'
#' ggplot(data, aes(x,y)) +
#' geom_taichi(yin = yin_values,
#'             yang = yang_values)
#'


geom_taichi <- function(yin,
                        yin_name = NULL,
                        yin_colors = c('gray100', 'gray85', 'gray50', 'gray35', 'gray0'),
                        yang,
                        yang_name = NULL,
                        yang_colors = c("#FED7D8","#FE8C91", "#F5636B", "#E72D3F","#C20824"),
                        eyes = TRUE,
                        yin_eye = "gray95",
                        yang_eye = "gray10",
                        eye_ratio = 1/6,
                        ...){

  if (eye_ratio <= 0 || eye_ratio >= 0.5) {
    rlang::abort(message = "`eye_ratio` has to be between 0 and 0.5.")
  }

  if (is.null(yin_name))  yin_name  <- rlang::as_label(rlang::enexpr(yin))
  if (is.null(yang_name)) yang_name <- rlang::as_label(rlang::enexpr(yang))

  list(geom_yin_fish(ggplot2::aes(fill = {{ yin }}),
                     eyes = eyes, eye_fill = yin_eye, eye_ratio = eye_ratio),

       ggplot2::scale_fill_gradientn(name = yin_name, colors = yin_colors, ...),

       ggnewscale::new_scale_fill(),

       geom_yang_fish(ggplot2::aes(fill = {{ yang }}),
                      eyes = eyes, eye_fill = yang_eye, eye_ratio = eye_ratio),

       ggplot2::scale_fill_gradientn(name = yang_name, colors = yang_colors, ...))

}




# Generate the boundary points of one taichi "fish".
#
# A taichi symbol is a circle of radius `r` centered at (cx, cy), split into
# two fish by an S-curve made of two small semicircles of radius r / 2. Each
# fish boundary is traced from three arcs that connect head-to-tail: half of
# the big circle plus the two small semicircles bulging in opposite ways.
taichi_fish <- function(cx, cy, r, fish = c("yin", "yang"), n = 50) {

  fish <- match.arg(fish)
  half <- r / 2

  big   <- seq(-pi / 2,  pi / 2, length.out = n)       # right half of the big circle
  upper <- seq( pi / 2,  3 * pi / 2, length.out = n)   # left half / left-bulging small arc
  lower <- seq( pi / 2, -pi / 2, length.out = n)       # right-bulging small arc

  if (fish == "yang") {
    # Right half of the big circle, bottom -> top.
    xa <- cx + r * cos(big);      ya <- cy + r * sin(big)
    # Upper small circle, right side, top -> center.
    xb <- cx + half * cos(lower); yb <- cy + half + half * sin(lower)
    # Lower small circle, left side, center -> bottom.
    xc <- cx + half * cos(upper); yc <- cy - half + half * sin(upper)
  } else {
    # Left half of the big circle, top -> bottom.
    xa <- cx + r * cos(upper);         ya <- cy + r * sin(upper)
    # Lower small circle, left side, bottom -> center.
    xb <- cx + half * cos(rev(upper)); yb <- cy - half + half * sin(rev(upper))
    # Upper small circle, right side, center -> top.
    xc <- cx + half * cos(rev(lower)); yc <- cy + half + half * sin(rev(lower))
  }

  list(x = c(xa, xb, xc), y = c(ya, yb, yc))
}


# Build a grob (the fish body plus its optional eye) for every taichi cell.
#
# Each taichi is drawn in its own viewport spanning the cell, with the shape
# offset in "snpc" units so the symbol stays round regardless of the panel
# aspect ratio, mirroring how `circleGrob()` keeps the original heatcircle
# round without needing `coord_fixed()`.
draw_taichi <- function(coords, fish, eyes, eye_fill, eye_ratio) {

  cx <- (coords$xmin + coords$xmax) / 2
  cy <- (coords$ymin + coords$ymax) / 2
  hw <- (coords$xmax - coords$xmin) / 2
  hh <- (coords$ymax - coords$ymin) / 2

  # Unit fish (radius 1, centered at the origin), shared by every cell.
  unit <- taichi_fish(0, 0, 1, fish, n = 50)
  eye_y <- if (fish == "yang") -0.5 else 0.5

  grobs <- lapply(seq_len(nrow(coords)), function(i) {

    vp <- grid::viewport(x = cx[i], y = cy[i],
                         width  = grid::unit(2 * hw[i], "npc"),
                         height = grid::unit(2 * hh[i], "npc"))

    body <- grid::polygonGrob(
      x = grid::unit(0.5, "npc") + grid::unit(0.5 * unit$x, "snpc"),
      y = grid::unit(0.5, "npc") + grid::unit(0.5 * unit$y, "snpc"),
      gp = grid::gpar(
        col = coords$colour[i],
        fill = alpha(coords$fill[i], coords$alpha[i]),
        lwd = coords$size[i] * .pt,
        lty = coords$linetype[i]
      )
    )

    if (!isTRUE(eyes)) {
      return(grid::grobTree(body, vp = vp))
    }

    # The eye sits in the head of the fish, half a radius from the center.
    eye <- grid::circleGrob(
      x = grid::unit(0.5, "npc"),
      y = grid::unit(0.5, "npc") + grid::unit(0.5 * eye_y, "snpc"),
      r = grid::unit(0.5 * eye_ratio, "snpc"),
      gp = grid::gpar(col = NA, fill = eye_fill)
    )

    grid::grobTree(body, eye, vp = vp)
  })

  grid::gTree(children = do.call(grid::gList, grobs))
}


# Shared setup: convert (x, y) cell centers into a bounding box and make sure
# every cell has its own group so polygonGrob keeps the fish separate.
taichi_setup_data <- function(data, params) {
  data$width  <- data$width  %||% params$width  %||% resolution(data$x, FALSE)
  data$height <- data$height %||% params$height %||% resolution(data$y, FALSE)

  data <- transform(data,
                    xmin = x - width / 2,  xmax = x + width / 2,  width = NULL,
                    ymin = y - height / 2, ymax = y + height / 2, height = NULL)

  if (anyDuplicated(data$group)) {
    data$group <- seq_len(nrow(data))
  }

  data
}


#' @format NULL
#' @usage NULL

GeomYinFish <- ggplot2::ggproto("GeomYinFish", ggplot2::Geom,
  extra_params = c("na.rm"),

  setup_data = function(data, params) taichi_setup_data(data, params),

  draw_panel = function(data, panel_params, coord,
                        eyes = TRUE, eye_fill = "gray95", eye_ratio = 1/6) {
    coords <- coord$transform(data, panel_params)
    draw_taichi(coords, "yin", eyes, eye_fill, eye_ratio)
  },

  default_aes = ggplot2::aes(fill = "grey20", colour = NA, size = 0.1, linetype = 1,
                             alpha = NA, width = NA, height = NA),

  required_aes = c("x", "y"),
  non_missing_aes = c("xmin", "xmax", "ymin", "ymax"),

  draw_key = ggplot2::draw_key_rect
)


#' @format NULL
#' @usage NULL

geom_yin_fish <- function(mapping = NULL, data = NULL,
                          stat = "identity", position = "identity",
                          ...,
                          na.rm = FALSE,
                          show.legend = NA,
                          inherit.aes = TRUE) {
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomYinFish,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm = na.rm,
      ...
    )
  )
}


#' @format NULL
#' @usage NULL

GeomYangFish <- ggplot2::ggproto("GeomYangFish", GeomYinFish,

  draw_panel = function(data, panel_params, coord,
                        eyes = TRUE, eye_fill = "gray10", eye_ratio = 1/6) {
    coords <- coord$transform(data, panel_params)
    draw_taichi(coords, "yang", eyes, eye_fill, eye_ratio)
  }
)


#' @format NULL
#' @usage NULL

geom_yang_fish <- function(mapping = NULL, data = NULL,
                           stat = "identity", position = "identity",
                           ...,
                           na.rm = FALSE,
                           show.legend = NA,
                           inherit.aes = TRUE) {
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomYangFish,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm = na.rm,
      ...
    )
  )
}
