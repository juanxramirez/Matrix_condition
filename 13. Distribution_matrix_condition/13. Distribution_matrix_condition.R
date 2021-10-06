#Install required packages
if(!requireNamespace("dplyr", quietly=TRUE))
  install.packages("dplyr", quiet=TRUE, dependencies=TRUE)
if(!requireNamespace("data.table", quietly=TRUE))
  install.packages("data.table", quiet=TRUE, dependencies=TRUE)
if(!requireNamespace("plyr", quietly=TRUE))
  install.packages("plyr", quiet=TRUE, dependencies=TRUE)
if(!requireNamespace("ggplot2", quietly=TRUE))
  install.packages("ggplot2", quiet=TRUE, dependencies=TRUE)

library(dplyr)
library(data.table)
library(plyr)
library(ggplot2)

#Set directory
setwd("/myfolder")

#Import data
highHFP.drivers<-read.delim("/myfolder/data_high_medium_first_last.txt")

#Check variables
str(highHFP.drivers)

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

#Extract matrix condition and extinction risk transitions
matrix.condition<-data.table(matrix.condition.global=highHFP.drivers$high_hfp_extent_unsuitable, transition=highHFP.drivers$trans_first_last)
matrix.condition.na.omit<-na.omit(matrix.condition)

#Extract number of high-risk and low-risk species
table(matrix.condition.na.omit$transition)

#Calculate mean values
mu_matrix.condition<-ddply(matrix.condition.na.omit, "transition", summarise, grp.mean=mean(matrix.condition.global))
head(mu_matrix.condition)

#Plot distribution of the matrix condition
matrix.condition.na.omit$transition<-factor(matrix.condition.na.omit$transition, levels=c("Low-risk", "High-risk"))
#png("matrix_condition_global.png", units="in", width=6, height=4.5, res=1200, type="cairo")
dist.matrix.condition<-ggplot(matrix.condition.na.omit, aes(x=matrix.condition.global)) +
  geom_density(aes(colour=transition), show.legend=FALSE, alpha=0.3) +
  xlab("High HFP extent matrix") + 
  ylab("Density") +
  theme(legend.position="bottom", legend.title=element_blank(),
        legend.background = element_rect(fill="white", linetype="solid", size=0.25, colour="white"),
        legend.spacing.y=unit(0, "mm"), panel.border=element_rect(colour="black", fill=NA, size=0.5),
        legend.text=element_text(size=7),
        panel.background=element_rect(fill="white", colour="grey", size=0.5, linetype="solid"),
        panel.grid.major=element_line(size=0.25, linetype='dashed', colour="lightgrey"),
        panel.grid.minor=element_line(size=0.25, linetype='dashed', colour="lightgrey"), 
        plot.title=element_text(color="black", size=7, hjust=0), axis.title.x=element_text(size=7),
        axis.title.y=element_text(size=7), axis.text.x=element_text(size=7), 
        axis.text.y=element_text(size=7), legend.key=element_rect(fill="transparent", colour="transparent")) +
  scale_x_continuous(limits=c(0,100)) +
  scale_color_manual(values=c("#80B1D3", "#FB8072")) +
  ggtitle("Global") +
  geom_vline(data=mu_matrix.condition, aes(xintercept=grp.mean, colour=transition), linetype="dashed", show.legend=FALSE) +
  stat_density(aes(x=matrix.condition.global, colour=transition), geom="line", position="identity")
dist.matrix.condition
#dev.off()

#Extract matrix condition for each biogeographic realm
matrix.Neotropical<-highHFP.drivers %>% filter(realm=="Neotropical")
matrix.Neotropical.realm<-data.table(matrix.Neotropical=matrix.Neotropical$high_hfp_extent_unsuitable, transition.matrix.Neotropical=matrix.Neotropical$trans_first_last)
matrix.Neotropical.realm.na.omit<-na.omit(matrix.Neotropical.realm)

