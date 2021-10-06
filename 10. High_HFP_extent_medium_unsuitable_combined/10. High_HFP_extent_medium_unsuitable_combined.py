import arcpy
from arcpy import env
from arcpy.sa import *
import os
import glob
arcpy.CheckOutExtension("Spatial")  
arcpy.env.overwriteOutput = True 

path_scripts = os.path.realpath('.')
path_base = os.path.dirname(path_scripts)

############# step 1: Extract data ############

env.workspace = path_scripts
# pip install py7zr # Command to install py7zr into the Python Command Prompt App. This is to extract the habitat suitability models into a folder. Otherwise, please extract them into a folder named "1.ESH_maps_extracted" manually
if not os.path.isdir("1.ESH_maps_extracted"):
    import py7zr
    os.makedirs("1.ESH_maps_extracted")
    for esh_file in glob.glob("ESH_maps/*.7z"):
        with py7zr.SevenZipFile(esh_file, mode='r') as z:
            z.extractall(path="1.ESH_maps_extracted")
    
############# step 2: Region group ############

env.workspace = path_scripts
# Path to ascii files
filepath = "1.ESH_maps_extracted" 
ascList = glob.glob(filepath + "/*.asc")  
print (ascList) 
# Path where to put rasters
outFolder = "2.Region_group"
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)

for ascFile in ascList:  
    outRaster = outFolder + "/" + os.path.split(ascFile)[1][:-3] + "tif"
    print (outRaster)
    try:
        region_group = arcpy.sa.RegionGroup(ascFile, "EIGHT", "WITHIN", "ADD_LINK", None)
        region_group.save(outRaster)
    except:
        print ("Conversion problem with file: " + ascFile)
        continue
    
############# step 3: SetNull ############

inFolder = "2.Region_group"
env.workspace = inFolder
rasterList = arcpy.ListRasters("*", "All")
rasterList.sort()
env.workspace = path_scripts
outFolder = "3.Set_null"
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)

for inRaster in rasterList:
    try:
        arcpy.CheckOutExtension("Spatial")
        outReclassify = arcpy.ia.SetNull(os.path.join(inFolder, inRaster), 1, "Count < 4")
        output = os.path.join(outFolder, inRaster)
        outReclassify.save(output)
    except:
        print ("The file does not have valid statistics as required by operation: " + inRaster)
        continue

############# step 4: Nibble ############

env.workspace = path_scripts
# Path to img files
filepath1 = "1.ESH_maps_extracted"
filepath2 = "3.Set_null"
# Path where to put rasters
outFolder = "4.Nibble"
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)

#zones to calculate stats on
inpoly1 = glob.glob(filepath1 + "/*.asc")
inpoly2 = glob.glob(filepath2 + "/*.tif")

#start loop
for k2 in inpoly2:
    filename = os.path.split(k2)[1][:-4]
    k1 = os.path.join(filepath1, filename + ".asc")
    if os.path.isfile(k1):
        print("processing ", filename)
        destination_raster =os.path.join(outFolder, filename + ".tif")
        if os.path.isfile(destination_raster):
            continue
        #print destination_raster
        pascuales = arcpy.sa.Nibble(k1, k2, "ALL_VALUES", "PRESERVE_NODATA", None)
        pascuales.save(destination_raster)

############# step 5: Reclassify - combines medium-suitablity and unusuitable habitat into a sinlge class ############

inFolder = "4.Nibble"
env.workspace = inFolder
rasterList = arcpy.ListRasters("*", "All")
rasterList.sort()
env.workspace = path_scripts
outFolder = "5.Reclassify"
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)

for inRaster in rasterList:
    try:
        reclassField = "Value"
        remap = RemapValue([[0, 0], [1, 0], [2, 2]])
        arcpy.CheckOutExtension("Spatial")
        outReclassify = Reclassify(os.path.join(inFolder, inRaster), reclassField, remap, "NODATA")
        output = os.path.join(outFolder, inRaster)
        outReclassify.save(output)
    except:
        print ("The file does not have valid statistics as required by operation: " + inRaster)
        continue
    
############# step 6: Reclassify - reclassifies the level of medium suitability and unsuitable habitat combined to no data ############

inFolder = "5.Reclassify"
env.workspace = inFolder
rasterList = arcpy.ListRasters("*", "All")
rasterList.sort()
env.workspace = path_scripts
outFolder = "6.High-suitability"
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)

