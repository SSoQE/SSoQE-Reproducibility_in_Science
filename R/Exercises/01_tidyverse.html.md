# Tidyverse for Ecologists: From Base R to Modern Data Science



## Introduction

Welcome to the tidyverse! This workshop will transform how you think about data manipulation in R. We'll explore how the tidyverse makes data analysis more intuitive, readable, and reproducible for ecological research.

The **tidyverse** is a collection of R packages designed for data science that share an underlying design philosophy, grammar, and data structures. Think of it as a unified language for talking to your data.


::: {.cell layout-align="center"}

```{.r .cell-code}
# Load the tidyverse (this loads multiple packages at once)
library(tidyverse)

# We'll also use some additional packages for our ecological examples
library(palmerpenguins) # For penguin data
```
:::


---

## 1. The Magic of Pipes (`%>%`) 🔗

### The Problem with Base R

In base R, complex operations often result in:

- Nested functions that are hard to read
- Many intermediate objects
- Code that reads from inside-out

The pipe operator `%>%` is arguably the most transformative feature of the tidyverse. It allows you to write code that reads like a recipe, from left to right, top to bottom.

You can read the pipe as "and then...". It takes the output of the left-hand side and passes it as the first argument to the function on the right-hand side.

### Exercise 1.1: Calculating Mean Body Mass

Let's calculate the mean body mass of penguins, excluding missing values.

**Base R approach:**


::: {.cell layout-align="center"}

```{.r .cell-code}
# Base R: nested functions (reads inside-out)
round(
  mean(
    na.omit(
      palmerpenguins::penguins$body_mass_g
    )
  ),
  2
)
#> [1] 4201.75
```
:::


**Tidyverse approach:**


::: {.cell layout-align="center"}

```{.r .cell-code}
# Tidyverse: reads like a recipe (top to bottom)
palmerpenguins::penguins$body_mass_g %>% # ..and then ...
  na.omit() %>% # ..and then ...
  mean() %>% # ..and then ...
  round(2)
#> [1] 4201.75
```
:::


### Exercise 1.2: Nested Functions vs Pipes

Let's see a more complex example with deeply nested functions - a common scenario in ecological data analysis.

**Task**: Calculate the standard deviation of bill lengths for the top 5 heaviest penguins of each species.

**Base R approach (nested nightmare):**

::: {.cell layout-align="center"}

```{.r .cell-code}
# Base R: deeply nested, reads from inside-out
# Task: Get top 5 heaviest penguins per species, then calculate SD of bill length
do.call(
  rbind,
  lapply(
    split(
      palmerpenguins::penguins[
        !is.na(palmerpenguins::penguins$body_mass_g) &
          !is.na(palmerpenguins::penguins$bill_length_mm),
      ],
      palmerpenguins::penguins[
        !is.na(palmerpenguins::penguins$body_mass_g) &
          !is.na(palmerpenguins::penguins$bill_length_mm),
      ]$species
    ),
    function(species_data) {
      top_5 <-
        head(
          species_data[order(
            species_data$body_mass_g,
            decreasing = TRUE
          ), ],
          5
        )
      data.frame(
        species = unique(species_data$species),
        sd_bill_length = sd(top_5$bill_length_mm, na.rm = TRUE)
      )
    }
  )
)
#>             species sd_bill_length
#> Adelie       Adelie       1.794993
#> Chinstrap Chinstrap       1.702351
#> Gentoo       Gentoo       5.372337
```
:::


**Tidyverse approach (readable recipe):**

::: {.cell layout-align="center"}

```{.r .cell-code}
# Tidyverse: reads like a step-by-step recipe
palmerpenguins::penguins %>%
  dplyr::filter(
    !is.na(body_mass_g),
    !is.na(bill_length_mm)
  ) %>%
  dplyr::arrange(
    dplyr::desc(body_mass_g)
  ) %>%
  dplyr::group_by(species) %>%
  dplyr::slice_head(n = 5) %>%
  dplyr::summarise(
    sd_bill_length = sd(bill_length_mm, na.rm = TRUE),
    .groups = "drop"
  )
#> # A tibble: 3 × 2
#>   species   sd_bill_length
#>   <fct>              <dbl>
#> 1 Adelie              1.79
#> 2 Chinstrap           1.70
#> 3 Gentoo              5.37
```
:::


