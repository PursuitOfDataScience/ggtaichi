library(ggplot2)
library(ggtaichi)

# The interactive path is tested at the grob level, not by snapshotting HTML:
# girafe() output is an htmlwidget whose markup shifts with ggiraph's own
# version, while what ggtaichi is responsible for is emitting the right grobs
# with the right tooltip and data_id vectors.

d <- data.frame(x = 1:3, y = 1, yin = c(1, 5, 9), yang = c(9, 5, 1))

ipar <- function(g) g$.interactive

# The value ggiraph writes for each polygon of an id-batched grob: it reads
# the attribute at the row of that polygon's first vertex.
per_polygon <- function(g, nm) {
  v <- ipar(g)[[nm]]
  if (is.null(g$id)) v else v[!duplicated(g$id)]
}

# What the widget really carries: one data-id / title per SVG element,
# NA where an element has none.
svg_attrs <- function(p) {
  svg <- ggiraph::girafe(ggobj = p)$x$html
  elements <- regmatches(svg, gregexpr("<(polygon|circle)[^>]*>", svg))[[1]]
  pick <- function(attr) {
    m <- regmatches(elements, regexpr(paste0(" ", attr, "='[^']*'|",
                                              " ", attr, '="[^"]*"'),
                                      elements), invert = FALSE)
    out <- rep(NA_character_, length(elements))
    has <- grepl(paste0(" ", attr, "="), elements)
    out[has] <- sub(paste0("^ ", attr, "=['\"](.*)['\"]$"), "\\1", m)
    out
  }
  data.frame(tag = sub("^<(\\w+).*", "\\1", elements),
             data_id = pick("data-id"), title = pick("title"),
             stringsAsFactors = FALSE)
}

test_that("interactive = FALSE leaves the static grobs exactly as they were", {
  sc <- forced_scene(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, eyes = TRUE))
  polys <- collect_grobs(sc, "polygon")
  circles <- collect_grobs(sc, "circle")
  expect_false(any(vapply(polys, inherits, logical(1),
                          "interactive_polygon_grob")))
  expect_false(any(vapply(circles, inherits, logical(1),
                          "interactive_circle_grob")))
})

test_that("interactive = TRUE without ggiraph errors early and clearly", {
  skip_if(requireNamespace("ggiraph", quietly = TRUE),
          "ggiraph is installed")
  expect_error(geom_taichi(yin = yin, yang = yang, interactive = TRUE),
               "ggiraph")
})

test_that("tooltip / data_id / onclick need interactive = TRUE", {
  expect_error(
    geom_taichi(yin = yin, yang = yang, tooltip = yin),
    "interactive = TRUE"
  )
})

test_that("the default tooltip carries both values and their difference", {
  # taichi_tooltip() is the thing under test; it does not need ggiraph
  tt <- ggtaichi:::taichi_tooltip(c(1, 5), c(9, 5), "Twitter", "Google",
                                  c("w1", "w2"), c("Covid", "Masks"),
                                  "week", "category")
  expect_length(tt, 2)
  expect_match(tt[1], "Twitter")
  expect_match(tt[1], "Google")
  expect_match(tt[1], "difference: -8")
  expect_match(tt[1], "week w1")
  expect_match(tt[1], "category Covid")
  # no padding around the numbers
  expect_false(grepl(":  ", tt[1], fixed = TRUE))
})

test_that("the tooltip degrades when the plot has no x / y to name", {
  tt <- ggtaichi:::taichi_tooltip(1, 2)
  expect_length(tt, 1)
  expect_match(tt, "yin")
  expect_false(grepl("NULL", tt, fixed = TRUE))
})

test_that("a discrete source is named rather than formatted as a number", {
  tt <- ggtaichi:::taichi_tooltip(factor(c("a", "b")), c(1, 2))
  expect_match(tt[1], ">a<|: a")
  expect_false(grepl("difference", tt[1]))
})

test_that("markup in a column name cannot break the tooltip", {
  tt <- ggtaichi:::taichi_tooltip(1, 2, "a<b", "c&d")
  expect_match(tt, "a&lt;b")
  expect_match(tt, "c&amp;d")
})

test_that("markup in a category or a cell label cannot break it either", {
  tt <- ggtaichi:::taichi_tooltip(factor(c("<5 yrs", "A&B")), c(1, 2),
                                  "age", "n", c("x<1", "x&2"), c("y", "y"),
                                  "xx", "yy")
  expect_match(tt[1], "&lt;5 yrs", fixed = TRUE)
  expect_match(tt[2], "A&amp;B", fixed = TRUE)
  expect_match(tt[1], "xx x&lt;1", fixed = TRUE)
  expect_match(tt[2], "xx x&amp;2", fixed = TRUE)
  # the package's own markup is left alone
  expect_match(tt[1], "<b>age</b>", fixed = TRUE)
})

