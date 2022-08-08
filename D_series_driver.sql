																								
DROP table if exists covid_util_adj;																									
Create temp table covid_util_adj																									
( MONTH DATE,																									
pbad DECIMAL(5,3),																									
DQ30 DECIMAL(5,3),																									
DQ30_plus_usd DECIMAL(5,3),																									
util DECIMAL(5,3));																									
																									
INSERT INTO covid_util_adj																									
(MONTH, pbad, DQ30, DQ30_plus_usd, util)																									
VALUES																									
																									
('01/01/2020', 1, 1, 1, 1),																									
('02/01/2020', 1, 1, 1, 1),																									
('03/01/2020', 1, 1, 1, 0.98),																									
('04/01/2020', 1, 0.896, 0.918, 0.96),																									
('05/01/2020', 0.993, 0.813, 0.852, 0.92),																									
('06/01/2020', 0.938, 0.684, 0.773, 0.89),																									
('07/01/2020', 0.856, 0.578, 0.689, 0.86),																									
('08/01/2020', 0.84, 0.516, 0.611, 0.84),																									
('09/01/2020', 0.78, 0.495, 0.546, 0.82),																									
('10/01/2020', 0.725, 0.5, 0.494, 0.8),																									
('11/01/2020', 0.637, 0.507, 0.463, 0.81),																									
('12/01/2020', 0.567, 0.551, 0.455, 0.82),																									
																									
('01/01/2021', 0.517, 0.656, 0.473, 0.83),																									
('02/01/2021', 0.49, 0.669, 0.494, 0.82),																									
('03/01/2021', 0.51, 0.622, 0.502, 0.79),																									
('04/01/2021', 0.525, 0.453, 0.479, 0.76),																									
('05/01/2021', 0.571, 0.37, 0.442, 0.73),																									
('06/01/2021', 0.62, 0.353, 0.395, 0.72),																									
('07/01/2021', 0.602, 0.383, 0.358, 0.72),																									
('08/01/2021', 0.545, 0.41, 0.332, 0.73),																									
('09/01/2021', 0.431, 0.429, 0.334, 0.72),																									
('10/01/2021', 0.384, 0.493, 0.374, 0.71),																									
('11/01/2021', 0.347, 0.558, 0.432, 0.7),																									
('12/01/2021', 0.348, 0.562, 0.482, 0.7),																									
																									
('01/01/2022', 0.338, 0.525, 0.5, 0.71),																									
('02/01/2022', 0.36, 0.491, 0.509, 0.7),																									
('03/01/2022', 0.387, 0.499, 0.517, 0.69),																									
('04/01/2022', 0.433, 0.47, 0.517, 0.68),																									
('05/01/2022', 0.437, 0.462, 0.508, 0.67),																									
('06/01/2022', 0.429, 0.476, 0.504, 0.64)																									
;																									
																									
		
        
        
																								
DROP table if exists covid_util_adj_granular;																									
Create temp table covid_util_adj_granular																									
( MONTH DATE,																									
util2 DECIMAL(5,3),																									
util3 DECIMAL(5,3),																									
util4 DECIMAL(5,3),																									
util5 DECIMAL(5,3),
util6 DECIMAL(5,3));																									
																									
INSERT INTO covid_util_adj_granular																									
(MONTH, util2, util3, util4, util5, util6)																									
VALUES																									
																									
('01/01/2020', 1, 1, 1, 1,1),																									
('02/01/2020', 1, 1, 1, 1,1),																									
('03/01/2020', 0.90, 0.90,0.92,0.95,0.97),																									
('04/01/2020', 0.84, 0.85,0.88,0.91,0.95),																									
('05/01/2020', 0.78, 0.78,0.82,0.86,0.92),																									
('06/01/2020', 0.74, 0.76,0.80,0.84,0.91),																									
('07/01/2020', 0.72, 0.76,0.80,0.83,0.90),																									
('08/01/2020', 0.69, 0.76,0.81,0.84,0.90),																									
('09/01/2020', 0.71, 0.77,0.82,0.85,0.89),																									
('10/01/2020', 0.70, 0.77,0.83,0.85,0.89),																									
('11/01/2020', 0.73, 0.79,0.84,0.86,0.89),																									
('12/01/2020', 0.77, 0.83,0.88,0.89,0.90),																									
																									
