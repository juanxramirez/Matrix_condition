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

############# step 5: Reclassify - combines high- and medium-suitablity into a sinlge class ############

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
        remap = RemapValue([[0, 0], [1, 1],[2, 1]])
        arcpy.CheckOutExtension("Spatial")
        outReclassify = Reclassify(os.path.join(inFolder, inRaster), reclassField, remap, "NODATA")
        output = os.path.join(outFolder, inRaster)
        outReclassify.save(output)
    except:
        print ("The file does not have valid statistics as required by operation: " + inRaster)
        continue
    
############# step 6: Reclassify - reclassifies the level of unsuitable habitat to no data ############

inFolder = "5.Reclassify"
env.workspace = inFolder
rasterList = arcpy.ListRasters("*", "All")
rasterList.sort()
env.workspace = path_scripts
outFolder = "6.Suitable"
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)

for inRaster in rasterList:
    try:
        reclassField = "Value"
        remap = RemapValue([[0, "NODATA"], [1, 1]])
        arcpy.CheckOutExtension("Spatial")
        outReclassify = Reclassify(os.path.join(inFolder, inRaster), reclassField, remap, "NODATA")
        output = os.path.join(outFolder, inRaster)
        outReclassify.save(output)
    except:
        print ("The file does not have valid statistics as required by operation: " + inRaster)
        continue

############# step 7: Define projection - defines the projection of high- and medium-suitability combined ############

env.workspace = path_scripts
env.workspace = "6.Suitable"
prjfile = "World_Mollweide.prj"
rasterList = arcpy.ListRasters("*", "All")
rasterList.sort()

for raster in arcpy.ListRasters():
    print (raster)
    arcpy.DefineProjection_management(raster, prjfile)
    print ("projection defined")

############# step 8: Tabulate area - calculates the extent of high HFP values within patches of suiatble habitat in 2000 ############

# Path to img files
env.workspace = path_scripts
filepath = "6.Suitable"
# Path where to put rasters
outFolder = os.path.join("8.Tabulate_area", "suitable", "2000")
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
 
############# step 9: Merge - combines cross-tabulated areas between the extent of high HFP values and patches of suitable habitat in 2000 for each species into a single table ############

inFolder = os.path.join("8.Tabulate_area", "suitable", "2000")
env.workspace = inFolder
files = arcpy.ListFiles ("*.dbf")
env.workspace = path_scripts
finalFolder = "Outputs"
if not os.path.isdir(finalFolder):
    os.makedirs(finalFolder)
arcpy.Merge_management([os.path.join(inFolder, inRaster) for inRaster in files], os.path.join(finalFolder, "high_hfp_extent_suitable_2000.dbf"))

############# step 10: Tabulate area - calculates cross-tabulated areas between the extent of high HFP values and patches of suitable habitat in 2013 ############

# Path to img files
env.workspace = path_scripts
filepath = "6.Suitable"
# Path where to put rasters
outFolder = os.path.join("8.Tabulate_area", "suitable", "2013")
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
 
############# step 11: Merge - combines cross-tabulated areas between the extent of high HFP values and patches of suitable habitat in 2013 for each species into a single table ############

inFolder = os.path.join("8.Tabulate_area", "suitable", "2013")
env.workspace = inFolder
files = arcpy.ListFiles ("*.dbf")
env.workspace = path_scripts
finalFolder = "Outputs"
if not os.path.isdir(finalFolder):
    os.makedirs(finalFolder)
arcpy.Merge_management([os.path.join(inFolder, inRaster) for inRaster in files], os.path.join(finalFolder, "high_hfp_extent_suitable_2013.dbf"))

############# step 12: Reclassify - reclassifies patches of suitable habitat to no data ############

inFolder = "5.Reclassify"
env.workspace = inFolder
rasterList = arcpy.ListRasters("*", "All")
rasterList.sort()
env.workspace = path_scripts
outFolder = "7.Unsuitable"
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)

for inRaster in rasterList:
    try:
        reclassField = "Value"
        remap = RemapValue([[0, 0], [1, "NODATA"]])
        arcpy.CheckOutExtension("Spatial")
        outReclassify = Reclassify(os.path.join(inFolder, inRaster), reclassField, remap, "NODATA")
        output = os.path.join(outFolder, inRaster)
        outReclassify.save(output)
    except:
        print ("The file does not have valid statistics as required by operation: " + inRaster)
        continue

############# step 13: Define projection - defines the projection of unsuitable habitat ############

env.workspace = path_scripts
env.workspace = "7.Unsuitable"
prjfile = "World_Mollweide.prj"
rasterList = arcpy.ListRasters("*", "All")
rasterList.sort()

for raster in arcpy.ListRasters():
    print (raster)
    arcpy.DefineProjection_management(raster, prjfile)
    print ("projection defined")

############# step 14: Tabulate area - calculates cross-tabulated areas between the extent of high HFP values and unsuitable habitat in 2000 ############

# Path to img files
env.workspace = path_scripts
filepath = "7.Unsuitable"
# Path where to put rasters
outFolder = os.path.join("8.Tabulate_area", "unsuitable", "2000")
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
 
############# step 15: Merge - combines cross-tabulated areas between the extent of high HFP values and unsuitable habitat in 2000 for each species into a single table ############

inFolder = os.path.join("8.Tabulate_area", "unsuitable", "2000")
env.workspace = inFolder
files = arcpy.ListFiles ("*.dbf")
env.workspace = path_scripts
finalFolder = "Outputs"
if not os.path.isdir(finalFolder):
    os.makedirs(finalFolder)
arcpy.Merge_management([os.path.join(inFolder, inRaster) for inRaster in files], os.path.join(finalFolder, "high_hfp_extent_matrix_2000.dbf"))