for inRaster in rasterList:
    try:
        reclassField = "Value"
        remap = RemapValue([[0, "NODATA"], [2, 2]])
        arcpy.CheckOutExtension("Spatial")
        outReclassify = Reclassify(os.path.join(inFolder, inRaster), reclassField, remap, "NODATA")
        output = os.path.join(outFolder, inRaster)
        outReclassify.save(output)
    except:
        print ("The file does not have valid statistics as required by operation: " + inRaster)
        continue

############# step 7: Define projection - defines the projection of high-suitability habitat alone ############

env.workspace = path_scripts
env.workspace = "6.High-suitability"
prjfile = "World_Mollweide.prj"
rasterList = arcpy.ListRasters("*", "All")
rasterList.sort()

for raster in arcpy.ListRasters():
    print (raster)
    arcpy.DefineProjection_management(raster, prjfile)
    print ("projection defined")

############# step 8: Tabulate area - calculates the extent of high HFP values (in the year 2000) within patches of high habitat suitability ############

# Path to img files
env.workspace = path_scripts
filepath = "6.High-suitability"
# Path where to put rasters
outFolder = os.path.join("8.Tabulate_area", "high-suitability", "2000")
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)
#zones to calculate stats on
inpoly = glob.glob(filepath + "/*.tif")

#list of rasters to calculate statistics on
hfp = os.path.join(path_scripts, "hfp2000_merisINT_3_or_above.tif")
#start loop
for raster in inpoly:
    tales = os.path.split(raster)[1][:-4]
    #print tales
    destination_raster = os.path.join(outFolder, tales + ".dbf")
    #print destination_raster
    pascuales = arcpy.gp.TabulateArea(raster, "VALUE", hfp, "VALUE", destination_raster, "1000")
    field = "FILENAME"
    #expression = str(raster)   
    arcpy.AddField_management(pascuales,field,"TEXT")
    arcpy.CalculateField_management(pascuales, field, "'"+tales+"'", "PYTHON")
 
############# step 9: Merge - combines cross-tabulated areas between the extent of high HFP values (in the year 2000) and patches of high habitat suitability for each species into a single table ############

inFolder = os.path.join("8.Tabulate_area", "high-suitability", "2000")
env.workspace = inFolder
files = arcpy.ListFiles ("*.dbf")
env.workspace = path_scripts
finalFolder = "Outputs"
if not os.path.isdir(finalFolder):
    os.makedirs(finalFolder)
arcpy.Merge_management([os.path.join(inFolder, inRaster) for inRaster in files], os.path.join(finalFolder, "high_hfp_extent_high-suitability_2000.dbf"))

############# step 10: Tabulate area - calculates cross-tabulated areas between the extent of high HFP values (in the year 2013) and patches of high habitat suitability ############

# Path to img files
env.workspace = path_scripts
filepath = "6.High-suitability"
# Path where to put rasters
outFolder = os.path.join("8.Tabulate_area", "high-suitability", "2013")
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)
#zones to calculate stats on
inpoly = glob.glob(filepath + "/*.tif")

#list of rasters to calculate statistics on
hfp = os.path.join(path_scripts, "hfp2013_merisINT_3_or_above.tif")
#start loop
for raster in inpoly:
    tales = os.path.split(raster)[1][:-4]
    #print tales
    destination_raster = os.path.join(outFolder, tales + ".dbf")
    #print destination_raster
    pascuales = arcpy.gp.TabulateArea(raster, "VALUE", hfp, "VALUE", destination_raster, "1000")
    field = "FILENAME"
    #expression = str(raster)   
    arcpy.AddField_management(pascuales,field,"TEXT")
    arcpy.CalculateField_management(pascuales, field, "'"+tales+"'", "PYTHON")
 
############# step 11: Merge - combines cross-tabulated areas between the extent of high HFP values (in the year 2013) and patches of high habitat suitability for each species into a single table ############

inFolder = os.path.join("8.Tabulate_area", "high-suitability", "2013")
env.workspace = inFolder
files = arcpy.ListFiles ("*.dbf")
env.workspace = path_scripts
finalFolder = "Outputs"
if not os.path.isdir(finalFolder):
    os.makedirs(finalFolder)
arcpy.Merge_management([os.path.join(inFolder, inRaster) for inRaster in files], os.path.join(finalFolder, "high_hfp_extent_high-suitability_2013.dbf"))

############# step 12: Reclassify - reclassifies patches of high habitat suitability to no data ############

inFolder = "5.Reclassify"
env.workspace = inFolder
rasterList = arcpy.ListRasters("*", "All")
rasterList.sort()
env.workspace = path_scripts
outFolder = "7.Medium_unsuitable_combined"
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)

