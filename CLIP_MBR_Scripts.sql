
///Average CLIP per CLIP'd account at statement 11

select
    date_trunc('month',evaluated_timestamp)::date as clip_month
    ,avg(post_clip_line_limit) as post_clip_line_avg
    ,avg(pre_clip_line_limit) as pre_clip_line_avg
    ,post_clip_line_avg - pre_clip_line_avg as clip_11_amt
from edw_db.public.clip_results_data
where statement_number = 11
    and outcome ilike '%approved%'
group by 1
;

///Average CLIP per CLIP'd account at statement 7

select
    date_trunc('month',evaluated_timestamp)::date as clip_month
    ,avg(post_clip_line_limit) as post_clip_line_avg
    ,avg(pre_clip_line_limit) as pre_clip_line_avg
    ,post_clip_line_avg - pre_clip_line_avg as clip_7_amt
from edw_db.public.clip_results_data
where statement_number = 7
    and outcome ilike '%approved%'
group by 1


//Statement 5 Incremental OS/CLIped Acct (post statement 11 CLIP) 
//// Also to calculate DQ30-60/CLIP'd acct
select
    date_trunc('month',evaluated_timestamp)::date as clip_month
    ,outcome
    ,test_segment
    ,count(*)
from edw_db.public.clip_results_data
where statement_number = 11
    //and test_segment ilike '%hold%'
    //and outcome ilike '%approved%'
    and evaluated_timestamp ilike '%2021-07%'
group by 1,2,3
;



create or replace temporary table CLIP_rollout as
select
    card_id
    ,date_trunc('month',evaluated_timestamp)::date as clip_month
    ,post_clip_line_limit
    ,pre_clip_line_limit
    ,post_clip_line_limit - pre_clip_line_limit as clip__amt
    ,test_segment
from edw_db.public.clip_results_data
where statement_number = 11
    and test_segment ilike '%rollout%'
    and outcome ilike '%approved%'
;

create or replace temporary table CLIP_holdout as
select
    card_id
    ,date_trunc('month',evaluated_timestamp)::date as clip_month
    ,post_clip_line_limit
    ,pre_clip_line_limit
    ,post_clip_line_limit - pre_clip_line_limit as clip__amt 
    ,outcome
    ,test_segment
    //distinct test_segment, count(*)
from edw_db.public.clip_results_data
where statement_number = 11
    and test_segment ilike '%hold%'
    //and outcome ilike '%approved%'
    //and evaluated_timestamp ilike '%2021-07%'
//group by 1
;

select
    a.clip_month
    ,(rollout_stmt5_OS - holdout_stmt5_OS) as incremental_stmt5_OS
    ,rollout_stmt5_OS_per_clip_acct - holdout_stmt5_OS_per_clip_acct as incremental_stmt5_OS_per_clip_acct
    ,
from
  (select 
      clip_month
      ,concat(year(clip_month),'Q',quarter(clip_month)) as clip_yq
      ,sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) as rollout_stmt5_OS
      ,count(distinct a.card_id) as rollout_accts
      ,sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD)/count(distinct a.card_id) as rollout_stmt5_OS_per_clip_acct
      ,sum(b.delinquency_d030_stmt_usd)-sum(b.delinquency_d060_stmt_usd) as DQ30_60_usd
      ,sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) as OS
  from CLIP_rollout a
      left join EDW_DB.PUBLIC.ACCOUNT_STATEMENTS b
          on a.card_id = b.account_id
  where b.statement_num = 16
  group by 1) a
  join
    (select 
        clip_month
        ,concat(year(clip_month),'Q',quarter(clip_month)) as clip_yq
        ,sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) as holdout_stmt5_OS
        ,count(distinct a.card_id) as holdout_accts
        ,sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD)/count(distinct a.card_id) as holdout_stmt5_OS_per_clip_acct
        ,sum(b.delinquency_d030_stmt_usd)-sum(b.delinquency_d060_stmt_usd) as DQ30_60_usd
        ,sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) as OS
    from CLIP_holdout a
        left join EDW_DB.PUBLIC.ACCOUNT_STATEMENTS b
            on a.card_id = b.account_id
    where b.statement_num = 16
    group by 1) b
        on a.clip_month = b.clip_month


