use database SANDBOX_DB;
use schema user_tb;

select * from edw_db.public.clip_results_data where statement_number = 3 limit 100
select * from edw_db.public.account_statements limit 100

create or replace temporary table s3_volume_drv as
select 
    a.account_id
    ,a.statement_num
    ,b.statement_number as clip3_statement
    ,c.statement_number as clip7_statement
    //,CASE WHEN a.BALANCE_CURRENT > 0 OR a.CASH_ADVANCE_BALANCE_STMT_USD > 0 OR a.PURCHASE_BALANCE_STMT_USD > 0 THEN TRUE ELSE FALSE END AS ACTIVE_AT_CURRENT_STATEMENT
    ,date(b.evaluated_timestamp) as clip3_eval_date
    ,date(c.evaluated_timestamp) as clip7_eval_date
    ,date(statement_end_dt) as statement_3_end_date
    ,b.decision_data as decision_data_s3
    ,case when b.outcome is null then 'INACTIVE CUT' else b.outcome end as outcome_s3
    ,case when b.decision_data:"active_at_current_statement" ilike '%true%' then 1 else 0 end as active_at_current_statement_s3
    ,b.decision_data:"cicada_risk_group"::FLOAT as cicada_RG_s3
    ,b.decision_data:"clip_model_d1_20220728_risk_group"::FLOAT as CLIP_D_RG_s3
    ,b.decision_data:"clip_model_c_20210811_risk_group"::FLOAT as CLIP_C_RG_s3
    ,b.decision_data:"average_utilization_3_months"::FLOAT AS average_utilization_3_months_FLOAT_s3
    ,b.decision_data:"policy_assignment_random_number"::FLOAT AS policy_assignment_random_number_FLOAT_s3
    ,case when average_utilization_3_months_FLOAT_s3 <= 0 then '<=0%'
        when average_utilization_3_months_FLOAT_s3 <0.1  then '0-10%'
        when average_utilization_3_months_FLOAT_s3 <=0.3  then '10-30%'
        when average_utilization_3_months_FLOAT_s3 <=0.5  then '30-50%'
        when average_utilization_3_months_FLOAT_s3 <=0.8  then '50-80%'
        when average_utilization_3_months_FLOAT_s3 >0.8  then '>80%'
        end as util_band_s3
    ,case when ((cicada_RG_s3 <= 2 and CLIP_C_RG_s3 <= 4) or (cicada_RG_s3 between 3 and 4 and CLIP_C_RG_s3 <= 2)) then 'A'
        when ((cicada_RG_s3 between 3 and 4 and CLIP_C_RG_s3 between 3 and 4) or (cicada_RG_s3 between 1 and 2 and CLIP_C_RG_s3 between 5 and 6)) then 'B'
        else null
     end as s3_group
    ,b.test_segment as test_segment_s3
    ,b.POST_CLIP_LINE_LIMIT as POST_CLIP_LINE_LIMIT_s3
    ,b.PRE_CLIP_LINE_LIMIT as PRE_CLIP_LINE_LIMIT_s3
    ,b.POST_CLIP_LINE_LIMIT - b.PRE_CLIP_LINE_LIMIT as CLIP_AMT_s3
    ,case when outcome_s3 ilike '%approved%' and test_segment_s3 ilike '%rollout%' then 'Test - Lower Lines'
        when outcome_s3 ilike '%approved%' and test_segment_s3 ilike '%test1%' then 'Test - Higher Lines'
        when outcome_s3 ilike '%declined%' and test_segment_s3 ilike '%hold%out%' then 'Holdout'
    end as s3_segment
    ,c.decision_data as decision_data_s7
    ,c.decision_data:"clip_model_c_20210811_risk_group"::FLOAT as CLIP_C_RG_s7
    ,c.decision_data:"clip_model_d1_20220728_risk_group"::FLOAT as CLIP_D_RG_s7
    ,c.decision_data:"average_utilization_3_months"::FLOAT AS average_utilization_3_months_FLOAT_s7
    ,c.decision_data:"statement_3_outcome" AS statement_3_outcome_TEXT
    ,c.decision_data:"statement_3_test_group" AS statement_3_test_group_TEXT 
    ,c.decision_data:"policy_assignment_random_number"::FLOAT AS policy_assignment_random_number_FLOAT_s7
    ,c.outcome as outcome_s7
    ,c.test_segment as test_segment_s7
    ,case WHEN statement_3_outcome_TEXT ilike '%approved%' and statement_3_test_group_TEXT ilike '%rollout%' and policy_assignment_random_number_FLOAT_s7 < 0.33 THEN 's3 test lower lines - s7 holdout'
  	   WHEN statement_3_outcome_TEXT ilike '%approved%' and statement_3_test_group_TEXT ilike '%rollout%' and policy_assignment_random_number_FLOAT_s7 >= 0.33 THEN 's3 test lower lines - s7 BAU CLIP'
       WHEN statement_3_outcome_TEXT ilike '%approved%' and statement_3_test_group_TEXT ilike '%test1%' and policy_assignment_random_number_FLOAT_s7 < 0.5 THEN 's3 test higher lines - s7 holdout'
       WHEN statement_3_outcome_TEXT ilike '%approved%' and statement_3_test_group_TEXT ilike '%test1%' and policy_assignment_random_number_FLOAT_s7 >= 0.5 THEN 's3 test higher lines - s7 BAU CLIP'
     end as s7_segment
    ,c.POST_CLIP_LINE_LIMIT - c.PRE_CLIP_LINE_LIMIT as CLIP_AMT_s7
    ,case when s3_segment ilike '%holdout%' and s3_group ilike '%A%' then 'S3 Holdout - Group A'
        when s3_segment ilike '%holdout%' and s3_group ilike '%B%' then 'S3 Holdout - Group B'
        when s3_segment ilike '%test%higher%' and s3_group ilike '%A%'  then 'S3 Test Higher Lines - Group A'
        when s3_segment ilike '%test%higher%' and s3_group ilike '%B%' then 'S3 Test Higher Lines - Group B'
        when s3_segment ilike '%test%lower%' and s3_group ilike '%A%' then 'S3 Test Lower Lines - Group A'
        when s3_segment ilike '%test%lower%' and s3_group ilike '%B%' then 'S3 Test Lower Lines - Group B'
    end as test_cell_s3
    ,case when s3_segment ilike '%holdout%' and s3_group ilike '%A%' then 'S3 Holdout - Group A'
        when s3_segment ilike '%holdout%' and s3_group ilike '%B%' then 'S3 Holdout - Group B'
        when s3_segment ilike '%test%higher%' and s3_group ilike '%A%' and s7_segment ilike '%holdout%' then 'S3 Test Higher Lines / S7 Holdout - Group A'
        when s3_segment ilike '%test%higher%' and s3_group ilike '%A%' and s7_segment ilike '%BAU%' then 'S3 Test Higher Lines / S7 BAU CLIP - Group A'
        when s3_segment ilike '%test%higher%' and s3_group ilike '%B%' and s7_segment ilike '%holdout%' then 'S3 Test Higher Lines / S7 Holdout - Group B'
        when s3_segment ilike '%test%higher%' and s3_group ilike '%B%' and s7_segment ilike '%BAU%' then 'S3 Test Higher Lines / S7 BAU CLIP - Group B'
        when s3_segment ilike '%test%lower%' and s3_group ilike '%A%' and s7_segment ilike '%holdout%' then 'S3 Test Lower Lines / S7 Holdout - Group A'
        when s3_segment ilike '%test%lower%' and s3_group ilike '%A%' and s7_segment ilike '%BAU%'then 'S3 Test Lower Lines / S7 BAU CLIP - Group A'
        when s3_segment ilike '%test%lower%' and s3_group ilike '%B%' and s7_segment ilike '%holdout%' then 'S3 Test Lower Lines / S7 Holdout - Group B'
        when s3_segment ilike '%test%lower%' and s3_group ilike '%B%' and s7_segment ilike '%BAU%' then 'S3 Test Lower Lines / S7 BAU CLIP - Group B'
    end as test_cell_s3s7
