////tCLIP Stmt 7/8 Driver
select
  card_id
  ,EVALUATED_TIMESTAMP
  ,POST_CLIP_LINE_LIMIT
  ,PRE_CLIP_LINE_LIMIT
  ,POST_CLIP_LINE_LIMIT - PRE_CLIP_LINE_LIMIT as CLIP_AMOUNT
  ,decision_data
  ,decision_data:"potential_atp_net_scores" as potential_atp_net_scores
  ,decision_data:"potential_credit_lines" as potential_credit_lines
  ,STATEMENT_NUMBER
  ,decision_data:"never_delinquent__passed"
  ,decision_data:"block_code__passed"  
  ,decision_data:"atp_net_score"
  ,decision_data:"not_over_limit__passed"
  ,CASE WHEN  
  STATEMENT_NUMBER in (7,8)  --Less than statement 18
  --Submitted Income / Residence Update more than 12 months ago
 
  AND decision_data:"never_delinquent__passed" = 'true'
  AND decision_data:"block_code__passed" = 'true' --Bankrupt/Deceased/Fraud
 
  AND
  (CASE
  WHEN decision_data:"atp_net_score"::INT > 0 THEN TRUE
  WHEN decision_data:"atp_net_score" is null THEN TRUE
  ELSE FALSE
  END)
 
  --ATP w/ $1,000 dollar CLIP imputed < 0
  AND decision_data:"not_over_limit__passed" = 'true' --Currently Overlimit
  THEN 1
  ELSE 0
  END
  as pass_eligibility
  ,decision_data:"transunion__account_review__fico_08__FICO_08"
  ,CASE 
  WHEN left(decision_data:"transunion__account_review__fico_08__FICO_08",1) = '+' 
  then 0 
  else decision_data:"transunion__account_review__fico_08__FICO_08"
  end AS FICO_CLEAN
  ,decision_data:"transunion__account_review__vantage_30__VANTAGE_30"::FLOAT
  ,decision_data:"total_revolving_debt_re33s_to_income"::FLOAT
  ,decision_data:"transunion__account_review__cv_enriched_attributes__RE33S"::FLOAT
  ,decision_data:"non_mortgage_debt_at33b_hi33s_hr33s_to_income"::FLOAT
  ,decision_data:"transunion__account_review__cv_enriched_attributes__BC01S"::FLOAT
  ,decision_data:"transunion__account_review__cv_enriched_attributes__AT01S"::FLOAT
  ,decision_data:"added_revolving_debt_re33s"::FLOAT
  ,decision_data:"payment_vacation__passed"::VARCHAR
  ,case when FICO_CLEAN::INT > 525 then 1 else 0 end  cond1
  ,case when decision_data:"transunion__account_review__vantage_30__VANTAGE_30"::FLOAT > 525 then 1 else 0 end cond2
  , case when decision_data:"total_revolving_debt_re33s_to_income"::FLOAT < .5  then 1 else 0 end cond3
  , case when decision_data:"transunion__account_review__cv_enriched_attributes__RE33S"::FLOAT < 25000  then 1 else 0 end cond4
  , case when decision_data:"non_mortgage_debt_at33b_hi33s_hr33s_to_income"::FLOAT < 1  then 1 else 0 end cond5
  , case when decision_data:"transunion__account_review__cv_enriched_attributes__BC01S"::FLOAT < 40  then 1 else 0 end cond6
  , case when decision_data:"transunion__account_review__cv_enriched_attributes__AT01S"::FLOAT < 80  then 1 else 0 end cond7
  , case when EVALUATED_TIMESTAMP >= '2021-11-04' then 1 
        when decision_data:"added_revolving_debt_re33s"::FLOAT <= 7500  then 1 else 0 end cond8
  , case when decision_data:"payment_vacation__passed"::VARCHAR ilike '%true%' then 1 else 0 end cond9
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
  ,decision_data:"average_purchase_utilization_3_months"::FLOAT AS average_purchase_utilization_3_months
  ,decision_data:"ab_testing_random_number"::FLOAT AS ab_testing_random_number_FLOAT
  ,TEST_SEGMENT
   , CASE WHEN pass_eligibility = 0 THEN 0
  WHEN pass_eligibility= 1 and account_review_hardcuts = 0 THEN 100
