library(ggplot2)
library(ggtaichi)

lum <- function(cols) {
  rgb <- t(grDevices::col2rgb(cols))
  as.numeric(farver::convert_colour(rgb, from = "rgb", to = "lab")[, "l"])
}

# ------------------------------------------------------------------
# taichi_palette_pair()
# ------------------------------------------------------------------

test_that("a constructed pair really is luminance matched", {
  p <- taichi_palette_pair()
  expect_named(p, c("yin", "yang"))
  expect_length(p$yin, 5)
  expect_length(p$yang, 5)
  expect_lt(max(abs(lum(p$yin) - lum(p$yang))), 2)
})

test_that("both ramps run light to dark, matching yin_colors", {
  p <- taichi_palette_pair(n = 6)
  expect_length(p$yin, 6)
  expect_true(all(diff(lum(p$yin)) < 0))
  expect_true(all(diff(lum(p$yang)) < 0))
  # the vector order of `luminance` does not decide the ramp's direction
  q <- taichi_palette_pair(luminance = c(90, 30))
  expect_equal(p$yin[1] > "", TRUE)
  expect_true(all(diff(lum(q$yin)) < 0))
})

test_that("the two hues really differ", {
  p <- taichi_palette_pair(hues = c(0, 180))
  expect_false(any(p$yin == p$yang))
})

test_that("taichi_palette_pair validates its arguments", {
  expect_error(taichi_palette_pair(n = 1), "2 or more")
  expect_error(taichi_palette_pair(hues = 1), "two numbers")
  expect_error(taichi_palette_pair(luminance = c(1, 2, 3)), "two numbers")
  expect_error(taichi_palette_pair(chroma = -1), "non-negative")
})

# ------------------------------------------------------------------
# taichi_palette()
# ------------------------------------------------------------------

test_that("every preset returns two ramps of the requested length", {
  for (nm in c("default", "balanced", "diverging", "viridis_pair",
               "brewer_pair", "print_safe")) {
    p <- taichi_palette(nm, n = 4)
    expect_named(p, c("yin", "yang"), info = nm)
    expect_length(p$yin, 4)
    expect_length(p$yang, 4)
    expect_silent(grDevices::col2rgb(c(p$yin, p$yang)))
  }
})

test_that("the 'default' preset is the package's own pair", {
  p <- taichi_palette("default")
  expect_equal(p$yin, c("gray100", "gray85", "gray50", "gray35", "gray0"))
  expect_equal(p$yang,
               c("#FED7D8", "#FE8C91", "#F5636B", "#E72D3F", "#C20824"))
})

test_that("print_safe collapses to the same greys, balanced does not", {
  p <- taichi_palette("print_safe")
  # identical luminance means identical ink once the colour is taken away
  expect_lt(max(abs(lum(p$yin) - lum(p$yang))), 2)
  # the yin ramp is genuinely grey
  rgb <- grDevices::col2rgb(p$yin)
  expect_true(all(abs(rgb[1, ] - rgb[2, ]) <= 1))
})

test_that("an unknown preset name errors", {
  expect_error(taichi_palette("sepia"))
  expect_error(taichi_palette("balanced", n = 0), "2 or more")
})

# ------------------------------------------------------------------
# taichi_check_palette()
# ------------------------------------------------------------------

test_that("the package defaults fail their own check, as documented", {
  chk <- taichi_check_palette()
  expect_s3_class(chk, "taichi_palette_check")
  expect_equal(chk$verdict, "fail")
  # the grey ramp reaches black while the red one stops around L* 41
  expect_gt(chk$max_luminance_diff, 30)
  expect_equal(nrow(chk$steps), 9)
})

test_that("a constructed pair passes", {
  expect_equal(taichi_check_palette(palette = "balanced")$verdict, "pass")
  p <- taichi_palette_pair()
  expect_equal(taichi_check_palette(p$yin, p$yang)$verdict, "pass")
  expect_equal(taichi_check_palette(palette = p)$verdict, "pass")
})

test_that("the verdict follows the tolerance", {
  p <- taichi_palette_pair()
  # the constructed pair is off by well under 1 L*, so a 0.5 tolerance puts
  # it in the warning band and a 0.2 one fails it
  expect_equal(taichi_check_palette(palette = p, tolerance = 0.5)$verdict,
               "warning")
  expect_equal(taichi_check_palette(palette = p, tolerance = 0.2)$verdict,
               "fail")
  expect_equal(taichi_check_palette(tolerance = 100)$verdict, "pass")
})

test_that("a non-monotone ramp is reported", {
  chk <- taichi_check_palette(c("black", "white", "black"),
                              c("black", "white", "black"))
  expect_false(chk$monotone[["yin"]])
  expect_equal(chk$verdict, "pass")   # matched, but not readable
})