**🧠 Notice the difference:**

- Base R: You have to read from the innermost function outward
- Tidyverse: You read from top to bottom, like following a recipe
- Each step in the pipe is a clear, logical transformation

---

## 2. Tibbles: Data Frames with Superpowers 📊

Tibbles are the tidyverse's enhanced data frames. They're designed to be more user-friendly and informative.

### Exercise 2.1: Comparing Data Frames and Tibbles

Let's compare a regular data frame to a tibble using the `penguins` dataset.

First, convert the `penguins` tibble to a regular data frame:


::: {.cell layout-align="center"}

```{.r .cell-code}
# Convert penguins to a regular data.frame
penguins_df <-
  as.data.frame(palmerpenguins::penguins)
```
:::



::: {.cell layout-align="center"}

```{.r .cell-code}
# Print - we need to limit to the first 25
#   Otherewise, it floods the console
print(
  head(penguins_df, 25)
)
```
:::



::: {.cell layout-align="center"}

```
#>    species    island bill_length_mm bill_depth_mm flipper_length_mm body_mass_g
#> 1   Adelie Torgersen           39.1          18.7               181        3750
#> 2   Adelie Torgersen           39.5          17.4               186        3800
#> 3   Adelie Torgersen           40.3          18.0               195        3250
#> 4   Adelie Torgersen             NA            NA                NA          NA
#> 5   Adelie Torgersen           36.7          19.3               193        3450
#> 6   Adelie Torgersen           39.3          20.6               190        3650
#> 7   Adelie Torgersen           38.9          17.8               181        3625
#> 8   Adelie Torgersen           39.2          19.6               195        4675
#> 9   Adelie Torgersen           34.1          18.1               193        3475
#> 10  Adelie Torgersen           42.0          20.2               190        4250
#> 11  Adelie Torgersen           37.8          17.1               186        3300
#> 12  Adelie Torgersen           37.8          17.3               180        3700
#> 13  Adelie Torgersen           41.1          17.6               182        3200
#> 14  Adelie Torgersen           38.6          21.2               191        3800
#> 15  Adelie Torgersen           34.6          21.1               198        4400
#> 16  Adelie Torgersen           36.6          17.8               185        3700
#> 17  Adelie Torgersen           38.7          19.0               195        3450
#> 18  Adelie Torgersen           42.5          20.7               197        4500
#> 19  Adelie Torgersen           34.4          18.4               184        3325
#> 20  Adelie Torgersen           46.0          21.5               194        4200
#> 21  Adelie    Biscoe           37.8          18.3               174        3400
#> 22  Adelie    Biscoe           37.7          18.7               180        3600
#> 23  Adelie    Biscoe           35.9          19.2               189        3800
#> 24  Adelie    Biscoe           38.2          18.1               185        3950
#> 25  Adelie    Biscoe           38.8          17.2               180        3800
#>       sex year
#> 1    male 2007
#> 2  female 2007
#> 3  female 2007
#> 4    <NA> 2007
#> 5  female 2007
#> 6    male 2007
#> 7  female 2007
#> 8    male 2007
#> 9    <NA> 2007
#> 10   <NA> 2007
#> 11   <NA> 2007
#> 12   <NA> 2007
#> 13 female 2007
#> 14   male 2007
#> 15   male 2007
#> 16 female 2007
#> 17 female 2007
#> 18   male 2007
#> 19 female 2007
#> 20   male 2007
#> 21 female 2007
#> 22   male 2007
#> 23 female 2007
#> 24   male 2007
#> 25   male 2007
```
:::


Now, let's look at the tibble version:


::: {.cell layout-align="center"}