('01/01/2021', 0.85, 0.89,0.92,0.91,0.90),																									
('02/01/2021', 0.80, 0.84,0.88,0.89,0.90),																									
('03/01/2021', 0.71, 0.76,0.80,0.81,0.84),																									
('04/01/2021', 0.65, 0.70,0.74,0.76,0.80),																									
('05/01/2021', 0.65, 0.70,0.74,0.76,0.80),																									
('06/01/2021', 0.69, 0.75,0.78,0.79,0.81),																									
('07/01/2021', 0.73, 0.81,0.83,0.82,0.83),																									
('08/01/2021', 0.76, 0.83,0.86,0.85,0.84),																									
('09/01/2021', 0.78, 0.84,0.87,0.85,0.84),																									
('10/01/2021', 0.74, 0.82,0.85,0.84,0.83),																									
('11/01/2021', 0.76, 0.82,0.84,0.83,0.83),																									
('12/01/2021', 0.80, 0.85,0.87,0.85,0.83),																									
																									
('01/01/2022', 0.88, 0.91,0.92,0.89,0.85),																									
('02/01/2022', 0.86, 0.89,0.91,0.89,0.86),																									
('03/01/2022', 0.77, 0.82,0.83,0.83,0.83),																									
('04/01/2022', 0.76, 0.80,0.82,0.81,0.81),																									
('05/01/2022', 0.83, 0.85,0.85,0.83,0.82),																									
('06/01/2022', 0.90, 0.90,0.88,0.83,0.81),
('07/01/2022', 0.99, 0.97,0.92,0.86,0.82)
;				        
																									
																									
																									
