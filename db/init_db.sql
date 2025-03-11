-- init_db.sql

-- Drop existing table(s) to start fresh (optional).
DROP TABLE IF EXISTS lung_cancer_data;

CREATE TABLE lung_cancer_data (
    id SERIAL PRIMARY KEY,
    age INT NOT NULL,
    gender BOOLEAN NOT NULL, -- 1 = Male, 0 = Female
    smoking BOOLEAN NOT NULL,
    finger_discoloration BOOLEAN NOT NULL,
    mental_stress BOOLEAN NOT NULL,
    exposure_to_pollution BOOLEAN NOT NULL,
    long_term_illness BOOLEAN NOT NULL,
    energy_level FLOAT NOT NULL,
    immune_weakness BOOLEAN NOT NULL,
    breathing_issue BOOLEAN NOT NULL,
    alcohol_consumption BOOLEAN NOT NULL,
    throat_discomfort BOOLEAN NOT NULL,
    oxygen_saturation FLOAT NOT NULL,
    chest_tightness BOOLEAN NOT NULL,
    family_history BOOLEAN NOT NULL,
    smoking_family_history BOOLEAN NOT NULL,
    stress_immune BOOLEAN NOT NULL,
    pulmonary_disease BOOLEAN NOT NULL
);
