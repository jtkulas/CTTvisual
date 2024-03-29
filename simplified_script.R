

```{r setup, include = FALSE}

library(psych)
library(reticulate)
```

```{r analysis-preferences}
# Seed for random number generation
set.seed(42)
knitr::opts_chunk$set(cache.extra = knitr::rand_seed, echo=FALSE, warning=FALSE, message=FALSE)
```


```{r plotting, results="hide", fig.cap="Four ICCs showcasing the difference between CTT and IRT-derivated curves at different levels." }

data<-read.csv("simulated_data.csv", header=FALSE)#LOADING SIMULATED DATA
library(mirt)#PACKAGE FOR IRT STUFF
library(latticeExtra)#PACKAGE FOR MERGING PLOTS
pseudob<-0 #JUST CREATING A PLACEHOLDER FOR pseudob SO THE FUNCTION BELOW CAN RUN
ahat<-function(x){
  r<-(((2.71828)^x)-(1/(2.71828)^x))/(2.71828-(2.71828)^x)
  
  ((0.51+(0.02*pseudob)+(0.301*pseudob^2))*r)+((0.57-(0.009*pseudob)+(0.19*pseudob^2))*r)
  
}#FUNCTION TO ESTIMATE THE CTT-A STATISTIC, WHICH IS THE EQUIVALENT TO THE DISCRIMINATION STATISTIC IN IRT

mod<-mirt(data, 1, itemtype="2PL")#COMPUTING IRT STATISTICS FOR ALL 100 ITEMS

alphas<-alpha(data)#COMPUTING ALPHAS FOR ALL 100 ITEMS. WE NEED THIS IN ORDER TO GET THE CORRECTED ITEM-TOTAL CORRELATIONS, WHICH WE THEN USE FOR COMPUTING THE CTT-A STATISTIC. 
citcs<-data.frame(alphas$item.stats$r.drop)#ACCESSING THE CORRECTED ITEM-TOTAL CORRELATIONS INSIDE alphas.
pseudoA<-data.frame(ahat(citcs))#USING THE ahat FUNCTION TO CALCULATE THE CTT-A PARAMETER FOR ALL 100 ITEMS. CORRECTED ITEM-TOTAL CORRELATION ARE ENTERED AS AN ARGUMENT.
pseudoB<-data.frame(qnorm(colMeans(data)))#CALCULATING THE CTT-B PARAMETER, WHICH IS JUST THE PROBABILITIES OF ANSWERING RIGHT FOR EACH ITEM. 
IRT_parms <- coef(mod, IRTpars = TRUE, simplify = TRUE)#GETTING THE IRT STATISTIC FROM THE mod OBJECT WE CREATED BEFORE
irt <- IRT_parms$items #SELECTING ONLY A AND B STATISTIC FROM THE PREVIOUS OBJECT. 
df<-as.data.frame(cbind(citcs, pseudoA, pseudoB, irt))#PUTTING ALL RELEVANT STATISTIC TOGETHER
colnames(df)<-c("CITC", "PseudoA", "PseudoB", "a", "b", "c1", "c2")#RENAMING COLUMN HEADERS


lm.reg<-lm(b ~PseudoB, data=df)#CREATING A REGRESSION MODEL USING b AS THE CRITERION AND PseudoB AS THE PREDICTOR. NEED THIS TO PUT EVERYTHING IN THE SAME SCALE.
 

b<-0.01479-(-1.33142*pseudoB)#PREDICTING A NEW b USING THE COEFFICIENTs FROM THE REGRESSION MODEL AND pseudoB
dat<-data.frame(b, alphas$item.stats$r.drop)#PUTTING NEW b AND CORRECTED ITEM-TOTAL CORRELATION IN A DATA FRAME
colnames(dat)<-c("b", "corrected item totals")# RENAMING COLUMN HEADERS


###############################################################
pseudob<-dat$b[47]#SELECTING CTT-b FOR ITEM 47
ahat<-function(x, plot){
  r<-(((2.71828)^x)-(1/(2.71828)^x))/(2.71828-(2.71828)^x)
  
  ((0.51+(0.02*pseudob)+(0.301*pseudob^2))*r)+((0.57-(0.009*pseudob)+(0.19*pseudob^2))*r)
  
  
}

pseudoa<-ahat(dat$`corrected item totals`[47])#CALCULATING CTT-a FOR ITEM 47
c <- 0

eq <- function(x){c + ((1-c)*(1/(1+2.71828^(-1.7*(pseudoa*(x-pseudob))))))}#FUNCTION THAT CREATES ICC BASED ON pseudob AND pseudoa

p1<-plot(mod, which.items=c(47), main=FALSE, sub="Moderate DIF \n(area between curves = 0.36 )", cex.sub=0.2)+latticeExtra::layer(panel.curve(eq, col="red"))#PLOTTING CTT-ICC AND IRT-ICC SIDE BY SIDE.
################################################################
#SAME COMMENTS AS FOR ITEM 47
pseudob2<-dat$b[1]
ahat<-function(x){
  r<-(((2.71828)^x)-(1/(2.71828)^x))/(2.71828-(2.71828)^x)
  
  ((0.51+(0.02*pseudob2)+(0.301*pseudob2^2))*r)+((0.57-(0.009*pseudob2)+(0.19*pseudob2^2))*r)
  
}

pseudoa2<-ahat(dat$`corrected item totals`[1])
c <- 0

eq2 <- function(x){c + ((1-c)*(1/(1+2.71828^(-1.7*(pseudoa2*(x-pseudob2))))))}

p2<-plot(mod, which.items=c(1),main=FALSE, sub="Small DIF \n(area between curves = 0.03)", cex.sub=0.2)+latticeExtra::layer(panel.curve(eq2, col="red"))


#####################################################################

pseudob3<-dat$b[54]
ahat<-function(x){
  r<-(((2.71828)^x)-(1/(2.71828)^x))/(2.71828-(2.71828)^x)
  
  ((0.51+(0.02*pseudob3)+(0.301*pseudob3^2))*r)+((0.57-(0.009*pseudob3)+(0.19*pseudob3^2))*r)
  
}

pseudoa3<-ahat(dat$`corrected item totals`[54])
c <- 0

eq3 <- function(x){c + ((1-c)*(1/(1+2.71828^(-1.7*(pseudoa3*(x-pseudob3))))))}

p3<-plot(mod, which.items=c(54), main=FALSE, sub="Small DIF \n(area between curves  = 0.09)", cex.sub=0.2)+latticeExtra::layer(panel.curve(eq3, col="red"))

###############################################################################
pseudob4<- dat$b[25]
ahat<-function(x){
  r<-(((2.71828)^x)-(1/(2.71828)^x))/(2.71828-(2.71828)^x)
  
  ((0.51+(0.02*pseudob4)+(0.301*pseudob4^2))*r)+((0.57-(0.009*pseudob4)+(0.19*pseudob4^2))*r)
  
}

pseudoa4<-ahat(dat$`corrected item totals`[25])
c <- 0

eq4 <- function(x){c + ((1-c)*(1/(1+2.71828^(-1.7*(pseudoa4*(x-pseudob4))))))}

p4<-plot(mod, which.items=c(25), main=FALSE, sub="Large DIF \n(area between curves = 0.81)", cex.main=5)+latticeExtra::layer(panel.curve(eq4, col="red", cex.sub=1))

###############################################################################
require(gridExtra)#PACKAGE NEEDED TO SHOW MULTIPLE PLOTS IN ONE GRAPH
grid.arrange(p2,p1,p3,p4, top="Item Characteristic Curves",nrow=2, ncol=2)#PUTTING ALL 4 PLOTS TOGETHER

##############################################################################



```

















