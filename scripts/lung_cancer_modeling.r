# lung_cancer_modeling_updated.R

# ---------------------------
# 1. Load Required Libraries
# ---------------------------
library(tidyverse)      # Data manipulation and visualization
library(caret)          # Modeling and cross-validation
library(randomForest)   # Random Forest implementation
library(e1071)          # For SVM model (requires kernlab too)
library(pROC)           # ROC and AUC calculations
library(FSelector)      # For mutual information based feature selection
library(kernlab)

# ---------------------------
# 2. Load and Preprocess Data
# ---------------------------
data <- read.csv("data/LungCancerDataset.csv", stringsAsFactors = FALSE)

# Convert binary columns (1/0 or "YES"/"NO") to factors.
binary_cols <- c("GENDER", "SMOKING", "FINGER_DISCOLORATION", "MENTAL_STRESS",
                 "EXPOSURE_TO_POLLUTION", "LONG_TERM_ILLNESS", "IMMUNE_WEAKNESS",
                 "BREATHING_ISSUE", "ALCOHOL_CONSUMPTION", "THROAT_DISCOMFORT",
                 "CHEST_TIGHTNESS", "FAMILY_HISTORY", "SMOKING_FAMILY_HISTORY",
                 "STRESS_IMMUNE", "PULMONARY_DISEASE")

data[binary_cols] <- lapply(data[binary_cols], function(x) {
  if(is.numeric(x)){
    factor(ifelse(x == 1, "Yes", "No"), levels = c("Yes", "No"))
  } else {
    # Standardize YES/NO (case insensitive)
    factor(ifelse(tolower(x) %in% c("yes", "true", "1"), "Yes", "No"), levels = c("Yes", "No"))
  }
})

# Convert numeric columns properly
data$AGE <- as.numeric(data$AGE)
data$ENERGY_LEVEL <- as.numeric(data$ENERGY_LEVEL)
data$OXYGEN_SATURATION <- as.numeric(data$OXYGEN_SATURATION)

# ---------------------------
# 3. Partition Data (70% Train / 30% Test)
# ---------------------------
set.seed(123)
trainIndex <- createDataPartition(data$PULMONARY_DISEASE, p = 0.7, list = FALSE)
trainData <- data[trainIndex, ]
testData  <- data[-trainIndex, ]

# Check distribution of target variable
print("Training Data Distribution:")
print(table(trainData$PULMONARY_DISEASE))
print("Test Data Distribution:")
print(table(testData$PULMONARY_DISEASE))

# Ensure target variable factors have both levels explicitly
trainData$PULMONARY_DISEASE <- factor(trainData$PULMONARY_DISEASE, levels = c("Yes", "No"))
testData$PULMONARY_DISEASE <- factor(testData$PULMONARY_DISEASE, levels = c("Yes", "No"))

# ---------------------------
# 4. Feature Selection
# ---------------------------
# 4.1 Mutual Information
weights <- information.gain(PULMONARY_DISEASE ~ ., data = trainData)
print("Mutual Information (Information Gain) Scores:")
print(weights)

# 4.2 Recursive Feature Elimination (RFE) with Random Forest
set.seed(123)
control_rfe <- rfeControl(functions = rfFuncs, method = "cv", number = 5)
rfe_results <- rfe(trainData[, setdiff(names(trainData), "PULMONARY_DISEASE")],
                   trainData$PULMONARY_DISEASE,
                   sizes = c(5, 10, length(setdiff(names(trainData), "PULMONARY_DISEASE"))),
                   rfeControl = control_rfe)
print("RFE Results:")
print(rfe_results)
print("Selected Features:")
print(predictors(rfe_results))

# ---------------------------
# 5. Model Training & Evaluation
# ---------------------------
# Cross-validation setup with ROC as the metric
train_control <- trainControl(method = "cv", 
                              number = 5, 
                              classProbs = TRUE,
                              summaryFunction = twoClassSummary, 
                              savePredictions = TRUE)

# 5.1 Logistic Regression (Baseline)
set.seed(123)
model_lr <- train(PULMONARY_DISEASE ~ ., data = trainData, 
                  method = "glm", family = "binomial",
                  trControl = train_control, metric = "ROC")