matrix.Afrotropical<-highHFP.drivers %>% filter(realm=="Afrotropical")
matrix.Afrotropical.realm<-data.table(matrix.Afrotropical=matrix.Afrotropical$high_hfp_extent_unsuitable, transition.matrix.Afrotropical=matrix.Afrotropical$trans_first_last)
matrix.Afrotropical.realm.na.omit<-na.omit(matrix.Afrotropical.realm)

matrix.Indomalayan<-highHFP.drivers %>% filter(realm=="Indomalayan")
matrix.Indomalayan.realm<-data.table(matrix.Indomalayan=matrix.Indomalayan$high_hfp_extent_unsuitable, transition.matrix.Indomalayan=matrix.Indomalayan$trans_first_last)
matrix.Indomalayan.realm.na.omit<-na.omit(matrix.Indomalayan.realm)

matrix.Australasian<-highHFP.drivers %>% filter(realm=="Australasian")
matrix.Australasian.realm<-data.table(matrix.Australasian=matrix.Australasian$high_hfp_extent_unsuitable, transition.matrix.Australasian=matrix.Australasian$trans_first_last)
matrix.Australasian.realm.na.omit<-na.omit(matrix.Australasian.realm)

matrix.Palearctic<-highHFP.drivers %>% filter(realm=="Palearctic")
matrix.Palearctic.realm<-data.table(matrix.Palearctic=matrix.Palearctic$high_hfp_extent_unsuitable, transition.matrix.Palearctic=matrix.Palearctic$trans_first_last)
matrix.Palearctic.realm.na.omit<-na.omit(matrix.Palearctic.realm)

matrix.Nearctic<-highHFP.drivers %>% filter(realm=="Nearctic")
matrix.Nearctic.realm<-data.table(matrix.Nearctic=matrix.Nearctic$high_hfp_extent_unsuitable, transition.matrix.Nearctic=matrix.Nearctic$trans_first_last)
matrix.Nearctic.realm.na.omit<-na.omit(matrix.Nearctic.realm)

#Calculate mean values
mu_Neotropical<-ddply(matrix.Neotropical.realm.na.omit, "transition.matrix.Neotropical", summarise, grp.mean=mean(matrix.Neotropical))
head(mu_Neotropical)

mu_Afrotropical<-ddply(matrix.Afrotropical.realm.na.omit, "transition.matrix.Afrotropical", summarise, grp.mean=mean(matrix.Afrotropical))
head(mu_Afrotropical)

mu_Indomalayan<-ddply(matrix.Indomalayan.realm.na.omit, "transition.matrix.Indomalayan", summarise, grp.mean=mean(matrix.Indomalayan))
head(mu_Indomalayan)

mu_Australasian<-ddply(matrix.Australasian.realm.na.omit, "transition.matrix.Australasian", summarise, grp.mean=mean(matrix.Australasian))
head(mu_Australasian)

mu_Palearctic<-ddply(matrix.Palearctic.realm.na.omit, "transition.matrix.Palearctic", summarise, grp.mean=mean(matrix.Palearctic))
head(mu_Palearctic)

mu_Nearctic<-ddply(matrix.Nearctic.realm.na.omit, "transition.matrix.Nearctic", summarise, grp.mean=mean(matrix.Nearctic))
head(mu_Nearctic)

