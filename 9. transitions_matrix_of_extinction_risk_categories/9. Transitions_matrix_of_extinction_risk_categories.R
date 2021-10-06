#Install required packages
if(!requireNamespace("ggplot2", quietly=TRUE))
  install.packages("ggplot2", quiet=TRUE, dependencies=TRUE)

library(ggplot2)

#set directory
setwd("/myfolder")

#Import data
extinction_risk_transitions_first_last<-read.delim("/myfolder/first_last.txt")

#Plot transition matrix of extinction risk categories between 1996 and 2020
#png("transitions_first_last_final.png", units="in", width=4, height=4, res=1200, type="cairo")
extinction_risk_transition_first_last_plot<-ggplot(extinction_risk_transitions_first_last, aes(x=first, y=last)) +
  geom_tile(aes(fill=asin_transform)) +
  scale_x_discrete(name="First IUCN Red List category 1996-2020", limits=c("LC","NT", "VU", "EN", "CR")) +
  scale_y_discrete(name="Last IUCN Red List category 1996-2020", limits=c("LC","NT", "VU", "EN", "CR")) +
  theme(legend.position="right", panel.grid.major=element_line(colour="grey", linetype="dotted"), 
        panel.grid.minor=element_line(size=2), legend.text=element_text(size=7), 
        plot.title=element_text(color="black", size=9, hjust=0), 
        axis.title.x=element_text(size=7), axis.text.x=element_text(size=7), 
        axis.title.y=element_text(size=7), axis.text.y=element_text(size=7), 
        panel.ontop=TRUE, panel.background=element_rect(color=TRUE, fill=NA)) +
  coord_fixed() +
  scale_fill_gradient2(name="", breaks=c(0.0149,0.1308,0.9560), labels=c("Min","","Max"), 
                       limits=c(0.0149,0.9560), low="lightyellow", mid="lightyellow", 
                       high="darkgreen", space="Lab", na.value="transparent",
                       guide="colourbar", aesthetics="fill") +
  guides(fill=guide_colourbar(barwidth=0.5, barheight=14, label=TRUE, ticks=FALSE, guide_legend(title="")))
extinction_risk_transition_first_last_plot
#dev.off()
