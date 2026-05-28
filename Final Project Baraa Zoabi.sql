--Data Explorations
select * from `bqproj-435911.fp_lamas_data.lamas_israel_2025`

select `סמל_ישוב` from `bqproj-435911.fp_lamas_data.lamas_israel_2025`

select * from `bqproj-435911.fp_israel_super_db.israel_supermarkets_points`
WHERE  City LIKE '%חיפה%' or 
       City LIKE '%רעננה%' or
       City LIKE '%נשר%' 

select * from `bqproj-435911.fp_israel_super_db.israel_supermarkets_polygons`
WHERE  (City LIKE '%חיפה%' or 
       City LIKE '%רעננה%' or
       City LIKE '%נשר%' ) and(Name ='Carrefour' or Name LIKE '%שופרסל דיל%' or Name Like '%רמי לוי%')

select * from `bqproj-435911.fp_adid_super_db.israel_super_adid_scheme`
where Name ='שופרסל דיל' and city='חיפה'

select * from `bqproj-435911.fp_adid_super_db.israel_super_adid_scheme`
where  city='חיפה'

select * from `bqproj-435911.fp_adid_super_db.shufersal_deal_haifa`

SELECT 
  COUNT(*) AS total_signals,
  SUM(CASE WHEN accuracy > 150 THEN 1 ELSE 0 END) AS outliers,
  ROUND(SUM(CASE WHEN accuracy > 150 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS outliers_percent
FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_haifa`

---how much supermarkets are there in each city

Select  City, count(*) as num_of_superMarkets
from `bqproj-435911.fp_israel_super_db.israel_supermarkets_points`
group by 1
order by 2 desc

--how much citzens are there in each city and how much supermarkets? 
--it shows no data, there are some cities with arabic names and cities like jerusalem with mixed name with arabic and hebrew names in the points table and some liken tel-aviv not similar to the lamas table what I did to overcome this problem, I added on the join query instead of equal sign only, I used ON LOWER(l.`שם_ישוב`) LIKE CONCAT('%', LOWER(s.City), '%')
SELECT 
  l.`שם_ישוב`,
  COUNT(s.Name) AS num_supermarkets,
  l.`סהכ` AS total_population
FROM `bqproj-435911.fp_lamas_data.lamas_israel_2025` l
JOIN `bqproj-435911.fp_israel_super_db.israel_supermarkets_points` s
ON LOWER(l.`שם_ישוב`) LIKE CONCAT('%', LOWER(s.City), '%')
GROUP BY l.`שם_ישוב`, l.`סהכ`
ORDER BY 2 DESC


--The cities with biggest populations in lamas table
----some cities name are written differently than other tables lets check the polygons table
select `שם_ישוב` as city, `סהכ` as population from `bqproj-435911.fp_lamas_data.lamas_israel_2025`
order by 2 desc 

---check the polygon table
--we can see that the points table and the polygons table have the same names 
select City, count(*) as num_of_occurences from `bqproj-435911.fp_israel_super_db.israel_supermarkets_polygons`
group by 1
order by 2 desc
-----------------------editing the names of the cities-------------
--editing the cities names in lamas table 
--I noticed that there are some cities with different names for example haifa doesn't appear the same in both tables lamas and points 
 
SELECT 
  REGEXP_REPLACE(LOWER(`שם_ישוב`), r'[-\s]', ' ') AS clean_city,
FROM `bqproj-435911.fp_lamas_data.lamas_israel_2025` 
where `שם_ישוב` LIKE '%חיפה%'
------------------------------יחס סופרים למספר תושבים האם יש מחסור?-------------------------------------------

SELECT 
  l.`שם_ישוב` as city_name,
  ROUND(SAFE_DIVIDE(SUM(l.`סהכ`), COUNT(s.Name)), 1) AS population_per_super
FROM `bqproj-435911.fp_lamas_data.lamas_israel_2025` l
JOIN `bqproj-435911.fp_israel_super_db.israel_supermarkets_points` s
ON LOWER(l.`שם_ישוב`) LIKE CONCAT('%', LOWER(s.City), '%')
GROUP BY l.`שם_ישוב`, l.`סהכ`
ORDER BY 2 DESC
-----------------------------------------שטח סופרים ממוצע לפי ישוב------------------------------------

SELECT 
  l.`שם_ישוב` as city_name,
  AVG(s.Area) as supermarkets_avg_area
FROM `bqproj-435911.fp_lamas_data.lamas_israel_2025` l
JOIN `bqproj-435911.fp_israel_super_db.israel_supermarkets_polygons` s
ON LOWER(l.`שם_ישוב`) LIKE CONCAT('%', LOWER(s.City), '%')
GROUP BY l.`שם_ישוב`, l.`סהכ`
ORDER BY 2 DESC

--------------------------------------------------התפלגות קבוצות גיל לפי ישוב--------------------------------------------------------


SELECT 
  `שם_ישוב` AS city,
  SUM(`גיל_0_5`) AS age_0_5,
  SUM(`גיל_6_18`) AS age_6_18,
  SUM(`גיל_19_45`) AS age_19_45,
  SUM(`גיל_46_55`) AS age_46_55,
  SUM(`גיל_56_64`) AS age_65_64,
  SUM(`גיל_65_פלוס`) AS age_65_plus,
  SUM(`סהכ`) AS total
FROM  `bqproj-435911.fp_lamas_data.lamas_israel_2025`
GROUP BY city
ORDER BY SUM(`סהכ`) DESC
LIMIT 10

--------------------------------------------------פרק 1 ---------------------------------------------------
--שאלה 1
--הצגת נתונים על כמות סופרים, מספר תושבים ויחס עומס 
SELECT 
  l.`שם_ישוב` as city,
  COUNT(s.Name) AS num_supermarkets,
  l.`סהכ` AS total_population,
  SAFE_DIVIDE(l.`סהכ`, COUNT(s.Name)) AS population_per_supermarket
FROM `bqproj-435911.fp_lamas_data.lamas_israel_2025` l
JOIN `bqproj-435911.fp_israel_super_db.israel_supermarkets_points` s
ON LOWER(l.`שם_ישוב`) LIKE CONCAT('%', LOWER(s.City), '%')
where city  LIKE '%חיפה%' or city LIKE '%גליל ים%' or city LIKE '%רעננה%' or city LIKE '%הרצליה%' or city LIKE '%נשר%' 
or city LIKE '%ראשון לציון%'
GROUP BY l.`שם_ישוב`, l.`סהכ`
ORDER BY 2 DESC
--כמות תושבים בכל עיר 
SELECT 
  l.`שם_ישוב` as city,
  COUNT(*) AS num_supermarkets,
  l.`סהכ` AS total_population
FROM `bqproj-435911.fp_lamas_data.lamas_israel_2025` l
JOIN `bqproj-435911.fp_israel_super_db.israel_supermarkets_points` s
ON LOWER(l.`שם_ישוב`) LIKE CONCAT('%', LOWER(s.City), '%')
where city  LIKE '%חיפה%' or city LIKE '%גליל ים%' or city LIKE '%רעננה%' or city LIKE '%הרצליה%' or city LIKE '%נשר%' 
or city LIKE '%ראשון לציון%'
GROUP BY l.`שם_ישוב`, l.`סהכ`
order by 3 desc

--POPULATION PER SUPERMARKET
SELECT 
  l.`שם_ישוב` as city,
  COUNT(distinct s.WKT) AS num_supermarkets,
  l.`סהכ` AS total_population,
  ROUND(l.`סהכ`/COUNT(distinct s.WKT),0) AS population_per_supermarket
FROM `bqproj-435911.fp_lamas_data.lamas_israel_2025` l
JOIN `bqproj-435911.fp_israel_super_db.israel_supermarkets_points` s
ON LOWER(l.`שם_ישוב`) LIKE CONCAT('%', LOWER(s.City), '%')
where city  LIKE '%חיפה%' or city LIKE '%גליל ים%' or city LIKE '%רעננה%' or city LIKE '%הרצליה%' or city LIKE '%נשר%' 
or city LIKE '%ראשון לציון%'
GROUP BY l.`שם_ישוב`, l.`סהכ`
order by 4 desc
--שאלה 2 פרק 1
-----הקשר בין כמות תושבים למספר סופרמרקטים בכל ישוב 
SELECT 
  l.`שם_ישוב` as city,
  COUNT(s.Name) AS num_supermarkets,
  l.`סהכ` AS total_population
FROM `bqproj-435911.fp_lamas_data.lamas_israel_2025` l
JOIN `bqproj-435911.fp_israel_super_db.israel_supermarkets_points` s
ON LOWER(l.`שם_ישוב`) LIKE CONCAT('%', LOWER(s.City), '%')
GROUP BY l.`שם_ישוב`, l.`סהכ`
ORDER BY 2 DESC

------הקשר בין עומס בסופרים לבין גודל אוכלוסיה -איך גודל אוכלוסיה משפיע על העומס? האם יש השפעה? 

SELECT 
  l.`שם_ישוב` as city,
  COUNT(s.Name) AS num_supermarkets,
  l.`סהכ` AS total_population,
  SAFE_DIVIDE(l.`סהכ`, COUNT(s.Name)) AS population_per_supermarket
FROM `bqproj-435911.fp_lamas_data.lamas_israel_2025` l
JOIN `bqproj-435911.fp_israel_super_db.israel_supermarkets_points` s
ON LOWER(l.`שם_ישוב`) LIKE CONCAT('%', LOWER(s.City), '%')
GROUP BY l.`שם_ישוב`, l.`סהכ`
ORDER BY 2 DESC

----הקשר בין שטח ממוצע לסניפים בערים לבין גודל אוכלוסיה 

SELECT 
  l.`שם_ישוב` AS city,
  COUNT(s.centroid) AS num_supers,
  SUM(s.area) AS total_area,
  ROUND(SUM(s.area) / COUNT(s.centroid), 2) AS avg_area_per_super,
  l.`סהכ` AS total_population
FROM `bqproj-435911.fp_lamas_data.lamas_israel_2025` l
JOIN `bqproj-435911.fp_israel_super_db.israel_supermarkets_polygons` s
ON LOWER(l.`שם_ישוב`) LIKE CONCAT('%', LOWER(s.City), '%')
GROUP BY city, total_population
ORDER BY total_population DESC


---------------------------------------פרק 2------------------------------------------------------------------
select * from `bqproj-435911.fp_adid_super_db.carrefour_raanana`----
select * from `bqproj-435911.fp_adid_super_db.fresh_market_galil_yam`
select * from `bqproj-435911.fp_adid_super_db.hatzi_hinam_rishon`
select * from `bqproj-435911.fp_adid_super_db.israel_super_adid_scheme`
select * from `bqproj-435911.fp_adid_super_db.keshet_teamim_haifa`
select * from `bqproj-435911.fp_adid_super_db.mega_ba_ir_herzliya`
select * from `bqproj-435911.fp_adid_super_db.rami_levy_haifa`-----
select * from `bqproj-435911.fp_adid_super_db.shufersal_deal_haifa`------
select * from `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`------
-------------------------------------------------------------------------------------------------------------------
--no data
select day_name from `bqproj-435911.fp_adid_super_db.carrefour_raanana`
where day_name='Saturday'
----------------------------------------------cleaning supermarkets tables-----------------------------------------------------

--CHECKING MAX AND MINIMUM VALUE FOR LONGTITUE AND LATITUDE
select 'Carrefour Raanana' as super_name, MAX(longitude) as max_longitude, min(longitude) as min_longitude, max(latitude) as max_latitude, min(latitude) as min_latitude from `bqproj-435911.fp_adid_super_db.carrefour_raanana`
UNION ALL
select 'Rami-Lavi Haifa' as super_name, MAX(longitude) as max_longitude, min(longitude) as min_longitude, max(latitude) as max_latitude, min(latitude) as min_latitude from `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
UNION ALL
select 'SHUFERSAL DEAL Haifa' as super_name, MAX(longitude) as max_longitude, min(longitude) as min_longitude, max(latitude) as max_latitude, min(latitude) as min_latitude from `bqproj-435911.fp_adid_super_db.shufersal_deal_haifa`
UNION ALL
select 'SHUFERSAL DEAL Haifa' as super_name, MAX(longitude) as max_longitude, min(longitude) as min_longitude, max(latitude) as max_latitude, min(latitude) as min_latitude from `bqproj-435911.fp_adid_super_db.shufersal_deal_haifa`
UNION ALL
select 'SHUFERSAL DEAL NESHER' as super_name, MAX(longitude) as max_longitude, min(longitude) as min_longitude, max(latitude) as max_latitude, min(latitude) as min_latitude from `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`





WITH cleaned_data AS (

  SELECT 
    deviceid, 'Carrefour' AS super_name, 'Raanana' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) AS israel_time_ts,
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS clean_date,
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS hour,
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS day_name,
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.carrefour_raanana`
  WHERE 
    deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Shufersal' AS super_name, 'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_haifa`
  WHERE 
    deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Rami-Levi' AS super_name, 'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
  WHERE 
    deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Shufersal' AS super_name, 'Nesher' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`
  WHERE 
    deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

)

SELECT 
  deviceid,super_name, city,
  COUNT(*) AS total_events, 
  COUNT(DISTINCT clean_date) AS active_days,
  COUNT(DISTINCT day_name) AS active_weekdays,
  ROUND(AVG(hour), 1) AS avg_hour,
  ROUND(AVG(accuracy), 1) AS avg_accuracy,
  COUNT(DISTINCT city) AS city_count,
  COUNT(DISTINCT super_name) AS super_count
FROM cleaned_data
GROUP BY deviceid, super_name, city
ORDER BY total_events DESC


----------------------------------------------------------------------------שאלה 2 -1------------------------------------------------------------------------------------------------

--סקירה כללית של נתונים
WITH cleaned_data AS (

  SELECT 
    deviceid, 'Carrefour' AS super_name, 'Raanana' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) AS israel_time_ts,
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS clean_date,
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS hour,
    EXTRACT(YEAR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS year,
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS day_name,
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.carrefour_raanana`
  WHERE 
    deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Shufersal-Haifa' AS super_name, 'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(YEAR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_haifa`
  WHERE 
    deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Rami-Levi' AS super_name, 'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(YEAR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
  WHERE 
    deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Shufersal-Nesher' AS super_name, 'Nesher' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(YEAR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`
  WHERE 
    deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

),

device_data as(

SELECT 
  deviceid,super_name, city, year,
  COUNT(*) AS total_events, 
  COUNT(DISTINCT clean_date) AS active_days,
  COUNT(DISTINCT day_name) AS active_weekdays,
  ROUND(AVG(hour), 1) AS avg_hour,
  ROUND(AVG(accuracy), 1) AS avg_accuracy,
  COUNT(DISTINCT city) AS city_count,
  COUNT(DISTINCT super_name) AS super_count,
  ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT clean_date), 1) AS avg_events_per_day

FROM cleaned_data
GROUP BY deviceid, super_name, city,year
ORDER BY total_events DESC)

