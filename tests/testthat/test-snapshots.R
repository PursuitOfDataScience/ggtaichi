# Visual-regression snapshots with vdiffr.
#
# These snapshots guard against silent rendering regressions, especially once
# rotation and eyes land.  They are skipped when vdiffr is not installed.

skip_if_not_installed("vdiffr")

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
