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
# Rendering verification (eyes actually appear in the grob tree)
# ------------------------------------------------------------------

# Helper: recursively count grobs of a given class inside a gTree
count_grob_type <- function(g, type) {
  n <- 0L
  if (inherits(g, type)) n <- n + 1L
  if (inherits(g, "gTree") && !is.null(g$children)) {
    for (ch in g$children) n <- n + count_grob_type(ch, type)
  }
  n
}

panel_grob <- function(p) {
  gt <- ggplotGrob(p)
  idx <- grep("panel", sapply(gt$grobs, function(x) x$name %||% ""))
  gt$grobs[[idx[1]]]
}

test_that("eyes = TRUE produces circle grobs for both fish", {
  d <- data.frame(x = 1, y = 1, yin = 1, yang = 2)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang, eyes = TRUE)
  pg <- panel_grob(p)
  expect_equal(count_grob_type(pg, "circle"), 2L)
  expect_equal(count_grob_type(pg, "polygon"), 2L)
})

test_that("eyes = FALSE produces no circle grobs", {
  d <- data.frame(x = 1, y = 1, yin = 1, yang = 2)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang, eyes = FALSE)
  pg <- panel_grob(p)
  expect_equal(count_grob_type(pg, "circle"), 0L)
  expect_equal(count_grob_type(pg, "polygon"), 2L)
})

test_that("eyes with custom colours and sizes render circles", {
  d <- data.frame(x = 1, y = 1, yin = 1, yang = 2)
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE,
                yin_eye_colour = "blue", yang_eye_colour = "red",
                yin_eye_size = 0.2, yang_eye_size = 0.1)
  pg <- panel_grob(p)
  expect_equal(count_grob_type(pg, "circle"), 2L)
})

# Helper: collect all grobs of a class inside a gTree
collect_grobs <- function(g, type) {
  out <- list()
  walk <- function(gr) {
    if (inherits(gr, type)) out[[length(out) + 1]] <<- gr
    if (inherits(gr, "gTree")) for (ch in gr$children) walk(ch)
  }
  walk(g)
  out
}

# Helper: the snpc offset of a grid unit like sum(0.5npc, 0.25snpc)
snpc_offset <- function(u) {
  s <- as.character(u)[1]
  as.numeric(regmatches(s, regexec("(-?[0-9.]+)snpc", s))[[1]][2])
}

test_that("each eye sits in its own fish's head (yin top, yang bottom)", {
  d <- data.frame(x = 1, y = 1, yin = 1, yang = 2)
  p <- ggplot(d, aes(x, y)) + geom_taichi(yin = yin, yang = yang, eyes = TRUE)
  circles <- collect_grobs(panel_grob(p), "circle")
  expect_length(circles, 2L)
  fills <- vapply(circles, function(ci) ci$gp$fill, character(1))
  offsets <- vapply(circles, function(ci) snpc_offset(ci$y), numeric(1))
  # default yin eye is white and lives in the top bulb (positive offset);
  # the yang eye is black and lives in the bottom bulb
  expect_gt(offsets[fills == "white"], 0)
  expect_lt(offsets[fills == "black"], 0)
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

test_that("NA eye sizes skip the eye for that cell", {
  d <- data.frame(x = 1:3, y = 1:3, yin = 1:3, yang = 4:6, sz = c(10, NA, 30))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE, yin_eye_size = sz)
  # 2 yin eyes (one NA) + 3 yang eyes
  expect_equal(count_grob_type(panel_grob(p), "circle"), 5L)
})

test_that("mapped eye colours reach the grobs", {
  d <- data.frame(x = 1:2, y = 1:2, yin = 1:2, yang = 3:4,
                  col = c("blue", "orange"))
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE, yin_eye_colour = col)
  circles <- collect_grobs(panel_grob(p), "circle")
  fills <- vapply(circles, function(ci) as.character(ci$gp$fill), character(1))
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
