
-- ELIGIBILITY AND HARDCUT LOGIC; APPLIES "INITIAL" CLIP CALCULATION AMOUNT TO UAT RECORD
CREATE OR REPLACE TEMPORARY TABLE CLIP_SIM_TABLE AS
SELECT
  A.ACCOUNT_ID
  ,A.EVALUATED_TIMESTAMP
  ,A.CLIP_POLICY_NAME
  ,POST_CLIP_LINE_LIMIT
  ,PRE_CLIP_LINE_LIMIT
  ,POST_CLIP_LINE_LIMIT - PRE_CLIP_LINE_LIMIT as CLIP_AMOUNT
  ,decision_data
  ,decision_data:"potential_atp_net_scores" as potential_atp_net_scores
  ,decision_data:"potential_credit_lines" as potential_credit_lines
  ,A.STATEMENT_NUMBER
 
  ,decision_data:"delinquencies_in_6_months" AS COL1
  ,decision_data:"block_code__passed" AS COL2
  ,decision_data:"atp_net_score" AS COL3
  ,decision_data:"not_over_limit__passed" AS COL4
  ,CASE WHEN  
  A.STATEMENT_NUMBER = 3
--  AND decision_data:"delinquencies_in_6_months"::INT = 0
  AND decision_data:"delinquencies"::INT = 0
  AND decision_data:"block_code__passed" = 'true' --Bankrupt/Deceased/Fraud

  AND
  (CASE
  WHEN decision_data:"atp_net_score"::FLOAT > 0 THEN TRUE
  WHEN decision_data:"atp_net_score" is null THEN TRUE
  ELSE FALSE
  END)
 
  --ATP w/ $1,000 dollar CLIP imputed < 0
  AND decision_data:"not_over_limit__passed" = 'true' --Currently Overlimit
  THEN 1
  ELSE 0
  END
  as pass_eligibility
  ,decision_data:"transunion__account_review__fico_08__FICO_08" AS COL5
  ,CASE WHEN left(decision_data:"transunion__account_review__fico_08__FICO_08",1) = '+' then 0
            WHEN decision_data:"transunion__account_review__fico_08__FICO_08" = 'null' then 0 
            else decision_data:"transunion__account_review__fico_08__FICO_08"
            end AS FICO_CLEAN
  ,decision_data:"transunion__account_review__vantage_30__VANTAGE_30"::FLOAT AS COL6
  ,decision_data:"total_revolving_debt_re33s_to_income"::FLOAT AS COL7
  ,decision_data:"transunion__account_review__cv_enriched_attributes__RE33S"::FLOAT AS COL8
  ,decision_data:"non_mortgage_debt_at33b_hi33s_hr33s_to_income"::FLOAT AS COL9
  ,decision_data:"transunion__account_review__cv_enriched_attributes__BC01S"::FLOAT AS COL10
  ,decision_data:"transunion__account_review__cv_enriched_attributes__AT01S"::FLOAT AS COL11
  ,decision_data:"added_revolving_debt_re33s"::FLOAT AS COL12
  ,case when FICO_CLEAN::INT > 525 then 1 else 0 end  cond1
  ,case when decision_data:"transunion__account_review__vantage_30__VANTAGE_30"::FLOAT > 525 then 1 else 0 end cond2
  , case when decision_data:"total_revolving_debt_re33s_to_income"::FLOAT < .5  then 1 else 0 end cond3
  , case when decision_data:"transunion__account_review__cv_enriched_attributes__RE33S"::FLOAT < 25000  then 1 else 0 end cond4
  , case when decision_data:"non_mortgage_debt_at33b_hi33s_hr33s_to_income"::FLOAT < 1  then 1 else 0 end cond5
  , case when decision_data:"transunion__account_review__cv_enriched_attributes__BC01S"::FLOAT < 40  then 1 else 0 end cond6
  , case when decision_data:"transunion__account_review__cv_enriched_attributes__AT01S"::FLOAT < 80  then 1 else 0 end cond7
  , case when A.EVALUATED_TIMESTAMP >= '2021-11-04' then 1 
        when decision_data:"added_revolving_debt_re33s"::FLOAT <= 7500  then 1 else 0 end cond8
  , case when decision_data:"active_at_current_statement" = 'true' THEN 1 ELSE 0 END cond9
  ,CASE
  WHEN
  --(case when (decision_data:"transunion__account_review__fico_08__FICO_08" = '+') then 0 else decision_data:"transunion__account_review__fico_08__FICO_08" end) > 525--FICO <= 525 or invalid
  --AND 
  cond1 = 1
  and cond2 = 1
  and cond3 = 1
  and cond4 = 1
  and cond5 = 1
  and cond6 = 1
  and cond7 = 1
  and cond8 = 1
  and cond9 = 1
  THEN 1
  ELSE 0
  END
  AS account_review_hardcuts
  ,decision_data:"clip_model_c_20210811_risk_group"::INT AS clip_risk_group_INT
  ,decision_data:"average_utilization_3_months"::FLOAT AS average_utilization_3_months_FLOAT
  ,decision_data:"ab_testing_random_number"::FLOAT AS ab_testing_random_number_FLOAT
  ,decision_data:"payment_vacation__passed" AS payment_vacation__passed
  ,decision_data:"min_clip" AS min_clip
  ,decision_data:"post_pie_evaluation" AS post_pie_evaluation
  ,decision_data:"cicada_risk_group"::INT AS cicada_risk_group
  ,OUTCOME
  ,TEST_SEGMENT
  ,decision_data:"delinquencies"::INT AS delinquencies_count