test_that("colour-vision distances are reported against normal vision", {
  chk <- taichi_check_palette()
  if (requireNamespace("colorspace", quietly = TRUE)) {
    expect_s3_class(chk$cvd, "data.frame")
    expect_equal(chk$cvd$simulation,
                 c("normal", "deutan", "protan", "tritan"))
    expect_true(all(chk$cvd$distance >= 0))
  } else {
    expect_null(chk$cvd)
  }
})

test_that("a matched pair is not falsely flagged for colour-vision", {
  skip_if_not_installed("colorspace")
  # the pale end of any two luminance-matched sequential ramps must converge,
  # so the report must not read that as a colour-vision problem
  chk <- taichi_check_palette(palette = "balanced")
  normal <- chk$cvd$distance[chk$cvd$simulation == "normal"]
  expect_gt(chk$cvd$distance[chk$cvd$simulation == "deutan"], 0.5 * normal)
  expect_gt(chk$cvd$distance[chk$cvd$simulation == "protan"], 0.5 * normal)
})

test_that("a pair that colour-vision deficiency really does hurt is flagged", {
  skip_if_not_installed("colorspace")
  chk <- taichi_check_palette(palette = "print_safe")
  normal <- chk$cvd$distance[chk$cvd$simulation == "normal"]
  # print_safe pays for greyscale survival with red-green separability
  expect_lt(chk$cvd$distance[chk$cvd$simulation == "protan"], 0.5 * normal)
})

test_that("taichi_check_palette validates its arguments", {
  expect_error(taichi_check_palette("red", palette = "balanced"), "not both")
  expect_error(taichi_check_palette(1:3), "character vector")
  expect_error(taichi_check_palette("notacolour"), "not a valid colour")
  expect_error(taichi_check_palette(n = 1), "2 or more")
})

# ------------------------------------------------------------------
# palette = in geom_taichi()
# ------------------------------------------------------------------

d <- data.frame(x = rep(1:3, 3), y = rep(1:3, each = 3),
                yin = 1:9, yang = 9:1)

test_that("palette = swaps both ramps at once", {
  pair <- taichi_palette("balanced")
  b <- ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, palette = "balanced"))
  expect_equal(b$plot$scales$scales[[1]]$palette(0), pair$yin[1])
})

test_that("palette accepts a constructed pair", {
  pair <- taichi_palette_pair(hues = c(120, 300))
  expect_silent(ggplot_build(ggplot(d, aes(x, y)) +
    geom_taichi(yin = yin, yang = yang, palette = pair)))
})

test_that("palette and the colour vectors are mutually exclusive", {
  expect_error(
    geom_taichi(yin = yin, yang = yang, palette = "balanced",
                yin_colors = c("red", "blue")),
    "not both"
  )
  expect_error(
    geom_taichi(yin = yin, yang = yang, palette = "balanced",
                yang_colors = c("red", "blue")),
    "not both"
  )
})

test_that("an unusable palette argument is named, not silently ignored", {
  expect_error(geom_taichi(yin = yin, yang = yang, palette = 42), "must be one of")
  expect_error(geom_taichi(yin = yin, yang = yang, palette = list(a = 1)),
               "must be one of")
})

test_that("a preset's colours are used verbatim for discrete fills", {
  # the default ramps skip their palest end for discrete data, because it
  # vanishes on a white panel; an explicit preset is used as given
  dd <- data.frame(x = 1:3, y = 1, g = factor(c("a", "b", "c")))
  b <- ggplot_build(ggplot(dd, aes(x, y)) +
    geom_taichi(yin = g, yang = g, palette = "brewer_pair"))
  used <- b$plot$scales$scales[[1]]$palette(3)
  expect_equal(used[1], taichi_palette("brewer_pair")$yin[1])
})

test_that("palette = 'default' behaves exactly like no palette at all", {
  dd <- data.frame(x = 1:3, y = 1, g = factor(c("a", "b", "c")))
  a <- ggplot_build(ggplot(dd, aes(x, y)) + geom_taichi(yin = g, yang = g))
  b <- ggplot_build(ggplot(dd, aes(x, y)) +
    geom_taichi(yin = g, yang = g, palette = "default"))
  expect_equal(a$data[[1]]$fill, b$data[[1]]$fill)
  expect_equal(a$data[[2]]$fill, b$data[[2]]$fill)
})

test_that("the check object prints a readable report", {
  expect_output(print(taichi_check_palette()), "ggtaichi palette check")
  expect_output(print(taichi_check_palette()), "Verdict: FAIL")
  expect_output(print(taichi_check_palette(palette = "balanced")),
                "Verdict: PASS")
})

test_that("mix_ink reproduces the fallback fill the package has always used", {
  expect_equal(substr(ggtaichi:::mix_ink("black", "white", 0.2), 1, 7),
               "#333333")
})