#Plot distribution of the matrix condition for each biogeographic realm
matrix.Neotropical.realm.na.omit$transition.matrix.Neotropical<-factor(matrix.Neotropical.realm.na.omit$transition.matrix.Neotropical, levels=c("Low-risk", "High-risk"))
#png("matrix_condition_Neotropical.png", units="in", width=6, height=4.5, res=1200, type="cairo")
dist.matrix.Neotropical<-ggplot(matrix.Neotropical.realm.na.omit, aes(x=matrix.Neotropical)) +
  geom_density(aes(colour=transition.matrix.Neotropical), show.legend=FALSE, alpha=0.3) +
  xlab("High HFP extent matrix") + 
  ylab("Density") +
  theme(legend.position="bottom", legend.title=element_blank(),
        legend.background = element_rect(fill="white", linetype="solid", size=0.25, colour="white"),
        legend.spacing.y=unit(0, "mm"), panel.border=element_rect(colour="black", fill=NA, size=0.5),
        legend.text=element_text(size=7),
        panel.background=element_rect(fill="white", colour="grey", size=0.5, linetype="solid"),
        panel.grid.major=element_line(size=0.25, linetype='dashed', colour="lightgrey"),
        panel.grid.minor=element_line(size=0.25, linetype='dashed', colour="lightgrey"), 
        plot.title=element_text(color="black", size=7, hjust=0), axis.title.x=element_text(size=7),
        axis.title.y=element_text(size=7), axis.text.x=element_text(size=7), 
        axis.text.y=element_text(size=7), legend.key=element_rect(fill="transparent", colour="transparent")) +
  scale_x_continuous(limits=c(0,100)) +
  scale_color_manual(values=c("#80B1D3", "#FB8072")) +
  ggtitle("Neotropical") +
  geom_vline(data=mu_Neotropical, aes(xintercept=grp.mean, colour=transition.matrix.Neotropical), linetype="dashed", show.legend=FALSE) +
  stat_density(aes(x=matrix.Neotropical, colour=transition.matrix.Neotropical), geom="line", position="identity")
dist.matrix.Neotropical
#dev.off()

matrix.Afrotropical.realm.na.omit$transition.matrix.Afrotropical<-factor(matrix.Afrotropical.realm.na.omit$transition.matrix.Afrotropical, levels=c("Low-risk", "High-risk"))
#png("matrix_condition_Afrotropical.png", units="in", width=6, height=4.5, res=1200, type="cairo")
dist.matrix.Afrotropical<-ggplot(matrix.Afrotropical.realm.na.omit, aes(x=matrix.Afrotropical)) +
  geom_density(aes(colour=transition.matrix.Afrotropical), show.legend=FALSE, alpha=0.3) +
  xlab("High HFP extent matrix") + 
  ylab("Density") +
  theme(legend.position="bottom", legend.title=element_blank(),
        legend.background = element_rect(fill="white", linetype="solid", size=0.25, colour="white"),
        legend.spacing.y=unit(0, "mm"), panel.border=element_rect(colour="black", fill=NA, size=0.5),
        legend.text=element_text(size=7),
        panel.background=element_rect(fill="white", colour="grey", size=0.5, linetype="solid"),
        panel.grid.major=element_line(size=0.25, linetype='dashed', colour="lightgrey"),
        panel.grid.minor=element_line(size=0.25, linetype='dashed', colour="lightgrey"), 
        plot.title=element_text(color="black", size=7, hjust=0), axis.title.x=element_text(size=7),
        axis.title.y=element_text(size=7), axis.text.x=element_text(size=7), 
        axis.text.y=element_text(size=7), legend.key=element_rect(fill="transparent", colour="transparent")) +
  scale_x_continuous(limits=c(0,100)) +
  scale_color_manual(values=c("#80B1D3", "#FB8072")) +
  ggtitle("Afrotropical") +
  geom_vline(data=mu_Afrotropical, aes(xintercept=grp.mean, colour=transition.matrix.Afrotropical), linetype="dashed", show.legend=FALSE) +
  stat_density(aes(x=matrix.Afrotropical, colour=transition.matrix.Afrotropical), geom="line", position="identity")
dist.matrix.Afrotropical
#dev.off()

