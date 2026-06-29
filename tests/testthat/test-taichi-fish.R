# Geometry tests for taichi_fish()
#
# The next_release.md confirms the fish geometry is provably exact (no overlap,
# no gap) via a 20k-point Monte-Carlo test.  These formal unit tests reify that
# check and add boundary-closure verification.

test_that("taichi_fish returns the correct number of points", {
  yin <- ggtaichi:::taichi_fish(0, 0, 1, "yin", n = 50)
  yang <- ggtaichi:::taichi_fish(0, 0, 1, "yang", n = 50)
  # 3 arcs × 50 points each = 150
  expect_length(yin$x, 150)
  expect_length(yin$y, 150)
  expect_length(yang$x, 150)
  expect_length(yang$y, 150)
})

test_that("fish polygons are closed (first == last vertex)", {
  yin <- ggtaichi:::taichi_fish(0, 0, 1, "yin")
  yang <- ggtaichi:::taichi_fish(0, 0, 1, "yang")
  expect_equal(yin$x[1],  yin$x[150])
  expect_equal(yin$y[1],  yin$y[150])
  expect_equal(yang$x[1], yang$x[150])
  expect_equal(yang$y[1], yang$y[150])
})

test_that("each fish covers approximately half the unit circle area", {
  # Use the "pipa" package or a simple winding-number check
  point_in_poly <- function(px, py, poly_x, poly_y) {
    n <- length(poly_x)
    inside <- logical(length(px))
    for (j in seq_along(px)) {
      xn <- px[j]; yn <- py[j]
      in_poly <- FALSE
      for (i in seq_len(n - 1)) {
        xi <- poly_x[i]; yi <- poly_y[i]
        xj <- poly_x[i + 1]; yj <- poly_y[i + 1]
        if (((yi > yn) != (yj > yn)) &&
            (xn < (xj - xi) * (yn - yi) / (yj - yi) + xi)) {
          in_poly <- !in_poly
        }
      }
      inside[j] <- in_poly
    }
    inside
  }

  set.seed(42)
  n <- 20000
  r <- sqrt(runif(n))
  theta <- runif(n, 0, 2 * pi)
  px <- r * cos(theta)
  py <- r * sin(theta)

  yin_poly <- ggtaichi:::taichi_fish(0, 0, 1, "yin")
  yang_poly <- ggtaichi:::taichi_fish(0, 0, 1, "yang")

  in_yin  <- point_in_poly(px, py, yin_poly$x, yin_poly$y)
  in_yang <- point_in_poly(px, py, yang_poly$x, yang_poly$y)

  prop_yin  <- mean(in_yin)
  prop_yang <- mean(in_yang)

  expect_equal(prop_yin,  0.5, tolerance = 0.02)
  expect_equal(prop_yang, 0.5, tolerance = 0.02)
  expect_equal(sum(in_yin & in_yang), 0)
  expect_lt(sum(!in_yin & !in_yang), n * 0.005)
})

test_that("rotation rotates the fish by the specified angle", {
  orig <- ggtaichi:::taichi_fish(0, 0, 1, "yin", n = 50, angle = 0)
  rot  <- ggtaichi:::taichi_fish(0, 0, 1, "yin", n = 50, angle = 90)

  # Points on the boundary should change position
  expect_false(isTRUE(all.equal(orig$x, rot$x)))
  expect_false(isTRUE(all.equal(orig$y, rot$y)))
})

test_that("rotation by 360 degrees returns to original position", {
  orig <- ggtaichi:::taichi_fish(0, 0, 1, "yin", n = 50, angle = 0)
  rot  <- ggtaichi:::taichi_fish(0, 0, 1, "yin", n = 50, angle = 360)
  expect_equal(orig$x, rot$x, tolerance = 1e-10)
  expect_equal(orig$y, rot$y, tolerance = 1e-10)
})

test_that("fish is centered at the given (cx, cy)", {
  fish <- ggtaichi:::taichi_fish(5, -3, 2, "yang")
  # The fish should be bounded by a circle of radius 2 around (5, -3)
  expect_true(all((fish$x - 5)^2 + (fish$y + 3)^2 <= 4.01))  # allow small numeric error
})
