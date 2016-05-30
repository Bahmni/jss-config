

select patient_identifier.identifier ,person_name.given_name, person_name.family_name, person.gender,DATEDIFF(curdate(), person.birthdate) /365, person_address.city_village village, person_address.address3, person_address.county_district, person_address.state_province, class.name, date(person.date_created), GROUP_CONCAT(DISTINCT diagnosisname.name), GROUP_CONCAT(DISTINCT formname.name),GROUP_CONCAT(DISTINCT drug.name)
from  patient_identifier inner join person ON (patient_identifier.patient_id = person.person_id and date(person.date_created) between '#startDate#' and '#endDate#')
      inner join person_name  ON person.person_id = person_name.person_id
      inner join person_address ON (person.person_id = person_address.person_id)
      left join person_attribute ON ( person.person_id = person_attribute.person_id AND person_attribute_type_id = 15)
      left join concept_name class ON (class.concept_id = person_attribute.value AND class.concept_name_type = 'FULLY_SPECIFIED')
      left join obs diagnosis ON ( diagnosis.person_id = person.person_id AND diagnosis.concept_id = 43 )
      left join concept_name diagnosisname ON (diagnosis.value_coded = diagnosisname.concept_id AND diagnosisname.concept_name_type = 'FULLY_SPECIFIED')
      left join obs form ON form.person_id = person.person_id
      left join concept_set ON (form.concept_id = concept_set.concept_id AND concept_set.concept_set = 2122)
      left join concept_name formname ON (formname.concept_id = concept_set.concept_id AND formname.concept_name_type = 'FULLY_SPECIFIED')
      left join orders ON patient_identifier.patient_id = orders.patient_id
      left join drug ON orders.concept_id = drug.concept_id
GROUP BY patient_identifier.identifier ;
