#conda install pandas 
#pip install pandas 
#pip install  xlrd
#pip install openpyxl

import pandas as pd

df = pd.read_excel("historical_assessments.xlsx")
groups_sp_name = df.groupby("sp_name")
groups_years = df.groupby("year")

data = {"sp_name": []}
years = list(groups_years.groups)

for group, group_item in groups_sp_name:
    data["sp_name"].append(group)
    for year in years:
        if not year in data:
            data[year] = []
        for row in group_item.itertuples():
            if year == row.year:
                data[year].append(row.code)
                break
        if year not in list(group_item.year):
            data[year].append("")

transposed_df = pd.DataFrame(data)

years = [1996,2000,2002,2003,2004,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020]

sp_filtered = {}
# filtering
for index, row in transposed_df.iterrows():
    row_years = row.loc[years]

    row_clean = [x for x in list(row_years[row_years.notna()]) if x]

    no_pass_filter_1 = False
    if "DD" in row_clean[-1] or "EX" in row_clean[-1] or "EW" in row_clean[-1]:
        if row['sp_name'] == 4311:
            print(row_clean)
        class_diff = [x for x in row_clean if x not in ["DD", "EX", "EW"]]
        if len(class_diff) <= 1:
            # pass filter 1, continue
            no_pass_filter_1 = True

    if row['sp_name'] == 4311:
        print(no_pass_filter_1)

    if no_pass_filter_1:
        continue
    
    # pass filter 1, continue
    # filter 2: delete "DD", "EX", "EW" -> empty space
    row_f2 = ["" if x in ["DD", "EX", "EW"] else x for x in row_years]
    # filter 3: replace LR/* items
    row_f3 = [x.replace("LR/lc", "LC").replace("LR/nt", "NT").replace("LR/cd", "NT") for x in row_f2]
    # filter 4: fill empty years    
    unique = [x for x in row_f3 if x][-1]
    row_f4 = [unique if x else "" for x in row_f3]
    
    sp_filtered[row['sp_name']] = row_f4

df_genuine = pd.read_excel("list_sp_with_genuine_changes.xlsx")

sp_filtered_gen = {}
for sp_index, row in sp_filtered.items():
    if sp_index in df_genuine.taxon_id.values:
        gen_row = df_genuine.loc[df_genuine['taxon_id'] == sp_index].filter(items=years).fillna("").values.tolist()[0]
        sp_filtered_gen[sp_index] = gen_row
    else:
        sp_filtered_gen[sp_index] = row
    
df_to_save = pd.DataFrame.from_dict(sp_filtered_gen, orient='index', columns=years)
df_to_save.index.name = 'taxon_id'

df_to_save.to_excel("transposed_and_filtered_with_genuine_changes.xlsx")
