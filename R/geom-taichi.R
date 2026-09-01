#' Taichi
#'
#' The taichi geom turns each cell of a heatmap-like grid into a taichi
#' (yin-yang) diagram. The two interlocking "fish" of the diagram use luminance
#' to show the values from two data sources on the same plot, so four
#' dimensions of data can be expressed at once: the \code{x} and \code{y}
#' position of every taichi symbol plus the \code{yin} and \code{yang} values
#' that fill its two halves. With the optional eyes enabled and mapped to data
#' (see \code{eyes}, \code{yin_eye_size}, \code{yang_eye_size}), a single glyph
#' can carry up to six dimensions.
#'
#' A seventh channel, \code{angle}, rotates the glyph, and \code{explicit}
#' adds an eighth that is \emph{computed} rather than mapped: the relationship
#' between the two sources, shown as a third channel of the same mark. See
#' the Explicit encoding section.
#'
#' @section Discrete and continuous fills:
#' \code{geom_taichi()} inspects the plot data at \code{+} time. A numeric
#' \code{yin} / \code{yang} column gets a continuous
#' \code{\link[ggplot2]{scale_fill_gradientn}} built from \code{yin_colors} /
#' \code{yang_colors}; a factor, character, or logical column (including
#' computed expressions such as \code{factor(week)}) gets a discrete
#' \code{\link[ggplot2]{scale_fill_manual}} whose palette is interpolated from
#' the same color vectors. With the default vectors the discrete palette skips
#' the palest end of the ramp so that no category is invisible on a white
#' panel; an explicitly supplied color vector is used as-is. Supply
#' \code{yin_scale} / \code{yang_scale} to override the automatic choice
#' entirely.
#'
#' The automatic discrete palette samples a \emph{sequential} ramp, which
#' implies that the levels are ordered. That suits an ordered factor and
#' overstates an unordered one: if your categories have no natural order,
#' supply a qualitative palette through \code{yin_colors} / \code{yang_colors}
#' or a scale through \code{yin_scale} / \code{yang_scale}, so the fill does
#' not assert a ranking the data does not have.
#'
#' Because the choice is made when the layer is added, replacing the plot's
#' data afterwards keeps the scales picked for the original data. Swapping in
#' data of the same types is fine; if the new \code{yin} / \code{yang} columns
#' are of the \emph{other} kind, ggplot2 reports a "Discrete value supplied to
#' a continuous scale" (or the reverse) at draw time --- rebuild the plot rather
#' than substituting its data.
#'
#' @section Eyes:
#' \code{eyes = TRUE} draws the classic taichi dots, each sitting in its own
#' fish's head: the yin eye in the top bulb, the yang eye in the bottom bulb.
#' The size and colour arguments accept either a constant or an (unquoted)
#' data column, so the eyes can encode up to two further variables. A mapped
#' eye-size column is rescaled to radii between 0.05 and 0.3 of the glyph
#' radius, unless all its non-zero values already lie in \code{(0, 0.5]}, in
#' which case they are used directly as radius proportions. Cells whose eye
#' size is \code{NA} or \code{0} are drawn without an eye, so a column may
#' mix proportions with zeros to suppress individual eyes. A column whose
#' values are all equal gets the midpoint radius, 0.175.
#'
#' @section Styling:
#' \code{alpha}, \code{colour}, \code{linewidth} and \code{linetype} are
#' layer-wide constants here. Each has a concrete default, so
#' \code{geom_taichi()} always passes it to both fish layers as a parameter,
#' and a parameter takes precedence over an inherited mapping: a plot-level
#' \code{aes(linewidth = ...)} (or \code{alpha}, \code{colour},
#' \code{linetype}) has no effect on the glyphs. To drive one of those from a
#' column, build the layers yourself with \code{\link{geom_yin_fish}()} /
#' \code{\link{geom_yang_fish}()}, which take all four as ordinary
#' aesthetics.
#'
#' \code{width} and \code{height} behave differently, because they default to
#' \code{NULL} and are forwarded only when you actually supply them: a
#' plot-level \code{aes(width = ...)} \emph{does} size the cells per row. So
#' the data-driven channels of \code{geom_taichi()} are \code{yin},
#' \code{yang}, \code{angle}, the two eyes, and \code{width} / \code{height}
#' via \code{\link[ggplot2]{aes}()}.
#'
#' @section Missing values:
#' A fish whose fill value is \code{NA} is painted in the scale's
#' \code{na.value} colour (pass e.g. \code{na.value = "transparent"} through
#' \code{...} to change it), while \code{na.rm = TRUE} silently drops rows
#' with missing positions.
#'
#' @section Time on an axis:
#' Putting time on \code{x} makes each row of the grid a time series drawn as
#' a row of discrete glyphs, and the series is then encoded in \emph{fill}
#' rather than in position --- so slope is not encoded at all, and a reader
#' infers a trend by comparing the shade of neighbouring cells. That is a poor
#' substitute for a line. Use a taichi grid for the question \emph{which
#' series differ from each other, and where}; put a line chart or a horizon
#' plot beside it for \emph{what is the trend}.
#'
#' @section Explicit encoding:
#' Two fish sharing one position is a \emph{superposition} comparison. It is
#' very good at "are these similar?" and "which is bigger here?", and it
#' cannot answer "by how much?" --- that needs the relationship itself to be
#' computed and drawn. \code{explicit} does exactly that, turning one of
#' \code{"difference"} (\code{yin - yang}), \code{"ratio"},
#' \code{"log_ratio"} or \code{"z"} into a third channel of the glyph. The
#' statistics are the ones \code{\link{taichi_summary}()} tabulates, including
#' its rule that a ratio of a non-positive value is \code{NA} rather than
#' \code{Inf}.
#'
#' \code{explicit_channel} chooses where it goes:
#' \describe{
#'   \item{\code{"eye_size"}}{The default, and the tidiest: the eyes already
#'     exist and are visually subordinate to the fills, so the two fish keep
#'     carrying the two sources while eye size carries the gap between them.
#'     A big eye reads as "look here", which is what a big gap means. Cells
#'     where the two sources agree exactly get no eye at all, so a plain glyph
#'     means agreement. Implies \code{eyes = TRUE}.}
#'   \item{\code{"angle"}}{The most \emph{accurate} option. Direction and
#'     angle are read far more precisely than shading, so encoding the gap as
#'     tilt makes it legible to a precision the fills can never reach: an
#'     upright glyph means the two sources agree and the lean shows which way
#'     and how far. The cost is the symbol's upright orientation, which is why
#'     it is a choice rather than the default.}
#'   \item{\code{"border"}}{Outline width. Unobtrusive, and it composes with
#'     everything else, but the least precise of the four. Because the default
#'     \code{colour} is \code{NA} --- no outline at all --- this channel gives
#'     the outline a visible colour unless you set \code{colour} yourself.}
#'   \item{\code{"radius"}}{Glyph size, scaled by area (radius proportional to
#'     the square root of the statistic) so that the eye's area-based reading
#'     is the correct one. Cells where the sources agree shrink; use it when
#'     the interesting thing is \emph{where} they disagree.}
#' }
#'
#' \code{explicit_range} sets the channel's output range; each channel has a
#' sensible default (\code{c(0, 0.3)} of the glyph radius for eyes,
#' \code{c(-45, 45)} degrees for angle, \code{c(0, 1)} mm for the border,
#' \code{c(0.4, 1)} of the cell for radius). The statistic is rescaled across
#' the whole layer, so the mapping is comparable between facets.
#'
#' \code{\link{geom_taichi_diff}()} draws the same statistic as a diverging
#' heatmap when the glyph is not the right chart for the question, and
#' \code{\link{taichi_summary}()} returns it as a table.
#'
#' @section Palettes:
#' The two ramps are compared against each other, so they need to be matched:
#' if one spans a wider luminance range than the other then equal values do
#' not read as equal ink and one fish looks heavier wherever the data says the
#' sources are level. The default grey-and-red pair is \emph{not} matched
#' (run \code{\link{taichi_check_palette}()} with no arguments to see the
#' numbers) and is kept only for continuity. \code{palette} selects a
#' matched pair instead --- \code{"balanced"} is the recommended one --- and
#' also accepts the output of \code{\link{taichi_palette_pair}()}. It is a
#' shorthand for setting \code{yin_colors} and \code{yang_colors} together,
#' so passing both is an error.
#'
#' @section Interactivity:
#' Fill is the least accurate channel there is, which is why an interactive
#' version of a taichi grid is not a gimmick: hovering supplies the exact
#' values without giving up the encoding. With \code{interactive = TRUE} the
#' layers emit \pkg{ggiraph} grobs, and the plot becomes a widget when it is
#' passed to \code{ggiraph::girafe()}:
#'
#' \preformatted{  p <- ggplot(cafes_tg, aes(week, neighbourhood)) +
#'     geom_taichi(yin = matcha, yang = espresso, interactive = TRUE)
#'   ggiraph::girafe(ggobj = p)}
#'
#' The default tooltip carries both values, their difference, and the cell's
#' coordinates. \code{data_id_by} decides what a hover highlights:
#' \code{"cell"} (the default) lights up both fish of one glyph,
#' \code{"fish"} one fish at a time, and \code{"source"} every fish of one
#' source at once --- which turns the superposition display into a
#' single-source display for as long as the pointer rests there, letting a
#' reader decompose the comparison instead of doing it in their head.
#' \code{tooltip}, \code{data_id} and \code{onclick} take a data column to
#' override any of it.
#'
#' The static rendering is unchanged: with \code{interactive = FALSE} the
#' package does not touch \pkg{ggiraph} at all, and with it \code{TRUE} the
#' same geometry is drawn, only in grobs that carry the extra attributes.
#' \pkg{plotly} is not and will not be supported --- \code{ggplotly()} cannot
#' translate custom grobs, which is exactly what this package draws.
#'
#' @param yin The unquoted column name (or a literal string naming a column)
#'   for the yin (dark) fish of the taichi symbol. To pass a name held in a
#'   variable, use \code{.data[[nm]]} or \code{!!rlang::sym(nm)} --- a bare
#'   variable would be mapped as a constant fill, exactly as it would be inside
#'   \code{\link[ggplot2]{aes}()}.
#' @param yang The unquoted column name (or a literal string naming a column)
#'   for the yang (light) fish of the taichi symbol, as \code{yin}.
#' @param yin_name The label name (in quotes) for the legend of the yin
#'   rendering. Default is \code{NULL} (uses the column name).
#' @param yang_name The label name (in quotes) for the legend of the yang
#'   rendering. Default is \code{NULL} (uses the column name).
#' @param yin_colors A color vector, usually as hex codes, for the yin fish
#'   fill. Used as a gradient for continuous data and as a discrete palette
#'   for factor/character data. Ignored if \code{yin_scale} is provided.
#' @param yang_colors A color vector, usually as hex codes, for the yang fish
#'   fill. Used as a gradient for continuous data and as a discrete palette
#'   for factor/character data. Ignored if \code{yang_scale} is provided.
#' @param palette A matched pair of ramps to use instead of
#'   \code{yin_colors} / \code{yang_colors}: the name of a
#'   \code{\link{taichi_palette}()} preset (\code{"balanced"},
#'   \code{"diverging"}, \code{"viridis_pair"}, \code{"brewer_pair"},
#'   \code{"greyscale_safe"}, \code{"default"}) or a list with \code{yin} and
#'   \code{yang} colour vectors, such as the result of
#'   \code{\link{taichi_palette_pair}()}. Default \code{NULL}, which keeps the
#'   package's historical grey / seal-red pair. See the Palettes section.
#' @param yin_scale An optional fill scale for the yin fish: either a ready
#'   scale object or a scale constructor function (e.g.
#'   \code{ggplot2::scale_fill_viridis_d}). Overrides auto-detection. It must
#'   govern a \emph{fill} aesthetic; a scale for another aesthetic (say
#'   \code{scale_colour_viridis_c}) is rejected with an error rather than
#'   quietly leaving the fish on the default gradient.
#' @param yang_scale An optional fill scale for the yang fish, as
#'   \code{yin_scale}.
#' @param angle Rotation of each glyph in degrees, counter-clockwise: either a
#'   single number or an unquoted column name (one angle per cell). A mapped
#'   column must be numeric.
#' @param eyes Logical. If \code{TRUE}, draws the classic taichi eyes (dots),
#'   each centred in its fish's head. Default \code{FALSE}, preserving the
#'   plain v0.1.0 look.
#' @param yin_eye_size,yang_eye_size Size of each eye as a proportion of the
#'   glyph radius: a constant (default 0.15) or an unquoted data column to
#'   encode a variable (see the Eyes section for the rescaling rule).
#' @param yin_eye_colour,yang_eye_colour Colour of each eye dot: a constant,
#'   an unquoted data column containing colour strings, or \code{NULL} (the
#'   default) to take the colour from the theme --- the yin eye from the
#'   theme's \code{paper} and the yang eye from its \code{ink}, which is white
#'   and black on every light theme and swaps on a dark one. On ggplot2 before
#'   4.0.0, where themes cannot set geom defaults, \code{NULL} falls back to
#'   the literal "white" and "black".
#' @param explicit Which relationship between the two sources to compute and
#'   show as a third channel: \code{"none"} (the default), \code{"difference"},
#'   \code{"ratio"}, \code{"log_ratio"} or \code{"z"}. See the Explicit
#'   encoding section, and \code{\link{taichi_summary}()} for the definitions.
#' @param explicit_channel Where the computed statistic goes:
#'   \code{"eye_size"} (the default), \code{"angle"}, \code{"border"} or
#'   \code{"radius"}. Ignored when \code{explicit = "none"}. The chosen
#'   channel cannot also be set by hand --- e.g. \code{explicit_channel =
#'   "angle"} together with an \code{angle} argument is an error rather than a
#'   silent override.
#' @param explicit_range Two numbers giving the output range of
#'   \code{explicit_channel}, or \code{NULL} (the default) for that channel's
#'   own sensible range.
#' @param radius_exponent Only used by \code{explicit_channel = "radius"}: the
#'   exponent relating the statistic to the glyph radius. \code{0.5} is strict
#'   area scaling; the default \code{0.57} is the cartographic
#'   apparent-magnitude (Flannery) compensation, which makes larger symbols
#'   slightly larger than the geometry alone would give because readers
#'   systematically underestimate the area ratio between big and small
#'   circles.
#' @param interactive If \code{TRUE}, draw the fish (and their eyes) as
#'   \pkg{ggiraph} grobs carrying \code{tooltip}, \code{data_id} and
#'   \code{onclick}, so that \code{ggiraph::girafe()} turns the plot into a
#'   widget. Needs the \pkg{ggiraph} package. Default \code{FALSE}, which
#'   renders exactly as before and does not touch \pkg{ggiraph}. See the
#'   Interactivity section.
#' @param tooltip,data_id,onclick Optional unquoted data columns overriding
#'   the interactive attributes. Used only when \code{interactive = TRUE}; by
#'   default \code{tooltip} is built from the two values, their difference and
#'   the cell's coordinates, \code{data_id} from \code{data_id_by}, and
#'   \code{onclick} is empty.
#' @param data_id_by Scope of the default \code{data_id}, i.e. what one hover
#'   highlights: \code{"cell"} (both fish of that glyph; the default),
#'   \code{"fish"} (one fish), or \code{"source"} (every fish of that source,
#'   in every cell). Ignored when \code{data_id} is supplied.
#' @param shared_limits If \code{TRUE} and both sources are of the same type
#'   (both continuous, or both discrete), the two auto-built fill scales share
#'   common limits --- the union range (or union of levels) of \code{yin} and
#'   \code{yang} --- so equal values read as equal ink. Explicit \code{limits}
#'   passed through \code{...} take precedence. As of 0.3.0 the shared limits
#'   are also pushed into a custom \code{yin_scale} / \code{yang_scale} that
#'   does not set limits of its own, so a supplied binned scale shares breaks
#'   too. Default \code{FALSE}.
#' @param shared_legend If \code{TRUE}, treats the two sources as directly
#'   comparable: implies \code{shared_limits = TRUE}, paints both fish with
#'   \code{yin_colors}, and shows a single legend (the yang guide is
#'   dropped). Unless \code{yin_name} is supplied, the legend is titled
#'   "\code{yin} / \code{yang}". Default \code{FALSE}. This is the
#'   perceptually correct choice whenever the two sources really are
#'   directly comparable: one ramp means equal values are equal ink by
#'   construction, with no palette pairing to get wrong (see the Palettes
#'   section). The cost is that the sources are then told apart only by their
#'   position inside the glyph --- yin is the top bulb, yang the bottom. When
#'   a custom \code{yang_scale} is supplied it is used as given, so making the
#'   two palettes agree is then your business; the duplicate yang guide is
#'   dropped either way.
#' @param width,height Width and height of each cell. Typically omitted.
#' @param alpha Alpha transparency for the fish fills. A single value for the
#'   whole layer (see the Styling section).
#' @param na.rm If \code{TRUE}, silently removes rows with missing values.
#' @param colour Outline colour of the fish. A single value for the whole
#'   layer (see the Styling section).
#' @param linewidth Outline width of the fish (in mm). Replaces the deprecated
#'   \code{size} aesthetic of ggtaichi 0.1.0. A single value for the whole
#'   layer (see the Styling section).
#' @param linetype Outline linetype of the fish. A single value for the whole
#'   layer (see the Styling section).
#' @param show.legend Logical. Should the layer be included in the legend?
#' @param key_glyph The legend key glyph, passed on to
#'   \code{\link[ggplot2]{layer}()}. Both fish default to a small taichi with
#'   their own half filled (see \code{\link{draw_key_taichi}()}); pass
#'   \code{"rect"} for the plain ggplot2 rectangles of earlier versions. Keys
#'   only appear for discrete fills --- a continuous fill gets a colourbar.
#' @param ... Additional arguments passed to \emph{both} auto-built fill
#'   scales (e.g., shared \code{limits} or \code{na.value}). Because they go
#'   to both, an argument that suits only one kind of scale will be rejected by
#'   the other when \code{yin} and \code{yang} are of different types --- for
#'   instance a numeric \code{limits} draws ggplot2's "Continuous limits
#'   supplied to discrete scale" warning from the discrete fish. For per-fish
#'   scale options, supply \code{yin_scale} / \code{yang_scale} instead. The
#'   scale arguments \code{geom_taichi()} fills in itself --- \code{name},
#'   \code{values} and \code{colors} / \code{colours} --- are not accepted
#'   here; use \code{yin_name} / \code{yang_name} and \code{yin_colors} /
#'   \code{yang_colors}.
#'
#' @import ggplot2
#' @import grid
#' @import rlang
#' @import ggnewscale
#' @return A \code{ggtaichi_plot} object: the two fish layers plus the fill
#'   scales they need, ready to be added to a \code{\link[ggplot2]{ggplot}}
#'   with \code{+}. It is not a plot on its own.
#' @export
#'
#' @examples
#'
#' library(ggplot2)
#'
#' # taichi with numeric fills
#'
#' data <- data.frame(x = rep(c(1, 2, 3), 3),
#'                    y = rep(c(1, 2, 3), each = 3),
#'                    yin_values = 1:9,
#'                    yang_values = 9:1)
#'
#' ggplot(data, aes(x, y)) +
#'   geom_taichi(yin = yin_values,
#'               yang = yang_values)
#'
#' # categorical (discrete) fills are detected automatically
#'
#' data$yin_class <- rep(c("low", "mid", "high"), 3)
#'
#' ggplot(data, aes(x, y)) +
#'   geom_taichi(yin = yin_class,
#'               yang = yang_values)
#'
#' # classic eyes, rotation, and data-driven eye sizes
#'
#' ggplot(data, aes(x, y)) +
#'   geom_taichi(yin = yin_values,
#'               yang = yang_values,
#'               eyes = TRUE,
#'               yin_eye_size = yang_values,
#'               angle = 45)
#'
#' # a matched palette pair, and the gap between the sources as eye size
#'
#' ggplot(data, aes(x, y)) +
#'   geom_taichi(yin = yin_values,
#'               yang = yang_values,
#'               palette = "balanced",
#'               shared_limits = TRUE,
#'               explicit = "difference")
#'
#' # the same gap as tilt: the most accurate channel available
#'
#' ggplot(data, aes(x, y)) +
#'   geom_taichi(yin = yin_values,
#'               yang = yang_values,
#'               explicit = "difference",
#'               explicit_channel = "angle")
#'
#' # tooltips carry the exact values; needs ggiraph to view
#'
#' p <- ggplot(data, aes(x, y)) +
#'   geom_taichi(yin = yin_values, yang = yang_values,
#'               interactive = TRUE, data_id_by = "source")
#' if (requireNamespace("ggiraph", quietly = TRUE)) {
#'   # ggiraph::girafe(ggobj = p)
#' }
#'