from (select * from edw_db.public.account_statements where statement_num = 3 and statement_end_dt >= '2022-06-15') a
    left join (select * from edw_db.public.clip_results_data where statement_number in (3) and evaluated_timestamp >= '2022-06-15') b
        on a.account_id = b.account_id
        and a.statement_num = b.statement_number
    left join (select * from edw_db.public.clip_results_data where statement_number in (7) and evaluated_timestamp >= '2022-10-15') c
        on b.account_id = c.account_id
;

create or replace temporary table s3_volume_drv2 as
select
    *
from s3_volume_drv
where clip3_statement = 3
;

//select * from s3_volume_drv

//select
//    substr(statement_3_end_date,0,7) as month
//    //,clip_amt
////    ,outcome
////    ,active_at_current_statement
////    ,test_segment
//    ,s3_segment
//    //,s3_group
//    ,util_band
//    ,count(distinct account_id)
//from s3_volume_drv
////where outcome ilike '%approve%' or test_segment ilike '%hold%out%'
//where month = '2022-06'
//group by 1,2,3
//;
//

create or replace temporary table statement_7_11_clip_drv as
select
    a.account_id
    ,statement_number
    ,substr(evaluated_timestamp,0,7) as clip_month
    ,decision_data:"clip_model_c_20210811_risk_group"::FLOAT as CLIP_C_RG
    ,decision_data:"average_utilization_3_months"::FLOAT AS average_utilization_3_months_FLOAT
    ,outcome
    ,test_segment
    ,POST_CLIP_LINE_LIMIT - PRE_CLIP_LINE_LIMIT as CLIP_AMT
