USE [Loan Risk - Practice Analysis];

-- Data Verification, Checking for nulls
SELECT COUNT(*) 
FROM Borrower_Profiles
WHERE annual_income IS NULL OR credit_score IS NULL;

SELECT COUNT(*) AS Invalid_rows
FROM loan_applications 
WHERE monthly_payment IS NULL OR loan_amount IS NULL;

-- Checking for duplicates
SELECT borrower_id, annual_income, credit_score, Count(*)
FROM borrower_profiles
Group BY borrower_id, annual_income, credit_score 
Having Count(*) > 1
;

SELECT borrower_id, loan_id, application_date, Count(*)
FROM loan_applications
Group BY borrower_id, loan_id, application_date
Having Count(*) > 1
;


--Join Tables, loans to loan applicants
Select*
FROM Borrower_Profiles As P
JOIN loan_applications As L
ON P.borrower_id = l.borrower_id
;