geom_taichi <- function(
  yin, yang,
  yin_name = NULL,
  yang_name = NULL,
  yin_colors = c("gray100", "gray85", "gray50", "gray35", "gray0"),
  yang_colors = c("#FED7D8", "#FE8C91", "#F5636B", "#E72D3F", "#C20824"),
  palette = NULL,
  yin_scale = NULL,
  yang_scale = NULL,
  angle = NULL,
  eyes = FALSE,
  yin_eye_size = 0.15,
  yang_eye_size = 0.15,
  yin_eye_colour = NULL,
  yang_eye_colour = NULL,
  explicit = c("none", "difference", "ratio", "log_ratio", "z"),
  explicit_channel = c("eye_size", "angle", "border", "radius"),
  explicit_range = NULL,
  radius_exponent = 0.57,
  interactive = FALSE,
  tooltip = NULL,
  data_id = NULL,
  onclick = NULL,
  data_id_by = c("cell", "fish", "source"),
  shared_limits = FALSE,
  shared_legend = FALSE,
  width = NULL,
  height = NULL,
  alpha = NA,
  na.rm = FALSE,
  colour = NA,
  linewidth = 0.1,
  linetype = 1,
  show.legend = NA,
  key_glyph = NULL,
  ...) {

  if (rlang::quo_is_missing(rlang::enquo(yin))) {
    rlang::abort("`yin` is required. Please specify the column for the yin fish.")
  }
  if (rlang::quo_is_missing(rlang::enquo(yang))) {
    rlang::abort("`yang` is required. Please specify the column for the yang fish.")
  }

  yin_quo <- as_column_quo(rlang::enquo(yin))
  yang_quo <- as_column_quo(rlang::enquo(yang))
  angle_quo <- rlang::enquo(angle)

  if (rlang::quo_is_null(yin_quo)) {
    rlang::abort("`yin` must be a column, not NULL.")
  }
  if (rlang::quo_is_null(yang_quo)) {
    rlang::abort("`yang` must be a column, not NULL.")
  }
  if (!rlang::is_bool(eyes)) {
    rlang::abort("`eyes` must be TRUE or FALSE.")
  }
  if (!rlang::is_bool(shared_limits)) {
    rlang::abort("`shared_limits` must be TRUE or FALSE.")
  }
  if (!rlang::is_bool(shared_legend)) {
    rlang::abort("`shared_legend` must be TRUE or FALSE.")
  }
  if (!rlang::is_bool(interactive)) {
    rlang::abort("`interactive` must be TRUE or FALSE.")
  }
  if (shared_legend) shared_limits <- TRUE

  explicit <- rlang::arg_match0(explicit, explicit_methods,
                                arg_nm = "explicit")
  explicit_channel <- rlang::arg_match0(explicit_channel, explicit_channels,
                                        arg_nm = "explicit_channel")
  data_id_by <- rlang::arg_match0(data_id_by, data_id_scopes,
                                  arg_nm = "data_id_by")
  if (!is.null(explicit_range)) {
    if (!is.numeric(explicit_range) || length(explicit_range) != 2 ||
        anyNA(explicit_range)) {
      rlang::abort("`explicit_range` must be two numbers, or NULL.")
    }
  }
  if (!is.numeric(radius_exponent) || length(radius_exponent) != 1 ||
      is.na(radius_exponent) || radius_exponent <= 0) {
    rlang::abort("`radius_exponent` must be a single positive number.")
  }
  if (explicit == "none") {
    explicit_channel <- NULL
  } else {
    # Refuse to quietly overwrite a channel the caller is also driving:
    # `explicit` and a hand-set version of the same channel are two answers to
    # the same question, and silently picking one is how a plot ends up saying
    # something nobody asked it to.
    conflict <- switch(explicit_channel,
      eye_size = if (!missing(yin_eye_size) || !missing(yang_eye_size)) {
        "`yin_eye_size` / `yang_eye_size`"
      },
      angle = if (!rlang::quo_is_null(angle_quo)) "`angle`",
      border = if (!missing(linewidth)) "`linewidth`",
      radius = NULL
    )
    if (!is.null(conflict)) {
      rlang::abort(paste0(
        "`explicit_channel = \"", explicit_channel, "\"` drives the same ",
        "channel as ", conflict, "; drop one of them."
      ))
    }
    if (explicit_channel == "eye_size") {
      if (!missing(eyes) && !isTRUE(eyes)) {
        rlang::abort(paste0(
          "`explicit_channel = \"eye_size\"` needs the eyes; drop ",
          "`eyes = FALSE` or pick another `explicit_channel`."
        ))
      }
      eyes <- TRUE
    }
    if (explicit_channel == "border" && missing(colour)) {
      # An outline of any width is invisible in the default colour (NA), so
      # the border channel has to bring its own.
      colour <- "grey20"
    }
  }

  if (isTRUE(interactive)) check_ggiraph()

  if (shared_legend && is.null(yin_name)) {
    yin_name <- paste(rlang::as_label(yin_quo), "/", rlang::as_label(yang_quo))
  }
  if (is.null(yin_name))  yin_name  <- rlang::as_label(yin_quo)
  if (is.null(yang_name)) yang_name <- rlang::as_label(yang_quo)

  scale_dots <- list(...)
  if (!is.null(scale_dots$size)) {
    rlang::warn(paste0(
      "The `size` argument of `geom_taichi()` is deprecated as of ggtaichi ",
      "0.2.0; please use `linewidth` instead."
    ))
    if (missing(linewidth)) linewidth <- scale_dots$size
    scale_dots$size <- NULL
  }

  # A custom scale is either used as-is or called to build one, so anything
  # else would only surface as a do.call() error much later.
  check_scale_arg <- function(value, arg) {
    if (is.null(value) || is.function(value) || inherits(value, "Scale")) {
      return(invisible())
    }
    rlang::abort(paste0(
      "`", arg, "` must be a fill scale object (e.g. ",
      "`scale_fill_viridis_c()`) or a scale constructor function (e.g. ",
      "`scale_fill_viridis_c`), not ", class(value)[1], "."
    ))
  }
  check_scale_arg(yin_scale, "yin_scale")
  check_scale_arg(yang_scale, "yang_scale")

  # `palette` is shorthand for setting both colour vectors at once, so having
  # both would leave two answers for one fish.
  colors_user <- !missing(yin_colors)
  yang_colors_user <- !missing(yang_colors)
  if (!is.null(palette)) {
    if (colors_user || yang_colors_user) {
      rlang::abort(paste0(
        "Supply either `palette` or `yin_colors` / `yang_colors`, not both."
      ))
    }
    pair <- as_palette_pair(palette, "palette")
    yin_colors <- pair$yin
    yang_colors <- pair$yang
    # A preset's colours are used verbatim for discrete fills, exactly as an
    # explicit colour vector is -- except "default", which is the built-in
    # ramp and keeps the built-in ramp's behaviour of skipping its palest end.
    named_default <- is.character(palette) && identical(palette, "default")
    colors_user <- !named_default
    yang_colors_user <- !named_default
  }

  # These are supplied to the auto-built scales by geom_taichi() itself, so
  # passing them through `...` would collide; say which per-fish argument to
  # use instead of letting do.call() raise "matched by multiple arguments".
  reserved <- c(
    name    = "`yin_name` / `yang_name`",
    values  = "`yin_colors` / `yang_colors`",
    colors  = "`yin_colors` / `yang_colors`",
    colours = "`yin_colors` / `yang_colors`"
  )
  clash <- intersect(names(reserved), names(scale_dots))
  if (length(clash) > 0) {
    rlang::abort(paste0(
      "`", clash[1], "` cannot be passed through `...`; use ",
      reserved[[clash[1]]], " instead."
    ))
  }

  yin_eye_size_quo    <- rlang::enquo(yin_eye_size)
  yang_eye_size_quo   <- rlang::enquo(yang_eye_size)
  yin_eye_colour_quo  <- rlang::enquo(yin_eye_colour)
  yang_eye_colour_quo <- rlang::enquo(yang_eye_colour)

  yin_aes_args <- list(fill = yin_quo)
  yang_aes_args <- list(fill = yang_quo)

  if (!rlang::quo_is_null(angle_quo)) {
    yin_aes_args$angle <- angle_quo
    yang_aes_args$angle <- angle_quo
  }

  shared_params <- list(
    alpha = alpha, na.rm = na.rm,
    colour = colour, linewidth = linewidth, linetype = linetype,
    show.legend = show.legend,
    eyes = eyes,
    interactive = interactive
  )
  if (!is.null(width))  shared_params$width  <- width
  if (!is.null(height)) shared_params$height <- height

  # The explicit statistic is computed by the layer's own aes evaluation, so
  # it follows the layer's data (including replaced data and every facet), and
  # is turned into channel units in setup_data() where the whole column is
  # visible at once.
  if (!is.null(explicit_channel)) {
    stat_quo <- rlang::quo(
      taichi_explicit_stat(!!yin_quo, !!yang_quo, !!explicit)
    )
    # `border` gets its own aesthetic rather than reusing `linewidth`:
    # ggplot2 owns `linewidth`, so a mapped one would be re-ranged by
    # scale_linewidth_continuous() (defeating `explicit_range`) and would
    # raise a second legend nobody asked for.
    channel_aes <- switch(explicit_channel,
      eye_size = "eye_size", angle = "angle",
      border = "border", radius = "radius"
    )
    yin_aes_args[[channel_aes]] <- stat_quo
    yang_aes_args[[channel_aes]] <- stat_quo
    # A parameter beats a mapping, so the channel's constant has to go.
    shared_params[[channel_aes]] <- NULL
    shared_params$explicit <- explicit
    shared_params$explicit_channel <- explicit_channel
    shared_params$explicit_range <- explicit_range
    shared_params$radius_exponent <- radius_exponent
  }
  if (!is.null(key_glyph)) shared_params$key_glyph <- key_glyph

  yin_params <- shared_params
  yang_params <- shared_params

  # Eye size and colour accept a constant or a data column: constants become
  # layer parameters, columns become per-fish aesthetic mappings. An eye
  # colour of NULL sets neither, which leaves the geom's theme-aware default
  # to supply it.
  if (!identical(explicit_channel, "eye_size")) {
    if (is_constant_quo(yin_eye_size_quo)) {
      yin_params$eye_size <- check_eye_size(rlang::eval_tidy(yin_eye_size_quo), "yin_eye_size")
    } else {
      yin_aes_args$eye_size <- yin_eye_size_quo
    }
    if (is_constant_quo(yang_eye_size_quo)) {
      yang_params$eye_size <- check_eye_size(rlang::eval_tidy(yang_eye_size_quo), "yang_eye_size")
    } else {
      yang_aes_args$eye_size <- yang_eye_size_quo
    }
  }
  if (is_constant_quo(yin_eye_colour_quo)) {
    yin_params$eye_colour <- eye_colour_param(
      rlang::eval_tidy(yin_eye_colour_quo), "white"
    )
  } else {
    yin_aes_args$eye_colour <- yin_eye_colour_quo
  }
  if (is_constant_quo(yang_eye_colour_quo)) {
    yang_params$eye_colour <- eye_colour_param(
      rlang::eval_tidy(yang_eye_colour_quo), "black"
    )
  } else {
    yang_aes_args$eye_colour <- yang_eye_colour_quo
  }

  # The interactive attributes need the plot's x / y mapping to name a cell,
  # which is only known at `+` time; the columns the user supplied are wired
  # up here, and the defaults are filled in by ggplot_add().
  tooltip_quo <- rlang::enquo(tooltip)
  data_id_quo <- rlang::enquo(data_id)
  onclick_quo <- rlang::enquo(onclick)
  for (nm in c("tooltip", "data_id", "onclick")) {
    quo <- switch(nm, tooltip = tooltip_quo, data_id = data_id_quo,
                  onclick = onclick_quo)
    if (rlang::quo_is_null(quo)) next
    if (!isTRUE(interactive)) {
      rlang::abort(paste0(
        "`", nm, "` only has an effect with `interactive = TRUE`."
      ))
    }
    quo <- as_column_quo(quo)
    yin_aes_args[[nm]] <- quo
    yang_aes_args[[nm]] <- quo
  }

  yin_aes <- ggplot2::aes(!!!yin_aes_args)
  yang_aes <- ggplot2::aes(!!!yang_aes_args)

  yin_layer <- do.call(geom_yin_fish, c(
    list(mapping = yin_aes),
    yin_params
  ))

  yang_layer <- do.call(geom_yang_fish, c(
    list(mapping = yang_aes),
    yang_params
  ))

  result <- list(
    yin_layer = yin_layer,
    yin_mapping = yin_aes,
    yin_colors = yin_colors,
    yin_colors_user = colors_user,
    yin_name = yin_name,
    yin_scale = yin_scale,
    scale_dots = scale_dots,
    yang_layer = yang_layer,
    yang_mapping = yang_aes,
    yang_colors = if (shared_legend) yin_colors else yang_colors,
    yang_colors_user = if (shared_legend) colors_user else yang_colors_user,
    yang_name = yang_name,
    yang_scale = yang_scale,
    shared_limits = shared_limits,
    shared_legend = shared_legend,
    eyes = eyes,
    explicit = explicit,
    explicit_channel = explicit_channel,
    interactive = interactive,
    data_id_by = data_id_by,
    has_tooltip = !rlang::quo_is_null(tooltip_quo),
    has_data_id = !rlang::quo_is_null(data_id_quo)
  )
  class(result) <- c("ggtaichi_plot", "list")
  result
}


