# ==========================================
# Lung Cancer Risk Assessment Report
# ==========================================
# This script:
# 1. Prompts the user for health-related inputs.
# 2. Uses a trained Random Forest model to predict lung cancer risk.
# 3. Categorizes risk into Low, Moderate, or High based on the probability score.
# 4. Generates a PDF report summarizing user responses, predictions, and recommendations.

# ==========================================
# Load Required Libraries
# ==========================================
library(randomForest)  # For loading the trained Random Forest model
library(pdftools)      # For generating PDF reports
library(grid)          # For plotting text in the PDF
library(gridExtra)     # For additional grid functionalities

# ==========================================
# Load the Trained Random Forest Model
# ==========================================
model_rf_tuned <- readRDS("rf_model.rds")

# ==========================================
# Function to Get User Inputs
# ==========================================
get_user_responses <- function() {
  responses <- list()
  
  cat("Please answer the following questions:\n")
  
  # List of questions to ask the user
  questions <- list(
    AGE = "Enter your age (numeric): ",
    GENDER = "Is your gender male? (1 for Yes, 0 for No): ",
    SMOKING = "Do you smoke? (1 for Yes, 0 for No): ",
    FINGER_DISCOLORATION = "Do you experience finger discoloration? (1 for Yes, 0 for No): ",
    MENTAL_STRESS = "Do you experience high mental stress? (1 for Yes, 0 for No): ",
    EXPOSURE_TO_POLLUTION = "Have you been exposed to high levels of air pollution? (1 for Yes, 0 for No): ",
    LONG_TERM_ILLNESS = "Do you have a long-term respiratory illness? (1 for Yes, 0 for No): ",
    ENERGY_LEVEL = "What is your energy level? (numeric value from 1 to 100): ",
    IMMUNE_WEAKNESS = "Do you have immune system weakness? (1 for Yes, 0 for No): ",
    BREATHING_ISSUE = "Do you have breathing issues? (1 for Yes, 0 for No): ",
    ALCOHOL_CONSUMPTION = "Do you consume alcohol? (1 for Yes, 0 for No): ",
    THROAT_DISCOMFORT = "Do you experience throat discomfort? (1 for Yes, 0 for No): ",
    OXYGEN_SATURATION = "What is your oxygen saturation level? (numeric value from 1 to 100): ",
    CHEST_TIGHTNESS = "Do you experience chest tightness? (1 for Yes, 0 for No): ",
    FAMILY_HISTORY = "Do you have a family history of lung cancer? (1 for Yes, 0 for No): ",
    SMOKING_FAMILY_HISTORY = "Is there a history of smoking in your family? (1 for Yes, 0 for No): ",
    STRESS_IMMUNE = "Do you experience stress affecting your immune system? (1 for Yes, 0 for No): "
  )
  
  # Loop through each question and collect user input
  for (key in names(questions)) {
    while (TRUE) {
      cat(questions[[key]])  # Display the question
      input <- readline()
      
      # Handle numeric inputs
      if (key %in% c("AGE", "ENERGY_LEVEL", "OXYGEN_SATURATION")) {
        if (!is.na(as.numeric(input))) {
          responses[[key]] <- as.numeric(input)
          break
        } else {
          cat("Please enter a numeric value.\n")
        }
      } else {
        # Handle binary (1/0) inputs
        if (input %in% c("1", "0")) {
          responses[[key]] <- as.numeric(input)
          break
        } else {
          cat("Invalid input. Please enter 1 for Yes or 0 for No.\n")
        }
      }
    }
  }
  
  return(as.data.frame(responses))
}

