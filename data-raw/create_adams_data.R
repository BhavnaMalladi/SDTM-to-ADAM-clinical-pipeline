# SDTM to ADaM Data Derivation Pipeline
# This script transforms SDTM datasets into ADaM datasets
# Following the pharmaverseadam workflow

cat("========================================\n")
cat("SDTM → ADaM Derivation Pipeline\n")
cat("========================================\n\n")

# Load required packages
library(admiral)
library(pharmaversesdtm)
library(dplyr)
library(lubridate)
library(readxl)
library(jsonlite)

# ============================================================================
# Step 1: Load Metadata
# ============================================================================
cat("Step 1: Loading metadata from adams-specs.xlsx...\n")

metadata_file <- "../inst/extdata/adams-specs.xlsx"
adam_specs <- read_excel(metadata_file)

cat(sprintf("✓ Loaded metadata for %d variables across %d datasets\n",
            nrow(adam_specs),
            length(unique(adam_specs$dataset_name))))

# Convert metadata to JSON for traceability
json_file <- "../inst/extdata/adams-specs.json"
write_json(adam_specs, json_file, pretty = TRUE)
cat(sprintf("✓ Saved metadata as JSON: %s\n", json_file))

# ============================================================================
# Step 2: Load SDTM Data
# ============================================================================
cat("\nStep 2: Loading SDTM datasets...\n")

data("dm", package = "pharmaversesdtm")  # Demographics
data("ex", package = "pharmaversesdtm")  # Exposure
data("ae", package = "pharmaversesdtm")  # Adverse Events
data("vs", package = "pharmaversesdtm")  # Vital Signs
data("lb", package = "pharmaversesdtm")  # Laboratory

cat(sprintf("✓ DM (Demographics): %d subjects\n", nrow(dm)))
cat(sprintf("✓ EX (Exposure): %d records\n", nrow(ex)))
cat(sprintf("✓ AE (Adverse Events): %d records\n", nrow(ae)))
cat(sprintf("✓ VS (Vital Signs): %d records\n", nrow(vs)))
cat(sprintf("✓ LB (Laboratory): %d records\n", nrow(lb)))

# ============================================================================
# Step 3: Derive ADSL (Subject-Level Analysis Dataset)
# ============================================================================
cat("\nStep 3: Creating ADSL (Subject-Level Analysis Dataset)...\n")

# Derive first and last treatment dates from EX
ex_dates <- ex %>%
  filter(!is.na(EXSTDTC)) %>%
  group_by(USUBJID) %>%
  summarise(
    TRTSDT = min(as.Date(EXSTDTC), na.rm = TRUE),
    TRTEDT = max(as.Date(EXENDTC), na.rm = TRUE),
    .groups = "drop"
  )

# Create ADSL
adsl <- dm %>%
  select(STUDYID, USUBJID, SUBJID, SITEID, AGE, SEX, RACE, COUNTRY, ARMCD, ARM) %>%
  # Add treatment variables
  mutate(
    TRT01P = ARM,
    TRT01A = ARM,
    TRT01PN = as.numeric(factor(ARMCD)),
    TRT01AN = as.numeric(factor(ARMCD))
  ) %>%
  # Join treatment dates
  left_join(ex_dates, by = "USUBJID")

cat(sprintf("✓ Created ADSL: %d subjects\n", nrow(adsl)))

# ============================================================================
# Step 4: Derive ADAE (Adverse Events Analysis Dataset)
# ============================================================================
cat("\nStep 4: Creating ADAE (Adverse Events Analysis Dataset)...\n")

adae <- ae %>%
  select(STUDYID, USUBJID, AESEQ, AETERM, AESTDTC, AEENDTC, AESEV, AESER) %>%
  # Join ADSL for treatment info
  left_join(
    adsl %>% select(USUBJID, TRT01P, TRT01A, TRTSDT, TRTEDT),
    by = "USUBJID"
  ) %>%
  # Derive analysis dates
  mutate(
    ASTDT = as.Date(AESTDTC),
    AENDT = as.Date(AEENDTC)
  ) %>%
  # Derive treatment-emergent flag
  mutate(
    TRTEMFL = if_else(
      !is.na(ASTDT) & !is.na(TRTSDT) & ASTDT >= TRTSDT,
      "Y",
      "N"
    )
  )