DROP table if exists eligibility_flags;																									
Create temp table eligibility_flags as (																									
SELECT																									
sum(AVG_OUTSTANDING_BALANCE_STMT_USD)																									
over (Partition by ACCOUNT_ID																									
order by STATEMENT_NUM ASC																									
rows between 2 preceding and 0 following) as rolling_os_3																									
																									
,sum(CASE WHEN to_char(a.STATEMENT_END_DT,'YYYY-MM') = to_char(D.MONTH,'YYYY-MM') THEN AVG_OUTSTANDING_BALANCE_STMT_USD/D.util ELSE AVG_OUTSTANDING_BALANCE_STMT_USD END)																									
over (Partition by ACCOUNT_ID																									
order by STATEMENT_NUM ASC																									
rows between 2 preceding and 0 following) as rolling_os_3_COVID																									
,min(CREDIT_LIMIT_STMT_USD)
over (Partition by ACCOUNT_ID
order by STATEMENT_NUM ASC
rows  1 preceding) as last_cl
  
,sum(CREDIT_LIMIT_STMT_USD)																									
over (Partition by ACCOUNT_ID																									
order by STATEMENT_NUM ASC																									
rows between 2 preceding and 0 following) as rolling_cl_3																									
,max(STATEMENT_DELINQUENCY_BUCKET_NUM)																									
over (Partition by ACCOUNT_ID																									
order by STATEMENT_NUM ASC																									
rows between 5 preceding and 0 following) as rolling_dq_6																									
,max(STATEMENT_DELINQUENCY_BUCKET_NUM)																									
over (Partition by ACCOUNT_ID																									
order by STATEMENT_NUM ASC																									
rows between 11 preceding and 0 following) as rolling_dq_12																									
,(FEE_OTHER_BALANCE_STMT_USD+PRINCIPAL_BALANCE_STMT_USD)/CREDIT_LIMIT_STMT_USD AS CURRENTLY_OVERLIMIT																									
,CASE																									
WHEN CURRENTLY_OVERLIMIT >= 1 THEN 1																									
WHEN CURRENTLY_OVERLIMIT < 1 THEN 0																									
ELSE null																									
END AS hardcut__CURRENTLY_OVERLIMIT																									
,rolling_os_3 / rolling_cl_3 AS rolling_util_3																									
,rolling_os_3_COVID / rolling_cl_3 AS rolling_util_3_COVID																									
,CASE																									
WHEN rolling_util_3 <= .0 THEN 'A.<= 0%'																									
WHEN rolling_util_3 < .1 THEN 'B.< 10%'																									
WHEN rolling_util_3 < .3 THEN 'C.10%-30%'																									
WHEN rolling_util_3 < .5 THEN 'D.30%-50%'																									
WHEN rolling_util_3 < .8 THEN 'E.50%-80%'																									
WHEN rolling_util_3 >= .8 THEN 'F.>80%'																									
ELSE NULL																									
END AS UTILBAND_CSERIES_DEFS																									
,CASE																									
WHEN rolling_util_3_COVID <= .0 THEN 'A.<= 0%'																									
WHEN rolling_util_3_COVID < .1 THEN 'B.< 10%'																									
WHEN rolling_util_3_COVID < .3 THEN 'C.10%-30%'																									
WHEN rolling_util_3_COVID < .5 THEN 'D.30%-50%'																									
WHEN rolling_util_3_COVID < .8 THEN 'E.50%-80%'																									
WHEN rolling_util_3_COVID >= .8 THEN 'F.>80%'																									
ELSE NULL																									
END AS UTILBAND_CSERIES_DEFS_COVID																									
,CASE																									
WHEN rolling_dq_6 = 0 THEN 0																									
WHEN rolling_dq_6 > 0 THEN 1																									
ELSE NULL																									
END AS hardcut__DQ_LAST_6_STATEMENTS																									
,CASE																									
WHEN rolling_dq_12 = 0 THEN 0																									
WHEN rolling_dq_12 > 0 THEN 1																									
ELSE NULL																									
END AS hardcut__DQ_LAST_12_STATEMENTS																									
,CASE																									
WHEN  SOR = 'FIS'																									
AND BLOCK_CD = '#' THEN 0																									
WHEN  SOR = 'TSYS'																									
AND BLOCK_CD is null THEN 0																									
ELSE 1																									
END AS hardcut__BANKRUPT_DECEASED_FRAUD																									
,*																									
FROM																									
ACCOUNT_STATEMENTS a																									
LEFT JOIN																									
covid_util_adj D																									
ON to_char(a.STATEMENT_END_DT,'YYYY-MM') = to_char(D.MONTH,'YYYY-MM')																									
WHERE																									
CREDIT_LIMIT_STMT_USD <> 0																									
);																									
																									

																									
DROP TABLE IF EXISTS analysis_table;																									
CREATE TEMP TABLE analysis_table AS (																									
SELECT																									
a.CARD_ID																									
,e.account_id																									
,A.internal__fis_tsys__statement_num AS STATEMENT_NUM																									
,a.USER_ID																									
,ACCOUNT_OPEN_CNT																									
,STATEMENT_END_DT																									
,to_char(STATEMENT_END_DT,'YYYY-MM') AS STATEMENT_END_DT_Y_M																									
,hardcut__BANKRUPT_DECEASED_FRAUD																									
,hardcut__CURRENTLY_OVERLIMIT																									
,hardcut__DQ_LAST_6_STATEMENTS	
,rolling_os_3
,rolling_cl_3	
,case when UTILBAND_CSERIES_DEFS ilike '%B.%' and to_char(E.STATEMENT_END_DT,'YYYY-MM') = to_char(D.MONTH,'YYYY-MM') then rolling_os_3/D.util2 
    when UTILBAND_CSERIES_DEFS ilike '%C.%' and to_char(E.STATEMENT_END_DT,'YYYY-MM') = to_char(D.MONTH,'YYYY-MM') then rolling_os_3/D.util3 
    when UTILBAND_CSERIES_DEFS ilike '%D.%' and to_char(E.STATEMENT_END_DT,'YYYY-MM') = to_char(D.MONTH,'YYYY-MM') then rolling_os_3/D.util4 
    when UTILBAND_CSERIES_DEFS ilike '%E.%' and to_char(E.STATEMENT_END_DT,'YYYY-MM') = to_char(D.MONTH,'YYYY-MM') then rolling_os_3/D.util5 
    when UTILBAND_CSERIES_DEFS ilike '%F.%' and to_char(E.STATEMENT_END_DT,'YYYY-MM') = to_char(D.MONTH,'YYYY-MM') then rolling_os_3/D.util6
    else rolling_os_3
end as rolling_os_3_by_util
,CASE																									
WHEN rolling_os_3_by_util/rolling_cl_3 <= .0 THEN 'A.<= 0%'																									
WHEN rolling_os_3_by_util/rolling_cl_3 < .1 THEN 'B.< 10%'																									
WHEN rolling_os_3_by_util/rolling_cl_3 < .3 THEN 'C.10%-30%'																									
WHEN rolling_os_3_by_util/rolling_cl_3 < .5 THEN 'D.30%-50%'																									
WHEN rolling_os_3_by_util/rolling_cl_3 < .8 THEN 'E.50%-80%'																									
WHEN rolling_os_3_by_util/rolling_cl_3 >= .8 THEN 'F.>80%'																									
ELSE NULL																									
END AS UTILBAND_COVID_ADJ_BY_UTIL
,UTILBAND_CSERIES_DEFS																									
,UTILBAND_CSERIES_DEFS_COVID																									
,scores__clip_model_d1_20220728_score AS Y1_D_score																									
,scores__clip_model_d2_20220728_score AS Y2_D_score																									
,CASE																									
WHEN Y1_D_score <= 0.038																									
THEN 1																									
WHEN Y1_D_score <= 0.062																									
THEN 2																									
WHEN Y1_D_score <= 0.081																									
THEN 3																									
WHEN Y1_D_score <= 0.095																									
THEN 4																									
WHEN Y1_D_score <= 0.126																									
THEN 5																									
WHEN Y1_D_score <= 0.172																									
THEN 6																									
WHEN Y1_D_score <= 0.219																									
THEN 7																									
WHEN Y1_D_score <= 0.253																									
THEN 8																									
WHEN Y1_D_score <= 0.272																									
THEN 9																									
WHEN Y1_D_score <= 0.302																									
THEN 10																									
WHEN Y1_D_score <= 0.333																									
THEN 11																									
WHEN Y1_D_score <= 0.363																									
THEN 12																									
WHEN Y1_D_score > 0.363																									
THEN 13																									
ELSE NULL																									
END AS RISKGROUP_DSERIES_Y1																									
,CASE																									
WHEN Y2_D_score <= 0.039																									
THEN 1																									
WHEN Y2_D_score <= 0.061																									
THEN 2																									
WHEN Y2_D_score <= 0.083																									
THEN 3																									
WHEN Y2_D_score <= 0.105																									
THEN 4																									
WHEN Y2_D_score <= 0.13																									
THEN 5																									
WHEN Y2_D_score <= 0.154																									
THEN 6																									
WHEN Y2_D_score <= 0.17																									
THEN 7																									
WHEN Y2_D_score <= 0.189																									
THEN 8																									
WHEN Y2_D_score <= 0.235																									
THEN 9																									
WHEN Y2_D_score <= 0.268																									
THEN 10																									
WHEN Y2_D_score <= 0.35																									
THEN 11																									
WHEN Y2_D_score <= 0.443																									
THEN 12																									
WHEN Y2_D_score > 0.443																									
THEN 13																									
ELSE NULL																									
END AS RISKGROUP_DSERIES_Y2																									
																									
,CASE																									
WHEN hardcut__BANKRUPT_DECEASED_FRAUD = 0																									
AND hardcut__CURRENTLY_OVERLIMIT = 0																									
AND hardcut__DQ_LAST_12_STATEMENTS = 0																									
--missing ATP																									
THEN 1																									
ELSE 0																									
END AS eligibility_HC_Y1																									
,CASE																									
WHEN hardcut__BANKRUPT_DECEASED_FRAUD = 0																									
AND hardcut__CURRENTLY_OVERLIMIT = 0																									
AND hardcut__DQ_LAST_6_STATEMENTS = 0																									
--missing ATP																									
THEN 1																									
ELSE 0																									
END AS eligibility_HC_Y2																									
,REWARDS_RATE	
,CASE WHEN last_cl <= 1000 THEN 'CL1. 0-1K'
WHEN last_cl <= 2000 THEN 'CL2. 1-2K'
WHEN last_cl <= 3000 THEN 'CL3. 2-3K'
WHEN last_cl > 3000 THEN 'CL4. 3K+'
//WHEN last_cl <= 4000 THEN 'CL4'
//WHEN last_cl <= 5000 THEN 'CL5'
//WHEN last_cl <= 6000 THEN 'CL6'
//WHEN last_cl <= 7000 THEN 'CL7'
//WHEN last_cl <= 8000 THEN 'CL8'
ELSE NULL END last_cl
FROM																									
DS_DB.LINE_MGMT.RETROSCORES_D_SERIES_MODEL_BUILD_v2 AS A			
LEFT JOIN																									
eligibility_flags AS E																									
ON a.external_account_id = E.external_account_id																									
AND A.internal__fis_tsys__statement_num = E.STATEMENT_NUM		
LEFT JOIN																									
covid_util_adj_granular D																									
    ON to_char(E.STATEMENT_END_DT,'YYYY-MM') = to_char(D.MONTH,'YYYY-MM')	
LEFT JOIN																									
(SELECT card_id, REWARDS_RATE FROM CARD_APPLICATIONS WHERE REWARDS_RATE >0 AND card_id IS NOT NULL) AS F																									
ON a.card_id = F.card_id																									
);																									
																									
																									
																									
																									
SELECT																									
A.STATEMENT_NUM AS STATEMENT_NUM_CLIP			
,B.STATEMENT_NUM - A.STATEMENT_NUM MONTH_SINCE_CLIP		
,TO_CHAR(B.STATEMENT_END_DT,'YYYY-MM') as STATEMENT_Y_M
//,TO_CHAR(account_open_dt,'YYYY') AS account_open_Y																									
//,TO_CHAR(account_open_dt,'YYYY-MM') AS account_open_Y_M																									
,TO_CHAR(EVALUATED_TIMESTAMP,'YYYY') AS EVALUATED_CLIP_Y																									
,TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') AS EVALUATED_CLIP_Y_M	
,case when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') >= '2022-01' then TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM')
    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2021-10' and '2021-12' then '2021Q4'
    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2021-07' and '2021-09' then '2021Q3'
    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2021-04' and '2021-06' then '2021Q2'
    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2021-01' and '2021-03' then '2021Q1'
    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2020-10' and '2020-12' then '2020Q4'
    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2020-07' and '2020-09' then '2020Q3'
    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2020-04' and '2020-06' then '2020Q2'
    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2020-01' and '2020-03' then '2020Q1'
    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2019-07' and '2019-12' then '2019H2'
    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2019-01' and '2019-06' then '2019H1'
    else TO_CHAR(EVALUATED_TIMESTAMP,'YYYY') 
 end as CLIP_COHORT
