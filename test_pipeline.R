# Test script to verify SDTM → ADaM pipeline works
# This script loads test SDTM data and creates a simple ADSL dataset

cat("========================================\n")
cat("Testing SDTM → ADaM Pipeline\n")
cat("========================================\n\n")

# Load required packages
library(admiral)
library(pharmaversesdtm)
library(dplyr)
library(lubridate)

cat("Step 1: Loading SDTM test data...\n")

# Load SDTM datasets from pharmaversesdtm
data("dm")  # Demographics
data("ex")  # Exposure
data("ae")  # Adverse Events
data("vs")  # Vital Signs
data("lb")  # Laboratory

cat(sprintf("✓ Loaded DM dataset: %d subjects\n", nrow(dm)))
cat(sprintf("✓ Loaded EX dataset: %d records\n", nrow(ex)))
cat(sprintf("✓ Loaded AE dataset: %d records\n", nrow(ae)))
cat(sprintf("✓ Loaded VS dataset: %d records\n", nrow(vs)))
cat(sprintf("✓ Loaded LB dataset: %d records\n", nrow(lb)))

cat("\nStep 2: Preview DM (Demographics) data...\n")
print(head(dm %>% select(STUDYID, USUBJID, AGE, SEX, RACE, COUNTRY), 3))

cat("\nStep 3: Creating simple ADSL (Subject-Level Analysis Dataset)...\n")

# Create a basic ADSL dataset using admiral functions
adsl <- dm %>%
  # Select key variables
  select(STUDYID, USUBJID, SUBJID, SITEID, AGE, SEX, RACE, COUNTRY, ARMCD, ARM) %>%
  # Add treatment variables
  mutate(
    TRT01P = ARM,
    TRT01A = ARM,
    TRT01PN = as.numeric(factor(ARMCD)),
    TRT01AN = as.numeric(factor(ARMCD))
  )

cat(sprintf("✓ Created ADSL dataset: %d subjects\n", nrow(adsl)))

cat("\nStep 4: Preview ADSL data...\n")
print(head(adsl %>% select(USUBJID, AGE, SEX, TRT01P), 3))

cat("\nStep 5: Checking data integrity...\n")

# Verify all subjects from DM are in ADSL
if (nrow(adsl) == nrow(dm)) {
  cat("✓ All subjects from DM are in ADSL\n")
} else {
  cat("✗ WARNING: Subject count mismatch!\n")
}

# Check for required variables
required_vars <- c("STUDYID", "USUBJID", "AGE", "SEX", "TRT01P")
missing_vars <- setdiff(required_vars, names(adsl))

if (length(missing_vars) == 0) {
  cat("✓ All required variables present in ADSL\n")
} else {
  cat(sprintf("✗ Missing variables: %s\n", paste(missing_vars, collapse = ", ")))
}

cat("\n========================================\n")
cat("Pipeline Test Complete!\n")
cat("========================================\n")
cat("\nNext steps:\n")
cat("1. Create adams-specs.xlsx metadata file\n")
cat("2. Build create_adams_data.R script\n")
cat("3. Generate full ADaM datasets\n")
