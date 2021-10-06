import pandas as pd

df = pd.read_excel("transposed_and_filtered_with_genuine_changes.xlsx")
print(df.index)

d_out = {"taxon_id": [], "first": [], "last": []}
for index, row in df.iterrows():
    #print(row["taxon_id"])
    d_out["taxon_id"].append(row["taxon_id"])
    d_sp = row.loc[[1996,2000,2002,2003,2004,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020]]
    d_sp = list(d_sp[d_sp.notna()])
    if len(d_sp) < 2:
        d_out["first"].append("")
        d_out["last"].append("")
        continue    
    d_out["first"].append(d_sp[0]) # First assessment
    #d_out["first"].append(d_sp[-2]) # Second to last assessment
    d_out["last"].append(d_sp[-1]) # Last assessment
    #print(d_sp)
    
out = pd.DataFrame(d_out)
out.to_excel("first_last_assessments.xlsx")
