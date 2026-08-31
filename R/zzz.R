# Theme-aware geom defaults, applied at load time.
#
# ggplot2 4.0 lets a theme set geom defaults through
# `theme(geom = element_geom(ink, paper, accent))`, and lets a geom read them
# with `from_theme()`. Without that, ggtaichi's hard-coded fallbacks -- a
# grey20 fish, a white yin eye, a black yang eye -- do not follow a dark
# theme: on a dark `paper` the fallback fish is nearly invisible and the two
# eyes are the wrong way round.
#
# The expressions below reproduce the current appearance exactly on the
# default light theme -- ink black, paper white and borderwidth 0.5 give a
# #333333 (grey20) fill, a linewidth of 0.1, a white yin eye and a black yang
# eye -- and flip with the theme otherwise. They are installed here rather
# than written into the ggproto definitions so that the package still works,
# with the literal fallbacks, on the ggplot2 3.4-3.5 it still supports, and so
# that upgrading ggplot2 after installing ggtaichi is enough to switch them on
# without a reinstall.
# The names below are supplied by ggplot2 as a data mask when it evaluates a
# from_theme() expression -- they are theme element properties, not objects in
# this namespace, so R's static check cannot see where they come from.
utils::globalVariables(c(
  "ink", "paper", "fill", "colour", "borderwidth", "bordertype"
))

.onLoad <- function(libname, pkgname) {
  if (!has_themed_aes()) return(invisible())

  GeomYinFish$default_aes <- ggplot2::aes(
    fill = from_theme(fill %||% mix_ink(ink, solid_colour(paper, "white"), 0.2)),
    colour = from_theme(colour %||% NA),
    linewidth = from_theme(0.2 * borderwidth),
    linetype = from_theme(bordertype),
    alpha = NA, width = NA, height = NA,
    angle = 0, radius = 1, border = NA,
    eye_size = 0.15,
    eye_colour = from_theme(solid_colour(paper, "white")),
    tooltip = NA, data_id = NA, onclick = NA
  )

  GeomYangFish$default_aes <- ggplot2::aes(
    fill = from_theme(fill %||% mix_ink(ink, solid_colour(paper, "white"), 0.2)),
    colour = from_theme(colour %||% NA),
    linewidth = from_theme(0.2 * borderwidth),
    linetype = from_theme(bordertype),
    alpha = NA, width = NA, height = NA,
    angle = 0, radius = 1, border = NA,
    eye_size = 0.15,
    eye_colour = from_theme(solid_colour(ink, "black")),
    tooltip = NA, data_id = NA, onclick = NA
  )

  invisible()
}
