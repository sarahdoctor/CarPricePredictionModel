library(readr)
library(dplyr)
library(tidyr)
library(caret)
library(ggplot2); library(ggcorrplot)
library(mlbench)
library(caret)
library(randomForest)
library(dplyr)
library(mice)
library(tidyverse)
library(rpart)
library(rpart.plot)
library(fastDummies)

#data
carData <- read.csv('/Users/sarahdoctor/Desktop/analysisData.csv')
str(carData)

#delete rows
carData <- select(carData,  -c("make_name", "model_name", "trim_name", "body_type", 
                               "power", "torque", "transmission", "transmission_display", 
                               "wheel_system_display", "engine_type", "description", 
                               "exterior_color", "interior_color", "major_options", 
                               "franchise_make", "listed_date"))


carData$fleet <- as.factor(carData$fleet) 
carData$frame_damaged <- as.factor(carData$frame_damaged) 
carData$franchise_dealer <- as.factor(carData$franchise_dealer) 
carData$has_accidents <- as.factor(carData$has_accidents) 
carData$isCab <- as.factor(carData$isCab) 
carData$is_new <- as.factor(carData$is_new) 
carData$salvage <- as.factor(carData$salvage)

#Find NAs
na_sum <- colSums(is.na(carData))
na_table <- data.frame(Column = names(na_sum), NA_Sum = na_sum)
print(na_table)

#delete owner count due to high value of NAs
carData <- select(carData, - "owner_count")

#Treat NAs using MICE
md.pattern(carData)

imputedData <- mice(carData, m = 5, method = "rf")
completeData <- complete(imputedData, 1)

colnames(completeData)


#Creating the model

#Partition Data
set.seed(1)


completeData <- select(completeData,  -c("fleet", "frame_damaged", "has_accidents", 
                                              "isCab", "is_cpo", "salvage"))

#Partition Data
ind <- sample(2, nrow(completeData), replace = TRUE, prob = c(0.7, 0.3))
set.seed(3247)
trainData <- completeData[ind == 1, ]
testData <- completeData[ind == 2, ]


predictors <- setdiff(names(trainData), "price")
train_predictors <- trainData[predictors]
train_response <- trainData$price
test_predictors <- testData[predictors]
test_response <- testData$price

library(randomForest)
# Train the Random Forest model
rf_model <- randomForest(x = train_predictors, y = train_response, na.action = na.omit)

plot(rf_model)
trControl=trainControl(method="cv",number=5)
tuneGrid = expand.grid(mtry=1:4)
set.seed(617)
cvModel = train(train_response~train_predictors,
                method="rf",ntree=100,trControl=trControl,tuneGrid=tuneGrid )
cvModel


# Predict on train and test data 
predictionsTrain <- predict(cvModel, train_predictors)
predictions <- predict(cvModel, test_predictors)

# RMSEs
library(Metrics)
rmse(train_response, predictionsTrain)
rmse(test_response, predictions)

# Load and prepare scoringData
scoringData <- read.csv("/Users/sarahdoctor/Desktop/scoringData.csv")
# Select the same columns as used for training (excluding the target variable 'price')
scoring_selected <- scoringData[, setdiff(selected_columns, "price")]

#  missing values for scoring data
scoring_selected[, numeric_columns] <- lapply(scoring_selected[, numeric_columns], function(x) {
  ifelse(is.na(x), mean(x, na.rm = TRUE), x)
})

scoring_selected[, categorical_columns] <- lapply(scoring_selected[, categorical_columns], function(x) {
  mode <- names(sort(table(x), decreasing = TRUE))[1]
  ifelse(is.na(x), mode, x)
})

# Create a new dummyVars object for scoring data
scoring_data_encoded <- dummyVars("~ .", data = scoring_selected)

# One-hot encoding 
scoring_final <- predict(scoring_data_encoded, newdata = scoring_selected)

# Ensure the columns of scoring_final match those of your training data
train_columns <- setdiff(names(trainData), "price")
missing_columns <- setdiff(train_columns, names(scoring_final))
scoring_final <- cbind(scoring_final, matrix(0, ncol = length(missing_columns), nrow = nrow(scoring_final), dimnames = list(NULL, missing_columns)))
scoring_final <- scoring_final[, train_columns]

# Run predictions
predictions <- predict(rf_model, scoring_final)
print(predictions)

submissionFile = data.frame(id = scoringData$id, price = predictions)
write.csv(submissionFile, 'sarah_RandomForestNew.csv',row.names = F)

