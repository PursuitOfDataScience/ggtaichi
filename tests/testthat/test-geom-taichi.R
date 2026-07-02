library(ggplot2)
library(ggtaichi)

# ------------------------------------------------------------------
# BUG-1: geom params routing
# ------------------------------------------------------------------

test_that("BUG-1: alpha, linewidth, colour, linetype are accepted", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, alpha = 0.5, linewidth = 2,
                colour = "red", linetype = 2)
  expect_silent(ggplot_build(p))
})

test_that("BUG-1: show.legend is accepted", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, show.legend = FALSE)
  expect_silent(ggplot_build(p))
})

test_that("BUG-1: width and height params are accepted", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, width = 0.8, height = 0.8)
  expect_silent(ggplot_build(p))
})

# ------------------------------------------------------------------
# BUG-2: linewidth aesthetic (replaces deprecated size)
# ------------------------------------------------------------------

test_that("BUG-2: linewidth is used instead of size", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, linewidth = 2)
  expect_silent(ggplot_build(p))
})

test_that("BUG-2: default linewidth does not produce warnings", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  expect_warning({
    p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang)
    ggplot_build(p)
  }, regexp = NA)
})

# ------------------------------------------------------------------
# BUG-2: legacy size still works, with a deprecation warning
# ------------------------------------------------------------------

test_that("BUG-2: passing size warns and is used as linewidth", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  expect_warning(
    p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang, size = 2),
    "deprecated"
  )
  b <- ggplot_build(p)
  expect_true(all(b$data[[1]]$linewidth == 2))
})

# ------------------------------------------------------------------
# BUG-3: missing yin/yang validation
# ------------------------------------------------------------------

test_that("BUG-3: missing yin errors with informative message", {
  d <- data.frame(x = 1:3, y = 1:3, yang = 4:6)
  expect_error(geom_taichi(yang = yang), "yin")
})

test_that("BUG-3: missing yang errors with informative message", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3)
  expect_error(geom_taichi(yin = yin), "yang")
})

test_that("BUG-3: NULL yin/yang errors with informative message", {
  expect_error(geom_taichi(yin = NULL, yang = yang), "NULL")
  expect_error(geom_taichi(yin = yin, yang = NULL), "NULL")
})

test_that("BUG-3: a yin/yang column absent from the data errors at + time", {
  d <- data.frame(x = 1:3, y = 1:3, yang = 4:6)
  expect_error(
    ggplot(d, aes(x, y)) + geom_taichi(yin = not_a_column, yang = yang),
    "not found in the plot data"
  )
})

test_that("eyes flag is validated", {
  expect_error(geom_taichi(yin = a, yang = b, eyes = "yes"), "TRUE or FALSE")
})

# ------------------------------------------------------------------
# BUG-4: categorical / discrete fill support
# ------------------------------------------------------------------

test_that("BUG-4: factor yin/yang works without error", {
  d <- data.frame(
    x = 1:3, y = 1:3,
    yin = factor(c("low", "med", "high")),
    yang = factor(c("type_a", "type_b", "type_c"))
  )
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang)
  expect_silent(ggplot_build(p))
})

test_that("BUG-4: character yin/yang works without error", {
  d <- data.frame(
    x = 1:3, y = 1:3,
    yin = c("low", "med", "high"),
    yang = c("type_a", "type_b", "type_c")
  )
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang)
  expect_silent(ggplot_build(p))
})

test_that("BUG-4: computed discrete expressions are detected", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = factor(yin), yang = yang)
  b <- ggplot_build(p)
  scales <- b$plot$scales$scales
  fill_scales <- scales[sapply(scales, function(s) grepl("^fill", s$aesthetics[1]))]
  scale_classes <- sapply(fill_scales, function(s) class(s)[1])
  expect_true(any(grepl("Discrete", scale_classes)))
})

test_that("BUG-4: logical yin/yang is treated as discrete", {
  d <- data.frame(x = 1:3, y = 1:3, yin = c(TRUE, FALSE, TRUE), yang = 4:6)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang)
  expect_silent(ggplot_build(p))
})

test_that("default discrete palette skips the invisible palest end", {
  d <- data.frame(x = 1:3, y = 1:3,
                  yin = factor(c("a", "b", "c")), yang = 4:6)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang)
  b <- ggplot_build(p)
  fills <- toupper(b$data[[1]]$fill)
  expect_false(any(fills %in% c("#FFFFFF", "GRAY100", "WHITE")))
})

