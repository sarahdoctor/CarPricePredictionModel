# CarPricePredictionModel
A predictive analytics model for a Kaggle competition to predict the price of car using a dataset containing information on 40,000 used cars.

# CLEANING THE DATA

The dataset provided had multiple kinds of variables, both categorical and numerical. In addition to this several columns also had multiple missing values. In the first step of cleaning, multiple columns were excluded from the analysis due to large strings, that would be difficult to interpret. Following this, columns containing characters were converted into factors, to facilitate statistical modelling. 
The next step was to identify columns that contained missing values and analyse their spread. After analysing the spread, we can observe there were 8 columns that contained missing values. 

# MODELS

As the dataset is significantly large, we split it into a training data set and testing dataset. Using this, I ran a multivariate linear regression model, regression tree models, random forest models and an XG Boost model. By comparing the RMSEs for the models, I found that the XG Boost model had the lowest RMSE score of the test data, however the random forest model yeilded the lowest RMSE on the test data.

# LIMITATIONS

In spite excluding several variables from the analysis, the process was extremely slow, making it difficult to conduct further analysis to improve the model. 
-	Feature engineering could have been used to capture more nuanced relationships between the variables. 
-	Cross-validation could have been utilised to validate the performance of the model and gain a better estimate. 