//,case when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') >= '2022-01' then TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM')
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2021-10' and '2021-12' then '2021Q4'
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2021-07' and '2021-09' then '2021Q3'
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2021-04' and '2021-06' then '2021Q2'
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2021-01' and '2021-03' then '2021Q1'
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2020-10' and '2020-12' then '2020Q4'
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2020-07' and '2020-09' then '2020Q3'
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2020-04' and '2020-06' then '2020Q2'
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2020-01' and '2020-03' then '2020Q1'
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2019-10' and '2019-12' then '2019Q4'
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2019-07' and '2019-09' then '2019Q3'
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2019-04' and '2019-06' then '2019Q2'
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2019-01' and '2019-03' then '2019Q1'
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2018-10' and '2018-12' then '2018Q4'
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2018-07' and '2018-09' then '2018Q3'
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2018-04' and '2018-06' then '2018Q2'
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2018-01' and '2018-03' then '2018Q1'
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2017-10' and '2017-12' then '2017Q4'
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2017-07' and '2017-09' then '2017Q3'
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2017-04' and '2017-06' then '2017Q2'
//    when TO_CHAR(EVALUATED_TIMESTAMP,'YYYY-MM') between '2017-01' and '2017-03' then '2017Q1'
//    else TO_CHAR(EVALUATED_TIMESTAMP,'YYYY') 
// end as CLIP_COHORT_COVID_ADJ_GROUNDING
,RISKGROUP_DSERIES_Y1																									
-- ,RISKGROUP_DSERIES_Y2																									
,UTILBAND_CSERIES_DEFS			
,UTILBAND_COVID_ADJ_BY_UTIL
//,UTILBAND_CSERIES_DEFS_COVID																									
-- ,eligibility_HC_Y1																									
-- ,eligibility_HC_Y2																									
																									
