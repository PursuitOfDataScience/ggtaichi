#' A taichi-shaped legend key
#'
#' The legend key glyph used by [geom_yin_fish()] and [geom_yang_fish()], and
#' therefore by [geom_taichi()]: a small taichi symbol whose relevant fish is
#' filled with the key's colour while the other is left as an outline, so the
#' key looks like the mark it describes and says which half of the glyph the
#' scale governs. Pass it to a layer's `key_glyph` argument to use it
#' elsewhere, or use `key_glyph = "rect"` for plain ggplot2 rectangles.
#'
#' Keys only appear for discrete fills. A continuous fill is drawn by
#' [ggplot2::guide_colourbar()], which is a gradient bar rather than a set of
#' keys, so this glyph has no effect there.
#'
#' @param data A one-row data frame of the key's aesthetics, supplied by
#'   ggplot2.
#' @param params The layer's parameters, supplied by ggplot2. `eyes = TRUE` is
#'   honoured, so a plot drawn with eyes gets keys with eyes. For a
#'   single-fish key the eye takes the layer's own eye colour and (constant)
#'   eye size, so it matches the eyes on the plot.
#' @param size The key size in mm, supplied by ggplot2. Unused: the glyph is
#'   drawn in a square viewport that fills the key, so it stays round whatever
#'   the key's aspect ratio.
#' @param fish Which fish carries `data$fill`: `"yin"`, `"yang"`, or
#'   `"both"`. The last fills the yin fish with the key colour and the yang
#'   fish with a pale version of it, for a decorative complete symbol with the
#'   classic white and black eyes.
#'
#' @return A grob.
#' @export
#' @examples
#' library(ggplot2)
#' d <- data.frame(x = c(1, 2), y = 1,
#'                 grp = factor(c("a", "b")), value = c(1, 2))
#'
#' # the default for the fish geoms
#' ggplot(d, aes(x, y)) +
#'   geom_yin_fish(aes(fill = grp))
#'
#' # a full symbol, or the old rectangles
#' ggplot(d, aes(x, y)) +
#'   geom_yin_fish(aes(fill = grp), key_glyph = draw_key_taichi)
#' ggplot(d, aes(x, y)) +
#'   geom_yin_fish(aes(fill = grp), key_glyph = "rect")
draw_key_taichi <- function(data, params, size, fish = "both") {
  fish <- rlang::arg_match0(fish, c("both", "yin", "yang"), arg_nm = "fish")

  fill <- data$fill[1] %||% "grey20"
  alpha <- data$alpha[1] %||% NA
  lwd <- (data$linewidth[1] %||% 0.1) * .pt
  lty <- data$linetype[1] %||% 1
  outline <- data$colour[1] %||% NA
  if (is.na(outline)) outline <- mix_ink("grey20", "white", 0.45)

  yin_fill <- switch(fish,
    yin = alpha(fill, alpha),
    yang = NA,
    both = alpha(fill, alpha)
  )
  yang_fill <- switch(fish,
    yin = NA,
    yang = alpha(fill, alpha),
    both = alpha(mix_ink(fill, "white", 0.7), alpha)
  )

  poly <- function(which, this_fill) {
    pts <- taichi_fish(0.5, 0.5, 0.45, which, n = 30)
    grid::polygonGrob(
      x = grid::unit(pts$x, "npc"), y = grid::unit(pts$y, "npc"),
      gp = grid::gpar(fill = this_fill, col = outline, lwd = lwd, lty = lty)
    )
  }

  children <- grid::gList(poly("yin", yin_fill), poly("yang", yang_fill))

  # A single-fish key describes one layer, so its eye is that layer's eye: the
  # colour the plot's eyes are drawn in (a constant, or the theme's) and a
  # constant size, under the plot's own rule that a size which is not a
  # positive number means no eye. A mapped size has no one value to show, so
  # the key gets the default. The decorative full symbol keeps the classic
  # pair.
  size <- if (fish == "both") 0.15 else data$eye_size[1] %||% 0.15
  has_eye <- is.numeric(size) && is.finite(size) && size > 0
  if (isTRUE(params$eyes) && has_eye) {
    own_colour <- function(classic) {
      col <- if (fish == "both") NULL else data$eye_colour[1]
      if (is.null(col)) classic else as.character(col)
    }
    eye <- function(y, col) {
      grid::circleGrob(
        x = grid::unit(0.5, "npc"), y = grid::unit(y, "npc"),
        r = grid::unit(0.45 * size, "npc"),
        gp = grid::gpar(fill = col, col = col)
      )
    }
    eyes <- list()
    if (fish %in% c("yin", "both")) {
      eyes[[length(eyes) + 1]] <- eye(0.5 + 0.225, own_colour("white"))
    }
    if (fish %in% c("yang", "both")) {
      eyes[[length(eyes) + 1]] <- eye(0.5 - 0.225, own_colour("black"))
    }
    children <- do.call(grid::gList, c(as.list(children), eyes))
  }

  # A square viewport keeps the key glyph round however the legend sizes its
  # keys; "snpc" resolves against the smaller side of the key.
  grid::gTree(
    children = children,
    vp = grid::viewport(width = grid::unit(1, "snpc"),
                        height = grid::unit(1, "snpc")),
    name = "taichi_key",
    cl = "taichi_key"
  )
}

draw_key_yin_fish <- function(data, params, size) {
  draw_key_taichi(data, params, size, fish = "yin")
}

draw_key_yang_fish <- function(data, params, size) {
  draw_key_taichi(data, params, size, fish = "yang")
}
