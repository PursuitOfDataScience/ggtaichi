test_that("cafes_tg is well-formed", {
  expect_s3_class(cafes_tg, "data.frame")
  expect_equal(nrow(cafes_tg), 96L)
  expect_named(cafes_tg, c("week", "neighbourhood", "espresso", "matcha"))
  expect_true(is.factor(cafes_tg$neighbourhood))
  expect_equal(nlevels(cafes_tg$neighbourhood), 8L)
  expect_equal(sort(unique(cafes_tg$week)), 1:12)
  expect_false(anyNA(cafes_tg))
  expect_true(all(cafes_tg$espresso >= 2 & cafes_tg$espresso <= 100))
  expect_true(all(cafes_tg$matcha >= 2 & cafes_tg$matcha <= 100))
})

test_that("cafes_tg draws with a shared legend", {
  library(ggplot2)
  p <- ggplot(cafes_tg, aes(x = week, y = neighbourhood)) +
    geom_taichi(yin = matcha, yang = espresso, shared_legend = TRUE)
  expect_silent(ggplot_build(p))
})