for inRaster in rasterList:
    try:
        reclassField = "Value"
        remap = RemapValue([[0, 0], [2, "NODATA"]])
        arcpy.CheckOutExtension("Spatial")
        outReclassify = Reclassify(os.path.join(inFolder, inRaster), reclassField, remap, "NODATA")
        output = os.path.join(outFolder, inRaster)
        outReclassify.save(output)
    except:
        print ("The file does not have valid statistics as required by operation: " + inRaster)
        continue

############# step 13: Define projection - defines the projection of medium suitability and unsuitable habitat combined ############

env.workspace = path_scripts
env.workspace = "7.Medium_unsuitable_combined"
prjfile = "World_Mollweide.prj"
rasterList = arcpy.ListRasters("*", "All")
rasterList.sort()

for raster in arcpy.ListRasters():
    print (raster)
    arcpy.DefineProjection_management(raster, prjfile)
    print ("projection defined")

############# step 14: Tabulate area - calculates cross-tabulated areas between the extent of high HFP values (in the year 2000) and the exent of medium-suitability and unsuitable habitat combined ############

# Path to img files
env.workspace = path_scripts
filepath = "7.Medium_unsuitable_combined"
# Path where to put rasters
outFolder = os.path.join("8.Tabulate_area", "medium_unsuitable", "2000")
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)
#zones to calculate stats on
inpoly = glob.glob(filepath + "/*.tif")

#list of rasters to calculate statistics on
hfp = os.path.join(path_scripts, "hfp2000_merisINT_3_or_above.tif")
#start loop
for raster in inpoly:
    tales = os.path.split(raster)[1][:-4]
    #print tales
    destination_raster = os.path.join(outFolder, tales + ".dbf")
    #print destination_raster
    pascuales = arcpy.gp.TabulateArea(raster, "VALUE", hfp, "VALUE", destination_raster, "1000")
    field = "FILENAME"
    #expression = str(raster)   
    arcpy.AddField_management(pascuales,field,"TEXT")
    arcpy.CalculateField_management(pascuales, field, "'"+tales+"'", "PYTHON")
 
############# step 15: Merge - combines cross-tabulated areas between the extent of high HFP values (in the year 2000) and the extent of medium-suitability and unsuitable habitat combined for each species into a single table ############

inFolder = os.path.join("8.Tabulate_area", "medium_unsuitable", "2000")
env.workspace = inFolder
files = arcpy.ListFiles ("*.dbf")
env.workspace = path_scripts
finalFolder = "Outputs"
if not os.path.isdir(finalFolder):
    os.makedirs(finalFolder)
arcpy.Merge_management([os.path.join(inFolder, inRaster) for inRaster in files], os.path.join(finalFolder, "high_hfp_extent_matrix_2000.dbf"))

############# step 16: Tabulate area - calculates cross-tabulated areas between the extent of high HFP values (in the year 2013) and the exent of medium-suitability and unsuitable habitat combined ############

# Path to img files
env.workspace = path_scripts
filepath = "7.Medium_unsuitable_combined"
# Path where to put rasters
outFolder = os.path.join("8.Tabulate_area", "medium_unsuitable", "2013")
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)
#zones to calculate stats on
inpoly = glob.glob(filepath + "/*.tif")

#list of rasters to calculate statistics on
hfp = os.path.join(path_scripts, "hfp2013_merisINT_3_or_above.tif")
#start loop
for raster in inpoly:
    tales = os.path.split(raster)[1][:-4]
    #print tales
    destination_raster = os.path.join(outFolder, tales + ".dbf")
    #print destination_raster
    pascuales = arcpy.gp.TabulateArea(raster, "VALUE", hfp, "VALUE", destination_raster, "1000")
    field = "FILENAME"
    #expression = str(raster)   
    arcpy.AddField_management(pascuales,field,"TEXT")
    arcpy.CalculateField_management(pascuales, field, "'"+tales+"'", "PYTHON")
 
############# step 17: Merge - combines cross-tabulated areas between the extent of high HFP values (in the year 2013) and the exent of medium-suitability and unsuitable habitat combined for each species into a single table ############

inFolder = os.path.join("8.Tabulate_area", "medium_unsuitable", "2013")
env.workspace = inFolder
files = arcpy.ListFiles ("*.dbf")
env.workspace = path_scripts
finalFolder = "Outputs"
if not os.path.isdir(finalFolder):
    os.makedirs(finalFolder)
arcpy.Merge_management([os.path.join(inFolder, inRaster) for inRaster in files], os.path.join(finalFolder, "high_hfp_extent_matrix_2013.dbf"))

