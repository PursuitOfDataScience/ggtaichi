#' Pittsburgh COVID-related Google & Twitter incidence rates
#'
#' A data set containing the 30-week incidence rates of COVID-related
#' categories in the Pittsburgh Metropolitan Statistical Area (MSA), from
#' week 1 beginning June 1, 2020 to week 30, which ended on the last Sunday of
#' the year. The data columns are introduced below. One quick note about the
#' columns of the data set: \code{week_start} is present for illustration
#' purposes, as a reminder of what the \code{week} column counts. In other
#' words, it does not participate in any visualization.
#' @format A data frame with 270 rows and 6 columns:
#' \describe{
#'   \item{msa}{Metropolitan statistical area (Pittsburgh only).}
#'   \item{week}{week 1 to week 30.}
#'   \item{week_start}{The Monday date of the week started.}
#'   \item{category}{One of 9 COVID-related categories: Covid, General Virus,
#'   Masks, Sanitizing, Social Distancing, Symptoms, Tests, Treatment,
#'   Working.}
#'   \item{Twitter}{weekly tweets percentage (%) in the MSA falling into each
#'   category.}
#'   \item{Google}{weekly Google search percentage (%) in the MSA falling into
#'   each category.}
#' }
#' @source Just like \code{states_tg}, Google is processed from Google Health
#' API, and Twitter from Meltwater, a Twitter vendor. Both data sources are
#' processed by the author of the package.
"pitts_tg"


#' States' COVID-related Google & Twitter incidence rates
#'
#' A data set containing the 31-week incidence rates of COVID-related
#' categories in 4 states (Florida, Missouri, New York, and Texas), from week 1
#' beginning June 1, 2020 to week 31, which begins December 28, 2020 and so
#' runs a few days past the end of the year. The data columns are introduced
#' below. One quick note about the columns of the data set:
#' \code{week_start} is present for illustration purposes, as a reminder of
#' what the \code{week} column counts. In other words, it does not participate
#' in any visualization.
#' @format A data frame with 1116 rows and 6 columns:
#' \describe{
#'   \item{state}{One of the four states: Florida, Missouri, New York, Texas.}
#'   \item{week}{week 1 to week 31.}
#'   \item{week_start}{The Monday date of the week started.}
#'   \item{category}{One of 9 COVID-related categories: Covid, General Virus,
#'   Masks, Sanitizing, Social Distancing, Symptoms, Tests, Treatment,
#'   Working.}
#'   \item{Twitter}{weekly tweets percentage (%) in state falling into each
#'   category.}
#'   \item{Google}{weekly Google search percentage (%) in state falling into
#'   each category.}
#' }
#' @source Just like \code{pitts_tg}, Google is processed from Google Health
#' API, and Twitter from Meltwater, a Twitter vendor. Both data sources are
#' processed by the author of the package.
"states_tg"




#' Popular Emojis
#'
#' The most popular emoji of a given week in a given category from the
#' Meltwater Tweet sample, as HTML \code{<img>} tags. The vector is aligned
#' row-for-row with \code{\link{pitts_tg}}, so \code{pitts_emojis[i]} is the
#' emoji for the \code{week} / \code{category} combination in row \code{i} of
#' that data set. The tags are meant to be drawn as rich text, e.g. with
#' \code{ggtext::geom_richtext()} or \code{annotate("richtext", ...)}.
#'
#' @format A character vector of 270 HTML \code{<img>} tags (90 distinct
#'   emoji), one per row of \code{\link{pitts_tg}}.
#'
#' @section Note on the image URLs:
#' Each tag points at a remotely hosted PNG on the Emojipedia asset host used
#' when the data was collected in 2020. Those objects are no longer served
#' publicly, so the tags no longer render as pictures on their own. The emoji
#' each tag refers to is still readable from its file name, which ends in the
#' Unicode code point (for example \code{thinking-face_1f914.png} is
#' U+1F914); substitute your own image paths or the literal emoji characters
#' to draw them.
#'
#' @source The most frequent emoji per week and category in the Meltwater
#' Twitter sample described in \code{\link{pitts_tg}}, processed by the
#' package author.
"pitts_emojis"


#' Synthetic café orders: espresso vs. matcha
#'
#' A small, deliberately \emph{synthetic} two-source dataset for demos and
#' vignettes: weekly orders (per 100 customers) of espresso and matcha drinks
#' across eight fictional neighbourhoods over a 12-week season. It provides an
#' evergreen alternative to the COVID-era \code{pitts_tg} / \code{states_tg}
#' data, and because both columns share the same units it is the natural demo
#' for \code{shared_limits} / \code{shared_legend} in \code{geom_taichi()}.
#' The values are simulated with a fixed seed (espresso cools off over the
#' season while matcha picks up, at neighbourhood-specific rates, plus noise);
#' the generating script ships in \code{data-raw/cafes_tg.R} in the source
#' repository.
#'
#' @format A data frame with 96 rows and 4 columns:
#' \describe{
#'   \item{week}{Week of the season, 1 to 12.}
#'   \item{neighbourhood}{One of eight fictional neighbourhoods (factor).}
#'   \item{espresso}{Weekly espresso orders per 100 customers.}
#'   \item{matcha}{Weekly matcha orders per 100 customers.}
#' }
#' @source Simulated by the package author; see \code{data-raw/cafes_tg.R}.
#' @examples
#' library(ggplot2)
#' ggplot(cafes_tg, aes(x = week, y = neighbourhood)) +
#'   geom_taichi(yin = matcha, yang = espresso, shared_legend = TRUE) +
#'   theme_taichi()
"cafes_tg"
