create or replace temporary table revised_account_review as
   SELECT
   user_id,
   case when TMSTMP_RECEIPT = '2016-01-11' then '2015-12'
        when TMSTMP_RECEIPT = '2016-08-09' then '2016-07'
        when TMSTMP_RECEIPT = '2017-03-01' then '2017-02'
        when TMSTMP_RECEIPT = '2017-04-01' then '2017-03'
        when TMSTMP_RECEIPT = '2018-03-01' then '2018-02'
        when TMSTMP_RECEIPT = '2018-12-12' then '2018-11'
        when TMSTMP_RECEIPT = '2019-01-06' then '2018-12'
        when TMSTMP_RECEIPT = '2019-02-04' then '2019-01'
        when TMSTMP_RECEIPT = '2019-04-02' then '2019-03'
        when TMSTMP_RECEIPT = '2019-07-02' then '2019-06'
        when TMSTMP_RECEIPT = '2019-08-05' then '2019-07'
        when TMSTMP_RECEIPT = '2019-10-04' then '2019-09'
        when TMSTMP_RECEIPT = '2020-01-06' then '2019-12'
        when TMSTMP_RECEIPT = '2020-07-07' then '2020-06'
        when TMSTMP_RECEIPT = '2020-08-06' then '2020-07'
        when TMSTMP_RECEIPT = '2020-10-01' then '2020-09'
        when TMSTMP_RECEIPT = '2020-10-02' then '2020-09'
        when TMSTMP_RECEIPT = '2020-11-01' then '2020-10'
        when TMSTMP_RECEIPT = '2020-12-01' then '2020-11'
        when TMSTMP_RECEIPT = '2021-01-04' then '2020-12'
        when TMSTMP_RECEIPT = '2021-02-03' then '2021-01'
        when TMSTMP_RECEIPT = '2021-03-03' then '2021-02'
        when TMSTMP_RECEIPT = '2021-04-01' then '2021-03'
        when TMSTMP_RECEIPT = '2021-05-01' then '2021-04'
        when TMSTMP_RECEIPT = '2021-07-05' then '2021-06'
        when TMSTMP_RECEIPT = '2021-09-02' then '2021-08'
        when TMSTMP_RECEIPT = '2021-10-03' then '2021-09'
        when TMSTMP_RECEIPT = '2021-11-01' then '2021-10'
        when TMSTMP_RECEIPT = '2021-12-08' then '2021-11'
        when TMSTMP_RECEIPT = '2022-01-04' then '2021-12'
        when TMSTMP_RECEIPT = '2022-02-01' then '2022-01'
        when TMSTMP_RECEIPT = '2022-02-02' then '2022-01'
        else to_char(TMSTMP_RECEIPT,'YYYY-MM') end as conv_time_stamp
  ,TMSTMP_RECEIPT
  ,vantage06_score::DOUBLE PRECISION as vtg30
  ,(case
  WHEN fico08_score = '+' THEN NULL
  when left(fico08_score,1) = '+'
  THEN right (fico08_score,3)
  ELSE LEFT(fico08_score,3)
  END)::FLOAT AS fico8
  ,attribute_re33s::DOUBLE PRECISION as re33s__tot_rev_debt
  ,attribute_at99::DOUBLE PRECISION as at99__tot_debt
  ,attribute_bc01s as bc01s__num_bc_trades
  ,attribute_at01s as at01s__num_trades
  ,attribute_at20s as at20s__age_oldest_trade2
  ,attribute_g242s as g242s__num_inq_3_mo
  ,attribute_g244s as g244s__num_inq_12_mo
  ,attribute_at02s as at02s_num_open_trades
  ,attribute_bc02s as bc02s_num_open_credit_cards
  ,attribute_attr08::DOUBLE PRECISION as attribute_attr08
  ,attribute_attr16::DOUBLE PRECISION as attribute_attr16
  ,attribute_st33s::DOUBLE PRECISION as attribute_st33s_student_debt
  ,attribute_in33s::DOUBLE PRECISION as attribute_in33s_installment_debt
  ,attribute_br12s::DOUBLE PRECISION as attribute_br12s
  ,attribute_at06s::DOUBLE PRECISION as attribute_at06s
  ,attribute_bc28s::DOUBLE PRECISION as attribute_bc28s
  ,attribute_bc31s::DOUBLE PRECISION as attribute_bc31s
  ,attribute_g051s::DOUBLE PRECISION as attribute_g051s
  ,attribute_bc34s::DOUBLE PRECISION as attribute_bc34s
  ,attribute_bc106s::DOUBLE PRECISION as attribute_bc106s
  ,attribute_bc36s::DOUBLE PRECISION as attribute_bc36s
  ,attribute_re12s::DOUBLE PRECISION as attribute_re12s
  ,attribute_au33s::DOUBLE PRECISION as attribute_au33s_auto_debt
  ,attribute_hi33s::DOUBLE PRECISION as attribute_hi33s_home_equity_loans
  from edw_db.public.tu_account_review
