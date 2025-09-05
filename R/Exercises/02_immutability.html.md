# Immutability Principles 



## Introduction

**Immutability** is a fundamental principle for reproducible research. It means **"never changing the original"** - whether that's raw data files, R objects, or data columns.

Think of immutability as creating a **clear audit trail** of all your data transformations. Instead of modifying existing data, you create new versions with documented changes.


::: {.cell layout-align="center"}

```{.r .cell-code}
# Load required packages
library(tidyverse)
library(palmerpenguins) # For penguin data
library(here) # For file paths
```
:::


### Why Immutability Matters in Ecology

1. **Preserve raw data**: Original field measurements should never be altered
2. **Enable reproduction**: Others can trace your exact steps
3. **Prevent errors**: No risk of accidentally overwriting important data
4. **Version control**: Clear history of all transformations

---

## 1. File-Level Immutability: Protecting Raw Data 📁

### The Golden Rule: Never Edit Raw Data Files


::: {.cell layout-align="center"}

```{.r .cell-code}
# ❌ BAD: Opening raw data file in Excel and "fixing" values
# This destroys reproducibility and creates no record of changes

# ✅ GOOD: Keep raw data in Data/Input/Raw/ and process in code
# All changes are documented and reproducible
```
:::


### Exercise 1.1: Reading Raw Data

Let's start with the penguin data as our "raw" dataset:


::: {.cell layout-align="center"}

```{.r .cell-code}
# Treat penguins as our raw field data
data_penguin_raw <-
  palmerpenguins::penguins

readr::write_csv(
  data_penguin_raw,
  file = here::here(
    "Data/Input/penguins_raw.csv"
  )
)
```
:::


**❌ Bad Practice:**

Keep saving over the same file:


::: {.cell layout-align="center"}

```{.r .cell-code}
data_penguin_raw <-
  readr::read_csv(
    here::here("Data/Input/penguins_raw.csv")
  )

data_penguin_changed <-
  data_penguin_raw %>%
  dplyr::filter(!is.na(body_mass_g))

data_penguin_changed %>%
  readr::write_csv(
    here::here("Data/Input/penguins_raw.csv")
  )
```
:::


**✅ Good Practice:**

Save as RDS in Data/Processed/:


::: {.cell layout-align="center"}

```{.r .cell-code}
data_penguin_raw <-
  readr::read_csv(
    here::here("Data/Input/penguins_raw.csv")
  )

data_penguin_changed <-
  data_penguin_raw %>%
  dplyr::filter(!is.na(body_mass_g))

data_penguin_changed %>%
  readr::write_rds(
    here::here("Data/Processed/penguins_processed.rds")
  )
```
:::


## 2. Object-Level Immutability: Creating New Instead of Modifying 🔄

### The Principle: Don't Overwrite R Objects

**❌ Bad Practice (Mutable):**

::: {.cell layout-align="center"}

```{.r .cell-code}
# This modifies the original object - BAD!
data_penguins <-
  palmerpenguins::penguins

data_penguins <-
  data_penguins[!is.na(data_penguins$body_mass_g), ]

data_penguins <-
  data_penguins[data_penguins$year >= 2008, ]

data_penguins$body_mass_kg <-
  data_penguins$body_mass_g / 1000

# Problem: We've lost the original data and can't trace changes!
```
:::


**✅ Good Practice (Immutable):**

::: {.cell layout-align="center"}

```{.r .cell-code}
# Create new objects for each transformation - GOOD!
data_penguins_no_na <-
  palmerpenguins::penguins %>%
  dplyr::filter(!is.na(body_mass_g))

data_penguins_recent <-
  data_penguins_no_na %>%
  dplyr::filter(year >= 2008)

data_penguins_with_kg <-
  data_penguins_recent %>%
  dplyr::mutate(body_mass_kg = body_mass_g / 1000)

# We can always go back to previous steps!
nrow(data_penguins_no_na)
#> [1] 342

nrow(data_penguins_recent)
#> [1] 233

names(data_penguins_with_kg)
#> [1] "species"           "island"            "bill_length_mm"   
#> [4] "bill_depth_mm"     "flipper_length_mm" "body_mass_g"      
#> [7] "sex"               "year"              "body_mass_kg"
```
:::


### Exercise 2.1: Immutable Data Cleaning