from edw_db.public.clip_results_data a
where statement_number in (7,11)
    and evaluated_timestamp >= '2022-06-01'
;

/////Performance monitoring
///A) Statement 3 only performance monitoring ( can start now)
///1. Risk (DQ30-60 / DQ60+), Util, Marginal Util, PVol, Revolve rate, Payment surplus, NIAT differences between higher line and lower line tests and holdout cells (Cells 1-5)
///2. Compare performance against known quantities (i.e. statement 7 CLIPs by RG, statement 11 CLIPs by RG)
///3. Util of the lowly engaged customers (util < 10%, util < 30%)
///4. Series C model distributions
///5. Bureau comparisons
///6. Util actuals by util band at s3, split by test cell
///
///B) Statement 3+7 performance monitoring (will start in November+)
///1. Approval Rate and CLIP amount distribution for statement 7 CLIP
///2. Risk group shifts 
///3. Risk (DQ30), Util, PVol, Revolve rate differences between the 5 different test cells
///4. Volume of inactives at statement 7 (who were active at Statement 3)
///5. Regrettable population deepdive -- S7 "regrettable rate" by Cicada RG, CLIP RG, Util, and PCL @ S3

///Monitoring A1
create or replace temporary table s3_perf_mtrg_drv1 as
select
    a.test_cell_s3s7
