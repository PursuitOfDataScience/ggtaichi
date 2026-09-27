test_that("remove_padding accepts 'c' and 'd' for x and y", {
  expect_error(remove_padding(x = "c", y = "d"), NA)
  expect_error(remove_padding(x = "c", y = "c"), NA)
  expect_error(remove_padding(x = "d", y = "c"), NA)
  expect_error(remove_padding(x = "d", y = "d"), NA)
})

test_that("remove_padding errors on invalid x", {
  expect_error(remove_padding(x = "x", y = "d"),
               "`x` only takes `c` or `d`")
})

test_that("remove_padding errors on invalid y", {
  expect_error(remove_padding(x = "c", y = "y"),
               "`y` only takes `c` or `d`")
})

test_that("remove_padding(x, y) adds two padding-free scales of those types", {
  library(ggplot2)
  d <- data.frame(x = 1:3, y = c("a", "b", "c"), yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang) +
    remove_padding(x = "c", y = "d")
  xs <- p$scales$get_scales("x")
  ys <- p$scales$get_scales("y")
  expect_true(inherits(xs, "ScaleContinuousPosition"))
  expect_true(inherits(ys, "ScaleDiscretePosition"))
  expect_equal(xs$expand, c(0, 0))
  expect_equal(ys$expand, c(0, 0))
})

test_that("remove_padding works with geom_taichi", {
  library(ggplot2)
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang) +
    remove_padding(x = "c", y = "c")
  expect_silent(ggplot_build(p))
})

test_that("remove_padding() auto-detects continuous x and discrete y", {
  library(ggplot2)
  d <- data.frame(x = 1:3, y = c("a", "b", "c"), yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang) +
    remove_padding()
  b <- ggplot_build(p)
  xs <- b$plot$scales$get_scales("x")
  ys <- b$plot$scales$get_scales("y")
  expect_true(inherits(xs, "ScaleContinuousPosition"))
  expect_true(inherits(ys, "ScaleDiscretePosition"))
  expect_equal(xs$expand, c(0, 0))
  expect_equal(ys$expand, c(0, 0))
})

test_that("remove_padding() auto mode honours a partial override", {
  library(ggplot2)
  d <- data.frame(x = 1:3, y = c("a", "b", "c"), yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang) +
    remove_padding(x = "c")
  b <- ggplot_build(p)
  expect_true(inherits(b$plot$scales$get_scales("y"), "ScaleDiscretePosition"))
})

test_that("... reaches both position scales", {
  library(ggplot2)
  mix <- data.frame(x = 1:3, y = c("a", "b", "c"), yin = 1:3, yang = 4:6)
  p <- function(...) ggplot(mix, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang) + remove_padding(...)
  # arguments both scale types accept are fine
  expect_silent(ggplot_build(p(x = "c", y = "d", name = "shared")))
  # a continuous-only argument is rejected by the discrete scale, because the
  # same `...` is handed to both; that is documented, so pin it
  expect_error(p(x = "c", y = "d", n.breaks = 3), "unused argument")
  # with axes of the same type it goes through
  same <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  expect_silent(ggplot_build(ggplot(same, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang) +
    remove_padding(x = "c", y = "c", n.breaks = 3)))
})

test_that("auto-detection reads the plot mapping, and the override rescues it", {
  library(ggplot2)
  mix <- data.frame(x = 1:3, y = c("a", "b", "c"), v = 1:3)
  # x/y mapped in the layer, not in ggplot(): nothing for detect_axis to read,
  # so it falls back to continuous and the discrete y fails at build time.
  # (ggplot2 3.5 words it "Discrete values supplied to continuous scale".)
  expect_error(
    ggplot_build(ggplot() + geom_yin_fish(data = mix, aes(x = x, y = y, fill = v)) +
                   remove_padding()),
    "Discrete values? supplied to (a )?continuous scale"
  )
  # naming the types explicitly is the documented way out
  expect_silent(
    ggplot_build(ggplot() + geom_yin_fish(data = mix, aes(x = x, y = y, fill = v)) +
                   remove_padding(x = "c", y = "d"))
  )
})

test_that("remove_padding() auto works with factor x from expressions", {
  library(ggplot2)
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(factor(x), y)) +
    geom_taichi(yin = yin, yang = yang) +
    remove_padding()
  b <- ggplot_build(p)
  expect_true(inherits(b$plot$scales$get_scales("x"), "ScaleDiscretePosition"))
  expect_true(inherits(b$plot$scales$get_scales("y"), "ScaleContinuousPosition"))
})

test_that("a date, date-time or time axis keeps its own scale and labels", {
  # scale_x_continuous() on a Date column printed day counts ("18420") where
  # the dates had been, and the bundled data sets all carry a Date column
  library(ggplot2)
  wk <- subset(pitts_tg, week <= 4)
  labels_of <- function(p) {
    ggplot_build(p)$layout$panel_params[[1]]$x$get_labels()
  }
  plain <- ggplot(wk, aes(week_start, category)) +
    geom_taichi(yin = Twitter, yang = Google)
  for (pad in list(remove_padding(), remove_padding(x = "c", y = "d"))) {
    p <- plain + pad
    xs <- p$scales$get_scales("x")
    expect_s3_class(xs, "ScaleContinuousDate")
    expect_equal(xs$expand, c(0, 0))
    expect_false(any(grepl("^[0-9]+$", stats::na.omit(labels_of(p)))))
  }

  dt <- data.frame(t = as.POSIXct("2026-01-01", tz = "UTC") + 3600 * 0:3,
                   y = 1, a = 1:4, b = 4:1)
  p <- ggplot(dt, aes(t, y)) + geom_taichi(yin = a, yang = b) +
    remove_padding()
  expect_s3_class(p$scales$get_scales("x"), "ScaleContinuousDatetime")

  # an hms column gets scale_*_time(); checked on the class alone, so the
  # test needs no hms package
  hms_like <- structure(3600 * 0:3, units = "secs",
                        class = c("hms", "difftime"))
  expect_identical(ggtaichi:::padding_scale("x", "c", hms_like),
                   ggplot2::scale_x_time)
  # and "d" is discrete whatever the data holds
  expect_identical(ggtaichi:::padding_scale("y", "d", wk$week_start),
                   ggplot2::scale_y_discrete)
})

test_that("a plotmath name passed through ... is handed on, not evaluated", {
  library(ggplot2)
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang) +
    remove_padding(name = quote(beta))
  expect_identical(p$scales$get_scales("x")$name, quote(beta))
  expect_no_error(ggplotGrob(p))
})