#' @export
print.ggtaichi_plot <- function(x, ...) {
  cat("<ggtaichi> taichi layers for a ggplot\n")
  cat("  yin  : ", x$yin_name, "\n", sep = "")
  cat("  yang : ", x$yang_name, "\n", sep = "")
  cat("  eyes : ", if (isTRUE(x$eyes)) "on" else "off", "\n", sep = "")
  if (!identical(x$explicit, "none") && !is.null(x$explicit)) {
    cat("  gap  : ", x$explicit, " -> ", x$explicit_channel, "\n", sep = "")
  }
  if (isTRUE(x$interactive)) {
    cat("  hover: interactive, highlighting by ", x$data_id_by, "\n", sep = "")
  }
  if (isTRUE(x$shared_legend)) {
    cat("  scale: shared limits, single legend\n")
  } else if (isTRUE(x$shared_limits)) {
    cat("  scale: shared limits\n")
  }
  cat("Add it to a plot: ggplot(data, aes(x, y)) + geom_taichi(...)\n")
  invisible(x)
}


# An eye colour of NULL means "let the theme decide", which is done by not
# passing the parameter at all so that the geom's default_aes applies. On a
# ggplot2 too old for theme-driven geom defaults there is nothing to defer to,
# so fall back to the literal colour the package has always used.
eye_colour_param <- function(value, fallback) {
  if (is.null(value)) {
    if (has_themed_aes()) return(NULL)
    return(fallback)
  }
  value
}


