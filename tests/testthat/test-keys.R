library(ggplot2)
library(ggtaichi)

dd <- data.frame(x = 1:3, y = 1, g = factor(c("a", "b", "c")))

key_of <- function(fish = "both", params = list()) {
  draw_key_taichi(data.frame(fill = "#336699", colour = NA, alpha = NA,
                             linewidth = 0.1, linetype = 1),
                  params, c(1.2, 1.2), fish = fish)
}

test_that("the key draws a whole taichi: two fish, in a square viewport", {
  k <- key_of()
  expect_s3_class(k, "gTree")
  polys <- collect_grobs(k, "polygon")
  expect_length(polys, 2)
  expect_equal(as.numeric(k$vp$width), 1)
  # a square viewport, so the glyph stays round whatever the key's shape
  expect_match(format(k$vp$width), "snpc")
  expect_equal(format(k$vp$width), format(k$vp$height))
})

same_colour <- function(a, b) {
  identical(grDevices::col2rgb(a)[, 1], grDevices::col2rgb(b)[, 1])
}

test_that("only the named fish carries the key's fill", {
  yin <- collect_grobs(key_of("yin"), "polygon")
  yang <- collect_grobs(key_of("yang"), "polygon")
  expect_true(same_colour(yin[[1]]$gp$fill, "#336699"))
  expect_true(is.na(yin[[2]]$gp$fill))
  expect_true(is.na(yang[[1]]$gp$fill))
  expect_true(same_colour(yang[[2]]$gp$fill, "#336699"))
})

test_that("'both' fills the yang fish with a pale version of the key colour", {
  polys <- collect_grobs(key_of("both"), "polygon")
  expect_true(same_colour(polys[[1]]$gp$fill, "#336699"))
  expect_false(same_colour(polys[[2]]$gp$fill, "#336699"))
  expect_false(is.na(polys[[2]]$gp$fill))
})

test_that("the key gets eyes only when the layer has them", {
  expect_length(collect_grobs(key_of("yin"), "circle"), 0)
  expect_length(collect_grobs(key_of("yin", list(eyes = TRUE)), "circle"), 1)
  expect_length(collect_grobs(key_of("both", list(eyes = TRUE)), "circle"), 2)
})

test_that("an unknown fish is rejected", {
  expect_error(key_of("shark"))
})

test_that("the fish geoms use the taichi key by default", {
  p <- ggplot(dd, aes(x, y)) + geom_taichi(yin = g, yang = g)
  keys <- collect_grobs(forced_scene(p), "taichi_key")
  # three levels x two legends
  expect_gte(length(keys), 6)
})

test_that("key_glyph = 'rect' restores the plain ggplot2 keys", {
  p <- ggplot(dd, aes(x, y)) + geom_taichi(yin = g, yang = g,
                                           key_glyph = "rect")
  expect_length(collect_grobs(forced_scene(p), "taichi_key"), 0)
})

test_that("key_glyph = draw_key_taichi gives the full symbol", {
  p <- ggplot(dd, aes(x, y)) +
    geom_yin_fish(aes(fill = g), key_glyph = draw_key_taichi)
  keys <- collect_grobs(forced_scene(p), "taichi_key")
  expect_gte(length(keys), 3)
  # the full-symbol key fills both fish
  fills <- vapply(collect_grobs(keys[[1]], "polygon"),
                  function(g) as.character(g$gp$fill), character(1))
  expect_false(any(is.na(fills)))
})

test_that("a continuous fill still gets a colourbar, not keys", {
  d <- data.frame(x = 1:3, y = 1, yin = 1:3, yang = 3:1)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang)
  expect_length(collect_grobs(forced_scene(p), "taichi_key"), 0)
})
