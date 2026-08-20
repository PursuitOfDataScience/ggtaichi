# Keep the suite from leaving a stray Rplots.pdf in tests/testthat/.
#
# Several tests render a plot to inspect the drawn scene (the taichi cells only
# materialise their children in makeContent(), at draw time). Each of those
# opens and closes its own device, and the first plotting call made afterwards
# with no device open starts the default pdf() device in the working directory.
# Holding a null device open for the whole run means there is always one, so
# nothing is ever written to disk. The R process closes it on exit.
grDevices::pdf(NULL)