# A quosure counts as a constant when its expression is a syntactic literal
# (number, string, TRUE/FALSE, NA); symbols and calls are treated as data
# mappings.
is_constant_quo <- function(quo) {
  rlang::is_syntactic_literal(rlang::quo_get_expr(quo))
}

check_eye_size <- function(value, arg) {
  if (!is.numeric(value) || length(value) != 1 || is.na(value)) {
    rlang::abort(paste0("`", arg, "` must be a single number or a data column."))
  }
  value
}

# Common fill limits for the two sources: the union range when both are
# continuous, the union of levels when both are discrete, NULL when the two
# are of incompatible types (or nothing is known about them yet).
shared_fill_limits <- function(yin_vals, yang_vals) {
  disc <- function(v) is.factor(v) || is.character(v) || is.logical(v)
  if (is.numeric(yin_vals) && is.numeric(yang_vals)) {
    vals <- c(yin_vals, yang_vals)
    vals <- vals[is.finite(vals)]
    if (length(vals) == 0) return(NULL)
    return(range(vals))
  }
  if (disc(yin_vals) && disc(yang_vals)) {
    as_lvls <- function(v) {
      if (is.factor(v)) levels(droplevels(v)) else unique(as.character(v[!is.na(v)]))
    }
    lvls <- union(as_lvls(yin_vals), as_lvls(yang_vals))
    if (length(lvls) == 0) return(NULL)
    return(lvls)
  }
  NULL
}

