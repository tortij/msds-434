create or replace table subscriber_model_final_project.test_data_subscriber as

with cte as (select usertype, cast(starttime as string) as starttime
from `nyc_citi_bike_trips.citibike_trips`
where usertype = 'Subscriber'
and starttime is not null),

cte2 as (select left(starttime, 10) as startdate, count(*) as ride_count
from cte
where left(starttime, 10) between '2014-01-01' and '2015-12-31'
group by left(starttime, 10))

select startdate as ride_date, ride_count
from cte2;
