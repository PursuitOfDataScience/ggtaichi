#' Pittsburgh COVID-related Google & Twitter incidence rates
#'
#' A data set containing the 30-week incidence rates of COVID related categories
#' from week 1 starting from June 1, 2020 to week 30
#' that ended in the last Sunday of the year in Pittsburgh Metropolitan
#' Statistical Area (MSA). The data columns are introduced below. One quick note
#' about the columns of the data set: \code{week_start} as a column is present
#' in the data set for illustration purposes, reminding users what \code{week}
#' column is. In other words, it does not participate any visualization.
#' @format A data frame with 270 rows and 6 columns:
#' \describe{
#'   \item{msa}{Metropolitan statistical area (Pittsburgh only).}
#'   \item{week}{week 1 to week 30.}
#'   \item{week_start}{The Monday date of the week started.}
#'   \item{category}{9 Covid-related categories in total.}
#'   \item{Twitter}{weekly tweets percentage (\%) in the MSA falling into each
#'   category.}
#'   \item{Google}{weekly Google search percentage (\%) in the MSA falling into
#'   each category.}
#' }
#' @source Just like \code{states_tg}, Google is processed from Google Health
#' API, and Twitter from Meltwater, a Twitter vendor. Both data sources are
#' processed by the author of the package.
"pitts_tg"


#' States' COVID-related Google & Twitter incidence rates
#'
#' A data set containing the 30-week incidence rates of COVID related categories
#' from week 1 starting from June 1, 2020 to week 30
#' that ended in the last Sunday of the year in 4 states (Florida, Missouri,
#' New York, and Texas). The data columns are introduced below. One quick note
#' about the columns of the data set: \code{week_start} as a column is present
#' in the data set for illustration purposes, reminding users what \code{week}
#' column is. In other words, it does not participate any visualization.
#' @format A data frame with 1116 rows and 6 columns:
#' \describe{
#'   \item{state}{state}
#'   \item{week}{week 1 to week 30.}
#'   \item{week_start}{The Monday date of the week started.}
#'   \item{category}{9 Covid-related categories in total.}
#'   \item{Twitter}{weekly tweets percentage (\%) in state falling into each
#'   category.}
#'   \item{Google}{weekly Google search percentage (\%) in state falling into
#'   each category.}
#' }
#' @source Just like \code{pitts_tg}, Google is processed from Google Health
#' API, and Twitter from Meltwater, a Twitter vendor. Both data sources are
#' processed by the author of the package.
"states_tg"




#' Popular Emojis
#'
#' The most popular Emoji of a given week in a given category from the Meltwater
#' Tweet sample. They can be rendered by using \code{"richtext"} with
#' \code{annotate()}.
#'
#'
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
