#Install required packages
if(!requireNamespace("randomForest", quietly=TRUE))
  install.packages("randomForest", quiet=TRUE, dependencies=TRUE)
if (!requireNamespace("caret", quietly=TRUE))
  install.packages("caret", quiet=TRUE, dependencies=TRUE)
if(!requireNamespace("dplyr", quietly=TRUE))
  install.packages("dplyr", quiet=TRUE, dependencies=TRUE)
if (!requireNamespace("ggplot2", quietly=TRUE))
  install.packages("ggplot2", quiet=TRUE, dependencies=TRUE)
if(!requireNamespace("iml", quietly=TRUE))
  install.packages("iml", quiet=TRUE, dependencies=TRUE)
if(!requireNamespace("ggpubr", quietly=TRUE))
  install.packages("ggpurb", quiet=TRUE, dependencies=TRUE)

library(randomForest)
library(caret)
library(dplyr)
library(ggplot2)
library(iml)
library(ggpubr)

#Set directory
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
write.csv(custommodel$results, "Tuning_results_high_medium_first_last.csv")

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
write.csv(as.table(confMatrix), "Confusion_matrix_high_medium_first_last.csv")

#Save model
saveRDS(highHFP.drivers.RF, "./Final_model_high_medium_first_last.rds")

#Extract importance values
importance.values<-data.frame(highHFP.drivers.RF$importance)
importance.values$names<-names[-length(names)]
importance.values$class<-class[-length(class)]
importance.mean.decrease.accuracy<-data.frame(names=importance.values$names, importance=importance.values$MeanDecreaseAccuracy, class=importance.values$class)
print(importance.mean.decrease.accuracy)

#Compute MIR metric
mir.metric.high.medium.first.last<-(importance.mean.decrease.accuracy$importance/max(importance.mean.decrease.accuracy$importance))
var.importance<-data.frame(mir.metric.high.medium.first.last)
var.importance$names<-names[-length(names)]
var.importance$class<-class[-length(class)]
print(var.importance)

#Save relative importance scores
write.table(var.importance, file="Relative_importance_scores_high_medium_first_last.csv", sep="\t", row.names=F)

#Plot variable importance
var.importance$class<-factor(var.importance$class, levels=c("Pressure", "Environment", "Life-history"))
#png("var.importance_high_medium_first_last.png", units="in", width=6, height=3, res=1200, type="cairo")
plot.var.importance<-ggplot(var.importance, aes(x=reorder(names, mir.metric.high.medium.first.last), y=mir.metric.high.medium.first.last)) +
  geom_bar(aes(y=mir.metric.high.medium.first.last, fill=class), stat="identity") +
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

#Create partial dependence plots
degree_habitat_fragmentation<-1/log(trainset$gisfrag_high_medium) #Degree of habitat fragmentation ln-transformed and inverse-coded
degree_patch_isolation<-log(trainset$gisfrag_unsuitable) #Degree of patch isolation ln-transformed
data_pdp<-cbind(trainset, degree_habitat_fragmentation, degree_patch_isolation)
vars2<-c("order", "massg", "diet", "realm", "degree_habitat_fragmentation", "high_hfp_change_high_medium", "high_hfp_change_unsuitable", "high_hfp_extent_high_medium", "high_hfp_extent_unsuitable", "degree_patch_isolation", "proportion_high_medium", "gestation_length", "weaning_age", "trans_first_last")
rf<-randomForest(trans_first_last~., data=data_pdp[,vars2], ntree=ntreebm, mtry=mtrybm)
mod<-Predictor$new(rf, data = data_pdp[,vars2], type = "prob")
effect.degree.fragmentation<-FeatureEffect$new(mod, feature="degree_habitat_fragmentation", method="pdp")
effect.degree.fragmentation.results<-data.frame(effect.degree.fragmentation$results)
effect.degree.fragmentation.low.risk<-effect.degree.fragmentation.results[grep("Low-risk", effect.degree.fragmentation.results$.class), ]
print(effect.degree.fragmentation.low.risk)
effect.degree.fragmentation.high.risk<-effect.degree.fragmentation.results[grep("High-risk", effect.degree.fragmentation.results$.class), ]
print(effect.degree.fragmentation.high.risk)
effect.degree.patch.isolation<-FeatureEffect$new(mod, feature="degree_patch_isolation", method="pdp")
effect.degree.patch.isolation.results<-data.frame(effect.degree.patch.isolation$results)
effect.degree.patch.isolation.low.risk<-effect.degree.patch.isolation.results[grep("Low-risk", effect.degree.fragmentation.results$.class), ]
print(effect.degree.patch.isolation.low.risk)
effect.degree.patch.isolation.high.risk<-effect.degree.patch.isolation.results[grep("High-risk", effect.degree.fragmentation.results$.class), ]
print(effect.degree.patch.isolation.high.risk)
effect.matrix.condition<-FeatureEffect$new(mod, feature="high_hfp_extent_unsuitable", method="pdp")
effect.matrix.condition.results<-data.frame(effect.matrix.condition$results)
effect.matrix.condition.low.risk<-effect.matrix.condition.results[grep("Low-risk", effect.degree.fragmentation.results$.class), ]
print(effect.matrix.condition.low.risk)
effect.matrix.condition.high.risk<-effect.matrix.condition.results[grep("High-risk", effect.degree.fragmentation.results$.class), ]
print(effect.matrix.condition.high.risk)