,CASE WHEN pass_eligibility = 0 OR account_review_hardcuts = 0 OR payment_vacation__passed = 'false' THEN 0
WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 1 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 500
WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 1 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 500
WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 1 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 500
WHEN cicada_risk_group = 2 AND clip_risk_group_INT = 1 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 500
WHEN cicada_risk_group = 3 AND clip_risk_group_INT = 1 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 500
WHEN cicada_risk_group = 4 AND clip_risk_group_INT = 1 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 500
WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 2 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 500
WHEN cicada_risk_group = 2 AND clip_risk_group_INT = 2 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 500
WHEN cicada_risk_group = 3 AND clip_risk_group_INT = 2 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 500
WHEN cicada_risk_group = 4 AND clip_risk_group_INT = 2 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 500
WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 3 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 500
WHEN cicada_risk_group = 2 AND clip_risk_group_INT = 3 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 500
WHEN cicada_risk_group = 3 AND clip_risk_group_INT = 3 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 300
WHEN cicada_risk_group = 4 AND clip_risk_group_INT = 3 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 300
WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 4 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 500
WHEN cicada_risk_group = 2 AND clip_risk_group_INT = 4 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 500
WHEN cicada_risk_group = 3 AND clip_risk_group_INT = 4 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 300
WHEN cicada_risk_group = 4 AND clip_risk_group_INT = 4 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 300
WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 5 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 300
WHEN cicada_risk_group = 2 AND clip_risk_group_INT = 5 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 300
WHEN cicada_risk_group = 3 AND clip_risk_group_INT = 5 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 0
WHEN cicada_risk_group = 4 AND clip_risk_group_INT = 5 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 0
WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 6 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 300
WHEN cicada_risk_group = 2 AND clip_risk_group_INT = 6 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 300
WHEN cicada_risk_group = 3 AND clip_risk_group_INT = 6 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 0
WHEN cicada_risk_group = 4 AND clip_risk_group_INT = 6 AND ab_testing_random_number_FLOAT >= 0.2 AND ab_testing_random_number_FLOAT < 0.8 THEN 0
WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 1 AND ab_testing_random_number_FLOAT >= 0.8 THEN 1000
WHEN cicada_risk_group = 2 AND clip_risk_group_INT = 1 AND ab_testing_random_number_FLOAT >= 0.8 THEN 1000
WHEN cicada_risk_group = 3 AND clip_risk_group_INT = 1 AND ab_testing_random_number_FLOAT >= 0.8 THEN 1000
WHEN cicada_risk_group = 4 AND clip_risk_group_INT = 1 AND ab_testing_random_number_FLOAT >= 0.8 THEN 1000
WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 2 AND ab_testing_random_number_FLOAT >= 0.8 THEN 1000
WHEN cicada_risk_group = 2 AND clip_risk_group_INT = 2 AND ab_testing_random_number_FLOAT >= 0.8 THEN 1000
WHEN cicada_risk_group = 3 AND clip_risk_group_INT = 2 AND ab_testing_random_number_FLOAT >= 0.8 THEN 1000
WHEN cicada_risk_group = 4 AND clip_risk_group_INT = 2 AND ab_testing_random_number_FLOAT >= 0.8 THEN 1000
WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 3 AND ab_testing_random_number_FLOAT >= 0.8 THEN 1000
WHEN cicada_risk_group = 2 AND clip_risk_group_INT = 3 AND ab_testing_random_number_FLOAT >= 0.8 THEN 1000
WHEN cicada_risk_group = 3 AND clip_risk_group_INT = 3 AND ab_testing_random_number_FLOAT >= 0.8 THEN 500
WHEN cicada_risk_group = 4 AND clip_risk_group_INT = 3 AND ab_testing_random_number_FLOAT >= 0.8 THEN 500
WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 4 AND ab_testing_random_number_FLOAT >= 0.8 THEN 1000
WHEN cicada_risk_group = 2 AND clip_risk_group_INT = 4 AND ab_testing_random_number_FLOAT >= 0.8 THEN 1000
WHEN cicada_risk_group = 3 AND clip_risk_group_INT = 4 AND ab_testing_random_number_FLOAT >= 0.8 THEN 500
WHEN cicada_risk_group = 4 AND clip_risk_group_INT = 4 AND ab_testing_random_number_FLOAT >= 0.8 THEN 500
WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 5 AND ab_testing_random_number_FLOAT >= 0.8 THEN 500
WHEN cicada_risk_group = 2 AND clip_risk_group_INT = 5 AND ab_testing_random_number_FLOAT >= 0.8 THEN 500
WHEN cicada_risk_group = 3 AND clip_risk_group_INT = 5 AND ab_testing_random_number_FLOAT >= 0.8 THEN 0
WHEN cicada_risk_group = 4 AND clip_risk_group_INT = 5 AND ab_testing_random_number_FLOAT >= 0.8 THEN 0
WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 6 AND ab_testing_random_number_FLOAT >= 0.8 THEN 500
WHEN cicada_risk_group = 2 AND clip_risk_group_INT = 6 AND ab_testing_random_number_FLOAT >= 0.8 THEN 500
WHEN cicada_risk_group = 3 AND clip_risk_group_INT = 6 AND ab_testing_random_number_FLOAT >= 0.8 THEN 0
WHEN cicada_risk_group = 4 AND clip_risk_group_INT = 6 AND ab_testing_random_number_FLOAT >= 0.8 THEN 0
ELSE 0 END AS CLIP_AMOUNT_FIRST
  ,decision_data:"TEST_SEGMENT" AS COL13
  ,decision_data:"clip_risk_group" AS COL14
  ,decision_data:"average_utilization_3_months" COL15
  ,decision_data:"ab_testing_random_number" AS COL16
  ,CLIP_AMOUNT_FIRST - CLIP_AMOUNT as difference
