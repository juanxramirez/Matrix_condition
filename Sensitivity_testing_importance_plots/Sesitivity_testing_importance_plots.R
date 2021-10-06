#Install required packages
if(!requireNamespace("ggplot2", quietly=TRUE))
  install.packages("ggplot2", quiet=TRUE, dependencies=TRUE)
if(!requireNamespace("ggpubr", quietly=TRUE))
  install.packages("ggpubr", quiet=TRUE, dependencies=TRUE)

library(ggplot2)
library(ggpubr)

#Set directory
setwd("/myfolder")

#Import relative importance scores
high.medium<-read.csv("/myfolder/Relative_importance_scores_high_medium_first_last.csv", sep="\t")
medium.unsuitable<-read.csv("/myfolder/Relative_importance_scores_medium_unsuitable_first_last.csv", sep="\t")

#Order classes
high.medium$class<-factor(high.medium$class, levels=c("Pressure", "Environment", "Life-history"))
medium.unsuitable$class<-factor(medium.unsuitable$class, levels=c("Pressure", "Environment", "Life-history"))

#Plot variable importance
plot.var.importance.high.medium<-ggplot(high.medium, aes(x=reorder(names, mir.metric.high.medium.first.last), y=mir.metric.high.medium.first.last)) +
  geom_bar(aes(y=mir.metric.high.medium.first.last, fill=class), stat="identity") +
  geom_hline(yintercept=0, colour="white", lwd=1) +
  coord_flip() + 
  labs(y="Variable importance (high and medium suitability combined)", x="") +
  theme(legend.position="bottom", legend.title=element_blank(), 
        panel.border=element_rect(colour="black", fill=NA, size=0.5), legend.text=element_text(size=7), 
        panel.background=element_rect(fill="white", colour="grey", size=0.5, linetype="solid"), 
        panel.grid.major=element_line(size=0.25, linetype="dashed", colour="lightgrey"), 
        panel.grid.minor=element_line(size=0.25, linetype="dashed", colour="lightgrey"), 
        plot.title=element_text(color="black", size=7, hjust=0), axis.title.x=element_text(size=7), 
        axis.text.x=element_text(size=7), axis.text.y=element_text(size=7)) +
  scale_fill_brewer(palette="Set2")
plot.var.importance.high.medium

plot.var.importance.medium.unsuitable<-ggplot(medium.unsuitable, aes(x=reorder(names, mir.metric.medium.unsuitable.first.last), y=mir.metric.medium.unsuitable.first.last)) +
  geom_bar(aes(y=mir.metric.medium.unsuitable.first.last, fill=class), stat="identity") +
  geom_hline(yintercept=0, colour="white", lwd=1) +
  coord_flip() + 
  labs(y="Variable importance (medium suitability and unsuitable combined)", x="") +
  theme(legend.position="bottom", legend.title=element_blank(), 
        panel.border=element_rect(colour="black", fill=NA, size=0.5), legend.text=element_text(size=7), 
        panel.background=element_rect(fill="white", colour="grey", size=0.5, linetype="solid"), 
        panel.grid.major=element_line(size=0.25, linetype="dashed", colour="lightgrey"), 
        panel.grid.minor=element_line(size=0.25, linetype="dashed", colour="lightgrey"), 
        plot.title=element_text(color="black", size=7, hjust=0), axis.title.x=element_text(size=7), 
        axis.text.x=element_text(size=7), axis.text.y=element_text(size=7)) +
  scale_fill_brewer(palette="Set2")
plot.var.importance.medium.unsuitable

#png("var.importance_sensitivity_analysis.png", units="in", width=6, height=6, res=1200, type="cairo")
ggarrange(plot.var.importance.high.medium, plot.var.importance.medium.unsuitable, 
          labels=c("a", "b"),
          ncol=1, nrow=2,
          common.legend=TRUE, legend="bottom", align="hv",
          font.label=list(size=7))
#dev.off()
