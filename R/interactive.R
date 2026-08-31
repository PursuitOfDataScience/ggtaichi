# Interactivity (ggiraph) -----------------------------------------------------
#
# A taichi grid encodes its two sources in fill, which graphical-perception
# work ranks as the least accurate channel available. Interactivity is not a
# convenience here: it is the second, accurate route to the numbers that the
# encoding needs. The vectorised makeContent() renderer already emits one
# id-batched polygon per layer, which maps one-to-one onto ggiraph's
# interactive_polygon_grob(), so the interactive path is a substitution inside
# the same renderer rather than a second way of drawing.

ggiraph_installed <- function() {
  requireNamespace("ggiraph", quietly = TRUE)
}

check_ggiraph <- function() {
  if (!ggiraph_installed()) {
    rlang::abort(paste0(
      "`interactive = TRUE` needs the ggiraph package.\n",
      "Install it with install.packages(\"ggiraph\"), or leave ",
      "`interactive = FALSE` for the static plot."
    ))
  }
  invisible(TRUE)
}

data_id_scopes <- c("cell", "fish", "source")

# The default tooltip: both values, the gap between them, and the cell's own
# coordinates when the plot's x / y mapping can supply them. The difference is
# included on purpose -- it is the quantity the glyph cannot show, and the
# reason interactivity earns its place.
taichi_tooltip <- function(yin, yang, yin_name = "yin", yang_name = "yang",
                           x = NULL, y = NULL,
                           x_name = NULL, y_name = NULL) {
  n <- max(length(yin), length(yang), 1L)
  fmt <- function(v) {
    if (is.numeric(v)) {
      formatC(v, format = "g", digits = 4, width = 1)
    } else {
      as.character(v)
    }
  }
  parts <- paste0(
    "<b>", html_escape(yin_name), "</b>: ", fmt(yin), "<br/>",
    "<b>", html_escape(yang_name), "</b>: ", fmt(yang)
  )
  if (is.numeric(yin) && is.numeric(yang)) {
    parts <- paste0(parts, "<br/>difference: ", fmt(yin - yang))
  }
  head <- taichi_cell_label(x, y, x_name, y_name, n)
  if (!is.null(head)) {
    parts <- paste0(head, "<br/>", parts)
  }
  rep_len(parts, n)
}

taichi_cell_label <- function(x, y, x_name, y_name, n) {
  bits <- list()
  if (!is.null(x)) {
    bits[[length(bits) + 1]] <- paste0(
      if (is.null(x_name)) "" else paste0(html_escape(x_name), " "),
      as.character(x)
    )
  }
  if (!is.null(y)) {
    bits[[length(bits) + 1]] <- paste0(
      if (is.null(y_name)) "" else paste0(html_escape(y_name), " "),
      as.character(y)
    )
  }
  if (length(bits) == 0) return(NULL)
  out <- if (length(bits) == 1) {
    bits[[1]]
  } else {
    paste0(bits[[1]], " / ", bits[[2]])
  }
  paste0("<b>", rep_len(out, n), "</b>")
}

# The default data_id, whose scope decides what a hover highlights:
#
#   "cell"   both fish of one cell share an id, so hovering lights up the
#            whole glyph -- the useful default.
#   "fish"   every fish gets its own id, for per-fish selection.
#   "source" all yin fish share one id and all yang fish another, so hovering
#            one source highlights it in every cell. That turns a
#            superposition display into a single-source display for as long as
#            the pointer rests there, which is the one thing a static
#            superposition cannot do.
taichi_data_id <- function(x = NULL, y = NULL, fallback, fish = "yin",
                           scope = "cell") {
  n <- length(fallback)
  if (scope == "source") return(rep_len(fish, max(n, 1L)))
  cell <- if (!is.null(x) && !is.null(y)) {
    paste0(as.character(x), "-", as.character(y))
  } else if (!is.null(x)) {
    as.character(x)
  } else if (!is.null(y)) {
    as.character(y)
  } else {
    as.character(seq_len(max(n, 1L)))
  }
  cell <- rep_len(cell, max(n, 1L))
  if (scope == "fish") paste0(cell, "-", fish) else cell
}

# Minimal escaping: the tooltip is inserted into the SVG as HTML, so a column
# name or category containing < or & would otherwise break the markup.
html_escape <- function(x) {
  x <- gsub("&", "&amp;", as.character(x), fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  gsub(">", "&gt;", x, fixed = TRUE)
}

# The interactive parameters actually present in a panel's data, dropped
# entirely when they are absent or all missing so that neither grid nor ggiraph
# is handed a column of NAs to render. One entry per cell, in cell order, so
# the eyes can subset it with the same mask they use for their own radii.
interactive_params <- function(coords) {
  out <- list()
  for (nm in c("tooltip", "data_id", "onclick")) {
    v <- coords[[nm]]
    if (is.null(v)) next
    v <- as.character(v)
    if (all(is.na(v))) next
    out[[nm]] <- v
  }
  out
}