test_that("data_id scopes address cells, fish and sources", {
  x <- c("w1", "w1", "w2")
  y <- c("A", "B", "A")
  v <- 1:3
  expect_equal(ggtaichi:::taichi_data_id(x, y, v, "yin", "cell"),
               c("w1-A", "w1-B", "w2-A"))
  expect_equal(ggtaichi:::taichi_data_id(x, y, v, "yang", "fish"),
               c("w1-A-yang", "w1-B-yang", "w2-A-yang"))
  expect_equal(ggtaichi:::taichi_data_id(x, y, v, "yang", "source"),
               rep("yang", 3))
  # nothing to name the cell with: fall back to the row index
  expect_equal(ggtaichi:::taichi_data_id(NULL, NULL, v, "yin", "cell"),
               c("1", "2", "3"))
})

test_that("an unknown data_id_by is rejected", {
  expect_error(geom_taichi(yin = yin, yang = yang, data_id_by = "planet"))
})

test_that("tooltip numbers stay in fixed notation for ordinary magnitudes", {
  # formatC(format = "g") went scientific from five integer digits on, so an
  # order count of 12000 read "1.2e+04" and 123456 read "1.235e+05"
  num <- ggtaichi:::tooltip_number
  expect_equal(num(c(12000, 123456, 1234567.891)),
               c("12000", "123456", "1234568"))
  expect_equal(num(c(0.68119059, -8, 0.965, 5L, 0)),
               c("0.6812", "-8", "0.965", "5", "0"))
  # no padding, integers included
  expect_equal(num(c(1L, 25L)), c("1", "25"))
  # only the magnitudes fixed notation would bury in zeros go scientific
  expect_equal(num(c(1e-7, 2.5e15)), c("1e-07", "2.5e+15"))
  expect_equal(num(c(NA, NaN, Inf)), c("NA", "NaN", "Inf"))
  tt <- ggtaichi:::taichi_tooltip(12000, 9500)
  expect_match(tt, "12000", fixed = TRUE)
  expect_match(tt, "difference: 2500", fixed = TRUE)
})

# ------------------------------------------------------------------
# The rest needs ggiraph itself
# ------------------------------------------------------------------

skip_if_not_installed("ggiraph")

test_that("interactive = TRUE emits ggiraph grobs for fish and eyes", {
  sc <- forced_scene(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, interactive = TRUE, eyes = TRUE))
  polys <- collect_grobs(sc, "polygon")
  circles <- collect_grobs(sc, "circle")
  expect_length(polys, 2)
  expect_true(all(vapply(polys, inherits, logical(1),
                         "interactive_polygon_grob")))
  # the eyes are interactive too, so the middle of a glyph is not a dead spot
  expect_true(all(vapply(circles, inherits, logical(1),
                         "interactive_circle_grob")))
})

test_that("one tooltip and one data_id are emitted per cell, in order", {
  sc <- forced_scene(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, interactive = TRUE))
  g <- collect_grobs(sc, "polygon")[[1]]
  expect_length(per_polygon(g, "tooltip"), 3)
  expect_equal(per_polygon(g, "data_id"), c("1-1", "2-1", "3-1"))
  expect_match(per_polygon(g, "tooltip")[1], "difference: -8")
})

test_that("every glyph in the widget carries its own tooltip and data_id", {
  # ggiraph reads a batched polygon's attributes at each polygon's first
  # vertex; given one value per cell, only the first glyph of each layer got
  # any, and hovering the rest showed and highlighted nothing
  a <- svg_attrs(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, interactive = TRUE, eyes = TRUE))
  polys <- a[a$tag == "polygon", ]
  expect_equal(nrow(polys), 6)
  expect_false(anyNA(polys$data_id))
  expect_false(anyNA(polys$title))
  expect_equal(polys$data_id, rep(c("1-1", "2-1", "3-1"), 2))
  # and the tooltips are the cells' own, in order
  expect_match(polys$title[2], "x 2 / y 1", fixed = TRUE)
  expect_match(polys$title[3], "x 3 / y 1", fixed = TRUE)
  # the eyes were right all along
  circles <- a[a$tag == "circle", ]
  expect_equal(circles$data_id, rep(c("1-1", "2-1", "3-1"), 2))
})

test_that("data_id_by = 'source' gives every fish of one source one id", {
  sc <- forced_scene(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, interactive = TRUE,
                data_id_by = "source"))
  polys <- collect_grobs(sc, "polygon")
  expect_equal(unique(ipar(polys[[1]])$data_id), "yin")
  expect_equal(unique(ipar(polys[[2]])$data_id), "yang")
})

