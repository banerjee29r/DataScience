#Project retail
library("caTools")
library("forecast")
library("tseries")
library("corrplot")
library("arules")
Data<-read.csv(file.choose(),header = T)
head(Data)
names(Data)
#Objective 1:To automate the process of recommendations, the store needs to analyze the given attributes of the product, like style, season, etc., and come up with a model to predict the recommendation of products (in binary output - 0 or 1) accordingly.
#Removed the First column as it is not required for the model for objective 1 
Question1<-Data[,-1]

head(Question1)
class(Question1$Recommendation)
summary(Question1)
levels(Question1$Style)
#Model for this objective 1 
model<-glm(Recommendation~Style + Price + Rating + Size + Season + NeckLine +
             SleeveLength + waiseline + Material + FabricType + Decoration + Pattern.Type,Question1 ,family = "gaussian")
summary(model)
#For testing and validating if the model is good or not and is applicaple to any random data or is just confined to this data set we do the following steps but since in the objective it is not asked to test and validate i will not be running the below codes
#Spliting data into 75%train and 25%test
set.seed(1234)
split1 <- sample.split(Question1,SplitRatio = 0.75)
train1 <- subset(Question1,split == TRUE)
test1 <- subset(Question1,split == FALSE)
levels(train1$Style)
levels(test1$Style)
#making a column for prediction of recomendation
test1$recomendpred<-0

#making logistic model to perform on train1 data
model1<-glm(Recommendation~Style + Price + Rating + Size + Season + NeckLine +
              SleeveLength + waiseline + Material + FabricType + Decoration + Pattern.Type,train1,family = "gaussian")
summary(model1)
1-pchisq(model1$null.deviance-model1$deviance,355-221)
table(test1$Style)
predict1<-predict(model1,test1,type="response")
class(test1$Style)
levels(test1$Style)
levels(train1$Style)
class(train1$style)
head(test1$Style)
#taking cutoff as 0.7 for the probability
test1$recomendpred <- ifelse(predicted>=0.7,1,0)
test1$recomendpred

#testing by confusion matrix
table(test1$Recommendation,test1$recomendpred)

tab<-table(test1$Recommendation,test1$recomendpred)
#accuracy
sum(tab)
sum(diag(tab))/sum(tab)
#error
1-sum(diag(tab))/sum(tab)

#Objective 2:In order to stock the inventory, the store wants to analyze the sales data and predict the trend of total sales for each dress for an extended period of three more alternative days.

Sales<-read.csv(file.choose(),header = T)
head(Sales)

timeseries <- ts(Sales, start = 1, frequency = 7)
plot(timeseries)
ArimaModel <- auto.arima(timeseries)
summary(ArimaModel)
forecast(ArimaModel,3)
plot(forecast(ArimaModel,3))
#Objective 3:To decide the pricing for various upcoming clothes, they wish to find how the style, season, and material affect the sales of a dress and if the style of the dress is more influential than its price.

Data3<-read.csv(file.choose(),header = T)
head(Data3)
class(Data3$Total.Sales)
OutStyle<-aov(Data3$Total.Sales~Data3$Style)
Outseason<-aov(Data3$Total.Sales~Data3$Season)
Outmaterial<-aov(Data3$Total.Sales~Data3$Material)
summary(OutStyle)
summary(Outseason)
summary(Outmaterial)

model3a<-lm(Total.Sales~Style+Season+Material,data = Data3)
summary(model3a)

model3b<-lm(Total.Sales~Price+Style,data = Data3)
summary(model3b)

#Objective4:Also, to increase the sales, the management wants to analyze the attributes
#of dresses and find which are the leading factors affecting the sale of a
#dress.
model4<-lm(Total.Sales~.,data = Data3)
summary(model4)

#objective5:To regularize the rating procedure and find its efficiency, the store wants to
#find if the rating of the dress affects the total sales.
model5<-cor(Data3$Total.Sales,Data3$Rating)
model5
names(Data3)
Data3[,c(4,15)]
c<-cor(Data3[,c(4,15)])
corrplot(c)
