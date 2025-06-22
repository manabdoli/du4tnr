#' Unified Data Set
#' Longitudinal data collected across the country from NIA-funded Alzheimer’s Disease Research Centers (ADRCs).
#' Explanation of variables can be found in [UDS's data dictionary](https://files.alz.washington.edu/documentation/uds3-rdd.pdf),
#' [The Neuropathology (NP) data dictionary](https://files.alz.washington.edu/documentation/rdd-np.pdf), and
#' [Genetic data dictionary](https://files.alz.washington.edu/documentation/rdd-genetic-data.pdf).
#'
#' @format
#' The dataset has 169,408 rows and 1,936 columns.
#' The common columns with other datasets are:
#' \describe{
#'   \item{NACCID}{Subject ID number}
#'   \item{NACCADC}{The Alzheimer’s Disease Center (ADC) at which subject was seen}
#'   \item{NACCAPSA}{At least one amyloid PET scan available}
#'   \item{NACCNAPA}{Total number of amyloid PET scans available}
#'   \item{NACCVNUM}{UDS visit number (order)}
#'   \item{NACCMRSA}{At least one MRI scan available}
#'   \item{NACCNMRI}{Total number of MRI sessions}
#' }
#' @source <https://files.alz.washington.edu/documentation/uds3-rdd.pdf>
"UDS"

#'  Biomarker data: CSF values for Abeta, P-tau, and T-tau.
#' Details of variable definitions can be found at
#' [Biomarker data dictionary](https://files.alz.washington.edu/documentation/biomarker-ee2-csf-ded.pdf)
#'
#' @format ## `biomarker_data`
#' The dataset has 3,021 rows and 23 columns, the columns which are common with other datasets are:
#' \describe{
#'   \item{NACCID}{Subject ID number}
#'   \item{NACCADC}{ADC at which subject was seen}
#' }
#' @source <https://naccdata.org/>
"biomarker_data"

#' MRI and Associated Volumetric Data
#' For variable definitions see Sections 1 to 3 of
#' [Imaging data dictionary](https://files.alz.washington.edu/documentation/rdd-imaging.pdf)
#'
#' @format ## `mri_data`
#' The dataset has 3,021 rows and 23 columns.
#' The following columns are common with other datasets:
#' \describe{
#'   \item{NACCID}{Subject ID number}
#'   \item{NACCADC}{ADC at which subject was seen}
#'   \item{NACCVNUM}{UDS visit number (order)}
#'   \item{NACCMRSA}{At least one MRI scan available}
#'   \item{NACCNMRI}{Total number of MRI sessions}
#' }
#' @source <https://files.alz.washington.edu/documentation/uds3-rdd.pdf>
"mri_data"


#' MRI and PET Scan Data
#' Details of variable definitions can be found at Section 4 of
#' [Imaging data dictionary](https://files.alz.washington.edu/documentation/rdd-imaging.pdf)
#'
#' @format ## `pet_data`
#' The dataset has 455 rows and 16 columns.
#' The common columns with other datasets are:
#' \describe{
#'   \item{NACCID}{Subject ID number}
#'   \item{NACCADC}{ADC at which subject was seen}
#'   \item{NACCAPSA}{At least one amyloid PET scan available}
#'   \item{NACCNAPA}{Total number of amyloid PET scans available}
#' }
#' @source <https://naccdata.org/>
"pet_data"

#' Groupings for Variables in UDS
#' This is a helper dataset that includes the `Form` value for variables listed
#' in the [UDS's data dictionary](https://files.alz.washington.edu/documentation/uds3-rdd.pdf).
#' When a value is not available, the variable is set to `No_Group`.
#' @format
#' The dataset of 1953 rows and 2 columns:
#' \describe{
#'   \item{Variables}{Name of variables in `UDS` dataset}
#'   \item{Group}{The `Form` used for collecting data, when available.}
#' }
#'
"udsGroups"