--  ,pass_eligibility
--  ,account_review_hardcuts
--  ,CLIP_AMOUNT
FROM    edw_db.public.clip_results_data A
WHERE   STATEMENT_NUMBER = 3
        AND CLIP_POLICY_NAME = 'YEAR_1_STATEMENT3_20220601'
        
--  AND A.EVALUATED_TIMESTAMP > '2022-04-01'
  AND (PRE_EVALUATION = FALSE OR PRE_EVALUATION IS NULL)
--  AND CLIP_POLICY_NAME = 'BAILEY_CONCLIP_20220307'
  --AND difference <> 0
;


-- PRE-EXISTING CODE TO REFORMAT ATP SCORES
CREATE OR REPLACE TEMPORARY TABLE INFO_ATP_NET_SCORES AS
SELECT 
  A.ACCOUNT_ID 
  ,A.EVALUATED_TIMESTAMP
  ,TRIM(B.VALUE) AS potential_atp_net_scores
  ,ROW_NUMBER() OVER (PARTITION BY A.ACCOUNT_ID , A.EVALUATED_TIMESTAMP ORDER BY A.EVALUATED_TIMESTAMP) R_NUM
FROM  CLIP_SIM_TABLE  A
, TABLE(SPLIT_TO_TABLE(A.decision_data:"potential_atp_net_scores"::STRING, ',')) B
WHERE
  decision_data:"potential_atp_net_scores"::STRING <> '[]'
