# Interactive SDTM → ADaM Transformation Demo
# Run this script step-by-step to see how SDTM transforms into ADaM
#
# HOW TO USE:
# 1. Open this file in RStudio
# 2. Run each section one at a time (Cmd+Enter on each line/block)
# 3. Look at the output in the console and viewer
# 4. Compare SDTM input vs ADaM output

cat("========================================\n")
cat("Interactive SDTM → ADaM Demo\n")
cat("========================================\n\n")

# ============================================================================
# STEP 1: Load Packages
# ============================================================================
cat("\n>>> STEP 1: Loading required packages...\n")
cat("Press Enter to continue...\n")
readline()

library(admiral)
library(pharmaversesdtm)
library(dplyr)
library(lubridate)

cat("✓ Packages loaded!\n")

# ============================================================================
# STEP 2: Load SDTM Data (Input)
# ============================================================================
cat("\n>>> STEP 2: Loading SDTM datasets (these are the INPUT)...\n")
cat("Press Enter to continue...\n")
readline()

data("dm", package = "pharmaversesdtm")  # Demographics
data("ex", package = "pharmaversesdtm")  # Exposure
data("ae", package = "pharmaversesdtm")  # Adverse Events

cat(sprintf("✓ Loaded DM (Demographics): %d subjects\n", nrow(dm)))
cat(sprintf("✓ Loaded EX (Exposure): %d records\n", nrow(ex)))
cat(sprintf("✓ Loaded AE (Adverse Events): %d records\n", nrow(ae)))

# ============================================================================
# STEP 3: Examine SDTM Input Data
# ============================================================================
cat("\n>>> STEP 3: Let's look at the SDTM input data...\n")
cat("Press Enter to view DM (Demographics) data...\n")
readline()

cat("\n--- SDTM DM Dataset (first 5 rows) ---\n")
print(head(dm %>% select(STUDYID, USUBJID, AGE, SEX, RACE, ARM), 5))

cat("\nPress Enter to view EX (Exposure) data...\n")
readline()

cat("\n--- SDTM EX Dataset (first 5 rows) ---\n")
print(head(ex %>% select(USUBJID, EXSTDTC, EXENDTC, EXTRT), 5))

cat("\nPress Enter to view AE (Adverse Events) data...\n")
readline()

cat("\n--- SDTM AE Dataset (first 5 rows) ---\n")
print(head(ae %>% select(USUBJID, AETERM, AESTDTC, AESEV), 5))

# ============================================================================
# STEP 4: Transform DM → ADSL (WATCH THE TRANSFORMATION!)
# ============================================================================
cat("\n>>> STEP 4: Now we'll transform SDTM DM into ADaM ADSL...\n")
cat("This adds treatment variables and dates.\n")
cat("Press Enter to run the transformation...\n")
readline()

cat("\n--- Calculating treatment dates from EX ---\n")
ex_dates <- ex %>%
  filter(!is.na(EXSTDTC)) %>%
  group_by(USUBJID) %>%
  summarise(
    TRTSDT = min(as.Date(EXSTDTC), na.rm = TRUE),
    TRTEDT = max(as.Date(EXENDTC), na.rm = TRUE),
    .groups = "drop"
  )

cat("✓ Treatment dates calculated\n")
print(head(ex_dates, 3))

cat("\nPress Enter to create ADSL from DM...\n")
readline()

cat("\n--- Creating ADSL (Subject-Level Analysis Dataset) ---\n")
adsl <- dm %>%
  select(STUDYID, USUBJID, SUBJID, SITEID, AGE, SEX, RACE, ARMCD, ARM) %>%
  # Add treatment variables (NEW!)
  mutate(
    TRT01P = ARM,                              # Planned treatment
    TRT01A = ARM,                              # Actual treatment
    TRT01PN = as.numeric(factor(ARMCD)),       # Planned treatment number
    TRT01AN = as.numeric(factor(ARMCD))        # Actual treatment number
  ) %>%
  # Join treatment dates (NEW!)
  left_join(ex_dates, by = "USUBJID")

cat(sprintf("✓ Created ADSL: %d subjects\n", nrow(adsl)))

cat("\nPress Enter to compare SDTM DM vs ADaM ADSL...\n")
readline()

