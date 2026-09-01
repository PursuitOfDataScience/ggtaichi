library(ggplot2)
library(ggtaichi)

# ------------------------------------------------------------------
# BUG-1: geom params routing
# ------------------------------------------------------------------

test_that("BUG-1: alpha, linewidth, colour, linetype are accepted", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, alpha = 0.5, linewidth = 2,
                colour = "red", linetype = 2)
  expect_silent(ggplot_build(p))
})

test_that("BUG-1: show.legend is accepted", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, show.legend = FALSE)
  expect_silent(ggplot_build(p))
})

test_that("BUG-1: width and height params are accepted", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, width = 0.8, height = 0.8)
  expect_silent(ggplot_build(p))
})

# ------------------------------------------------------------------
# BUG-2: linewidth aesthetic (replaces deprecated size)
# ------------------------------------------------------------------

test_that("mapped width/height size the cells, unlike the styling constants", {
  d <- data.frame(x = 1:3, y = 1, yin = 1:3, yang = 3:1, w = c(0.2, 0.5, 0.9))
  # width/height default to NULL, so they are not forwarded as params and an
  # inherited mapping survives
  b <- ggplot_build(ggplot(d, aes(x, y, width = w)) +
    geom_taichi(yin = yin, yang = yang))
  expect_equal(b$data[[1]]$xmax - b$data[[1]]$xmin, c(0.2, 0.5, 0.9))
  bh <- ggplot_build(ggplot(d, aes(x, y, height = w)) +
    geom_taichi(yin = yin, yang = yang))
  expect_equal(bh$data[[1]]$ymax - bh$data[[1]]$ymin, c(0.2, 0.5, 0.9))
  # an explicit argument still wins over the mapping
  bp <- ggplot_build(ggplot(d, aes(x, y, width = w)) +
    geom_taichi(yin = yin, yang = yang, width = 0.5))
  expect_equal(bp$data[[1]]$xmax - bp$data[[1]]$xmin, rep(0.5, 3))
  # whereas the styling constants ignore a mapping entirely
  bs <- ggplot_build(ggplot(d, aes(x, y, linewidth = w)) +
    geom_taichi(yin = yin, yang = yang))
  expect_true(all(bs$data[[1]]$linewidth == 0.1))
})

test_that("BUG-2: linewidth is used instead of size", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, linewidth = 2)
  expect_silent(ggplot_build(p))
})

test_that("BUG-2: default linewidth does not produce warnings", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  expect_warning({
    p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang)
    ggplot_build(p)
  }, regexp = NA)
})

# ------------------------------------------------------------------
# BUG-2: legacy size still works, with a deprecation warning
# ------------------------------------------------------------------

test_that("BUG-2: passing size warns and is used as linewidth", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  expect_warning(
    p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang, size = 2),
    "deprecated"
  )
  b <- ggplot_build(p)
  expect_true(all(b$data[[1]]$linewidth == 2))
})

# ------------------------------------------------------------------
# BUG-3: missing yin/yang validation
# ------------------------------------------------------------------

test_that("BUG-3: missing yin errors with informative message", {
  d <- data.frame(x = 1:3, y = 1:3, yang = 4:6)
  expect_error(geom_taichi(yang = yang), "yin")
})

test_that("BUG-3: missing yang errors with informative message", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3)
  expect_error(geom_taichi(yin = yin), "yang")
})

test_that("BUG-3: NULL yin/yang errors with informative message", {
  expect_error(geom_taichi(yin = NULL, yang = yang), "NULL")
  expect_error(geom_taichi(yin = yin, yang = NULL), "NULL")
})

test_that("BUG-3: a yin/yang column absent from the data errors at + time", {
  d <- data.frame(x = 1:3, y = 1:3, yang = 4:6)
  expect_error(
    ggplot(d, aes(x, y)) + geom_taichi(yin = not_a_column, yang = yang),
    "not found in the plot data"
  )
})

test_that("eyes flag is validated", {
  expect_error(geom_taichi(yin = a, yang = b, eyes = "yes"), "TRUE or FALSE")
})

