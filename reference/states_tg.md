# States' COVID-related Google & Twitter incidence rates

A data set containing the 31-week incidence rates of COVID-related
categories in 4 states (Florida, Missouri, New York, and Texas), from
week 1 beginning June 1, 2020 to week 31, which begins December 28, 2020
and so runs a few days past the end of the year. The data columns are
introduced below. One quick note about the columns of the data set:
`week_start` is present for illustration purposes, as a reminder of what
the `week` column counts. In other words, it does not participate in any
visualization.

## Usage

``` r
states_tg
```

## Format

A data frame with 1116 rows and 6 columns:

- state:

  One of the four states: Florida, Missouri, New York, Texas.

- week:

  week 1 to week 31.

- week_start:

  The Monday date of the week started.

- category:

  One of 9 COVID-related categories: Covid, General Virus, Masks,
  Sanitizing, Social Distancing, Symptoms, Tests, Treatment, Working.

- Twitter:

  weekly tweets percentage (%) in state falling into each category.

- Google:

  weekly Google search percentage (%) in state falling into each
  category.

## Source

Just like `pitts_tg`, Google is processed from Google Health API, and
Twitter from Meltwater, a Twitter vendor. Both data sources are
processed by the author of the package.
