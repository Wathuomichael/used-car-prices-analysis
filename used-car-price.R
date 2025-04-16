library(ggplot2)
library(corrplot)
library(ggthemes)
library(dplyr)
library(caTools)
library(fastDummies)
library(car)
library(Amelia)
library(Metrics)

prices <- read.csv('./Documents/stats/models/linear-regression/used-car-prices-analysis/cardekho_data.csv')

missmap(prices, col = c('yellow', 'black'))

prices$Fuel_Type <- sapply(prices$Fuel_Type, factor)
prices$Seller_Type <- sapply(prices$Seller_Type, factor)
prices$Transmission <- sapply(prices$Transmission, factor)

ggplot(prices, aes(Selling_Price)) + geom_histogram(fill = '#01a1ab', alpha = 0.6) + theme_minimal() + labs(x = 'Selling Price(Lakh)')

ggplot(prices, aes(Fuel_Type, Selling_Price)) + geom_boxplot() + theme_bw()

ggplot(prices, aes(Kms_Driven, Selling_Price)) + geom_point(aes(colour = Transmission)) + xlim(0, 2.5 + 10^5)

ggplot(prices, aes(Transmission, Selling_Price)) + geom_boxplot() + theme_bw()

year.count <- prices %>% group_by(Year) %>% summarise(Count = n())

numeric.cols <- sapply(prices, is.numeric)

cor.data <- cor(prices[, numeric.cols])

corrplot(cor.data, 'color')

prices <- subset(prices, Selling_Price < 20, select = - Car_Name)

set.seed(0)

data.split <- sample.split(prices, SplitRatio = 0.7)

train <- subset(prices, data.split == T)
test <- subset(prices, data.split == F)

lm.model <- lm(log(Selling_Price) ~ ., train)
summary(lm.model)

var.vif <- vif(lm.model)
var.vif

plot(lm.model)

lm.preds <- exp(predict(lm.model, test))

lm.rmse <- rmse(test$Selling_Price, lm.preds)

lm.mae <- mae(test$Selling_Price, lm.preds)

ggplot(test) + geom_line(aes(x = Selling_Price, y = lm.preds), colour = 'red') + 
  theme_minimal() + 
  labs(title = 'Predicted vs Actual values', x = 'Actual Selling Price(Lakh)', y = 'Predicted Selling Price(Lakh)') 

