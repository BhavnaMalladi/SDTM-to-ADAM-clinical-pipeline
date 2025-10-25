# Script to create adams-specs.xlsx metadata template
# This defines the structure and variables for ADaM datasets

library(openxlsx)
library(dplyr)

cat("Creating ADaM metadata specification...\n")

# Create metadata dataframe
# This defines variables for different ADaM datasets
adam_metadata <- tribble(
  ~dataset_name, ~variable_name, ~label, ~type, ~length, ~derivation, ~source,

  # ADSL - Subject-Level Analysis Dataset
  "adsl", "STUDYID", "Study Identifier", "character", 20, "From DM.STUDYID", "pharmaversesdtm::dm",
  "adsl", "USUBJID", "Unique Subject Identifier", "character", 40, "From DM.USUBJID", "pharmaversesdtm::dm",
  "adsl", "SUBJID", "Subject Identifier for the Study", "character", 20, "From DM.SUBJID", "pharmaversesdtm::dm",
  "adsl", "SITEID", "Study Site Identifier", "character", 10, "From DM.SITEID", "pharmaversesdtm::dm",
  "adsl", "AGE", "Age", "numeric", 8, "From DM.AGE", "pharmaversesdtm::dm",
  "adsl", "SEX", "Sex", "character", 1, "From DM.SEX", "pharmaversesdtm::dm",
  "adsl", "RACE", "Race", "character", 50, "From DM.RACE", "pharmaversesdtm::dm",
  "adsl", "COUNTRY", "Country", "character", 3, "From DM.COUNTRY", "pharmaversesdtm::dm",
  "adsl", "ARM", "Description of Planned Arm", "character", 40, "From DM.ARM", "pharmaversesdtm::dm",
  "adsl", "ARMCD", "Planned Arm Code", "character", 20, "From DM.ARMCD", "pharmaversesdtm::dm",
  "adsl", "TRT01P", "Planned Treatment for Period 01", "character", 40, "ARM", "Derived",
  "adsl", "TRT01A", "Actual Treatment for Period 01", "character", 40, "ARM", "Derived",
  "adsl", "TRTSDT", "Date of First Exposure to Treatment", "date", 10, "min(EX.EXSTDTC)", "pharmaversesdtm::ex",
  "adsl", "TRTEDT", "Date of Last Exposure to Treatment", "date", 10, "max(EX.EXENDTC)", "pharmaversesdtm::ex",

  # ADAE - Adverse Events Analysis Dataset
  "adae", "STUDYID", "Study Identifier", "character", 20, "From AE.STUDYID", "pharmaversesdtm::ae",
  "adae", "USUBJID", "Unique Subject Identifier", "character", 40, "From AE.USUBJID", "pharmaversesdtm::ae",
  "adae", "AESEQ", "Sequence Number", "numeric", 8, "From AE.AESEQ", "pharmaversesdtm::ae",
  "adae", "AETERM", "Reported Term for the Adverse Event", "character", 200, "From AE.AETERM", "pharmaversesdtm::ae",
  "adae", "AESTDTC", "Start Date/Time of Adverse Event", "character", 20, "From AE.AESTDTC", "pharmaversesdtm::ae",
  "adae", "AEENDTC", "End Date/Time of Adverse Event", "character", 20, "From AE.AEENDTC", "pharmaversesdtm::ae",
  "adae", "AESEV", "Severity/Intensity", "character", 20, "From AE.AESEV", "pharmaversesdtm::ae",
  "adae", "AESER", "Serious Event", "character", 1, "From AE.AESER", "pharmaversesdtm::ae",
  "adae", "TRTEMFL", "Treatment Emergent Analysis Flag", "character", 1, "AESTDT >= TRTSDT", "Derived",

  # ADVS - Vital Signs Analysis Dataset
  "advs", "STUDYID", "Study Identifier", "character", 20, "From VS.STUDYID", "pharmaversesdtm::vs",
  "advs", "USUBJID", "Unique Subject Identifier", "character", 40, "From VS.USUBJID", "pharmaversesdtm::vs",
  "advs", "VSSEQ", "Sequence Number", "numeric", 8, "From VS.VSSEQ", "pharmaversesdtm::vs",
  "advs", "VSTESTCD", "Vital Signs Test Short Name", "character", 8, "From VS.VSTESTCD", "pharmaversesdtm::vs",
  "advs", "VSTEST", "Vital Signs Test Name", "character", 40, "From VS.VSTEST", "pharmaversesdtm::vs",
  "advs", "VSORRES", "Result or Finding in Original Units", "character", 20, "From VS.VSORRES", "pharmaversesdtm::vs",
  "advs", "VSORRESU", "Original Units", "character", 20, "From VS.VSORRESU", "pharmaversesdtm::vs",
  "advs", "VSSTRESN", "Numeric Result/Finding in Standard Units", "numeric", 8, "From VS.VSSTRESN", "pharmaversesdtm::vs",
  "advs", "VSSTRESU", "Standard Units", "character", 20, "From VS.VSSTRESU", "pharmaversesdtm::vs",
  "advs", "VISITNUM", "Visit Number", "numeric", 8, "From VS.VISITNUM", "pharmaversesdtm::vs",
  "advs", "VISIT", "Visit Name", "character", 40, "From VS.VISIT", "pharmaversesdtm::vs",
  "advs", "CHG", "Change from Baseline", "numeric", 8, "AVAL - BASE", "Derived",

  # ADLB - Laboratory Analysis Dataset
  "adlb", "STUDYID", "Study Identifier", "character", 20, "From LB.STUDYID", "pharmaversesdtm::lb",
  "adlb", "USUBJID", "Unique Subject Identifier", "character", 40, "From LB.USUBJID", "pharmaversesdtm::lb",
  "adlb", "LBSEQ", "Sequence Number", "numeric", 8, "From LB.LBSEQ", "pharmaversesdtm::lb",
  "adlb", "LBTESTCD", "Lab Test Short Name", "character", 8, "From LB.LBTESTCD", "pharmaversesdtm::lb",
  "adlb", "LBTEST", "Lab Test Name", "character", 40, "From LB.LBTEST", "pharmaversesdtm::lb",
  "adlb", "LBORRES", "Result or Finding in Original Units", "character", 20, "From LB.LBORRES", "pharmaversesdtm::lb",
  "adlb", "LBORRESU", "Original Units", "character", 20, "From LB.LBORRESU", "pharmaversesdtm::lb",
  "adlb", "LBSTRESN", "Numeric Result in Standard Units", "numeric", 8, "From LB.LBSTRESN", "pharmaversesdtm::lb",
  "adlb", "LBSTRESU", "Standard Units", "character", 20, "From LB.LBSTRESU", "pharmaversesdtm::lb",
  "adlb", "VISITNUM", "Visit Number", "numeric", 8, "From LB.VISITNUM", "pharmaversesdtm::lb",
  "adlb", "VISIT", "Visit Name", "character", 40, "From LB.VISIT", "pharmaversesdtm::lb",
  "adlb", "CHG", "Change from Baseline", "numeric", 8, "AVAL - BASE", "Derived"
)

