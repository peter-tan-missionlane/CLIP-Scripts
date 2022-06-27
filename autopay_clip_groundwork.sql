use database SANDBOX_DB;
use schema user_tb;

select payment_date, count(*) from "EDW_DB"."PUBLIC"."AUTOPAY_SCHEDULE_CREATED" group by 1
select * from mono_db.autopay_schedule limit 100


create or replace temporary table autopay_base_20220609 as 
Select apsc.Account_ID
  ,  apsc.Autopay_Source
  , apsc.Customer_ID
  , apsc.Day_of_Month
  , apsc.Fixed_Amount
  , apsc.Funding_Account_ID
  , APSC.Policy_Type
  , APSC.Schedule_Status,
assu.Schedule_id, assu.Schedule_status as Sched_Status, apsc.ETL_INSERt_TIMESTAMP_EST::date as Created_Date, assu.ETL_INSERt_TIMESTAMP_EST::date as Update_date
from "EDW_DB"."PUBLIC"."AUTOPAY_SCHEDULE_CREATED" as apsc
left join "EDW_DB"."PUBLIC"."AUTOPAY_SCHEDULE_STATUS_UPDATED" as assu
on apsc.schedule_id = assu.schedule_id
where apsc.Policy_Type ilike '%Monthly%' and TRIM(APSC.Schedule_Status) = 'ACTIVE' and (assu.Schedule_status is null or assu.Schedule_status = 'COMPLETE')
;


create or replace table AUTOPAY_DATA_20220609 as (
select b.*
  , a.EXTERNAL_ACCOUNT_ID
  , a.STATEMENT_END_DT
  , a.STATEMENT_NUM
  , case when b.ACCOUNT_ID is not null then 1 else 0 end as auto_pay_flag
from autopay_base_20220609 as b 
  left join  "EDW_DB"."PUBLIC"."ACCOUNT_STATEMENTS"  as a
on a.ACCOUNT_ID = b.ACCOUNT_ID and b.Created_Date <= a.STATEMENT_END_DT
--BETWEEN a.STATEMENT_START_DT AND a.STATEMENT_END_DT
)
;


select statement_end_dt, count(*) from autopay_data_20220609 group by 1 order by 1;

////May snapshot of CLIP7 decline rate for autopay-enrolled customers
create or replace temporary table drv1 as
select
    a.card_id
    ,c.account_id
    ,a.statement_number
    ,a.outcome
    ,(POST_CLIP_LINE_LIMIT - PRE_CLIP_LINE_LIMIT) as CLIP_AMT
    ,decision_data:"clip_model_c_20210811_risk_group"::INT AS clip_risk_group_INT
    ,case 
        when statement_number not in (7) then 'N/A'
        when outcome ilike '%approved%' and clip_amt = 100 and clip_risk_group_INT = 10 then '1) RG 10' //s7
        when outcome ilike '%approved%' and clip_amt = 100 and clip_risk_group_INT >= 7 then '2) RG 7-9' //s7
        else '0)RG < 7'
     end as s7_model_decline_flag
    ,case 
        when statement_number not in (11,18) then 'N/A'
        when outcome ilike '%decline%' and clip_risk_group_INT = 10 then '1) RG 10' //s11 and 18
        when outcome ilike '%decline%' and clip_risk_group_INT >= 7 then '2) RG 7-9' //s11 and 18
        else '0)RG < 7'
     end as s11_18_model_decline_flag
    ,case when auto_pay_flag = 1 then 1 else 0 end as autopay_flag 
from (select * from edw_db.public.clip_results_data where evaluated_timestamp between '2022-05-01' and '2022-05-31') a
    left join edw_db.public.accounts_customers_bridge bridge 
        on bridge.card_id = a.card_id
     left join (select * from autopay_data_20220609 where auto_pay_flag = 1 and statement_end_dt between '2022-05-01' and '2022-05-31') c
        on c.account_id = bridge.account_id
        and c.statement_num = a.statement_number
where statement_number in (7,11,18)
;

//from (select * from autopay_data_20220609 where auto_pay_flag = 1 and statement_num = 7 and statement_end_dt between '2022-05-01' and '2022-05-31') a
//  left join edw_db.public.accounts_customers_bridge bridge
//        on a.account_id = bridge.account_id
//  left join edw_db.public.clip_results_data c
//        on bridge.card_id = c.card_id
//;

