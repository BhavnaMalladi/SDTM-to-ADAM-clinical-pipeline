# Installation script for SDTM to ADaM pipeline
# This script installs all necessary pharmaverse and supporting packages

cat("========================================\n")
cat("Installing Pharmaverse Packages\n")
cat("========================================\n\n")

# List of packages to install
packages <- c(
  # Core pharmaverse packages
  "admiral",
  "pharmaversesdtm",
  "pharmaverseadam",

  # Admiral extensions for different therapeutic areas
  "admiralonco",
  "admiralophtha",
  "admiralvaccine",

  # Data manipulation and utilities
  "dplyr",
  "tidyr",
  "lubridate",
  "stringr",
  "purrr",

  # Metadata and validation
  "metacore",
  "metatools",
  "xportr",

  # For Excel file handling
  "readxl",
  "writexl",
  "openxlsx",

  # JSON handling
  "jsonlite"
)

# Function to install packages if not already installed
install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat(sprintf("Installing %s...\n", pkg))
    install.packages(pkg, dependencies = TRUE, repos = "https://cloud.r-project.org/")
  } else {
    cat(sprintf("%s is already installed.\n", pkg))
  }
}

# Install all packages
for (pkg in packages) {
  tryCatch({
    install_if_missing(pkg)
  }, error = function(e) {
    cat(sprintf("ERROR installing %s: %s\n", pkg, e$message))
  })
}

cat("\n========================================\n")
cat("Installation Complete!\n")
cat("========================================\n")

# Test loading key packages
cat("\nTesting package loading...\n")
test_packages <- c("admiral", "pharmaversesdtm", "dplyr")

for (pkg in test_packages) {
  if (require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat(sprintf("✓ %s loaded successfully\n", pkg))
  } else {
    cat(sprintf("✗ %s failed to load\n", pkg))
  }
}

cat("\nReady to build SDTM → ADaM pipeline!\n")
