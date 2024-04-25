/*1. No.of day's the temperature increased(Hotter) in mumbai as compared to it's previous days - 
     * 71 days out of 211 days the temperature was increased(Hotter) in mumbai. 
	 * 73 days out of 211 days the temperature was dropeed(cold) in mumbai. 
     * 66 days out of 211 days the temperature was same in mumbai. 
*/

with cte as (select location_name,region,last_updated,temperature_celsius,
avg(temperature_celsius) over(partition by date(last_updated) order by date(last_updated)) as Avg_temp,
date(last_updated) as date
from Weather_India.indianweatherrepository
where location_name like 'mumbai'
order by last_updated),

avg_day_temp as (select date,avg(temperature_celsius) as DayAvg_temp
from cte
group by 1
order by 1),

lag_day_temp as (select *,
lag(DayAvg_temp) over(order by date) as lagger,
(DayAvg_temp-(lag(DayAvg_temp) over(order by date))) as Diff
from avg_day_temp)

select 
sum((Diff>0)) as rised,
sum((Diff<0)) as dropped,
sum((Diff=0)) as same
from lag_day_temp;


#2. Maximum Temperature: Query for top 5 cities with highest temperature
select region,location_name,max(feels_like_celsius)
from Weather_India.indianweatherrepository
where region like 'Maharashtra'
group by 1,2
order by 3 desc
limit 5;

#3. Minimum Temperature: Query for top 5 cities with lowest temperature
select region,location_name,min(feels_like_celsius)
from Weather_India.indianweatherrepository
where region like 'Maharashtra'
group by 1,2
order by 3
limit 5;

#4. Cities IN maharashtra where ICE-CREAM parlour's can be open OR Ice-cream/cold beverages where the ads can be played.
select region,location_name,last_updated,feels_like_celsius,condition_text,cloud,humidity
from Weather_India.indianweatherrepository
where region like 'Maharashtra' AND (condition_text='sunny' OR feels_like_celsius>30 OR humidity>60);

#5. Cities in Maharashtra where the average humidity level was above 60% between August 29, 2023, and March 1, 2024
select region,location_name,avg(humidity)
from Weather_India.indianweatherrepository
where region like 'Maharashtra' AND date(last_updated) BETWEEN '2023-08-29' AND '2024-03-01'
group by 1,2
having avg(humidity)>60
order by avg(humidity) desc;


#6. SQL query to perform the hourly wind analysis.
#6.1 Resultent set provides list of cities where wind turbins can be placed as per wind data.
select 
	region,
    location_name,
    EXTRACT(hour from last_updated) AS hour,
    avg(wind_kph) as avg_wind_KPH
from Weather_India.indianweatherrepository
group by location_name,region, EXTRACT(hour from last_updated)
having avg(wind_kph) > 18 
order by avg(wind_kph) desc;

#7.Identify Locations with Strongest Winds: 
select 
    location_name,
    region,
    round(avg(wind_kph),1) as avg_wind_kph
from Weather_India.indianweatherrepository
group by 1,2
order by  avg_wind_kph desc
limit 5;

#8.Extreme Wind Events (Gusts) Analysis: TOP 20 CITIES over region where maximum gust occured in kph between dates '29th August, 2023' and '1st April, 2024'.
/*
Gusts are sudden increase in wind speed
*/
select 
	region,
    location_name,
    MAX(gust_kph) as max_gust_kph
from Weather_India.indianweatherrepository
where date(last_updated) between '2023-08-29 ' and '2024-04-01'
group by location_name,region
order by max_gust_kph desc
limit 20;

#9. TOP CITIES of region 'Maharshtra and Gujarat' where the visibility_km is below avg.alter
#this query retrieves the top 4 locations with visibility is less than the average visibility for that location within each region.
#TOP Cities where visibility can be fixed firstly.
select * from (SELECT 
	region,
    location_name,
    min(visibility_km) as mivnvib,
    avg(visibility_km) as avvgvib,
    row_number() over(partition by region order by min(visibility_km)) as rn
from Weather_India.indianweatherrepository
group by 1,2
having mivnvib<avvgvib
order by region,mivnvib) as etmp
where rn<=1;

/*OPTIONAL
#TOP Cities where the visibiliy is very poor less than 2km
select 
    region,
    location_name,
    min(visibility_km) as mivnvib
from Weather_India.indianweatherrepository
where visibility_km < 2
group by 1, 2
order by region, mivnvib;*/


#10. Top 3 locations where the feels like temperature is the highest compared to the temperature.
/*
Businesses involved in outdoor activities or events, such as tourism, sports events, or outdoor concerts, need to consider the feels-like temperature to ensure the comfort 
and safety of participants and attendees.*/
select 
    location_name,
    temperature_celsius,
    feels_like_celsius
from Weather_India.indianweatherrepository
order by ABS(feels_like_celsius - temperature_celsius) desc
limit 10;	


/* 11. Average Temperature Comparison by Month: This query calculates the average temperature and feels-like temperature for each month, 
allowing businesses to identify trends and seasonal variations.
Ording the months which have maximum temperture deviation between current temperature and feels like temperature.
*/
select 
    month(last_updated) as month,
    avg(temperature_celsius) as AvgTemperature,
    avg(feels_like_celsius) as AvgFeelsLikeTemperature
from Weather_India.indianweatherrepository
group by month(last_updated)
order by (AvgFeelsLikeTemperature - AvgTemperature) desc;
	