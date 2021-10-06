#Install required packages
if(!requireNamespace("randomForest", quietly=TRUE))
  install.packages("randomForest", quiet=TRUE, dependencies=TRUE)
if (!requireNamespace("caret", quietly=TRUE))
  install.packages("caret", quiet=TRUE, dependencies=TRUE)
if(!requireNamespace("dplyr", quietly=TRUE))
  install.packages("dplyr", quiet=TRUE, dependencies=TRUE)
if (!requireNamespace("ggplot2",quietly=TRUE))
  install.packages("ggplot2", quiet=TRUE, dependencies=TRUE)
if(!requireNamespace("ggpubr", quietly=TRUE))
  install.packages("ggpurb", quiet=TRUE, dependencies=TRUE)

library(randomForest)
library(caret)
library(dplyr)
library(ggplot2)
library(ggpubr)

#set directory
setwd("/myfolder")

#Import data
highHFP.drivers<-read.delim("/myfolder/data_high_medium_first_last.txt")

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
vars<-c("order", "massg", "diet", "realm", "gisfrag_high_medium", "high_hfp_change_high_medium", "high_hfp_change_unsuitable", "high_hfp_extent_high_medium", "high_hfp_extent_unsuitable", "gisfrag_unsuitable", "proportion_high_medium", "gestation_length", "weaning_age", "trans_first_last")
names<-c("Order", "Body mass", "Diet", "Realm", "Degree fragmentation", "High HFP change suitable", "High HFP change matrix", "High HFP extent suitable", "High HFP extent matrix", "Degree patch isolation", "Proportion suitable", "Gestation length", "Weaning age", "Transitions first last")
class<-c("Life-history", "Life-history", "Life-history", "Environment", "Environment", "Pressure", "Pressure", "Pressure", "Pressure", "Environment", "Environment", "Life-history", "Life-history", "Extinction risk transition")

#Extract species with low- and high-quality matrices
low.quality.matrix<-highHFP.drivers %>% filter(high_hfp_extent_unsuitable>84.210526)
str(low.quality.matrix)
high.quality.matrix<-highHFP.drivers %>% filter(high_hfp_extent_unsuitable<15.789474)
str(high.quality.matrix)

#Extract number of high-risk and low-risk species with low-quality and high-quality matrices
table(low.quality.matrix$trans_first_last)
table(high.quality.matrix$trans_first_last)

#Remove species with missing values
low.quality.matrix.na.omit<-na.omit(low.quality.matrix)
high.quality.matrix.na.omit<-na.omit(high.quality.matrix)

#Set training and test data
train_split.low.quality.matrix<-createDataPartition(low.quality.matrix.na.omit$trans_first_last,p=0.75,list=FALSE)
training.low.quality.matrix<-low.quality.matrix.na.omit[train_split.low.quality.matrix,]
trainset.low.quality.matrix<-training.low.quality.matrix[,vars]
testing.low.quality.matrix<-low.quality.matrix.na.omit[-train_split.low.quality.matrix,]
testset.low.quality.matrix<-testing.low.quality.matrix[,vars]
train_split.high.quality.matrix<-createDataPartition(high.quality.matrix.na.omit$trans_first_last,p=0.75,list=FALSE)
training.high.quality.matrix<-high.quality.matrix.na.omit[train_split.high.quality.matrix,]
trainset.high.quality.matrix<-training.high.quality.matrix[,vars]
testing.high.quality.matrix<-high.quality.matrix.na.omit[-train_split.high.quality.matrix,]
testset.high.quality.matrix<-testing.high.quality.matrix[,vars]

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
metric='Accuracy'

#Create control function for training with 10-fold cross-validation, repeated 3 times
control<-trainControl(method="repeatedcv", number=10, repeats=3)

#Create tunegrid
tunegrid.low.quality.matrix<-expand.grid(.mtry=c(1:ncol(trainset.low.quality.matrix)-1), .ntree=c(1000, 1500, 2000, 2500))
tunegrid.high.quality.matrix<-expand.grid(.mtry=c(1:ncol(trainset.high.quality.matrix)-1), .ntree=c(1000, 1500, 2000, 2500))

#Train with different ntree and mtry
custommodel.low.quality.matrix<-train(trans_first_last~., data=trainset.low.quality.matrix, method=customRF, metric=metric, tuneGrid=tunegrid.low.quality.matrix, trControl=control)
summary(custommodel.low.quality.matrix)
print(custommodel.low.quality.matrix)
custommodel.low.quality.matrix$results
print(custommodel.low.quality.matrix$finalModel)
plot(custommodel.low.quality.matrix)
custommodel.high.quality.matrix<-train(trans_first_last~., data=trainset.high.quality.matrix, method=customRF, metric=metric, tuneGrid=tunegrid.high.quality.matrix, trControl=control)
summary(custommodel.high.quality.matrix)
print(custommodel.high.quality.matrix)
custommodel.high.quality.matrix$results
print(custommodel.high.quality.matrix$finalModel)
plot(custommodel.high.quality.matrix)