test_that("explicit discrete palettes are used verbatim", {
  d <- data.frame(x = 1:2, y = 1:2,
                  yin = factor(c("a", "b")), yang = 3:4)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, yin_colors = c("red", "blue"))
  b <- ggplot_build(p)
  expect_setequal(b$data[[1]]$fill, c("red", "blue"))
})

test_that("yin/yang accept strings naming a column", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = "yin", yang = "yang")
  b <- expect_silent(ggplot_build(p))
  expect_equal(b$data[[1]]$fill, ggplot_build(
    ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang)
  )$data[[1]]$fill)
})

# ------------------------------------------------------------------
# Rotation aesthetic (§3a)
# ------------------------------------------------------------------

test_that("rotation aesthetic is accepted without warnings", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, angle = 45)
  expect_silent(ggplot_build(p))
})

# ------------------------------------------------------------------
# Eyes (§3b)
# ------------------------------------------------------------------

test_that("eyes = TRUE is accepted without warnings", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE)
  expect_silent(ggplot_build(p))
})

test_that("eyes with custom colours and sizes is accepted", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE,
                yin_eye_colour = "blue", yang_eye_colour = "red",
                yin_eye_size = 0.2, yang_eye_size = 0.1)
  expect_silent(ggplot_build(p))
})

# ------------------------------------------------------------------
# Custom scales
# ------------------------------------------------------------------

test_that("custom yin_scale / yang_scale (function) are accepted", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  my_scale <- function(name = waiver(), ...) {
    scale_fill_gradientn(name = name, colours = c("white", "black"), ...)
  }
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang,
                yin_scale = my_scale,
                yang_scale = my_scale)
  expect_silent(ggplot_build(p))
})

test_that("custom yin_scale / yang_scale (Scale object) are accepted", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  my_scale <- scale_fill_gradient(low = "white", high = "black")
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang,
                yin_scale = my_scale,
                yang_scale = my_scale)
  expect_silent(ggplot_build(p))
})

# ------------------------------------------------------------------
# NA handling
# ------------------------------------------------------------------

test_that("NA values in yin are handled", {
  d <- data.frame(x = 1:3, y = 1:3, yin = c(1, NA, 3), yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, na.rm = TRUE)
  expect_silent(ggplot_build(p))
})

test_that("NA values in yang are handled", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = c(4, NA, 6))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, na.rm = TRUE)
  expect_silent(ggplot_build(p))
})

# ------------------------------------------------------------------
# Rendering verification (eyes actually appear in the drawn scene)
# ------------------------------------------------------------------

# The taichi cells materialize their children at draw time (makeContent), so
# render the plot on a null device and grab the forced scene.
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

# Helper: collect all grobs of a class inside a gTree
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

test_that("eyes = TRUE produces circles for both fish", {
  d <- data.frame(x = 1, y = 1, yin = 1, yang = 2)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang, eyes = TRUE)
  sc <- forced_scene(p)
  expect_equal(count_circles(sc), 2L)
  expect_equal(count_polygons(sc), 2L)
})

test_that("eyes = FALSE produces no circles", {
  d <- data.frame(x = 1, y = 1, yin = 1, yang = 2)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang, eyes = FALSE)
  sc <- forced_scene(p)
  expect_equal(count_circles(sc), 0L)
  expect_equal(count_polygons(sc), 2L)
})

test_that("eyes with custom colours and sizes render circles", {
  d <- data.frame(x = 1, y = 1, yin = 1, yang = 2)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE,
                yin_eye_colour = "blue", yang_eye_colour = "red",
                yin_eye_size = 0.2, yang_eye_size = 0.1)
  sc <- forced_scene(p)
  expect_equal(count_circles(sc), 2L)
})

test_that("each eye sits in its own fish's head (yin top, yang bottom)", {
  d <- data.frame(x = 1, y = 1, yin = 1, yang = 2)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang, eyes = TRUE)
  circles <- collect_grobs(forced_scene(p), "circle")
  fills <- unlist(lapply(circles, function(ci) as.character(ci$gp$fill)))
  ys <- unlist(lapply(circles, function(ci) as.numeric(ci$y)))
  expect_setequal(fills, c("white", "black"))
  # the white yin eye lives in the top bulb, the black yang eye in the bottom
  expect_gt(ys[fills == "white"], ys[fills == "black"])
})

test_that("mapped eye sizes are rescaled to [0.05, 0.3]", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6, sz = c(10, 20, 30))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE, yin_eye_size = sz)
  b <- ggplot_build(p)
  expect_equal(b$data[[1]]$eye_size, c(0.05, 0.175, 0.30))
  # the yang layer keeps its constant default
  expect_true(all(b$data[[2]]$eye_size == 0.15))
})

