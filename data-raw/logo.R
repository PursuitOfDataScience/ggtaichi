# Hex logo for ggtaichi, drawn with the package's own fish geometry.
# Regenerate with:  Rscript data-raw/logo.R   (from the package root)
#
# Design: the classic pointy-top R hexagon in the theme_taichi() rice-paper
# colour with a seal-red border; inside, one taichi glyph built from
# taichi_fish() (ink yin, seal-red yang, classic eyes), tilted slightly as a
# nod to the angle aesthetic; the package name beneath.

library(ggplot2)

ink   <- "#222222"
seal  <- "#C20824"
paper <- "#f3efe6"

# pointy-top unit hexagon (standard R sticker orientation)
hex_theta <- seq(90, 390, by = 60)[1:6] * pi / 180
hexagon <- data.frame(x = cos(hex_theta), y = sin(hex_theta))

glyph_cx <- 0
glyph_cy <- 0.22
glyph_r  <- 0.52
tilt     <- 20

yin  <- ggtaichi:::taichi_fish(glyph_cx, glyph_cy, glyph_r, "yin",  n = 200, angle = tilt)
yang <- ggtaichi:::taichi_fish(glyph_cx, glyph_cy, glyph_r, "yang", n = 200, angle = tilt)

# eyes sit in each fish's head (yin top, yang bottom), rotating with the glyph
th <- tilt * pi / 180
eye_offset <- 0.5 * glyph_r
eyes <- data.frame(
  x = glyph_cx + c(-eye_offset * sin(th), eye_offset * sin(th)),
  y = glyph_cy + c( eye_offset * cos(th), -eye_offset * cos(th)),
  fill = c("white", ink)
)
eye_r <- 0.15 * glyph_r
circ <- seq(0, 2 * pi, length.out = 120)

eye_circle <- function(i) {
  data.frame(x = eyes$x[i] + eye_r * cos(circ),
             y = eyes$y[i] + eye_r * sin(circ))
}

logo <- ggplot() +
  geom_polygon(data = hexagon, aes(x, y),
               fill = paper, colour = seal, linewidth = 2.6) +
  geom_polygon(data = as.data.frame(yin),  aes(x, y), fill = ink) +
  geom_polygon(data = as.data.frame(yang), aes(x, y), fill = seal) +
  geom_polygon(data = eye_circle(1), aes(x, y), fill = "white") +
  geom_polygon(data = eye_circle(2), aes(x, y), fill = ink) +
  annotate("text", x = 0, y = -0.55, label = "ggtaichi",
           family = "sans", fontface = "bold", size = 4.6, colour = ink) +
  coord_fixed(xlim = c(-1.02, 1.02), ylim = c(-1.02, 1.02), expand = FALSE) +
  theme_void()

ggsave("man/figures/logo.png", logo,
       width = 4.39, height = 5.08, units = "cm", dpi = 600, bg = "transparent")