;

-- PRE-EXISTING CODE TO REFORMAT ATP SCORES
CREATE OR REPLACE TEMPORARY TABLE INFO_CL AS
SELECT A.ACCOUNT_ID , A.EVALUATED_TIMESTAMP , TRIM(C.VALUE) AS potential_credit_lines,
ROW_NUMBER() OVER (PARTITION BY A.ACCOUNT_ID , A.EVALUATED_TIMESTAMP ORDER BY A.EVALUATED_TIMESTAMP) R_NUM
FROM  CLIP_SIM_TABLE  A, TABLE(SPLIT_TO_TABLE(A.decision_data:"potential_credit_lines"::STRING, ',')) C
WHERE
  decision_data:"potential_atp_net_scores"::STRING <> '[]'
;

-- PRE-EXISTING CODE TO REFORMAT ATP SCORES
CREATE OR REPLACE TEMPORARY TABLE INFO_ATP_CL AS
SELECT 
A.ACCOUNT_ID
,A.EVALUATED_TIMESTAMP
,A.R_NUM AS ATP_ROW
,B.R_NUM AS CL_ROW
,REPLACE(REPLACE(potential_atp_net_scores,'[',''),']','')--::FLOAT 
AS potential_atp_net_scores
,REPLACE(REPLACE(potential_credit_lines,'[',''),']','')--::FLOAT 
    AS potential_credit_lines
FROM INFO_ATP_NET_SCORES A 
INNER JOIN INFO_CL B 
ON A.ACCOUNT_ID = B.ACCOUNT_ID 
    AND A.EVALUATED_TIMESTAMP = B.EVALUATED_TIMESTAMP
    AND A.R_NUM=B.R_NUM
WHERE (potential_atp_net_scores IS NOT NULL OR potential_credit_lines IS NOT NULL)
ORDER BY A.ACCOUNT_ID, A.R_NUM
;

--CREATES TABLES WITH MAX CREDIT LINE BASED ON ATP BY ACCOUNT AND EVAL TIMESTAMP
CREATE OR REPLACE TEMPORARY TABLE Info_MAX_CL AS
SELECT ACCOUNT_ID,EVALUATED_TIMESTAMP, MAX( CASE WHEN potential_atp_net_scores>0 THEN  potential_credit_lines ELSE 0 END ) AS potential_credit_lines_max
FROM INFO_ATP_CL

GROUP BY 1,2
;

