# Pittsburgh COVID-related Google & Twitter incidence rates

A data set containing the 30-week incidence rates of COVID-related
categories in the Pittsburgh Metropolitan Statistical Area (MSA), from
week 1 beginning June 1, 2020 to week 30, which ended on the last Sunday
of the year. The data columns are introduced below. One quick note about
the columns of the data set: `week_start` is present for illustration
purposes, as a reminder of what the `week` column counts. In other
words, it does not participate in any visualization.

## Usage

``` r
pitts_tg
```

## Format

A data frame with 270 rows and 6 columns:

- msa:

  Metropolitan statistical area (Pittsburgh only).

- week:

  week 1 to week 30.

- week_start:

  The Monday date of the week started.

- category:

  One of 9 COVID-related categories: Covid, General Virus, Masks,
  Sanitizing, Social Distancing, Symptoms, Tests, Treatment, Working.

- Twitter:

  weekly tweets percentage (%) in the MSA falling into each category.

- Google:

  weekly Google search percentage (%) in the MSA falling into each
  category.

## Source

Just like `states_tg`, Google is processed from Google Health API, and
Twitter from Meltwater, a Twitter vendor. Both data sources are
processed by the author of the package.
