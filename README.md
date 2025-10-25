# SDTM to ADaM Clinical Data Pipeline

An automated, CDISC-compliant pipeline for transforming SDTM (Study Data Tabulation Model) datasets into ADaM (Analysis Data Model) datasets using the Pharmaverse ecosystem.

## Overview

This repository implements an end-to-end clinical data transformation pipeline that:
- Ingests SDTM standardized clinical trial data
- Applies metadata-driven derivations to create ADaM datasets
- Follows CDISC standards for regulatory submission (FDA/EMA)
- Uses open-source R packages from the Pharmaverse initiative

## Project Structure

```
SDTM-to-ADAM-clinical-pipeline/
├── inst/
│   └── extdata/
│       ├── adams-specs.xlsx    # Metadata defining ADaM variable specifications
│       └── adams-specs.json    # JSON version for traceability
├── data-raw/
│   ├── create_metadata.R       # Script to generate metadata template
│   └── create_adams_data.R     # Main SDTM → ADaM derivation script
├── data/
│   └── *.rda                   # Generated ADaM datasets (RData format)
├── output/
│   └── *.csv                   # Generated ADaM datasets (CSV format)
├── R/
│   └── (dataset documentation)
├── install_packages.R          # Install required R packages
└── test_pipeline.R             # Test script to verify setup
```

## Pipeline Workflow

### 1. Input: SDTM Data
Uses test SDTM datasets from `pharmaversesdtm` package:
- **DM** - Demographics
- **EX** - Exposure
- **AE** - Adverse Events
- **VS** - Vital Signs
- **LB** - Laboratory Results

### 2. Metadata Configuration
The `inst/extdata/adams-specs.xlsx` file defines:
- Dataset structure (ADSL, ADAE, ADVS, ADLB)
- Variable names, labels, and types
- Derivation logic
- Source mappings

### 3. Transformation Process
The `data-raw/create_adams_data.R` script:
1. Loads metadata from Excel
2. Loads SDTM datasets
3. Applies admiral derivation templates
4. Creates analysis-ready ADaM datasets
5. Saves output in RData and CSV formats

### 4. Output: ADaM Datasets
Generated datasets:
- **ADSL** - Subject-Level Analysis Dataset (306 subjects)
- **ADAE** - Adverse Events Analysis (1,191 events)
- **ADVS** - Vital Signs Analysis (29,643 records)
- **ADLB** - Laboratory Analysis (59,580 records)

## Installation & Setup

### Prerequisites
- R version 4.5.0 or higher
- Git

### 1. Clone Repository
```bash
git clone https://github.com/BhavnaMalladi/SDTM-to-ADAM-clinical-pipeline.git
cd SDTM-to-ADAM-clinical-pipeline
```

### 2. Install R Packages
```r
Rscript install_packages.R
```

This installs:
- `admiral`, `pharmaversesdtm`, `pharmaverseadam`
- Admiral extensions: `admiralonco`, `admiralophtha`, `admiralvaccine`
- Supporting packages: `dplyr`, `lubridate`, `metacore`, `xportr`

### 3. Test Installation
```r
Rscript test_pipeline.R
```

## Running the Pipeline

### Generate ADaM Datasets
```r
cd data-raw
Rscript create_adams_data.R
```

### Output
- **RData files**: `data/adsl.rda`, `data/adae.rda`, etc.
- **CSV files**: `output/adsl.csv`, `output/adae.csv`, etc.

### Load Generated Data in R
```r
load("data/adsl.rda")
head(adsl)
```

## Customization

### Adding New Variables
1. Edit `inst/extdata/adams-specs.xlsx`
2. Add row with:
   - `dataset_name`: Target ADaM dataset
   - `variable_name`: Variable name
   - `label`: Human-readable description
   - `type`: character/numeric/date
   - `derivation`: Formula or mapping logic
   - `source`: Source SDTM dataset

3. Re-run `data-raw/create_adams_data.R`

### Adding New Datasets
1. Update metadata in `adams-specs.xlsx`
2. Add derivation logic in `create_adams_data.R`
3. Follow admiral templates for domain-specific logic

## Technologies Used

| Component | Technology | Purpose |
|-----------|------------|---------|
| Data Standardization | CDISC SDTM/ADaM | Regulatory compliance |
| Derivation Engine | admiral (Pharmaverse) | ADaM dataset creation |
| Test Data | pharmaversesdtm | SDTM source datasets |
| Validation | metacore, xportr | CDISC compliance checks |
| Data Manipulation | dplyr, tidyr, lubridate | Data transformation |

## Key Features

- **Metadata-Driven**: All derivations defined in `adams-specs.xlsx`
- **Reproducible**: Version-controlled transformation logic
- **CDISC-Compliant**: Follows ADaM Implementation Guide
- **Extensible**: Easy to add new variables/datasets
- **Documented**: Auto-generated documentation for each dataset
- **Open Source**: Built on Pharmaverse R packages

## Next Steps

1. **Validation**: Implement xportr validation checks
2. **ADRG**: Generate Analysis Data Reviewer's Guide
3. **Define.xml**: Create metadata definition file
4. **Raw → SDTM**: Add custom raw data ingestion layer
5. **Python Integration**: Add rpy2 wrapper for Python workflows
6. **TFL Generation**: Create Tables, Figures, Listings from ADaM

## Resources

- [Pharmaverse](https://pharmaverse.org/)
- [admiral Documentation](https://pharmaverse.github.io/admiral/)
- [CDISC ADaM Standards](https://www.cdisc.org/standards/foundational/adam)
- [pharmaverseadam GitHub](https://github.com/pharmaverse/pharmaverseadam)

## License

MIT License

## Author

Bhavna Malladi
