library(ggplot2)
library(ggtaichi)

# What the package says out loud.
#
# The print methods and the error messages are part of the interface, so they
# are pinned with snapshots: a change to any of them should be a deliberate
# edit of the recorded text rather than something that slips out in a release.
# expect_snapshot() does not run on CRAN, so a message that reads differently
# under another locale cannot fail somebody else's check.

d <- data.frame(x = 1:3, y = 1, yin = c(1, 5, 9), yang = c(9, 5, 1))

test_that("geom_taichi() prints a readable summary of what it will draw", {
  expect_snapshot(print(geom_taichi(yin = Twitter, yang = Google)))
  expect_snapshot(
    print(geom_taichi(yin = Twitter, yang = Google, eyes = TRUE,
                      shared_legend = TRUE))
  )
  expect_snapshot(
    print(geom_taichi(yin = Twitter, yang = Google,
                      explicit = "log_ratio", explicit_channel = "angle",
                      interactive = TRUE, data_id_by = "source"))
  )
})

test_that("geom_taichi_diff() prints a summary too", {
  expect_snapshot(print(geom_taichi_diff(yin = matcha, yang = espresso)))
  expect_snapshot(
    print(geom_taichi_diff(yin = matcha, yang = espresso, method = "ratio"))
  )
})

test_that("the palette check prints its measurements", {
  expect_snapshot(print(taichi_check_palette()))
  expect_snapshot(print(taichi_check_palette(palette = "balanced")))
})

test_that("the argument errors say which argument and what to do", {
  expect_snapshot(error = TRUE, geom_taichi(yang = Google))
  expect_snapshot(error = TRUE, geom_taichi(yin = Twitter))
  expect_snapshot(error = TRUE, geom_taichi(yin = NULL, yang = Google))
  expect_snapshot(error = TRUE, geom_taichi(yin = a, yang = b, eyes = "yes"))
  expect_snapshot(error = TRUE,
                  geom_taichi(yin = a, yang = b, palette = "balanced",
                              yin_colors = "red"))
  expect_snapshot(error = TRUE,
                  geom_taichi(yin = a, yang = b, palette = 42))
  expect_snapshot(error = TRUE,
                  geom_taichi(yin = a, yang = b, explicit = "difference",
                              explicit_channel = "angle", angle = 30))
  expect_snapshot(error = TRUE,
                  geom_taichi(yin = a, yang = b, explicit = "difference",
                              eyes = FALSE))
  expect_snapshot(error = TRUE,
                  geom_taichi(yin = a, yang = b, explicit = "difference",
                              explicit_range = 1))
  expect_snapshot(error = TRUE,
                  geom_taichi(yin = a, yang = b, tooltip = lab))
  expect_snapshot(error = TRUE,
                  geom_taichi(yin = a, yang = b, yin_scale = "viridis"))
  expect_snapshot(error = TRUE,
                  geom_taichi(yin = a, yang = b, name = "x"))
})

test_that("a column that is not there is named at + time", {
  expect_snapshot(
    error = TRUE,
    ggplot(d, aes(x, y)) + geom_taichi(yin = nope, yang = yang)
  )
})

test_that("mismatched source types warn rather than pretending to share", {
  dd <- data.frame(x = 1:3, y = 1, a = 1:3, b = letters[1:3])
  # assigned, not printed: the warning comes from `+`, and printing the plot
  # would record a graphics device instead of the message
  expect_snapshot(
    p <- ggplot(dd, aes(x, y)) + geom_taichi(yin = a, yang = b,
                                             shared_limits = TRUE)
  )
})

test_that("a ratio of a non-positive value warns before it becomes NA", {
  dd <- data.frame(x = 1:3, y = 1, a = c(1, 0, 3), b = c(2, 2, 2))
  expect_snapshot(
    ggplot_build(ggplot(dd, aes(x, y)) +
      geom_taichi(yin = a, yang = b, explicit = "ratio"))$data[[1]]$eye_size
  )
})

test_that("the deprecated size argument still says what replaced it", {
  expect_snapshot(obj <- geom_taichi(yin = a, yang = b, size = 2))
})

test_that("taichi_summary() errors point at the column", {
  expect_snapshot(error = TRUE, taichi_summary(d, yin = nope, yang = yang))
  expect_snapshot(error = TRUE, taichi_summary(1:3, yin = a, yang = b))
})

test_that("the palette helpers explain what they will accept", {
  expect_snapshot(error = TRUE, taichi_palette_pair(n = 1))
  expect_snapshot(error = TRUE, taichi_palette_pair(hues = 1))
  expect_snapshot(error = TRUE, taichi_check_palette("notacolour"))
  expect_snapshot(error = TRUE,
                  taichi_check_palette("red", palette = "balanced"))
})