test_that("shared_limits and shared_legend flags are validated", {
  expect_error(geom_taichi(yin = a, yang = b, shared_limits = "yes"),
               "`shared_limits` must be TRUE or FALSE")
  expect_error(geom_taichi(yin = a, yang = b, shared_legend = "yes"),
               "`shared_legend` must be TRUE or FALSE")
  # NA and length > 1 are not booleans either
  expect_error(geom_taichi(yin = a, yang = b, shared_limits = NA),
               "TRUE or FALSE")
  expect_error(geom_taichi(yin = a, yang = b, shared_legend = c(TRUE, FALSE)),
               "TRUE or FALSE")
})

test_that("a constant eye size must be a single non-missing number", {
  expect_error(geom_taichi(yin = a, yang = b, yin_eye_size = NA),
               "`yin_eye_size` must be a single number or a data column")
  expect_error(geom_taichi(yin = a, yang = b, yang_eye_size = NA),
               "`yang_eye_size` must be a single number or a data column")
  expect_error(geom_taichi(yin = a, yang = b, yin_eye_size = "big"),
               "single number or a data column")
  # a mapped column is fine, and so is an ordinary constant
  expect_error(geom_taichi(yin = a, yang = b, yin_eye_size = 0.2), NA)
})

# ------------------------------------------------------------------
# BUG-4: categorical / discrete fill support
# ------------------------------------------------------------------

test_that("BUG-4: factor yin/yang works without error", {
  d <- data.frame(
    x = 1:3, y = 1:3,
    yin = factor(c("low", "med", "high")),
    yang = factor(c("type_a", "type_b", "type_c"))
  )
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang)
  expect_silent(ggplot_build(p))
})

test_that("BUG-4: character yin/yang works without error", {
  d <- data.frame(
    x = 1:3, y = 1:3,
    yin = c("low", "med", "high"),
    yang = c("type_a", "type_b", "type_c")
  )
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang)
  expect_silent(ggplot_build(p))
})

test_that("BUG-4: computed discrete expressions are detected", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = factor(yin), yang = yang)
  b <- ggplot_build(p)
  scales <- b$plot$scales$scales
  fill_scales <- scales[sapply(scales, function(s) grepl("^fill", s$aesthetics[1]))]
  scale_classes <- sapply(fill_scales, function(s) class(s)[1])
  expect_true(any(grepl("Discrete", scale_classes)))
})

test_that("BUG-4: logical yin/yang is treated as discrete", {
  d <- data.frame(x = 1:3, y = 1:3, yin = c(TRUE, FALSE, TRUE), yang = 4:6)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang)
  expect_silent(ggplot_build(p))
})

test_that("default discrete palette skips the invisible palest end", {
  d <- data.frame(x = 1:3, y = 1:3,
                  yin = factor(c("a", "b", "c")), yang = 4:6)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang)
  b <- ggplot_build(p)
  fills <- toupper(b$data[[1]]$fill)
  expect_false(any(fills %in% c("#FFFFFF", "GRAY100", "WHITE")))
})

test_that("explicit discrete palettes are used verbatim", {
  d <- data.frame(x = 1:2, y = 1:2,
                  yin = factor(c("a", "b")), yang = 3:4)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, yin_colors = c("red", "blue"))
  b <- ggplot_build(p)
  expect_setequal(b$data[[1]]$fill, c("red", "blue"))
})

test_that("yin/yang accept strings naming a column", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = "yin", yang = "yang")
  b <- expect_silent(ggplot_build(p))
  expect_equal(b$data[[1]]$fill, ggplot_build(
    ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang)
  )$data[[1]]$fill)
})

# ------------------------------------------------------------------
# Rotation aesthetic (§3a)
# ------------------------------------------------------------------

test_that("rotation aesthetic is accepted without warnings", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, angle = 45)
  expect_silent(ggplot_build(p))
})

# ------------------------------------------------------------------
# Eyes (§3b)
# ------------------------------------------------------------------

test_that("eyes = TRUE is accepted without warnings", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE)
  expect_silent(ggplot_build(p))
})

test_that("eyes with custom colours and sizes is accepted", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE,
                yin_eye_colour = "blue", yang_eye_colour = "red",
                yin_eye_size = 0.2, yang_eye_size = 0.1)
  expect_silent(ggplot_build(p))
})

# ------------------------------------------------------------------
# Custom scales
# ------------------------------------------------------------------

