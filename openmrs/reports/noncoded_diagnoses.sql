select distinct(o.value_text) as 'Non-Coded Diagnosis', date(o.date_created) as Date, pi.identifier as Patient, concat(pn.given_name, IFNULL(pn.family_name, '')) as Provider
from obs o
  join encounter e on e.encounter_id = o.encounter_id
  join encounter_provider ep on ep.encounter_id = e.encounter_id
  join provider p on p.provider_id = ep.provider_id
  join person pp on pp.person_id=p.person_id
  join person_name pn on pn.person_id=pp.person_id
  join patient_identifier pi on pi.patient_id = o.person_id
where o.concept_id= (select concept_id from concept_name where name='Non-Coded Diagnosis' and concept_name_type='FULLY_SPECIFIED')
      AND date(obs_datetime) BETWEEN  '#startDate#' and '#endDate#'
order by o.value_text;