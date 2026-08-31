library(ggplot2)
library(ggtaichi)

d <- data.frame(x = rep(1:3, 3), y = rep(1:3, each = 3),
                yin = 1:9, yang = 9:1)
dd <- data.frame(x = 1:3, y = 1, g = factor(c("a", "b", "c")))

test_that("every scale_taichi_* constructor governs the fill aesthetic", {
  fns <- list(
    scale_taichi_yin_c, scale_taichi_yang_c,
    scale_taichi_yin_d, scale_taichi_yang_d,
    scale_taichi_yin_binned, scale_taichi_yang_binned,
    scale_taichi_yin_viridis_c, scale_taichi_yang_viridis_c,
    scale_taichi_yin_viridis_d, scale_taichi_yang_viridis_d
  )
  for (f in fns) {
    s <- f()
    expect_s3_class(s, "Scale")
    expect_true("fill" %in% s$aesthetics)
  }
})

test_that("the continuous constructors carry the requested palette", {
  s <- scale_taichi_yin_c(palette = "brewer_pair")
  expect_equal(s$palette(0), taichi_palette("brewer_pair")$yin[1])
  s2 <- scale_taichi_yang_c(colors = c("white", "purple"))
  expect_equal(s2$palette(0), "#FFFFFF")
})

test_that("the discrete constructors size themselves to the data", {
  b <- ggplot_build(ggplot(dd, aes(x, y)) +
    geom_taichi(yin = g, yang = g,
                yin_scale = scale_taichi_yin_d(),
                yang_scale = scale_taichi_yang_d()))
  expect_length(unique(b$data[[1]]$fill), 3)
  # the palest end of the ramp is skipped, as it is for the automatic palette
  s <- scale_taichi_yin_d()
  expect_false(s$palette(3)[1] == taichi_palette("default")$yin[1])
})

test_that("the binned constructors produce a binned scale", {
  s <- scale_taichi_yin_binned(n.breaks = 4)
  expect_s3_class(s, "ScaleBinned")
  b <- ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang,
                yin_scale = scale_taichi_yin_binned(n.breaks = 4),
                yang_scale = scale_taichi_yang_binned(n.breaks = 4)))
  # a binned fill takes far fewer distinct colours than a continuous one
  expect_lt(length(unique(b$data[[1]]$fill)), 9)
})

test_that("shared_limits reaches a supplied scale object", {
  b <- ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang,
                yin_scale = scale_taichi_yin_binned(n.breaks = 4),
                yang_scale = scale_taichi_yang_binned(n.breaks = 4),
                shared_limits = TRUE))
  scales <- b$plot$scales$scales
  fills <- Filter(function(s) any(grepl("^fill", s$aesthetics)), scales)
  for (s in fills) expect_equal(s$limits, c(1, 9))
})

test_that("shared_limits reaches a supplied scale constructor", {
  b <- ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang,
                yin_scale = scale_taichi_yin_viridis_c,
                yang_scale = scale_taichi_yang_viridis_c,
                shared_limits = TRUE))
  fills <- Filter(function(s) any(grepl("^fill", s$aesthetics)),
                  b$plot$scales$scales)
  for (s in fills) expect_equal(s$limits, c(1, 9))
})

test_that("a supplied scale's own limits still win", {
  b <- ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang,
                yin_scale = scale_taichi_yin_c(limits = c(0, 20)),
                shared_limits = TRUE))
  yin_scale <- b$plot$scales$scales[[1]]
  expect_equal(yin_scale$limits, c(0, 20))
})

test_that("shared_legend drops the duplicate guide from a supplied scale", {
  b <- ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang,
                yang_scale = scale_taichi_yang_binned(),
                shared_legend = TRUE))
  fills <- Filter(function(s) any(grepl("^fill", s$aesthetics)),
                  b$plot$scales$scales)
  guides <- vapply(fills, function(s) {
    g <- s$guide
    if (is.character(g)) g else class(g)[1]
  }, character(1))
  expect_true("none" %in% guides)
})

test_that("equal values land in the same bin once limits are shared", {
  # the point of binning both fish against one set of breaks
  dsym <- data.frame(x = 1:3, y = 1, a = c(1, 5, 9), b = c(1, 5, 9))
  b <- ggplot_build(ggplot(dsym, aes(x, y)) +
    geom_taichi(yin = a, yang = b,
                yin_scale = scale_taichi_yin_binned(n.breaks = 4),
                yang_scale = scale_taichi_yin_binned(n.breaks = 4),
                shared_limits = TRUE))
  expect_equal(b$data[[1]]$fill, b$data[[2]]$fill)
})

test_that("an explicit colour vector beats the palette argument", {
  s <- scale_taichi_yin_c(palette = "balanced", colors = c("white", "black"))
  expect_equal(s$palette(1), "#000000")
})

test_that("a bad palette or colour vector is rejected by the constructors", {
  expect_error(scale_taichi_yin_c(palette = "nope"), "must be one of")
  expect_error(scale_taichi_yin_c(colors = 1:3), "character vector")
})