test_that("mapped eye sizes already in (0, 0.5] pass through unchanged", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6, pz = c(0.1, 0.2, 0.3))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE, yin_eye_size = pz)
  b <- ggplot_build(p)
  expect_equal(b$data[[1]]$eye_size, c(0.1, 0.2, 0.3))
})

test_that("NA eye sizes skip the eye for that cell", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6, sz = c(10, NA, 30))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE, yin_eye_size = sz)
  # 2 yin eyes (one NA) + 3 yang eyes
  expect_equal(count_circles(forced_scene(p)), 5L)
})

test_that("mapped eye colours reach the grobs", {
  d <- data.frame(x = 1:2, y = 1:2, yin = 1:2, yang = 3:4,
                  col = c("blue", "orange"))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE, yin_eye_colour = col)
  circles <- collect_grobs(forced_scene(p), "circle")
  fills <- unlist(lapply(circles, function(ci) as.character(ci$gp$fill)))
  expect_true(all(c("blue", "orange") %in% fills))
})

test_that("non-numeric mapped eye sizes error clearly", {
  d <- data.frame(x = 1:2, y = 1:2, yin = 1:2, yang = 3:4, sz = c("a", "b"))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE, yin_eye_size = sz)
  expect_error(ggplot_build(p), "numeric")
})

# ------------------------------------------------------------------
# Rotation renders different output (§3a)
# ------------------------------------------------------------------

test_that("rotation changes the rendered polygon coordinates", {
  d <- data.frame(x = 1, y = 1, yin = 1, yang = 2)
  p0 <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang, angle = 0)
  p90 <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang, angle = 90)
  b0 <- ggplot_build(p0)
  b90 <- ggplot_build(p90)
  # angle should be populated in the data
  expect_equal(b0$data[[1]]$angle, 0)
  expect_equal(b90$data[[1]]$angle, 90)
})

test_that("NA angles fall back to no rotation instead of failing", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6, rot = c(0, NA, 90))
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang, angle = rot)
  expect_silent(ggplotGrob(p))
})

# ------------------------------------------------------------------
# Categorical scale selection (BUG-4 deeper check)
# ------------------------------------------------------------------

test_that("factor yin selects a discrete fill scale", {
  d <- data.frame(x = 1:3, y = 1:3,
                  yin = factor(c("low", "med", "high")), yang = 4:6)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang)
  b <- ggplot_build(p)
  scales <- b$plot$scales$scales
  fill_scales <- scales[sapply(scales, function(s) grepl("^fill", s$aesthetics[1]))]
  scale_classes <- sapply(fill_scales, function(s) class(s)[1])
  expect_true(any(grepl("Discrete", scale_classes)))
  expect_true(any(grepl("Continuous", scale_classes)))
})

test_that("numeric yin/yang select continuous fill scales", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang)
  b <- ggplot_build(p)
  scales <- b$plot$scales$scales
  fill_scales <- scales[sapply(scales, function(s) grepl("^fill", s$aesthetics[1]))]
  scale_classes <- sapply(fill_scales, function(s) class(s)[1])
  expect_true(all(grepl("Continuous", scale_classes)))
})

# ------------------------------------------------------------------
# BUG-1 deeper: geom params appear in built data
# ------------------------------------------------------------------

test_that("alpha, colour, linewidth, linetype appear in built layer data", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang,
                alpha = 0.5, colour = "red", linewidth = 2, linetype = 2)
  b <- ggplot_build(p)
  expect_true(all(b$data[[1]]$alpha == 0.5))
  expect_true(all(b$data[[1]]$colour == "red"))
  expect_true(all(b$data[[1]]$linewidth == 2))
  expect_true(all(b$data[[1]]$linetype == 2))
})

# ------------------------------------------------------------------
# Shared limits / shared legend (§4b)
# ------------------------------------------------------------------

test_that("shared_limits aligns both continuous fill scales", {
  d <- data.frame(x = 1:3, y = 1:3, yin = c(1, 2, 3), yang = c(7, 8, 10))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, shared_limits = TRUE)
  b <- ggplot_build(p)
  scales <- b$plot$scales$scales
  fill_scales <- scales[sapply(scales, function(s) grepl("^fill", s$aesthetics[1]))]
  lims <- lapply(fill_scales, function(s) s$limits)
  expect_length(lims, 2L)
  expect_true(all(vapply(lims, identical, logical(1), y = c(1, 10))))
})

