#' Taichi
#'
#' The taichi geom turns each cell of a heatmap-like grid into a taichi
#' (yin-yang) diagram. The two interlocking "fish" of the diagram use luminance
#' to show the values from two data sources on the same plot, so four
#' dimensions of data can be expressed at once: the \code{x} and \code{y}
#' position of every taichi symbol plus the \code{yin} and \code{yang} values
#' that fill its two halves. With the optional eyes enabled and mapped to data
#' (see \code{eyes}, \code{yin_eye_size}, \code{yang_eye_size}), a single glyph
#' can carry up to six dimensions.
#'
#' @section Discrete and continuous fills:
#' \code{geom_taichi()} inspects the plot data at \code{+} time. A numeric
#' \code{yin} / \code{yang} column gets a continuous
#' \code{\link[ggplot2]{scale_fill_gradientn}} built from \code{yin_colors} /
#' \code{yang_colors}; a factor, character, or logical column (including
#' computed expressions such as \code{factor(week)}) gets a discrete
#' \code{\link[ggplot2]{scale_fill_manual}} whose palette is interpolated from
#' the same color vectors. With the default vectors the discrete palette skips
#' the palest end of the ramp so that no category is invisible on a white
#' panel; an explicitly supplied color vector is used as-is. Supply
#' \code{yin_scale} / \code{yang_scale} to override the automatic choice
#' entirely.
#'
#' @section Eyes:
#' \code{eyes = TRUE} draws the classic taichi dots, each sitting in its own
#' fish's head: the yin eye in the top bulb, the yang eye in the bottom bulb.
#' The size and colour arguments accept either a constant or an (unquoted)
#' data column, so the eyes can encode up to two further variables. A mapped
#' eye-size column is rescaled to radii between 0.05 and 0.3 of the glyph
#' radius, unless all its values already lie in \code{(0, 0.5]}, in which case
#' they are used directly as radius proportions. Cells whose eye size is
#' \code{NA} or \code{0} are drawn without an eye.
#'
#' @section Missing values:
#' A fish whose fill value is \code{NA} is painted in the scale's
#' \code{na.value} colour (pass e.g. \code{na.value = "transparent"} through
#' \code{...} to change it), while \code{na.rm = TRUE} silently drops rows
#' with missing positions.
#'
#' @param yin The unquoted column name (or a string naming a column) for the
#'   yin (dark) fish of the taichi symbol.
#' @param yang The unquoted column name (or a string naming a column) for the
#'   yang (light) fish of the taichi symbol.
#' @param yin_name The label name (in quotes) for the legend of the yin
#'   rendering. Default is \code{NULL} (uses the column name).
#' @param yang_name The label name (in quotes) for the legend of the yang
#'   rendering. Default is \code{NULL} (uses the column name).
#' @param yin_colors A color vector, usually as hex codes, for the yin fish
#'   fill. Used as a gradient for continuous data and as a discrete palette
#'   for factor/character data. Ignored if \code{yin_scale} is provided.
#' @param yang_colors A color vector, usually as hex codes, for the yang fish
#'   fill. Used as a gradient for continuous data and as a discrete palette
#'   for factor/character data. Ignored if \code{yang_scale} is provided.
#' @param yin_scale An optional fill scale for the yin fish: either a ready
#'   scale object or a scale constructor function (e.g.
#'   \code{ggplot2::scale_fill_viridis_d}). Overrides auto-detection.
#' @param yang_scale An optional fill scale for the yang fish, as
#'   \code{yin_scale}.
#' @param angle Rotation of each glyph in degrees, counter-clockwise: either a
#'   single number or an unquoted column name (one angle per cell).
#' @param eyes Logical. If \code{TRUE}, draws the classic taichi eyes (dots),
#'   each centred in its fish's head. Default \code{FALSE}, preserving the
#'   plain v0.1.0 look.
#' @param yin_eye_size,yang_eye_size Size of each eye as a proportion of the
#'   glyph radius: a constant (default 0.15) or an unquoted data column to
#'   encode a variable (see the Eyes section for the rescaling rule).
#' @param yin_eye_colour,yang_eye_colour Colour of each eye dot: a constant
#'   (defaults "white" and "black") or an unquoted data column containing
#'   colour strings.
#' @param width,height Width and height of each cell. Typically omitted.
#' @param alpha Alpha transparency for the fish fills.
#' @param na.rm If \code{TRUE}, silently removes rows with missing values.
#' @param colour Outline colour of the fish.
#' @param linewidth Outline width of the fish (in mm). Replaces the deprecated
#'   \code{size} aesthetic of ggtaichi 0.1.0.
#' @param linetype Outline linetype of the fish.
#' @param show.legend Logical. Should the layer be included in the legend?
#' @param ... Additional arguments passed to \emph{both} auto-built fill
#'   scales (e.g., shared \code{limits} or \code{na.value}). For per-fish
#'   scale options, supply \code{yin_scale} / \code{yang_scale} instead.
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
#' library(ggplot2)
#'
#' # taichi with numeric fills
#'
#' data <- data.frame(x = rep(c(1, 2, 3), 3),
#'                    y = rep(c(1, 2, 3), each = 3),
#'                    yin_values = 1:9,
#'                    yang_values = 9:1)
#'
#' ggplot(data, aes(x, y)) +
#'   geom_taichi(yin = yin_values,
#'               yang = yang_values)
#'
#' # categorical (discrete) fills are detected automatically
#'
#' data$yin_class <- rep(c("low", "mid", "high"), 3)
#'
#' ggplot(data, aes(x, y)) +
#'   geom_taichi(yin = yin_class,
#'               yang = yang_values)
#'
#' # classic eyes, rotation, and data-driven eye sizes
#'
#' ggplot(data, aes(x, y)) +
#'   geom_taichi(yin = yin_values,
#'               yang = yang_values,
#'               eyes = TRUE,
#'               yin_eye_size = yang_values,
#'               angle = 45)
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

  if (rlang::quo_is_missing(rlang::enquo(yin))) {
    rlang::abort("`yin` is required. Please specify the column for the yin fish.")
  }
  if (rlang::quo_is_missing(rlang::enquo(yang))) {
    rlang::abort("`yang` is required. Please specify the column for the yang fish.")
  }

  yin_quo <- as_column_quo(rlang::enquo(yin))
  yang_quo <- as_column_quo(rlang::enquo(yang))
  angle_quo <- rlang::enquo(angle)

  if (rlang::quo_is_null(yin_quo)) {
    rlang::abort("`yin` must be a column, not NULL.")
  }
  if (rlang::quo_is_null(yang_quo)) {
    rlang::abort("`yang` must be a column, not NULL.")
  }
  if (!rlang::is_bool(eyes)) {
    rlang::abort("`eyes` must be TRUE or FALSE.")
  }

  if (is.null(yin_name))  yin_name  <- rlang::as_label(yin_quo)
  if (is.null(yang_name)) yang_name <- rlang::as_label(yang_quo)

  scale_dots <- list(...)
  if (!is.null(scale_dots$size)) {
    rlang::warn(paste0(
      "The `size` argument of `geom_taichi()` is deprecated as of ggtaichi ",
      "0.2.0; please use `linewidth` instead."
    ))
    if (missing(linewidth)) linewidth <- scale_dots$size
    scale_dots$size <- NULL
  }

  yin_eye_size_quo    <- rlang::enquo(yin_eye_size)
  yang_eye_size_quo   <- rlang::enquo(yang_eye_size)
  yin_eye_colour_quo  <- rlang::enquo(yin_eye_colour)
  yang_eye_colour_quo <- rlang::enquo(yang_eye_colour)

  yin_aes_args <- list(fill = yin_quo)
  yang_aes_args <- list(fill = yang_quo)

  if (!rlang::quo_is_null(angle_quo)) {
    yin_aes_args$angle <- angle_quo
    yang_aes_args$angle <- angle_quo
  }

  shared_params <- list(
    alpha = alpha, na.rm = na.rm,
    colour = colour, linewidth = linewidth, linetype = linetype,
    show.legend = show.legend,
    eyes = eyes
  )
  if (!is.null(width))  shared_params$width  <- width
  if (!is.null(height)) shared_params$height <- height

  yin_params <- shared_params
  yang_params <- shared_params

  # Eye size and colour accept a constant or a data column: constants become
  # layer parameters, columns become per-fish aesthetic mappings.
  if (is_constant_quo(yin_eye_size_quo)) {
    yin_params$eye_size <- check_eye_size(rlang::eval_tidy(yin_eye_size_quo), "yin_eye_size")
  } else {
    yin_aes_args$eye_size <- yin_eye_size_quo
  }
  if (is_constant_quo(yang_eye_size_quo)) {
    yang_params$eye_size <- check_eye_size(rlang::eval_tidy(yang_eye_size_quo), "yang_eye_size")
  } else {
    yang_aes_args$eye_size <- yang_eye_size_quo
  }
  if (is_constant_quo(yin_eye_colour_quo)) {
    yin_params$eye_colour <- rlang::eval_tidy(yin_eye_colour_quo)
  } else {
    yin_aes_args$eye_colour <- yin_eye_colour_quo
  }
  if (is_constant_quo(yang_eye_colour_quo)) {
    yang_params$eye_colour <- rlang::eval_tidy(yang_eye_colour_quo)
  } else {
    yang_aes_args$eye_colour <- yang_eye_colour_quo
  }

  yin_aes <- ggplot2::aes(!!!yin_aes_args)
  yang_aes <- ggplot2::aes(!!!yang_aes_args)

  yin_layer <- do.call(geom_yin_fish, c(
    list(mapping = yin_aes),
    yin_params
  ))

  yang_layer <- do.call(geom_yang_fish, c(
    list(mapping = yang_aes),
    yang_params
  ))

  result <- list(
    yin_layer = yin_layer,
    yin_mapping = yin_aes,
    yin_colors = yin_colors,
    yin_colors_user = !missing(yin_colors),
    yin_name = yin_name,
    yin_scale = yin_scale,
    scale_dots = scale_dots,
    yang_layer = yang_layer,
    yang_mapping = yang_aes,
    yang_colors = yang_colors,
    yang_colors_user = !missing(yang_colors),
    yang_name = yang_name,
    yang_scale = yang_scale
  )
  class(result) <- c("ggtaichi_plot", "list")
  result
}


