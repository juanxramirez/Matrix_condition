# Matrix_condition

# Overview

Here, we quantify the relationship between changes in the extinction risk of 4,426 terrestrial mammals over a 24-year period (1996-2020), the fragmentation of their suitable habitat (in terms of the degree of fragmentation and the degree of patch isolation), and the levels of human pressure within the associated habitat matrix (matrix condition). In Fig. 1, we show the classification of extinction risk transitions based on past and present IUCN Red List categories in terrestrial mammals between 1996 and 2020. In Fig. 2, we show the relative importance of selected variables for the prediction of extinction risk transitions in terrestrial mammals, including the degree of fragmentation, the degree of patch isolation and the matrix condition. In Fig. 3, we show the effect of the degree of habitat fragmentaiton, the degree of patch isolation and the matrix condition on extinction risk transitions in terrestrial mammals. Finally, we show the influence of the matrix condition on the relative importance of the degree of fragmentation and the degree of patch isolation for the prediction of extinction risk in terrestrial mammals, including other predictors of extinction risk, in Fig. 4.

#1. Historical_assessments_Red_List_IUCN_categories.R
Table showing IUCN Red List categories over time. Requires list_of_species_with_habitat_suitabilty_defined.txt as input data.

#2. Transpose_and_filter_historical_assessments_with_genuine_changes.py
Table showing IUCN Red List categories over time based on retrospective adjustments and genuine changes. Requires historical_assessemtents.xlsx and list_sp_with_genuine_changes.xlsx as input data.

#3. Classify_extinction_risk_transitions.py
Table showing extinction risk transitions based on retrospective adjustments and genuine changes in the IUCN Red List categories over time. Requires transposed_and_filtered_with_genuine_changes.xlsx as input data. 

#4. High_HFP_extent_suitable.py
For quantifying variables derived from spatial analyses. Requieres habitat suitabilty models, hfp2000_merisINT_3_or_above.tif, hfp2013_merisINT_3_or_above.tif, and WorldMollweide.prj as input data. 

#5. RF_high_medium_first_last.R
Random forest model for the prediction of extinction risk transtions in terrestrial mammals. Here we show relative variable importance (Fig. 2), and partial dependence plots (Fig. 3). Requires data_high_medium_first_last.txt as input data.

#6. RF_quality_matrix
Separate random forest models for the prediction of extinction risk transitions for species with low-quality matrices and high-quality matrices. Here, we show relative variable importance for species with low-quality matrices (Fig. 4a) and high-quality matrices (Fig. 4b).