#Save tuning results
write.csv(custommodel.low.quality.matrix$results, "Tuning_results_low_quality_matrix.csv")
write.csv(custommodel.high.quality.matrix$results, "Tuning_results_high_quality_matrix.csv")

#Run the optimal model
ntreebm.low.quality.matrix<-custommodel.low.quality.matrix$finalModel$ntree
mtrybm.low.quality.matrix<-custommodel.low.quality.matrix$finalModel$mtry
ntreebm.high.quality.matrix<-custommodel.high.quality.matrix$finalModel$ntree
mtrybm.high.quality.matrix<-custommodel.high.quality.matrix$finalModel$mtry
low.quality.matrix.RF<-randomForest(trans_first_last~., data=trainset.low.quality.matrix, ntree=ntreebm.low.quality.matrix, mtry=mtrybm.low.quality.matrix, importance = TRUE)
print(low.quality.matrix.RF)
high.quality.matrix.RF<-randomForest(trans_first_last~., data=trainset.high.quality.matrix, ntree=ntreebm.high.quality.matrix, mtry=mtrybm.high.quality.matrix, importance = TRUE)
print(high.quality.matrix.RF)

#Set test
testmodel.low.quality.matrix<-predict(low.quality.matrix.RF, testset.low.quality.matrix)
confMatrix.low.quality.matrix<-confusionMatrix(testmodel.low.quality.matrix, testset.low.quality.matrix$trans_first_last)
print(confMatrix.low.quality.matrix)
testmodel.high.quality.matrix<-predict(high.quality.matrix.RF, testset.high.quality.matrix)
confMatrix.high.quality.matrix<-confusionMatrix(testmodel.high.quality.matrix, testset.high.quality.matrix$trans_first_last)
print(confMatrix.high.quality.matrix)

#Compute true skill statistic
confution.matrix.byclass.low.quality.matrix<-data.frame(confMatrix.low.quality.matrix$byClass)
sensitivity.low.quality.matrix<-confution.matrix.byclass.low.quality.matrix[1,]
specificity.low.quality.matrix<-confution.matrix.byclass.low.quality.matrix[2,]
TSS.low.quality.matrix<-sensitivity.low.quality.matrix+specificity.low.quality.matrix-1
print(TSS.low.quality.matrix)
confution.matrix.byclass.high.quality.matrix<-data.frame(confMatrix.high.quality.matrix$byClass)
sensitivity.high.quality.matrix<-confution.matrix.byclass.high.quality.matrix[1,]
specificity.high.quality.matrix<-confution.matrix.byclass.high.quality.matrix[2,]
TSS.high.quality.matrix<-sensitivity.high.quality.matrix+specificity.high.quality.matrix-1
print(TSS.high.quality.matrix)

#Save confusion matrix
write.csv(as.table(confMatrix.low.quality.matrix), "Confusion_matrix_low_quality_matrix.csv")
write.csv(as.table(confMatrix.high.quality.matrix), "Confusion_matrix_high_quality_matrix.csv")

#Save model
saveRDS(low.quality.matrix.RF, "./Final_model_low_quality_matrix.rds")
saveRDS(high.quality.matrix.RF, "./Final_model_high_quality_matrix.rds")

#Extract importance values
importance.values.low.quality.matrix<-data.frame(low.quality.matrix.RF$importance)
importance.values.low.quality.matrix$names<-names[-length(names)]
importance.values.low.quality.matrix$class<-class[-length(class)]
importance.low.quality.matrix.mean.decrease.accuracy<-data.frame(names=importance.values.low.quality.matrix$names, importance=importance.values.low.quality.matrix$MeanDecreaseAccuracy, class=importance.values.low.quality.matrix$class)
print(importance.low.quality.matrix.mean.decrease.accuracy)
importance.values.high.quality.matrix<-data.frame(high.quality.matrix.RF$importance)
importance.values.high.quality.matrix$names<-names[-length(names)]
importance.values.high.quality.matrix$class<-class[-length(class)]
importance.high.quality.matrix.mean.decrease.accuracy<-data.frame(names=importance.values.high.quality.matrix$names, importance=importance.values.high.quality.matrix$MeanDecreaseAccuracy, class=importance.values.high.quality.matrix$class)
print(importance.high.quality.matrix.mean.decrease.accuracy)

