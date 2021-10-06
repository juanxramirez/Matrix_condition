#Install required packages
if(!requireNamespace("randomForest", quietly=TRUE))
  install.packages("randomForest", quiet=TRUE, dependencies=TRUE)
if (!requireNamespace("caret",quietly=TRUE))
  install.packages("caret", quiet=TRUE, dependencies=TRUE)
if(!requireNamespace("dplyr", quietly=TRUE))
  install.packages("dplyr", quiet=TRUE, dependencies=TRUE)
if (!requireNamespace("ggplot2",quietly=TRUE))
  install.packages("ggplot2", quiet=TRUE, dependencies=TRUE)

library(randomForest)
library(caret)
library(dplyr)
library(ggplot2)

#Set directory
setwd("/myfolder")

#Import data
highHFP.drivers<-read.delim("/myfolder/data_medium_unsuitable_first_last.txt")

#Convert categorical variables to factor
highHFP.drivers$trans_first_last<-as.factor(highHFP.drivers$trans_first_last)
highHFP.drivers$order<-as.factor(highHFP.drivers$order)
highHFP.drivers$diet<-as.factor(highHFP.drivers$diet)
highHFP.drivers$realm<-as.factor(highHFP.drivers$realm)

#Check variables
str(highHFP.drivers)

#Set seed to ensure reproducibility
seed<-set.seed(17)
seed<-17

#Select variables and assign names for plotting labels
vars<-c("order", "massg", "diet", "realm", "gisfrag_high", "high_hfp_change_high", "high_hfp_change_medium_unsuitable", "high_hfp_extent_high", "high_hfp_extent_medium_unsuitable", "gisfrag_medium_unsuitable", "proportion_high", "gestation_length", "weaning_age", "trans_first_last")
names<-c("Order", "Body mass", "Diet", "Realm", "Degree fragmentation", "High HFP change high suitability", "High HFP change matrix", "High HFP extent high suitability", "High HFP extent matrix", "Degree patch isolation", "Proportion high suitability", "Gestation length", "Weaning age", "Transitions first last")
class<-c("Life-history", "Life-history", "Life-history", "Environment", "Environment", "Pressure", "Pressure", "Pressure", "Pressure", "Environment", "Environment", "Life-history", "Life-history", "Extinction risk transition")

#Remove species with missing values
data_na.omit<-na.omit(highHFP.drivers)

#Set training and test data
train_split<-createDataPartition(data_na.omit$trans_first_last, p=0.75, list=FALSE)
training<-data_na.omit[train_split,]
trainset<-training[,vars]
testing<-data_na.omit[-train_split,]
testset<-testing[,vars]

#Define custom RF model based on mtry and ntree tuning
customRF<-list(type="Classification", library="randomForest", loop=NULL)
customRF$parameters<-data.frame(parameter=c("mtry", "ntree"), class=rep("numeric", 2), label=c("mtry", "ntree"))
customRF$grid<-function(x, y, len=NULL, search="grid") {}
customRF$fit<-function(x, y, wts, param, lev, last, weights, classProbs, ...) {
  randomForest(x, y, mtry=param$mtry, ntree=param$ntree, ...)
}

#Predict label
customRF$predict<-function(modelFit, newdata, preProc=NULL, submodels=NULL)
  predict(modelFit, newdata)

#Predict prob
customRF$prob<-function(modelFit, newdata, preProc=NULL, submodels=NULL)
  predict(modelFit, newdata, type="prob")
customRF$sort<-function(x) x[order(x[,1]),]
customRF$levels<-function(x) x$classes

#Set metric to select the optimal model over cross-validation iterations
metric<-'Accuracy'

#Create control function for training with 10-fold cross-validation, repeated 3 times
control<-trainControl(method="repeatedcv", number=10, repeats=3)

#Create tunegrid
tunegrid<-expand.grid(.mtry=c(1:ncol(trainset)-1), .ntree=c(1000, 1500, 2000, 2500))

#Train with different ntree and mtry
custommodel<-train(trans_first_last~., data=trainset, method=customRF, metric=metric, tuneGrid=tunegrid, trControl=control)
summary(custommodel)
print(custommodel)
custommodel$results
print(custommodel$finalModel)
#plot(custommodel)

#Save tuning results
write.csv(custommodel$results, "Tuning_results_medium_unsuitable_first_last.csv")

#Run the optimal model
ntreebm<-custommodel$finalModel$ntree
mtrybm<-custommodel$finalModel$mtry
highHFP.drivers.RF<-randomForest(trans_first_last~., data=trainset, ntree=ntreebm, mtry=mtrybm, importance=TRUE)
print(highHFP.drivers.RF)

#Set test
testmodel<-predict(highHFP.drivers.RF, testset)
confMatrix<-confusionMatrix(testmodel, testset$trans_first_last)
print(confMatrix)

#Compute true skill statistic
confution.matrix.byclass<-data.frame(confMatrix$byClass)
sensitivity<-confution.matrix.byclass[1,]
specificity<-confution.matrix.byclass[2,]
TSS<-sensitivity+specificity-1
print(TSS)

#Save confusion matrix
write.csv(as.table(confMatrix), "Confusion_matrix_medium_unsuitable_first_last.csv")

#Save model
saveRDS(highHFP.drivers.RF, "./Final_model_medium_unsuitable_first_last.rds")

#Extract importance values
importance.values<-data.frame(highHFP.drivers.RF$importance)
importance.values$names<-names[-length(names)]
importance.values$class<-class[-length(class)]
importance.mean.decrease.accuracy<-data.frame(names=importance.values$names, importance=importance.values$MeanDecreaseAccuracy, class=importance.values$class)
print(importance.mean.decrease.accuracy)

#Compute MIR metric
mir.metric.medium.unsuitable.first.last<-(importance.mean.decrease.accuracy$importance/max(importance.mean.decrease.accuracy$importance))
var.importance<-data.frame(mir.metric.medium.unsuitable.first.last)
var.importance$names<-names[-length(names)]
var.importance$class<-class[-length(class)]
print(var.importance)

#Save relative importance scores
write.table(var.importance, file="Relative_importance_scores_medium_unsuitable_first_last.csv", sep="\t", row.names=F)

#Plot variable importance
var.importance$class<-factor(var.importance$class, levels=c("Pressure", "Environment", "Life-history"))
#png("var.importance_medium_unsuitable_first_last.png", units="in", width=6, height=3, res=1200, type="cairo")
plot.var.importance<-ggplot(var.importance, aes(x=reorder(names, mir.metric.medium.unsuitable.first.last), y=mir.metric.medium.unsuitable.first.last)) +
  geom_bar(aes(y=mir.metric.medium.unsuitable.first.last, fill=class), stat="identity") +
  geom_hline(yintercept=0, colour="white", lwd=1) +
  coord_flip() + 
  labs(y="Variable importance", x="") +
  theme(legend.position="bottom", legend.title=element_blank(), 
        panel.border=element_rect(colour="black", fill=NA, size=0.5), legend.text=element_text(size=7), 
        panel.background=element_rect(fill="white", colour="grey", size=0.5, linetype="solid"), 
        panel.grid.major=element_line(size=0.25, linetype="dashed", colour="lightgrey"), 
        panel.grid.minor=element_line(size=0.25, linetype="dashed", colour="lightgrey"), 
        plot.title=element_text(color="black", size=7, hjust=0), axis.title.x=element_text(size=7), 
        axis.text.x=element_text(size=7), axis.text.y=element_text(size=7)) +
  scale_fill_brewer(palette="Set2")
plot.var.importance
#dev.off()