SELECT
  max (avg_accuracy) as max_accuracy, min(avg_accuracy) as min_accuracy,
  max(avg_hour) as max_hour, min(avg_hour) as min_hour,
  max(active_days) as max_active_days, max(year) as max_year, min(year) as min_year
from device_data
------------------------------------------------------בדיקת מספר מופע כל מכשיר ברמה יומית---------------------------------------------------------------------------------
WITH cleaned_data AS (

  SELECT 
    deviceid, 'Carrefour' AS super_name, 'Raanana' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) AS israel_time_ts,
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS clean_date,
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS hour,
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS day_name,
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.carrefour_raanana`
  WHERE 
    deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Shufersal' AS super_name, 'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_haifa`
  WHERE 
    deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Rami-Levi' AS super_name, 'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
  WHERE 
    deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Shufersal' AS super_name, 'Nesher' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`
  WHERE 
    deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

)

SELECT 
  deviceid,
  clean_date,
  city,
  super_name,
  COUNT(*) AS daily_device_events
FROM cleaned_data
GROUP BY deviceid, clean_date, city, super_name
ORDER BY daily_device_events desc


------------------------------------------------------------------------------בדיקת מכשירים שהופיעו ביותר מסופר אחד----------------------------------------------------------------------------------------------
WITH cleaned_data AS (

  SELECT 
    deviceid, 'Carrefour' AS super_name, 'Raanana' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) AS israel_time_ts,
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS clean_date,
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS hour,
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS day_name,
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.carrefour_raanana`
  WHERE 
    deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Shufersal' AS super_name, 'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_haifa`
  WHERE 
    deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Rami-Levi' AS super_name, 'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
  WHERE 
    deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Shufersal' AS super_name, 'Nesher' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`
  WHERE 
    deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

),