############# step 16: Tabulate area - calculates cross-tabulated areas between the extent of high HFP values and unsuitable habitat in 2013 ############

# Path to img files
env.workspace = path_scripts
filepath = "7.Unsuitable"
# Path where to put rasters
outFolder = os.path.join("8.Tabulate_area", "unsuitable", "2013")
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
 
############# step 17: Merge - combines cross-tabulated areas between the extent of high HFP values and unsuitable habitat in 2013 for each species into a single table ############

inFolder = os.path.join("8.Tabulate_area", "unsuitable", "2013")
env.workspace = inFolder
files = arcpy.ListFiles ("*.dbf")
env.workspace = path_scripts
finalFolder = "Outputs"
if not os.path.isdir(finalFolder):
    os.makedirs(finalFolder)
arcpy.Merge_management([os.path.join(inFolder, inRaster) for inRaster in files], os.path.join(finalFolder, "high_hfp_extent_matrix_2013.dbf"))

############# step 18: Reclassify - reclassifies suitable habitat to calculate the Euclidean distance within patches of suitable habitat ############

inFolder = "6.Suitable"
env.workspace = inFolder
rasterList = arcpy.ListRasters("*", "All")
rasterList.sort()
env.workspace = path_scripts
outFolder = "9.Suitable_inverted"
if not os.path.isdir(outFolder):
    os.makedirs(outFolder)

for inRaster in rasterList:
    try:
        reclassField = "Value"
        remap = RemapValue([[1, "NODATA"], ["NODATA", 1]])
        arcpy.CheckOutExtension("Spatial")
        outReclassify = Reclassify(os.path.join(inFolder, inRaster), reclassField, remap, "NODATA")
        output = os.path.join(outFolder, inRaster)
        outReclassify.save(output)
    except:
        print ("The file does not have valid statistics as required by operation: " + inRaster)
        continue

############# step 19: Euclidean distance - calculates the Euclidean distance within patches of suitable habitat ############

inFolder = "9.Suitable_inverted"
env.workspace = inFolder
rasterList = arcpy.ListRasters("*", "All")
rasterList.sort()
env.workspace = path_scripts
outFolder = "10.Euclidean_distance_suitable"
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

############# step 20: Zonal statistics - calculates the mean Euclidean distance wihtin patches of suitable habitat ############

env.workspace = path_scripts
# Path to img files
filepath1 = "6.Suitable" 
filepath2 = "10.Euclidean_distance_suitable"
# Path where to put rasters
outFolder = "11.Zonal_statistics_Euclidean_distance_suitable"
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

############# step 21: Merge - combines the mean values of the Euclidean distance wihtin patches of suitable habitat for each species into a single table ############

inFolder = os.path.join("11.Zonal_statistics_Euclidean_distance_suitable")
env.workspace = inFolder
files = arcpy.ListFiles ("*.dbf")
env.workspace = path_scripts
finalFolder = "Outputs"
if not os.path.isdir(finalFolder):
    os.makedirs(finalFolder)
arcpy.Merge_management([os.path.join(inFolder, inRaster) for inRaster in files], os.path.join(finalFolder, "degree_habitat_fragmentation.dbf"))

############# step 22: Reclassify - reclassifies unsuitable habitat to calculate the Euclidean distance within unsuitable habitat ############

inFolder = "7.Unsuitable"
env.workspace = inFolder
rasterList = arcpy.ListRasters("*", "All")
rasterList.sort()
env.workspace = path_scripts
outFolder = "12.Unsuitable_inverted"
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

############# step 23: Euclidean distance - calculates the Euclidean distance within unsuitable habitat ############

inFolder = "12.Unsuitable_inverted"
env.workspace = inFolder
rasterList = arcpy.ListRasters("*", "All")
rasterList.sort()
env.workspace = path_scripts
outFolder = "13.Euclidean_distance_unsuitable"
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

############# step 24: Zonal statistics - calculates the mean Euclidean distance wihtin unsuitable habitat ############

env.workspace = path_scripts
# Path to img files
filepath1 = "7.Unsuitable" 
filepath2 = "13.Euclidean_distance_unsuitable"
# Path where to put rasters
outFolder = "14.Zonal_statistics_Euclidean_distance_unsuitable"
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

############ step 25: Merge - combines the mean values of the Euclidean distance wihtin unsuitable habitat for each species into a single table ############

inFolder = os.path.join("14.Zonal_statistics_Euclidean_distance_unsuitable")
env.workspace = inFolder
files = arcpy.ListFiles ("*.dbf")
env.workspace = path_scripts
finalFolder = "Outputs"
if not os.path.isdir(finalFolder):
    os.makedirs(finalFolder)
arcpy.Merge_management([os.path.join(inFolder, inRaster) for inRaster in files], os.path.join(finalFolder, "degree_patch_isolation.dbf"))

############ step 26: Zonal statistics - generates a table containing the pixel count for suitable and unsuitable habitat ############

env.workspace = path_scripts
# Path to img files
filepath1 = "5.Reclassify" 
filepath2 = "5.Reclassify"
# Path where to put rasters
outFolder = "15.Pixel_count_suitable_unsuitable"
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

############ step 27: Merge - combines tables containing the pixel count for suitable and unsuitable habitat of each species into a single table to calculate the proportion of suitable habitat patches within species ranges ############

inFolder = os.path.join("15.Pixel_count_suitable_unsuitable")
env.workspace = inFolder
files = arcpy.ListFiles ("*.dbf")
env.workspace = path_scripts
finalFolder = "Outputs"
if not os.path.isdir(finalFolder):
    os.makedirs(finalFolder)
arcpy.Merge_management([os.path.join(inFolder, inRaster) for inRaster in files], os.path.join(finalFolder, "proportion_suitable.dbf"))

print ("DONE")