--transactor CLIP
WHEN  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months <0.1 THEN 100
WHEN  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT < 0.05 THEN 100
WHEN   clip_risk_group_INT = 1 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 500
WHEN   clip_risk_group_INT = 2 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 500
WHEN   clip_risk_group_INT = 3 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 500
WHEN   clip_risk_group_INT = 4 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 300
WHEN   clip_risk_group_INT = 5 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 300
WHEN   clip_risk_group_INT = 6 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 300
WHEN   clip_risk_group_INT = 7 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 100
WHEN   clip_risk_group_INT = 8 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 100
WHEN   clip_risk_group_INT = 9 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 100
WHEN   clip_risk_group_INT = 10 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 100
-- other CLIP
WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 6 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 7 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 8 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 9 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 10 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 500  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 300  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 500  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 300  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 300  
 WHEN clip_risk_group_INT = 6 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 7 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 8 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 9 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 10 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 500  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 300  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 300  
 WHEN clip_risk_group_INT = 6 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 7 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 8 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 9 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 10 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 500  
 WHEN clip_risk_group_INT = 6 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 6 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 300  
 WHEN clip_risk_group_INT = 6 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 300  
 WHEN clip_risk_group_INT = 7 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 8 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 9 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 10 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 500  
 WHEN clip_risk_group_INT = 6 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 6 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 6 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 500  
 WHEN clip_risk_group_INT = 7 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 7 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 300  
 WHEN clip_risk_group_INT = 7 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 300  
 WHEN clip_risk_group_INT = 8 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 9 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 10 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 ELSE 999 END AS CLIP_AMOUNT_FIRST
,CASE
      WHEN pass_eligibility = 0 THEN 0
      WHEN pass_eligibility= 1 and account_review_hardcuts = 0 THEN 0
      WHEN  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months <0.1 THEN 1
      WHEN  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT < 0.05 THEN 1
      WHEN   clip_risk_group_INT = 1 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 2 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 3 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 4 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 5 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 6 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 7 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 8 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 9 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 10 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
ELSE 0
END as Transactor_CLIP_FLAG
,case when CLIP_AMOUNT_FIRST -(POST_CLIP_LINE_LIMIT - PRE_CLIP_LINE_LIMIT) <> 0 then 1
            else 0
         end as tCLIP_error
,CLIP_AMOUNT_FIRST -(POST_CLIP_LINE_LIMIT - PRE_CLIP_LINE_LIMIT) as ERROR_CLIP_Amount
FROM
  (SELECT 
      *
    FROM
      EDW_DB.PUBLIC.CLIP_RESULTS_DATA
   TS_DATA
    WHERE 
      DATE(EVALUATED_TIMESTAMP) >= '2021-12-14')
WHERE STATEMENT_NUMBER in (7,8)
  AND decision_data:"average_utilization_3_months"::FLOAT < .1
  AND decision_data:"average_purchase_utilization_3_months"::FLOAT > .1
  AND DATE(EVALUATED_TIMESTAMP) = '2021-12-25'
;




