pdp.degree.fragmentation.low.risk<-ggplot(effect.degree.fragmentation.low.risk, aes(x=degree_habitat_fragmentation, y=.value, fill=.class, color=.class)) +
  geom_point(shape=21) +
  xlab("Degree fragmentation") + 
  ylab("Prob. low-risk transitions") +
  theme(legend.position="none", legend.title=element_blank(),
        legend.background = element_rect(fill="white", linetype="solid", size=0.25, colour="black"),
        legend.spacing.y=unit(0, "mm"), panel.border=element_rect(colour="black", fill=NA, size=0.5),
        legend.text=element_text(size=7),
        panel.background=element_rect(fill="white", colour="grey", size=0.5, linetype="solid"),
        panel.grid.major=element_line(size=0.25, linetype='dashed', colour="lightgrey"),
        panel.grid.minor=element_line(size=0.25, linetype='dashed', colour="lightgrey"), 
        plot.title=element_text(color="black", size=7, hjust=0), axis.title.x=element_text(size=7),
        axis.title.y=element_text(size=7), axis.text.x=element_text(size=7), 
        axis.text.y=element_text(size=7), legend.key=element_rect(fill="transparent", colour="transparent")) +
  geom_smooth(method="loess", size=0.9) +
  scale_fill_manual(values=c("#80B1D3")) +
  scale_color_manual(values=c("#80B1D3"))
pdp.degree.fragmentation.low.risk

pdp.degree.fragmentation.high.risk<-ggplot(effect.degree.fragmentation.high.risk, aes(x=degree_habitat_fragmentation, y=.value, fill=.class, color=.class)) +
  geom_point(shape=21) +
  xlab("Degree fragmentation") + 
  ylab("Prob. high-risk transitions") +
  theme(legend.position="none", legend.title=element_blank(),
        legend.background = element_rect(fill="white", linetype="solid", size=0.25, colour="black"),
        legend.spacing.y=unit(0, "mm"), panel.border=element_rect(colour="black", fill=NA, size=0.5),
        legend.text=element_text(size=7),
        panel.background=element_rect(fill="white", colour="grey", size=0.5, linetype="solid"),
        panel.grid.major=element_line(size=0.25, linetype='dashed', colour="lightgrey"),
        panel.grid.minor=element_line(size=0.25, linetype='dashed', colour="lightgrey"), 
        plot.title=element_text(color="black", size=7, hjust=0), axis.title.x=element_text(size=7),
        axis.title.y=element_text(size=7), axis.text.x=element_text(size=7), 
        axis.text.y=element_text(size=7), legend.key=element_rect(fill="transparent", colour="transparent")) +
  geom_smooth(method="loess", se=TRUE, size=0.9) +
  scale_fill_manual(values=c("#FB8072")) +
  scale_color_manual(values=c("#FB8072"))
pdp.degree.fragmentation.high.risk

pdp.degree.patch.isolation.low.risk<-ggplot(effect.degree.patch.isolation.low.risk, aes(x=degree_patch_isolation, y=.value, fill=.class, color=.class)) +
  geom_point(shape=21) +
  xlab("Degree patch isolation") + 
  ylab("Prob. low-risk transitions") +
  theme(legend.position="none", legend.title=element_blank(),
        legend.background = element_rect(fill="white", linetype="solid", size=0.25, colour="black"),
        legend.spacing.y=unit(0, "mm"), panel.border=element_rect(colour="black", fill=NA, size=0.5),
        legend.text=element_text(size=7),
        panel.background=element_rect(fill="white", colour="grey", size=0.5, linetype="solid"),
        panel.grid.major=element_line(size=0.25, linetype='dashed', colour="lightgrey"),
        panel.grid.minor=element_line(size=0.25, linetype='dashed', colour="lightgrey"), 
        plot.title=element_text(color="black", size=7, hjust=0), axis.title.x=element_text(size=7),
        axis.title.y=element_text(size=7), axis.text.x=element_text(size=7), 
        axis.text.y=element_text(size=7), legend.key=element_rect(fill="transparent", colour="transparent")) +
  geom_smooth(method="loess", size=0.9) +
  scale_x_continuous(limits=c(5.7,11.8)) +
  scale_fill_manual(values=c("#80B1D3")) +
  scale_color_manual(values=c("#80B1D3"))