# A quosure counts as a constant when its expression is a syntactic literal
# (number, string, TRUE/FALSE, NA); symbols and calls are treated as data
# mappings.
is_constant_quo <- function(quo) {
  rlang::is_syntactic_literal(rlang::quo_get_expr(quo))
}

check_eye_size <- function(value, arg) {
  if (!is.numeric(value) || length(value) != 1 || is.na(value)) {
    rlang::abort(paste0("`", arg, "` must be a single number or a data column."))
  }
  value
}

# Allow `yin = "Twitter"` as a synonym for `yin = Twitter`: a literal string
# would otherwise be mapped as a constant fill, which is never what the user
# means here.
as_column_quo <- function(quo) {
  expr <- rlang::quo_get_expr(quo)
  if (rlang::is_string(expr)) {
    rlang::new_quosure(rlang::sym(expr), rlang::quo_get_env(quo))
  } else {
    quo
  }
}


#' @export
#' @method ggplot_add ggtaichi_plot
ggplot_add.ggtaichi_plot <- function(object, plot, ...) {
  data <- plot$data
  if (!is.data.frame(data)) data <- NULL

  scale_dots <- object$scale_dots %||% list()

  # Evaluate the fill quosure against the plot data so that discrete columns
  # -- including computed expressions such as factor(week) -- can be detected.
  # A plain column name that matches nothing is a user error worth a clear
  # message; other failing expressions are left for ggplot2 to report when
  # the plot is built.
  resolve_values <- function(mapping, arg) {
    fill_quo <- mapping$fill
    if (is.null(fill_quo)) return(NULL)
    vals <- tryCatch(rlang::eval_tidy(fill_quo, data), error = function(e) e)
    if (inherits(vals, "error")) {
      expr <- rlang::quo_get_expr(fill_quo)
      if (is.name(expr)) {
        rlang::abort(paste0(
          "Column `", as.character(expr), "` (supplied to `", arg,
          "`) was not found in the plot data."
        ))
      }
      return(NULL)
    }
    vals
  }

  build_scale <- function(vals, colors, name, custom_scale, user_palette) {
    if (!is.null(custom_scale)) {
      if (inherits(custom_scale, "Scale")) {
        return(custom_scale)
      }
      return(do.call(custom_scale, c(list(name = name), scale_dots)))
    }
    is_disc <- is.factor(vals) || is.character(vals) || is.logical(vals)
    if (is_disc) {
      n_vals <- if (is.factor(vals)) {
        nlevels(droplevels(vals))
      } else {
        length(unique(vals[!is.na(vals)]))
      }
      n_vals <- max(n_vals, 1L)
      if (!user_palette) {
        # The default vectors are gradients whose palest end vanishes on a
        # white panel; sample them evenly but skip that extreme.
        scale_col <- grDevices::colorRampPalette(colors)(n_vals + 1)[-1]
      } else if (n_vals <= length(colors)) {
        scale_col <- colors[seq_len(n_vals)]
      } else {
        scale_col <- grDevices::colorRampPalette(colors)(n_vals)
      }
      do.call(ggplot2::scale_fill_manual, c(list(name = name, values = scale_col), scale_dots))
    } else {
      do.call(ggplot2::scale_fill_gradientn, c(list(name = name, colors = colors), scale_dots))
    }
  }

  yin_vals <- resolve_values(object$yin_mapping, "yin")
  yang_vals <- resolve_values(object$yang_mapping, "yang")

  yin_scale_obj <- build_scale(yin_vals, object$yin_colors, object$yin_name,
                               object$yin_scale, isTRUE(object$yin_colors_user))
  yang_scale_obj <- build_scale(yang_vals, object$yang_colors, object$yang_name,
                                object$yang_scale, isTRUE(object$yang_colors_user))

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
# At angle = 0 the yin fish is the left half plus the top bulb (its head),
# the yang fish the right half plus the bottom bulb.
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


# Rescale a mapped eye-size column to sensible radius proportions. Values
# already lying in (0, 0.5] are taken as literal proportions; anything else
# is linearly rescaled to [0.05, 0.3]. NAs are preserved (drawn as no eye).
rescale_eye_size <- function(x) {
  finite <- x[is.finite(x)]
  if (length(finite) == 0) return(x)
  rng <- range(finite)
  if (rng[1] > 0 && rng[2] <= 0.5) return(x)
  if (rng[1] == rng[2]) {
    x[is.finite(x)] <- 0.175
    return(x)
  }
  0.05 + (x - rng[1]) / (rng[2] - rng[1]) * 0.25
}


# Build the grob (fish bodies, and optionally their eyes) for every taichi
# cell of one panel.
draw_taichi <- function(coords, fish, eyes = FALSE) {

  cx <- (coords$xmin + coords$xmax) / 2
  cy <- (coords$ymin + coords$ymax) / 2
  hw <- (coords$xmax - coords$xmin) / 2
  hh <- (coords$ymax - coords$ymin) / 2

  n <- nrow(coords)
  angles <- coords$angle %||% rep(0, n)
  angles[is.na(angles)] <- 0

  lwd_vals <- coords$linewidth %||% rep(0.1, n)
  lwd_vals[is.na(lwd_vals)] <- 0.1

  eye_sizes <- coords$eye_size %||% rep(0.15, n)
  eye_cols  <- as.character(coords$eye_colour %||%
    rep(if (fish == "yang") "black" else "white", n))

  grobs <- lapply(seq_len(n), function(i) {
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

    eye_r <- eye_sizes[i]
    if (is.na(eye_r) || eye_r <= 0) return(fish_grob)

    # Each eye sits in its own fish's head: the yin bulb is at the top of the
    # glyph, the yang bulb at the bottom (see taichi_fish()).
    eye_cx <- 0
    eye_cy <- if (fish == "yang") -0.5 else 0.5

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
      gp = grid::gpar(fill = eye_cols[i], col = eye_cols[i])
    )

    grid::grobTree(fish_grob, eye_grob)
  })

  grid::gTree(children = do.call(grid::gList, grobs))
}