Let's clean some messy ecological data the immutable way:


::: {.cell layout-align="center"}

```{.r .cell-code}
# Create some "messy" field data (simulating real-world issues)
data_messy <-
  tibble::tibble(
    site_id = c("SITE001", "SITE002", "SITE003", "SITE001", "SITE002"),
    species = c("Betula nana", "Salix glauca", "NA", "Vaccinium", "Salix glauca"),
    count = c(45, 32, -999, 67, 28),
    temperature_c = c(15.5, NA, 18.1, 12.3, 16.8),
    notes = c("healthy", "some damage", "missing", "flowering", ""),
    date = c("2023-07-01", "2023-07-02", "2023-07-03", "2023-07-04", "2023-07-05")
  )
data_messy
#> # A tibble: 5 × 6
#>   site_id species      count temperature_c notes         date      
#>   <chr>   <chr>        <dbl>         <dbl> <chr>         <chr>     
#> 1 SITE001 Betula nana     45          15.5 "healthy"     2023-07-01
#> 2 SITE002 Salix glauca    32          NA   "some damage" 2023-07-02
#> 3 SITE003 NA            -999          18.1 "missing"     2023-07-03
#> 4 SITE001 Vaccinium       67          12.3 "flowering"   2023-07-04
#> 5 SITE002 Salix glauca    28          16.8 ""            2023-07-05
```
:::


Now let's clean it step by step, creating new objects:


::: {.cell layout-align="center"}

```{.r .cell-code}
# Step 1: Remove invalid counts (keeping original object intact)
data_valid_counts <-
  data_messy %>%
  dplyr::filter(count >= 0)

nrow(data_valid_counts)
#> [1] 4

# Step 2: Fix species names (creating new object)
data_clean_species <-
  data_valid_counts %>%
  dplyr::mutate(
    species_clean = dplyr::case_when(
      species == "NA" ~ NA_character_,
      species == "Vaccinium" ~ "Vaccinium uliginosum",
      TRUE ~ species
    )
  )

data_clean_species %>%
  dplyr::select(species, species_clean)
#> # A tibble: 4 × 2
#>   species      species_clean       
#>   <chr>        <chr>               
#> 1 Betula nana  Betula nana         
#> 2 Salix glauca Salix glauca        
#> 3 Vaccinium    Vaccinium uliginosum
#> 4 Salix glauca Salix glauca

# Step 3: Remove rows with missing species (new object again)
data_complete_species <-
  data_clean_species %>%
  dplyr::filter(!is.na(species_clean))

nrow(data_complete_species)
#> [1] 4

# Step 4: Final cleaned dataset
data_cleaned <-
  data_complete_species %>%
  dplyr::select(-species) %>%
  dplyr::rename(species = species_clean) %>%
  dplyr::mutate(date = as.Date(date))

data_cleaned
#> # A tibble: 4 × 6
#>   site_id count temperature_c notes         date       species             
#>   <chr>   <dbl>         <dbl> <chr>         <date>     <chr>               
#> 1 SITE001    45          15.5 "healthy"     2023-07-01 Betula nana         
#> 2 SITE002    32          NA   "some damage" 2023-07-02 Salix glauca        
#> 3 SITE001    67          12.3 "flowering"   2023-07-04 Vaccinium uliginosum
#> 4 SITE002    28          16.8 ""            2023-07-05 Salix glauca
```
:::


**🧠 Notice:**

- Original `data_messy` is unchanged
- Each step creates a new object
- We can inspect any intermediate step
- Full audit trail of all transformations

---

## 3. Column-Level Immutability: Adding Not Replacing 📊

### The Principle: Create New Columns Instead of Modifying Existing Ones

**❌ Bad Practice:**

::: {.cell layout-align="center"}

```{.r .cell-code}
data_penguin <-
  palmerpenguins::penguins

# This overwrites the original column - BAD!
data_penguin$bill_length_mm <- data_penguin$bill_length_mm * 10 # Convert to cm?

data_penguin$body_mass_g <- log(data_penguin$body_mass_g) # Log transform?

# Problem: Original measurements are lost forever!
```
:::


**✅ Good Practice:**

::: {.cell layout-align="center"}