pdp.degree.patch.isolation.low.risk

pdp.degree.patch.isolation.high.risk<-ggplot(effect.degree.patch.isolation.high.risk, aes(x=degree_patch_isolation, y=.value, fill=.class, color=.class)) +
  geom_point(shape=21) +
  xlab("Degree patch isolation") + 
  ylab("Prob. high-risk transitions") +
  theme(legend.position="none", legend.title=element_blank(),
        legend.background = element_rect(fill="white", linetype="solid", size=0.25, colour="black"),
        legend.spacing.y=unit(0, "mm"), panel.border=element_rect(colour="black", fill=NA, size=0.5),
        legend.text=element_text(size=7),
        panel.background=element_rect(fill="white", colour="grey", size=0.5, linetype="solid"),
        panel.grid.major=element_line(size=0.25, linetype='dashed', colour="lightgrey"),
        panel.grid.minor=element_line(size=0.25, linetype='dashed', colour="lightgrey"), 
        plot.title=element_text(color="black", size=7, hjust=0), axis.title.x=element_text(size=7),
        axis.title.y=element_text(size=7), axis.text.x=element_text(size=7), 
        axis.text.y=element_text(size=7), legend.key=element_rect(fill="transparent", colour="transparent")) +
  geom_smooth(method="loess", se=TRUE, size=0.9) +
  scale_x_continuous(limits=c(5.7,11.8)) +
  scale_fill_manual(values=c("#FB8072")) +
  scale_color_manual(values=c("#FB8072"))
pdp.degree.patch.isolation.high.risk

pdp.matrix.condition.low.risk<-ggplot(effect.matrix.condition.low.risk, aes(x=high_hfp_extent_unsuitable, y=.value, fill=.class, color=.class)) +
  geom_point(shape=21) +
  xlab("High HFP extent matrix") + 
  ylab("Prob. low-risk transitions") +
  theme(legend.position="none", legend.title=element_blank(),
        legend.background = element_rect(fill="white", linetype="solid", size=0.25, colour="black"),
        legend.spacing.y=unit(0, "mm"), panel.border=element_rect(colour="black", fill=NA, size=0.5),
        legend.text=element_text(size=7),
        panel.background=element_rect(fill="white", colour="grey", size=0.5, linetype="solid"),
        panel.grid.major=element_line(size=0.25, linetype='dashed', colour="lightgrey"),
        panel.grid.minor=element_line(size=0.25, linetype='dashed', colour="lightgrey"), 
        plot.title=element_text(color="black", size=7, hjust=0), axis.title.x=element_text(size=7),
        axis.title.y=element_text(size=7), axis.text.x=element_text(size=7), 
        axis.text.y=element_text(size=7), legend.key=element_rect(fill="transparent", colour="transparent")) +
  geom_smooth(method="loess", size=0.9) +
  scale_fill_manual(values=c("#80B1D3")) +
  scale_color_manual(values=c("#80B1D3"))
pdp.matrix.condition.low.risk

pdp.matrix.condition.high.risk<-ggplot(effect.matrix.condition.high.risk, aes(x=high_hfp_extent_unsuitable, y=.value, fill=.class, color=.class)) +
  geom_point(shape=21) +
  xlab("High HFP extent matrix") + 
  ylab("Prob. high-risk transitions") +
  theme(legend.position="none", legend.title=element_blank(),
        legend.background = element_rect(fill="white", linetype="solid", size=0.25, colour="black"),
        legend.spacing.y=unit(0, "mm"), panel.border=element_rect(colour="black", fill=NA, size=0.5),
        legend.text=element_text(size=7),
        panel.background=element_rect(fill="white", colour="grey", size=0.5, linetype="solid"),
        panel.grid.major=element_line(size=0.25, linetype='dashed', colour="lightgrey"),
        panel.grid.minor=element_line(size=0.25, linetype='dashed', colour="lightgrey"), 
        plot.title=element_text(color="black", size=7, hjust=0), axis.title.x=element_text(size=7),
        axis.title.y=element_text(size=7), axis.text.x=element_text(size=7), 
        axis.text.y=element_text(size=7), legend.key=element_rect(fill="transparent", colour="transparent")) +
  geom_smooth(method="loess", se=TRUE, size=0.9) +
  scale_fill_manual(values=c("#FB8072")) +
  scale_color_manual(values=c("#FB8072"))
pdp.matrix.condition.high.risk

#png("pdp.png", units="in", width=8, height=2.8, res=1200, type="cairo")
ggarrange(pdp.degree.fragmentation.high.risk, pdp.degree.patch.isolation.high.risk, pdp.matrix.condition.high.risk,
          labels=c("a", "b", "c"),
          ncol=3, nrow=1,
          common.legend=FALSE, legend="none", align="hv",
          font.label=list(size=7))
#dev.off()