############# step 18: Reclassify - reclassifies high habitat suitability to calculate the Euclidean distance within patches of high-suitability habitat ############

inFolder = "6.High-suitability"
env.workspace = inFolder
rasterList = arcpy.ListRasters("*", "All")
rasterList.sort()
env.workspace = path_scripts
outFolder = "9.High-suitability_inverted"
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)

for inRaster in rasterList:
    try:
        reclassField = "Value"
        remap = RemapValue([[2, "NODATA"], ["NODATA", 2]])
        arcpy.CheckOutExtension("Spatial")
        outReclassify = Reclassify(os.path.join(inFolder, inRaster), reclassField, remap, "NODATA")
        output = os.path.join(outFolder, inRaster)
        outReclassify.save(output)
    except:
        print ("The file does not have valid statistics as required by operation: " + inRaster)
        continue

############# step 19: Euclidean distance - calculates the Euclidean distance within patches of high-suitability habitat ############

inFolder = "9.High-suitability_inverted"
env.workspace = inFolder
rasterList = arcpy.ListRasters("*", "All")
rasterList.sort()
env.workspace = path_scripts
outFolder = "10.Euclidean_distance_high-suitability"
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)
    
for inRaster in rasterList:
    try:    
        arcpy.CheckOutExtension("Spatial")
        outReclassify = arcpy.sa.EucDistance(os.path.join(inFolder, inRaster), None, 300, None, "PLANAR", None, None)
        output = os.path.join(outFolder, inRaster)
        outReclassify.save(output)
    except:
        print ("The file does not have valid statistics as required by operation: " + inRaster)
        continue

############# step 20: Zonal statistics - calculates the mean Euclidean distance wihtin patches of high-suitability habitat ############

env.workspace = path_scripts
# Path to img files
filepath1 = "6.High-suitability" 
filepath2 = "10.Euclidean_distance_high-suitability"
# Path where to put rasters
outFolder = "11.Zonal_statistics_Euclidean_distance_high-suitability"
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)

#zones to calculate stats on
inpoly1 = glob.glob(filepath1 + "/*.tif")
inpoly2 = glob.glob(filepath2 + "/*.tif")

#start loop
for k2 in inpoly2:
    filename = os.path.split(k2)[1][:-4]
    k1 = os.path.join(filepath1, os.path.split(k2)[1])
    if os.path.isfile(k1):
        destination_raster = outFolder + "/" + filename + ".dbf"
        if os.path.isfile(destination_raster):
            continue
        #print destination_raster
        pascuales = ZonalStatisticsAsTable(k1, "VALUE", k2, destination_raster, "DATA", "MEAN")
        field = "FILENAME"
        #expression = str(raster)   
        arcpy.AddField_management(pascuales,field,"TEXT")
        arcpy.CalculateField_management(pascuales, field, "'"+filename+"'", "PYTHON")

############# step 21: Merge - combines the mean values of the Euclidean distance wihtin patches of high-suitability habitat for each species into a single table ############

inFolder = os.path.join("11.Zonal_statistics_Euclidean_distance_high-suitability")
env.workspace = inFolder
files = arcpy.ListFiles ("*.dbf")
env.workspace = path_scripts
finalFolder = "Outputs"
if not os.path.isdir(finalFolder):
    os.makedirs(finalFolder)
arcpy.Merge_management([os.path.join(inFolder, inRaster) for inRaster in files], os.path.join(finalFolder, "degree_habitat_fragmentation.dbf"))

############# step 22: Reclassify - reclassifies medium habitat suitability and unsuitable habitat combined to calculate the Euclidean distance within medium habitat suitability and unsuitable habitat combined ############

inFolder = "7.Medium_unsuitable_combined"
env.workspace = inFolder
rasterList = arcpy.ListRasters("*", "All")
rasterList.sort()
env.workspace = path_scripts
outFolder = "12.Medium_unsuitable_inverted"
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)

for inRaster in rasterList:
    try:
        reclassField = "Value"
        remap = RemapValue([[0, "NODATA"], ["NODATA", 0]])
        arcpy.CheckOutExtension("Spatial")
        outReclassify = Reclassify(os.path.join(inFolder, inRaster), reclassField, remap, "NODATA")
        output = os.path.join(outFolder, inRaster)
        outReclassify.save(output)
    except:
        print ("The file does not have valid statistics as required by operation: " + inRaster)
        continue

############# step 23: Euclidean distance - calculates the Euclidean distance within medium habitat suitability and unsuitable habitat combined ############

