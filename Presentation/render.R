#----------------------------------------------------------#
#
#
#                     Project name
#
#                  Render presentation
#
#
#                O. Mottl, Author name
#                         2024
#
#----------------------------------------------------------#

# The QUARTO is curently unable to render into other directory.
# GitHub pages require the presentation to be in the `docs` directory.
# This is a workaround to render the presentation into the `docs`` directory

# Setup -----

library(here)

source(
  here::here("R/00_Confiq_file.R")
)

# Render -----
quarto::quarto_render(
  input = here::here("Presentation/presentation.qmd")
)

# Move the rendered file to the `docs` directory. -----

fs::file_copy(
  path = here::here("Presentation/index.html"),
  new_path = here::here("docs/index.html"),
  overwrite = TRUE
)

# Clean up -----
fs::file_delete(
  here::here("Presentation/index.html")
)
