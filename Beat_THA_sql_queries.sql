{\rtf1\ansi\ansicpg1252\cocoartf2580
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 -- question1\
\
select id_request, latitude,longitude from request\
where cast(strftime('%W', created_at) as integer) =11\
\
\
-- question2\
-- option 1\
select date(created_at) as request_date, strftime('%W', created_at)  as week_number,\
count(distinct id_request)  as requests_per_day \
from request \
where (cast(strftime('%W', created_at) as integer) =11\
OR cast(strftime('%W', created_at) as integer) =10)\
and cast(strftime('%Y', created_at) as integer) =2018\
group by date(created_at) ,\
strftime('%W', created_at) \
\
-- option 2\
WITH \
  weeks(week_number) AS (\
   SELECT 11\
  )\
\
\
select date(created_at) as request_date, strftime('%W', created_at)  as week_number,\
count(distinct id_request)  as requests_per_day \
from request \
where \
cast(strftime('%W', created_at) as integer) = (select distinct cast(week_number as integer)from weeks)\
AND cast(strftime('%Y', created_at) as integer) =2018\
group by date(created_at) ,\
strftime('%W', created_at) \
\
UNION\
\
select date(created_at) as request_date, strftime('%W', created_at)  as week_number,\
count(distinct id_request)  as requests_per_day \
from request \
where \
cast(strftime('%W', created_at) as integer) IN (select distinct cast(week_number as integer)-1 from weeks)\
AND cast(strftime('%Y', created_at) as integer) =2018\
group by date(created_at) ,\
strftime('%W', created_at) \
\
\
\
-- question3\
\
select count(*) from ride where actual_revenue = 0 -- 16507\
select count(*) from ride where actual_revenue > 0 -- 85596\
select count(*) from ride - 102103\
\
\
SELECT fare.id_passenger,  count(distinct ride.id_request) as no_of_rides\
FROM fare_snapshot fare\
JOIN ride ride\
ON fare. id_request = ride.id_request\
WHERE ride.actual_revenue>0\
AND  cast(strftime('%W', ride.created_at) as integer) =11\
group by fare.id_passenger \
order by  count(distinct ride.id_request) desc\
\
\
-- question 4\
select \
a.per_weekday,\
case \
  when a.per_weekday=0 then 'Sunday'\
  when a.per_weekday=1 then 'Monday'\
  when a.per_weekday=2 then 'Tuesday'\
  when a.per_weekday=3 then 'Wednesday'\
  when a.per_weekday=4 then 'Thursday'\
  when a.per_weekday=5 then 'Friday'\
  else 'Saturday' end as per_weekday_name\
, a.per_hour,  \
coalesce(cast(a.total_requests as float)/cast(b.total_rides as float),0) as request_to_ride_ratio\
from\
\
(select cast(strftime('%w',created_at) as integer) as per_weekday, strftime('%H',created_at) as per_hour, count(distinct id_request) as total_requests \
from request \
where cast(strftime('%W', created_at) as integer) =11\
group by strftime('%w',created_at), strftime('%H',created_at))a\
\
LEFT JOIN\
\
(select cast( strftime('%w',created_at)as integer) as per_weekday, strftime('%H',created_at) as per_hour, count(distinct id_request) as total_rides\
from ride\
where actual_revenue>0\
AND  cast(strftime('%W', created_at) as integer) =11\
group by strftime('%w',created_at), strftime('%H',created_at))b\
\
ON a.per_hour = b.per_hour\
AND a.per_weekday = b.per_weekday\
order by 1\
\
\
\
-- question 5\
\
SELECT  date(ride_request_time) as ride_request_day , CASE WHEN credit_or_Cash = 1 THEN 'CREDIT' ELSE 'CASH' END as cash_or_credit, count(distinct id_request) as completed_rides_per_day\
 FROM(\
SELECT id_passenger, id_request, ride_request_time, max(cridit_or_cash) as credit_or_Cash from(\
SELECT fare.id_passenger, ride.id_request, ride.created_at as ride_request_time, pay.created_at, pay.deleted_at,\
CASE WHEN ride.created_at> pay.created_at and pay.deleted_at is NULL THEN 1\
            WHEN ride.created_at> pay.created_at and ride.created_at< pay.deleted_at  THEN 1\
						ELSE 0 END as cridit_or_cash\
FROM fare_snapshot fare\
JOIN ride ride\
ON fare.id_request = ride.id_request\
AND  ride.actual_revenue>0\
AND cast(strftime('%W', ride.created_at) as integer) =11\
LEFT JOIN payment_mean_history pay\
ON fare.id_passenger = pay.id_passenger\
\
)\
GROUP BY id_passenger, id_request, ride_request_time)\
GROUP BY date(ride_request_time), CASE WHEN credit_or_Cash = 1 THEN 'CREDIT' ELSE 'CASH' END\
\
}