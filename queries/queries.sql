-- queries.sql
-------------------------------------------------------------------------------
-- Query: 1) RETRIEVE FIRST 10 PATIENT RECORDS
-------------------------------------------------------------------------------
-- Purpose: Basic query to peek at the table (for quick reference).
SELECT TOP 10 *
FROM lung_cancer_data;

-------------------------------------------------------------------------------
-- Query: 2) RETRIEVE ONLY RISK FACTOR COLUMNS
-------------------------------------------------------------------------------
-- Purpose: This focuses on the Boolean risk factors + relevant numeric columns
-- Purpose: (excluding the primary key 'id').
SELECT TOP 10
    age,
    gender,
    smoking,
    finger_discoloration,
    mental_stress,
    exposure_to_pollution,
    long_term_illness,
    energy_level,
    immune_weakness,
    breathing_issue,
    alcohol_consumption,
    throat_discomfort,
    oxygen_saturation,
    chest_tightness,
    family_history,
    smoking_family_history,
    stress_immune,
    pulmonary_disease
FROM lung_cancer_data;

-------------------------------------------------------------------------------
-- Query: 3) AVERAGE AGE FOR THOSE WITH PULMONARY DISEASE
-------------------------------------------------------------------------------
-- Purpose: Identifies the average age of patients whose pulmonary_disease is TRUE.
SELECT 
    AVG(age) AS avg_age_pulmonary_disease
FROM lung_cancer_data
WHERE pulmonary_disease = TRUE;

-------------------------------------------------------------------------------
-- Query: 4) AVERAGE AGE FOR THOSE WITHOUT PULMONARY DISEASE
-------------------------------------------------------------------------------
-- Purpose: Compares to see if there's a significant difference in average age.
SELECT 
    AVG(age) AS avg_age_no_pulmonary_disease
FROM lung_cancer_data
WHERE pulmonary_disease = FALSE;

-------------------------------------------------------------------------------
-- Query: 5) COUNT & PERCENT OF SMOKERS VS NON-SMOKERS, GROUPED BY PULMONARY DISEASE
-------------------------------------------------------------------------------
-- Purpose: Helps identify how smoking relates to disease frequency.
SELECT 
    smoking,
    pulmonary_disease,
    COUNT(*) AS total_patients,
    ROUND(
      100.0 * COUNT(*) OVER (PARTITION BY pulmonary_disease) 
      / SUM(COUNT(*)) OVER (PARTITION BY pulmonary_disease), 
    2) AS percent_in_group
FROM lung_cancer_data
GROUP BY smoking, pulmonary_disease
ORDER BY pulmonary_disease DESC, smoking DESC;

-------------------------------------------------------------------------------
-- Query: 6) AVERAGE & MIN/MAX OXYGEN SATURATION BY PULMONARY DISEASE
-------------------------------------------------------------------------------
-- Purpose: Shows if there's a notable difference in oxygen levels.
SELECT 
    pulmonary_disease,
    AVG(oxygen_saturation) AS avg_oxygen,
    MIN(oxygen_saturation) AS min_oxygen,
    MAX(oxygen_saturation) AS max_oxygen
FROM lung_cancer_data
GROUP BY pulmonary_disease
ORDER BY pulmonary_disease DESC;

-------------------------------------------------------------------------------
-- Query: 7) HIGH-RISK DEMOGRAPHIC #1
-------------------------------------------------------------------------------
-- Purpose: "High-risk" can be defined as patients who are older than 60, smokers,
-- Purpose: and have exposure_to_pollution. This query identifies how many such patients
-- Purpose: also have pulmonary_disease = TRUE.
SELECT 
    COUNT(*) AS high_risk_count
FROM lung_cancer_data
WHERE age > 60
  AND smoking = TRUE
  AND exposure_to_pollution = TRUE
  AND pulmonary_disease = TRUE;

