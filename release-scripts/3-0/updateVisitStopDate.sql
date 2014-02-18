### Update Visits with encounter datetime same as visit start date

update visit v1
join visit v2 on v1.visit_id=v2.visit_id
join encounter e on v2.visit_id = e.visit_id
set v1.date_stopped = addtime( cast(date(v2.date_started) as datetime), '0 23:59:59.0')
where date(v2.date_stopped) = '2013-09-23'
and date(e.encounter_datetime) <= date(v2.date_started);



### Update Visits with encounter datetime greater than visit start date

update visit v1
join visit v2 on v1.visit_id=v2.visit_id
join encounter e on v2.visit_id = e.visit_id
set v1.date_stopped = addtime( cast(date(e.encounter_datetime) as datetime), '0 23:59:59.0')
where date(v2.date_stopped) = '2013-09-23'
and date(e.encounter_datetime) > date(v2.date_started);