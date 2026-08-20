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

test_that("remove_padding returns a list of two scale objects", {
  result <- remove_padding(x = "c", y = "d")
  expect_type(result, "list")
  expect_length(result, 2)
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
  # same `...` is handed to both -- documented, so pin it
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
  # so it falls back to continuous and the discrete y fails at build time
  expect_error(
    ggplot_build(ggplot() + geom_yin_fish(data = mix, aes(x = x, y = y, fill = v)) +
                   remove_padding()),
    "Discrete value supplied to a continuous scale"
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