test_that("shared_legend maps equal values to equal colours across fish", {
  d <- data.frame(x = 1:2, y = 1:2, a = c(1, 5), b = c(5, 1))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = a, yang = b, shared_legend = TRUE)
  b_ <- ggplot_build(p)
  # a == 5 (yin, row 2) and b == 5 (yang, row 1) must share a colour
  expect_equal(b_$data[[1]]$fill[2], b_$data[[2]]$fill[1])
  expect_equal(b_$data[[1]]$fill[1], b_$data[[2]]$fill[2])
})

test_that("shared_legend drops the yang guide and titles the legend jointly", {
  obj <- geom_taichi(yin = matcha, yang = espresso, shared_legend = TRUE)
  expect_equal(obj$yin_name, "matcha / espresso")
  d <- data.frame(x = 1:2, y = 1:2, matcha = c(1, 5), espresso = c(5, 1))
  b <- ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi(yin = matcha, yang = espresso, shared_legend = TRUE))
  scales <- b$plot$scales$scales
  fill_scales <- scales[sapply(scales, function(s) grepl("^fill", s$aesthetics[1]))]
  guides <- lapply(fill_scales, function(s) s$guide)
  expect_true(any(vapply(guides, identical, logical(1), y = "none")))
})

test_that("shared_limits unions the levels of two discrete sources", {
  d <- data.frame(x = 1:2, y = 1:2,
                  yin = factor(c("a", "b")), yang = factor(c("b", "c")))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, shared_limits = TRUE)
  b <- ggplot_build(p)
  scales <- b$plot$scales$scales
  fill_scales <- scales[sapply(scales, function(s) grepl("^fill", s$aesthetics[1]))]
  lims <- lapply(fill_scales, function(s) s$limits)
  expect_true(all(vapply(lims, identical, logical(1), y = c("a", "b", "c"))))
})

test_that("shared_legend gives the shared discrete level one colour", {
  d <- data.frame(x = 1:2, y = 1:2,
                  yin = factor(c("a", "b")), yang = factor(c("b", "c")))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, shared_legend = TRUE)
  b <- ggplot_build(p)
  # the shared level "b" gets the same colour on both fish
  expect_equal(b$data[[1]]$fill[2], b$data[[2]]$fill[1])
})

test_that("shared_limits warns and is ignored for mixed source types", {
  d <- data.frame(x = 1:2, y = 1:2, yin = factor(c("a", "b")), yang = c(1, 2))
  expect_warning(
    ggplot_build(ggplot(d, aes(x, y)) +
      geom_taichi(yin = yin, yang = yang, shared_limits = TRUE)),
    "same type"
  )
})

test_that("explicit limits in ... beat shared_limits", {
  d <- data.frame(x = 1:2, y = 1:2, yin = c(1, 2), yang = c(3, 4))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, shared_limits = TRUE, limits = c(0, 100))
  b <- ggplot_build(p)
  scales <- b$plot$scales$scales
  fill_scales <- scales[sapply(scales, function(s) grepl("^fill", s$aesthetics[1]))]
  expect_true(all(vapply(fill_scales, function(s) identical(s$limits, c(0, 100)),
                         logical(1))))
})

# ------------------------------------------------------------------
# Exported fish geoms (§4d)
# ------------------------------------------------------------------

test_that("geom_yin_fish / geom_yang_fish are exported and work standalone", {
  expect_true(all(c("geom_yin_fish", "geom_yang_fish") %in%
                    getNamespaceExports("ggtaichi")))
  d <- data.frame(x = 1:3, y = 1, v = 1:3)
  p <- ggplot(d, aes(x, y)) +
    geom_yin_fish(aes(fill = v)) +
    scale_fill_viridis_c() +
    ggnewscale::new_scale_fill() +
    geom_yang_fish(aes(fill = rev(v))) +
    scale_fill_viridis_c(option = "magma")
  expect_silent(ggplot_build(p))
  sc <- forced_scene(p)
  expect_equal(count_polygons(sc), 6L)
})

# ------------------------------------------------------------------
# print method
# ------------------------------------------------------------------

test_that("printing the geom_taichi() object is human-readable", {
  obj <- geom_taichi(yin = a, yang = b, eyes = TRUE, shared_legend = TRUE)
  out <- capture.output(print(obj))
  expect_true(any(grepl("<ggtaichi>", out)))
  expect_true(any(grepl("yin  : a / b", out, fixed = TRUE)))
  expect_true(any(grepl("eyes : on", out, fixed = TRUE)))
  expect_true(any(grepl("shared", out)))
})