//    ,a.s3_segment
//    ,a.s3_group
    ,substr(a.statement_3_end_date,0,7) as s3_month
    //,a.clip_amt
    //,b.statement_num
    ,b.statement_num - a.statement_num as statement_post_s3_clip
    ,sum(a.CLIP_AMT_s3) as s3_clips_sum
    ,avg(b.delinquency_d030_stmt_cnt) as DQ30_Cnt
    ,case when sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) <> 0 then sum(b.delinquency_d030_stmt_usd) / sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD)
         else 0
         end as DQ30_USD
    ,avg(b.delinquency_d030_stmt_cnt)+avg(b.delinquency_d060_stmt_cnt)+avg(b.delinquency_d090_stmt_cnt)+avg(b.delinquency_d120_stmt_cnt)+avg(b.delinquency_d150_stmt_cnt) as DQ30_plus_Cnt
    ,case when sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) <> 0 then sum((b.delinquency_d030_stmt_usd)+(b.delinquency_d060_stmt_usd)+(b.delinquency_d090_stmt_usd)+(b.delinquency_d120_stmt_usd)+(b.delinquency_d150_stmt_usd)) / sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD)
         else 0
         end as DQ30_plus_USD
    ,sum(b.CREDIT_LIMIT_STMT_USD) as cl
    ,sum(b.purchase_balance_stmt_usd) / sum(b.CREDIT_LIMIT_STMT_USD) as avg_purch_utilization
    ,sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) / sum(b.CREDIT_LIMIT_STMT_USD) as avg_os_utilization
    ,sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) as os
    ,sum(b.purchase_balance_stmt_usd) as pvol
    ,sum(b.payment_surplus_stmt_usd) as payment_surplus
    ,count(distinct a.account_id) as accts
    ,pvol/accts as pvol_acct
    ,payment_surplus/accts as payment_surplus_acct
from s3_volume_drv2 a
    left join edw_db.public.account_statements b
        on a.account_id = b.account_id
where a.s3_segment is not null and a.s3_group is not null and a.test_cell_s3s7 is not null and statement_post_s3_clip >= 0
group by 1,2,3
;


select * from S3_PERF_MTRG_DRV1;


///Monitor A6
create or replace temporary table s3_perf_mtrg_drv2 as
select
    a.test_cell_s3s7
    ,util_band_s3
    ,substr(a.statement_3_end_date,0,7) as s3_month
    ,b.statement_num - a.statement_num as statement_post_s3_clip
    ,sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) / sum(b.CREDIT_LIMIT_STMT_USD) as avg_os_utilization
from s3_volume_drv2 a
    left join edw_db.public.account_statements b
        on a.account_id = b.account_id
where a.s3_segment is not null and a.s3_group is not null and a.test_cell_s3s7 is not null and statement_post_s3_clip >= 0
group by 1,2,3,4
;

select * from s3_perf_mtrg_drv2

//Monitoring A1 --> MU specifically: statement 4 post CLIP3, what are the MU and U of different test cells?
//create or replace temporary table holdout_util_s0 as
//select
//    a.s3_segment
//    ,a.s3_group
//    ,a.month
//    ,b.s3_clips_sum
//    ,b.cl - a.cl as incr_cl
//    ,b.os - a.os as incr_os
//from (select * from s3_perf_mtrg_drv1 where test_cell ilike '%holdout%' and statement_post_s3_clip = 0) a
//    left join (select * from s3_perf_mtrg_drv1 where test_cell ilike '%holdout%' and statement_post_s3_clip = 3) b
//        where a.test_cell = b.test_cell
//;
//
//create or replace temporary table rollout_util_s0 as
//select
//    s3_segment
//    ,s3_group
//    ,month
//    ,accts
//    ,s3_clips_sum
//    ,cl
//    ,os
//from s3_perf_mtrg_drv1 
//where test_cell ilike '%test%'
//    and statement_post_s3_clip = 0
//;
//
//create or replace temporary table holdout_util_s4 as
//select
//    s3_segment
//    ,s3_group
//    ,month
//    ,accts
//    ,s3_clips_sum
//    ,cl
//    ,os
//from s3_perf_mtrg_drv1 
//where test_cell ilike '%holdout%'
//    and statement_post_s3_clip = 4
//;
//
//create or replace temporary table rollout_util_s4 as
//select
//    s3_segment
//    ,s3_group
//    ,month
//    ,accts
//    ,s3_clips_sum
//    ,cl
//    ,os
//from s3_perf_mtrg_drv1 
//where test_cell ilike '%test%'
//    and statement_post_s3_clip = 4
//;
//    
//select
//    b.month
//    ,b.test_cell
//    ,a.test_cell
//    ,(a.os - b.os) - (c.os - d.os) as marg_os
//    ,b.s3_clips_sum - d.s3_clips_sum as marg_cl
//    ,(a.cl - b.cl) - (c.cl - d.cl) as marg_cl2
//from rollout_util_s0 a
//    left join rollout_util_s4 b
//        on a.month = b.month
//    left join holdout_util_s0 c
//        on a.month = c.month
//    left join holdout_util_s4 d
//        on a.month = d.month
//;


