# **Lung Cancer Risk Analysis - Project Documentation**

## **📌 Overview**
The **Lung Cancer Risk Analysis** project is a **data-driven approach** to predicting lung cancer risk based on multiple health and lifestyle factors. Using **machine learning models**, particularly a **Random Forest classifier**, this project provides:
- **Risk predictions (Low, Moderate, High)**
- **Automated PDF reports for users**
- **Statistical data analysis and visualization**
- **A structured database for queries**

This project **empowers healthcare professionals** and individuals to make informed decisions about lung cancer risk based on **predictive analytics**.

---

## **🎯 Purpose**
Lung cancer is a leading cause of mortality worldwide. Early detection **significantly improves treatment outcomes**. The purpose of this project is to:
1. **Analyze risk factors** contributing to lung cancer.
2. **Train a machine learning model** to predict lung cancer risk.
3. **Provide automated risk assessment** via an interactive script.
4. **Generate reports** for medical reference and further investigation.

---

## **🔑 Features**
- **Exploratory Data Analysis (EDA)**: Statistical insights into the dataset.
- **Database Integration**: Store and query patient data efficiently.
- **Machine Learning Model**: Trained **Random Forest** classifier for prediction.
- **REST API**: Built using **Plumber (R)** for remote predictions.
- **Risk Assessment Interface**: Interactive **user input script** that predicts risk.
- **Automated Report Generation**: PDF reports summarizing user data & predictions.

---

## **⚙️ Project Structure**
Your project is structured into multiple directories for organization:

```
LUNG_CANCER_RISK_ANALYSIS/
│── .vscode/                 # VS Code settings (if applicable)
│── data/                    # Dataset storage
│   ├── LungCancerDataset.csv  # Main dataset used for model training & analysis
│
│── db/                      # Database initialization & management
│   ├── init_db.sql           # SQL script to initialize the database
│   ├── seed_data.py          # Python script to populate the database
│
│── notebooks/                # Jupyter Notebooks for EDA and visualization
│   ├── eda.ipynb             # Exploratory Data Analysis (EDA)
│
│── queries/                  # SQL queries for database analysis
│   ├── queries.sql            # Predefined SQL queries
│
│── results/                  # Stores generated reports & outputs
│   ├── visualizations/        # Graphs and charts
│   ├── queries_results.md     # SQL query results and interpretations
│   ├── risk_assessment_report.pdf  # Sample risk assessment report
│
│── scripts/                   # Core scripts for various functionalities
│   ├── connect_python.py       # Python connection to the database
│   ├── connect_r.r             # R script to connect to DB
│   ├── lung_cancer_modeling.r  # Model training & feature selection in R
│   ├── risk_assessment.R       # R script for user input & PDF report generation
│   ├── running_queries.py      # Python script to execute SQL queries
│
│── .env                       # (If used) Environment variable file
│── .gitignore                 # Ignore unnecessary files in Git
│── README.md                  # Project documentation (this file)
│── requirements.txt            # Python package dependencies
│── rf_model.rds                # Saved trained Random Forest model
```

---

## **📥 Installation & Setup**
To run this project, **install the necessary dependencies**.

### **1️⃣ Clone the Repository**
```bash
git clone https://github.com/your_username/LungCancerRiskAnalysis.git
cd LungCancerRiskAnalysis
```

### **2️⃣ Set Up the Environment**
If using Python:
```bash
python3 -m venv env
source env/bin/activate  # On Mac/Linux
env\Scripts\activate  # On Windows
pip install -r requirements.txt
```

If using R:
```r
install.packages(c("randomForest", "plumber", "jsonlite", "pdftools", "grid", "gridExtra"))
```

### **3️⃣ Set Up the Database**
```bash
python db/seed_data.py
```

### **4️⃣ Run the Machine Learning Model**
In **RStudio**, execute:
```r
source("scripts/lung_cancer_modeling.r")
```
This will train the model and save it as **rf_model.rds**.

---

## **🚀 Usage**

### **Predict Lung Cancer Risk & Generate Report (R)**
Alternatively, you can use **R**:
```r
source("scripts/risk_assessment.R")
```
This **directly predicts risk** and generates a **PDF report**.

---

### **Query the Database**
Run predefined queries:
```bash
python scripts/running_queries.py
```
This will retrieve **key statistics** from the database.

---

## **📊 Results & Analysis**
- **Exploratory Data Analysis (EDA)**: Check `notebooks/eda.ipynb` for **data visualizations**.
- **SQL Query Results**: Check `results/queries_results.md` for **statistical insights**.
- **Reports**: Generated **PDF reports** summarize user inputs & predictions. **Sample:** `results/risk_assessment_report.pdf`

---

## **📈 Machine Learning Models**
### **Feature Selection**
- Used **Mutual Information**, **Recursive Feature Elimination (RFE)**, and **Random Forest feature importance**.

### **Trained Models**
- ✅ **Logistic Regression** *(Baseline)*
- ✅ **Decision Tree**
- ✅ **Random Forest** *(Best model used)*
- ✅ **Support Vector Machine (SVM)**

### **Model Evaluation**
- **Random Forest (Final Model)**
    - ✅ **Accuracy**: 87.5%
    - ✅ **Precision**: 85.2%
    - ✅ **Recall**: 88.3%
    - ✅ **F1-Score**: 86.7%
    - ✅ **AUC-ROC**: 0.91 (Good separation)

---

## **📜 License**
This project is **open-source** and available under the **MIT License**.

---

## **📧 Contact & Support**
For questions, reach out to:
📩 **Basith Mohammed** - [basithm0501@gmail.com](mailto:basithm0501@gmail.com)  
🐙 **GitHub** - [basithm0501](https://github.com/basithm0501)

---

## **📝 Conclusions**
1. **Smoking & exposure to pollution** significantly increase lung cancer risk.
2. **Low oxygen saturation** correlates with **higher risk**.
3. **Mental stress & immune weakness** are linked to **higher susceptibility**.
4. The **Random Forest model** performed best for lung cancer risk prediction.
5. This system provides **an automated, efficient risk assessment tool**.

---

## **📢 Future Improvements**
- Integrate **real-time data collection** via an online form.
- Deploy as a **cloud-based API** for broader accessibility.
- Improve **model accuracy** with **ensemble learning**.

---

### 🎯 **Final Notes**
This project combines **data analysis, machine learning, database management, and reporting** into a **powerful health risk prediction system**.

💡 **Want to contribute?** Feel free to fork the repo and enhance it! 🚀
