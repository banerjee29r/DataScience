install.packages('openxlsx')
library("openxlsx")
library('ggplot2')
library('rmarkdown')
mydata=read.xlsx(file.choose(), sheet = 1, startRow = 1, colNames = TRUE)
head(mydata)
summary(mydata)

names(mydata)


ano1<-aov(Uniquepageviews~Visits, data=mydata)
summary(ano1) 

ano2<-aov(Exits~Timeinpage+Continent+
           Sourcegroup+Bounces+Uniquepageviews+Visits, data=mydata)
summary(ano2)


ano3<-aov(Timeinpage~Exits+Continent+Sourcegroup+Bounces+
           Uniquepageviews+Visits, data=mydata)
summary(ano3)

mydata$Bounces=as.factor(mydata$Bounces)

reg1<-glm(Bounces~Timeinpage+Continent+Exits+
            Sourcegroup+Uniquepageviews+
            Visits, data=mydata,family="binomial")
summary(reg1)

rmarkdown::render("Internet project.R", "pdf_document")