////Monitoring A2
create or replace temporary table s7_11_perf_monitoring_drv1 as
select
    a.statement_number as clip_stmt
    ,clip_month
    ,CLIP_C_RG
    ,b.statement_num
    ,b.statement_num - a.statement_number as statement_post_clip
    ,avg(b.delinquency_d030_stmt_cnt) as DQ30_Cnt
    ,case when sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) <> 0 then sum(b.delinquency_d030_stmt_usd) / sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD)
         else 0
         end as DQ30_USD
    ,avg(b.delinquency_d030_stmt_cnt)+avg(b.delinquency_d060_stmt_cnt)+avg(b.delinquency_d090_stmt_cnt)+avg(b.delinquency_d120_stmt_cnt)+avg(b.delinquency_d150_stmt_cnt) as DQ30_plus_Cnt
    ,case when sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) <> 0 then sum((b.delinquency_d030_stmt_usd)+(b.delinquency_d060_stmt_usd)+(b.delinquency_d090_stmt_usd)+(b.delinquency_d120_stmt_usd)+(b.delinquency_d150_stmt_usd)) / sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD)
         else 0
         end as DQ30_plus_USD
    ,sum(b.CREDIT_LIMIT_STMT_USD)
    ,sum(b.purchase_balance_stmt_usd) / sum(b.CREDIT_LIMIT_STMT_USD) as avg_purch_utilization
    ,sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) / sum(b.CREDIT_LIMIT_STMT_USD) as avg_os_utilization
    ,sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) as os
    ,sum(b.purchase_balance_stmt_usd) as pvol
    ,sum(b.payment_surplus_stmt_usd) as payment_surplus
    ,count(distinct a.account_id) as accts
    ,pvol/accts as pvol_acct
    ,payment_surplus/accts as payment_surplus_acct
from statement_7_11_clip_drv a
    left join edw_db.public.account_statements b
        on a.account_id = b.account_id
where outcome ilike '%approved%'
    and clip_amt > 100
    and statement_number <= statement_num
group by 1,2,3,4,5
;


////monitoring A3 -- segment by latest statement util
create or replace temporary table s6_util as
select
    a.account_id
    ,a.util_band_s3
    ,a.s3_segment
    //,a.clip_amt
    //,a.s3_group
    //,b.statement_num
    //,b.statement_num - a.statement_num as statement_post_s3_clip
    //,b.CREDIT_LIMIT_STMT_USD
    ,sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) / sum(b.CREDIT_LIMIT_STMT_USD) as avg_os_utilization_6
    ,case when avg_os_utilization_6 <= 0 then '<=0%'
        when avg_os_utilization_6 <0.1  then '0-10%'
        when avg_os_utilization_6 <=0.3  then '10-30%'
        when avg_os_utilization_6 <=0.5  then '30-50%'
        when avg_os_utilization_6 <=0.8  then '50-80%'
        when avg_os_utilization_6 >0.8  then '>80%'
        end as util_band_s6
from s3_volume_drv a
    left join (select * from edw_db.public.account_statements where statement_num in (4,5,6)) b
        on a.account_id = b.account_id
group by 1,2,3
;



select
    s3_segment
    ,util_band_s3
    ,util_band_s6 
    ,count(distinct account_id)
from s6_util
where s3_segment is not null
    //and statement_post_s3_clip = 3
group by 1,2,3