print("Logistic Regression Model:")
print(model_lr)
pred_lr <- predict(model_lr, newdata = testData)
conf_lr <- confusionMatrix(pred_lr, testData$PULMONARY_DISEASE, positive = "Yes")
print("Logistic Regression Confusion Matrix:")
print(conf_lr)
roc_lr <- roc(testData$PULMONARY_DISEASE, predict(model_lr, newdata = testData, type = "prob")[, "Yes"])
print(paste("Logistic Regression AUC:", auc(roc_lr)))

# 5.2 Decision Tree
set.seed(123)
model_dt <- train(PULMONARY_DISEASE ~ ., data = trainData, 
                  method = "rpart", trControl = train_control, metric = "ROC")
print("Decision Tree Model:")
print(model_dt)
pred_dt <- predict(model_dt, newdata = testData)
conf_dt <- confusionMatrix(pred_dt, testData$PULMONARY_DISEASE, positive = "Yes")
print("Decision Tree Confusion Matrix:")
print(conf_dt)
roc_dt <- roc(testData$PULMONARY_DISEASE, predict(model_dt, newdata = testData, type = "prob")[, "Yes"])
print(paste("Decision Tree AUC:", auc(roc_dt)))

# 5.3 Random Forest
set.seed(123)
model_rf <- train(PULMONARY_DISEASE ~ ., data = trainData, 
                  method = "rf", trControl = train_control, metric = "ROC")
print("Random Forest Model:")
print(model_rf)
pred_rf <- predict(model_rf, newdata = testData)
conf_rf <- confusionMatrix(pred_rf, testData$PULMONARY_DISEASE, positive = "Yes")
print("Random Forest Confusion Matrix:")
print(conf_rf)
roc_rf <- roc(testData$PULMONARY_DISEASE, predict(model_rf, newdata = testData, type = "prob")[, "Yes"])
print(paste("Random Forest AUC:", auc(roc_rf)))

# 5.4 Support Vector Machine (SVM)
set.seed(123)
model_svm <- train(PULMONARY_DISEASE ~ ., data = trainData, 
                   method = "svmRadial", trControl = train_control, metric = "ROC")
print("SVM Model:")
print(model_svm)
pred_svm <- predict(model_svm, newdata = testData)
conf_svm <- confusionMatrix(pred_svm, testData$PULMONARY_DISEASE, positive = "Yes")
print("SVM Confusion Matrix:")
print(conf_svm)
roc_svm <- roc(testData$PULMONARY_DISEASE, predict(model_svm, newdata = testData, type = "prob")[, "Yes"])
print(paste("SVM AUC:", auc(roc_svm)))

# ---------------------------
# 6. Model Optimization (Hyperparameter Tuning for Random Forest)
# ---------------------------
set.seed(123)
tune_grid <- expand.grid(mtry = c(2, 4, 6, 8))
model_rf_tuned <- train(PULMONARY_DISEASE ~ ., data = trainData, 
                        method = "rf", trControl = train_control, metric = "ROC",
                        tuneGrid = tune_grid)
print("Tuned Random Forest Model:")
print(model_rf_tuned)
pred_rf_tuned <- predict(model_rf_tuned, newdata = testData)
conf_rf_tuned <- confusionMatrix(pred_rf_tuned, testData$PULMONARY_DISEASE, positive = "Yes")
print("Tuned Random Forest Confusion Matrix:")
print(conf_rf_tuned)
roc_rf_tuned <- roc(testData$PULMONARY_DISEASE, predict(model_rf_tuned, newdata = testData, type = "prob")[, "Yes"])
print(paste("Tuned Random Forest AUC:", auc(roc_rf_tuned)))

# ---------------------------
# 7. Summarize Model Performance
# ---------------------------
model_performance <- data.frame(
  Model = c("Logistic Regression", "Decision Tree", "Random Forest", "SVM", "Tuned RF"),
  Accuracy = c(conf_lr$overall['Accuracy'],
               conf_dt$overall['Accuracy'],
               conf_rf$overall['Accuracy'],
               conf_svm$overall['Accuracy'],
               conf_rf_tuned$overall['Accuracy']),
  ROC_AUC = c(auc(roc_lr), auc(roc_dt), auc(roc_rf), auc(roc_svm), auc(roc_rf_tuned))
)
print("Model Performance Summary:")
print(model_performance)

saveRDS(model_rf_tuned, file = "rf_model.rds")