matrix.Indomalayan.realm.na.omit$transition.matrix.Indomalayan<-factor(matrix.Indomalayan.realm.na.omit$transition.matrix.Indomalayan, levels=c("Low-risk", "High-risk"))
#png("matrix_condition_Indomalayan.png", units="in", width=6, height=4.5, res=1200, type="cairo")
dist.matrix.Indomalayan<-ggplot(matrix.Indomalayan.realm.na.omit, aes(x=matrix.Indomalayan)) +
  geom_density(aes(colour=transition.matrix.Indomalayan), show.legend=FALSE, alpha=0.3) +
  xlab("High HFP extent matrix") + 
  ylab("Density") +
  theme(legend.position="bottom", legend.title=element_blank(),
        legend.background = element_rect(fill="white", linetype="solid", size=0.25, colour="white"),
        legend.spacing.y=unit(0, "mm"), panel.border=element_rect(colour="black", fill=NA, size=0.5),
        legend.text=element_text(size=7),
        panel.background=element_rect(fill="white", colour="grey", size=0.5, linetype="solid"),
        panel.grid.major=element_line(size=0.25, linetype='dashed', colour="lightgrey"),
        panel.grid.minor=element_line(size=0.25, linetype='dashed', colour="lightgrey"), 
        plot.title=element_text(color="black", size=7, hjust=0), axis.title.x=element_text(size=7),
        axis.title.y=element_text(size=7), axis.text.x=element_text(size=7), 
        axis.text.y=element_text(size=7), legend.key=element_rect(fill="transparent", colour="transparent")) +
  scale_x_continuous(limits=c(0,100)) +
  scale_color_manual(values=c("#80B1D3", "#FB8072")) +
  ggtitle("Indomalayan") +
  geom_vline(data=mu_Indomalayan, aes(xintercept=grp.mean, colour=transition.matrix.Indomalayan), linetype="dashed", show.legend=FALSE) +
  stat_density(aes(x=matrix.Indomalayan, colour=transition.matrix.Indomalayan), geom="line", position="identity")
dist.matrix.Indomalayan
#dev.off()

matrix.Australasian.realm.na.omit$transition.matrix.Australasian<-factor(matrix.Australasian.realm.na.omit$transition.matrix.Australasian, levels=c("Low-risk", "High-risk"))
#png("matrix_condition_Australasian.png", units="in", width=6, height=4.5, res=1200, type="cairo")
dist.matrix.Australasian<-ggplot(matrix.Australasian.realm.na.omit, aes(x=matrix.Australasian)) +
  geom_density(aes(colour=transition.matrix.Australasian), show.legend=FALSE, alpha=0.3) +
  xlab("High HFP extent matrix") + 
  ylab("Density") +
  theme(legend.position="bottom", legend.title=element_blank(),
        legend.background = element_rect(fill="white", linetype="solid", size=0.25, colour="white"),
        legend.spacing.y=unit(0, "mm"), panel.border=element_rect(colour="black", fill=NA, size=0.5),
        legend.text=element_text(size=7),
        panel.background=element_rect(fill="white", colour="grey", size=0.5, linetype="solid"),
        panel.grid.major=element_line(size=0.25, linetype='dashed', colour="lightgrey"),
        panel.grid.minor=element_line(size=0.25, linetype='dashed', colour="lightgrey"), 
        plot.title=element_text(color="black", size=7, hjust=0), axis.title.x=element_text(size=7),
        axis.title.y=element_text(size=7), axis.text.x=element_text(size=7), 
        axis.text.y=element_text(size=7), legend.key=element_rect(fill="transparent", colour="transparent")) +
  scale_x_continuous(limits=c(0,100)) +
  scale_color_manual(values=c("#80B1D3", "#FB8072")) +
  ggtitle("Australasian") +
  geom_vline(data=mu_Australasian, aes(xintercept=grp.mean, colour=transition.matrix.Australasian), linetype="dashed", show.legend=FALSE) +
  stat_density(aes(x=matrix.Australasian, colour=transition.matrix.Australasian), geom="line", position="identity")
dist.matrix.Australasian
#dev.off()