/////////MOnitoring A4 -- series C and cicada distros
select
    substr(statement_3_end_date,0,7) as clip_month
    ,cicada_rg
    ,clip_c_rg
    ,count(distinct account_id)
from s3_volume_drv
where s3_group in ('A','B') and s3_segment is not null
group by 1,2,3


/////////Monitoring B1 -- statement 7 CLIP distributions of statement 3 CLIPs
select distinct CLIP_D_RG_s7 from s3_volume_drv2 where substr(statement_3_end_date,0,7) = '2022-06';

select *
from s3_volume_drv2
where test_cell_s3s7 ilike '%s7%holdout%'
    and outcome_s7 ilike '%approve%'
;

select
    test_cell_s3s7
    ,substr(statement_3_end_date,0,7) as s3_month
    ,case when outcome_s7 ilike '%approve%' and clip_amt_s7 > 100 then 'A) Regular CLIP @ S7'
        when outcome_s7 ilike '%approve%' and clip_amt_s7 = 100 and average_utilization_3_months_FLOAT_s7 < 0.1 and CLIP_D_RG_s7 between 1 and 7 then 'B) minCLIP @ S7: Low risk and low util' 
        when outcome_s7 ilike '%approve%' and clip_amt_s7 = 100 and CLIP_D_RG_s7 > 7 then 'C) minCLIP @ S7: High risk'
        when outcome_s7 ilike '%ineligible%' then 'D) No CLIP @ S7: Ineligible'
        when outcome_s7 ilike '%decline%' then 'E) No CLIP @ S7: Decline/Holdout'
     end as s7_outcomes
     ,count(distinct account_id)
from s3_volume_drv2
where test_cell_s3s7 is not null and clip7_eval_date is not null
group by 1,2,3
;


//////////Monitoring B4 -- inactives at statement 7
select
    test_cell_s3s7
    ,s3_group
    ,substr(statement_3_end_date,0,7) as s3_month
    ,sum(active_in_stmt_cnt) as total_active
    ,count(distinct a.account_id) as total_accts
    ,sum(account_open_cnt) as total_open
from s3_volume_drv2 a
    left join (select * from edw_db.public.account_statements where statement_num = 7 and statement_end_dt >= '2022-10-01') b
        on a.account_id = b.account_id
where test_cell_s3s7 is not null and clip7_eval_date is not null
group by 1,2,3



///////Monitoring B5 --regrettables
select
    cicada_RG_s3
    ,CLIP_C_RG_s3
    ,util_band_s3
    ,case when PRE_CLIP_LINE_LIMIT_s3 < 1000 then 'A) 0-999'
        when PRE_CLIP_LINE_LIMIT_s3 < 2000 then 'B) 1000-1999'
        when PRE_CLIP_LINE_LIMIT_s3 < 3000 then 'C) 2000-2999'
        when PRE_CLIP_LINE_LIMIT_s3 >= 3000 then 'D) 3000+'
    end as PCL_s3
    //,substr(statement_3_end_date,0,7) as s3_month
    ,case when outcome_s7 ilike '%approve%' and clip_amt_s7 > 100 then 'A) Regular CLIP @ S7'
        when outcome_s7 ilike '%approve%' and clip_amt_s7 = 100 and average_utilization_3_months_FLOAT_s7 < 0.1 and CLIP_D_RG_s7 between 1 and 7 then 'B) minCLIP @ S7: Low risk and low util' 
        when outcome_s7 ilike '%approve%' and clip_amt_s7 = 100 and CLIP_D_RG_s7 > 7 then 'C) minCLIP @ S7: High risk'
        when outcome_s7 ilike '%ineligible%' then 'D) No CLIP @ S7: Ineligible'
        when outcome_s7 ilike '%decline%' then 'E) No CLIP @ S7: Decline/Holdout'
     end as s7_outcomes
     ,count(distinct account_id)
from s3_volume_drv2
where test_cell_s3s7 is not null and clip7_eval_date is not null
group by 1,2,3,4,5
;