cat("\n=== COMPARISON: SDTM DM (input) vs ADaM ADSL (output) ===\n")
cat("\nSDTM DM (original):\n")
print(head(dm %>% select(USUBJID, AGE, SEX, ARM), 3))

cat("\nADaM ADSL (transformed - notice new TRT01P, TRTSDT, TRTEDT columns!):\n")
print(head(adsl %>% select(USUBJID, AGE, SEX, ARM, TRT01P, TRTSDT, TRTEDT), 3))

# ============================================================================
# STEP 5: Transform AE → ADAE (WATCH THE TRANSFORMATION!)
# ============================================================================
cat("\n>>> STEP 5: Now we'll transform SDTM AE into ADaM ADAE...\n")
cat("This adds treatment info and treatment-emergent flag.\n")
cat("Press Enter to run the transformation...\n")
readline()

cat("\n--- Creating ADAE (Adverse Events Analysis Dataset) ---\n")
adae <- ae %>%
  select(USUBJID, AESEQ, AETERM, AESTDTC, AESEV) %>%
  # Join ADSL for treatment info (NEW!)
  left_join(
    adsl %>% select(USUBJID, TRT01P, TRTSDT),
    by = "USUBJID"
  ) %>%
  # Derive analysis dates (NEW!)
  mutate(
    ASTDT = as.Date(AESTDTC)
  ) %>%
  # Derive treatment-emergent flag (NEW!)
  mutate(
    TRTEMFL = if_else(
      !is.na(ASTDT) & !is.na(TRTSDT) & ASTDT >= TRTSDT,
      "Y",  # Treatment-emergent
      "N"   # Not treatment-emergent
    )
  )

cat(sprintf("✓ Created ADAE: %d adverse events\n", nrow(adae)))
cat(sprintf("  - Treatment-emergent: %d\n", sum(adae$TRTEMFL == "Y", na.rm = TRUE)))

cat("\nPress Enter to compare SDTM AE vs ADaM ADAE...\n")
readline()

cat("\n=== COMPARISON: SDTM AE (input) vs ADaM ADAE (output) ===\n")
cat("\nSDTM AE (original):\n")
print(head(ae %>% select(USUBJID, AETERM, AESTDTC, AESEV), 3))

cat("\nADaM ADAE (transformed - notice new TRT01P, TRTEMFL columns!):\n")
print(head(adae %>% select(USUBJID, AETERM, AESTDTC, AESEV, TRT01P, TRTEMFL), 3))

# ============================================================================
# STEP 6: View Summary Statistics
# ============================================================================
cat("\n>>> STEP 6: Summary of transformation...\n")
cat("Press Enter to see summary...\n")
readline()

cat("\n========================================\n")
cat("TRANSFORMATION COMPLETE!\n")
cat("========================================\n\n")

cat("What we did:\n")
cat("1. Started with SDTM datasets (DM, EX, AE)\n")
cat("2. Calculated treatment dates from EX\n")
cat("3. Created ADSL by adding treatment variables to DM\n")
cat("4. Created ADAE by merging AE with ADSL and adding flags\n\n")

cat("Results:\n")
cat(sprintf("  ADSL: %d subjects (from DM)\n", nrow(adsl)))
cat(sprintf("  ADAE: %d events (from AE)\n", nrow(adae)))
cat(sprintf("    └─ Treatment-emergent: %d (%.1f%%)\n",
            sum(adae$TRTEMFL == "Y", na.rm = TRUE),
            100 * mean(adae$TRTEMFL == "Y", na.rm = TRUE)))

cat("\nNew variables created:\n")
cat("  In ADSL:\n")
cat("    - TRT01P, TRT01A: Treatment descriptions\n")
cat("    - TRTSDT, TRTEDT: Treatment start/end dates\n")
cat("  In ADAE:\n")
cat("    - TRT01P: Treatment for each AE\n")
cat("    - TRTEMFL: Treatment-emergent flag (Y/N)\n")

cat("\n========================================\n")
cat("You can now explore these datasets:\n")
cat("  View(dm)     # Original SDTM Demographics\n")
cat("  View(adsl)   # Derived ADaM Subject-Level\n")
cat("  View(ae)     # Original SDTM Adverse Events\n")
cat("  View(adae)   # Derived ADaM Adverse Events\n")
cat("========================================\n")
