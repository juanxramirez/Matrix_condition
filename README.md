# Matrix_condition

# Overview

Here, we quantify the relationship between changes in the extinction risk of 4,426 terrestrial mammals over a 24-year period (1996-2020), the fragmentation of their suitable habitat (in terms of the degree of fragmentation and the degree of patch isolation), and the levels of human pressure within the associated habitat matrix (matrix condition). In Fig. 1, we show how we classified extinction risk transitions based on past and present IUCN Red List categories. In Fig. 2, we show the relative importance of selected variables for the prediction of extinction risk transitions in terrestrial mammals, including the degree of fragmentation, the degree of patch isolation, and the matrix condition. In Fig. 3, we show the effect of the degree of habitat fragmentaiton, the degree of patch isolation, and the matrix condition on extinction risk transitions in terrestrial mammals. Finally, we show the influence of the matrix condition on the relative importance of selected predictors of extinction risk transitions in terrestrial mammals, including the degree of fragmentation and the degree of patch isolation (Fig. 4).

# 1. Historical_assessments_Red_List_IUCN_categories.R
Table showing IUCN Red List categories over time. Requires list_of_species_with_habitat_suitabilty_defined.txt as input data. 

# 2. Transpose_and_filter_historical_assessments_with_genuine_changes.py
Table showing IUCN Red List categories over time based on retrospective adjustments and genuine changes. Requires historical_assessemtents.xlsx (output from 1. Historical_assessents_Red_List_IUCN_categories.R) and list_sp_with_genuine_changes.xlsx as input data.

# 3. Classify_extinction_risk_transitions.py
Table showing extinction risk transitions based on retrospective adjustments and genuine changes in the IUCN Red List categories over time. Requires transposed_and_filtered_with_genuine_changes.xlsx (output from 2. Transpose_and_filter_historical_assessments_with_genuine_changes.py) as input data. 

# 4. High_HFP_extent_suitable_unsuitable.py
For quantifying variables derived from spatial analyses when the extent of suitable habitat is represented by high and medium habitat suitability combined and the extent of the matrix by 'unsuitable' habitat alone. Requieres habitat suitabilty models (available upon request; https://globalmammal.org/habitat-suitability-models-for-terrestrial-mammals/), hfp2000_merisINT_3_or_above.tif, hfp2013_merisINT_3_or_above.tif, and WorldMollweide.prj as input data. 

# 5. RF_high_medium_first_last.R
Random forest model for the prediction of extinction risk transtions in terrestrial mammals. Here we show the relative variable importance of predictors (Fig. 2) and partial dependence plots of the degree of habitat fragmentation, the degree of patch isolation, and the matrix condition (Fig. 3). Requires data_high_medium_first_last.txt as input data.

# 6. RF_quality_matrix
Separate random forest models for the prediction of extinction risk transitions for species with low-quality matrices and high-quality matrices. Here, we show the relative variable importance in the model for species with low-quility matrices (Fig. 4a) and in the model for species with high-quality matrices (fig. 4b). Requires data_high_medium_first_last.txt as input data. 

# 7. Wilcox_test_and_cohens_d_quality_matrix
Runs the Wilcoxon rank sum tests to test for statistical differences in the degree of fragmentation and the degree of patch isolation between extinction risk transitions and calculates effect sizes based Cohen's d statistics to determine the effect size of the degree of fragmentation and the degree of patch isolation between extinction risk transitions. Requires data_high_medium_first_last.txt as input data.

# 8. Extract_IUCN_categories
Extracts IUCN categories from a table. Requires transposed_and_filtered_with_genuine_changes.xlsx (output from 2. Transpose_and_filter_historical_assessments_with_genuine_changes.py) as input data.

# 9. Transitions_matrix_of_extinction_risk_categories
Figure showing the transition matrix of the first and last Red List category reported between 1996 and 2020 (Supplementary Fig. 1). Requires first_last.txt as input data.

# 10. High_HFP_extent_.py
For quantifying variables derived from spatial analyses when the extent of suitable habitat is represented by high and medium habitat suitability combined and the extent of the matrix by 'unsuitable' habitat alone. Requieres habitat suitabilty models (available upon request; https://globalmammal.org/habitat-suitability-models-for-terrestrial-mammals/), hfp2000_merisINT_3_or_above.tif, hfp2013_merisINT_3_or_above.tif, and WorldMollweide.prj as input data. 

# 11. Sensitivity_analysis_