```{.r .cell-code}
print(palmerpenguins::penguins)
#> # A tibble: 344 × 8
#>    species island    bill_length_mm bill_depth_mm flipper_length_mm body_mass_g
#>    <fct>   <fct>              <dbl>         <dbl>             <int>       <int>
#>  1 Adelie  Torgersen           39.1          18.7               181        3750
#>  2 Adelie  Torgersen           39.5          17.4               186        3800
#>  3 Adelie  Torgersen           40.3          18                 195        3250
#>  4 Adelie  Torgersen           NA            NA                  NA          NA
#>  5 Adelie  Torgersen           36.7          19.3               193        3450
#>  6 Adelie  Torgersen           39.3          20.6               190        3650
#>  7 Adelie  Torgersen           38.9          17.8               181        3625
#>  8 Adelie  Torgersen           39.2          19.6               195        4675
#>  9 Adelie  Torgersen           34.1          18.1               193        3475
#> 10 Adelie  Torgersen           42            20.2               190        4250
#> # ℹ 334 more rows
#> # ℹ 2 more variables: sex <fct>, year <int>
```
:::


**Key differences:**

- Tibbles show data types for each column
- They don't print all columns if they don't fit on screen
- They show the dimensions (rows × columns)
- Character strings stay as characters (no automatic factor conversion)

### Exercise 2.2: Creating Tibbles


::: {.cell layout-align="center"}

```{.r .cell-code}
# Create a tibble of ecological sites
sites <-
  tibble::tibble(
    site_id = c("SITE_001", "SITE_002", "SITE_003"),
    latitude = c(60.1, 65.2, 58.9),
    longitude = c(-149.8, -147.3, -152.1),
    elevation_m = c(250, 450, 180),
    habitat_type = c("tundra", "forest", "wetland")
  )

sites
#> # A tibble: 3 × 5
#>   site_id  latitude longitude elevation_m habitat_type
#>   <chr>       <dbl>     <dbl>       <dbl> <chr>       
#> 1 SITE_001     60.1     -150.         250 tundra      
#> 2 SITE_002     65.2     -147.         450 forest      
#> 3 SITE_003     58.9     -152.         180 wetland
```
:::


---

## 3. dplyr: Grammar of Data Manipulation 🔧

`dplyr` provides a consistent set of verbs for solving the most common data manipulation challenges. Think of these as actions you can perform on your data.

### The Main dplyr Verbs

- `filter()`: Pick observations (rows) by their values
- `arrange()`: Reorder the rows
- `select()`: Pick variables (columns) by their names
- `mutate()`: Create new variables with functions of existing variables
- `summarise()`: Collapse many values down to a single summary

### Exercise 3.1: Filtering Data

**Base R:**

::: {.cell layout-align="center"}

```{.r .cell-code}
# Base R: subset function
data_penguins_large_adelie <-
  palmerpenguins::penguins[
    palmerpenguins::penguins$body_mass_g > 4500 &
      !is.na(palmerpenguins::penguins$body_mass_g) &
      palmerpenguins::penguins$species == "Adelie",
  ]

nrow(data_penguins_large_adelie)
#> [1] 7
```
:::


**Tidyverse:**

Multiple conditions are easy to read


::: {.cell layout-align="center"}

```{.r .cell-code}
# Tidyverse: readable and chainable
data_penguins_large_adelie <-
  palmerpenguins::penguins %>%
  dplyr::filter(
    body_mass_g > 4500,
    !is.na(body_mass_g),
    species == "Adelie"
  )

nrow(data_penguins_large_adelie)
#> [1] 7
```
:::


### Exercise 3.2: Selecting and Arranging


::: {.cell layout-align="center"}

```{.r .cell-code}
# Select specific columns and arrange by body mass
penguin_basics <-
  palmerpenguins::penguins %>%
  # which columns?
  dplyr::select(species, island, body_mass_g, year) %>%
  # arrange by year, then body mass (descending)
  dplyr::arrange(
    year,
    dplyr::desc(body_mass_g)
  )

head(penguin_basics)
#> # A tibble: 6 × 4
#>   species island body_mass_g  year
#>   <fct>   <fct>        <int> <int>
#> 1 Gentoo  Biscoe        6300  2007
#> 2 Gentoo  Biscoe        6050  2007
#> 3 Gentoo  Biscoe        5850  2007
#> 4 Gentoo  Biscoe        5850  2007
#> 5 Gentoo  Biscoe        5700  2007
#> 6 Gentoo  Biscoe        5700  2007
```
:::