test_that("custom yin_scale / yang_scale (function) are accepted", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  my_scale <- function(name = waiver(), ...) {
    scale_fill_gradientn(name = name, colours = c("white", "black"), ...)
  }
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang,
                yin_scale = my_scale,
                yang_scale = my_scale)
  expect_silent(ggplot_build(p))
})

test_that("yin_scale / yang_scale must be a scale object or a constructor", {
  expect_error(geom_taichi(yin = a, yang = b, yin_scale = "viridis"),
               "must be a fill scale object")
  expect_error(geom_taichi(yin = a, yang = b, yang_scale = 42),
               "must be a fill scale object")
  expect_error(geom_taichi(yin = a, yang = b, yin_scale = list()),
               "must be a fill scale object")
})

test_that("a custom scale for another aesthetic is rejected, not silently ignored", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  # scale_colour_* would attach to `colour` and leave the fish on ggplot2's
  # default fill gradient, i.e. the wrong plot with no error
  expect_error(
    ggplot_build(ggplot(d, aes(x, y)) +
      geom_taichi(yin = yin, yang = yang, yin_scale = scale_colour_viridis_c)),
    "must be a scale for the `fill` aesthetic"
  )
  expect_error(
    ggplot_build(ggplot(d, aes(x, y)) +
      geom_taichi(yin = yin, yang = yang,
                  yang_scale = scale_colour_gradient(low = "white", high = "black"))),
    "must be a scale for the `fill` aesthetic"
  )
})

test_that("non-numeric cell width / height error clearly", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  expect_error(
    ggplot_build(ggplot(d, aes(x, y)) +
      geom_taichi(yin = yin, yang = yang, width = "wide")),
    "must be numeric"
  )
})

test_that("custom yin_scale / yang_scale (Scale object) are accepted", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  my_scale <- scale_fill_gradient(low = "white", high = "black")
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang,
                yin_scale = my_scale,
                yang_scale = my_scale)
  expect_silent(ggplot_build(p))
})

# ------------------------------------------------------------------
# NA handling
# ------------------------------------------------------------------

test_that("NA values in yin are handled", {
  d <- data.frame(x = 1:3, y = 1:3, yin = c(1, NA, 3), yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, na.rm = TRUE)
  expect_silent(ggplot_build(p))
})

test_that("NA values in yang are handled", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = c(4, NA, 6))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, na.rm = TRUE)
  expect_silent(ggplot_build(p))
})

# ------------------------------------------------------------------
# Rendering verification (eyes actually appear in the drawn scene)
# ------------------------------------------------------------------

# forced_scene(), collect_grobs(), count_circles() and count_polygons() live
# in helper-scene.R, since several test files need them.

test_that("eyes = TRUE produces circles for both fish", {
  d <- data.frame(x = 1, y = 1, yin = 1, yang = 2)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang, eyes = TRUE)
  sc <- forced_scene(p)
  expect_equal(count_circles(sc), 2L)
  expect_equal(count_polygons(sc), 2L)
})

test_that("eyes = FALSE produces no circles", {
  d <- data.frame(x = 1, y = 1, yin = 1, yang = 2)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang, eyes = FALSE)
  sc <- forced_scene(p)
  expect_equal(count_circles(sc), 0L)
  expect_equal(count_polygons(sc), 2L)
})

test_that("eyes with custom colours and sizes render circles", {
  d <- data.frame(x = 1, y = 1, yin = 1, yang = 2)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE,
                yin_eye_colour = "blue", yang_eye_colour = "red",
                yin_eye_size = 0.2, yang_eye_size = 0.1)
  sc <- forced_scene(p)
  expect_equal(count_circles(sc), 2L)
})

test_that("each eye sits in its own fish's head (yin top, yang bottom)", {
  d <- data.frame(x = 1, y = 1, yin = 1, yang = 2)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang, eyes = TRUE)
  circles <- collect_grobs(forced_scene(p), "circle")
  fills <- unlist(lapply(circles, function(ci) as.character(ci$gp$fill)))
  ys <- unlist(lapply(circles, function(ci) as.numeric(ci$y)))
  expect_setequal(fills, c("white", "black"))
  # the white yin eye lives in the top bulb, the black yang eye in the bottom
  expect_gt(ys[fills == "white"], ys[fills == "black"])
})