# Allow `yin = "Twitter"` as a synonym for `yin = Twitter`: a literal string
# would otherwise be mapped as a constant fill, which is never what the user
# means here.
as_column_quo <- function(quo) {
  expr <- rlang::quo_get_expr(quo)
  if (rlang::is_string(expr)) {
    rlang::new_quosure(rlang::sym(expr), rlang::quo_get_env(quo))
  } else {
    quo
  }
}


#' @export
#' @method ggplot_add ggtaichi_plot
ggplot_add.ggtaichi_plot <- function(object, plot, ...) {
  data <- plot$data
  if (!is.data.frame(data)) data <- NULL

  scale_dots <- object$scale_dots %||% list()

  # Evaluate the fill quosure against the plot data so that discrete columns
  # -- including computed expressions such as factor(week) -- can be detected.
  # A plain column name that matches nothing is a user error worth a clear
  # message; other failing expressions are left for ggplot2 to report when
  # the plot is built.
  resolve_values <- function(mapping, arg) {
    fill_quo <- mapping$fill
    if (is.null(fill_quo)) return(NULL)
    vals <- tryCatch(rlang::eval_tidy(fill_quo, data), error = function(e) e)
    if (inherits(vals, "error")) {
      expr <- rlang::quo_get_expr(fill_quo)
      if (is.name(expr)) {
        rlang::abort(paste0(
          "Column `", as.character(expr), "` (supplied to `", arg,
          "`) was not found in the plot data."
        ))
      }
      return(NULL)
    }
    vals
  }

  # A scale for another aesthetic (scale_colour_*) would be attached to that
  # aesthetic instead, leaving the fish to ggplot2's default fill gradient --
  # a wrong plot with no error. Catch it for objects and constructors alike.
  check_fill_scale <- function(scale, arg) {
    aes_names <- tryCatch(scale$aesthetics, error = function(e) NULL)
    if (!any(grepl("^fill", aes_names))) {
      governs <- if (length(aes_names) == 0) {
        "the supplied scale declares no aesthetics"
      } else {
        paste0("the supplied scale governs ",
               paste0("`", aes_names, "`", collapse = ", "))
      }
      rlang::abort(paste0(
        "`", arg, "` must be a scale for the `fill` aesthetic; ", governs, "."
      ))
    }
    scale
  }

  build_scale <- function(vals, colors, name, custom_scale, user_palette,
                          extra = list(), arg, order = NULL) {
    if (!is.null(custom_scale)) {
      # The options ggtaichi computes for this fish -- the shared limits and
      # the dropped duplicate guide -- have to reach a supplied scale too, or
      # `shared_limits` silently does nothing as soon as anyone brings their
      # own (binned, viridis, ...) scale. A limit the scale sets itself wins.
      if (inherits(custom_scale, "Scale")) {
        scale <- check_fill_scale(custom_scale, arg)
        if (!is.null(extra$limits) && is.null(scale$limits)) {
          scale$limits <- extra$limits
        }
        # `shared_legend` means "one legend", so the yang guide goes whatever
        # the supplied scale asked for -- that is the request, not an
        # accident.
        if (identical(extra$guide, "none")) scale$guide <- "none"
        return(scale)
      }
      return(check_fill_scale(
        do.call(custom_scale, c(
          list(name = name), extra,
          scale_dots[setdiff(names(scale_dots), names(extra))]
        )),
        arg
      ))
    }
    # Options ggtaichi computes for this fish (shared limits, the dropped yang
    # guide) win over the same name in `...`, which otherwise both reach
    # do.call() and abort.
    dots <- c(extra, scale_dots[setdiff(names(scale_dots), names(extra))])
    is_disc <- is.factor(vals) || is.character(vals) || is.logical(vals)
    if (is_disc) {
      # `limits` can arrive either from shared_limits (extra) or straight from
      # the user through `...`; either way the manual palette must be as long
      # as the limits, not as the data. A function-valued `limits` says nothing
      # about how many levels survive, so fall back to counting the data.
      lims <- extra$limits %||% scale_dots$limits
      if (!is.character(lims) && !is.numeric(lims) && !is.logical(lims)) {
        lims <- NULL
      }
      n_vals <- if (length(lims) > 0) {
        length(lims)
      } else if (is.factor(vals)) {
        nlevels(droplevels(vals))
      } else {
        length(unique(vals[!is.na(vals)]))
      }
      n_vals <- max(n_vals, 1L)
      if (!user_palette) {
        # The default vectors are gradients whose palest end vanishes on a
        # white panel; sample them evenly but skip that extreme.
        scale_col <- grDevices::colorRampPalette(colors)(n_vals + 1)[-1]
      } else if (n_vals <= length(colors)) {
        scale_col <- colors[seq_len(n_vals)]
      } else {
        scale_col <- grDevices::colorRampPalette(colors)(n_vals)
      }
      dots$guide <- dots$guide %||% ggplot2::guide_legend(order = order)
      do.call(ggplot2::scale_fill_manual, c(list(name = name, values = scale_col), dots))
    } else {
      dots$guide <- dots$guide %||% ggplot2::guide_colourbar(order = order)
      do.call(ggplot2::scale_fill_gradientn, c(list(name = name, colors = colors), dots))
    }
  }

  yin_vals <- resolve_values(object$yin_mapping, "yin")
  yang_vals <- resolve_values(object$yang_mapping, "yang")

  yin_extra <- list()
  yang_extra <- list()

  if (isTRUE(object$shared_limits) && is.null(scale_dots$limits)) {
    lims <- shared_fill_limits(yin_vals, yang_vals)
    if (is.null(lims)) {
      rlang::warn(paste0(
        "`shared_limits` needs `yin` and `yang` to be of the same type ",
        "(both continuous or both discrete); ignoring it."
      ))
    } else {
      yin_extra$limits <- lims
      yang_extra$limits <- lims
    }
  }
  if (isTRUE(object$shared_legend)) {
    yang_extra$guide <- "none"
  }

  # `order` pins the two guides. With both left at ggplot2's default the tie
  # is broken by something that is not stable between sessions, so the yin and
  # yang legends could swap places from one render to the next -- on the same
  # data, the same package and the same ggplot2. Yin first, matching the
  # argument order and every example in the docs.
  yin_scale_obj <- build_scale(yin_vals, object$yin_colors, object$yin_name,
                               object$yin_scale, isTRUE(object$yin_colors_user),
                               yin_extra, "yin_scale", order = 1)
  yang_scale_obj <- build_scale(yang_vals, object$yang_colors, object$yang_name,
                                object$yang_scale, isTRUE(object$yang_colors_user),
                                yang_extra, "yang_scale", order = 2)

  yin_layer <- object$yin_layer
  yang_layer <- object$yang_layer
  if (isTRUE(object$interactive)) {
    yin_layer <- add_interactive_aes(yin_layer, object, plot, "yin")
    yang_layer <- add_interactive_aes(yang_layer, object, plot, "yang")
  }

  plot +
    yin_layer +
    yin_scale_obj +
    ggnewscale::new_scale_fill() +
    yang_layer +
    yang_scale_obj
}