# ==========================================
# Function to Predict Risk Using Random Forest Model
# ==========================================
get_prediction <- function(responses) {
  # Convert categorical binary variables into factors
  responses$GENDER <- factor(responses$GENDER, levels = c(1, 0), labels = c("Yes", "No"))
  responses$SMOKING <- factor(responses$SMOKING, levels = c(1, 0), labels = c("Yes", "No"))
  responses$FINGER_DISCOLORATION <- factor(responses$FINGER_DISCOLORATION, levels = c(1, 0), labels = c("Yes", "No"))
  responses$MENTAL_STRESS <- factor(responses$MENTAL_STRESS, levels = c(1, 0), labels = c("Yes", "No"))
  responses$EXPOSURE_TO_POLLUTION <- factor(responses$EXPOSURE_TO_POLLUTION, levels = c(1, 0), labels = c("Yes", "No"))
  responses$LONG_TERM_ILLNESS <- factor(responses$LONG_TERM_ILLNESS, levels = c(1, 0), labels = c("Yes", "No"))
  responses$IMMUNE_WEAKNESS <- factor(responses$IMMUNE_WEAKNESS, levels = c(1, 0), labels = c("Yes", "No"))
  responses$BREATHING_ISSUE <- factor(responses$BREATHING_ISSUE, levels = c(1, 0), labels = c("Yes", "No"))
  responses$ALCOHOL_CONSUMPTION <- factor(responses$ALCOHOL_CONSUMPTION, levels = c(1, 0), labels = c("Yes", "No"))
  responses$THROAT_DISCOMFORT <- factor(responses$THROAT_DISCOMFORT, levels = c(1, 0), labels = c("Yes", "No"))
  responses$CHEST_TIGHTNESS <- factor(responses$CHEST_TIGHTNESS, levels = c(1, 0), labels = c("Yes", "No"))
  responses$FAMILY_HISTORY <- factor(responses$FAMILY_HISTORY, levels = c(1, 0), labels = c("Yes", "No"))
  responses$SMOKING_FAMILY_HISTORY <- factor(responses$SMOKING_FAMILY_HISTORY, levels = c(1, 0), labels = c("Yes", "No"))
  responses$STRESS_IMMUNE <- factor(responses$STRESS_IMMUNE, levels = c(1, 0), labels = c("Yes", "No"))
  
  # Make prediction
  pred_prob <- predict(model_rf_tuned, responses, type = "prob")[, "Yes"]
  
  # Categorize into Low, Moderate, High Risk
  if (pred_prob < 0.3) {
    pred_class <- "Low Risk"
    recommendation <- "Your risk level is low.\n Maintain a healthy lifestyle and get regular check-ups."
  } else if (pred_prob >= 0.3 & pred_prob <= 0.7) {
    pred_class <- "Moderate Risk"
    recommendation <- "Your risk level is moderate. \n Consider reducing risk factors and scheduling a medical consultation."
  } else {
    pred_class <- "High Risk"
    recommendation <- "Your risk level is high. \n Consult a healthcare professional immediately for further evaluation."
  }
  
  return(list(probability = pred_prob, prediction = pred_class, recommendation = recommendation))
}

# ==========================================
# Function to Generate PDF Report
# ==========================================
generate_pdf_report <- function(responses, prediction, filename = "risk_assessment_report.pdf") {
  pdf(filename, width = 8.5, height = 11)
  plot.new()
  
  title <- "Lung Cancer Risk Assessment Report"
  subtitle <- paste("Generated on:", Sys.time())
  
  text(0.5, 0.9, title, cex = 1.5, font = 2)
  text(0.5, 0.85, subtitle, cex = 1, font = 3)
  
  text(0.5, 0.75, "User Responses:", cex = 1.2, font = 2)
  y_pos <- 0.7
  for (key in names(responses)) {
    text(0.5, y_pos, paste0(key, ": ", responses[[key]]), cex = 1)
    y_pos <- y_pos - 0.03
  }
  
  text(0.5, y_pos - 0.05, "Prediction:", cex = 1.2, font = 2)
  text(0.5, y_pos - 0.08, paste("Probability:", round(prediction$probability, 2)), cex = 1)
  text(0.5, y_pos - 0.12, paste("Risk Level:", prediction$prediction), cex = 1)
  text(0.5, y_pos - 0.18, paste("Recommendation:", prediction$recommendation), cex = 1)
  
  dev.off()
  cat("\nPDF report generated:", filename, "\n")
}

# ==========================================
# Main Execution
# ==========================================
main <- function() {
  responses <- get_user_responses()
  prediction <- get_prediction(responses)
  generate_pdf_report(responses, prediction)
}

main()