device_locations AS (
  SELECT 
    deviceid,
    COUNT(DISTINCT super_name) AS num_supers,
    COUNT(DISTINCT city) AS num_cities
  FROM cleaned_data
  GROUP BY deviceid
  ),

  multi_location_devices AS (
    SELECT deviceid
    FROM device_locations
    WHERE num_supers >= 2 AND num_cities >= 2
  )

  SELECT distinct(deviceid)
  FROM multi_location_devices

--------------------------------------------------------פתרון פרק 2 שאלה 1

WITH cleaned_data AS (
  SELECT 
    deviceid, 'Carrefour' AS super_name, 'Raanana' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) AS israel_time_ts,
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS clean_date,
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS hour,
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS day_name,
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.carrefour_raanana`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Shufersal-Haifa' AS super_name, 'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Rami-Levi' AS super_name, 'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Shufersal-Nesher' AS super_name, 'Nesher' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150
),

daily_duration AS (
  SELECT 
    deviceid,
    city,
    super_name,
    clean_date,
    MAX(hour) - MIN(hour) AS duration_hours
  FROM cleaned_data
  GROUP BY deviceid, city, super_name, clean_date
),


device_stats AS (
  SELECT 
    d.deviceid,
    d.city,
    d.super_name,
    COUNT(*) AS total_events,
    COUNT(DISTINCT d.clean_date) AS active_days,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT d.clean_date), 1) AS avg_events_per_day,
    MIN(hour) AS min_hour,
    MAX(hour) AS max_hour,
    ROUND(AVG(accuracy), 1) AS avg_accuracy,
    ROUND(AVG(dd.duration_hours), 1) AS avg_daily_duration
  FROM cleaned_data d
  JOIN daily_duration dd 
    ON d.deviceid = dd.deviceid 
    AND d.clean_date = dd.clean_date
    AND d.city = dd.city
    AND d.super_name = dd.super_name
  GROUP BY d.deviceid, d.city, d.super_name
),

-- בדיקת האם המכשיר הופיע בעוד ערים או סופרים
device_scope_check AS (
  SELECT 
    deviceid,
    COUNT(DISTINCT city) AS total_cities,
    COUNT(DISTINCT super_name) AS total_supers
  FROM cleaned_data
  GROUP BY deviceid
)

-- סינון מכשירים לפי קריטריונים של עובד סניף
SELECT 
  ds.deviceid,
  ds.city,
  ds.super_name,
  ds.total_events,
  ds.active_days,
  ds.avg_events_per_day,
  ds.min_hour,
  ds.max_hour,
  ds.avg_accuracy,
  ds.avg_daily_duration
FROM device_stats ds
JOIN device_scope_check dsc ON ds.deviceid = dsc.deviceid
WHERE 
  ds.active_days >= 10
  AND ds.avg_events_per_day >= 10
  AND ds.min_hour >= 6
  AND ds.max_hour <= 22
  AND ds.avg_accuracy <=50
  AND dsc.total_cities = 1
  AND dsc.total_supers = 1
  AND ds.avg_daily_duration >=4
ORDER BY ds.total_events DESC
---------------------------------------------------------------------------פרק 2 שאלה 2-------------------------------------------------------------------------------------------------

WITH cleaned_data AS (
SELECT 
    deviceid, 'Carrefour' AS super_name, 'Raanana' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) AS israel_time_ts,
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS clean_date,
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS hour,
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS day_name,
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.carrefour_raanana`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Shufersal-Haifa' AS super_name, 'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Rami-Levi' AS super_name, 'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Shufersal-Nesher' AS super_name, 'Nesher' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150
),