# Fill in the interactive attributes the user did not supply. This happens at
# `+` time because the default tooltip names the cell, and the cell's x / y
# come from the *plot's* mapping, which geom_taichi() cannot see. The layer's
# mapping is completed before the layer is added, so ggplot2 still computes
# everything itself at build time.
add_interactive_aes <- function(layer, object, plot, fish) {
  mapping <- layer$mapping
  yin_quo <- object$yin_mapping$fill
  yang_quo <- object$yang_mapping$fill
  x_quo <- plot$mapping$x
  y_quo <- plot$mapping$y
  x_lab <- if (is.null(x_quo)) NULL else rlang::as_label(x_quo)
  y_lab <- if (is.null(y_quo)) NULL else rlang::as_label(y_quo)

  if (!isTRUE(object$has_tooltip)) {
    mapping$tooltip <- rlang::quo(taichi_tooltip(
      !!yin_quo, !!yang_quo, !!object$yin_name, !!object$yang_name,
      !!x_quo, !!y_quo, !!x_lab, !!y_lab
    ))
  }
  if (!isTRUE(object$has_data_id)) {
    mapping$data_id <- rlang::quo(taichi_data_id(
      !!x_quo, !!y_quo, !!yin_quo, !!fish, !!object$data_id_by
    ))
  }
  layer$mapping <- mapping
  layer
}




# Generate the boundary points of one taichi "fish".
#
# A taichi symbol is a circle of radius `r` centred at (cx, cy), split into
# two fish by an S-curve made of two small semicircles of radius r / 2. Each
# fish boundary is traced from three arcs that connect head-to-tail: half of
# the big circle plus the two small semicircles bulging in opposite ways.
# At angle = 0 the yin fish is the left half plus the top bulb (its head),
# the yang fish the right half plus the bottom bulb.
taichi_fish <- function(cx, cy, r, fish = c("yin", "yang"), n = 50, angle = 0) {

  fish <- match.arg(fish)
  half <- r / 2
  theta <- angle * pi / 180

  big   <- seq(-pi / 2,  pi / 2, length.out = n)
  upper <- seq( pi / 2,  3 * pi / 2, length.out = n)
  lower <- seq( pi / 2, -pi / 2, length.out = n)

  if (fish == "yang") {
    xa <- r * cos(big);      ya <- r * sin(big)
    xb <- half * cos(lower); yb <- half + half * sin(lower)
    xc <- half * cos(upper); yc <- -half + half * sin(upper)
  } else {
    xa <- r * cos(upper);         ya <- r * sin(upper)
    xb <- half * cos(rev(upper)); yb <- -half + half * sin(rev(upper))
    xc <- half * cos(rev(lower)); yc <- half + half * sin(rev(lower))
  }

  x <- c(xa, xb, xc)
  y <- c(ya, yb, yc)

  if (angle != 0) {
    rot_x <- x * cos(theta) - y * sin(theta)
    rot_y <- x * sin(theta) + y * cos(theta)
    x <- rot_x
    y <- rot_y
  }

  list(x = cx + x, y = cy + y)
}


# Rescale a mapped eye-size column to sensible radius proportions. Values
# already lying in (0, 0.5] are taken as literal proportions; anything else
# is linearly rescaled to [0.05, 0.3]. NAs are preserved (drawn as no eye).
rescale_eye_size <- function(x) {
  finite <- x[is.finite(x)]
  if (length(finite) == 0) return(x)
  # A zero means "draw no eye here", not "an eye of size zero", so it is a
  # marker rather than a measurement and must not decide whether the column is
  # already expressed as radius proportions. Without this, one 0 in an
  # otherwise-proportional column silently rescaled every other value.
  prop <- finite[finite != 0]
  rng <- range(finite)
  if (length(prop) > 0 && min(prop) > 0 && max(prop) <= 0.5) {
    out <- x
    out[is.finite(x) & x == 0] <- 0
    return(out)
  }
  if (rng[1] == rng[2]) {
    out <- x
    out[is.finite(x)] <- 0.175
    out[is.finite(x) & x == 0] <- 0
    return(out)
  }
  out <- 0.05 + (x - rng[1]) / (rng[2] - rng[1]) * 0.25
  out[is.finite(x) & x == 0] <- 0
  return(out)
}


