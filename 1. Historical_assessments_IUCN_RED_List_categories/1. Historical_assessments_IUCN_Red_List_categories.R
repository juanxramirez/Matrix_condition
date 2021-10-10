#Install required packages 
if(!requireNamespace("rredlist", quietly=TRUE))
  install.packages("rredlist", quiet=TRUE, dependencies=TRUE)  
if(!requireNamespace("dplyr", quietly=TRUE))
  install.packages("dplyr", quiet=TRUE, dependencies=TRUE)  
if(!requireNamespace("writexl", quietly=TRUE))
  install.packages("writexl", quiet=TRUE, dependencies=TRUE) 
  
library(rredlist)
library(dplyr)
library(writexl)

#set directory
setwd("/myfolder")

#Call species IDs with a .txt file to get historical assessments per species
sp.with.esh.map=read.table("/myfolder/list_of_species_with_habitat_suitability_defined.txt", header=TRUE)

a=c(sp.with.esh.map[,1])

#Get historical assessments by species ID
list=list()
for (i in 1:length(a)){
  b=rl_history(id=a[i], key="#API key#", parse=TRUE) #Requires  you  to  get  your  own  API  key,  an  alphanumeric  string  that  you  need  to  send  in every request. Please see https://apiv3.iucnredlist.org/ for more details
  sp_result=b$result
  sp_result$sp_name=b$name 
  list[[i]]=sp_result
}

#Convert results to a table
red.list.assessments.sp.with.esh.map<-dplyr::bind_rows(list)
red.list.assessments.sp.with.esh.map<-as.data.frame(red.list.assessments.sp.with.esh.map)
#Save historical assessments to a table
write_xlsx(red.list.assessments.sp.with.esh.map, "historical_assessments.xlsx")
