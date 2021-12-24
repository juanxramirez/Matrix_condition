# Matrix_condition
.. image:: https://zenodo.org/badge/394084139.svg
   :target: https://zenodo.org/badge/latestdoi/394084139
# Index
- [Overview](#Overview)
- [System requirements](#System-requirements)
- [Data](#Data)
- [1. Historical_assessments_Red_List_IUCN_categories.R](#1-historical_assessments_red_list_iucn_categoriesr) 
- [2. Retrospective_adjustments_and_genuine_changes.py](#2-retrospective_adjustments_and_genuine_changespy)
- [3. Classifying_extinction_risk_transitions.py](#3-classifying_extinction_risk_transitionspy)
- [4. High_HFP_extent_suitable_unsuitable.py](#4-high_hfp_extent_suitable_unsuitablepy)
- [5. RF_high_medium_first_last.R](#5-rf_high_medium_first_lastr)
- [6. RF_quality_matrix.R](#6-rf_quality_matrixr)
- [7. Wilcox_test_and_cohens_d_quality_matrix.R](#7-wilcox_test_and_cohens_d_quality_matrixr)
- [Extract_IUCN_categories.py](#extract_iucn_categoriespy)
- [Transition_matrix_of_extinction_risk_categories.R](#transition_matrix_of_extinction_risk_categoriesr)
- [High_HFP_extent_medium_unsuitable_combined.py](#high_hfp_extent_medium_unsuitable_combinedpy)
- [RF_medium_unsuitable_first_last.R](#rf_medium_unsuitable_first_lastr)
- [Sensitivity_testing_importance_plots.R](#sensitivity_testing_importance_plotsr)
- [Distribution_matrix_condition.R](#distribution_matrix_conditionr)

# Overview
The Matrix_condition repository includes `R` code, `Python` code, and data to reproduce the analyses shown in the article:

**Matrix condition mediates the effects of habitat fragmentation on species extinction risk**

_by J.P. Ramírez-Delgado, M. Di Marco, J.E.M. Watson, C.J. Johnson, C. Rondinini, X. Corredor Llano, M. Arias, and O. Venter_

In this article, we quantify the relationship between changes in the extinction risk of 4,426 terrestrial mammals over a 24-year period (1996-2020), the fragmentation of their suitable habitat (in terms of the degree of fragmentation and the degree of patch isolation), and the levels of human pressure within the associated habitat matrix (i.e. the  condition of the matrix). In Fig. 1, we show how we classified extinction risk transitions based on past and present IUCN Red List categories. In Fig. 2, we show the relative importance of selected variables for the prediction of extinction risk transitions in terrestrial mammals. In Fig. 3, we show the effect of the degree of fragmentaiton, the degree of patch isolation, and the matrix condition on extinction risk transitions in terrestrial mammals. Finally, we show the influence of low-quality matrices and high-quality matrices on the relative importance of selected predictors of extinction risk transitions in terrestrial mammals (Fig. 4).

Each script loads necessary packages and sets up path and working directories. This set up needs to be adjusted for specific users and `R` or `Python` sessions. 

Scripts from 1 to 7 can be used to reproduce the figures shown in the main manuscript. 
Other scripts can be used to reproduce the figures shown in the supplementary information of the article.

Input data are available within each folder of this repository, with the exception of the habitat suitability models, which were derived from another study and are available only upon request (see https://globalmammal.org/habitat-suitability-models-for-terrestrial-mammals/).

# System requirements 

## Hardware requirements 
The code presented here requires only a standard computer with enough RAM to support the in-memory operations. 

We have tested our code using a desktop PC with 3.6 GHz CPU and 16 GB of RAM.

## Software requirements
### OS Requirements

Our code is supported for _Windows_ and has been tested on the following system:

- Windows 10 Enterprise version 20H2

Users should have `R` version 4.1.0 or higher to run `R` scripts (.R), and `Python` version 3.7.10 or higher to run `Python` scripts (.py) 

The scripts `4. High_HFP_extent_suitable_unsuitable.py` and `High_HFP_extent_medium_unsuitable_combined.py` require `ArcGIS Pro` version 2.8.2 or higher, and the `Spatial Analyst` license to run.

`R` scripts have been tested on `RStudio` version 1.4.1717, and `Python` scripts on `Spyder` version 4.1.5.

# Data
There are 8 data files in the data folder:

`list_of_species_with_habitat_suitabilty_defined.txt`: This file contains the species' taxon ID of those species with a defined level of habitat suitability.

`list_sp_with_genuine_changes.xlsx`: This file contains the list of species that showed a genuine change in their IUCN Red List category between 1996 and 2000.

`hfp2000_merisINT_3_or_above.tif`: Spatially explicit layer with the areas of high human pressure levels (i.e. human footprint values of 3 or above) for the year 2000. 

`hfp2013_merisINT_3_or_above.tif`: Spatially explicit layer with the areas of high human pressure levels (i.e. human footprint values of 3 or above) for the year 2013.

`WorldMollweide.prj`: This file cotains the Spatial Reference used in our spatial analyses.

`data_high_medium_first_last.txt`: This file contains the data used to run our models of extinction risk when the extent of suitable habitat is represented by high and medium habitat suitability combined, and the extent of the matrix by unsuitable habitat alone.

`first_last.txt`: This file contains the data required to show the transition matrix of the first and last Red List category reported between 1996 and 2020 (Supplementary Fig. 1).

`data_medium_unsuitable_first_last.txt`: This file contains the data used to run our models of extinction risk twhen the extent of suitable habitat is represented by high habitat suitability, and the extent of the matrix by medium habitat suitability and unsuitable habitat combined. 

# 1. Historical_assessments_Red_List_IUCN_categories.R
Creates a table with the IUCN Red List categories over time. Requires `list_of_species_with_habitat_suitabilty_defined.txt` as input data. Line 23-28 can take anywhere from 30 min to 1 hour to finish, depending on the processor speed of the user.

# 2. Retrospective_adjustments_and_genuine_changes.py
Creates a table showing IUCN Red List categories over time based on retrospective adjustments and genuine changes. Requires `historical_assessments.xlsx` (output from `1. Historical_assessments_Red_List_IUCN_categories.R`) and `list_sp_with_genuine_changes.xlsx` as input data.

# 3. Classifying_extinction_risk_transitions.py
Creates a table with the transitions of exitnciton risk for each species based on retrospective adjustments and genuine changes in the IUCN Red List categories over time. Requires `transposed_and_filtered_with_genuine_changes.xlsx` (output from `2. Transpose_and_filter_historical_assessments_with_genuine_changes.py`) as input data. Note that the number of species facing a low-risk transition and those facing a high-risk transition were obtained from here. This was included in the Fig. 1 of the article.

# 4. High_HFP_extent_suitable_unsuitable.py
Runs the spatial analyses for the quantification of the following variables: (i) the degree of habitat fragmentation; (ii) the degree of patch isolation; (iii) the extent of high human footprint values within the matrix; (iv) the extent of high human footprint values within suitable habitat; (v) the change in the extent of high human footprint values within the matrix over time (between 2000 and 2013); (vi) the change in the extent of high human footprint values within suitable habitat over time (between 2000 and 2013); and (vii) the proportion of suitable habitat. This is when the extent of suitable habitat is represented by high and medium habitat suitability combined, and the extent of the matrix by unsuitable habitat alone. Requieres habitat suitabilty models (available only upon request; https://globalmammal.org/habitat-suitability-models-for-terrestrial-mammals/), `hfp2000_merisINT_3_or_above.tif`, `hfp2013_merisINT_3_or_above.tif`, and `WorldMollweide.prj` as input data. 

# 5. RF_high_medium_first_last.R
Runs a random forest model for the prediction of extinction risk transtions in terrestrial mammals when the extent of suitable habitat is represented by high and medium habitat suitability combined, and the extent of the matrix by unsuitable habitat alone. Here, we show the relative importance of selected variables for the prediction of extinction risk transitions in terestrial mammals  (Fig. 2), as well as the effect of the degree of habitat fragmentation, the degree of patch isolation, and the matrix condition on the probability of extinction risk transitions in terrestrial mammals (Fig. 3). Requires `data_high_medium_first_last.txt` as input data. Line 84 can take anywhere from 3 to 6 hours to finish, depending on the processor speed of the user.

# 6. RF_quality_matrix.R
Runs random forest models to predict extinction risk transitions for both species with a low-quality matrix and species with a high-quality matrix. Here, we show the relative variable importance in predicting extinction risk transitions for species with a low-quility matrix (Fig. 4a) and for species with a high-quality matrix (Fig. 4b). Requires `data_high_medium_first_last.txt` as input data. Line 98 can take anywhere from 1 to 2 hours to finish, depending on the processor speed of the user. Line 104 can take anywhere from 20 min to 1 hour to finish, depending on the processor speed of the user.

# 7. Wilcox_test_and_cohens_d_quality_matrix.R
Runs the Wilcoxon rank sum tests used to test for statistical differences in the degree of fragmentation and the degree of patch isolation between low-risk and high-risk species with a low-quality matrix and a high-quality matrix. It also calculates effect sizes (based on Cohen's d statistic) to determine the effect size of the degree of fragmentation and the degree of patch isolation between low-risk and high-risk species with a low-quality matrix and a high-quality matrix (Supplementary Fig. 5). Requires `data_high_medium_first_last.txt' as input data.

# Extract_IUCN_categories.py
Extracts the first and last IUCN Red List category for each species and creates a table with these categories from an existing table. Requires `transposed_and_filtered_with_genuine_changes.xlsx` (output from `2. Transpose_and_filter_historical_assessments_with_genuine_changes.py`) as input data.

# Transition_matrix_of_extinction_risk_categories.R
Shows the transition matrix of the first and last Red List category reported between 1996 and 2020 (Supplementary Fig. 1). Requires `first_last.txt` as input data (derived from the output of `Extract_IUCN_categories.py`).

# High_HFP_extent_medium_unsuitable_combined.py
Runs the spatial analyses for the quantification of the following varaibles: (i) the degree of habitat fragmentation; (ii) the degree of patch isolation; (iii) the extent of high human footprint values within the matrix; (iv) the extent of high human footprint values within high habitat suitability; (v) the change in the extent of high human footprint values within the matrix over time (between 2000 and 2013); (vi) the change in the extent of high human footprint values within high habitat suitability over time (between 2000 and 2013); and (vii) the proportion of high habitat suitability. This is when the extent of suitable habitat is represented by high habitat suitability, and the extent of the matrix by medium habitat suitability and unsuitable habitat combined. Requieres habitat suitabilty models (available only upon request; https://globalmammal.org/habitat-suitability-models-for-terrestrial-mammals/), `hfp2000_merisINT_3_or_above.tif`, `hfp2013_merisINT_3_or_above.tif`, and `WorldMollweide.prj` as input data. 

# RF_medium_unsuitable_first_last.R
Runs a random forest model for the prediction of extinction risk transtions in terrestrial mammals when the extent of suitable habitat is represented by high habitat suitability, and the extent of the matrix by medium habitat suitability and unsuitable habitat combined. Requires `data_medium_unsuitable_first_last.txt` as input data. Line 78 can take anywhere from 3 to 6 hours to finish, depending on the processor speed of the user.

# Sensitivity_testing_importance_plots.R
Shows the relative importance of selected variables for the prediction of extinction risk transitions in terrestrial mammals when the extent of suitable habitat is represented by high and medium suitability combined, and the extent of the matrix by unsuitable habitat alone (Supplementary Fig. 2a). It also shows the relative importance of selected variables for the prediction of extinction risk transitions in terrestrial mammals when the extent of suitable habitat is represented by high habitat suitability, and the extent of the matrix by medium habitat suitability and unsuitable habitat combined (Supplementary Fig. 2b). Requires `Relative_importance_scores_high_medium_first_last.csv` (output from  5. `RF_high_medium_first_last.R`) and `Relative_importance_scores_medium_unsuitable_first_last.csv` (output from `11. RF_medium_unsuitable_first_last.R`).

# Distribution_matrix_condition.R
Shows the distribution of the matrix condition in low-risk and high-risk species both globally (Supplementary Fig. 4) and at the scale of individual biogeopraphic realms (Supplementary Fig. 5). Requires `data_high_medium_first_last.txt` as input data.
