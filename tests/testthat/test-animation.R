library(ggplot2)
library(ggtaichi)

# gganimate transitions must actually advance.
#
# gganimate tracks which rows belong to which frame by encoding the frame into
# the `group` column, as a "<id>" suffix. Before 0.3.0 the geom's setup_data()
# reset `group` to seq_len(nrow(data)) whenever it held duplicates, which threw
# that away and collapsed every transition to a single frame. It did so
# silently, because the animations vignette only ever built the gganim object
# and left every animate() call commented out for CI. These tests render
# frames with file_renderer(), which needs no gifski, no ffmpeg and no system
# libraries, so the regression is caught wherever gganimate is installed.

test_that("setup_data leaves gganimate's frame encoding in `group` intact", {
  # the mechanism, tested directly (and without gganimate), so a future change
  # to setup_data fails here with an explanatory name rather than only as a
  # frame count. Duplicated on purpose: the code before 0.3.0 only rewrote
  # `group` when it had duplicates, which is exactly the case gganimate
  # produces when several cells share a frame
  d <- data.frame(x = 1:3, y = 1, fill = 1:3,
                  group = c("-1<1>", "-1<1>", "-1<1>"),
                  PANEL = factor(1))
  out <- ggtaichi:::taichi_setup_data(d, list())
  expect_equal(out$group, c("-1<1>", "-1<1>", "-1<1>"))
})

skip_if_not_installed("gganimate")

# How many frames were rendered, and how many of them differ. The count alone
# is not enough: a transition that collapses (the pre-0.3.0 bug) can still
# write the requested number of files, all of them the same picture.
render_frames <- function(p, nframes = 12) {
  dir <- tempfile("taichi-frames")
  dir.create(dir)
  on.exit(unlink(dir, recursive = TRUE), add = TRUE)
  # transition_manual() fixes its own frame count and says so in a message
  # ("`nframes` and `fps` adjusted to match transition"); that is gganimate
  # talking, not something under test
  files <- suppressMessages(gganimate::animate(
    p,
    nframes = nframes,
    renderer = gganimate::file_renderer(dir, overwrite = TRUE)
  ))
  list(n = length(files), distinct = length(unique(tools::md5sum(files))))
}
n_frames <- function(p, nframes = 12) render_frames(p, nframes)$n

anim_data <- local({
  d <- expand.grid(x = 1:3, f = 1:6)
  d$y <- 1
  d$yin <- d$x
  d$yang <- 4 - d$x
  d$turn <- (d$f - 1) * 15
  d$level <- d$f
  d
})

test_that("transition_manual gives one frame per state", {
  p <- ggplot(anim_data, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, limits = c(0, 4)) +
    gganimate::transition_manual(f)
  expect_equal(n_frames(p), 6L)
})

test_that("transition_states tweens across frames", {
  # the fills change from state to state, so the tweened frames must differ
  p <- ggplot(anim_data, aes(x, y)) +
    geom_taichi(yin = level, yang = 7 - level, limits = c(0, 7)) +
    gganimate::transition_states(f, transition_length = 1, state_length = 0)
  fr <- render_frames(p, nframes = 12)
  expect_equal(fr$n, 12L)
  expect_gte(fr$distinct, 6L)
})

test_that("a rotating glyph animates, which is the package's own demo", {
  p <- ggplot(anim_data, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, angle = turn, eyes = TRUE,
                limits = c(0, 4)) +
    gganimate::transition_manual(f)
  fr <- render_frames(p)
  expect_equal(fr$n, 6L)
  # one angle per state, so six different pictures
  expect_equal(fr$distinct, 6L)
})

test_that("the individual fish geoms animate too", {
  p <- ggplot(anim_data, aes(x, y)) +
    geom_yin_fish(aes(fill = yin, angle = turn)) +
    gganimate::transition_manual(f)
  fr <- render_frames(p)
  expect_equal(fr$n, 6L)
  expect_equal(fr$distinct, 6L)
})