test_that("data_id_by = 'fish' distinguishes the two fish of a cell", {
  sc <- forced_scene(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, interactive = TRUE,
                data_id_by = "fish"))
  polys <- collect_grobs(sc, "polygon")
  expect_equal(ipar(polys[[1]])$data_id[1], "1-1-yin")
  expect_equal(ipar(polys[[2]])$data_id[1], "1-1-yang")
})

test_that("a supplied tooltip / data_id / onclick column wins", {
  dd <- transform(d, lab = c("one", "two", "three"),
                  key = c("k1", "k2", "k3"),
                  click = c("f(1)", "f(2)", "f(3)"))
  sc <- forced_scene(ggplot(dd, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, interactive = TRUE,
                tooltip = lab, data_id = key, onclick = click))
  g <- collect_grobs(sc, "polygon")[[1]]
  expect_equal(per_polygon(g, "tooltip"), c("one", "two", "three"))
  expect_equal(per_polygon(g, "data_id"), c("k1", "k2", "k3"))
  expect_equal(per_polygon(g, "onclick"), c("f(1)", "f(2)", "f(3)"))
})

test_that("the eyes carry their own cell's attributes", {
  # the middle cell gets no eye, so the eye vectors must be subset to match
  sc <- forced_scene(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, interactive = TRUE,
                explicit = "difference"))
  circles <- collect_grobs(sc, "circle")
  expect_length(as.numeric(circles[[1]]$r), 2)
  expect_length(ipar(circles[[1]])$data_id, 2)
  expect_equal(ipar(circles[[1]])$data_id, c("1-1", "3-1"))
})

test_that("the interactive geometry is identical to the static one", {
  coords <- function(int) {
    g <- collect_grobs(forced_scene(ggplot(d, aes(x, y)) +
      geom_taichi(yin = yin, yang = yang, interactive = int) +
      coord_fixed()), "polygon")[[1]]
    list(x = as.numeric(grid::convertX(g$x, "pt")),
         y = as.numeric(grid::convertY(g$y, "pt")),
         fill = g$gp$fill)
  }
  expect_equal(coords(TRUE), coords(FALSE))
})

test_that("girafe() accepts an interactive taichi plot", {
  p <- ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, interactive = TRUE)
  w <- ggiraph::girafe(ggobj = p)
  expect_s3_class(w, "girafe")
})

test_that("the fish geoms take interactive aesthetics on their own", {
  dd <- transform(d, lab = c("a", "b", "c"))
  sc <- forced_scene(ggplot(dd, aes(x, y)) +
    geom_yin_fish(aes(fill = yin, tooltip = lab), interactive = TRUE))
  g <- collect_grobs(sc, "polygon")[[1]]
  expect_s3_class(g, "interactive_polygon_grob")
  expect_equal(per_polygon(g, "tooltip"), c("a", "b", "c"))
})

test_that("under shared_legend the tooltip names each source by its column", {
  # the yin name is the joint legend title there, and the tooltip used to
  # label the yin value with it ("yin / yang: 1")
  tooltip <- function(...) {
    sc <- forced_scene(ggplot(d, aes(x, y)) +
      geom_taichi(yin = yin, yang = yang, interactive = TRUE,
                  shared_legend = TRUE, ...))
    ipar(collect_grobs(sc, "polygon")[[1]])$tooltip[1]
  }
  expect_match(tooltip(), "<b>yin</b>: 1", fixed = TRUE)
  expect_false(grepl("yin / yang", tooltip(), fixed = TRUE))
  expect_match(tooltip(yin_name = "orders"), "<b>yin</b>: 1", fixed = TRUE)
})

test_that("one interactive object can be added to several plots", {
  # the layers are shared by reference, and filling in the tooltip used to
  # write into them, pointing the first plot at the second plot's columns
  obj <- geom_taichi(yin = yin, yang = yang, interactive = TRUE)
  d2 <- data.frame(week = 1:3, hood = "A", yin = 4:6, yang = 6:4)
  p1 <- ggplot(d, aes(x, y)) + obj
  p2 <- ggplot(d2, aes(week, hood)) + obj
  expect_no_error(ggplot_build(p1))
  expect_no_error(ggplot_build(p2))
  g1 <- collect_grobs(forced_scene(p1), "polygon")
  expect_match(ipar(g1[[2]])$tooltip[1], "x 1 / y 1", fixed = TRUE)
})

test_that("a plotmath legend title reaches the tooltip as text", {
  # the name used to be injected into the tooltip quosure as a call, and
  # evaluated there ("object 'mu' not found")
  sc <- forced_scene(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, interactive = TRUE,
                yin_name = bquote(mu * g), yang_name = expression(beta)))
  tt <- ipar(collect_grobs(sc, "polygon")[[1]])$tooltip[1]
  expect_match(tt, "<b>mu * g</b>: 1", fixed = TRUE)
  expect_match(tt, "<b>beta</b>: 9", fixed = TRUE)
})