inFolder = "12.Medium_unsuitable_inverted"
env.workspace = inFolder
rasterList = arcpy.ListRasters("*", "All")
rasterList.sort()
env.workspace = path_scripts
outFolder = "13.Euclidean_distance_medium_unsuitable"
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)
    
for inRaster in rasterList:
    try:    
        arcpy.CheckOutExtension("Spatial")
        outReclassify = arcpy.sa.EucDistance(os.path.join(inFolder, inRaster), None, 300, None, "PLANAR", None, None)
        output = os.path.join(outFolder, inRaster)
        outReclassify.save(output)
    except:
        print ("The file does not have valid statistics as required by operation: " + inRaster)
        continue

############# step 24: Zonal statistics - calculates the mean Euclidean distance wihtin medium habitat suitability and unsuitable habitat combined ############

env.workspace = path_scripts
# Path to img files
filepath1 = "7.Medium_unsuitable_combined" 
filepath2 = "13.Euclidean_distance_medium_unsuitable"
# Path where to put rasters
outFolder = "14.Zonal_statistics_Euclidean_distance_medium_unsuitable"
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)

#zones to calculate stats on
inpoly1 = glob.glob(filepath1 + "/*.tif")
inpoly2 = glob.glob(filepath2 + "/*.tif")

#start loop
for k2 in inpoly2:
    filename = os.path.split(k2)[1][:-4]
    k1 = os.path.join(filepath1, os.path.split(k2)[1])
    if os.path.isfile(k1):
        destination_raster = outFolder + "/" + filename + ".dbf"
        if os.path.isfile(destination_raster):
            continue
        #print destination_raster
        pascuales = ZonalStatisticsAsTable(k1, "VALUE", k2, destination_raster, "DATA", "MEAN")
        field = "FILENAME"
        #expression = str(raster)   
        arcpy.AddField_management(pascuales,field,"TEXT")
        arcpy.CalculateField_management(pascuales, field, "'"+filename+"'", "PYTHON")

############ step 25: Merge - combines the mean values of the Euclidean distance wihtin medium habitat suitability and unsuitable habitat combined for each species into a single table ############

inFolder = os.path.join("14.Zonal_statistics_Euclidean_distance_medium_unsuitable")
env.workspace = inFolder
files = arcpy.ListFiles ("*.dbf")
env.workspace = path_scripts
finalFolder = "Outputs"
if not os.path.isdir(finalFolder):
    os.makedirs(finalFolder)
arcpy.Merge_management([os.path.join(inFolder, inRaster) for inRaster in files], os.path.join(finalFolder, "degree_patch_isolation.dbf"))

############ step 26: Zonal statistics - generates a table containing the pixel count for high suitability habitat and medium-suitability and unsuitable habitat combined ############

env.workspace = path_scripts
# Path to img files
filepath1 = "5.Reclassify" 
filepath2 = "5.Reclassify"
# Path where to put rasters
outFolder = "15.Pixel_count_high-suitability_medium_unsuitable"
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)

#zones to calculate stats on
inpoly1 = glob.glob(filepath1 + "/*.tif")
inpoly2 = glob.glob(filepath2 + "/*.tif")

#start loop
for k2 in inpoly2:
    filename = os.path.split(k2)[1][:-4]
    k1 = os.path.join(filepath1, os.path.split(k2)[1])
    if os.path.isfile(k1):
        destination_raster = outFolder + "/" + filename + ".dbf"
        if os.path.isfile(destination_raster):
            continue
        #print destination_raster
        pascuales = ZonalStatisticsAsTable(k1, "VALUE", k2, destination_raster, "DATA", "MEAN")
        field = "FILENAME"
        #expression = str(raster)   
        arcpy.AddField_management(pascuales,field,"TEXT")
        arcpy.CalculateField_management(pascuales, field, "'"+filename+"'", "PYTHON")

############ step 27: Merge - combines tables containing the pixel count for high habitat suitability and medium-suitability and unsuitable habitat combined of each species into a single table to calculate the proportion of high-suitability habitat within species ranges ############

inFolder = os.path.join("15.Pixel_count_high-suitability_medium_unsuitable")
env.workspace = inFolder
files = arcpy.ListFiles ("*.dbf")
env.workspace = path_scripts
finalFolder = "Outputs"
if not os.path.isdir(finalFolder):
    os.makedirs(finalFolder)
arcpy.Merge_management([os.path.join(inFolder, inRaster) for inRaster in files], os.path.join(finalFolder, "proportion_high-suitability.dbf"))

print ("DONE")