daily_duration AS (
  SELECT 
    deviceid,
    city,
    super_name,
    clean_date,
    MAX(hour) - MIN(hour) AS duration_hours,
    EXTRACT(WEEK FROM clean_date) AS week_number
  FROM cleaned_data
  GROUP BY deviceid, city, super_name, clean_date
),

device_stats AS (
  SELECT 
    d.deviceid,
    d.city,
    d.super_name,
    COUNT(*) AS total_events,
    COUNT(DISTINCT d.clean_date) AS active_days,
    COUNT(DISTINCT EXTRACT(WEEK FROM d.clean_date)) AS weeks_active,
    ROUND(COUNT(DISTINCT d.clean_date) * 1.0 / COUNT(DISTINCT EXTRACT(WEEK FROM d.clean_date)), 2) AS avg_days_per_week,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT d.clean_date), 1) AS avg_events_per_day,
    MIN(hour) AS min_hour,
    MAX(hour) AS max_hour,
    ROUND(AVG(accuracy), 1) AS avg_accuracy,
    ROUND(AVG(dd.duration_hours), 1) AS avg_daily_duration
  FROM cleaned_data d
  JOIN daily_duration dd 
    ON d.deviceid = dd.deviceid 
    AND d.clean_date = dd.clean_date
    AND d.city = dd.city
    AND d.super_name = dd.super_name
  GROUP BY d.deviceid, d.city, d.super_name
),

device_scope_check AS (
  SELECT 
    deviceid,
    COUNT(DISTINCT city) AS total_cities,
    COUNT(DISTINCT super_name) AS total_supers
  FROM cleaned_data
  GROUP BY deviceid
)

SELECT 
  ds.deviceid,
  ds.city,
  ds.super_name,
  ds.total_events,
  ds.avg_days_per_week,
  ds.avg_events_per_day,
  ds.min_hour,
  ds.max_hour,
  ds.avg_accuracy,
  ds.avg_daily_duration,
FROM device_stats ds
JOIN device_scope_check dsc ON ds.deviceid = dsc.deviceid
WHERE 
  ds.avg_days_per_week <= 1.5
  AND ds.avg_daily_duration <= 1.5
  AND ds.avg_events_per_day <= 3
  AND ds.active_days >= 3
  AND ds.total_events BETWEEN 5 AND 50
  AND ds.weeks_active <= 4
  AND ((ds.min_hour BETWEEN 6 AND 12 AND ds.max_hour <= 14)
  OR (ds.min_hour >= 20 AND ds.max_hour <= 23))
  AND ds.avg_accuracy <=20
  AND (dsc.total_cities >= 2 OR dsc.total_supers >= 2)

ORDER BY ds.total_events DESC;

