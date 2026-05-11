import pandas as pd
import numpy as np
from faker import Faker
import random
from datetime import timedelta

# Seeding for reproducibility
fake = Faker()
Faker.seed(42)
random.seed(42)
np.random.seed(42)

N = 300_000

blood_types       = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
medical_conditions = ['Diabetes', 'Hypertension', 'Asthma', 'Cancer', 'Obesity', 'Arthritis']
admission_types   = ['Emergency', 'Elective', 'Urgent']
insurance_providers = ['Blue Cross', 'Medicare', 'UnitedHealthcare', 'Cigna', 'Private']
medications       = ['Aspirin', 'Ibuprofen', 'Paracetamol', 'Lipitor', 'Metformin', 'Omeprazole', 'Amoxicillin']
test_results      = ['Normal', 'Abnormal', 'Inconclusive']

# Generate data
data = {
    'Name': [fake.name() for _ in range(N)],
    'Age': np.random.randint(18, 91, N),
    'Gender': np.random.choice(['Male', 'Female'], N, p=[0.48, 0.52]),
    'Blood Type': np.random.choice(blood_types, N),
    'Medical Condition': np.random.choice(medical_conditions, N),
    'Doctor': ["Dr. " + fake.name() for _ in range(N)],
    'Hospital': [fake.company() + " Hospital" for _ in range(N)],
    'Insurance Provider': np.random.choice(insurance_providers, N),
    'Billing Amount': np.random.uniform(500, 50000, N).round(2),
    'Room Number': np.random.randint(100, 10000, N),
    'Admission Type': np.random.choice(admission_types, N),
    'Medication': np.random.choice(medications, N),
    'Test Results': np.random.choice(test_results, N),
}

# Dates (much lighter than creating 96k timestamps)
admission_dates = pd.date_range(start='2015-01-01', end='2025-12-31', periods=N)
shuffled_dates = admission_dates[np.random.permutation(len(admission_dates))]
data['Date of Admission'] = shuffled_dates

days_to_add = np.random.randint(1, 31, N)
data['Discharge Date'] = data['Date of Admission'] + pd.to_timedelta(days_to_add, unit='D')

df = pd.DataFrame(data)

# Optional: sort by admission date if you want chronological order
# df = df.sort_values('Date of Admission').reset_index(drop=True)

output_path = "synthetic_healthcare_300k.csv"
df.to_csv(output_path, index=False)

print(f"Generated {len(df):,} rows")
print("Columns:", df.columns.tolist())
print(f"Saved to: {output_path}")