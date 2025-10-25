# Quick Demo - See SDTM → ADaM transformation in action

library(admiral)
library(pharmaversesdtm)
library(dplyr)

# Load SDTM data
data("dm", package = "pharmaversesdtm")
data("ex", package = "pharmaversesdtm")
data("ae", package = "pharmaversesdtm")

cat("\n=== SDTM INPUT DATA ===\n")
cat("\nDM (Demographics) - First 3 subjects:\n")
print(dm %>% select(USUBJID, AGE, SEX, ARM) %>% head(3))

cat("\nEX (Exposure) - First 3 records:\n")
print(ex %>% select(USUBJID, EXSTDTC, EXENDTC) %>% head(3))

# Calculate treatment dates
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
  select(USUBJID, AGE, SEX, ARM) %>%
  mutate(TRT01P = ARM) %>%
  left_join(ex_dates, by = "USUBJID")

cat("\n\n=== ADaM OUTPUT DATA ===\n")
cat("\nADSL (Subject-Level Analysis) - First 3 subjects:\n")
cat("Notice new columns: TRT01P, TRTSDT, TRTEDT!\n")
print(adsl %>% head(3))

cat("\n\n=== COMPARISON ===\n")
cat("SDTM DM had:", ncol(dm), "columns\n")
cat("ADaM ADSL has:", ncol(adsl), "columns\n")
cat("New columns added:", ncol(adsl) - ncol(dm %>% select(USUBJID, AGE, SEX, ARM)), "\n")
cat("\nTransformation complete! SDTM → ADaM ✓\n")
