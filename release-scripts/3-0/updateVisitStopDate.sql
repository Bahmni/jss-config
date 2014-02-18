### Update Visits with encounter datetime same as visit start date. Stop date would be day end of visit start date.

update visit v1
join visit v2 on v1.visit_id=v2.visit_id
left outer join encounter e on v2.visit_id = e.visit_id
set v1.date_stopped = addtime( cast(date(v2.date_started) as datetime), '0 23:59:59.0')
where date(v2.date_stopped) = '2013-09-23'
and date(e.encounter_datetime) <= date(v2.date_started);



### Update Visits with encounter datetime greater than visit start date. Stop date would be day end of last encounter datetime.

#update visit v1
#join visit v2 on v1.visit_id=v2.visit_id
#join encounter e on v2.visit_id = e.visit_id
#set v1.date_stopped = addtime( cast(date( (select max(e.encounter_datetime)) ) as datetime), '0 23:59:59.0') -- this will not work
#where date(v2.date_stopped) = '2013-09-23'
#and date(e.encounter_datetime) > date(v2.date_started);


### Update Visits with stop date as null. Stop date would be day end of visit start date.

update visit v1
join visit v2 on v1.visit_id=v2.visit_id
left outer join encounter e on v2.visit_id = e.visit_id
set v1.date_stopped = addtime( cast(date(v2.date_started) as datetime), '0 23:59:59.0')
where date(v2.date_stopped) is null and date(v2.date_started) <> curdate()
and date(e.encounter_datetime) <= date(v2.date_started);


### Update Visits with stop date as null. Stop date would be day end of last encounter datetime.

#update visit v1
#join visit v2 on v1.visit_id=v2.visit_id
#join encounter e on v2.visit_id = e.visit_id
#set v1.date_stopped = addtime( cast(date( (select max(e.encounter_datetime)) ) as datetime), '0 23:59:59.0') -- this will not work
#where date(v2.date_stopped) is null and date(v2.date_stopped) <> curdate()
#and date(e.encounter_datetime) > date(v2.date_started);