--REVISES CLIP AMOUNT IN CASES WHEN NEW LINE IS OVER MAX
CREATE OR REPLACE TEMPORARY TABLE CL_THRESHOLD AS
SELECT  A.ACCOUNT_ID,
        A.EVALUATED_TIMESTAMP,
        A.CLIP_POLICY_NAME,
        STATEMENT_NUMBER,
        decision_data,
        cicada_risk_group,
        CLIP_RISK_GROUP_INT,
        cond9 AS currently_active_hardcut,
        AVERAGE_UTILIZATION_3_MONTHS_FLOAT,
        CASE WHEN AVERAGE_UTILIZATION_3_MONTHS_FLOAT < 0.1 THEN 'UTIL12'
            WHEN AVERAGE_UTILIZATION_3_MONTHS_FLOAT < 0.3 THEN 'UTIL3'
            WHEN AVERAGE_UTILIZATION_3_MONTHS_FLOAT < 0.5 THEN 'UTIL4'
            WHEN AVERAGE_UTILIZATION_3_MONTHS_FLOAT < 0.8 THEN 'UTIL5'
            ELSE 'UTIL6' END AS UTIL_BAND,
        AB_TESTING_RANDOM_NUMBER_FLOAT,
        OUTCOME,
        TEST_SEGMENT,
        pass_eligibility,
        account_review_hardcuts,
        delinquencies_count,
        PRE_CLIP_LINE_LIMIT,
        CLIP_AMOUNT,
        CASE WHEN CLIP_AMOUNT_FIRST + PRE_CLIP_LINE_LIMIT > 5000 THEN 5000 - PRE_CLIP_LINE_LIMIT ELSE CLIP_AMOUNT_FIRST END AS CLIP_AMOUNT_FIRST
        
FROM    CLIP_SIM_TABLE A
;        

--REVISES CLIP AMOUNT FOR RECORDS THAT FAIL ATP CALC; CONSIDERS ROLLOUT LINE FOR TEST RECORDS
CREATE OR REPLACE TEMPORARY TABLE CLIP_FINAL AS
SELECT  A.ACCOUNT_ID,
        A.EVALUATED_TIMESTAMP,
        A.CLIP_POLICY_NAME,
        STATEMENT_NUMBER,
