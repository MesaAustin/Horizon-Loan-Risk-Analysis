# Horizon Loan Risk Analysis
This project analyzes personal loan defaults for Horizon Financial Group using borrower profiles and loan application data (2024–2025).

# Business Problem
The company has noticed that roughly 25% default rate of loans, which is well above their target of 12%. 
The VP of Risk requested to analysis of the existing loan book and borrower data to answer the following questions:

1) What is the overall default rate, and how does it break down by credit score range (e.g., 520–599, 600–649, 650–699, 700–749, 750+)? Which credit score bucket has the highest default rate?
2) Is there a relationship between a borrower’s debt-to-income (DTI) ratio and the likelihood of defaulting? What DTI threshold would you recommend as a cutoff for loan approval?
3) Which loan purposes have the highest default rates, and does the average loan amount differ significantly between defaulted and non-defaulted loans?
4) How do employment status and years employed affect default risk? Are borrowers with less than 2 years of employment significantly more likely to default?

# Datasets
borrower_profiles.csv
Contains: Borrower ID, Credit Score, Annual Income, Employment Status, Years Employed, Debt-to-Income Ratio (DTI),

loan_applications.csv
Contains: Borrower ID, Loan Amount, Loan Purpose, Interest Rate, Loan Term, Default Status

# Tools & Skills
MS Excel- Exploratory Data Analysis  |
SQL: SSMS- Business Analysis, Data Cleaning  |
PowerBI- Business Analysis, Data Visualization  |

# Workflow
a) Create staging tables, load and validate both datasets (checking data types, null checks, summary stats).

b) Joined both borrower_profiles and loan_application tables on borrower_id.

c) Segment default rates by: Credit score buckets, DTI ranges, Loan purpose, Employment status, Years employed [ under 2yrs vs 2 or more yrs ]

d) Run correlation analysis for numeric features against default outcome.

e) Generate visualizations and summarize risk recommendations.

# Key Findings
Overall default rate is approximately 24.28%.
Highest default rate occurs in the 520–599 credit score bucket, defaulting at 49.14%.
Default risk increases as DTI rises, spiking significantly from a DTI rate of 51 and above.
Some loan purposes (Wedding, Home Improvement) have higher default rates.
Borrowers with less than 2 years employment show significantly higher default risk.

# Business Recommendations
Limiting loans to borrowers with a minimum credit score of 700.

Implementing a more critical DTI threshold of 50% or lower. If a more aggressive approach is desired then limit loans to borrowers with 25% DTI ratio in order to achieve bank's stated goal of 12%

Increased scrutiny for loan applications for the top 4 highest defaulting loan purposes (Wedding, Home Improvement, Auto Loans, Business Loans)

Stricter review of loan applications for borrowers employed for less than 2 years.

# Project Source

This project was completed using the Loan Default Risk Analysis case study provided by Analyst Builder. https://www.analystbuilder.com/projects/loan-default-risk-analysis-Vjfdl?tab=overview