matrix.Palearctic.realm.na.omit$transition.matrix.Palearctic<-factor(matrix.Palearctic.realm.na.omit$transition.matrix.Palearctic, levels=c("Low-risk", "High-risk"))
#png("matrix_condition_Palearctic.png", units="in", width=6, height=4.5, res=1200, type="cairo")
dist.matrix.Palearctic<-ggplot(matrix.Palearctic.realm.na.omit, aes(x=matrix.Palearctic)) +
  geom_density(aes(colour=transition.matrix.Palearctic), show.legend=FALSE, alpha=0.3) +
  xlab("High HFP extent matrix") + 
  ylab("Density") +
  theme(legend.position="bottom", legend.title=element_blank(),
        legend.background = element_rect(fill="white", linetype="solid", size=0.25, colour="white"),
        legend.spacing.y=unit(0, "mm"), panel.border=element_rect(colour="black", fill=NA, size=0.5),
        legend.text=element_text(size=7),
        panel.background=element_rect(fill="white", colour="grey", size=0.5, linetype="solid"),
        panel.grid.major=element_line(size=0.25, linetype='dashed', colour="lightgrey"),
        panel.grid.minor=element_line(size=0.25, linetype='dashed', colour="lightgrey"), 
        plot.title=element_text(color="black", size=7, hjust=0), axis.title.x=element_text(size=7),
        axis.title.y=element_text(size=7), axis.text.x=element_text(size=7), 
        axis.text.y=element_text(size=7), legend.key=element_rect(fill="transparent", colour="transparent")) +
  scale_x_continuous(limits=c(0,100)) +
  scale_color_manual(values=c("#80B1D3", "#FB8072")) +
  ggtitle("Palearctic") +
  geom_vline(data=mu_Palearctic, aes(xintercept=grp.mean, colour=transition.matrix.Palearctic), linetype="dashed", show.legend=FALSE) +
  stat_density(aes(x=matrix.Palearctic, colour=transition.matrix.Palearctic), geom="line", position="identity")
dist.matrix.Palearctic
#dev.off()

matrix.Nearctic.realm.na.omit$transition.matrix.Nearctic<-factor(matrix.Nearctic.realm.na.omit$transition.matrix.Nearctic, levels=c("Low-risk", "High-risk"))
#png("matrix_condition_Nearctic.png", units="in", width=6, height=4.5, res=1200, type="cairo")
dist.matrix.Nearctic<-ggplot(matrix.Nearctic.realm.na.omit, aes(x=matrix.Nearctic)) +
  geom_density(aes(colour=transition.matrix.Nearctic), show.legend=FALSE, alpha=0.3) +
  xlab("High HFP extent matrix") + 
  ylab("Density") +
  theme(legend.position="bottom", legend.title=element_blank(),
        legend.background = element_rect(fill="white", linetype="solid", size=0.25, colour="white"),
        legend.spacing.y=unit(0, "mm"), panel.border=element_rect(colour="black", fill=NA, size=0.5),
        legend.text=element_text(size=7),
        panel.background=element_rect(fill="white", colour="grey", size=0.5, linetype="solid"),
        panel.grid.major=element_line(size=0.25, linetype='dashed', colour="lightgrey"),
        panel.grid.minor=element_line(size=0.25, linetype='dashed', colour="lightgrey"), 
        plot.title=element_text(color="black", size=7, hjust=0), axis.title.x=element_text(size=7),
        axis.title.y=element_text(size=7), axis.text.x=element_text(size=7), 
        axis.text.y=element_text(size=7), legend.key=element_rect(fill="transparent", colour="transparent")) +
  scale_x_continuous(limits=c(0,100)) +
  scale_color_manual(values=c("#80B1D3", "#FB8072")) +
  ggtitle("Nearctic") +
  geom_vline(data=mu_Nearctic, aes(xintercept=grp.mean, colour=transition.matrix.Nearctic), linetype="dashed", show.legend=FALSE) +
  stat_density(aes(x=matrix.Nearctic, colour=transition.matrix.Nearctic), geom="line", position="identity")
dist.matrix.Nearctic
#dev.off()