--        decision_data,
        cicada_risk_group,
        CLIP_RISK_GROUP_INT,
        AVERAGE_UTILIZATION_3_MONTHS_FLOAT,
        UTIL_BAND,
        OUTCOME,
        AB_TESTING_RANDOM_NUMBER_FLOAT,
        TEST_SEGMENT,
        pass_eligibility,
        account_review_hardcuts,
        --decision_data:"delinquencies_in_6_months",
        --decision_data:"block_code__passed",
        --decision_data:"atp_net_score",
        --decision_data:"not_over_limit__passed",
        currently_active_hardcut,
        delinquencies_count,
        PRE_CLIP_LINE_LIMIT,
        CLIP_AMOUNT AS CLIP_AMOUNT_ENG,
        CLIP_AMOUNT_FIRST AS CLIP_AMOUNT_INITIAL,
        CASE WHEN (potential_credit_lines_max - PRE_CLIP_LINE_LIMIT) > 0 THEN potential_credit_lines_max - PRE_CLIP_LINE_LIMIT ELSE 0 END
            AS MAX_ATP_CLIP_AMOUNT,
        CASE WHEN CLIP_AMOUNT_FIRST <= MAX_ATP_CLIP_AMOUNT THEN CLIP_AMOUNT_FIRST
            WHEN AB_TESTING_RANDOM_NUMBER_FLOAT < 0.8 THEN 0
            WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 1 AND (PRE_CLIP_LINE_LIMIT + 500 <= potential_credit_lines_max) THEN 500
            WHEN cicada_risk_group = 2 AND clip_risk_group_INT = 1 AND (PRE_CLIP_LINE_LIMIT + 500 <= potential_credit_lines_max) THEN 500
            WHEN cicada_risk_group = 3 AND clip_risk_group_INT = 1 AND (PRE_CLIP_LINE_LIMIT + 500 <= potential_credit_lines_max) THEN 500
            WHEN cicada_risk_group = 4 AND clip_risk_group_INT = 1 AND (PRE_CLIP_LINE_LIMIT + 500 <= potential_credit_lines_max) THEN 500
            WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 2 AND (PRE_CLIP_LINE_LIMIT + 500 <= potential_credit_lines_max) THEN 500
            WHEN cicada_risk_group = 2 AND clip_risk_group_INT = 2 AND (PRE_CLIP_LINE_LIMIT + 500 <= potential_credit_lines_max) THEN 500
            WHEN cicada_risk_group = 3 AND clip_risk_group_INT = 2 AND (PRE_CLIP_LINE_LIMIT + 500 <= potential_credit_lines_max) THEN 500
            WHEN cicada_risk_group = 4 AND clip_risk_group_INT = 2 AND (PRE_CLIP_LINE_LIMIT + 500 <= potential_credit_lines_max) THEN 500
            WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 3 AND (PRE_CLIP_LINE_LIMIT + 500 <= potential_credit_lines_max) THEN 500
            WHEN cicada_risk_group = 2 AND clip_risk_group_INT = 3 AND (PRE_CLIP_LINE_LIMIT + 500 <= potential_credit_lines_max) THEN 500
            WHEN cicada_risk_group = 3 AND clip_risk_group_INT = 3 AND (PRE_CLIP_LINE_LIMIT + 300 <= potential_credit_lines_max) THEN 300
            WHEN cicada_risk_group = 4 AND clip_risk_group_INT = 3 AND (PRE_CLIP_LINE_LIMIT + 300 <= potential_credit_lines_max) THEN 300
            WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 4 AND (PRE_CLIP_LINE_LIMIT + 500 <= potential_credit_lines_max) THEN 500
            WHEN cicada_risk_group = 2 AND clip_risk_group_INT = 4 AND (PRE_CLIP_LINE_LIMIT + 500 <= potential_credit_lines_max) THEN 500
            WHEN cicada_risk_group = 3 AND clip_risk_group_INT = 4 AND (PRE_CLIP_LINE_LIMIT + 300 <= potential_credit_lines_max) THEN 300
            WHEN cicada_risk_group = 4 AND clip_risk_group_INT = 4 AND (PRE_CLIP_LINE_LIMIT + 300 <= potential_credit_lines_max) THEN 300
            WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 5 AND (PRE_CLIP_LINE_LIMIT + 300 <= potential_credit_lines_max) THEN 300
            WHEN cicada_risk_group = 2 AND clip_risk_group_INT = 5 AND (PRE_CLIP_LINE_LIMIT + 300 <= potential_credit_lines_max) THEN 300
            WHEN cicada_risk_group = 3 AND clip_risk_group_INT = 5 AND (PRE_CLIP_LINE_LIMIT + 0 <= potential_credit_lines_max) THEN 0
            WHEN cicada_risk_group = 4 AND clip_risk_group_INT = 5 AND (PRE_CLIP_LINE_LIMIT + 0 <= potential_credit_lines_max) THEN 0
            WHEN cicada_risk_group = 1 AND clip_risk_group_INT = 6 AND (PRE_CLIP_LINE_LIMIT + 300 <= potential_credit_lines_max) THEN 300
            WHEN cicada_risk_group = 2 AND clip_risk_group_INT = 6 AND (PRE_CLIP_LINE_LIMIT + 300 <= potential_credit_lines_max) THEN 300
            WHEN cicada_risk_group = 3 AND clip_risk_group_INT = 6 AND (PRE_CLIP_LINE_LIMIT + 0 <= potential_credit_lines_max) THEN 0
            WHEN cicada_risk_group = 4 AND clip_risk_group_INT = 6 AND (PRE_CLIP_LINE_LIMIT + 0 <= potential_credit_lines_max) THEN 0      
            ELSE 0 END AS CLIP_AMOUNT_CREDIT,
            CLIP_AMOUNT - CLIP_AMOUNT_CREDIT AS DIFFERENCE

FROM    CL_THRESHOLD A
        LEFT JOIN Info_MAX_CL B ON A.ACCOUNT_ID = B.ACCOUNT_ID AND A.EVALUATED_TIMESTAMP = B.EVALUATED_TIMESTAMP
;

--RETURNS RECORDS WHERE THERE IS A DIFFERENCE BETWEEN ENGINEERS CLIP ASSIGNMENT AND CREDITS CALCULATION
SELECT  *
FROM    CLIP_FINAL
WHERE   DIFFERENCE <> 0
