# Matrix_condition

## Index
- [Overview](#Overview)
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

## Overview
Here, we quantify the relationship between changes in the extinction risk of 4,426 terrestrial mammals over a 24-year period (1996-2020), the fragmentation of their suitable habitat (in terms of the degree of fragmentation and the degree of patch isolation), and the levels of human pressure within the associated habitat matrix (i.e. the matrix condition). In Fig. 1, we show how we classified extinction risk transitions based on past and present IUCN Red List categories. In Fig. 2, we show the relative importance of selected variables for the prediction of extinction risk transitions in terrestrial mammals, including the degree of fragmentation, the degree of patch isolation, and the matrix condition. In Fig. 3, we show the effect of the degree of fragmentaiton, the degree of patch isolation, and the matrix condition on extinction risk transitions in terrestrial mammals. Finally, we show the influence of low-quality matrices and high-quality matrices on the relative importance of selected predictors of extinction risk transitions in terrestrial mammals (Fig. 4), including the predictors associated with fragmentation (i.e. the degree of fragemtantion and the degree of patch isolation).

## 1. Historical_assessments_Red_List_IUCN_categories.R
Creates a table with the IUCN Red List categories over time. Requires list_of_species_with_habitat_suitabilty_defined.txt as input data. 

## 2. Retrospective_adjustments_and_genuine_changes.py
Creates a table that shows IUCN Red List categories over time based on retrospective adjustments and genuine changes. Requires historical_assessments.xlsx (output from 1. Historical_assessments_Red_List_IUCN_categories.R) and list_sp_with_genuine_changes.xlsx as input data.

## 3. Classifying_extinction_risk_transitions.py
Creates a table with the transitions of exitnciton risk for each species based on retrospective adjustments and genuine changes in the IUCN Red List categories over time. Requires transposed_and_filtered_with_genuine_changes.xlsx (output from 2. Transpose_and_filter_historical_assessments_with_genuine_changes.py) as input data. Note: The number of species facing a low-risk transition and those facing a high-risk transition were obtained from here and used to create the Fig. 1 of the main manuscript.

## 4. High_HFP_extent_suitable_unsuitable.py
Runs the spatial analyses for the quantification of variables (i.e. the degree of fragmentation, the degree of patch isolation, the extent of high human footprint values within the matrix, the extent of high human footprint values within suitable habitat, the change in the extent of high human footprint values within the matrix, the change in the extent of high human footprint values within suitable habitat, and the proportion of suitable habitat) when the extent of suitable habitat is represented by high and medium habitat suitability combined and the extent of the matrix by 'unsuitable' habitat alone. Requieres habitat suitabilty models (available only upon request; https://globalmammal.org/habitat-suitability-models-for-terrestrial-mammals/), hfp2000_merisINT_3_or_above.tif, hfp2013_merisINT_3_or_above.tif, and WorldMollweide.prj as input data. 

## 5. RF_high_medium_first_last.R
Runs a random forest model for the prediction of extinction risk transtions in terrestrial mammals when the extent of suitable habitat is represented by high and medium habitat suitability combined and the extent of the matrix by 'unsuitable' habitat alone. Here, we show the relative variable importance of predictors (Fig. 2). We also show the effect of the degree of habitat fragmentation, the degree of patch isolation, and the matrix condition on the predictive probability of extinction risk transitions in terrestrial mammals (Fig. 3). Requires data_high_medium_first_last.txt as input data.

## 6. RF_quality_matrix.R
Runs separate random forest models for the prediction of extinction risk transitions for species with low-quality matrices and high-quality matrices. Here, we show the relative variable importance in the model for species with low-quility matrices (Fig. 4a) and in the model for species with high-quality matrices (Fig. 4b). Requires data_high_medium_first_last.txt as input data. 

## 7. Wilcox_test_and_cohens_d_quality_matrix.R
Runs the Wilcoxon rank sum tests to test for statistical differences in the degree of fragmentation and the degree of patch isolation between low-risk and high-risk species with low-quality matrices and high-quality matrices, and calculates effect sizes (based on Cohen's d statistic) to determine the effect size of the degree of fragmentation and the degree of patch isolation between low-risk and high-risk species with low-quality matrices and high-quality matrices (Supplementary Fig. 5). Requires data_high_medium_first_last.txt as input data.

## Extract_IUCN_categories.py
Extracts IUCN categories from a table. Requires transposed_and_filtered_with_genuine_changes.xlsx (output from 2. Transpose_and_filter_historical_assessments_with_genuine_changes.py) as input data.

## Transition_matrix_of_extinction_risk_categories.R
Creates a figure to show the transition matrix of the first and last Red List category reported between 1996 and 2020 (Supplementary Fig. 1). Requires first_last.txt as input data.

## High_HFP_extent_medium_unsuitable_combined.py
Runs the spatial analyses for the quantification of variables (i.e. the degree of fragmentation, the degree of patch isolation, the extent of high human footprint values within the matrix, the extent of high human footprint values within high habitat suitability, the change in the extent of high human footprint values within the matrix, the change in the extent of high human footprint values within high habitat suitability, and the proportion of high habitat suitability) when the extent of suitable habitat is represented by high habitat suitability and the extent of the matrix by medium habitat suitability and 'unsuitable' habitat combined. Requieres habitat suitabilty models (available only upon request; https://globalmammal.org/habitat-suitability-models-for-terrestrial-mammals/), hfp2000_merisINT_3_or_above.tif, hfp2013_merisINT_3_or_above.tif, and WorldMollweide.prj as input data. 

## RF_medium_unsuitable_first_last.R
Runs a random forest model for the prediction of extinction risk transtions in terrestrial mammals when the extent of suitable habitat is represented by high habitat suitability and the extent of the matrix by medium habitat suitability and 'unsuitable' habitat combined. Requires data_medium_unsuitable_first_last.txt as input data.

## Sensitivity_testing_importance_plots.R
Creates a figure to show the relative importance of selected variables for the prediction of extinction risk transitions in terrestrial mammals when the extent of suitable habitat is represented by high and medium suitability combined and the extent of the matrix by 'unsuitable' habitat alone (Supplementary Fig. 2a), and when the extent of suitable habitat is represented by high habitat suitability and the extent of the matrix by medium habitat suitability and 'unsuitable' habitat combined (Supplementary Fig. 2b). Requires Relative_importance_scores_high_medium_first_last.csv (output from  5. RF_high_medium_first_last.R) and Relative_importance_scores_medium_unsuitable_first_last.csv (output from 11. RF_medium_unsuitable_first_last.R).

## Distribution_matrix_condition.R
Creates two figures to show the distribution of the matrix condition in low-risk and high-risk species both globally (Supplementary Fig. 4) and at the scale of individual biogeopraphic realms (Supplementary Fig. 5). Requires data_high_medium_first_last.txt as input data.
