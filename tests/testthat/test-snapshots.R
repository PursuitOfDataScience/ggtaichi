# Visual-regression snapshots with vdiffr.
#
# These snapshots guard against silent rendering regressions in the glyph
# geometry, the eyes and the rotation.  They are skipped when vdiffr is not
# installed.
#
# They are also skipped on CRAN and on CI, because a single committed reference
# SVG cannot match every rendering stack.  Two things drift independently of
# ggtaichi: text metrics (the svglite / systemfonts versions and the platform's
# font stack shift every label by a fraction of a point, which moves the panel),
# and the continuous legend colourbar, which `guide_colourbar()` emits as an
# embedded base64 PNG that different R graphics engines encode differently --
# under R 4.3.2 six of these seven snapshots differ from the R >= 4.4 references
# by nothing but those raster bytes.  The references here were generated with
# R 4.4.1, ggplot2 4.0.3 and vdiffr 1.0.9; regenerate them on that stack (or
# whatever the current reference is) rather than on an older R.
#
# Run them locally (`devtools::test()`) to review visual changes; the package
# logic is covered by the non-visual tests.

skip_if_not_installed("vdiffr")
testthat::skip_on_ci()
# vdiffr already passes cran = FALSE to expect_snapshot_file(); this makes the
# same guarantee explicit and independent of that default.
testthat::skip_on_cran()

library(ggplot2)
library(ggtaichi)

# A small, deterministic grid used across several snapshots.
snap_data <- data.frame(
  x = rep(1:3, each = 3),
  y = rep(1:3, 3),
  yin = c(1, 5, 2, 8, 3, 7, 4, 6, 9),
  yang = c(9, 4, 6, 2, 7, 3, 8, 1, 5)
)

test_that("basic taichi grid snapshot", {
  p <- ggplot(snap_data, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang) +
    coord_fixed()
  vdiffr::expect_doppelganger("basic-taichi", p)
})

test_that("taichi with eyes snapshot", {
  p <- ggplot(snap_data, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE) +
    coord_fixed()
  vdiffr::expect_doppelganger("taichi-eyes", p)
})

test_that("taichi with data-driven eyes snapshot", {
  p <- ggplot(snap_data, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE,
                yin_eye_size = yang, yang_eye_size = yin) +
    coord_fixed()
  vdiffr::expect_doppelganger("taichi-data-eyes", p)
})

test_that("taichi with rotation snapshot", {
  p <- ggplot(snap_data, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, angle = 45) +
    coord_fixed()
  vdiffr::expect_doppelganger("taichi-rotated", p)
})

test_that("taichi with categorical fills snapshot", {
  d <- data.frame(
    x = c(1, 2, 1, 2),
    y = c(2, 2, 1, 1),
    yin = factor(c("A", "B", "C", "A")),
    yang = factor(c("win", "loss", "win", "loss"))
  )
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang) +
    coord_fixed()
  vdiffr::expect_doppelganger("taichi-categorical", p)
})

test_that("taichi with theme_taichi snapshot", {
  p <- ggplot(snap_data, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang) +
    coord_fixed() +
    theme_taichi()
  vdiffr::expect_doppelganger("taichi-themed", p)
})

test_that("taichi with a shared legend snapshot", {
  p <- ggplot(snap_data, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, shared_legend = TRUE) +
    coord_fixed()
  vdiffr::expect_doppelganger("taichi-shared-legend", p)
})
