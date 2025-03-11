import pandas as pd
import os
from dotenv import load_dotenv
from supabase import create_client, Client

# 1) Load environment variables from .env
load_dotenv()

# 2) Retrieve Supabase credentials from environment
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

# 3) Initialize Supabase client
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# 4) Load your CSV data
df = pd.read_csv("data/LungCancerDataset.csv")

# 5) Rename CSV columns to match the SQL table definitions
df = df.rename(columns={
    "AGE": "age",
    "GENDER": "gender",
    "SMOKING": "smoking",
    "FINGER_DISCOLORATION": "finger_discoloration",
    "MENTAL_STRESS": "mental_stress",
    "EXPOSURE_TO_POLLUTION": "exposure_to_pollution",
    "LONG_TERM_ILLNESS": "long_term_illness",
    "ENERGY_LEVEL": "energy_level",
    "IMMUNE_WEAKNESS": "immune_weakness",
    "BREATHING_ISSUE": "breathing_issue",
    "ALCOHOL_CONSUMPTION": "alcohol_consumption",
    "THROAT_DISCOMFORT": "throat_discomfort",
    "OXYGEN_SATURATION": "oxygen_saturation",
    "CHEST_TIGHTNESS": "chest_tightness",
    "FAMILY_HISTORY": "family_history",
    "SMOKING_FAMILY_HISTORY": "smoking_family_history",
    "STRESS_IMMUNE": "stress_immune",
    "PULMONARY_DISEASE": "pulmonary_disease"
})

# 6) Convert columns with 1/0 into boolean True/False
bool_columns = [
    "gender",
    "smoking",
    "finger_discoloration",
    "mental_stress",
    "exposure_to_pollution",
    "long_term_illness",
    "immune_weakness",
    "breathing_issue",
    "alcohol_consumption",
    "throat_discomfort",
    "chest_tightness",
    "family_history",
    "smoking_family_history",
    "stress_immune"
]
df[bool_columns] = df[bool_columns].astype(bool)

# 7) Convert "YES"/"NO" in 'pulmonary_disease' to boolean
df["pulmonary_disease"] = df["pulmonary_disease"].map({"YES": True, "NO": False})

# 8) Function to insert data into Supabase
def insert_data(df: pd.DataFrame):
    """
    Inserts all rows from a DataFrame into the 'lung_cancer_data' table
    on Supabase.
    """
    # Convert DataFrame to list of dicts
    data_records = df.to_dict(orient="records")
    response = supabase.table("lung_cancer_data").insert(data_records).execute()
    print("Insertion response:", response)

# 9) Call the insert function
if __name__ == "__main__":
    insert_data(df)
    print("Data successfully inserted into Supabase!")
