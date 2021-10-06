#Install required packages
if(!requireNamespace("dplyr", quietly=TRUE))
  install.packages("dplyr", quiet=TRUE, dependencies=TRUE)
if(!requireNamespace("data.table", quietly=TRUE))
  install.packages("data.table", quiet=TRUE, dependencies=TRUE)
if(!requireNamespace("plyr", quietly=TRUE))
  install.packages("plyr", quiet=TRUE, dependencies=TRUE)
if(!requireNamespace("ggpubr", quietly=TRUE))
  install.packages("ggpubr",quiet=TRUE, dependencies=TRUE)
if(!requireNamespace("effsize", quietly = TRUE))
  install.packages("effsize", quiet=TRUE, dependencies=TRUE)
if(!requireNamespace("ggplot2", quietly=TRUE))
  install.packages("ggplot2", quiet=TRUE, dependencies=TRUE)
if(!requireNamespace("cowplot", quietly=TRUE))
  install.packages("cowplot", quiet=TRUE, dependencies=TRUE)

library(dplyr)
library(data.table)
library(plyr)
library(ggpubr)
library(effsize)
library(ggplot2)
library(cowplot)

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

#Extract species for the two broad levels of quality of the matrix (low- and high-quality matrix)
low.quality.matrix<-highHFP.drivers %>% filter(high_hfp_extent_unsuitable>84.210526)
str(low.quality.matrix)
high.quality.matrix<-highHFP.drivers %>% filter(high_hfp_extent_unsuitable<15.789474)
str(high.quality.matrix)

#Remove species with missing values
low.quality.matrix.na.omit<-na.omit(low.quality.matrix)
high.quality.matrix.na.omit<-na.omit(high.quality.matrix)

#Create data table for the degree of fragmentation and the degree of patch isolation with a low-quality matrix and a high-quality matrix
degree.habitat.fragmentation.low.quality.matrix<-data.table(degree.habitat.fragmentation.low.quality.matrix=low.quality.matrix.na.omit$gisfrag_high_medium, transition.low.quality.matrix=low.quality.matrix.na.omit$trans_first_last)
degree.habitat.fragmentation.high.quality.matrix<-data.table(degree.habitat.fragmentation.high.quality.matrix=high.quality.matrix.na.omit$gisfrag_high_medium, transition.high.quality.matrix=high.quality.matrix.na.omit$trans_first_last)
degree.patch.isolation.low.quality.matrix<-data.table(degree.patch.isolation.low.quality.matrix=low.quality.matrix.na.omit$gisfrag_unsuitable, transition.low.quality.matrix=low.quality.matrix.na.omit$trans_first_last)
degree.patch.isolation.high.quality.matrix<-data.table(degree.patch.isolation.high.quality.matrix=high.quality.matrix.na.omit$gisfrag_unsuitable, transition.high.quality.matrix=high.quality.matrix.na.omit$trans_first_last)

#Create QQ plots to assess for normal distribution
ggqqplot(degree.habitat.fragmentation.low.quality.matrix$degree.habitat.fragmentation.low.quality.matrix, ylab="degree.habitat.fragmentation.low.quality.matrix")
ggqqplot(degree.habitat.fragmentation.high.quality.matrix$degree.habitat.fragmentation.high.quality.matrix, ylab="degree.habitat.fragmentation.high.quality.matrix")
ggqqplot(degree.patch.isolation.low.quality.matrix$degree.patch.isolation.low.quality.matrix, ylab="degree.patch.isolation.low.quality.matrix")
ggqqplot(degree.patch.isolation.high.quality.matrix$degree.patch.isolation.high.quality.matrix, ylab="degree.patch.isolation.high.quality.matrix")

#Run Wilcoxon rank sum test
degree.habitat.fragmentation.low.quality.matrix$transition.low.quality.matrix<-factor(degree.habitat.fragmentation.low.quality.matrix$transition.low.quality.matrix, levels=c("Low-risk", "High-risk"))
degree.habitat.fragmentation.high.quality.matrix$transition.high.quality.matrix<-factor(degree.habitat.fragmentation.high.quality.matrix$transition.high.quality.matrix, levels=c("Low-risk", "High-risk"))
wilcox.test(degree.habitat.fragmentation.low.quality.matrix~transition.low.quality.matrix, mu=0, alt="g", conf.inf=T, conf.level=0.95, paired=F, exact=T, correct=T, data=degree.habitat.fragmentation.low.quality.matrix)
wilcox.test(degree.habitat.fragmentation.high.quality.matrix~transition.high.quality.matrix, mu=0, alt="g", conf.inf=T, conf.level=0.95, paired=F, exact=T, correct=T, data=degree.habitat.fragmentation.high.quality.matrix)

