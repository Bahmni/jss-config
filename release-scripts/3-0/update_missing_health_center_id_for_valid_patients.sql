update patient set health_center_id = result.health_center_id
from (
select distinct p.id, hc.id  
from patient p
left outer join patient_identity pi on pi.patient_id = p.id and pi.identity_type_id = 2
left outer join health_center hc on hc.name = substring(pi.identity_data, 1,3)
where p.health_center_id is null
and pi.identity_data is not null
order by p.id
) as result (patient_id, health_center_id) 
where id = result.patient_id;