Select columns by pattern (very useful for ecological data!)


::: {.cell layout-align="center"}

```{.r .cell-code}
# Select columns by pattern (very useful for ecological data!)
data_penguins_measurements <-
  palmerpenguins::penguins %>%
  dplyr::select(
    # specify the name of the columns to keep
    species,
    # select all columns ending with _mm or _g
    dplyr::ends_with("_mm"),
    dplyr::ends_with("_g")
  )

head(data_penguins_measurements)
#> # A tibble: 6 × 5
#>   species bill_length_mm bill_depth_mm flipper_length_mm body_mass_g
#>   <fct>            <dbl>         <dbl>             <int>       <int>
#> 1 Adelie            39.1          18.7               181        3750
#> 2 Adelie            39.5          17.4               186        3800
#> 3 Adelie            40.3          18                 195        3250
#> 4 Adelie            NA            NA                  NA          NA
#> 5 Adelie            36.7          19.3               193        3450
#> 6 Adelie            39.3          20.6               190        3650
```
:::


### Exercise 3.3: Creating New Variables

**Base R:**

::: {.cell layout-align="center"}

```{.r .cell-code}
# Base R: assignment to new columns
data_penguins <- palmerpenguins::penguins

data_penguins$bill_ratio <-
  data_penguins$bill_length_mm / data_penguins$bill_depth_mm

data_penguins$size_category <-
  ifelse(data_penguins$body_mass_g > 4000, "Large", "Small")

data_penguins$penguin_id <-
  paste(data_penguins$species, seq_len(nrow(data_penguins)), sep = "_")

head(data_penguins[, c("species", "bill_ratio", "size_category", "penguin_id")])
#> # A tibble: 6 × 4
#>   species bill_ratio size_category penguin_id
#>   <fct>        <dbl> <chr>         <chr>     
#> 1 Adelie        2.09 Small         Adelie_1  
#> 2 Adelie        2.27 Small         Adelie_2  
#> 3 Adelie        2.24 Small         Adelie_3  
#> 4 Adelie       NA    <NA>          Adelie_4  
#> 5 Adelie        1.90 Small         Adelie_5  
#> 6 Adelie        1.91 Small         Adelie_6
```
:::


**Tidyverse:**

::: {.cell layout-align="center"}

```{.r .cell-code}
# Tidyverse: all transformations in one place
data_penguins_enhanced <-
  palmerpenguins::penguins %>%
  dplyr::mutate(
    bill_ratio = bill_length_mm / bill_depth_mm,
    size_category = dplyr::case_when(
      body_mass_g > 4500 ~ "Large",
      body_mass_g > 3500 ~ "Medium",
      TRUE ~ "Small"
    ),
    # Create a unique identifier
    penguin_id = paste(species, dplyr::row_number(), sep = "_")
  )

data_penguins_enhanced %>%
  dplyr::select(species, bill_ratio, size_category, penguin_id) %>%
  head()
#> # A tibble: 6 × 4
#>   species bill_ratio size_category penguin_id
#>   <fct>        <dbl> <chr>         <chr>     
#> 1 Adelie        2.09 Medium        Adelie_1  
#> 2 Adelie        2.27 Medium        Adelie_2  
#> 3 Adelie        2.24 Small         Adelie_3  
#> 4 Adelie       NA    Small         Adelie_4  
#> 5 Adelie        1.90 Small         Adelie_5  
#> 6 Adelie        1.91 Medium        Adelie_6
```
:::


### Exercise 3.4: Summarizing Data

Let's start with simple summarization across the entire dataset.

**Base R:**

::: {.cell layout-align="center"}