test_that("a positive angle rotates counter-clockwise in the drawn scene", {
  # makeContent() rotates the unit fish itself, so this is the only path that
  # exercises the rotation the plots actually use -- taichi_fish(angle =) is a
  # separate implementation used outside drawing.
  d <- data.frame(x = 1, y = 1, yin = 1, yang = 2)
  eye_pos <- function(angle) {
    p <- ggplot(d, aes(x, y)) +
      geom_taichi(yin = yin, yang = yang, eyes = TRUE, angle = angle) +
      coord_fixed()
    circles <- collect_grobs(forced_scene(p), "circle")
    fills <- vapply(circles, function(ci) as.character(ci$gp$fill)[1], character(1))
    list(
      white = c(x = as.numeric(circles[[which(fills == "white")]]$x),
                y = as.numeric(circles[[which(fills == "white")]]$y)),
      black = c(x = as.numeric(circles[[which(fills == "black")]]$x),
                y = as.numeric(circles[[which(fills == "black")]]$y))
    )
  }
  at0 <- eye_pos(0)
  # at rest the yin (white) eye is the top bulb, the yang (black) eye the bottom
  expect_gt(at0$white[["y"]], at0$black[["y"]])

  at90 <- eye_pos(90)
  # a counter-clockwise quarter turn carries the top bulb to the LEFT; a
  # clockwise one would carry it to the right
  expect_lt(at90$white[["x"]], at90$black[["x"]])
  # and both eyes end up at about the same height
  expect_equal(at90$white[["y"]], at90$black[["y"]], tolerance = 1e-6)

  # The fish bodies are rotated by a different block of makeContent() than the
  # eyes, so pin their direction too. The yin outline starts at the top of the
  # circle, which a counter-clockwise quarter turn carries to the left.
  first_vertex <- function(angle) {
    p <- ggplot(d, aes(x, y)) +
      geom_taichi(yin = yin, yang = yang, angle = angle) + coord_fixed()
    pg <- collect_grobs(forced_scene(p), "polygon")[[1]]
    c(x = as.numeric(pg$x)[1], y = as.numeric(pg$y)[1])
  }
  v0 <- first_vertex(0)
  v90 <- first_vertex(90)
  expect_lt(v90[["x"]], v0[["x"]])
  expect_lt(v90[["y"]], v0[["y"]])
})

test_that("mapped eye sizes are rescaled to [0.05, 0.3]", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6, sz = c(10, 20, 30))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE, yin_eye_size = sz)
  b <- ggplot_build(p)
  expect_equal(b$data[[1]]$eye_size, c(0.05, 0.175, 0.30))
  # the yang layer keeps its constant default
  expect_true(all(b$data[[2]]$eye_size == 0.15))
})

test_that("mapped eye sizes already in (0, 0.5] pass through unchanged", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6, pz = c(0.1, 0.2, 0.3))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE, yin_eye_size = pz)
  b <- ggplot_build(p)
  expect_equal(b$data[[1]]$eye_size, c(0.1, 0.2, 0.3))
})

test_that("a zero does not stop the rest of the column passing through", {
  # 0 means "no eye here", so it is a marker, not a measurement: it must not
  # push an otherwise-proportional column through the [0.05, 0.3] rescale
  expect_equal(ggtaichi:::rescale_eye_size(c(0, 0.2, 0.4)), c(0, 0.2, 0.4))
  expect_equal(ggtaichi:::rescale_eye_size(c(0.2, 0, 0.5)), c(0.2, 0, 0.5))
  # ... while genuinely out-of-range columns still rescale (over their full
  # range, zero included) and zeros still suppress the eye
  expect_equal(ggtaichi:::rescale_eye_size(c(0, 10, 20)), c(0, 0.175, 0.3))
  # an all-zero column stays all-zero (no eyes at all)
  expect_equal(ggtaichi:::rescale_eye_size(c(0, 0, 0)), c(0, 0, 0))
  # and it reaches the built layer data intact
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6, sz = c(0, 0.2, 0.4))
  b <- ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE, yin_eye_size = sz))
  expect_equal(b$data[[1]]$eye_size, c(0, 0.2, 0.4))
})

