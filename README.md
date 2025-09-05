# Lecture "Reproducibility in Science"

The presentation and materials for a lecture "Reproducibility in Science" for SSoQE 2025.

## Presentation

This lecture has a build-in presentation, which is accessible [here](https://ssoqe.github.io/SSoQE-Reproducibility_in_Science/)

## Structure and content

```plaintext
├─ Data/
|   ├─ Input/
|   └─ Processed/
├─ docs/
|   └─ index.html
├─ Presentation/
|   ├─ Materials/
|   |   ├─ Author/
|   |   ├─ Illustrations/
|   |   ├─ Logos/
|   |   ├─ Memes/
|   |   ├─ Packages/
|   |   ├─ QR/
|   |   └─ Screenshots/
|   ├─ _colors.scss
|   ├─ _fonts.scss
|   ├─ _quarto.yml
|   ├─ colors.json
|   ├─ custom_theme.scss
|   ├─ fonts-include.html
|   ├─ fonts.json
|   ├─ presentation.html
|   └─ presentation.qmd
├─ R/
|   ├─ Exercises/
|   |   ├─ 01_tidyverse.qmd
|   |   ├─ 01_tidyverse.html
|   |   ├─ 02_immutability.qmd
|   |   ├─ 02_immutability.html
|   |   ├─ _exercise_theme.scss
|   |   └─ _quarto.yml
|   ├─ Functions/
|   ├─ Project/
|   ├─ ___Init_project___.R
|   ├─ 00_Config_file.R
|   ├─ generate_theme.R
|   ├─ render.R
|   └─ set_r_theme.R
├─ renv/
|   ├─ activate.R
|   ├─ library/
|   └─ settings.json
├─ .gitignore
├─ .Rprofile
├─ LICENSE
├─ README.md
├─ renv.lock
└─ SSoQE-Reproducibility_in_Science.Rproj
```

## Setup

### Getting the repo

The template is accessible in two ways:
  
1. If a user has a [GitHub account](https://github.com/), the easiest way is to create your own GitHub repo using this GitHub template. More details about how to use GitHub templates are on [GitHub Docs](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template).
2. Use can download the latest [Release](https://github.com/OndrejMottl/quarto_revealjs_template/releases) of the Workflow as a zip file.

### Set up R project

Once a user obtains their version of the project, there are several steps to be done before using it:

* Update [R](https://en.wikipedia.org/wiki/R_(programming_language)) and [R-studio IDE](https://posit.co/products/open-source/rstudio/). There are many guides on how to do so (e.g. [here](https://jennhuck.github.io/workshops/install_update_R.html))
* Execute all individual steps with the `R/___Init_project___.R` script. This will result in the preparation of all R-packages using the [`{renv}` package](https://rstudio.github.io/renv/articles/renv.html), which is an R dependency management of your projects. Mainly it will install [`{RUtilpol}`](https://github.com/HOPE-UIB-BIO/R-Utilpol-package) and all dependencies. `{RUtilpol}` is used throughout the project as a version control of files.
* Set up your preferences by editing the The Config file in `R/00_Config_file.R` script. The Config file is a script where all settings (configurations) and criteria used throughout the project are predefined by the user before running individual scripts. In addition, it prepares the current session by loading the required packages and saving all settings throughout the project

## Automatic Theme Generation

This project features a comprehensive automated theme generation system that ensures consistent branding and styling across presentation slides, exercise documents, and R visualizations. The system is based on the SSoQE Brand Guidelines and automatically generates theme files from JSON configurations.

### How it works

The theme generation is automatically triggered before every Quarto render through the `pre-render` hook in `_quarto.yml`, which calls the `00_Config_file.R` script. This script sources `generate_theme.R`, which reads configuration from JSON files and generates all necessary theme files for both presentations and exercises.

### Configuration Files

- **`Presentation/colors.json`**: Defines the SSoQE brand color palette with primary colors and semantic color mappings
- **`Presentation/fonts.json`**: Specifies typography settings including fonts, sizes, weights, and spacing for both presentations and HTML documents
- **`Presentation/custom_theme.json`**: Contains presentation-specific styling configurations

### Generated Files

The system automatically generates the following files (do not edit these directly):

#### Presentation Theme Files
1. **`Presentation/_colors.scss`**: SCSS variables and utility classes for colors
2. **`Presentation/_fonts.scss`**: SCSS variables and utility classes for typography (presentation-optimized)
3. **`Presentation/custom_theme.scss`**: Complete custom theme for Reveal.js presentations
4. **`Presentation/fonts-include.html`**: HTML includes for Google Fonts

#### Exercise Theme Files
5. **`R/Exercises/_colors.scss`**: SCSS color variables and utilities for HTML exercises
6. **`R/Exercises/_fonts.scss`**: SCSS typography variables for HTML documents (HTML-optimized sizes)
7. **`R/Exercises/_exercise_theme.scss`**: Complete custom theme for exercise HTML documents

#### R Theme Files
8. **`R/set_r_theme.R`**: R theme configuration for ggplot2 with SSoQE branding