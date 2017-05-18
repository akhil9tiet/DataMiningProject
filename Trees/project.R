# Uploading the file into R

setwd("C:/Users/gupta/DataMiningProject")
project <- read.csv("app_metadata_cleaned_removed_min_downloads_above_5m.csv")

# creating duplicate copy of project
data <- project
class(project$PRICE)

# removing not required files
data$APP_ID <- NULL
data$APP_NAME <- NULL
data$DOWNLOADS <- NULL
data$CURRENT_VERSION <- NULL
data$LASTUPDATED <- NULL
data$DEVELOPER_SITE <- NULL
data$DEVELOPER_CONTACT <- NULL
data$DEVELOPER_NAME <- NULL
data$MIN_REQUIRED_ANDROID <- NULL

# creating factors of independent variables and changing variables from integer to numeric
data$CATEGORY <- as.factor(data$CATEGORY)
data$PRICE <- as.numeric(data$PRICE)
data$CONTENT_RATING <- as.factor(data$CONTENT_RATING)
data$DOWNLOAD_MIN <- as.numeric(data$DOWNLOAD_MIN)
data$DOWNLOAD_MAX <- as.numeric(data$DOWNLOAD_MAX)
data$SIZE_MEGABYTES <- as.numeric(data$SIZE_MEGABYTES)
data$MIN_REQ_ANDROID_FIRST <- as.factor(data$MIN_REQ_ANDROID_FIRST)
data$TOTAL_REVIEWS <- as.numeric(data$TOTAL_REVIEWS)
data$AVERAGE_RATING <- as.numeric(data$AVERAGE_RATING)
data$X5RATING <- as.numeric(data$X5RATING)
data$X4RATING <- as.numeric(data$X4RATING)
data$X3RATING <- as.numeric(data$X3RATING)
data$X2RATING <- as.numeric(data$X2RATING)
data$X1RATING <- as.numeric(data$X1RATING)
data$spam <- as.factor(data$spam)

#setting seed and dividing the dataset into Training and Test
set.seed(12345)
train <- sample(nrow(data),0.7*nrow(data))
project_training <- data[train,]
project_Validation <- data[-train,]

library(tree)
library(ISLR)

#Under Sampling Data
#Taking all the observations with dependent variable = 1
train_under <- project_training[project_training$spam==1,]

#Randomly select observations with dependent variable = 0
zeroObs <- project_training[project_training$spam==0,]
set.seed(123457)
rearrangedZeroObs <-  zeroObs[sample(nrow(zeroObs), length(train_under$spam)),]

#Appending rows of randomly selected 0s in our undersampled data frame
train_under <- rbind(train_under, rearrangedZeroObs)

# creating the classification tree
tree.project <- tree(spam ~ CATEGORY+PRICE+CONTENT_RATING+DOWNLOAD_MAX+DOWNLOAD_MIN+TOTAL_REVIEWS+AVERAGE_RATING+X5RATING+X4RATING+X3RATING+X2RATING+X1RATING,data = train_under)
summary(tree.project) 

#plotting the tree
plot(tree.project)
text(tree.project, pretty=6)

# Creating confusion matrix of pridcted values in test data set 
tree.predict <- predict(tree.project, project_Validation, type = "class")
confmatrix <- table (project_Validation$spam,tree.predict)
confmatrix

#calculating the accuracy
accuracy <- (confmatrix[1,1]+confmatrix[2,2])/sum(confmatrix)
accuracy

# calculating the sensitivity
sensitivity <- (confmatrix[1,1]/confmatrix[1,1]+confmatrix[2,1])
sensitivity


# Cross validation technique to find the best tree
set.seed(123)
cv.credit <- cv.tree(tree.project,FUN =prune.misclass, K=10)
names(cv.credit)

cv.credit

#pruning the tree with best no. of terminal nodes
prune.credit <- prune.misclass(tree.project, best =8)
plot(prune.credit)
text(prune.credit, pretty=0)

summary(prune.credit)

# Creating confusion matrix of pridcted values in test data set with pruned tree
tree.predict1 <- predict(prune.credit, project_Validation, type = "class")
confmatrix1 <- table (tree.predict1, project_Validation$spam)
confmatrix1

#calculating accuracy of pruned tree
accuracy1 <- (confmatrix1[1,1]+confmatrix1[2,2])/sum(confmatrix1)
accuracy1

# calculating the sensitivity of pruned tree
sensitivity1 <- (confmatrix[1,1]/confmatrix[1,1]+confmatrix[2,1])
sensitivity1

#oversampling the data
train_over <- project_training[project_training$spam==1,]
train_1 <- train_over
for (i in seq(from=1, to=6, by=1)){
  train_over <- rbind(train_over, train_1)
}
train_over
train_oversampling <- rbind(project_training, train_over)

# running classification tree on oversampled data
tree.project <- tree(spam ~ CATEGORY+PRICE+CONTENT_RATING+DOWNLOAD_MAX+DOWNLOAD_MIN+TOTAL_REVIEWS+AVERAGE_RATING+X5RATING+X4RATING+X3RATING+X2RATING+X1RATING,data = train_oversampling)
summary(tree.project) 

#plotting the tree
plot(tree.project)
text(tree.project, pretty=6)

# Creating confusion matrix 
tree.predict <- predict(tree.project, project_Validation, type = "class")
confmatrix <- table (tree.predict, project_Validation$spam)
confmatrix

# calculating accuracy
accuracy <- (confmatrix[1,1]+confmatrix[2,2])/sum(confmatrix)
accuracy

# calculating the sensitivity
sensitivity <- (confmatrix[1,1]/confmatrix[1,1]+confmatrix[2,1])
sensitivity

#running cross validation technique to fnd best tree
set.seed(12345)
cv.credit <- cv.tree(tree.project,FUN =prune.misclass, K=10)
names(cv.credit)

cv.credit

#pruning the tree
prune.credit <- prune.misclass(tree.project, best =4)
plot(prune.credit)
text(prune.credit, pretty=0)

summary(prune.credit)

# calcuate confusion matrix
tree.predict1 <- predict(prune.credit, project_Validation, type = "class")
confmatrix1 <- table (tree.predict1, project_Validation$spam)
confmatrix1

# calculating accuracy of pruned tree
accuracy1 <- (confmatrix1[1,1]+confmatrix1[2,2])/sum(confmatrix1)
accuracy1

# calculating the sensitivity of pruned tree
sensitivity1 <- (confmatrix[1,1]/confmatrix[1,1]+confmatrix[2,1])
sensitivity1