degree.patch.isolation.low.quality.matrix$transition.low.quality.matrix<-factor(degree.patch.isolation.low.quality.matrix$transition.low.quality.matrix, levels=c("Low-risk", "High-risk"))
degree.patch.isolation.high.quality.matrix$transition.high.quality.matrix<-factor(degree.patch.isolation.high.quality.matrix$transition.high.quality.matrix, levels=c("Low-risk", "High-risk"))
wilcox.test(degree.patch.isolation.low.quality.matrix~transition.low.quality.matrix, mu=0, alt="g", conf.inf=T, conf.level=0.95, paired=F, exact=T, correct=T, data=degree.patch.isolation.low.quality.matrix)
wilcox.test(degree.patch.isolation.high.quality.matrix~transition.high.quality.matrix, mu=0, alt="g", conf.inf=T, conf.level=0.95, paired=F, exact=T, correct=T, data=degree.patch.isolation.high.quality.matrix)

#Run Cohen's d statistic
degree.habitat.frag.lqm<-degree.habitat.fragmentation.low.quality.matrix$degree.habitat.fragmentation.low.quality.matrix
trans.lqm<-degree.habitat.fragmentation.low.quality.matrix$transition.low.quality.matrix
cohen.d(degree.habitat.frag.lqm, trans.lqm)
cohens.d.degree.habitat.frag.lqm<-cohen.d(degree.habitat.frag.lqm, trans.lqm)
cohens.d.degree.habitat.frag.lqm.conf.interval<-data.frame(cohens.d.degree.habitat.frag.lqm$conf.int)
cohens.d.degree.habitat.frag.lqm.df<-data.frame(estimate=cohens.d.degree.habitat.frag.lqm$estimate, lower=cohens.d.degree.habitat.frag.lqm.conf.interval["lower",], upper=cohens.d.degree.habitat.frag.lqm.conf.interval["upper",], variable="Degree fragmentation")
degree.patch.isolation.lqm<-degree.patch.isolation.low.quality.matrix$degree.patch.isolation.low.quality.matrix
trans.lqm<-degree.patch.isolation.low.quality.matrix$transition.low.quality.matrix
cohen.d(degree.patch.isolation.lqm, trans.lqm)
cohens.d.degree.patch.isolation.lqm<-cohen.d(degree.patch.isolation.lqm, trans.lqm)
cohens.d.degree.patch.isolation.lqm.conf.interval<-data.frame(cohens.d.degree.patch.isolation.lqm$conf.int)
cohens.d.degree.patch.isolation.lqm.df<-data.frame(estimate=cohens.d.degree.patch.isolation.lqm$estimate, lower=cohens.d.degree.patch.isolation.lqm.conf.interval["lower",], upper=cohens.d.degree.patch.isolation.lqm.conf.interval["upper",], variable="Degree patch isolation")
cohens.d.statistics.lqm<-rbind(cohens.d.degree.habitat.frag.lqm.df, cohens.d.degree.patch.isolation.lqm.df)

degree.habitat.frag.hqm<-degree.habitat.fragmentation.high.quality.matrix$degree.habitat.fragmentation.high.quality.matrix
trans.hqm<-degree.habitat.fragmentation.high.quality.matrix$transition.high.quality.matrix
cohen.d(degree.habitat.frag.hqm, trans.hqm)
cohens.d.degree.habitat.frag.hqm<-cohen.d(degree.habitat.frag.hqm, trans.hqm)
cohens.d.degree.habitat.frag.hqm.conf.interval<-data.frame(cohens.d.degree.habitat.frag.hqm$conf.int)
cohens.d.degree.habitat.frag.hqm.df<-data.frame(estimate=cohens.d.degree.habitat.frag.hqm$estimate, lower=cohens.d.degree.habitat.frag.hqm.conf.interval["lower",], upper=cohens.d.degree.habitat.frag.hqm.conf.interval["upper",], variable="Degree fragmentation")
degree.patch.isolation.hqm<-degree.patch.isolation.high.quality.matrix$degree.patch.isolation.high.quality.matrix
trans.hqm<-degree.patch.isolation.high.quality.matrix$transition.high.quality.matrix
cohen.d(degree.patch.isolation.hqm, trans.hqm)
cohens.d.degree.patch.isolation.hqm<-cohen.d(degree.patch.isolation.hqm, trans.hqm)
cohens.d.degree.patch.isolation.hqm.conf.interval<-data.frame(cohens.d.degree.patch.isolation.hqm$conf.int)
cohens.d.degree.patch.isolation.hqm.df<-data.frame(estimate=cohens.d.degree.patch.isolation.hqm$estimate, lower=cohens.d.degree.patch.isolation.hqm.conf.interval["lower",], upper=cohens.d.degree.patch.isolation.hqm.conf.interval["upper",], variable="Degree patch isolation")
cohens.d.statistics.hqm<-rbind(cohens.d.degree.habitat.frag.hqm.df, cohens.d.degree.patch.isolation.hqm.df)