-------------------------------------------------------------------------פרק 2 שאלה 3 ---------------------------------------------------------------------------------------------------
WITH cleaned_data AS (
  SELECT 
    deviceid, 'Carrefour' AS super_name, 'Raanana' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) AS israel_time_ts,
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS clean_date,
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS hour,
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS day_name,
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.carrefour_raanana`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Shufersal-Haifa' AS super_name, 'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Rami-Levi' AS super_name, 'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Shufersal-Nesher' AS super_name, 'Nesher' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

),

daily_duration AS (
  SELECT 
    deviceid,
    city,
    super_name,
    clean_date,
    MAX(hour) - MIN(hour) AS duration_hours,
    EXTRACT(WEEK FROM clean_date) AS week_number
  FROM cleaned_data
  GROUP BY deviceid, city, super_name, clean_date
),

device_stats AS (
  SELECT 
    d.deviceid,
    d.city,
    d.super_name,
    COUNT(*) AS total_events,
    COUNT(DISTINCT d.clean_date) AS active_days,
    COUNT(DISTINCT EXTRACT(WEEK FROM d.clean_date)) AS weeks_active,
    ROUND(COUNT(DISTINCT d.clean_date) * 1.0 / COUNT(DISTINCT EXTRACT(WEEK FROM d.clean_date)), 2) AS avg_days_per_week,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT d.clean_date), 1) AS avg_events_per_day,
    ROUND(AVG(accuracy), 1) AS avg_accuracy,
    ROUND(AVG(dd.duration_hours), 1) AS avg_daily_duration
  FROM cleaned_data d
  JOIN daily_duration dd 
    ON d.deviceid = dd.deviceid 
    AND d.clean_date = dd.clean_date
    AND d.city = dd.city
    AND d.super_name = dd.super_name
  GROUP BY d.deviceid, d.city, d.super_name
),

device_scope_check AS (
  SELECT 
    deviceid,
    COUNT(DISTINCT city) AS total_cities,
    COUNT(DISTINCT super_name) AS total_supers
  FROM cleaned_data
  GROUP BY deviceid
)

SELECT 
  ds.deviceid,
  ds.city,
  ds.super_name,
  ds.total_events,
  ds.active_days,
  ds.weeks_active,
  ds.avg_days_per_week,
  ds.avg_events_per_day,
  ds.avg_accuracy,
  ds.avg_daily_duration,
  dsc.total_cities,
  dsc.total_supers
FROM device_stats ds
JOIN device_scope_check dsc ON ds.deviceid = dsc.deviceid
WHERE 
  ds.avg_days_per_week BETWEEN 2 AND 5         
  AND ds.weeks_active >= 4                     
  AND ds.total_events >= 50                    
  AND ds.avg_events_per_day BETWEEN 3 AND 15   
  AND ds.avg_accuracy <= 25                    
  AND dsc.total_supers = 1                     
  AND dsc.total_cities = 1                     
----------------------------------------------------------------------------------------שאלה 4 פרק 2-----------------------------------------------------------------

WITH cleaned_data AS (
  SELECT 
    deviceid, 'Carrefour' AS super_name, 'Raanana' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) AS israel_time_ts,
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS clean_date,
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS hour,
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS day_name,
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.carrefour_raanana`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Shufersal-Haifa' AS super_name, 'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Rami-Levi' AS super_name, 'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Shufersal-Nesher' AS super_name, 'Nesher' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

),

activity_by_day_hour AS (
  SELECT
    super_name,
    city,
    day_name,
    hour,
    clean_date,
    deviceid
  FROM cleaned_data
  
)

SELECT *
FROM activity_by_day_hour
ORDER BY 
  CASE day_name
    WHEN 'Sunday' THEN 1
    WHEN 'Monday' THEN 2
    WHEN 'Tuesday' THEN 3
    WHEN 'Wednesday' THEN 4
    WHEN 'Thursday' THEN 5
    WHEN 'Friday' THEN 6
    WHEN 'Saturday' THEN 7
  END,
  hour;


------------------------------------------------------------------------------------פרק 2 שאלה 5 


