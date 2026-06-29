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
#' @param yang The column name for the yang (light) fish of the taichi symbol.
#' @param yin_name The label name (in quotes) for the legend of the yin
#'   rendering. Default is \code{NULL} (uses the column name).
#' @param yang_name The label name (in quotes) for the legend of the yang
#'   rendering. Default is \code{NULL} (uses the column name).
#' @param yin_colors A color vector, usually as hex codes, for the yin fish
#'   fill gradient. Ignored if \code{yin_scale} is provided or the data is
#'   discrete.
#' @param yang_colors A color vector, usually as hex codes, for the yang fish
#'   fill gradient. Ignored if \code{yang_scale} is provided or the data is
#'   discrete.
#' @param yin_scale An optional scale object or constructor function (e.g.,
#'   \code{scale_fill_viridis_d}) for the yin fish. Overrides auto-detection.
#' @param yang_scale An optional scale object or constructor function (e.g.,
#'   \code{scale_fill_viridis_d}) for the yang fish. Overrides auto-detection.
#' @param angle Optional column name for rotating each glyph (in degrees).
#' @param eyes Logical. If \code{TRUE}, draws the classic taichi eyes (dots)
#'   at the center of each fish. Default \code{FALSE}.
#' @param yin_eye_size Size of the yin eye as a proportion of the fish radius.
#' @param yang_eye_size Size of the yang eye as a proportion of the fish radius.
#' @param yin_eye_colour Colour of the yin eye dot.
#' @param yang_eye_colour Colour of the yang eye dot.
#' @param width,height Width and height of each cell. Typically omitted.
#' @param alpha Alpha transparency for the fish fills.
#' @param na.rm If \code{TRUE}, silently removes rows with missing values.
#' @param colour Outline colour of the fish.
#' @param linewidth Outline width of the fish (in mm).
#' @param linetype Outline linetype of the fish.
#' @param show.legend Logical. Should the layer be included in the legend?
#' @param ... Additional arguments passed to the fill scales (e.g.,
#'   \code{limits}, \code{na.value}).
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

geom_taichi <- function(
  yin, yang,
  yin_name = NULL,
  yang_name = NULL,
  yin_colors = c('gray100', 'gray85', 'gray50', 'gray35', 'gray0'),
  yang_colors = c("#FED7D8","#FE8C91", "#F5636B", "#E72D3F","#C20824"),
  yin_scale = NULL,
  yang_scale = NULL,
  angle = NULL,
  eyes = FALSE,
  yin_eye_size = 0.15,
  yang_eye_size = 0.15,
  yin_eye_colour = "white",
  yang_eye_colour = "black",
  width = NULL,
  height = NULL,
  alpha = NA,
  na.rm = FALSE,
  colour = NA,
  linewidth = 0.1,
  linetype = 1,
  show.legend = NA,
  ...) {

  if (rlang::is_missing(rlang::enexpr(yin))) {
    rlang::abort("`yin` is required. Please specify the column for the yin fish.")
  }
  if (rlang::is_missing(rlang::enexpr(yang))) {
    rlang::abort("`yang` is required. Please specify the column for the yang fish.")
  }

  yin_quo <- rlang::enquo(yin)
  yang_quo <- rlang::enquo(yang)
  angle_quo <- rlang::enquo(angle)

  if (is.null(yin_name))  yin_name  <- rlang::as_label(yin_quo)
  if (is.null(yang_name)) yang_name <- rlang::as_label(yang_quo)

  yin_aes <- ggplot2::aes(fill = {{ yin }})
  yang_aes <- ggplot2::aes(fill = {{ yang }})

  if (!rlang::quo_is_null(angle_quo)) {
    yin_aes <- ggplot2::aes(fill = {{ yin }}, angle = !!angle_quo)
    yang_aes <- ggplot2::aes(fill = {{ yang }}, angle = !!angle_quo)
  }

  geom_params <- list(
    alpha = alpha, na.rm = na.rm,
    colour = colour, linewidth = linewidth, linetype = linetype,
    show.legend = show.legend,
    eyes = eyes,
    yin_eye_size = yin_eye_size, yang_eye_size = yang_eye_size,
    yin_eye_colour = yin_eye_colour, yang_eye_colour = yang_eye_colour
  )

  if (!is.null(width))  geom_params$width  <- width
  if (!is.null(height)) geom_params$height <- height

  yin_layer <- do.call(geom_yin_fish, c(
    list(mapping = yin_aes),
    geom_params
  ))

  yang_layer <- do.call(geom_yang_fish, c(
    list(mapping = yang_aes),
    geom_params
  ))

  result <- list(
    yin_layer = yin_layer,
    yin_mapping = yin_aes,
    yin_colors = yin_colors,
    yin_name = yin_name,
    yin_scale = yin_scale,
    scale_dots = list(...),
    yang_layer = yang_layer,
    yang_mapping = yang_aes,
    yang_colors = yang_colors,
    yang_name = yang_name,
    yang_scale = yang_scale
  )
  class(result) <- c("ggtaichi_plot", "list")
  result
}


