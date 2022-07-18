----AT06S: number of trades opened in past 6 months
----RE33S: total revolving debt
select
    substr(evaluated_timestamp, 0, 7) as clip_month
    ,case when attribute_at06s = 0 then 'A) 0'
        when attribute_at06s = 1 then 'B) 1'
        when attribute_at06s = 2 then 'C) 2'
        when attribute_at06s = 3 then 'D) 3'
        when attribute_at06s = 4 then 'E) 4'
        when attribute_at06s = 5 then 'F) 5'
        when attribute_at06s between 6 and 8 then 'G) 6-8'
        when attribute_at06s between 9 and 10 then 'H) 9-10'
        when attribute_at06s > 10 then 'I) 10+'
     end as new_trades_past_6_mos
    ,case when re33s__tot_rev_debt < 10000 then 'A) < 10000'
        when re33s__tot_rev_debt between 10000 and 15000 then 'B) 10000-15000'
        when re33s__tot_rev_debt between 15000 and 20000 then 'C) 15000-20000'
        when re33s__tot_rev_debt between 20000 and 25000 then 'D) 20000-25000'
        when re33s__tot_rev_debt > 25000 then 'E) 25000+'
     end as total_rev_debt
    ,count(distinct a.account_id)
from (select * from edw_db.public.clip_results_data where statement_number = 7 and evaluated_timestamp >= '2021-01-01' and outcome ilike '%approve%') a
    left join account_review_data b on a.account_id = b.account_id and a.statement_number = b.statement_num
group by 1,2,3
;