/////tCLIP stmt 11 Drv
select
  card_id
  ,EVALUATED_TIMESTAMP
  ,POST_CLIP_LINE_LIMIT
  ,PRE_CLIP_LINE_LIMIT
  ,POST_CLIP_LINE_LIMIT - PRE_CLIP_LINE_LIMIT as CLIP_AMOUNT
  ,decision_data
  ,decision_data:"potential_atp_net_scores" as potential_atp_net_scores
  ,decision_data:"potential_credit_lines" as potential_credit_lines
  ,STATEMENT_NUMBER
  ,decision_data:"never_delinquent__passed"
  ,decision_data:"block_code__passed"  
  ,decision_data:"atp_net_score"
  ,decision_data:"not_over_limit__passed"
  ,CASE WHEN  
  STATEMENT_NUMBER in (11)  --Less than statement 18
  --Submitted Income / Residence Update more than 12 months ago
 
  AND decision_data:"never_delinquent__passed" = 'true'
  AND decision_data:"block_code__passed" = 'true' --Bankrupt/Deceased/Fraud
 
  AND
  (CASE
  WHEN decision_data:"atp_net_score"::INT > 0 THEN TRUE
  WHEN decision_data:"atp_net_score" is null THEN TRUE
  ELSE FALSE
  END)
 
  --ATP w/ $1,000 dollar CLIP imputed < 0
  AND decision_data:"not_over_limit__passed" = 'true' --Currently Overlimit
  THEN 1
  ELSE 0
  END
  as pass_eligibility
  ,decision_data:"transunion__account_review__fico_08__FICO_08"
  ,CASE 
  WHEN left(decision_data:"transunion__account_review__fico_08__FICO_08",1) = '+' 
  then 0 
  else decision_data:"transunion__account_review__fico_08__FICO_08"
  end AS FICO_CLEAN
  ,decision_data:"transunion__account_review__vantage_30__VANTAGE_30"::FLOAT
  ,decision_data:"total_revolving_debt_re33s_to_income"::FLOAT
  ,decision_data:"transunion__account_review__cv_enriched_attributes__RE33S"::FLOAT
  ,decision_data:"non_mortgage_debt_at33b_hi33s_hr33s_to_income"::FLOAT
  ,decision_data:"transunion__account_review__cv_enriched_attributes__BC01S"::FLOAT
  ,decision_data:"transunion__account_review__cv_enriched_attributes__AT01S"::FLOAT
  ,decision_data:"added_revolving_debt_re33s"::FLOAT
  ,decision_data:"payment_vacation__passed"::VARCHAR
  ,case when FICO_CLEAN::INT > 525 then 1 else 0 end  cond1
  ,case when decision_data:"transunion__account_review__vantage_30__VANTAGE_30"::FLOAT > 525 then 1 else 0 end cond2
  , case when decision_data:"total_revolving_debt_re33s_to_income"::FLOAT < .5  then 1 else 0 end cond3
  , case when decision_data:"transunion__account_review__cv_enriched_attributes__RE33S"::FLOAT < 25000  then 1 else 0 end cond4
  , case when decision_data:"non_mortgage_debt_at33b_hi33s_hr33s_to_income"::FLOAT < 1  then 1 else 0 end cond5
  , case when decision_data:"transunion__account_review__cv_enriched_attributes__BC01S"::FLOAT < 40  then 1 else 0 end cond6
  , case when decision_data:"transunion__account_review__cv_enriched_attributes__AT01S"::FLOAT < 80  then 1 else 0 end cond7
  , case when EVALUATED_TIMESTAMP >= '2021-11-04' then 1 
        when decision_data:"added_revolving_debt_re33s"::FLOAT <= 7500  then 1 else 0 end cond8
  , case when decision_data:"payment_vacation__passed"::VARCHAR ilike '%true%' then 1 else 0 end cond9
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
  ,decision_data:"average_purchase_utilization_3_months"::FLOAT AS average_purchase_utilization_3_months
  ,decision_data:"ab_testing_random_number"::FLOAT AS ab_testing_random_number_FLOAT
  ,TEST_SEGMENT
  , CASE WHEN pass_eligibility = 0 THEN 0
  WHEN pass_eligibility= 1 and account_review_hardcuts = 0 THEN 100