#' @export
#' @method ggplot_add ggtaichi_plot
ggplot_add.ggtaichi_plot <- function(object, plot, ...) {
  data <- plot$data

  scale_dots <- object$scale_dots %||% list()

  build_scale <- function(mapping, colors, name, custom_scale) {
    if (!is.null(custom_scale)) {
      if (inherits(custom_scale, "Scale")) {
        return(custom_scale)
      }
      return(do.call(custom_scale, c(list(name = name), scale_dots)))
    }
    is_disc <- FALSE
    col_name <- NULL
    fill_aes <- mapping$fill
    if (!is.null(data) && !is.null(fill_aes)) {
      fill_expr <- rlang::quo_get_expr(fill_aes)
      if (is.name(fill_expr)) {
        col_name <- as.character(fill_expr)
        if (col_name %in% names(data)) {
          vals <- data[[col_name]]
          is_disc <- is.factor(vals) || is.character(vals)
        }
      }
    }
    if (isTRUE(is_disc) && !is.null(col_name)) {
      n_vals <- length(unique(data[[col_name]]))
      if (n_vals <= length(colors)) {
        scale_col <- colors[seq_len(n_vals)]
      } else {
        scale_col <- grDevices::colorRampPalette(colors)(n_vals)
      }
      do.call(ggplot2::scale_fill_manual, c(list(name = name, values = scale_col), scale_dots))
    } else {
      do.call(ggplot2::scale_fill_gradientn, c(list(name = name, colors = colors), scale_dots))
    }
  }

  yin_scale_obj <- build_scale(object$yin_mapping, object$yin_colors, object$yin_name, object$yin_scale)
  yang_scale_obj <- build_scale(object$yang_mapping, object$yang_colors, object$yang_name, object$yang_scale)

  plot +
    object$yin_layer +
    yin_scale_obj +
    ggnewscale::new_scale_fill() +
    object$yang_layer +
    yang_scale_obj
}





# Generate the boundary points of one taichi "fish".
#
# A taichi symbol is a circle of radius `r` centered at (cx, cy), split into
# two fish by an S-curve made of two small semicircles of radius r / 2. Each
# fish boundary is traced from three arcs that connect head-to-tail: half of
# the big circle plus the two small semicircles bulging in opposite ways.
taichi_fish <- function(cx, cy, r, fish = c("yin", "yang"), n = 50, angle = 0) {

  fish <- match.arg(fish)
  half <- r / 2
  theta <- angle * pi / 180

  big   <- seq(-pi / 2,  pi / 2, length.out = n)
  upper <- seq( pi / 2,  3 * pi / 2, length.out = n)
  lower <- seq( pi / 2, -pi / 2, length.out = n)

  if (fish == "yang") {
    xa <- r * cos(big);      ya <- r * sin(big)
    xb <- half * cos(lower); yb <- half + half * sin(lower)
    xc <- half * cos(upper); yc <- -half + half * sin(upper)
  } else {
    xa <- r * cos(upper);         ya <- r * sin(upper)
    xb <- half * cos(rev(upper)); yb <- -half + half * sin(rev(upper))
    xc <- half * cos(rev(lower)); yc <- half + half * sin(rev(lower))
  }

  x <- c(xa, xb, xc)
  y <- c(ya, yb, yc)

  if (angle != 0) {
    rot_x <- x * cos(theta) - y * sin(theta)
    rot_y <- x * sin(theta) + y * cos(theta)
    x <- rot_x
    y <- rot_y
  }

  list(x = cx + x, y = cy + y)
}


# Build the grob (one fish body) for every taichi cell.
draw_taichi <- function(coords, fish, eyes = FALSE,
                        yin_eye_size = 0.15, yang_eye_size = 0.15,
                        yin_eye_colour = "white", yang_eye_colour = "black") {

  cx <- (coords$xmin + coords$xmax) / 2
  cy <- (coords$ymin + coords$ymax) / 2
  hw <- (coords$xmax - coords$xmin) / 2
  hh <- (coords$ymax - coords$ymin) / 2

  angles <- coords$angle %||% rep(0, nrow(coords))
  if (is.na(angles[1])) angles <- rep(0, nrow(coords))

  lwd_vals <- coords$linewidth
  if (is.null(lwd_vals)) lwd_vals <- coords$size
  if (is.null(lwd_vals)) lwd_vals <- rep(0.1, nrow(coords))
  lwd_vals[is.na(lwd_vals)] <- 0.1

  grobs <- lapply(seq_len(nrow(coords)), function(i) {
    angle_i <- angles[i]
    unit <- taichi_fish(0, 0, 1, fish, n = 50, angle = angle_i)

    vp <- grid::viewport(x = cx[i], y = cy[i],
                         width  = grid::unit(2 * hw[i], "npc"),
                         height = grid::unit(2 * hh[i], "npc"))

    fish_grob <- grid::polygonGrob(
      x = grid::unit(0.5, "npc") + grid::unit(0.5 * unit$x, "snpc"),
      y = grid::unit(0.5, "npc") + grid::unit(0.5 * unit$y, "snpc"),
      vp = vp,
      gp = grid::gpar(
        col = coords$colour[i],
        fill = alpha(coords$fill[i], coords$alpha[i]),
        lwd = lwd_vals[i] * .pt,
        lty = coords$linetype[i]
      )
    )

    if (!eyes) return(fish_grob)

    if (fish == "yang") {
      eye_cx <- 0
      eye_cy <- 0.5
      eye_r <- yang_eye_size
      eye_col <- yang_eye_colour
    } else {
      eye_cx <- 0
      eye_cy <- -0.5
      eye_r <- yin_eye_size
      eye_col <- yin_eye_colour
    }

    if (angle_i != 0) {
      th <- angle_i * pi / 180
      ecx <- eye_cx * cos(th) - eye_cy * sin(th)
      ecy <- eye_cx * sin(th) + eye_cy * cos(th)
      eye_cx <- ecx
      eye_cy <- ecy
    }

    eye_grob <- grid::circleGrob(
      x = grid::unit(0.5, "npc") + grid::unit(0.5 * eye_cx, "snpc"),
      y = grid::unit(0.5, "npc") + grid::unit(0.5 * eye_cy, "snpc"),
      r = grid::unit(0.5 * eye_r, "snpc"),
      vp = vp,
      gp = grid::gpar(fill = eye_col, col = eye_col)
    )

    grid::grobTree(fish_grob, eye_grob)
  })

  grid::gTree(children = do.call(grid::gList, grobs))
}


