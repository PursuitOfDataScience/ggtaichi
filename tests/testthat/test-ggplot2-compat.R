library(ggplot2)
library(ggtaichi)

# Currency with the ggplot2 the user actually has.
#
# ggplot2 4.0.0 moved much of its class system to S7 and gave themes control
# of geom defaults. ggtaichi still dispatches S3 methods (`ggplot_add`,
# `print`, `makeContent`) on those objects and still supports ggplot2 3.4, so
# these tests pin down the two things that could quietly break: that the `+`
# chain reaches our methods, and that the theme-aware defaults resolve to the
# appearance the package has always had.

d <- data.frame(x = rep(1:3, 3), y = rep(1:3, each = 3),
                yin = 1:9, yang = 9:1)

test_that("ggplot_add dispatch reaches ggtaichi on this ggplot2", {
  obj <- geom_taichi(yin = yin, yang = yang)
  expect_s3_class(obj, "ggtaichi_plot")

  p <- ggplot(d, aes(x, y)) + obj
  expect_s3_class(p, "ggplot")
  # two fish layers, and the ggnewscale break between their fill scales
  expect_length(p$layers, 2)
  expect_s3_class(p$layers[[1]]$geom, "GeomYinFish")
  expect_s3_class(p$layers[[2]]$geom, "GeomYangFish")
  expect_true(any(vapply(p$scales$scales,
                         function(s) any(grepl("^fill", s$aesthetics)),
                         logical(1))))
})

test_that("the other ggplot_add methods dispatch too", {
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang) +
    remove_padding()
  expect_s3_class(p, "ggplot")
  p2 <- ggplot(d, aes(x, y)) + geom_taichi_diff(yin = yin, yang = yang)
  expect_s3_class(p2, "ggplot")
  expect_length(p2$layers, 1)
})

test_that("the S3 methods are registered, whatever ggplot2's own classes do", {
  for (m in c("ggplot_add.ggtaichi_plot", "ggplot_add.ggtaichi_diff",
              "ggplot_add.taichi_padding", "makeContent.taichi_cells",
              "print.ggtaichi_plot", "print.ggtaichi_diff",
              "print.taichi_palette_check")) {
    expect_true(
      !is.null(utils::getS3method(sub("\\..*$", "", m),
                                  sub("^[^.]*\\.", "", m),
                                  optional = TRUE,
                                  envir = asNamespace("ggtaichi"))),
      info = m
    )
  }
})

test_that("a ggtaichi plot survives being built and rendered end to end", {
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE) +
    facet_wrap(~ y) + coord_fixed() + theme_taichi()
  expect_silent(gt <- ggplot_gtable(ggplot_build(p)))
  expect_s3_class(gt, "gtable")
})

# ------------------------------------------------------------------
# Theme-driven geom defaults
# ------------------------------------------------------------------

test_that("the fallbacks are exactly the appearance of earlier releases", {
  b <- ggplot_build(ggplot(d, aes(x, y)) + geom_yin_fish())
  fill <- grDevices::col2rgb(unique(b$data[[1]]$fill))[, 1]
  expect_equal(unname(fill), unname(grDevices::col2rgb("grey20")[, 1]))
  expect_equal(unique(b$data[[1]]$linewidth), 0.1)
  expect_equal(unique(b$data[[1]]$linetype), 1)
  expect_true(is.na(unique(b$data[[1]]$colour)))
})

test_that("the eyes are white on yin and black on yang by default", {
  b <- ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE))
  expect_equal(unique(b$data[[1]]$eye_colour), "white")
  expect_equal(unique(b$data[[2]]$eye_colour), "black")
})

test_that("an explicit eye colour still wins", {
  b <- ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE,
                yin_eye_colour = "red", yang_eye_colour = "blue"))
  expect_equal(unique(b$data[[1]]$eye_colour), "red")
  expect_equal(unique(b$data[[2]]$eye_colour), "blue")
})

test_that("a dark theme flips the fallbacks instead of hiding the glyph", {
  skip_if_not(ggtaichi:::has_themed_aes(), "ggplot2 < 4.0.0")
  b <- ggplot_build(
    ggplot(d, aes(x, y)) + geom_yin_fish() + geom_yang_fish() +
      theme(geom = element_geom(ink = "white", paper = "black"))
  )
  # the fill moves to the light side of the palette instead of staying grey20
  lum <- function(col) {
    farver::convert_colour(t(grDevices::col2rgb(col)),
                           from = "rgb", to = "lab")[1, "l"]
  }
  expect_gt(lum(unique(b$data[[1]]$fill)), 60)
  # and the eyes swap, so each still contrasts with its own fish
  expect_equal(unique(b$data[[1]]$eye_colour), "black")
  expect_equal(unique(b$data[[2]]$eye_colour), "white")
})

test_that("a theme's geom fill overrides the ink/paper mix", {
  skip_if_not(ggtaichi:::has_themed_aes(), "ggplot2 < 4.0.0")
  b <- ggplot_build(ggplot(d, aes(x, y)) + geom_yin_fish() +
    theme(geom = element_geom(fill = "#123456")))
  expect_equal(unname(grDevices::col2rgb(unique(b$data[[1]]$fill))[, 1]),
               unname(grDevices::col2rgb("#123456")[, 1]))
})

test_that("linewidth follows the theme's borderwidth", {
  skip_if_not(ggtaichi:::has_themed_aes(), "ggplot2 < 4.0.0")
  b <- ggplot_build(ggplot(d, aes(x, y)) + geom_yin_fish() +
    theme(geom = element_geom(borderwidth = 1)))
  expect_equal(unique(b$data[[1]]$linewidth), 0.2)
})

test_that("has_themed_aes agrees with the installed ggplot2", {
  expect_equal(ggtaichi:::has_themed_aes(),
               utils::packageVersion("ggplot2") >= "4.0.0")
})