WITH cleaned_data AS (
  SELECT 
    deviceid,
    CASE 
      WHEN table_name = 'carrefour_raanana' THEN 'Carrefour'
      WHEN table_name = 'shufersal_deal_haifa' THEN 'Shufersal-Haifa'
      WHEN table_name = 'rami_levy_haifa' THEN 'Rami-Levi'
      WHEN table_name = 'shufersal_deal_nesher' THEN 'Shufersal-Nesher'
    END AS super_name,
    CASE 
      WHEN table_name = 'carrefour_raanana' THEN 'Raanana'
      ELSE 'Haifa'  
    END AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) AS israel_time_ts,
    accuracy
  FROM (
    SELECT *, 'carrefour_raanana' AS table_name FROM `bqproj-435911.fp_adid_super_db.carrefour_raanana`
    UNION ALL
    SELECT *, 'shufersal_deal_haifa' FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_haifa`
    UNION ALL
    SELECT *, 'rami_levy_haifa' FROM `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
    UNION ALL
    SELECT *, 'shufersal_deal_nesher' FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`
  )
  WHERE 
    deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
)

SELECT 
  super_name,
  city,
  COUNTIF(accuracy > 150) * 100.0 / COUNT(*) AS percent_of_outliers,
  COUNT(*) AS total_signals,
  COUNTIF(accuracy > 150) AS outlier_signals
FROM cleaned_data
GROUP BY super_name, city
ORDER BY percent_of_outliers DESC;

--------------------------------------------------------שאלה 3 
--חישוב ממוצע אותות לפי יום כדי לעזור בפתרון שאלה 3 
WITH cleaned_data AS (
  
  SELECT 
    deviceid,
    'Carrefour' AS super_name,
    'Raanana' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) AS israel_time_ts,
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS clean_date,
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS hour,
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS day_name
  FROM `bqproj-435911.fp_adid_super_db.carrefour_raanana`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy < 150

  UNION ALL
  SELECT 
    deviceid, 'Shufersal-Haifa', 'Haifa',
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy < 150

  UNION ALL
  SELECT 
    deviceid, 'Rami-Levi', 'Haifa',
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy < 150

  UNION ALL
  SELECT 
    deviceid, 'Shufersal-Nesher', 'Nesher',
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy < 150
),


daily_stats AS (
  SELECT 
    city,
    super_name,
    day_name,
    COUNT(*) AS total_signals,
    COUNT(DISTINCT hour) AS active_hours
  FROM cleaned_data
  GROUP BY city, super_name, day_name
)


SELECT 
  city,
  super_name,
  day_name,
  total_signals,
  active_hours,
  ROUND(total_signals * 1.0 / active_hours, 1) AS avg_signals_per_hour
FROM daily_stats
ORDER BY 
  super_name,
  CASE day_name
    WHEN 'Sunday' THEN 1
    WHEN 'Monday' THEN 2
    WHEN 'Tuesday' THEN 3
    WHEN 'Wednesday' THEN 4
    WHEN 'Thursday' THEN 5
    WHEN 'Friday' THEN 6
    WHEN 'Saturday' THEN 7
  END
------------------------------------שאלה 4 רגרסיה---------------
--שאלה 1 משתנה תלוי מספר מכשירים ייחודים, ב"ת מספר שבוע
--קרפור רעננה 
WITH cleaned_data AS (
  SELECT
    deviceid,
    'Carrefour' AS super_name,
    'Raanana' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) AS ts,
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS week_number
  FROM `bqproj-435911.fp_adid_super_db.carrefour_raanana`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT
    deviceid,
    'Rami-Levi' AS super_name,
    'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT
    deviceid,
    'Shufersal-Nesher' AS super_name,
    'Nesher' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150
),


weekly_unique_devices AS (
  SELECT
    week_number,
    COUNT(DISTINCT deviceid) AS unique_devices
  FROM cleaned_data
  WHERE super_name='Carrefour'
  GROUP BY week_number
)

SELECT *
FROM weekly_unique_devices
ORDER BY week_number;

---שופרסל נשר
WITH cleaned_data AS (
SELECT
    deviceid,
    'Carrefour' AS super_name,
    'Raanana' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) AS ts,
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS week_number
  FROM `bqproj-435911.fp_adid_super_db.carrefour_raanana`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT
    deviceid,
    'Rami-Levi' AS super_name,
    'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT
    deviceid,
    'Shufersal-Nesher' AS super_name,
    'Nesher' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150
),


weekly_unique_devices AS (
  SELECT
    week_number,
    COUNT(DISTINCT deviceid) AS unique_devices
  FROM cleaned_data
  WHERE super_name='Shufersal-Nesher'
  GROUP BY week_number
)

SELECT *
FROM weekly_unique_devices
ORDER BY week_number;

---רמי לוי חיפה 

WITH cleaned_data AS (
  SELECT
    deviceid,
    'Carrefour' AS super_name,
    'Raanana' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) AS ts,
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS week_number
  FROM `bqproj-435911.fp_adid_super_db.carrefour_raanana`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT
    deviceid,
    'Rami-Levi' AS super_name,
    'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT
    deviceid,
    'Shufersal-Nesher' AS super_name,
    'Nesher' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150
),


weekly_unique_devices AS (
  SELECT
    week_number,
    COUNT(DISTINCT deviceid) AS unique_devices
  FROM cleaned_data
  WHERE super_name='Rami-Levi'
  GROUP BY week_number
)

SELECT *
FROM weekly_unique_devices
ORDER BY week_number;

-------------שאלה 4 פרק 2 -רגרסיה משתנה תלוי שטח סופר ביחס לכמות מכשירים ייחודיים---------------------
---תהליך חילוץ מידע היה צריך לאתר מידע  על סניפים נכונים מכיוון שהיו כפיליות בנתונים בטבלת POLYGONS 
---אז היה צריך לעשות גילוי נתונים קטן כדי לאתר נתוניםפ נכונים במיוחד לקרפור רעננה 

--הטבלה הזו מסכמת את הנתונים בטבלה על הסופרין ניתן לראות כפיליות בחלק מהנתונים בשם סופר ובשם עיר אז היה צריך לפנות לטבלת POINTS  על מנת לאתר את המיקום הנכון 
select * from `bqproj-435911.fp_israel_super_db.israel_supermarkets_polygons`
WHERE  (City LIKE '%חיפה%' or 
       City LIKE '%רעננה%' or
       City LIKE '%נשר%' ) and(Name ='Carrefour' or Name LIKE '%שופרסל דיל%' or Name Like '%רמי לוי%')
---------------------------------------------------------------------
--חיבור טבלת POLYGONS עם POINTS 
select * from `bqproj-435911.fp_israel_super_db.israel_supermarkets_polygons` p
join `bqproj-435911.fp_adid_super_db.israel_super_adid_scheme` s on p.centroid=s.centroid
WHERE  (p.City LIKE '%חיפה%' or 
       p.City LIKE '%רעננה%' or
       p.City LIKE '%נשר%' ) and(p.Name ='Carrefour' or p.Name LIKE '%שופרסל דיל%' or p.Name Like '%רמי לוי%')
----------------הטבלה הנ"ל מכילה מידע על ארבעת הסניפים שבחרתי לניתוח נתונים בשאלת הרגרסיה בחרתי 3 והמידע לא כפול וניתן להוסיף אותו לטבלת הרגרסיה כטבלת עזר לשליפת המידע על השטח לכל סופר

WITH cleaned_data AS (
  SELECT
    deviceid,
    'Carrefour-Raanana' AS super_name,
    'Raanana' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) AS ts,
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS week_number
  FROM `bqproj-435911.fp_adid_super_db.carrefour_raanana`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT
    deviceid,
    'Rami-Levi-Haifa' AS super_name,
    'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT
    deviceid,
    'Shufersal-Nesher' AS super_name,
    'Nesher' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150
),
device_counts AS (
  SELECT
    super_name,
    city,
    week_number,
    COUNT(DISTINCT deviceid) AS unique_devices
  FROM cleaned_data
  GROUP BY super_name, city, week_number
),

super_areas AS (
  SELECT
    CONCAT(
    CASE 
      WHEN p.Name LIKE '%שופרסל%' THEN 'Shufersal'
      WHEN p.Name LIKE '%רמי לוי%' THEN 'Rami-Levi'
      WHEN (p.Name LIKE '%קרפור%' OR p.Name LIKE '%Carrefour%') THEN 'Carrefour'
      ELSE 'Unknown'
    END,
    '-',
    CASE 
      WHEN p.City LIKE '%חיפה%' THEN 'Haifa'
      WHEN p.City LIKE '%רעננה%' THEN 'Raanana'
      WHEN p.City LIKE '%נשר%' THEN 'Nesher'
      ELSE 'Unknown'
    END) AS super_name_city,
    CASE 
      WHEN p.City LIKE '%חיפה%' THEN 'Haifa'
      WHEN p.City LIKE '%רעננה%' THEN 'Raanana'
      WHEN p.City LIKE '%נשר%' THEN 'Nesher'
      ELSE 'Unknown'
    END AS city,
    area 
  from `bqproj-435911.fp_israel_super_db.israel_supermarkets_polygons` p
  join `bqproj-435911.fp_adid_super_db.israel_super_adid_scheme` s on p.centroid=s.centroid
  WHERE  (p.City LIKE '%חיפה%' or 
       p.City LIKE '%רעננה%' or
       p.City LIKE '%נשר%' ) and(p.Name ='Carrefour' or p.Name LIKE '%שופרסל דיל%' or p.Name Like '%רמי לוי%')

)

SELECT 
  d.super_name,
  d.week_number,
  d.unique_devices,
  a.area,
  a.city,
  SAFE_DIVIDE(a.area, d.unique_devices) AS area_per_device
FROM device_counts d
JOIN super_areas a
ON d.super_name = a.super_name_city
ORDER BY d.super_name, d.week_number;
--------לכל סניף אעשה רגרסיה נפרדת כנדרש בשאלה
--קרפור רעננה 
WITH cleaned_data AS (
  SELECT
    deviceid,
    'Carrefour-Raanana' AS super_name,
    'Raanana' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) AS ts,
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS week_number
  FROM `bqproj-435911.fp_adid_super_db.carrefour_raanana`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT
    deviceid,
    'Rami-Levi-Haifa' AS super_name,
    'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT
    deviceid,
    'Shufersal-Nesher' AS super_name,
    'Nesher' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150
),
device_counts AS (
  SELECT
    super_name,
    city,
    week_number,
    COUNT(DISTINCT deviceid) AS unique_devices
  FROM cleaned_data
  GROUP BY super_name, city, week_number
),

super_areas AS (
  SELECT
    CONCAT(
    CASE 
      WHEN p.Name LIKE '%שופרסל%' THEN 'Shufersal'
      WHEN p.Name LIKE '%רמי לוי%' THEN 'Rami-Levi'
      WHEN (p.Name LIKE '%קרפור%' OR p.Name LIKE '%Carrefour%') THEN 'Carrefour'
      ELSE 'Unknown'
    END,
    '-',
    CASE 
      WHEN p.City LIKE '%חיפה%' THEN 'Haifa'
      WHEN p.City LIKE '%רעננה%' THEN 'Raanana'
      WHEN p.City LIKE '%נשר%' THEN 'Nesher'
      ELSE 'Unknown'
    END) AS super_name_city,
    CASE 
      WHEN p.City LIKE '%חיפה%' THEN 'Haifa'
      WHEN p.City LIKE '%רעננה%' THEN 'Raanana'
      WHEN p.City LIKE '%נשר%' THEN 'Nesher'
      ELSE 'Unknown'
    END AS city,
    area 
  from `bqproj-435911.fp_israel_super_db.israel_supermarkets_polygons` p
  join `bqproj-435911.fp_adid_super_db.israel_super_adid_scheme` s on p.centroid=s.centroid
  WHERE  (p.City LIKE '%חיפה%' or 
       p.City LIKE '%רעננה%' or
       p.City LIKE '%נשר%' ) and(p.Name ='Carrefour' or p.Name LIKE '%שופרסל דיל%' or p.Name Like '%רמי לוי%')

)

SELECT 
  d.week_number,
  d.unique_devices,
  a.area,
  SAFE_DIVIDE(a.area, d.unique_devices) AS area_per_device
FROM device_counts d
JOIN super_areas a
ON d.super_name = a.super_name_city
WHERE d.super_name='Carrefour-Raanana'
ORDER BY d.super_name, d.week_number;
--------רמי לוי חיפה
WITH cleaned_data AS (
  SELECT
    deviceid,
    'Carrefour-Raanana' AS super_name,
    'Raanana' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) AS ts,
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS week_number
  FROM `bqproj-435911.fp_adid_super_db.carrefour_raanana`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT
    deviceid,
    'Rami-Levi-Haifa' AS super_name,
    'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT
    deviceid,
    'Shufersal-Nesher' AS super_name,
    'Nesher' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150
),
device_counts AS (
  SELECT
    super_name,
    city,
    week_number,
    COUNT(DISTINCT deviceid) AS unique_devices
  FROM cleaned_data
  GROUP BY super_name, city, week_number
),

super_areas AS (
  SELECT
    CONCAT(
    CASE 
      WHEN p.Name LIKE '%שופרסל%' THEN 'Shufersal'
      WHEN p.Name LIKE '%רמי לוי%' THEN 'Rami-Levi'
      WHEN (p.Name LIKE '%קרפור%' OR p.Name LIKE '%Carrefour%') THEN 'Carrefour'
      ELSE 'Unknown'
    END,
    '-',
    CASE 
      WHEN p.City LIKE '%חיפה%' THEN 'Haifa'
      WHEN p.City LIKE '%רעננה%' THEN 'Raanana'
      WHEN p.City LIKE '%נשר%' THEN 'Nesher'
      ELSE 'Unknown'
    END) AS super_name_city,
    CASE 
      WHEN p.City LIKE '%חיפה%' THEN 'Haifa'
      WHEN p.City LIKE '%רעננה%' THEN 'Raanana'
      WHEN p.City LIKE '%נשר%' THEN 'Nesher'
      ELSE 'Unknown'
    END AS city,
    area 
  from `bqproj-435911.fp_israel_super_db.israel_supermarkets_polygons` p
  join `bqproj-435911.fp_adid_super_db.israel_super_adid_scheme` s on p.centroid=s.centroid
  WHERE  (p.City LIKE '%חיפה%' or 
       p.City LIKE '%רעננה%' or
       p.City LIKE '%נשר%' ) and(p.Name ='Carrefour' or p.Name LIKE '%שופרסל דיל%' or p.Name Like '%רמי לוי%')

)

SELECT 
  d.week_number,
  d.unique_devices,
  a.area,
  SAFE_DIVIDE(a.area, d.unique_devices) AS area_per_device
FROM device_counts d
JOIN super_areas a
ON d.super_name = a.super_name_city
WHERE d.super_name='Rami-Levi-Haifa'
ORDER BY d.super_name, d.week_number;


---שופרסל נשר
WITH cleaned_data AS (
  SELECT
    deviceid,
    'Carrefour-Raanana' AS super_name,
    'Raanana' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) AS ts,
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS week_number
  FROM `bqproj-435911.fp_adid_super_db.carrefour_raanana`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT
    deviceid,
    'Rami-Levi-Haifa' AS super_name,
    'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT
    deviceid,
    'Shufersal-Nesher' AS super_name,
    'Nesher' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150
),
device_counts AS (
  SELECT
    super_name,
    city,
    week_number,
    COUNT(DISTINCT deviceid) AS unique_devices
  FROM cleaned_data
  GROUP BY super_name, city, week_number
),

super_areas AS (
  SELECT
    CONCAT(
    CASE 
      WHEN p.Name LIKE '%שופרסל%' THEN 'Shufersal'
      WHEN p.Name LIKE '%רמי לוי%' THEN 'Rami-Levi'
      WHEN (p.Name LIKE '%קרפור%' OR p.Name LIKE '%Carrefour%') THEN 'Carrefour'
      ELSE 'Unknown'
    END,
    '-',
    CASE 
      WHEN p.City LIKE '%חיפה%' THEN 'Haifa'
      WHEN p.City LIKE '%רעננה%' THEN 'Raanana'
      WHEN p.City LIKE '%נשר%' THEN 'Nesher'
      ELSE 'Unknown'
    END) AS super_name_city,
    CASE 
      WHEN p.City LIKE '%חיפה%' THEN 'Haifa'
      WHEN p.City LIKE '%רעננה%' THEN 'Raanana'
      WHEN p.City LIKE '%נשר%' THEN 'Nesher'
      ELSE 'Unknown'
    END AS city,
    area 
  from `bqproj-435911.fp_israel_super_db.israel_supermarkets_polygons` p
  join `bqproj-435911.fp_adid_super_db.israel_super_adid_scheme` s on p.centroid=s.centroid
  WHERE  (p.City LIKE '%חיפה%' or 
       p.City LIKE '%רעננה%' or
       p.City LIKE '%נשר%' ) and(p.Name ='Carrefour' or p.Name LIKE '%שופרסל דיל%' or p.Name Like '%רמי לוי%')

)

SELECT 
  d.week_number,
  d.unique_devices,
  a.area,
  SAFE_DIVIDE(a.area, d.unique_devices) AS area_per_device
FROM device_counts d
JOIN super_areas a
ON d.super_name = a.super_name_city
WHERE d.super_name='Shufersal-Nesher'
ORDER BY d.super_name, d.week_number;




----------------------------------------dashboard-------------------------------
--data for devices
WITH cleaned_data AS (
  SELECT
    deviceid,
    'Carrefour' AS super_name,
    'Raanana' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) AS ts,
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS week_number
  FROM `bqproj-435911.fp_adid_super_db.carrefour_raanana`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT
    deviceid,
    'Rami-Levi' AS super_name,
    'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT
    deviceid,
    'Shufersal-Nesher' AS super_name,
    'Nesher' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL
  SELECT
  deviceid,
    'Shufersal-Haifa' AS super_name,
    'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(WEEK FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time))
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150
),


weekly_unique_devices AS (
  SELECT
    week_number,
    COUNT(DISTINCT deviceid) AS unique_devices,
    super_name,
    city
  FROM cleaned_data
  GROUP BY week_number,super_name,city
)

SELECT *
FROM weekly_unique_devices
ORDER BY week_number;

--heatmap data
WITH cleaned_data AS (
  SELECT 
    deviceid, 'Carrefour' AS super_name, 'Raanana' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) AS israel_time_ts,
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS clean_date,
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS hour,
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)) AS day_name,
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.carrefour_raanana`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Shufersal-Haifa' AS super_name, 'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Rami-Levi' AS super_name, 'Haifa' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.rami_levy_haifa`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

  UNION ALL

  SELECT 
    deviceid, 'Shufersal-Nesher' AS super_name, 'Nesher' AS city,
    PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time),
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    EXTRACT(HOUR FROM PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    FORMAT_TIMESTAMP('%A', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time)),
    latitude,
    longitude,
    accuracy
  FROM `bqproj-435911.fp_adid_super_db.shufersal_deal_nesher`
  WHERE deviceid IS NOT NULL AND eventtype IS NOT NULL AND accuracy IS NOT NULL
    AND PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', israel_time) IS NOT NULL
    AND accuracy < 150

),

