USE [Loan Risk - Practice Analysis];

--overall default rate: 24.29%
SELECT
CAST(SUM(CASE WHEN Loan.defaulted = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(Loan.loan_id) AS Default_Rate
FROM Borrower_Profiles AS Bor
JOIN loan_applications AS Loan
ON Bor.borrower_id = loan.borrower_id
;

-- Verifying Lowest credit score before segmentation: 528, lowest bucket starts at 520\

Select top 10 *
FROM Borrower_Profiles
JOIN loan_applications
ON Borrower_Profiles.borrower_id = loan_applications.borrower_id
ORDER By Borrower_Profiles.credit_score;

---Credit Score Segmentation 520–599, 600–649, 650–699, 700–749, 750+, 
--Find default rate 520-599 = 49.14%, 600–649 = 29.03%, 650–699 = 28%, 700–749 = 16.28%, 750+ = 11.69%

Select 
		CASE
		When Credit_Score >=520 AND credit_score <= 599 Then '520-599'
		When Credit_Score >=600 AND credit_score <= 649 Then '600–649'
		When Credit_Score >=650 AND credit_score <= 699 Then '650–699'
		When Credit_Score >=700 AND credit_score <= 749 Then '700–749'
		When Credit_Score >=700 Then '750+'
		Else 'Error'
		END AS Credit_bucket,
CAST(SUM(CASE WHEN Loan.defaulted = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(Loan.loan_id) * 100 AS Default_Rate
FROM Borrower_Profiles AS Bor
JOIN loan_applications AS Loan
ON Bor.borrower_id = loan.borrower_id
GROUP BY 
    CASE
		When Credit_Score >=520 AND credit_score <= 599 Then '520-599'
		When Credit_Score >=600 AND credit_score <= 649 Then '600–649'
		When Credit_Score >=650 AND credit_score <= 699 Then '650–699'
		When Credit_Score >=700 AND credit_score <= 749 Then '700–749'
		When Credit_Score >=700 Then '750+'
		Else 'Error'
		END
ORDER By Credit_bucket;

--Creating view to visualize credit segment deafaults

GO
CREATE VIEW credscore_segment_default_rate AS
Select 
		CASE
		When Credit_Score >=520 AND credit_score <= 599 Then '520-599'
		When Credit_Score >=600 AND credit_score <= 649 Then '600–649'
		When Credit_Score >=650 AND credit_score <= 699 Then '650–699'
		When Credit_Score >=700 AND credit_score <= 749 Then '700–749'
		When Credit_Score >=700 Then '750+'
		Else 'Error'
		END AS Credit_bucket,
CAST(SUM(CASE WHEN Loan.defaulted = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(Loan.loan_id) * 100 AS Default_Rate
FROM Borrower_Profiles AS Bor
JOIN loan_applications AS Loan
ON Bor.borrower_id = loan.borrower_id
GROUP BY 
    CASE
		When Credit_Score >=520 AND credit_score <= 599 Then '520-599'
		When Credit_Score >=600 AND credit_score <= 649 Then '600–649'
		When Credit_Score >=650 AND credit_score <= 699 Then '650–699'
		When Credit_Score >=700 AND credit_score <= 749 Then '700–749'
		When Credit_Score >=700 Then '750+'
		Else 'Error'
		END
;
GO

-- how many loans went to the best credit scores? if more than half recommending limit to the best is feasable.

SELECT COUNT(L.loan_id) AS no_CS700_and_UP_loans
FROM loan_applications AS L
Join Borrower_Profiles AS B
ON B.borrower_id = L.borrower_id
WHERE B.credit_score >= 700
;

--- Debt-To-Income (DTI) segmentation. Taking a look at the DTI format
Select B.borrower_id, loan_id, dti_Ratio
FROM loan_applications AS L
Join Borrower_Profiles AS B
ON B.borrower_id = L.borrower_id

--Check top 15 and bottom 15 for data format and ranges to confirm appropriate segment sizes

Select top 15 borrower_id, loan_id, dti_Ratio
FROM loan_applications
Order by dti_Ratio Desc
;

Select top 15 borrower_id, loan_id, dti_Ratio
FROM loan_applications
Order by dti_Ratio 
;

--Highest 177.40% lowest 7.6% Ranges should be 25% intervals to make 7 in total  
--Default rate results show  DTI of 25% or lower: 11.39%, DTI of 26%-50%: 17.46%, DTI of 51%-75%: 35.96%, 
--DTI of 76%-100%: 26.67%, DTI of 101%-125%: 33.33%, DTI of 126%-150%: 40.00%, DTI of 151% or above: 50%

SELECT
	CASE 
	WHEN dti_ratio <= 25 THEN '1: 0%-25%'
	WHEN dti_ratio > 25 AND dti_ratio <= 50  THEN '2: 26%-50%'
	WHEN dti_ratio > 50 AND dti_ratio <= 75  THEN '3: 51%-75%'
	WHEN dti_ratio > 75 AND dti_ratio <= 100  THEN '4: 76%-100%'
	WHEN dti_ratio > 100 AND dti_ratio <= 125  THEN '5: 101%-125%'
	WHEN dti_ratio > 125 AND dti_ratio <= 150  THEN '6: 126%-150'
	WHEN dti_ratio > 150 THEN '7: 151% +'
	ELSE 'Error'
	END AS DTI_Bucket,
CAST(SUM(CASE WHEN L.defaulted = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(L.loan_id) * 100 AS Default_Rate
FROM Borrower_Profiles AS B
JOIN loan_applications AS L
ON B.borrower_id = L.borrower_id
GROUP BY
	CASE 
	WHEN dti_ratio <= 25 THEN '1: 0%-25%'
	WHEN dti_ratio > 25 AND dti_ratio <= 50  THEN '2: 26%-50%'
	WHEN dti_ratio > 50 AND dti_ratio <= 75  THEN '3: 51%-75%'
	WHEN dti_ratio > 75 AND dti_ratio <= 100  THEN '4: 76%-100%'
	WHEN dti_ratio > 100 AND dti_ratio <= 125  THEN '5: 101%-125%'
	WHEN dti_ratio > 125 AND dti_ratio <= 150  THEN '6: 126%-150'
	WHEN dti_ratio > 150 THEN '7: 151% +'
	ELSE 'Error'
	END
order by DTI_Bucket;


--creating dti view for visualiztion

GO
CREATE VIEW dti_segmented_default_rate AS
SELECT
	CASE 
	WHEN dti_ratio <= 25 THEN '1: 0%-25%'
	WHEN dti_ratio > 25 AND dti_ratio <= 50  THEN '2: 26%-50%'
	WHEN dti_ratio > 50 AND dti_ratio <= 75  THEN '3: 51%-75%'
	WHEN dti_ratio > 75 AND dti_ratio <= 100  THEN '4: 76%-100%'
	WHEN dti_ratio > 100 AND dti_ratio <= 125  THEN '5: 101%-125%'
	WHEN dti_ratio > 125 AND dti_ratio <= 150  THEN '6: 126%-150'
	WHEN dti_ratio > 150 THEN '7: 151% +'
	ELSE 'Error'
	END AS DTI_Bucket,
CAST(SUM(CASE WHEN L.defaulted = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(L.loan_id)  * 100 AS Default_Rate
FROM Borrower_Profiles AS B
JOIN loan_applications AS L
ON B.borrower_id = L.borrower_id
GROUP BY
	CASE 
	WHEN dti_ratio <= 25 THEN '1: 0%-25%'
	WHEN dti_ratio > 25 AND dti_ratio <= 50  THEN '2: 26%-50%'
	WHEN dti_ratio > 50 AND dti_ratio <= 75  THEN '3: 51%-75%'
	WHEN dti_ratio > 75 AND dti_ratio <= 100  THEN '4: 76%-100%'
	WHEN dti_ratio > 100 AND dti_ratio <= 125  THEN '5: 101%-125%'
	WHEN dti_ratio > 125 AND dti_ratio <= 150  THEN '6: 126%-150'
	WHEN dti_ratio > 150 THEN '7: 151% +'
	ELSE 'Error'
	END
;
GO

SELECT *
FROM
dti_segmented_default_rate

---  Loan Purpose segmentation: Verifiying types
SELECT DISTINCT l.loan_purpose
FROM Borrower_Profiles AS B
JOIN loan_applications AS L
ON B.borrower_id = L.borrower_id

-- Creating loan purpose segment default rates: Auto Loan= 27.12%, Business Loan= 24.14%, Debt Consolidation= 21.57%, Education= 22.64%, 
-- Home Improvement= 28.57%, Major Purchase= 22.06%, Medical Expenses= 20.59%, Moving= 21.43%, Vacation= 22.58%, Wedding= 32.14%


SELECT l.loan_purpose,
CAST(SUM(CASE WHEN L.defaulted = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(L.loan_id) AS Default_Rate
FROM Borrower_Profiles AS B
JOIN loan_applications AS L
ON B.borrower_id = L.borrower_id
GROUP BY l.loan_purpose
order by l.loan_purpose
;

--creating view for loan purpose visualiztion
GO
CREATE VIEW loan_purpose_default_rate AS
SELECT l.loan_purpose,
CAST(SUM(CASE WHEN L.defaulted = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(L.loan_id) * 100 AS Default_Rate
FROM Borrower_Profiles AS B
JOIN loan_applications AS L
ON B.borrower_id = L.borrower_id
GROUP BY l.loan_purpose
;
GO



--AVG loan amount for defaulted loans vs non-defaultt

SELECT *
FROM loan_applications
;

SELECT 	CASE WHEN defaulted = 1 THEN 'Defaulted Loan' 
		 ELSE 'Non-Defaulted Loan'
		 END AS loan_status,
AVG(loan_amount) AS avg_loan, MIN(loan_amount) AS lowest_loan, MAX(loan_amount) AS highest_loan, defaulted
FROM loan_applications
GROUP BY defaulted
;

--Create visualizition view for defaulted vs non-defaulted loans
GO
Create View default_vs_non_default_loans AS
SELECT 	CASE WHEN defaulted = 1 THEN 'Defaulted Loan' 
		 ELSE 'Non-Defaulted Loan'
		 END AS loan_status,
AVG(loan_amount) AS avg_loan, MIN(loan_amount) AS lowest_loan, MAX(loan_amount) AS highest_loan, defaulted
FROM loan_applications
GROUP BY defaulted
;
GO
 
 SELECT *
 FROM default_vs_non_default_loans

--- Employment Status segmentation: Self-Employed, Full-Time, Part-time, Contract, Retired

SELECT DISTINCT b.employment_status
FROM Borrower_Profiles AS B
JOIN loan_applications AS L
ON B.borrower_id = L.borrower_id

-- Creating employments status buckets. Self-Employed= 24.76%, Full-Time= 23.93%, Part-time= 27.69, Contract= 22.72%, Retired= 23.33%

SELECT b.employment_status, 
CAST(SUM(CASE WHEN L.defaulted = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(L.loan_id) AS general_default_rate
FROM Borrower_Profiles AS B
JOIN loan_applications AS L
ON B.borrower_id = L.borrower_id
GROUP BY b.employment_status
order by b.employment_status;
;

-- employment status and tenure and default rate for 2year or more employed vs less than 2 years

SELECT b.employment_status,
CASE
			WHEN	years_employed >= 2 THEN '2 or more years'
			else 'Fewer than 2 years'
			End AS employment_tenure,
CAST(SUM(CASE WHEN L.defaulted = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(L.loan_id) AS employment_type_default_rate
FROM Borrower_Profiles AS B
JOIN loan_applications AS L
ON B.borrower_id = L.borrower_id
Group by	b.employment_status,
			CASE
			WHEN	years_employed >= 2 THEN '2 or more years'
			else 'Fewer than 2 years'
			End 
			;

-- breakdown of differences based on years employed

WITH diff_btw_2yr_employment AS (
								 SELECT
								 b.employment_status,
								 CASE
						WHEN	years_employed >= 2 THEN '2 or more years'
						else 'Fewer than 2 years'
						End AS employment_tenure,
						CAST(SUM(CASE WHEN L.defaulted = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(L.loan_id) * 100 AS employment_type_default_rate
FROM Borrower_Profiles AS B
JOIN loan_applications AS L
ON B.borrower_id = L.borrower_id
Group by	b.employment_status,
			CASE
			WHEN	years_employed >= 2 THEN '2 or more years'
			else 'Fewer than 2 years'
			End )
SELECT
employment_status,
    MAX(CASE WHEN employment_tenure = 'Fewer than 2 years' THEN employment_type_default_rate ELSE 0 END) AS Rate_Under_2_Years,
    MAX(CASE WHEN employment_tenure = '2 or more years' THEN employment_type_default_rate ELSE 0 END) AS Rate_2_Plus_Years,
		MAX(CASE WHEN employment_tenure = 'Fewer than 2 years' THEN employment_type_default_rate ELSE 0 END)  - 
		MAX(CASE WHEN employment_tenure = '2 or more years' THEN employment_type_default_rate ELSE 0 END) AS Default_Rate_Difference
FROM diff_btw_2yr_employment
GROUP BY employment_status;

GO
CREATE VIEW two_year_employment_default_rate AS
WITH diff_btw_2yr_employment AS (
								 SELECT
								 b.employment_status,
								 CASE
						WHEN	years_employed >= 2 THEN '2 or more years'
						else 'Fewer than 2 years'
						End AS employment_tenure,
						CAST(SUM(CASE WHEN L.defaulted = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(L.loan_id) * 100 AS employment_type_default_rate
FROM Borrower_Profiles AS B
JOIN loan_applications AS L
ON B.borrower_id = L.borrower_id
Group by	b.employment_status,
			CASE
			WHEN	years_employed >= 2 THEN '2 or more years'
			else 'Fewer than 2 years'
			End )
SELECT
employment_status,
    MAX(CASE WHEN employment_tenure = 'Fewer than 2 years' THEN employment_type_default_rate ELSE 0 END) AS Rate_Under_2_Years,
    MAX(CASE WHEN employment_tenure = '2 or more years' THEN employment_type_default_rate ELSE 0 END) AS Rate_2_Plus_Years,
		MAX(CASE WHEN employment_tenure = 'Fewer than 2 years' THEN employment_type_default_rate ELSE 0 END)  - 
		MAX(CASE WHEN employment_tenure = '2 or more years' THEN employment_type_default_rate ELSE 0 END) AS Default_Rate_Difference
FROM diff_btw_2yr_employment
GROUP BY employment_status
;
Go

Select *
from two_year_employment_default_rate;

--income analysis

SELECT CASE
						WHEN b.annual_income <= 45000 THEN '45000 or less'
						WHEN b.annual_income > 45000 AND b.annual_income <= 60000 THEN '45000 - 60000'
						WHEN b.annual_income > 60000 AND b.annual_income <= 75000 THEN '60000 - 75000'
						WHEN b.annual_income > 75000 AND b.annual_income <= 90000 THEN '75000 - 90000'
						WHEN b.annual_income > 90000 AND b.annual_income <= 105000 THEN '90000 - 105000'
						WHEN b.annual_income > 105000 AND b.annual_income <= 120000 THEN '105000 -120000'
						WHEN b.annual_income > 120000 THEN '120000 or more'
						ELSE 'Error' END AS salary_segments,
CAST(SUM(CASE WHEN L.defaulted = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(L.loan_id) * 100 AS salary_seg_default_rate,
CASE
						WHEN b.annual_income <= 45000 THEN 'A'
						WHEN b.annual_income > 45000 AND b.annual_income <= 60000 THEN 'B'
						WHEN b.annual_income > 60000 AND b.annual_income <= 75000 THEN 'C'
						WHEN b.annual_income > 75000 AND b.annual_income <= 90000 THEN 'D'
						WHEN b.annual_income > 90000 AND b.annual_income <= 105000 THEN 'E'
						WHEN b.annual_income > 105000 AND b.annual_income <= 120000 THEN 'F'
						WHEN b.annual_income > 120000 THEN 'G'
						ELSE 'Error' END AS sal_seg_order
FROM borrower_profiles AS b
JOIN loan_applications AS L
ON b.borrower_id = l.borrower_ID
GROUP BY CASE
						WHEN b.annual_income <= 45000 THEN '45000 or less'
						WHEN b.annual_income > 45000 AND b.annual_income <= 60000 THEN '45000 - 60000'
						WHEN b.annual_income > 60000 AND b.annual_income <= 75000 THEN '60000 - 75000'
						WHEN b.annual_income > 75000 AND b.annual_income <= 90000 THEN '75000 - 90000'
						WHEN b.annual_income > 90000 AND b.annual_income <= 105000 THEN '90000 - 105000'
						WHEN b.annual_income > 105000 AND b.annual_income <= 120000 THEN '105000 -120000'
						WHEN b.annual_income > 120000 THEN '120000 or more'
						ELSE 'Error' END,
						CASE
						WHEN b.annual_income <= 45000 THEN 'A'
						WHEN b.annual_income > 45000 AND b.annual_income <= 60000 THEN 'B'
						WHEN b.annual_income > 60000 AND b.annual_income <= 75000 THEN 'C'
						WHEN b.annual_income > 75000 AND b.annual_income <= 90000 THEN 'D'
						WHEN b.annual_income > 90000 AND b.annual_income <= 105000 THEN 'E'
						WHEN b.annual_income > 105000 AND b.annual_income <= 120000 THEN 'F'
						WHEN b.annual_income > 120000 THEN 'G'
						ELSE 'Error' END
;

GO
CREATE VIEW annual_income_default_rate AS 
SELECT
	CASE
				WHEN b.annual_income <= 45000 THEN '45000 or less'
				WHEN b.annual_income > 45000 AND b.annual_income <= 60000 THEN '45000 - 60000'
				WHEN b.annual_income > 60000 AND b.annual_income <= 75000 THEN '60000 - 75000'
				WHEN b.annual_income > 75000 AND b.annual_income <= 90000 THEN '75000 - 90000'
				WHEN b.annual_income > 90000 AND b.annual_income <= 105000 THEN '90000 - 105000'
				WHEN b.annual_income > 105000 AND b.annual_income <= 120000 THEN '105000 -120000'
				WHEN b.annual_income > 120000 THEN '120000 or more'
				ELSE 'Error' END AS salary_segments,
	CAST(SUM(CASE WHEN L.defaulted = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(L.loan_id) * 100 AS salary_seg_default_rate,
	CASE
				WHEN b.annual_income <= 45000 THEN 'A'
				WHEN b.annual_income > 45000 AND b.annual_income <= 60000 THEN 'B'
				WHEN b.annual_income > 60000 AND b.annual_income <= 75000 THEN 'C'
				WHEN b.annual_income > 75000 AND b.annual_income <= 90000 THEN 'D'
				WHEN b.annual_income > 90000 AND b.annual_income <= 105000 THEN 'E'
				WHEN b.annual_income > 105000 AND b.annual_income <= 120000 THEN 'F'
				WHEN b.annual_income > 120000 THEN 'G'
				ELSE 'Error' END AS sal_seg_order
FROM borrower_profiles AS b
JOIN loan_applications AS L
ON b.borrower_id = l.borrower_ID
GROUP BY CASE
				WHEN b.annual_income <= 45000 THEN '45000 or less'
				WHEN b.annual_income > 45000 AND b.annual_income <= 60000 THEN '45000 - 60000'
				WHEN b.annual_income > 60000 AND b.annual_income <= 75000 THEN '60000 - 75000'
				WHEN b.annual_income > 75000 AND b.annual_income <= 90000 THEN '75000 - 90000'
				WHEN b.annual_income > 90000 AND b.annual_income <= 105000 THEN '90000 - 105000'
				WHEN b.annual_income > 105000 AND b.annual_income <= 120000 THEN '105000 -120000'
				WHEN b.annual_income > 120000 THEN '120000 or more'
				ELSE 'Error' END,
			CASE
				WHEN b.annual_income <= 45000 THEN 'A'
				WHEN b.annual_income > 45000 AND b.annual_income <= 60000 THEN 'B'
				WHEN b.annual_income > 60000 AND b.annual_income <= 75000 THEN 'C'
				WHEN b.annual_income > 75000 AND b.annual_income <= 90000 THEN 'D'
				WHEN b.annual_income > 90000 AND b.annual_income <= 105000 THEN 'E'
				WHEN b.annual_income > 105000 AND b.annual_income <= 120000 THEN 'F'
				WHEN b.annual_income > 120000 THEN 'G'
				ELSE 'Error' END
;
GO

SELECT CASE WHEN b.annual_income > 120000 THEN 'Big Bucks' Else 'irrelevant' END AS earnings,
CAST(SUM(CASE WHEN L.defaulted = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(L.loan_id) * 100 AS salary_seg_default_rate
FROM borrower_profiles AS b
JOIN loan_applications AS L
ON b.borrower_id = l.borrower_ID
GROUP BY CASE WHEN b.annual_income > 120000 THEN 'Big Bucks' Else 'irrelevant' END
;

SELECT *
FROM annual_income_default_rate
;