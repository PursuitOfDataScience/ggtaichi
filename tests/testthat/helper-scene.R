# Helpers for inspecting what a taichi plot actually draws.
#
# The taichi cells materialize their children at draw time (makeContent), so
# the only way to see the fish polygons, the eyes, or the interactive
# attributes is to render the plot on a throwaway device and grab the forced
# scene.

forced_scene <- function(p) {
  path <- tempfile(fileext = ".pdf")
  grDevices::pdf(path)
  on.exit({
    grDevices::dev.off()
    unlink(path)
  }, add = TRUE)
  print(p)
  grid::grid.force()
  grid::grid.grab()
}

# Collect all grobs of a class inside a gTree
collect_grobs <- function(g, type) {
  out <- list()
  walk <- function(gr) {
    if (inherits(gr, type)) out[[length(out) + 1]] <<- gr
    if (inherits(gr, "gTree")) for (ch in gr$children) walk(ch)
  }
  walk(g)
  out
}

# Circles drawn in a scene: circle grobs are batched, so count the points
count_circles <- function(g) {
  sum(vapply(collect_grobs(g, "circle"), function(ci) length(ci$x), integer(1)))
}

# Fish polygons drawn in a scene: one id-batched polygon grob per layer
count_polygons <- function(g) {
  sum(vapply(collect_grobs(g, "polygon"), function(pg) {
    if (is.null(pg$id)) 1L else length(unique(pg$id))
  }, integer(1)))
}