activity_by_day_hour AS (
  SELECT
    super_name,
    city,
    day_name,
    hour,
    clean_date,
    deviceid
  FROM cleaned_data
  
)

SELECT *
FROM activity_by_day_hour
ORDER BY 
  CASE day_name
    WHEN 'Sunday' THEN 1
    WHEN 'Monday' THEN 2
    WHEN 'Tuesday' THEN 3
    WHEN 'Wednesday' THEN 4
    WHEN 'Thursday' THEN 5
    WHEN 'Friday' THEN 6
    WHEN 'Saturday' THEN 7
  END,
  hour;

--data for cities 
SELECT 
  l.`שם_ישוב` AS city,
  COUNT(s.centroid) AS num_supers,
  SUM(s.area) AS total_area,
  ROUND(SUM(s.area) / COUNT(s.centroid), 2) AS avg_area_per_super,
  l.`סהכ` AS total_population
FROM `bqproj-435911.fp_lamas_data.lamas_israel_2025` l
JOIN `bqproj-435911.fp_israel_super_db.israel_supermarkets_polygons` s
ON LOWER(l.`שם_ישוב`) LIKE CONCAT('%', LOWER(s.City), '%')
GROUP BY city, total_population
ORDER BY total_population DESC





-----------------------------------------------------------------------------------------



