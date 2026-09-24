library(ggplot2)
library(ggtaichi)

test_that("theme_taichi()'s text grows with base_size", {
  # axis titles, tick labels and the plot title used to be fixed point sizes,
  # so base_size only reached the elements the theme did not restate
  size <- function(th, el) calc_element(el, th)$size
  big <- theme_taichi(base_size = 22)
  expect_equal(size(big, "axis.title.x"), 26)
  expect_equal(size(big, "axis.text.x"), 22)
  expect_equal(size(big, "plot.title"), 30)
  expect_equal(size(big, "legend.text"), 22)
})

test_that("the default sizes are exactly the ones the theme always had", {
  size <- function(el) calc_element(el, theme_taichi())$size
  expect_identical(size("axis.title.x"), 13)
  expect_identical(size("axis.text.y"), 11)
  expect_identical(size("plot.title"), 15)
})
