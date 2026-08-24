--- Credit Default Analysis
USE [Loan Risk - Practice Analysis];

-- Creating Staging Table

CREATE TABLE Borrower_Profiles (
borrower_id				VARCHAR(50),
age						INT,
[state]					VARCHAR(50),
education_level			VARCHAR(50),
employment_status		VARCHAR(50),
years_employed			INT,
annual_income			INT,
credit_score			INT,
home_ownership			VARCHAR(50),
dependents				INT,
existing_monthly_debt	INT
)
;

CREATE TABLE loan_applications (
loan_id					VARCHAR(50),
borrower_id				VARCHAR(50),
application_date		DATE,
loan_purpose			VARCHAR(50),
loan_amount				INT,
term_months				INT,
interest_rate			NUMERIC(4,2),
monthly_payment			NUMERIC,
dti_ratio				NUMERIC(5,2),
loan_status				VARCHAR(50),
days_delinquent			INT,
defaulted				BIT,
)
						;


--Extracing Data

BULK INSERT Borrower_Profiles
FROM 'C:\Users\igbuk\OneDrive\Documents\SQL Server Management Studio\Analyst Builder Practices\Loan Default Risk Analysis Project\borrower_profiles.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    TABLOCK
);

BULK INSERT loan_applications
FROM 'C:\Users\igbuk\OneDrive\Documents\SQL Server Management Studio\Analyst Builder Practices\Loan Default Risk Analysis Project\loan_applications.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    TABLOCK
);

--Checking Tables, 
Select *
FROM Borrower_Profiles
;

Select *
FROM loan_applications
;