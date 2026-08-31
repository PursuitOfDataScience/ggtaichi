library(ggplot2)
library(ggtaichi)

# ------------------------------------------------------------------
# The statistics
# ------------------------------------------------------------------

test_that("taichi_summary computes every statistic per cell", {
  d <- data.frame(x = 1:3, y = 1, a = c(1, 5, 9), b = c(9, 5, 1))
  s <- taichi_summary(d, yin = a, yang = b, x = x, y = y)

  expect_s3_class(s, "data.frame")
  expect_equal(names(s), c("x", "y", "yin", "yang", "difference", "ratio",
                           "log_ratio", "z", "dominant", "rank"))
  expect_equal(s$difference, c(-8, 0, 8))
  expect_equal(s$ratio, c(1 / 9, 1, 9))
  expect_equal(s$log_ratio, log2(c(1 / 9, 1, 9)))
  expect_equal(as.character(s$dominant), c("b", "tie", "a"))
  # widest gaps rank first, and the tie ranks last
  expect_equal(s$rank, c(1L, 3L, 1L))
})

test_that("taichi_summary's z standardises each source before differencing", {
  # b is a units-of-1000 version of a, so the raw difference is dominated by
  # b while the standardised one is exactly zero.
  d <- data.frame(a = c(1, 2, 3), b = c(1000, 2000, 3000))
  s <- taichi_summary(d, yin = a, yang = b)
  expect_true(all(abs(s$z) < 1e-12))
  expect_false(all(abs(s$difference) < 1e-12))
})

test_that("x and y are optional in taichi_summary", {
  d <- data.frame(a = 1:3, b = 3:1)
  s <- taichi_summary(d, yin = a, yang = b)
  expect_false(any(c("x", "y") %in% names(s)))
  expect_equal(nrow(s), 3)
})

test_that("a ratio of a non-positive value is NA, never Inf", {
  d <- data.frame(a = c(1, 0, -2), b = c(2, 4, 4))
  s <- taichi_summary(d, yin = a, yang = b)
  expect_equal(s$ratio, c(0.5, NA, NA))
  expect_false(any(is.infinite(s$ratio), na.rm = TRUE))
  # and the same rule inside the geom, with a warning this time
  expect_warning(
    ggtaichi:::taichi_explicit_stat(c(1, 0), c(2, 4), "ratio"),
    "positive"
  )
})

test_that("taichi_summary rejects non-numeric and missing columns", {
  d <- data.frame(a = letters[1:3], b = 1:3)
  expect_error(taichi_summary(d, yin = a, yang = b), "numeric")
  expect_error(taichi_summary(d, yin = nope, yang = b), "not found")
  expect_error(taichi_summary(1:3, yin = a, yang = b), "data frame")
})

test_that("a constant source contributes nothing to z instead of NaN", {
  expect_equal(ggtaichi:::zscore(rep(2, 4)), rep(0, 4))
})

# ------------------------------------------------------------------
# explicit = / explicit_channel =
# ------------------------------------------------------------------

d3 <- data.frame(x = 1:3, y = 1, yin = c(1, 5, 9), yang = c(9, 5, 1))

test_that("explicit = 'difference' drives eye size, zero gap meaning no eye", {
  b <- ggplot_build(ggplot(d3, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, explicit = "difference"))
  expect_equal(b$data[[1]]$eye_size, c(0.3, 0, 0.3))
  expect_equal(b$data[[2]]$eye_size, c(0.3, 0, 0.3))

  # the zero-gap cell draws no eye at all: 2 fish x 2 outer cells
  sc <- forced_scene(ggplot(d3, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, explicit = "difference"))
  expect_equal(count_circles(sc), 4L)
})

test_that("explicit = eye_size turns the eyes on by itself", {
  p <- ggplot(d3, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, explicit = "difference")
  expect_true(isTRUE(p$layers[[1]]$geom_params$eyes))
})

test_that("the angle channel is signed and symmetric about agreement", {
  b <- ggplot_build(ggplot(d3, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, explicit = "difference",
                explicit_channel = "angle"))
  expect_equal(b$data[[1]]$angle, c(-45, 0, 45))
})

test_that("the border channel does not go through ggplot2's linewidth scale", {
  b <- ggplot_build(ggplot(d3, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, explicit = "difference",
                explicit_channel = "border"))
  # the values stay in the range we asked for, rather than being re-ranged
  # into scale_linewidth_continuous()'s default c(1, 6)
  expect_equal(b$data[[1]]$border, c(1, 0, 1))
  expect_true(all(b$data[[1]]$linewidth == 0.1))
  # and it becomes visible, since the default outline colour is NA
  expect_equal(unique(b$data[[1]]$colour), "grey20")
})

test_that("a per-cell border reaches the drawn grob as a line width", {
  sc <- forced_scene(ggplot(d3, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, explicit = "difference",
                explicit_channel = "border"))
  lwd <- collect_grobs(sc, "polygon")[[1]]$gp$lwd
  expect_equal(lwd, c(1, 0, 1) * .pt)
})

test_that("the radius channel scales by area and shrinks the drawn glyph", {
  b <- ggplot_build(ggplot(d3, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, explicit = "difference",
                explicit_channel = "radius"))
  expect_equal(b$data[[1]]$radius, c(1, 0.4, 1))

  span <- function(p) {
    pg <- collect_grobs(forced_scene(p), "polygon")[[1]]
    xs <- as.numeric(grid::convertX(pg$x, "pt"))
    i <- pg$id == 1
    max(xs[i]) - min(xs[i])
  }
  full <- span(ggplot(d3, aes(x, y)) + geom_yin_fish() + coord_fixed())
  half <- span(ggplot(d3, aes(x, y)) + geom_yin_fish(aes(radius = 0.5)) +
                 coord_fixed())
  expect_equal(half, full / 2, tolerance = 1e-6)
})