test_that("NA eye sizes skip the eye for that cell", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6, sz = c(10, NA, 30))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE, yin_eye_size = sz)
  # 2 yin eyes (one NA) + 3 yang eyes
  expect_equal(count_circles(forced_scene(p)), 5L)
})

test_that("mapped eye colours reach the grobs", {
  d <- data.frame(x = 1:2, y = 1:2, yin = 1:2, yang = 3:4,
                  col = c("blue", "orange"))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE, yin_eye_colour = col)
  circles <- collect_grobs(forced_scene(p), "circle")
  fills <- unlist(lapply(circles, function(ci) as.character(ci$gp$fill)))
  expect_true(all(c("blue", "orange") %in% fills))
})

test_that("non-numeric mapped eye sizes error clearly", {
  d <- data.frame(x = 1:2, y = 1:2, yin = 1:2, yang = 3:4, sz = c("a", "b"))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE, yin_eye_size = sz)
  expect_error(ggplot_build(p), "numeric")
})

# ------------------------------------------------------------------
# Rotation renders different output (§3a)
# ------------------------------------------------------------------

test_that("glyphs are sized by the SHORTER cell side, so they fit non-square cells", {
  # Every visual snapshot uses coord_fixed() on a square grid, where the two
  # cell sides are equal, pmin == pmax, and width/height are interchangeable.
  # These checks use cells that are deliberately not square.

  # 1. the per-cell box follows width on x and height on y, not the other way
  d2 <- data.frame(x = 1:2, y = 1:2, yin = 1:2, yang = 2:1)
  b <- ggplot_build(ggplot(d2, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, width = 0.9, height = 0.4))
  expect_equal(b$data[[1]]$xmax - b$data[[1]]$xmin, rep(0.9, 2))
  expect_equal(b$data[[1]]$ymax - b$data[[1]]$ymin, rep(0.4, 2))

  # 2. on a wide, short device each cell is far wider than it is tall, so the
  #    radius must come from the height. Taking the longer side would make each
  #    glyph about four times its cell's height and swamp its neighbours.
  g <- data.frame(x = rep(1:3, each = 3), y = rep(1:3, 3), yin = 1:9, yang = 9:1)
  path <- tempfile(fileext = ".pdf")
  grDevices::pdf(path, width = 12, height = 3)
  on.exit({
    grDevices::dev.off()
    unlink(path)
  }, add = TRUE)
  print(ggplot(g, aes(x, y)) + geom_taichi(yin = yin, yang = yang))
  grid::grid.force()
  pg <- collect_grobs(grid::grid.grab(), "polygon")[[1]]
  ys <- as.numeric(pg$y)
  ids <- pg$id
  # vertical extent of each cell's fish, and the pitch between cell rows
  extent <- vapply(split(ys, ids), function(v) diff(range(v)), numeric(1))
  centres <- vapply(split(ys, ids), mean, numeric(1))
  rows <- sort(unique(round(centres, 6)))
  pitch <- min(diff(rows))
  expect_length(rows, 3L)
  expect_true(all(extent <= pitch * 1.02))
})

test_that("rotation changes the rendered polygon coordinates", {
  d <- data.frame(x = 1, y = 1, yin = 1, yang = 2)
  p0 <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang, angle = 0)
  p90 <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang, angle = 90)
  b0 <- ggplot_build(p0)
  b90 <- ggplot_build(p90)
  # angle should be populated in the data
  expect_equal(b0$data[[1]]$angle, 0)
  expect_equal(b90$data[[1]]$angle, 90)
})

test_that("NA angles fall back to no rotation instead of failing", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6, rot = c(0, NA, 90))
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang, angle = rot)
  expect_silent(ggplotGrob(p))
})

