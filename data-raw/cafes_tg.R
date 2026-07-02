# cafes_tg — synthetic espresso-vs-matcha café orders.
#
# A deliberately synthetic, evergreen two-source dataset for ggtaichi demos:
# weekly orders (per 100 customers) of espresso and matcha drinks across
# eight fictional neighbourhoods over a 12-week season. Regenerate with:
#   Rscript data-raw/cafes_tg.R   (from the package root)

set.seed(20260701)

neighbourhoods <- c(
  "Old Town", "Riverside", "University", "Market Square",
  "Harborfront", "Uptown", "Garden District", "Station Quarter"
)

base_espresso <- c(55, 48, 42, 60, 65, 52, 40, 68)
base_matcha   <- c(35, 42, 62, 38, 30, 45, 58, 33)

cafes_tg <- expand.grid(
  week = 1:12,
  neighbourhood = neighbourhoods,
  KEEP.OUT.ATTRS = FALSE,
  stringsAsFactors = FALSE
)

idx <- match(cafes_tg$neighbourhood, neighbourhoods)

# espresso cools off over the season while matcha picks up, at different
# rates per neighbourhood, plus noise
esp_trend <- -0.9 + 0.1 * (idx %% 3)
mat_trend <-  1.2 - 0.1 * (idx %% 4)

cafes_tg$espresso <- round(pmin(100, pmax(
  2, base_espresso[idx] + esp_trend * cafes_tg$week + rnorm(nrow(cafes_tg), sd = 4)
)), 1)
cafes_tg$matcha <- round(pmin(100, pmax(
  2, base_matcha[idx] + mat_trend * cafes_tg$week + rnorm(nrow(cafes_tg), sd = 4)
)), 1)

cafes_tg$neighbourhood <- factor(cafes_tg$neighbourhood, levels = neighbourhoods)
cafes_tg <- cafes_tg[, c("week", "neighbourhood", "espresso", "matcha")]

save(cafes_tg, file = "data/cafes_tg.rda", compress = "bzip2")