;

create or replace temporary table account_review_data as
  SELECT
  case
  when to_char(account_open_dt,'YYYY-MM') between '2017-01' and '2017-12' then '2017_cohort'
  when to_char(account_open_dt,'YYYY-MM') between '2018-01' and '2018-12' then '2018_cohort'
  when to_char(account_open_dt,'YYYY-MM') between '2019-01' and '2019-06' then '2019_1H_cohort'
  when to_char(account_open_dt,'YYYY-MM') between '2019-07' and '2019-09' then '2019_3Q_cohort'
  when to_char(account_open_dt,'YYYY-MM') between '2019-10' and '2019-12' then '2019_4Q_cohort'
  when to_char(account_open_dt,'YYYY-MM') between '2020-01' and '2020-03' then '2020_1Q_cohort'
  when to_char(account_open_dt,'YYYY-MM') between '2020-04' and '2020-06' then '2020_2Q_cohort'
  when to_char(account_open_dt,'YYYY-MM') between '2020-07' and '2020-09' then '2020_3Q_cohort'
  when to_char(account_open_dt,'YYYY-MM') between '2020-10' and '2020-12' then '2020_4Q_cohort'
  when to_char(account_open_dt,'YYYY-MM') between '2021-01' and '2021-03' then '2021_1Q_cohort'
  when to_char(account_open_dt,'YYYY-MM') between '2021-04' and '2021-06' then '2021_2Q_cohort'
  when to_char(account_open_dt,'YYYY-MM') between '2021-07' and '2021-09' then '2021_3Q_cohort'
  when to_char(account_open_dt,'YYYY-MM') between '2021-10' and '2021-12' then '2021_4Q_cohort'
  when to_char(account_open_dt,'YYYY-MM') between '2022-01' and '2022-03' then '2022_1Q_cohort'
  when to_char(account_open_dt,'YYYY-MM') between '2022-04' and '2022-06' then '2022_2Q_cohort'
  when to_char(account_open_dt,'YYYY-MM') between '2022-07' and '2022-09' then '2022_3Q_cohort'
  when to_char(account_open_dt,'YYYY-MM') between '2022-10' and '2022-12' then '2022_4Q_cohort'
  else null end as cohort,
  account_open_dt,
  A.account_open_cnt,
  A.avg_outstanding_principal_balance_stmt_usd as princ_bal,
  A.credit_limit_orig_usd as orig_cl,
  A.credit_limit_stmt_usd as curr_cl,
  A.delinquency_d005_stmt_cnt as num_bucket_1,
  A.delinquency_d030_stmt_cnt as num_bucket_2,
  A.delinquency_d060_stmt_cnt as num_bucket_3,
  A.delinquency_d090_stmt_cnt as num_bucket_4,
  A.delinquency_d120_stmt_cnt as num_bucket_5,
  A.delinquency_d150_stmt_cnt as num_bucket_6,
  A.ACCOUNT_ID
  ,A.STATEMENT_NUM
  ,A.STATEMENT_END_DT
  ,C.conv_time_stamp
  ,C.TMSTMP_RECEIPT
  ,vtg30
  ,fico8
  ,re33s__tot_rev_debt
  ,at99__tot_debt
  ,bc01s__num_bc_trades
  ,at01s__num_trades
  ,at20s__age_oldest_trade2
  ,g242s__num_inq_3_mo
  ,g244s__num_inq_12_mo
  ,at02s_num_open_trades
  ,bc02s_num_open_credit_cards
  ,attribute_attr08
  ,attribute_attr16
  ,attribute_st33s_student_debt
  ,attribute_in33s_installment_debt
  ,attribute_br12s
  ,attribute_bc28s
  ,attribute_at06s
  ,attribute_bc31s
  ,attribute_g051s
  ,attribute_bc34s
  ,attribute_bc106s
  ,attribute_bc36s
  ,attribute_re12s
  ,attribute_au33s_auto_debt
  ,attribute_hi33s_home_equity_loans
FROM
  edw_db.public.ACCOUNT_STATEMENTS AS A
  INNER JOIN
    EDW_DB.PUBLIC.accounts_customers_bridge AS B
    ON A.ACCOUNT_ID = B.ACCOUNT_ID
  INNER JOIN
    revised_account_review AS C
    ON B.USER_ID = C.USER_ID
      AND to_char(STATEMENT_END_DT,'YYYY-MM') = conv_time_stamp
;