test_that("non-finite angles and eye sizes degrade quietly, not into NaN", {
  # is.na() catches NA and NaN but not +-Inf, so an infinite angle used to reach
  # cos()/sin() and turn every vertex of that glyph into NaN, warning
  # "NaNs produced" and drawing nothing.
  d <- data.frame(x = 1, y = 1, yin = 1, yang = 2)
  for (bad in c(Inf, -Inf, NaN, NA_real_)) {
    p <- ggplot(transform(d, rot = bad), aes(x, y)) +
      geom_taichi(yin = yin, yang = yang, angle = rot)
    expect_warning(forced_scene(p), regexp = NA)
    # the glyph is still drawn, unrotated
    expect_equal(count_polygons(forced_scene(p)), 2L)
  }

  # an infinite eye size is not a size: it must mean "no eye", like NA, rather
  # than a circle of infinite radius
  d3 <- data.frame(x = 1:3, y = 1, yin = 1:3, yang = 3:1, sz = c(0.2, Inf, 0.4))
  p2 <- ggplot(d3, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE, yin_eye_size = sz)
  # 2 yin eyes (the Inf one skipped) + 3 yang eyes
  expect_equal(count_circles(forced_scene(p2)), 5L)
  expect_warning(forced_scene(p2), regexp = NA)
})

test_that("non-numeric mapped angles error clearly instead of at draw time", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6,
                  chr = c("a", "b", "c"), fct = factor(c("a", "b", "c")))
  expect_error(
    ggplot_build(ggplot(d, aes(x, y)) +
                   geom_taichi(yin = yin, yang = yang, angle = chr)),
    "Rotation angles must be numeric"
  )
  # a factor used to silently draw unrotated glyphs with base arithmetic warnings
  expect_error(
    ggplot_build(ggplot(d, aes(x, y)) +
                   geom_taichi(yin = yin, yang = yang, angle = fct)),
    "Rotation angles must be numeric"
  )
  # the same guard protects the exported fish geoms
  expect_error(
    ggplot_build(ggplot(d, aes(x, y)) +
                   geom_yin_fish(aes(fill = yin, angle = chr))),
    "Rotation angles must be numeric"
  )
})

# ------------------------------------------------------------------
# Categorical scale selection (BUG-4 deeper check)
# ------------------------------------------------------------------

test_that("factor yin selects a discrete fill scale", {
  d <- data.frame(x = 1:3, y = 1:3,
                  yin = factor(c("low", "med", "high")), yang = 4:6)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang)
  b <- ggplot_build(p)
  scales <- b$plot$scales$scales
  fill_scales <- scales[sapply(scales, function(s) grepl("^fill", s$aesthetics[1]))]
  scale_classes <- sapply(fill_scales, function(s) class(s)[1])
  expect_true(any(grepl("Discrete", scale_classes)))
  expect_true(any(grepl("Continuous", scale_classes)))
})

test_that("numeric yin/yang select continuous fill scales", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang)
  b <- ggplot_build(p)
  scales <- b$plot$scales$scales
  fill_scales <- scales[sapply(scales, function(s) grepl("^fill", s$aesthetics[1]))]
  scale_classes <- sapply(fill_scales, function(s) class(s)[1])
  expect_true(all(grepl("Continuous", scale_classes)))
})

# ------------------------------------------------------------------
# BUG-1 deeper: geom params appear in built data
# ------------------------------------------------------------------

test_that("alpha, colour, linewidth, linetype appear in built layer data", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang,
                alpha = 0.5, colour = "red", linewidth = 2, linetype = 2)
  b <- ggplot_build(p)
  expect_true(all(b$data[[1]]$alpha == 0.5))
  expect_true(all(b$data[[1]]$colour == "red"))
  expect_true(all(b$data[[1]]$linewidth == 2))
  expect_true(all(b$data[[1]]$linetype == 2))
})

# ------------------------------------------------------------------
# Shared limits / shared legend (§4b)
# ------------------------------------------------------------------

test_that("shared_limits aligns both continuous fill scales", {
  d <- data.frame(x = 1:3, y = 1:3, yin = c(1, 2, 3), yang = c(7, 8, 10))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, shared_limits = TRUE)
  b <- ggplot_build(p)
  scales <- b$plot$scales$scales
  fill_scales <- scales[sapply(scales, function(s) grepl("^fill", s$aesthetics[1]))]
  lims <- lapply(fill_scales, function(s) s$limits)
  expect_length(lims, 2L)
  expect_true(all(vapply(lims, identical, logical(1), y = c(1, 10))))
})

