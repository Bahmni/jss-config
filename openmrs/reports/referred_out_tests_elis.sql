select PID.identity_data as "Patient Id", concat(person.first_name,' ', person.last_name) as "Name",
  type_of_sample.description "Sample", test.name "Test",
  organization.name "Centre", referral.requester_name "Requester",
  date(referral.referral_request_date) as "Request Date", date(result.lastupdated) as "Result Date"
from clinlims.referral
LEFT JOIN clinlims.organization ON referral.organization_id = organization.id 
LEFT JOIN clinlims.analysis ON referral.analysis_id = analysis.id
LEFT JOIN clinlims.test ON analysis.test_id = test.id
LEFT JOIN clinlims.sample_item ON analysis.sampitem_id = sample_item.id 
LEFT JOIN clinlims.sample_human ON sample_item.samp_id = sample_human.samp_id
LEFT JOIN clinlims.type_of_sample  ON type_of_sample.id = sample_item.typeosamp_id
LEFT JOIN clinlims.patient_identity PID ON (sample_human.patient_id = PID.patient_id AND PID.identity_type_id = 2) 
LEFT JOIN clinlims.patient ON (patient.id = sample_human.patient_id)
LEFT JOIN clinlims.person ON (person.id = patient.person_id) 
LEFT JOIN clinlims.result ON result.analysis_id = analysis.id
WHERE date(referral_request_date) between '#startDate#' and '#endDate#'
;
