library(dummies)
library(GGally)
DM <- read.csv(file = "app_metadata_cleaned.csv", header = TRUE)
attach(DM)

set.seed(12345)
df <- data.frame(CATEGORY,PRICE, CONTENT_RATING,DOWNLOAD_MIN,DOWNLOAD_MAX,MIN_REQ_ANDROID_FIRST,TOTAL_REVIEWS,AVERAGE_RATING)

data <- df
num.vars <- sapply(data, is.numeric)
data[num.vars] <- lapply(data[num.vars], scale)
df <- data

df_new <- dummy.data.frame(df, names = c("CATEGORY","CONTENT_RATING","MIN_REQ_ANDROID_FIRST"), sep = ".")
df_new <- cbind(df_new, spam)
ggcorr(DM)

train_ind<-sample(nrow(df_new),0.7*nrow(df_new))
train <- df_new[train_ind,]
test <- df_new[-train_ind,]
nrow(train)
nrow(test)
View(test)


bfit <- glm(as.numeric(spam)~., data = train, family = "binomial")
summary(bfit)

predict_train <- predict(bfit, newdata = train[,1:47])
t3 <- ifelse(predict_train > 0.5,1,0)
t3
Confusion_train <- table(as.numeric(train$spam),t3)
actual <- as.numeric(train$spam)
Metrics <- c("AE","RMSE","MAE")
x1 <- mean(actual-predict_train)
x2 <- sqrt(mean((actual-predict_train)^2))
x3 <- mean(abs(actual-predict_train))
Values <- c(x1,x2,x3)
X <- data.frame(Metrics,Values)
X

predict_test <- predict(bfit, newdata = test[,1:47])
t4 <- ifelse(predict_test > 0.5,1,0)
t4
confusion_test <- table(as.numeric(test$spam),t4)
actual_test <- as.numeric(test$spam)
Metrics <- c("AE","RMSE","MAE")
x1_test <- mean(actual_test-predict_test)
x2_test <- sqrt(mean((actual_test-predict_test)^2))
x3_test <- mean(abs(actual_test-predict_test))
Values <- c(x1_test,x2_test,x3_test)
X_test <- data.frame(Metrics,Values)
X_test

Accuracy_train <- (Confusion_train[1,1] + Confusion_train[2,2])/(Confusion_train[1,1] + Confusion_train[1,2]
                                                                                            + Confusion_train[2,1] + Confusion_train[2,2])
Accuracy_train

Error_rate_train <- (Confusion_train[1,2]+Confusion_train[2,1])/ (Confusion_train[1,1] + Confusion_train[1,2]
                                                                                             + Confusion_train[2,1] + Confusion_train[2,2])
Error_rate_train


Accuracy_test <- (confusion_test[1,1] + confusion_test[2,2])/(confusion_test[1,1] + confusion_test[1,2]
                                                                 + confusion_test[2,1] + confusion_test[2,2])
Accuracy_test

Error_rate_test <- (confusion_test[1,2]+confusion_test[2,1])/ (confusion_test[1,1] + confusion_test[1,2]
                                                                  + confusion_test[2,1] + confusion_test[2,2])
Error_rate_test


library(randomForest)

set.seed(1)
bag=randomForest(train$spam~.,data=train[,-1],mtry=48, importance=TRUE)
bag

yhat.bag = predict(bag,newdata=test)
length(yhat.bag)
mean((yhat.bag-train$spam)^2)

plot(yhat.bag, test$spam)
abline(0,1)

RF=randomForest(train$spam~.,data=train[,-1],mtry=7, importance=TRUE)
RF

yhat.RF = predict(RF,newdata=test)
length(yhat.RF)
mean((yhat.RF-test$spam)^2)

plot(yhat.RF, test$spam)
abline(0,1)

library(gbm)
set.seed(1)
boost=gbm(spam~.,data=train[,-1],distribution="gaussian",n.trees=5000,interaction.depth=4)
summary(boost)
par(mfrow=c(1,2))
plot(boost,i="rm")
plot(boost,i="lstat")
yhat.boost=predict(boost,newdata=test,n.trees=5000)
mean((yhat.boost-test$NPV)^2)





