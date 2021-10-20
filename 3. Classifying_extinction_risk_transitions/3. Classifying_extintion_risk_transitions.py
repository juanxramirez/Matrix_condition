#conda install pip

#pip install pandas 

#pip install  xlrd

#pip install openpyxl

# python 3.9
# import xlrd
# xlrd.xlsx.ensure_elementtree_imported(False, None)
# xlrd.xlsx.Element_has_iter = True

import pandas as pd

df = pd.read_excel("transposed_and_filtered_with_genuine_changes.xlsx")
print(df.index)

classification = {
    1: {
        "LC": "One-category",
        "NT": "One-category",
        "VU": "One-category",
        "EN": "One-category",
        "CR": "One-category",
    },
    2: {
         "LC-LC": "Low-risk",
         "LC-NT": "High-risk",
         "LC-VU": "High-risk",
         "LC-EN": "High-risk",
         "LC-CR": "High-risk",
         "NT-LC": "Low-risk",
         "NT-NT": "High-risk",
         "NT-VU": "High-risk",
         "NT-EN": "High-risk",
         "NT-CR": "High-risk",
         "VU-LC": "Low-risk",
         "VU-NT": "Low-risk",
         "VU-VU": "High-risk",
         "VU-EN": "High-risk",
         "VU-CR": "High-risk",
         "EN-LC": "Low-risk",
         "EN-NT": "Low-risk",
         "EN-VU": "Low-risk",
         "EN-EN": "High-risk",
         "EN-CR": "High-risk",
         "CR-LC": "Low-risk",
         "CR-NT": "Low-risk",
         "CR-VU": "Low-risk",
         "CR-EN": "Low-risk",
         "CR-CR": "High-risk",
    }
}


def classify(class_type, species_chain):
    if class_type == "first_last":
        if len(species_chain) == 1:
            chain = species_chain[0]
            return classification[1][chain]
        else:
            chain = "{}-{}".format(species_chain[0], species_chain[-1])
            return classification[2][chain]
        

    if class_type == "last_two":
        if len(species_chain) == 1:
            chain = species_chain[0]
            return classification[1][chain]
        else:
            chain = "{}-{}".format(species_chain[-2], species_chain[-1])
            return classification[2][chain]


d_out = {"taxon_id": [], "classif": []}
for index, row in df.iterrows():
    print(row["taxon_id"])
    d_out["taxon_id"].append(row["taxon_id"])
    d_sp = row.loc[[1996,2000,2002,2003,2004,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020]]
    d_sp = list(d_sp[d_sp.notna()])
    if len(d_sp) < 2:
        d_out["classif"].append("No_trend")
        continue
    #d_sp = [d_sp[0], d_sp[-1]]   
    print(d_sp)
    print(len(d_sp))
                               
    if len(d_sp) == 0:
        d_out["classif"].append("No_class")
    else:
        #Classification routines:
        d_out["classif"].append(classify("first_last", d_sp))
        #d_out["classif"].append(classify("last_two", d_sp))

    if len(d_out["taxon_id"]) != len(d_out["classif"]):
        print("\nERROR: the specie {} missing classification: {}".format(row["taxon_id"], d_sp))
        break

if len(d_out["taxon_id"]) == len(d_out["classif"]):
    out = pd.DataFrame(d_out)
    out.to_excel("transitions_first_last_category.xlsx")