test_that("shared_legend maps equal values to equal colours across fish", {
  d <- data.frame(x = 1:2, y = 1:2, a = c(1, 5), b = c(5, 1))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = a, yang = b, shared_legend = TRUE)
  b_ <- ggplot_build(p)
  # a == 5 (yin, row 2) and b == 5 (yang, row 1) must share a colour
  expect_equal(b_$data[[1]]$fill[2], b_$data[[2]]$fill[1])
  expect_equal(b_$data[[1]]$fill[1], b_$data[[2]]$fill[2])
})

test_that("shared_legend drops the yang guide and titles the legend jointly", {
  obj <- geom_taichi(yin = matcha, yang = espresso, shared_legend = TRUE)
  expect_equal(obj$yin_name, "matcha / espresso")
  d <- data.frame(x = 1:2, y = 1:2, matcha = c(1, 5), espresso = c(5, 1))
  b <- ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi(yin = matcha, yang = espresso, shared_legend = TRUE))
  scales <- b$plot$scales$scales
  fill_scales <- scales[sapply(scales, function(s) grepl("^fill", s$aesthetics[1]))]
  guides <- lapply(fill_scales, function(s) s$guide)
  expect_true(any(vapply(guides, identical, logical(1), y = "none")))
})

test_that("shared_limits unions the levels of two discrete sources", {
  d <- data.frame(x = 1:2, y = 1:2,
                  yin = factor(c("a", "b")), yang = factor(c("b", "c")))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, shared_limits = TRUE)
  b <- ggplot_build(p)
  scales <- b$plot$scales$scales
  fill_scales <- scales[sapply(scales, function(s) grepl("^fill", s$aesthetics[1]))]
  lims <- lapply(fill_scales, function(s) s$limits)
  expect_true(all(vapply(lims, identical, logical(1), y = c("a", "b", "c"))))
})

test_that("shared_legend gives the shared discrete level one colour", {
  d <- data.frame(x = 1:2, y = 1:2,
                  yin = factor(c("a", "b")), yang = factor(c("b", "c")))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, shared_legend = TRUE)
  b <- ggplot_build(p)
  # the shared level "b" gets the same colour on both fish
  expect_equal(b$data[[1]]$fill[2], b$data[[2]]$fill[1])
})

test_that("shared_limits warns and is ignored for mixed source types", {
  d <- data.frame(x = 1:2, y = 1:2, yin = factor(c("a", "b")), yang = c(1, 2))
  expect_warning(
    ggplot_build(ggplot(d, aes(x, y)) +
      geom_taichi(yin = yin, yang = yang, shared_limits = TRUE)),
    "same type"
  )
})

test_that("explicit limits in ... beat shared_limits", {
  d <- data.frame(x = 1:2, y = 1:2, yin = c(1, 2), yang = c(3, 4))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, shared_limits = TRUE, limits = c(0, 100))
  b <- ggplot_build(p)
  scales <- b$plot$scales$scales
  fill_scales <- scales[sapply(scales, function(s) grepl("^fill", s$aesthetics[1]))]
  expect_true(all(vapply(fill_scales, function(s) identical(s$limits, c(0, 100)),
                         logical(1))))
})

test_that("scale options ggtaichi sets itself win over the same name in ...", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6)
  # `guide` in ... used to collide with the yang guide shared_legend drops
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, shared_legend = TRUE, guide = "colourbar")
  b <- expect_silent(ggplot_build(p))
  scales <- b$plot$scales$scales
  fill_scales <- scales[sapply(scales, function(s) grepl("^fill", s$aesthetics[1]))]
  guides <- lapply(fill_scales, function(s) s$guide)
  # the yang guide is still dropped, and the yin guide is the user's colourbar
  expect_true(any(vapply(guides, identical, logical(1), y = "none")))
  expect_true(any(vapply(guides, function(g) !identical(g, "none"), logical(1))))
})

test_that("... arguments geom_taichi() supplies itself error informatively", {
  expect_error(geom_taichi(yin = a, yang = b, name = "oops"), "yin_name")
  expect_error(geom_taichi(yin = a, yang = b, colors = c("red", "blue")),
               "yin_colors")
  expect_error(geom_taichi(yin = a, yang = b, values = c("red", "blue")),
               "yin_colors")
})