#Plot Cohen's d statistic results
#png("effect_size.png",height=3, width=3.5, units ="in", res = 1200, type = "cairo")
cohens.d.lqm.plot<-ggplot(cohens.d.statistics.lqm, aes(x=variable, y=estimate, colour=variable)) +
  #geom_line() +
  geom_errorbar(width=0.4, aes(ymin=lower, ymax=upper)) +
  geom_point(shape=21, size=3.5, fill="white") +
  labs(y="Cohen's d statistic (low-quality matrices)", x="") +
  theme_bw() +
  theme(legend.background=element_rect(fill="white", size=0.5, linetype="solid", colour="white"),
        legend.position="none", legend.title = element_blank(), legend.text=element_text(size=7),
        panel.border = element_rect(colour = "black", fill = NA, size = 0.5),
        panel.background = element_rect(fill = "white", colour = "grey", size = 0.5, linetype = "solid"), 
        panel.grid.major = element_line(size = 0.25, linetype = 'dashed', colour = "lightgrey"), 
        panel.grid.minor = element_line(size = 0.25, linetype = 'dashed', colour = "lightgrey"), 
        plot.title = element_text(color="black", size=7, hjust = 0.5), 
        axis.title.x = element_text(size = 7), axis.text.x = element_text(size = 7),
        axis.title.y = element_text(size = 7), axis.text.y = element_text(size = 7)) +
  scale_color_manual(values=c("#A6D854", "#FFD92F"))
cohens.d.lqm.plot
#dev.off()

degree.habitat.frag.hqm<-degree.habitat.fragmentation.high.quality.matrix$degree.habitat.fragmentation.high.quality.matrix
trans.hqm<-degree.habitat.fragmentation.high.quality.matrix$transition.high.quality.matrix
cohen.d(degree.habitat.frag.hqm, trans.hqm)
cohens.d.degree.habitat.frag.hqm<-cohen.d(degree.habitat.frag.hqm, trans.hqm)
cohens.d.degree.habitat.frag.hqm.conf.interval<-data.frame(cohens.d.degree.habitat.frag.hqm$conf.int)
cohens.d.degree.habitat.frag.hqm.df<-data.frame(estimate=cohens.d.degree.habitat.frag.hqm$estimate, lower=cohens.d.degree.habitat.frag.hqm.conf.interval["lower",], upper=cohens.d.degree.habitat.frag.hqm.conf.interval["upper",], variable="Degree fragmentation")
degree.patch.isolation.hqm<-degree.patch.isolation.high.quality.matrix$degree.patch.isolation.high.quality.matrix
trans.hqm<-degree.patch.isolation.high.quality.matrix$transition.high.quality.matrix
cohen.d(degree.patch.isolation.hqm, trans.hqm)
cohens.d.degree.patch.isolation.hqm<-cohen.d(degree.patch.isolation.hqm, trans.hqm)
cohens.d.degree.patch.isolation.hqm.conf.interval<-data.frame(cohens.d.degree.patch.isolation.hqm$conf.int)
cohens.d.degree.patch.isolation.hqm.df<-data.frame(estimate=cohens.d.degree.patch.isolation.hqm$estimate, lower=cohens.d.degree.patch.isolation.hqm.conf.interval["lower",], upper=cohens.d.degree.patch.isolation.hqm.conf.interval["upper",], variable="Degree patch isolation")
cohens.d.statistics.hqm<-rbind(cohens.d.degree.habitat.frag.hqm.df, cohens.d.degree.patch.isolation.hqm.df)

#png("effect_size.png",height=3, width=3.5, units ="in", res = 1200, type = "cairo")
cohens.d.hqm.plot<-ggplot(cohens.d.statistics.hqm, aes(x=variable, y=estimate, colour=variable)) +
  #geom_line() +
  geom_errorbar(width=0.4, aes(ymin=lower, ymax=upper)) +
  geom_point(shape=21, size=3.5, fill="white") +
  labs(y="Cohen's d statistic (high-quality matrices)", x="") +
  theme_bw() +
  theme(legend.background=element_rect(fill="white", size=0.5, linetype="solid", colour="white"),
        legend.position="none", legend.title = element_blank(), legend.text=element_text(size=7),
        panel.border = element_rect(colour = "black", fill = NA, size = 0.5),
        panel.background = element_rect(fill = "white", colour = "grey", size = 0.5, linetype = "solid"), 
        panel.grid.major = element_line(size = 0.25, linetype = 'dashed', colour = "lightgrey"), 
        panel.grid.minor = element_line(size = 0.25, linetype = 'dashed', colour = "lightgrey"), 
        plot.title = element_text(color="black", size=7, hjust = 0.5), 
        axis.title.x = element_text(size = 7), axis.text.x = element_text(size = 7),
        axis.title.y = element_text(size = 7), axis.text.y = element_text(size = 7)) +
  scale_color_manual(values=c("#A6D854", "#FFD92F"))
cohens.d.hqm.plot
#dev.off()

#png("effect_size.png", units="in", width=4, height=5, res=1200, type="cairo")
ggarrange(cohens.d.lqm.plot, cohens.d.hqm.plot, 
          labels=c("a", "b"),
          ncol=1, nrow=2,
          common.legend=TRUE, legend="none", align="hv",
          font.label=list(size=7))
#dev.off()

