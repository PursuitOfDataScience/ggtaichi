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