test_that("explicit_range overrides the channel default", {
  b <- ggplot_build(ggplot(d3, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, explicit = "difference",
                explicit_channel = "angle", explicit_range = c(-90, 90)))
  expect_equal(b$data[[1]]$angle, c(-90, 0, 90))
  expect_error(
    geom_taichi(yin = yin, yang = yang, explicit = "difference",
                explicit_range = 1),
    "two numbers"
  )
})

test_that("the statistic is rescaled across the whole layer, not per facet", {
  d <- data.frame(
    x = rep(1:2, 2), y = 1, f = rep(c("A", "B"), each = 2),
    yin = c(1, 2, 1, 9), yang = c(2, 1, 9, 1)
  )
  b <- ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, explicit = "difference",
                explicit_channel = "angle") +
    facet_wrap(~f))
  # panel A's gaps are +-1 against a layer-wide maximum of 8, so they stay
  # small; rescaling per panel would have made them +-45 too
  ang <- b$data[[1]]$angle
  expect_equal(sort(round(ang, 4)), sort(round(c(-45 / 8, 45 / 8, -45, 45), 4)))
})

test_that("a grid where the two sources agree everywhere degrades quietly", {
  d <- data.frame(x = 1:3, y = 1, a = c(2, 2, 2), b = c(2, 2, 2))
  b <- ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi(yin = a, yang = b, explicit = "difference"))
  expect_equal(b$data[[1]]$eye_size, rep(0, 3))
  ba <- ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi(yin = a, yang = b, explicit = "difference",
                explicit_channel = "angle"))
  expect_equal(ba$data[[1]]$angle, rep(0, 3))
})

test_that("explicit refuses to fight the same channel set by hand", {
  expect_error(
    geom_taichi(yin = yin, yang = yang, explicit = "difference",
                explicit_channel = "angle", angle = 30),
    "drives the same channel"
  )
  expect_error(
    geom_taichi(yin = yin, yang = yang, explicit = "difference",
                yin_eye_size = 0.2),
    "drives the same channel"
  )
  expect_error(
    geom_taichi(yin = yin, yang = yang, explicit = "difference",
                explicit_channel = "border", linewidth = 2),
    "drives the same channel"
  )
  expect_error(
    geom_taichi(yin = yin, yang = yang, explicit = "difference",
                eyes = FALSE),
    "needs the eyes"
  )
})

test_that("an unknown explicit method or channel errors", {
  expect_error(geom_taichi(yin = yin, yang = yang, explicit = "nope"))
  expect_error(geom_taichi(yin = yin, yang = yang, explicit = "difference",
                           explicit_channel = "nope"))
})

test_that("explicit needs numeric sources", {
  d <- data.frame(x = 1:2, y = 1, a = c("p", "q"), b = c(1, 2))
  expect_error(
    ggplot_build(ggplot(d, aes(x, y)) +
      geom_taichi(yin = a, yang = b, explicit = "difference")),
    "numeric"
  )
})

test_that("explicit = 'none' leaves every channel alone", {
  b <- ggplot_build(ggplot(d3, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang))
  expect_equal(unique(b$data[[1]]$angle), 0)
  expect_equal(unique(b$data[[1]]$radius), 1)
  expect_true(all(is.na(b$data[[1]]$border)))
})

# ------------------------------------------------------------------
# geom_taichi_diff()
# ------------------------------------------------------------------

test_that("geom_taichi_diff draws tiles on a symmetric diverging scale", {
  p <- ggplot(d3, aes(x, y)) + geom_taichi_diff(yin = yin, yang = yang)
  expect_s3_class(p$layers[[1]]$geom, "GeomTile")
  b <- ggplot_build(p)
  sc <- b$plot$scales$get_scales("fill")
  expect_equal(sc$limits, c(-8, 8))
  expect_equal(sc$name, "yin - yang")
})

test_that("geom_taichi_diff centres a ratio on 1, not 0", {
  p <- ggplot(d3, aes(x, y)) +
    geom_taichi_diff(yin = yin, yang = yang, method = "ratio")
  b <- ggplot_build(p)
  sc <- b$plot$scales$get_scales("fill")
  expect_equal(mean(sc$limits), 1)
})

test_that("geom_taichi_diff accepts explicit colours and midpoints", {
  p <- ggplot(d3, aes(x, y)) +
    geom_taichi_diff(yin = yin, yang = yang,
                     palette = c("blue", "white", "red"),
                     midpoint = 2, symmetric = FALSE, name = "gap")
  b <- ggplot_build(p)
  sc <- b$plot$scales$get_scales("fill")
  expect_null(sc$limits)
  expect_equal(sc$name, "gap")
})

test_that("geom_taichi_diff validates its arguments", {
  expect_error(geom_taichi_diff(yang = yang), "`yin` is required")
  expect_error(geom_taichi_diff(yin = yin), "`yang` is required")
  expect_error(geom_taichi_diff(yin = yin, yang = yang, method = "nope"))
  expect_error(
    geom_taichi_diff(yin = yin, yang = yang, midpoint = "a"),
    "single number"
  )
})

test_that("an all-agreeing grid does not ask for a zero-width scale", {
  d <- data.frame(x = 1:3, y = 1, a = rep(2, 3), b = rep(2, 3))
  b <- ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi_diff(yin = a, yang = b))
  expect_null(b$plot$scales$get_scales("fill")$limits)
})