-------------------------------------------------------------------------------
-- Query: 8) HIGH-RISK DEMOGRAPHIC #2
-------------------------------------------------------------------------------
-- Purpose: Another definition of high-risk: those with family_history, smoking_family_history,
-- Purpose: and immune_weakness. Grouped by whether they have pulmonary_disease or not.
SELECT 
    pulmonary_disease,
    COUNT(*) AS count_with_family_risk
FROM lung_cancer_data
WHERE family_history = TRUE
  AND smoking_family_history = TRUE
  AND immune_weakness = TRUE
GROUP BY pulmonary_disease
ORDER BY count_with_family_risk DESC;

-------------------------------------------------------------------------------
-- Query: 9) AVERAGE ENERGY LEVEL BY BREATHING_ISSUE
-------------------------------------------------------------------------------
-- Purpose: Compares the energy level for those who have breathing issues vs. those who don't.
SELECT 
    breathing_issue,
    AVG(energy_level) AS avg_energy
FROM lung_cancer_data
GROUP BY breathing_issue
ORDER BY avg_energy ASC;

-------------------------------------------------------------------------------
-- Query: 10) DISTRIBUTION: MENTAL_STRESS VS. STRESS_IMMUNE
-------------------------------------------------------------------------------
-- Purpose: Might reveal how mental stress correlates with stress_immune. We look at the 
-- Purpose: proportion of each category who have pulmonary_disease.
SELECT 
    mental_stress,
    stress_immune,
    COUNT(*) AS total_patients,
    SUM(CASE WHEN pulmonary_disease = TRUE THEN 1 ELSE 0 END) AS disease_positive,
    ROUND(
      100.0 * SUM(CASE WHEN pulmonary_disease = TRUE THEN 1 ELSE 0 END) 
      / COUNT(*), 
    2) AS percent_disease_positive
FROM lung_cancer_data
GROUP BY mental_stress, stress_immune
ORDER BY percent_disease_positive DESC;

-------------------------------------------------------------------------------
-- Query: 11) GROUPED STATISTICS ACROSS MULTIPLE BOOLEAN COLUMNS
-------------------------------------------------------------------------------
-- Purpose: Summaries per group of: (smoking, alcohol_consumption, pulmonary_disease)
-- Purpose: e.g., see how many are in each combination, plus average age & average oxygen.
SELECT
    smoking,
    alcohol_consumption,
    pulmonary_disease,
    COUNT(*) AS group_count,
    ROUND(CAST(AVG(age) AS NUMERIC), 2) AS avg_age,
    ROUND(CAST(AVG(oxygen_saturation) AS NUMERIC), 2) AS avg_oxy
FROM lung_cancer_data
GROUP BY smoking, alcohol_consumption, pulmonary_disease
ORDER BY group_count DESC;

-------------------------------------------------------------------------------
-- Query: 12) CHECK RELATION: LONG_TERM_ILLNESS AND PULMONARY_DISEASE
-------------------------------------------------------------------------------
-- Purpose: Quick check if having a long-term illness correlates strongly with disease.
SELECT
    long_term_illness,
    pulmonary_disease,
    COUNT(*) AS total_patients
FROM lung_cancer_data
GROUP BY long_term_illness, pulmonary_disease
ORDER BY total_patients DESC;

-------------------------------------------------------------------------------
-- Query: 13) INTERSECTION OF MULTIPLE FACTORS
-------------------------------------------------------------------------------
-- Purpose: Example: among those who have (breathing_issue = TRUE) and (mental_stress = TRUE),
-- Purpose: how many also have chest_tightness = TRUE? We group by pulmonary_disease to see
-- Purpose: if there's a difference.
SELECT 
    pulmonary_disease,
    COUNT(*) AS total_subset
FROM lung_cancer_data
WHERE breathing_issue = TRUE
  AND mental_stress = TRUE
  AND chest_tightness = TRUE
GROUP BY pulmonary_disease
ORDER BY total_subset DESC;