```{.r .cell-code}
# Base R: multiple separate calculations
penguin_count <-
  nrow(palmerpenguins::penguins)

mean_mass <-
  mean(palmerpenguins::penguins$body_mass_g, na.rm = TRUE)

sd_mass <-
  sd(palmerpenguins::penguins$body_mass_g, na.rm = TRUE)

mean_bill_length <-
  mean(palmerpenguins::penguins$bill_length_mm, na.rm = TRUE)

# Combine into a data frame
data_overall_summary <-
  data.frame(
    count = penguin_count,
    mean_mass = mean_mass,
    sd_mass = sd_mass,
    mean_bill_length = mean_bill_length
  )

data_overall_summary
#>   count mean_mass  sd_mass mean_bill_length
#> 1   344  4201.754 801.9545         43.92193
```
:::


**Tidyverse:**

::: {.cell layout-align="center"}

```{.r .cell-code}
# Tidyverse: all calculations in one place
data_overall_summary <-
  palmerpenguins::penguins %>%
  dplyr::summarise(
    count = dplyr::n(),
    mean_mass = mean(body_mass_g, na.rm = TRUE),
    sd_mass = sd(body_mass_g, na.rm = TRUE),
    mean_bill_length = mean(bill_length_mm, na.rm = TRUE)
  )

data_overall_summary
#> # A tibble: 1 × 4
#>   count mean_mass sd_mass mean_bill_length
#>   <int>     <dbl>   <dbl>            <dbl>
#> 1   344     4202.    802.             43.9
```
:::



## 4. {tidyr}: Pivoting and more! 📐

Pivoting is a common task in ecological data analysis. {`tidyr`} helps you reshape your data into a tidy format where:

- Each variable forms a column
- Each observation forms a row
- Each type of observational unit forms a table

### Exercise 4.1: Wide to Long Format

Ecological data often comes in wide format (species as columns), but analysis often requires long format.


::: {.cell layout-align="center"}

```{.r .cell-code}
# Create some wide-format species abundance data
data_species_wide <-
  tibble::tibble(
    site = paste0("Site_", 1:5),
    treatment = rep(c("Control", "Fertilized"), length.out = 5),
    Betula_nana = c(23, 45, 12, 67, 34),
    Salix_glauca = c(15, 23, 8, 45, 28),
    Vaccinium_uliginosum = c(8, 12, 15, 23, 19)
  )

data_species_wide
#> # A tibble: 5 × 5
#>   site   treatment  Betula_nana Salix_glauca Vaccinium_uliginosum
#>   <chr>  <chr>            <dbl>        <dbl>                <dbl>
#> 1 Site_1 Control             23           15                    8
#> 2 Site_2 Fertilized          45           23                   12
#> 3 Site_3 Control             12            8                   15
#> 4 Site_4 Fertilized          67           45                   23
#> 5 Site_5 Control             34           28                   19
```
:::



::: {.cell layout-align="center"}

```{.r .cell-code}
# Convert to long format for analysis
data_species_long <-
  data_species_wide %>%
  tidyr::pivot_longer(
    cols = Betula_nana:Vaccinium_uliginosum,
    names_to = "species",
    values_to = "abundance"
  )

data_species_long
#> # A tibble: 15 × 4
#>    site   treatment  species              abundance
#>    <chr>  <chr>      <chr>                    <dbl>
#>  1 Site_1 Control    Betula_nana                 23
#>  2 Site_1 Control    Salix_glauca                15
#>  3 Site_1 Control    Vaccinium_uliginosum         8
#>  4 Site_2 Fertilized Betula_nana                 45
#>  5 Site_2 Fertilized Salix_glauca                23
#>  6 Site_2 Fertilized Vaccinium_uliginosum        12
#>  7 Site_3 Control    Betula_nana                 12
#>  8 Site_3 Control    Salix_glauca                 8
#>  9 Site_3 Control    Vaccinium_uliginosum        15
#> 10 Site_4 Fertilized Betula_nana                 67
#> 11 Site_4 Fertilized Salix_glauca                45
#> 12 Site_4 Fertilized Vaccinium_uliginosum        23
#> 13 Site_5 Control    Betula_nana                 34
#> 14 Site_5 Control    Salix_glauca                28
#> 15 Site_5 Control    Vaccinium_uliginosum        19
```
:::