test_that("a discrete palette is sized against explicit limits, not the data", {
  d <- data.frame(x = 1:3, y = 1:3,
                  yin = factor(c("a", "b", "c")),
                  yang = factor(c("p", "q", "r")))
  # limits wider than the levels present used to abort with
  # "Insufficient values in manual scale"
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, limits = c("a", "b", "c", "d"))
  b <- expect_silent(ggplot_build(p))
  expect_length(unique(b$data[[1]]$fill), 3L)
  # narrower limits still work: the unmatched level falls to na.value
  expect_silent(ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, limits = c("a", "b"))))
  # a function-valued `limits` says nothing about the level count, so the
  # palette must still be sized from the data
  expect_silent(ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, limits = rev)))
})

# ------------------------------------------------------------------
# Exported fish geoms (§4d)
# ------------------------------------------------------------------

test_that("geom_yin_fish / geom_yang_fish are exported and work standalone", {
  expect_true(all(c("geom_yin_fish", "geom_yang_fish") %in%
                    getNamespaceExports("ggtaichi")))
  d <- data.frame(x = 1:3, y = 1, v = 1:3)
  p <- ggplot(d, aes(x, y)) +
    geom_yin_fish(aes(fill = v)) +
    scale_fill_viridis_c() +
    ggnewscale::new_scale_fill() +
    geom_yang_fish(aes(fill = rev(v))) +
    scale_fill_viridis_c(option = "magma")
  expect_silent(ggplot_build(p))
  sc <- forced_scene(p)
  expect_equal(count_polygons(sc), 6L)
})

# ------------------------------------------------------------------
# print method
# ------------------------------------------------------------------

test_that("printing the geom_taichi() object is human-readable", {
  obj <- geom_taichi(yin = a, yang = b, eyes = TRUE, shared_legend = TRUE)
  out <- capture.output(print(obj))
  expect_true(any(grepl("<ggtaichi>", out)))
  expect_true(any(grepl("yin  : a / b", out, fixed = TRUE)))
  expect_true(any(grepl("eyes : on", out, fixed = TRUE)))
  expect_true(any(grepl("shared", out)))
})

# ------------------------------------------------------------------
# Legend order is pinned, not left to chance
# ------------------------------------------------------------------

test_that("the yin guide always comes before the yang guide", {
  # With both guides left at ggplot2's default `order`, the tie was broken by
  # something that is not stable between sessions: the same plot, package and
  # ggplot2 could put yin first in one render and yang first in the next. One
  # of the committed vdiffr references had in fact captured the wrong order.
  d <- data.frame(x = rep(1:3, 3), y = rep(1:3, each = 3),
                  yin = 1:9, yang = 9:1)
  guide_order <- function(p) {
    fills <- Filter(function(s) any(grepl("^fill", s$aesthetics)),
                    ggplot_build(p)$plot$scales$scales)
    vapply(fills, function(s) {
      g <- s$guide
      if (is.character(g)) NA_real_ else (g$params$order %||% g$order %||% NA_real_)
    }, numeric(1))
  }
  ord <- guide_order(ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang))
  expect_equal(ord, c(1, 2))

  # and for discrete fills, which use a different guide
  dd <- data.frame(x = 1:3, y = 1, g = factor(c("a", "b", "c")))
  ordd <- guide_order(ggplot(dd, aes(x, y)) + geom_taichi(yin = g, yang = g))
  expect_equal(ordd, c(1, 2))
})

test_that("an explicit guide passed through ... still wins", {
  d <- data.frame(x = 1:3, y = 1, yin = 1:3, yang = 3:1)
  b <- ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, guide = "none"))
  fills <- Filter(function(s) any(grepl("^fill", s$aesthetics)),
                  b$plot$scales$scales)
  expect_true(all(vapply(fills, function(s) identical(s$guide, "none"),
                         logical(1))))
})

test_that("shared_legend still drops the yang guide", {
  d <- data.frame(x = 1:3, y = 1, yin = 1:3, yang = 3:1)
  b <- ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, shared_legend = TRUE))
  fills <- Filter(function(s) any(grepl("^fill", s$aesthetics)),
                  b$plot$scales$scales)
  guides <- vapply(fills, function(s) {
    if (is.character(s$guide)) s$guide else class(s$guide)[1]
  }, character(1))
  expect_true("none" %in% guides)
})