//Statement 3 Pre-Post OS/CLIped Acct and $DQ30-60% (post statement 7 CLIP)  
////

create or replace temporary table CLIP7_accounts as
select
    card_id
    ,date_trunc('month',evaluated_timestamp)::date as clip_month
    ,post_clip_line_limit
    ,pre_clip_line_limit
    ,post_clip_line_limit - pre_clip_line_limit as clip__amt
    ,test_segment
    ,outcome
    ,b.AVG_OUTSTANDING_BALANCE_STMT_USD as clipd_stmt_os_bal
from (select * from edw_db.public.clip_results_data where statement_number = 7 and outcome ilike '%approved%') a
    left join EDW_DB.PUBLIC.ACCOUNT_STATEMENTS b
        on a.card_id = b.account_id
            and a.statement_number = b.statement_num
;


select
    a.clip_month
    ,(rollout_stmt5_OS - holdout_stmt5_OS) as incremental_stmt5_OS
    ,rollout_stmt5_OS_per_clip_acct - holdout_stmt5_OS_per_clip_acct as incremental_stmt5_OS_per_clip_acct
from
  (select 
      clip_month
      ,sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) as rollout_stmt3_OS
      ,count(distinct a.card_id) as rollout_accts
      ,sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD)/count(distinct a.card_id) as rollout_stmt3_OS_per_clip_acct
      ,sum(a.clipd_stmt_os_bal) as pre_clip_os
      ,pre_clip_os / count(distinct a.card_id) as pre_clip_os_per_clip_acct
      ,rollout_stmt3_OS_per_clip_acct-pre_clip_os_per_clip_acct as pre_post_incremental_os
  from CLIP7_accounts a
      left join EDW_DB.PUBLIC.ACCOUNT_STATEMENTS b
          on a.card_id = b.account_id
  where b.statement_num = 10
  group by 1)
  

///CLIP 7 / 11 Funnel
DROP TABLE IF EXISTS sandbox_db.user_tb.acct_clip;
Create temp table sandbox_db.user_tb.acct_clip as (
select
   card_id
  ,statement_number
  ,to_char(EVALUATED_TIMESTAMP,'YYYY-MM') AS month_evaluated
  ,outcome
  ,DECISION_DATA
  ,CLIP_RISK_GROUP
  ,CLIP_POLICY_NAME
  ,TEST_SEGMENT
  ,(POST_CLIP_LINE_LIMIT - PRE_CLIP_LINE_LIMIT) as CLIP_AMT
  ,decision_data:"never_delinquent__passed" as no_DQ_flag1
  ,decision_data:"delinquency__passed" as no_DQ_flag2
  ,decision_data:"average_utilization_3_months"::FLOAT as util_at_clip
from EDW_DB.PUBLIC.CLIP_RESULTS_DATA
);

DROP TABLE IF EXISTS sandbox_db.user_tb.acct_clip_1;
Create temp table sandbox_db.user_tb.acct_clip_1 as (
select a.*,
  substring(b.statement_end_dt,1,7) as stmt_month
from sandbox_db.user_tb.acct_clip a
left join edw_db.public.account_statements b
on a.card_id=b.account_id
and a.statement_number=b.statement_num 
);

/*create or replace temporary table clip_funnel_eval as
select 
  stmt_month,
  statement_number,
  month_evaluated,
  outcome,
  CLIP_RISK_GROUP,
  CLIP_POLICY_NAME,
  TEST_SEGMENT,
  CLIP_AMT,
  case when util_at_clip < 0.1 then 'A.<10%'
  when util_at_clip <0.3 then 'B.10%-30%'
  when util_at_clip <.5 then 'C.30%-50%'
  when util_at_clip <0.8 then 'D.50%-80%'
  when util_at_clip >=0.8  then 'E.>80%'
  end as util_band,
  count(card_id) as accounts,
  sum(clip_amt)
from sandbox_db.user_tb.acct_clip_1
group by 1,2,3,4,5,6,7,8,9
; */

