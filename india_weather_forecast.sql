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


#2. max temperatire of Top 5 cities of regions(Maharashtra).
# TOP 5 cities in india which have max temperature from 26thug2024-2ndFeb2024. 
select region,location_name,max(feels_like_celsius)
from Weather_India.indianweatherrepository
where region like 'Maharashtra'
group by 1,2
order by 3 desc
limit 5;

# TOP 5 cities in india which have max temperature from 26thug2024-2ndFeb2024. 
select region,location_name,min(feels_like_celsius)
from Weather_India.indianweatherrepository
where region like 'Maharashtra'
group by 1,2
order by 3
limit 5;

#3. Cities IN maharashtra where ICE-CREAM parlour's can be open/Ice-cream/cold beverages where the ads can be played.
select region,location_name,last_updated,feels_like_celsius,condition_text,cloud,humidity
from Weather_India.indianweatherrepository
where region like 'Maharashtra' AND (condition_text='sunny' OR feels_like_celsius>30 OR humidity>60);

#4. cities in Maharashtra where the average humidity level was above 60% between August 29, 2023, and March 1, 2024
select region,location_name,avg(humidity)
from Weather_India.indianweatherrepository
where region like 'Maharashtra' AND date(last_updated) BETWEEN '2023-08-29' AND '2024-03-01'
group by 1,2
having avg(humidity)>60
order by avg(humidity) desc;

#4. Cities where the tempearture increased suddenly in short period of time.
#5. Vacation rate as per cities in maharashtra


#5. SQL query to perform the hourly wind analysis.
#5.1 Result set provides list of cities where wind turbins can be placed as per wind data.
SELECT 
	region,
    location_name,
    EXTRACT(HOUR FROM last_updated) AS hour,
    AVG(wind_kph) AS avg_wind_KPH
FROM Weather_India.indianweatherrepository
GROUP BY location_name,region, EXTRACT(HOUR FROM last_updated)
having AVG(wind_kph) > 18 
ORDER BY AVG(wind_kph) desc;

#6.Identify Locations with Strongest Winds: 
SELECT 
    location_name,
    region,
    round(AVG(wind_kph),1) AS avg_wind_kph
FROM Weather_India.indianweatherrepository
GROUP BY 1,2
ORDER BY avg_wind_kph DESC
LIMIT 5; -- Top 5 locations with highest average wind speed

#7.Extreme Wind Events (Gusts) Analysis: TOP 20 CITIES over region where maximum gust occured in kph
/*
Gusts are sudden increase in wind speed
*/
SELECT 
	region,
    location_name,
    MAX(gust_kph) AS max_gust_kph
FROM Weather_India.indianweatherrepository
where date(last_updated) BETWEEN '2023-08-29 ' AND '2024-04-01'
GROUP BY location_name,region
ORDER BY max_gust_kph DESC
limit 20;

#8.TOP CITIES of region 'Maharshtra and Gujarat' where the visibility_km is below avg.alter

#this query retrieves the top 4 locations with visibility is less than the average visibility for that location within each region.

#TOP Cities where visibility can be fixed firstly.
select * from (SELECT 
	region,
    location_name,
    min(visibility_km) as mivnvib,
    avg(visibility_km) as avvgvib,
    row_number() over(partition by region order by min(visibility_km)) as rn
FROM Weather_India.indianweatherrepository
group by 1,2
having mivnvib<avvgvib
order by region,mivnvib) as etmp
where rn<=1;


#TOP Cities where the visibiliy is very poor less than 2km
SELECT 
    region,
    location_name,
    min(visibility_km) as mivnvib
FROM Weather_India.indianweatherrepository
WHERE visibility_km < 2
GROUP BY 1, 2
ORDER BY region, mivnvib;



#11.TOP 10 LOCATIONS where the difference between the current temperture and the feels-like temperature is the highest
/*The industries affected are Hospitality and Tourism,Healthcare,Construction and Infrastructure
The industries benefited are Food and Beverage,Energy and Utilities
*/
SELECT 
	region,
    location_name,
    temperature_celsius AS current_temperature,
    feels_like_celsius AS feels_like_temperature,
    ABS(temperature_celsius - feels_like_celsius) AS temperature_difference
FROM 
    Weather_India.indianweatherrepository
ORDER BY 
    temperature_difference DESC
limit 10;



#Top 3 locations where the feels like temperature is the highest compared to the temperature.

/*
Businesses involved in outdoor activities or events, such as tourism, sports events, or outdoor concerts, need to consider the feels-like temperature to ensure the comfort and safety of participants and attendees.*/
SELECT 
    location_name,
    temperature_celsius,
    feels_like_celsius
FROM 
    Weather_India.indianweatherrepository
ORDER BY 
    ABS(feels_like_celsius - temperature_celsius) DESC
limit 10;