### Exercise 4.2: Long to Wide Format

Sometimes you need to go the other direction:


::: {.cell layout-align="center"}

```{.r .cell-code}
# Calculate mean abundance by treatment and species
data_treatment_means <-
  data_species_long %>%
  dplyr::group_by(treatment, species) %>%
  dplyr::summarise(mean_abundance = mean(abundance), .groups = "drop")

data_treatment_means
#> # A tibble: 6 × 3
#>   treatment  species              mean_abundance
#>   <chr>      <chr>                         <dbl>
#> 1 Control    Betula_nana                    23  
#> 2 Control    Salix_glauca                   17  
#> 3 Control    Vaccinium_uliginosum           14  
#> 4 Fertilized Betula_nana                    56  
#> 5 Fertilized Salix_glauca                   34  
#> 6 Fertilized Vaccinium_uliginosum           17.5
```
:::



::: {.cell layout-align="center"}

```{.r .cell-code}
# Convert back to wide for a summary table
data_treatment_wide <-
  data_treatment_means %>%
  tidyr::pivot_wider(
    names_from = species,
    values_from = mean_abundance
  )

data_treatment_wide
#> # A tibble: 2 × 4
#>   treatment  Betula_nana Salix_glauca Vaccinium_uliginosum
#>   <chr>            <dbl>        <dbl>                <dbl>
#> 1 Control             23           17                 14  
#> 2 Fertilized          56           34                 17.5
```
:::


--- 

## Showcase of full {tidyverse} power: A Complete Analysis 🔬

Let's combine everything we've learned in a complete ecological analysis:

### Research Question: How do penguin body measurements vary by species and sex?


::: {.cell layout-align="center"}

```{.r .cell-code}
data_penguins_analysis <-
  palmerpenguins::penguins %>%
  # Clean the data
  dplyr::filter(
    !is.na(sex),
    !is.na(body_mass_g)
  ) %>%
  # Create new variables
  dplyr::mutate(
    bill_ratio = bill_length_mm / bill_depth_mm,
    size_category = dplyr::case_when(
      body_mass_g > 4500 ~ "Large",
      body_mass_g > 3500 ~ "Medium",
      TRUE ~ "Small"
    )
  ) %>%
  # Group and summarize
  dplyr::group_by(species, sex) %>%
  dplyr::summarise(
    n = dplyr::n(),
    mean_body_mass = mean(body_mass_g),
    sd_body_mass = sd(body_mass_g),
    mean_bill_ratio = mean(bill_ratio, na.rm = TRUE),
    sd_bill_ratio = sd(bill_ratio, na.rm = TRUE),
    # Proportion of large individuals
    prop_large = mean(size_category == "Large"),
    .groups = "drop"
  ) %>%
  # Arrange results
  dplyr::arrange(species, sex)

data_penguins_analysis
#> # A tibble: 6 × 8
#>   species  sex       n mean_body_mass sd_body_mass mean_bill_ratio sd_bill_ratio
#>   <fct>    <fct> <int>          <dbl>        <dbl>           <dbl>         <dbl>
#> 1 Adelie   fema…    73          3369.         269.            2.12         0.146
#> 2 Adelie   male     73          4043.         347.            2.12         0.165
#> 3 Chinstr… fema…    34          3527.         285.            2.65         0.184
#> 4 Chinstr… male     34          3939.         362.            2.66         0.100
#> 5 Gentoo   fema…    58          4680.         282.            3.20         0.143
#> 6 Gentoo   male     61          5485.         313.            3.15         0.189
#> # ℹ 1 more variable: prop_large <dbl>

# Create a visualization using the analysis data
data_penguins_analysis %>%
  ggplot2::ggplot(
    mapping = ggplot2::aes(
      x = mean_body_mass,
      y = mean_bill_ratio,
      size = n,
      color = species,
      shape = sex
    )
  ) +
  ggplot2::facet_wrap(~species) +
  ggplot2::geom_point(
    data = palmerpenguins::penguins %>%
      dplyr::mutate(
        bill_ratio = bill_length_mm / bill_depth_mm
      ),
    mapping = ggplot2::aes(
      x = body_mass_g,
      y = bill_ratio
    ),
    size = 1,
    alpha = 0.25
  ) +
  ggplot2::geom_segment(
    mapping = ggplot2::aes(
      x = mean_body_mass,
      y = mean_bill_ratio - sd_bill_ratio,
      xend = mean_body_mass,
      yend = mean_bill_ratio + sd_bill_ratio
    ),
    color = "grey50",
    linewidth = 1
  ) +
  ggplot2::geom_segment(
    mapping = ggplot2::aes(
      x = mean_body_mass - sd_body_mass,
      y = mean_bill_ratio,
      xend = mean_body_mass + sd_body_mass,
      yend = mean_bill_ratio
    ),
    color = "grey50",
    linewidth = 1
  ) +
  ggplot2::geom_point() +
  ggplot2::scale_size_continuous(
    name = "Sample Size",
    range = c(3, 5),
    guide = ggplot2::guide_legend(
      override.aes = list(shape = 16)
    )
  ) +
  ggplot2::scale_color_viridis_d(
    name = "Species",
    guide = NULL
  ) +
  ggplot2::scale_shape_manual(
    name = "Sex",
    values = c("female" = 15, "male" = 17),
    guide = ggplot2::guide_legend(
      override.aes = list(size = 5)
    )
  ) +
  ggplot2::labs(
    title = "Palmer Penguins Dataset",
    subtitle = "Morphological Relationships by Species and Sex",
    x = "Mean Body Mass (g)",
    y = "Mean Bill Length:Depth Ratio",
  ) +
  theme_ssoqe() +
  ggplot2::theme(
    legend.position = "right",
    legend.box = "vertical"
  )
#> Warning: Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0.
#> ℹ Please use `linewidth` instead.
#> Warning: Removed 11 rows containing missing values or values outside the scale range
#> (`geom_point()`).
```