///Statement 7/11 funnel
select
    month_evaluated as clip_month
    ,outcome
    ,case when outcome ilike '%approved%' then 'Approved'
          when outcome ilike '%ineligible%' and (no_dq_flag1 ilike '%false%' or no_dq_flag2 ilike '%false%') then 'Ineligible - DQ Cut'
          when outcome ilike '%ineligible%'                                  then 'Ineligible - Hardcut'
          when outcome ilike '%declined%' and (util_at_clip < 0.1)           then 'Declined - Low Util'
          when outcome ilike '%declined%'                                    then 'Declined - High Risk'
     end as CLIP_outcome_group
    ,case when clip_amt > 100 then '>$100'
          when clip_amt = 100 and util_band not ilike '%<10%%' then '$100 - Util > 10%'
          when clip_amt = 100 and util_band ilike '%<10%%' then '$100 - Util < 10%'
     end as CLIP_amt_group
    ,sum(accounts)
from
    (select 
      stmt_month,
      statement_number,
      month_evaluated,
      outcome,
      CLIP_RISK_GROUP,
      CLIP_POLICY_NAME,
      TEST_SEGMENT,
      CLIP_AMT,
      UTIL_AT_CLIP,
      NO_DQ_FLAG1,
      NO_DQ_FLAG2,
      case when util_at_clip < 0.1 then 'A.<10%'
      when util_at_clip <0.3 then 'B.10%-30%'
      when util_at_clip <.5 then 'C.30%-50%'
      when util_at_clip <0.8 then 'D.50%-80%'
      when util_at_clip >=0.8  then 'E.>80%'
      end as util_band,
      count(card_id) as accounts,
      sum(clip_amt)
    from sandbox_db.user_tb.acct_clip_1
    group by 1,2,3,4,5,6,7,8,9,10,11)
where
    statement_number = 11
group by 1,2,3,4

///////
////
////
////
///
/// DQ 30-60 / Open for Stmt 7 and 11 CLIPs
/// C-H
/// (by quarterly cohorts)
create or replace temporary table CLIP11_DQ_RO as
select
    date_trunc('month',evaluated_timestamp)::date as clip_month
    //,concat(year(clip_month),'Q',quarter(clip_month)) as clip_yq
    ,b.statement_num - 11 as statement_num_post_clip
    ,sum(b.delinquency_d030_stmt_usd) as DQ30_usd
    ,sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) as OS
from (select * from edw_db.public.clip_results_data where statement_number = 11 
        and test_segment ilike '%rollout%' and outcome ilike '%approved%') a
    left join edw_db.public.account_statements b
        on a.card_id = b.account_id
where b.statement_num >= 11
group by 1,2
;

create or replace temporary table CLIP11_DQ_HO as
select
    date_trunc('month',evaluated_timestamp)::date as clip_month
    //,concat(year(clip_month),'Q',quarter(clip_month)) as clip_yq
    ,b.statement_num - 11 as statement_num_post_clip
    ,sum(b.delinquency_d030_stmt_usd) as DQ30_usd
    ,sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) as OS
    ,count(distinct account_id)
from (select * from edw_db.public.clip_results_data where statement_number = 11 
        and test_segment ilike '%hold%') a
    left join edw_db.public.account_statements b
        on a.card_id = b.account_id
where b.statement_num >= 11
group by 1,2
;

select
    a.clip_month
    ,a.statement_num_post_clip
    ,(a.dq30_usd / a.os) as RO_dq30_usd
    ,(b.dq30_usd / b.os) as HO_dq30_usd
from clip11_dq_RO a
    join clip11_dq_HO b
        on a.clip_month = b.clip_month
            and a.statement_num_post_clip = b.statement_num_post_clip