# Build the grob (fish bodies, and optionally their eyes) for every taichi
# cell of one panel. The heavy lifting happens at draw time in
# makeContent.taichi_cells(), where the per-cell radius can be resolved
# against the physical panel size (keeping every glyph round under resize)
# and all cells collapse into one id-batched polygon plus one circle grob.
draw_taichi <- function(coords, fish, eyes = FALSE, interactive = FALSE) {

  n <- nrow(coords)
  if (n == 0) return(grid::nullGrob())

  angles <- coords$angle %||% rep(0, n)
  # is.finite() rather than !is.na(): an infinite angle would otherwise reach
  # cos()/sin() and turn every vertex of that glyph into NaN.
  angles[!is.finite(angles)] <- 0

  # A per-cell `border` (the explicit-encoding channel) overrides the
  # layer-wide `linewidth`; both are millimetres.
  lwd_vals <- coords$border
  if (is.null(lwd_vals) || all(is.na(lwd_vals))) {
    lwd_vals <- coords$linewidth %||% rep(0.1, n)
  }
  lwd_vals[is.na(lwd_vals)] <- 0.1

  # The radius channel is a proportion of the cell's own radius. A non-finite
  # or out-of-range value is not a proportion, so clamp rather than ask grid
  # for a negative radius.
  radius <- coords$radius %||% rep(1, n)
  radius[!is.finite(radius)] <- 1
  radius <- pmin(pmax(radius, 0), 1)

  eye_sizes <- coords$eye_size %||% rep(0.15, n)
  eye_cols  <- as.character(coords$eye_colour %||%
    rep(if (fish == "yang") "black" else "white", n))

  grid::gTree(
    cx = (coords$xmin + coords$xmax) / 2,
    cy = (coords$ymin + coords$ymax) / 2,
    w  = coords$xmax - coords$xmin,
    h  = coords$ymax - coords$ymin,
    angle = angles,
    radius = radius,
    fill = alpha(coords$fill, coords$alpha),
    col = coords$colour,
    lwd = lwd_vals * .pt,
    lty = coords$linetype,
    fish = fish,
    eyes = isTRUE(eyes),
    eye_size = eye_sizes,
    eye_colour = eye_cols,
    interactive = isTRUE(interactive),
    ipar = interactive_params(coords),
    cl = "taichi_cells"
  )
}


#' @export
#' @method makeContent taichi_cells
makeContent.taichi_cells <- function(x) {
  n <- length(x$cx)

  # Physical cell geometry: the glyph radius is half the smaller cell side,
  # exactly as the former per-cell "snpc" viewports resolved it.
  w_pt <- grid::convertWidth(grid::unit(x$w, "npc"), "pt", valueOnly = TRUE)
  h_pt <- grid::convertHeight(grid::unit(x$h, "npc"), "pt", valueOnly = TRUE)
  cx_pt <- grid::convertX(grid::unit(x$cx, "npc"), "pt", valueOnly = TRUE)
  cy_pt <- grid::convertY(grid::unit(x$cy, "npc"), "pt", valueOnly = TRUE)
  r_pt <- pmin(w_pt, h_pt) / 2 * (x$radius %||% 1)

  # The unit fish is built once at angle 0 and then rotated here, vectorised
  # over every cell of the panel -- which is what makes one id-batched polygon
  # possible instead of a grob per cell. That means this is the rotation the
  # plots actually use; `taichi_fish(angle =)` rotates a single fish for callers
  # outside the draw path (the tests and data-raw/logo.R). The two must agree:
  # both are counter-clockwise for a positive angle.
  unit_fish <- taichi_fish(0, 0, 1, x$fish, n = 50)
  m <- length(unit_fish$x)

  theta <- x$angle * pi / 180
  cs <- rep(cos(theta), each = m)
  sn <- rep(sin(theta), each = m)
  ux <- rep.int(unit_fish$x, n)
  uy <- rep.int(unit_fish$y, n)
  r_rep <- rep(r_pt, each = m)

  vx <- rep(cx_pt, each = m) + r_rep * (ux * cs - uy * sn)
  vy <- rep(cy_pt, each = m) + r_rep * (ux * sn + uy * cs)

  # One id-batched polygon per layer either way: with `interactive` the same
  # arguments go to ggiraph's constructor, which adds the hover / tooltip
  # attributes and otherwise draws identically -- so there is one renderer,
  # not two.
  poly_args <- list(
    x = grid::unit(vx, "pt"),
    y = grid::unit(vy, "pt"),
    id = rep(seq_len(n), each = m),
    gp = grid::gpar(
      col = x$col,
      fill = x$fill,
      lwd = x$lwd,
      lty = x$lty
    )
  )
  fish_grob <- if (isTRUE(x$interactive) && ggiraph_installed()) {
    do.call(ggiraph::interactive_polygon_grob,
            c(poly_args, x$ipar %||% list()))
  } else {
    do.call(grid::polygonGrob, poly_args)
  }
  children <- grid::gList(fish_grob)

  if (isTRUE(x$eyes)) {
    # A non-finite size is not a size: treat Inf/NaN like the documented NA
    # case (no eye) rather than asking grid for a circle of infinite radius.
    keep <- is.finite(x$eye_size) & x$eye_size > 0
    if (any(keep)) {
      # Each eye sits in its own fish's head: the yin bulb is at the top of
      # the glyph, the yang bulb at the bottom (see taichi_fish()), rotating
      # with the glyph.
      ey0 <- if (x$fish == "yang") -0.5 else 0.5
      th <- x$angle[keep] * pi / 180
      ex <- -ey0 * sin(th)
      ey <-  ey0 * cos(th)
      eye_args <- list(
        x = grid::unit(cx_pt[keep] + r_pt[keep] * ex, "pt"),
        y = grid::unit(cy_pt[keep] + r_pt[keep] * ey, "pt"),
        r = grid::unit(r_pt[keep] * x$eye_size[keep], "pt"),
        gp = grid::gpar(fill = x$eye_colour[keep], col = x$eye_colour[keep])
      )
      # The eyes carry their cell's attributes too, so that hovering the dot
      # is not a dead spot in the middle of the glyph.
      eye_grob <- if (isTRUE(x$interactive) && ggiraph_installed()) {
        do.call(ggiraph::interactive_circle_grob,
                c(eye_args, lapply(x$ipar %||% list(), function(v) v[keep])))
      } else {
        do.call(grid::circleGrob, eye_args)
      }
      children <- grid::gList(fish_grob, eye_grob)
    }
  }

  grid::setChildren(x, children)
}


# Shared setup: convert (x, y) cell centers into a bounding box, and rescale
# mapped eye sizes (the eye_size column only exists here when it was mapped;
# constants arrive later as aesthetic parameters and are used verbatim).
taichi_setup_data <- function(data, params) {
  data$width  <- data$width  %||% params$width  %||% resolution(data$x, FALSE)
  data$height <- data$height %||% params$height %||% resolution(data$y, FALSE)

  if (!is.numeric(data$width) || !is.numeric(data$height)) {
    rlang::abort("Cell `width` and `height` must be numeric.")
  }

  data$xmin <- data$x - data$width / 2
  data$xmax <- data$x + data$width / 2
  data$ymin <- data$y - data$height / 2
  data$ymax <- data$y + data$height / 2
  data$width <- NULL
  data$height <- NULL

  # The explicit statistic arrives here in its own units -- a difference, a
  # ratio -- and is turned into channel units now, while the whole column is
  # in one place: rescaling per panel would make facets incomparable.
  channel <- params$explicit_channel
  channel_col <- if (is.null(channel)) NULL else switch(channel,
    eye_size = "eye_size", angle = "angle",
    border = "border", radius = "radius"
  )
  if (!is.null(channel_col) && !is.null(data[[channel_col]])) {
    data[[channel_col]] <- rescale_explicit(data[[channel_col]], channel,
                                            params$explicit_range,
                                            params$radius_exponent)
  }

  if (!identical(channel, "eye_size") &&
      !is.null(data$eye_size) && is.null(params$eye_size)) {
    if (!is.numeric(data$eye_size)) {
      rlang::abort("Eye sizes must be numeric when mapped to a data column.")
    }
    data$eye_size <- rescale_eye_size(data$eye_size)
  }

  # Rotation is arithmetic on degrees at draw time, so a non-numeric column
  # would otherwise fail with an opaque base error (or, for a factor, quietly
  # draw unrotated glyphs).
  if (!is.null(data$angle) && !is.numeric(data$angle)) {
    rlang::abort(
      "Rotation angles must be numeric when mapped to a data column."
    )
  }

  # Same reasoning as `angle`: a mapped radius is arithmetic at draw time.
  if (!is.null(data$radius) && !is.numeric(data$radius)) {
    rlang::abort(
      "Glyph radii must be numeric when mapped to a data column."
    )
  }

  # `group` is deliberately left alone. Nothing in this geom reads it --
  # draw_panel() batches every row of a panel into one polygon and numbers the
  # vertices itself -- but gganimate *encodes the frame into `group`*, as a
  # "<id>" suffix, and anything that overwrites it collapses every transition
  # to a single frame. Versions up to 0.3.0 reset it to seq_len(nrow(data)),
  # which is why no animation ever advanced.

  data
}


