library(ggplot2)
library(ggtaichi)

# gganimate transitions must actually advance.
#
# gganimate tracks which rows belong to which frame by encoding the frame into
# the `group` column, as a "<id>" suffix. Up to 0.3.0 the geom's setup_data()
# reset `group` to seq_len(nrow(data)), which threw that away and collapsed
# every transition to a single frame -- silently, because the animations
# vignette only ever built the gganim object and left every animate() call
# commented out for CI. These tests render frames with file_renderer(), which
# needs no gifski, no ffmpeg and no system libraries, so the regression is
# caught wherever gganimate is installed.

skip_if_not_installed("gganimate")

n_frames <- function(p, nframes = 12) {
  dir <- tempfile("taichi-frames")
  dir.create(dir)
  on.exit(unlink(dir, recursive = TRUE), add = TRUE)
  files <- gganimate::animate(
    p,
    nframes = nframes,
    renderer = gganimate::file_renderer(dir, overwrite = TRUE)
  )
  length(files)
}

anim_data <- local({
  d <- expand.grid(x = 1:3, f = 1:6)
  d$y <- 1
  d$yin <- d$x
  d$yang <- 4 - d$x
  d$turn <- (d$f - 1) * 15
  d
})

test_that("transition_manual gives one frame per state", {
  p <- ggplot(anim_data, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, limits = c(0, 4)) +
    gganimate::transition_manual(f)
  expect_equal(n_frames(p), 6L)
})

test_that("transition_states tweens across frames", {
  p <- ggplot(anim_data, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, limits = c(0, 4)) +
    gganimate::transition_states(f, transition_length = 1, state_length = 0)
  expect_equal(n_frames(p, nframes = 12), 12L)
})

test_that("a rotating glyph animates, which is the package's own demo", {
  p <- ggplot(anim_data, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, angle = turn, eyes = TRUE,
                limits = c(0, 4)) +
    gganimate::transition_manual(f)
  expect_equal(n_frames(p), 6L)
})

test_that("the individual fish geoms animate too", {
  p <- ggplot(anim_data, aes(x, y)) +
    geom_yin_fish(aes(fill = yin, angle = turn)) +
    gganimate::transition_manual(f)
  expect_equal(n_frames(p), 6L)
})

test_that("setup_data leaves gganimate's frame encoding in `group` intact", {
  # the mechanism, tested directly, so a future change to setup_data fails
  # here with an explanatory name rather than only as a frame count
  # duplicated on purpose: the 0.3.0 code only rewrote `group` when it had
  # duplicates, which is exactly the case gganimate produces when several
  # cells share a frame
  d <- data.frame(x = 1:3, y = 1, fill = 1:3,
                  group = c("-1<1>", "-1<1>", "-1<1>"),
                  PANEL = factor(1))
  out <- ggtaichi:::taichi_setup_data(d, list())
  expect_equal(out$group, c("-1<1>", "-1<1>", "-1<1>"))
})
