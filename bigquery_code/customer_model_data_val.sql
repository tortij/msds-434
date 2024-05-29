create or replace table customer_model_final_project.val_data_customer as

with cte as (select usertype, cast(starttime as string) as starttime
from `nyc_citi_bike_trips.citibike_trips`
where usertype = 'Customer'
and starttime is not null),

cte2 as (select left(starttime, 10) as startdate, count(*) as ride_count
from cte
where left(starttime, 10) between '2016-05-01' and '2016-07-31'
group by left(starttime, 10))

select timestamp(startdate) as ride_date, ride_count
from cte2