# Shared setup: convert (x, y) cell centers into a bounding box, and rescale
# mapped eye sizes (the eye_size column only exists here when it was mapped;
# constants arrive later as aesthetic parameters and are used verbatim).
taichi_setup_data <- function(data, params) {
  data$width  <- data$width  %||% params$width  %||% resolution(data$x, FALSE)
  data$height <- data$height %||% params$height %||% resolution(data$y, FALSE)

  data <- transform(data,
                    xmin = x - width / 2,  xmax = x + width / 2,  width = NULL,
                    ymin = y - height / 2, ymax = y + height / 2, height = NULL)

  if (!is.null(data$eye_size) && is.null(params$eye_size)) {
    if (!is.numeric(data$eye_size)) {
      rlang::abort("Eye sizes must be numeric when mapped to a data column.")
    }
    data$eye_size <- rescale_eye_size(data$eye_size)
  }

  if (anyDuplicated(data$group)) {
    data$group <- seq_len(nrow(data))
  }

  data
}


GeomYinFish <- ggplot2::ggproto("GeomYinFish", ggplot2::Geom,
  extra_params = c("na.rm", "eyes"),

  rename_size = TRUE,

  setup_data = function(data, params) taichi_setup_data(data, params),

  draw_panel = function(data, panel_params, coord, eyes = FALSE) {
    coords <- coord$transform(data, panel_params)
    draw_taichi(coords, "yin", eyes = eyes)
  },

  default_aes = ggplot2::aes(fill = "grey20", colour = NA,
                              linewidth = 0.1, linetype = 1,
                              alpha = NA, width = NA, height = NA,
                              angle = 0,
                              eye_size = 0.15, eye_colour = "white"),

  required_aes = c("x", "y"),
  non_missing_aes = c("xmin", "xmax", "ymin", "ymax"),

  draw_key = ggplot2::draw_key_rect
)


geom_yin_fish <- function(mapping = NULL, data = NULL,
                          stat = "identity", position = "identity",
                          width = NULL, height = NULL,
                          eyes = FALSE,
                          na.rm = FALSE,
                          show.legend = NA,
                          inherit.aes = TRUE,
                          ...) {
  params <- list(
    na.rm = na.rm,
    eyes = eyes,
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


GeomYangFish <- ggplot2::ggproto("GeomYangFish", GeomYinFish,

  draw_panel = function(data, panel_params, coord, eyes = FALSE) {
    coords <- coord$transform(data, panel_params)
    draw_taichi(coords, "yang", eyes = eyes)
  },

  default_aes = ggplot2::aes(fill = "grey20", colour = NA,
                              linewidth = 0.1, linetype = 1,
                              alpha = NA, width = NA, height = NA,
                              angle = 0,
                              eye_size = 0.15, eye_colour = "black")
)


geom_yang_fish <- function(mapping = NULL, data = NULL,
                           stat = "identity", position = "identity",
                           width = NULL, height = NULL,
                           eyes = FALSE,
                           na.rm = FALSE,
                           show.legend = NA,
                           inherit.aes = TRUE,
                           ...) {
  params <- list(
    na.rm = na.rm,
    eyes = eyes,
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
