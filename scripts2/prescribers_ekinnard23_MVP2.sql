SELECT *
FROM cbsa 

SELECT *
FROM drug

SELECT *
FROM fips_county

SELECT *
FROM overdoses

SELECT *
FROM population

SELECT *
FROM prescriber

SELECT *
FROM prescription

SELECT *
FROM zip_fips



1. a. Which prescriber had the highest total number of claims 
	(totaled over all drugs)? Report the npi and the total number of claims.
   

SELECT npi,
	SUM(total_claim_count) AS total_claim
FROM prescription
GROUP BY npi
ORDER BY total_claim DESC;

--1881634483
    
    b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.


SELECT npi,
	SUM(total_claim_count) AS total_claim,
	nppes_provider_first_name AS provider_first_name,
	nppes_provider_last_org_name AS provider_last_name,
	specialty_description
FROM prescription
INNER JOIN prescriber
USING (npi)
GROUP BY npi, provider_first_name,provider_last_name,specialty_description
ORDER BY total_claim DESC;

--Bruce Pendley

2.  a. Which specialty had the most total number of claims (totaled over all drugs)?
	
SELECT 
	SUM(total_claim_count) AS total_claim,
	specialty_description
FROM prescription
INNER JOIN prescriber
USING (npi)
GROUP BY specialty_description
ORDER BY total_claim DESC;

--Family Practice

    b. Which specialty had the most total number of claims for opioids?
SELECT specialty_description,
	opioid_drug_flag,
	SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
USING (npi)
	INNER JOIN drug
	USING (drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY opioid_drug_flag,specialty_description
ORDER BY total_claims DESC;

--Nurse Practitioner

    c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

    d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

3.  a. Which drug (generic_name) had the highest total drug cost?
	
SELECT SUM(total_drug_cost) AS drug_cost,
	generic_name
FROM prescription
INNER JOIN drug
USING (drug_name)
GROUP BY generic_name
ORDER BY drug_cost DESC;

--Insulin


    b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
	
SELECT ROUND(SUM(total_drug_cost)/365,2) AS drug_cost_per_day,
	generic_name
FROM prescription
INNER JOIN drug
USING (drug_name)
GROUP BY generic_name
ORDER BY drug_cost_per_day DESC;

--Insulin

4. 
    a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT drug_name,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotics'
	ELSE 'neither' END AS drug_type
FROM drug



    b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
	
SELECT SUM(total_drug_cost)::money, 
	drug_name
FROM prescription
INNER JOIN drug
USING (drug_name)
WHERE opioid_drug_flag = 'Y' 
GROUP BY drug_name,total_drug_cost 
ORDER BY total_drug_cost DESC

SELECT SUM(total_drug_cost)::money, 
	drug_name
FROM prescription
INNER JOIN drug
USING (drug_name)
WHERE antibiotic_drug_flag = 'Y' 
GROUP BY drug_name,total_drug_cost 
ORDER BY total_drug_cost DESC

--Exported - Opioids 3 to 1

5. 
    a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
	
SELECT*
FROM cbsa
WHERE cbsaname ILIKE '%TN%'

    b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
	
SELECT cbsaname,
	cbsa,
	SUM(population) AS population
FROM cbsa
INNER JOIN population
USING (fipscounty)
GROUP BY cbsaname,
	cbsa
ORDER BY population DESC;

--Biggest - Nashville ; Smallest - Morristown

    c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT county,
	SUM(population) AS population
FROM cbsa
FULL JOIN fips_county
USING(fipscounty)
FULL JOIN population
USING(fipscounty)
WHERE cbsa IS NULL AND population IS NOT NULL
GROUP BY cbsa, county
ORDER BY population DESC;

--Sevier - 95523

6. 
    a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
	
	

    b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

    c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

    a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

    b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
    
    c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.