,CASE WHEN REWARDS_RATE >0 THEN 1 ELSE 0 END REWARDS																									
,CASE																									
WHEN POST_CLIP_LINE_LIMIT - PRE_CLIP_LINE_LIMIT = 0 THEN 0																									
ELSE 1																									
END AS CLIPed	
,last_cl
//Util metrics
,sum(AVG_OUTSTANDING_BALANCE_STMT_USD) AS OS		
,sum(AVG_OUTSTANDING_PRINCIPAL_BALANCE_STMT_USD) AS OS_PRINCIPAL	
,SUM(CREDIT_LIMIT_STMT_USD) AS CL	
,SUM(CASE WHEN D.MONTH IS NOT NULL AND UTILBAND_COVID_ADJ_BY_UTIL ilike '%B.%' THEN AVG_OUTSTANDING_BALANCE_STMT_USD/d.util2 
          WHEN D.MONTH IS NOT NULL AND UTILBAND_COVID_ADJ_BY_UTIL ilike '%C.%' THEN AVG_OUTSTANDING_BALANCE_STMT_USD/d.util3
          WHEN D.MONTH IS NOT NULL AND UTILBAND_COVID_ADJ_BY_UTIL ilike '%D.%' THEN AVG_OUTSTANDING_BALANCE_STMT_USD/d.util4 
          WHEN D.MONTH IS NOT NULL AND UTILBAND_COVID_ADJ_BY_UTIL ilike '%E.%' THEN AVG_OUTSTANDING_BALANCE_STMT_USD/d.util5 
          WHEN D.MONTH IS NOT NULL AND UTILBAND_COVID_ADJ_BY_UTIL ilike '%F.%' THEN AVG_OUTSTANDING_BALANCE_STMT_USD/d.util6 
     ELSE AVG_OUTSTANDING_BALANCE_STMT_USD END) OS_COVID_ADJ	