```{.r .cell-code}
# Create new columns with descriptive names - GOOD!
data_penguin_measurements <-
  palmerpenguins::penguins %>%
  dplyr::filter(
    !is.na(bill_length_mm),
    !is.na(body_mass_g)
  ) %>%
  dplyr::mutate(
    # Keep original, add new
    bill_length_cm = bill_length_mm / 10,
    body_mass_log = log(body_mass_g),
    # Create derived measurements
    bill_ratio = bill_length_mm / bill_depth_mm,
    body_condition = body_mass_g / flipper_length_mm
  )

# Original data preserved, new insights available
data_penguin_measurements %>%
  dplyr::select(
    bill_length_mm, bill_length_cm,
    body_mass_g, body_mass_log,
    bill_ratio, body_condition
  ) %>%
  head()
#> # A tibble: 6 × 6
#>   bill_length_mm bill_length_cm body_mass_g body_mass_log bill_ratio
#>            <dbl>          <dbl>       <int>         <dbl>      <dbl>
#> 1           39.1           3.91        3750          8.23       2.09
#> 2           39.5           3.95        3800          8.24       2.27
#> 3           40.3           4.03        3250          8.09       2.24
#> 4           36.7           3.67        3450          8.15       1.90
#> 5           39.3           3.93        3650          8.20       1.91
#> 6           38.9           3.89        3625          8.20       2.19
#> # ℹ 1 more variable: body_condition <dbl>
```
:::


---

## 4. Common Immutability Violations and Solutions ⚠️

### Exercise 5.1: Identifying Problems

**❌ Problem 1: Overwriting during exploration**

::: {.cell layout-align="center"}

```{.r .cell-code}
# BAD: Repeatedly modifying the same object
data <- read.csv("my_data.csv")
data <- data[data$year > 2020, ] # Lost pre-2020 data
data <- data[complete.cases(data), ] # Lost NA pattern info
data$value <- log(data$value) # Lost original scale
```
:::


**✅ Solution 1: Create exploration pipeline**

::: {.cell layout-align="center"}

```{.r .cell-code}
# GOOD: Preserve each exploration step
data_raw <-
  palmerpenguins::penguins

# Step-by-step exploration
data_recent <-
  data_raw %>%
  dplyr::filter(year > 2007)

data_complete <-
  data_recent %>%
  dplyr::filter(complete.cases(.))

data_log_transformed <-
  data_complete %>%
  dplyr::mutate(
    body_mass_log = log(body_mass_g),
    bill_length_log = log(bill_length_mm)
  )

print(paste("Raw data:", nrow(data_raw), "rows"))
#> [1] "Raw data: 344 rows"
print(paste("Recent data:", nrow(data_recent), "rows"))
#> [1] "Recent data: 234 rows"
print(paste("Complete data:", nrow(data_complete), "rows"))
#> [1] "Complete data: 230 rows"
print(paste("Final data:", nrow(data_log_transformed), "rows"))
#> [1] "Final data: 230 rows"
```
:::


**🧠 Key Immutability Features:**

- Raw data never modified
- Each analysis step creates new objects  
- Original measurements preserved alongside derived ones
- Can return to any step for verification
- Clear audit trail of all transformations

---

## 5. Practice Exercises 💪

### Exercise A: Fix This Mutable Analysis

The following code violates immutability principles. Rewrite it properly:


::: {.cell layout-align="center"}

```{.r .cell-code}
# ❌ BAD CODE - Fix this!
data <- palmerpenguins::penguins
data <- data[!is.na(data$body_mass_g), ]
data$body_mass_g <- scale(data$body_mass_g)
data <- data[data$species == "Adelie", ]
data$bill_length_mm <- log(data$bill_length_mm)
summary(data)
```
:::


**Your task:** Rewrite using immutability principles:


::: {.cell layout-align="center"}

```{.r .cell-code}
# ✅ Your solution here:
```
:::


### Exercise B: Design an Immutable Workflow

Create an immutable analysis workflow for this research question:

**Question:** How does the relationship between flipper length and body mass change with climate (represented by year) in each penguin species?


::: {.cell layout-align="center"}

```{.r .cell-code}
# Your immutable workflow here:

# Step 1: Define raw data

# Step 2: Quality control

# Step 3: Add climate proxy and morphometric indices

# Step 4: Species-specific temporal analysis
```
:::

