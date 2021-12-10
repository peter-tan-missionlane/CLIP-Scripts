//// Sloppy Payer Data Exploration
//
/// Analysis Plan: 
/// 1. Split by Sloppy payer (1 DQ5+ count ever in first 7 statements) vs non sloppy payer 
///.        (0 DQ5+ in first 7 statements), what are their:
///     A) Risk scores distro @ stmt 7, B) subsequent DQ rates, C) trended OS Util, D) trended Purchase Util?
/// 2. Population selection: accounts who have at least 15 statements (i.e. 2020Q2 and prior) is preferred, but include COVID population as well to understand latest trends
/// 3.  Hypothesis free analysis

use database SANDBOX_DB;
use schema user_tb;

///Separate accounts who are considered 'sloppy payers' vs those who are not
/// Sloppy payer defn: those who missed only 1 payment in first 7 statements who have not missed another
///     one in the first x (9) statements
create or replace temporary table Sloppy_Payers_Drv1 as
select
    *
    ,case when delinquency_d005_ever_cnt = 1 and delinquency_d030_ever_cnt = 0 then 1
        else 0
     end as Missed_1_Payment_Flag
from EDW_DB.PUBLIC.ACCOUNT_STATEMENTS 
where statement_num = 5
    and account_open_dt >= '2020-01-01'
    //and account_open_dt <= '2021-01-01'
    and CREDIT_LIMIT_STMT_USD <> 0 //open accounts
;

create or replace temporary table Sloppy_Payers as
select
    b.*
    ,case when a.Missed_1_Payment_flag = 1 and b.delinquency_d005_ever_cnt = 1 and b.delinquency_d030_ever_cnt = 0 then '1. Sloppy Payer'
          when b.delinquency_d005_ever_cnt >= 1 then '2. Multiple Missed Payments'
          else '0. No Missed Payments'
     end as Sloppy_Payer_Flag
from Sloppy_Payers_Drv1 a
    join EDW_DB.PUBLIC.ACCOUNT_STATEMENTS b
        on a.account_id = b.account_id
where b.statement_num = 11
    and b.CREDIT_LIMIT_STMT_USD <> 0 //open accounts
;

select count(*) from sloppy_payers_drv1 where missed_1_payment_flag = 1;
select count(*) from sloppy_payers where sloppy_payer_flag ilike '%1%';
select * from sloppy_payers where sloppy_payer_flag = 1;


///RG Score distro @ stmt 7 between sloppy and non-sloppy payers --> Sloppy payers fail hardcuts and thus aren't 
///.  scored on model
///.  But use alternative methods to score the accounts (i.e. bureau risk scores, Acquisition risk score, 
///.        prior model retroscores)

// Cicada (Acq) Risk group distributions
select
    a.sloppy_payer_flag
    //,c.cicada_risk_group
    ,avg(c.cicada_risk_group)
    //,count(distinct a.account_id)
from
    Sloppy_Payers a
    left join edw_db.public.credit_applications b
        on a.customer_id = b.user_id
    left join edw_db.retro.scores__all c
        on b.id = c.application_id
group by 1//,2


select * from edw_db.public.credit_applications limit 100;

/// B-series retroscore (and util) distributions
SELECT 
    a.sloppy_payer_flag
    ,case 
      when CLIP_B_20200301_SCORE <= 0.065615684 then 1
      when CLIP_B_20200301_SCORE <= 0.10625795 then 2
      when CLIP_B_20200301_SCORE <= 0.14418404 then 3
      when CLIP_B_20200301_SCORE <= 0.18268697 then 4
      when CLIP_B_20200301_SCORE <= 0.21704997 then 5
      when CLIP_B_20200301_SCORE <= 0.2542925 then 6
      when CLIP_B_20200301_SCORE <= 0.27338776 then 7
      when CLIP_B_20200301_SCORE <= 0.29361102 then 8
      when CLIP_B_20200301_SCORE <= 0.3156857 then 9
      when CLIP_B_20200301_SCORE <= 1 then 10
    END AS CLIP_RG 
    //,avg(CLIP_B_20200301_SCORE)
    ,count(distinct a.account_id)
FROM Sloppy_Payers a
    left join sandbox_DB.user_tb.CLIP_B_MODEL_RETRO_20210325 b
        on a.account_id = b.card_id
where b.statement_num = 11
group by 1,2


/// Vantage / Revolving debt distributions
select 
    * 
from EDW_DB.PUBLIC.TU_ACCOUNT_REVIEW
where user_id = 442222853
limit 100
    


   


///Subsequent DQ Rates / OS util / Purchase util post stmt 9 (sloppy vs non-sloppy payers)
select
    a.sloppy_payer_flag
    ,b.statement_num
    ,avg(b.delinquency_d030_stmt_cnt) as DQ30Plus_Cnt
    ,case when sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) <> 0 then sum(b.delinquency_d030_stmt_usd) / sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD)
         else 0
         end as DQ30Plus_USD
    ,sum(b.purchase_balance_stmt_usd) / sum(b.CREDIT_LIMIT_STMT_USD) as avg_purch_utilization
    ,sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) / sum(b.CREDIT_LIMIT_STMT_USD) as avg_os_utilization
    ,count(distinct a.account_id)