,case when CL = 0 then 0 else OS/CL end as OS_UTIL
,case when CL = 0 then 0 else OS_COVID_ADJ/CL end as OS_UTIL_COVID_ADJ

-- ,sum(AVG_OUTSTANDING_BALANCE_STMT_USD) AS AVG_OUTSTANDING_BALANCE_STMT_USD_SUM																									
-- ,SUM(CREDIT_LIMIT_STMT_USD) AS CREDIT_LIMIT_STMT_USD_USD																									
-- ,SUM(DELINQUENCY_D030_STMT_CNT) AS DQ30_CNT_SUM																									
,SUM(account_charge_off_in_stmt_cnt) co_in_stmt																									
--,SUM(CASE WHEN D.MONTH IS NOT NULL THEN account_charge_off_in_stmt_cnt/pbad ELSE account_charge_off_in_stmt_cnt END) co_in_stmt_COVID																									
,SUM(b.ACCOUNT_OPEN_CNT) AS ACCOUNT_OPEN_CNT_SUM																									
FROM																									
analysis_table AS A																									
LEFT JOIN																									
ACCOUNT_STATEMENTS AS B																									
ON A.ACCOUNT_ID = B.ACCOUNT_ID																									
AND A.STATEMENT_NUM <= B.STATEMENT_NUM																									
LEFT JOIN																									
(SELECT * FROM CLIP_RESULTS_DATA WHERE PRE_EVALUATION IS NULL OR PRE_EVALUATION = FALSE) AS C																									
ON A.account_id = C.account_id																									
AND A.STATEMENT_NUM = C.STATEMENT_NUMBER																									
LEFT JOIN																									
covid_util_adj_granular D																									
ON to_char(B.STATEMENT_END_DT,'YYYY-MM') = to_char(D.MONTH,'YYYY-MM')																									
																									
--------------------------- Y1 -----------------------------																									
WHERE																									
A.STATEMENT_NUM IN (7)																									
and eligibility_HC_Y1 = 1																									
and TO_CHAR(account_open_dt,'YYYY') > 2016																									
AND RISKGROUP_DSERIES_Y1 IS NOT NULL																									
GROUP BY																									
1,2,3,4,5,6,7,8,9,10,11,12																							
--------------------------- Y2+ -----------------------------																									
-- WHERE																									
-- A.STATEMENT_NUM IN (18,26)																									
-- and eligibility_HC_Y2 = 1																									
-- and TO_CHAR(account_open_dt,'YYYY') > 2016																									
-- AND RISKGROUP_DSERIES_Y2 IS NOT NULL																									
-- GROUP BY																									
-- 1,2,3,4,5,6,7,8,9,10,11																									
;			
