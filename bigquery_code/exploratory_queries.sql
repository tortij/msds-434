-- data exploration– determining business use case and model

-- how big is this dataset?
select count(*) from `nyc_citi_bike_trips.citibike_trips`
-- 59 million records

select count(start_station_id) from `nyc_citi_bike_trips.citibike_trips`
-- 53 million records
-- note– including a where is not null clause returned the same count

-- what is the range of data for my project?
select min(starttime) as first_trip, max(starttime) as last_trip
from `nyc_citi_bike_trips.citibike_trips`

-- first_trip is july 2013
-- last_trip is may 2018

-- is there sufficient data across all years?
with cte as(
select cast(starttime as string) as starttime
from `nyc_citi_bike_trips.citibike_trips`
)

select left(starttime,4) as year, count(*)
from cte
group by left(starttime,4)
order by year asc

-- answer is yes, there are sufficient rides–
-- https://docs.google.com/spreadsheets/d/1ofnRKiitOSH3fcrM8hNYjF6hoqqBcRIqTzRbDdhbxoc/edit#gid=1565653107

-- what is the geographic breakdown of the data?
select distinct region_id
from `nyc_citi_bike_trips.citibike_stations`

-- 4 regions (71, 70, 0, 311) there are no names for the regions
-- there are 2209 distinct stations

select count(distinct start_station_id) as start_count,
count(distinct end_station_id) as end_count
from `nyc_citi_bike_trips.citibike_trips`

-- there are 881 and 926 starting and ending stations, respectively, used

-- *************************idea:**************************
-- do demand forecasting for each of the 4 regions

-- is there enough data to do this analysis?

with cte as (select region_id, extract(year from starttime) as year
from `nyc_citi_bike_trips.citibike_trips` as trip
left join `nyc_citi_bike_trips.citibike_stations` as station
on cast(trip.start_station_id as string) = station.station_id
where extract(year from starttime) is not null
and start_station_id is not null
and region_id is not null)

select count(*)
from cte

-- returns 0 records …

with cte as (select region_id, start_station_id
from `nyc_citi_bike_trips.citibike_trips` as trip
left join `nyc_citi_bike_trips.citibike_stations` as station
on cast(trip.start_station_id as string) = station.station_id)


select region_id, count(*)
from cte
group by region_id

-- returns 0. ok so region id isn’t actually used !

-- can i do something with station_name?
select distinct start_station_name
from `nyc_citi_bike_trips.citibike_trips`
limit 100

-- nope, no discernable data for the boroughs

-- can i use latitude and longitude coordinates to group origins by borough?

-- Manhattan, New York City, is approximately located within the following latitude and longitude range:
-- Latitude: 40.7011° to 40.8781° N
-- Longitude: -74.0209° to -73.9070° W

-- Brooklyn is approximately located within the following latitude and longitude range:
-- Latitude: 40.5704° to 40.7394° N
-- Longitude: -74.0419° to -73.8334° W

-- manhattan range–
-- where start_station_latitude between 40.7011 and 40.8781
-- and start_station_longitude between -74.0209 and -73.9070




select count(distinct start_station_id)
from `nyc_citi_bike_trips.citibike_trips`
where start_station_latitude between 40.5704 and 40.7394
and start_station_longitude between -74.0419 and -73.8334

-- (brooklyn range)
-- this output 477

select count(distinct station_id)
from `nyc_citi_bike_trips.citibike_stations`
where latitude between 40.7011 and 40.8781
and longitude between -74.0209 and -73.9070

-- (manhattan range)
-- output is 1141)

-- range will not work, they all overlap by lat lon pairs


-- ****************idea*************************
-- do demand forecasting by usertype (subscriber vs customer)

-- is usertype used?
select count(*)
from `nyc_citi_bike_trips.citibike_trips`
where 
usertype is not null

-- ~58 million records


-- is there sufficient data by year and usertype?
select usertype, extract(year from starttime) as year, count(*)
from `nyc_citi_bike_trips.citibike_trips`
where usertype is not null
and starttime is not null
group by usertype, extract(year from starttime)

-- yes there is enough
-- https://docs.google.com/spreadsheets/d/1kh0YVWg0bkwRWntZzdsGH7xKs4XGvHhu_r19OAeejcE/edit#gid=159864911

-- another gut check on sufficient data when starttime and usertype nulls are accounted for
select count(*)
from `nyc_citi_bike_trips.citibike_trips`
where usertype is not null
and starttime is not null
-- 53 million records

-- what grain of data is good for the demand forecasting?
with cte as (select usertype, cast(starttime as string) as starttime
from `nyc_citi_bike_trips.citibike_trips`
where usertype is not null
and starttime is not null)

select usertype, left(starttime, 7) as startdate, count(*)
from cte
group by usertype, left(starttime, 7)

-- this is monthly^
-- https://docs.google.com/spreadsheets/d/1QG71chTyoPURsHI7WaR1E9mRNDoCY3lS3CV3X4X3k4Y/edit#gid=1068258353

with cte as (select usertype, cast(starttime as string) as starttime
from `nyc_citi_bike_trips.citibike_trips`
where usertype is not null
and starttime is not null),

cte2 as (select usertype, left(starttime, 10) as startdate
from cte)

select distinct startdate 
from cte2
order by cte2.startdate asc

-- this is daily^