#Compute MIR metric
mir.metric.low.quality.matrix<-(importance.low.quality.matrix.mean.decrease.accuracy$importance/max(importance.low.quality.matrix.mean.decrease.accuracy$importance))
var.importance.low.quality.matrix<-data.frame(mir.metric.low.quality.matrix)
var.importance.low.quality.matrix$names<-names[-length(names)]
var.importance.low.quality.matrix$class<-class[-length(class)]
var.importance.low.quality.matrix
mir.metric.high.quality.matrix<-(importance.high.quality.matrix.mean.decrease.accuracy$importance/max(importance.high.quality.matrix.mean.decrease.accuracy$importance))
var.importance.high.quality.matrix <- data.frame(mir.metric.high.quality.matrix)
var.importance.high.quality.matrix$names<-names[-length(names)]
var.importance.high.quality.matrix$class<-class[-length(class)]
var.importance.high.quality.matrix

#Save relative importance scores
write.table(var.importance.low.quality.matrix, file="Relative_importance_scores_low_quality_matrix.csv", sep="\t", row.names=F)
write.table(var.importance.high.quality.matrix, file="Relative_importance_scores_high_quality_matrix.csv", sep="\t", row.names=F)

#Plot variable importance
var.importance.low.quality.matrix$class<-factor(var.importance.low.quality.matrix$class, levels = c("Pressure", "Environment", "Life-history"))
var.importance.high.quality.matrix$class<-factor(var.importance.high.quality.matrix$class, levels = c("Pressure", "Environment", "Life-history"))
#png("var.importance_low-quality_matrix.png", units="in", width=6, height=3, res=800)
plot.var.importance.low.quality.matrix<-ggplot(var.importance.low.quality.matrix, aes(x=reorder(names, mir.metric.low.quality.matrix), y=mir.metric.low.quality.matrix)) +
  geom_bar(aes(y=mir.metric.low.quality.matrix, fill=class), stat="identity") +
  geom_hline(yintercept=0, colour="white", lwd=1) +
  coord_flip() +
  labs(y="Variable importance (low-quality matrices)", x="") +
  theme(legend.position="", legend.title=element_blank(),
        panel.border=element_rect(colour="black", fill=NA, size=0.5), legend.text=element_text(size=7),
        panel.background=element_rect(fill="white", colour="grey", size=0.5, linetype="solid"),
        panel.grid.major=element_line(size=0.25, linetype='dashed', colour="lightgrey"),
        panel.grid.minor=element_line(size=0.25, linetype='dashed', colour="lightgrey"), 
        plot.title=element_text(color="black", size=7, hjust=0), axis.title.x=element_text(size=7),
        axis.text.x=element_text(size=7), axis.text.y=element_text(size=7)) +
  scale_fill_brewer(palette="Set2")
plot.var.importance.low.quality.matrix
#dev.off()

#png("var.importance_high-quality_matrix.png", units="in", width=6, height=3, res=800)
plot.var.importance.high.quality.matrix<-ggplot(var.importance.high.quality.matrix, aes(x=reorder(names, mir.metric.high.quality.matrix), y=mir.metric.high.quality.matrix)) +
  geom_bar(aes(y=mir.metric.high.quality.matrix, fill=class), stat="identity") +
  geom_hline(yintercept=0, colour="white", lwd=1) +
  coord_flip() + 
  labs(y="Variable importance (high-quality matrices)", x="") +
  theme(legend.position="bottom", legend.title=element_blank(), 
        panel.border=element_rect(colour="black", fill=NA, size=0.5), legend.text=element_text(size=7), 
        panel.background=element_rect(fill="white", colour="grey", size=0.5, linetype="solid"),
        panel.grid.major=element_line(size=0.25, linetype='dashed', colour="lightgrey"),
        panel.grid.minor=element_line(size=0.25, linetype='dashed', colour="lightgrey"), 
        plot.title=element_text(color="black", size=7, hjust=0), axis.title.x=element_text(size=7), 
        axis.text.x=element_text(size=7), axis.text.y=element_text(size=7)) +
  scale_fill_brewer(palette="Set2")
plot.var.importance.high.quality.matrix
#dev.off()

#png("var.importance_low-and_high-quality_matrix.png", units="in", width=6, height=6, res=1200, type="cairo")
ggarrange(plot.var.importance.low.quality.matrix, plot.var.importance.high.quality.matrix, 
          labels=c("a", "b"),
          ncol=1, nrow=2,
          common.legend=TRUE, legend="bottom", align="hv",
          font.label=list(size=7))
#dev.off()