--transactor CLIP
WHEN  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months < 0.1 AND ab_testing_random_number_FLOAT  THEN 0
WHEN  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT < 0.05 THEN 0
WHEN   clip_risk_group_INT = 1 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 500
WHEN   clip_risk_group_INT = 2 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 500
WHEN   clip_risk_group_INT = 3 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 500
WHEN   clip_risk_group_INT = 4 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 500
WHEN   clip_risk_group_INT = 5 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 500
WHEN   clip_risk_group_INT = 6 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 500
WHEN   clip_risk_group_INT = 7 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 0
WHEN   clip_risk_group_INT = 8 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 0
WHEN   clip_risk_group_INT = 9 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 0
WHEN   clip_risk_group_INT = 10 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 0
-- other CLIP
WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 6 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 7 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 8 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 9 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 10 AND average_utilization_3_months_FLOAT >  0.0 AND average_utilization_3_months_FLOAT <=  0.1 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 500  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 300  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 500  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 300  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 300  
 WHEN clip_risk_group_INT = 6 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 7 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 8 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 9 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 10 AND average_utilization_3_months_FLOAT >  0.1 AND average_utilization_3_months_FLOAT <=  0.3 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 500  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 300  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 300  
 WHEN clip_risk_group_INT = 6 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 7 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 8 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 9 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 10 AND average_utilization_3_months_FLOAT >  0.3 AND average_utilization_3_months_FLOAT <=  0.5 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 500  
 WHEN clip_risk_group_INT = 6 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 6 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 300  
 WHEN clip_risk_group_INT = 6 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 300  
 WHEN clip_risk_group_INT = 7 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 8 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 9 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 10 AND average_utilization_3_months_FLOAT >  0.5 AND average_utilization_3_months_FLOAT <=  0.8 AND ab_testing_random_number_FLOAT >= -0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 1 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 2 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 3 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 4 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 1000  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 5 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 500  
 WHEN clip_risk_group_INT = 6 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 6 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 500  
 WHEN clip_risk_group_INT = 6 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 500  
 WHEN clip_risk_group_INT = 7 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 0.05 THEN 100  
 WHEN clip_risk_group_INT = 7 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.05 AND ab_testing_random_number_FLOAT < 0.8 THEN 300  
 WHEN clip_risk_group_INT = 7 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.8 AND ab_testing_random_number_FLOAT < 1.0 THEN 300  
 WHEN clip_risk_group_INT = 8 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 9 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 WHEN clip_risk_group_INT = 10 AND average_utilization_3_months_FLOAT >  0.8 AND ab_testing_random_number_FLOAT >= 0.0 AND ab_testing_random_number_FLOAT < 1.0 THEN 100  
 ELSE 999 END AS CLIP_AMOUNT_FIRST
,CASE
      WHEN pass_eligibility = 0 THEN 0
      WHEN pass_eligibility= 1 and account_review_hardcuts = 0 THEN 0
      WHEN  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months <0.1 THEN 1
      WHEN  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT < 0.05 THEN 1
      WHEN   clip_risk_group_INT = 1 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 2 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 3 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 4 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 5 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 6 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 7 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 8 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 9 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 10 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
ELSE 0
END as Transactor_CLIP_FLAG
,CASE
      WHEN pass_eligibility = 0 THEN 0
      WHEN pass_eligibility= 1 and account_review_hardcuts = 0 THEN 0
      WHEN  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months <0.1 THEN 1
      WHEN  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT < 0.05 THEN 1
      WHEN   clip_risk_group_INT = 1 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 2 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 3 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 4 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 5 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 6 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 7 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 8 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 9 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
      WHEN   clip_risk_group_INT = 10 AND  average_utilization_3_months_FLOAT <0.1 AND  average_purchase_utilization_3_months >=0.1 AND  ab_testing_random_number_FLOAT >= 0.05 THEN 1
ELSE 0
END as Transactor_CLIP_EVAL_FLAG
,case when CLIP_AMOUNT_FIRST -(POST_CLIP_LINE_LIMIT - PRE_CLIP_LINE_LIMIT) <> 0 then 1
            else 0
         end as tCLIP_error
,CLIP_AMOUNT_FIRST -(POST_CLIP_LINE_LIMIT - PRE_CLIP_LINE_LIMIT) as ERROR_CLIP_Amount_Difference
FROM
  (SELECT 
      *
    FROM
      EDW_DB.PUBLIC.CLIP_RESULTS_DATA
   TS_DATA
    WHERE 
      DATE(EVALUATED_TIMESTAMP) >= '2021-12-14')
WHERE STATEMENT_NUMBER in (11)
  AND decision_data:"average_utilization_3_months"::FLOAT < .1
  AND decision_data:"average_purchase_utilization_3_months"::FLOAT > .1
;