#' ggtaichi's ggproto classes
#'
#' The [ggplot2::ggproto()] objects powering [geom_yin_fish()] and
#' [geom_yang_fish()]. Exported so that extension packages can inherit from
#' them; most users never need to touch these.
#'
#' @format NULL
#' @usage NULL
#' @keywords internal
#' @name ggtaichi-ggproto
#' @export
GeomYinFish <- ggplot2::ggproto("GeomYinFish", ggplot2::Geom,
  extra_params = c("na.rm", "eyes", "interactive",
                   "explicit", "explicit_channel", "explicit_range",
                   "radius_exponent"),

  rename_size = TRUE,

  setup_data = function(data, params) taichi_setup_data(data, params),

  draw_panel = function(data, panel_params, coord, eyes = FALSE,
                        interactive = FALSE) {
    coords <- coord$transform(data, panel_params)
    draw_taichi(coords, "yin", eyes = eyes, interactive = interactive)
  },

  # These literal fallbacks are replaced at load time with theme-aware ones
  # on ggplot2 >= 4.0.0 (see zzz.R); the values there resolve to exactly
  # these on any light theme.
  default_aes = ggplot2::aes(fill = "grey20", colour = NA,
                              linewidth = 0.1, linetype = 1,
                              alpha = NA, width = NA, height = NA,
                              angle = 0, radius = 1, border = NA,
                              eye_size = 0.15, eye_colour = "white",
                              tooltip = NA, data_id = NA, onclick = NA),

  required_aes = c("x", "y"),
  non_missing_aes = c("xmin", "xmax", "ymin", "ymax"),

  # A closure rather than the bare function so that the reference is
  # resolved at draw time, independently of the order R sources the
  # package's files in.
  draw_key = function(data, params, size) {
    draw_key_taichi(data, params, size, fish = "yin")
  }
)


#' The individual taichi fish layers
#'
#' `geom_yin_fish()` and `geom_yang_fish()` each draw one of the two
#' interlocking fish of a taichi symbol per `(x, y)` cell. They are the
#' building blocks that [geom_taichi()] assembles (together with two fill
#' scales and a [ggnewscale::new_scale_fill()] break); use them directly when
#' you want full control --- e.g. to bring your own fill scale for a single
#' fish, to stack scales differently, or to draw only one source.
#'
#' Both geoms understand the aesthetics `x`, `y`, `fill`, `colour`,
#' `linewidth`, `linetype`, `alpha`, `width`, `height`, `angle` (degrees,
#' counter-clockwise), `radius` (a proportion of the cell's own radius, so
#' `0.5` draws a half-size glyph in the same cell), `border` (a per-cell
#' outline width in mm, overriding `linewidth`), `eye_size`, and
#' `eye_colour` (the latter two only matter when `eyes = TRUE`), plus
#' `tooltip`, `data_id` and `onclick`, which are only read when
#' `interactive = TRUE`. At `angle = 0` the yin fish is the left half of the
#' circle plus the top bulb (its head); the yang fish is the right half plus
#' the bottom bulb.
#'
#' @param mapping,data,stat,position,inherit.aes See [ggplot2::layer()].
#' @param width,height Cell size; defaults to the resolution of the data.
#' @param eyes Logical. Draw the classic eye dot inside this fish's head?
#' @param interactive Logical. Draw \pkg{ggiraph} grobs carrying the
#'   `tooltip`, `data_id` and `onclick` aesthetics, so that
#'   `ggiraph::girafe()` can turn the plot into a widget. Needs the
#'   \pkg{ggiraph} package.
#' @param na.rm If `TRUE`, silently removes rows with missing values.
#' @param show.legend Logical. Should this layer be included in the legends?
#' @param key_glyph Legend key glyph; defaults to this fish's half of a
#'   taichi symbol (see [draw_key_taichi()]). Passed to [ggplot2::layer()].
#' @param ... Other arguments passed to [ggplot2::layer()]: either aesthetics
#'   used as constant parameters (e.g. `eye_size = 0.2`) or geom parameters.
#' @return A ggplot2 layer drawing one fish per cell.
#' @export
#' @examples
#' library(ggplot2)
#' d <- data.frame(x = 1:3, y = 1, value = 1:3)
#'
#' # a yin-only plot with an ordinary fill scale
#' ggplot(d, aes(x, y)) +
#'   geom_yin_fish(aes(fill = value)) +
#'   scale_fill_viridis_c()
#'
#' # both fish, manually stacked with ggnewscale
#' ggplot(d, aes(x, y)) +
#'   geom_yin_fish(aes(fill = value)) +
#'   scale_fill_viridis_c(name = "yin") +
#'   ggnewscale::new_scale_fill() +
#'   geom_yang_fish(aes(fill = rev(value))) +
#'   scale_fill_viridis_c(name = "yang", option = "magma")
geom_yin_fish <- function(mapping = NULL, data = NULL,
                          stat = "identity", position = "identity",
                          width = NULL, height = NULL,
                          eyes = FALSE,
                          interactive = FALSE,
                          na.rm = FALSE,
                          show.legend = NA,
                          inherit.aes = TRUE,
                          key_glyph = NULL,
                          ...) {
  if (isTRUE(interactive)) check_ggiraph()
  params <- list(
    na.rm = na.rm,
    eyes = eyes,
    interactive = interactive,
    ...
  )
  if (!is.null(width))  params$width  <- width
  if (!is.null(height)) params$height <- height
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomYinFish,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    key_glyph = key_glyph %||% draw_key_yin_fish,
    params = params
  )
}


#' @format NULL
#' @usage NULL
#' @rdname ggtaichi-ggproto
#' @export
GeomYangFish <- ggplot2::ggproto("GeomYangFish", GeomYinFish,

  draw_panel = function(data, panel_params, coord, eyes = FALSE,
                        interactive = FALSE) {
    coords <- coord$transform(data, panel_params)
    draw_taichi(coords, "yang", eyes = eyes, interactive = interactive)
  },

  default_aes = ggplot2::aes(fill = "grey20", colour = NA,
                              linewidth = 0.1, linetype = 1,
                              alpha = NA, width = NA, height = NA,
                              angle = 0, radius = 1, border = NA,
                              eye_size = 0.15, eye_colour = "black",
                              tooltip = NA, data_id = NA, onclick = NA),

  draw_key = function(data, params, size) {
    draw_key_taichi(data, params, size, fish = "yang")
  }
)


#' @rdname geom_yin_fish
#' @export
geom_yang_fish <- function(mapping = NULL, data = NULL,
                           stat = "identity", position = "identity",
                           width = NULL, height = NULL,
                           eyes = FALSE,
                           interactive = FALSE,
                           na.rm = FALSE,
                           show.legend = NA,
                           inherit.aes = TRUE,
                           key_glyph = NULL,
                           ...) {
  if (isTRUE(interactive)) check_ggiraph()
  params <- list(
    na.rm = na.rm,
    eyes = eyes,
    interactive = interactive,
    ...
  )
  if (!is.null(width))  params$width  <- width
  if (!is.null(height)) params$height <- height
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomYangFish,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    key_glyph = key_glyph %||% draw_key_yang_fish,
    params = params
  )
}