from
    sloppy_payers a
    left join EDW_DB.PUBLIC.ACCOUNT_STATEMENTS b
        on a.account_id = b.account_id
where
    b.statement_num >= 1
group by 1,2


///Distribution of accounts / exposure for the most recent mature vintages
select
    sloppy_payer_flag
    ,count(distinct account_id)
    ,sum(credit_limit_orig_usd)
from sloppy_payers
group by 1


///% accounts CLIP'd at stmt 18
select
    a.sloppy_payer_flag
    ,b.outcome
    ,count(distinct a.account_id)
from sloppy_payers a
join edw_db.public.clip_results_data b
    on a.account_id = b.card_id
where b.statement_number = 18
group by 1,2

//// Compare the marginal in-group (high RG) from current policy with the marginal out-group (low RG) from the expansion
create or replace temporary table B_series_retro as
SELECT 
    a.*
    ,case 
      when CLIP_B_20200301_SCORE <= 0.065615684 then 1
      when CLIP_B_20200301_SCORE <= 0.10625795 then 2
      when CLIP_B_20200301_SCORE <= 0.14418404 then 3
      when CLIP_B_20200301_SCORE <= 0.18268697 then 4
      when CLIP_B_20200301_SCORE <= 0.21704997 then 5
      when CLIP_B_20200301_SCORE <= 0.2542925 then 6
      when CLIP_B_20200301_SCORE <= 0.27338776 then 7
      when CLIP_B_20200301_SCORE <= 0.29361102 then 8
      when CLIP_B_20200301_SCORE <= 0.3156857 then 9
      when CLIP_B_20200301_SCORE <= 1 then 10
    END AS CLIP_RG 
    ,case when sloppy_payer_flag ilike '%0%' and CLIP_RG between 5 and 7 then 'Marginal In-Group'
        when sloppy_payer_flag ilike '%1%' and CLIP_RG <= 7 then 'Marginal Expansion Group'
        else 'Other'
      end as marginal_group_flag
FROM Sloppy_Payers a
    left join sandbox_DB.user_tb.CLIP_B_MODEL_RETRO_20210325 b
        on a.account_id = b.card_id
where b.statement_num = 11
;

    ///Subsequent DQ Rates / OS util / Purchase util
select
    a.marginal_group_flag
    ,b.statement_num
    ,avg(b.delinquency_d030_stmt_cnt) as DQ30Plus_Cnt
    ,case when sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) <> 0 then sum(b.delinquency_d030_stmt_usd) / sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD)
         else 0
         end as DQ30Plus_USD
    ,sum(b.purchase_balance_stmt_usd) / sum(b.CREDIT_LIMIT_STMT_USD) as avg_purch_utilization
    ,sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) / sum(b.CREDIT_LIMIT_STMT_USD) as avg_os_utilization
    ,count(distinct a.account_id)
from
    b_series_retro a
    left join EDW_DB.PUBLIC.ACCOUNT_STATEMENTS b
        on a.account_id = b.account_id
where
    b.statement_num >= 1
group by 1,2

    ////Util x Risk bucket distrition
create or replace temporary table riskxutil_distro as
select
    a.account_id
    ,sloppy_payer_flag
    ,marginal_group_flag
    ,CLIP_RG
    ,sum(b.AVG_OUTSTANDING_BALANCE_STMT_USD) / sum(b.CREDIT_LIMIT_STMT_USD) as avg_os_utilization
from
    b_series_retro a
    left join EDW_DB.PUBLIC.ACCOUNT_STATEMENTS b
        on a.account_id = b.account_id
where
    b.statement_num = 11
group by 1,2,3,4
;

select
    sloppy_payer_flag
    ,CLIP_RG
    ,case when avg_OS_utilization < 0.1 then 'A) (0%, 10%)'
         when avg_OS_utilization < 0.3 then 'B) [10%, 30%)'
         when avg_OS_utilization >= 0.3 then 'C) >= 30%'
      end as stmt11_os_util
    ,count(distinct account_id)
from riskxutil_distro
group by 1,2,3
    

///// Compare CLOs between the sloppy payers and no missed payments
select
     a.sloppy_payer_flag
    ,b.statement_num
    ,case when sum(b.account_open_cnt) = 0 then null
        else avg(b.credit_limit_stmt_usd) / sum(b.account_open_cnt) 
     end as CLO
     ,avg(b.credit_limit_stmt_usd)
from
    sloppy_payers a
    left join EDW_DB.PUBLIC.ACCOUNT_STATEMENTS b
        on a.account_id = b.account_id
where
    b.statement_num >= 1
    and b.credit_limit_stmt_usd <> 0
group by 1,2


//// Get the monthly NABs data from 2021+ to size the accounts reaching stmt 11
select
    date_trunc('month', initiated)::date as open_date
    ,count(distinct user_id)
from edw_db.public.cards
where open_date >= '2020-01-01'
group by 1