//select count(distinct card_id) from edw_db.public.clip_results_data where statement_number = 18 and evaluated_timestamp between '2022-05-01' and '2022-05-31';

//select * from drv1;

/*select
    statement_number
    ,concat(s7_model_decline_flag, ' / ', s11_18_model_decline_flag, ' / ', autopay_flag) as Segmentation
    ,count(distinct card_id)
from drv1 a
group by 1,2
;
*/


///////For statement 6-11, look at both short (DQ ever in 4 statements post) and long term risk (DQ ever in 8 statements post)
//////PROBLEM: post-TSYS data only available --> can't look at long term risk
create or replace temporary table drv2 as
select
    a.account_id
    ,a.statement_number
    ,decision_data:"clip_model_c_20210811_risk_group"::INT AS clip_risk_group_INT
    ,case when auto_pay_flag = 1 then 1 else 0 end as autopay_flag 
from (select * from edw_db.public.clip_results_data where evaluated_timestamp between '2021-10-01' and '2021-11-30') a
    left join edw_db.public.accounts_customers_bridge bridge 
        on bridge.card_id = a.card_id
     left join (select * from autopay_data_20220609 where statement_end_dt between '2021-10-01' and '2021-11-30') c
        on c.account_id = bridge.account_id
        and c.statement_num = a.statement_number
//from (select * from edw_db.public.account_statements where statement_end_dt between '2021-09-08' and '2021-10-08') a
//     left join (select * from autopay_data_20220609 where auto_pay_flag = 1 and statement_end_dt between '2021-09-08' and '2021-10-08') c
//        on c.account_id = a.account_id
//        and c.statement_num = a.statement_num
//     left join edw_db.public.accounts_customers_bridge bridge
//        on a.account_id = bridge.account_id
//     left join edw_db.public.clip_results_data f
//        on f.account_id = a.account_id
where statement_number in (7,11,18)
;


--performance data 6 months out
create or replace temporary table autopay_short_term_perf as
select
    account_id
    ,case when delinquency_d030_ever_cnt > 0 then 1 else 0 end as delinquency_d030_ever_cnt
    ,case when delinquency_d060_ever_cnt > 0 then 1 else 0 end as delinquency_d060_ever_cnt
    ,statement_end_dt
    ,statement_num
from edw_db.public.account_statements
where statement_end_dt between '2022-04-01' and '2022-05-31' //adjust to change observation window
;

select * from autopay_short_term_perf

select
   // a.account_id
    a.clip_risk_group_INT
    ,a.autopay_flag
    ,avg(delinquency_d030_ever_cnt) as DQ30_ever_6mo
    ,avg(delinquency_d060_ever_cnt) as DQ60_ever_6mo
    ,count(distinct a.account_id)
from drv2 a
    left join autopay_short_term_perf b
        on a.account_id = b.account_id
where a.statement_number + 6 = b.statement_num
group by 1,2


//////For S7/11/18: How long have they had autopay enabled?
create or replace temporary table autopay_duration_drv1 as
select
    a.account_id
    ,a.statement_number
    ,s7_model_decline_flag
    ,s11_18_model_decline_flag
    ,b.statement_num
    ,b.auto_pay_flag
    ,row_number () over(partition by a.account_id order by b.statement_num asc) as num_months_enrolled
from (select * from drv1 where autopay_flag = 1) a
  left join autopay_data_20220609 b
      on a.account_id = b.account_id
      and b.statement_num <= a.statement_number
order by 1
;

select
    statement_number
    ,s7_model_decline_flag
    ,s11_18_model_decline_flag
    ,case when num_months_enrolled between 0 and 2 then 'A) 0-2 months'
          when num_months_enrolled between 2 and 5 then 'B) 2-5 months' 
          when num_months_enrolled between 5 and 8 then 'C) 5-8 months'
          when num_months_enrolled > 8 then 'D) 8+ months'
     end as months_enrolled_in_autopay
    ,count(distinct account_id)
from (select account_id, statement_number,s7_model_decline_flag,s11_18_model_decline_flag , max(num_months_enrolled) as num_months_enrolled from autopay_duration_drv1 group by 1,2,3,4)
group by 1,2,3,4
    