::: {.cell-output-display}
![](01_tidyverse_files/figure-html/complete-analysis-1.png){fig-align='center' width=100%}
:::
:::


---

## Practice Exercises 💪

### Exercise A: Data Cleaning Challenge

Take this messy ecological dataset and clean it using tidyverse functions:


::: {.cell layout-align="center"}

```{.r .cell-code}
data_messy <-
  tibble::tibble(
    sample = c("SITE1_PLOT_A_2023", "SITE2_PLOT_B_2023", "SITE1_PLOT_C_2024"),
    species_1 = c("20", "15", "missing"),
    species_2 = c("5", "8", "12"),
    NOTES = c("Betula nana", "Salix glauca", "Betula nana"),
    temp_c = c("15.5", "12.3", "18.1")
  )

data_messy
#> # A tibble: 3 × 5
#>   sample            species_1 species_2 NOTES        temp_c
#>   <chr>             <chr>     <chr>     <chr>        <chr> 
#> 1 SITE1_PLOT_A_2023 20        5         Betula nana  15.5  
#> 2 SITE2_PLOT_B_2023 15        8         Salix glauca 12.3  
#> 3 SITE1_PLOT_C_2024 missing   12        Betula nana  18.1

# Your task: Clean this data to have proper types and structure
# Hints: separate sample info, fix missing values, convert types
```
:::


### Exercise B: Comparison Study

Compare body mass between penguin species using tidyverse functions:


::: {.cell layout-align="center"}

```{.r .cell-code}
# Your task:
# 1. Calculate summary statistics by species
# 2. Find the species with highest variation in body mass
# 3. Create a comparison showing the difference from the overall mean

# Your code here:
```
:::


### Exercise C: Temporal Analysis

Using the penguins data (which includes years), analyze changes over time:


::: {.cell layout-align="center"}

```{.r .cell-code}
# Your task:
# 1. Calculate mean body mass by species and year
# 2. Identify any trends over time
# 3. Find which species-year combination had the largest individuals

# Your code here:
```
:::