cat(sprintf("✓ Created ADAE: %d adverse events\n", nrow(adae)))
cat(sprintf("  - Treatment-emergent AEs: %d\n", sum(adae$TRTEMFL == "Y", na.rm = TRUE)))

# ============================================================================
# Step 5: Derive ADVS (Vital Signs Analysis Dataset)
# ============================================================================
cat("\nStep 5: Creating ADVS (Vital Signs Analysis Dataset)...\n")

advs <- vs %>%
  select(STUDYID, USUBJID, VSSEQ, VSTESTCD, VSTEST, VSORRES, VSORRESU,
         VSSTRESN, VSSTRESU, VISITNUM, VISIT) %>%
  # Join ADSL for treatment info
  left_join(
    adsl %>% select(USUBJID, TRT01P, TRT01A, TRTSDT),
    by = "USUBJID"
  ) %>%
  # Add analysis value
  mutate(AVAL = VSSTRESN) %>%
  # Derive baseline (first non-missing value before treatment)
  group_by(USUBJID, VSTESTCD) %>%
  mutate(
    BASE = first(AVAL[VISITNUM == 1], default = NA_real_),
    CHG = AVAL - BASE
  ) %>%
  ungroup()

cat(sprintf("✓ Created ADVS: %d vital signs records\n", nrow(advs)))

# ============================================================================
# Step 6: Derive ADLB (Laboratory Analysis Dataset)
# ============================================================================
cat("\nStep 6: Creating ADLB (Laboratory Analysis Dataset)...\n")

adlb <- lb %>%
  select(STUDYID, USUBJID, LBSEQ, LBTESTCD, LBTEST, LBORRES, LBORRESU,
         LBSTRESN, LBSTRESU, VISITNUM, VISIT) %>%
  # Join ADSL for treatment info
  left_join(
    adsl %>% select(USUBJID, TRT01P, TRT01A, TRTSDT),
    by = "USUBJID"
  ) %>%
  # Add analysis value
  mutate(AVAL = LBSTRESN) %>%
  # Derive baseline
  group_by(USUBJID, LBTESTCD) %>%
  mutate(
    BASE = first(AVAL[VISITNUM == 1], default = NA_real_),
    CHG = AVAL - BASE
  ) %>%
  ungroup()

cat(sprintf("✓ Created ADLB: %d laboratory records\n", nrow(adlb)))

# ============================================================================
# Step 7: Save ADaM Datasets
# ============================================================================
cat("\nStep 7: Saving ADaM datasets...\n")

# Save as RData files (R native format)
save(adsl, file = "../data/adsl.rda", compress = "xz")
save(adae, file = "../data/adae.rda", compress = "xz")
save(advs, file = "../data/advs.rda", compress = "xz")
save(adlb, file = "../data/adlb.rda", compress = "xz")

cat("✓ Saved RData files to data/\n")

# Also save as CSV for easy viewing
write.csv(adsl, "../output/adsl.csv", row.names = FALSE)
write.csv(adae, "../output/adae.csv", row.names = FALSE)
write.csv(advs, "../output/advs.csv", row.names = FALSE)
write.csv(adlb, "../output/adlb.csv", row.names = FALSE)

cat("✓ Saved CSV files to output/\n")

# ============================================================================
# Step 8: Generate Summary Report
# ============================================================================
cat("\n========================================\n")
cat("Pipeline Execution Complete!\n")
cat("========================================\n\n")

cat("Summary of Generated ADaM Datasets:\n")
cat(sprintf("  ADSL: %d subjects\n", nrow(adsl)))
cat(sprintf("  ADAE: %d adverse events (%d treatment-emergent)\n",
            nrow(adae), sum(adae$TRTEMFL == "Y", na.rm = TRUE)))
cat(sprintf("  ADVS: %d vital signs records\n", nrow(advs)))
cat(sprintf("  ADLB: %d laboratory records\n", nrow(adlb)))

cat("\nOutput Locations:\n")
cat("  - RData files: data/\n")
cat("  - CSV files: output/\n")
cat("  - Metadata: inst/extdata/adams-specs.xlsx\n")

cat("\nNext Steps:\n")
cat("  1. Review generated datasets in output/ folder\n")
cat("  2. Validate against CDISC standards using xportr\n")
cat("  3. Run statistical analyses per SAP\n")
cat("  4. Generate TFLs (Tables, Figures, Listings)\n")