# Create Excel workbook
wb <- createWorkbook()

# Add worksheet
addWorksheet(wb, "ADaM_Specifications")

# Write data
writeData(wb, sheet = "ADaM_Specifications", x = adam_metadata)

# Style header row
headerStyle <- createStyle(
  fontSize = 12,
  fontColour = "white",
  halign = "center",
  fgFill = "#4F81BD",
  border = "TopBottomLeftRight",
  textDecoration = "bold"
)

addStyle(wb, sheet = "ADaM_Specifications", headerStyle, rows = 1, cols = 1:7, gridExpand = TRUE)

# Set column widths
setColWidths(wb, sheet = "ADaM_Specifications", cols = 1:7, widths = c(12, 15, 40, 12, 8, 30, 25))

# Save the file
output_file <- "../inst/extdata/adams-specs.xlsx"
saveWorkbook(wb, output_file, overwrite = TRUE)

cat(sprintf("✓ Created metadata file: %s\n", output_file))
cat(sprintf("✓ Defined %d variables across %d datasets\n",
            nrow(adam_metadata),
            length(unique(adam_metadata$dataset_name))))
cat("\nDatasets included:\n")
for (ds in unique(adam_metadata$dataset_name)) {
  n_vars <- sum(adam_metadata$dataset_name == ds)
  cat(sprintf("  - %s: %d variables\n", toupper(ds), n_vars))
}