# Shared setup: convert (x, y) cell centers into a bounding box.
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
  extra_params = c("na.rm", "eyes", "yin_eye_size", "yang_eye_size",
                    "yin_eye_colour", "yang_eye_colour"),

  setup_data = function(data, params) taichi_setup_data(data, params),

  draw_panel = function(data, panel_params, coord,
                        eyes = FALSE,
                        yin_eye_size = 0.15, yang_eye_size = 0.15,
                        yin_eye_colour = "white", yang_eye_colour = "black") {
    coords <- coord$transform(data, panel_params)
    draw_taichi(coords, "yin",
                eyes = eyes,
                yin_eye_size = yin_eye_size,
                yang_eye_size = yang_eye_size,
                yin_eye_colour = yin_eye_colour,
                yang_eye_colour = yang_eye_colour)
  },

  default_aes = ggplot2::aes(fill = "grey20", colour = NA,
                              linewidth = 0.1, linetype = 1,
                              alpha = NA, width = NA, height = NA,
                              angle = 0),

  required_aes = c("x", "y"),
  non_missing_aes = c("xmin", "xmax", "ymin", "ymax"),

  draw_key = ggplot2::draw_key_rect
)


#' @format NULL
#' @usage NULL

geom_yin_fish <- function(mapping = NULL, data = NULL,
                          stat = "identity", position = "identity",
                          width = NULL, height = NULL,
                          eyes = FALSE,
                          yin_eye_size = 0.15, yang_eye_size = 0.15,
                          yin_eye_colour = "white", yang_eye_colour = "black",
                          na.rm = FALSE,
                          show.legend = NA,
                          inherit.aes = TRUE,
                          ...) {
  params <- list(
    na.rm = na.rm,
    eyes = eyes,
    yin_eye_size = yin_eye_size, yang_eye_size = yang_eye_size,
    yin_eye_colour = yin_eye_colour, yang_eye_colour = yang_eye_colour,
    ...
  )
  if (!is.null(width))  params$width  <- width
  if (!is.null(height)) params$height <- height
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomYinFish,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = params
  )
}


#' @format NULL
#' @usage NULL

GeomYangFish <- ggplot2::ggproto("GeomYangFish", GeomYinFish,

  draw_panel = function(data, panel_params, coord,
                        eyes = FALSE,
                        yin_eye_size = 0.15, yang_eye_size = 0.15,
                        yin_eye_colour = "white", yang_eye_colour = "black") {
    coords <- coord$transform(data, panel_params)
    draw_taichi(coords, "yang",
                eyes = eyes,
                yin_eye_size = yin_eye_size,
                yang_eye_size = yang_eye_size,
                yin_eye_colour = yin_eye_colour,
                yang_eye_colour = yang_eye_colour)
  }
)


#' @format NULL
#' @usage NULL

geom_yang_fish <- function(mapping = NULL, data = NULL,
                           stat = "identity", position = "identity",
                           width = NULL, height = NULL,
                           eyes = FALSE,
                           yin_eye_size = 0.15, yang_eye_size = 0.15,
                           yin_eye_colour = "white", yang_eye_colour = "black",
                           na.rm = FALSE,
                           show.legend = NA,
                           inherit.aes = TRUE,
                           ...) {
  params <- list(
    na.rm = na.rm,
    eyes = eyes,
    yin_eye_size = yin_eye_size, yang_eye_size = yang_eye_size,
    yin_eye_colour = yin_eye_colour, yang_eye_colour = yang_eye_colour,
    ...
  )
  if (!is.null(width))  params$width  <- width
  if (!is.null(height)) params$height <- height
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomYangFish,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = params
  )
}
